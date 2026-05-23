#!/usr/bin/env python3
"""
Fetch a Mobalytics PoE2 build URL and emit a slim JSON describing it.

The page embeds the full document tree in `window.__PRELOADED_STATE__`
as JSON. We extract that, walk the document's content tree (Lexical
nodes) for textual sections, and pull structured equipment + skill gems
straight from the first buildVariant. Output is one line of JSON for
QML to JSON.parse — small enough to fit comfortably in StdioCollector.

Usage:
    mob-extract.py <url>

Exit codes:
    0  → success, JSON on stdout
    1  → fetch/parse failure, error message on stderr
"""

import json
import re
import sys
import urllib.request


USER_AGENT = (
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/120.0 Safari/537.36"
)

SLOT_ORDER = [
    "mainHand", "offHand", "helmet", "body", "gloves", "boots",
    "belt", "amulet", "leftRing", "rightRing", "extraRing",
    "flask1", "flask2", "charm1", "charm2", "charm3",
]
SLOT_LABELS = {
    "mainHand":  "Main Hand", "offHand":  "Off Hand",
    "body":      "Body Armour",
    "leftRing":  "Ring (L)",  "rightRing": "Ring (R)",
    "extraRing": "Ring (Extra)",
    "flask1":    "Flask 1",   "flask2":    "Flask 2",
    "charm1":    "Charm 1",   "charm2":    "Charm 2",  "charm3": "Charm 3",
}


def fetch(url):
    req = urllib.request.Request(url, headers={
        "User-Agent":      USER_AGENT,
        "Accept":          "text/html,application/xhtml+xml",
        "Accept-Language": "en-US,en;q=0.9",
    })
    with urllib.request.urlopen(req, timeout=20) as resp:
        return resp.read().decode("utf-8", errors="replace")


def extract_state(html):
    marker = "window.__PRELOADED_STATE__="
    idx = html.find(marker)
    if idx == -1:
        raise RuntimeError("__PRELOADED_STATE__ not found")
    s = html[idx + len(marker):]
    depth = 0
    end = -1
    for i, c in enumerate(s):
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                end = i + 1
                break
    if end == -1:
        raise RuntimeError("malformed JSON")
    return json.loads(s[:end])


def find_document(state):
    queries = (
        state.get("poe2State", {})
             .get("apollo", {})
             .get("graphqlV2", {})
             .get("queries", [])
    )
    for q in queries:
        data = (q.get("state") or {}).get("data")
        if not data:
            continue
        rows = data if isinstance(data, list) else [data]
        for row in rows:
            doc = (
                (((row or {}).get("game") or {}).get("documents") or {})
                .get("userGeneratedDocumentBySlug")
            )
            if doc and doc.get("data"):
                return doc["data"]
    raise RuntimeError("build document not found in state")


def node_text(node, depth=0):
    if not node:
        return ""
    t = node.get("type")
    if t == "text":
        return node.get("text", "")
    if t == "static-data-widget":
        label = node.get("label")
        return f"[{label}]" if label else ""
    inner = "".join(node_text(c, depth + 1) for c in node.get("children") or [])
    if t == "heading":
        tag = (node.get("tag") or "h2").lower()
        hashes = {"h1": "#", "h2": "##", "h3": "###"}.get(tag, "####")
        return f"\n{hashes} {inner}\n"
    if t == "listitem":
        return f"• {inner}\n"
    if t in ("list", "paragraph"):
        return inner + "\n"
    if t == "linebreak":
        return "\n"
    return inner


def lexical_to_text(value):
    if not value or not value.get("root"):
        return ""
    return node_text(value["root"]).strip()


def lexical_to_list(value):
    items = []

    def walk(node):
        if not node:
            return
        if node.get("type") == "listitem":
            t = node_text(node).lstrip("• ").strip()
            if t:
                items.append(t)
            return
        for c in node.get("children") or []:
            walk(c)

    if value and value.get("root"):
        walk(value["root"])
    return items


def slug_to_name(slug):
    if not slug:
        return ""
    s = re.sub(r"^support", "", slug, flags=re.I)
    s = re.sub(r"player$", "", s, flags=re.I)
    s = re.sub(r"(two|three)$", "", s, flags=re.I)
    s = re.sub(r"^new", "", s, flags=re.I)
    s = re.sub(r"([a-z])([A-Z])", r"\1 \2", s)
    return s[:1].upper() + s[1:]


def walk_content(by_id, root_id, sections, ctx, visited=None):
    if visited is None:
        visited = set()
    if root_id in visited:
        return
    visited.add(root_id)
    block = by_id.get(root_id)
    if not block:
        return
    add_block(block, sections, ctx)
    for cid in (block.get("data") or {}).get("childrenIds") or []:
        walk_content(by_id, cid, sections, ctx, visited)


def content_index(content):
    """Return a dict mapping block id → block, regardless of source shape."""
    if isinstance(content, list):
        return {b.get("id"): b for b in content if isinstance(b, dict) and b.get("id")}
    if isinstance(content, dict):
        return {b.get("id", k): b for k, b in content.items() if isinstance(b, dict)}
    return {}


def add_block(block, sections, ctx=None):
    """ctx provides `by_id`, `variants_by_id`, and `variants_out` (the
    list to append variant tab entries to). General sections go in
    `sections`; variant tabs are extracted as separate top-level entries."""
    t = block.get("__typename")
    d = block.get("data") or {}
    if t == "NgfDocumentCmWidgetRichTextSimplifiedV2":
        sc = d.get("simplifiedContent") or {}
        body = lexical_to_text(sc.get("value"))
        if body:
            sections.append({"kind": "text", "title": d.get("title") or "", "body": body})
    elif t == "NgfDocumentCmWidgetStrengthsAndWeaknessesV1":
        sections.append({
            "kind": "strengths",
            "title": d.get("title") or "Strengths and Weaknesses",
            "strengths":  lexical_to_list((d.get("strengths")  or {}).get("value")),
            "weaknesses": lexical_to_list((d.get("weaknesses") or {}).get("value")),
        })
    elif t == "Poe2DocumentUgWidgetEquipmentV1":
        desc = (d.get("descriptionPoeEquipment") or {}).get("value")
        body = lexical_to_text(desc)
        if body:
            sections.append({"kind": "text", "title": d.get("title") or "Equipment notes", "body": body})
    elif t == "Poe2DocumentUgWidgetSkillGemsV1":
        desc = (d.get("descriptionPoeSkillGems") or {}).get("value")
        body = lexical_to_text(desc)
        if body:
            sections.append({"kind": "text", "title": d.get("title") or "Skill notes", "body": body})
    elif t == "Poe2DocumentUgWidgetPassiveTreeV1":
        desc = (d.get("descriptionPoe2PassiveTree") or {}).get("value")
        body = lexical_to_text(desc)
        if body:
            sections.append({"kind": "text", "title": d.get("title") or "Passive tree", "body": body})
    elif t == "Poe2DocumentUgWidgetAtlasTreeV1":
        desc = (d.get("descriptionPoe2AtlasTree") or {}).get("value")
        body = lexical_to_text(desc)
        if body:
            sections.append({"kind": "text", "title": d.get("title") or "Atlas tree", "body": body})
    elif t == "NgfDocumentCmWidgetContentVariantsV1" and ctx is not None:
        for v in d.get("childrenVariants") or []:
            vsec = []
            for cid in v.get("childrenIds") or []:
                child = ctx["by_id"].get(cid)
                if child:
                    add_block(child, vsec, ctx)
            bv = ctx["variants_by_id"].get(v.get("id")) or {}
            gear = variant_equipment(bv)
            if gear:
                vsec.append({"kind": "equipment_real", "title": "Gear", "items": gear})
            skills = variant_skills(bv)
            if skills:
                vsec.append({"kind": "skills_real", "title": "Skill Gems", "groups": skills})
            tree = variant_passive_summary(bv)
            if tree:
                vsec.append(tree)
            ctx["variants_out"].append({
                "id":          v.get("id"),
                "title":       v.get("title") or ("Variant " + str(v.get("id"))),
                "description": lexical_to_text((v.get("description") or {}).get("value")),
                "sections":    vsec,
            })


def _to_webp(url):
    """Mobalytics' CDN serves the same asset under .webp; rewrite from .avif so
    Qt6 (which lacks AVIF without an extra plugin) can render the icon."""
    if url and url.lower().endswith(".avif"):
        return url[: -len(".avif")] + ".webp"
    return url or ""


def variant_equipment(variant):
    items = []
    eq = variant.get("equipment") or {}
    for key in SLOT_ORDER:
        slot = eq.get(key)
        if not slot:
            continue
        c = slot.get("commonItem") or slot
        if not c or not c.get("name"):
            continue
        mods = [
            x["description"]
            for x in (c.get("explicitDescriptions") or [])
            if x.get("description")
        ]
        items.append({
            "slot":     SLOT_LABELS.get(key, key.title()),
            "name":     c["name"],
            "isUnique": bool(c.get("isUnique")),
            "iconUrl":  _to_webp(c.get("iconURL")),
            "mods":     mods,
        })
    return items


def variant_passive_summary(variant):
    pt = variant.get("passiveTree") or {}
    main = ((pt.get("mainTree") or {}).get("selectedSlugs")) or []
    ascend = ((pt.get("ascendancyTree") or {}).get("selectedSlugs")) or []
    jewels_raw = pt.get("jewels") or []
    if not main and not ascend and not jewels_raw:
        return None

    # Strip the "node-" prefix and convert to integers for the renderer.
    def to_ints(slugs):
        out = []
        for s in slugs:
            if not isinstance(s, str):
                continue
            num = s.split("-")[-1]
            try:
                out.append(int(num))
            except ValueError:
                pass
        return out

    allocated_ids = to_ints(main) + to_ints(ascend)
    jewels = []
    for j in jewels_raw:
        if not isinstance(j, dict):
            continue
        slug = j.get("jewelSlug") or ""
        # Slug format e.g. "jewel-fouruniquejewel4-megalomaniac" or
        # "jewel-jewelradiusint" (rare/magic placeholder).
        s = re.sub(r"^jewel-", "", slug)
        if j.get("isUnique"):
            # Strip the variable "fouruniquejewelN" / "newuniqueX" type prefix
            s = re.sub(r"^[a-z]+(unique)?jewel\d+-?", "", s)
            name = s.replace("-", " ").title() or "Unique Jewel"
        elif "radius" in s.lower():
            name = "Jewel (radius)"
        else:
            name = "Jewel"
        jewels.append({
            "name":     name,
            "iconUrl":  _to_webp(j.get("iconURL")),
            "isUnique": bool(j.get("isUnique")),
        })
    return {
        "kind":            "passive_summary",
        "title":           "Passive Tree",
        "mainCount":       len(main),
        "ascendancyCount": len(ascend),
        "jewels":          jewels,
        "allocatedIds":    allocated_ids,
        "ascendancyIds":   to_ints(ascend),
    }


def variant_skills(variant):
    groups = []
    for g in (variant.get("skillGems") or {}).get("gems") or []:
        active = g.get("activeSkill") or {}
        if not active.get("name") and not active.get("gemSlug"):
            continue
        supports = [
            slug_to_name(s.get("gemSlug") or "")
            for s in g.get("subSkills") or []
            if s.get("gemSlug")
        ]
        groups.append({
            "main":     active.get("name") or slug_to_name(active.get("gemSlug") or ""),
            "mainIcon": _to_webp(active.get("iconURL") or active.get("gemIconURL")),
            "supports": [s for s in supports if s],
            "level":    active.get("level") or 0,
        })
    return groups


def flatten(doc, source_url):
    d = doc.get("data") or {}
    content = doc.get("content") or {}
    variants = (d.get("buildVariants") or {}).get("values") or []
    variant = variants[0] if variants else {}

    tags = ((doc.get("tags") or {}).get("data")) or []

    def _tag_by_group(group):
        for t in tags:
            if t.get("groupSlug") == group:
                return t
        return None

    cls_tag    = _tag_by_group("class")
    ascend_tag = _tag_by_group("ascendancy")

    guide = {
        "id":             doc.get("id"),
        "slug":           doc.get("slugifiedName"),
        "url":            source_url,
        "name":           d.get("name") or doc.get("slugifiedName") or "Sin título",
        "author":         ((doc.get("author") or {}).get("displayName")
                           or (doc.get("author") or {}).get("username")
                           or (doc.get("author") or {}).get("name")
                           or "Anónimo"),
        "updatedAt":      doc.get("updatedAt") or doc.get("firstPublishedAt") or "",
        "coverImage":     d.get("backgroundImage") or "",
        "pobCode":        d.get("pobCode") or "",
        "charClass":      (cls_tag or {}).get("name") or "Otros",
        "classIcon":      _to_webp((cls_tag or {}).get("imageUrl")),
        "ascendancy":     (ascend_tag or {}).get("name") or "",
        "ascendancyIcon": _to_webp((ascend_tag or {}).get("imageUrl")),
        "sections":       [],
        "variants":       [],
    }

    by_id = content_index(content)
    ctx = {
        "by_id":           by_id,
        "variants_by_id":  {v.get("id"): v for v in variants if v.get("id") is not None},
        "variants_out":    guide["variants"],
    }
    if "root" in by_id:
        walk_content(by_id, "root", guide["sections"], ctx)
    else:
        for block in by_id.values():
            add_block(block, guide["sections"], ctx)

    # Fallback: if no variant tabs were found, emit first variant's content
    # as a synthetic single-tab so the UI still has gear/skills.
    if not guide["variants"] and variant:
        fallback = []
        gear = variant_equipment(variant)
        if gear:
            fallback.append({"kind": "equipment_real", "title": "Gear", "items": gear})
        skills = variant_skills(variant)
        if skills:
            fallback.append({"kind": "skills_real", "title": "Skill Gems", "groups": skills})
        if fallback:
            guide["variants"].append({
                "id": variant.get("id") or "default",
                "title": "Default",
                "description": "",
                "sections": fallback,
            })

    return guide


def main():
    if len(sys.argv) != 2:
        sys.stderr.write("usage: mob-extract.py <url>\n")
        return 1
    url = sys.argv[1]
    if "mobalytics.gg" not in url or "/builds/" not in url:
        sys.stderr.write("URL must be a mobalytics.gg/...build URL\n")
        return 1
    try:
        html  = fetch(url)
        state = extract_state(html)
        doc   = find_document(state)
        guide = flatten(doc, url)
        # ensure_ascii=True: escape non-ASCII as \uXXXX so Quickshell's
        # StdioCollector doesn't misread UTF-8 bytes as Latin-1.
        sys.stdout.write(json.dumps(guide, ensure_ascii=True))
        return 0
    except Exception as e:
        sys.stderr.write(f"{type(e).__name__}: {e}\n")
        return 1


if __name__ == "__main__":
    sys.exit(main())

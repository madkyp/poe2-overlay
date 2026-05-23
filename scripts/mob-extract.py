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


def walk_content(by_id, root_id, sections, visited=None):
    if visited is None:
        visited = set()
    if root_id in visited:
        return
    visited.add(root_id)
    block = by_id.get(root_id)
    if not block:
        return
    add_block(block, sections)
    for cid in (block.get("data") or {}).get("childrenIds") or []:
        walk_content(by_id, cid, sections, visited)


def content_index(content):
    """Return a dict mapping block id → block, regardless of source shape."""
    if isinstance(content, list):
        return {b.get("id"): b for b in content if isinstance(b, dict) and b.get("id")}
    if isinstance(content, dict):
        return {b.get("id", k): b for k, b in content.items() if isinstance(b, dict)}
    return {}


def add_block(block, sections):
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
            "iconUrl":  c.get("iconURL") or "",
            "mods":     mods,
        })
    return items


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
            "mainIcon": active.get("iconURL") or active.get("gemIconURL") or "",
            "supports": [s for s in supports if s],
            "level":    active.get("level") or 0,
        })
    return groups


def flatten(doc, source_url):
    d = doc.get("data") or {}
    content = doc.get("content") or {}
    variants = (d.get("buildVariants") or {}).get("values") or []
    variant = variants[0] if variants else {}

    guide = {
        "id":         doc.get("id"),
        "slug":       doc.get("slugifiedName"),
        "url":        source_url,
        "name":       d.get("name") or doc.get("slugifiedName") or "Sin título",
        "author":     ((doc.get("author") or {}).get("displayName")
                       or (doc.get("author") or {}).get("username")
                       or (doc.get("author") or {}).get("name")
                       or "Anónimo"),
        "updatedAt":  doc.get("updatedAt") or doc.get("firstPublishedAt") or "",
        "coverImage": d.get("backgroundImage") or "",
        "pobCode":    d.get("pobCode") or "",
        "sections":   [],
    }

    by_id = content_index(content)
    if "root" in by_id:
        walk_content(by_id, "root", guide["sections"])
    else:
        for block in by_id.values():
            add_block(block, guide["sections"])

    gear = variant_equipment(variant)
    if gear:
        guide["sections"].append({"kind": "equipment_real", "title": "Gear", "items": gear})

    skills = variant_skills(variant)
    if skills:
        guide["sections"].append({"kind": "skills_real", "title": "Skill Gems", "groups": skills})

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
        sys.stdout.write(json.dumps(guide, ensure_ascii=False))
        return 0
    except Exception as e:
        sys.stderr.write(f"{type(e).__name__}: {e}\n")
        return 1


if __name__ == "__main__":
    sys.exit(main())

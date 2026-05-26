#!/usr/bin/env python3
"""
Fetch the official Path of Exile 2 passive-tree data from
grindinggear/poe2-skilltree-export and convert it to the slim JSON
our renderer consumes.

This is the *official* GGG-published data, updated alongside each PoE2
patch (0.4, 0.5, …). Replaces the previous PoB Community Lua-based
pipeline.

The official format is JSON already so no Lua interpreter is needed.
Small adapter step rewrites it into the format the rest of the app
expects (mainly: turn the `out` array of string ids into a
`connections` array of `{id: <int>}` objects, and resolve
`ascendancyId` to a human-readable `ascendancyName`).

Output paths (compatible with previous pipeline):
  ~/.config/quickshell/poe2/.cache/tree.json     (slim JSON used by QML)
  ~/.config/quickshell/poe2/.cache/tree.version  (e.g. "0.5.0")

Usage:
  fetch-tree.py            # download latest release + convert
  fetch-tree.py --tag 0.4.0  # pin to a specific release
"""

import json
import os
import sys
import urllib.request

REPO_API = "https://api.github.com/repos/grindinggear/poe2-skilltree-export"
RAW      = "https://raw.githubusercontent.com/grindinggear/poe2-skilltree-export"

CACHE_DIR  = os.path.expanduser("~/.config/quickshell/poe2/.cache")
ASSETS_DIR = os.path.join(CACHE_DIR, "assets")
JSON_FILE  = os.path.join(CACHE_DIR, "tree.json")
VER_FILE   = os.path.join(CACHE_DIR, "tree.version")

# Sprite atlases we mirror locally so QML can render proper frames + icons
# without hammering Mobalytics' CDN for every node icon.
ASSETS = [
    "frame.json",  "frame.webp",
    "skills.json", "skills.webp",
    "skills-disabled.json", "skills-disabled.webp",
    "group-background.json", "group-background.webp",
    "line.json", "line.webp",
]


def gh_get(url):
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.read()


def pick_latest_tag():
    """Pick the highest semver-style tag. GitHub's /latest endpoint follows
    the 'latest' marker which isn't always the newest version."""
    releases = json.loads(gh_get(f"{REPO_API}/releases"))
    versions = []
    for r in releases:
        tag = r.get("tag_name", "")
        try:
            parts = tuple(int(p) for p in tag.split("."))
            versions.append((parts, tag))
        except ValueError:
            pass
    if not versions:
        raise RuntimeError("no tagged releases found")
    versions.sort()
    return versions[-1][1]


def download_data(tag):
    sys.stderr.write(f"Downloading data.json @ {tag}\n")
    raw = gh_get(f"{RAW}/{tag}/data.json")
    sys.stderr.write(f"Got {len(raw)} bytes\n")
    return json.loads(raw)


def download_assets(tag):
    """Mirror the GGG asset atlases locally."""
    os.makedirs(ASSETS_DIR, exist_ok=True)
    for name in ASSETS:
        url = f"{RAW}/{tag}/assets/{name}"
        sys.stderr.write(f"Downloading assets/{name}\n")
        data = gh_get(url)
        with open(os.path.join(ASSETS_DIR, name), "wb") as f:
            f.write(data)
        sys.stderr.write(f"  {len(data)} bytes\n")


def build_ascendancy_id_map(classes):
    """Map e.g. 'Warrior3' → 'Smith of Kitava'."""
    out = {}
    for c in classes or []:
        for a in c.get("ascendancies") or []:
            aid = a.get("id")
            name = a.get("name")
            if aid and name:
                out[aid] = name
    return out


def convert(data, tag):
    asc_map = build_ascendancy_id_map(data.get("classes") or [])

    out = {
        "groups":    {},
        "nodes":     {},
        "classes":   {},
        "constants": {},   # left empty — official data uses pre-computed x/y
        "min_x": data.get("min_x", 0),
        "min_y": data.get("min_y", 0),
        "max_x": data.get("max_x", 0),
        "max_y": data.get("max_y", 0),
        "ggg_version": tag,
    }

    # ── Groups: pass through with same field names
    for gid, g in (data.get("groups") or {}).items():
        out["groups"][gid] = {
            "x":       g.get("x"),
            "y":       g.get("y"),
            "orbits":  g.get("orbits"),
            "nodes":   g.get("nodes"),
        }

    # ── Nodes: adapt to old field shape
    for nid, n in (data.get("nodes") or {}).items():
        # Build a connections array shaped like PoB's: [{id: int, orbit: int?}]
        connections = []
        for tgt in n.get("out") or []:
            try:
                connections.append({"id": int(tgt)})
            except (ValueError, TypeError):
                pass
        # GGG stores edges bidirectionally; out already covers each edge.
        out["nodes"][nid] = {
            "name":           n.get("name"),
            "icon":           n.get("icon"),
            "stats":          n.get("stats"),
            "group":          n.get("group"),
            "orbit":          n.get("orbit"),
            "orbitIndex":     n.get("orbitIndex"),
            "x":              n.get("x"),
            "y":              n.get("y"),
            "connections":    connections,
            "isNotable":      n.get("isNotable"),
            "isKeystone":     n.get("isKeystone"),
            "isJewelSocket":  n.get("isJewelSocket"),
            "isMastery":      n.get("isMastery"),
            "ascendancyName": asc_map.get(n.get("ascendancyId")) or "",
            "classStartIndex": n.get("classStartIndex"),
        }

    # ── Classes table: same shape as before (id → { name, ascendancies })
    for i, c in enumerate(data.get("classes") or []):
        out["classes"][str(i)] = {
            "name":         c.get("name"),
            "base_str":     c.get("base_str"),
            "base_dex":     c.get("base_dex"),
            "base_int":     c.get("base_int"),
            "ascendancies": [
                {"name": a.get("name"), "id": a.get("id")}
                for a in (c.get("ascendancies") or [])
                if a.get("name")
            ],
        }

    return out


def main():
    tag = None
    if "--tag" in sys.argv:
        tag = sys.argv[sys.argv.index("--tag") + 1]
    try:
        if not tag:
            tag = pick_latest_tag()
        sys.stderr.write(f"Using GGG tree release {tag}\n")
        data = download_data(tag)
        download_assets(tag)
        out = convert(data, tag)
        os.makedirs(CACHE_DIR, exist_ok=True)
        with open(JSON_FILE, "w", encoding="utf-8") as f:
            json.dump(out, f, ensure_ascii=False)
        with open(VER_FILE, "w") as f:
            f.write(tag)
        size = os.path.getsize(JSON_FILE)
        sys.stderr.write(f"Wrote {size} bytes ({len(out['nodes'])} nodes, "
                         f"{len(out['groups'])} groups)\n")
        sys.stdout.write(f"OK {size}\n")
        return 0
    except Exception as e:
        sys.stderr.write(f"{type(e).__name__}: {e}\n")
        return 1


if __name__ == "__main__":
    sys.exit(main())

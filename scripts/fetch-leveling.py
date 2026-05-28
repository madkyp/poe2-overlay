#!/usr/bin/env python3
"""
Fetch PoE2 leveling-guide data from Lailloken/Exile-UI (MIT-licensed)
and convert it into a single slim JSON our QML widget can consume.

Output:
  ~/.config/quickshell/poe2/.cache/leveling.json

Structure:
{
  "zones": {
    "<lowercase zone name>": {
       "id":              "g1_1",
       "name":            "The Riverbank",
       "recommendation":  "2 | 2",
       "steps":           [{"text": "kill the_bloated_miller"}, ...],
       "act":             "Act 1"
    },
    ...
  }
}

Steps still carry the raw Exile-UI markup like (img:skill), (color:red),
(hint), areaid… — QML cleans / interprets it at render time.
"""

import json
import os
import re
import sys
import urllib.parse
import urllib.request

REPO    = "Lailloken/Exile-UI"
RAW     = f"https://raw.githubusercontent.com/{REPO}/main"
AREAS   = "data/english/[leveltracker] areas 2.json"
GUIDE   = "data/english/[leveltracker] default guide 2.json"

CACHE_DIR = os.path.expanduser("~/.config/quickshell/poe2/.cache")
OUT_FILE  = os.path.join(CACHE_DIR, "leveling.json")


def fetch(path):
    url = RAW + "/" + urllib.parse.quote(path)
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    sys.stderr.write(f"Downloading {url}\n")
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.read()


def main():
    try:
        areas_raw = fetch(AREAS)
        guide_raw = fetch(GUIDE)
    except Exception as e:
        sys.stderr.write(f"Download failed: {e}\n")
        return 1

    areas = json.loads(areas_raw)
    guide = json.loads(guide_raw)

    # Build id → metadata map. areas is a list of sections, each section is
    # a list of area entries. Sections map to the 0.5 campaign structure:
    # 4 acts (g1–g4) + 3 interludes (p1–p3) + endgame.
    act_names = ["Act 1", "Act 2", "Act 3", "Act 4",
                 "Interludio 1", "Interludio 2", "Interludio 3", "Endgame"]
    id_to_meta = {}
    for sect_idx, sect in enumerate(areas):
        act = act_names[sect_idx] if sect_idx < len(act_names) else f"Section {sect_idx + 1}"
        if not isinstance(sect, list):
            continue
        for entry in sect:
            aid  = entry.get("id")
            name = entry.get("name") or ""
            if not aid:
                continue
            id_to_meta[aid] = {
                "id":             aid,
                "name":           name,
                "recommendation": entry.get("recommendation") or "",
                "act":            act,
                "steps":          [],
            }

    # Walk the guide. Each section is a list of step-groups. The "current
    # zone" for a group is the zone the player is in WHEN the group's
    # instructions run — i.e. the destination of the previous group's last
    # `enter`. Each section starts at that section's first area, derived
    # from the matching areas section (robust against id changes between
    # versions, e.g. g4_town / p1_town in 0.5).
    enter_re   = re.compile(r"areaid([a-zA-Z0-9_]+)")
    sect_first = []
    for sect in areas:
        if isinstance(sect, list) and sect and sect[0].get("id"):
            sect_first.append(sect[0]["id"])
        else:
            sect_first.append(None)
    for sect_idx, sect in enumerate(guide):
        if not isinstance(sect, list):
            continue
        current_zone = sect_first[sect_idx] if sect_idx < len(sect_first) else None
        for group in sect:
            if not isinstance(group, list):
                continue
            if current_zone and current_zone in id_to_meta:
                id_to_meta[current_zone]["steps"].append({"text": "\n".join(group)})
            # Whatever this group's last `enter` is becomes the new zone
            joined = " ".join(group)
            matches = enter_re.findall(joined)
            if matches:
                current_zone = matches[-1]

    # Reindex by lowercase zone name for the runtime lookup
    out = {"zones": {}}
    for aid, meta in id_to_meta.items():
        key = (meta.get("name") or "").strip().lower()
        if key:
            out["zones"][key] = meta

    os.makedirs(CACHE_DIR, exist_ok=True)
    with open(OUT_FILE, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False)
    size = os.path.getsize(OUT_FILE)
    sys.stderr.write(f"Wrote {size} bytes; {len(out['zones'])} zones\n")
    sys.stdout.write(f"OK {size}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""
Fetch the latest PoE2 passive-tree data from Path of Building Community
and convert it to the slim JSON our renderer consumes.

The PoB repo stores tree data in Lua tables at
https://raw.githubusercontent.com/PathOfBuildingCommunity/PathOfBuilding-PoE2/master/src/TreeData/<version>/tree.lua

This script:
  1. Picks the highest-numbered version directory under TreeData/
  2. Downloads tree.lua to the cache
  3. Runs scripts/tree-lua-to-json.lua to slim it down
  4. Writes <cache>/tree.json
  5. Echoes "OK <size>" or an error to stderr

Output paths:
  cache_dir = ~/.config/quickshell/poe2/.cache
  cache_dir/tree.lua    (raw upstream)
  cache_dir/tree.json   (slim, used by QML)
  cache_dir/tree.version (the PoB version directory we used)

Usage:
  fetch-tree.py            # full download + convert
  fetch-tree.py --convert  # skip download, reuse cached tree.lua
"""

import json
import os
import subprocess
import sys
import urllib.request

REPO_API   = "https://api.github.com/repos/PathOfBuildingCommunity/PathOfBuilding-PoE2/contents/src/TreeData"
RAW_PREFIX = "https://raw.githubusercontent.com/PathOfBuildingCommunity/PathOfBuilding-PoE2/master/src/TreeData"

HERE       = os.path.dirname(os.path.realpath(__file__))
CACHE_DIR  = os.path.expanduser("~/.config/quickshell/poe2/.cache")
LUA_FILE   = os.path.join(CACHE_DIR, "tree.lua")
JSON_FILE  = os.path.join(CACHE_DIR, "tree.json")
VER_FILE   = os.path.join(CACHE_DIR, "tree.version")
CONVERTER  = os.path.join(HERE, "tree-lua-to-json.lua")


def pick_latest_version():
    req = urllib.request.Request(REPO_API, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=20) as resp:
        entries = json.loads(resp.read())
    versions = []
    for e in entries:
        n = e.get("name", "")
        if e.get("type") == "dir" and "_" in n:
            try:
                versions.append((tuple(int(p) for p in n.split("_")), n))
            except ValueError:
                pass
    if not versions:
        raise RuntimeError("no tree-data versions found in PoB repo")
    versions.sort()
    return versions[-1][1]


def download(version):
    url = f"{RAW_PREFIX}/{version}/tree.lua"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    sys.stderr.write(f"Downloading {url}\n")
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = resp.read()
    os.makedirs(CACHE_DIR, exist_ok=True)
    with open(LUA_FILE, "wb") as f:
        f.write(data)
    with open(VER_FILE, "w") as f:
        f.write(version)
    sys.stderr.write(f"Saved {len(data)} bytes to {LUA_FILE}\n")


def convert():
    if not os.path.exists(LUA_FILE):
        raise RuntimeError(f"missing {LUA_FILE} — run without --convert first")
    sys.stderr.write(f"Converting {LUA_FILE} → {JSON_FILE}\n")
    with open(JSON_FILE, "w") as out:
        r = subprocess.run(["lua", CONVERTER, LUA_FILE], stdout=out, stderr=subprocess.PIPE)
    if r.returncode != 0:
        raise RuntimeError("lua converter failed: " + r.stderr.decode("utf-8", "replace"))
    size = os.path.getsize(JSON_FILE)
    sys.stderr.write(f"Wrote {size} bytes\n")
    return size


def main():
    convert_only = "--convert" in sys.argv
    try:
        if not convert_only:
            version = pick_latest_version()
            sys.stderr.write(f"Using PoB tree version {version}\n")
            download(version)
        size = convert()
        sys.stdout.write(f"OK {size}\n")
        return 0
    except Exception as e:
        sys.stderr.write(f"{type(e).__name__}: {e}\n")
        return 1


if __name__ == "__main__":
    sys.exit(main())

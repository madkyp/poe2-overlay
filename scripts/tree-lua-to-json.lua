#!/usr/bin/env lua
-- tree-lua-to-json.lua
--
-- Convert Path of Building Community's PoE2 tree.lua into a slim JSON file
-- containing just the fields we need to render the passive tree:
--   - groups: x, y, orbits (array)
--   - nodes:  name, stats, icon, group, orbit, orbitIndex, connections (ids),
--             isNotable, isKeystone, isJewelSocket, isMastery, ascendancyName,
--             classStartIndex (for class starting positions)
--   - constants.orbitRadii  (radius per orbit level)
--   - constants.skillsPerOrbit (slots in each orbit ring)
--
-- Usage:
--   lua tree-lua-to-json.lua <path-to-tree.lua> > tree.json

local treePath = arg[1]
if not treePath then
    io.stderr:write("usage: lua tree-lua-to-json.lua <tree.lua>\n")
    os.exit(1)
end

local function escape(s)
    s = s:gsub("\\", "\\\\")
    s = s:gsub('"',  '\\"')
    s = s:gsub("\n", "\\n")
    s = s:gsub("\r", "\\r")
    s = s:gsub("\t", "\\t")
    return s
end

local function enc(v)
    local t = type(v)
    if t == "string" then return '"' .. escape(v) .. '"' end
    if t == "number" then
        if v ~= v then return "null" end   -- NaN
        return tostring(v)
    end
    if t == "boolean" then return v and "true" or "false" end
    if t == "nil"     then return "null" end
    if t == "table" then
        local isArr, max = true, 0
        for k, _ in pairs(v) do
            if type(k) ~= "number" then isArr = false; break end
            if k > max then max = k end
        end
        if isArr then
            local parts = {}
            for i = 1, max do parts[#parts+1] = enc(v[i]) end
            return "[" .. table.concat(parts, ",") .. "]"
        end
        local parts = {}
        for k, vv in pairs(v) do
            parts[#parts+1] = '"' .. escape(tostring(k)) .. '":' .. enc(vv)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return "null"
end

-- Load the file as a Lua expression returning the tree table.
local chunk, err = loadfile(treePath)
if not chunk then
    io.stderr:write("loadfile failed: " .. tostring(err) .. "\n")
    os.exit(1)
end
local tree = chunk()

-- ─── Slim down: keep only the fields the renderer needs ────────────
local out = {
    groups    = {},
    nodes     = {},
    constants = {
        orbitRadii      = (tree.constants or {}).orbitRadii,
        skillsPerOrbit  = (tree.constants or {}).skillsPerOrbit,
    },
    classes   = {},
    min_x = (tree.min_x or 0), min_y = (tree.min_y or 0),
    max_x = (tree.max_x or 0), max_y = (tree.max_y or 0),
}

for gid, g in pairs(tree.groups or {}) do
    out.groups[tostring(gid)] = {
        x       = g.x,
        y       = g.y,
        orbits  = g.orbits,
        nodes   = g.nodes,
        isAscendancyStart = g.isAscendancyStart,
        isProxy = g.isProxy,
    }
end

for nid, n in pairs(tree.nodes or {}) do
    local conns = {}
    if n.connections then
        for i, c in ipairs(n.connections) do
            conns[i] = { id = c.id, orbit = c.orbit }
        end
    end
    out.nodes[tostring(nid)] = {
        name             = n.name,
        icon             = n.icon,
        stats            = n.stats,
        group            = n.group,
        orbit            = n.orbit,
        orbitIndex       = n.orbitIndex,
        connections      = conns,
        isNotable        = n.isNotable,
        isKeystone       = n.isKeystone,
        isJewelSocket    = n.isJewelSocket,
        isMastery        = n.isMastery,
        ascendancyName   = n.ascendancyName,
        classStartIndex  = n.classStartIndex,
    }
end

if tree.classes then
    for ci, c in pairs(tree.classes) do
        out.classes[tostring(ci)] = {
            name           = c.name,
            base_str       = c.base_str,
            base_dex       = c.base_dex,
            base_int       = c.base_int,
            ascendancies   = c.ascendancies,
        }
    end
end

io.write(enc(out))

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Renders the PoE2 passive tree using PoB Community tree data.
// Input properties:
//   treeData         : object loaded from .cache/tree.json (groups, nodes, constants)
//   allocatedNodeIds : array of integer node IDs (the build's selectedSlugs without
//                      the "node-" prefix; convert externally)
// Usage:
//   PassiveTreeView { treeData: ...; allocatedNodeIds: [10364, 42857, ...] }

Rectangle {
    id: root
    color: "#060810"
    border.color: "#2a2a2d"
    border.width: 1
    radius: 4
    clip: true

    property var    treeData:         null
    property var    allocatedNodeIds: []     // array of int

    // Pan/zoom state
    property real   scale:    0.05
    property real   offsetX:  0
    property real   offsetY:  0
    property real   minScale: 0.01
    property real   maxScale: 0.5

    // Quick lookup as a Set-ish object (key = stringified id → true)
    property var    _allocatedSet: ({})

    // Pre-computed node positions: { id: { x, y, kind } }
    property var    _nodePositions: ({})

    onAllocatedNodeIdsChanged: _rebuildAllocatedSet()
    onTreeDataChanged:         _rebuildPositions()
    onWidthChanged:            _refit()
    onHeightChanged:           _refit()

    function _rebuildAllocatedSet() {
        var s = {}
        var arr = allocatedNodeIds || []
        for (var i = 0; i < arr.length; i++) s[String(arr[i])] = true
        _allocatedSet = s
        canvas.requestPaint()
    }

    function _rebuildPositions() {
        if (!treeData || !treeData.nodes || !treeData.groups || !treeData.constants) {
            _nodePositions = {}
            return
        }
        // PoB tables are Lua 1-indexed but my converter emits dense arrays
        // starting from Lua index 1, so the JSON array index 0 corresponds
        // to Lua index 1. The data's own `orbit` field, however, is 0-indexed
        // (matches PoE2's internal data). So:
        //   radii[0]  = Lua's orbit 1 = orbit-0 radius = 0   ✓
        //   radii[4]  = Lua's orbit 5 = orbit-4 radius = 493 ✓
        var radii    = treeData.constants.orbitRadii         || []
        var perOrb   = treeData.constants.skillsPerOrbit     || []
        var angTable = treeData.constants.orbitAnglesByOrbit || []
        var groups = treeData.groups
        var nodes  = treeData.nodes

        function angleFor(orbit, idx) {
            var per = angTable[orbit]
            if (per && per[idx] !== undefined) return per[idx] - Math.PI / 2
            var slots = perOrb[orbit] || 1
            return (idx / slots) * 2 * Math.PI - Math.PI / 2
        }

        var out = {}
        for (var nid in nodes) {
            var n = nodes[nid]
            if (n.group === undefined || n.group === null) continue
            var g = groups[String(n.group)]
            if (!g) continue
            var orbit = n.orbit || 0
            var idx   = n.orbitIndex || 0
            var r     = radii[orbit] || 0
            var angle = angleFor(orbit, idx)
            out[nid] = {
                x:  g.x + r * Math.cos(angle),
                y:  g.y + r * Math.sin(angle),
                k:  n.isKeystone ? "keystone" :
                    n.isNotable ? "notable"  :
                    n.isJewelSocket ? "jewel" :
                    n.isMastery ? "mastery" : "normal",
                a:  n.ascendancyName || ""
            }
        }
        _nodePositions = out
        _refit()
    }

    function _refit() {
        if (!treeData || !_nodePositions) return
        // Fit the bounding box of allocated nodes (or whole tree if none).
        var ids = allocatedNodeIds && allocatedNodeIds.length > 0
                  ? allocatedNodeIds
                  : Object.keys(_nodePositions)
        if (!ids.length || width <= 0 || height <= 0) return
        var minX =  1e9, minY =  1e9, maxX = -1e9, maxY = -1e9
        for (var i = 0; i < ids.length; i++) {
            var p = _nodePositions[String(ids[i])]
            if (!p) continue
            if (p.x < minX) minX = p.x
            if (p.x > maxX) maxX = p.x
            if (p.y < minY) minY = p.y
            if (p.y > maxY) maxY = p.y
        }
        var padding = 600
        minX -= padding; maxX += padding
        minY -= padding; maxY += padding
        var w = maxX - minX, h = maxY - minY
        if (w <= 0 || h <= 0) return
        var sx = width  / w
        var sy = height / h
        scale = Math.max(minScale, Math.min(maxScale, Math.min(sx, sy)))
        // Centre
        var cx = (minX + maxX) / 2
        var cy = (minY + maxY) / 2
        offsetX = width  / 2 - cx * scale
        offsetY = height / 2 - cy * scale
        canvas.requestPaint()
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative
        renderTarget:   Canvas.Image

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            if (!root.treeData) return
            var positions = root._nodePositions
            var allocated = root._allocatedSet
            var nodes = root.treeData.nodes
            var s = root.scale, ox = root.offsetX, oy = root.offsetY

            // ── Connections ─────────────────────────────────────
            // Two passes: dim unallocated first, then bright allocated on top.
            var allocEdges = []
            ctx.lineWidth   = Math.max(0.3, 4 * s)
            ctx.strokeStyle = "#1a1a25"
            ctx.beginPath()
            for (var nid in nodes) {
                var n  = nodes[nid]
                var pa = positions[nid]
                if (!pa || (n.ascendancyName && n.ascendancyName !== "")) continue
                var conns = n.connections || []
                for (var c = 0; c < conns.length; c++) {
                    var oid = String(conns[c].id)
                    var pb  = positions[oid]
                    if (!pb) continue
                    var nOther = nodes[oid]
                    if (nOther && nOther.ascendancyName) continue
                    if (parseInt(nid) > parseInt(oid)) continue
                    var bothAlloc = allocated[nid] && allocated[oid]
                    if (bothAlloc) { allocEdges.push([pa, pb]); continue }
                    ctx.moveTo(pa.x * s + ox, pa.y * s + oy)
                    ctx.lineTo(pb.x * s + ox, pb.y * s + oy)
                }
            }
            ctx.stroke()

            // Bright allocated connections (drawn after so they sit on top)
            ctx.lineWidth   = Math.max(1.5, 10 * s)
            ctx.strokeStyle = "#d4a843"
            ctx.beginPath()
            for (var e = 0; e < allocEdges.length; e++) {
                var ea = allocEdges[e][0], eb = allocEdges[e][1]
                ctx.moveTo(ea.x * s + ox, ea.y * s + oy)
                ctx.lineTo(eb.x * s + ox, eb.y * s + oy)
            }
            ctx.stroke()

            // ── Nodes — pass 1: dim unallocated ────────────────
            for (var nid2 in positions) {
                var p = positions[nid2]
                if (p.a && p.a !== "") continue
                if (allocated[nid2]) continue
                var x = p.x * s + ox
                var y = p.y * s + oy
                if (x < -10 || x > width + 10 || y < -10 || y > height + 10) continue
                var rad = (p.k === "keystone") ? Math.max(2, 12 * s) :
                          (p.k === "notable")  ? Math.max(1.5, 9 * s) :
                          (p.k === "jewel")    ? Math.max(2, 9 * s) :
                          (p.k === "mastery")  ? Math.max(1.2, 7 * s) :
                                                 Math.max(0.8, 4 * s)
                ctx.fillStyle = (p.k === "keystone" || p.k === "notable") ? "#2a2535" : "#1a1a25"
                ctx.beginPath()
                ctx.arc(x, y, rad, 0, 2 * Math.PI)
                ctx.fill()
            }

            // ── Nodes — pass 2: bright allocated on top ────────
            for (var nid3 in positions) {
                var pp = positions[nid3]
                if (pp.a && pp.a !== "") continue
                if (!allocated[nid3]) continue
                var xx = pp.x * s + ox
                var yy = pp.y * s + oy
                if (xx < -30 || xx > width + 30 || yy < -30 || yy > height + 30) continue

                var arad, afill, astroke
                if (pp.k === "keystone") {
                    arad = Math.max(5, 32 * s); afill = "#ffd060"; astroke = "#fff5a0"
                } else if (pp.k === "notable") {
                    arad = Math.max(4, 24 * s); afill = "#d4a843"; astroke = "#ffe080"
                } else if (pp.k === "jewel") {
                    arad = Math.max(4, 20 * s); afill = "#7adde0"; astroke = "#c0f5f8"
                } else if (pp.k === "mastery") {
                    arad = Math.max(3, 16 * s); afill = "#e08545"; astroke = "#ffbf80"
                } else {
                    arad = Math.max(2.5, 14 * s); afill = "#c5a070"; astroke = "#e8c98a"
                }
                // Outer glow
                var grad = ctx.createRadialGradient(xx, yy, 0, xx, yy, arad * 2.2)
                grad.addColorStop(0, afill)
                grad.addColorStop(0.4, afill)
                grad.addColorStop(1, "transparent")
                ctx.fillStyle = grad
                ctx.beginPath()
                ctx.arc(xx, yy, arad * 2.2, 0, 2 * Math.PI)
                ctx.fill()
                // Core
                ctx.fillStyle   = afill
                ctx.strokeStyle = astroke
                ctx.lineWidth   = Math.max(0.8, 3 * s)
                ctx.beginPath()
                ctx.arc(xx, yy, arad, 0, 2 * Math.PI)
                ctx.fill()
                ctx.stroke()
            }
        }
    }

    // ── Pan + zoom ─────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        acceptedButtons: Qt.LeftButton
        property real lastX: 0
        property real lastY: 0
        onPressed:         { lastX = mouseX; lastY = mouseY }
        onPositionChanged: {
            if (pressed) {
                root.offsetX += (mouseX - lastX)
                root.offsetY += (mouseY - lastY)
                lastX = mouseX; lastY = mouseY
                canvas.requestPaint()
            }
        }
        onWheel: function(wheel) {
            var factor = wheel.angleDelta.y > 0 ? 1.15 : 1 / 1.15
            var newScale = Math.max(root.minScale, Math.min(root.maxScale, root.scale * factor))
            // Zoom around cursor: keep the tree point under the cursor fixed
            var tx = (wheel.x - root.offsetX) / root.scale
            var ty = (wheel.y - root.offsetY) / root.scale
            root.scale = newScale
            root.offsetX = wheel.x - tx * newScale
            root.offsetY = wheel.y - ty * newScale
            canvas.requestPaint()
        }
    }

    // Reset/fit buttons
    Row {
        anchors { right: parent.right; top: parent.top; margins: 6 }
        spacing: 4
        Rectangle {
            width: 50; height: 22; radius: 3
            color: "#161a20"; border.color: "#2a3040"; border.width: 1
            Text {
                anchors.centerIn: parent; text: "Fit"
                color: "#7adde0"; font.pixelSize: 10
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root._refit() }
        }
    }
}

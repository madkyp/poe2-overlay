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
        var radii  = treeData.constants.orbitRadii      || []
        var perOrb = treeData.constants.skillsPerOrbit  || []
        var groups = treeData.groups
        var nodes  = treeData.nodes
        var out = {}
        for (var nid in nodes) {
            var n = nodes[nid]
            if (n.group === undefined || n.group === null) continue
            var g = groups[String(n.group)]
            if (!g) continue
            var orbit = n.orbit || 0
            var idx   = n.orbitIndex || 0
            var r     = radii[orbit] || 0
            var slots = perOrb[orbit] || 1
            var angle = (idx / slots) * 2 * Math.PI - Math.PI / 2
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
            ctx.lineWidth = Math.max(0.5, 8 * s)
            for (var nid in nodes) {
                var n = nodes[nid]
                var pa = positions[nid]
                if (!pa) continue
                var conns = n.connections || []
                for (var c = 0; c < conns.length; c++) {
                    var oid = String(conns[c].id)
                    var pb = positions[oid]
                    if (!pb) continue
                    // Draw each edge once: only when nid < oid
                    if (parseInt(nid) > parseInt(oid)) continue
                    var bothAlloc = allocated[nid] && allocated[oid]
                    ctx.strokeStyle = bothAlloc ? "#d4a843" : "#2a2a3a"
                    ctx.beginPath()
                    ctx.moveTo(pa.x * s + ox, pa.y * s + oy)
                    ctx.lineTo(pb.x * s + ox, pb.y * s + oy)
                    ctx.stroke()
                }
            }

            // ── Nodes ───────────────────────────────────────────
            for (var nid2 in positions) {
                var p = positions[nid2]
                if (p.a && p.a !== "") continue  // skip ascendancy nodes in main view
                var isAlloc = !!allocated[nid2]
                var x = p.x * s + ox
                var y = p.y * s + oy
                if (x < -20 || x > width + 20 || y < -20 || y > height + 20) continue

                var rad, fill, stroke
                if (p.k === "keystone") {
                    rad   = Math.max(3, 28 * s)
                    fill  = isAlloc ? "#d4a843" : "#2a2030"
                    stroke = isAlloc ? "#ffd060" : "#3a3045"
                } else if (p.k === "notable") {
                    rad   = Math.max(2.5, 22 * s)
                    fill  = isAlloc ? "#d4a843" : "#1c1c2a"
                    stroke = isAlloc ? "#ffd060" : "#3a3040"
                } else if (p.k === "jewel") {
                    rad   = Math.max(2.5, 18 * s)
                    fill  = isAlloc ? "#7adde0" : "#0a1822"
                    stroke = isAlloc ? "#aef0f4" : "#1e3040"
                } else if (p.k === "mastery") {
                    rad   = Math.max(2, 16 * s)
                    fill  = isAlloc ? "#af6025" : "#1a1010"
                    stroke = isAlloc ? "#e08545" : "#2a1818"
                } else {
                    rad   = Math.max(1.5, 12 * s)
                    fill  = isAlloc ? "#c5a070" : "#1a1a20"
                    stroke = isAlloc ? "#e0bf90" : "#2a2a30"
                }
                ctx.fillStyle   = fill
                ctx.strokeStyle = stroke
                ctx.lineWidth   = Math.max(0.5, 2 * s)
                ctx.beginPath()
                ctx.arc(x, y, rad, 0, 2 * Math.PI)
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

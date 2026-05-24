import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Renders the PoE2 passive tree using PoB Community tree data.
// Required properties:
//   treeData          : object loaded from .cache/tree.json
//   allocatedNodeIds  : array of int — main tree allocations
//   ascendancyIds     : array of int — ascendancy node allocations
//   ascendancyName    : string — which ascendancy (e.g., "Invoker") to render the
//                       small inset for. If empty no inset is drawn.
//   classIcon         : optional URL of the character class icon at the centroid

Rectangle {
    id: root
    color: "#060810"
    border.color: "#2a2a2d"
    border.width: 1
    radius: 4
    clip: true

    property var    treeData:          null
    property var    allocatedNodeIds:  []
    property var    ascendancyIds:     []
    property string ascendancyName:    ""
    property string classIcon:         ""

    // View transform
    property real   scale:    0.05
    property real   offsetX:  0
    property real   offsetY:  0
    property real   minScale: 0.01
    property real   maxScale: 0.6

    // Lookups (rebuilt when data/alloc changes)
    property var    _allocatedSet:   ({})
    property var    _nodePositions:  ({})
    property real   _centroidX:      0
    property real   _centroidY:      0

    // Hover state
    property string _hoverId:    ""
    property real   _hoverScreenX: 0
    property real   _hoverScreenY: 0

    onAllocatedNodeIdsChanged: _rebuildAllocatedSet()
    onTreeDataChanged:         _rebuildPositions()
    onWidthChanged:            _refit()
    onHeightChanged:           _refit()

    function _rebuildAllocatedSet() {
        var s = {}
        var arr = allocatedNodeIds || []
        for (var i = 0; i < arr.length; i++) s[String(arr[i])] = true
        _allocatedSet = s
        // Variants have very different allocation counts. Always refit so the
        // viewport tracks the new variant's bounds instead of staying zoomed
        // on the previously-visible build.
        _refit()
        canvas.requestPaint()
    }

    function _rebuildPositions() {
        if (!treeData || !treeData.nodes || !treeData.groups || !treeData.constants) {
            _nodePositions = {}
            return
        }
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
        var ids = allocatedNodeIds && allocatedNodeIds.length > 0
                  ? allocatedNodeIds
                  : Object.keys(_nodePositions)
        if (!ids.length || width <= 0 || height <= 0) return
        var minX =  1e9, minY =  1e9, maxX = -1e9, maxY = -1e9, n = 0, sx = 0, sy = 0
        for (var i = 0; i < ids.length; i++) {
            var p = _nodePositions[String(ids[i])]
            if (!p) continue
            if (p.x < minX) minX = p.x
            if (p.x > maxX) maxX = p.x
            if (p.y < minY) minY = p.y
            if (p.y > maxY) maxY = p.y
            sx += p.x; sy += p.y; n++
        }
        if (n === 0) return
        _centroidX = sx / n
        _centroidY = sy / n
        // Include origin (class start neighborhood) for context
        if (minX > 0) minX = -200
        if (minY > 0) minY = -200
        if (maxX < 0) maxX = 200
        if (maxY < 0) maxY = 200
        var padding = 1200
        minX -= padding; maxX += padding
        minY -= padding; maxY += padding
        var w = maxX - minX, h = maxY - minY
        if (w <= 0 || h <= 0) return
        var fx = width  / w
        var fy = height / h
        scale = Math.max(minScale, Math.min(maxScale, Math.min(fx, fy)))
        var cx = (minX + maxX) / 2
        var cy = (minY + maxY) / 2
        offsetX = width  / 2 - cx * scale
        offsetY = height / 2 - cy * scale
        canvas.requestPaint()
    }

    // ── Tree-coord polygon helpers (drawn on the 2D context) ────
    function _drawStar(ctx, x, y, rOuter, rInner, points) {
        ctx.beginPath()
        for (var k = 0; k < points * 2; k++) {
            var ang = -Math.PI / 2 + k * Math.PI / points
            var r   = (k % 2 === 0) ? rOuter : rInner
            var px  = x + r * Math.cos(ang)
            var py  = y + r * Math.sin(ang)
            if (k === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py)
        }
        ctx.closePath()
    }
    function _drawDiamond(ctx, x, y, rad) {
        ctx.beginPath()
        ctx.moveTo(x, y - rad)
        ctx.lineTo(x + rad, y); ctx.lineTo(x, y + rad); ctx.lineTo(x - rad, y)
        ctx.closePath()
    }
    function _drawHex(ctx, x, y, rad) {
        ctx.beginPath()
        for (var i = 0; i < 6; i++) {
            var ang = -Math.PI / 2 + i * Math.PI / 3
            var px  = x + rad * Math.cos(ang)
            var py  = y + rad * Math.sin(ang)
            if (i === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py)
        }
        ctx.closePath()
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

            // ── Connections — dim batch, then bright on top ────
            // PoB stores edges asymmetrically (only one direction), so we
            // can't dedupe by id ordering — just draw every connection from
            // every node. Overlapping draws are invisible anyway.
            var allocEdges = []
            var drawn = {}
            ctx.lineWidth   = Math.max(0.3, 4 * s)
            ctx.strokeStyle = "#181822"
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
                    // canonical key for de-dup without losing asymmetric edges
                    var ka = parseInt(nid) < parseInt(oid) ? nid + "_" + oid : oid + "_" + nid
                    if (drawn[ka]) continue
                    drawn[ka] = true
                    if (allocated[nid] && allocated[oid]) { allocEdges.push([pa, pb]); continue }
                    ctx.moveTo(pa.x * s + ox, pa.y * s + oy)
                    ctx.lineTo(pb.x * s + ox, pb.y * s + oy)
                }
            }
            ctx.stroke()

            ctx.lineWidth   = Math.max(1.5, 10 * s)
            ctx.strokeStyle = "#d4a843"
            ctx.beginPath()
            for (var e = 0; e < allocEdges.length; e++) {
                var ea = allocEdges[e][0], eb = allocEdges[e][1]
                ctx.moveTo(ea.x * s + ox, ea.y * s + oy)
                ctx.lineTo(eb.x * s + ox, eb.y * s + oy)
            }
            ctx.stroke()

            // ── Pass 1: unallocated, dim, shape-by-kind ────────
            for (var nid2 in positions) {
                var p = positions[nid2]
                if (p.a && p.a !== "") continue
                if (allocated[nid2]) continue
                var x = p.x * s + ox
                var y = p.y * s + oy
                if (x < -10 || x > width + 10 || y < -10 || y > height + 10) continue
                ctx.fillStyle = "#1c1c25"
                if (p.k === "notable") {
                    root._drawStar(ctx, x, y, Math.max(2, 10 * s), Math.max(1, 5 * s), 5)
                    ctx.fill()
                } else if (p.k === "keystone") {
                    root._drawHex(ctx, x, y, Math.max(3, 14 * s))
                    ctx.fill()
                } else if (p.k === "jewel") {
                    root._drawDiamond(ctx, x, y, Math.max(2.5, 10 * s))
                    ctx.fill()
                } else if (p.k === "mastery") {
                    ctx.beginPath()
                    ctx.arc(x, y, Math.max(1.5, 7 * s), 0, 2 * Math.PI)
                    ctx.fill()
                } else {
                    ctx.beginPath()
                    ctx.arc(x, y, Math.max(0.8, 4 * s), 0, 2 * Math.PI)
                    ctx.fill()
                }
            }

            // ── Pass 2: allocated, glowing, shape-by-kind ──────
            for (var nid3 in positions) {
                var pp = positions[nid3]
                if (pp.a && pp.a !== "") continue
                if (!allocated[nid3]) continue
                var xx = pp.x * s + ox
                var yy = pp.y * s + oy
                if (xx < -40 || xx > width + 40 || yy < -40 || yy > height + 40) continue

                var arad, afill, astroke
                if (pp.k === "keystone") {
                    arad = Math.max(6, 30 * s); afill = "#ffd060"; astroke = "#fff5a0"
                } else if (pp.k === "notable") {
                    arad = Math.max(5, 22 * s); afill = "#d4a843"; astroke = "#ffe080"
                } else if (pp.k === "jewel") {
                    arad = Math.max(4, 18 * s); afill = "#7adde0"; astroke = "#c0f5f8"
                } else if (pp.k === "mastery") {
                    arad = Math.max(3, 14 * s); afill = "#e08545"; astroke = "#ffbf80"
                } else {
                    arad = Math.max(2.5, 12 * s); afill = "#d4a843"; astroke = "#ffe080"
                }
                // Outer glow
                var grad = ctx.createRadialGradient(xx, yy, 0, xx, yy, arad * 2.2)
                grad.addColorStop(0,   afill)
                grad.addColorStop(0.45, afill)
                grad.addColorStop(1,   "transparent")
                ctx.fillStyle = grad
                ctx.beginPath()
                ctx.arc(xx, yy, arad * 2.2, 0, 2 * Math.PI)
                ctx.fill()
                // Shape
                ctx.fillStyle   = afill
                ctx.strokeStyle = astroke
                ctx.lineWidth   = Math.max(0.8, 3 * s)
                if (pp.k === "notable") {
                    root._drawStar(ctx, xx, yy, arad, arad * 0.5, 5)
                } else if (pp.k === "keystone") {
                    root._drawHex(ctx, xx, yy, arad)
                } else if (pp.k === "jewel") {
                    root._drawDiamond(ctx, xx, yy, arad)
                } else {
                    ctx.beginPath()
                    ctx.arc(xx, yy, arad, 0, 2 * Math.PI)
                }
                ctx.fill()
                ctx.stroke()
            }
        }
    }

    // (Class portrait now drawn inside the ascendancy inset below.)

    // ── Mouse interaction: pan, zoom, hover ────────────────────
    MouseArea {
        id: viewMouse
        anchors.fill: parent
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        property real lastX: 0
        property real lastY: 0
        onPressed:         { lastX = mouseX; lastY = mouseY }
        onPositionChanged: {
            if (pressed) {
                root.offsetX += (mouseX - lastX)
                root.offsetY += (mouseY - lastY)
                lastX = mouseX; lastY = mouseY
                canvas.requestPaint()
                root._hoverId = ""
            } else {
                root._updateHover(mouseX, mouseY)
            }
        }
        onExited: root._hoverId = ""
        onWheel: function(wheel) {
            var factor = wheel.angleDelta.y > 0 ? 1.15 : 1 / 1.15
            var newScale = Math.max(root.minScale, Math.min(root.maxScale, root.scale * factor))
            var tx = (wheel.x - root.offsetX) / root.scale
            var ty = (wheel.y - root.offsetY) / root.scale
            root.scale = newScale
            root.offsetX = wheel.x - tx * newScale
            root.offsetY = wheel.y - ty * newScale
            canvas.requestPaint()
            root._updateHover(wheel.x, wheel.y)
        }
    }

    function _updateHover(mx, my) {
        if (!_nodePositions) return
        // Convert mouse to tree coords
        var tx = (mx - offsetX) / scale
        var ty = (my - offsetY) / scale
        var bestId = "", bestDist = 1e9
        // Generous hit radius scaled with current zoom
        var hitR = 80 / Math.max(0.02, scale)
        for (var nid in _nodePositions) {
            var p = _nodePositions[nid]
            if (p.a && p.a !== "") continue
            var dx = p.x - tx, dy = p.y - ty
            var d  = dx * dx + dy * dy
            if (d < hitR * hitR && d < bestDist) { bestDist = d; bestId = nid }
        }
        _hoverId = bestId
        if (bestId) {
            _hoverScreenX = _nodePositions[bestId].x * scale + offsetX
            _hoverScreenY = _nodePositions[bestId].y * scale + offsetY
        }
    }

    // ── Hover tooltip ──────────────────────────────────────────
    Rectangle {
        id: tip
        visible: root._hoverId !== "" && !!root.treeData
        readonly property var n: visible && root.treeData && root.treeData.nodes
                                 ? root.treeData.nodes[root._hoverId] : null
        z: 10
        color: "#0c0e14"
        border.color: "#5a6a80"; border.width: 1; radius: 4
        // Position above-right of the node, clipped to the viewport.
        property real targetX: root._hoverScreenX + 12
        property real targetY: root._hoverScreenY - implicitHeight - 8
        x: Math.max(4, Math.min(root.width - implicitWidth - 4, targetX))
        y: Math.max(4, Math.min(root.height - implicitHeight - 4, targetY < 4 ? root._hoverScreenY + 14 : targetY))
        implicitWidth:  tipCol.implicitWidth  + 14
        implicitHeight: tipCol.implicitHeight + 10

        ColumnLayout {
            id: tipCol
            x: 7; y: 5
            spacing: 2
            Text {
                visible: tip.n
                text: tip.n ? (tip.n.name || "") : ""
                color: tip.n && tip.n.isKeystone ? "#ff7a3a" :
                       tip.n && tip.n.isNotable  ? "#d4a843" :
                       tip.n && tip.n.isJewelSocket ? "#7adde0" : "#c0b090"
                font.pixelSize: 11; font.bold: true
            }
            Repeater {
                model: tip.n && tip.n.stats ? tip.n.stats : []
                Text {
                    text: modelData
                    color: "#9aa8b8"; font.pixelSize: 10
                    wrapMode: Text.WordWrap
                    Layout.maximumWidth: 280
                }
            }
            Text {
                visible: tip.n && (tip.n.isKeystone || tip.n.isNotable || tip.n.isJewelSocket || tip.n.isMastery)
                text: tip.n && tip.n.isKeystone ? "Keystone" :
                      tip.n && tip.n.isNotable  ? "Notable"  :
                      tip.n && tip.n.isJewelSocket ? "Jewel Socket" :
                      tip.n && tip.n.isMastery  ? "Mastery"  : ""
                color: "#5a6a80"; font.pixelSize: 8; font.italic: true
            }
        }
    }

    // ── Controls overlay (Fit) ─────────────────────────────────
    Row {
        anchors { right: parent.right; top: parent.top; margins: 6 }
        spacing: 4
        z: 6
        Rectangle {
            width: 50; height: 22; radius: 3
            color: "#161a20"; border.color: "#2a3040"; border.width: 1
            Text { anchors.centerIn: parent; text: "Fit"; color: "#7adde0"; font.pixelSize: 10 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root._refit() }
        }
    }

    // ── Ascendancy inset ──────────────────────────────────────
    // Filters all ascendancy nodes by the build's ascendancyName, recenters
    // around their bounding box, and renders the small circular tree at the
    // actual centre of the passive tree (world coord 0,0 — where the class
    // starts converge). Scales with the tree zoom, clamped so it stays usable.
    Rectangle {
        id: ascInset
        visible: !!root.treeData && !!root.ascendancyName && _ascCount > 0
        x: root.offsetX - width / 2
        y: root.offsetY - height / 2
        width: Math.max(160, Math.min(360, 5000 * root.scale))
        height: width
        radius: width / 2
        color: "#0c0e14"
        border.color: "#5a4a30"; border.width: 1
        z: 6

        property var  _ascPositions: ({})
        property real _ascCenterX:   0
        property real _ascCenterY:   0
        property real _ascRadius:    1
        property int  _ascCount:     0

        // Per-ascendancy allocated set (string ids)
        property var  _ascAllocSet:  ({})

        onVisibleChanged: if (visible) _rebuild()

        Connections {
            target: root
            function onTreeDataChanged()      { ascInset._rebuild() }
            function onAscendancyNameChanged(){ ascInset._rebuild() }
            function onAscendancyIdsChanged() { ascInset._rebuildAlloc(); ascCanvas.requestPaint() }
        }

        function _rebuildAlloc() {
            var s = {}, arr = root.ascendancyIds || []
            for (var i = 0; i < arr.length; i++) s[String(arr[i])] = true
            _ascAllocSet = s
        }

        function _rebuild() {
            _rebuildAlloc()
            if (!root.treeData || !root.ascendancyName) { _ascCount = 0; return }
            var radii    = root.treeData.constants.orbitRadii         || []
            var perOrb   = root.treeData.constants.skillsPerOrbit     || []
            var angTable = root.treeData.constants.orbitAnglesByOrbit || []
            var nodes    = root.treeData.nodes
            var groups   = root.treeData.groups
            var positions = {}
            var minX =  1e9, minY =  1e9, maxX = -1e9, maxY = -1e9, count = 0
            function angleFor(orbit, idx) {
                var per = angTable[orbit]
                if (per && per[idx] !== undefined) return per[idx] - Math.PI / 2
                var slots = perOrb[orbit] || 1
                return (idx / slots) * 2 * Math.PI - Math.PI / 2
            }
            for (var nid in nodes) {
                var n = nodes[nid]
                if (n.ascendancyName !== root.ascendancyName) continue
                var g = groups[String(n.group)]
                if (!g) continue
                var orbit = n.orbit || 0, idx = n.orbitIndex || 0
                var r = radii[orbit] || 0
                var a = angleFor(orbit, idx)
                var px = g.x + r * Math.cos(a)
                var py = g.y + r * Math.sin(a)
                positions[nid] = {
                    x: px, y: py,
                    k: n.isKeystone ? "keystone" :
                       n.isNotable ? "notable" :
                       n.isJewelSocket ? "jewel" :
                       n.isMastery ? "mastery" : "normal"
                }
                if (px < minX) minX = px
                if (px > maxX) maxX = px
                if (py < minY) minY = py
                if (py > maxY) maxY = py
                count++
            }
            _ascPositions = positions
            _ascCount     = count
            if (count > 0) {
                _ascCenterX = (minX + maxX) / 2
                _ascCenterY = (minY + maxY) / 2
                _ascRadius  = Math.max(maxX - minX, maxY - minY) / 2 + 50
            }
            ascCanvas.requestPaint()
        }

        Canvas {
            id: ascCanvas
            anchors.fill: parent
            renderStrategy: Canvas.Cooperative
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                if (ascInset._ascCount === 0) return
                var pos = ascInset._ascPositions
                var alloc = ascInset._ascAllocSet
                var nodes = root.treeData.nodes
                var s  = (Math.min(width, height) - 24) / (2 * ascInset._ascRadius)
                var cx = width  / 2 - ascInset._ascCenterX * s
                var cy = height / 2 - ascInset._ascCenterY * s

                // Edges
                var allocEdges = []
                var drawn = {}
                ctx.lineWidth   = 1.2
                ctx.strokeStyle = "#2a2530"
                ctx.beginPath()
                for (var nid in nodes) {
                    if (!pos[nid]) continue
                    var pa = pos[nid]
                    var conns = nodes[nid].connections || []
                    for (var c = 0; c < conns.length; c++) {
                        var oid = String(conns[c].id)
                        var pb  = pos[oid]
                        if (!pb) continue
                        var key = parseInt(nid) < parseInt(oid) ? nid+"_"+oid : oid+"_"+nid
                        if (drawn[key]) continue
                        drawn[key] = true
                        if (alloc[nid] && alloc[oid]) { allocEdges.push([pa, pb]); continue }
                        ctx.moveTo(pa.x*s+cx, pa.y*s+cy)
                        ctx.lineTo(pb.x*s+cx, pb.y*s+cy)
                    }
                }
                ctx.stroke()
                ctx.lineWidth   = 2.5
                ctx.strokeStyle = "#d4a843"
                ctx.beginPath()
                for (var e = 0; e < allocEdges.length; e++) {
                    var ea = allocEdges[e][0], eb = allocEdges[e][1]
                    ctx.moveTo(ea.x*s+cx, ea.y*s+cy)
                    ctx.lineTo(eb.x*s+cx, eb.y*s+cy)
                }
                ctx.stroke()

                // Nodes
                for (var nid2 in pos) {
                    var p = pos[nid2]
                    var isAlloc = !!alloc[nid2]
                    var x = p.x*s+cx, y = p.y*s+cy
                    var rad = p.k === "keystone" ? 6 : p.k === "notable" ? 5 : p.k === "jewel" ? 4 : 2.5
                    if (isAlloc) {
                        ctx.fillStyle   = p.k === "keystone" ? "#ffd060"
                                        : p.k === "jewel"    ? "#7adde0"
                                                             : "#d4a843"
                        ctx.strokeStyle = "#ffe080"
                        ctx.lineWidth   = 1
                    } else {
                        ctx.fillStyle   = "#1c1c25"
                        ctx.strokeStyle = "#2a2530"
                        ctx.lineWidth   = 0.5
                    }
                    ctx.beginPath()
                    ctx.arc(x, y, rad, 0, 2*Math.PI)
                    ctx.fill()
                    ctx.stroke()
                }
            }
        }

        Text {
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 10 }
            text: root.ascendancyName
            color: "#d4a843"; font.pixelSize: 12; font.bold: true
        }
    }
}

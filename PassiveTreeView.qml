import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

// Renders the PoE2 passive tree for a build guide, with the build's
// allocated nodes highlighted gold and the ascendancy overlaid on a
// character portrait at the centre — same visual style as the
// standalone tree viewer.
//
// Required properties:
//   treeData          : object loaded from .cache/tree.json
//   allocatedNodeIds  : array of int — main tree allocations
//   ascendancyIds     : array of int — ascendancy allocations
//   ascendancyName    : string — e.g. "Invoker"
//   charClass         : string — e.g. "Monk" (used for portrait URL)

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
    property string charClass:         ""

    // View transform
    property real   scale:    0.05
    property real   offsetX:  0
    property real   offsetY:  0
    property real   minScale: 0.015
    property real   maxScale: 0.6

    // Lookups
    property var    _allocatedSet:    ({})
    property var    _ascAllocSet:     ({})
    property var    _nodePositions:   ({})

    // Hover state
    property string _hoverId:      ""
    property real   _hoverScreenX: 0
    property real   _hoverScreenY: 0

    onAllocatedNodeIdsChanged: { _rebuildAllocatedSet(); _rebuildPositions() }
    onAscendancyIdsChanged:    _rebuildAllocatedSet()
    onAscendancyNameChanged:   _rebuildPositions()
    onTreeDataChanged:         _rebuildPositions()
    onWidthChanged:            _refit()
    onHeightChanged:           _refit()

    // Map any icon path to a Mobalytics CDN WebP URL.
    // PoB-Community paths ended in .dds; official GGG paths end in .png.
    function _iconUrl(icon) {
        if (!icon || icon.length < 5) return ""
        return "https://cdn.mobalytics.gg/assets/poe-2/images/game/" +
               icon.replace(/\.(dds|png|avif|jpg|jpeg)$/i, ".webp")
    }

    function _portraitUrl() {
        if (!charClass || !ascendancyName) return ""
        var c = charClass.toLowerCase().replace(/\s+/g, "-")
        var a = ascendancyName.toLowerCase().replace(/\s+/g, "-")
        return "https://cdn.mobalytics.gg/assets/poe-2/images/game/classes/header/" + c + "-" + a + ".jpg"
    }

    function _rebuildAllocatedSet() {
        var s = {}, sa = {}
        var arr = allocatedNodeIds || []
        for (var i = 0; i < arr.length; i++) s[String(arr[i])] = true
        var arr2 = ascendancyIds || []
        for (var j = 0; j < arr2.length; j++) sa[String(arr2[j])] = true
        _allocatedSet = s
        _ascAllocSet  = sa
        _refit()
        canvas.requestPaint()
        ascCanvas.requestPaint()
    }

    function _rebuildPositions() {
        if (!treeData || !treeData.nodes || !treeData.groups) {
            _nodePositions = {}
            return
        }
        // The GGG official export ships pre-computed x/y for every node and
        // does NOT include orbit constants. Older PoB-Community-derived
        // caches do include orbits but not x/y. Use x/y when present, fall
        // back to orbit math otherwise.
        var radii    = (treeData.constants && treeData.constants.orbitRadii)         || []
        var perOrb   = (treeData.constants && treeData.constants.skillsPerOrbit)     || []
        var angTable = (treeData.constants && treeData.constants.orbitAnglesByOrbit) || []
        function angleFor(orbit, idx) {
            var per = angTable[orbit]
            if (per && per[idx] !== undefined) return per[idx] - Math.PI / 2
            var slots = perOrb[orbit] || 1
            return (idx / slots) * 2 * Math.PI - Math.PI / 2
        }

        var groups = treeData.groups
        var nodes  = treeData.nodes
        var out = {}
        var ascNatural = []
        for (var nid in nodes) {
            var n = nodes[nid]
            var ascName = n.ascendancyName || ""
            if (ascName !== "" && ascName !== ascendancyName) continue
            if (n.group === undefined || n.group === null) continue
            // Skip the synthetic "root" pseudo-node and anything else with
            // no name (null icon, null position).
            if (n.name === null || n.name === "") {
                if (n.x === null || n.x === undefined ||
                    n.y === null || n.y === undefined) continue
            }
            var rx, ry
            if (n.x !== undefined && n.x !== null &&
                n.y !== undefined && n.y !== null) {
                rx = n.x; ry = n.y
            } else {
                var g = groups[String(n.group)]; if (!g) continue
                var orbit = n.orbit || 0, idx = n.orbitIndex || 0
                var r = radii[orbit] || 0
                var a = angleFor(orbit, idx)
                rx = g.x + r * Math.cos(a)
                ry = g.y + r * Math.sin(a)
            }
            var kind = n.isKeystone ? "keystone" :
                       n.isNotable  ? "notable"  :
                       n.isJewelSocket ? "jewel" :
                       n.isMastery ? "mastery" : "normal"
            if (ascName === "") {
                out[nid] = { id: nid, x: rx, y: ry, icon: _iconUrl(n.icon), k: kind, a: "" }
            } else {
                ascNatural.push({ nid: nid, rx: rx, ry: ry, icon: _iconUrl(n.icon), k: kind, a: ascName })
            }
        }

        // Relocate ascendancy cluster onto the portrait, same logic as
        // standalone: fit inside ~45% of the portrait diameter, centred on
        // origin.
        if (ascNatural.length > 0) {
            var minX =  1e9, minY =  1e9, maxX = -1e9, maxY = -1e9
            for (var k1 = 0; k1 < ascNatural.length; k1++) {
                var p = ascNatural[k1]
                if (p.rx < minX) minX = p.rx
                if (p.rx > maxX) maxX = p.rx
                if (p.ry < minY) minY = p.ry
                if (p.ry > maxY) maxY = p.ry
            }
            var cx = (minX + maxX) / 2
            var cy = (minY + maxY) / 2
            var spanX = Math.max(1, maxX - minX)
            var spanY = Math.max(1, maxY - minY)
            var targetSide = 2200
            var ascZoom = targetSide / Math.max(spanX, spanY)
            for (var k2 = 0; k2 < ascNatural.length; k2++) {
                var ap = ascNatural[k2]
                out[ap.nid] = {
                    id: ap.nid,
                    x:  (ap.rx - cx) * ascZoom,
                    y:  (ap.ry - cy) * ascZoom,
                    icon: ap.icon, k: ap.k, a: ap.a
                }
            }
        }
        _nodePositions = out
        _refit()
    }

    // Property bindings so QML auto-recomputes when _nodePositions changes.
    property var _posList: {
        var arr = []
        var src = _nodePositions
        if (!src) return arr
        for (var k in src) {
            var p = src[k]
            if (p.a && p.a !== "") continue
            arr.push(p)
        }
        return arr
    }
    property var _ascPosList: {
        var arr = []
        var src = _nodePositions
        if (!src) return arr
        for (var k in src) {
            var p = src[k]
            if (!p.a || p.a === "") continue
            arr.push(p)
        }
        return arr
    }

    function _refit() {
        if (!treeData) return
        var ids = allocatedNodeIds && allocatedNodeIds.length > 0
                  ? allocatedNodeIds
                  : Object.keys(_nodePositions || {})
        if (!ids.length || width <= 0 || height <= 0) return
        var minX =  1e9, minY =  1e9, maxX = -1e9, maxY = -1e9, n = 0
        for (var i = 0; i < ids.length; i++) {
            var p = _nodePositions[String(ids[i])]
            if (!p) continue
            if (p.x < minX) minX = p.x
            if (p.x > maxX) maxX = p.x
            if (p.y < minY) minY = p.y
            if (p.y > maxY) maxY = p.y
            n++
        }
        if (n === 0) return
        // Tight padding so the allocated path fills the viewport. Don't
        // include world origin — for endgame variants with 100+ picks the
        // path is already huge; the portrait will be off-centre but the
        // user can pan to it if needed.
        var padding = 500
        minX -= padding; maxX += padding
        minY -= padding; maxY += padding
        var w = maxX - minX, h = maxY - minY
        var fx = width / w, fy = height / h
        scale = Math.max(minScale, Math.min(maxScale, Math.min(fx, fy)))
        var ccx = (minX + maxX) / 2, ccy = (minY + maxY) / 2
        offsetX = width  / 2 - ccx * scale
        offsetY = height / 2 - ccy * scale
        canvas.requestPaint()
        ascCanvas.requestPaint()
    }

    // ── Main-tree connections (background canvas) ──────────────
    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative
        renderTarget:   Canvas.Image
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            if (!root.treeData) return
            var pos = root._nodePositions
            var alloc = root._allocatedSet
            var nodes = root.treeData.nodes
            var s = root.scale, ox = root.offsetX, oy = root.offsetY

            var allocEdges = []
            var drawn = {}
            ctx.lineWidth   = Math.max(0.4, 5 * s)
            ctx.strokeStyle = "#3a4a60"
            ctx.beginPath()
            for (var nid in nodes) {
                var n = nodes[nid]
                if (n.ascendancyName && n.ascendancyName !== "") continue
                var pa = pos[nid]; if (!pa) continue
                var conns = n.connections || []
                for (var c = 0; c < conns.length; c++) {
                    var oid = String(conns[c].id)
                    var pb = pos[oid]; if (!pb) continue
                    var nOther = nodes[oid]
                    if (nOther && nOther.ascendancyName) continue
                    var key = parseInt(nid) < parseInt(oid) ? nid+"_"+oid : oid+"_"+nid
                    if (drawn[key]) continue
                    drawn[key] = true
                    if (alloc[nid] && alloc[oid]) { allocEdges.push([pa, pb]); continue }
                    ctx.moveTo(pa.x * s + ox, pa.y * s + oy)
                    ctx.lineTo(pb.x * s + ox, pb.y * s + oy)
                }
            }
            ctx.stroke()

            // Gold path: thicker minimum so it stays visible when the
            // build has so many nodes that auto-fit zooms quite far out.
            ctx.lineWidth   = Math.max(2.5, 12 * s)
            ctx.strokeStyle = "#d4a843"
            ctx.beginPath()
            for (var e = 0; e < allocEdges.length; e++) {
                var ea = allocEdges[e][0], eb = allocEdges[e][1]
                ctx.moveTo(ea.x * s + ox, ea.y * s + oy)
                ctx.lineTo(eb.x * s + ox, eb.y * s + oy)
            }
            ctx.stroke()
        }
    }

    // ── Main-tree nodes (icons + allocation halo) ──────────────
    Item {
        id: nodesLayer
        anchors.fill: parent
        Repeater {
            model: root._posList
            Item {
                property bool isAlloc: !!root._allocatedSet[modelData.id]
                property real baseSize: modelData.k === "keystone" ? 200
                                      : modelData.k === "notable"  ? 160
                                      : modelData.k === "jewel"    ? 130
                                      : modelData.k === "mastery"  ? 110
                                      : 80
                property real renderSize: Math.max(6, baseSize * root.scale)
                width:  renderSize * (isAlloc ? 1.15 : 1)
                height: width
                x: modelData.x * root.scale + root.offsetX - width / 2
                y: modelData.y * root.scale + root.offsetY - height / 2
                opacity: isAlloc ? 1.0 : 0.32
                visible: renderSize > 2.5
                         && (x + width)  > -8 && x < nodesLayer.width  + 8
                         && (y + height) > -8 && y < nodesLayer.height + 8

                Rectangle {
                    visible: parent.isAlloc
                    anchors.centerIn: parent
                    width: parent.width * 1.6; height: width
                    radius: width / 2
                    color: "transparent"
                    border.color: "#d4a843"
                    border.width: Math.max(1, parent.renderSize / 14)
                    opacity: 0.45
                }
                Image {
                    anchors.fill: parent
                    source: modelData.icon
                    sourceSize.width:  Math.round(parent.baseSize)
                    sourceSize.height: Math.round(parent.baseSize)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: true
                    smooth: true
                }
            }
        }
    }

    // ── Class portrait at origin (covers class-start area) ─────
    Item {
        id: portrait
        visible: !!_portraitUrl() && portraitImg.status === Image.Ready
        x: root.offsetX - width  / 2
        y: root.offsetY - height / 2
        width:  4800 * root.scale
        height: width
        z: 1

        Image {
            id: portraitImg
            anchors.fill: parent
            source: root._portraitUrl()
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: portraitMask
                maskThresholdMin: 0.5
            }
        }
        Item {
            id: portraitMask
            anchors.fill: portrait
            visible: false
            layer.enabled: true
            Rectangle { anchors.fill: parent; radius: width / 2; color: "white" }
        }
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: "#8b7355"
            border.width: Math.max(1, 3 * root.scale * 20)
        }
    }

    // ── Ascendancy connection lines (above portrait) ──────────
    Canvas {
        id: ascCanvas
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative
        renderTarget:   Canvas.Image
        z: 2
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            if (!root.treeData || !root.ascendancyName) return
            var pos = root._nodePositions
            var alloc = root._ascAllocSet
            var nodes = root.treeData.nodes
            var s = root.scale, ox = root.offsetX, oy = root.offsetY
            var allocEdges = []
            var drawn = {}
            ctx.lineWidth   = Math.max(0.7, 7 * s)
            ctx.strokeStyle = "#8a9ab0"
            ctx.beginPath()
            for (var nid in nodes) {
                var n = nodes[nid]
                if (!n.ascendancyName || n.ascendancyName !== root.ascendancyName) continue
                var pa = pos[nid]; if (!pa) continue
                var conns = n.connections || []
                for (var c = 0; c < conns.length; c++) {
                    var oid = String(conns[c].id)
                    var pb = pos[oid]; if (!pb) continue
                    var nOther = nodes[oid]
                    if (!nOther || nOther.ascendancyName !== root.ascendancyName) continue
                    var key = parseInt(nid) < parseInt(oid) ? nid+"_"+oid : oid+"_"+nid
                    if (drawn[key]) continue
                    drawn[key] = true
                    if (alloc[nid] && alloc[oid]) { allocEdges.push([pa, pb]); continue }
                    ctx.moveTo(pa.x * s + ox, pa.y * s + oy)
                    ctx.lineTo(pb.x * s + ox, pb.y * s + oy)
                }
            }
            ctx.stroke()
            // Allocated ascendancy edges in gold
            ctx.lineWidth   = Math.max(1.5, 9 * s)
            ctx.strokeStyle = "#d4a843"
            ctx.beginPath()
            for (var e = 0; e < allocEdges.length; e++) {
                var ea = allocEdges[e][0], eb = allocEdges[e][1]
                ctx.moveTo(ea.x * s + ox, ea.y * s + oy)
                ctx.lineTo(eb.x * s + ox, eb.y * s + oy)
            }
            ctx.stroke()
        }
    }

    // ── Ascendancy framed nodes on top of portrait ────────────
    Item {
        id: ascLayer
        anchors.fill: parent
        z: 3
        Repeater {
            model: root._ascPosList
            Item {
                property bool isAlloc: !!root._ascAllocSet[modelData.id]
                property real baseSize: modelData.k === "keystone" ? 220
                                      : modelData.k === "notable"  ? 180
                                      : modelData.k === "jewel"    ? 160
                                      : 120
                property real renderSize: Math.max(12, baseSize * root.scale)
                width:  renderSize * (isAlloc ? 1.1 : 1)
                height: width
                x: modelData.x * root.scale + root.offsetX - width / 2
                y: modelData.y * root.scale + root.offsetY - height / 2
                opacity: isAlloc ? 1.0 : 0.55
                visible: renderSize > 5
                         && (x + width)  > -10 && x < ascLayer.width  + 10
                         && (y + height) > -10 && y < ascLayer.height + 10

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "#1a1c24"
                    border.width: Math.max(1.5, parent.renderSize / 14)
                    border.color: parent.isAlloc ? "#ffd060"
                                : modelData.k === "keystone" ? "#ffd060"
                                : modelData.k === "notable"  ? "#d4a843"
                                : modelData.k === "jewel"    ? "#7adde0"
                                                             : "#8a96b0"
                }
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Math.max(1, parent.renderSize / 14)
                    radius: width / 2
                    color: "transparent"
                    border.color: "#3a3a45"
                    border.width: 1
                }
                Image {
                    anchors.fill: parent
                    anchors.margins: Math.max(2, parent.renderSize * 0.18)
                    source: modelData.icon
                    sourceSize.width:  Math.round(parent.baseSize)
                    sourceSize.height: Math.round(parent.baseSize)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: true
                    smooth: true
                }
            }
        }
    }

    // ── Pan + zoom + hover ────────────────────────────────────
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
                ascCanvas.requestPaint()
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
            ascCanvas.requestPaint()
            root._updateHover(wheel.x, wheel.y)
        }
    }

    function _updateHover(mx, my) {
        if (!_nodePositions) return
        var tx = (mx - offsetX) / scale
        var ty = (my - offsetY) / scale
        var bestId = "", bestDist = 1e9
        var hitR = 80 / Math.max(0.02, scale)
        for (var nid in _nodePositions) {
            var p = _nodePositions[nid]
            var dx = p.x - tx, dy = p.y - ty
            var d = dx * dx + dy * dy
            if (d < hitR * hitR && d < bestDist) { bestDist = d; bestId = nid }
        }
        _hoverId = bestId
        if (bestId) {
            _hoverScreenX = _nodePositions[bestId].x * scale + offsetX
            _hoverScreenY = _nodePositions[bestId].y * scale + offsetY
        }
    }

    // ── Hover tooltip ─────────────────────────────────────────
    Rectangle {
        id: tip
        visible: root._hoverId !== "" && !!root.treeData
        readonly property var n: visible && root.treeData && root.treeData.nodes
                                 ? root.treeData.nodes[root._hoverId] : null
        z: 10
        color: "#0c0e14"
        border.color: "#5a6a80"; border.width: 1; radius: 4
        property real targetX: root._hoverScreenX + 14
        property real targetY: root._hoverScreenY - implicitHeight - 8
        x: Math.max(4, Math.min(root.width  - implicitWidth  - 4, targetX))
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
        }
    }

    // ── Fit button ────────────────────────────────────────────
    Row {
        anchors { right: parent.right; top: parent.top; margins: 6 }
        spacing: 4; z: 6
        Rectangle {
            width: 50; height: 22; radius: 3
            color: "#161a20"; border.color: "#2a3040"; border.width: 1
            Text { anchors.centerIn: parent; text: "Fit"; color: "#7adde0"; font.pixelSize: 10 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root._refit() }
        }
    }
}

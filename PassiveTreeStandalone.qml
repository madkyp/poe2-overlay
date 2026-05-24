import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "js/State.js" as State

// Standalone fullscreen-ish viewer for the PoE2 passive tree.
// Uses real passive icons from Mobalytics' public CDN (which mirrors
// PoE2 game assets under the same path scheme PoB uses):
//   Art/2DArt/SkillIcons/passives/<x>.dds  →  cdn.mobalytics.gg/.../<x>.webp
//
// V1: renders all nodes; connections drawn with Canvas; pan/zoom only.
// No build-specific allocation highlighting yet — that's the next step
// once the visuals are validated.

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.margins.left: isOpen ? offsetX : 0
    WlrLayershell.margins.top:  isOpen ? offsetY : 0

    anchors.top:  true
    anchors.left: true

    color: "transparent"
    implicitWidth:  isOpen ? windowW : 1
    implicitHeight: isOpen ? windowH : 1

    property bool   isOpen:     false
    property int    offsetX:    200
    property int    offsetY:    50
    property real   windowW:    1100
    property real   windowH:    800
    property var    treeData:   null

    // View transform (much smaller initial scale than PassiveTreeView since
    // the panel is bigger and we want to see most of the tree)
    property real   scale:    0.05
    property real   panX:     0
    property real   panY:     0
    property real   minScale: 0.015
    property real   maxScale: 0.4

    // Hover state
    property string _hoverId:    ""
    property real   _hoverScreenX: 0
    property real   _hoverScreenY: 0

    // Class/ascendancy selection
    property string selectedClass:      "Monk"
    property string selectedAscendancy: "Invoker"

    function _ascendanciesFor(cls) {
        if (!treeData || !treeData.classes) return []
        for (var k in treeData.classes) {
            if (treeData.classes[k].name === cls)
                return (treeData.classes[k].ascendancies || []).map(function(a) { return a.name })
        }
        return []
    }
    function _classNames() {
        if (!treeData || !treeData.classes) return []
        var out = []
        for (var k in treeData.classes) out.push(treeData.classes[k].name)
        return out.sort()
    }
    function _portraitUrl(cls, asc) {
        if (!cls || !asc) return ""
        var c = cls.toLowerCase().replace(/\s+/g, "-")
        var a = asc.toLowerCase().replace(/\s+/g, "-")
        return "https://cdn.mobalytics.gg/assets/poe-2/images/game/classes/header/" + c + "-" + a + ".jpg"
    }

    Component.onCompleted: {
        State.addPassiveStandaloneListener(function(v) {
            root.isOpen = v
            if (v && !root.treeData) root._loadTree()
        })
    }

    function _updateHover(mx, my) {
        var positions = nodesView ? nodesView.positionsById : null
        if (!positions) { _hoverId = ""; return }
        // Generous hit radius (in tree coords); scales inversely with zoom
        var hitR = 80 / Math.max(0.02, scale)
        var tx = (mx - panX) / scale
        var ty = (my - panY) / scale
        var bestId = "", bestDist = 1e9
        for (var nid in positions) {
            var p = positions[nid]
            var dx = p.x - tx, dy = p.y - ty
            var d  = dx * dx + dy * dy
            if (d < hitR * hitR && d < bestDist) { bestDist = d; bestId = nid }
        }
        _hoverId = bestId
        if (bestId) {
            _hoverScreenX = positions[bestId].x * scale + panX
            _hoverScreenY = positions[bestId].y * scale + panY
        }
    }

    function _iconUrl(icon) {
        // PoB stores icon as e.g. "Art/2DArt/SkillIcons/passives/Harrier.dds"
        if (!icon || icon.length < 5) return ""
        return "https://cdn.mobalytics.gg/assets/poe-2/images/game/" +
               icon.replace(/\.dds$/i, ".webp")
    }

    function _centreTree() {
        if (!treeData) return
        panX = windowW / 2
        panY = windowH / 2
    }

    // Load tree.json from cache
    Process {
        id: loadProc
        stdout: StdioCollector { id: loadOut }
        property bool _ran: false
        onRunningChanged: {
            if (!running && _ran) {
                try {
                    root.treeData = JSON.parse(loadOut.text)
                    root._centreTree()
                    canvas.requestPaint()
                } catch (e) {
                    console.log("[PassiveTreeStandalone] parse error:", e.message)
                }
            }
        }
    }

    function _loadTree() {
        homeResolver.running = true
    }

    Process {
        id: homeResolver
        command: ["sh", "-c", "printf '%s' \"$HOME\""]
        stdout: StdioCollector { id: homeOut }
        onRunningChanged: {
            if (!running) {
                var home = homeOut.text.trim()
                loadProc._ran = true
                loadProc.command = ["sh", "-c",
                    "F=\"" + home + "/.config/quickshell/poe2/.cache/tree.json\"; " +
                    "if [ ! -f \"$F\" ]; then " +
                    "/usr/bin/python3 \"" + home + "/.config/quickshell/poe2/scripts/fetch-tree.py\" >&2; " +
                    "fi; cat \"$F\""]
                loadProc.running = true
            }
        }
    }

    Rectangle {
        id: panel
        visible: root.isOpen
        anchors.fill: parent
        color: "#080a0f"
        border.color: "#8B7355"
        border.width: 1
        radius: 8

        // ── Header bar ────────────────────────────────────────
        Rectangle {
            id: header
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 36
            color: "#1c1c1e"
            radius: 8

            RowLayout {
                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                spacing: 10

                Text {
                    text: "⠿  🌲  PoE2 Passive Tree"
                    color: "#d4a843"; font.pixelSize: 13; font.bold: true
                    Layout.fillWidth: true
                    MouseArea {
                        anchors.fill: parent
                        property real mx: 0; property real my: 0
                        property int  ox: 0; property int  oy: 0
                        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                        onPressed:         { mx = mouseX; my = mouseY; ox = root.offsetX; oy = root.offsetY }
                        onPositionChanged: { if (pressed) { root.offsetX = Math.max(0, ox + (mouseX - mx)); root.offsetY = Math.max(0, oy + (mouseY - my)) } }
                    }
                }

                Text {
                    text: "Zoom: " + Math.round(root.scale * 1000) / 10 + "%"
                    color: "#5a5a5a"; font.pixelSize: 10
                }

                ComboBox {
                    id: classCombo
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 26
                    model: root._classNames()
                    currentIndex: {
                        var names = model || []
                        var i = names.indexOf(root.selectedClass)
                        return i >= 0 ? i : 0
                    }
                    onActivated: {
                        root.selectedClass = currentText
                        var ascs = root._ascendanciesFor(currentText)
                        ascCombo.model = ascs
                        ascCombo.currentIndex = 0
                        root.selectedAscendancy = ascs.length > 0 ? ascs[0] : ""
                        nodesView.recompute()
                    }

                    background: Rectangle {
                        color: "#1a1d24"; border.color: "#3a3a45"; border.width: 1; radius: 3
                    }
                    contentItem: Text {
                        leftPadding: 8; rightPadding: classCombo.indicator.width + 4
                        text: classCombo.displayText
                        color: "#d4a843"
                        font.pixelSize: 11; font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    popup: Popup {
                        y: classCombo.height + 2
                        width: classCombo.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: classCombo.popup.visible ? classCombo.delegateModel : null
                            currentIndex: classCombo.highlightedIndex
                        }
                        background: Rectangle { color: "#0d0f15"; border.color: "#3a3a45"; border.width: 1; radius: 3 }
                    }
                    delegate: ItemDelegate {
                        width: classCombo.width
                        height: 24
                        contentItem: Text {
                            text: modelData
                            color: classCombo.highlightedIndex === index ? "#ffe080" : "#c0b090"
                            font.pixelSize: 11
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }
                        background: Rectangle {
                            color: classCombo.highlightedIndex === index ? "#2a2530" : "transparent"
                        }
                    }
                }

                ComboBox {
                    id: ascCombo
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 26
                    model: root._ascendanciesFor(root.selectedClass)
                    currentIndex: {
                        var ascs = model || []
                        var i = ascs.indexOf(root.selectedAscendancy)
                        return i >= 0 ? i : 0
                    }
                    onActivated: {
                        root.selectedAscendancy = currentText
                        nodesView.recompute()
                    }

                    background: Rectangle {
                        color: "#1a1d24"; border.color: "#3a3a45"; border.width: 1; radius: 3
                    }
                    contentItem: Text {
                        leftPadding: 8; rightPadding: ascCombo.indicator.width + 4
                        text: ascCombo.displayText
                        color: "#7adde0"
                        font.pixelSize: 11; font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    popup: Popup {
                        y: ascCombo.height + 2
                        width: ascCombo.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: ascCombo.popup.visible ? ascCombo.delegateModel : null
                            currentIndex: ascCombo.highlightedIndex
                        }
                        background: Rectangle { color: "#0d0f15"; border.color: "#3a3a45"; border.width: 1; radius: 3 }
                    }
                    delegate: ItemDelegate {
                        width: ascCombo.width
                        height: 24
                        contentItem: Text {
                            text: modelData
                            color: ascCombo.highlightedIndex === index ? "#c0f5f8" : "#9aa8b8"
                            font.pixelSize: 11
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }
                        background: Rectangle {
                            color: ascCombo.highlightedIndex === index ? "#1e2a3a" : "transparent"
                        }
                    }
                }

                Rectangle {
                    width: 28; height: 22; radius: 3
                    color: "#161a20"; border.color: "#2a3040"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Fit"; color: "#7adde0"; font.pixelSize: 9 }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.scale = 0.05; root._centreTree(); canvas.requestPaint() } }
                }

                Text {
                    text: "✕"
                    color: "#9a6a50"; font.pixelSize: 14
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: State.setPassiveStandaloneOpen(false)
                    }
                }
            }
        }

        // ── Tree viewport ─────────────────────────────────────
        Item {
            id: viewport
            anchors { left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom }
            clip: true

            // Connections layer (dim grey, on Canvas for batching)
            Canvas {
                id: canvas
                anchors.fill: parent
                renderStrategy: Canvas.Cooperative
                renderTarget:   Canvas.Image
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    if (!root.treeData || !root.treeData.nodes) return
                    var positions = nodesView.positionsById
                    if (!positions) return
                    var s = root.scale, ox = root.panX, oy = root.panY
                    var nodes = root.treeData.nodes
                    var drawn = {}
                    // Brighter steely-blue lines so the tree structure pops
                    ctx.lineWidth   = Math.max(0.5, 6 * s)
                    ctx.strokeStyle = "#5a708a"
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
                            var key = parseInt(nid) < parseInt(oid) ? nid+"_"+oid : oid+"_"+nid
                            if (drawn[key]) continue
                            drawn[key] = true
                            ctx.moveTo(pa.x * s + ox, pa.y * s + oy)
                            ctx.lineTo(pb.x * s + ox, pb.y * s + oy)
                        }
                    }
                    ctx.stroke()
                }
            }

            // Icons layer (Repeater of Images)
            Item {
                id: nodesView
                anchors.fill: parent

                // Pre-compute node positions: { id: {x, y, icon, kind} }
                property var positionsById: _computePositions()
                function recompute() {
                    positionsById = _computePositions()
                    posList = _buildPosList(false)
                    ascPosList = _buildPosList(true)
                    canvas.requestPaint()
                    ascCanvas.requestPaint()
                }
                function _computePositions() {
                    if (!root.treeData) return {}
                    var radii    = root.treeData.constants.orbitRadii         || []
                    var perOrb   = root.treeData.constants.skillsPerOrbit     || []
                    var angTable = root.treeData.constants.orbitAnglesByOrbit || []
                    function angleFor(orbit, idx) {
                        var per = angTable[orbit]
                        if (per && per[idx] !== undefined) return per[idx] - Math.PI / 2
                        var slots = perOrb[orbit] || 1
                        return (idx / slots) * 2 * Math.PI - Math.PI / 2
                    }
                    var groups = root.treeData.groups
                    var nodes  = root.treeData.nodes
                    var selectedAsc = root.selectedAscendancy

                    // ─── Pass 1: main-tree positions
                    var out = {}
                    var ascNatural = []   // [{ nid, rx, ry, icon, kind }] in original coords
                    for (var nid in nodes) {
                        var n = nodes[nid]
                        var ascName = n.ascendancyName || ""
                        if (ascName !== "" && ascName !== selectedAsc) continue
                        if ((n.connections || []).length === 0 && n.name === "Attribute") continue
                        if (n.group === undefined || n.group === null) continue
                        var g = groups[String(n.group)]; if (!g) continue
                        var orbit = n.orbit || 0, idx = n.orbitIndex || 0
                        var r = radii[orbit] || 0
                        var a = angleFor(orbit, idx)
                        var rx = g.x + r * Math.cos(a)
                        var ry = g.y + r * Math.sin(a)
                        var kind = n.isKeystone ? "keystone" :
                                   n.isNotable  ? "notable"  :
                                   n.isJewelSocket ? "jewel" :
                                   n.isMastery ? "mastery" : "normal"
                        if (ascName === "") {
                            out[nid] = { x: rx, y: ry, icon: root._iconUrl(n.icon), kind: kind, asc: "" }
                        } else {
                            ascNatural.push({ nid: nid, rx: rx, ry: ry, icon: root._iconUrl(n.icon), kind: kind, asc: ascName })
                        }
                    }

                    // ─── Pass 2: fit ascendancy cluster inside portrait
                    // Computes the natural bounding box of the selected
                    // ascendancy and scales it uniformly to a fixed target
                    // diameter (≈ 65% of the portrait), preserving the
                    // cluster's natural shape regardless of which class is
                    // selected (Invoker's tall layout, Pathfinder's square,
                    // etc. all end up similar visual size).
                    if (ascNatural.length > 0) {
                        var minX =  1e9, minY =  1e9, maxX = -1e9, maxY = -1e9
                        for (var i = 0; i < ascNatural.length; i++) {
                            var p = ascNatural[i]
                            if (p.rx < minX) minX = p.rx
                            if (p.rx > maxX) maxX = p.rx
                            if (p.ry < minY) minY = p.ry
                            if (p.ry > maxY) maxY = p.ry
                        }
                        var cx = (minX + maxX) / 2
                        var cy = (minY + maxY) / 2
                        var spanX = Math.max(1, maxX - minX)
                        var spanY = Math.max(1, maxY - minY)
                        // Fit into a square region inside the portrait (~45%
                        // of the portrait diameter). Uniform scale on the
                        // larger of the two spans keeps the natural cluster
                        // shape but guarantees neither axis pokes out.
                        var targetSide = 2200
                        var ascZoom = targetSide / Math.max(spanX, spanY)
                        for (var j = 0; j < ascNatural.length; j++) {
                            var ap = ascNatural[j]
                            out[ap.nid] = {
                                x:    (ap.rx - cx) * ascZoom,
                                y:    (ap.ry - cy) * ascZoom,
                                icon: ap.icon,
                                kind: ap.kind,
                                asc:  ap.asc
                            }
                        }
                    }
                    return out
                }

                // When tree data loads, recompute everything
                Connections {
                    target: root
                    function onTreeDataChanged() { nodesView.recompute() }
                }

                // Two separate lists: main tree (renders BEHIND the portrait)
                // and ascendancy (renders ON TOP of the portrait). This
                // matches Mobalytics' layered presentation.
                property var posList:    _buildPosList(false)
                property var ascPosList: _buildPosList(true)
                function _buildPosList(wantAsc) {
                    var arr = []
                    if (!positionsById) return arr
                    for (var k in positionsById) {
                        var p = positionsById[k]
                        var isAsc = !!(p.asc && p.asc !== "")
                        if (isAsc !== wantAsc) continue
                        arr.push({ id: k, x: p.x, y: p.y, icon: p.icon, kind: p.kind, asc: p.asc || "" })
                    }
                    return arr
                }

                Repeater {
                    model: nodesView.posList
                    Image {
                        property real baseSize: modelData.kind === "keystone" ? 64
                                              : modelData.kind === "notable"  ? 56
                                              : modelData.kind === "jewel"    ? 44
                                              : modelData.kind === "mastery"  ? 40
                                              : 32
                        property real renderSize: Math.max(6, baseSize * root.scale)
                        width:  renderSize
                        height: renderSize
                        x: modelData.x * root.scale + root.panX - width / 2
                        y: modelData.y * root.scale + root.panY - height / 2
                        sourceSize.width:  Math.round(baseSize)
                        sourceSize.height: Math.round(baseSize)
                        source: modelData.icon
                        asynchronous: true
                        cache: true
                        fillMode: Image.PreserveAspectFit
                        visible: renderSize > 3
                                 && (x + width)  > -10 && x < viewport.width  + 10
                                 && (y + height) > -10 && y < viewport.height + 10
                    }
                }
            }

            // ── Class portrait at tree origin ─────────────────
            // Sits ON TOP of the main passive tree (z=1, above nodes
            // layer at z=0) so the dense class-start nodes underneath
            // get visually hidden behind the artwork — matching how
            // Mobalytics frames the centre of the tree.
            Item {
                id: portrait
                visible: !!root.selectedClass && !!root.selectedAscendancy && portraitImg.status === Image.Ready
                x: root.panX - width  / 2
                y: root.panY - height / 2
                // Portrait scales linearly with the world (4800 tree-units
                // wide) so it stays locked to the same area as the
                // ascendancy cluster on top — no clamping, since clamping
                // would desynchronise the two when the user zooms.
                width:  4800 * root.scale
                height: width
                z: 1

                Image {
                    id: portraitImg
                    anchors.fill: parent
                    source: root._portraitUrl(root.selectedClass, root.selectedAscendancy)
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
                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "white"
                    }
                }
                Rectangle {
                    // Gold ring border
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: "#8b7355"
                    border.width: Math.max(1, 3 * root.scale * 20)
                }
            }

            // ── Ascendancy connections (above portrait) ───────
            // Mirror the structure of the main connections canvas, but
            // only draw edges where both endpoints are ascendancy nodes.
            // Placed at z:2 so the lines sit on top of the portrait.
            Canvas {
                id: ascCanvas
                anchors.fill: parent
                renderStrategy: Canvas.Cooperative
                renderTarget:   Canvas.Image
                z: 2
                Connections {
                    target: nodesView
                    function onAscPosListChanged() { ascCanvas.requestPaint() }
                }
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    if (!root.treeData) return
                    var positions = nodesView.positionsById
                    if (!positions) return
                    var s = root.scale, ox = root.panX, oy = root.panY
                    var nodes = root.treeData.nodes
                    var drawn = {}
                    ctx.lineWidth   = Math.max(0.7, 7 * s)
                    ctx.strokeStyle = "#8a9ab0"
                    ctx.beginPath()
                    for (var nid in nodes) {
                        var n = nodes[nid]
                        if (!n.ascendancyName || n.ascendancyName === "") continue
                        if (n.ascendancyName !== root.selectedAscendancy) continue
                        var pa = positions[nid]; if (!pa) continue
                        var conns = n.connections || []
                        for (var c = 0; c < conns.length; c++) {
                            var oid = String(conns[c].id)
                            var pb  = positions[oid]; if (!pb) continue
                            var nOther = nodes[oid]
                            if (!nOther || nOther.ascendancyName !== root.selectedAscendancy) continue
                            var key = parseInt(nid) < parseInt(oid) ? nid+"_"+oid : oid+"_"+nid
                            if (drawn[key]) continue
                            drawn[key] = true
                            ctx.moveTo(pa.x * s + ox, pa.y * s + oy)
                            ctx.lineTo(pb.x * s + ox, pb.y * s + oy)
                        }
                    }
                    ctx.stroke()
                }
            }

            // ── Ascendancy nodes (on top of portrait) ─────────
            // Larger frames around each node give the Mobalytics-style
            // polished look (rather than just floating icons). Notables
            // get a gold ring, keystones an outer halo, normals a thin
            // steel ring.
            Item {
                id: ascLayer
                anchors.fill: parent
                z: 3
                Repeater {
                    model: nodesView.ascPosList
                    Item {
                        property real baseSize: modelData.kind === "keystone" ? 90
                                              : modelData.kind === "notable"  ? 70
                                              : modelData.kind === "jewel"    ? 64
                                              : 44
                        property real renderSize: Math.max(10, baseSize * root.scale)
                        width:  renderSize
                        height: renderSize
                        x: modelData.x * root.scale + root.panX - width / 2
                        y: modelData.y * root.scale + root.panY - height / 2
                        visible: renderSize > 5
                                 && (x + width)  > -10 && x < ascLayer.width  + 10
                                 && (y + height) > -10 && y < ascLayer.height + 10

                        // Frame ring
                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: "#0c0e14"
                            border.width: Math.max(1, renderSize / 18)
                            border.color: modelData.kind === "keystone" ? "#d4a843"
                                         : modelData.kind === "notable"  ? "#c5a070"
                                         : modelData.kind === "jewel"    ? "#7adde0"
                                                                         : "#6a7a90"
                            opacity: 0.92
                        }
                        // Icon
                        Image {
                            anchors.fill: parent
                            anchors.margins: Math.max(1, parent.renderSize * 0.08)
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

            // ── Pan + zoom + hover ────────────────────────────
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
                        root.panX += (mouseX - lastX)
                        root.panY += (mouseY - lastY)
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
                    var tx = (wheel.x - root.panX) / root.scale
                    var ty = (wheel.y - root.panY) / root.scale
                    root.scale = newScale
                    root.panX = wheel.x - tx * newScale
                    root.panY = wheel.y - ty * newScale
                    canvas.requestPaint()
                    ascCanvas.requestPaint()
                    root._updateHover(wheel.x, wheel.y)
                }
            }

            // ── Hover tooltip ──────────────────────────────────
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
                x: Math.max(4, Math.min(viewport.width  - implicitWidth  - 4, targetX))
                y: Math.max(4, Math.min(viewport.height - implicitHeight - 4, targetY < 4 ? root._hoverScreenY + 14 : targetY))
                implicitWidth:  tipCol.implicitWidth  + 16
                implicitHeight: tipCol.implicitHeight + 12

                RowLayout {
                    id: tipCol
                    x: 8; y: 6
                    spacing: 8

                    Image {
                        visible: tip.n && tip.n.icon
                        source: tip.n ? root._iconUrl(tip.n.icon) : ""
                        sourceSize.width: 48; sourceSize.height: 48
                        width: 48; height: 48
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: true
                        Layout.alignment: Qt.AlignTop
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            visible: tip.n
                            text: tip.n ? (tip.n.name || "") : ""
                            color: tip.n && tip.n.isKeystone ? "#ff7a3a" :
                                   tip.n && tip.n.isNotable  ? "#d4a843" :
                                   tip.n && tip.n.isJewelSocket ? "#7adde0" :
                                   tip.n && tip.n.isMastery ? "#e08545" : "#c0b090"
                            font.pixelSize: 12; font.bold: true
                        }
                        Repeater {
                            model: tip.n && tip.n.stats ? tip.n.stats : []
                            Text {
                                text: modelData
                                color: "#9aa8b8"; font.pixelSize: 10
                                wrapMode: Text.WordWrap
                                Layout.maximumWidth: 320
                            }
                        }
                        Text {
                            visible: tip.n && (tip.n.isKeystone || tip.n.isNotable || tip.n.isJewelSocket || tip.n.isMastery)
                            text: tip.n && tip.n.isKeystone ? "Keystone" :
                                  tip.n && tip.n.isNotable  ? "Notable"  :
                                  tip.n && tip.n.isJewelSocket ? "Jewel Socket" :
                                  tip.n && tip.n.isMastery  ? "Mastery"  : ""
                            color: "#5a6a80"; font.pixelSize: 9; font.italic: true
                        }
                    }
                }
            }

            // Loading state
            Text {
                visible: !root.treeData
                anchors.centerIn: parent
                text: "Cargando árbol…"
                color: "#7a6a50"; font.pixelSize: 12
            }
        }
    }
}

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "js/State.js" as State

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

    property bool   isOpen:      false
    property int    offsetX:     400
    property int    offsetY:     80
    property real   windowW:     820
    property real   windowH:     560
    property string _homeDir:    ""
    property var    builds:      []          // saved imported builds
    property int    selected:    -1
    property int    variantSel:  0           // active variant tab
    property bool   importing:   false
    property string importErr:   ""
    property string _pendingUrl: ""

    onSelectedChanged: variantSel = 0

    // Builds list grouped by character class, alphabetised, headers in
    // the same array so a single Repeater renders both.
    readonly property var _groupedBuilds: {
        var groups = {}
        for (var i = 0; i < builds.length; i++) {
            var b = builds[i]
            var cls = b.charClass || "Otros"
            if (!groups[cls]) groups[cls] = { icon: b.classIcon || "", items: [] }
            groups[cls].items.push({ build: b, origIndex: i })
        }
        var classNames = Object.keys(groups).sort()
        var out = []
        for (var c = 0; c < classNames.length; c++) {
            var g = groups[classNames[c]]
            out.push({ kind: "header", className: classNames[c], icon: g.icon, count: g.items.length })
            for (var k = 0; k < g.items.length; k++) {
                var it = g.items[k]
                out.push({ kind: "item", build: it.build, origIndex: it.origIndex })
            }
        }
        return out
    }

    Component.onCompleted: {
        State.addBuildsOpenListener(function(v) { root.isOpen = v })
    }

    // ── Load saved builds + position on startup ──────────────────
    Process {
        id: bHomeProc
        command: ["sh", "-c", "printf '%s' \"$HOME\""]
        stdout: StdioCollector { id: bHomeOut }
        Component.onCompleted: running = true
        onRunningChanged: {
            if (!running) {
                root._homeDir = bHomeOut.text.trim()
                bLoadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-builds\" 2>/dev/null"]
                bLoadProc.running = true
                posLoadBuildsProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-pos-builds\" 2>/dev/null"]
                posLoadBuildsProc.running = true
                sizeLoadBuildsProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-size-builds\" 2>/dev/null"]
                sizeLoadBuildsProc.running = true
            }
        }
    }

    Process { id: sizeSaveBuildsProc }
    Process {
        id: sizeLoadBuildsProc
        stdout: StdioCollector { id: sizeLoadBuildsOut }
        onRunningChanged: {
            if (!running) {
                var txt = sizeLoadBuildsOut.text.trim()
                if (txt && txt.indexOf("x") !== -1) {
                    var parts = txt.split("x")
                    var w = parseInt(parts[0], 10); var h = parseInt(parts[1], 10)
                    if (!isNaN(w) && w >= 600 && w <= 1800) root.windowW = w
                    if (!isNaN(h) && h >= 400 && h <= 1400) root.windowH = h
                }
            }
        }
    }

    function _saveSize() {
        if (_homeDir === "" || sizeSaveBuildsProc.running) return
        sizeSaveBuildsProc.command = ["sh", "-c",
            "printf '%sx%s' " + Math.round(windowW) + " " + Math.round(windowH) +
            " > \"" + _homeDir + "/.config/quickshell/poe2/.saved-size-builds\""]
        sizeSaveBuildsProc.running = true
    }

    Process {
        id: bLoadProc
        stdout: StdioCollector { id: bLoadOut }
        onRunningChanged: {
            if (!running) {
                var txt = bLoadOut.text.trim()
                if (txt) {
                    try { root.builds = JSON.parse(txt) } catch (e) { root.builds = [] }
                }
            }
        }
    }

    Process {
        id: bSaveProc
        onRunningChanged: {
            if (!running && root._saveQueued) {
                root._saveQueued = false
                Qt.callLater(root._saveBuilds)
            }
        }
    }
    Process { id: posSaveBuildsProc }
    Process { id: pobCopyProc }

    property bool _saveQueued: false

    // Passive tree data (loaded lazily from .cache/tree.json the first time
    // any build's passive_summary becomes visible).
    property var    _treeData:        null
    property bool   _treeLoading:     false
    property string _treeError:       ""

    function _ensureTree() {
        if (_treeData || _treeLoading || _homeDir === "") return
        _treeLoading = true
        treeFetchProc.command = ["sh", "-c",
            "F=\"" + _homeDir + "/.config/quickshell/poe2/.cache/tree.json\"; " +
            "if [ ! -f \"$F\" ]; then " +
            "  /usr/bin/python3 \"" + _homeDir + "/.config/quickshell/poe2/scripts/fetch-tree.py\" >&2 || exit 1; " +
            "fi; " +
            "cat \"$F\""]
        treeFetchProc.running = true
    }

    Process {
        id: treeFetchProc
        stdout: StdioCollector { id: treeFetchOut }
        onRunningChanged: {
            if (!running) {
                root._treeLoading = false
                var text = treeFetchOut.text
                if (text.length < 1000) {
                    root._treeError = "No se pudo cargar tree.json (¿python3 / lua / red OK?)"
                    return
                }
                try { root._treeData = JSON.parse(text) }
                catch (e) { root._treeError = "tree.json inválido: " + e.message }
            }
        }
    }

    Process {
        id: posLoadBuildsProc
        stdout: StdioCollector { id: posLoadBuildsOut }
        onRunningChanged: {
            if (!running) {
                var txt = posLoadBuildsOut.text.trim()
                if (txt && txt.indexOf(",") !== -1) {
                    var parts = txt.split(",")
                    var x = parseInt(parts[0], 10); var y = parseInt(parts[1], 10)
                    if (!isNaN(x) && x >= 0) root.offsetX = x
                    if (!isNaN(y) && y >= 0) root.offsetY = y
                }
            }
        }
    }

    // ── Python script does fetch + extract + flatten ─────────────
    // Stage 1: run the script, output goes to /tmp/poe2-mob-build.json.
    // Stage 2: read /tmp/poe2-mob-build.json (or .err) back into QML.
    Process {
        id: fetchProc
        stdout: StdioCollector { id: fetchOut }
        onRunningChanged: {
            if (!running) {
                console.log("[BuildsWindow] fetchProc done, stdout:", fetchOut.text.trim())
                var m = fetchOut.text.match(/EXIT=(\d+)/)
                var scriptExit = m ? parseInt(m[1], 10) : -1
                if (scriptExit !== 0) {
                    readErrProc.command = ["sh", "-c", "cat /tmp/poe2-mob-build.err 2>/dev/null"]
                    readErrProc._scriptExit = scriptExit
                    readErrProc.running = true
                } else {
                    readOutProc.command = ["sh", "-c", "cat /tmp/poe2-mob-build.json"]
                    readOutProc.running = true
                }
            }
        }
    }

    Process {
        id: readErrProc
        property int _scriptExit: -1
        stdout: StdioCollector { id: readErrOut }
        onRunningChanged: {
            if (!running) {
                root.importing = false
                root.importErr = (readErrOut.text.trim() || "Script falló") +
                                 " (exit=" + readErrProc._scriptExit + ")"
                console.log("[BuildsWindow] script error:", root.importErr)
            }
        }
    }

    Process {
        id: readOutProc
        stdout: StdioCollector { id: readOutOut }
        onRunningChanged: {
            if (!running) {
                console.log("[BuildsWindow] script JSON size:", readOutOut.text.length)
                try {
                    var guide = JSON.parse(readOutOut.text)
                    var arr = [guide]
                    for (var j = 0; j < root.builds.length; j++)
                        if (root.builds[j].id !== guide.id) arr.push(root.builds[j])
                    root.builds = arr
                    root.selected = 0
                    root._saveBuilds()
                    urlInput.text = ""
                } catch (e) {
                    root.importErr = "JSON inválido: " + e.message + " (recibidos " + readOutOut.text.length + " bytes)"
                    console.log("[BuildsWindow] JSON parse error:", root.importErr)
                }
                root.importing = false
            }
        }
    }

    function _b64encode(str) { return Qt.btoa(unescape(encodeURIComponent(str))) }

    function _saveBuilds() {
        if (root._homeDir === "") return
        if (bSaveProc.running) { root._saveQueued = true; return }
        var dst = root._homeDir + "/.config/quickshell/poe2/.saved-builds"
        var tmp = "/tmp/poe2-saved-builds.b64"
        var b64 = _b64encode(JSON.stringify(root.builds))
        // Write base64 to a temp file with printf, then decode to atomic temp,
        // then rename. Splitting the pipeline avoids any ARG_MAX edge cases
        // and gives us a non-corrupt file even if the process is interrupted.
        bSaveProc.command = ["sh", "-c",
            "printf '%s' '" + b64 + "' > \"" + tmp + "\" && " +
            "base64 -d < \"" + tmp + "\" > \"" + dst + ".tmp\" && " +
            "mv \"" + dst + ".tmp\" \"" + dst + "\" && " +
            "rm -f \"" + tmp + "\""]
        bSaveProc.running = true
    }

    function _import(url) {
        root.importErr = ""
        if (!url || url.indexOf("mobalytics.gg") === -1 || url.indexOf("/builds/") === -1) {
            root.importErr = "URL debe ser mobalytics.gg/.../builds/…"
            return
        }
        if (fetchProc.running) return
        if (root._homeDir === "") { root.importErr = "$HOME no resuelto aún"; return }
        root._pendingUrl = url
        root.importing = true
        // Run through sh so PATH lookup + redirects work; absolute paths
        // for python3 and the script avoid PATH issues inside Quickshell.
        // The script's JSON goes to /tmp/, then we cat it — keeps stdout
        // small in case Quickshell's StdioCollector has surprises.
        var script = root._homeDir + "/.config/quickshell/poe2/scripts/mob-extract.py"
        var outFile = "/tmp/poe2-mob-build.json"
        var errFile = "/tmp/poe2-mob-build.err"
        console.log("[BuildsWindow] _import:", url)
        console.log("[BuildsWindow] script:", script)
        fetchProc.command = ["sh", "-c",
            "/usr/bin/python3 \"" + script + "\" \"" + url + "\" > " + outFile +
            " 2> " + errFile + "; echo EXIT=$?"]
        fetchProc.running = true
    }

    function _savePos() {
        if (_homeDir === "" || posSaveBuildsProc.running) return
        posSaveBuildsProc.command = ["sh", "-c",
            "printf '%d,%d' " + Math.round(offsetX) + " " + Math.round(offsetY) +
            " > \"" + _homeDir + "/.config/quickshell/poe2/.saved-pos-builds\""]
        posSaveBuildsProc.running = true
    }

    function _deleteSelected() { _deleteAt(selected) }

    function _deleteAt(idx) {
        if (idx < 0 || idx >= builds.length) return
        var arr = []
        for (var i = 0; i < builds.length; i++) if (i !== idx) arr.push(builds[i])
        builds = arr
        // Keep selection sensible after deletion
        if (arr.length === 0) selected = -1
        else if (selected === idx) selected = Math.min(idx, arr.length - 1)
        else if (selected > idx)   selected = selected - 1
        _saveBuilds()
    }

    // ── UI ───────────────────────────────────────────────────────
    Rectangle {
        id: panel
        visible: root.isOpen
        anchors.fill: parent
        color: "#1c1c1e"
        border.color: "#8B7355"
        border.width: 1
        radius: 8

        // Resize handles
        Item {
            id: resizeRight
            width: 6
            anchors { top: parent.top; bottom: parent.bottom; bottomMargin: 16; right: parent.right }
            property real pressLocalX: 0
            property real startW: 0
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SizeHorCursor
                onPressed:        { resizeRight.pressLocalX = mapToItem(panel, mouseX, mouseY).x; resizeRight.startW = root.windowW }
                onPositionChanged: { if (pressed) root.windowW = Math.max(600, Math.min(1800, resizeRight.startW + (mapToItem(panel, mouseX, mouseY).x - resizeRight.pressLocalX))) }
                onReleased:        root._saveSize()
            }
        }
        Item {
            id: resizeBottom
            height: 6
            anchors { left: parent.left; right: parent.right; rightMargin: 16; bottom: parent.bottom }
            property real pressLocalY: 0
            property real startH: 0
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SizeVerCursor
                onPressed:        { resizeBottom.pressLocalY = mapToItem(panel, mouseX, mouseY).y; resizeBottom.startH = root.windowH }
                onPositionChanged: { if (pressed) root.windowH = Math.max(400, Math.min(1400, resizeBottom.startH + (mapToItem(panel, mouseX, mouseY).y - resizeBottom.pressLocalY))) }
                onReleased:        root._saveSize()
            }
        }
        Item {
            id: resizeCorner
            width: 16; height: 16
            anchors { right: parent.right; bottom: parent.bottom }
            property real pressLocalX: 0; property real pressLocalY: 0
            property real startW: 0;      property real startH: 0
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SizeFDiagCursor
                onPressed: {
                    var pt = mapToItem(panel, mouseX, mouseY)
                    resizeCorner.pressLocalX = pt.x; resizeCorner.pressLocalY = pt.y
                    resizeCorner.startW = root.windowW;  resizeCorner.startH = root.windowH
                }
                onPositionChanged: {
                    if (pressed) {
                        var pt = mapToItem(panel, mouseX, mouseY)
                        root.windowW = Math.max(600, Math.min(1800, resizeCorner.startW + (pt.x - resizeCorner.pressLocalX)))
                        root.windowH = Math.max(400, Math.min(1400, resizeCorner.startH + (pt.y - resizeCorner.pressLocalY)))
                    }
                }
                onReleased: root._saveSize()
            }
        }

        ColumnLayout {
            anchors { fill: parent; margins: 12 }
            spacing: 8

            // Header (drag handle)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "⠿ 📘 Builds importadas (Mobalytics)"
                    color: "#d4a843"; font.pixelSize: 14; font.bold: true
                    Layout.fillWidth: true
                    MouseArea {
                        anchors.fill: parent
                        property real mx: 0; property real my: 0
                        property int  ox: 0; property int  oy: 0
                        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                        onPressed:         { mx = mouseX; my = mouseY; ox = root.offsetX; oy = root.offsetY }
                        onPositionChanged: { if (pressed) { root.offsetX = Math.max(0, ox + (mouseX - mx)); root.offsetY = Math.max(0, oy + (mouseY - my)) } }
                        onReleased:        root._savePos()
                    }
                }
                Text {
                    text: "✕"
                    color: "#9a6a50"; font.pixelSize: 14
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: State.setBuildsOpen(false)
                    }
                }
            }

            // URL input row
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    Layout.fillWidth: true; height: 28; radius: 4
                    color: "#0d0f12"; border.color: "#3a3a3a"; border.width: 1
                    TextInput {
                        id: urlInput
                        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                        color: "#dde8f0"; font.pixelSize: 11
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true
                        onAccepted: if (text.length > 10) root._import(text)
                    }
                    Text {
                        visible: urlInput.text === ""
                        anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                        text: "https://mobalytics.gg/poe-2/builds/…"
                        color: "#5a5a5a"; font.pixelSize: 11
                    }
                }

                Rectangle {
                    width: 90; height: 28; radius: 4
                    color: root.importing ? "#3a3a3a" : "#1e4a3a"
                    border.color: "#3a7a5a"; border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: root.importing ? "..." : "Importar"
                        color: "#7adda0"; font.pixelSize: 11; font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: !root.importing
                        onClicked: if (urlInput.text.length > 10) root._import(urlInput.text)
                    }
                }
            }

            Text {
                visible: root.importErr !== ""
                text: "⚠ " + root.importErr
                color: "#d05050"; font.pixelSize: 11; Layout.fillWidth: true
            }

            // Body — list + detail
            RowLayout {
                Layout.fillWidth: true; Layout.fillHeight: true
                spacing: 8

                // List
                Rectangle {
                    Layout.preferredWidth: 230
                    Layout.fillHeight: true
                    color: "#0d0f12"; border.color: "#2a2a2d"; border.width: 1; radius: 4

                    ScrollView {
                        id: listScroll
                        anchors.fill: parent; anchors.margins: 4
                        clip: true
                        contentWidth: availableWidth
                        contentHeight: listCol.implicitHeight
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        ColumnLayout {
                            id: listCol
                            width: listScroll.availableWidth
                            spacing: 2

                            Text {
                                visible: root.builds.length === 0
                                text: "  Pega una URL de Mobalytics arriba para importar tu primera build."
                                color: "#5a5a5a"; font.pixelSize: 10
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                Layout.margins: 6
                            }

                            // Build the grouped model client-side: array of
                            // { kind: "header", className, icon } and
                            // { kind: "item", build, origIndex } entries.
                            Repeater {
                                model: root._groupedBuilds
                                Loader {
                                    Layout.fillWidth: true
                                    sourceComponent: modelData.kind === "header" ? headerRow : itemRow
                                    property var rowData: modelData
                                }
                            }

                            Component {
                                id: headerRow
                                Rectangle {
                                    width: parent ? parent.width : 0
                                    height: 26
                                    color: "#161a20"
                                    radius: 3
                                    RowLayout {
                                        anchors { fill: parent; leftMargin: 6; rightMargin: 6 }
                                        spacing: 6
                                        Image {
                                            visible: rowData && rowData.icon !== ""
                                            source: rowData ? rowData.icon : ""
                                            sourceSize.width: 18; sourceSize.height: 18
                                            width: 18; height: 18
                                            fillMode: Image.PreserveAspectFit
                                        }
                                        Text {
                                            text: rowData ? rowData.className : ""
                                            color: "#d4a843"; font.pixelSize: 11; font.bold: true
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: rowData ? "(" + rowData.count + ")" : ""
                                            color: "#5a5a5a"; font.pixelSize: 9
                                        }
                                    }
                                }
                            }

                            Component {
                                id: itemRow
                                Rectangle {
                                    width: parent ? parent.width : 0
                                    height: 42
                                    radius: 3
                                    color: rowData && rowData.origIndex === root.selected ? "#2a2a3a" : (rowMouse.containsMouse ? "#181820" : "transparent")
                                    border.color: rowData && rowData.origIndex === root.selected ? "#5a5a7a" : "transparent"
                                    border.width: 1

                                    MouseArea {
                                        id: rowMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (rowData) root.selected = rowData.origIndex
                                    }

                                    RowLayout {
                                        anchors { fill: parent; margins: 6 }
                                        spacing: 4

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 1
                                            Text {
                                                text: rowData && rowData.build ? rowData.build.name : ""
                                                color: "#c0b090"; font.pixelSize: 10; font.bold: true
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                            Text {
                                                text: {
                                                    if (!rowData || !rowData.build) return ""
                                                    var b = rowData.build
                                                    var asc = b.ascendancy ? "  ·  " + b.ascendancy : ""
                                                    return "by " + b.author + asc
                                                }
                                                color: "#5a5a5a"; font.pixelSize: 9
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                        }

                                        Rectangle {
                                            visible: rowMouse.containsMouse || trashMouse.containsMouse
                                            Layout.alignment: Qt.AlignVCenter
                                            width: 22; height: 22; radius: 3
                                            color: trashMouse.containsMouse ? "#3a0f0f" : "transparent"
                                            border.color: trashMouse.containsMouse ? "#7a2020" : "transparent"
                                            border.width: 1
                                            Text {
                                                anchors.centerIn: parent
                                                text: "🗑"
                                                color: "#d05050"; font.pixelSize: 11
                                            }
                                            MouseArea {
                                                id: trashMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: if (rowData) root._deleteAt(rowData.origIndex)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Detail
                Rectangle {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    color: "#0d0f12"; border.color: "#2a2a2d"; border.width: 1; radius: 4

                    ScrollView {
                        id: detailScroll
                        anchors.fill: parent; anchors.margins: 10
                        clip: true
                        contentWidth: availableWidth
                        contentHeight: detail.implicitHeight
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded

                        ColumnLayout {
                            id: detail
                            width: detailScroll.availableWidth
                            spacing: 10

                            property var current: (root.selected >= 0 && root.selected < root.builds.length)
                                                  ? root.builds[root.selected] : null
                            property var activeVariant: {
                                if (!current || !current.variants) return null
                                var vs = current.variants
                                if (root.variantSel < 0 || root.variantSel >= vs.length) return null
                                return vs[root.variantSel]
                            }

                            // Empty state
                            Text {
                                visible: !detail.current
                                text: "Selecciona una build de la lista o importa una nueva."
                                color: "#5a5a5a"; font.pixelSize: 11
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            // Header
                            ColumnLayout {
                                visible: !!detail.current
                                Layout.fillWidth: true; spacing: 3

                                Text {
                                    text: detail.current ? detail.current.name : ""
                                    color: "#d4a843"; font.pixelSize: 13; font.bold: true
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                                RowLayout {
                                    spacing: 6
                                    Text {
                                        text: detail.current ? "by " + detail.current.author : ""
                                        color: "#7a7a7a"; font.pixelSize: 10
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: "→ Mobalytics"
                                        color: "#4a7aaa"; font.pixelSize: 10
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: if (detail.current) Qt.openUrlExternally(detail.current.url)
                                        }
                                    }
                                    Text {
                                        text: root.importing ? "⏳" : "🔄"
                                        color: "#7adda0"; font.pixelSize: 11
                                        MouseArea {
                                            id: refreshMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            enabled: !root.importing
                                            onClicked: if (detail.current && detail.current.url) root._import(detail.current.url)
                                        }
                                    }
                                    Text {
                                        text: "🗑"
                                        color: "#9a5050"; font.pixelSize: 11
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: root._deleteSelected()
                                        }
                                    }
                                }
                                Rectangle { Layout.fillWidth: true; height: 1; color: "#2a2a2d" }
                            }

                            // Section delegate — reused for both top-level and variant sections
                            Component {
                                id: sectionDelegate
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 4

                                    Text {
                                        visible: !!modelData.title
                                        text: modelData.title || ""
                                        color: "#8ab4d4"; font.pixelSize: 12; font.bold: true
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        visible: modelData.kind === "text"
                                        text: modelData.body || ""
                                        color: "#c0b090"; font.pixelSize: 11
                                        wrapMode: Text.WordWrap
                                        textFormat: Text.PlainText
                                        Layout.fillWidth: true
                                    }

                                    RowLayout {
                                        visible: modelData.kind === "strengths"
                                        Layout.fillWidth: true; spacing: 10

                                        ColumnLayout {
                                            Layout.fillWidth: true; Layout.alignment: Qt.AlignTop
                                            Text { text: "Strengths"; color: "#5fa56f"; font.pixelSize: 10; font.bold: true }
                                            Repeater {
                                                model: modelData.strengths || []
                                                Text {
                                                    text: "✓ " + modelData
                                                    color: "#9ac49a"; font.pixelSize: 10
                                                    wrapMode: Text.WordWrap
                                                    Layout.fillWidth: true
                                                }
                                            }
                                        }
                                        ColumnLayout {
                                            Layout.fillWidth: true; Layout.alignment: Qt.AlignTop
                                            Text { text: "Weaknesses"; color: "#a55f5f"; font.pixelSize: 10; font.bold: true }
                                            Repeater {
                                                model: modelData.weaknesses || []
                                                Text {
                                                    text: "✗ " + modelData
                                                    color: "#c49a9a"; font.pixelSize: 10
                                                    wrapMode: Text.WordWrap
                                                    Layout.fillWidth: true
                                                }
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        visible: modelData.kind === "equipment_real"
                                        Layout.fillWidth: true; spacing: 4

                                        Repeater {
                                            model: modelData.items || []
                                            RowLayout {
                                                spacing: 8; Layout.fillWidth: true

                                                Image {
                                                    visible: modelData.iconUrl !== ""
                                                    source: modelData.iconUrl
                                                    sourceSize.width: 32; sourceSize.height: 32
                                                    width: 32; height: 32
                                                    fillMode: Image.PreserveAspectFit
                                                    Layout.alignment: Qt.AlignTop
                                                }
                                                ColumnLayout {
                                                    Layout.fillWidth: true; spacing: 1
                                                    RowLayout {
                                                        spacing: 6
                                                        Text {
                                                            text: modelData.slot
                                                            color: "#5a5a5a"; font.pixelSize: 9
                                                            Layout.preferredWidth: 80
                                                        }
                                                        Text {
                                                            text: modelData.name
                                                            color: modelData.isUnique ? "#af6025" : "#c0b090"
                                                            font.pixelSize: 11; font.bold: true
                                                            wrapMode: Text.WordWrap
                                                            Layout.fillWidth: true
                                                        }
                                                    }
                                                    Repeater {
                                                        model: modelData.mods || []
                                                        Text {
                                                            text: "  " + modelData
                                                            color: "#7a8aaa"; font.pixelSize: 9
                                                            wrapMode: Text.WordWrap
                                                            Layout.fillWidth: true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        visible: modelData.kind === "skills_real"
                                        Layout.fillWidth: true; spacing: 4

                                        Repeater {
                                            model: modelData.groups || []
                                            RowLayout {
                                                spacing: 8; Layout.fillWidth: true

                                                Image {
                                                    visible: modelData.mainIcon !== ""
                                                    source: modelData.mainIcon
                                                    sourceSize.width: 28; sourceSize.height: 28
                                                    width: 28; height: 28
                                                    fillMode: Image.PreserveAspectFit
                                                    Layout.alignment: Qt.AlignTop
                                                }
                                                ColumnLayout {
                                                    Layout.fillWidth: true; spacing: 1
                                                    Text {
                                                        text: modelData.main + (modelData.level ? "  (lvl " + modelData.level + ")" : "")
                                                        color: "#d4a843"; font.pixelSize: 11; font.bold: true
                                                    }
                                                    Text {
                                                        visible: modelData.supports && modelData.supports.length > 0
                                                        text: "+ " + (modelData.supports || []).join(", ")
                                                        color: "#7a8aaa"; font.pixelSize: 9
                                                        wrapMode: Text.WordWrap
                                                        Layout.fillWidth: true
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Passive tree summary
                                    ColumnLayout {
                                        visible: modelData.kind === "passive_summary"
                                        Layout.fillWidth: true; spacing: 4

                                        // Kick off lazy load of tree data the first time we show
                                        Component.onCompleted: root._ensureTree()

                                        // The interactive tree render
                                        PassiveTreeView {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 460
                                            treeData: root._treeData
                                            charClass:      detail.current ? (detail.current.charClass  || "") : ""
                                            ascendancyName: detail.current ? (detail.current.ascendancy || "") : ""
                                            allocatedNodeIds: modelData.allocatedIds  || []
                                            ascendancyIds:    modelData.ascendancyIds || []
                                        }

                                        Text {
                                            visible: root._treeLoading
                                            text: "Cargando árbol de pasivas…"
                                            color: "#7a6a50"; font.pixelSize: 10
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            visible: root._treeError !== ""
                                            text: "⚠ " + root._treeError
                                            color: "#d05050"; font.pixelSize: 10
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 8
                                            Text {
                                                text: "▣ " + (modelData.mainCount || 0) + " nodos principales" +
                                                      (modelData.ascendancyCount ? "  ·  " + modelData.ascendancyCount + " ascendancy" : "") +
                                                      (modelData.jewels && modelData.jewels.length ? "  ·  " + modelData.jewels.length + " jewels" : "")
                                                color: "#9aa8b8"; font.pixelSize: 11
                                                Layout.fillWidth: true
                                            }
                                            Rectangle {
                                                width: treeLinkText.implicitWidth + 14; height: 22; radius: 3
                                                color: "#1a2535"; border.color: "#3a5060"; border.width: 1
                                                Text {
                                                    id: treeLinkText
                                                    anchors.centerIn: parent
                                                    text: "🌳 Ver árbol en Mobalytics"
                                                    color: "#7adde0"; font.pixelSize: 10; font.bold: true
                                                }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: if (detail.current) Qt.openUrlExternally(detail.current.url)
                                                }
                                            }
                                        }

                                        Flow {
                                            visible: modelData.jewels && modelData.jewels.length > 0
                                            Layout.fillWidth: true
                                            spacing: 6
                                            Repeater {
                                                model: modelData.jewels || []
                                                Rectangle {
                                                    width: jewelRow.implicitWidth + 14
                                                    height: 28
                                                    radius: 3
                                                    color: "#161a20"
                                                    border.color: modelData.isUnique ? "#af6025" : "#2a3040"
                                                    border.width: 1
                                                    RowLayout {
                                                        id: jewelRow
                                                        anchors.centerIn: parent
                                                        spacing: 4
                                                        Image {
                                                            visible: modelData.iconUrl !== ""
                                                            source: modelData.iconUrl
                                                            sourceSize.width: 20; sourceSize.height: 20
                                                            width: 20; height: 20
                                                            fillMode: Image.PreserveAspectFit
                                                        }
                                                        Text {
                                                            text: modelData.name
                                                            color: modelData.isUnique ? "#af6025" : "#9aa8b8"
                                                            font.pixelSize: 9
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Rectangle { Layout.fillWidth: true; height: 1; color: "#1a1a1d"; Layout.topMargin: 4 }
                                }
                            }

                            // Top-level sections (overview, strengths/weaknesses)
                            Repeater {
                                model: detail.current ? (detail.current.sections || []) : []
                                delegate: sectionDelegate
                            }

                            // ── Variant tabs ────────────────────────────
                            Flow {
                                visible: !!detail.current && (detail.current.variants || []).length > 0
                                Layout.fillWidth: true
                                Layout.topMargin: 8
                                spacing: 4

                                Repeater {
                                    model: detail.current ? (detail.current.variants || []) : []

                                    Rectangle {
                                        property bool active: index === root.variantSel
                                        height: 26
                                        width: tabLabel.implicitWidth + 18
                                        radius: 3
                                        color: active ? "#2a3a4a" : "#161a20"
                                        border.color: active ? "#7adde0" : "#2a3040"
                                        border.width: 1

                                        Text {
                                            id: tabLabel
                                            anchors.centerIn: parent
                                            text: modelData.title || ("Variant " + index)
                                            color: parent.active ? "#7adde0" : "#8a9aaa"
                                            font.pixelSize: 10
                                            font.bold: parent.active
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.variantSel = index
                                        }

                                        // Active-tab underline
                                        Rectangle {
                                            visible: parent.active
                                            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                                            height: 2
                                            color: "#d4a843"
                                        }
                                    }
                                }
                            }

                            // Variant description
                            Text {
                                visible: !!detail.activeVariant && !!detail.activeVariant.description
                                text: detail.activeVariant ? detail.activeVariant.description : ""
                                color: "#9aa8b8"; font.pixelSize: 10
                                wrapMode: Text.WordWrap
                                textFormat: Text.PlainText
                                Layout.fillWidth: true
                                Layout.topMargin: 4
                            }

                            // Selected variant's sections
                            Repeater {
                                model: detail.activeVariant ? (detail.activeVariant.sections || []) : []
                                delegate: sectionDelegate
                            }

                            // PoB code — fixed-height scrollable box + Copy button
                            ColumnLayout {
                                visible: !!detail.current && !!detail.current.pobCode
                                Layout.fillWidth: true
                                Layout.topMargin: 8
                                spacing: 3

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "Path of Building code"
                                        color: "#8ab4d4"; font.pixelSize: 12; font.bold: true
                                        Layout.fillWidth: true
                                    }
                                    Rectangle {
                                        width: 80; height: 22; radius: 3
                                        color: "#1e4a3a"; border.color: "#3a7a5a"; border.width: 1
                                        Text {
                                            anchors.centerIn: parent
                                            text: "📋 Copiar"
                                            color: "#7adda0"; font.pixelSize: 10; font.bold: true
                                        }
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (detail.current && detail.current.pobCode) {
                                                    pobCopyProc.command = ["sh", "-c",
                                                        "printf '%s' '" +
                                                        Qt.btoa(unescape(encodeURIComponent(detail.current.pobCode))) +
                                                        "' | base64 -d | wl-copy"]
                                                    pobCopyProc.running = true
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 80
                                    color: "#060e18"; border.color: "#2d4060"; border.width: 1; radius: 3
                                    clip: true

                                    ScrollView {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        clip: true
                                        ScrollBar.vertical.policy: ScrollBar.AsNeeded

                                        TextEdit {
                                            id: pobText
                                            width: parent.width
                                            text: detail.current ? (detail.current.pobCode || "") : ""
                                            color: "#7a8aaa"; font.pixelSize: 9; font.family: "monospace"
                                            wrapMode: TextEdit.WrapAnywhere
                                            readOnly: true
                                            selectByMouse: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

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
    implicitWidth:  isOpen ? 820 : 1
    implicitHeight: isOpen ? 560 : 1

    property bool   isOpen:      false
    property int    offsetX:     400
    property int    offsetY:     80
    property string _homeDir:    ""
    property var    builds:      []          // saved imported builds
    property int    selected:    -1
    property bool   importing:   false
    property string importErr:   ""
    property string _pendingUrl: ""

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
            }
        }
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

    Process { id: bSaveProc }
    Process { id: posSaveBuildsProc }

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
        if (root._homeDir === "" || bSaveProc.running) return
        var b64 = _b64encode(JSON.stringify(root.builds))
        bSaveProc.command = ["sh", "-c",
            "printf '%s' '" + b64 + "' | base64 -d > \"" +
            root._homeDir + "/.config/quickshell/poe2/.saved-builds\""]
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

    function _deleteSelected() {
        if (selected < 0 || selected >= builds.length) return
        var arr = []
        for (var i = 0; i < builds.length; i++) if (i !== selected) arr.push(builds[i])
        builds = arr
        selected = arr.length > 0 ? 0 : -1
        _saveBuilds()
    }

    // ── UI ───────────────────────────────────────────────────────
    Rectangle {
        visible: root.isOpen
        anchors.fill: parent
        color: "#1c1c1e"
        border.color: "#8B7355"
        border.width: 1
        radius: 8

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
                        anchors.fill: parent; anchors.margins: 4
                        clip: true
                        ColumnLayout {
                            width: parent.width
                            spacing: 2

                            Text {
                                visible: root.builds.length === 0
                                text: "  Pega una URL de Mobalytics arriba para importar tu primera build."
                                color: "#5a5a5a"; font.pixelSize: 10
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                Layout.margins: 6
                            }

                            Repeater {
                                model: root.builds
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 42
                                    radius: 3
                                    color: index === root.selected ? "#2a2a3a" : "transparent"
                                    border.color: index === root.selected ? "#5a5a7a" : "transparent"
                                    border.width: 1

                                    ColumnLayout {
                                        anchors { fill: parent; margins: 6 }
                                        spacing: 1
                                        Text {
                                            text: modelData.name
                                            color: "#c0b090"; font.pixelSize: 10; font.bold: true
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: "by " + modelData.author
                                            color: "#5a5a5a"; font.pixelSize: 9
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.selected = index
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
                        anchors.fill: parent; anchors.margins: 10
                        clip: true

                        ColumnLayout {
                            id: detail
                            width: parent.width
                            spacing: 10

                            property var current: (root.selected >= 0 && root.selected < root.builds.length)
                                                  ? root.builds[root.selected] : null

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

                            // Sections
                            Repeater {
                                model: detail.current ? detail.current.sections : []
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 4

                                    Text {
                                        visible: !!modelData.title
                                        text: modelData.title || ""
                                        color: "#8ab4d4"; font.pixelSize: 12; font.bold: true
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }

                                    // Text section
                                    Text {
                                        visible: modelData.kind === "text"
                                        text: modelData.body || ""
                                        color: "#c0b090"; font.pixelSize: 11
                                        wrapMode: Text.WordWrap
                                        textFormat: Text.PlainText
                                        Layout.fillWidth: true
                                    }

                                    // Strengths/Weaknesses
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

                                    // Equipment (real gear from variant)
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

                                    // Skills (real gems from variant)
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

                                    Rectangle { Layout.fillWidth: true; height: 1; color: "#1a1a1d"; Layout.topMargin: 4 }
                                }
                            }

                            // PoB code
                            ColumnLayout {
                                visible: !!detail.current && detail.current.pobCode
                                Layout.fillWidth: true; spacing: 3
                                Text {
                                    text: "Path of Building code"
                                    color: "#8ab4d4"; font.pixelSize: 12; font.bold: true
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: pobText.implicitHeight + 12
                                    color: "#060e18"; border.color: "#2d4060"; border.width: 1; radius: 3
                                    TextEdit {
                                        id: pobText
                                        anchors { fill: parent; margins: 6 }
                                        text: detail.current ? detail.current.pobCode : ""
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

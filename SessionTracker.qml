import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "js/State.js" as State

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.margins.left: offsetX
    WlrLayershell.margins.top:  offsetY

    anchors.top:  true
    anchors.left: true

    color: "transparent"
    implicitWidth:  widgetVisible ? 200 : 1
    implicitHeight: widgetVisible ? (collapsed ? 30 : body.implicitHeight + 16) : 1

    property bool   widgetVisible: true
    property bool   collapsed:     false
    property int    sessionSecs:  0
    property int    deaths:       0
    property string zone:         "—"
    property string _homeDir:     ""
    property string _clientLog:   ""
    property int    offsetX:      10
    property int    offsetY:      890

    // ── Session timer ─────────────────────────────────────────────
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.sessionSecs++
    }

    // ── Zone poll (every 12 s) ────────────────────────────────────
    Timer {
        interval: 12000; running: root._clientLog !== ""; repeat: true
        onTriggered: zoneProc.running || (zoneProc.running = true)
    }

    function _fmtTime(s) {
        var h = Math.floor(s / 3600)
        var m = Math.floor((s % 3600) / 60)
        var sc = s % 60
        return (h > 0 ? h + ":" : "") +
               (m < 10 ? "0" + m : m) + ":" +
               (sc < 10 ? "0" + sc : sc)
    }

    function _savePos() {
        if (_homeDir === "" || savePosProc.running) return
        savePosProc.command = ["sh", "-c",
            "printf '%d,%d' " + Math.round(offsetX) + " " + Math.round(offsetY) +
            " > \"" + _homeDir + "/.config/quickshell/poe2/.saved-pos-session\""]
        savePosProc.running = true
    }

    function _resetSession() {
        sessionSecs = 0; deaths = 0
        saveSessProc.command = ["sh", "-c",
            "printf '0' > \"" + _homeDir + "/.config/quickshell/poe2/.saved-deaths\""]
        saveSessProc.running = true
    }

    function _saveDeaths() {
        if (_homeDir === "" || saveSessProc.running) return
        saveSessProc.command = ["sh", "-c",
            "printf '%s' " + deaths +
            " > \"" + _homeDir + "/.config/quickshell/poe2/.saved-deaths\""]
        saveSessProc.running = true
    }

    Component.onCompleted: {
        root.widgetVisible = State.isSessionVisible()
        State.addSessionVisibleListener(function(v) {
            root.widgetVisible = v
            if (root._homeDir !== "" && !saveVisProc.running) {
                saveVisProc.command = ["sh", "-c",
                    "printf '%s' " + (v ? "1" : "0") +
                    " > \"" + root._homeDir + "/.config/quickshell/poe2/.saved-widget-session\""]
                saveVisProc.running = true
            }
        })
    }

    // ── Resolve $HOME → find client.txt → load saved deaths ──────
    Process {
        id: homeProc
        command: ["sh", "-c", "printf '%s' \"$HOME\""]
        stdout: StdioCollector { id: homeOut }
        Component.onCompleted: running = true
        onRunningChanged: {
            if (!running) {
                root._homeDir = homeOut.text.trim()
                findLogProc.command = ["sh", "-c",
                    "find \"" + root._homeDir + "/.local/share/Steam\" " +
                    "\"" + root._homeDir + "/.steam/steam\" " +
                    "-name 'Client.txt' -path '*/Path of Exile 2/*' 2>/dev/null | head -1"]
                findLogProc.running = true
                deathLoadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-deaths\" 2>/dev/null"]
                deathLoadProc.running = true
                posLoadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-pos-session\" 2>/dev/null"]
                posLoadProc.running = true
                visLoadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-widget-session\" 2>/dev/null"]
                visLoadProc.running = true
            }
        }
    }

    Process {
        id: findLogProc
        stdout: StdioCollector { id: findLogOut }
        onRunningChanged: {
            if (!running) {
                var p = findLogOut.text.trim()
                if (p !== "") {
                    root._clientLog = p
                    zoneProc.running = true   // first read immediately
                }
            }
        }
    }

    Process {
        id: deathLoadProc
        stdout: StdioCollector { id: deathLoadOut }
        onRunningChanged: {
            if (!running) {
                var n = parseInt(deathLoadOut.text.trim(), 10)
                if (!isNaN(n) && n >= 0) root.deaths = n
            }
        }
    }

    // ── Read current zone from client.txt ─────────────────────────
    // ── Poll client.txt: zone + deaths ───────────────────────────
    // Output format: two lines — zone name, then death count (may be empty)
    Process {
        id: zoneProc
        command: ["sh", "-c",
            "LOG=\"" + root._clientLog + "\"; " +
            "ZONE=$(tail -300 \"$LOG\" 2>/dev/null | grep -o '\\[SCENE\\] Set Source \\[[^]]*\\]' | tail -1 | sed 's/\\[SCENE\\] Set Source \\[//;s/\\]$//'); " +
            "DEATHS=$(tail -500 \"$LOG\" 2>/dev/null | grep -o ': You have died [0-9]* times\\.' | tail -1 | grep -o '[0-9]*'); " +
            "printf '%s\\n%s' \"$ZONE\" \"$DEATHS\""]
        stdout: StdioCollector { id: zoneOut }
        onRunningChanged: {
            if (!running) {
                var lines = zoneOut.text.split("\n")
                var z = lines[0] ? lines[0].trim() : ""
                var d = lines[1] ? lines[1].trim() : ""
                if (z !== "") root.zone = z
                if (d !== "") {
                    var n = parseInt(d, 10)
                    if (!isNaN(n) && n >= 0) {
                        root.deaths = n
                        root._saveDeaths()
                    }
                }
            }
        }
    }

    Process { id: saveSessProc }
    Process { id: savePosProc }
    Process { id: saveVisProc }
    Process {
        id: visLoadProc
        stdout: StdioCollector { id: visLoadOut }
        onRunningChanged: {
            if (!running) {
                var v = visLoadOut.text.trim()
                if (v === "0") State.setSessionVisible(false)
            }
        }
    }
    Process {
        id: posLoadProc
        stdout: StdioCollector { id: posLoadOut }
        onRunningChanged: {
            if (!running) {
                var txt = posLoadOut.text.trim()
                if (txt && txt.indexOf(",") !== -1) {
                    var parts = txt.split(",")
                    var x = parseInt(parts[0], 10); var y = parseInt(parts[1], 10)
                    if (!isNaN(x) && x >= 0) root.offsetX = x
                    if (!isNaN(y) && y >= 0) root.offsetY = y
                }
            }
        }
    }

    // ── UI ────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#1c1c1e"
        border.color: "#3a5060"
        border.width: 1
        radius: 6
        opacity: 0.93

        ColumnLayout {
            id: body
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
            spacing: 5

            // ── Header ───────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "⠿ ⏱ Session"
                    color: "#7ab4d4"; font.pixelSize: 11; font.bold: true
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
                    text: "↺"
                    color: "#4a6a7a"; font.pixelSize: 11
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root._resetSession()
                    }
                }
                Text {
                    text: root.collapsed ? "v" : "^"
                    color: "#4a6a7a"; font.pixelSize: 10; leftPadding: 6
                    MouseArea { anchors.fill: parent; onClicked: root.collapsed = !root.collapsed }
                }
                Text {
                    text: "✕"; color: "#5a3a3a"; font.pixelSize: 10; leftPadding: 6
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: State.setSessionVisible(false) }
                }
            }

            ColumnLayout {
                visible: !root.collapsed
                Layout.fillWidth: true
                spacing: 6

                // ── Timer ────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: root._fmtTime(root.sessionSecs)
                        color: "#dde8f0"; font.pixelSize: 18; font.bold: true
                        font.family: "monospace"
                        Layout.fillWidth: true
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#1e2d3e" }

                // ── Deaths ───────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true; spacing: 6
                    Text { text: "💀"; font.pixelSize: 12 }
                    Text {
                        text: "Deaths"
                        color: "#8a9aaa"; font.pixelSize: 11
                        Layout.fillWidth: true
                    }
                    Text {
                        text: root.deaths
                        color: root.deaths > 0 ? "#e06060" : "#4a6a8a"
                        font.pixelSize: 13; font.bold: true
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#1e2d3e" }

                // ── Zone ─────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true; spacing: 5
                    Text { text: "📍"; font.pixelSize: 11 }
                    Text {
                        text: root.zone
                        color: "#8ab4a0"; font.pixelSize: 10
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                    }
                }
            }
        }
    }
}

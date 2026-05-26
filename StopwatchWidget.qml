import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "js/State.js" as State

// Small draggable stopwatch — manual timer with start/stop/reset.
// Independent from SessionTracker (which auto-tracks the whole session).

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.margins.left: offsetX
    WlrLayershell.margins.top:  offsetY

    anchors.top:  true
    anchors.left: true

    color: "transparent"
    implicitWidth:  widgetVisible ? 160 : 1
    implicitHeight: widgetVisible ? 70 : 1

    property bool   widgetVisible: true
    property int    elapsedMs:     0
    property bool   running:       false
    property int    offsetX:       250
    property int    offsetY:       890
    property string _homeDir:      ""

    Timer {
        id: tick
        interval: 100
        running: root.running
        repeat: true
        property double _lastTickMs: 0
        onTriggered: {
            var now = Date.now()
            if (_lastTickMs > 0) root.elapsedMs += (now - _lastTickMs)
            _lastTickMs = now
        }
        onRunningChanged: { if (!running) _lastTickMs = 0; else _lastTickMs = Date.now() }
    }

    function _fmt(ms) {
        var total = Math.floor(ms / 1000)
        var h = Math.floor(total / 3600)
        var m = Math.floor((total % 3600) / 60)
        var s = total % 60
        var cs = Math.floor((ms % 1000) / 100)
        var hh = h > 0 ? (h + ":") : ""
        var mm = (m < 10 ? "0" + m : m)
        var ss = (s < 10 ? "0" + s : s)
        return hh + mm + ":" + ss + "." + cs
    }

    function _savePos() {
        if (_homeDir === "" || savePosProc.running) return
        savePosProc.command = ["sh", "-c",
            "printf '%d,%d' " + Math.round(offsetX) + " " + Math.round(offsetY) +
            " > \"" + _homeDir + "/.config/quickshell/poe2/.saved-pos-stopwatch\""]
        savePosProc.running = true
    }

    Process {
        id: homeProc
        command: ["sh", "-c", "printf '%s' \"$HOME\""]
        stdout: StdioCollector { id: homeOut }
        Component.onCompleted: running = true
        onRunningChanged: {
            if (!running) {
                root._homeDir = homeOut.text.trim()
                posLoadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-pos-stopwatch\" 2>/dev/null"]
                posLoadProc.running = true
                visLoadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-widget-stopwatch\" 2>/dev/null"]
                visLoadProc.running = true
            }
        }
    }
    Process { id: savePosProc }
    Process { id: saveVisProc }

    Process {
        id: posLoadProc
        stdout: StdioCollector { id: posLoadOut }
        onRunningChanged: {
            if (!running) {
                var txt = posLoadOut.text.trim()
                if (txt && txt.indexOf(",") !== -1) {
                    var parts = txt.split(",")
                    var x = parseInt(parts[0], 10), y = parseInt(parts[1], 10)
                    if (!isNaN(x) && x >= 0) root.offsetX = x
                    if (!isNaN(y) && y >= 0) root.offsetY = y
                }
            }
        }
    }
    Process {
        id: visLoadProc
        stdout: StdioCollector { id: visLoadOut }
        onRunningChanged: {
            if (!running) {
                var v = visLoadOut.text.trim()
                if (v === "0") State.setStopwatchVisible(false)
            }
        }
    }

    Component.onCompleted: {
        root.widgetVisible = State.isStopwatchVisible()
        State.addStopwatchVisibleListener(function(v) {
            root.widgetVisible = v
            if (root._homeDir !== "" && !saveVisProc.running) {
                saveVisProc.command = ["sh", "-c",
                    "printf '%s' " + (v ? "1" : "0") +
                    " > \"" + root._homeDir + "/.config/quickshell/poe2/.saved-widget-stopwatch\""]
                saveVisProc.running = true
            }
        })
    }

    Rectangle {
        anchors.fill: parent
        color: "#1c1c1e"
        border.color: "#5a6a80"
        border.width: 1
        radius: 6
        opacity: 0.93

        ColumnLayout {
            anchors { fill: parent; margins: 6 }
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "⠿ ⏱ Timer"
                    color: "#7adde0"; font.pixelSize: 10; font.bold: true
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
                    text: "✕"; color: "#5a3a3a"; font.pixelSize: 10; leftPadding: 4
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: State.setStopwatchVisible(false) }
                }
            }

            Text {
                text: root._fmt(root.elapsedMs)
                color: root.running ? "#dde8f0" : "#7a8aaa"
                font.pixelSize: 18; font.bold: true
                font.family: "monospace"
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                Rectangle {
                    Layout.fillWidth: true; height: 18; radius: 3
                    color: root.running ? "#3a0f0f" : "#0f2a18"
                    border.color: root.running ? "#7a2020" : "#1e5030"
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: root.running ? "Stop" : "Start"
                        color: root.running ? "#d05050" : "#4fc3a0"
                        font.pixelSize: 9; font.bold: true
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.running = !root.running }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 18; radius: 3
                    color: "#1a1d24"; border.color: "#3a3a45"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Reset"; color: "#9aa8b8"; font.pixelSize: 9; font.bold: true }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { root.running = false; root.elapsedMs = 0 } }
                }
            }
        }
    }
}

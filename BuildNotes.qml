import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "js/State.js" as State

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.margins.bottom: 10
    WlrLayershell.margins.left: 10

    anchors.bottom: true
    anchors.left: true

    color: "transparent"
    implicitWidth:  collapsed ? 36 : 300
    implicitHeight: collapsed ? 36 : 420

    property bool   collapsed: true
    property string _homeDir:  ""
    property bool   _loaded:   false

    // ── Resolve $HOME → load notes from file ──────────────────────
    Process {
        id: notesHomeProc
        command: ["sh", "-c", "printf '%s' \"$HOME\""]
        stdout: StdioCollector { id: notesHomeOut }
        Component.onCompleted: running = true
        onRunningChanged: {
            if (!running) {
                root._homeDir = notesHomeOut.text.trim()
                notesLoadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-notes\" 2>/dev/null"]
                notesLoadProc.running = true
            }
        }
    }

    Process {
        id: notesLoadProc
        stdout: StdioCollector { id: notesLoadOut }
        onRunningChanged: {
            if (!running) {
                var txt = notesLoadOut.text
                if (txt && txt.length > 0) editor.text = txt
                root._loaded = true
            }
        }
    }

    Process { id: notesSaveProc }

    function _b64encode(str) {
        // Qt.btoa expects ASCII; encode UTF-8 first to handle accents/emojis safely
        return Qt.btoa(unescape(encodeURIComponent(str)))
    }

    Timer {
        id: saveDebounce
        interval: 600
        repeat: false
        onTriggered: {
            if (root._homeDir === "" || notesSaveProc.running) return
            var b64 = root._b64encode(editor.text)
            notesSaveProc.command = ["sh", "-c",
                "printf '%s' '" + b64 + "' | base64 -d > \"" +
                root._homeDir + "/.config/quickshell/poe2/.saved-notes\""]
            notesSaveProc.running = true
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#1c1c1e"
        border.color: "#8B7355"
        border.width: 1
        radius: 6
        opacity: 0.93
        clip: true

        // Toggle button
        Rectangle {
            id: toggleBtn
            width: 28
            height: 28
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 4
            color: "transparent"
            radius: 4

            Text {
                anchors.centerIn: parent
                text: root.collapsed ? "N" : "x"
                font.pixelSize: root.collapsed ? 14 : 12
                font.bold: true
                color: "#d4a843"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.collapsed = !root.collapsed
                hoverEnabled: true
                onEntered: toggleBtn.color = "#2a2a2d"
                onExited:  toggleBtn.color = "transparent"
            }
        }

        // Panel content
        ColumnLayout {
            visible: !root.collapsed
            anchors { fill: parent; margins: 8; topMargin: 8 }
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Notas de Build"
                    color: "#d4a843"
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                }

                Text {
                    text: State.getLeague()
                    color: "#5a5a5a"
                    font.pixelSize: 10
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#2a2a2d"
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                TextArea {
                    id: editor
                    width: parent.width
                    text: "# Notas de Build\n\n## Skills\n\n## Items necesarios\n\n## Pasivas clave"
                    color: "#c0b090"
                    selectionColor: "#8B7355"
                    selectedTextColor: "#ffffff"
                    font.pixelSize: 11
                    font.family: "monospace"
                    wrapMode: TextArea.WordWrap
                    background: Rectangle { color: "#111113"; radius: 3 }
                    padding: 6

                    onTextChanged: {
                        if (root._loaded) saveDebounce.restart()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: editor.text ? editor.text.length + " chars" : "0 chars"
                    color: "#3a3a3a"
                    font.pixelSize: 9
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "auto-guardado"
                    color: "#3a5a3a"
                    font.pixelSize: 9
                }
            }
        }
    }
}

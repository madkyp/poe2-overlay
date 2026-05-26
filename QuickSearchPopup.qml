import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "js/State.js" as State

// Popup with pre-canned search strings. Press Ctrl+Q to open; click any
// entry to copy it to the clipboard (and inject Ctrl+V into the focused
// game window via xdotool for one-shot pasting).

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.margins.top:  80
    WlrLayershell.margins.left: 740

    anchors.top:  true
    anchors.left: true

    color: "transparent"
    implicitWidth:  isOpen ? 440 : 1
    implicitHeight: isOpen ? 380 : 1

    property bool isOpen: false

    GlobalShortcut {
        appid: "poe2-foundry"
        name: "quicksearch"
        description: "Quick search strings menu"
        triggerDescription: "Ctrl+Q"
        onPressed: root.isOpen = !root.isOpen
    }

    // Categorised search strings. The actual game UI (stash search, trade
    // window filter) accepts regex-style queries. Each entry is { label, query }.
    readonly property var sections: ([
        { name: "Currency — high value", entries: [
            { label: "Divine Orb",            query: "Divine Orb" },
            { label: "Exalted Orb",           query: "Exalted Orb" },
            { label: "Mirror of Kalandra",    query: "Mirror" },
            { label: "Annulment",             query: "Annulment" },
            { label: "Chaos Orb",             query: "Chaos Orb" },
        ]},
        { name: "Currency — crafting", entries: [
            { label: "Essence",               query: "Essence of" },
            { label: "Catalysts",             query: "Catalyst" },
            { label: "Omen",                  query: "Omen of" },
            { label: "Vaal Orb",              query: "Vaal Orb" },
            { label: "Hinekora's Lock",       query: "Hinekora" },
            { label: "Fracturing Orb",        query: "Fracturing" },
        ]},
        { name: "Maps — quick filters", entries: [
            { label: "Waystones tier 15+",    query: "Waystone (Tier:|T1[5-9])" },
            { label: "Map regex: pack size",  query: "pack size" },
            { label: "Reflect mods (avoid)",  query: "Reflect" },
            { label: "No regen + less recov", query: "(cannot regenerate|less recovery)" },
        ]},
        { name: "Gems & jewels", entries: [
            { label: "Uncut skill gem",       query: "Uncut Skill" },
            { label: "Uncut support gem",     query: "Uncut Support" },
            { label: "Time-lost / Talisman",  query: "Talisman" },
            { label: "Soul Core",             query: "Soul Core" },
        ]},
    ])

    function _copyAndPaste(query) {
        // Copy to clipboard then close the popup. We don't auto-inject
        // because the user might not have a search box focused.
        copyProc.command = ["sh", "-c",
            "printf '%s' " + JSON.stringify(query) + " | wl-copy"]
        copyProc.running = true
        root.isOpen = false
    }

    Process { id: copyProc }

    Rectangle {
        visible: root.isOpen
        anchors.fill: parent
        color: "#1c1c1e"
        border.color: "#5a6a80"
        border.width: 1
        radius: 8

        ColumnLayout {
            anchors { fill: parent; margins: 10 }
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "🔎 Quick Search"
                    color: "#d4a843"; font.pixelSize: 13; font.bold: true
                    Layout.fillWidth: true
                }
                Text {
                    text: "Ctrl+V para pegar  ·  ✕"
                    color: "#7a7a7a"; font.pixelSize: 9
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.isOpen = false
                    }
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ColumnLayout {
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: root.sections
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.name
                                color: "#7adde0"
                                font.pixelSize: 10; font.bold: true
                            }
                            Rectangle { Layout.fillWidth: true; height: 1; color: "#2a2d35" }

                            Repeater {
                                model: modelData.entries
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 24
                                    radius: 3
                                    color: rowMouse.containsMouse ? "#2a3040" : "transparent"
                                    border.color: rowMouse.containsMouse ? "#3a4060" : "transparent"
                                    border.width: 1
                                    RowLayout {
                                        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                                        Text {
                                            text: modelData.label
                                            color: "#c0b090"; font.pixelSize: 11
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: modelData.query
                                            color: "#5a6a80"; font.pixelSize: 9
                                            font.family: "monospace"
                                            elide: Text.ElideRight
                                            Layout.preferredWidth: 200
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }
                                    MouseArea {
                                        id: rowMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root._copyAndPaste(modelData.query)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Text {
                text: "Click una entrada → copia al portapapeles → pega en el buscador del juego con Ctrl+V"
                color: "#5a5a5a"; font.pixelSize: 9
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}

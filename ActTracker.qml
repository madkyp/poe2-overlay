import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "js/State.js" as State
import "js/Markup.js" as Markup

// Campaign leveling guide overlay. Reads the current zone from
// Client.txt and shows the matching steps from a leveling DB derived
// from Lailloken/Exile-UI (MIT, fetched on first use via
// scripts/fetch-leveling.py).

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.margins.left: offsetX
    WlrLayershell.margins.top:  offsetY

    anchors.top:  true
    anchors.left: true

    color: "transparent"
    implicitWidth:  widgetVisible ? 320 : 1
    implicitHeight: widgetVisible ? (collapsed ? 32 : Math.min(440, body.implicitHeight + 16)) : 1

    property bool   widgetVisible: true
    property bool   collapsed:     false
    property int    offsetX:       10
    property int    offsetY:       180
    property string _homeDir:      ""
    property string _clientLog:    ""
    property string currentZone:   "—"
    property var    levelingData:  null
    property var    currentEntry:  null

    function _setZone(z) {
        currentZone = z
        if (!levelingData) return
        currentEntry = levelingData.zones[(z || "").trim().toLowerCase()] || null
    }

    function _renderStep(text) {
        return Markup.render(text, levelingData ? levelingData.zones : null)
    }

    // ── Resolve $HOME, locate Client.txt, load leveling data ─────
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
                loadDbProc.command = ["sh", "-c",
                    "F=\"" + root._homeDir + "/.config/quickshell/poe2/.cache/leveling.json\"; " +
                    "if [ ! -f \"$F\" ]; then " +
                    "  /usr/bin/python3 \"" + root._homeDir +
                    "/.config/quickshell/poe2/scripts/fetch-leveling.py\" >&2; " +
                    "fi; cat \"$F\""]
                loadDbProc.running = true
                posLoadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-pos-acttracker\" 2>/dev/null"]
                posLoadProc.running = true
                visLoadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-widget-acttracker\" 2>/dev/null"]
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
                    zonePollTimer.start()
                    zoneReadProc.running = true   // first read immediately
                }
            }
        }
    }

    Process {
        id: loadDbProc
        stdout: StdioCollector { id: loadDbOut }
        onRunningChanged: {
            if (!running) {
                try {
                    root.levelingData = JSON.parse(loadDbOut.text)
                    root._setZone(root.currentZone)
                } catch (e) {
                    console.log("[ActTracker] db parse error:", e.message)
                }
            }
        }
    }

    // ── Poll Client.txt for the latest "Set Source [Zone]" event ──
    Timer {
        id: zonePollTimer
        interval: 10000; repeat: true
        onTriggered: { if (!zoneReadProc.running) zoneReadProc.running = true }
    }

    Process {
        id: zoneReadProc
        command: ["sh", "-c",
            "tail -400 \"" + root._clientLog + "\" 2>/dev/null | " +
            "grep -o '\\[SCENE\\] Set Source \\[[^]]*\\]' | tail -1 | " +
            "sed 's/\\[SCENE\\] Set Source \\[//;s/\\]$//'"]
        stdout: StdioCollector { id: zoneReadOut }
        onRunningChanged: {
            if (!running) {
                var z = zoneReadOut.text.trim()
                if (z !== "" && z !== root.currentZone) root._setZone(z)
            }
        }
    }

    function _savePos() {
        if (_homeDir === "" || savePosProc.running) return
        savePosProc.command = ["sh", "-c",
            "printf '%d,%d' " + Math.round(offsetX) + " " + Math.round(offsetY) +
            " > \"" + _homeDir + "/.config/quickshell/poe2/.saved-pos-acttracker\""]
        savePosProc.running = true
    }
    Process { id: savePosProc }
    Process { id: saveVisProc }

    Process {
        id: posLoadProc
        stdout: StdioCollector { id: posLoadOut }
        onRunningChanged: {
            if (!running) {
                var t = posLoadOut.text.trim()
                if (t && t.indexOf(",") !== -1) {
                    var p = t.split(",")
                    var x = parseInt(p[0], 10), y = parseInt(p[1], 10)
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
                if (visLoadOut.text.trim() === "0") State.setActTrackerVisible(false)
            }
        }
    }

    Component.onCompleted: {
        root.widgetVisible = State.isActTrackerVisible()
        State.addActTrackerVisibleListener(function(v) {
            root.widgetVisible = v
            if (root._homeDir !== "" && !saveVisProc.running) {
                saveVisProc.command = ["sh", "-c",
                    "printf '%s' " + (v ? "1" : "0") +
                    " > \"" + root._homeDir + "/.config/quickshell/poe2/.saved-widget-acttracker\""]
                saveVisProc.running = true
            }
        })
    }

    // ── UI ────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#1c1c1e"
        border.color: "#5a4a2a"; border.width: 1; radius: 6
        opacity: 0.94

        ColumnLayout {
            id: body
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
            spacing: 5

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "⠿ 📜 " + (root.currentEntry ? root.currentEntry.act : "Campaign Guide")
                    color: "#d4a843"; font.pixelSize: 11; font.bold: true
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
                    text: root.collapsed ? "v" : "^"
                    color: "#7a6a50"; font.pixelSize: 10; leftPadding: 6
                    MouseArea { anchors.fill: parent; onClicked: root.collapsed = !root.collapsed }
                }
                Text {
                    text: "✕"; color: "#5a3a3a"; font.pixelSize: 10; leftPadding: 6
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: State.setActTrackerVisible(false) }
                }
            }

            ColumnLayout {
                visible: !root.collapsed
                Layout.fillWidth: true
                spacing: 4

                // Zone + level recommendation
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "📍 " + (root.currentEntry ? root.currentEntry.name :
                                                          (root.currentZone || "—"))
                        color: "#8ab4d4"; font.pixelSize: 11; font.bold: true
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    Text {
                        visible: !!root.currentEntry && !!root.currentEntry.recommendation
                        text: "lvl " + (root.currentEntry ? root.currentEntry.recommendation : "")
                        color: "#7a8aaa"; font.pixelSize: 9
                    }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: "#2a2a2d" }

                // No data
                Text {
                    visible: !root.currentEntry || !(root.currentEntry.steps || []).length
                    text: !root.levelingData ? "Cargando guía…"
                          : !root.currentEntry ? "No hay guía para esta zona."
                                              : "Sin pasos registrados aquí."
                    color: "#7a6a50"; font.pixelSize: 10
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                // Steps for the current zone
                ScrollView {
                    visible: !!root.currentEntry && (root.currentEntry.steps || []).length > 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(350, stepsCol.implicitHeight + 6)
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    ColumnLayout {
                        id: stepsCol
                        width: parent.width
                        spacing: 6
                        Repeater {
                            model: root.currentEntry ? (root.currentEntry.steps || []) : []
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text {
                                    text: (index + 1) + "."
                                    color: "#d4a843"; font.pixelSize: 10; font.bold: true
                                    Layout.alignment: Qt.AlignTop
                                }
                                Text {
                                    text: root._renderStep(modelData.text)
                                    textFormat: Text.RichText
                                    color: "#c0b090"; font.pixelSize: 10
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "js/State.js" as State

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.margins.bottom: 10
    WlrLayershell.margins.right: 10

    anchors.bottom: true
    anchors.right: true

    color: "transparent"
    implicitWidth:  210
    implicitHeight: collapsed ? 30 : content.implicitHeight + 16

    property bool   collapsed:  false
    property string lastUpdate: "--:--"

    readonly property var tracked: ["Divine Orb", "Exalted Orb", "Orb of Annulment", "Vaal Orb"]

    readonly property var icons: ({
        "Divine Orb":       Qt.resolvedUrl("icons/divine.png"),
        "Exalted Orb":      Qt.resolvedUrl("icons/exalted.png"),
        "Orb of Annulment": Qt.resolvedUrl("icons/annul.png"),
        "Vaal Orb":         Qt.resolvedUrl("icons/vaal.png"),
        "chaos":            Qt.resolvedUrl("icons/chaos.png")
    })

    property var    rates:       ({})
    property string leagueName:  State.getLeague()

    Component.onCompleted: {
        var cached = State.getEntries()
        if (cached && cached.length > 0) root._updateFromEntries(cached)

        State.addRateListener(function(entries, err) {
            root._updateFromEntries(entries)
        })
        State.addLeagueListener(function(name) {
            root.leagueName = name
        })
    }

    function _updateFromEntries(entries) {
        if (!entries || entries.length === 0) return
        var map = {}
        for (var i = 0; i < entries.length; i++) {
            map[entries[i].name] = entries[i]
        }
        rates = map
        var now = new Date()
        var m = now.getMinutes()
        lastUpdate = now.getHours() + ":" + (m < 10 ? "0" + m : "" + m)
    }

    Rectangle {
        anchors.fill: parent
        color: "#1c1c1e"
        border.color: "#8B7355"
        border.width: 1
        radius: 6
        opacity: 0.93

        ColumnLayout {
            id: content
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
            spacing: 4

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: root.leagueName
                    color: "#d4a843"
                    font.pixelSize: 11
                    font.bold: true
                }

                Text {
                    text: "▶"
                    color: "#8B7355"
                    font.pixelSize: 9
                    rightPadding: 4
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: State.setEconomyOpen(true)
                    }
                }

                Text {
                    text: State.isFetching() ? "..." : "↺"
                    color: "#7a6a50"
                    font.pixelSize: 11
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { /* fetch is owned by EconomyWindow */ }
                    }
                }

                Text {
                    text: root.collapsed ? "v" : "^"
                    color: "#7a6a50"
                    font.pixelSize: 10
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.collapsed = !root.collapsed
                    }
                }
            }

            // Currency rows
            ColumnLayout {
                visible: !root.collapsed
                Layout.fillWidth: true
                spacing: 5

                Text {
                    visible: State.getError() !== ""
                    text: State.getError()
                    color: "#d20000"
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Repeater {
                    model: root.tracked

                    RowLayout {
                        spacing: 6
                        Layout.fillWidth: true

                        Image {
                            width: 18; height: 18
                            sourceSize.width: 18; sourceSize.height: 18
                            source: root.icons[modelData] || ""
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        Text {
                            text: modelData.replace("Orb of ", "").replace(" Orb", "")
                            color: "#c0b090"
                            font.pixelSize: 11
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: 3
                            Image {
                                width: 13; height: 13
                                sourceSize.width: 13; sourceSize.height: 13
                                source: root.icons["chaos"]
                                fillMode: Image.PreserveAspectFit
                                visible: !!root.rates[modelData]
                            }
                            Text {
                                text: {
                                    var r = root.rates[modelData]
                                    if (!r) return "..."
                                    var v = r.chaosValue
                                    return v >= 10 ? v.toFixed(0) : v.toFixed(1)
                                }
                                color: root.rates[modelData] ? "#d4a843" : "#5a5a5a"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#2a2a2d"
                }

                Text {
                    text: "act. " + root.lastUpdate + "  trade API"
                    color: "#3a3a3a"
                    font.pixelSize: 9
                }
            }
        }
    }
}

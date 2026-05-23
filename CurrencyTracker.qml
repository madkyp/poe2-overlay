import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "js/State.js" as State

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: alertTarget !== "" ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.margins.left: offsetX
    WlrLayershell.margins.top:  offsetY

    anchors.top:  true
    anchors.left: true

    color: "transparent"
    implicitWidth:  widgetVisible ? 210 : 1
    implicitHeight: widgetVisible ? (collapsed ? 30 : content.implicitHeight + 16) : 1

    property bool   widgetVisible: true
    property bool   collapsed:     false
    property string lastUpdate:   "--:--"
    property int    offsetX:      1700
    property int    offsetY:      890

    property string _homeDir:     ""
    property var    alerts:       ({})   // { "Divine Orb": { dir: "below", value: 150 } }
    property var    firing:       ({})   // { "Divine Orb": true }
    property string alertTarget:  ""
    property string alertEditDir: "below"
    property string alertEditVal: ""

    readonly property var tracked: ["Divine Orb", "Exalted Orb", "Orb of Annulment", "Vaal Orb"]

    readonly property var icons: ({
        "Divine Orb":       Qt.resolvedUrl("icons/divine.png"),
        "Exalted Orb":      Qt.resolvedUrl("icons/exalted.png"),
        "Orb of Annulment": Qt.resolvedUrl("icons/annul.png"),
        "Vaal Orb":         Qt.resolvedUrl("icons/vaal.png"),
        "chaos":            Qt.resolvedUrl("icons/chaos.png")
    })

    property var    rates:      ({})
    property string leagueName: State.getLeague()

    Component.onCompleted: {
        var cached = State.getEntries()
        if (cached && cached.length > 0) root._updateFromEntries(cached)
        State.addRateListener(function(entries, err) { root._updateFromEntries(entries) })
        State.addLeagueListener(function(name) { root.leagueName = name })
        root.widgetVisible = State.isCurrencyVisible()
        State.addCurrencyVisibleListener(function(v) {
            root.widgetVisible = v
            if (root._homeDir !== "" && !saveVisProc.running) {
                saveVisProc.command = ["sh", "-c",
                    "printf '%s' " + (v ? "1" : "0") +
                    " > \"" + root._homeDir + "/.config/quickshell/poe2/.saved-widget-currency\""]
                saveVisProc.running = true
            }
        })
    }

    function _updateFromEntries(entries) {
        if (!entries || entries.length === 0) return
        var map = {}
        for (var i = 0; i < entries.length; i++) map[entries[i].name] = entries[i]
        rates = map
        var now = new Date(); var m = now.getMinutes()
        lastUpdate = now.getHours() + ":" + (m < 10 ? "0" + m : "" + m)
        _checkAlerts()
    }

    function _checkAlerts() {
        var newFiring = {}
        for (var name in alerts) {
            var al = alerts[name]; var rate = rates[name]
            if (!rate || !al) continue
            var v = rate.chaosValue
            if (al.dir === "below" && v <= al.value) newFiring[name] = true
            if (al.dir === "above" && v >= al.value) newFiring[name] = true
        }
        firing = newFiring
    }

    function _savePos() {
        if (_homeDir === "" || savePosProc.running) return
        savePosProc.command = ["sh", "-c",
            "printf '%d,%d' " + Math.round(offsetX) + " " + Math.round(offsetY) +
            " > \"" + _homeDir + "/.config/quickshell/poe2/.saved-pos-currency\""]
        savePosProc.running = true
    }

    function _saveAlerts() {
        if (_homeDir === "" || alertSaveProc.running) return
        var json = JSON.stringify(alerts)
        alertSaveProc.command = ["sh", "-c",
            "printf '%s' '" + json + "' > \"" + _homeDir + "/.config/quickshell/poe2/.saved-alerts\""]
        alertSaveProc.running = true
    }

    // ── Resolve $HOME ─────────────────────────────────────────────
    Process {
        id: trackerHomeProc
        command: ["sh", "-c", "printf '%s' \"$HOME\""]
        stdout: StdioCollector { id: trackerHomeOut }
        Component.onCompleted: running = true
        onRunningChanged: {
            if (!running) {
                root._homeDir = trackerHomeOut.text.trim()
                alertLoadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-alerts\" 2>/dev/null"]
                alertLoadProc.running = true
                posLoadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-pos-currency\" 2>/dev/null"]
                posLoadProc.running = true
                visLoadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-widget-currency\" 2>/dev/null"]
                visLoadProc.running = true
            }
        }
    }

    Process {
        id: alertLoadProc
        stdout: StdioCollector { id: alertLoadOut }
        onRunningChanged: {
            if (!running) {
                var txt = alertLoadOut.text.trim()
                if (txt) { try { root.alerts = JSON.parse(txt) } catch(e) {} }
                root._checkAlerts()
            }
        }
    }

    Process { id: alertSaveProc }
    Process { id: savePosProc }
    Process { id: saveVisProc }
    Process {
        id: visLoadProc
        stdout: StdioCollector { id: visLoadOut }
        onRunningChanged: {
            if (!running) {
                var v = visLoadOut.text.trim()
                if (v === "0") State.setCurrencyVisible(false)
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
                    text: "⠿ " + root.leagueName
                    color: "#d4a843"; font.pixelSize: 11; font.bold: true
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
                    text: "▶"; color: "#8B7355"; font.pixelSize: 9; rightPadding: 4
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: State.setEconomyOpen(true) }
                }
                Text {
                    text: "📘"; color: "#8B7355"; font.pixelSize: 10; rightPadding: 4
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: State.setBuildsOpen(true) }
                }
                Text {
                    text: State.isFetching() ? "..." : "↺"; color: "#7a6a50"; font.pixelSize: 11
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                }
                Text {
                    text: root.collapsed ? "v" : "^"; color: "#7a6a50"; font.pixelSize: 10
                    MouseArea { anchors.fill: parent; onClicked: root.collapsed = !root.collapsed }
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
                    color: "#d20000"; font.pixelSize: 10
                    wrapMode: Text.WordWrap; Layout.fillWidth: true
                }

                Repeater {
                    model: root.tracked

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true

                        // Currency row
                        RowLayout {
                            spacing: 5; Layout.fillWidth: true

                            Image {
                                width: 18; height: 18
                                sourceSize.width: 18; sourceSize.height: 18
                                source: root.icons[modelData] || ""
                                fillMode: Image.PreserveAspectFit; smooth: true
                            }
                            Text {
                                text: modelData.replace("Orb of ", "").replace(" Orb", "")
                                color: "#c0b090"; font.pixelSize: 11; Layout.fillWidth: true
                            }

                            // Bell icon
                            Text {
                                text: root.alerts[modelData] ? "🔔" : "🔕"
                                font.pixelSize: 10
                                color: root.firing[modelData]  ? "#ff6060" :
                                       root.alerts[modelData]  ? "#d4a843" : "#2a2a2a"
                                opacity: root.alerts[modelData] || root.alertTarget === modelData ? 1.0 : 0.35
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.alertTarget === modelData) {
                                            root.alertTarget = ""
                                        } else {
                                            var ex = root.alerts[modelData]
                                            root.alertEditDir = ex ? ex.dir   : "below"
                                            root.alertEditVal = ex ? String(ex.value) : ""
                                            root.alertTarget  = modelData
                                        }
                                    }
                                }
                            }

                            // Value
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
                                    color: root.firing[modelData] ? "#ff6060" :
                                           root.rates[modelData]  ? "#d4a843" : "#5a5a5a"
                                    font.pixelSize: 12; font.bold: true
                                }
                            }
                        }

                        // Alert badge (when firing)
                        Rectangle {
                            visible: !!root.firing[modelData]
                            Layout.fillWidth: true
                            height: 16; radius: 3
                            color: "#3a0f0f"
                            border.color: "#7a2020"; border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    var al = root.alerts[modelData]
                                    if (!al) return ""
                                    return "⚠ " + (al.dir === "below" ? "▼" : "▲") + " " + al.value + " c"
                                }
                                color: "#ff8080"; font.pixelSize: 9; font.bold: true
                            }
                        }

                        // Alert config panel (inline)
                        Rectangle {
                            id: alertPanel
                            visible: root.alertTarget === modelData
                            Layout.fillWidth: true
                            height: 26; radius: 3
                            color: "#0d1520"
                            border.color: "#2d4060"; border.width: 1

                            onVisibleChanged: {
                                if (visible) configInput.text = root.alertEditVal
                            }

                            RowLayout {
                                anchors { fill: parent; margins: 3 }
                                spacing: 3

                                // Direction toggle
                                Rectangle {
                                    width: 58; height: 20; radius: 3
                                    color: "#1a2535"; border.color: "#2d4060"; border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: root.alertEditDir === "below" ? "▼ below" : "▲ above"
                                        color: "#8ab4d4"; font.pixelSize: 9
                                    }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: root.alertEditDir = root.alertEditDir === "below" ? "above" : "below"
                                    }
                                }

                                // Chaos value input
                                Rectangle {
                                    Layout.fillWidth: true; height: 20; radius: 3
                                    color: "#060e18"; border.color: "#2d4060"; border.width: 1
                                    TextInput {
                                        id: configInput
                                        anchors { fill: parent; leftMargin: 4; rightMargin: 14 }
                                        color: "#dde8f0"; font.pixelSize: 10
                                        verticalAlignment: TextInput.AlignVCenter
                                        validator: IntValidator { bottom: 0; top: 99999 }
                                        onTextChanged: root.alertEditVal = text
                                    }
                                    Text {
                                        anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
                                        text: "c"; color: "#4a6a8a"; font.pixelSize: 9
                                    }
                                }

                                // Set
                                Rectangle {
                                    width: 28; height: 20; radius: 3
                                    color: "#0f2a18"; border.color: "#1e5030"; border.width: 1
                                    Text { anchors.centerIn: parent; text: "Set"; color: "#4fc3a0"; font.pixelSize: 9 }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var val = parseInt(root.alertEditVal, 10)
                                            if (!isNaN(val) && val > 0) {
                                                var na = {}
                                                for (var k in root.alerts) na[k] = root.alerts[k]
                                                na[root.alertTarget] = { dir: root.alertEditDir, value: val }
                                                root.alerts = na
                                                root._checkAlerts()
                                                root._saveAlerts()
                                            }
                                            root.alertTarget = ""
                                        }
                                    }
                                }

                                // Clear (only if alert exists)
                                Rectangle {
                                    visible: !!root.alerts[root.alertTarget]
                                    width: 20; height: 20; radius: 3
                                    color: "#2a0f0f"; border.color: "#501818"; border.width: 1
                                    Text { anchors.centerIn: parent; text: "✕"; color: "#d05050"; font.pixelSize: 9 }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var na = {}
                                            for (var k in root.alerts) if (k !== root.alertTarget) na[k] = root.alerts[k]
                                            root.alerts = na
                                            root._checkAlerts()
                                            root._saveAlerts()
                                            root.alertTarget = ""
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#2a2a2d" }

                Text {
                    text: "act. " + root.lastUpdate + "  trade API"
                    color: "#3a3a3a"; font.pixelSize: 9
                }
            }
        }
    }
}

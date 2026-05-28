import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "js/State.js" as State
import "js/Markup.js" as Markup

// Per-act checklist of reward-bearing campaign objectives (skill gems,
// spirit, support gems, quests) extracted from the same Lailloken/Exile-UI
// leveling data the Act Tracker uses. Check items off as you complete
// them; the state persists across sessions. Off by default — enable from
// Options → Widgets.

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.margins.left: offsetX
    WlrLayershell.margins.top:  offsetY

    anchors.top:  true
    anchors.left: true

    color: "transparent"
    implicitWidth:  widgetVisible ? 340 : 1
    implicitHeight: widgetVisible ? (collapsed ? 32 : Math.min(560, body.implicitHeight + 16)) : 1

    property bool   widgetVisible: false
    property bool   collapsed:     false
    property int    offsetX:       360
    property int    offsetY:       180
    property string _homeDir:      ""
    property var    levelingData:  null
    property var    actModel:      []
    property var    checked:       ({})
    property string expandedAct:   "Act 1"
    property bool   autoMode:      false
    // zone (lowercase) → array of mandatory item ids, for auto-ticking
    property var    _zoneMandatory: ({})

    readonly property var _actOrder: [
        "Act 1", "Act 2", "Act 3",
        "Cruel Act 1", "Cruel Act 2", "Cruel Act 3", "Endgame"
    ]
    readonly property var _kindColor: ({
        "skill":   "#7adde0",
        "spirit":  "#c080e0",
        "support": "#7adda0",
        "quest":   "#d4a843"
    })

    // ── Build per-act list of reward-bearing objectives ────────────
    function _rebuild() {
        if (!levelingData || !levelingData.zones) { actModel = []; return }
        var byAct = {}
        var mandMap = {}
        var zones = levelingData.zones
        for (var key in zones) {
            var z = zones[key]
            var act = z.act || "?"
            var steps = z.steps || []
            for (var i = 0; i < steps.length; i++) {
                var txt = steps[i].text
                var kind = Markup.rewardKind(txt)
                if (!kind) continue
                var id = act + "|" + z.name + "|" + i
                // "optional:" / "leaguestart:" / "twinkrun:" steps are skippable
                var optional = /\b(optional|leaguestart|twinkrun)\s*:/i.test(txt)
                if (!byAct[act]) byAct[act] = []
                byAct[act].push({
                    "id":       id,
                    "kind":     kind,
                    "zone":     z.name,
                    "optional": optional,
                    "html":     Markup.render(txt, zones)
                })
                if (!optional) {
                    var zk = z.name.toLowerCase()
                    if (!mandMap[zk]) mandMap[zk] = []
                    mandMap[zk].push(id)
                }
            }
        }
        _zoneMandatory = mandMap
        var ordered = []
        for (var a = 0; a < _actOrder.length; a++) {
            var name = _actOrder[a]
            if (byAct[name] && byAct[name].length)
                ordered.push({ "act": name, "items": byAct[name] })
        }
        // Any acts not in the canonical order, appended as-is
        for (var extra in byAct) {
            if (_actOrder.indexOf(extra) === -1)
                ordered.push({ "act": extra, "items": byAct[extra] })
        }
        actModel = ordered
    }

    function _doneCount(items) {
        var n = 0
        for (var i = 0; i < items.length; i++)
            if (checked[items[i].id]) n++
        return n
    }

    function _toggle(id) {
        var c = {}
        for (var k in checked) c[k] = checked[k]
        if (c[id]) delete c[id]; else c[id] = true
        checked = c          // fresh ref → bindings on root.checked refresh
        _saveChecked()
    }

    // Look up the act a zone belongs to (for auto-expand).
    function _zoneAct(zoneLower) {
        if (levelingData && levelingData.zones && levelingData.zones[zoneLower])
            return levelingData.zones[zoneLower].act || ""
        return ""
    }

    // Client.txt can't tell us when a reward was claimed, only when the
    // zone changes. So when the player leaves a zone we tick that zone's
    // *mandatory* objectives (quests you must do to progress); optionals
    // are left for the player to confirm by hand.
    function _onZoneChange(zone, prevZone) {
        var act = _zoneAct((zone || "").trim().toLowerCase())
        if (act) expandedAct = act
        if (!autoMode || !prevZone) return
        var ids = _zoneMandatory[prevZone.trim().toLowerCase()]
        if (!ids || !ids.length) return
        var c = {}, changed = false
        for (var k in checked) c[k] = checked[k]
        for (var i = 0; i < ids.length; i++) {
            if (!c[ids[i]]) { c[ids[i]] = true; changed = true }
        }
        if (changed) { checked = c; _saveChecked() }
    }

    // ── Persistence: $HOME, leveling DB, position, visibility, checks
    Process {
        id: homeProc
        command: ["sh", "-c", "printf '%s' \"$HOME\""]
        stdout: StdioCollector { id: homeOut }
        Component.onCompleted: running = true
        onRunningChanged: {
            if (!running) {
                root._homeDir = homeOut.text.trim()
                var base = root._homeDir + "/.config/quickshell/poe2"
                loadDbProc.command = ["sh", "-c",
                    "F=\"" + base + "/.cache/leveling.json\"; " +
                    "if [ ! -f \"$F\" ]; then " +
                    "  /usr/bin/python3 \"" + base + "/scripts/fetch-leveling.py\" >&2; " +
                    "fi; cat \"$F\""]
                loadDbProc.running = true
                posLoadProc.command = ["sh", "-c",
                    "cat \"" + base + "/.saved-pos-rewards\" 2>/dev/null"]
                posLoadProc.running = true
                visLoadProc.command = ["sh", "-c",
                    "cat \"" + base + "/.saved-widget-rewards\" 2>/dev/null"]
                visLoadProc.running = true
                checkedLoadProc.command = ["sh", "-c",
                    "cat \"" + base + "/.saved-rewards-checked\" 2>/dev/null"]
                checkedLoadProc.running = true
                autoLoadProc.command = ["sh", "-c",
                    "cat \"" + base + "/.saved-rewards-auto\" 2>/dev/null"]
                autoLoadProc.running = true
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
                    root._rebuild()
                } catch (e) {
                    console.log("[RewardChecklist] db parse error:", e.message)
                }
            }
        }
    }

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
            if (!running && visLoadOut.text.trim() === "1")
                State.setRewardChecklistVisible(true)
        }
    }
    Process {
        id: checkedLoadProc
        stdout: StdioCollector { id: checkedLoadOut }
        onRunningChanged: {
            if (!running) {
                var c = {}
                var lines = checkedLoadOut.text.split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var k = lines[i].trim()
                    if (k) c[k] = true
                }
                root.checked = c
            }
        }
    }
    Process {
        id: autoLoadProc
        stdout: StdioCollector { id: autoLoadOut }
        onRunningChanged: {
            if (!running && autoLoadOut.text.trim() === "1")
                root.autoMode = true
        }
    }

    Process { id: savePosProc }
    Process { id: saveVisProc }
    Process { id: saveCheckedProc }
    Process { id: saveAutoProc }

    function _saveAuto() {
        if (_homeDir === "" || saveAutoProc.running) return
        saveAutoProc.command = ["sh", "-c",
            "printf '%s' " + (autoMode ? "1" : "0") +
            " > \"" + _homeDir + "/.config/quickshell/poe2/.saved-rewards-auto\""]
        saveAutoProc.running = true
    }

    function _savePos() {
        if (_homeDir === "" || savePosProc.running) return
        savePosProc.command = ["sh", "-c",
            "printf '%d,%d' " + Math.round(offsetX) + " " + Math.round(offsetY) +
            " > \"" + _homeDir + "/.config/quickshell/poe2/.saved-pos-rewards\""]
        savePosProc.running = true
    }
    function _saveChecked() {
        if (_homeDir === "" || saveCheckedProc.running) return
        var keys = []
        for (var k in checked) if (checked[k]) keys.push(k)
        var dst = _homeDir + "/.config/quickshell/poe2/.saved-rewards-checked"
        var tmp = "/tmp/poe2-rewards-checked.b64"
        // base64 the payload so zone names with spaces/apostrophes can't
        // break shell quoting (mirrors BuildsWindow._saveBuilds).
        var b64 = Qt.btoa(keys.join("\n"))
        saveCheckedProc.command = ["sh", "-c",
            "printf '%s' '" + b64 + "' > \"" + tmp + "\" && " +
            "base64 -d < \"" + tmp + "\" > \"" + dst + "\" && rm -f \"" + tmp + "\""]
        saveCheckedProc.running = true
    }

    Component.onCompleted: {
        root.widgetVisible = State.isRewardChecklistVisible()
        State.addRewardChecklistVisibleListener(function(v) {
            root.widgetVisible = v
            if (root._homeDir !== "" && !saveVisProc.running) {
                saveVisProc.command = ["sh", "-c",
                    "printf '%s' " + (v ? "1" : "0") +
                    " > \"" + root._homeDir + "/.config/quickshell/poe2/.saved-widget-rewards\""]
                saveVisProc.running = true
            }
        })
        // Auto-tick mandatory objectives + auto-expand as the player advances
        State.addZoneListener(function(zone, prev) { root._onZoneChange(zone, prev) })
        if (State.getCurrentZone())
            root.expandedAct = root._zoneAct(State.getCurrentZone().trim().toLowerCase()) || root.expandedAct
    }

    // ── UI ─────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#1c1c1e"
        border.color: "#5a4a2a"; border.width: 1; radius: 6
        opacity: 0.95

        ColumnLayout {
            id: body
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
            spacing: 5

            // Title bar (drag / collapse / close)
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "⠿ 🏆 Recompensas"
                    color: "#d4a843"; font.pixelSize: 11; font.bold: true
                    elide: Text.ElideRight
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
                // Auto-tick toggle
                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: autoLbl.implicitWidth + 12
                    implicitHeight: 16
                    radius: 8
                    color:        root.autoMode ? "#1e3a28" : "#26201a"
                    border.color: root.autoMode ? "#7adda0" : "#4a4036"
                    border.width: 1
                    Text {
                        id: autoLbl
                        anchors.centerIn: parent
                        text: (root.autoMode ? "⟳ auto" : "auto off")
                        color: root.autoMode ? "#7adda0" : "#8a7a60"
                        font.pixelSize: 8; font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.autoMode = !root.autoMode; root._saveAuto() }
                    }
                }
                Text {
                    text: root.collapsed ? "v" : "^"
                    color: "#7a6a50"; font.pixelSize: 10; leftPadding: 6
                    MouseArea { anchors.fill: parent; onClicked: root.collapsed = !root.collapsed }
                }
                Text {
                    text: "✕"; color: "#5a3a3a"; font.pixelSize: 10; leftPadding: 6
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: State.setRewardChecklistVisible(false) }
                }
            }

            Text {
                visible: !root.collapsed && !root.levelingData
                text: "Cargando guía…"
                color: "#7a6a50"; font.pixelSize: 10
            }
            Text {
                visible: !root.collapsed && root.levelingData && root.actModel.length === 0
                text: "Sin objetivos registrados."
                color: "#7a6a50"; font.pixelSize: 10
            }

            ScrollView {
                visible: !root.collapsed && root.actModel.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(500, actsCol.implicitHeight + 4)
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ColumnLayout {
                    id: actsCol
                    width: parent.width
                    spacing: 3

                    Repeater {
                        model: root.actModel
                        delegate: ColumnLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 2

                            // Act header — click to expand/collapse
                            Rectangle {
                                Layout.fillWidth: true
                                height: 24; radius: 4
                                color: hdrMouse.containsMouse ? "#2a2620" : "#232018"
                                RowLayout {
                                    anchors { fill: parent; leftMargin: 6; rightMargin: 6 }
                                    Text {
                                        text: (root.expandedAct === modelData.act ? "▾ " : "▸ ") + modelData.act
                                        color: "#d4a843"; font.pixelSize: 10; font.bold: true
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: root._doneCount(modelData.items) + "/" + modelData.items.length
                                        color: root._doneCount(modelData.items) === modelData.items.length
                                               ? "#7adda0" : "#7a8aaa"
                                        font.pixelSize: 9; font.bold: true
                                    }
                                }
                                MouseArea {
                                    id: hdrMouse
                                    anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.expandedAct =
                                        (root.expandedAct === modelData.act ? "" : modelData.act)
                                }
                            }

                            // Items for this act
                            Repeater {
                                model: root.expandedAct === modelData.act ? modelData.items : []
                                delegate: RowLayout {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 6
                                    spacing: 6

                                    Rectangle {
                                        width: 14; height: 14; radius: 3
                                        Layout.alignment: Qt.AlignTop
                                        Layout.topMargin: 2
                                        color: root.checked[modelData.id] ? "#2e5a3a" : "#1a1a1d"
                                        border.color: root.checked[modelData.id] ? "#7adda0" : "#4a4a50"
                                        border.width: 1
                                        Text {
                                            anchors.centerIn: parent
                                            text: root.checked[modelData.id] ? "✓" : ""
                                            color: "#7adda0"; font.pixelSize: 10; font.bold: true
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root._toggle(modelData.id)
                                        }
                                    }
                                    Text {
                                        text: modelData.html
                                        textFormat: Text.RichText
                                        color: root.checked[modelData.id] ? "#5a6a5a" : "#c0b090"
                                        font.pixelSize: 10
                                        font.strikeout: !!root.checked[modelData.id]
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
}

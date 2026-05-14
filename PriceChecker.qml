import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "js/ItemParser.js" as ItemParser
import "js/TradeApi.js" as TradeApi
import "js/StatIds.js" as StatIds
import "js/State.js" as State
import "js/MapMods.js" as MapMods

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.margins.top: 10
    WlrLayershell.margins.right: 10

    anchors.top: true
    anchors.right: true

    color: "transparent"
    implicitWidth:  showing ? 330 : 1
    implicitHeight: showing ? panel.implicitHeight + 20 : 1

    property bool   showing:       false
    property var    currentItem:   null
    property var    priceResult:   null
    property bool   loading:       false
    property string errorMsg:      ""
    property bool   statsReady:    false
    property string lastClipboard: ""
    property var    mapWarning:    null  // { summary, alerts: [...] }

    // ── Stash Pricer: watch clipboard every 1.5s ─────────────────
    Timer {
        id: clipWatcher
        interval: 1500; running: true; repeat: true
        onTriggered: { if (!clipReadProc.running) clipReadProc.running = true }
    }

    Process {
        id: clipReadProc
        command: ["bash", "-c", "wl-paste --no-newline 2>/dev/null || xclip -selection clipboard -o 2>/dev/null"]
        stdout: StdioCollector { id: clipReadOut }
        onRunningChanged: {
            if (!running) {
                var text = clipReadOut.text
                if (text === root.lastClipboard) return
                root.lastClipboard = text
                var trimmed = text.trim()
                if (!trimmed || !ItemParser.isPoeItem(trimmed)) return
                var item = ItemParser.parse(trimmed)
                if (!item) return
                root.currentItem = item
                root.startSearch(item)
            }
        }
    }

    Component.onCompleted: {
        StatIds.fetchStats(function(err, _) {
            root.statsReady = (err === null || err === undefined || err === "")
        })
    }

    // ── Ctrl+D global shortcut ────────────────────────────────────
    // Hyprland config needs: bind = CTRL, D, global, poe2-foundry:pricecheck
    // Requires: xdotool (sudo pacman -S xdotool)
    GlobalShortcut {
        appid: "poe2-foundry"
        name: "pricecheck"
        description: "PoE2 item price check"
        triggerDescription: "Ctrl+D"

        onPressed: {
            if (!pasteProc.running) pasteProc.running = true
        }
    }

    // ── Inject Ctrl+C into the focused window (PoE2/XWayland), wait for
    //   clipboard sync, then read. xdotool sends to the active X11 window.
    Process {
        id: pasteProc
        command: ["bash", "-c",
            "xdotool key --clearmodifiers ctrl+c; sleep 0.3; " +
            "xclip -selection clipboard -o 2>/dev/null || wl-paste --no-newline 2>/dev/null"]
        stdout: StdioCollector { id: pasteOut }

        onRunningChanged: {
            if (!running) {
                Qt.callLater(function() {
                    var text = pasteOut.text.trim()

                    if (!text || !ItemParser.isPoeItem(text)) {
                        root.currentItem = null
                        root.priceResult = null
                        root.loading = false
                        root.errorMsg = "No PoE2 item in clipboard"
                        root.showing = true
                        hideTimer.restart()
                        return
                    }

                    var item = ItemParser.parse(text)
                    if (!item) {
                        root.currentItem = null
                        root.priceResult = null
                        root.loading = false
                        root.errorMsg = "Could not parse item"
                        root.showing = true
                        hideTimer.restart()
                        return
                    }

                    root.currentItem = item
                    root.startSearch(item)
                })
            }
        }
    }

    // ── Auto-hide after 15s ───────────────────────────────────────
    Timer {
        id: hideTimer
        interval: 15000
        onTriggered: root.showing = false
    }

    // ── Price lookup ──────────────────────────────────────────────
    function startSearch(item) {
        root.loading = true
        root.priceResult = null
        root.errorMsg = ""
        root.mapWarning = null
        root.showing = true
        hideTimer.restart()

        var league = State.getLeague()

        // Waystone: skip trade lookup, run dangerous-mod analysis instead
        if (MapMods.isWaystone(item)) {
            root.loading = false
            root.mapWarning = MapMods.analyzeMods(item.mods || [])
            return
        }

        if (item.rarity === "Currency" || item.itemClass === "Stackable Currency" ||
            item.itemClass === "Moneda apilable") {
            var lookupName = ItemParser.toEnglishName(item.name)
            var found = State.getRate(lookupName)
            root.loading = false
            if (found) {
                root.priceResult = {
                    type: "currency",
                    name: item.name,
                    chaosValue: found.chaosValue,
                    icon: found.icon || ""
                }
            } else {
                root.errorMsg = "'" + item.name + "' not in cache\n(open Economy first to load data)"
            }
            return
        }

        // Ensure stat ID cache is loaded, then map mods and search
        var _item   = item
        var _league = league
        StatIds.fetchStats(function(err2, _) {
            var statFilters = []
            if (_item.rarity !== "Unique") {
                var mods = _item.mods || []
                // Map mods to stat IDs, deduplicating by ID (keep highest min value).
                // This removes implicit/explicit duplicates (e.g. staff implicit
                // "60% increased Spell Damage" vs explicit "147%") so we don't
                // waste a filter slot or send conflicting values.
                var statMap = {}
                for (var mi = 0; mi < mods.length; mi++) {
                    var mapped = StatIds.mapMod(mods[mi])
                    if (!mapped) continue
                    var existing = statMap[mapped.id]
                    if (!existing || (mapped.min !== undefined && mapped.min > (existing.min || 0))) {
                        statMap[mapped.id] = { id: mapped.id, min: mapped.min, origText: mods[mi] }
                    }
                }
                // Sort by weight descending so fallback drops least-important mods first
                var weightedPairs = []
                for (var sid2 in statMap) {
                    var m = statMap[sid2]
                    var sf = { id: m.id }
                    if (m.min !== undefined) sf.value = { min: m.min }
                    weightedPairs.push({ sf: sf, w: TradeApi.getModWeight(m.origText || "") })
                }
                weightedPairs.sort(function(a, b) { return b.w - a.w })
                for (var wi = 0; wi < weightedPairs.length; wi++)
                    statFilters.push(weightedPairs[wi].sf)
            }

            TradeApi.searchItem(_item, statFilters, _league, "", function(err, data) {
                root.loading = false
                if (err) { root.errorMsg = err; return }
                var sid = data.searchId || ""
                var lg  = data.league  || _league
                root.priceResult = {
                    type: _item.rarity === "Unique" ? "unique" : "rare",
                    name: ItemParser.getDisplayName(_item),
                    listings: data.listings || [],
                    total: data.total || 0,
                    modsUsed: data.modsUsed || 0,
                    confidence: TradeApi.getConfidence(data.modsUsed || 0, data.total || 0),
                    tradeUrl: sid ? "https://www.pathofexile.com/trade2/search/poe2/" + encodeURIComponent(lg) + "/" + sid : ""
                }
            })
        })
    }

    function rarityColor(rarity) {
        switch (rarity) {
            case "Rare":     return "#ffff77"
            case "Unique":   return "#af6025"
            case "Magic":    return "#8888ff"
            case "Currency": return "#aa9e82"
            default:         return "#c0c0c0"
        }
    }

    // ── Result panel ──────────────────────────────────────────────
    Rectangle {
        id: panel
        anchors { fill: parent; margins: 10 }
        visible: root.showing
        color: "#1c1c1e"
        border.color: "#8B7355"
        border.width: 1
        radius: 6
        implicitHeight: col.implicitHeight + 20

        ColumnLayout {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
            spacing: 6

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: {
                        if (!root.currentItem) return "Price Check"
                        var it = root.currentItem
                        if (it.rarity === "Rare") return it.name + "  ·  " + it.baseType
                        return it.name
                    }
                    color: root.currentItem ? root.rarityColor(root.currentItem.rarity) : "#c0b090"
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    visible: !!root.currentItem
                    text: root.currentItem ? root.currentItem.rarity : ""
                    color: "#5a5a5a"
                    font.pixelSize: 10
                }

                // Green dot = mod stat IDs loaded, red = still loading
                Rectangle {
                    width: 6; height: 6; radius: 3
                    color: root.statsReady ? "#3a9a3a" : "#7a3a3a"
                }

                Text {
                    text: "  ✕"
                    color: "#7a6a50"
                    font.pixelSize: 12
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.showing = false }
                }
            }

            // Loading
            Text {
                visible: root.loading
                text: "Searching price..."
                color: "#7a6a50"
                font.pixelSize: 11
            }

            // Error
            Text {
                visible: !root.loading && root.errorMsg !== ""
                text: root.errorMsg
                color: "#d20000"
                font.pixelSize: 11
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            // ── Waystone danger analysis ─────────────────────────
            ColumnLayout {
                visible: !root.loading && !!root.mapWarning
                Layout.fillWidth: true
                spacing: 4

                Rectangle {
                    Layout.fillWidth: true
                    height: 22; radius: 3
                    color: {
                        if (!root.mapWarning) return "#2a2a2d"
                        var s = root.mapWarning.summary
                        if (s === "deadly") return "#3a0f0f"
                        if (s === "danger") return "#3a2a0f"
                        if (s === "warn")   return "#2a2a0f"
                        return "#0f2a18"
                    }
                    border.color: {
                        if (!root.mapWarning) return "#3a3a3a"
                        var s = root.mapWarning.summary
                        if (s === "deadly") return "#7a2020"
                        if (s === "danger") return "#7a5020"
                        if (s === "warn")   return "#7a7a20"
                        return "#1e5030"
                    }
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (!root.mapWarning) return ""
                            var s = root.mapWarning.summary
                            if (s === "deadly") return "☠  WAYSTONE LETAL"
                            if (s === "danger") return "⚠  WAYSTONE PELIGROSO"
                            if (s === "warn")   return "⚠  Mods a vigilar"
                            return "✓  Waystone seguro"
                        }
                        color: {
                            if (!root.mapWarning) return "#c0c0c0"
                            var s = root.mapWarning.summary
                            if (s === "deadly") return "#ff7070"
                            if (s === "danger") return "#ffaa50"
                            if (s === "warn")   return "#dddd60"
                            return "#4fc3a0"
                        }
                        font.pixelSize: 11; font.bold: true
                    }
                }

                Repeater {
                    model: root.mapWarning ? root.mapWarning.alerts : []
                    RowLayout {
                        spacing: 6
                        Layout.fillWidth: true

                        Rectangle {
                            width: 4
                            Layout.preferredHeight: alertBody.implicitHeight + 4
                            radius: 2
                            color: modelData.sev === "deadly" ? "#d20000" :
                                   modelData.sev === "danger" ? "#d28030" : "#c0c060"
                        }

                        ColumnLayout {
                            id: alertBody
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: modelData.label
                                color: modelData.sev === "deadly" ? "#ff8080" :
                                       modelData.sev === "danger" ? "#ffb060" : "#dddd80"
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text {
                                text: modelData.why
                                color: "#9a9a9a"
                                font.pixelSize: 9
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Text {
                    visible: root.mapWarning && root.mapWarning.alerts.length === 0
                    text: "Ningún mod peligroso detectado."
                    color: "#7a9a7a"
                    font.pixelSize: 10
                    Layout.fillWidth: true
                }
            }

            // Currency result
            RowLayout {
                visible: !root.loading && !!root.priceResult && root.priceResult.type === "currency"
                spacing: 8

                Image {
                    visible: !!root.priceResult && root.priceResult.icon !== ""
                    source: root.priceResult ? root.priceResult.icon : ""
                    width: 32; height: 32
                    sourceSize.width: 32; sourceSize.height: 32
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: root.priceResult ? root.fmtChaos(root.priceResult.chaosValue) + "  chaos" : ""
                        color: "#d4a843"
                        font.pixelSize: 18
                        font.bold: true
                    }
                    Text {
                        text: "poe.ninja price  ·  " + State.getLeague()
                        color: "#3a3a3a"
                        font.pixelSize: 9
                    }
                }
            }

            // Trade listings
            ColumnLayout {
                visible: !root.loading && !!root.priceResult && root.priceResult.type !== "currency"
                spacing: 3
                Layout.fillWidth: true

                RowLayout {
                    spacing: 6
                    Text {
                        visible: !!root.priceResult && root.priceResult.type !== "unique"
                        text: {
                            if (!root.priceResult) return ""
                            var c = root.priceResult.confidence
                            if (c === "high")    return "[ high confidence ]"
                            if (c === "medium")  return "[ medium confidence ]"
                            if (c === "low")     return "[ low confidence ]"
                            return "[ not enough data ]"
                        }
                        color: {
                            if (!root.priceResult) return "#5a5a5a"
                            var c = root.priceResult.confidence
                            if (c === "high")   return "#3a7a3a"
                            if (c === "medium") return "#7a7a3a"
                            return "#7a3a3a"
                        }
                        font.pixelSize: 10
                    }
                    Text {
                        visible: !!root.priceResult
                        text: root.priceResult ? root.priceResult.total + " listings" : ""
                        color: "#3a3a3a"
                        font.pixelSize: 10
                    }
                }

                Text {
                    visible: !!root.priceResult && root.priceResult.listings.length === 0
                    text: "No online listings"
                    color: "#5a5a5a"
                    font.pixelSize: 11
                }

                Repeater {
                    model: root.priceResult ? root.priceResult.listings : []
                    RowLayout {
                        spacing: 10
                        Text {
                            text: modelData.price
                            color: "#d4a843"
                            font.pixelSize: 12
                            font.bold: true
                            Layout.minimumWidth: 120
                        }
                        Text {
                            text: modelData.account
                            color: "#5a5a5a"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                // Trade link
                Text {
                    visible: !!root.priceResult && root.priceResult.tradeUrl !== ""
                    text: "→ view on trade site"
                    color: "#4a7aaa"
                    font.pixelSize: 10
                    topPadding: 4
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally(root.priceResult.tradeUrl)
                    }
                }
            }
        }
    }

    function fmtChaos(v) {
        if (!v) return "0"
        if (v >= 1000) return (v / 1000).toFixed(1) + "k"
        if (v >= 100)  return v.toFixed(0)
        if (v >= 10)   return v.toFixed(1)
        if (v >= 1)    return v.toFixed(2)
        return v.toFixed(3)
    }
}

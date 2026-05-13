import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "js/PoeNinja2.js" as PoeNinja2
import "js/EconomyApi.js" as EconomyApi
import "js/State.js" as State
import "js/NeverSink.js" as NeverSink

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.margins.left: isOpen ? offsetX : 0
    WlrLayershell.margins.top:  isOpen ? offsetY : 0

    anchors.top:  true
    anchors.left: true

    implicitWidth:  isOpen ? 1020 : 1
    implicitHeight: isOpen ? 580  : 1

    color: "transparent"

    property bool   isOpen:         false
    property int    offsetX:        400
    property int    offsetY:        240

    property var    entries:        []
    property bool   fetching:       false
    property int    fetched:        0
    property string fetchErr:       ""
    property var    hoveredEntry:   null
    property real   hoveredRowY:     0
    property string activeCategory:  "Currency"
    property string searchText:      ""
    property var    filteredEntries: []
    property var    currencyEntries:  []

    onEntriesChanged:        Qt.callLater(root._applyFilter)
    onSearchTextChanged:     Qt.callLater(root._applyFilter)
    onActiveCategoryChanged: root.searchText = ""

    function _applyFilter() {
        if (searchText.length === 0) {
            filteredEntries = entries
            return
        }
        var q = searchText.toLowerCase()
        var out = []
        for (var i = 0; i < entries.length; i++) {
            if (entries[i].name.toLowerCase().indexOf(q) !== -1)
                out.push(entries[i])
        }
        filteredEntries = out
    }

    property string selectedLeague:  "Fate of the Vaal"
    property var    availableLeagues: []
    property bool   leaguesFetched:  false
    property var    categoryIcons:   ({})

    // ── NeverSink filter state ────────────────────────────────────
    property string filterLatestVersion:   ""
    property bool   filterUpdateAvailable: false
    property bool   filterInstalling:      false
    property string filterInstallStatus:   ""
    property string filterInstallError:    ""
    property bool   filterDetecting:       false
    property string _homeDir:              ""
    property string localFilterStyle:      "DARKMODE"
    property string localInstalledVersion: ""

    readonly property string effectiveInstallPath: Config.filterInstallPath ||
        (_homeDir + "/.steam/steam/steamapps/compatdata/2694490/pfx/drive_c/users/steamuser/My Documents/My Games/Path of Exile 2")

    readonly property var categories: [
        { label: "Currency",   type: "Currency"   },
        { label: "Fragments",  type: "Fragments"  },
        { label: "Essences",   type: "Essences"   },
        { label: "Soul Cores", type: "SoulCores"  },
        { label: "Uncut Gems", type: "UncutGems"  },
        { label: "Idols",      type: "Idols"      },
        { label: "Runes",      type: "Runes"      },
        { label: "Omens",      type: "Ritual"     },
        { label: "Expedition", type: "Expedition" },
        { label: "Catalysts",  type: "Breach"     },
        { label: "⚙ Options",  type: "__options__" }
    ]

    Component.onCompleted: {
        State.addEconomyListener(function(v) { root.isOpen = v })
        // fetchLeagues / startFetch / prefetchCategoryIcons are deferred until
        // homeProc → leagueReadProc chain completes, so selectedLeague is correct first.
        NeverSink.checkLatestVersion(function(err, data) {
            if (!err && data && data.tag) {
                root.filterLatestVersion = data.tag
                root.filterUpdateAvailable = (
                    !!root.localInstalledVersion &&
                    root.localInstalledVersion !== data.tag
                )
            }
        })
    }

    function fmtVal(v) {
        if (v >= 1000000) return (v / 1000000).toFixed(2) + "M"
        if (v >= 1000)    return (v / 1000).toFixed(1) + "k"
        if (v >= 100)     return v.toFixed(0)
        if (v >= 10)      return v.toFixed(1)
        if (v >= 1)       return v.toFixed(2)
        return v.toFixed(3)
    }

    function _detectFilterPath() {
        root.filterDetecting = true
        detectProc.running = true
    }

    function _startFilterInstall() {
        root.filterInstalling = true
        root.filterInstallStatus = ""
        root.filterInstallError = ""
        filterInstallProc.command = NeverSink.buildInstallCmd(
            root.filterLatestVersion,
            root.localFilterStyle,
            root.effectiveInstallPath
        )
        filterInstallProc.running = true
    }

    // ── Resolve $HOME once at startup ────────────────────────────
    Process {
        id: homeProc
        command: ["sh", "-c", "printf '%s' \"$HOME\""]
        stdout: StdioCollector { id: homeOut }
        Component.onCompleted: running = true
        onRunningChanged: {
            if (!running) {
                root._homeDir = homeOut.text.trim()
                leagueReadProc.command = ["sh", "-c",
                    "cat \"" + root._homeDir + "/.config/quickshell/poe2/.saved-league\" 2>/dev/null || printf 'Fate of the Vaal'"]
                leagueReadProc.running = true
                versionCheckProc.command = ["sh", "-c",
                    "cat \"" + root.effectiveInstallPath + "/.neversink-version\" 2>/dev/null"]
                versionCheckProc.running = true
            }
        }
    }

    // ── Read saved league from file ───────────────────────────────
    Process {
        id: leagueReadProc
        stdout: StdioCollector { id: leagueReadOut }
        onRunningChanged: {
            if (!running) {
                var lg = leagueReadOut.text.trim()
                if (lg) {
                    root.selectedLeague = lg
                    State.setLeague(lg)
                }
                root.fetchLeagues()
                root.startFetch(true)
                root.prefetchCategoryIcons()
            }
        }
    }

    // ── Save league to file ───────────────────────────────────────
    Process {
        id: leagueSaveProc
        stdout: StdioCollector {}
    }

    // ── Check installed NeverSink version from marker file ────────
    Process {
        id: versionCheckProc
        stdout: StdioCollector { id: versionCheckOut }
        onRunningChanged: {
            if (!running) {
                var v = versionCheckOut.text.trim()
                if (v) root.localInstalledVersion = v
            }
        }
    }

    // ── PoE2 path auto-detection process ─────────────────────────
    // command is a static binding evaluated once at init — never change it at runtime
    Process {
        id: detectProc
        command: NeverSink.getDetectCmd()
        stdout: StdioCollector { id: detectOut }
        onRunningChanged: {
            if (!running) {
                Qt.callLater(function() {
                    var path = detectOut.text.trim()
                    root.filterDetecting = false
                    if (path !== "") {
                        Config.filterInstallPath = path
                    }
                })
            }
        }
    }

    // ── NeverSink filter delete process ──────────────────────────
    Process {
        id: filterDeleteProc
        stdout: StdioCollector { id: filterDeleteOut }
        onRunningChanged: {
            if (!running) {
                if (filterDeleteOut.text.trim() === "OK") {
                    root.localInstalledVersion = ""
                    root.filterInstallError = ""
                    root.filterUpdateAvailable = false
                }
            }
        }
    }

    // ── NeverSink filter install process ─────────────────────────
    Process {
        id: filterInstallProc
        stdout: StdioCollector { id: filterInstallOut }
        stderr: StdioCollector { id: filterInstallErr }
        onRunningChanged: {
            if (!running) {
                Qt.callLater(function() {
                    var out = filterInstallOut.text.trim()
                    var err = filterInstallErr.text.trim()
                    root.filterInstalling = false
                    if (out.indexOf("OK") !== -1) {
                        root.localInstalledVersion = root.filterLatestVersion
                        root.filterUpdateAvailable = false
                        root.filterInstallStatus = ""
                        root.filterInstallError = ""
                    } else {
                        root.filterInstallError = "Error: " + (err || out || "desconocido")
                        root.filterInstallStatus = ""
                    }
                })
            }
        }
    }

    // ── Main panel ──────────────────────────────────────────────
    Rectangle {
        id: panel
        anchors.fill: parent
        visible: root.isOpen
        color: "#1b2430"
        border.color: "#2d3d50"
        border.width: 1
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Title / drag bar ───────────────────────────────
            Rectangle {
                id: headerBar
                Layout.fillWidth: true
                height: 42
                color: "#111820"
                radius: 8
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: 8; color: parent.color
                }
                MouseArea {
                    anchors.fill: parent
                    property real mx: 0; property real my: 0
                    property int  ox: 0; property int  oy: 0
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    onPressed:  { mx = mouseX; my = mouseY; ox = root.offsetX; oy = root.offsetY }
                    onPositionChanged: {
                        if (pressed) {
                            root.offsetX = Math.max(0, ox + (mouseX - mx))
                            root.offsetY = Math.max(0, oy + (mouseY - my))
                        }
                    }
                }
                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 12 }
                    Text {
                        text: root.selectedLeague + "  ›  " + root.activeCategory
                        color: "#6a8aaa"; font.pixelSize: 11
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "The Foundry: PoE2"
                        color: "#d4a843"; font.pixelSize: 15; font.bold: true
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        text: {
                            if (root.fetching) return "Loading..."
                            if (root.fetchErr)  return (root.fetchErr.indexOf("No data") !== -1 ? "ℹ " : "⚠ ") + root.fetchErr
                            if (root.entries.length === 0) return ""
                        var total = root.entries.length
                        var shown = root.filteredEntries.length
                        return shown < total ? shown + " / " + total + " items" : total + " items"
                        }
                        color: (root.fetchErr && root.fetchErr.indexOf("No data") === -1) ? "#d20000" : "#4a5a6a"
                        font.pixelSize: 10
                    }
                    Text {
                        text: root.fetching ? "..." : "↺"
                        color: "#7a8a99"; font.pixelSize: 14; leftPadding: 8
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: if (!root.fetching) root.startFetch(true)
                        }
                    }
                    Text {
                        text: "✕"
                        color: "#7a8a99"; font.pixelSize: 14; leftPadding: 12
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: State.setEconomyOpen(false)
                        }
                    }
                }
            }

            // ── Body: sidebar + content ────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // ── Sidebar ────────────────────────────────────
                Rectangle {
                    width: 150
                    Layout.fillHeight: true
                    color: "#111820"

                    // Category tabs (all except Options)
                    Column {
                        id: sidebarCol
                        anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 6 }
                        spacing: 1

                        Repeater {
                            model: root.categories.filter(function(c) { return c.type !== "__options__" })
                            delegate: Rectangle {
                                id: catRow
                                property var cat: modelData
                                width: sidebarCol.width
                                height: 34
                                color: cat.type === root.activeCategory ? "#1e3a50" : "transparent"
                                radius: 4

                                // Active bar
                                Rectangle {
                                    visible: cat.type === root.activeCategory
                                    width: 3; height: parent.height * 0.6; radius: 2
                                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                                    color: "#4fc3a0"
                                }

                                // Icon + label
                                RowLayout {
                                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 8; rightMargin: 6 }
                                    spacing: 6

                                    Image {
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                        sourceSize.width: 24; sourceSize.height: 24
                                        source: root.categoryIcons[cat.type] || ""
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: cat.label
                                        color: cat.type === root.activeCategory ? "#4fc3a0" : "#6a8aaa"
                                        font.pixelSize: 12
                                        font.bold: cat.type === root.activeCategory
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: catRow.color = cat.type === root.activeCategory ? "#1e3a50" : "#182838"
                                    onExited:  catRow.color = cat.type === root.activeCategory ? "#1e3a50" : "transparent"
                                    onClicked: {
                                        if (cat.type !== root.activeCategory) {
                                            root.activeCategory = cat.type
                                            root.startFetch(true)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Options tab pinned to bottom
                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                        height: 42
                        color: "#111820"

                        Rectangle {
                            anchors { left: parent.left; right: parent.right; top: parent.top }
                            height: 1; color: "#1e2d3e"
                        }

                        Rectangle {
                            id: optRow
                            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                            height: 34
                            color: root.activeCategory === "__options__" ? "#1e3a50" : "transparent"
                            radius: 4

                            Rectangle {
                                visible: root.activeCategory === "__options__"
                                width: 3; height: parent.height * 0.6; radius: 2
                                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                                color: "#4fc3a0"
                            }

                            Text {
                                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                                text: "⚙  Options"
                                color: root.activeCategory === "__options__" ? "#4fc3a0" : "#6a8aaa"
                                font.pixelSize: 12
                                font.bold: root.activeCategory === "__options__"
                            }

                            // Update available badge
                            Rectangle {
                                visible: root.filterUpdateAvailable
                                width: 8; height: 8; radius: 4
                                color: "#e0a030"
                                anchors { right: parent.right; top: parent.top; rightMargin: 8; topMargin: 6 }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: optRow.color = root.activeCategory === "__options__" ? "#1e3a50" : "#182838"
                                onExited:  optRow.color = root.activeCategory === "__options__" ? "#1e3a50" : "transparent"
                                onClicked: root.activeCategory = "__options__"
                            }
                        }
                    }
                }

                Rectangle { width: 1; Layout.fillHeight: true; color: "#1e2d3e" }

                // ── Main content ───────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    // Search bar
                    Rectangle {
                        Layout.fillWidth: true
                        height: 32
                        color: "#0d141c"
                        Rectangle {
                            anchors { fill: parent; leftMargin: 10; rightMargin: 10; topMargin: 5; bottomMargin: 5 }
                            color: "#111e2c"
                            border.color: searchInput.activeFocus ? "#4a7aaa" : "#1e2d3e"
                            border.width: 1
                            radius: 4

                            Text {
                                anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                                text: "🔍"
                                font.pixelSize: 10
                                color: "#3a5070"
                            }

                            TextInput {
                                id: searchInput
                                anchors { left: parent.left; right: clearBtn.left; leftMargin: 24; rightMargin: 4; verticalCenter: parent.verticalCenter }
                                text: root.searchText
                                onTextChanged: root.searchText = text
                                color: "#dde8f0"
                                font.pixelSize: 12
                                clip: true
                                selectByMouse: true

                                Text {
                                    visible: searchInput.text.length === 0
                                    text: "Search items..."
                                    color: "#2a4060"
                                    font.pixelSize: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Text {
                                id: clearBtn
                                visible: root.searchText.length > 0
                                anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                text: "✕"
                                color: "#3a5070"
                                font.pixelSize: 11
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { root.searchText = ""; searchInput.text = "" }
                                }
                            }
                        }
                    }

                    // Column headers
                    Rectangle {
                        Layout.fillWidth: true
                        height: 28
                        color: "#0f161f"
                        RowLayout {
                            anchors { fill: parent; leftMargin: 62; rightMargin: 14 }
                            spacing: 0
                            Text { text: "Name";          color: "#4a6a8a"; font.pixelSize: 11; Layout.fillWidth: true }
                            Text { text: "Value  ⓘ";      color: "#4a6a8a"; font.pixelSize: 11; width: 210; horizontalAlignment: Text.AlignRight }
                            Text { text: "Last 7 days";   color: "#4a6a8a"; font.pixelSize: 11; width: 155; horizontalAlignment: Text.AlignHCenter }
                            Text { text: "Vol / Hour  ⓘ"; color: "#4a6a8a"; font.pixelSize: 11; width: 100; horizontalAlignment: Text.AlignRight }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#1e2d3e" }

                    // Empty / loading state
                    Item {
                        visible: root.entries.length === 0 && root.activeCategory !== "__options__"
                        Layout.fillWidth: true; Layout.fillHeight: true
                        Text {
                            anchors.centerIn: parent
                            text: root.fetching ? "Loading..." : (root.fetchErr ? root.fetchErr : "Press ↺ to load")
                            color: (root.fetchErr && root.fetchErr.indexOf("No data") === -1) ? "#d04040" : "#3a5070"
                            font.pixelSize: 13
                        }
                    }

                    // Currency list
                    ListView {
                        id: listView
                        visible: root.entries.length > 0 && root.activeCategory !== "__options__"
                        Layout.fillWidth: true; Layout.fillHeight: true
                        clip: true
                        model: root.filteredEntries

                        HoverHandler {
                            onHoveredChanged: if (!hovered) root.hoveredEntry = null
                        }

                        delegate: Rectangle {
                            id: row
                            width: listView.width
                            height: 52
                            color: rowHH.hovered ? "#263347" : (index % 2 === 0 ? "#1b2430" : "#1e2a38")

                            RowLayout {
                                anchors { fill: parent; leftMargin: 12; rightMargin: 14 }
                                spacing: 0

                                Image {
                                    width: 38; height: 38
                                    sourceSize.width: 38; sourceSize.height: 38
                                    source: modelData.icon
                                    fillMode: Image.PreserveAspectFit; smooth: true
                                }
                                Item { width: 12 }
                                Text {
                                    text: modelData.name
                                    color: "#dde8f0"; font.pixelSize: 13
                                    Layout.fillWidth: true; elide: Text.ElideRight
                                }

                                // Value: [num] [divine] ⇄ 1.0 [icon]
                                Item {
                                    width: 210
                                    Row {
                                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                                        spacing: 5
                                        Text {
                                            text: root.fmtVal(modelData.primaryValue)
                                            color: "#4fc3a0"; font.pixelSize: 14; font.bold: true
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Image {
                                            width: 18; height: 18; sourceSize.width: 18; sourceSize.height: 18
                                            source: Qt.resolvedUrl("icons/divine.png")
                                            fillMode: Image.PreserveAspectFit
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text { text: "⇄"; color: "#3a5470"; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: "1.0"; color: "#8a9aaa"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                                        Image {
                                            width: 20; height: 20; sourceSize.width: 20; sourceSize.height: 20
                                            source: modelData.icon; fillMode: Image.PreserveAspectFit
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }

                                // Sparkline + % change
                                Item {
                                    width: 155
                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Canvas {
                                            id: spark
                                            width: 90; height: 30
                                            anchors.verticalCenter: parent.verticalCenter
                                            property var  pts: modelData.sparkData   || []
                                            property real chg: modelData.sparkChange || 0
                                            Component.onCompleted: requestPaint()
                                            onPtsChanged: requestPaint()
                                            onPaint: {
                                                var c = getContext("2d")
                                                c.clearRect(0, 0, width, height)
                                                var filtered = []
                                                for (var i = 0; i < pts.length; i++) {
                                                    if (pts[i] !== null && pts[i] !== undefined)
                                                        filtered.push({ idx: i, val: pts[i] })
                                                }
                                                if (filtered.length < 2) return
                                                var mn = filtered[0].val, mx = filtered[0].val
                                                for (var k = 1; k < filtered.length; k++) {
                                                    if (filtered[k].val < mn) mn = filtered[k].val
                                                    if (filtered[k].val > mx) mx = filtered[k].val
                                                }
                                                var rng = mx - mn; if (rng < 0.0001) rng = 1
                                                var nmax = pts.length - 1; if (nmax < 1) nmax = 1
                                                c.strokeStyle = chg >= 0 ? "#4caf8b" : "#e05252"
                                                c.lineWidth = 1.5; c.lineJoin = "round"; c.lineCap = "round"
                                                c.beginPath()
                                                for (var j = 0; j < filtered.length; j++) {
                                                    var px = (filtered[j].idx / nmax) * (width - 6) + 3
                                                    var py = (height - 4) - ((filtered[j].val - mn) / rng) * (height - 8)
                                                    if (j === 0) c.moveTo(px, py); else c.lineTo(px, py)
                                                }
                                                c.stroke()
                                            }
                                        }
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: {
                                                var v = modelData.sparkChange || 0
                                                return (v >= 0 ? "+" : "") + v.toFixed(0) + "%"
                                            }
                                            color: (modelData.sparkChange || 0) >= 0 ? "#4caf8b" : "#e05252"
                                            font.pixelSize: 11; width: 40; horizontalAlignment: Text.AlignRight
                                        }
                                    }
                                }

                                // Volume / Hour
                                Item {
                                    width: 100
                                    Row {
                                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                                        spacing: 5
                                        Text {
                                            text: modelData.volume > 0 ? root.fmtVal(modelData.volume) : "—"
                                            color: "#6a8aaa"; font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Image {
                                            visible: modelData.volume > 0
                                            width: 16; height: 16; sourceSize.width: 16; sourceSize.height: 16
                                            source: modelData.volumeIcon || modelData.icon
                                            fillMode: Image.PreserveAspectFit
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }
                            }

                            HoverHandler {
                                id: rowHH
                                onHoveredChanged: {
                                    if (hovered) {
                                        root.hoveredEntry = modelData
                                        var pos = row.mapToItem(panel, 0, row.height / 2)
                                        root.hoveredRowY = pos.y
                                    }
                                }
                            }
                        }
                    }

                    // ── Options panel ──────────────────────────────
                    Item {
                        visible: root.activeCategory === "__options__"
                        Layout.fillWidth: true; Layout.fillHeight: true

                        Flickable {
                            anchors.fill: parent
                            contentWidth: width
                            contentHeight: optionsCol.y + optionsCol.implicitHeight + 20
                            clip: true

                            Column {
                                id: optionsCol
                                x: 24; y: 20
                                width: parent.width - 48
                                spacing: 8

                                // ── League ──────────────────────────────────
                                Text { text: "Liga activa"; color: "#d4a843"; font.pixelSize: 14; font.bold: true }

                                Text {
                                    visible: root.availableLeagues.length === 0
                                    text: "Cargando ligas..."
                                    color: "#3a5070"; font.pixelSize: 12
                                }

                                Repeater {
                                    model: root.availableLeagues
                                    delegate: Rectangle {
                                        id: lgRow
                                        property string lgName: modelData
                                        width: parent.width; height: 42; radius: 5
                                        color:        root.selectedLeague === lgName ? "#0e2a1a" : "#131b26"
                                        border.color: root.selectedLeague === lgName ? "#4fc3a0" : "#1e2d3e"
                                        border.width: 1
                                        Text {
                                            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                                            text: lgRow.lgName
                                            color: root.selectedLeague === lgRow.lgName ? "#4fc3a0" : "#8a9aaa"
                                            font.pixelSize: 13; font.bold: root.selectedLeague === lgRow.lgName
                                        }
                                        Text {
                                            visible: root.selectedLeague === lgRow.lgName
                                            anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                                            text: "✓"; color: "#4fc3a0"; font.pixelSize: 14
                                        }
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: root.applyLeague(lgRow.lgName)
                                        }
                                    }
                                }

                                Rectangle { width: parent.width; height: 1; color: "#1e2d3e" }

                                Text { text: "Liga personalizada"; color: "#4a6a8a"; font.pixelSize: 11 }

                                Rectangle {
                                    width: parent.width; height: 36; radius: 5
                                    color: customInput.activeFocus ? "#131b26" : "#0f161f"
                                    border.color: customInput.activeFocus ? "#4fc3a0" : "#2a3d50"
                                    border.width: 1
                                    TextInput {
                                        id: customInput
                                        anchors { left: parent.left; right: confirmBtn.left; top: parent.top; bottom: parent.bottom; leftMargin: 12; rightMargin: 4; topMargin: 2; bottomMargin: 2 }
                                        color: "#dde8f0"; font.pixelSize: 13
                                        verticalAlignment: TextInput.AlignVCenter; clip: true
                                        onAccepted: { var t = text.trim(); if (t.length > 0) root.applyLeague(t) }
                                    }
                                    Text {
                                        visible: customInput.text.length === 0 && !customInput.activeFocus
                                        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                                        text: "Nombre de liga..."; color: "#2a3d50"; font.pixelSize: 13
                                    }
                                    Rectangle {
                                        id: confirmBtn
                                        anchors { right: parent.right; top: parent.top; bottom: parent.bottom; margins: 4 }
                                        width: 32; radius: 4
                                        color: customInput.activeFocus ? "#1a3a28" : "transparent"
                                        Text { anchors.centerIn: parent; text: "↵"; color: customInput.activeFocus ? "#4fc3a0" : "#2a3d50"; font.pixelSize: 14 }
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: { var t = customInput.text.trim(); if (t.length > 0) root.applyLeague(t) }
                                        }
                                    }
                                }

                                Text { text: "Usando: " + root.selectedLeague; color: "#3a6a5a"; font.pixelSize: 11 }

                                // ── NeverSink Filter ─────────────────────────
                                Item { width: parent.width; height: 12 }

                                Rectangle { width: parent.width; height: 1; color: "#1e2d3e" }

                                Item { width: parent.width; height: 4 }

                                Text { text: "NeverSink Loot Filter"; color: "#d4a843"; font.pixelSize: 14; font.bold: true }

                                Text {
                                    text: root.localInstalledVersion ? "Instalado: " + root.localInstalledVersion : "No instalado"
                                    color: root.localInstalledVersion ? "#3a9a3a" : "#4a6a8a"
                                    font.pixelSize: 11
                                }

                                // Style selector — selecting a style installs all strictness levels
                                Text { text: "Estilo (instala todos los niveles de strictness)"; color: "#4a6a8a"; font.pixelSize: 11 }

                                RowLayout {
                                    width: parent.width
                                    spacing: 4
                                    Repeater {
                                        model: ["DARKMODE", "COBALT", "MYTHIC", "ZEN", "CUSTOMSOUNDS"]
                                        Rectangle {
                                            property bool sel: root.localFilterStyle === modelData
                                            Layout.fillWidth: true; height: 30; radius: 4
                                            color: sel ? "#1a3a50" : "#111e2c"
                                            border.color: sel ? "#4a8aaa" : "#1e2d3e"; border.width: 1
                                            Text {
                                                anchors.centerIn: parent; text: modelData
                                                color: sel ? "#90c0e0" : "#4a6a8a"
                                                font.pixelSize: 10; font.bold: sel
                                            }
                                            MouseArea {
                                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onClicked: root.localFilterStyle = modelData
                                            }
                                        }
                                    }
                                }

                                // Install path
                                RowLayout {
                                    width: parent.width
                                    Text { text: "Ruta de instalación"; color: "#4a6a8a"; font.pixelSize: 11; Layout.fillWidth: true }
                                    Text {
                                        visible: root.filterDetecting
                                        text: "Detectando..."
                                        color: "#4a7aaa"; font.pixelSize: 10
                                    }
                                }

                                RowLayout {
                                    width: parent.width
                                    spacing: 4

                                    Rectangle {
                                        Layout.fillWidth: true; height: 32; radius: 4
                                        color: "#0f161f"
                                        border.color: "#1e2d3e"; border.width: 1

                                        Text {
                                            id: filterPathInput
                                            anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                            text: root.effectiveInstallPath
                                            color: "#6a8aaa"
                                            font.pixelSize: 10; elide: Text.ElideLeft; clip: true
                                        }
                                    }

                                    Rectangle {
                                        width: 76; height: 32; radius: 4
                                        color: root.filterDetecting ? "#1a2a3a" : "#131b26"
                                        border.color: root.filterDetecting ? "#2a4a6a" : "#2a4060"; border.width: 1
                                        Text {
                                            anchors.centerIn: parent
                                            text: root.filterDetecting ? "..." : "Detectar"
                                            color: root.filterDetecting ? "#3a5070" : "#6a8aaa"; font.pixelSize: 11
                                        }
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: if (!root.filterDetecting) root._detectFilterPath()
                                        }
                                    }
                                }

                                // Install / Update button + Delete button
                                RowLayout {
                                    width: parent.width
                                    spacing: 4

                                Rectangle {
                                    Layout.fillWidth: true; height: 40; radius: 5
                                    color: root.filterInstalling ? "#1a2a3a"
                                         : root.filterUpdateAvailable ? "#1a3020"
                                         : root.localInstalledVersion === root.filterLatestVersion && root.filterLatestVersion !== "" ? "#111e2c"
                                         : "#0e1f14"
                                    border.color: root.filterInstalling ? "#2a4a6a"
                                               : root.filterUpdateAvailable ? "#3a7050"
                                               : root.localInstalledVersion === root.filterLatestVersion && root.filterLatestVersion !== "" ? "#2a3a4a"
                                               : "#2a6040"
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: {
                                            if (root.filterInstalling) return "⏳  Instalando..."
                                            if (root.filterLatestVersion === "") return "Buscando versión..."
                                            if (!root.localInstalledVersion) return "⬇  Instalar " + root.filterLatestVersion
                                            if (root.filterUpdateAvailable) return "⬆  Actualizar a " + root.filterLatestVersion
                                            return "✓  Instalado " + root.localInstalledVersion
                                        }
                                        color: {
                                            if (root.filterInstalling) return "#3a5070"
                                            if (root.filterLatestVersion === "") return "#3a5070"
                                            if (!root.localInstalledVersion) return "#4fc3a0"
                                            if (root.filterUpdateAvailable) return "#4fc3a0"
                                            return "#5a7a5a"
                                        }
                                        font.pixelSize: 12
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        property bool canInstall: !root.filterInstalling && root.filterLatestVersion !== ""
                                        cursorShape: canInstall ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: { if (canInstall) root._startFilterInstall() }
                                    }
                                }

                                // Trash button — deletes all installed filters
                                Rectangle {
                                    width: 40; height: 40; radius: 5
                                    visible: !!root.localInstalledVersion
                                    color: trashArea.containsMouse ? "#2a1010" : "#1a1010"
                                    border.color: trashArea.containsMouse ? "#7a3030" : "#3a2020"; border.width: 1
                                    Text {
                                        anchors.centerIn: parent; text: "🗑"
                                        font.pixelSize: 16
                                    }
                                    MouseArea {
                                        id: trashArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            filterDeleteProc.command = [
                                                "bash", "-c",
                                                "rm -f \"" + root.effectiveInstallPath + "\"/*.filter \"" + root.effectiveInstallPath + "\"/.neversink-version && echo OK"
                                            ]
                                            filterDeleteProc.running = true
                                        }
                                    }
                                }

                                } // end RowLayout

                                // Status / error
                                Text {
                                    visible: root.filterInstallStatus !== "" || root.filterInstallError !== ""
                                    width: parent.width
                                    text: root.filterInstallError !== "" ? root.filterInstallError : root.filterInstallStatus
                                    color: root.filterInstallError !== "" ? "#d04040" : "#3a9a3a"
                                    font.pixelSize: 11; wrapMode: Text.WordWrap
                                }

                                Item { width: parent.width; height: 10 }
                            }
                        }
                    }
                }
            }
        }

        // ── Cross-rate hover popup ──────────────────────────────
        Rectangle {
            id: crossPopup
            visible: root.hoveredEntry !== null && crossRepeater.count > 0
            z: 200
            width: 270
            height: crossCol.implicitHeight + 16
            x: panel.width - width - 14
            y: {
                var ideal = root.hoveredRowY - height / 2
                return Math.max(44, Math.min(ideal, panel.height - height - 5))
            }
            color: "#0d1117"
            border.color: "#2d3d50"; border.width: 1; radius: 6

            ColumnLayout {
                id: crossCol
                anchors { fill: parent; margins: 8 }
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true; spacing: 6
                    Image {
                        width: 18; height: 18; sourceSize.width: 18; sourceSize.height: 18
                        source: root.hoveredEntry ? root.hoveredEntry.icon : ""
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        text: root.hoveredEntry ? root.hoveredEntry.name : ""
                        color: "#d4a843"; font.pixelSize: 11; font.bold: true
                        Layout.fillWidth: true
                    }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: "#1e2d3e" }

                Repeater {
                    id: crossRepeater
                    model: {
                        if (!root.hoveredEntry) return []
                        var pinned = ["exalted", "annul", "vaal", "chaos"]
                        var list = []
                        for (var p = 0; p < pinned.length; p++) {
                            if (pinned[p] === root.hoveredEntry.id) continue
                            for (var i = 0; i < root.currencyEntries.length; i++) {
                                if (root.currencyEntries[i].id === pinned[p]) { list.push(root.currencyEntries[i]); break }
                            }
                        }
                        return list
                    }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 5
                        Image {
                            width: 16; height: 16; sourceSize.width: 16; sourceSize.height: 16
                            source: modelData.icon; fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            text: modelData.name; color: "#c0ccd8"; font.pixelSize: 10
                            Layout.fillWidth: true; elide: Text.ElideRight
                        }
                        Text {
                            text: root.fmtVal(root.hoveredEntry.chaosValue / modelData.chaosValue)
                            color: "#4fc3a0"; font.pixelSize: 11; font.bold: true
                        }
                        Image {
                            width: 13; height: 13; sourceSize.width: 13; sourceSize.height: 13
                            source: modelData.icon; fillMode: Image.PreserveAspectFit
                        }
                        Text { text: "⇄ 1"; color: "#3a5070"; font.pixelSize: 10 }
                        Image {
                            width: 13; height: 13; sourceSize.width: 13; sourceSize.height: 13
                            source: root.hoveredEntry ? root.hoveredEntry.icon : ""
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                }
            }
        }
    }

    // ── Prefetch icons for all sidebar categories ────────────────
    function prefetchCategoryIcons() {
        var cats = root.categories
        for (var i = 0; i < cats.length; i++) {
            if (cats[i].type === "__options__" || cats[i].type === "Currency") continue
            ;(function(type) {
                PoeNinja2.fetchAll(root.selectedLeague, type, function(err, entries) {
                    if (!err && entries && entries.length > 0) {
                        var icons = {}
                        for (var k in root.categoryIcons) icons[k] = root.categoryIcons[k]
                        icons[type] = entries[0].icon
                        root.categoryIcons = icons
                    }
                })
            })(cats[i].type)
        }
    }

    // ── League list from poe.ninja ──────────────────────────────
    function fetchLeagues() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://poe.ninja/poe2/api/data/index-state", true)
        xhr.setRequestHeader("Accept", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4 || xhr.status !== 200) return
            try {
                var d = JSON.parse(xhr.responseText)
                var raw = d.economyLeagues || []
                var names = []
                for (var i = 0; i < raw.length; i++) {
                    if (raw[i].name) names.push(raw[i].name)
                }
                if (names.length > 0) {
                    root.availableLeagues = names
                    // Only switch if the saved league no longer exists in poe.ninja
                    var found = false
                    for (var j = 0; j < names.length; j++) {
                        if (names[j] === root.selectedLeague) { found = true; break }
                    }
                    if (!found) root.applyLeague(names[0])
                }
            } catch(e) {}
        }
        xhr.send()
    }

    // ── League change ───────────────────────────────────────────
    function applyLeague(name) {
        root.selectedLeague = name
        State.setLeague(name)
        leagueSaveProc.command = ["sh", "-c",
            "printf '%s' \"" + name + "\" > \"" + root._homeDir + "/.config/quickshell/poe2/.saved-league\""]
        leagueSaveProc.running = true
        root.activeCategory = "Currency"
        root.startFetch(true)
    }

    // ── Fetch logic ─────────────────────────────────────────────
    function startFetch(clear) {
        if (root.activeCategory === "__options__") return
        if (clear !== false) entries = []
        fetching = true; fetched = 0; fetchErr = ""
        hoveredEntry = null
        State.setFetching(true)

        PoeNinja2.fetchAll(root.selectedLeague, root.activeCategory, function(err, newEntries) {
            if (!err && newEntries && newEntries.length > 0) {
                fetching = false
                State.setFetching(false)
                entries = newEntries
                fetched = newEntries.length
                var icons = {}; for (var _k in root.categoryIcons) icons[_k] = root.categoryIcons[_k]
                icons[root.activeCategory] = newEntries[0].icon
                root.categoryIcons = icons
                if (root.activeCategory === "Currency") {
                    root.currencyEntries = newEntries
                    State.setEntries(entries, "")
                }
            } else {
                if (root.activeCategory === "Currency") {
                    fetchErr = ""
                    _fetchTrade(EconomyApi.CURRENCIES.slice())
                } else {
                    fetching = false
                    State.setFetching(false)
                    fetchErr = "No data yet — not enough trades tracked for this category"
                }
            }
        })
    }

    function _fetchTrade(pending) {
        if (pending.length === 0) {
            fetching = false
            State.setFetching(false)
            State.setEntries(entries, fetchErr)
            return
        }
        var curr = pending[0]
        var rest = pending.slice(1)
        EconomyApi.fetchOne(curr, root.selectedLeague, function(err, item) {
            if (err && (err.indexOf("Rate") !== -1 || err.indexOf("429") !== -1)) {
                fetching = false
                State.setFetching(false)
                fetchErr = "Rate limited — wait 1 min and press ↺"
                State.setEntries(entries, fetchErr)
                return
            }
            if (item) {
                fetched++
                var arr = entries.slice().filter(function(e) { return e.id !== item.id })
                var ok = false
                for (var i = 0; i < arr.length; i++) {
                    if (item.chaosValue > arr[i].chaosValue) { arr.splice(i, 0, item); ok = true; break }
                }
                if (!ok) arr.push(item)
                entries = arr
                root.currencyEntries = arr
                if (!root.categoryIcons["Currency"]) {
                    var icons2 = {}; for (var _k2 in root.categoryIcons) icons2[_k2] = root.categoryIcons[_k2]
                    icons2["Currency"] = arr[0].icon
                    root.categoryIcons = icons2
                }
                State.setEntries(arr, "")
            }
            _fetchTrade(rest)
        })
    }
}

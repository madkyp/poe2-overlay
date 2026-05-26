import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

// Watches Client.txt for in-game events and shows brief toast
// notifications. Currently detects:
//   - Level-ups        ("Your character has reached level X")
//   - Boss kill chat   (": has been slain by")
//   - AFK-mode toggle  ("AFK mode is now ON/OFF")
//   - Trade whispers   ("@From Name: Hi, I'd like to buy ...")

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.margins.top:   80
    WlrLayershell.margins.right: 10

    anchors.top:   true
    anchors.right: true

    color: "transparent"
    implicitWidth:  toasts.length > 0 ? 320 : 1
    implicitHeight: toasts.length > 0 ? listCol.implicitHeight + 16 : 1

    // List of active toasts; each entry { id, kind, text, born }
    property var toasts: []
    property int _nextId: 1
    property string _homeDir:   ""
    property string _clientLog: ""

    // Toast lifetime in ms
    readonly property int toastLifetime: 7000

    function _push(kind, text) {
        var t = { id: _nextId++, kind: kind, text: text, born: Date.now() }
        var arr = toasts.slice()
        arr.unshift(t)
        if (arr.length > 5) arr = arr.slice(0, 5)
        toasts = arr
    }
    function _pruneOld() {
        var cutoff = Date.now() - toastLifetime
        var arr = toasts.filter(function(t) { return t.born >= cutoff })
        if (arr.length !== toasts.length) toasts = arr
    }

    Timer { interval: 1000; running: true; repeat: true; onTriggered: root._pruneOld() }

    // ── Find client.txt and poll it for events ────────────────
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
                    sinceProc.running = true
                }
            }
        }
    }

    // Track our last-read byte offset so we only get NEW lines each poll.
    property int _bytesSeen: 0
    Process {
        id: sinceProc   // initial: just record current file size
        command: ["sh", "-c",
            "stat -c %s \"" + root._clientLog + "\" 2>/dev/null || echo 0"]
        stdout: StdioCollector { id: sinceOut }
        onRunningChanged: {
            if (!running) {
                var n = parseInt(sinceOut.text.trim(), 10)
                if (!isNaN(n) && n > 0) root._bytesSeen = n
            }
        }
    }
    Timer {
        interval: 4000
        running: root._clientLog !== ""
        repeat: true
        onTriggered: { if (!pollProc.running) pollProc.running = true }
    }
    Process {
        id: pollProc
        // Read whatever bytes are new since last poll
        command: ["sh", "-c",
            "LOG=\"" + root._clientLog + "\"; " +
            "SZ=$(stat -c %s \"$LOG\" 2>/dev/null || echo 0); " +
            "PREV=" + root._bytesSeen + "; " +
            "if [ \"$SZ\" -gt \"$PREV\" ]; then " +
            "  tail -c $((SZ-PREV)) \"$LOG\" 2>/dev/null; " +
            "  echo --SIZE-- $SZ; " +
            "fi"]
        stdout: StdioCollector { id: pollOut }
        onRunningChanged: {
            if (!running) {
                var text = pollOut.text
                if (!text) return
                var lines = text.split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var ln = lines[i]
                    if (ln.indexOf("--SIZE-- ") === 0) {
                        var n = parseInt(ln.substring(9).trim(), 10)
                        if (!isNaN(n)) root._bytesSeen = n
                        continue
                    }
                    root._matchLine(ln)
                }
            }
        }
    }

    function _matchLine(ln) {
        // Level-up
        var m = ln.match(/is now level (\d+)/)
        if (m) { _push("level", "Level up: " + m[1]); return }
        m = ln.match(/has reached level (\d+)/)
        if (m) { _push("level", "Level up: " + m[1]); return }
        // Trade whisper
        m = ln.match(/@From ([^:]+): (.{0,160})/)
        if (m) {
            var who  = m[1].replace(/^<.*?>\s*/, "")
            var text = m[2]
            _push("whisper", "Whisper " + who + ": " + text)
            return
        }
        // Boss / player kill
        m = ln.match(/: ([^ ]+ has been slain (?:by [^.]+)?)\.?/)
        if (m) { _push("kill", m[1]); return }
        // AFK
        if (ln.indexOf("AFK mode is now ON")  !== -1) { _push("afk", "AFK ON");  return }
        if (ln.indexOf("AFK mode is now OFF") !== -1) { _push("afk", "AFK OFF"); return }
    }

    // ── Visual stack of toasts ────────────────────────────────
    ColumnLayout {
        id: listCol
        anchors { right: parent.right; top: parent.top; margins: 8 }
        width: 304
        spacing: 4

        Repeater {
            model: root.toasts
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                radius: 4
                color: "#1a1d24"
                border.color: modelData.kind === "level"   ? "#d4a843"
                            : modelData.kind === "whisper" ? "#7adde0"
                            : modelData.kind === "kill"    ? "#e08545"
                            : modelData.kind === "afk"     ? "#8a8a8a"
                                                           : "#5a6a80"
                border.width: 1
                opacity: 0.96

                RowLayout {
                    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                    spacing: 6
                    Text {
                        text: modelData.kind === "level"   ? "⬆"
                            : modelData.kind === "whisper" ? "💬"
                            : modelData.kind === "kill"    ? "💀"
                            : modelData.kind === "afk"     ? "💤"
                                                           : "•"
                        font.pixelSize: 12
                    }
                    Text {
                        text: modelData.text
                        color: "#dde8f0"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "✕"; color: "#5a5a5a"; font.pixelSize: 10
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var arr = root.toasts.filter(function(t) { return t.id !== modelData.id })
                                root.toasts = arr
                            }
                        }
                    }
                }
            }
        }
    }
}

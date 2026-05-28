.pragma library

// Lailloken/Exile-UI markup → Qt RichText HTML.
// Shared by ActTracker.qml and RewardChecklist.qml.
//   (color:red), (color:7adda0)   inline color
//   (img:skill), (img:quest)      inline icon
//   (hint) ...                    indented hint block
//   (quest_text:Quest Name)       italic quest reference
//   areaidg1_1                    zone-id reference (resolved to name)
//   foo ;; comment                fallback label after ;; is dropped
//   alt_a || alt_b                bullet-separated alternatives

var namedColors = {
    "red":     "#e07070",
    "green":   "#7adda0",
    "lime":    "#9ade6a",
    "blue":    "#7adde0",
    "yellow":  "#e0d060",
    "orange":  "#e0a040",
    "purple":  "#c080e0",
    "white":   "#dde8f0",
    "gray":    "#9aa8b8",
    "grey":    "#9aa8b8"
}

var imgIcons = {
    "skill":      "💎",
    "support":    "💠",
    "spirit":     "✨",
    "quest":      "📜",
    "quest_2":    "📜",
    "quest_3":    "📜",
    "rune":       "🔹",
    "artificer":  "🔧",
    "ring":       "💍",
    "exa":        "🟡",
    "waypoint":   "🌀",
    "checkpoint": "🚩",
    "trial":      "⚔",
    "boss":       "💀",
    "in-out":     "↔",
    "in-out2":    "↔",
    "portal":     "🚪",
    "logout":     "🚪",
    "vendor":     "🛒",
    "stash":      "📦"
}

function esc(s) {
    return s.replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
}

function resolveAreaId(zones, id) {
    if (zones) {
        for (var k in zones) {
            if (zones[k].id === id) return zones[k].name
        }
    }
    return id
}

// Style already-escaped plain text: keyword accents, ||.
function stylePlain(escaped) {
    var t = escaped
    t = t.replace(/\b(kill)\b/gi,  '<font color="#e07070"><b>$1</b></font>')
    t = t.replace(/\b(enter)\b/gi, '<font color="#7adda0"><b>$1</b></font>')
    t = t.replace(/\b(optional|leaguestart|twinkrun)\s*:/gi,
                  '<font color="#7a8aaa"><b>$1:</b></font>')
    t = t.replace(/\s*\|\|\s*/g, ' <font color="#5a6a80">·</font> ')
    t = t.replace(/_/g, " ")
    t = t.replace(/\n/g, "<br>")
    return t
}

// Single-pass converter. `zones` is levelingData.zones (or null).
function render(text, zones) {
    if (!text) return ""

    // Strip "<cmd> ;; <comment>" fallback labels per line — the bit after
    // ;; duplicates whatever the line's areaid<id> already resolves to.
    var src = text.split("\n").map(function(line) {
        var i = line.indexOf(";;")
        return i === -1 ? line : line.substring(0, i).replace(/\s+$/, "")
    }).join("\n")

    var html = ""
    var openFonts = 0
    var re = /\(([a-zA-Z_][a-zA-Z0-9_-]*)(?::([^)]*))?\)|areaid([a-zA-Z0-9_]+)/g
    var last = 0
    var m
    while ((m = re.exec(src)) !== null) {
        html += stylePlain(esc(src.substring(last, m.index)))
        last = re.lastIndex

        if (m[3] !== undefined) {
            html += '<font color="#8ab4d4"><b>' +
                    esc(resolveAreaId(zones, m[3])) + '</b></font>'
            continue
        }

        var tag = m[1].toLowerCase()
        var val = m[2] || ""
        if (tag === "color") {
            var c = val.toLowerCase()
            var hex = namedColors[c] ||
                      (/^[0-9a-f]{3,8}$/i.test(c) ? "#" + c : null)
            if (hex) { html += '<font color="' + hex + '">'; openFonts++ }
        } else if (tag === "hint") {
            html += '<br>&nbsp;&nbsp;<font color="#7a8aaa">→ '
            openFonts++
        } else if (tag === "img") {
            html += (imgIcons[val.toLowerCase()] || "•") + " "
        } else if (tag === "quest_text" && val) {
            html += '<font color="#c0b090"><i>' + esc(val) + '</i></font>'
        }
        // unknown / no-op tags silently consumed
    }
    html += stylePlain(esc(src.substring(last)))
    while (openFonts-- > 0) html += '</font>'
    return html
}

// Returns the dominant reward icon for a step, for checklist grouping.
// One of: "skill" | "spirit" | "support" | "quest" | "" (none).
function rewardKind(text) {
    if (!text) return ""
    if (/\(img:spirit\)/i.test(text))  return "spirit"
    if (/\(img:skill\)/i.test(text))   return "skill"
    if (/\(img:support\)/i.test(text)) return "support"
    if (/\(img:quest/i.test(text) || /\(quest:/i.test(text)) return "quest"
    return ""
}

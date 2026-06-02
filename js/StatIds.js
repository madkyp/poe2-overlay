.pragma library

var USER_AGENT = "OAuth poe2-qs-overlay/1.0 (contact: mikelarnaiz0@gmail.com)"
var _cache = null

function fetchStats(callback) {
    if (_cache) { callback(null, _cache); return }
    var xhr = new XMLHttpRequest()
    xhr.open("GET", "https://www.pathofexile.com/api/trade2/data/stats", true)
    xhr.setRequestHeader("User-Agent", USER_AGENT)
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return
        if (xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText)
                var flat = []
                var groups = data.result || []
                for (var i = 0; i < groups.length; i++) {
                    var ents = groups[i].entries || []
                    for (var j = 0; j < ents.length; j++) flat.push(ents[j])
                }
                _cache = flat
                callback(null, flat)
            } catch(e) { callback("Parse error: " + e, null) }
        } else {
            callback("HTTP " + xhr.status, null)
        }
    }
    xhr.send()
}

// Suffixes the in-game clipboard appends per mod source — none of these
// exist in the trade API stat templates, so they have to come off before
// matching or the mod is silently dropped.
var _SUFFIX_RE = /\s*\((?:implicit|crafted|rune|enchant|enchanted|fractured|desecrated|corrupted|scourge|veiled)\)\s*$/i

function _stripSuffix(text) { return text.replace(_SUFFIX_RE, "") }

function _norm(text) {
    // Drop the per-source suffix, replace actual numbers (consuming any
    // leading +/-), then strip remaining + signs before placeholders so
    // "+# to maximum..." matches "# to maximum...".
    return _stripSuffix(text)
               .replace(/[+\-]?\d+(\.\d+)?/g, "#")
               .replace(/\+#/g, "#")
               .replace(/\s+/g, " ").trim().toLowerCase()
}

// Type search priority — explicit first, then special mod types.
// "rune" added in 0.5: rune-granted mods that don't exist as explicit
// (Unique Power Runes etc.) would otherwise be dropped.
var TYPE_PRIORITY = ["explicit", "desecrated", "fractured", "implicit", "rune", "enchant"]

// Returns { id, min } or null if no match found
function mapMod(modText) {
    if (!_cache) return null
    var normalized = _norm(modText)
    var nums = modText.match(/\d+(\.\d+)?/g)

    var best = null
    var bestPriority = TYPE_PRIORITY.length

    for (var i = 0; i < _cache.length; i++) {
        var s = _cache[i]
        var pri = TYPE_PRIORITY.indexOf(s.type)
        if (pri === -1) continue
        if (_norm(s.text) !== normalized) continue
        if (pri < bestPriority) {
            best = s
            bestPriority = pri
        }
    }

    if (!best) return null
    var result = { id: best.id }
    if (nums && nums.length > 0) {
        result.min = Math.floor(parseFloat(nums[0]))
    }
    return result
}

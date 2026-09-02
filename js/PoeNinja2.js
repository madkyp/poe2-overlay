.pragma library

var API_URL   = "https://poe.ninja/poe2/api/economy/exchange/current/overview"
var IMAGE_CDN = "https://web.poecdn.com"

function fetchAll(league, type, callback) {
    var url = API_URL + "?league=" + encodeURIComponent(league || "Runes of Aldur")
                      + "&type="   + encodeURIComponent(type   || "Currency")
    var xhr = new XMLHttpRequest()
    xhr.open("GET", url, true)
    xhr.setRequestHeader("Accept", "application/json")
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return
        if (xhr.status === 200) {
            try {
                var d = JSON.parse(xhr.responseText)
                var entries = _parse(d)
                if (entries.length > 0) callback(null, entries)
                else callback("no_data", null)
            } catch(e) {
                callback("Parse error: " + e, null)
            }
        } else if (xhr.status === 429) {
            callback("Rate limited", null)
        } else {
            callback("poe.ninja HTTP " + xhr.status, null)
        }
    }
    xhr.send()
}

function _parse(d) {
    var core  = d.core  || {}
    var rates = core.rates || {}

    // core.rates["chaos"] = number of chaos per 1 divine
    var chaosPerDiv = rates["chaos"] || 0

    var lines = d.lines || []

    // Fallback: derive chaosPerDiv from chaos line
    if (!(chaosPerDiv > 0)) {
        for (var j = 0; j < lines.length; j++) {
            var cl = lines[j]
            if (cl.id === "chaos") {
                // maxVolumeRate on the chaos line = chaos per divine
                if (cl.maxVolumeRate > 0) chaosPerDiv = cl.maxVolumeRate
                else if (cl.primaryValue > 0) chaosPerDiv = 1 / cl.primaryValue
                break
            }
        }
    }
    if (!(chaosPerDiv > 0)) return []

    // id → { name, image } for display metadata
    var itemMap = {}
    var allItems = d.items || []
    for (var k = 0; k < allItems.length; k++) {
        var itm = allItems[k]
        if (itm.id) itemMap[itm.id] = itm
    }

    function absIcon(path) {
        if (!path) return ""
        return (path.charAt(0) === "/") ? IMAGE_CDN + path : path
    }

    var entries = []
    for (var i = 0; i < lines.length; i++) {
        var ln = lines[i]
        if (!ln.id || !(ln.primaryValue > 0)) continue
        // primaryValue = divines per 1 unit of this currency
        // chaosValue   = chaos per 1 unit
        var primaryValue = ln.primaryValue
        var chaosValue   = chaosPerDiv * primaryValue
        if (chaosValue < 0.001) continue

        var meta     = itemMap[ln.id] || {}
        var volMeta  = itemMap[ln.maxVolumeCurrency] || {}
        var spark    = ln.sparkline || {}

        entries.push({
            id:           ln.id,
            name:         meta.name || ln.id,
            icon:         absIcon(meta.image),
            primaryValue: primaryValue,
            chaosValue:   chaosValue,
            sparkData:    spark.data || [],
            sparkChange:  spark.totalChange || 0,
            volume:       ln.volumePrimaryValue || 0,
            volumeIcon:   absIcon(volMeta.image)
        })
    }

    entries.sort(function(a, b) { return b.primaryValue - a.primaryValue })
    return entries
}

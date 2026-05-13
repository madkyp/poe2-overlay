.pragma library

var EXCHANGE_BASE = "https://www.pathofexile.com/api/trade2/exchange/"
var USER_AGENT = "OAuth poe2-qs-overlay/1.0 (contact: mikelarnaiz0@gmail.com)"

// All tradeable PoE2 currencies, ordered by expected value (high→low)
var CURRENCIES = [
    { id: "mirror",              name: "Mirror of Kalandra",     icon: "mirror.png" },
    { id: "hinekoras-lock",      name: "Hinekora's Lock",        icon: "hinekoras-lock.png" },
    { id: "fracturing-orb",      name: "Fracturing Orb",         icon: "fracturing-orb.png" },
    { id: "divine",              name: "Divine Orb",             icon: "divine.png" },
    { id: "perfect-exalted-orb", name: "Perfect Exalted Orb",   icon: "exalted.png" },
    { id: "greater-exalted-orb", name: "Greater Exalted Orb",   icon: "exalted.png" },
    { id: "exalted",             name: "Exalted Orb",            icon: "exalted.png" },
    { id: "annul",               name: "Orb of Annulment",       icon: "annul.png" },
    { id: "vaal",                name: "Vaal Orb",               icon: "vaal.png" },
    { id: "perfect-regal-orb",   name: "Perfect Regal Orb",     icon: "regal.png" },
    { id: "greater-regal-orb",   name: "Greater Regal Orb",     icon: "regal.png" },
    { id: "regal",               name: "Regal Orb",              icon: "regal.png" },
    { id: "perfect-chaos-orb",   name: "Perfect Chaos Orb",     icon: "chaos.png" },
    { id: "greater-chaos-orb",   name: "Greater Chaos Orb",     icon: "chaos.png" },
    { id: "gcp",                 name: "Gemcutter's Prism",      icon: "gcp.png" },
    { id: "artificers",          name: "Artificer's Orb",        icon: "artificers.png" },
    { id: "perfect-jewellers-orb", name: "Perfect Jeweller's Orb", icon: "jewellers-perfect.png" },
    { id: "greater-jewellers-orb", name: "Greater Jeweller's Orb", icon: "jewellers-greater.png" },
    { id: "alch",                name: "Orb of Alchemy",         icon: "alch.png" },
]

// Fetches rates progressively. Calls onProgress({ id, name, icon, chaosValue }) for each result.
// Calls onDone(err) when all done.
// Fetches a single currency. callback(err, item|null)
function fetchOne(curr, league, callback) {
    _fetchRate("chaos", curr.id, league, function(err, rate) {
        if (err) { callback(err, null); return }
        callback(null, rate > 0 ? { id: curr.id, name: curr.name, icon: curr.icon, chaosValue: rate } : null)
    })
}

function _fetchRate(have, want, league, callback) {
    var xhr = new XMLHttpRequest()
    xhr.open("POST", EXCHANGE_BASE + encodeURIComponent(league), true)
    xhr.setRequestHeader("Content-Type", "application/json")
    xhr.setRequestHeader("User-Agent", USER_AGENT)

    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return
        if (xhr.status === 200) {
            try {
                var d = JSON.parse(xhr.responseText)
                if (d.error) { callback(d.error.message, 0); return }
                callback(null, _median(d.result || {}))
            } catch(e) { callback("Parse: " + e, 0) }
        } else if (xhr.status === 429) {
            callback("Rate limited", 0)
        } else {
            callback("HTTP " + xhr.status + ": " + xhr.responseText.substring(0, 120), 0)
        }
    }
    xhr.send(JSON.stringify({
        exchange: { status: { option: "any" }, have: [have], want: [want] }
    }))
}

function _median(result) {
    var rates = []
    var keys = Object.keys(result)
    for (var i = 0; i < keys.length; i++) {
        var entry = result[keys[i]]
        if (!entry || !entry.listing) continue
        var offers = entry.listing.offers || []
        for (var j = 0; j < offers.length; j++) {
            var ex = offers[j].exchange || {}
            var itm = offers[j].item || {}
            if (ex.amount > 0 && itm.amount > 0) rates.push(ex.amount / itm.amount)
        }
    }
    if (!rates.length) return 0
    rates.sort(function(a,b){ return a-b })
    return rates[Math.floor(rates.length * 0.2)]
}

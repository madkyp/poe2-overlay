.pragma library

var EXCHANGE_BASE = "https://www.pathofexile.com/api/trade2/exchange/"
var USER_AGENT = "OAuth poe2-qs-overlay/1.0 (contact: mikelarnaiz0@gmail.com)"

// Valid PoE2 exchange currency IDs (from /api/trade2/data/static)
var CURRENCY_IDS = {
    "Divine Orb":         "divine",
    "Exalted Orb":        "exalted",
    "Orb of Annulment":   "annul",
    "Vaal Orb":           "vaal",
    "Greater Chaos Orb":  "greater-chaos-orb",
    "Perfect Chaos Orb":  "perfect-chaos-orb"
}

var TRACKED = ["Divine Orb", "Exalted Orb", "Orb of Annulment", "Vaal Orb"]

// Fetches exchange rates sequentially to avoid rate limiting.
// callback(err, rates) where rates = { "Divine Orb": { chaosValue: N, name: "..." }, ... }
function fetchCurrencyRates(league, callback) {
    var results = {}
    var pending = TRACKED.slice()
    var lastError = ""

    function fetchNext() {
        if (pending.length === 0) {
            callback(lastError || null, results)
            return
        }
        var currName = pending.shift()
        var haveId = CURRENCY_IDS[currName]
        if (!haveId) { fetchNext(); return }

        // Direction: "I have chaos, want <currName>" → finds SELLERS of currName
        // offer: exchange = chaos they accept, item = currName they give
        // rate = exchange.amount / item.amount = chaos per 1 unit of currName
        _fetchRate("chaos", haveId, league, function(err, rate) {
            if (err) lastError = err
            if (rate > 0) {
                results[currName] = { name: currName, chaosValue: rate }
            }
            fetchNext()
        })
    }

    fetchNext()
}

function _fetchRate(have, want, league, callback) {
    var xhr = new XMLHttpRequest()
    xhr.open("POST", EXCHANGE_BASE + encodeURIComponent(league), true)
    xhr.setRequestHeader("Content-Type", "application/json")
    xhr.setRequestHeader("User-Agent", USER_AGENT)

    var query = JSON.stringify({
        exchange: {
            status: { option: "any" },
            have: [have],
            want: [want]
        }
    })

    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return
        if (xhr.status === 200) {
            try {
                var d = JSON.parse(xhr.responseText)
                if (d.error) { callback("API error: " + d.error.message, 0); return }
                var rate = _medianRate(d.result || {})
                callback(null, rate)
            } catch (e) {
                callback("Parse error: " + e, 0)
            }
        } else if (xhr.status === 429) {
            callback("Rate limited (espera unos segundos)", 0)
        } else {
            callback("HTTP " + xhr.status, 0)
        }
    }
    xhr.send(query)
}

// Computes median chaos-per-unit from result dict.
// offer.exchange = currency they accept (the "have" side)
// offer.item     = chaos they give (the "want" side)
// rate = item.amount / exchange.amount = chaos per 1 unit of have currency
function _medianRate(result) {
    var rates = []
    var keys = Object.keys(result)
    for (var i = 0; i < keys.length; i++) {
        var entry = result[keys[i]]
        if (!entry || !entry.listing) continue
        var offers = entry.listing.offers || []
        for (var j = 0; j < offers.length; j++) {
            var ex  = offers[j].exchange || {}
            var itm = offers[j].item || {}
            if (ex.amount > 0 && itm.amount > 0) {
                rates.push(ex.amount / itm.amount)
            }
        }
    }
    if (rates.length === 0) return 0
    rates.sort(function(a, b) { return a - b })
    return rates[Math.floor(rates.length * 0.2)]
}

function lookupCurrencyPrice(currencyName, rates) {
    var lower = currencyName.toLowerCase()
    for (var key in rates) {
        if (key.toLowerCase().indexOf(lower) !== -1 ||
            lower.indexOf(key.toLowerCase()) !== -1) {
            return rates[key]
        }
    }
    return null
}

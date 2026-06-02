.pragma library

var TRADE_BASE = "https://www.pathofexile.com/api/trade2/"
var USER_AGENT = "OAuth poe2-qs-overlay/1.0 (contact: mikelarnaiz0@gmail.com)"

// Mod weight table — higher = more impact on item price
var MOD_WEIGHTS = {
    // Weapons — offensive
    "increased Physical Damage":                    10,
    "Adds # to # Physical Damage":                   9,
    "increased Attack Speed":                         8,
    "increased Critical Hit Chance":                  7,
    "increased Critical Hit Multiplier":              7,
    "increased Elemental Damage with Attack Skills":  8,
    "increased Spell Damage":                         9,
    "increased Spell Physical Damage":                9,
    "increased Cast Speed":                           7,
    "Level of all":                                   8,
    // Defence
    "to maximum Life":                               10,
    "to maximum Energy Shield":                       9,
    "increased maximum Life":                         8,
    "increased Energy Shield":                        7,
    "increased Armour":                               5,
    "increased Evasion Rating":                       5,
    // Resistances
    "to all Elemental Resistances":                   9,
    "to Fire Resistance":                             4,
    "to Cold Resistance":                             4,
    "to Lightning Resistance":                        4,
    // Utility
    "increased Movement Speed":                       7,
    "reduced Skill Cooldown":                         7,
    "reduced Mana Cost":                              5,
    "to Mana":                                        4,
    "Mana Regeneration Rate":                         3,
    "to Strength":                                    3,
    "to Intelligence":                                3,
    "to Dexterity":                                   3
}

function getModWeight(modText) {
    var normalized = modText.replace(/[+\-]?\d+(\.\d+)?/g, "#")
    for (var key in MOD_WEIGHTS) {
        if (normalized.indexOf(key) !== -1) return MOD_WEIGHTS[key]
    }
    return 1
}

function _getModWeight(modText) {
    var normalized = modText.replace(/[+\-]?\d+(\.\d+)?/g, "#")
    for (var key in MOD_WEIGHTS) {
        if (normalized.indexOf(key) !== -1) return MOD_WEIGHTS[key]
    }
    return 1
}

function _sortModsByWeight(mods) {
    var weighted = []
    for (var i = 0; i < mods.length; i++) {
        weighted.push({ text: mods[i], weight: _getModWeight(mods[i]) })
    }
    weighted.sort(function(a, b) { return b.weight - a.weight })
    var result = []
    for (var j = 0; j < weighted.length; j++) result.push(weighted[j].text)
    return result
}

// Returns: "high" | "medium" | "low" | "no data"
function getConfidence(modsUsed, totalResults) {
    if (totalResults < 3)  return "no data"
    if (modsUsed >= 3)     return "high"
    if (modsUsed >= 2)     return "medium"
    return "low"
}

// statFilters: array of { id, value: { min } } from StatIds.mapMod()
// Main entry point
function searchItem(item, statFilters, league, poesessid, callback) {
    if (item.rarity === "Currency") {
        callback(null, { usePoeNinja: true })
        return
    }

    if (item.rarity === "Unique") {
        _searchUniqueWithFallback(item, league, poesessid, callback)
    } else {
        _searchRareWithFallback(item, statFilters || [], league, poesessid, callback)
    }
}

// Try the precise unique-name query first; on "Unknown item name" (common
// during the first hours of a patch — GGG's items dictionary lags the
// game), fall back to a base+rarity=unique search so the user at least
// gets every unique of that base type to compare against.
function _searchUniqueWithFallback(item, league, poesessid, callback) {
    _postSearch(_buildUniqueQuery(item), league, poesessid, function(err, data) {
        if (err) { callback(err, null); return }
        if (!data.error && data.id) {
            _fetchListings(data.id, (data.result || []).slice(0, 6),
                           league, poesessid, 0, callback)
            return
        }
        // Fallback path
        _postSearch(_buildUniqueFallbackQuery(item), league, poesessid, function(err2, data2) {
            if (err2) { callback(err2, null); return }
            if (data2.error || !data2.id) {
                var msg = (data2.error && data2.error.message) || "Unique no encontrado"
                callback(msg, null); return
            }
            _fetchListings(data2.id, (data2.result || []).slice(0, 6),
                           league, poesessid, 0, callback)
        })
    })
}

// Progressive fallback: try up to 6 mods, drop one at a time only when 0 results.
// 600ms delay between attempts + auto-retry on 429 to avoid rate limits.
function _searchRareWithFallback(item, statFilters, league, poesessid, callback) {
    var attempt = statFilters.length

    function tryNext() {
        var filtersToUse = statFilters.slice(0, attempt)
        var q = _buildRareQuery(item, filtersToUse)
        _postSearch(q, league, poesessid, function(err, data) {
            if (err) { callback(err, null); return }
            var total = (data.result || []).length
            if (total > 0 || attempt <= 0) {
                _fetchListings(data.id, (data.result || []).slice(0, 6),
                               league, poesessid, filtersToUse.length, callback)
            } else {
                attempt--
                setTimeout(tryNext, 1000)
            }
        })
    }

    tryNext()
}

var BUYOUT_FILTER = {
    trade_filters: {
        filters: {
            sale_type: { option: "priced" }
        }
    }
}

function _buildUniqueQuery(item) {
    return {
        query: {
            status: { option: "securable" },
            name: item.name,
            type: item.baseType,
            stats: [{ type: "and", filters: [] }],
            filters: BUYOUT_FILTER
        },
        sort: { price: "asc" }
    }
}

// Fallback for uniques whose name isn't in the trade2 dictionary yet.
// Drops the name and forces rarity=unique on the base, so the user gets
// every unique of that base type instead of a broken empty page.
function _buildUniqueFallbackQuery(item) {
    return {
        query: {
            status: { option: "securable" },
            type: item.baseType,
            filters: {
                type_filters: { filters: { rarity: { option: "unique" } } },
                trade_filters: { filters: { sale_type: { option: "priced" } } }
            }
        },
        sort: { price: "asc" }
    }
}

function _buildRareQuery(item, statFilters) {
    return {
        query: {
            status: { option: "securable" },
            type: item.baseType,
            stats: [{ type: "and", filters: statFilters || [] }],
            filters: BUYOUT_FILTER
        },
        sort: { price: "asc" }
    }
}

function _postSearch(query, league, poesessid, callback, _retry) {
    var retry = _retry || 0
    var xhr = new XMLHttpRequest()
    var url = TRADE_BASE + "search/" + encodeURIComponent(league)

    xhr.open("POST", url, true)
    xhr.setRequestHeader("Content-Type", "application/json")
    xhr.setRequestHeader("User-Agent", USER_AGENT)
    if (poesessid) xhr.setRequestHeader("Cookie", "POESESSID=" + poesessid)

    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return
        if (xhr.status === 200) {
            try { callback(null, JSON.parse(xhr.responseText)) }
            catch (e) { callback("Parse error: " + e, null) }
        } else if (xhr.status === 429) {
            if (retry < 2) {
                setTimeout(function() {
                    _postSearch(query, league, poesessid, callback, retry + 1)
                }, 2000 + retry * 1000)
            } else {
                callback("Rate limited — espera unos segundos", null)
            }
        } else {
            callback("HTTP " + xhr.status, null)
        }
    }
    xhr.send(JSON.stringify(query))
}

function _fetchListings(queryId, ids, league, poesessid, modsUsed, callback) {
    if (!ids || ids.length === 0) {
        callback(null, { listings: [], total: 0, modsUsed: modsUsed, searchId: queryId, league: league })
        return
    }

    var xhr = new XMLHttpRequest()
    var url = TRADE_BASE + "fetch/" + ids.join(",") + "?query=" + queryId

    xhr.open("GET", url, true)
    xhr.setRequestHeader("User-Agent", USER_AGENT)
    if (poesessid) xhr.setRequestHeader("Cookie", "POESESSID=" + poesessid)

    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return
        if (xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText)
                callback(null, {
                    listings: _parseListings(data.result || []),
                    total: ids.length,
                    modsUsed: modsUsed,
                    searchId: queryId,
                    league: league
                })
            } catch (e) {
                callback("Parse error: " + e, null)
            }
        } else {
            callback("HTTP " + xhr.status, null)
        }
    }
    xhr.send()
}

function _parseListings(results) {
    var out = []
    for (var i = 0; i < results.length; i++) {
        var r = results[i]
        var price = r.listing && r.listing.price
        if (!price) continue
        out.push({
            price: price.amount + " " + price.currency,
            account: r.listing ? r.listing.account.name : "?"
        })
    }
    return out
}

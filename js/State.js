.pragma library

// ── Economy panel open/close ─────────────────────────────────
var _economyOpen = false
var _openListeners = []

function setEconomyOpen(v) {
    _economyOpen = (v === true)
    for (var i = 0; i < _openListeners.length; i++) _openListeners[i](_economyOpen)
}
function isEconomyOpen() { return _economyOpen }
function addEconomyListener(fn) { _openListeners.push(fn) }

// ── Currency rate cache ──────────────────────────────────────
// entries: Array of { id, name, icon, chaosValue }
var _entries = []
var _fetching = false
var _fetchErr = ""
var _rateListeners = []

function setEntries(entries, err) {
    _entries = entries || []
    _fetchErr = err || ""
    for (var i = 0; i < _rateListeners.length; i++) _rateListeners[i](_entries, _fetchErr)
}
function setFetching(v) { _fetching = v }
function getEntries() { return _entries }
function isFetching() { return _fetching }
function getError() { return _fetchErr }
function addRateListener(fn) { _rateListeners.push(fn) }

// ── Current league ───────────────────────────────────────────
var _league = "Fate of the Vaal"
var _leagueListeners = []

function setLeague(name) {
    _league = name
    for (var i = 0; i < _leagueListeners.length; i++) _leagueListeners[i](_league)
}
function getLeague() { return _league }
function addLeagueListener(fn) { _leagueListeners.push(fn) }

// Lookup by name (for CurrencyTracker)
function getRate(name) {
    for (var i = 0; i < _entries.length; i++) {
        if (_entries[i].name === name) return _entries[i]
    }
    return null
}

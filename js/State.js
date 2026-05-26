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

// ── Builds window open/close ─────────────────────────────────
var _buildsOpen = false
var _buildsListeners = []

function setBuildsOpen(v) {
    _buildsOpen = (v === true)
    for (var i = 0; i < _buildsListeners.length; i++) _buildsListeners[i](_buildsOpen)
}
function isBuildsOpen() { return _buildsOpen }
function addBuildsOpenListener(fn) { _buildsListeners.push(fn) }

// ── Standalone passive tree viewer open/close ────────────────
var _passiveStandaloneOpen = false
var _passiveStandaloneListeners = []

function setPassiveStandaloneOpen(v) {
    _passiveStandaloneOpen = (v === true)
    for (var i = 0; i < _passiveStandaloneListeners.length; i++) _passiveStandaloneListeners[i](_passiveStandaloneOpen)
}
function isPassiveStandaloneOpen() { return _passiveStandaloneOpen }
function addPassiveStandaloneListener(fn) { _passiveStandaloneListeners.push(fn) }

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

// ── Widget visibility ────────────────────────────────────────
var _currencyVisible = true
var _sessionVisible  = true
var _cvListeners = []
var _svListeners = []

function setCurrencyVisible(v) { _currencyVisible = (v === true); for (var i=0;i<_cvListeners.length;i++) _cvListeners[i](_currencyVisible) }
function isCurrencyVisible()   { return _currencyVisible }
function addCurrencyVisibleListener(fn) { _cvListeners.push(fn) }

function setSessionVisible(v)  { _sessionVisible  = (v === true); for (var i=0;i<_svListeners.length;i++) _svListeners[i](_sessionVisible) }
function isSessionVisible()    { return _sessionVisible }
function addSessionVisibleListener(fn) { _svListeners.push(fn) }

// Stopwatch widget visibility
var _stopwatchVisible = true
var _swListeners      = []
function setStopwatchVisible(v) {
    _stopwatchVisible = (v === true)
    for (var i = 0; i < _swListeners.length; i++) _swListeners[i](_stopwatchVisible)
}
function isStopwatchVisible() { return _stopwatchVisible }
function addStopwatchVisibleListener(fn) { _swListeners.push(fn) }

// Lookup by name (for CurrencyTracker)
function getRate(name) {
    for (var i = 0; i < _entries.length; i++) {
        if (_entries[i].name === name) return _entries[i]
    }
    return null
}

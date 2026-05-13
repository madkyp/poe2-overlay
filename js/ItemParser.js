.pragma library

// Supports English and Spanish PoE2 item clipboard text.

var RARITY_EN = {
    "Normal":  "Normal",
    "Magic":   "Magic",
    "Magia":   "Magic",
    "Rare":    "Rare",
    "Raro":    "Rare",
    "Rara":    "Rare",
    "Unique":  "Unique",
    "Único":   "Unique",
    "Única":   "Unique",
    "Currency":"Currency",
    "Moneda":  "Currency",
    "Gem":     "Gem",
    "Gema":    "Gem"
}

// Spanish → English for currency name lookup against poe.ninja cache
var ES_TO_EN = {
    // Orbs
    "Orbe divino":                   "Divine Orb",
    "Orbe exaltado":                 "Exalted Orb",
    "Orbe de anulación":             "Orb of Annulment",
    "Orbe vaal":                     "Vaal Orb",
    "Orbe de alteración":            "Orb of Alteration",
    "Orbe de alquimia":              "Orb of Alchemy",
    "Orbe del caos":                 "Chaos Orb",
    "Orbe de transmutación":         "Orb of Transmutation",
    "Orbe de aumento":               "Orb of Augmentation",
    "Orbe regal":                    "Regal Orb",
    "Orbe de duplicación":           "Mirror of Kalandra",
    "Orbe de fusión":                "Orb of Fusing",
    "Orbe de amalgama":              "Orb of Binding",
    "Orbe del artesano":             "Arcanist's Etcher",
    // Splinters / Fragments
    "Fragmento de pureza":           "Breach Splinter",
    // Uncut gems
    "Gema bruta de habilidad":       "Uncut Skill Gem",
    "Gema bruta de soporte":         "Uncut Support Gem",
    "Gema bruta espiritual":         "Uncut Spirit Gem",
    // Soul cores
    "Núcleo de alma de Azcapa":      "Soul Core of Azcapa",
    "Núcleo de alma de Zalatl":      "Soul Core of Zalatl",
    // Misc
    "Piedra de Portal":              "Portal Scroll",
    "Pergamino de sabiduría":        "Scroll of Wisdom",
    "Runa de hierro":                "Iron Rune"
}

function _isPoeHeader(line) {
    return line.startsWith("Item Class:") ||
           line.startsWith("Clase de objeto:")
}

function isPoeItem(text) {
    if (typeof text !== "string") return false
    var first = text.split("\n")[0].trim()
    return _isPoeHeader(first)
}

function parse(text) {
    if (!text) return null
    var firstLine = text.split("\n")[0].trim()
    if (!_isPoeHeader(firstLine)) return null

    var lines = text.split("\n")
    var sections = []
    var current = []

    for (var i = 0; i < lines.length; i++) {
        var line = lines[i].trim()
        if (line === "--------") {
            if (current.length > 0) sections.push(current.slice())
            current = []
        } else if (line !== "") {
            current.push(line)
        }
    }
    if (current.length > 0) sections.push(current)
    if (sections.length === 0) return null

    var header = sections[0]
    var result = {
        itemClass: "",
        rarity: "",
        name: "",
        baseType: "",
        itemLevel: 0,
        mods: [],
        corrupted: false,
        identified: true
    }

    for (var h = 0; h < header.length; h++) {
        var l = header[h]
        if (l.startsWith("Item Class: "))          result.itemClass = l.substring(12)
        else if (l.startsWith("Clase de objeto: ")) result.itemClass = l.substring(17)
        else if (l.startsWith("Rarity: "))         result.rarity = _normalizeRarity(l.substring(8))
        else if (l.startsWith("Rareza: "))         result.rarity = _normalizeRarity(l.substring(8))
        else if (result.name === "")               result.name = l
        else if (result.baseType === "")           result.baseType = l
    }

    if (result.rarity === "Normal" || result.rarity === "Magic" ||
        result.rarity === "Currency" || result.baseType === "") {
        result.baseType = result.name
    }

    var pastItemLevel = false
    for (var s = 1; s < sections.length; s++) {
        var sec = sections[s]
        var secHasIlvl = false

        for (var j = 0; j < sec.length; j++) {
            var ln = sec[j]
            if (ln.startsWith("Item Level: ") || ln.startsWith("Nivel de objeto: ")) {
                var lvlStr = ln.indexOf(": ") !== -1 ? ln.substring(ln.indexOf(": ") + 2) : "0"
                result.itemLevel = parseInt(lvlStr) || 0
                secHasIlvl = true
                pastItemLevel = true
            }
            if (ln === "Corrupted" || ln === "Corrompido") result.corrupted = true
            if (ln === "Unidentified" || ln === "Sin identificar") result.identified = false
        }

        if (pastItemLevel && !secHasIlvl) {
            for (var k = 0; k < sec.length; k++) {
                var ml = sec[k]
                if (!_isMetaLine(ml)) result.mods.push(ml)
            }
        }
    }

    return result
}

function _normalizeRarity(r) {
    var v = r ? r.trim() : ""
    return RARITY_EN[v] || v
}

function _isMetaLine(line) {
    return line === "Corrupted"       ||
           line === "Corrompido"      ||
           line === "Unidentified"    ||
           line === "Sin identificar" ||
           line === "Synthesised Item" ||
           line === "Fractured Item"  ||
           line === "Desecrated Item" ||
           line === "Objeto profanado"||
           line === "Mirrored"        ||
           line.startsWith("Note:")   ||
           line.startsWith("Nota:")   ||
           line.startsWith("Stack Size:")  ||
           line.startsWith("Tamaño de la pila:") ||
           line.startsWith("Stored Experience:")
}

// Maps Spanish item names to English for poe.ninja cache lookup.
// If no translation found, returns the original name (might work for non-translated items).
function toEnglishName(name) {
    return ES_TO_EN[name] || name
}

function normalizeModText(mod) {
    return mod.replace(/[+\-]?\d+(\.\d+)?/g, "#").trim()
}

function getDisplayName(item) {
    if (item.rarity === "Rare") return item.name + " (" + item.baseType + ")"
    return item.name
}

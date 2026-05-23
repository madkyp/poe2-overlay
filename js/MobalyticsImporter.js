.pragma library

// Mobalytics build guide importer.
//
// Fetches a Mobalytics build URL and extracts the build data from
// window.__PRELOADED_STATE__. Returns a simplified, app-friendly guide object.
//
// Usage:
//   MobalyticsImporter.importBuild(url, function(err, guide) { ... })
//
// Guide format:
//   {
//     id: string,         // mobalytics document ID
//     slug: string,
//     url: string,        // canonical URL
//     name: string,
//     author: string,
//     updatedAt: string,
//     coverImage: string,
//     pobCode: string,    // Path of Building code (if available)
//     sections: [
//       { kind: "text",        title, body }         // markdown-ish body
//       { kind: "strengths",   strengths: [], weaknesses: [] }
//       { kind: "equipment",   title, items: [{ slot, name, isUnique, iconUrl, mods: [] }] }
//       { kind: "skills",      title, groups: [{ main, supports: [] }] }
//     ]
//   }

// Validate the URL — actual fetching is done by the caller (via curl)
// since QML's XMLHttpRequest can't set User-Agent (Mobalytics returns 403).
function validateUrl(url) {
    if (!url) return "URL vacía"
    if (url.indexOf("mobalytics.gg") === -1) return "URL debe ser de mobalytics.gg"
    if (url.indexOf("/builds/") === -1) return "URL debe ser una build (.../builds/…)"
    return null
}

// Parse already-fetched HTML and return guide object via callback.
function parseHtml(html, sourceUrl, cb) {
    try {
        var guide = _parseHtml(html, sourceUrl)
        cb(null, guide)
    } catch (e) {
        cb("Error parseando: " + e.message, null)
    }
}

function _parseHtml(html, sourceUrl) {
    var marker = "window.__PRELOADED_STATE__="
    var start = html.indexOf(marker)
    if (start === -1) throw new Error("__PRELOADED_STATE__ no encontrado")
    var after = html.substring(start + marker.length)

    // Find matching closing brace
    var depth = 0, end = -1
    for (var i = 0; i < after.length; i++) {
        var c = after.charAt(i)
        if (c === "{") depth++
        else if (c === "}") {
            depth--
            if (depth === 0) { end = i + 1; break }
        }
    }
    if (end === -1) throw new Error("JSON malformado")

    var state = JSON.parse(after.substring(0, end))
    var queries = state.poe2State && state.poe2State.apollo &&
                  state.poe2State.apollo.graphqlV2 && state.poe2State.apollo.graphqlV2.queries
    if (!queries) throw new Error("estructura inesperada (queries)")

    // Find the query containing the build document
    var doc = null
    for (var q = 0; q < queries.length; q++) {
        var d = queries[q].state && queries[q].state.data
        if (!d) continue
        var arr = Array.isArray(d) ? d : [d]
        for (var a = 0; a < arr.length; a++) {
            var got = arr[a] && arr[a].game && arr[a].game.documents &&
                      arr[a].game.documents.userGeneratedDocumentBySlug
            if (got && got.data) { doc = got.data; break }
        }
        if (doc) break
    }
    if (!doc) throw new Error("documento no encontrado en el JSON")

    return _flattenBuild(doc, sourceUrl)
}

function _flattenBuild(doc, sourceUrl) {
    var d = doc.data || {}
    var content = doc.content || {}
    var variants = (d.buildVariants && d.buildVariants.values) || []
    var variant = variants[0] || {}

    var guide = {
        id: doc.id,
        slug: doc.slugifiedName,
        url: sourceUrl,
        name: d.name || doc.slugifiedName || "Sin título",
        author: (doc.author && (doc.author.displayName || doc.author.username || doc.author.name)) || "Anónimo",
        updatedAt: doc.updatedAt || doc.firstPublishedAt || "",
        coverImage: d.backgroundImage || "",
        pobCode: d.pobCode || "",
        sections: []
    }

    // Walk content in tree order starting from "root" — captures rich text
    // and equipment widget descriptions (which include item references)
    var rootBlock = content["root"] || content[0]
    if (rootBlock && rootBlock.data && rootBlock.data.childrenIds) {
        _walkChildren(rootBlock.data.childrenIds, content, guide.sections)
    } else {
        for (var k in content) _addBlock(content[k], guide.sections)
    }

    // Append the actual gear/skills from the first variant as structured sections
    var gear = _variantEquipment(variant)
    if (gear.length > 0) guide.sections.push({ kind: "equipment_real", title: "Gear (Variante 1)", items: gear })

    var skills = _variantSkills(variant)
    if (skills.length > 0) guide.sections.push({ kind: "skills_real", title: "Skill Gems (Variante 1)", groups: skills })

    return guide
}

function _variantEquipment(variant) {
    var items = []
    var eq = variant.equipment || {}
    var slotOrder = ["mainHand", "offHand", "helmet", "body", "gloves", "boots",
                     "belt", "amulet", "leftRing", "rightRing", "extraRing",
                     "flask1", "flask2", "charm1", "charm2", "charm3"]
    for (var i = 0; i < slotOrder.length; i++) {
        var key = slotOrder[i]
        var slot = eq[key]
        if (!slot) continue
        var c = slot.commonItem || slot
        if (!c || !c.name) continue
        var mods = []
        if (c.explicitDescriptions) {
            for (var m = 0; m < c.explicitDescriptions.length; m++) {
                if (c.explicitDescriptions[m].description) mods.push(c.explicitDescriptions[m].description)
            }
        }
        items.push({
            slot: _humanSlot(key),
            name: c.name,
            isUnique: !!c.isUnique,
            iconUrl: c.iconURL || "",
            mods: mods
        })
    }
    return items
}

function _variantSkills(variant) {
    var groups = []
    var gems = (variant.skillGems && variant.skillGems.gems) || []
    for (var i = 0; i < gems.length; i++) {
        var g = gems[i]
        var active = g.activeSkill || {}
        if (!active.name && !active.gemSlug) continue
        var supports = []
        var subs = g.subSkills || []
        for (var s = 0; s < subs.length; s++) {
            var nm = _slugToName(subs[s].gemSlug || "")
            if (nm) supports.push(nm)
        }
        groups.push({
            main: active.name || _slugToName(active.gemSlug || ""),
            mainIcon: active.iconURL || active.gemIconURL || "",
            supports: supports,
            level: active.level || 0
        })
    }
    return groups
}

function _humanSlot(key) {
    switch (key) {
        case "mainHand":   return "Main Hand"
        case "offHand":    return "Off Hand"
        case "body":       return "Body Armour"
        case "leftRing":   return "Ring (L)"
        case "rightRing":  return "Ring (R)"
        case "extraRing":  return "Ring (Extra)"
        case "flask1":     return "Flask 1"
        case "flask2":     return "Flask 2"
        case "charm1":     return "Charm 1"
        case "charm2":     return "Charm 2"
        case "charm3":     return "Charm 3"
        default: return key.charAt(0).toUpperCase() + key.substring(1)
    }
}

function _slugToName(slug) {
    if (!slug) return ""
    // Strip common prefixes/suffixes
    var s = slug.replace(/^support/i, "").replace(/player$/i, "").replace(/two$/i, "")
                .replace(/three$/i, "").replace(/^new/i, "")
    // Insert spaces before capitals or after lowercase→uppercase boundaries
    s = s.replace(/([a-z])([A-Z])/g, "$1 $2")
    // Title-case first letter
    return s.charAt(0).toUpperCase() + s.substring(1)
}

function _walkChildren(ids, content, out) {
    for (var i = 0; i < ids.length; i++) {
        var b = content[ids[i]]
        if (!b) continue
        _addBlock(b, out)
        if (b.data && b.data.childrenIds) _walkChildren(b.data.childrenIds, content, out)
    }
}

function _addBlock(block, sections) {
    var t = block.__typename
    var data = block.data || {}

    if (t === "NgfDocumentCmWidgetRichTextSimplifiedV2" && data.simplifiedContent) {
        var body = _lexicalToText(data.simplifiedContent.value)
        if (body.trim().length > 0) {
            sections.push({ kind: "text", title: data.title || "", body: body })
        }
    } else if (t === "NgfDocumentCmWidgetStrengthsAndWeaknessesV1") {
        sections.push({
            kind: "strengths",
            title: data.title || "Strengths and Weaknesses",
            strengths: _lexicalToList(data.strengths && data.strengths.value),
            weaknesses: _lexicalToList(data.weaknesses && data.weaknesses.value)
        })
    } else if (t === "Poe2DocumentUgWidgetEquipmentV1" && data.descriptionPoeEquipment) {
        var body = _lexicalToText(data.descriptionPoeEquipment.value)
        if (body.trim().length > 0) sections.push({ kind: "text", title: data.title || "Equipment notes", body: body })
    } else if (t === "Poe2DocumentUgWidgetSkillGemsV1" && data.descriptionPoeSkillGems) {
        var body2 = _lexicalToText(data.descriptionPoeSkillGems.value)
        if (body2.trim().length > 0) sections.push({ kind: "text", title: data.title || "Skill notes", body: body2 })
    }
}

// ── Lexical (Meta's editor) → plain text ─────────────────────────
function _lexicalToText(value) {
    if (!value || !value.root) return ""
    return _nodeToText(value.root, 0).trim()
}

function _nodeToText(node, depth) {
    if (!node) return ""
    if (node.type === "text") return node.text || ""
    // Mobalytics item/skill reference node — extract label
    if (node.type === "static-data-widget") {
        return node.label ? "[" + node.label + "]" : ""
    }
    var children = node.children || []
    var inner = ""
    for (var i = 0; i < children.length; i++) {
        inner += _nodeToText(children[i], depth + 1)
    }
    if (node.type === "heading") {
        var hashes = "##"
        var tag = (node.tag || "h2").toLowerCase()
        if (tag === "h1") hashes = "#"
        else if (tag === "h2") hashes = "##"
        else if (tag === "h3") hashes = "###"
        else hashes = "####"
        return "\n" + hashes + " " + inner + "\n"
    }
    if (node.type === "listitem") return "• " + inner + "\n"
    if (node.type === "list") return inner + "\n"
    if (node.type === "paragraph") return inner + "\n"
    if (node.type === "linebreak") return "\n"
    if (node.type === "link") return inner
    return inner
}

function _lexicalToList(value) {
    if (!value || !value.root) return []
    var items = []
    _collectListItems(value.root, items)
    return items
}

function _collectListItems(node, out) {
    if (!node) return
    if (node.type === "listitem") {
        var text = _nodeToText(node, 0).replace(/^•\s*/, "").trim()
        if (text) out.push(text)
        return
    }
    var children = node.children || []
    for (var i = 0; i < children.length; i++) _collectListItems(children[i], out)
}

// ── Equipment extraction ─────────────────────────────────────────
function _extractEquipment(data) {
    var items = []
    // Equipment block tends to reference variant ids. We need access to the
    // build's buildVariants, but we don't have it here directly — equipment
    // data is often inline as `slots` in older blocks. Best effort:
    var slots = data.equipment && (data.equipment.slots || data.equipment)
    if (!slots) return items
    for (var key in slots) {
        var slot = slots[key]
        if (!slot || typeof slot !== "object") continue
        var c = slot.commonItem || slot
        if (!c || !c.name) continue
        var mods = []
        if (c.explicitDescriptions) {
            for (var m = 0; m < c.explicitDescriptions.length; m++) {
                if (c.explicitDescriptions[m].description) mods.push(c.explicitDescriptions[m].description)
            }
        }
        items.push({
            slot: key,
            name: c.name,
            isUnique: !!c.isUnique,
            iconUrl: c.iconURL || "",
            mods: mods
        })
    }
    return items
}

// ── Skills extraction ────────────────────────────────────────────
function _extractSkills(data) {
    var groups = []
    var src = data.skillGems || data.skills
    if (!src) return groups
    var list = Array.isArray(src) ? src : (src.values || src.groups || [])
    for (var i = 0; i < list.length; i++) {
        var g = list[i]
        if (!g) continue
        var main = (g.mainGem && (g.mainGem.name || g.mainGem.slug)) || g.name || ""
        var supports = []
        var sups = g.supports || g.supportGems || []
        for (var s = 0; s < sups.length; s++) {
            var sg = sups[s]
            supports.push((sg && (sg.name || sg.slug)) || String(sg))
        }
        if (main) groups.push({ main: main, supports: supports })
    }
    return groups
}

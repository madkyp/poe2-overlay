.pragma library

// Waystone (map) mod danger analyzer.
// Each rule has a regex (matches against a single mod line) and a severity level.
// Severity: "deadly" (red), "danger" (orange), "warn" (yellow).
//
// Detection is case-insensitive and works on English clipboard text. Spanish
// equivalents are added where the user might play in Spanish.

var RULES = [
    // ── DEADLY ────────────────────────────────────────────────────
    { re: /reflect.*physical/i,                          sev: "deadly", label: "Phys Reflect", why: "Mata builds de daño físico — el daño se devuelve al jugador" },
    { re: /reflect.*elemental/i,                         sev: "deadly", label: "Elemental Reflect", why: "Mata builds de daño elemental/hechizo — el daño se devuelve al jugador" },
    { re: /reflejan.*físico/i,                           sev: "deadly", label: "Phys Reflect", why: "Mata builds de daño físico" },
    { re: /reflejan.*elemental/i,                        sev: "deadly", label: "Elemental Reflect", why: "Mata builds de daño elemental/hechizo" },
    { re: /cannot regenerate/i,                          sev: "deadly", label: "No Regen", why: "No regeneras vida/mana/ES — solo leech/flasks" },
    { re: /no pueden regenerar/i,                        sev: "deadly", label: "No Regen", why: "No regeneras vida/mana/ES" },

    // ── DANGER ────────────────────────────────────────────────────
    { re: /less recovery rate/i,                         sev: "danger", label: "Less Recovery", why: "Flasks y leech curan menos — combinado con No Regen es letal" },
    { re: /menos.*recuperación/i,                        sev: "danger", label: "Less Recovery", why: "Flasks y leech curan menos" },
    { re: /to maximum.*resistance/i,                     sev: "danger", label: "−Max Resists", why: "Reduce el cap de resistencias máximas — daño elemental se dispara" },
    { re: /máxima.*resistencia/i,                        sev: "danger", label: "−Max Resists", why: "Reduce el cap de resistencias máximas" },
    { re: /penetrat[ei]s?\s+\d+%.*resist/i,              sev: "danger", label: "Resist Penetration", why: "Los monstruos ignoran parte de tus resistencias" },
    { re: /penetran\s+\d+%.*resist/i,                    sev: "danger", label: "Resist Penetration", why: "Los monstruos ignoran parte de tus resistencias" },
    { re: /extra damage as chaos/i,                      sev: "danger", label: "Extra Chaos Damage", why: "Daño caos extra — ignora la mayoría de defensas y resistencias" },
    { re: /daño adicional.*como caos/i,                  sev: "danger", label: "Extra Chaos Damage", why: "Daño caos extra" },
    { re: /cursed with vulnerability/i,                  sev: "danger", label: "Vulnerability", why: "Maldición: +30% daño físico recibido" },
    { re: /maldecidos con vulnerabilidad/i,              sev: "danger", label: "Vulnerability", why: "Maldición: +30% daño físico recibido" },
    { re: /cursed with elemental weakness/i,             sev: "danger", label: "Elemental Weakness", why: "Maldición: −25% resistencias elementales" },
    { re: /maldecidos con debilidad elemental/i,         sev: "danger", label: "Elemental Weakness", why: "Maldición: −25% resistencias elementales" },

    // ── WARN ──────────────────────────────────────────────────────
    { re: /cursed with temporal chains/i,                sev: "warn", label: "Temporal Chains", why: "Te mueves y atacas más lento" },
    { re: /maldecidos con cadenas temporales/i,          sev: "warn", label: "Temporal Chains", why: "Te mueves y atacas más lento" },
    { re: /cursed with enfeeble/i,                       sev: "warn", label: "Enfeeble", why: "Tu daño y precisión bajan" },
    { re: /critical damage bonus/i,                      sev: "warn", label: "+Crit Damage (mobs)", why: "Los crits de los monstruos te hacen mucho más daño" },
    { re: /critical hit chance/i,                        sev: "warn", label: "+Crit Chance (mobs)", why: "Los monstruos critean más a menudo" },
    { re: /additional projectile/i,                      sev: "warn", label: "+Projectiles", why: "Los monstruos disparan proyectiles extra" },
    { re: /increased area of effect/i,                   sev: "warn", label: "+AoE", why: "Las habilidades de los monstruos cubren más área" },
    { re: /buff effects? expire/i,                       sev: "warn", label: "Buffs Expire Faster", why: "Flasks y buffs duran menos" },
    { re: /reduced movement speed/i,                     sev: "warn", label: "−Move Speed", why: "Te mueves más lento — peor kiting" },

    // ── COMBO HINTS (handled separately) ─────────────────────────
]

// Analyze an array of mod strings. Returns:
//   { hasWaystone: true, alerts: [{ sev, label, why, mod }], summary: "deadly"|"danger"|"warn"|"safe" }
function analyzeMods(mods) {
    var alerts = []
    var hasReflect = false
    var hasNoRegen = false
    var hasLessRecovery = false

    for (var i = 0; i < mods.length; i++) {
        var mod = mods[i]
        for (var r = 0; r < RULES.length; r++) {
            if (RULES[r].re.test(mod)) {
                // Avoid duplicate labels (e.g. multiple rules matching same mod)
                var dup = false
                for (var a = 0; a < alerts.length; a++) {
                    if (alerts[a].label === RULES[r].label) { dup = true; break }
                }
                if (!dup) alerts.push({ sev: RULES[r].sev, label: RULES[r].label, why: RULES[r].why, mod: mod })

                if (RULES[r].label.indexOf("Reflect") !== -1) hasReflect = true
                if (RULES[r].label === "No Regen") hasNoRegen = true
                if (RULES[r].label === "Less Recovery") hasLessRecovery = true
                break
            }
        }
    }

    // Combo detection
    if (hasNoRegen && hasLessRecovery) {
        alerts.push({
            sev: "deadly",
            label: "COMBO: No sustain",
            why: "Sin regen y con menos recuperación — vas a depender 100% de leech. Build de leech recomendado.",
            mod: ""
        })
    }

    // Order: deadly > danger > warn
    alerts.sort(function(a, b) {
        var rank = { deadly: 0, danger: 1, warn: 2 }
        return rank[a.sev] - rank[b.sev]
    })

    var summary = "safe"
    for (var s = 0; s < alerts.length; s++) {
        if (alerts[s].sev === "deadly") { summary = "deadly"; break }
        if (alerts[s].sev === "danger" && summary !== "danger") summary = "danger"
        else if (alerts[s].sev === "warn" && summary === "safe") summary = "warn"
    }

    return { alerts: alerts, summary: summary }
}

function isWaystone(item) {
    if (!item) return false
    var c = (item.itemClass || "").toLowerCase()
    return c === "waystone" || c === "waystones" ||
           c === "piedra de paso" || c === "piedras de paso"
}

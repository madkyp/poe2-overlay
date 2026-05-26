.pragma library

// Helpers for looking up GGG sprite-atlas coordinates from the cached
// frame.json / skills.json files.
//
// Usage from QML:
//   import "js/SpriteAtlas.js" as SpriteAtlas
//   var rect = SpriteAtlas.frame(framesData, "frame:NotableFrameAllocated")
//   // -> { x: ..., y: ..., w: ..., h: ... }
//
// The atlas JSON has shape: { "frames": { "<name>": { "frame": {x,y,w,h} } } }.

// Frame name selection per node kind + state.
// kind:   "keystone" | "notable" | "jewel" | "mastery" | "normal" | "ascendancyNotable" | "ascendancyNormal"
// state:  "allocated" | "canAllocate" | "unallocated"
function pickFrame(kind, state) {
    if (kind === "keystone") {
        if (state === "allocated")    return "frame:KeystoneFrameAllocated"
        if (state === "canAllocate")  return "frame:KeystoneFrameCanAllocate"
        return "frame:KeystoneFrameUnallocated"
    }
    if (kind === "notable") {
        if (state === "allocated")    return "frame:NotableFrameAllocated"
        if (state === "canAllocate")  return "frame:NotableFrameCanAllocate"
        return "frame:NotableFrameUnallocated"
    }
    if (kind === "jewel") {
        if (state === "allocated")    return "frame:JewelFrameAllocated"
        if (state === "canAllocate")  return "frame:JewelFrameCanAllocate"
        return "frame:JewelFrameUnallocated"
    }
    if (kind === "ascendancyNotable") {
        if (state === "allocated")    return "frame:AscendancyFrameNotableAllocated"
        if (state === "canAllocate")  return "frame:AscendancyFrameNotableCanAllocate"
        return "frame:AscendancyFrameNotableUnallocated"
    }
    if (kind === "ascendancyNormal") {
        if (state === "allocated")    return "frame:AscendancyFrameNormalAllocated"
        if (state === "canAllocate")  return "frame:AscendancyFrameNormalCanAllocate"
        return "frame:AscendancyFrameNormalUnallocated"
    }
    // normal / mastery / fallback
    if (state === "allocated")    return "frame:PSSkillFrameActive"
    if (state === "canAllocate")  return "frame:PSSkillFrameHighlighted"
    return "frame:PSSkillFrame"
}

function frame(framesData, name) {
    if (!framesData || !framesData.frames) return null
    var f = framesData.frames[name]
    if (!f || !f.frame) return null
    return f.frame
}

// Lookup helper that picks the frame by kind/state and returns its rect.
function rect(framesData, kind, state) {
    return frame(framesData, pickFrame(kind, state))
}

// Icon sprite lookup — skills.json uses keys like
//   "<prefix>:Art/2DArt/SkillIcons/passives/X.png"
// where prefix is normalActive / notableActive / keystoneActive (skills.webp)
// or normalInactive / notableInactive / keystoneInactive (skills-disabled.webp).
function iconKey(kind, iconPath, active) {
    var pref
    if (kind === "keystone") pref = active ? "keystoneActive" : "keystoneInactive"
    else if (kind === "notable") pref = active ? "notableActive" : "notableInactive"
    else                          pref = active ? "normalActive"   : "normalInactive"
    return pref + ":" + iconPath
}

function iconRect(skillsData, kind, iconPath, active) {
    if (!skillsData || !iconPath) return null
    var key = iconKey(kind, iconPath, active)
    return frame(skillsData, key)
}

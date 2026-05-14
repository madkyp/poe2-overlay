.pragma library

var GUIDES = [
    {
        id: "general",
        title: "Crafting Guide: Step by Step",
        category: "General",
        categoryColor: "#6a9aaa",
        difficulty: "Intermediate",
        summary: "Complete crafting process from base selection to final corruption.",
        sections: [
            {
                heading: "Core Concepts",
                content: "Every item has max 3 Prefixes and 3 Suffixes. Prefixes = offense, Suffixes = defense. Item Level controls which affix tiers can roll — higher ilvl = stronger possible mods.",
                steps: [],
                tips: ["Pick bases at ilvl 75+ for endgame gear", "Identify which slots you need prefix vs suffix before you start crafting"]
            },
            {
                heading: "Step-by-step Process",
                content: "",
                steps: [
                    { n: 1, action: "Find a quality base", detail: "High ilvl normal item. Match your build — right implicit, attack speed, socket colors." },
                    { n: 2, action: "Apply quality first", detail: "Use Whetstone / Armourer's Scrap before upgrading rarity to get the full 20% bonus." },
                    { n: 3, action: "Use Essences for a guaranteed mod", detail: "Apply a relevant Essence to lock in one important mod as you upgrade the item to Rare." },
                    { n: 4, action: "Fill remaining affixes", detail: "Use Exalted Orbs to add mods to the Rare item. Alternatively use the Reforging Bench." },
                    { n: 5, action: "Remove weak affixes", detail: "Chaos Orb + Omen of Whittling removes the lowest tier mod. Omen of Sinistral/Dextral Erasure for prefix/suffix control." },
                    { n: 6, action: "Optimize values", detail: "Use Divine Orb to reroll numeric values within the current tier ranges. Very expensive — save for near-perfect items." },
                    { n: 7, action: "Lock your best mod", detail: "Use Fracturing Orb to permanently lock the most important mod before any risky crafting step." },
                    { n: 8, action: "Add sockets", detail: "Use Artificer's Orb to add augment slots, then insert Runes or Soul Cores." },
                    { n: 9, action: "Optional: Corrupt", detail: "Use Vaal Orb last. Use Hinekora's Lock to preview the result first. Irreversible." }
                ],
                tips: []
            },
            {
                heading: "Advanced: Omen Stacking",
                content: "Combine multiple Omens to guarantee specific outcomes. Example: Omen of Whittling + Omen of Dextral Erasure ensures removing a specific suffix. Hinekora's Lock previews the next currency effect — use before any expensive orb. Perfect Essences work on existing Rares, replacing a random mod with the guaranteed one.",
                steps: [],
                tips: ["Always plan your prefix/suffix budget before spending Exalted Orbs", "Recombinator workflow: craft multiple copies separately, then merge the best mods from each"]
            }
        ]
    },
    {
        id: "recombinator",
        title: "Recombinator Guide",
        category: "Expedition",
        categoryColor: "#c4903a",
        difficulty: "Advanced",
        summary: "Merge the best mods from two items into one using Expedition Artifacts.",
        sections: [
            {
                heading: "How It Works",
                content: "Combines two items of the same item class. You choose which mods to carry over to the resulting item. Both items are destroyed on failure.",
                steps: [],
                tips: ["Only items of the same class can be combined (e.g. two amulets)", "Base type can differ — result base is random between the two inputs"]
            },
            {
                heading: "Success Rates",
                content: "Selecting rarer and more powerful mods reduces success chance. Attempting more than 2 mods drastically reduces odds. Cost in Artifacts scales with mod rarity.",
                steps: [],
                tips: ["Aim for 2 mods max for reasonable success rates", "Craft multiple copies of the same item and merge the best mods from each"]
            },
            {
                heading: "Unlock",
                content: "Unlocks after completing your first Expedition in the Atlas endgame. Artifacts drop from Expedition encounters on Atlas maps.",
                steps: [],
                tips: []
            }
        ]
    },
    {
        id: "corruption",
        title: "Corrupted Items Guide",
        category: "Vaal",
        categoryColor: "#aa4a4a",
        difficulty: "Beginner",
        summary: "Corruption is permanent and unpredictable. Only corrupt fully crafted items.",
        sections: [
            {
                heading: "What Corruption Does",
                content: "Applies a random effect to the item — stats can go up, down, or the item may simply become locked with no change. Once corrupted, the item cannot be modified further by any standard crafting currency.",
                steps: [],
                tips: ["Always corrupt as the very last crafting step", "Use Omen of Corruption to guarantee a corrupted implicit instead of random negative effects", "Use Hinekora's Lock to preview the result before committing the Vaal Orb"]
            },
            {
                heading: "How to Corrupt",
                content: "Use a Vaal Orb from your inventory at any time. Or interact with a Corruption Altar: Act 2 (Vaal Ruins, Jiquani's Sanctum, Temple of Atzoatl) and Act 3 (Trial of Chaos).",
                steps: [],
                tips: []
            },
            {
                heading: "Fate of the Vaal — New Tools",
                content: "New items added in the Fate of the Vaal league allow further manipulation of already-corrupted items: Vaal Cultivation Orb (replace up to 2 mods on corrupted Uniques, or convert normal Uniques into corrupted variants), Vaal Siphoner (adds a kill threshold — on reaching it, siphons a random mod and improves values of the rest), Architect's Orb (randomly modify or destroy corrupted gear/jewels), Crystallised Corruption (for corrupted skill gems).",
                steps: [],
                tips: ["Architect's Orb is high risk — only use on items with no other value", "Vaal Siphoner grows stronger with more kills — great for long-term improvement on a solid item"]
            }
        ]
    },
    {
        id: "reforging",
        title: "Reforging Benches Guide",
        category: "General",
        categoryColor: "#7aaa6a",
        difficulty: "Beginner",
        summary: "Combine 3 identical bases to reroll mods or upgrade currency tier.",
        sections: [
            {
                heading: "Unlock",
                content: "Complete the Act 3 optional quest 'Treasures of Utzaal'. Defeat Mektul the Forgemaster in the Molten Vault and deliver the Hammer of Kamasa to Oswald at Ziggurat Encampment.",
                steps: [],
                tips: ["The Molten Vault entrance appears in Drowned City after clearing the flood during 'Legacy of the Vaal'"]
            },
            {
                heading: "Recipes",
                content: "3 × same base + same rarity → new item with rerolled mods (inherits lowest ilvl of the three). Also works for Waystones, Runes, Essences, and Liquid Emotions to upgrade their tier. Soul Cores and Catalysts produce a random variant.",
                steps: [],
                tips: ["All 3 items must share the exact same base name and rarity", "Result inherits the lowest Item Level — use items with similar ilvl to avoid downgrading"]
            },
            {
                heading: "Locations",
                content: "Available at all major encampments: Clearfell Encampment (Act 1), The Ardura Caravan (Act 2), Ziggurat Encampment (Act 3), Kingsmarch (Act 4), and all Interlude Act towns and Hideouts.",
                steps: [],
                tips: []
            }
        ]
    },
    {
        id: "abyss",
        title: "Abyss & Desecrated Modifiers",
        category: "Abyss",
        categoryColor: "#8a7a5a",
        difficulty: "Intermediate",
        summary: "Add hidden mods to Rare items and reveal them at the Well of Souls.",
        sections: [
            {
                heading: "How It Works",
                content: "Apply an Abyssal Bone to a Rare item that still has open modifier slots. The modifier starts hidden (no effect). Bring the item to the Well of Souls in Act 2 and choose 1 of 3 offered affixes to reveal.",
                steps: [],
                tips: ["Essence of the Abyss creates a Mark of the Abyssal Lord — guarantees a higher-tier desecrated mod when revealed", "Gnawed bones cap at ilvl 64. Use Preserved or Ancient tier bones for endgame items"]
            },
            {
                heading: "Bone Types",
                content: "Jawbone → Weapons / Quivers. Rib → Armor. Collarbone → Amulets / Rings / Belts. Preserved Cranium → Jewels. Preserved Vertebrae → Waystones. Each bone comes in 3 tiers: Gnawed / Preserved / Ancient (Ancient requires level 40+).",
                steps: [],
                tips: []
            },
            {
                heading: "Abyssal Omens",
                content: "Omens of Abyssal Echoes / Sovereign: give one reroll of the 3 choices at the Well. Omen of the Liege (Amananmu) / Blackblooded (Kurgal): guarantee specific modifier types. Omen of Putrefaction: replaces ALL existing mods with up to 6 desecrated ones. Omens of Sinistral/Dextral Necromancy: restrict desecration to prefix or suffix only.",
                steps: [],
                tips: ["Omen of Putrefaction is high risk/reward — full reroll with up to 6 desecrated slots possible", "Sinistral/Dextral Necromancy gives control over prefix vs suffix when desecrating"]
            },
            {
                heading: "Obtaining Abyssal Bones",
                content: "Drop from chests, enemies, and bosses in Abyss encounters. Best sources: Abyssal Armouries and deeper cavern areas within Abyss maps on the Atlas.",
                steps: [],
                tips: []
            }
        ]
    },
    {
        id: "sockets",
        title: "Sockets, Runes & Soul Cores",
        category: "Sockets",
        categoryColor: "#6a7aaa",
        difficulty: "Beginner",
        summary: "Add augment slots to gear and fill them with Runes, Soul Cores, or Idols.",
        sections: [
            {
                heading: "Socket Limits",
                content: "Max 7 sockets across full gear: Weapons 2, Body Armour 2, Gloves / Boots / Helmet 1 each. Certain unique or corrupted items may exceed these limits.",
                steps: [],
                tips: ["Use Artificer's Orb to add sockets (craft from 10 Artificer's Shards)", "Vaal Orb can add an extra socket beyond the normal cap on corrupted gear"]
            },
            {
                heading: "Runes",
                content: "3 tiers: Lesser, Standard, Greater. Body Rune: life leech (weapon) / max life (armor). Iron Rune: physical damage (weapon) / defense (armor). Storm / Desert / Glacial: elemental damage or resistance. Inspiration / Mind / Rebirth: mana recovery. Stone Rune: stun. Vision Rune: accuracy or flask recovery. Greater runes provide significantly higher percentages than Lesser.",
                steps: [],
                tips: ["Match rune tier to your character level — Greater runes are endgame investment", "Sockets can be filled and emptied freely at any time at no cost"]
            },
            {
                heading: "Soul Cores",
                content: "Drop from the Temple of Atzoatl. Provide varied effects depending on whether socketed in weapon or armor: life on kill, bleed/poison chance, elemental bonuses, stat conversions, minion bonuses.",
                steps: [],
                tips: ["Soul Cores are tradeable and often valuable — check poe2.ninja rates before selling or destroying", "Core Destabiliser (Fate of the Vaal) rerolls a Soul Core randomly — use it on unwanted cores only"]
            },
            {
                heading: "Idols",
                content: "Armor-type specific socketables. Provide minor bonuses: Area of Effect, attack speed, curse magnitude, cooldown recovery, item rarity, skill quality.",
                steps: [],
                tips: []
            }
        ]
    },
    {
        id: "essences",
        title: "Essences Guide",
        category: "General",
        categoryColor: "#9a6aaa",
        difficulty: "Beginner",
        summary: "The best way to guarantee a specific mod when crafting a Rare item.",
        sections: [
            {
                heading: "How They Work",
                content: "Apply an Essence to a Normal item to upgrade it to Rare with a guaranteed specific modifier determined by the Essence type. The remaining mods are random.",
                steps: [],
                tips: ["Always use Essences on good bases (high ilvl, right implicit)", "The guaranteed mod depends on the Essence type AND the item type it is applied to — check the description before using"]
            },
            {
                heading: "Lesser / Greater / Perfect Tiers",
                content: "Lesser Essences work on Normal items only. Greater Essences upgrade Normal to Rare with a stronger guaranteed mod. Perfect Essences work on existing Rare items — they replace a random existing mod with the guaranteed one, making them powerful for refinement.",
                steps: [],
                tips: ["Perfect Essences are the only way to add a guaranteed mod to an already-crafted Rare item without rerolling everything", "They are rare drops — prioritize using them on items that are already close to perfect"]
            },
            {
                heading: "Essence of the Abyss",
                content: "Special Essence that creates a 'Mark of the Abyssal Lord' on the item. When revealed at the Well of Souls, it guarantees a higher-tier Desecrated Modifier choice.",
                steps: [],
                tips: ["Combine with Abyss crafting for double guaranteed-mod items"]
            }
        ]
    }
]

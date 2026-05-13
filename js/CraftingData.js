.pragma library

var SECTIONS = [
    {
        title: "Calidad",
        color: "#7aaa6a",
        orbs: [
            {
                name: "Blacksmith's Whetstone",
                applies: "Arma marcial",
                effect: "Mejora la calidad de un arma marcial. Máximo 20%.",
                tip: "Aplica antes de subir de rareza para aprovechar el bonus máximo."
            },
            {
                name: "Arcanist's Etcher",
                applies: "Varita, Bastón, Cetro",
                effect: "Mejora la calidad de una varita, bastón o cetro. Máximo 20%.",
                tip: "Equivalente al Whetstone pero para armas de lanzador."
            },
            {
                name: "Armourer's Scrap",
                applies: "Armadura",
                effect: "Mejora la calidad de una armadura. Máximo 20%.",
                tip: "Aplica antes de subir de rareza."
            },
            {
                name: "Glassblower's Bauble",
                applies: "Flask",
                effect: "Mejora la calidad de un flask. Máximo 20%.",
                tip: ""
            },
            {
                name: "Gemcutter's Prism",
                applies: "Gema de habilidad",
                effect: "Mejora la calidad de una gema de habilidad.",
                tip: "Mayor calidad en gemas suele aumentar el efecto base de la habilidad."
            },
            {
                name: "Vaal Infuser",
                applies: "Arma o Armadura",
                effect: "Mejora la calidad por encima del 20% con probabilidad de corromper el item.",
                tip: "NUEVO — Fate of the Vaal. Solo úsalo si el item ya está bien crafteado — la corrupción es irreversible."
            }
        ]
    },
    {
        title: "Cambio de rareza",
        color: "#aaa06a",
        orbs: [
            {
                name: "Orb of Transmutation",
                applies: "Normal",
                effect: "Convierte un item Normal en Magic con 1 modificador aleatorio.",
                tip: ""
            },
            {
                name: "Orb of Augmentation",
                applies: "Magic",
                effect: "Añade un nuevo modificador aleatorio a un item Magic.",
                tip: "Úsalo cuando el Magic tiene solo 1 mod y quieres intentar conseguir el segundo."
            },
            {
                name: "Regal Orb",
                applies: "Magic",
                effect: "Convierte un item Magic en Rare.",
                tip: "Úsalo cuando tengas los mods Magic que buscas y quieras subir a Rare."
            },
            {
                name: "Orb of Alchemy",
                applies: "Normal",
                effect: "Convierte un item Normal en Rare con 4 modificadores aleatorios.",
                tip: "Rápido pero sin control sobre los mods."
            },
            {
                name: "Orb of Chance",
                applies: "Normal",
                effect: "Convierte un item Normal en Unique de forma impredecible, o lo destruye.",
                tip: "Úsalo en bases específicas cuando buscas un Unique concreto. Alto riesgo."
            }
        ]
    },
    {
        title: "Modificación de mods",
        color: "#6a9aaa",
        orbs: [
            {
                name: "Chaos Orb",
                applies: "Rare",
                effect: "Elimina un modificador aleatorio del item y añade uno nuevo aleatorio. Solo cambia 1 mod, no rerollea todo.",
                tip: "⚠ Diferente a PoE1. No rerollea todos los mods, solo sustituye uno. Más quirúrgico."
            },
            {
                name: "Exalted Orb",
                applies: "Rare",
                effect: "Añade 1 nuevo modificador aleatorio a un item Rare.",
                tip: "Úsalo solo cuando el item ya tiene los mods base que buscas."
            },
            {
                name: "Orb of Annulment",
                applies: "Magic / Rare",
                effect: "Elimina 1 modificador aleatorio del item.",
                tip: "Alto riesgo. Úsalo si el item tiene un mod malo que quieres intentar borrar."
            },
            {
                name: "Divine Orb",
                applies: "Magic / Rare / Unique",
                effect: "Rerollea los valores numéricos de todos los mods del item. Los tipos de mod no cambian.",
                tip: "Para maximizar valores. Muy caro — úsalo solo en items casi perfectos."
            },
            {
                name: "Fracturing Orb",
                applies: "Rare (mínimo 4 mods)",
                effect: "Fractura un modificador aleatorio del item bloqueándolo en su lugar. El mod fracturado no puede ser cambiado.",
                tip: "Úsalo cuando tienes el mod más importante que quieres conservar pase lo que pase."
            },
            {
                name: "Hinekora's Lock",
                applies: "Cualquier item",
                effect: "Permite prever el resultado del siguiente orbe que uses en el item. Modificar el item de cualquier forma elimina la previsión.",
                tip: "Planifica antes de usar un orbe caro. Si el resultado previsto no convence, no uses el orbe."
            }
        ]
    },
    {
        title: "Essences",
        color: "#9a6aaa",
        orbs: [
            {
                name: "Essence (cualquier tipo)",
                applies: "Normal",
                effect: "Convierte un item Normal en Rare garantizando al menos 1 modificador específico según el tipo de Essence.",
                tip: "El mejor método cuando necesitas un mod concreto. Úsalas en buenas bases."
            }
        ]
    },
    {
        title: "Corrupción y Vaal",
        color: "#aa4a4a",
        orbs: [
            {
                name: "Vaal Orb",
                applies: "Cualquier item",
                effect: "Corrompe el item aplicando un efecto aleatorio e impredecible. El item no puede modificarse más.",
                tip: "Irreversible. Solo corrompe items cuando ya son casi perfectos."
            },
            {
                name: "Vaal Cultivation Orb",
                applies: "Unique Vaal corrompido / Unique normal",
                effect: "En Uniques Vaal corrompidos: reemplaza hasta 2 modificadores. En otros Uniques: los convierte en un Unique corrompido de la misma clase de item.",
                tip: "NUEVO — Fate of the Vaal. Útil para mejorar Uniques Vaal o transformar Uniques normales en variantes corrompidas."
            },
            {
                name: "Vaal Siphoner",
                applies: "Joyería Rare corrompida",
                effect: "Añade un Kill Threshold al item. Al alcanzarse, sifona un modificador aleatorio y mejora los valores numéricos del resto.",
                tip: "NUEVO — Fate of the Vaal. Progresivo: cuantos más kills, mejor se vuelve el item."
            },
            {
                name: "Architect's Orb",
                applies: "Equipamiento o Joya corrompida",
                effect: "Modifica un item corrompido de forma impredecible, o lo destruye.",
                tip: "NUEVO — Fate of the Vaal. Alto riesgo, úsalo solo si el item ya no tiene otro uso."
            },
            {
                name: "Crystallised Corruption",
                applies: "Gema de habilidad corrompida",
                effect: "Modifica una gema de habilidad corrompida de forma impredecible, o la destruye.",
                tip: "NUEVO — Fate of the Vaal. Para intentar mejorar gemas corrompidas ya sin otro valor."
            }
        ]
    },
    {
        title: "Fate of the Vaal — Nuevos items",
        color: "#c47a3a",
        orbs: [
            {
                name: "Ancient Infuser",
                applies: "Precursor Tablet",
                effect: "Modifica un Precursor Tablet de forma impredecible, con posibilidad de destruirlo.",
                tip: "NUEVO — para intentar mejorar tablets de endgame."
            },
            {
                name: "Core Destabiliser",
                applies: "Soul Core",
                effect: "Modifica un Soul Core de forma impredecible, con posibilidad de destruirlo.",
                tip: "NUEVO — úsalo en Soul Cores con mods que no quieres."
            },
            {
                name: "Orb of Extraction",
                applies: "Equipamiento o Joya",
                effect: "Destruye el item devolviendo todos los Augments (Runes, Soul Cores) que tenía socketados.",
                tip: "NUEVO — imprescindible para recuperar Runes y Soul Cores valiosos antes de desechar un item."
            }
        ]
    },
    {
        title: "Desecramiento (Abyss)",
        color: "#8a7a5a",
        orbs: [
            {
                name: "Collarbone (Ancient / Gnawed / Preserved)",
                applies: "Amuleto, Anillo o Cinturón Rare",
                effect: "Desecra el item. Ancient = efecto más fuerte, Preserved = más débil.",
                tip: "El desecramiento añade mods Abyss especiales al item."
            },
            {
                name: "Jawbone (Ancient / Gnawed / Preserved)",
                applies: "Arma o Carcaj Rare",
                effect: "Desecra el arma o carcaj.",
                tip: ""
            },
            {
                name: "Rib (Ancient / Gnawed / Preserved)",
                applies: "Armadura Rare",
                effect: "Desecra la armadura.",
                tip: ""
            },
            {
                name: "Preserved Cranium",
                applies: "Joya Rare",
                effect: "Desecra una joya Rare.",
                tip: ""
            },
            {
                name: "Preserved Vertebrae",
                applies: "Waystone Rare",
                effect: "Desecra un Waystone Rare.",
                tip: ""
            }
        ]
    },
    {
        title: "Sockets de gema",
        color: "#6a7aaa",
        orbs: [
            {
                name: "Artificer's Orb",
                applies: "Arma marcial o Armadura",
                effect: "Añade un socket al item para colocar Runes o Soul Cores.",
                tip: "Necesario para equipar Runes. Los sockets se pueden rellenar y vaciar libremente."
            },
            {
                name: "Lesser Jeweller's Orb",
                applies: "Gema de habilidad",
                effect: "Establece la gema con 3 sockets de soporte.",
                tip: ""
            },
            {
                name: "Greater Jeweller's Orb",
                applies: "Gema de habilidad",
                effect: "Establece la gema con 4 sockets de soporte.",
                tip: ""
            },
            {
                name: "Perfect Jeweller's Orb",
                applies: "Gema de habilidad",
                effect: "Establece la gema con 5 sockets de soporte (máximo).",
                tip: "Muy caro. Guárdalo para gemas principales de tu build."
            }
        ]
    },
    {
        title: "Omens (Ritual)",
        color: "#c4903a",
        orbs: [
            {
                name: "Omen of Whittling",
                applies: "Junto a orbe de reroll",
                effect: "Al rerollear un item, elimina el peor modificador en lugar de rerollear todos.",
                tip: "Útil para conservar un mod bueno y eliminar solo el malo."
            },
            {
                name: "Omen of Amelioration",
                applies: "Junto a Orb of Annulment",
                effect: "Al usar Orb of Annulment, puedes elegir qué modificador eliminar en lugar de que sea aleatorio.",
                tip: "Elimina el riesgo del Annulment — borra el mod malo con total seguridad."
            },
            {
                name: "Omen of Corruption",
                applies: "Junto a Vaal Orb",
                effect: "Al corromper con Vaal Orb, garantiza que se aplique un implicit corrupto en vez de efectos negativos.",
                tip: "Reduce el riesgo de corrupción en items valiosos."
            },
            {
                name: "Omen of Sinistral Erasure",
                applies: "Magic / Rare",
                effect: "Elimina un prefijo aleatorio del item.",
                tip: "Más control que Annulment cuando sabes que el mod malo es un prefijo."
            },
            {
                name: "Omen of Dextral Erasure",
                applies: "Magic / Rare",
                effect: "Elimina un sufijo aleatorio del item.",
                tip: "Más control que Annulment cuando sabes que el mod malo es un sufijo."
            },
            {
                name: "Omen of Sinistral Alchemy",
                applies: "Normal",
                effect: "Sube a Rare garantizando al menos un prefijo de un tipo específico.",
                tip: "Alternativa controlada al Orb of Alchemy cuando buscas un prefijo concreto."
            },
            {
                name: "Omen of Dextral Alchemy",
                applies: "Normal",
                effect: "Sube a Rare garantizando al menos un sufijo de un tipo específico.",
                tip: "Alternativa controlada al Orb of Alchemy cuando buscas un sufijo concreto."
            }
        ]
    },
    {
        title: "Catalysts (Breach)",
        color: "#3aaa8a",
        orbs: [
            {
                name: "Abrasive Catalyst",
                applies: "Joyería",
                effect: "Añade calidad sesgando hacia mods de Ataque.",
                tip: "Para anillos/amuletos en builds de ataque físico."
            },
            {
                name: "Fertile Catalyst",
                applies: "Joyería",
                effect: "Añade calidad sesgando hacia mods de Vida y Mana.",
                tip: "Para accesorios defensivos."
            },
            {
                name: "Intrinsic Catalyst",
                applies: "Joyería",
                effect: "Añade calidad sesgando hacia mods de Atributos (STR, DEX, INT).",
                tip: ""
            },
            {
                name: "Prismatic Catalyst",
                applies: "Joyería",
                effect: "Añade calidad sesgando hacia mods de Resistencias Elementales.",
                tip: "El más usado para solucionar resistencias en accesorios."
            },
            {
                name: "Tempering Catalyst",
                applies: "Joyería",
                effect: "Añade calidad sesgando hacia mods de Defensa (armadura, evasión, ES).",
                tip: ""
            },
            {
                name: "Turbulent Catalyst",
                applies: "Joyería",
                effect: "Añade calidad sesgando hacia mods de Daño Elemental.",
                tip: "Para builds de hechizos o daño elemental."
            },
            {
                name: "Unstable Catalyst",
                applies: "Joyería",
                effect: "Añade calidad sesgando hacia mods de Crítico.",
                tip: "Muy valorado en builds de crítico."
            }
        ]
    }
]

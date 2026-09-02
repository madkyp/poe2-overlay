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
                name: "Vaal Infusers (4 tipos)",
                applies: "Item con 20%+ calidad",
                effect: "Sube la calidad por encima del 20% corrompiendo el item. En 0.5 hay 4 variantes: Armourer's (armadura), Blacksmith's (armas marciales), Arcanist's (varita/bastón/cetro), Catalysing (joyería). Requieren ya 20% de calidad.",
                tip: "Solo úsalo si el item ya está bien crafteado — la corrupción es irreversible."
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
                tip: "En 0.5 (Runes of Aldur) son notablemente más raras que antes."
            },
            {
                name: "Orb of Augmentation",
                applies: "Magic",
                effect: "Añade un nuevo modificador aleatorio a un item Magic.",
                tip: "Úsalo cuando el Magic tiene solo 1 mod y quieres intentar conseguir el segundo. En 0.5 son más raras; las versiones Greater caen desde el Acto 4 con nivel mín. de mod 44."
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
                tip: "Para maximizar valores. En 0.5 son más comunes que antes, así que optimizar valores es más asequible."
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
                tip: "Útil para mejorar Uniques Vaal o transformar Uniques normales en variantes corrompidas. En 0.5 se rebajaron los valores en algunos uniques concretos."
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
    },
    {
        title: "Runes of Aldur (0.5) — Crafteo rúnico",
        color: "#5a8aca",
        orbs: [
            {
                name: "Remnant",
                applies: "Mecánica de liga",
                effect: "Aparece en cada zona de la liga. Te deja craftear un item a elegir grabando Runic Recipes en sus slots. Tiene entre 2 y 10 slots (más slots = más raro, pero permite craftear items mucho mejores). Al activarlo te enfrentas a un encuentro que debes superar para reclamar el item.",
                tip: "Añadir más Runeshapes aumenta las oleadas de enemigos y les pone modificadores rúnicos, a cambio de mejores resultados."
            },
            {
                name: "Verisium (Runeforging)",
                applies: "Armadura",
                effect: "Se desbloquea en el Acto 1 (misión en Ogham). Gastas Verisium para añadir Runic Ward (nueva defensa) a tus armaduras. Por debajo de nivel 55 la armadura gana Runic Ward sin penalización; las de nivel alto cambian parte de su defensa base por Runic Ward. El Runeforging de armas (con Transcendent Alloy, aplicable a Staves/Wands/Foci) se desbloquea en el Acto 3.",
                tip: "Runic Ward se activa al llegar a 1 de vida y absorbe daño mientras dura — una capa extra de supervivencia."
            },
            {
                name: "Runas nuevas (0.5)",
                applies: "Sockets de Rune",
                effect: "Ancient Runes (efectos especiales según el tipo de arma), Runic Ward Runes (ligadas a la nueva defensa Runic Ward) y runas de Augment/meta-crafting que, en vez de un bonus fijo, añaden una línea de modificador nueva al item (ej. Uhtred's Sidereus en botas añade mods de Chronomancy).",
                tip: "Aldur's Legacy destruye un Unique Kalguuran o Ezomyte y forja una runa que hereda parte de sus mods (variantes como Passion/Breath/Ire of Aldur). Cadigan's Epiphany convierte todos los sockets de Rune del item en un único socket de Joya."
            }
        ]
    },
    {
        title: "Soul Cores",
        color: "#4a6a9a",
        orbs: [
            {
                name: "Soul Core",
                applies: "Socket de Rune/Augment (arma, armadura, casco, guantes, botas, escudo/foco)",
                effect: "Socketable mucho más potente que una Rune normal: bonus fuertes y a menudo build-defining (escalado de ailments, crítico, generación de cargas, penetración, conversión de daño, resistencias, recoup...). El efecto cambia según si se coloca en arma o en armadura.",
                tip: "Se obtienen sobre todo del Trial of Chaos (Inscribed Ultimatums) — mínimo 1 garantizada por run, más en Ultimatums de nivel alto; las rondas 4, 7 y 10 siempre ofrecen una como recompensa."
            },
            {
                name: "Core Destabiliser",
                applies: "Soul Core",
                effect: "Intenta mejorar una Soul Core a Ancient Soul Core (mucho más fuerte). Riesgo real de destruir la Soul Core en el intento.",
                tip: "Se encuentra en el Templo de Atziri. Solo puedes llevar un Ancient Augment por personaje — Ancient Soul Core y Abyssal Eye son mutuamente excluyentes."
            },
            {
                name: "Orb of Extraction",
                applies: "Item con Soul Core socketeada",
                effect: "Recupera la Soul Core de un item, destruyendo el item en el proceso.",
                tip: "Útil para recuperar una Soul Core cara antes de descartar o reemplazar el item que la lleva."
            }
        ]
    }
]

.pragma library

var GUIDES = [
    {
        id: "campaign_vs_endgame",
        title: "Campaña vs. Endgame: cuándo craftear",
        category: "Progresión",
        categoryColor: "#7aaa6a",
        difficulty: "Beginner",
        summary: "Qué currency guardar, qué gastar y cuándo merece la pena invertir en craftear.",
        sections: [
            {
                heading: "Durante la campaña (Actos 1–4)",
                content: "No merece la pena invertir currency seria en gear de campaña. El gear que usas en el Acto 2 quedará obsoleto en el Acto 3. Equipa lo que caiga al suelo o usa Transmutation + Augmentation en buenas bases para tener algo funcional.",
                steps: [],
                tips: [
                    "USA libremente: Transmutation, Augmentation, Armourer's Scrap, Whetstone — son abundantes y no valen mucho",
                    "GUARDA siempre: Exalted Orbs, Divine Orbs, Fracturing Orbs, Essences, Omens — son endgame",
                    "Las Essences son la excepción: úsalas en el Acto 3–4 si necesitas un slot específico que no puedes cubrir con drops"
                ]
            },
            {
                heading: "Transición al endgame (primeros mapas)",
                content: "Al entrar al Atlas con los primeros Waystones tu gear de campaña se queda corto rápido. Aquí empieza el crafteo real. Busca bases de ilvl 60–70 y empieza a usar Essences para piezas que te duelen (resistencias rotas, vida baja).",
                steps: [],
                tips: [
                    "Cierra las resistencias primero — sin el cap de res (75%) morirás mucho en mapas",
                    "Un Exalted Orb en un item de ilvl 55 es currency tirada — espera a tener bases ilvl 75+"
                ]
            },
            {
                heading: "Endgame establecido (T10+ Waystones)",
                content: "Aquí ya merece la pena el crafteo completo: base ilvl 75+, Essence para mod garantizado, Exalteds para rellenar, Chaos + Omens para ajustar, Divine para maximizar. Empieza a farmear las bases correctas en lugar de usar lo primero que caiga.",
                steps: [],
                tips: [
                    "No gastes Divine Orbs en items que no tienen todos los mods correctos — primero consigue los mods, luego optimiza valores",
                    "Fracturing Orb vale la pena cuando tienes T1 en el mod más importante del item",
                    "A partir de aquí el trade también es una opción válida — a veces comprar una base buena es más barato que farmearla"
                ]
            },
            {
                heading: "Regla de oro: el coste de oportunidad",
                content: "Antes de gastar currency en un item pregúntate: ¿Voy a usar este item durante más de 10 mapas? Si la respuesta es no, usa solo currency barata (Transmutation, Augmentation). Si es sí, invierte. Si llevas 20+ horas en el mismo item, ese es el momento de gastar Divines y Fracturing Orbs.",
                steps: [],
                tips: [
                    "Un item 'bueno pero no perfecto' con el que farmeas más currency para craftear el perfecto es siempre mejor que quedarte sin resources",
                    "Desenchanta (Salvage) todo el gear que no uses — los shards de currency suman con el tiempo"
                ]
            }
        ]
    },
    {
        id: "liquid_emotions",
        title: "Liquid Emotions y Anointment de Amuletos",
        category: "Mecánicas",
        categoryColor: "#9a6aaa",
        difficulty: "Intermediate",
        summary: "Cómo anotar un Notable pasivo en tu amuleto y cómo añadir Delirium a Waystones.",
        sections: [
            {
                heading: "Qué son las Liquid Emotions",
                content: "Antes llamadas Distilled Emotions. Currency de endgame obtenida en encuentros de Delirium. Tienen dos usos: anotar un Notable pasivo en un Amuleto (permanente) o añadir modificadores de Delirium a un Waystone.",
                steps: [],
                tips: [
                    "Se obtienen principalmente dentro de la niebla de Delirium en mapas — cuanto más tiempo aguantes dentro, más drops",
                    "Son currency de endgame — no las gastes en amuletos que vas a cambiar pronto"
                ]
            },
            {
                heading: "Anointment en Amuleto",
                content: "Aplicar una Liquid Emotion a un amuleto otorga permanentemente un Notable Pasivo del árbol — como si hubieras asignado ese punto, pero sin coste de pasiva. El Notable depende del tipo de Liquid Emotion que uses. Una vez aplicado no se puede cambiar sin una nueva Liquid Emotion.",
                steps: [],
                tips: [
                    "El anointment es UNO por amuleto — elige el Notable más impactante para tu build",
                    "Busca Notables que estén lejos de tu posición en el árbol pasivo — los que están cerca ya los cogerías normalmente"
                ]
            },
            {
                heading: "Cómo elegir el Notable correcto",
                content: "Cada tipo de Liquid Emotion corresponde a una región del árbol pasivo: Desolation → daño de caos. Isolation → defensa. Anguish → ataque físico. Contempt → crítico. Dread → velocidad de movimiento/ataque. Fear → magia y hechizos. Guilt → minions. Hatred → elemental. Loathing → resistencias y atributos. Paranoia → life y regeneración. Rage → daño de área. Torment → mana y energy shield.",
                steps: [],
                tips: [
                    "Para casters: Fear (hechizos) o Torment (ES/Mana) suelen dar los mejores Notables",
                    "Para builds de ataque físico: Anguish o Contempt (crítico)",
                    "Para builds de minions: Guilt",
                    "Consulta la wiki o el árbol pasivo in-game antes de aplicar — el Notable específico depende de cuál escoges dentro de esa categoría"
                ]
            },
            {
                heading: "Uso en Waystones (Delirium)",
                content: "Aplicar Liquid Emotions a un Waystone añade modificadores de Delirium al mapa: más niebla, más monstruos de Delirium, y recompensas específicas según el tipo. Ideal para farmear un tipo de item concreto (armas, armaduras, currency, etc.).",
                steps: [],
                tips: [
                    "Combina Liquid Emotions en Waystones con Catalysts de Breach para una sesión de farmeo muy optimizada",
                    "Los Waystones con Delirium son más difíciles — asegúrate de tener gear suficiente antes de meter múltiples modificadores"
                ]
            }
        ]
    },
    {
        id: "example_chest",
        title: "Ejemplo: Pecho Defensivo (Body Armour)",
        category: "Ejemplo",
        categoryColor: "#6a9aaa",
        difficulty: "Intermediate",
        summary: "Crafteo de un pecho Rare con Life o Energy Shield + Resistencias. El slot más importante del personaje.",
        sections: [
            {
                heading: "Objetivo final",
                content: "Pecho Rare con: +(85–120) to maximum Life (o Energy Shield alto si juegas ES) · +(25–35)% a dos o tres Resistencias · % increased Armour/ES/Evasion. El pecho es el slot con más impacto en survivability — merece la mayor inversión.",
                steps: [],
                tips: [
                    "Un buen pecho puede compensar deficiencias en otros slots — priorízalo sobre guantes o casco",
                    "Decide ANTES de empezar si quieres Life build o ES build — las bases son distintas"
                ]
            },
            {
                heading: "Elegir la base",
                content: "Life build (STR): Crusader Plate, Astral Plate — alta Armour base, requiere STR. Evasion build (DEX): Zodiac Leather, Varnished Coat — alta Evasion base. ES build (INT): Vaal Regalia, Occultist's Vestment — alto ES base. Híbrido popular: Armour+ES (STR/INT) o Evasion+ES (DEX/INT). ilvl 75+ obligatorio.",
                steps: [],
                tips: [
                    "Asegúrate de que puedes cumplir el requisito de atributo de la base — un pecho que no puedes equipar no sirve de nada",
                    "Las bases de mayor tier tienen más defensa base — dentro del mismo tipo, siempre la base más alta que puedas usar"
                ]
            },
            {
                heading: "Material necesario",
                content: "Base ilvl 75+ del tipo correcto ×3. Armourer's Scrap ×4. Essence of the Body (Greater: +(85–99) Life) o Essence of the Mind (Greater: +(90–104) ES para builds de ES). Exalted Orbs ×3. Chaos Orb + Omen of Whittling ×2. Divine Orb ×1. Artificer's Orb ×1.",
                steps: [],
                tips: []
            },
            {
                heading: "Pasos",
                content: "",
                steps: [
                    { n: 1, action: "Armourer's Scrap al 20% de calidad", detail: "En estado Normal. La calidad en el pecho aumenta directamente el valor de Armour, Evasion o ES base." },
                    { n: 2, action: "Essence of the Body (Greater) → Rare", detail: "Garantiza +(85–99) to maximum Life. Para ES builds usa Essence of the Mind. Los mods restantes (3) son aleatorios — busca que salga alguna Resistencia." },
                    { n: 3, action: "Evalúa los 3 mods aleatorios", detail: "Ideal: 2+ Resistencias entre los mods aleatorios. Aceptable: 1 Resistencia + 1 mod defensivo. Malo: todo ofensivo o mods completamente inútiles → repite con otra base." },
                    { n: 4, action: "Rellena Resistencias con Exalted Orbs", detail: "Añade Fire, Cold o Lightning Resistance (sufijos) en los huecos libres. Si ya tienes 3 sufijos pero son malos, no puedes añadir más — necesitarás Annulment primero." },
                    { n: 5, action: "% increased Armour/ES con Exalted (prefijo)", detail: "Si tienes hueco de prefijo libre, añade un mod de % increased defensa. Aumenta el valor base de la defensa del pecho." },
                    { n: 6, action: "Elimina el mod más inútil", detail: "Chaos Orb + Omen of Whittling para el peor mod. En un pecho, mods como Mana o Accuracy suelen ser los candidatos a eliminar." },
                    { n: 7, action: "Divine Orb para maximizar", detail: "Optimiza Life (o ES), Resistencias y % defensa. En el pecho el rango entre min y max de Life puede ser grande — el Divine tiene mucho impacto aquí." },
                    { n: 8, action: "Artificer's Orb + Rib Abyss", detail: "Añade socket para Body Rune (Life leech en arma / +Life en armadura). Luego Rib Ancient para mod Desecrado si aún tienes huecos de affix libres." }
                ],
                tips: [
                    "Si en el paso 3 salieron 0 Resistencias pero la Life está bien, puedes continuar — cubre las resistencias en anillos y cinturón",
                    "Perfect Essence of the Body en un pecho que ya tiene buenos mods pero Life baja es una opción de endgame para refinar sin rehacer todo"
                ]
            }
        ]
    },
    {
        id: "example_ring",
        title: "Ejemplo: Anillo de Resistencias + Vida",
        category: "Ejemplo",
        categoryColor: "#3aaa8a",
        difficulty: "Beginner",
        summary: "Crafteo concreto de un anillo Rare con All Elemental Resistances, Life y un mod ofensivo.",
        sections: [
            {
                heading: "Objetivo final",
                content: "Anillo Rare con: +(70–85) to maximum Life · +(25–35)% to All Elemental Resistances · un tercer mod útil (Accuracy, Added Damage, Attribute). Ideal para cerrar resistencias en cualquier build.",
                steps: [],
                tips: ["Este anillo es el más versátil del juego — sirve para cualquier build que necesite resistencias"]
            },
            {
                heading: "Material necesario",
                content: "Base: Two-Stone Ring ilvl 75+ (implicit: +12–16% a dos resistencias — el mejor implicit para este objetivo). Prismatic Catalyst ×4. Essence of the Body (Standard o Greater). Exalted Orbs ×2–3. Chaos Orb + Omen of Whittling (si sale un mod malo). Divine Orb ×1 (opcional, para optimizar).",
                steps: [],
                tips: ["Two-Stone Ring es mejor que Coral Ring para este objetivo porque su implicit ya cubre 2 resistencias", "Coge 3–4 copias de la base — a veces la Essence no da buenos mods adicionales"]
            },
            {
                heading: "Pasos",
                content: "",
                steps: [
                    { n: 1, action: "Aplica Prismatic Catalyst ×4", detail: "Sube la calidad al máximo sesgada hacia mods de Resistencias. Hazlo en estado Normal. La calidad amplificará los % de resistencias que salgan." },
                    { n: 2, action: "Usa Essence of the Body (Standard)", detail: "Garantiza +(70–84) to maximum Life en el anillo al convertirlo a Rare. Los otros 3 mods salen aleatorios — busca que alguno sea All Resistances, Fire, Cold o Lightning Resistance." },
                    { n: 3, action: "Evalúa el resultado", detail: "¿Salió alguna resistencia en los mods aleatorios? Si tienes Life garantizada + 1 resistencia buena → sigue. Si los 3 mods aleatorios son inútiles → repite con otra base." },
                    { n: 4, action: "Añade All Elemental Resistances con Exalted Orb", detail: "Si el anillo tiene hueco libre, usa Exalted Orb buscando '% to All Elemental Resistances'. Si ya tiene este mod, usa Exalted para añadir el tercer mod útil." },
                    { n: 5, action: "Elimina mods malos", detail: "Si hay un mod inútil (p.ej. Mana Regeneration cuando no lo necesitas), usa Chaos Orb + Omen of Whittling para borrar el peor mod y añadir uno nuevo." },
                    { n: 6, action: "Prismatic Catalyst (si se gastó la calidad)", detail: "Algunos procesos de crafteo consumen calidad. Re-aplica Catalyst si es necesario." },
                    { n: 7, action: "Divine Orb (opcional)", detail: "Si todos los mods son buenos pero los valores son bajos, un Divine Orb maximiza los % de resistencias y la vida dentro del tier." },
                    { n: 8, action: "Collarbone Abyss (endgame)", detail: "Aplica Collarbone Ancient si quedan huecos de mod libres o quieres un mod Desecrado único adicional. Revela en el Well of Souls." }
                ],
                tips: ["Si Orb of Annulment borra el Life — mala suerte, vuelve al paso 2 con otra base", "No gastes Divine en un anillo que no tenga todos los mods que buscas — primero consigue los mods, después optimiza valores"]
            }
        ]
    },
    {
        id: "example_boots",
        title: "Ejemplo: Botas con Movement Speed garantizado",
        category: "Ejemplo",
        categoryColor: "#6a9aaa",
        difficulty: "Beginner",
        summary: "Botas Rare con 30% Movement Speed garantizado usando Essence of Hysteria + Life + Resistencias.",
        sections: [
            {
                heading: "Objetivo final",
                content: "Botas Rare con: 30% increased Movement Speed (garantizado) · +(70–99) to maximum Life · +(21–35)% a una o dos Resistencias. El Movement Speed es el mod más buscado en botas — sin él las botas no son endgame.",
                steps: [],
                tips: ["30% Movement Speed de Essence of Hysteria es el tier más alto posible en botas — no necesitarás Divine para este mod"]
            },
            {
                heading: "Material necesario",
                content: "Base: cualquier botas ilvl 75+ que encaje con tu tipo de defensa (Armour/Evasion/ES según build). Armourer's Scrap ×4. Essence of Hysteria (garantiza 30% Movement Speed en botas). Exalted Orbs ×2–3. Chaos Orb + Omen of Sinistral o Dextral Erasure (si sale un mod muy malo). Divine Orb ×1 (para Life y Resistencias).",
                steps: [],
                tips: ["Essence of Hysteria puede ser cara — cómprala en el trade si no la encuentras drops", "Guarda siempre al menos 3 copias de la base por si los mods aleatorios son malos"]
            },
            {
                heading: "Pasos",
                content: "",
                steps: [
                    { n: 1, action: "Armourer's Scrap × calidad 20%", detail: "Aplica en estado Normal para máxima eficiencia. La calidad aumenta el valor de Armour/Evasion/ES base de las botas." },
                    { n: 2, action: "Essence of Hysteria → Rare", detail: "Garantiza exactamente '30% increased Movement Speed' como mod en las botas. Los otros 3 mods son aleatorios. Este es el mod más importante — ya está asegurado." },
                    { n: 3, action: "Evalúa mods aleatorios", detail: "Busca que salgan Life y al menos una Resistencia entre los 3 mods aleatorios. Si salieron 2+ mods útiles → excelente, sigue. Si los 3 son inútiles → repite con otra base." },
                    { n: 4, action: "Rellena con Exalted Orbs", detail: "Añade Life con Exalted si no salió, o una Resistencia. Controla si necesitas prefix o suffix antes de tirar (Life es prefix, Resistencias son suffix)." },
                    { n: 5, action: "Elimina el mod más inútil", detail: "Si hay un mod que no necesitas (p.ej. Mana o Accuracy en boots), usa Chaos Orb + Omen of Whittling. O Omen of Dextral/Sinistral Erasure si sabes qué tipo es el mod malo." },
                    { n: 6, action: "Divine Orb para maximizar", detail: "Optimiza los valores de Life y Resistencias. El Movement Speed ya está al máximo tier — el Divine no lo afecta." },
                    { n: 7, action: "Artificer's Orb para socket", detail: "Añade socket para Iron Rune (Armour) o Body Rune (Life) según tu tipo de defensa." },
                    { n: 8, action: "Rib Abyss (opcional, endgame)", detail: "Aplica Rib Ancient para añadir un mod Desecrado de armadura. Los mods Abyss en botas pueden incluir bonuses únicos de movimiento o recuperación." }
                ],
                tips: ["Movement Speed en botas es SIEMPRE prefijo — si ves que ya tienes 3 prefijos y no está el Mov Speed, algo salió mal", "Si el resultado tiene Mov Speed + Life + 1 resistencia ya es una bota usable — no la deseches aunque no sea perfecta"]
            }
        ]
    },
    {
        id: "example_amulet",
        title: "Ejemplo: Amuleto Caster (Hechizos)",
        category: "Ejemplo",
        categoryColor: "#9a6aaa",
        difficulty: "Intermediate",
        summary: "Amuleto Rare para build de hechizos con Life, Spell Damage o +Skills, y anointment con Liquid Emotions.",
        sections: [
            {
                heading: "Objetivo final",
                content: "Amuleto Rare con: +(85–99) to maximum Life · % increased Spell Damage o +# to Level of all [tipo] Skills · % increased Cast Speed o Resistencia. Anointado con un Notable del árbol pasivo relevante para tu build.",
                steps: [],
                tips: ["+# to Level of all Skills en amuleto es uno de los mods más poderosos del juego para casters — duplica el nivel efectivo de tus gemas"]
            },
            {
                heading: "Elegir la base",
                content: "Marble Amulet: implicit de Life Regeneration — bueno para builds con poca regeneración. Gold Amulet: implicit de Item Rarity — bueno para farmeo. Lapis Amulet: implicit de +Intelligence — bueno para casters INT. Jade Amulet: implicit de +Dexterity. Amber Amulet: implicit de +Strength. Ilvl 75+ en todos los casos.",
                steps: [],
                tips: ["Para un caster puro, Lapis Amulet (INT) o Marble Amulet son las mejores bases"]
            },
            {
                heading: "Material necesario",
                content: "Base de amuleto ilvl 75+. Catalyst relevante ×4 (Turbulent para Spell Damage, Fertile para Life, Intrinsic para Atributos). Essence of the Body (Greater o Perfect) para Life garantizada. Exalted Orbs ×2–3. Chaos Orb + Omen of Whittling/Erasure. Liquid Emotions para anointment. Divine Orb (opcional).",
                steps: [],
                tips: []
            },
            {
                heading: "Pasos",
                content: "",
                steps: [
                    { n: 1, action: "Aplica Catalyst ×4", detail: "Turbulent Catalyst si priorizas Spell Damage. Fertile si priorizas Life. Intrinsic si necesitas Atributos. Aplica en estado Normal." },
                    { n: 2, action: "Essence of the Body (Greater) → Rare", detail: "Garantiza +(85–99) to maximum Life en el amuleto. La vida es el mod más difícil de conseguir de otra forma en un amuleto con buenos mods — asegúralo aquí." },
                    { n: 3, action: "Evalúa mods aleatorios", detail: "Busca que salga Spell Damage, +Level of Skills, Cast Speed, o una Resistencia importante. Si salieron 2 mods buenos → sigue. Si los mods son todos inútiles → repite." },
                    { n: 4, action: "Añade mod ofensivo con Exalted Orb", detail: "Si no salió Spell Damage ni +Skills, usa Exalted buscando uno de estos. Son prefix — comprueba que tengas espacio de prefijo libre." },
                    { n: 5, action: "Añade Cast Speed o Resistencia con Exalted", detail: "Rellena el último hueco con Cast Speed (suffix) o una resistencia que te falte." },
                    { n: 6, action: "Elimina mods inútiles", detail: "Si hay un mod irrelevante (p.ej. Mana Regeneration Rate siendo un mod muy pequeño), usa Chaos + Omen of Whittling." },
                    { n: 7, action: "Divine Orb para maximizar", detail: "Optimiza los valores de Spell Damage, Life y cualquier otro mod numérico." },
                    { n: 8, action: "Anointment con Liquid Emotions", detail: "Elige el Notable pasivo más impactante para tu build. Este anointment es permanente — investiga bien qué Notable quieres antes de aplicarlo. Ejemplos para casters: nodos de Spell Damage, Cast Speed, o penetración." }
                ],
                tips: ["El anointment con Liquid Emotions es lo que hace el amuleto realmente poderoso — un Notable del árbol pasivo gratis sin gastar puntos", "Perfect Essence of the Body puede usarse en un amuleto ya Rare para reemplazar un mod malo por Life garantizada — muy útil si tienes todos los otros mods buenos pero la vida es baja"]
            }
        ]
    },
    {
        id: "jewelry",
        title: "Craftear Joyería (Anillo, Amuleto, Cinturón)",
        category: "Joyería",
        categoryColor: "#3aaa8a",
        difficulty: "Intermediate",
        summary: "Cómo craftear accesorios para cerrar resistencias y stats clave. Incluye Catalysts y Liquid Emotions.",
        sections: [
            {
                heading: "1. Mods objetivo por pieza",
                content: "Anillos: to Fire/Cold/Lightning/All Elemental Resistances, to Maximum Life, Accuracy Rating, Attributes, Added Damage to Attacks. Amuleto: igual que anillos + posibilidad de anointment con Liquid Emotions para ganar un Notable del árbol pasivo sin gastar puntos. Cinturón: Maximum Life, Resistances, Strength, Flask Charges Generated, Stun Threshold.",
                steps: [],
                tips: ["Los anillos son el slot más fácil para cerrar resistencias — prioriza All Elemental Resistances si tienes hueco", "El amuleto es uno de los slots más poderosos — busca uno con implicit útil para tu build antes de craftear"]
            },
            {
                heading: "2. Catalysts (Breach)",
                content: "Los Catalysts aumentan la calidad de Anillos y Amuletos sesgando el efecto hacia un tipo de mod. Prismatic Catalyst → mods de Resistencias Elementales (el más usado). Fertile Catalyst → mods de Vida y Mana. Abrasive Catalyst → mods de Ataque. Intrinsic Catalyst → mods de Atributos. Turbulent Catalyst → mods de Daño Elemental. Unstable Catalyst → mods de Crítico. Tempering Catalyst → mods de Defensa.",
                steps: [],
                tips: ["Aplica el Catalyst ANTES de modificar el item — la calidad se aplica sobre los mods existentes", "Prismatic Catalyst es el más valioso en el mercado — úsalo solo si vas a quedarte el accesorio"]
            },
            {
                heading: "3. Ruta de crafteo",
                content: "",
                steps: [
                    { n: 1, action: "Elige base con buen implicit", detail: "Cada base de anillo/amuleto tiene un implicit distinto. Busca el que se ajuste a tu build (p.ej. Coral Ring → Life, Sapphire Ring → Cold Resistance)." },
                    { n: 2, action: "Aplica Catalyst para calidad", detail: "Usa el Catalyst relevante para tu build antes de empezar a craftear. La calidad amplifica los mods del tipo elegido." },
                    { n: 3, action: "Essence para un mod garantizado", detail: "Usa la Essence correspondiente al stat que más necesitas. Las Essences de resistencias son las más habituales para joyería." },
                    { n: 4, action: "Rellena huecos con Exalted Orb", detail: "Añade los mods que faltan. En joyería suelen buscar: resistencias + vida + un mod ofensivo o de utilidad." },
                    { n: 5, action: "Ajusta mods malos", detail: "Chaos Orb + Omen of Whittling o Omen of Sinistral/Dextral Erasure para eliminar el mod menos útil." },
                    { n: 6, action: "Optimiza con Divine Orb", detail: "Solo si todos los mods son correctos. En joyería el Divine es especialmente valioso para maximizar resistencias." },
                    { n: 7, action: "Abyss con Collarbone (opcional)", detail: "Aplica Collarbone Ancient para añadir un mod Desecrado oculto. Revela en el Well of Souls." },
                    { n: 8, action: "Liquid Emotions (amuleto)", detail: "Si es un amuleto, usa Liquid Emotions para anotar un Notable del árbol pasivo. Muy poderoso — elige el notable que más impacte tu build." }
                ],
                tips: []
            },
            {
                heading: "4. Collarbone de Abyss",
                content: "El Collarbone (Jawbone para armas, Rib para armadura) es exclusivo de Anillos, Amuletos y Cinturones. Los mods Abyss para accesorios incluyen opciones únicas como bonificaciones de resistencias, regeneración, o efectos especiales que no existen en el pool normal.",
                steps: [],
                tips: ["Ancient Collarbone requiere nivel 40+ — úsalo en items de endgame", "El Preserved Cranium es para Joyas (Jewels), no para accesorios"]
            }
        ]
    },
    {
        id: "armor",
        title: "Craftear Armadura (Pecho, Casco, Guantes, Botas)",
        category: "Armadura",
        categoryColor: "#6a9aaa",
        difficulty: "Intermediate",
        summary: "Guía para craftear piezas defensivas con Vida, ES, Evasion o Armour según tu build.",
        sections: [
            {
                heading: "1. Elegir la base según tu build",
                content: "Cada tipo de armadura da un tipo de defensa base: Armour puro (rojo, STR) → reducción de daño físico. Evasion puro (verde, DEX) → esquiva ataques. Energy Shield puro (azul, INT) → escudo de maná antes de vida. Armour/Evasion, Armour/ES, Evasion/ES → híbridos. Elige la base que cuadre con los nodos defensivos de tu árbol pasivo.",
                steps: [],
                tips: ["Un ilvl 75+ asegura acceso a los tiers más altos de Vida y Energy Shield", "Las bases híbridas (Armour/Evasion etc.) tienen menos defensa base pero más flexibilidad en mods"]
            },
            {
                heading: "2. Mods objetivo por slot",
                content: "Pecho (Body Armour): Maximum Life / Energy Shield (prefijo más valioso), Resistencias (sufijos), % increased Armour/ES/Evasion. Casco: Life/ES, Resistencias, Accuracy Rating. Guantes: Life/ES, Attack Speed o Cast Speed, Resistencias, Accuracy. Botas: Life/ES, % increased Movement Speed (el prefijo más buscado en botas), Resistencias.",
                steps: [],
                tips: ["Movement Speed en botas es casi obligatorio para endgame — búscalo como prefijo principal", "El pecho es el slot con mayor impacto en survivability — invierte más recursos aquí"]
            },
            {
                heading: "3. Calidad primero",
                content: "Usa Armourer's Scrap antes de subir de rareza. La calidad aumenta el valor de la defensa base (Armour, Evasion o Energy Shield).",
                steps: [],
                tips: ["Aplica quality en estado Normal — obtienes más % por scrap que en items de mayor rareza"]
            },
            {
                heading: "4. Ruta de crafteo",
                content: "",
                steps: [
                    { n: 1, action: "Calidad al 20% con Armourer's Scrap", detail: "Hazlo en estado Normal para mayor eficiencia de scraps." },
                    { n: 2, action: "Essence para mod garantizado", detail: "Essence of Iron (Armour), Essence of the Body (Life), Essence of the Mind (ES) según tu necesidad principal." },
                    { n: 3, action: "Evalúa y rellena con Exalted Orbs", detail: "Añade los mods que faltan. Prioriza: Vida/ES + Resistencias + stat ofensivo secundario." },
                    { n: 4, action: "Elimina mods inútiles", detail: "Chaos Orb + Omen of Whittling. Para botas: si no salió Movement Speed, puede valer la pena volver a intentar desde el paso 2 con otra base." },
                    { n: 5, action: "Divine Orb para valores", detail: "Especialmente útil en Life y ES donde la diferencia entre el mínimo y máximo del tier es grande." },
                    { n: 6, action: "Añade socket con Artificer's Orb", detail: "Coloca Runes defensivas — Body Rune para Life, Iron Rune para Armour." },
                    { n: 7, action: "Abyss con Rib (opcional)", detail: "Aplica un Rib Ancient para añadir un mod Desecrado. Los mods Abyss para armaduras incluyen bonuses defensivos únicos." },
                    { n: 8, action: "Corrompe (opcional)", detail: "La corrupción en armadura puede añadir implícitos poderosos como resistencias adicionales o bonuses de Life. Solo en items ya muy buenos." }
                ],
                tips: []
            }
        ]
    },
    {
        id: "waystones",
        title: "Craftear Waystones (Maps)",
        category: "Endgame",
        categoryColor: "#c4903a",
        difficulty: "Beginner",
        summary: "Cómo modificar Waystones para maximizar drops y experiencia en endgame.",
        sections: [
            {
                heading: "¿Por qué craftear Waystones?",
                content: "Un Waystone sin modificar es básicamente un mapa vacío. Añadiendo mods aumentas Item Quantity (más items drops), Item Rarity (mejor calidad de drops), Pack Size (más monstruos) y dificultad general. A mayor dificultad aceptada, más recompensas.",
                steps: [],
                tips: ["La mayoría de jugadores de endgame corren solo Waystones Rare — Normal y Magic no compensan el tiempo invertido"]
            },
            {
                heading: "Mods buenos vs. mods peligrosos",
                content: "Buenos: % increased Item Quantity, % increased Item Rarity, % increased Pack Size, Monsters drop additional Currency, Rare Monsters drop additional items. Peligrosos pero aceptables: Monsters have X% increased Life, Monsters deal X% increased Damage. Evitar si no tienes buen gear: Players have -max Resistances, Players are Cursed with [efecto fuerte], No Life/Mana recovery.",
                steps: [],
                tips: ["Con el tiempo aprenderás qué mods puedes ignorar con tu build — al principio evita los que anulan resistencias", "Los mods de 'additional Currency drops' y 'Pack Size' son los más valiosos económicamente"]
            },
            {
                heading: "Ruta de crafteo",
                content: "",
                steps: [
                    { n: 1, action: "Orb of Transmutation → Magic (1 mod)", detail: "Convierte el Waystone Normal a Magic. Comprueba si el mod es bueno o neutro." },
                    { n: 2, action: "Orb of Augmentation → Magic (2 mods)", detail: "Añade un segundo mod al Magic. Si los dos mods son aceptables, sigue." },
                    { n: 3, action: "Regal Orb → Rare (3 mods)", detail: "Sube a Rare para acceder a más mods. Los Waystones Rare son el estándar de endgame." },
                    { n: 4, action: "Exalted Orb para más mods", detail: "Añade 1-2 mods más al Rare. Busca Item Quantity y Pack Size." },
                    { n: 5, action: "Si salió un mod muy peligroso", detail: "Usa Orb of Annulment para eliminar el peor mod, o descarta ese Waystone y empieza con otro." }
                ],
                tips: ["Guarda los Waystones de tier alto (T14+) para correrlos con máximos mods — no los gastes en vacío", "Los Waystones Rare con Pack Size + IQ + IR son los más rentables aunque sean más difíciles"]
            },
            {
                heading: "Abyss en Waystones",
                content: "El Preserved Vertebrae añade un mod Desecrado a un Waystone Rare. Los mods Abyss para Waystones pueden incluir efectos de encontrar más abismos, más monstruos abisales o mejores recompensas de Abyss encounters.",
                steps: [],
                tips: ["Muy útil si quieres farmear Abyssal Bones o loot de Abyss", "Combina con Liquid Emotions para añadir también modificadores de Delirium al mapa"]
            },
            {
                heading: "Liquid Emotions (Delirium en Waystones)",
                content: "Las Liquid Emotions se pueden aplicar a Waystones para añadir modificadores de Delirium: más niebla, más monstruos Delirium, mejores recompensas específicas de Delirium. Elige el tipo de Liquid Emotion según el loot que busques.",
                steps: [],
                tips: ["Las Liquid Emotions de Armour, Weapons o Currency amplifican los drops de esa categoría en el mapa"]
            }
        ]
    },
    {
        id: "flasks",
        title: "Craftear Flasks",
        category: "General",
        categoryColor: "#7aaa6a",
        difficulty: "Beginner",
        summary: "Cómo conseguir los mods correctos en tus flasks para máxima utilidad y resistencia a status.",
        sections: [
            {
                heading: "Por qué importan los flasks",
                content: "Un flask bien rolleado puede marcar la diferencia entre morir o no morir. Los sufijos de Immunity eliminan status negativos (Freeze, Bleed, Poison, Shock, Curses) que de otro modo te matarían. Los prefijos aumentan la cantidad o velocidad de recuperación.",
                steps: [],
                tips: ["Tener al menos 2 flasks con sufijos de Immunity es prácticamente obligatorio en endgame"]
            },
            {
                heading: "Calidad con Glassblower's Bauble",
                content: "Aplica Glassblower's Bauble para subir la calidad del flask al 20%. La calidad aumenta la cantidad recuperada (Life/Mana) o la duración del efecto según el tipo de flask.",
                steps: [],
                tips: ["Aplica la calidad en estado Normal para mayor eficiencia de Baubles"]
            },
            {
                heading: "Prefijos clave",
                content: "Surgeon's: recarga cargas al hacer un Critical Strike — ideal para builds de crítico. Chemist's: el flask usa menos cargas por uso — más usos por pack. Perpetual: genera cargas continuamente durante el efecto. Ample: comienza con el máximo de cargas. Concentrated: mayor efecto pero menor duración.",
                steps: [],
                tips: ["Surgeon's es el mejor prefijo para builds de crítico — prácticamente infinito en endgame", "Chemist's o Perpetual son mejores para builds sin crítico"]
            },
            {
                heading: "Sufijos clave (Immunities)",
                content: "Of Heat: elimina e inmuniza a Freeze y Chill. Of Staunching: elimina e inmuniza a Bleed. Of Grounding: elimina e inmuniza a Shock. Of Dousing: elimina e inmuniza a Ignite. Of Warding: elimina e inmuniza a Curses. Of Antidoting: elimina e inmuniza a Poison. Of Iron Skin: aumenta Armour durante el efecto. Of Reflexes: aumenta Evasion durante el efecto.",
                steps: [],
                tips: ["Prioriza los Immunity sufijos según los status que más te maten en endgame", "Of Warding (Immunity a Curses) es muy útil en mapas con mods de Curse"]
            },
            {
                heading: "Ruta de crafteo",
                content: "",
                steps: [
                    { n: 1, action: "Consigue el tipo de flask correcto", detail: "Life Flask, Mana Flask o Utility Flask (Quicksilver, Granite, Jade, Bismuth...). Tier más alto que encuentres." },
                    { n: 2, action: "Calidad al 20% con Glassblower's Bauble", detail: "En estado Normal. Necesitarás varios Baubles — los da la campaña con frecuencia." },
                    { n: 3, action: "Orb of Transmutation → Magic", detail: "Convierte a Magic con 1 mod. Comprueba si es útil." },
                    { n: 4, action: "Orb of Augmentation → Magic (2 mods)", detail: "Añade el segundo mod. Si obtienes el prefijo y sufijo que buscabas, ¡listo!" },
                    { n: 5, action: "Si los mods no son buenos", detail: "Vuelve a Normal con Orb of Scouring... No existe en PoE2. Directamente usa otro flask base y repite." },
                    { n: 6, action: "Orb of Annulment si hay 1 mod malo", detail: "Si tienes el prefijo que buscas pero el sufijo es malo (o viceversa), usa Orb of Annulment para eliminar el mod malo. Riesgo: puede eliminar el bueno." }
                ],
                tips: ["Los flasks son baratos de craftear — si no sale en 3-4 intentos, coge otra base y repite", "En PoE2 no existe Orb of Scouring — si el flask quedó con mods malos usa otro flask base directamente"]
            }
        ]
    },
    {
        id: "weapon_physical",
        title: "Craftear un Arma Física (Attack)",
        category: "Armas",
        categoryColor: "#c47a3a",
        difficulty: "Intermediate",
        summary: "Guía paso a paso para craftear un arma física Rare para builds de ataque (Warrior, Ranger, Mercenary).",
        sections: [
            {
                heading: "1. Elegir la base",
                content: "Busca una base con ilvl 75+ para tener acceso a los tiers más altos de mods. Prioriza bases con buen DPS base (Physical Damage alto) y un implicit útil: Spiked Spear (Accuracy + Crit), Iron Greatsword / Reaver Sword (daño bruto), Glacial Hammer (Freeze chance). Para Rangers: Short Bow / Recurve Bow con alta velocidad de ataque.",
                steps: [],
                tips: ["El ilvl de la base determina el tier máximo de los mods que pueden salir — no craftees en bases de bajo nivel", "Consigue varias copias de la misma base para no quedarte sin material"]
            },
            {
                heading: "2. Calidad primero",
                content: "Aplica Blacksmith's Whetstone antes de subir de rareza para llegar al 20% de calidad. La calidad en armas físicas aumenta el Physical Damage del item.",
                steps: [],
                tips: ["La calidad aplica sobre el daño base del arma — en armas de ataque físico importa más que en otros slots"]
            },
            {
                heading: "3. Mods objetivo",
                content: "Prefijos clave (máx. 3): Adds # to # Physical Damage (el más valioso), % increased Physical Damage, Adds # to # Fire/Cold/Lightning Damage to Attacks. Sufijos clave (máx. 3): % increased Attack Speed, % increased Critical Hit Chance, % increased Critical Hit Multiplier, +# Accuracy Rating.",
                steps: [],
                tips: ["Prioriza 'Adds Physical Damage' como primer prefijo — es el mayor multiplicador de DPS", "Attack Speed es el sufijo más valioso para la mayoría de builds de ataque"]
            },
            {
                heading: "4. Ruta de crafteo",
                content: "",
                steps: [
                    { n: 1, action: "Essence para garantizar un mod", detail: "Usa una Essence de Rage (Attack Speed) o Greed (Physical Damage) sobre la base Normal. Obtienes el mod garantizado + mods aleatorios al pasar a Rare." },
                    { n: 2, action: "Evalúa el resultado", detail: "Si salieron 2+ mods buenos además del guaranteed, sigue adelante. Si es malo, repite con otra copia de la base." },
                    { n: 3, action: "Añade mods con Exalted Orb", detail: "Si te quedan huecos libres (menos de 6 mods), usa Exalted Orbs para rellenar. Antes comprueba si tienes espacio de prefix o suffix." },
                    { n: 4, action: "Elimina mods malos con Chaos + Omen", detail: "Chaos Orb elimina 1 mod y añade 1 nuevo. Combina con Omen of Whittling para que elimine el peor mod. Para control total: Omen of Sinistral/Dextral Erasure para borrar un prefix o suffix específico." },
                    { n: 5, action: "Optimiza valores con Divine Orb", detail: "Si todos los mods son buenos pero los valores son bajos, usa Divine Orb para rerollear los números dentro del rango del tier." },
                    { n: 6, action: "Fracturing Orb (opcional)", detail: "Si tienes el mod más importante (p.ej. 'Adds 80-120 Physical Damage'), usa Fracturing Orb para bloquearlo antes de seguir modificando." },
                    { n: 7, action: "Añade socket con Artificer's Orb", detail: "Agrega un socket y coloca una Iron Rune o Soul Core relevante para tu build." },
                    { n: 8, action: "Corrompe (opcional, endgame)", detail: "Solo si el arma ya es casi perfecta. Usa Hinekora's Lock para previsualizar el resultado del Vaal Orb antes de aplicarlo." }
                ],
                tips: []
            },
            {
                heading: "5. Abyss (avanzado)",
                content: "Aplica un Jawbone (Ancient tier para endgame) al arma para añadir un mod Desecrado oculto. Lleva el arma al Well of Souls y elige entre 3 opciones de mod Abyss — suelen ser mods únicos que no puedes conseguir de otra forma.",
                steps: [],
                tips: ["Los mods Abyss para armas incluyen opciones como 'Hits Penetrate Resistance' o 'Gain Onslaught on Kill' — únicos y muy poderosos", "El Jawbone Ancient requiere nivel 40+ y permite ilvl máximo"]
            }
        ]
    },
    {
        id: "weapon_spell",
        title: "Craftear un Arma de Hechizo (Caster)",
        category: "Armas",
        categoryColor: "#9a6aaa",
        difficulty: "Intermediate",
        summary: "Guía para craftear Staff, Wand o Sceptre para builds de hechizos (Sorceress, Witch, Monk).",
        sections: [
            {
                heading: "1. Elegir la base",
                content: "Staff: implícito de 60% increased Spell Damage + 5 sockets de soporte — la mejor opción para casters que no necesitan escudo. Wand: mayor velocidad de ataque / cast speed, buen implicit de Spell Damage. Sceptre: equilibrio entre daño y bonuses de minions/atributos, ideal para Witch. Busca ilvl 75+ en todos los casos.",
                steps: [],
                tips: ["Staff da el mayor Spell Damage base pero ocupa las dos manos — no puedes llevar escudo", "Wand + Escudo es mejor para survivability, Staff es mejor para daño puro"]
            },
            {
                heading: "2. Calidad primero",
                content: "Usa Arcanist's Etcher (equivalente al Whetstone para armas de caster) antes de subir de rareza para llegar al 20% de calidad.",
                steps: [],
                tips: []
            },
            {
                heading: "3. Mods objetivo",
                content: "Prefijos clave: % increased Spell Damage, Adds # to # [element] Damage to Spells, +# to Level of all [Skill type] Skills (muy valioso — afecta a todas las gemas de esa categoría). Sufijos clave: % increased Cast Speed, % increased Critical Hit Chance for Spells, % increased Critical Hit Multiplier for Spells, +# to Maximum Mana.",
                steps: [],
                tips: ["+# to Level of all Skills es el mod más valioso en Staves — priorízalo si puedes conseguirlo", "Cast Speed afecta directamente cuántas veces por segundo lanzas — prioridad alta en cualquier caster"]
            },
            {
                heading: "4. Ruta de crafteo",
                content: "",
                steps: [
                    { n: 1, action: "Essence para garantizar un mod", detail: "Usa Essence of Electricity (Lightning Damage to Spells), Essence of Sorrow (Cold Damage to Spells) o Essence of Flames (Fire Damage to Spells) según tu elemento. Obtienes el mod garantizado al craftear a Rare." },
                    { n: 2, action: "Evalúa el resultado", detail: "Busca que salgan al menos 1-2 mods más útiles junto al guaranteed. Si el resultado es malo, repite con otra copia." },
                    { n: 3, action: "Rellena huecos con Exalted Orb", detail: "Añade mods en los slots vacíos. Comprueba si necesitas prefix o suffix antes de tirar." },
                    { n: 4, action: "Elimina mods no deseados", detail: "Chaos Orb + Omen of Whittling para borrar el peor mod. Omen of Sinistral/Dextral Erasure si sabes exactamente qué tipo de mod quieres eliminar." },
                    { n: 5, action: "Optimiza con Divine Orb", detail: "Rerollea los valores numéricos de mods como % Spell Damage o Cast Speed para acercarte al máximo del tier." },
                    { n: 6, action: "Fracturing Orb (opcional)", detail: "Bloquea '+# to Level of all Skills' o el mayor mod de Spell Damage si ya los tienes en valor alto." },
                    { n: 7, action: "Añade socket", detail: "Usa Artificer's Orb para el socket. Coloca una Rune de Inspiration (Mana) o un Soul Core relevante." },
                    { n: 8, action: "Corrompe (opcional, endgame)", detail: "La corrupción en Staves/Wands puede añadir implícitos poderosos como +1 to Level of all Skills. Alto riesgo — solo en armas ya muy buenas." }
                ],
                tips: []
            },
            {
                heading: "5. Abyss (avanzado)",
                content: "Usa un Jawbone Ancient para añadir un mod Desecrado al arma. Los mods Abyss para armas de caster incluyen opciones únicas como bonificaciones de penetración o efectos on-cast. Revela en el Well of Souls.",
                steps: [],
                tips: ["Para Staves también puedes usar Vaal Cultivation Orb si tienes una versión Unique que quieras mejorar"]
            }
        ]
    },
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

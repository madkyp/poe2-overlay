.pragma library

var GUIDES = [
    {
        id: "reading_items",
        title: "Cómo leer un item: Tiers y Prefijos/Sufijos",
        category: "Fundamentos",
        categoryColor: "#6a9aaa",
        difficulty: "Beginner",
        summary: "Entiende si un mod es bueno o malo, qué es T1, y cómo distinguir prefijos de sufijos.",
        sections: [
            {
                heading: "Prefijos y Sufijos",
                content: "Cada item Rare puede tener hasta 6 mods: 3 Prefijos (izquierda/arriba) y 3 Sufijos (derecha/abajo). En el tooltip del juego los prefijos aparecen primero. Saber de qué tipo es cada mod es crítico: si tienes 3 prefijos llenos no puedes añadir más prefijos con Exalted Orb aunque te queden sufijos libres.",
                steps: [],
                tips: [
                    "Prefijos típicos: Vida, ES, Armour, Evasion, Daño físico, Spell Damage, +Level of Skills",
                    "Sufijos típicos: Resistencias, Attack Speed, Cast Speed, Accuracy, Atributos (STR/DEX/INT), Mana",
                    "Movement Speed en botas es SIEMPRE prefijo — uno de los pocos casos que confunde"
                ]
            },
            {
                heading: "Tiers de mods (T1, T2, T3...)",
                content: "Cada mod tiene varios tiers — el T1 es el mejor (valores más altos), T2 es el segundo mejor, etc. El tier que puede salir depende del ilvl de la base: necesitas ilvl alto para que el T1 esté disponible. En el tooltip del juego el tier aparece a la derecha del mod entre corchetes como [T1] o [T2].",
                steps: [],
                tips: [
                    "ilvl 75+ suele desbloquear T1 en la mayoría de mods importantes",
                    "Un mod T1 con valor bajo (cerca del mínimo del tier) sigue siendo T1 — el Divine Orb puede subir ese valor",
                    "Un mod T2 con valor máximo NO es mejor que un T1 con valor mínimo — el tier importa más que el valor dentro del tier"
                ]
            },
            {
                heading: "Cómo saber si un valor es bueno",
                content: "Cada tier tiene un rango de valores (min–max). Si el valor está cerca del máximo del tier es casi perfecto. Si está cerca del mínimo, un Divine Orb puede mejorarlo. Por ejemplo: Life T1 puede ir de 85 a 99 — un valor de 87 es T1 pero mejorable, un 98 es casi perfecto.",
                steps: [],
                tips: [
                    "Poe2db.tw muestra los rangos exactos por tier para cada mod — consúltalo antes de gastar un Divine",
                    "No uses Divine en un item que no tiene todos los mods correctos — primero consigue los mods, luego optimiza valores",
                    "Un item con todos los mods correctos en T1 aunque con valores bajos ya vale mucho — el Divine es el último paso"
                ]
            },
            {
                heading: "Implicits vs. Explicits",
                content: "Los mods Implicit son los que vienen fijos con la base del item (p.ej. Two-Stone Ring siempre tiene resistencias como implicit). Los Explicit son los mods que se añaden mediante crafteo. Los Implicit no cuentan para el límite de 3 prefijos / 3 sufijos y no pueden ser cambiados por orbes normales — solo por corrupción o en algunos casos por mecánicas especiales.",
                steps: [],
                tips: [
                    "Un item corrompido puede tener un Implicit corrompido adicional — muy poderoso si salió bueno",
                    "La calidad del item amplifica el Implicit en algunos tipos de item (p.ej. Catalysts en joyería)"
                ]
            }
        ]
    },
    {
        id: "fracturing_strategy",
        title: "Fracturing Orb: cuándo y cómo usarla",
        category: "Mecánicas",
        categoryColor: "#aa4a4a",
        difficulty: "Advanced",
        summary: "La Fracturing Orb bloquea un mod para siempre. Úsala bien y ahorra recursos enormes; úsala mal y los desperdicias.",
        sections: [
            {
                heading: "Qué hace exactamente",
                content: "La Fracturing Orb elige un mod aleatorio del item y lo 'fractura' — lo bloquea permanentemente. El mod fracturado nunca puede ser cambiado por ningún orbe posterior (Chaos, Annulment, Exalted). El item queda marcado como Fractured. El resto de mods siguen siendo modificables con normalidad.",
                steps: [],
                tips: [
                    "Solo se puede fracturar UN mod por item — no hay forma de fracturar dos mods",
                    "La Fracturing Orb elige el mod a fracturar ALEATORIAMENTE — no puedes elegir cuál",
                    "Hinekora's Lock previsualiza qué mod fracturará antes de aplicar la Orb — úsala siempre en items caros"
                ]
            },
            {
                heading: "Cuándo usar Fracturing Orb",
                content: "Úsala cuando el item tenga exactamente UN mod T1 muy valioso que no quieres arriesgar perder con crafteo posterior. Si el item tiene 2+ mods buenos, la Fracturing puede fracturar el que no quieres — usa Hinekora's Lock para confirmar antes.",
                steps: [],
                tips: [
                    "Mods que merecen ser fracturados: +Level of all Skills T1, Adds Physical Damage T1, Life T1 alto (95+), Movement Speed 30%",
                    "NO fractures mods mediocres esperando que sean suficientes — espera a tener T1 real"
                ]
            },
            {
                heading: "Orden correcto en el proceso de crafteo",
                content: "El momento ideal para fracturar es DESPUÉS de tener el mod T1 que quieres conservar, pero ANTES de seguir modificando con Chaos Orbs o Annulment que podrían borrarlo. No fractures al principio (puede salir un mod malo) ni al final (puede que ya hayas gastado recursos en el mod que querías proteger).",
                steps: [
                    { n: 1, action: "Consigue el mod T1 objetivo", detail: "Via Essence, Exalted, o crafteo normal. Asegúrate de que el valor es bueno (cerca del máximo del tier)." },
                    { n: 2, action: "Usa Hinekora's Lock para previsualizar", detail: "Aplica Hinekora's Lock y luego la Fracturing Orb sobre el item — la previsualización mostrará qué mod se fracturaría. Si no es el que quieres, cancela." },
                    { n: 3, action: "Fractura si la previsualización es correcta", detail: "Confirma la fractura. El mod queda bloqueado para siempre." },
                    { n: 4, action: "Sigue crafteando el resto del item", detail: "Ahora puedes usar Chaos Orbs, Annulment, Exalted con tranquilidad — el mod fracturado nunca se perderá." }
                ],
                tips: [
                    "Si el item tiene solo 1 mod y es el que quieres fracturar, no necesitas Hinekora's Lock — solo hay un candidato",
                    "Un item Fractured en el trade vale MÁS que uno sin fracturar si el mod fracturado es valioso — es una garantía para el comprador"
                ]
            },
            {
                heading: "Errores comunes",
                content: "Fracturar demasiado pronto (cuando el mod está en valor bajo del tier — después no puedes usar Divine en ese mod). Fracturar sin Hinekora's Lock y que salga el mod incorrecto. Fracturar un mod que luego resulta ser innecesario para tu build.",
                steps: [],
                tips: [
                    "El Divine Orb NO afecta al mod fracturado — fractura DESPUÉS de haber optimizado el valor con Divine si es importante",
                    "Hay una excepción: si el mod fracturado ya es el máximo posible del tier, no importa que no puedas usar Divine en él"
                ]
            }
        ]
    },
    {
        id: "essence_table",
        title: "Tabla de Essences: qué usar para cada slot",
        category: "Referencia",
        categoryColor: "#9a6aaa",
        difficulty: "Beginner",
        summary: "Referencia rápida de qué Essence garantiza qué mod en cada tipo de item.",
        sections: [
            {
                heading: "Essences de Vida y Defensa",
                content: "Essence of the Body → +(85–99) Life en Amuleto, Botas, Guantes, Anillo (Greater tier). Essence of the Mind → +(90–104) Mana en Joyería. Essence of Enhancement → % increased Armour/ES/Evasion en Armadura.",
                steps: [],
                tips: [
                    "Essence of the Body (Greater) es la más usada del juego — sirve para cualquier slot de joyería o botas",
                    "Para Life en Pecho o Casco no hay Essence directa — usa Alchemy o Essences de resistencia y reza por Life aleatoria"
                ]
            },
            {
                heading: "Essences de Resistencias",
                content: "Essence of Insulation → +% Fire Resistance (Lesser: 11–15%, Standard: 21–25%, Greater: 31–35%). Essence of Thawing → +% Cold Resistance (mismos rangos). Essence of Grounding → +% Lightning Resistance (mismos rangos). Aplican en joyería, botas, guantes y armadura.",
                steps: [],
                tips: [
                    "Si necesitas cerrar una resistencia específica, estas Essences son la forma más directa",
                    "En joyería combínalas con el Catalyst correspondiente para amplificar el mod de resistencia"
                ]
            },
            {
                heading: "Essences de Armas (Ataque)",
                content: "Essence of Torment → Adds Physical Damage to Attacks. Essence of Rage → % increased Attack Speed. Essence of Battle → mod de ataque según tipo de arma. Essence of Flames → Adds Fire Damage. Essence of Ice → Adds Cold Damage. Essence of Electricity → Adds Lightning Damage.",
                steps: [],
                tips: [
                    "Essence of Rage para Attack Speed garantizada es muy eficiente en armas físicas",
                    "Elige el elemento de la Essence según el elemento principal de tu build de ataque"
                ]
            },
            {
                heading: "Essences de Armas (Hechizos)",
                content: "Essence of Sorcery → % increased Spell Damage en Varita/Bastón (55–64%). Essence of Flames/Ice/Electricity → Adds elemental Damage to Spells en armas de caster. Essence of Hysteria → Helmet: +1 to Level of all Minion Skills / Boots: 30% increased Movement Speed.",
                steps: [],
                tips: [
                    "Essence of Hysteria es la más valiosa del juego para dos usos completamente distintos: Movement Speed en botas y +1 Minion Skills en casco",
                    "Essence of Sorcery es el equivalente a Essence of Rage pero para builds de hechizo"
                ]
            },
            {
                heading: "Essences especiales",
                content: "Essence of Delirium → Body Armour: Allocates a random Notable Passive Skill (muy poderoso, aleatorio). Essence of the Abyss → crea 'Mark of the Abyssal Lord' en el item para un mod Desecrado de tier superior en el Well of Souls. Perfect Essences → trabajan sobre items ya Rare reemplazando un mod aleatorio por el garantizado.",
                steps: [],
                tips: [
                    "Essence of Delirium en pecho puede dar un Notable pasivo gratuito — muy valioso si sale el correcto",
                    "Perfect Essences son las más raras y caras — úsalas solo para refinar items que ya tienen 5/6 mods correctos"
                ]
            }
        ]
    },
    {
        id: "example_helmet",
        title: "Ejemplo: Casco (Helmet)",
        category: "Ejemplo",
        categoryColor: "#c47a3a",
        difficulty: "Beginner",
        summary: "Casco Rare con Life + Resistencias. Si juegas Minions: +1 to Minion Skills garantizado con Essence of Hysteria.",
        sections: [
            {
                heading: "Dos rutas según tu build",
                content: "Ruta A (cualquier build): Life + dos Resistencias + mod secundario. Ruta B (builds de Minions): +1 to Level of all Minion Skills garantizado con Essence of Hysteria, luego Life y Resistencias en el resto de mods. El casco es el único slot donde puedes garantizar +1 Minion Skills con una Essence.",
                steps: [],
                tips: [
                    "Si juegas Minions, el casco con +1 Minion Skills es una prioridad absoluta — sube el nivel efectivo de todas tus gemas de minion",
                    "Para otras builds, el casco comparte prioridad con guantes y botas en cuanto a inversión de resources"
                ]
            },
            {
                heading: "Material necesario",
                content: "Base de casco ilvl 75+ del tipo correcto (Armour/Evasion/ES según build). Armourer's Scrap ×4. Essence of Hysteria (si builds Minions: garantiza +1 Minion Skills en casco) O Essence of the Body (Greater) para Life garantizada. Exalted Orbs ×2–3. Chaos Orb + Omen of Whittling ×1–2. Divine Orb ×1.",
                steps: [],
                tips: []
            },
            {
                heading: "Pasos (ruta Minions)",
                content: "",
                steps: [
                    { n: 1, action: "Calidad al 20% con Armourer's Scrap", detail: "En estado Normal. Aumenta Armour/Evasion/ES base del casco." },
                    { n: 2, action: "Essence of Hysteria → Rare", detail: "Garantiza exactamente '+1 to Level of all Minion Skills' en el casco. Este es el mod más valioso para builds de minions — ya está asegurado." },
                    { n: 3, action: "Evalúa los 3 mods aleatorios", detail: "Busca Life y al menos una Resistencia. Si salió Life + 1 Resistencia → excelente. Si los 3 mods son inútiles → repite con otra base." },
                    { n: 4, action: "Rellena con Exalted Orbs", detail: "Añade Life (si no salió) y Resistencias en los huecos. Controla prefix/suffix disponibles." },
                    { n: 5, action: "Elimina mods inútiles", detail: "Chaos Orb + Omen of Whittling para el peor mod. Cuida de no borrar el +1 Minion Skills — es un prefix." },
                    { n: 6, action: "Divine Orb", detail: "Optimiza Life y Resistencias. El +1 Minion Skills es un valor fijo — el Divine no lo afecta." },
                    { n: 7, action: "Socket con Artificer's Orb", detail: "Añade socket para Rune o Soul Core. Iron Rune (defensa) o una Soul Core relevante para tu build de minions." }
                ],
                tips: [
                    "Para la ruta no-Minions usa Essence of the Body en el paso 2 para Life garantizada en vez de +1 Skills",
                    "+1 to Level of all Minion Skills afecta a TODAS las gemas de minion que uses — es multiplicativo en el daño total"
                ]
            }
        ]
    },
    {
        id: "example_belt",
        title: "Ejemplo: Cinturón",
        category: "Ejemplo",
        categoryColor: "#8a7a5a",
        difficulty: "Beginner",
        summary: "Cinturón Rare con Life + Resistencias + Flask Charges. Uno de los slots más fáciles de craftear bien.",
        sections: [
            {
                heading: "Objetivo final",
                content: "Cinturón Rare con: +(70–99) to maximum Life · +(25–35)% a dos Resistencias · Flask Charges Generated o Stun Threshold. El cinturón es un slot relativamente fácil de craftear — tiene menos slots que otros items y los mods objetivo son claros.",
                steps: [],
                tips: [
                    "El cinturón es ideal para practicar el flujo de crafteo antes de atacar slots más caros como el pecho",
                    "Stun Threshold en cinturón reduce mucho la probabilidad de ser stunneado en endgame — muy útil para builds de melee"
                ]
            },
            {
                heading: "Elegir la base",
                content: "Heavy Belt: +25–35 Strength implicit — bueno para builds STR. Chain Belt: +9–12 Mana Regen implicit. Leather Belt: +25–40 Life implicit — la mejor base para Life builds, el implicit ya suma vida. Rustic Sash: % increased Physical Damage implicit — bueno para builds de ataque físico. Studded Belt: % increased Evasion implicit. Ilvl 75+ siempre.",
                steps: [],
                tips: [
                    "Leather Belt es la base más usada — el implicit de Life es directamente útil para cualquier build",
                    "Rustic Sash para builds de ataque físico que quieren exprimir todo el daño posible"
                ]
            },
            {
                heading: "Pasos",
                content: "",
                steps: [
                    { n: 1, action: "Essence of the Body (Standard o Greater)", detail: "Garantiza Life en el cinturón. Standard da +(70–84), Greater da +(85–99). Con Leather Belt como base sumas el implicit de Life encima." },
                    { n: 2, action: "Evalúa los mods aleatorios", detail: "Busca Resistencias. El cinturón tiene solo 4 mods totales (2 prefix + 2 suffix) — con Life garantizada solo quedan 3 huecos. Si salió 1–2 Resistencias → perfecto." },
                    { n: 3, action: "Rellena con Exalted Orb", detail: "Añade la Resistencia que falte o Flask Charges Generated (suffix muy buscado para QoL en endgame)." },
                    { n: 4, action: "Elimina mod inútil si aparece", detail: "Chaos Orb + Omen of Whittling. En cinturones los mods típicamente inútiles son Mana o Accuracy." },
                    { n: 5, action: "Divine Orb para optimizar", detail: "Maximiza Life y Resistencias. El impacto en cinturón no es tan grande como en pecho, pero si el cinturón es muy bueno vale la pena." },
                    { n: 6, action: "Collarbone Abyss (opcional)", detail: "Aplica Collarbone Ancient si tienes huecos libres. Los mods Abyss en cinturones pueden incluir bonuses únicos de Flask o efectos especiales." }
                ],
                tips: [
                    "El cinturón tiene MENOS slots que otros items (4 mods max en lugar de 6) — no intentes poner 6 mods, no caben",
                    "Flask Charges Generated es uno de los sufijos más cómodos del juego — los flasks se recargan mucho más rápido"
                ]
            }
        ]
    },
    {
        id: "example_weapon_minion",
        title: "Ejemplo: Arma para Builds de Minions",
        category: "Ejemplo",
        categoryColor: "#aa4a4a",
        difficulty: "Intermediate",
        summary: "Crafteo de arma para Witch/Necromancer. Los mods objetivo son completamente distintos a armas de ataque o hechizo propio.",
        sections: [
            {
                heading: "Diferencia clave respecto a otras armas",
                content: "En builds de Minions el personaje NO ataca directamente — los minions hacen el daño. Por tanto los mods de Adds Physical Damage, Attack Speed o Spell Damage para el jugador no sirven de nada. Los mods objetivo son: +Level of Minion Skills, % increased Minion Damage, Minion Attack/Cast Speed, Minions have % increased Life.",
                steps: [],
                tips: [
                    "+# to Level of all Minion Skills es el mod más poderoso — sube el nivel de todas tus gemas de minion a la vez",
                    "Un arma con +2 to all Minion Skills puede doblar efectivamente el daño de tus minions si las gemas son de alto nivel"
                ]
            },
            {
                heading: "Elegir la base",
                content: "Para builds de Minions la base del arma importa menos que para otras builds — no la usas para atacar. Lo importante es el ilvl (75+) y el tipo de arma que requiera tu build. Wand o Sceptre son los más comunes para Witch/Necromancer. El implicit del Sceptre suele dar bonuses de Minions o Elemental — muy útil.",
                steps: [],
                tips: [
                    "Sceptre con implicit de +1 to Level of all Minion Skills es la base endgame para Necromancer — muy cara en trade",
                    "Si llevas escudo, una Wand con +1 Skills en mano principal es el setup más eficiente"
                ]
            },
            {
                heading: "Mods objetivo",
                content: "Prefijos: +# to Level of all Minion Skills (el más valioso), % increased Minion Damage, Minions have % increased Maximum Life. Sufijos: Minions have % increased Attack Speed, Minions have % increased Cast Speed, +# to Level of all [tipo específico] Skills (Skeleton Skills, Zombie Skills, etc.).",
                steps: [],
                tips: [
                    "+Level of all Minion Skills es PREFIX — controla que tienes espacio de prefijo antes de usar Exalted",
                    "Los mods específicos por tipo de minion (Skeleton, Zombie, Spectre) son más fáciles de conseguir que el genérico 'all Minion Skills'"
                ]
            },
            {
                heading: "Pasos",
                content: "",
                steps: [
                    { n: 1, action: "Busca base con implicit de Minions", detail: "Sceptre con +1 to Minion Skills o Wand con Spell Damage (que al menos no sea inútil aunque no sea minion-específico). ilvl 75+." },
                    { n: 2, action: "Arcanist's Etcher al 20% calidad", detail: "Para Wand/Sceptre/Staff usa Arcanist's Etcher, no Whetstone." },
                    { n: 3, action: "Orb of Alchemy → Rare", detail: "Para armas de Minion el método más eficiente al principio es Alchemy directo — si salió +1 Minion Skills entre los 4 mods ya tienes una base sólida." },
                    { n: 4, action: "Si no salió +1 Minion Skills: Essence o Exalted", detail: "Usa Exalted Orb buscando +Level of Minion Skills si aún tienes huecos de prefix. O busca la base directamente en trade con el mod ya presente." },
                    { n: 5, action: "Añade Minion Damage y Speed", detail: "Rellena los huecos restantes con mods de daño y velocidad de minions con Exalted Orbs." },
                    { n: 6, action: "Fracturing Orb en +1 Minion Skills", detail: "Si conseguiste +1 to Level of all Minion Skills en valor máximo, fractura ese mod con Hinekora's Lock para previsualizar primero." },
                    { n: 7, action: "Divine Orb para Minion Damage", detail: "Optimiza los valores de % Minion Damage y Minion Speed — el rango puede ser grande." }
                ],
                tips: [
                    "En muchos casos es más eficiente comprar en trade un arma con +1–2 Minion Skills ya en ella y luego añadir el resto de mods",
                    "Essence of Hysteria en CASCO (no arma) da +1 Minion Skills — el casco y el arma son los dos slots donde se acumula esta bonificación"
                ]
            }
        ]
    },
    {
        id: "example_gloves",
        title: "Ejemplo: Guantes",
        category: "Ejemplo",
        categoryColor: "#6a9aaa",
        difficulty: "Beginner",
        summary: "Guantes Rare con Life + Attack/Cast Speed + Resistencias. El slot más flexible para añadir velocidad.",
        sections: [
            {
                heading: "Objetivo final",
                content: "Guantes Rare con: +(70–99) to maximum Life · % increased Attack Speed (para builds de ataque) o % increased Cast Speed (para casters) · +(21–35)% a una o dos Resistencias. Los guantes son el mejor slot para conseguir velocidad de ataque o casteo además de defensas.",
                steps: [],
                tips: [
                    "Attack Speed en guantes afecta a TODOS los ataques con cualquier arma — muy eficiente por slot",
                    "Para casters, Cast Speed en guantes libera ese sufijo en el arma para otros mods"
                ]
            },
            {
                heading: "Elegir la base",
                content: "Elige el tipo de defensa de la base según tu build: Armour (STR), Evasion (DEX), ES (INT) o híbrido. Los guantes tienen solo 1 socket. ilvl 75+ para tener acceso a T1 en Life y velocidad.",
                steps: [],
                tips: ["Las bases de guantes no tienen grandes diferencias de implicit — elige principalmente por el tipo de defensa"]
            },
            {
                heading: "Pasos",
                content: "",
                steps: [
                    { n: 1, action: "Calidad al 20% con Armourer's Scrap", detail: "En estado Normal." },
                    { n: 2, action: "Essence of the Body (Greater) → Rare", detail: "Garantiza +(85–99) Life. Los 3 mods restantes son aleatorios — busca que salga Attack/Cast Speed o una Resistencia." },
                    { n: 3, action: "Evalúa mods aleatorios", detail: "¿Salió Attack Speed o Cast Speed? Si sí, es un gran resultado. Si no, decide si continúas o repites con otra base." },
                    { n: 4, action: "Añade Attack/Cast Speed con Exalted", detail: "Si no salió, usa Exalted Orb buscando el sufijo de velocidad. Attack Speed y Cast Speed son SUFIJOS — comprueba que tengas huecos de suffix." },
                    { n: 5, action: "Añade Resistencias", detail: "Rellena los huecos de suffix restantes con Resistencias. Fire, Cold o Lightning según lo que más necesites." },
                    { n: 6, action: "Elimina mods inútiles", detail: "Chaos + Omen of Whittling para el mod más débil. En guantes los mods típicamente inútiles son Mana o Accuracy Rating." },
                    { n: 7, action: "Divine Orb", detail: "Optimiza Life y los % de velocidad. Attack/Cast Speed T1 puede ir del 12% al 17% — un Divine puede subir varios puntos de DPS." },
                    { n: 8, action: "Socket + Rib Abyss (opcional)", detail: "Añade socket con Artificer's Orb. Rib Ancient para mod Desecrado si tienes hueco." }
                ],
                tips: [
                    "Si tras el paso 2 salió Attack Speed + Life, ya tienes los 2 mods clave — añade Resistencias en los huecos",
                    "Accuracy Rating en guantes es útil para builds de ataque que tengan problemas de hit chance — no lo descartes sin comprobarlo"
                ]
            }
        ]
    },
    {
        id: "example_recombinator",
        title: "Ejemplo: Recombinator paso a paso",
        category: "Ejemplo",
        categoryColor: "#c47a3a",
        difficulty: "Advanced",
        summary: "Cómo usar el Recombinator para fusionar los mejores mods de dos items en uno. Ejemplo con dos anillos.",
        sections: [
            {
                heading: "El objetivo del ejemplo",
                content: "Tenemos dos anillos: Anillo A con Life T1 + All Resistances T1 + dos mods malos. Anillo B con Accuracy T1 + Added Physical Damage T1 + dos mods malos. Queremos un anillo con Life T1 + All Resistances T1 + Added Physical Damage T1.",
                steps: [],
                tips: [
                    "El Recombinator es endgame — solo úsalo en items con al menos 2 mods T1 reales que valga la pena preservar",
                    "Cuantos más mods quieras transferir, menor es la probabilidad de éxito — apunta a máximo 2 mods"
                ]
            },
            {
                heading: "Preparación",
                content: "Ambos items deben ser de la MISMA clase (p.ej. dos anillos, o dos amuletos). La base puede ser diferente — el resultado hereda una de las dos bases aleatoriamente. Necesitas Artifacts obtenidos en encuentros de Expedition en el Atlas.",
                steps: [],
                tips: [
                    "Farmea Expedition en el Atlas para acumular Artifacts antes de intentar el Recombinator",
                    "El coste en Artifacts es mayor cuanto más raros/poderosos son los mods que intentas transferir"
                ]
            },
            {
                heading: "Proceso",
                content: "",
                steps: [
                    { n: 1, action: "Craftea dos copias del mismo item base", detail: "Ejemplo: craftea varios anillos hasta tener uno con Life T1 + Res T1 y otro con el mod ofensivo T1 que buscas." },
                    { n: 2, action: "Desbloquea el Recombinator", detail: "Completa tu primer Expedition en el Atlas. El bench aparece en tu Hideout." },
                    { n: 3, action: "Selecciona los mods a transferir", detail: "En el Recombinator, marca exactamente los 2 mods que quieres en el resultado: Life T1 del Anillo A y Added Physical Damage T1 del Anillo B." },
                    { n: 4, action: "Revisa el coste y la probabilidad", detail: "El interface muestra el coste en Artifacts y una probabilidad estimada. Con 2 mods T1 el coste es alto — asegúrate de tener suficientes Artifacts." },
                    { n: 5, action: "Confirma la recombinación", detail: "Si la probabilidad es aceptable (>20% es razonable para mods T1), confirma. Ambos anillos se destruyen en caso de fallo." },
                    { n: 6, action: "Si falla: repite desde el paso 1", detail: "Necesitas craftear dos nuevos anillos con los mods objetivo. Por eso siempre hay que tener varias copias de la base." },
                    { n: 7, action: "Si tiene éxito: añade el tercer mod", detail: "El resultado tiene Life T1 + Added Physical Damage T1 (y posiblemente algún mod extra aleatorio). Ahora usa Exalted Orb para añadir All Resistances o lo que falte." }
                ],
                tips: [
                    "NO intentes transferir 3 mods — la probabilidad cae tanto que no compensa",
                    "Farmea múltiples copias de las bases antes de empezar — un intento fallido sin material de repuesto es muy frustrante",
                    "El Recombinator es especialmente potente para items de alto valor donde los mods T1 son rarísimos juntos de forma natural"
                ]
            },
            {
                heading: "Cuándo merece la pena",
                content: "Vale la pena cuando: tienes dos items cada uno con UN mod T1 muy difícil de conseguir junto al otro, y el coste de craftear más items manualmente sería mayor que el coste de los Artifacts. No vale la pena para items con mods comunes que puedes conseguir fácil con Essences.",
                steps: [],
                tips: []
            }
        ]
    },
    {
        id: "corruption_by_slot",
        title: "Corrupción estratégica por slot",
        category: "Mecánicas",
        categoryColor: "#aa4a4a",
        difficulty: "Advanced",
        summary: "Qué implicits corruptos buscar en cada pieza de gear para máximo impacto.",
        sections: [
            {
                heading: "Cómo funcionan los implicits corruptos",
                content: "Al corromper con Vaal Orb, uno de los resultados posibles es añadir un implicit corrupto al item (además de otros resultados: sin cambio, modificar un mod existente, o añadir un socket). Los implicits corruptos son únicos y no pueden conseguirse de ninguna otra forma. Cada tipo de item tiene su propio pool de implicits posibles.",
                steps: [],
                tips: [
                    "⚠ En 0.5 (Runes of Aldur) el Omen of Corruption ya NO se obtiene — la corrupción es RNG puro, no puedes forzar el implicit",
                    "Hinekora's Lock previsualiza el resultado de la Vaal Orb — úsalo en items valiosos para no corromper a ciegas",
                    "El resultado de corrupción que rerollea valores numéricos ahora MULTIPLICA cada mod según su valor actual (antes era totalmente aleatorio)"
                ]
            },
            {
                heading: "Implicits por slot",
                content: "Casco: % increased Area of Effect, Socketed Gems have +# Level, % increased Minion Damage. Pecho: % increased Life, Reflected Damage reduction, Socketed Gems have +# Level. Guantes: % increased Attack Speed, % increased Cast Speed, Adds Physical/Elemental Damage. Botas: % increased Movement Speed (adicional al mod explícito), % increased Mana Regeneration, Cannot be Frozen. Armas: +# to Level of all Skills (muy poderoso), % increased Spell/Physical Damage, Gain % of Physical as extra Element.",
                steps: [],
                tips: [
                    "+# to Level of all Skills en arma como implicit corrupto es uno de los mejores resultados posibles del juego",
                    "% increased Movement Speed en botas como implicit se suma al explicit — puedes superar el cap normal de Mov Speed"
                ]
            },
            {
                heading: "Implicits de joyería",
                content: "Anillos: % increased Life Leech, Elemental Damage Penetration, Reflects Damage to Attackers, % increased Mana. Amuletos: % increased Global Critical Multiplier, +# to Level of all Skills, % increased Damage, Elemental Weakening on Hit. Cinturón: % increased Flask Effect Duration, % increased Stun and Block Recovery.",
                steps: [],
                tips: [
                    "+# to Level of all Skills en amuleto como implicit corrupto es equiparable al anointment en valor",
                    "% increased Global Critical Multiplier en anillo es muy buscado en builds de crítico"
                ]
            },
            {
                heading: "Cuándo corromper para implicits",
                content: "Solo merece la pena cuando el item base ya es casi perfecto y aceptas el riesgo: la corrupción puede no añadir nada (o bloquear el item) y es irreversible. En 0.5 ya no existe el Omen of Corruption, así que no hay forma de garantizar el implicit — es RNG. Previsualiza con Hinekora's Lock antes de tirar.",
                steps: [],
                tips: [
                    "Comprar items ya corrompidos con el implicit que buscas en el trade suele ser más barato que intentar conseguirlo tú mismo",
                    "Los items con implicits corruptos muy buenos valen mucho más en el mercado — es una fuente de ingresos para crafters avanzados"
                ]
            }
        ]
    },
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
                tips: ["Always corrupt as the very last crafting step", "⚠ Omen of Corruption was removed in 0.5 (Runes of Aldur) — corruption can no longer be steered, it's pure RNG", "Use Hinekora's Lock to preview the result before committing the Vaal Orb"]
            },
            {
                heading: "How to Corrupt",
                content: "Use a Vaal Orb from your inventory at any time. Or interact with a Corruption Altar: Act 2 (Vaal Ruins, Jiquani's Sanctum, Temple of Atzoatl) and Act 3 (Trial of Chaos).",
                steps: [],
                tips: []
            },
            {
                heading: "Manipulating corrupted items",
                content: "Vaal Cultivation Orb can further alter already-corrupted Uniques: it replaces up to 2 mods on corrupted Uniques, or converts a normal Unique into a corrupted variant of the same item class. In 0.5 its outcome values were reduced on certain specific Uniques.",
                steps: [],
                tips: ["Corrupted items can't be touched by standard currency — Vaal Cultivation Orb is one of the few exceptions, and only on Uniques"]
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
        summary: "Add Augment Sockets to weapons/armour for Runes and Soul Cores, and use the dedicated Idol sockets on Helmet/Body/Gloves/Boots/Sceptre for build-defining bonuses.",
        sections: [
            {
                heading: "Socket Limits",
                content: "Artificer's Orb (crafted from 10 Artificer's Shards) adds an Augment Socket to a martial weapon, wand, staff or armour piece — up to 2 sockets on body armour and two-handed weapons, up to 1 on other weapon/armour slots by default. Corrupted or unique items can exceed the normal cap.",
                steps: [],
                tips: ["Sockets can be filled and emptied freely at any time at no cost", "Cadigan's Epiphany destroys all Augment Sockets on an item and converts them into a single Jewel socket instead"]
            },
            {
                heading: "Runes",
                content: "Standard Runes come in 4 tiers — Lesser, Normal, Greater, Perfect — across categories: Elemental (Desert/Glacial/Storm — elemental damage or resistance), Attribute (Robust/Adept/Resolve — Str/Dex/Int), Resource (Body/Mind/Rebirth/Inspiration — leech and recovery), Utility (Iron/Stone/Vision/Tempered — damage scaling and defence). 0.5 (Runes of Aldur) added: Ancient Runes (special weapon-specific effects), Runic Ward runes (Ward/Charging/Warding, tied to the new Runic Ward defence) and Augment/meta-crafting runes that add a whole new modifier line instead of a fixed bonus (e.g. Uhtred's Sidereus on Boots grants Chronomancy modifiers).",
                steps: [],
                tips: ["Match rune tier to your character level — Greater/Perfect runes are an endgame investment", "Aldur's Legacy destroys a Kalguuran or Ezomyte Unique to forge a rune that inherits part of its modifiers (named variants like Passion/Breath/Ire of Aldur)"]
            },
            {
                heading: "Soul Cores",
                content: "Farmed mainly from the Trial of Chaos (via Inscribed Ultimatums) — at least 1 Soul Core is guaranteed per run, more from higher-level Ultimatums, and rounds 4, 7 and 10 always offer one as a reward. Effects vary heavily depending on whether the core is socketed in a weapon or in armour.",
                steps: [],
                tips: ["Core Destabiliser (found in Atziri's Temple) can upgrade a Soul Core into a rarer Ancient Soul Core — but risks destroying it instead", "Orb of Extraction recovers a socketed Soul Core at the cost of destroying the host item", "Soul Cores are tradeable and often valuable — check poe2.ninja rates before selling or destroying"]
            },
            {
                heading: "Idols",
                content: "Socket directly into 5 specific gear types — Helmet, Body Armour, Gloves, Boots, Sceptre. One of the most build-defining endgame systems: the same Idol gives a different effect depending on which of those slots it's socketed into (e.g. offensive/defensive stats in armour vs. minion/ally bonuses in a Sceptre).",
                steps: [],
                tips: ["Drop mainly from Azmerian Spirit-Possessed monsters", "Once socketed an Idol can't be removed — only replaced with another socketable"]
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

# The Foundry: PoE2 App

Overlay de escritorio para **Path of Exile 2** construido con **Quickshell** (QML/Qt6) sobre Wayland. Muestra precios de items y divisa en tiempo real, notas de build, monitor de economía con tasas cruzadas e instalador automático de filtros NeverSink, todo sin salir del juego.

---

## Características

- **Price Checker** — Consulta el precio de cualquier item al vuelo con **Ctrl + D**. Muestra los primeros listados con precio, vendedor y liga.
- **Currency Tracker** — Widget siempre visible con el valor actualizado de las divisas principales (Divine, Exalted, Annulment, Vaal).
- **Notas de Build** — Panel lateral con editor Markdown para apuntar skills, items clave y pasivas de tu build.
- **Economy Window** — Tabla completa de divisa con popup de tasas cruzadas al pasar el ratón. Selección de categoría lateral.
- **Opciones de liga** — Cambia al vuelo entre ligas (Fate of the Vaal, HC, Standard, Hardcore…) sin reiniciar.
- **Crafting Cheat Sheet** — Panel de referencia rápida con todos los orbes, essences, omens, catalysts y los nuevos items de Fate of the Vaal. Incluye descripción, a qué se aplica y tips de uso para cada uno.
- **Instalador NeverSink** — Descarga e instala directamente los filtros NeverSink para PoE2 desde GitHub. Detecta automáticamente la carpeta del juego, muestra la versión instalada y avisa cuando hay actualizaciones.

---

## Capturas

### Price Checker

<p align="center">
  <img src="screenshots/price-checker.png" alt="Price Checker" width="380">
  <br><em>Overlay de búsqueda de precios — muestra listados reales de la API de trade</em>
</p>

> **Uso:** Pasa el cursor sobre el item en el juego y pulsa **Ctrl + D** — la app muestra el precio al instante.
> Requiere tener instalado **xdotool** (`sudo pacman -S xdotool`).

---

### Currency Tracker

<p align="center">
  <img src="screenshots/currency-tracker.png" alt="Currency Tracker" width="280">
  <br><em>Widget siempre visible con el valor de las divisas principales</em>
</p>

---

### Notas de Build

<p align="center">
  <img src="screenshots/build-notes-btn.png" alt="Botón Notas" width="180">&nbsp;&nbsp;&nbsp;
  <img src="screenshots/build-notes.png" alt="Panel Notas" width="380">
  <br><em>Botón de acceso rápido &nbsp;·&nbsp; Editor de notas con formato Markdown</em>
</p>

---

### Economy Window

<p align="center">
  <img src="screenshots/economy-window.png" alt="Economy Window" width="680">
  <br><em>Monitor de economía con popup de tasas cruzadas</em>
</p>

---

### Crafting Cheat Sheet

<p align="center">
  <img src="screenshots/crafting.png" alt="Crafting Cheat Sheet" width="680">
  <br><em>Panel de referencia rápida — todos los orbes y mecánicas de crafting de PoE2</em>
</p>

Accesible desde la pestaña **📖 Crafting** en la ventana de economía. Cubre:

- **Calidad** — Whetstone, Arcanist's Etcher, Armourer's Scrap, Gemcutter's Prism, Vaal Infuser
- **Cambio de rareza** — Transmutation, Augmentation, Regal, Alchemy, Chance
- **Modificación de mods** — Chaos Orb *(⚠ en PoE2 solo cambia 1 mod)*, Exalted, Annulment, Divine, Fracturing, Hinekora's Lock
- **Essences, Omens (Ritual), Catalysts (Breach)**
- **Corrupción y Vaal** — Vaal Orb, Vaal Cultivation Orb, Vaal Siphoner, Architect's Orb, Crystallised Corruption
- **Fate of the Vaal** — Ancient Infuser, Core Destabiliser, Orb of Extraction
- **Desecramiento (Abyss)** — Collarbone, Jawbone, Rib, Cranium, Vertebrae
- **Sockets de gema** — Artificer's Orb, Jeweller's Orbs

---

### Opciones de Liga

<p align="center">
  <img src="screenshots/league-options.png" alt="Opciones de Liga" width="680">
  <br><em>Selector de liga — cambia la fuente de datos sin reiniciar</em>
</p>

---

### Filtros NeverSink

<p align="center">
  <img src="screenshots/neversink-filter.png" alt="Filtros NeverSink" width="680">
  <br><em>Instalador integrado — detecta la ruta del juego, selecciona estilo y descarga todos los niveles de estrictez</em>
</p>

---

## Requisitos del sistema

- **Wayland** — Hyprland, KDE Plasma (Wayland), Sway u otro compositor compatible con `wlr-layer-shell`.
- **Path of Exile 2** instalado vía **Steam + Proton** (para la detección automática de la carpeta de filtros).

---

## Dependencias

| Paquete | Para qué |
|---------|----------|
| `quickshell` ≥ 0.3.0 | Runtime QML del overlay |
| `qt6-base` | Módulos Qt6 base |
| `qt6-declarative` | Motor QML |
| `python3` | Detección automática de la ruta de instalación |
| `curl` | Descarga de filtros NeverSink desde GitHub |
| `unzip` | Extracción del archivo ZIP de filtros |
| `bash` | Scripts de instalación y gestión de filtros |
| `xdotool` | Inyectar Ctrl+C al juego desde el Price Checker |

### Instalación de dependencias

**Arch / CachyOS / Manjaro:**
```bash
sudo pacman -S quickshell python curl unzip bash xdotool
```

**Otros sistemas:**  
Consulta el gestor de paquetes de tu distro. Quickshell puede instalarse desde [quickshell.outfoxxed.me](https://quickshell.outfoxxed.me).

---

## Instalación

```bash
git clone https://github.com/madkyp/poe2-overlay.git
cp -r poe2-overlay ~/.config/quickshell/poe2
```

Lanzar el overlay:
```bash
qs -p ~/.config/quickshell/poe2
```

O añadir a tu `hyprland.conf` para que arranque con el sistema:
```
exec-once = qs -p ~/.config/quickshell/poe2
```

### Atajo de teclado en Hyprland

Si prefieres lanzar el overlay con un atajo en lugar de arrancarlo al inicio, añade esto a tu `~/.config/hypr/hyprland.conf`:

```
bind = SUPER, M, exec, qs -p ~/.config/quickshell/poe2
```

Esto abre el overlay con **Super + M**. Puedes cambiar `M` por cualquier otra tecla.

> Si ya tienes el overlay corriendo y quieres usar el atajo para mostrarlo/ocultarlo, la opción más sencilla es arrancarlo con `exec-once` y controlar la visibilidad desde dentro de la app.

---

## Configuración

Al primer arranque el overlay detecta automáticamente la carpeta de filtros de PoE2 buscando en las rutas estándar de Steam (`~/.local/share/Steam`, `~/.steam/steam`). Si no la encuentra, puedes introducirla manualmente en la pestaña **Opciones → Filtros**.

La configuración (liga, POESESSID, notas, versión de filtro) se guarda automáticamente en el perfil de Quickshell entre sesiones.

---

## Stack técnico

| Capa | Tecnología |
|------|-----------|
| UI / lógica | QML (Qt 6) + Quickshell 0.3.0 |
| Scripting | JavaScript (inline QML) |
| HTTP | `XMLHttpRequest` (QML nativo) |
| Procesos externos | `Process` de Quickshell |
| Persistencia | `PersistentProperties` de Quickshell |
| Filtros | NeverSink Filter for PoE2 (GitHub releases) |

---

## Fuentes de datos

- **Precios**: [poe2.ninja](https://poe2.ninja) / API oficial de trade de PoE2
- **Filtros**: [NeverSinkDev/NeverSink-Filter-for-PoE2](https://github.com/NeverSinkDev/NeverSink-Filter-for-PoE2)

---

## Licencia

Uso personal. Path of Exile 2 y sus assets son propiedad de Grinding Gear Games. Los filtros NeverSink son obra de NeverSinkDev.

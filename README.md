# The Foundry: PoE2 App

Overlay de escritorio para **Path of Exile 2** construido con **Quickshell** (QML/Qt6) sobre Wayland. Muestra precios de items y divisa en tiempo real, notas de build, monitor de economía con tasas cruzadas e instalador automático de filtros NeverSink, todo sin salir del juego.

---

## Características

- **Price Checker** — Consulta el precio de cualquier item al vuelo usando la API de trade de PoE2. Muestra los primeros listados con precio, vendedor y liga.
- **Currency Tracker** — Widget siempre visible con el valor actualizado de las divisas principales (Divine, Exalted, Annulment, Vaal).
- **Notas de Build** — Panel lateral con editor Markdown para apuntar skills, items clave y pasivas de tu build.
- **Economy Window** — Tabla completa de divisa con popup de tasas cruzadas al pasar el ratón. Selección de categoría lateral.
- **Opciones de liga** — Cambia al vuelo entre ligas (Fate of the Vaal, HC, Standard, Hardcore…) sin reiniciar.
- **Instalador NeverSink** — Descarga e instala directamente los filtros NeverSink para PoE2 desde GitHub. Detecta automáticamente la carpeta del juego, muestra la versión instalada y avisa cuando hay actualizaciones.

---

## Capturas

### Price Checker
![Price Checker](screenshots/price-checker.png)
*Overlay de búsqueda de precios — muestra listados reales de la API de trade*

> **Uso (provisional):** Pasa el cursor sobre el item en el juego y pulsa **Ctrl + D** — la app inyecta el Ctrl + C automáticamente y muestra el precio.

### Currency Tracker
![Currency Tracker](screenshots/currency-tracker.png)
*Widget siempre visible con el valor de las divisas principales*

### Notas de Build

| | |
|---|---|
| ![Botón Notas](screenshots/build-notes-btn.png) | ![Panel Notas](screenshots/build-notes.png) |
| Botón de acceso rápido | Editor de notas con formato Markdown |

### Economy Window
![Economy Window](screenshots/economy-window.png)
*Monitor de economía con popup de tasas cruzadas (Mirror of Kalandra → rates)*

### Opciones de Liga
![Opciones](screenshots/league-options.png)
*Selector de liga — cambia la fuente de datos sin reiniciar*

### Filtros NeverSink
![NeverSink](screenshots/neversink-filter.png)
*Instalador integrado — detecta la ruta del juego, selecciona estilo y descarga todos los niveles de estrictez*

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

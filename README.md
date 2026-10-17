# mf_waypoint

[English](#english) · [Español](#español)

---

## English

3D waypoint system for FiveM: when you set a map waypoint, a floating UI with distance, a vertical light beam, and a ground ring appear at the destination.

### Features

- NUI overlay on the destination (distance in M/KM + label)
- Light beam from the ground up to the marker
- Glowing ground ring
- Fade-out on arrival (optional sound)
- Command to toggle the 3D display

### Installation

1. Copy the `mf_waypoint` folder into your resources.
2. Add to `server.cfg`:

```cfg
ensure mf_waypoint
```

3. Restart the server or run `ensure mf_waypoint`.

No dependencies required.

### Usage

Set a waypoint on the GTA map. The 3D marker appears automatically.

| Command (default) | Description |
| --- | --- |
| `/waypoint3d` | Toggle the 3D visualization on/off |

The command name is configured in `config.lua`.

### Configuration (`config.lua`)

| Option | Description | Default |
| --- | --- | --- |
| `ArrivalDistance` | Meters at which arrival is triggered | `15.0` |
| `AutoDeleteWaypoint` | Clear the map waypoint on arrival | `true` |
| `PlayArrivalSound` | Play sound on arrival | `true` |
| `ArrivalSoundName` / `ArrivalSoundSet` | GTA sound names | `CHECKPOINT_NORMAL` / `HUD_MINI_GAME_SOUNDSET` |
| `LabelText` | Text under the distance | `'DESTINO'` |
| `BeamRadius` | Beam thickness | `0.7` |
| `BeamColor` | Beam color (RGBA) | white |
| `GroundRingColor` | Ground ring color (RGBA) | red |
| `UIColor` | Arrow, divider line and glow color (RGB) | red |
| `EnableCommand` | Enable the toggle command | `true` |
| `CommandName` | Command name | `'waypoint3d'` |

#### Colors

```lua
-- Light beam
Config.BeamColor = { r = 255, g = 255, b = 255, a = 200 }

-- Ground ring
Config.GroundRingColor = { r = 255, g = 50, b = 50, a = 200 }

-- UI (arrow, line, glows)
Config.UIColor = { r = 255, g = 46, b = 46 }
```

`UIColor` examples:

```lua
Config.UIColor = { r = 50, g = 150, b = 255 }  -- blue
Config.UIColor = { r = 50, g = 255, b = 100 }  -- green
Config.UIColor = { r = 255, g = 200, b = 40 }  -- yellow
```

After changing the config: `restart mf_waypoint`.

### Structure

```
mf_waypoint/
├── config.lua
├── fxmanifest.lua
├── client/
│   └── main.lua
└── html/
    ├── index.html
    ├── style.css
    └── script.js
```

### Notes

- Client-side only resource.
- UI is hidden while the pause menu is open or the screen is faded.
- Compatible with the native map waypoint (blip type 8).

---

## Español

Sistema de waypoint 3D para FiveM: al marcar un punto en el mapa se muestra una interfaz flotante con distancia, un haz de luz vertical y un anillo en el suelo.

### Características

- UI NUI sobre el destino (distancia en M/KM + etiqueta)
- Haz de luz desde el suelo hasta el marcador
- Anillo brillante en el suelo
- Fade al llegar al destino (con sonido opcional)
- Comando para activar/desactivar la visualización 3D

### Instalación

1. Copia la carpeta `mf_waypoint` en tus resources.
2. Añade en `server.cfg`:

```cfg
ensure mf_waypoint
```

3. Reinicia el servidor o ejecuta `ensure mf_waypoint`.

No requiere dependencias.

### Uso

Marca un punto en el mapa (waypoint de GTA). El marcador 3D aparece automáticamente.

| Comando (por defecto) | Descripción |
| --- | --- |
| `/waypoint3d` | Activa o desactiva la visualización 3D |

El nombre del comando se configura en `config.lua`.

### Configuración (`config.lua`)

| Opción | Descripción | Por defecto |
| --- | --- | --- |
| `ArrivalDistance` | Metros a los que se considera llegada | `15.0` |
| `AutoDeleteWaypoint` | Quita el waypoint del mapa al llegar | `true` |
| `PlayArrivalSound` | Sonido al llegar | `true` |
| `ArrivalSoundName` / `ArrivalSoundSet` | Sonido de GTA | `CHECKPOINT_NORMAL` / `HUD_MINI_GAME_SOUNDSET` |
| `LabelText` | Texto bajo la distancia | `'DESTINO'` |
| `BeamRadius` | Grosor del haz | `0.7` |
| `BeamColor` | Color del haz (RGBA) | blanco |
| `GroundRingColor` | Color del anillo (RGBA) | rojo |
| `UIColor` | Color de flecha, línea y brillos (RGB) | rojo |
| `EnableCommand` | Activa el comando toggle | `true` |
| `CommandName` | Nombre del comando | `'waypoint3d'` |

#### Colores

```lua
-- Haz de luz
Config.BeamColor = { r = 255, g = 255, b = 255, a = 200 }

-- Anillo del suelo
Config.GroundRingColor = { r = 255, g = 50, b = 50, a = 200 }

-- UI (flecha, línea, brillos)
Config.UIColor = { r = 255, g = 46, b = 46 }
```

Ejemplos de `UIColor`:

```lua
Config.UIColor = { r = 50, g = 150, b = 255 }  -- azul
Config.UIColor = { r = 50, g = 255, b = 100 }  -- verde
Config.UIColor = { r = 255, g = 200, b = 40 }  -- amarillo
```

Tras cambiar el config: `restart mf_waypoint`.

### Estructura

```
mf_waypoint/
├── config.lua
├── fxmanifest.lua
├── client/
│   └── main.lua
└── html/
    ├── index.html
    ├── style.css
    └── script.js
```

### Notas

- Recurso solo client-side.
- Si el menú de pausa está abierto o la pantalla está en fade, la UI se oculta.
- Compatible con el waypoint nativo del mapa (blip tipo 8).

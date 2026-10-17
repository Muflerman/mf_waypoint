Config = {}

-- Distancia en metros a la que el waypoint se considera alcanzado y se desvanece
Config.ArrivalDistance = 15.0

-- Eliminar automáticamente el waypoint del mapa de GTA al llegar
Config.AutoDeleteWaypoint = true

-- Reproducir sonido sutil al llegar al destino
Config.PlayArrivalSound = true
Config.ArrivalSoundName = 'CHECKPOINT_NORMAL'
Config.ArrivalSoundSet  = 'HUD_MINI_GAME_SOUNDSET'

-- Texto mostrado debajo de la distancia
Config.LabelText = 'DESTINO'

-- Altura del haz de luz vertical (en metros)
Config.BeamHeight = 350.0

-- Grosor del haz de luz
Config.BeamRadius = 0.7

-- Color del haz de luz vertical (RGBA)
Config.BeamColor = { r = 255, g = 255, b = 255, a = 200 }

-- Color del anillo brillante en el suelo (RGBA)
Config.GroundRingColor = { r = 255, g = 50, b = 50, a = 200 }

-- Color de la UI del waypoint: flecha, línea divisoria y brillos (RGB 0-255)
Config.UIColor = { r = 255, g = 46, b = 46 }

-- Altura flotante del marcador UI sobre el suelo (se adapta a la distancia para mejor visibilidad)
Config.MinFloatHeight = 15.0
Config.MaxFloatHeight = 60.0

-- Permitir a los jugadores activar/desactivar la visualización 3D mediante comando
Config.EnableCommand = true
Config.CommandName = 'waypoint3d'

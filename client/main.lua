local isWaypointActive = false
local waypointCoords = nil
local groundZ = 0.0
local hasCalculatedGround = false
local realGroundFound = false
local lastWaypointPos = vec2(0.0, 0.0)
local isArrived = false
local enabled = true

-- Formateo de distancia (M o KM)
local function formatDistance(dist)
    if dist >= 1000 then
        local km = dist / 1000
        return string.format('%.1f', km), 'KM'
    else
        return tostring(math.floor(dist)), 'M'
    end
end

-- Cálculo de escala según distancia
local function getScale(dist)
    local minScale = 0.75
    local maxScale = 1.05
    local factor = 1.0 - (dist / 3000.0) * 0.3
    if factor < minScale then factor = minScale end
    if factor > maxScale then factor = maxScale end
    return factor
end

-- Intentar obtener la altura exacta del suelo
local function resolveGroundZ(x, y)
    local found, z = GetGroundZFor_3dCoord(x, y, 1000.0, false)
    if found then
        return z
    end

    -- Si el suelo no está cargado aún en streaming, probar alturas progresivas
    for h = 900.0, -100.0, -50.0 do
        local f, testZ = GetGroundZFor_3dCoord(x, y, h, false)
        if f then
            return testZ
        end
    end

    return 20.0
end

-- Comprobar si el waypoint del mapa está activo
local function checkWaypoint()
    if not enabled then return false, nil end

    -- Comprobación directa del blip de tipo 8 (Waypoint)
    local blip = GetFirstBlipInfoId(8)
    if DoesBlipExist(blip) then
        return true, GetBlipInfoIdCoord(blip)
    end

    if IsWaypointActive and IsWaypointActive() then
        local blipEnum = (GetWaypointBlipEnumId and GetWaypointBlipEnumId()) or 8
        local b = GetFirstBlipInfoId(blipEnum)
        if DoesBlipExist(b) then
            return true, GetBlipInfoIdCoord(b)
        end
    end

    return false, nil
end

local function sendUIColor()
    local c = Config.UIColor or { r = 255, g = 46, b = 46 }
    SendNUIMessage({
        action = 'setColor',
        color  = { r = c.r or 255, g = c.g or 46, b = c.b or 46 }
    })
end

-- Enviar color de UI al iniciar el recurso
CreateThread(function()
    Wait(100)
    sendUIColor()
end)

-- Hilo principal para monitorizar y renderizar el waypoint
CreateThread(function()
    print('^2[mf_waypoint]^0 Sistema de Waypoint 3D iniciado correctamente.')
    
    while true do
        if IsPauseMenuActive() or IsScreenFadedOut() then
            SendNUIMessage({
                action  = 'update',
                visible = false
            })
            Wait(150)
        else
            local active, coords = checkWaypoint()

            if active and coords then
                -- Si ha cambiado la posición del punto marcado o es nuevo
                local currentPos = vec2(coords.x, coords.y)
                if not isWaypointActive or #(currentPos - lastWaypointPos) > 1.0 then
                    isWaypointActive = true
                    lastWaypointPos = currentPos
                    waypointCoords = coords
                    groundZ = resolveGroundZ(coords.x, coords.y)
                    hasCalculatedGround = false
                    realGroundFound = false
                    isArrived = false
                end

            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)

            -- Actualizar la altura del suelo en cuanto esté cargada la colisión cercana
            if not realGroundFound then
                local found, actualZ = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, 1000.0, false)
                if found then
                    groundZ = actualZ
                    realGroundFound = true
                end
            end

            local baseZ = (groundZ and groundZ > -50.0) and groundZ or playerCoords.z
            local targetVec3 = vec3(waypointCoords.x, waypointCoords.y, baseZ)
            local distance = #(playerCoords - targetVec3)

            -- Comprobar si hemos llegado al destino
            if distance <= Config.ArrivalDistance and not isArrived then
                isArrived = true
                SendNUIMessage({ action = 'arrived' })

                if Config.PlayArrivalSound then
                    PlaySoundFrontend(-1, Config.ArrivalSoundName, Config.ArrivalSoundSet, true)
                end

                if Config.AutoDeleteWaypoint then
                    SetWaypointOff()
                end

                Wait(400)
                isWaypointActive = false
                waypointCoords = nil
                lastWaypointPos = vec2(0.0, 0.0)
                realGroundFound = false
            else
                -- Proyección a coordenadas de pantalla (2D) y cálculo de ancla
                local camCoords = GetGameplayCamCoord()
                local dist2D = #(vec2(camCoords.x, camCoords.y) - vec2(waypointCoords.x, waypointCoords.y))

                -- Altura dinámica: baja progresivamente conforme te vas acercando
                -- De lejos (>= 500m) flota alto en el cielo (~50m)
                -- Conforme te acercas, va descendiendo suavemente hasta posarse a ~2.2m del suelo al llegar
                local minHeight = 2.2
                local maxHeight = 50.0
                local progress = math.min(1.0, math.max(0.0, dist2D / 500.0))
                local heightAboveGround = minHeight + (progress * (maxHeight - minHeight))

                local anchorZ = baseZ + heightAboveGround

                -- Si está lejos y el destino está en una depresión, asegurar visibilidad sobre el horizonte
                if dist2D > 300.0 and anchorZ < (camCoords.z + 8.0) then
                    anchorZ = camCoords.z + (dist2D * 0.12) + 2.0
                end

                -- Haz de luz: nace en el suelo y termina EXACTAMENTE en la flecha roja (anchorZ), sin tapar ni sobrepasar los números
                local beamBottomZ = baseZ - 0.5
                local beamHeight = math.max(0.5, anchorZ - beamBottomZ)

                DrawMarker(
                    1,
                    waypointCoords.x, waypointCoords.y, beamBottomZ,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    Config.BeamRadius, Config.BeamRadius, beamHeight,
                    Config.BeamColor.r, Config.BeamColor.g, Config.BeamColor.b, Config.BeamColor.a,
                    false, false, 2, false, nil, nil, false
                )

                -- Dibujar anillos en el suelo si la cota Z es válida
                if groundZ and groundZ > -50.0 then
                    DrawMarker(
                        25,
                        waypointCoords.x, waypointCoords.y, groundZ + 0.05,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        3.5, 3.5, 1.0,
                        Config.GroundRingColor.r, Config.GroundRingColor.g, Config.GroundRingColor.b, Config.GroundRingColor.a,
                        false, false, 2, false, nil, nil, false
                    )
                end

                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(waypointCoords.x, waypointCoords.y, anchorZ)

                -- Si por el ángulo de cámara queda fuera de visión a corta distancia
                if not onScreen and dist2D < 400.0 then
                    local lowZ = baseZ + 3.0
                    onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(waypointCoords.x, waypointCoords.y, lowZ)
                end

                if onScreen then
                    local distStr, unitStr = formatDistance(distance)
                    local scale = getScale(distance)

                    SendNUIMessage({
                        action  = 'update',
                        visible = true,
                        x       = screenX,
                        y       = screenY,
                        dist    = distStr,
                        unit    = unitStr,
                        label   = Config.LabelText,
                        scale   = scale
                    })
                else
                    SendNUIMessage({
                        action  = 'update',
                        visible = false
                    })
                end
            end

            Wait(0)
        else
            if isWaypointActive then
                isWaypointActive = false
                waypointCoords = nil
                lastWaypointPos = vec2(0.0, 0.0)
                isArrived = false
                SendNUIMessage({ action = 'hide' })
            end
            Wait(250)
        end
        end
    end
end)

-- Comando opcional para alternar el sistema
if Config.EnableCommand then
    RegisterCommand(Config.CommandName, function()
        enabled = not enabled
        if not enabled then
            SendNUIMessage({ action = 'hide' })
        end
        local status = enabled and '~g~activado~s~' or '~r~desactivado~s~'
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(('Waypoint 3D %s'):format(status))
        EndTextCommandThefeedPostTicker(false, true)
    end, false)
end

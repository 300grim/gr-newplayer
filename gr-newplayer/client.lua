local QBCore = exports['qb-core']:GetCoreObject()

local isNewPlayer = false
local haloEnabled = true
local newPlayers = {}

local RENDER_DIST_SQ = 30.0 * 30.0

CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(500)
    end
    TriggerServerEvent('newplayer:requestSync')
end)

RegisterNetEvent('newplayer:setStatus', function(isNew)
    isNewPlayer = isNew
    if isNew then
        QBCore.Functions.Notify('You have a new player halo! Toggle with /halo', 'primary', 7500)
    end
end)

RegisterNetEvent('newplayer:syncAll', function(cache)
    newPlayers = {}
    local myId = GetPlayerServerId(PlayerId())
    for serverId, isNew in pairs(cache) do
        if isNew and serverId ~= myId then
            newPlayers[serverId] = true
        end
    end
end)

RegisterCommand('halo', function()
    QBCore.Functions.TriggerCallback('newplayer:checkNew', function(isNew)
        isNewPlayer = isNew

        if not isNew then
            QBCore.Functions.Notify('You\'re not a new player', 'error')
            return
        end

        haloEnabled = not haloEnabled
        QBCore.Functions.Notify(haloEnabled and 'Halo enabled' or 'Halo disabled', 'primary')
    end)
end, false)

TriggerEvent('chat:addSuggestion', '/halo', 'Toggle your new player halo')

CreateThread(function()
    while true do
        local drawing = false
        local myPed = PlayerPedId()
        local myCoords = GetEntityCoords(myPed)

        if isNewPlayer and haloEnabled then
            DrawHalo(myPed)
            drawing = true
        end

        for serverId, _ in pairs(newPlayers) do
            local targetPlayer = GetPlayerFromServerId(serverId)
            if targetPlayer ~= -1 then
                local targetPed = GetPlayerPed(targetPlayer)
                if targetPed ~= 0 and DoesEntityExist(targetPed) then
                    local tCoords = GetEntityCoords(targetPed)
                    local dx = myCoords.x - tCoords.x
                    local dy = myCoords.y - tCoords.y
                    local dz = myCoords.z - tCoords.z
                    if (dx*dx + dy*dy + dz*dz) < RENDER_DIST_SQ then
                        DrawHalo(targetPed)
                        drawing = true
                    end
                end
            end
        end

        Wait(drawing and 0 or 1000)
    end
end)

function DrawHalo(ped)
    local coords = GetEntityCoords(ped)
    DrawMarker(
        1,
        coords.x, coords.y, coords.z - 0.95,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        1.0, 1.0, 0.05,
        0, 200, 255, 180,
        false, false, 2, false, nil, nil, false
    )
end

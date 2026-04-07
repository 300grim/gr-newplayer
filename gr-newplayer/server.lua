local QBCore = exports['qb-core']:GetCoreObject()
local TWO_WEEKS = 14 * 24 * 60 * 60

local playerCache = {}

local function CheckIfNew(Player)
    local firstJoined = Player.PlayerData.metadata['first_joined']


    if firstJoined == nil then
        firstJoined = os.time()
        Player.Functions.SetMetaData('first_joined', firstJoined)
    end


    if firstJoined == 0 then return false end

    return (os.time() - firstJoined) < TWO_WEEKS
end

function LoadPlayer(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local isNew = CheckIfNew(Player)
    playerCache[src] = isNew

    TriggerClientEvent('newplayer:setStatus', src, isNew)
    TriggerClientEvent('newplayer:syncAll', -1, playerCache)
end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    LoadPlayer(source)
end)


AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Wait(2000)
    local players = QBCore.Functions.GetQBPlayers()
    for src, _ in pairs(players) do
        LoadPlayer(src)
    end
end)


QBCore.Functions.CreateCallback('newplayer:checkNew', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false) return end
    cb(CheckIfNew(Player))
end)

RegisterNetEvent('newplayer:requestSync', function()
    TriggerClientEvent('newplayer:syncAll', source, playerCache)
end)

AddEventHandler('playerDropped', function()
    local src = source
    if playerCache[src] ~= nil then
        playerCache[src] = nil
        TriggerClientEvent('newplayer:syncAll', -1, playerCache)
    end
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    if playerCache[src] ~= nil then
        playerCache[src] = nil
        TriggerClientEvent('newplayer:syncAll', -1, playerCache)
    end
end)

lib.versionCheck('Qbox-project/qbx_radio')

local config = require 'config.shared'
local restrictedChannels = config.restrictedChannels
local playerRadios = {}

exports.qbx_core:CreateUseableItem('radio', function(source)
    TriggerClientEvent('qbx_radio:client:use', source)
end)

if not config.whitelistSubChannels then
    for channel, jobs in pairs(restrictedChannels) do
        for i = 1, 99 do
            restrictedChannels[channel + (i / 100)] = jobs
        end
    end
end

for channel, jobs in pairs(restrictedChannels) do
    exports['pma-voice']:addChannelCheck(channel, function(source)
        local player = exports.qbx_core:GetPlayer(source)
        return jobs[player.PlayerData.job.name] and player.PlayerData.job.onduty
    end)
end

---@param source number
local function deleteProp(source)
    local prop = playerRadios[source]

    if prop then
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end

        playerRadios[source] = nil
    end
end

---@param source number
---@return number?
lib.callback.register('qbx_radio:server:spawnProp', function(source)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local object = CreateObject(`prop_cs_hand_radio`, coords.x, coords.y, coords.z, true, false, false)

    local propExists = lib.waitFor(function()
        if DoesEntityExist(object) then
            return true
        end
    end, locale('failed_spawn'), 2000)

    if not propExists then return end

    playerRadios[source] = object

    local netId = NetworkGetNetworkIdFromEntity(object)

    SetEntityIgnoreRequestControlFilter(object, true)

    return netId
end)

AddEventHandler('playerDropped', function()
    local src = source

    deleteProp(src)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    for i in pairs (playerRadios) do
        deleteProp(i)
    end
end)

RegisterNetEvent('qbx_radio:server:deleteProp', function()
    local src = source

    deleteProp(src)
end)
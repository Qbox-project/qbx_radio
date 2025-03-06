local config = require 'config.client'
local sharedConfig = require 'config.shared'
local radioMenu = false
local onRadio = false
local onChannel = false
local radioChannel = 0
local radioVolume = 50
local Radios = {}
local micClicks = config.defaultMicClicks

local function connectToRadio(channel)
    radioChannel = channel

    onChannel = true
    qbx.playAudio({
        audioName = 'Start_Squelch',
        audioRef = 'CB_RADIO_SFX',
        source = cache.ped
    })
    exports['pma-voice']:setRadioChannel(channel)
    exports['pma-voice']:setVoiceProperty('radioEnabled', true)
    if channel % 1 > 0 then
        exports.qbx_core:Notify(locale('joined_radio') .. channel .. ' MHz', 'success')
    else
        exports.qbx_core:Notify(locale('joined_radio') .. channel .. '0 MHz', 'success')
    end
end

local function leaveChannel()
    if onChannel then
        qbx.playAudio({
            audioName = 'End_Squelch',
            audioRef = 'CB_RADIO_SFX',
            source = cache.ped
        })
        exports.qbx_core:Notify(locale('left_channel'), 'error')
    end
    radioChannel = 0
    onChannel = false
    exports['pma-voice']:setRadioChannel(0)
    exports['pma-voice']:setVoiceProperty('radioEnabled', false)
end

local function adjustRadioChannel(increment)
    if not onRadio then
        return false
    end

    local rchannel = radioChannel + increment

    -- Skip restricted channels
    while sharedConfig.restrictedChannels[rchannel] do
        rchannel += increment
    end
    rchannel = math.min(math.max(rchannel, 1), config.maxFrequency)
    -- Validate the new channel
    if not rchannel or type(rchannel) ~= "number" or rchannel > config.maxFrequency or rchannel < 1 then
        exports.qbx_core:Notify(locale('invalid_channel'), 'error')
        return false
    end

    rchannel = qbx.math.round(rchannel, config.decimalPlaces)

    -- Check if already on the channel
    if rchannel == radioChannel then
        exports.qbx_core:Notify(locale('on_channel'), 'error')
        return false
    end

    -- Check restricted channel access
    local frequency = sharedConfig.whitelistSubChannels and rchannel or math.floor(rchannel)
    if sharedConfig.restrictedChannels[frequency] then
        local isJobAllowed = sharedConfig.restrictedChannels[frequency][QBX.PlayerData.job.name]
        if not (isJobAllowed and QBX.PlayerData.job.onduty) then
            exports.qbx_core:Notify(locale('restricted_channel'), 'error')
            return false
        end
    end

    -- Set the new channel
    radioChannel = rchannel
    return true
end

local function toggleRadio(toggle)
    radioMenu = toggle
    SetNuiFocus(radioMenu, radioMenu)

    TriggerServerEvent('qbx_radio:server:setHoldingRadio', radioMenu)
    if radioMenu then
        lib.playAnim(cache.ped, 'cellphone@', 'cellphone_text_read_base', 2.0, 2.0, -1, 51, 0.0, false, 0, false)
        SendNUIMessage({type = 'open'})
    else
        ClearPedTasks(cache.ped)
        SendNUIMessage({type = 'close'})
    end
end

local function cleanupRadioProp(serverId)
    if not Radios[serverId] then return end
    SetEntityAsMissionEntity(Radios[serverId], true, true)
    DeleteEntity(Radios[serverId])
    Radios[serverId] = nil
end

AddStateBagChangeHandler('isHoldingRadio', '', function(bagName, _, value, _, replicated)
    if replicated then return end

    local player = GetPlayerFromStateBagName(bagName)
    if not player then return end

    local serverId = GetPlayerServerId(player)

    if value then
        local model = lib.requestModel(`prop_cs_hand_radio`)
        if not model then return end

        local ped = lib.waitFor(function ()
            local playerPed = GetPlayerPed(player)
            if playerPed > 0 then return playerPed end
        end, locale('failed_spawn'), 3000)

        local coords = GetEntityCoords(ped)
        Radios[serverId] = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
        AttachEntityToEntity(Radios[serverId], ped, GetPedBoneIndex(ped, 28422), -0.01, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        SetModelAsNoLongerNeeded(model)
    else
        cleanupRadioProp(serverId)
    end
end)

RegisterNetEvent('onPlayerDropped', function(serverId)
    cleanupRadioProp(serverId)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    for serverId in pairs(Radios) do
        cleanupRadioProp(serverId)
    end
end)

local function powerButton()
    onRadio = not onRadio

    if not onRadio then
        leaveChannel()
        toggleRadio(false)
    end
end



local function isRadioOn()
    return onRadio
end

exports('IsRadioOn', isRadioOn)

-- Sets mic clicks to the default value when the player logs in.
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    exports['pma-voice']:setVoiceProperty("micClicks", config.defaultMicClicks)
end)

-- Resets state on logout, in case of character change.
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    powerButton()
end)

AddEventHandler('ox_inventory:itemCount', function(itemName, totalCount)
    if itemName ~= 'radio' then return end
    if totalCount <= 0 and radioChannel ~= 0 then
        powerButton()
    end
end)

RegisterNetEvent('qbx_radio:client:use', function()
    toggleRadio(not radioMenu)
end)

RegisterNetEvent('qbx_radio:client:onRadioDrop', function()
    if radioChannel ~= 0 then
        powerButton()
    end
end)

RegisterNUICallback('joinRadio', function(data, cb)
    if not onRadio then return cb('ok') end
    local rchannel = tonumber(data.channel)
    if not rchannel or type(rchannel) ~= "number" or rchannel > config.maxFrequency or rchannel < 1 then
        exports.qbx_core:Notify(locale('invalid_channel'), 'error')
        cb('ok')
        return
    end
    rchannel = qbx.math.round(rchannel, config.decimalPlaces)

    if rchannel == radioChannel then
        exports.qbx_core:Notify(locale('on_channel'), 'error')
        cb('ok')
        return
    end

    local frequency = not sharedConfig.whitelistSubChannels and math.floor(rchannel) or rchannel
    if sharedConfig.restrictedChannels[frequency] and (not sharedConfig.restrictedChannels[frequency][QBX.PlayerData.job.name] or not QBX.PlayerData.job.onduty) then
        exports.qbx_core:Notify(locale('restricted_channel'), 'error')
        cb('ok')
        return
    end

    connectToRadio(rchannel)
end)

RegisterNUICallback('leaveChannel', function(_, cb)
    if not onRadio then return cb('ok') end
    if radioChannel == 0 then
        exports.qbx_core:Notify(locale('not_on_channel'), 'error')
    else
        leaveChannel()
    end
    cb('ok')
end)

RegisterNUICallback('volumeUp', function(_, cb)
    if not onRadio then return cb('ok') end
    if radioVolume > 95 then
        exports.qbx_core:Notify(locale('max_volume'), 'error')
        return
    end

    radioVolume += 5
    exports.qbx_core:Notify(locale('new_volume') .. radioVolume, 'success')
    exports['pma-voice']:setRadioVolume(radioVolume)
    cb('ok')
end)

RegisterNUICallback('volumeDown', function(_, cb)
    if not onRadio then return cb('ok') end
    if radioVolume < 10 then
        exports.qbx_core:Notify(locale('min_volume'), 'error')
        return
    end

    radioVolume -= 5
    exports.qbx_core:Notify(locale('new_volume') .. radioVolume, 'success')
    exports['pma-voice']:setRadioVolume(radioVolume)
    cb('ok')
end)

RegisterNUICallback('increaseradiochannel', function(_, cb)
    if not onRadio then return cb('ok') end

    if adjustRadioChannel(1) then
        connectToRadio(radioChannel)
        cb(radioChannel)
    end
end)

RegisterNUICallback('decreaseradiochannel', function(_, cb)
    if not onRadio then return cb('ok') end

    if adjustRadioChannel(-1) then
        connectToRadio(radioChannel)
        cb(radioChannel)
    end
end)

RegisterNUICallback('toggleClicks', function(_, cb)
    if not onRadio then return cb('ok') end
    micClicks = not micClicks
    exports['pma-voice']:setVoiceProperty("micClicks", micClicks)
    qbx.playAudio({
        audioName = "Off_High",
        audioRef = 'MP_RADIO_SFX',
        source = cache.ped
    })
    exports.qbx_core:Notify(locale('clicks' .. (micClicks and 'On' or 'Off')), micClicks and 'success' or 'error')
    cb('ok')
end)

RegisterNUICallback('powerButton', function(_, cb)
    qbx.playAudio({
        audioName = "On_High",
        audioRef = 'MP_RADIO_SFX',
        source = cache.ped
    })
    powerButton()
    cb(onRadio and 'on' or 'off')
end)

RegisterNUICallback('escape', function(_, cb)
    toggleRadio(false)
    cb('ok')
end)

if config.leaveOnDeath then
    AddStateBagChangeHandler('isDead', ('player:%s'):format(cache.serverId), function(_, _, value)
        if value and onRadio and radioChannel ~= 0 then
            leaveChannel()
        end
    end)
end

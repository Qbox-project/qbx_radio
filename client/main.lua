local config = require 'config.client'
local sharedConfig = require 'config.shared'
local radioMenu = false
local onRadio = false
local onChannel = false
local radioChannel = 0
local radioVolume = 50
local micClicks = config.defaultMicClicks

local function connectToRadio(channel)
    radioChannel = channel
    if onChannel then
        exports['pma-voice']:setRadioChannel(0)
    else
        onChannel = true
        exports['pma-voice']:setVoiceProperty('radioEnabled', true)
        qbx.playAudio({
            audioName = 'Start_Squelch',
            audioRef = 'CB_RADIO_SFX',
            source = cache.ped
        })
    end
    exports['pma-voice']:setRadioChannel(channel)
    if channel % 1 > 0 then
        exports.qbx_core:Notify(locale('joined_radio')..channel..' MHz', 'success')
    else
        exports.qbx_core:Notify(locale('joined_radio')..channel..'0 MHz', 'success')
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

local function powerButton()
    onRadio = not onRadio

    if not onRadio then
        leaveChannel()
    end
end

local function toggleRadio(toggle)
    radioMenu = toggle
    SetNuiFocus(radioMenu, radioMenu)
    if radioMenu then
        exports.scully_emotemenu:playEmoteByCommand('wt')
        SendNUIMessage({type = 'open'})
    else
        exports.scully_emotemenu:cancelEmote()
        SendNUIMessage({type = 'close'})
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
	exports.qbx_core:Notify(locale('new_volume')..radioVolume, 'success')
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
	exports.qbx_core:Notify(locale('new_volume')..radioVolume, 'success')
	exports['pma-voice']:setRadioVolume(radioVolume)
	cb('ok')
end)

RegisterNUICallback('increaseradiochannel', function(_, cb)
    if not onRadio then return cb('ok') end
    radioChannel += 1
    exports['pma-voice']:setRadioChannel(radioChannel)
    exports.qbx_core:Notify(locale('new_channel')..radioChannel, 'success')
    cb(radioChannel)
end)

RegisterNUICallback('decreaseradiochannel', function(_, cb)
	if not onRadio then return cb('ok') end
	radioChannel -= 1
	radioChannel = radioChannel < 1 and 1 or radioChannel

	exports['pma-voice']:setRadioChannel(radioChannel)
	exports.qbx_core:Notify(locale('new_channel')..radioChannel, 'success')
	cb(radioChannel)
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
    exports.qbx_core:Notify(locale('clicks'..(micClicks and 'On' or 'Off')), micClicks and 'success' or 'error')
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
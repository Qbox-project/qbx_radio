local config = require 'config.client'
local sharedConfig = require 'config.shared'
local radioMenu = false
local onRadio = false
local radioChannel = 0
local radioVolume = 50
local radioProp = nil

local function connectToRadio(channel)
    radioChannel = channel
    if onRadio then
        exports['pma-voice']:setRadioChannel(0)
    else
        onRadio = true
        exports['pma-voice']:setVoiceProperty('radioEnabled', true)
    end
    exports['pma-voice']:setRadioChannel(channel)
    if channel % 1 > 0 then
        exports.qbx_core:Notify(Lang:t('joined_radio')..channel..' MHz', 'success')
    else
        exports.qbx_core:Notify(Lang:t('joined_radio')..channel..'.00 MHz', 'success')
    end
end

local function closeEvent()
	TriggerEvent('InteractSound_CL:PlayOnOne','click',0.6)
end

local function leaveradio()
    closeEvent()
    radioChannel = 0
    onRadio = false
    exports['pma-voice']:setRadioChannel(0)
    exports['pma-voice']:setVoiceProperty('radioEnabled', false)
    exports.qbx_core:Notify(Lang:t('left_channel'), 'error')
end

local function toggleRadioAnimation(pState)
    lib.requestAnimDict('cellphone@')
	if pState then
		TriggerEvent('attachItemRadio','radio01')
		TaskPlayAnim(cache.ped, 'cellphone@', 'cellphone_text_read_base', 2.0, 3.0, -1, 49, 0, 0, 0, 0)
		radioProp = CreateObject(`prop_cs_hand_radio`, 1.0, 1.0, 1.0, 1, 1, 0)
		AttachEntityToEntity(radioProp, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
	else
		StopAnimTask(cache.ped, 'cellphone@', 'cellphone_text_read_base', 1.0)
		ClearPedTasks(cache.ped)
		if radioProp ~= 0 then
			DeleteObject(radioProp)
			radioProp = 0
		end
	end
end

local function toggleRadio(toggle)
    radioMenu = toggle
    SetNuiFocus(radioMenu, radioMenu)
    if radioMenu then
        toggleRadioAnimation(true)
        SendNUIMessage({type = 'open'})
    else
        toggleRadioAnimation(false)
        SendNUIMessage({type = 'close'})
    end
end

local function isRadioOn()
    return onRadio
end

exports('IsRadioOn', isRadioOn)

-- Resets state on logout, in case of character change.
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    leaveradio()
end)

AddEventHandler('ox_inventory:itemCount', function(itemName, totalCount)
    if itemName ~= 'radio' then return end
    if not totalCount > 0 and radioChannel ~= 0 then
        leaveradio()
    end
end)

RegisterNetEvent('qbx_radio:client:use', function()
    toggleRadio(not radioMenu)
end)

RegisterNetEvent('qbx_radio:client:onRadioDrop', function()
    if radioChannel ~= 0 then
        leaveradio()
    end
end)

RegisterNUICallback('joinRadio', function(data, cb)
    local rchannel = tonumber(data.channel)
    if not rchannel or type(rchannel) ~= "number" or rchannel > config.maxFrequency or rchannel < 1 then
        exports.qbx_core:Notify(Lang:t('invalid_channel'), 'error')
        cb('ok')
        return
    end
    rchannel = qbx.math.round(rchannel, config.decimalPlaces)

    if rchannel == radioChannel then
        exports.qbx_core:Notify(Lang:t('on_channel'), 'error')
        cb('ok')
        return
    end

    local frequency = not sharedConfig.whitelistSubChannels and math.floor(rchannel) or rchannel
    if sharedConfig.restrictedChannels[frequency] and (not sharedConfig.restrictedChannels[frequency][QBX.PlayerData.job.name] or not QBX.PlayerData.job.onduty) then
        exports.qbx_core:Notify(Lang:t('restricted_channel'), 'error')
        cb('ok')
        return
    end

    connectToRadio(rchannel)
end)

RegisterNUICallback('leaveRadio', function(_, cb)
    if radioChannel == 0 then
        exports.qbx_core:Notify(Lang:t('not_on_channel'), 'error')
    else
        leaveradio()
    end
    cb('ok')
end)

RegisterNUICallback('volumeUp', function(_, cb)
	if not onRadio then return cb('ok') end
	if radioVolume > 95 then
        exports.qbx_core:Notify(Lang:t('max_volume'), 'error')
	    return
	end

	radioVolume += 5
	exports.qbx_core:Notify(Lang:t('new_volume')..radioVolume, 'success')
	exports['pma-voice']:setRadioVolume(radioVolume)
	cb('ok')
end)

RegisterNUICallback('volumeDown', function(_, cb)
	if not onRadio then return cb('ok') end
	if radioVolume < 10 then
        exports.qbx_core:Notify(Lang:t('min_volume'), 'error')
		return
	end

	radioVolume -= 5
	exports.qbx_core:Notify(Lang:t('new_volume')..radioVolume, 'success')
	exports['pma-voice']:setRadioVolume(radioVolume)
	cb('ok')
end)

RegisterNUICallback('increaseradiochannel', function(_, cb)
    if not onRadio then return cb('ok') end
    radioChannel += 1
    exports['pma-voice']:setRadioChannel(radioChannel)
    exports.qbx_core:Notify(Lang:t('new_channel')..radioChannel, 'success')
    cb('ok')
end)

RegisterNUICallback('decreaseradiochannel', function(_, cb)
	if not onRadio then return cb('ok') end
	radioChannel -= 1
	radioChannel = radioChannel < 1 and 1 or radioChannel

	exports['pma-voice']:setRadioChannel(radioChannel)
	exports.qbx_core:Notify(Lang:t('new_channel')..radioChannel, 'success')
	cb('ok')
end)

RegisterNUICallback('poweredOff', function(_, cb)
    leaveradio()
    cb('ok')
end)

RegisterNUICallback('escape', function(_, cb)
    toggleRadio(false)
    cb('ok')
end)

if config.leaveOnDeath then
    AddStateBagChangeHandler('isDead', ('player:%s'):format(cache.serverId), function(_, _, value)
        if value and onRadio and radioChannel ~= 0 then
            leaveradio()
        end
    end)
end

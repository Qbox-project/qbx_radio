lib.versionCheck('Qbox-project/qbx_radio')

local config = require 'config.shared'
local restrictedChannels = config.restrictedChannels

exports.qbx_core:CreateUseableItem('radio', function(source)
    TriggerClientEvent('qbx_radio:client:use', source)
end)

if not config.whitelistSubChannels then
    for channel, v in ipairs(restrictedChannels) do
        for i = 1, 99 do
            restrictedChannels[channel + (i / 100)] = v
        end
    end
end

for channel, jobs in pairs(restrictedChannels) do
    exports['pma-voice']:addChannelCheck(channel, function(source)
        local player = exports.qbx_core:GetPlayer(source)
        return jobs[player.PlayerData.job.name] and player.PlayerData.job.onduty
    end)
end

RegisterNetEvent('qbx_radio:server:setHoldingRadio', function(bool)
    local src = source
    if type(bool) ~= 'boolean' then return end
    Player(src).state.isHoldingRadio = bool
end)
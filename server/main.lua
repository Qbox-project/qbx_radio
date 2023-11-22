exports.qbx_core:CreateUseableItem('radio', function(source)
    TriggerClientEvent('qbx_radio:client:use', source)
end)

for channel, config in pairs(config.restrictedChannels) do
    exports['pma-voice']:addChannelCheck(channel, function(source)
        local player = exports.qbx_core:GetPlayer(source)
        return config[player.PlayerData.job.name] and player.PlayerData.job.onduty
    end)
end

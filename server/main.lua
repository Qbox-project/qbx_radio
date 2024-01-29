local config = require 'config.shared'

exports.qbx_core:CreateUseableItem('radio', function(source)
    TriggerClientEvent('qbx_radio:client:use', source)
end)

for channel = 1, 11 do
    exports['pma-voice']:addChannelCheck(channel, function(source)
        local player = exports.qbx_core:GetPlayer(source)
        return (player.PlayerData.job.type == 'leo' or player.PlayerData.job.type == 'ems') and player.PlayerData.job.onduty
    end)
end

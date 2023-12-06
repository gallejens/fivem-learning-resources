-- make humanekeycard usable item and link event
QBCore.Functions.CreateUseableItem('humanekeycard', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemByName('humanekeycard') ~= nil then
        TriggerClientEvent("humanekeycard:UseKeycard", source)
    end
end)

-- event gets called to make sure newly joined players also have open doors if theyve been opened
RegisterServerEvent('jens-humanelabs:server:SetupKeycard')
AddEventHandler('jens-humanelabs:server:SetupKeycard', function(state)
    Config.KeycardUsed = state
	TriggerClientEvent("jens-humanelabs:client:SetupKeycard", -1, Config.KeycardUsed)
end)
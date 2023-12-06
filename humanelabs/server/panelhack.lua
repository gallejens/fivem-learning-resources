RegisterServerEvent('jens-humanelabs:server:SetPanelHacked')
AddEventHandler('jens-humanelabs:server:SetPanelHacked', function(state)
    Config.PanelHacked = state
    TriggerClientEvent('jens-humanelabs:client:SetPanelHacked', -1, state)
end)
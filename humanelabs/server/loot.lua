RegisterServerEvent('jens-humanelabs:server:UnlockLoot')
AddEventHandler('jens-humanelabs:server:UnlockLoot', function()
    Config.LootUnlocked = true
    TriggerClientEvent('jens-humanelabs:client:UnlockLoot', -1)
end)

RegisterServerEvent('jens-humanelabs:server:SetLootTaken')
AddEventHandler('jens-humanelabs:server:SetLootTaken', function(locId, state)
    Config.LootLocations[locId].Taken = state
    TriggerClientEvent('jens-humanelabs:client:SetLootTaken', -1, locId, state)
end)
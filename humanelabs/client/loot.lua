-- Checks if ur close to any of the doors every half a second and opens or closed the door
-- also checks if every task has been completed to unlock loot
Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(500)

        if not Config.LootUnlocked then
            if not Config.Lockdown and Config.DoorsOpened and Config.PanelHacked and Config.LockersPicked and Config.PincodeEntered and Config.ScalesActivated and Config.KeycardUsed[1] and Config.KeycardUsed[2] then
                TriggerServerEvent('jens-humanelabs:server:UnlockLoot')
            end
        end

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for i = 8, 9 do
            local distance = #(pos - Config.Doors[i].objCoords)
            if distance < 15 then
                local object = GetClosestObjectOfType(Config.Doors[i].objCoords.x, Config.Doors[i].objCoords.y, Config.Doors[i].objCoords.z, 5.0, Config.Doors[i].objName, false, false, false)

                if object ~= 0 then
                    FreezeEntityPosition(object, not Config.LootUnlocked)
                    Citizen.Wait(10)
                end
            end
        end
    end
end)

RegisterNetEvent('jens-humanelabs:client:UnlockLoot')
AddEventHandler('jens-humanelabs:client:UnlockLoot', function()
    Config.LootUnlocked = true;
end)

--Shows textbox to search location and logic behind searching
Citizen.CreateThread(function()
    Citizen.Wait(1500)

    while true do
        if Config.LootUnlocked then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
    
            for i = 1, #Config.LootLocations do
                if not Config.LootLocations[i].Taken then
                    local distance = #(pos - Config.LootLocations[i].Position)
    
                    if distance < 1 then
                        DrawText3Ds(Config.LootLocations[i].Position.x, Config.LootLocations[i].Position.y, Config.LootLocations[i].Position.z, '~g~E~w~ - Take')
        
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent('jens-humanelabs:server:SetLootTaken', i, true)
                            QBCore.Functions.Progressbar("loot", "Taking items...", 15000, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {
                                animDict = "anim@gangops@facility@servers@bodysearch@",
                                anim = "player_search",
                                flags = 16,
                            }, {}, {}, function() -- Done
                                StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@", "player_search", 1.0)
                                
                                local item
                                local rng = math.random(1, 100)
                                local chance = 0
                                for i = 1, #Config.LootPool do
                                    chance = chance + Config.LootPool[i].Chance
                                    if rng < chance then
                                        item = Config.LootPool[i].Name
                                        break
                                    end
                                end
                                
                                TriggerServerEvent("QBCore:Server:AddItem", item, 1)
                                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[item], "add")
                            end, function() -- Cancel
                                StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@", "player_search", 1.0)
                                TriggerServerEvent('jens-humanelabs:server:SetLootTaken', i, false)
                                QBCore.Functions.Notify("Canceled..", "error")
                            end)
                        end
                    end
                end
            end
        end

        Citizen.Wait(1)
    end
end)

-- update to all clients
RegisterNetEvent('jens-humanelabs:client:SetLootTaken')
AddEventHandler('jens-humanelabs:client:SetLootTaken', function(locId, state)
    Config.LootLocations[locId].Taken = state
end)
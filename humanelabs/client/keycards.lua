-- Checks if ur close to any of the doors every half a second and opens or closed the door
Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(500)

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for i = 4, 7 do
            local distance = #(pos - Config.Doors[i].objCoords)
            if distance < 25 then
                local object = GetClosestObjectOfType(Config.Doors[i].objCoords.x, Config.Doors[i].objCoords.y, Config.Doors[i].objCoords.z, 5.0, Config.Doors[i].objName, false, false, false)

                if object ~= 0 then
                    local keycardId = 1
                    if i == 6 or i == 7 then
                        keycardId = 2
                    end

                    FreezeEntityPosition(object, not Config.KeycardUsed[keycardId])
                    Citizen.Wait(10)
                end
            end
        end
    end
end)

RegisterNetEvent('humanekeycard:UseKeycard')
AddEventHandler('humanekeycard:UseKeycard', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    if not Config.Lockdown and Config.DoorsOpened then
        for i = 1, #Config.KeycardPosition do
            if not Config.KeycardUsed[i] then
                local distance = #(pos - Config.KeycardPosition[i])
    
                if distance < 1.0 then
                    QBCore.Functions.Progressbar("humanekeycard_use", "Swiping the card", 2000, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {
                        animDict = "mp_fbi_heist",
                        anim = "card_swipe",
                        flags = 16,
                    }, {}, {}, function() -- Function gets called when loadbar finished
                        StopAnimTask(PlayerPedId(), "mp_fbi_heist", "card_swipe", 1.0)
            
                        TriggerServerEvent("QBCore:Server:RemoveItem", "humanekeycard", 1)
                        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["humanekeycard"], "remove")
                        QBCore.Functions.Notify("Card got scratched...", "error")

                        Config.KeycardUsed[i] = true
                    TriggerServerEvent('jens-humanelabs:server:SetupKeycard', Config.KeycardUsed)
                    end, function() -- Cancel
                        StopAnimTask(PlayerPedId(), "mp_fbi_heist", "card_swipe", 1.0)
                        QBCore.Functions.Notify("Canceled..", "error")
                    end)
                end
            end
        end
    end
end)

RegisterNetEvent('jens-humanelabs:client:SetupKeycard')
AddEventHandler('jens-humanelabs:client:SetupKeycard', function(state)
    Config.KeycardUsed = state
end)



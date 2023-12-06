local requiredItemsShowed = false
Citizen.CreateThread(function()
    Citizen.Wait(2000)

    local requiredItems = {
        [1] = {name = QBCore.Shared.Items["electronickit"]["name"], image = QBCore.Shared.Items["electronickit"]["image"]},
        [2] = {name = QBCore.Shared.Items["trojan_usb"]["name"], image = QBCore.Shared.Items["trojan_usb"]["image"]},
    }

    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local distance = #(pos - Config.PanelHackPosition)

        if not Config.Lockdown and Config.DoorsOpened and not Config.PanelHacked then
            if distance < 1 then
                if not requiredItemsShowed then
                    requiredItemsShowed = true
                    TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                end
            else
                if requiredItemsShowed then
                    requiredItemsShowed = false
                    TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                end
            end
        else
            Citizen.Wait(1500)
        end

        Citizen.Wait(1)
    end
end)

RegisterNetEvent('electronickit:UseElectronickit')
AddEventHandler('electronickit:UseElectronickit', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local distance = #(pos - Config.PanelHackPosition)

    if not Config.Lockdown and Config.DoorsOpened then
        if not Config.PanelHacked then
            if distance < 1 then
                QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasItem)
                    if hasItem then 
                        TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                        TriggerServerEvent('jens-humanelabs:server:SetPanelHacked', true)
                        QBCore.Functions.Progressbar("hack_panel", "Connecting the hacking device ..", math.random(10000, 20000), false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = true,
                            disableCombat = true,
                        }, {
                            animDict = "anim@gangops@facility@servers@",
                            anim = "hotwire",
                            flags = 16,
                        }, {}, {}, function() -- Done
                            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                            
                            TriggerServerEvent("QBCore:Server:RemoveItem", "electronickit", 1)
                            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["electronickit"], "remove")
                            TriggerServerEvent("QBCore:Server:RemoveItem", "trojan_usb", 1)
                            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["trojan_usb"], "remove")
    
                            TriggerEvent("mhacking:show")
                            TriggerEvent("mhacking:start", math.random(6, 7), math.random(12, 15), OnHackDone)
                        end, function() -- Cancel
                            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                            TriggerServerEvent('jens-humanelabs:server:SetPanelHacked', false)
                            QBCore.Functions.Notify("Canceled..", "error")
                        end)
                    else
                        QBCore.Functions.Notify("You're missing an item ..", "error")
                    end
                end, "trojan_usb")
            end
        end
    end
end)

function OnHackDone(success) 
    TriggerEvent('mhacking:hide')

    if success then
        QBCore.Functions.Notify('Hack completed', 'success')
    else
        TriggerServerEvent('jens-humanelabs:server:SetLockdown', true)
    end
end

RegisterNetEvent('jens-humanelabs:client:SetPanelHacked')
AddEventHandler('jens-humanelabs:client:SetPanelHacked', function(state)
    Config.PanelHacked = state
end)
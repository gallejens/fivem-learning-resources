local noteInfo = {
    location, text, code
}

--Shows textbox to search location and logic behind searching
Citizen.CreateThread(function()
    Citizen.Wait(2000)
    
    QBCore.Functions.TriggerCallback('jens-humanelabs:server:GetNoteInfo', function(cb)
        noteInfo = cb
    end)

    -- wait for server callback
    Citizen.Wait(50)

    while true do
        if not Config.Lockdown and Config.DoorsOpened then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
    
            for i = 1, #Config.SearchLocations do
                if not Config.SearchLocations[i].Searched then
                    local distance = #(pos - Config.SearchLocations[i].Position)
    
                    if distance < 1 then
                        DrawText3Ds(Config.SearchLocations[i].Position.x, Config.SearchLocations[i].Position.y, Config.SearchLocations[i].Position.z, '~g~E~w~ - Search')
        
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent('jens-humanelabs:server:SetLocationSearched', i, true)
                            QBCore.Functions.Progressbar("search_location", "Searching...", 10000, false, true, {
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

                                if i == noteInfo.location then
                                    TriggerServerEvent('jens-humanelabs:server:GiveNote')
                                else
                                    local item = Config.SearchItemPool[math.random(1, #Config.SearchItemPool - 1)]
                                    TriggerServerEvent("QBCore:Server:AddItem", item, 1)
                                    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[item], "add")
                                end
                            end, function() -- Cancel
                                StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@", "player_search", 1.0)
                                TriggerServerEvent('jens-humanelabs:server:SetLocationSearched', i, false)
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
RegisterNetEvent('jens-humanelabs:client:SetLocationSearched')
AddEventHandler('jens-humanelabs:client:SetLocationSearched', function(searchId, state)
    Config.SearchLocations[searchId].Searched = state
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)

    while true do
        if not Config.Lockdown and Config.DoorsOpened and not Config.PincodeEntered then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
    
            local distance = #(pos - Config.KeypadPosition)
    
            if distance < 1 then
                DrawText3Ds(Config.KeypadPosition.x, Config.KeypadPosition.y, Config.KeypadPosition.z, '~g~E~w~ - Enter code')

                if IsControlJustPressed(0, 38) then
                    SendNUIMessage({
                        action = "open"
                    })
                    SetNuiFocus(true, true)
                end
            end
        end

        Citizen.Wait(1)
    end
end)

RegisterNUICallback('PinpadClose', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('EnterPincode', function(d)
    if tonumber(d.pin) == noteInfo.code then
        TriggerServerEvent('jens-humanelabs:server:SetPincodeEntered')
        QBCore.Functions.Notify('Code correct!', 'success')
    else
        TriggerServerEvent('jens-humanelabs:server:SetLockdown', true)
        QBCore.Functions.Notify('Incorrect code...', 'error')
    end
end)

-- update to all clients
RegisterNetEvent('jens-humanelabs:client:SetPincodeEntered')
AddEventHandler('jens-humanelabs:client:SetPincodeEntered', function()
    Config.PincodeEntered = true
end)


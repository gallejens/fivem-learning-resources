--Shows required items on location
local requiredItemsShowed = false
local requiredItems = {}
Citizen.CreateThread(function()
    Citizen.Wait(2000)

    requiredItems = {
        [1] = {name = QBCore.Shared.Items["lockpick"]["name"], image = QBCore.Shared.Items["lockpick"]["image"]},
        [2] = {name = QBCore.Shared.Items["screwdriverset"]["name"], image = QBCore.Shared.Items["screwdriverset"]["image"]},
    }

    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local distance = #(pos - Config.LockersPosition)

        if QBCore ~= nil then
            if not Config.Lockdown and Config.DoorsOpened and not Config.LockersPicked then
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
        end

        Citizen.Wait(1)
    end
end)

RegisterNetEvent("lockpicks:UseLockpick")
AddEventHandler("lockpicks:UseLockpick", function(isAdvanced)
    usingAdvanced = isAdvanced
    
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        hasToolkit = result
    end, "screwdriverset")

    -- callback not finished without delay
    Citizen.Wait(50)

    if hasToolkit or usingAdvanced then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local distance = #(pos - Config.LockersPosition)

        if distance < 1 then
            if not Config.Lockdown and Config.DoorsOpened and not Config.LockersPicked then
                TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                TriggerEvent('qb-lockpick:client:openLockpick', lockpickFinish)
            end
        end   
    end
end)

function lockpickFinish(success)
    if success then
        TriggerServerEvent("QBCore:Server:AddItem", "scalesbutton", 1)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["scalesbutton"], "add")
        TriggerServerEvent('jens-humanelabs:server:SetLockpicked')
    else
        if usingAdvanced then
            local itemInfo = QBCore.Shared.Items["advancedlockpick"]
            if math.random(1, 100) < 20 then
                TriggerServerEvent("QBCore:Server:RemoveItem", "advancedlockpick", 1)
                TriggerEvent('inventory:client:ItemBox', itemInfo, "remove")
            end
        else
            local itemInfo = QBCore.Shared.Items["lockpick"]
            if math.random(1, 100) < 40 then
                TriggerServerEvent("QBCore:Server:RemoveItem", "lockpick", 1)
                TriggerEvent('inventory:client:ItemBox', itemInfo, "remove")
            end
        end
    end
end

-- Gets triggered to return weight on scales
RegisterNetEvent('scalesbutton:UseButton')
AddEventHandler('scalesbutton:UseButton', function()
    loadAnimDict("anim@mp_player_intmenu@key_fob@")
    TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false, false)

    TriggerServerEvent("QBCore:Server:RemoveItem", "scalesbutton", 1)
    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items['scalesbutton'], "remove")

    if Config.LockersPicked and Config.KeycardUsed[1] and Config.KeycardUsed[2] then
        TriggerServerEvent('jens-humanelabs:server:CheckScales')
    end
end)


RegisterNetEvent('jens-humanelabs:client:SetLockpicked')
AddEventHandler('jens-humanelabs:client:SetLockpicked', function()
    Config.LockersPicked = true
end)

RegisterNetEvent('jens-humanelabs:client:SetScalesActivated')
AddEventHandler('jens-humanelabs:client:SetScalesActivated', function()
    Config.ScalesActivated = true
end)


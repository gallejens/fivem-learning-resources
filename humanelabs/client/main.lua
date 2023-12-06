Citizen.CreateThread(function()
    Citizen.Wait(100)
    TriggerServerEvent('jens-humanelabs:server:SetupConfig')
end)

RegisterNetEvent('jens-humanelabs:client:SetupConfig')
AddEventHandler('jens-humanelabs:client:SetupConfig', function(config)
    Config = config
end)

-- event get called when hack failed
RegisterNetEvent('jens-humanelabs:client:SetLockdown')
AddEventHandler('jens-humanelabs:client:SetLockdown', function()
    Config.Lockdown = true
end)

-- get coords from server to prevent serverdumb
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    QBCore.Functions.TriggerCallback('jens-humanelabs:server:GetCoords', function(empShop, keycardShop, sellLocation)
        Config.EMPShop = empShop
        Config.KeycardShop = keycardShop
        Config.SellLocation = sellLocation
    end)
end)

-- Show sell location
Citizen.CreateThread(function()
    Citizen.Wait(700)

    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if #(pos - Config.SellLocation) < 1  then
            if GetClockHours() >= 0 and GetClockHours() <= 24 then
                DrawText3Ds(Config.SellLocation.x, Config.SellLocation.y, Config.SellLocation.z, '~g~E~w~ - Sell items')
    
                if IsControlJustPressed(0, 38) then
                    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
                    QBCore.Functions.Progressbar("sell_items", "Checking items", 3000, false, true, {}, {}, {}, {}, function() -- Done
                        ClearPedTasks(PlayerPedId())
                        TriggerServerEvent('jens-humanelabs:server:SellItems')
                    end, function() -- Cancel
                        ClearPedTasks(PlayerPedId())
                        QBCore.Functions.Notify("Canceled...", "error")
                    end)          
                end
            else
                DrawText3Ds(Config.SellLocation.x, Config.SellLocation.y, Config.SellLocation.z, 'Come back at night')
            end
        end   

        Citizen.Wait(1)
    end
end)

--Shows required items for emp buy on location
local requiredItemsShowed = false
local requiredItems = {}
Citizen.CreateThread(function()
    Citizen.Wait(800)

    requiredItems = {
        [1] = {name = QBCore.Shared.Items["electronickit"]["name"], image = QBCore.Shared.Items["electronickit"]["image"]},
    }

    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if #(pos - Config.EMPShop) < 1 then
            if not requiredItemsShowed then
                requiredItemsShowed = true
                TriggerEvent('inventory:client:requiredItems', requiredItems, true)
            end

            DrawText3Ds(Config.EMPShop.x, Config.EMPShop.y, Config.EMPShop.z, '~g~E~w~ - Buy MiniEMP')

            if IsControlJustPressed(0, 38) then
                RequestAnimDict(mp_common)
                TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, 1.0, -1, 16, 0, 0, 0, 0)
                Citizen.Wait(2000)
                ClearPedTasks(ped)

                TriggerServerEvent('jens-humanelabs:server:BuyEMP')
            end
        else
            if requiredItemsShowed then
                requiredItemsShowed = false
                TriggerEvent('inventory:client:requiredItems', requiredItems, false)
            end
        end

        Citizen.Wait(1)
    end
end)

--Shows required items for keycard shop on location
Citizen.CreateThread(function()
    Citizen.Wait(900)

    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if QBCore ~= nil then
            if #(pos - Config.KeycardShop) < 1 then
                DrawText3Ds(Config.KeycardShop.x, Config.KeycardShop.y, Config.KeycardShop.z, '~g~E~w~ - Buy Keycard')

                if IsControlJustPressed(0, 38) then
                    RequestAnimDict(mp_common)
                    TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, 1.0, -1, 16, 0, 0, 0, 0)
                    Citizen.Wait(2000)
                    ClearPedTasks(ped)

                    TriggerServerEvent('jens-humanelabs:server:BuyKeycard')
                end
            end
        end

        Citizen.Wait(1)
    end
end)

-- load shop npcs
Citizen.CreateThread(function()
    Citizen.Wait(500)
      
    SetNPC(Config.KeycardShop, 50.0, 's_m_y_blackops_01', "mini@strip_club@idles@bouncer@idle_a", "idle_a")
    SetNPC(Config.EMPShop, 300.0, 's_m_y_dealer_01', "missheistdockssetup1ig_2_p1@new_structure", "wait_loop_supervisor")
    SetNPC(Config.SellLocation, 120.0, 's_m_y_autopsy_01', "mini@strip_club@idles@bouncer@idle_a", "idle_a")
end)

function SetNPC(coords, heading, model, animDict, anim) 
    local modelHash = GetHashKey(model)
  
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(1)
    end
  
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(1)
    end

    ped = CreatePed(4, modelHash, coords.x, coords.y, coords.z - 1, heading, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskPlayAnim(ped, animDict, anim, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
end
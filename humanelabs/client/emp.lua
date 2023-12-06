local closestEMPableBox = 0
local currentCops = 0

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
    currentCops = amount
end)

-- Look closest EMPable box
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist

        if QBCore ~= nil then
            local inRange = false
            for k, v in pairs(Config.EMPableBoxes) do
                dist = #(pos - Config.EMPableBoxes[k].coords)
                if dist < 5 then
                    closestEMPableBox = k
                    inRange = true
                end
            end

            if not inRange then
                Citizen.Wait(1000)
                closestEMPableBox = 0
            end
        end
        Citizen.Wait(3)
    end
end)

--Shows required items on location
local requiredItemsShowed = false
local requiredItems = {}
Citizen.CreateThread(function()
    Citizen.Wait(2000)

    requiredItems = {
        [1] = {name = QBCore.Shared.Items["miniemp"]["name"], image = QBCore.Shared.Items["miniemp"]["image"]},
    }

    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if QBCore ~= nil then
            if closestEMPableBox ~= 0 then
                if not Config.EMPableBoxes[closestEMPableBox].hit and not Config.Lockdown then
                    local dist = #(pos - Config.EMPableBoxes[closestEMPableBox].coords)
                    if dist < 0.5 then
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
                end
            else
                Citizen.Wait(1500)
            end
        end

        Citizen.Wait(1)
    end
end)

-- logic about using the emp
RegisterNetEvent('miniemp:UseMiniEMP')
AddEventHandler('miniemp:UseMiniEMP', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    if closestEMPableBox ~= 0 then
        local dist = #(pos - Config.EMPableBoxes[closestEMPableBox].coords)
        if dist < 0.5 then
            if not Config.Lockdown and not Config.DoorsOpened then
                if currentCops >= Config.MinimumPolice then
                    if not Config.EMPableBoxes[closestEMPableBox].hit then
                        TriggerEvent('inventory:client:requiredItems', requiredItems, false) --disable required item box
                        TriggerServerEvent('jens-humanelabs:server:StartEMPTimer')
                        TriggerServerEvent('jens-humanelabs:server:StartHumaneTimer')
                        
                        QBCore.Functions.Progressbar("emp_box", "Setting up the Mini EMP..", 8000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {
                            animDict = "anim@gangops@facility@servers@",
                            anim = "hotwire",
                            flags = 16,
                        }, {}, {}, function() -- Function gets called when loadbar finished
                            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)

                            TriggerServerEvent("QBCore:Server:RemoveItem", "miniemp", 1)
                            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["miniemp"], "remove")

                            TriggerEvent('jens-hackinggame:StartHack', 8, 2, OnEMPDone) -- CHANGE THIS FOR AMOUNT OF HACKS
                        end, function() -- Cancel
                            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)       
                            QBCore.Functions.Notify("Canceled..", "error")
                        end)
                    end
                else
                    QBCore.Functions.Notify('Minimum Of '..Config.MinimumPolice..' Police Needed', "error")
                end
            end
        end
    end
end)

-- functions get called when emp is finished
function OnEMPDone(success) 
    if not Config.Lockdown then
        if success then
            TriggerServerEvent('jens-humanelabs:server:SetEMPableBoxStatus', closestEMPableBox, true)
            QBCore.Functions.Notify("Electronic circuit has been temporarily disabled.", "success")
        else
            TriggerServerEvent('jens-humanelabs:server:SetEMPableBoxStatus', closestEMPableBox, false)
            TriggerServerEvent('jens-humanelabs:server:SetLockdown', true)
            QBCore.Functions.Notify("EMP Failed...", "error")
        end
    end
end

-- event gets called from server script to set empableboxstatus to hit
RegisterNetEvent('jens-humanelabs:client:SetEMPableBoxStatus')
AddEventHandler('jens-humanelabs:client:SetEMPableBoxStatus', function(key, isHit)
    Config.EMPableBoxes[key].hit = isHit
end)



--gets called to change door status
RegisterNetEvent('jens-humanelabs:client:SetupDoors')
AddEventHandler('jens-humanelabs:client:SetupDoors', function(doorState)
	Config.DoorsOpened = doorState
end)

--gets called to change emp box status
RegisterNetEvent('jens-humanelabs:client:SetupEMPableBoxes')
AddEventHandler('jens-humanelabs:client:SetupEMPableBoxes', function(EMPableBoxesState)
	Config.EMPableBoxes = EMPableBoxesState
end)

-- Checks if ur close to any of the doors every half a second and opens or closed the door
Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(500)

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for i = 1, 3 do
            local distance = #(pos - Config.Doors[i].objCoords)
            if distance < 25 then
                local object = GetClosestObjectOfType(Config.Doors[i].objCoords.x, Config.Doors[i].objCoords.y, Config.Doors[i].objCoords.z, 5.0, Config.Doors[i].objName, false, false, false)

                if object ~= 0 then
                    FreezeEntityPosition(object, not Config.DoorsOpened)
                    Citizen.Wait(10)
                end
            end
        end
    end
end)

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end


local hasToolkit = false
local usingAdvanced = false
local lastMeter
local lastMeterPos
local lockpicked = {}

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    TriggerServerEvent('jens-parkingmeter:server:UpdateMeterState', lockpicked, true)
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
    
        for i = 1, #Config.Props do
            local object = GetClosestObjectOfType(pos.x, pos.y, pos.z, Config.Props[i].distance, Config.Props[i].name, false, false, false)
            lastMeterPos = GetEntityCoords(object)

            if object ~= 0 then
                local hasBeenPicked = false
                
                for k, v in pairs(lockpicked) do
                    if v == lastMeterPos then
                        hasBeenPicked = true
                        break
                    end
                end
                
                if not hasBeenPicked then
                    TaskTurnPedToFaceEntity(ped, object, -1)

                    TriggerEvent('qb-lockpick:client:openLockpick', lockpickFinish)
                    lastMeter = i

                    if math.random(1, 100) < Config.Props[i].policeChance then
                        TriggerServerEvent('police:server:PoliceAlertMessage', 'Parkingmeter', "A bystander has reported a suspicious activity at a parkingmeter")
                    end 
                end

                break
            end
        end
    end
end)

local takingMoney = false
function lockpickFinish(success)
    if success then
        table.insert(lockpicked, lastMeterPos)
        TriggerServerEvent('jens-parkingmeter:server:UpdateMeterState', lockpicked, false)

        local lockpickTime = 10000
        playAnim(lockpickTime)
        QBCore.Functions.Progressbar("lockpick_parkingmeter", "Stealing the coins..", lockpickTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "veh@break_in@0h@p_m_one@",
            anim = "low_force_entry_ds",
            flags = 16,
        }, {}, {}, function()
            takingMoney = false
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('jens-parkingmeter:server:LockpickFinished', Config.Props[lastMeter].amount)
        end, function() -- Cancel
            takingMoney = false
            ClearPedTasks(PlayerPedId())
            QBCore.Functions.Notify("Canceled..", "error")
        end)   
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

function playAnim(time)
    time = time / 1000
    loadAnimDict("veh@break_in@0h@p_m_one@")
    TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, false, false, false)
    takingMoney = true
    Citizen.CreateThread(function()
        while takingMoney do
            TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Citizen.Wait(2000)
            time = time - 2
            if time <= 0 then
                takingMoney = false
                StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
            end
        end
    end)
end

-- load the animation dict to use animation
function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(100)
    end
end

RegisterNetEvent('jens-parkingmeter:client:UpdateMeterState')
AddEventHandler('jens-parkingmeter:client:UpdateMeterState', function(state)
    lockpicked = state
end)
Citizen.CreateThread(function() 
    while true do
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            if IsControlJustPressed(0, 97) then
                local vehicle = GetVehiclePedIsIn(ped, false)

                SendNUIMessage({
                    Action = "Show"
                })
                SetNuiFocus(true, true)
            end
        end

        Citizen.Wait(1)
    end
end)

RegisterNUICallback('Hide', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('ButtonClicked', function(data)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local index = tonumber(data.Index)
    
    if data.Name == "engine" then
        SetVehicleEngineOn(vehicle, not GetIsVehicleEngineRunning(vehicle), false, true)
    elseif data.Name == "seat" then
        if IsVehicleSeatFree(vehicle, index) then
            SetPedIntoVehicle(ped, vehicle, index)
        else
            QBCore.Functions.Notify("Seat occupied", "error")
        end
    elseif data.Name == "door" then
        if GetVehicleDoorAngleRatio(vehicle, index) > 0.0 then
            SetVehicleDoorShut(vehicle, index, false)
        else
            SetVehicleDoorOpen(vehicle, index, false, false)
        end
    elseif data.Name == "window" then
        if IsVehicleWindowIntact(vehicle, index) then
            RollDownWindow(vehicle, index)
        else
            RollUpWindow(vehicle, index)
        end
    end
end)
local selectedCar = 0

Citizen.CreateThread(function() 
    SetNPC(Config.RentLocation, 11, "mp_m_waremech_01", "missheistdockssetup1ig_2_p1@new_structure", "wait_loop_supervisor")
    SetBlip(Config.RentLocation, 745, "Carrental", 54)
    
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if #(pos - Config.RentLocation) < 1.5 then
            DrawText3D(Config.RentLocation, "~g~E~w~ - Rent car")

            if IsControlJustPressed(0, 38) then
                MenuGarage()
                Menu.hidden = not Menu.hidden
            end

            Menu.renderGUI()
        end

        Citizen.Wait(1)
    end
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

function SetBlip(coords, blipSprite, text, color)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipSprite)
    SetBlipDisplay(blip, 2)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end

function DrawText3D(coords, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function MenuGarage()
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("Vehicles", "VehicleList", nil)
    Menu.addButton("Close Menu", "CloseMenuFull", nil) 
end

function VehicleList(isDown)
    MenuTitle = "Vehicles:"
    ClearMenu()
    for k, v in pairs(Config.Cars) do
        Menu.addButton(Config.Cars[k].name, "SelectCar", k, "Price: "..Config.Cars[k].price)
    end
        
    Menu.addButton("Back", "MenuGarage", nil)
end

function SelectCar(index)
    CloseMenuFull()
    
    if QBCore.Functions.GetPlayerData().money["cash"] >= Config.Cars[index].price then
        QBCore.Functions.Progressbar("rent_car", "Exchanging details...", 2000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mp_common",
            anim = "givetake1_a",
            flags = 16,
        }, {}, {}, function() -- Done
            ClearPedTasks(ped)

            local name = Config.Cars[index].name:lower()

            RequestModel(Config.Cars[index].name)
            while not HasModelLoaded(Config.Cars[index].name) do
                Citizen.Wait(10)
            end

            local vehicle = CreateVehicle(Config.Cars[index].name, Config.SpawnLocation, 340.0, true, false)

            local plate = GetVehicleNumberPlateText(vehicle)

            TriggerEvent("vehiclekeys:client:SetOwner", plate)
            exports['LegacyFuel']:SetFuel(vehicle, 100.0)

            TriggerServerEvent("jens-carrent:server:RentCar", Config.Cars[index].name, Config.Cars[index].price, plate)

            SetModelAsNoLongerNeeded(Config.Cars[index].name)
            SetEntityAsNoLongerNeeded(vehicle)
        end, function() -- Cancel
            ClearPedTasks(ped)
            QBCore.Functions.Notify("Canceled..", "error")
        end)
    else
        QBCore.Functions.Notify("You don\'t have enough cash...", "error")
    end
end

function CloseMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end
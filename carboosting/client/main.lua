local Contracts
local CurrentContract = {
    Player,
    CarName,
    CarClass,
    Mode,
    Location,
    SpawnedOwner = false,
    VehicleNetId,
}
local ActiveContracts = {}

local canDoContract = true
local radius
local policeBlip
local deliveryBlip
local playerJob = {}
local onDuty
local currentCops = 0

local ParamsPerClass = {
    ["D"] = {Weapon = "weapon_knife", HackAmount = 5},
    ["C"] = {Weapon = "weapon_pistol", HackAmount = 6},
    ["B"] = {Weapon = "weapon_heavypistol", HackAmount = 7},
    ["A"] = {Weapon = "weapon_microsmg", HackAmount = 8},
    ["S"] = {Weapon = "weapon_sawnoffshotgun", HackAmount = 10},
}

Citizen.CreateThread(function()
    Citizen.Wait(100)

    TriggerServerEvent("jens-carboosting:server:GetContracts")
    TriggerServerEvent("jens-carboosting:server:GetActiveContracts")
    
    if QBCore.Functions.GetPlayerData() ~= nil then
        playerJob = QBCore.Functions.GetPlayerData().job
        onDuty = true
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    playerJob = JobInfo
    onDuty = true
end)

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
    currentCops = amount
end)

RegisterNetEvent('QBCore:Client:SetDuty')
AddEventHandler('QBCore:Client:SetDuty', function(duty)
    onDuty = duty
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    playerJob = QBCore.Functions.GetPlayerData().job
    onDuty = true
end)

RegisterNetEvent("jens-carboosting:client:UpdateContracts")
AddEventHandler("jens-carboosting:client:UpdateContracts", function(contracts)
    Contracts = contracts
end)

RegisterNetEvent("jens-carboosting:client:UpdateActiveContracts")
AddEventHandler("jens-carboosting:client:UpdateActiveContracts", function(active)
    ActiveContracts = active

    for i = 1, #ActiveContracts do
        if CurrentContract.VehicleNetId == ActiveContracts[i].VehicleNetId then
            if ActiveContracts.SpawnedOwner then
                RemoveBlip(radius)
            end
        end
    end
end)

RegisterNetEvent("dgtablet:UseTablet")
AddEventHandler("dgtablet:UseTablet", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "Show",
        rep = QBCore.Functions.GetPlayerData().metadata["boostrep"],
        contracts = Contracts,
        allowed = not canDoContract,
    })
end)

RegisterNUICallback('Hide', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('StartContract', function(data)
    local enoughCrypto
    QBCore.Functions.TriggerCallback("jens-carboosting:server:Pay", function(callback)
        enoughCrypto = callback
    end, Contracts[data.selectedContract + 1][3])

    Citizen.Wait(100) -- wait for servercallbacks

    if enoughCrypto then
        canDoContract = false

        QBCore.Functions.TriggerCallback("jens-carboosting:server:GetPlayerId", function(callback)
            CurrentContract.Player = callback
        end)
    
        CurrentContract.CarClass = Contracts[data.selectedContract + 1][1]
        CurrentContract.CarName = Contracts[data.selectedContract + 1][4] 
        CurrentContract.Location = Config.Locations[math.random(1, #Config.Locations)]
        
        Citizen.Wait(100) -- wait for servercallbacks

        table.remove(Contracts, data.selectedContract + 1)
        TriggerServerEvent("jens-carboosting:server:UpdateContracts", Contracts)
        SpawnBoostVehicle()
        SetRadius(CurrentContract.Location[1].x + math.random(1, 150), CurrentContract.Location[1].y + math.random(1, 150), CurrentContract.Location[1].z + math.random(1, 150))
    else
        QBCore.Functions.Notify("Not enough crypto...", "error")
    end
end)

function SpawnBoostVehicle() 
    RequestModel(CurrentContract.CarName)
    while not HasModelLoaded(CurrentContract.CarName) do
        Wait(100)
    end 
    
    local vehicle = CreateVehicle(CurrentContract.CarName, CurrentContract.Location[1].x, CurrentContract.Location[1].y, CurrentContract.Location[1].z, CurrentContract.Location[1].w, true, false)
    CurrentContract.Plate = GetVehicleNumberPlateText(vehicle)
    exports['LegacyFuel']:SetFuel(vehicle, 100.0)
    SetModelAsNoLongerNeeded(CurrentContract.CarName)

    CurrentContract.VehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    SetNetworkIdExistsOnAllMachines(CurrentContract.VehicleNetId, true)

    table.insert(ActiveContracts, CurrentContract)
    TriggerServerEvent("jens-carboosting:server:UpdateActiveContracts", ActiveContracts)
end

RegisterNetEvent('lockpicks:UseLockpick')
AddEventHandler('lockpicks:UseLockpick', function()
    for i = 1, #ActiveContracts do
        if ActiveContracts[i].CarName ~= nil and not ActiveContracts[i].SpawnedOwner then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local distance = #(pos - vector3(ActiveContracts[i].Location[1].x, ActiveContracts[i].Location[1].y, ActiveContracts[i].Location[1].z))
            
            if distance < 2.5 then
                SpawnOwnerNPC()
                ActiveContracts[i].SpawnedOwner = true
                TriggerServerEvent("jens-carboosting:server:RemoveRadius", ActiveContracts[i].Player)
                TriggerServerEvent("jens-carboosting:server:AddPoliceBlip", ActiveContracts[i].VehicleNetId, 500)
                TriggerServerEvent("jens-carboosting:server:UpdateActiveContracts", ActiveContracts)
                TriggerServerEvent("police:server:PoliceAlertMessage", "Vehicle Tracker", "Alarm from tracked vehicle went off, check GPS for location.")
            end
        end
    end  
end)

local ownerNPCModels = {"a_m_m_bevhills_01", "a_m_m_bevhills_02", "a_m_m_eastsa_01"}
function SpawnOwnerNPC()
    local model = ownerNPCModels[math.random(1, #ownerNPCModels)]
    local weapon = ParamsPerClass[CurrentContract.CarClass].Weapon
    local modelHash = GetHashKey(model)
  
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(100)
    end

    ped = CreatePed(4, modelHash, CurrentContract.Location[2].x, CurrentContract.Location[2].y, CurrentContract.Location[2].z, CurrentContract.Location[2].w, true, true)
    TaskCombatPed(ped, PlayerPedId(), 0, 16)
    GiveWeaponToPed(ped, weapon, 16, false, true)
end

local currentBlipInterval -- save current interval to stop loop when new interval gets set
RegisterNetEvent("jens-carboosting:client:AddPoliceBlip")
AddEventHandler("jens-carboosting:client:AddPoliceBlip", function(netId, interval)
    currentBlipInterval = interval
    if playerJob.name == "police" and onDuty then
        Citizen.CreateThread(function()
            while currentBlipInterval == interval do
                local vehicle = NetworkGetEntityFromNetworkId(netId)
                local pos = GetEntityCoords(vehicle)
                RemoveBlip(policeBlip)
                SetPoliceBlip(pos)
                Citizen.Wait(interval)
            end
        end)
    end
end)

RegisterNetEvent("jens-carboosting:client:RemoveRadius")
AddEventHandler("jens-carboosting:client:RemoveRadius", function()
    RemoveBlip(radius)
end)

local timesHacked = 0
RegisterNetEvent("trackerdisabler:UseTool")
AddEventHandler("trackerdisabler:UseTool", function(isAdvanced)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)

        if GetPedInVehicleSeat(vehicle, -1) ~= nil and GetIsVehicleEngineRunning(vehicle) then  -- ped ~= GetPedInVehicleSeat(vehicle, -1) and
            for i = 1, #ActiveContracts do
                if NetworkGetNetworkIdFromEntity(vehicle) == ActiveContracts[i].VehicleNetId then
                    TriggerEvent('jens-hackinggame:StartHack', ParamsPerClass[ActiveContracts[i].CarClass].HackAmount, 1, function(success)
                        if success then
                            timesHacked = timesHacked + 1
                            QBCore.Functions.Notify("Disabling tracker... "..timesHacked.."/3", "success")
                            
                            if timesHacked == 3 then
                                timesHacked = 0
                                TriggerServerEvent("jens-carboosting:server:TrackerDisabled", ActiveContracts[i].Player)
                            else
                                TriggerServerEvent("jens-carboosting:server:AddPoliceBlip", ActiveContracts[i].VehicleNetId, timesHacked * 1000)
                            end
                        else
                            QBCore.Functions.Notify("Disabling tracker failed...", "error")
                        end
                    end)
                end
            end
        end
    end
end)

RegisterNetEvent("jens-carboosting:client:RemovePoliceBlip")
AddEventHandler("jens-carboosting:client:RemovePoliceBlip", function()
    RemoveBlip(policeBlip)
    currentBlipInterval = nil
end)


RegisterNetEvent("jens-carboosting:client:TrackerDisabled")
AddEventHandler("jens-carboosting:client:TrackerDisabled", function()
    local DeliveryLocation = Config.DeliveryLocations[math.random(1, #Config.DeliveryLocations)]

    -- remove current contract from actives ones because not needed anymore for other players
    for i = 1, #ActiveContracts do
        if ActiveContracts[i].Player == CurrentContract.Player then
            table.remove(ActiveContracts, i)
            break
        end
    end 
    TriggerServerEvent("jens-carboosting:server:UpdateActiveContracts", ActiveContracts)

    SetDeliveryBlip(DeliveryLocation)
    Citizen.CreateThread(function()
        local delivered = false
        local leftArea = false
        local vehicle = NetworkGetEntityFromNetworkId(CurrentContract.VehicleNetId)
        local ped = PlayerPedId()
        while not leftArea do
            if not delivered then
                DrawMarker(2, DeliveryLocation.x, DeliveryLocation.y, DeliveryLocation.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)

                local vehiclePos = GetEntityCoords(vehicle)
                if #(vehiclePos - DeliveryLocation) < 3 then
                    QBCore.Functions.Notify("Leave the area", "success")
                    RemoveBlip(deliveryBlip)
                    delivered = true
                end
            else
                local pos = GetEntityCoords(ped)
                if #(pos - DeliveryLocation) > 50 then
                    QBCore.Functions.Notify("Payment received", "success")
                    TriggerServerEvent("jens-carboosting:server:ReceivePayment", Config.Payment[CurrentContract.CarClass])
                    DeleteVehicle(vehicle)
                    leftArea = true
                    TriggerServerEvent("jens-carboosting:server:IncreaseRep")

                    Citizen.CreateThread(function() 
                        Citizen.Wait(1000 * 60 * 1) -- 60 * 60 ipv 1 * 1 
                        canDoContract = true 

                        local isOneTimeClass = false
                        for _, carClass in pairs(Config.OneTimeClasses) do
                            if CurrentContract.CarClass == carClass then
                                isOneTimeClass = true
                            end
                        end

                        if not isOneTimeClass then
                            TriggerServerEvent("jens-carboosting:server:GenerateNewContract", CurrentContract.CarClass)
                        end
                    end) 
                end
            end

            Citizen.Wait(0)
        end
    end)
end)

-- buy npcs
Citizen.CreateThread(function() 
    SetNPC(Config.Shops[1][1], 350.0, 's_m_y_dealer_01', "mini@strip_club@idles@bouncer@idle_a", "idle_a")
    SetNPC(Config.Shops[2][1], 90.0, 's_m_y_dealer_01', "missheistdockssetup1ig_2_p1@new_structure", "wait_loop_supervisor")

    local close = {false, false}
    while true do
        for i = 1, #Config.Shops do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)

            if #(pos - Config.Shops[i][1]) < 1 then
                close[i] = true

                if close[i] then
                    DrawText3D(Config.Shops[i][1], "~g~E~w~ - Buy")

                    if IsControlJustPressed(0, 38) then
                        RequestAnimDict("mp_common")
                        while not HasAnimDictLoaded("mp_common") do
                            Wait(1)
                        end

                        TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, 1.0, -1, 16, 0, 0, 0, 0)
                        Citizen.Wait(2000)
                        ClearPedTasks(ped)

                        TriggerServerEvent("jens-carboosting:server:BuyItem", Config.Shops[i][2])
                    end
                else
                    Citizen.Wait(500)
                end
            else
                close[i] = false
            end
        end

        Citizen.Wait(1)
    end
end)

function SetRadius(x, y, z)
    radius = AddBlipForRadius(x, y, z, 300.0)
    SetBlipHighDetail(radius, true)
    SetBlipColour(radius, 5);
    SetBlipAlpha(radius, 150)
end

function SetPoliceBlip(pos) 
    policeBlip = AddBlipForCoord(pos[1], pos[2], pos[3]);
    SetBlipSprite(policeBlip, 225);
    SetBlipDisplay(policeBlip, 2);
    SetBlipScale(policeBlip, 1.0);
    SetBlipColour(policeBlip, 2);
    SetBlipAsShortRange(policeBlip, true);
    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString("Stolen Vehicle Tracker");
    EndTextCommandSetBlipName(policeBlip);
end

function SetDeliveryBlip(pos) 
    deliveryBlip = AddBlipForCoord(pos.x, pos.y, pos.z);
    SetBlipSprite(deliveryBlip, 50);
    SetBlipDisplay(deliveryBlip, 2);
    SetBlipScale(deliveryBlip, 1.0);
    SetBlipColour(deliveryBlip, 20);
    SetBlipAsShortRange(deliveryBlip, true);
    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString("Delivery Location");
    EndTextCommandSetBlipName(deliveryBlip);
end

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

function DrawText3D(pos, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(pos.x, pos.y, pos.z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end



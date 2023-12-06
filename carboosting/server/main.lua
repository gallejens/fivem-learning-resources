local Contracts = {}
local ActiveContracts = {}

Citizen.CreateThread(function()
    Contracts[1] = GenerateContract("D")
    Contracts[2] = GenerateContract("C")
    Contracts[3] = GenerateContract("B")
    Contracts[4] = GenerateContract("A")
    Contracts[5] = GenerateContract("S")
end)

function GenerateContract(carClass)
    local random = math.random(1, #Config.Cars[carClass])
    return {carClass, Config.Cars[carClass][random][1], Config.Price[carClass], Config.Cars[carClass][random][2]}
end

RegisterServerEvent("jens-carboosting:server:GetContracts")
AddEventHandler("jens-carboosting:server:GetContracts", function()
    TriggerClientEvent("jens-carboosting:client:UpdateContracts", source, Contracts)
end)

RegisterServerEvent("jens-carboosting:server:UpdateContracts")
AddEventHandler("jens-carboosting:server:UpdateContracts", function(contracts)
    Contracts = contracts
    TriggerClientEvent("jens-carboosting:client:UpdateContracts", -1, Contracts)
end)

RegisterServerEvent("jens-carboosting:server:GetActiveContracts")
AddEventHandler("jens-carboosting:server:GetActiveContracts", function()
    TriggerClientEvent("jens-carboosting:client:UpdateActiveContracts", source, ActiveContracts)
end)

RegisterServerEvent("jens-carboosting:server:UpdateActiveContracts")
AddEventHandler("jens-carboosting:server:UpdateActiveContracts", function(active)
    ActiveContracts = active
    TriggerClientEvent("jens-carboosting:client:UpdateActiveContracts", -1, ActiveContracts)
end)

QBCore.Functions.CreateUseableItem('dgtablet', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemByName('dgtablet') ~= nil then
        TriggerClientEvent("dgtablet:UseTablet", source)
    end
end)

QBCore.Functions.CreateUseableItem('trackerdisabler', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemByName('trackerdisabler') ~= nil then
        TriggerClientEvent("trackerdisabler:UseTool", source)
    end
end)

QBCore.Functions.CreateCallback("jens-carboosting:server:Pay", function(source, cb, amount)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local enoughCrypto = xPlayer.Functions.RemoveMoney("crypto", amount)
    print(amount)
    cb(enoughCrypto)
end)

QBCore.Functions.CreateCallback("jens-carboosting:server:GetPlayerId", function(source, cb)
    cb(source)
end)

RegisterServerEvent("jens-carboosting:server:AddPoliceBlip")
AddEventHandler("jens-carboosting:server:AddPoliceBlip", function(netId, interval)
    TriggerClientEvent("jens-carboosting:client:AddPoliceBlip", -1, netId, interval)
end)

RegisterServerEvent("jens-carboosting:server:RemoveRadius")
AddEventHandler("jens-carboosting:server:RemoveRadius", function(id)
    TriggerClientEvent("jens-carboosting:client:RemoveRadius", id)
end)

RegisterServerEvent("jens-carboosting:server:TrackerDisabled")
AddEventHandler("jens-carboosting:server:TrackerDisabled", function(player)
    TriggerClientEvent("jens-carboosting:client:RemovePoliceBlip", -1)
    TriggerClientEvent("jens-carboosting:client:TrackerDisabled", player)
end)

RegisterServerEvent("jens-carboosting:server:ReceivePayment")
AddEventHandler("jens-carboosting:server:ReceivePayment", function(amount)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    xPlayer.Functions.AddMoney("crypto", amount)
end)

local classToIndex = {["D"] = 1, ["C"] = 2, ["B"] = 3, ["A"] = 4, ["S"] = 5} --there s prob a better way but its 3am and slowbrain :)
RegisterServerEvent("jens-carboosting:server:GenerateNewContract")
AddEventHandler("jens-carboosting:server:GenerateNewContract", function(carClass)
    local contract = GenerateContract(carClass)
    table.insert(Contracts, classToIndex[carClass], contract)
    TriggerClientEvent("jens-carboosting:client:UpdateContracts", -1, Contracts)
end)

RegisterServerEvent("jens-carboosting:server:BuyItem")
AddEventHandler("jens-carboosting:server:BuyItem", function(item)
    local xPlayer = QBCore.Functions.GetPlayer(source)

    if xPlayer.Functions.RemoveMoney('cash', 5000) then
        xPlayer.Functions.AddItem(item, 1)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
    else
        TriggerClientEvent("QBCore:Notify", source, "Not enough money.", "error")
    end
end)

RegisterServerEvent("jens-carboosting:server:IncreaseRep")
AddEventHandler("jens-carboosting:server:IncreaseRep", function()
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local currentRep = xPlayer.PlayerData.metadata["boostrep"]
    xPlayer.Functions.SetMetaData('boostrep', currentRep + 10)
end)

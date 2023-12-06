RegisterServerEvent("jens-carrent:server:RentCar")
AddEventHandler("jens-carrent:server:RentCar", function(name, price, plate)
    local xPlayer = QBCore.Functions.GetPlayer(source)

    local info = {
        label = "Rentingpapers: "..plate
    }
    
    print(info.label)

    xPlayer.Functions.AddItem("stickynote", 1, false, info)
    TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items["stickynote"], "add")
    xPlayer.Functions.RemoveMoney("cash", price)
end)
local lockpicked = {}

RegisterServerEvent('jens-parkingmeter:server:LockpickFinished')
AddEventHandler('jens-parkingmeter:server:LockpickFinished', function(amount)
    local Player = QBCore.Functions.GetPlayer(source)
    
    Player.Functions.AddMoney('cash', math.random(amount - amount / 2, amount + amount / 2))
end)

RegisterServerEvent('jens-parkingmeter:server:UpdateMeterState')
AddEventHandler('jens-parkingmeter:server:UpdateMeterState', function(param, newPlayer)
    if newPlayer then
        TriggerClientEvent('jens-parkingmeter:client:UpdateMeterState', source, lockpicked)
    else
        lockpicked = param
        TriggerClientEvent('jens-parkingmeter:client:UpdateMeterState', -1, lockpicked)
    end
end)
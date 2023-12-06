local EMPTimer

RegisterServerEvent('jens-humanelabs:server:SetupConfig')
AddEventHandler('jens-humanelabs:server:SetupConfig', function()
    TriggerClientEvent('jens-humanelabs:client:SetupConfig', source, Config)
end)

-- event gets called to set lockdown is failed so all clients get lockdown
RegisterServerEvent('jens-humanelabs:server:SetLockdown')
AddEventHandler('jens-humanelabs:server:SetLockdown', function()
    TriggerClientEvent('jens-humanelabs:client:SetLockdown', -1)

    if not Config.Lockdown then
        Config.Lockdown = true
        TriggerEvent('police:server:PoliceAlertMessage', 'Humane Labs Lockdown', "Suspicious activity has been detected near the Humane Labs Facility")
    end 
end)

RegisterServerEvent('jens-humanelabs:server:SellItems')
AddEventHandler('jens-humanelabs:server:SellItems', function()
    local Player = QBCore.Functions.GetPlayer(source)
    local price = 0

    if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then
        for i = 1, #Player.PlayerData.items do
            if Player.PlayerData.items[i] ~= nil then
                if Config.SellableItems[Player.PlayerData.items[i].name] ~= nil then 
                    price = price + (Config.SellableItems[Player.PlayerData.items[i].name] * Player.PlayerData.items[i].amount)
                    Player.Functions.RemoveItem(Player.PlayerData.items[i].name, Player.PlayerData.items[i].amount)
                    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[Player.PlayerData.items[i].name], "remove")
                end
            end
        end
        Player.Functions.AddMoney("cash", price)
        TriggerClientEvent('QBCore:Notify', source, "You have sold your items")
    end
end)

-- buy EMP
RegisterServerEvent('jens-humanelabs:server:BuyEMP')
AddEventHandler('jens-humanelabs:server:BuyEMP', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.GetItemByName('electronickit') ~= nil then
        if Player.Functions.RemoveMoney('crypto', 1) then
            Player.Functions.RemoveItem('electronickit', 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["electronickit"], "remove")

            Player.Functions.AddItem('miniemp', 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["miniemp"], "add")

            TriggerClientEvent('QBCore:Notify', src, 'Nice doing business with you', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'I don\'t accept trackable money...', 'error')
        end       
    else
        TriggerClientEvent('QBCore:Notify', src, 'You forgot to bring the electronics', 'error')
    end
end)

-- buy keycards
RegisterServerEvent('jens-humanelabs:server:BuyKeycard')
AddEventHandler('jens-humanelabs:server:BuyKeycard', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.GetItemByName('goldbar') ~= nil then
        Player.Functions.RemoveItem('goldbar', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["goldbar"], "remove")

        Player.Functions.AddItem('humanekeycard', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["humanekeycard"], "add")


        TriggerClientEvent('QBCore:Notify', src, 'Don\'t tell anyone, sssht!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'I don\'t accept money....', 'error')
    end
end)

local EMPTimer = 0
local EMPTimerStarted = false
RegisterServerEvent('jens-humanelabs:server:StartEMPTimer')
AddEventHandler('jens-humanelabs:server:StartEMPTimer', function()
    if not EMPTimerStarted then
        Citizen.CreateThread(function()
            EMPTimerStarted = true

            while EMPTimer < Config.EMPTime do
                EMPTimer = EMPTimer + 1
                Citizen.Wait(1000)
    
                if Config.Lockdown or Config.DoorsOpened then
                    break
                end
            end
    
            if not Config.DoorsOpened then
                TriggerEvent('jens-humanelabs:server:SetLockdown')
            end
        end)
    end   
end)

local HumaneTimer = 0
local HumaneTimerStarted = false
RegisterServerEvent('jens-humanelabs:server:StartHumaneTimer')
AddEventHandler('jens-humanelabs:server:StartHumaneTimer', function()
    if not HumaneTimerStarted then
        Citizen.CreateThread(function()
            HumaneTimerStarted = true

            while HumaneTimer < Config.HumaneTime do
                HumaneTimer = HumaneTimer + 1
                Citizen.Wait(1000)
    
                if Config.Lockdown or Config.LootUnlocked then
                    break
                end
            end

            TriggerEvent('jens-humanelabs:server:SetLockdown')
        end)
    end   
end)

-- server sided coords
local empShop = vector3(943.17, -1699.83, 30.08)
local keycardShop = vector3(575.71, -3127.18, 18.77)
local sellLocation = vector3(232.68, -1360.0, 28.65)

QBCore.Functions.CreateCallback('jens-humanelabs:server:GetCoords', function(source, cb)
    Config.EMPShop = empShop
    Config.KeycardShop = keycardShop
    Config.SellLocation = sellLocation
    cb(empShop, keycardShop, sellLocation)
end)



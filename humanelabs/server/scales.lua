-- make humanebutton usable item and link event
QBCore.Functions.CreateUseableItem('scalesbutton', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemByName('scalesbutton') ~= nil then
        TriggerClientEvent("scalesbutton:UseButton", source)
    end
end)

RegisterServerEvent('jens-humanelabs:server:SetLockpicked')
AddEventHandler('jens-humanelabs:server:SetLockpicked', function()
    Config.LockersPicked = true
    TriggerClientEvent('jens-humanelabs:client:SetLockpicked', -1)
end)

local onScale = {
    [1] = false,
    [2] = false,
}

RegisterServerEvent('jens-humanelabs:server:CheckScales')
AddEventHandler('jens-humanelabs:server:CheckScales', function()
    local allPlayers = GetPlayers()
    
    for i = 1, #Config.ScalePositions do
        local playerOnScale = true
        
        for j = 1, #allPlayers do
            local player = GetPlayerPed(allPlayers[j])
            local pos = GetEntityCoords(player)
            
            local distance = #(pos - Config.ScalePositions[i])

            if distance < 1 then
                onScale[i] = true
                break
            end

            if j == #allPlayers then
                playerOnScale = false
            end            
        end

        if not playerOnScale then
            onScale[i] = false
        end
    end

    if onScale[1] and onScale[2] then
        Config.ScalesActivated = true
        TriggerClientEvent('jens-humanelabs:client:SetScalesActivated', -1)
    end
end)
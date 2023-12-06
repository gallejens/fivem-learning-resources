-- event gets called when emp is successful so all clients get same hit status
RegisterServerEvent('jens-humanelabs:server:SetEMPableBoxStatus')
AddEventHandler('jens-humanelabs:server:SetEMPableBoxStatus', function(key, isHit)
    Config.EMPableBoxes[key].hit = isHit
    TriggerClientEvent("jens-humanelabs:client:SetEMPableBoxStatus", -1, key, isHit)

    if AllEMPableBoxesHit() then
        Config.DoorsOpened = true

        TriggerClientEvent('jens-humanelabs:client:SuccessfulEMP', source)
        TriggerClientEvent('jens-humanelabs:client:SetupDoors', -1, Config.DoorsOpened)
    end
end)

-- check if all boxes are hit
function AllEMPableBoxesHit()
    local retval = true
    for k, v in pairs(Config.EMPableBoxes) do
        if not Config.EMPableBoxes[k].hit then
            retval = false
        end
    end
    return retval
end

-- make miniemp usable item and link event
QBCore.Functions.CreateUseableItem('miniemp', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemByName('miniemp') ~= nil then
        TriggerClientEvent("miniemp:UseMiniEMP", source)
    end
end)




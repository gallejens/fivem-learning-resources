RegisterServerEvent('jens-humanelabs:server:SetLocationSearched')
AddEventHandler('jens-humanelabs:server:SetLocationSearched', function(searchId, state)
    Config.SearchLocations[searchId].Searched = state
    TriggerClientEvent('jens-humanelabs:client:SetLocationSearched', -1, searchId, state)
end)

RegisterServerEvent('jens-humanelabs:server:SetPincodeEntered')
AddEventHandler('jens-humanelabs:server:SetPincodeEntered', function()
    Config.PincodeEntered = true
    TriggerClientEvent('jens-humanelabs:client:SetPincodeEntered', -1)
end)

local noteInfo = {
    location, text, code
}

AddEventHandler('onResourceStart', function()
    Citizen.Wait(100)

    noteInfo.location = math.random(1, #Config.SearchLocations)
    local noteId = math.random(1, #Config.NoteText)
    noteInfo.text = Config.NoteText[noteId].Tip
    noteInfo.code = Config.NoteText[noteId].Code
end)

QBCore.Functions.CreateCallback('jens-humanelabs:server:GetNoteInfo', function(source, cb)
    cb(noteInfo)
end)

RegisterServerEvent('jens-humanelabs:server:GiveNote')
AddEventHandler('jens-humanelabs:server:GiveNote', function()
    local Player = QBCore.Functions.GetPlayer(source)
    
    local info = {
        label = noteInfo.text
    }
    
    Player.Functions.AddItem("stickynote", 1, false, info)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["stickynote"], "add")
end)


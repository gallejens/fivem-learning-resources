import { Server } from 'qbcore.js';
import { Config } from 'qbcore.js/common/common';
import DefaultConfig from '../../config.json';

const QBCore : Server = global.exports["qb-core"].GetSharedObject();

QBCore.Functions.CreateCallback("jens-lumberjack:server:GetConfig", (source, cb) => {
    cb(DefaultConfig)
})

onNet("jens-lumberjack:server:SignIn", () => {
    const xPlayer = QBCore.Functions.GetPlayer(source);
    xPlayer.Functions.AddItem("weapon_hatchet", 1);
    emitNet("inventory:client:ItemBox", source, QBCore.Shared.Items["weapon_hatchet"], "add");
})

// check if he has axe
onNet("jens-lumberjack:server:SignOut", () => {
    const xPlayer = QBCore.Functions.GetPlayer(source);
    xPlayer.Functions.RemoveItem("weapon_hatchet", 1);
    emitNet("inventory:client:ItemBox", source, QBCore.Shared.Items["weapon_hatchet"], "remove");
})

onNet("jens-lumberjack:server:CutTree", (treeIndex : number) => {
    DefaultConfig.trees[treeIndex].cut = true;
    const xPlayer = QBCore.Functions.GetPlayer(source);
    xPlayer.Functions.AddItem("treelog", 1);
    emitNet("inventory:client:ItemBox", source, QBCore.Shared.Items["treelog"], "add");

    emitNet("jens-lumberjack:client:SetTree", -1, treeIndex, true);
})

// regrow trees every hour
setImmediate(() => {
    setInterval(function() {
        for (let i = 0; i < DefaultConfig.trees.length; i++) {
            emitNet("jens-lumberjack:client:SetTree", -1, i, false);
        }
    }, 60 * 1000);
})

onNet("jens-lumberjack:server:ProcessLog", () => {
    const xPlayer = QBCore.Functions.GetPlayer(source);
    const hasItem = xPlayer.Functions.RemoveItem("treelog", 1);
    
    if (hasItem) {
        const logsRemaining = xPlayer.Functions.GetItemsByName("treelog").length; // checks how many items array has, 1 mean still has logs 0 means no logs remaining after removal
        
        emitNet("inventory:client:ItemBox", source, QBCore.Shared.Items["treelog"], "remove");
        emitNet("jens-lumberjack:client:ProcessLog", source, logsRemaining == 0);
    } else {
        emitNet('QBCore:Notify', source, "You don't have any logs", "error");
    }
})

onNet("jens-lumberjack:server:PickupPlanks", (amount : number) => {
    let amountOfPlanks = 0;
    for (let i = 0; i < amount; i++) {
        amountOfPlanks += 3 + Math.ceil(Math.random() * 3); // get between 3 and 6 planks
    }
    
    const xPlayer = QBCore.Functions.GetPlayer(source);
    xPlayer.Functions.AddItem("woodenplank", amountOfPlanks);
    emitNet("inventory:client:ItemBox", source, QBCore.Shared.Items["treelog"], "add");
    emitNet('QBCore:Notify', source, "Planks processed, don't forget to check out!", "success");
})

onNet("jens-lumberjack:server:Sell", () => {
    const xPlayer = QBCore.Functions.GetPlayer(source);
    
    let hasItem = true;
    let plankAmount = -1; 

    while (hasItem) {
        plankAmount++;
        hasItem = xPlayer.Functions.RemoveItem("woodenplank", 1);
    }

    if (plankAmount != 0) {
        emitNet("inventory:client:ItemBox", source, QBCore.Shared.Items["woodenplank"], "remove");
        xPlayer.Functions.AddMoney("cash", plankAmount * DefaultConfig.price);
    }   
})





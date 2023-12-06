import { Client } from 'qbcore.js';
import Config from '../../config.json';

const Delay = (ms: number) => new Promise(res => setTimeout(res, ms));
const QBCore: Client = global.exports["qb-core"].GetSharedObject();
let signedIn = false;
let DefaultConfig = Config; // Callback takes time without this first few ticks will get undefined error 
let processBlip;
let plankCount = 0;

setImmediate(() => {
    console.log("Resource started");

    QBCore.Functions.TriggerCallback("jens-lumberjack:server:GetConfig", (cb) => {
        DefaultConfig = cb;
    })

    SetNPC(DefaultConfig.startPos, "s_m_m_lathandy_01", "missheistdockssetup1ig_2_p1@new_structure", "wait_loop_supervisor");
    SetNPC(DefaultConfig.processPos, "s_m_m_lathandy_01", "missheistdockssetup1ig_2_p1@new_structure", "wait_loop_supervisor");
    SetNPC(DefaultConfig.pickupPos, "s_m_m_lathandy_01", "missheistdockssetup1ig_2_p1@new_structure", "wait_loop_supervisor");
    SetNPC(DefaultConfig.sellPos, "s_m_m_lathandy_01", "missheistdockssetup1ig_2_p1@new_structure", "wait_loop_supervisor");
    SetBlip(DefaultConfig.startPos, 480, "Lumberjack - Sign in", 11);
    SetBlip(DefaultConfig.sellPos, 480, "Lumberjack - Sell", 11);
})


setTick(() => {
    Delay(1);
    const ped = PlayerPedId();
    const pos = GetEntityCoords(ped, false);

    // signing in and out at ped
    if (GetDistanceBetweenCoords(pos[0], pos[1], pos[2], DefaultConfig.startPos[0], DefaultConfig.startPos[1], DefaultConfig.startPos[2], true) < 1) {
        if (signedIn) {
            DrawText3D(DefaultConfig.startPos, "~g~E~w~ - Sign out");
            if (IsControlJustPressed(0, 38)) {
                QBCore.Functions.Progressbar("sign_out", "Signing out...", 1000, false, true, {
                    disableMovement: true,
                    disableCarMovement: true,
                    disableMouse: false,
                    disableCombat: true,
                }, {
                    animDict: "mp_common",
                    anim: "givetake1_a",
                    flags: 16,
                }, {}, {}, () => {
                    ClearPedTasks(ped)
                    signedIn = false;
                    QBCore.Functions.Notify("Signed out!", "success");
                    RemoveBlip(processBlip);
                    emitNet("jens-lumberjack:server:SignOut");
                }, () => {
                    ClearPedTasks(ped)
                    QBCore.Functions.Notify("Canceled...", "error")
                })
            }
        } else {
            DrawText3D(DefaultConfig.startPos, "~g~E~w~ - Sign in");
            if (IsControlJustPressed(0, 38)) {
                QBCore.Functions.Progressbar("sign_in", "Signing in...", 1000, false, true, {
                    disableMovement: true,
                    disableCarMovement: true,
                    disableMouse: false,
                    disableCombat: true,
                }, {
                    animDict: "mp_common",
                    anim: "givetake1_a",
                    flags: 16,
                }, {}, {}, () => {
                    ClearPedTasks(ped)
                    signedIn = true;
                    QBCore.Functions.Notify("Signed in!", "success");
                    processBlip = SetBlip(DefaultConfig.processPos, 480, "Lumberjack - Process", 11);
                    emitNet("jens-lumberjack:server:SignIn");
                }, () => {
                    ClearPedTasks(ped)
                    QBCore.Functions.Notify("Canceled...", "error")
                })
            }
        }
    }

    // cutting trees
    if (signedIn && GetSelectedPedWeapon(ped) == GetHashKey("weapon_hatchet")) {
        for (let i = 0; i < DefaultConfig.trees.length; i++) {
            const tree = DefaultConfig.trees[i];

            if (!tree.cut) {
                if (GetDistanceBetweenCoords(pos[0], pos[1], pos[2], tree.pos[0], tree.pos[1], tree.pos[2], true) < 2) {
                    DrawText3D(tree.pos, "~g~E~w~ - Cut tree");
                    if (IsControlJustPressed(0, 38)) {
                        QBCore.Functions.Progressbar("cutting_tree", "Cutting tree...", 1500, false, true, {
                            disableMovement: true,
                            disableCarMovement: true,
                            disableMouse: false,
                            disableCombat: true,
                        }, {
                            animDict: "melee@hatchet@streamed_core",
                            anim: "plyr_front_takedown",
                            flags: 16,
                        }, {}, {}, () => {
                            ClearPedTasks(ped)

                            if (Math.floor(Math.random() * 5) + 1 == 1) {
                                emitNet("jens-lumberjack:server:CutTree", i);
                            }
                        }, () => {
                            ClearPedTasks(ped)
                            QBCore.Functions.Notify("Canceled...", "error")
                        })
                    }
                }
            }
        }
    }

    // process log
    if (signedIn) {
        if (GetDistanceBetweenCoords(pos[0], pos[1], pos[2], DefaultConfig.processPos[0], DefaultConfig.processPos[1], DefaultConfig.processPos[2], true) < 1) {
            DrawText3D(DefaultConfig.processPos, "~g~E~w~ - Process log");
            if (IsControlJustPressed(0, 38)) {
                QBCore.Functions.Progressbar("process_log", "Processing log...", 2000, false, true, {
                    disableMovement: true,
                    disableCarMovement: true,
                    disableMouse: false,
                    disableCombat: true,
                }, {
                    animDict: "mp_common",
                    anim: "givetake1_a",
                    flags: 16,
                }, {}, {}, () => {
                    ClearPedTasks(ped);
                    emitNet("jens-lumberjack:server:ProcessLog");
                }, () => {
                    ClearPedTasks(ped);
                    QBCore.Functions.Notify("Canceled...", "error");
                })
            }
        }
    }

    // planks pickup
    if (plankCount > 0) {
        if (GetDistanceBetweenCoords(pos[0], pos[1], pos[2], DefaultConfig.pickupPos[0], DefaultConfig.pickupPos[1], DefaultConfig.pickupPos[2], true) < 1) {
            DrawText3D(DefaultConfig.pickupPos, "~g~E~w~ - Pickup planks");
            if (IsControlJustPressed(0, 38)) {
                QBCore.Functions.Progressbar("pickup_plank", "Picking up planks...", 10000, false, true, {
                    disableMovement: true,
                    disableCarMovement: true,
                    disableMouse: false,
                    disableCombat: true,
                }, {
                    animDict: "mp_car_bomb",
                    anim: "car_bomb_mechanic",
                    flags: 16,
                }, {}, {}, () => {
                    ClearPedTasks(ped);
                    emitNet("jens-lumberjack:server:PickupPlanks", plankCount);
                    plankCount = 0;
                }, () => {
                    ClearPedTasks(ped);
                    QBCore.Functions.Notify("Canceled...", "error");
                })
            }
        }
    }

    // sell planks
    if (GetDistanceBetweenCoords(pos[0], pos[1], pos[2], DefaultConfig.sellPos[0], DefaultConfig.sellPos[1], DefaultConfig.sellPos[2], true) < 1) {
        DrawText3D(DefaultConfig.sellPos, "~g~E~w~ - Sell planks");
        if (IsControlJustPressed(0, 38)) {
            QBCore.Functions.Progressbar("sell_planks", "Selling...", 10000, false, true, {
                disableMovement: true,
                disableCarMovement: true,
                disableMouse: false,
                disableCombat: true,
            }, {
                animDict: "mp_car_bomb",
                anim: "car_bomb_mechanic",
                flags: 16,
            }, {}, {}, () => {
                ClearPedTasks(ped);
                emitNet("jens-lumberjack:server:Sell");
                QBCore.Functions.Notify("Planks sold!", "success");
            }, () => {
                ClearPedTasks(ped);
                QBCore.Functions.Notify("Canceled...", "error");
            })
        }
    }
})

onNet("jens-lumberjack:client:SetTree", (treeIndex: number, cut: boolean) => {
    DefaultConfig.trees[treeIndex].cut = cut;
})

function DrawText3D(pos: Array<number>, text: string) {
    SetTextScale(0.35, 0.35);
    SetTextFont(4);
    SetTextProportional(true);
    SetTextColour(255, 255, 255, 215);
    SetTextEntry("STRING");
    SetTextCentre(true);
    AddTextComponentString(text);
    SetDrawOrigin(pos[0], pos[1], pos[2], 0);
    DrawText(0.0, 0.0);
    const factor = (text.length) / 370;
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75);
    ClearDrawOrigin();
}

async function SetNPC(pos: Array<number>, model: string, animDict: string, anim: string) {
    const modelHash = GetHashKey(model);

    RequestModel(modelHash)
    while (!HasModelLoaded(modelHash)) {
        await Delay(1);
    }

    RequestAnimDict(animDict)
    while (!HasAnimDictLoaded(animDict)) {
        await Delay(1);
    }

    const ped = CreatePed(4, modelHash, pos[0], pos[1], pos[2] - 1, pos[3], false, true);
    FreezeEntityPosition(ped, true);
    SetEntityInvincible(ped, true);
    SetBlockingOfNonTemporaryEvents(ped, true);
    TaskPlayAnim(ped, animDict, anim, 8.0, 0.0, -1, 1, 0, false, false, false);
}

function SetBlip(pos: Array<number>, blipSprite: number, text: string, color: number) : number {
    const blip = AddBlipForCoord(pos[0], pos[1], pos[2]);
    SetBlipSprite(blip, blipSprite);
    SetBlipDisplay(blip, 2);
    SetBlipScale(blip, 1.0);
    SetBlipColour(blip, color);
    SetBlipAsShortRange(blip, true);
    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString(text);
    EndTextCommandSetBlipName(blip);
    return blip;
}

onNet("jens-lumberjack:client:ProcessLog", (last : boolean) => {
    plankCount++;
    if (last) {
        QBCore.Functions.Notify("Pickup planks at the end of the conveyor belt.", "primary");
    }
})


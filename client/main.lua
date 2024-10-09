function DebugPrinter(message)
    if Config.Debug.debugPrinter then
        print("^1[DEBUGGER "..GetCurrentResourceName().."] ^5"..message)
    end
end

RegisterCommand('check_server', function ()
    TriggerServerEvent('nw-containermission:server:payoutClient')
end, false)

CreateThread(function()
    DebugPrinter("Debugger started, if you find any issues please let us know. Discord: https://discord.gg/bkr7RUJWQz")
    DebugPrinter("Creating NPC for the mission")
    for key, tableInformation in ipairs(Config.MissionNPC) do
        RequestModel(GetHashKey(tableInformation.model))
        while not HasModelLoaded(GetHashKey(tableInformation.model)) do
            Wait(1)
        end
        
        DebugPrinter("Npc information: index: "..key..". The npc location: "..tableInformation.location..". The npc model: "..tableInformation.model)
        
        npc = CreatePed(2, tableInformation.model, tableInformation.location.x, tableInformation.location.y, (tableInformation.location.z - 1.0), tableInformation.location.w,  false, true)
        
        SetPedFleeAttributes(npc, 0, 0)
        SetPedDropsWeaponsWhenDead(npc, false)
        SetPedDiesWhenInjured(npc, false)
        SetEntityInvincible(npc , true)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        TaskStartScenarioInPlace(npc, 'WORLD_HUMAN_DRUG_DEALER', 0, true)
        DebugPrinter("Npc created.")
        
        DebugPrinter("Creating box zone for the npc.")
        
        npcBoxZone = exports.ox_target:addBoxZone({
            coords = vec3(tableInformation.location.x, tableInformation.location.y, tableInformation.location.z),
            size = vec3(1, 1, 1),
            rotation = 360,
            debug = Config.Debug.ox_targetDebugger,
            options = {
                {
                    onSelect = function()
                        if Config.PoliceInformation.policeRequired then
                            TriggerServerEvent("nw-containermission:server:checkForPolice")
                        else
                            TriggerServerEvent('nw-containermission:server:MissionOccupied')
                        end
                    end,
                    distance = Config.TargetDistances.npcTargetDistance,
                    icon = 'fa fa-table-cells-row-lock',
                    label = Config.Translations['start_container_mission'],
                },
            }
        })
        DebugPrinter("Box zone created for the npc.")
    end
    DebugPrinter("Npc and box zone creation works fine.")
end)

function loadModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do Citizen.Wait(0) end
end

RegisterNetEvent('nw-containermission:client:StartContainerMission')
AddEventHandler('nw-containermission:client:StartContainerMission', function()
    DebugPrinter("Starting mission now.")
    local randomContainer = math.random(1, #Config.ContainerCoords)
    ContainerInfo = Config.ContainerCoords[randomContainer]
    if ContainerInfo.grabMoneyTimer > 47933 or ContainerInfo.grabMoneyTimer <= 0 then
        print("^1["..GetCurrentResourceName().."] ^4The money grabscene timer is: "..ContainerInfo.grabMoneyTimer.." miliseconds, this is not possible! ^3Contact server staff!")
        lib.notify({
            description = Config.Translations['error_message'],
            duration = Config.Notifies["NotifyTimer"], 
            position = Config.Notifies["NotifyPosition"], 
            type = 'info'
        })
        return
    end
    TaskStartScenarioInPlace(npc, 'WORLD_HUMAN_STAND_MOBILE', 0, true)
    lib.progressBar({
        duration = Config.Notifies["ProgressBarTimer"], 
        position = 'bottom', 
        label = Config.Translations['consulting'], 
        canCancel = false, 
        anim = {
            dict = "misscarsteal4@actor", 
            lockX = true, 
            lockY = true, 
            lockZ = true, 
            clip = "actor_berating_loop"
        }
    })

    ClearPedTasks(npc)

    loadModel('tr_prop_tr_container_01a')
    DebugPrinter("Picked a random index for the container: "..randomContainer.." (This is the point where the random container is picked from the table)")

    CreateBlip(ContainerInfo)

    lib.notify({
        title = Config.Notifies["NotifyTitleNPC"],
        description = Config.Translations['marked_gps'],
        duration = Config.Notifies["NotifyTimer"], 
        position = Config.Notifies["NotifyPosition"], 
        type = 'info'
    })

    while true do
        Wait(1500)
        local distance_to_create_container = 300
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(ContainerInfo.containerLocation - playerCoords)
        DebugPrinter("Player's current distance to the container: "..distance.." he is not in range yet. The range is: "..distance_to_create_container)
        if distance < distance_to_create_container then
            Wait(1000)
            DebugPrinter("Player is in range of the container coords, distance is smaller then 100 so we place the container now.")
            Container = CreateObject(GetHashKey('tr_prop_tr_container_01a'), ContainerInfo.containerLocation.x, ContainerInfo.containerLocation.y, (ContainerInfo.containerLocation.z - 1), true, false, false)
            SetEntityHeading(Container, ContainerInfo.containerHeading)
            FreezeEntityPosition(Container, true)
            
            DebugPrinter("Placing the container on the coords of: "..ContainerInfo.containerLocation.." with a heading: "..ContainerInfo.containerHeading)
            
            boxZoneCoords = GetOffsetFromEntityInWorldCoords(Container, 0.0, -1.85, 1.2)
        break
        end
    end

    containerZone = exports.ox_target:addBoxZone({
        coords = vec3(boxZoneCoords),
        size = vec3(1, 1, 1),
        rotation = 360,
        debug = Config.Debug.ox_targetDebugger,
        options = {
            {
                onSelect = function (data)
                    TriggerEvent('nw-containermission:client:OpenContainerScene', ContainerInfo)
                end,
                distance = Config.TargetDistances.containerTargetDistance,
                icon = 'fa fa-door-open',
                label = Config.Translations['open_container'],
            },
        }
    })
end)

RegisterNetEvent('nw-containermission:client:OpenContainerScene')
AddEventHandler('nw-containermission:client:OpenContainerScene', function (data)
    DebugPrinter("Player opening container scene starting now.")
    exports.ox_target:removeZone(containerZone)
    exports.ox_target:disableTargeting(true)
    local player = PlayerPedId()

    DeleteEntity(Container)
    
    container = CreateObject(GetHashKey('tr_prop_tr_container_01a'), data.containerLocation.x, data.containerLocation.y, data.containerLocation.z, true, false, false)
    PlaceObjectOnGroundProperly(container)
    SetEntityHeading(container, data.containerHeading)
    FreezeEntityPosition(container, true)
    DebugPrinter("Container has been spawned on the following coords: "..data.containerLocation..data.containerLocation.y..data.containerLocation.z.." and has the following heading: "..data.containerHeading)

    local rotation = vector3(0.0, 0.0, data.containerHeading)
    local animDict = "anim@scripted@player@mission@tunf_train_ig1_container_p1@male@"
    
    loadModel('tr_prop_tr_container_01a')
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Citizen.Wait(10) end
    
    animPosContainer = GetOffsetFromEntityInWorldCoords(container, 0.0, 0.0, 0.0)

    local scene = NetworkCreateSynchronisedScene(animPosContainer.x, animPosContainer.y, animPosContainer.z, rotation.x, rotation.y, rotation.z, 2, false, false, 1065353216, 0, 1065353216)
    
    NetworkAddPedToSynchronisedScene(player, scene, animDict, "action", 1.5, -4.0, 2, 16, 1148846080, 0)    
    
    loadModel('hei_prop_hei_cash_trolly_01')
    loadModel('prop_ld_container')
    loadModel('tr_prop_tr_grinder_01a')
    loadModel('ch_p_m_bag_var04_arm_s')
    loadModel('tr_prop_tr_lock_01a')
    
    local angleGrinder = CreateObject(`tr_prop_tr_grinder_01a`, 10.0, 0.0, 0.0, true, false, false)
    local bag = CreateObject(`ch_p_m_bag_var04_arm_s`, 10.0, 0.0, 0.0, true, false, false)
    local containerLock = CreateObject(`tr_prop_tr_lock_01a`, 10.0, 0.0, 0.0, true, false, false)
    
    SetEntityCollision(bag, false, true)
    
    NetworkAddEntityToSynchronisedScene(angleGrinder, scene, animDict, "action_angle_grinder", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(bag, scene, animDict, "action_bag", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(containerLock, scene, animDict, "action_lock", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(container, scene, animDict, "action_container", 1.0, 1.0, 1)
    
    NetworkStartSynchronisedScene(scene)
    
    trolleyCoords = GetOffsetFromEntityInWorldCoords(container, 0.0, 0.0, 0.68)

    trolleyProp = CreateObjectNoOffset(`hei_prop_hei_cash_trolly_01`, trolleyCoords.x, trolleyCoords.y, trolleyCoords.z, true, true, true)
    SetEntityHeading(trolleyProp, (data.containerHeading - 180))
    
    RequestScriptAudioBank("dlc_tuner/dlc_tuner_generic", false, -1)
    
    NetworkStartSynchronisedScene(scene)

    Citizen.Wait(11000)

    NetworkStopSynchronisedScene(scene)
    
    ReleaseNamedScriptAudioBank("dlc_tuner/dlc_tuner_generic")
    
    DeleteEntity(containerLock)
    DeleteEntity(angleGrinder)
    DeleteEntity(bag)

    trolleyBoxZone = exports.ox_target:addBoxZone({
        coords = vec3(trolleyCoords.x, trolleyCoords.y, trolleyCoords.z),
        size = vec3(1, 1, 1),
        rotation = 360,
        debug = Config.Debug.ox_targetDebugger,
        options = {
            {
                onSelect = function ()
                    TriggerEvent('nw-containermission:client:GrabMoneyFromColley', data, trolleyCoords)
                end,
                distance = Config.TargetDistances.trolleyTargetDistance,
                icon = 'fa fa-money-bill',
                label = Config.Translations['grab_money'],
            },
        }
    })
    
    SetEntityCollision(container, false, true)

    PlayEntityAnim(container, "action_container", animDict, 0, false, true, true, 1000, false)
    
    local player_coords = GetEntityCoords(PlayerPedId())

    lib.notify({
        title = Config.Notifies["NotifyTitleNPC"],
        description = Config.Translations['hurry_for_police'],
        duration = Config.Notifies["NotifyTimer"], 
        position = Config.Notifies["NotifyPosition"], 
        type = 'info'
    })

    dupeContainer = CreateObject(`prop_ld_container`, data.containerLocation.x, data.containerLocation.y, (player_coords.z - 1), true, false, false)
    SetEntityHeading(dupeContainer, data.containerHeading)
    FreezeEntityPosition(dupeContainer, true)
    SetEntityVisible(dupeContainer, false, 0)

    exports.ox_target:disableTargeting(false)
end)

RegisterNetEvent('nw-containermission:client:playContainerAnimation')
AddEventHandler('nw-containermission:client:playContainerAnimation', function(data)
    DebugPrinter("Creating police blip.")
    PoliceBlip = AddBlipForCoord(data.containerLocation)
    SetBlipSprite(PoliceBlip, Config.PoliceInformation['PoliceBlip'].Sprite)
    SetBlipScale(PoliceBlip, Config.PoliceInformation['PoliceBlip'].Scale)
    SetBlipColour(PoliceBlip, Config.PoliceInformation['PoliceBlip'].Colour)
    SetBlipRoute(PoliceBlip, Config.PoliceInformation['PoliceBlip'].Route)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.PoliceInformation['PoliceBlip'].Translation)
    EndTextCommandSetBlipName(PoliceBlip)
    TriggerEvent('nw-containermission:client:RemovePoliceBlip')
    DebugPrinter("Police blip created.")
end)

function CreateCameraAndRender(posx, posy, posz, heading, fov)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", posx, posy, posz, 0.0 ,0.0, heading, fov, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, true)
end

function StopCameraRender()
    RenderScriptCams(false, true, 1000, true, true)
    SetCamActive(cam, false)
end

RegisterNetEvent('nw-containermission:client:GrabMoneyFromColley')
AddEventHandler('nw-containermission:client:GrabMoneyFromColley', function(data, trolleyCoords)
    if Config.PoliceInformation.policeRequired then
        TriggerServerEvent("nw-containermission:server:SendPoliceAlert", data)
    end

    trolleyRotation = vec3(0.0, 0.0, (data.containerHeading - 180))
    local animDict = "anim@heists@ornate_bank@grab_cash"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Citizen.Wait(10) end

    loadModel('hei_p_m_bag_var22_arm_s')
    loadModel('hei_prop_hei_cash_trolly_03')
    
    local playerPed = PlayerPedId()

    local cashBag = CreateObjectNoOffset(`hei_p_m_bag_var22_arm_s`, trolleyCoords.x, trolleyCoords.y, trolleyCoords.z, true, true, true)

    local animPos = GetOffsetFromEntityInWorldCoords(trolleyProp, 0.0, 0.0, 0.0)
    
    local introScene = NetworkCreateSynchronisedScene(animPos.x, animPos.y, animPos.z, trolleyRotation.x, trolleyRotation.y, trolleyRotation.z, 2, true, false, 1065353216, 0, 1065353216)
    
    NetworkAddPedToSynchronisedScene(playerPed, introScene, animDict, "intro", 1.5, -4.0, 2, 16, 1148846080, 0)    
    NetworkAddEntityToSynchronisedScene(cashBag, introScene, animDict, "bag_intro", 1.0, 1.0, 1)

    local camPosition = GetOffsetFromEntityInWorldCoords(trolleyProp, 0.02, -1.4, 1.3)
    CreateCameraAndRender(camPosition.x, camPosition.y, camPosition.z, (data.containerHeading - 180), 90.0)
    
    NetworkStartSynchronisedScene(introScene)
    exports.ox_target:removeZone(trolleyBoxZone)
    
    Citizen.Wait(2050)
    
    NetworkStopSynchronisedScene(introScene)
    SetSynchronizedSceneHoldLastFrame(introScene, true)

    local grabScene = NetworkCreateSynchronisedScene(animPos.x, animPos.y, animPos.z, trolleyRotation.x, trolleyRotation.y, trolleyRotation.z, 2, true, false, 1065353216, 0, 1065353216)

    NetworkAddPedToSynchronisedScene(playerPed, grabScene, animDict, "grab", 1.5, -4.0, 2, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(cashBag, grabScene, animDict, "bag_grab", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(trolleyProp, grabScene, animDict, "cart_cash_dissapear", 1.0, 1.0, 1)

    NetworkStartSynchronisedScene(grabScene)
    local timer = data.grabMoneyTimer
    
    Citizen.Wait(timer)
    
    NetworkStopSynchronisedScene(grabScene)
    DeleteEntity(trolleyProp)

    local emptyTrolley = CreateObjectNoOffset(`hei_prop_hei_cash_trolly_03`, trolleyCoords.x, trolleyCoords.y, trolleyCoords.z, true, true, true)
    PlaceObjectOnGroundProperly(emptyTrolley)
    SetEntityHeading(emptyTrolley, (data.containerHeading - 180))

    local outroScene = NetworkCreateSynchronisedScene(animPos.x, animPos.y, animPos.z, trolleyRotation.x, trolleyRotation.y, trolleyRotation.z, 2, true, false, 1065353216, 0, 1065353216)
    
    NetworkAddPedToSynchronisedScene(playerPed, outroScene, animDict, "exit", 1.5, -4.0, 2, 16, 1148846080, 0)    
    NetworkAddEntityToSynchronisedScene(cashBag, outroScene, animDict, "bag_exit", 1.0, 1.0, 1)
    
    NetworkStartSynchronisedScene(outroScene)
    
    Citizen.Wait(3500)

    StopCameraRender()
    
    NetworkStopSynchronisedScene(outroScene)

    TriggerServerEvent('nw-containermission:server:StartTimer')

    DeleteEntity(trolleyProp)
    DeleteEntity(cashBag)
    
    local blipInfo = Config.ContainerBlipInformation
    if blipInfo['Blip'].enabled then
        RemoveBlip(containerBlip)
    else
        RemoveBlip(containerRadiusBlip)
    end

    DebugPrinter("Mission done, player should received his reward + the timer should be running right now.")
    TriggerServerEvent("nw-containermission:server:payoutClient", trolleyCoords)

    Citizen.Wait(Config.TimerToRestoreMissionAndDeleteContainer * 1000)
    TriggerServerEvent('nw-containermission:server:MissionCompleted')
    DeleteEntity(emptyTrolley)
    DeleteEntity(container)
    DeleteEntity(dupeContainer)
end)

RegisterNetEvent('nw-containermission:client:SendPoliceBlip')
AddEventHandler('nw-containermission:client:SendPoliceBlip', function(data)
    DebugPrinter("Creating police blip.")
    PoliceBlip = AddBlipForCoord(data.containerLocation)
    SetBlipSprite(PoliceBlip, Config.PoliceInformation['PoliceBlip'].Sprite)
    SetBlipScale(PoliceBlip, Config.PoliceInformation['PoliceBlip'].Scale)
    SetBlipColour(PoliceBlip, Config.PoliceInformation['PoliceBlip'].Colour)
    SetBlipRoute(PoliceBlip, Config.PoliceInformation['PoliceBlip'].Route)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.PoliceInformation['PoliceBlip'].Translation)
    EndTextCommandSetBlipName(PoliceBlip)
    TriggerEvent('nw-containermission:client:RemovePoliceBlip')
    DebugPrinter("Police blip created.")
end)

RegisterNetEvent('nw-containermission:client:RemovePoliceBlip')
AddEventHandler('nw-containermission:client:RemovePoliceBlip', function()
    Citizen.Wait(Config.PoliceInformation['PoliceBlip'].timerToRemovePoliceBlip * 1000)
    RemoveBlip(PoliceBlip)
    DebugPrinter("Removed police blip.")
end)

function CreateBlip(data)
    local blipInfo = Config.ContainerBlipInformation
    if blipInfo['Blip'].enabled then
        containerBlip = AddBlipForCoord(data.containerLocation.x, data.containerLocation.y, data.containerLocation.z)
        SetBlipSprite(containerBlip, blipInfo['Blip'].Sprite)
        SetBlipScale(containerBlip, blipInfo['Blip'].Scale)
        SetBlipColour(containerBlip, blipInfo['Blip'].Colour)
        SetBlipRoute(containerBlip, blipInfo['Blip'].BlipRoute)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(blipInfo['Blip'].ContainerBlipName)
        EndTextCommandSetBlipName(containerBlip)
    else
        containerRadiusBlip = AddBlipForRadius(data.containerLocation.x, data.containerLocation.y, data.containerLocation.z, blipInfo['BlipRadius'].Radius)
        SetBlipColour(containerRadiusBlip, blipInfo['BlipRadius'].Colour)
        SetBlipAlpha(containerRadiusBlip, blipInfo['BlipRadius'].Alpha)
    end
end

TriggerServerEvent('nw-containermission:server:CheckVersion')

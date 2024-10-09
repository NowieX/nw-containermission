function DebugPrinter(message)
    if Config.Debug.debugPrinter then
        print("^1[DEBUGGER "..GetCurrentResourceName().."] ^5"..message)
    end
end

local scriptVersion = "1.0.0"
local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')

RegisterServerEvent('nw-containermission:server:CheckVersion')
AddEventHandler('nw-containermission:server:CheckVersion', function()
    if currentVersion == scriptVersion then
        print("^2["..GetCurrentResourceName().."] ^4Running version "..currentVersion.." which is the latest version!")
    else
        print("^2["..GetCurrentResourceName().."] ^1Running version "..currentVersion.." which is outdated! Please update to the new version.")
    end
end)

RegisterServerEvent('nw-containermission:server:CheckVersion')
AddEventHandler('nw-containermission:server:CheckVersion', function()
    if currentVersion == scriptVersion then
        print("^2["..GetCurrentResourceName().."] ^4Running version "..currentVersion.." which is the latest version!")
    else
        print("^2["..GetCurrentResourceName().."] ^1Running version "..currentVersion.." which is outdated! Please update to the new version.")
    end
end)

RegisterServerEvent('nw-containermission:server:payoutClient')
AddEventHandler('nw-containermission:server:payoutClient', function(coords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local playerCoords = xPlayer.getCoords(true)

    if not coords then
        xPlayer.kick("Caught by nw 📸")
        SendDiscordMessage(Config.Webhooks.hacker.message, Config.Webhooks.hacker.webhookUrl)
        return
    end

    local distance = #(playerCoords - coords)

    if distance > (Config.TargetDistances.trolleyTargetDistance + 2.0) then
        xPlayer.kick("Caught by nw 📸")
        sendDiscordMessage(Config.Webhooks.hacker.message, Config.Webhooks.hacker.webhookUrl)
        return
    end

    local playerRewardAccount = Config.PayoutSystem.payout
    local playerReward = Config.PayoutSystem.amount
    
    xPlayer.addAccountMoney(playerRewardAccount, playerReward)
    DebugPrinter("Player received his payout on account: "..playerRewardAccount.." and got: "..playerReward)
end)

local isMissionOccupied = false
local timerActive = false
local timerDuration = Config.TimerToRestoreMissionAndDeleteContainer

function StartTimer()
    DebugPrinter("Starting timer now to restore the mission, this takes "..timerDuration.." seconds.")
    timerActive = true
    Citizen.CreateThread(function()
        while timerDuration > 0 do
            Citizen.Wait(1000) -- Wacht 1 seconde
            timerDuration = timerDuration - 1
        end
        timerActive = false
    end)
    DebugPrinter("Timer is done and mission is available again.")
end

RegisterNetEvent('esx:playerDropped', function(playerId, reason)
    DebugPrinter("Player left the server and the mission is available again.")
    isMissionOccupied = false
end)

RegisterServerEvent('nw-containermission:server:MissionCompleted')
AddEventHandler('nw-containermission:server:MissionCompleted', function()
    DebugPrinter("Player completed the mission, starting timer now.")
    isMissionOccupied = false
    StartTimer()
end)

RegisterServerEvent('nw-containermission:server:MissionOccupied')
AddEventHandler('nw-containermission:server:MissionOccupied', function()
    if isMissionOccupied then
        TriggerClientEvent('ox_lib:notify', source, {title = Config.Notifies.NotifyTitleNPC, description = Config.Translations['mission_occupied'], duration = Config.Notifies["NotifyTimer"], position = Config.Notifies["NotifyPosition"], type = 'warning'})
        return
    end
    
    if timerActive then
        TriggerClientEvent('ox_lib:notify', source, {title = Config.Notifies.NotifyTitleNPC, description = Config.Translations['no_mission_right_now'], duration = Config.Notifies["NotifyTimer"], position = Config.Notifies["NotifyPosition"], type = 'info'})
        DebugPrinter("Checking if timer is active: "..timerActive)
    else
        TriggerClientEvent('nw-containermission:client:StartContainerMission', source)
        isMissionOccupied = true
        DebugPrinter("Sending client event to start the mission.")
    end
end)

RegisterServerEvent("nw-containermission:server:checkForPolice")
AddEventHandler("nw-containermission:server:checkForPolice", function(data)
    local PolicePlayers = ESX.GetExtendedPlayers('job', 'police')

    if #PolicePlayers >= Config.PoliceInformation.policeNumberRequired then
        TriggerClientEvent('nw-containermission:client:StartContainerMission', source, data)
        DebugPrinter("Player starting container mission now, there is enough police online.")
    else
        TriggerClientEvent('ox_lib:notify', source, {description = Config.Translations['not_enough_police'], duration = Config.Notifies["NotifyTimer"], position = Config.Notifies["NotifyPosition"], type = 'error'})
        DebugPrinter("Not enough police players online.")
    end
end)

RegisterServerEvent("nw-containermission:server:SendPoliceAlert")
AddEventHandler("nw-containermission:server:SendPoliceAlert", function(data)
    local PolicePlayers = ESX.GetExtendedPlayers('job', 'police')

    for i=1, #(PolicePlayers) do
        local policePlayer = PolicePlayers[i]
        TriggerClientEvent('ox_lib:notify', source, {title = Config.Translations['police_message'].title, description = Config.Translations['police_message'].message, duration = Config.Notifies["NotifyTimer"], position = Config.Notifies["NotifyPosition"], type = 'warning'})
        TriggerClientEvent('nw-containermission:client:SendPoliceBlip', policePlayer.source, data)
        DebugPrinter("Made a message for the police and created a police blip.")
    end
end)

function SendDiscordMessage(message, webhookUrl)
    local identifiers = GetPlayerIdentifiers(source)
    local steamName = GetPlayerName(source)
    local steamid = identifiers[1]
    local discordID = identifiers[2]
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local message = message
    local embedData = {{
        ['title'] = "nw-containermission",
        ['color'] = 0,
        ['footer'] = {
            ['icon_url'] = "https://media.discordapp.net/attachments/1135317834851958835/1135317941504712735/Ontwerp_zonder_titel_1.png"
        },
        ['description'] = message,
        ['fields'] = {
            {
                name = "",
                value = "",
            },

            {
                name = "ID",
                value = "SpelerID: "..xPlayer.source,
            },

            {
                name = "",
                value = "",
            },


            {
                name = "Steam Identifier",
                value = "Steam"..steamid,
                inline = true
            },

            {
                name = "",
                value = "",
            },

            {
                name = "Steam Name",
                value = "Steam name: "..steamName,
            },

            {
                name = "",
                value = "",
            },

            {
                name = "Discord Identifier",
                value = discordID,
            },
        },
    }}
    
    local webhookUrl = webhookUrl

    PerformHttpRequest(webhookUrl, nil, 'POST', json.encode({
        username = 'nw-containermission logs',
        embeds = embedData
    }), {
        ['Content-Type'] = 'application/json'
    })
end

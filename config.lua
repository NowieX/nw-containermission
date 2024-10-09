Config = {}

Config.Webhooks = {
    payout = {
        webhookUrl = "",
        message = "**Player with the following information has got his money from nw-containermission.**",
    },
    hacker = {
        webhookUrl = "",
        message = "**Player with the following information tried to cash out without the container being spawned. He may be a hacker.**"
    },
}

Config.PayoutSystem = {
    payout = 'black_money', -- black_money, bank or cash
    amount = math.random(10000, 30000),
}

Config.MissionNPC = {
    {
        location = vec4(2489.2302, 4959.0166, 44.7961, 43.7669),
        model = 's_m_y_dealer_01',
    },
}

Config.PoliceInformation = {
    policeRequired = true, -- Set to false if police is not necessary for the mission, this also means the police won't get notified
    policeNumberRequired = 1,
    ['PoliceBlip'] = {
        Sprite = 161,
        Colour = 59,
        Scale = 1.0,
        Route = true,
        Translation = "Suspicious activity",
        timerToRemovePoliceBlip = 120, -- Timer in seconds, after the seconds the blip gets removed
    }
}

Config.Notifies = {
    ["NotifyTitleNPC"] = 'Dealer',
    ["NotifyPosition"] = 'center-right',
    ["NotifyTimer"] = 7500,
    ["ProgressBarTimer"] = 10000,
}

Config.Debug = {
    debugPrinter = false,
    ox_targetDebugger = false
}

Config.TargetDistances = {
    npcTargetDistance = 2.0,
    containerTargetDistance = 2.0,
    trolleyTargetDistance = 1.5,
}

Config.TimerToRestoreMissionAndDeleteContainer = 60

Config.ContainerBlipInformation = {
    ['Blip'] = {
        enabled = false, -- Create a blip for the container? Disadvantage is that people immediately know where the container is.
        Sprite = 677,
        Scale = 1.0,
        Colour = 59,
        BlipRoute = true,
        ContainerBlipName = "Container",
    },
    ['BlipRadius'] = {
        Alpha = 125,
        Radius = 100.0,
        Colour = 59,
        ContainerBlipName = "Container zoekgebied",
    }
}

Config.ContainerCoords = {
    -- grabMoneyTimer can't be higher then 47933 miliseconds or lower/equal to 0 miliseconds!
    -- I recommend you to let the timers be between 30000 and 47933 miliseconds
    {
        containerLocation = vec3(-1564.3474, 4489.4023, 21.1035),
        containerHeading = 99.2312,
        grabMoneyTimer = 47933,
    },
    {
        containerLocation = vec3(-1402.6700, 5220.0908, 3.5803),
        containerHeading = 136.2626,
        grabMoneyTimer = 47933,
    },
    {
        containerLocation = vec3(53.3329, 7086.0493, 2.6801),
        containerHeading = 19.4381,
        grabMoneyTimer = 47933,
    },
    {
        containerLocation = vec3(503.6274, -3318.5576, 6.0698),
        containerHeading = 181.7982,
        grabMoneyTimer = 47933,
    },
    {
        containerLocation = vec3(1053.8604, -3278.3052, 5.8978),
        containerHeading = 90.3660,
        grabMoneyTimer = 47933,
    },
    {
        containerLocation = vec3(1379.3986, -2718.8079, 2.9240),
        containerHeading = 1.5871,
        grabMoneyTimer = 47933,
    },
}

Config.Translations = {
    -- Ox-target
    ['start_container_mission'] = "Start containermission",
    ['open_container'] = "Open container",
    ['grab_money'] = "Grab money",

    -- NPC interactions
    ['consulting'] = "Consulting...",
    ['marked_gps'] = "I have marked a location on your GPS. Go here and cut open the container. When you have done this you may keep the money!",
    ['hurry_for_police'] = "Hurry up, the police can be notified by this time!",
    ['not_enough_police'] = "There are not enough cops in the town.",
    ['no_mission_right_now'] = "I don't have a mission for you at the moment, please come back later!",
    ['mission_occupied'] = "Someone is doing a mission for me already!",
    
    -- Police notification
    ['police_message'] = {title = "Control Room", message = "Suspicious activity seen! Location is on your GPS!"},

    -- Error message when grabmoneytimers are higher then 47933 or lower/equal to 0
    ['error_message'] = "ERROR: Contact the server owner to check the script out. See F8 for the error message.",
}
-- Math utility aliases for clarity and reusability
mathfloor = math.floor
mathceil = math.ceil
mathround = math.round
mathrandom = math.random

-- Global state table
current = {
    initialized = false,
    inVehicle = false,
    stress = 0,
    settings = {},
    sound = {}
}

-- Sends a message to the NUI (React frontend)
function SendReactMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

-- Initializes HUD with server and player settings
function initialize()
    -- Initialize language settings
    Wait(1000)
    izzy.debug("Langs initializing!")
    SendReactMessage("setLang", cfg.locales[cfg.locale])
    izzy.debug("Langs initialized!")

    -- Load player settings
    Wait(100)
    izzy.debug("Server details and player settings initializing!")
    local settings = json.decode(GetResourceKvpString("settings")) or cfg.defaultSettings

    -- Assign status colors
    for _, status in pairs(cfg.status) do
        settings.statusColors[status.name] = cfg.colors[status.color] or cfg.colors.theme
    end

    -- Send server and HUD configuration to NUI
    SendReactMessage("setData", {
        showTopInfos = cfg.showTopInfos,
        showServerImage = cfg.showServerImage,
        serverName = cfg.serverName,
        serverDesc = cfg.serverDesc,
        useRealTime = cfg.useRealTime,
        useMinimapBorder = cfg.useMinimapBorder,
        showCompass = cfg.showCompass,
        showLocation = cfg.showLocation,
        notifyStyle = cfg.notifyStyle,
        notifyPosition = cfg.notifyPosition,
        currency = cfg.currency,
        colors = cfg.colors,
        settings = settings
    })

    Wait(500)
    current.settings = settings
    izzy.debug("Server details and player settings initialized!")

    -- Set initialized state
    Wait(100)
    current.initialized = true
    SendReactMessage("setDisplay", current.initialized)

    -- Initialize status values
    Wait(100)
    izzy.debug("Status initializing!")
    for _, status in ipairs(cfg.status) do
        status.value = getStatus(status.name)
    end
    SendReactMessage("setStatus", cfg.status)

    -- Initialize top info values
    Wait(100)
    izzy.debug("Top infos initializing!")
    for i, _ in ipairs(cfg.topInfos) do
        cfg.topInfos[i] = getTopInfo(cfg.topInfos[i])
    end
    SendReactMessage("setTopInfos", cfg.topInfos)
    izzy.debug("Top infos initialized!")

    -- Set map style and stress
    Wait(100)
    map(current.settings.mapStyle)
    current.stress = izzy.callback("sith-hud:getStress")

    -- Adjust minimap offset based on map style
    local screenWidth, _ = GetActiveScreenResolution()
    local offset = getMinimapAnchor().x * screenWidth + (current.settings.mapStyle == "circle" and 9.0 or 0)
    SendReactMessage("setXOffset", offset)
end

-- Unloads HUD data
function unloadData()
    current.initialized = false
    SendReactMessage("setDisplay", current.initialized)
    DisplayRadar(0)
end

-- Main thread for updating HUD status and weapon info
CreateThread(function()
    SetNuiFocus(false)
    DisplayRadar(0)

    while true do
        if current.initialized then
            local playerPed = PlayerPedId()
            local weapon = GetSelectedPedWeapon(playerPed)
            local weaponData = izzy.weapons[weapon]

            -- Update status values
            for _, status in ipairs(cfg.status) do
                if status.name == "mic" then
                    status.active = getVoiceState().talking
                end
                status.value = mathfloor(getStatus(status.name))
            end

            -- Update weapon info
            if weapon and weapon ~= -1569615261 and weaponData then
                local ammoInClip = GetAmmoInClip(playerPed, weapon)
                local totalAmmo = GetAmmoInPedWeapon(playerPed, weapon) - ammoInClip
                SendReactMessage("setWeapon", {
                    current = ammoInClip,
                    total = totalAmmo,
                    name = (weaponData.name or "WEAPON_ASSAULTRIFLE"):lower(),
                    label = weaponData.label or "Assault Rifle"
                })
            else
                SendReactMessage("setWeapon", {})
            end

            -- Configure radar settings
            SetRadarBigmapEnabled(false, false)
            SetRadarZoom(cfg.minimapScale)
            SendReactMessage("setStatus", cfg.status)
        end

        Wait(cfg.statusInterval)
    end
end)

-- Thread for updating top infos and radar visibility
CreateThread(function()
    while true do
        if current.initialized then
            -- Update top infos
            for i, _ in ipairs(cfg.topInfos) do
                cfg.topInfos[i] = getTopInfo(cfg.topInfos[i])
            end
            SendReactMessage("setTopInfos", cfg.topInfos)

            -- Update HUD visibility based on pause menu
            SendReactMessage("setVisibility", not IsPauseMenuActive())

            -- Control radar visibility
            if current.settings.cinematic then
                DisplayRadar(0)
            elseif current.settings.mapVisibility == "always" or current.inVehicle then
                DisplayRadar(1)
            else
                DisplayRadar(0)
            end
        end

        Wait(cfg.topInfosInterval)
    end
end)

-- Caches and retrieves street name based on player position
local lastStreetUpdate = 0
local streetCache = {}

function getStreetName(playerPed)
    local currentTime = GetGameTimer()
    if currentTime - lastStreetUpdate > 1500 then
        local coords = GetEntityCoords(playerPed)
        local streetHash, crossStreetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        lastStreetUpdate = currentTime
        streetCache = {
            GetStreetNameFromHashKey(streetHash),
            GetStreetNameFromHashKey(crossStreetHash)
        }
    end
    return streetCache
end

-- Thread for updating compass and direction
CreateThread(function()
    local lastHeading = "0"
    while cfg.showCompass do
        if current.initialized then
            local camRot = GetGameplayCamRot(0)
            local heading = tostring(mathfloor((360.0 - (camRot.z + 360.0) % 360.0)))

            SendReactMessage("setLocation", {
                heading = heading ~= lastHeading and heading or "0",
                direction = getDirection(),
                inVehicle = current.inVehicle
            })
            lastHeading = heading
        end
        Wait(cfg.locationInterval)
    end
end)

-- Thread for updating location and time
CreateThread(function()
    while true do
        if current.initialized and (cfg.showLocation or current.settings.statusStyle == 7) then
            local playerPed = PlayerPedId()
            local streets = getStreetName(playerPed)
            SendReactMessage("setLocation", {
                street = streets[1] .. " " .. streets[2],
                time = calculateTime()
            })
        end
        Wait(1000)
    end
end)

-- Adds a notification to the HUD
function addNotification(type, title, message, duration)
    SendReactMessage("addNotification", {
        type = type == "error" and "error" or type == "success" and "success" or "inform",
        str = message,
        duration = duration or 5000,
        title = title
    })
end

-- Export and register notification event
exports("addNotification", addNotification)
RegisterNetEvent("sith-hud:client:addNotification", addNotification)

-- Debug notification command
RegisterCommand("notify", function()
    addNotification("success", "Izzy", "Izzy Shop")
    Wait(100)
    addNotification("inform", "Izzy", "Izzy Shop")
    Wait(100)
    addNotification("error", "Izzy", "Izzy Shop")
end)

-- NUI callback to reset settings
RegisterNUICallback("reset", function(data, cb)
    current.settings = cfg.defaultSettings
    for _, status in pairs(cfg.status) do
        current.settings.statusColors[status.name] = cfg.colors[status.color] or cfg.colors.theme
    end

    SendReactMessage("clearLocalStorage")
    SendReactMessage("setData", { settings = current.settings })
    SendReactMessage("setDisplay", false)
    Wait(500)
    SendReactMessage("setDisplay", true)
    SetResourceKvp("settings", json.encode(current.settings))
    cb({ "ok" })
end)

-- NUI callback to update settings
RegisterNUICallback("updateData", function(data, cb)
    for key, value in pairs(data) do
        current.settings[key] = value
        if key == "mapVisibility" or key == "mapStyle" then
            map(current.settings.mapStyle)
            local screenWidth, _ = GetActiveScreenResolution()
            local offset = getMinimapAnchor().x * screenWidth + (current.settings.mapStyle == "circle" and 9.0 or 0)
            SendReactMessage("setXOffset", offset)
        end
    end
    SetResourceKvp("settings", json.encode(current.settings))
    cb({ "ok" })
end)

-- NUI callback to get status
RegisterNUICallback("getStatus", function(data, cb)
    cb(cfg.status)
end)

-- NUI callback to close settings/music UI
RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    SendReactMessage("setSettingsDisplay", false)
    SendReactMessage("setMusicDisplay", false)
    cb({ "ok" })
end)

-- Register settings command if enabled
if cfg.useSettings then
    RegisterCommand(cfg.settingsCommand, function()
        SendReactMessage("setSettingsDisplay", true)
        SetNuiFocus(true, true)
    end)
end

-- Register music player commands if enabled
if cfg.useMusicPlayer then
    RegisterCommand(cfg.musicCommand, function()
        if not current.inVehicle then return end
        SendReactMessage("setMusicDisplay", true)
        SetNuiFocus(true, true)
    end)

    RegisterCommand(cfg.focusCommand, function()
        if not current.inVehicle then return end
        SetNuiFocus(true, true)
    end)
end

-- Calculates minimap anchor for positioning
function getMinimapAnchor()
    local safeZone = GetSafeZoneSize()
    local safeZoneX, safeZoneY = 0.05, 0.05
    local aspectRatio = GetAspectRatio(0)
    local screenWidth, screenHeight = GetActiveScreenResolution()
    local xUnit, yUnit = 1.0 / screenWidth, 1.0 / screenHeight

    local anchor = {}
    anchor.width = xUnit * (screenWidth / (4 * aspectRatio))
    anchor.height = yUnit * (screenHeight / 5.674)
    anchor.left_x = xUnit * screenWidth * safeZoneX * math.abs(safeZone - 1.0) * 10
    anchor.bottom_y = 1.0 - (yUnit * screenHeight * safeZoneY * math.abs(safeZone - 1.0) * 10)
    anchor.right_x = anchor.left_x + anchor.width
    anchor.top_y = anchor.bottom_y - anchor.height
    anchor.x = anchor.left_x
    anchor.y = anchor.top_y
    anchor.xunit = xUnit
    anchor.yunit = yUnit

    return anchor
end
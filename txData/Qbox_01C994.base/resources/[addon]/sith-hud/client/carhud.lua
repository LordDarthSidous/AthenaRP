
function enteredVehicle()
    current.inVehicle = true
    SendReactMessage("setVehicleDisplay", true)

    local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false))
    local soundData = izzy.callback("sith-hud:server:getSoundByPlate", plate)

    if soundData then
        current.sound = soundData
        volume = soundData.volume

        if soundData.isPlaying then
            exports.xsound:PlayUrl(soundData.plate, soundData.url, soundData.volume / 100, false)
            Wait(1000)
            exports.xsound:setTimeStamp(soundData.plate, soundData.timeStamp)
        else
            Wait(1000)
        end
        SendReactMessage("setRadio", soundData)
    end

    while current.inVehicle do
        Wait(cfg.speedoInterval)
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 then
            local speed = mathceil(GetEntitySpeed(vehicle) * (current.settings.speedType == "kmh" and 3.6 or 2.236936))
            local fuel = mathround(getFuel(vehicle))
            local vehicleClass = GetVehicleClass(vehicle)
            local gear = getGear(vehicle) or 0

            SendReactMessage("setVehicleData", {
                speedoType = vehicleClass == 14 and "boat" or (vehicleClass == 15 or vehicleClass == 16) and "heli" or nil,
                speed = speed,
                fuel = fuel,
                rpm = GetVehicleCurrentRpm(vehicle) * 12,
                previousGear = gear == 0 and "R" or gear == 1 and "N" or gear - 1,
                currentGear = gear == 0 and "N" or gear,
                nextGear = gear + 1 <= GetVehicleHighGear(vehicle) and gear + 1 or "",
                traction = "FWD",
                time = calculateTime(),
                engineRunning = GetIsVehicleEngineRunning(vehicle),
                lights = {
                    headlights = (GetVehicleDashboardLights() == 128 or GetVehicleDashboardLights() == 256) and 1 or GetVehicleDashboardLights() == 384 and 2 or 0,
                    seatbelt = getSeatbelt(vehicle),
                    engine = tonumber(mathfloor(GetVehicleEngineHealth(vehicle) / 10)),
                }
            })
        end

        if not current.settings.cinematic then
            DisplayRadar(1)
        end
    end

    if not current.settings.alwaysShowMap then
        DisplayRadar(0)
    end

    if current.sound and GetResourceState("xsound") == "started" then
        if exports.xsound:soundExists(current.sound.plate) then
            if current.sound.musicId then
                current.sound.timeStamp = exports.xsound:getTimeStamp(current.sound.plate)
                current.sound.volume = volume
                TriggerServerEvent("sith-hud:server:updateSound", current.sound, true)
            end
            exports.xsound:Destroy(current.sound.plate)
        end
        SendReactMessage("setRadio", nil)
        current.sound = nil
    end
end

function leftVehicle()
    current.inVehicle = false
    SendReactMessage("setVehicleDisplay", false)
    if not current.settings.alwaysShowMap then
        DisplayRadar(0)
    end
end

CreateThread(function()
    while true do
        if current.initialized then
            local ped = PlayerPedId()
            local inVehicle = IsPedInAnyVehicle(ped, false)

            if not current.inVehicle and inVehicle then
                TriggerEvent("sith-hud:enteredVehicle")
                CreateThread(enteredVehicle)
            elseif current.inVehicle and (not inVehicle or IsPlayerDead(PlayerId())) then
                leftVehicle()
            end
        end
        Wait(1000)
    end
end)

if cfg.useMusicPlayer then
    RegisterCommand(cfg.musicCommand, function()
        if current.inVehicle then
            SendReactMessage("setMusicDisplay", true)
            SetNuiFocus(true, true)
        end
    end)
end

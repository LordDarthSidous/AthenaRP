seatbeltOn = false
local handbrake = 0
local newvehicleBodyHealth = 0
local currentvehicleBodyHealth = 0
local frameBodyChange = 0
local lastFrameVehiclespeed = 0
local lastFrameVehiclespeed2 = 0
local thisFrameVehicleSpeed = 0
local tick = 0
local damagedone = false
local modifierDensity = true
local lastVehicle = nil
local veloc

local function ejectFromVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local coords = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 1.0)
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    Wait(1)
    SetPedToRagdoll(ped, 5511, 5511, 0, 0, 0, 0)
    SetEntityVelocity(ped, veloc.x * 4, veloc.y * 4, veloc.z * 4)
    local ejectspeed = mathceil(GetEntitySpeed(ped) * 8)
    if GetEntityHealth(ped) - ejectspeed > 0 then
        SetEntityHealth(ped, GetEntityHealth(ped) - ejectspeed)
    elseif GetEntityHealth(ped) ~= 0 then
        SetEntityHealth(ped, 0)
    end
end

local function toggleSeatbelt()
    seatbeltOn = not seatbeltOn
    seatBeltLoop()
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, seatbeltOn and 'carbuckle' or 'carunbuckle', 0.25)
end

local function resetHandBrake()
    if handbrake <= 0 then return end
    handbrake -= 1
end

function seatBeltLoop()
    CreateThread(function()
        while true do
            if seatbeltOn then
                DisableControlAction(0, 75, true)
                DisableControlAction(27, 75, true)
            end
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                seatbeltOn = false
                break
            end
            if not seatbeltOn then break end
            Wait(0)
        end
    end)
end

RegisterNetEvent('sith-hud:enteredVehicle', function()
    local playerPed = PlayerPedId()
    while IsPedInAnyVehicle(playerPed, false) do
        Wait(0)
        local currentVehicle = GetVehiclePedIsIn(playerPed, false)
        if currentVehicle and currentVehicle ~= false and currentVehicle ~= 0 then
            SetPedHelmet(playerPed, false)
            lastVehicle = GetVehiclePedIsIn(playerPed, false)
            if GetVehicleEngineHealth(currentVehicle) < 0.0 then
                SetVehicleEngineHealth(currentVehicle, 0.0)
            end
            if (GetVehicleHandbrake(currentVehicle) or (GetVehicleSteeringAngle(currentVehicle)) > 25.0 or (GetVehicleSteeringAngle(currentVehicle)) < -25.0) then
                if handbrake == 0 then
                    handbrake = 100
                    resetHandBrake()
                else
                    handbrake = 100
                end
            end

            thisFrameVehicleSpeed = GetEntitySpeed(currentVehicle) * 3.6
            currentvehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
            if currentvehicleBodyHealth == 1000 and frameBodyChange ~= 0 then
                frameBodyChange = 0
            end
            if frameBodyChange ~= 0 then
                if lastFrameVehiclespeed > 110 and thisFrameVehicleSpeed < (lastFrameVehiclespeed * 0.75) and not damagedone then
                    if frameBodyChange > 18.0 then
                        if not seatbeltOn and not IsThisModelABike(currentVehicle) then
                            if mathrandom(mathceil(lastFrameVehiclespeed)) > 60 then
                                ejectFromVehicle()
                            end
                        elseif seatbeltOn and not IsThisModelABike(currentVehicle) then
                            if lastFrameVehiclespeed > 150 then
                                if mathrandom(mathceil(lastFrameVehiclespeed)) > 150 then
                                    --ejectFromVehicle()
                                end
                            end
                        end
                    else
                        if not seatbeltOn and not IsThisModelABike(currentVehicle) then
                            if mathrandom(mathceil(lastFrameVehiclespeed)) > 60 then
                                ejectFromVehicle()
                            end
                        elseif seatbeltOn and not IsThisModelABike(currentVehicle) then
                            if lastFrameVehiclespeed > 120 then
                                if mathrandom(mathceil(lastFrameVehiclespeed)) > 200 then
                                    --ejectFromVehicle()
                                end
                            end
                        end
                    end
                    damagedone = true
                    SetVehicleEngineOn(currentVehicle, false, true, true)
                end
                if currentvehicleBodyHealth < 350.0 and not damagedone then
                    damagedone = true
                    SetVehicleEngineOn(currentVehicle, false, true, true)
                    Wait(1000)
                end
            end
            if lastFrameVehiclespeed < 100 then
                Wait(100)
                tick = 0
            end
            frameBodyChange = newvehicleBodyHealth - currentvehicleBodyHealth
            if tick > 0 then
                tick -= 1
                if tick == 1 then
                    lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * 3.6
                end
            else
                if damagedone then
                    damagedone = false
                    frameBodyChange = 0
                    lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * 3.6
                end
                lastFrameVehiclespeed2 = GetEntitySpeed(currentVehicle) * 3.6
                if lastFrameVehiclespeed2 > lastFrameVehiclespeed then
                    lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * 3.6
                end
                if lastFrameVehiclespeed2 < lastFrameVehiclespeed then
                    tick = 25
                end
            end
            if tick < 0 then
                tick = 0
            end
            newvehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
            if not modifierDensity then
                modifierDensity = true
            end
            veloc = GetEntityVelocity(currentVehicle)
        else
            if lastVehicle then
                SetPedHelmet(playerPed, true)
                Wait(200)
                newvehicleBodyHealth = GetVehicleBodyHealth(lastVehicle)
                if not damagedone and newvehicleBodyHealth < currentvehicleBodyHealth then
                    damagedone = true
                    SetVehicleEngineOn(lastVehicle, false, true, true)
                    Wait(1000)
                end
                lastVehicle = nil
            end
            lastFrameVehiclespeed2 = 0
            lastFrameVehiclespeed = 0
            newvehicleBodyHealth = 0
            currentvehicleBodyHealth = 0
            frameBodyChange = 0
            Wait(2000)
            break
        end
    end
end)

if cfg.seatbeltWarnSound then
    CreateThread(function()
        while true do
            Wait(2000)
            local vehicle = GetVehiclePedIsIn(PlayerPedId())
            local model = GetEntityModel(vehicle)
            if not IsThisModelABike(model) and not IsThisModelABoat(model) and not IsThisModelAJetski(model) then
                if IsPedInAnyVehicle(PlayerPedId()) and GetEntitySpeed(PlayerPedId()) > 10 and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
                    if not seatbeltOn then
                        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'beltalarm', cfg.seatbeltWarnVolume)
                    end
                end
            end
        end
    end)
end

izzy.registerKeyMap({
    command = 'toggleseatbelt',
    key = 'B',
    description = izzy._t('toggleseatbelt'),
}, function()
    local pPed = PlayerPedId()
    if not IsPedInAnyVehicle(pPed, false) or IsPauseMenuActive() then return end
    local class = GetVehicleClass(GetVehiclePedIsUsing(pPed))
    if class == 8 or class == 13 or class == 14 then return end
    toggleSeatbelt()
end)

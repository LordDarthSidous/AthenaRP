if cfg.useStress then
    CreateThread(function() -- Speeding
        while true do
            if current.initialized then
                local ped = PlayerPedId()
                if IsPedInAnyVehicle(ped, false) then
                    local veh = GetVehiclePedIsIn(ped, false)
                    local vehClass = GetVehicleClass(veh)
                    local speed = GetEntitySpeed(veh) * (current.settings.speedType == "kmh" and 3.6 or 2.236936)
                    local vehHash = GetEntityModel(veh)
                    if cfg.VehClassStress[tostring(vehClass)] and not cfg.WhitelistedVehicles[vehHash] then
                        local stressSpeed
                        if vehClass == 8 then -- Motorcycle exception for seatbelt
                            stressSpeed = cfg.MinimumSpeed
                        else
                            stressSpeed = seatbeltOn and cfg.MinimumSpeed or cfg.MinimumSpeedUnbuckled
                        end
                        if speed >= stressSpeed and not cfg.WhitelistedJobs[getPlayerJob()] then
                            Wait(1000)
                            TriggerServerEvent('sith-hud:server:gainStress', math.random(1, 3))
                        end
                    end
                end
            end
            Wait(10000)
        end
    end)

    CreateThread(function() -- Shooting
        while true do
            if current.initialized then
                local ped = PlayerPedId()
                local weapon = GetSelectedPedWeapon(ped)
                if weapon ~= `WEAPON_UNARMED` then
                    if IsPedShooting(ped) and not cfg.WhitelistedWeaponStress[weapon] then
                        if math.random() < cfg.StressChance and not cfg.WhitelistedJobs[getPlayerJob()] then
                            Wait(1000)
                            TriggerServerEvent('sith-hud:server:gainStress', math.random(1, 3))
                        end
                    end
                else
                    Wait(1000)
                end
            end
            Wait(1000)
        end
    end)

    local function GetBlurIntensity(stresslevel)
        for _, v in pairs(cfg.Intensity['blur']) do
            if stresslevel >= v.min and stresslevel <= v.max then
                return v.intensity
            end
        end
        return 1500
    end
    
    local function GetEffectInterval(stresslevel)
        for _, v in pairs(cfg.EffectInterval) do
            if stresslevel >= v.min and stresslevel <= v.max then
                return v.timeout
            end
        end
        return 60000
    end
    
    CreateThread(function()
        while true do
            local ped = PlayerPedId()
            local effectInterval = GetEffectInterval(current.stress)
            if current.stress >= 100 then
                local BlurIntensity = GetBlurIntensity(current.stress)
                local FallRepeat = math.random(2, 4)
                local RagdollTimeout = FallRepeat * 1750
                TriggerScreenblurFadeIn(1000.0)
                Wait(BlurIntensity)
                TriggerScreenblurFadeOut(1000.0)
    
                if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                    SetPedToRagdollWithFall(ped, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                end
    
                Wait(1000)
                for _ = 1, FallRepeat, 1 do
                    Wait(750)
                    DoScreenFadeOut(200)
                    Wait(1000)
                    DoScreenFadeIn(200)
                    TriggerScreenblurFadeIn(1000.0)
                    Wait(BlurIntensity)
                    TriggerScreenblurFadeOut(1000.0)
                end
            elseif current.stress >= cfg.MinimumStress then
                local BlurIntensity = GetBlurIntensity(current.stress)
                TriggerScreenblurFadeIn(1000.0)
                Wait(BlurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            end

            if current.stress >= 1 then
                Wait(1000)
                TriggerServerEvent('sith-hud:server:relieveStress', math.random(1, 3))
            end
            Wait(effectInterval)
        end
    end)
    
    RegisterNetEvent("sith-hud:client:setStress", function(value)
        current.stress = value
    end)

    RegisterNetEvent("sith-hud:client:gainStress", function(value)
        Wait(1000)
        TriggerServerEvent('sith-hud:server:gainStress', value)
    end)

    RegisterNetEvent("sith-hud:client:relieveStress", function(value)
        Wait(1000)
        TriggerServerEvent('sith-hud:server:relieveStress', value)
    end)
end

local isOpen = false

local function send(action, payload)
    SendNUIMessage({
        type = "towRemote",
        action = action,
        title = payload and payload.title or nil,
        options = payload and payload.options or nil,
    })
end

local UI_CTRL_THREAD = nil

local function SetUIControlsEnabled(state)
    if state then
        if UI_CTRL_THREAD then return end

        UI_CTRL_THREAD = CreateThread(function()
            local savedMouse = nil
            local altWasHeld = false
            while isOpen do
                DisableAllControlActions(0)

                local altHeld = IsDisabledControlPressed(0, 19)

                if altHeld and not altWasHeld and IsNuiFocused() then
                    savedMouse = { GetNuiCursorPosition() }
                    SetNuiFocusKeepInput(true)
                    SetNuiFocus(false, false)
                elseif not altHeld and altWasHeld and not IsNuiFocused() then
                    SetNuiFocus(true, true)
                    Wait(0)

                    if savedMouse then
                        local sx, sy = GetActiveScreenResolution()
                        SetCursorLocation(savedMouse[1] / sx, savedMouse[2] / sy)
                    end
                end

                if altHeld and not IsNuiFocused() then
                    EnableControlAction(0, 1, true)
                    EnableControlAction(0, 2, true)
                end

                EnableControlAction(0, 30, true)
                EnableControlAction(0, 31, true)
                EnableControlAction(0, 21, true)
                EnableControlAction(0, 22, true)
                EnableControlAction(0, 59, true)
                EnableControlAction(0, 71, true)
                EnableControlAction(0, 72, true)
                EnableControlAction(0, 63, true)
                EnableControlAction(0, 64, true)

                EnableControlAction(0, 249, true) -- proximity voice
                EnableControlAction(0, 137, true) -- radio voice
                EnableControlAction(0, 170, true) -- alt push to talk
                EnableControlAction(0, 246, true) -- team voice

                altWasHeld = altHeld
                Wait(0)
            end
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            UI_CTRL_THREAD = nil
        end)
    end
end
local UI_TYPING = false
local function ApplyNuiTypingState()
    -- When typing in inputs, DO NOT keep game input (prevents chat/other binds).
    -- When not typing, allow your movement/vehicle controls via KeepInput.
    if isOpen then
        SetNuiFocusKeepInput(not UI_TYPING)
    else
        SetNuiFocusKeepInput(false)
    end
end

local function setOpen(open)
    if open == isOpen then return end
    isOpen = open
    SetNuiFocus(open, open)

    if not open then
        send("close")
    end
end

local function netIdToEntity(netId)
    if not netId then return nil end
    local n = tonumber(netId)
    if not n then return nil end
    if NetworkDoesNetworkIdExist(n) then
        local ent = NetworkGetEntityFromNetworkId(n)
        if ent and ent ~= 0 and DoesEntityExist(ent) then
            return ent
        end
    end
    if DoesEntityExist(n) then
        return n
    end
    return nil
end

RegisterNetEvent("Pug:client:TowRemoteUI:Open", function(payload)
    payload = payload or {}
    if not isOpen then
        isOpen = true
        SetNuiFocus(true, true)

        UI_TYPING = false
        ApplyNuiTypingState()
        SetUIControlsEnabled(true)

        send("open", payload)
    else
        send("update", payload)
    end
end)

RegisterNetEvent("Pug:client:TowRemoteUI:Close", function()
    setOpen(false)
end)

RegisterNUICallback("towRemote:close", function(_, cb)
    setOpen(false)
    TriggerEvent("Pug:client:CloseTowMenu")
    cb({ ok = true })
end)

RegisterNUICallback("towRemote:action", function(data, cb)
    data = data or {}
    local action = tostring(data.action or "")
    local ent = netIdToEntity(data.netId)

    if action == "attach_vehicle" then
        if ent and DoesEntityExist(ent) then
            TriggerEvent("Pug:client:AddVehicleToTruck", ent)
        end
    elseif action == "unattach_vehicle" then
        if ent and DoesEntityExist(ent) then
            TriggerEvent("Pug:client:RemoveVehicleFromTruck", ent)
        end
    elseif action == "wind_hitch" then
        TriggerEvent("Pug:client:WindHitch")
    elseif action == "unwind_hitch" then
        TriggerEvent("Pug:client:UnWindHitch")
    elseif action == "remove_tow_hook" then
        TriggerEvent("Pug:client:RemoveTowHook")
    elseif action == "put_remote_away" then
        setOpen(false)
        TriggerEvent("Pug:client:CloseTowMenu")
    end

    cb({ ok = true })
end)

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    setOpen(false)
end)

local vehicleSounds = {}
local playerData = {}

CreateThread(function()
    while true do
        GlobalState.playerCount = GetNumPlayerIndices()
        Wait(15000)
    end
end)

izzy.createCallback("sith-hud:getName", function(source)
    return getPlayerName(source)
end)

RegisterNetEvent("sith-hud:server:gainStress", function(stressAmount)
    local playerId = source
    local identifier = getIdentifier(playerId)
    if not identifier then return end

    if not playerData[identifier] then
        playerData[identifier] = 0
    end

    playerData[identifier] = math.min(playerData[identifier] + stressAmount, 100)
    TriggerClientEvent("sith-hud:client:setStress", playerId, playerData[identifier])
end)

RegisterNetEvent("sith-hud:server:relieveStress", function(stressAmount)
    local playerId = source
    local identifier = getIdentifier(playerId)
    if not identifier then return end

    if not playerData[identifier] then
        playerData[identifier] = 0
    end

    playerData[identifier] = math.max(playerData[identifier] - stressAmount, 0)
    TriggerClientEvent("sith-hud:client:setStress", playerId, playerData[identifier])
end)

RegisterNetEvent("hud:server:GainStress", function(stressAmount)
    TriggerClientEvent("sith-hud:client:gainStress", source, stressAmount)
end)

RegisterNetEvent("hud:server:RelieveStress", function(stressAmount)
    TriggerClientEvent("sith-hud:client:relieveStress", source, stressAmount)
end)

izzy.createCallback("sith-hud:getStress", function(source)
    local identifier = getIdentifier(source)
    return playerData[identifier] or 0
end)

function getYouTubeVideoInfo(url)
    local promiseObj = promise.new()
    PerformHttpRequest(url, function(status, response)
        if status == 200 then
            local photo = string.match(response, '<meta property="og:image" content="(.-)">')
            local title = string.match(response, '<meta property="og:title" content="(.-)">')
            local author = string.match(response, '"ownerChannelName":"(.-)"')
            promiseObj:resolve({ photo = photo, name = title, author = author, url = url })
        else
            promiseObj:resolve(false)
        end
    end, "GET", "", { ["Content-Type"] = "text/html" })
    return Citizen.Await(promiseObj)
end

RegisterNetEvent("sith-hud:server:playSound", function(plate, soundData)
    if not soundData or not soundData.url then return end
    local videoInfo = getYouTubeVideoInfo(soundData.url)
    if not plate or not videoInfo then return end

    soundData.photo = videoInfo.photo
    soundData.name = videoInfo.name
    soundData.author = videoInfo.author
    soundData.maxDuration = 100
    soundData.plate = plate
    vehicleSounds[plate] = soundData
    TriggerClientEvent("sith-hud:client:playSound", -1, soundData)
end)

RegisterNetEvent("sith-hud:server:updateSound", function(soundData, clear)
    if clear then
        vehicleSounds[soundData] = nil
    else
        vehicleSounds[soundData.plate] = soundData
    end
    if not clear then
        TriggerClientEvent("sith-hud:client:updateSound", -1, soundData)
    end
end)

izzy.createCallback("sith-hud:server:getMusicData", function(source, url)
    local result = getYouTubeVideoInfo(url)
    return result or false
end)

izzy.createCallback("sith-hud:server:getSoundByPlate", function(source, plate)
    return vehicleSounds[plate]
end)
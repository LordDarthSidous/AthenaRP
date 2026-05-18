-- Exit if music player is disabled
if not cfg.useMusicPlayer then
    return
end

-- Default volume setting
volume = 50

-- Updates the sound state for the current vehicle
function updateSoundState()
    local sound = current.sound
    if sound then
        local soundInfo = exports.xsound:getInfo(sound.plate)
        if not soundInfo then
            -- Play new sound if none exists
            exports.xsound:PlayUrl(sound.plate, sound.url, 0.1, false)
            Wait(1000)
            exports.xsound:setTimeStamp(sound.plate, sound.timeStamp or 0)
        else
            -- Toggle play/pause state
            sound.isPlaying = not sound.isPlaying
            sound.timeStamp = soundInfo.timeStamp
        end
        TriggerServerEvent("sith-hud:server:updateSound", sound)
    else
        SendReactMessage("setRadio", nil)
    end
end

-- Plays a sound in the current vehicle
function playSound(soundData)
    soundData.timeStamp = 0
    soundData.isPlaying = true
    soundData.volume = volume
    local vehiclePlate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false))
    TriggerServerEvent("sith-hud:server:playSound", vehiclePlate, soundData)
end

-- NUI callback to play music
RegisterNUICallback("playMusic", function(data, cb)
    local sound = current.sound
    if sound and sound.url == data.url then
        updateSoundState()
    else
        playSound(data)
    end
    cb({ "ok" })
end)

-- NUI callback to update sound state
RegisterNUICallback("updateSoundState", function(data, cb)
    updateSoundState()
    cb({ "ok" })
end)

-- NUI callback to retrieve playlists and favorites
RegisterNUICallback("getMusicDatas", function(data, cb)
    cb({
        playlists = json.decode(GetResourceKvpString("playlists")) or {},
        favorites = json.decode(GetResourceKvpString("favoriteMusics")) or {}
    })
end)

-- NUI callback to add a new playlist
RegisterNUICallback("addPlaylist", function(data, cb)
    local playlists = json.decode(GetResourceKvpString("playlists")) or {}
    table.insert(playlists, data)
    SetResourceKvp("playlists", json.encode(playlists))
    SendReactMessage("setPlaylists", playlists)
    SendReactMessage("setCurrent", #playlists - 1)
    cb({ "ok" })
end)

-- NUI callback to edit an existing playlist
RegisterNUICallback("editPlaylist", function(data, cb)
    local playlists = json.decode(GetResourceKvpString("playlists")) or {}
    playlists[data.id + 1] = data
    SetResourceKvp("playlists", json.encode(playlists))
    SendReactMessage("setPlaylists", playlists)
    cb({ "ok" })
end)

-- NUI callback to delete a playlist
RegisterNUICallback("deletePlaylist", function(data, cb)
    local playlists = json.decode(GetResourceKvpString("playlists")) or {}
    if playlists[data.id + 1] then
        table.remove(playlists, data.id + 1)
    end
    SetResourceKvp("playlists", json.encode(playlists))
    SendReactMessage("setPlaylists", playlists)
    cb({ "ok" })
end)

-- NUI callback to delete a music track from a playlist
RegisterNUICallback("deleteMusic", function(data, cb)
    local playlists = json.decode(GetResourceKvpString("playlists")) or {}
    local playlist = playlists[data.playlistId]
    if playlist and playlist.musics[data.musicId] then
        local music = playlist.musics[data.musicId]
        if current.sound and music.url == current.sound.url then
            exports.xsound:Destroy(current.sound.plate)
            TriggerServerEvent("sith-hud:server:updateSound", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)), true, true)
            SendReactMessage("setRadio", nil)
            current.sound = nil
        end
        table.remove(playlist.musics, data.musicId)
    end
    SetResourceKvp("playlists", json.encode(playlists))
    SendReactMessage("setPlaylists", playlists)
    cb({ "ok" })
end)

-- NUI callback to add a music track to a playlist
RegisterNUICallback("addMusic", function(data, cb)
    local playlists = json.decode(GetResourceKvpString("playlists")) or {}
    local playlist = playlists[data.id + 1]
    if playlist then
        local musicData = izzy.callback("sith-hud:server:getMusicData", data.url)
        if not musicData then
            return
        end
        table.insert(playlist.musics, musicData)
        SetResourceKvp("playlists", json.encode(playlists))
        SendReactMessage("setPlaylists", playlists)
    end
    cb({ "ok" })
end)

-- NUI callback to add a music track to favorites
RegisterNUICallback("addFavorite", function(data, cb)
    local favorites = json.decode(GetResourceKvpString("favoriteMusics")) or {}
    table.insert(favorites, data)
    SetResourceKvp("favoriteMusics", json.encode(favorites))
    SendReactMessage("setFavorites", favorites)
    cb({ "ok" })
end)

-- NUI callback to remove a music track from favorites
RegisterNUICallback("removeFavorite", function(data, cb)
    local favorites = json.decode(GetResourceKvpString("favoriteMusics")) or {}
    for i, favorite in pairs(favorites) do
        if favorite.url == data.url then
            table.remove(favorites, i)
            break
        end
    end
    SetResourceKvp("favoriteMusics", json.encode(favorites))
    SendReactMessage("setFavorites", favorites)
    cb({ "ok" })
end)

-- NUI callback to play the previous music track
RegisterNUICallback("previousMusic", function(data, cb)
    local sound = current.sound
    local musicList = sound.favorite and json.decode(GetResourceKvpString("favoriteMusics")) or json.decode(GetResourceKvpString("playlists"))
    musicList = musicList or {}
    local tracks = sound.favorite and musicList or musicList[sound.playlistId].musics
    if #musicList > 0 and tracks[sound.musicId - 1] then
        local prevTrack = tracks[sound.musicId - 1]
        prevTrack.playlistId = sound.playlistId
        prevTrack.musicId = sound.musicId - 1
        playSound(prevTrack)
    end
    cb({ "ok" })
end)

-- NUI callback to play the next music track
RegisterNUICallback("nextMusic", function(data, cb)
    local sound = current.sound
    local playlists = json.decode(GetResourceKvpString("playlists")) or {}
    if #playlists > 0 then
        local tracks = playlists[sound.playlistId].musics
        local nextTrack = tracks[sound.musicId + 1]
        if nextTrack then
            nextTrack.playlistId = sound.playlistId
            nextTrack.musicId = sound.musicId + 1
            playSound(nextTrack)
        end
    end
    cb({ "ok" })
end)

-- NUI callback to update volume
RegisterNUICallback("updateVolume", function(data, cb)
    volume = data
    if current.sound then
        local soundInfo = exports.xsound:getInfo(current.sound.plate)
        if soundInfo then
            exports.xsound:setVolume(current.sound.plate, volume / 100)
        end
    end
    SendReactMessage("setRadio", { volume = volume })
    cb({ "ok" })
end)

-- NUI callback to stop music playback
RegisterNUICallback("closeMusic", function(data, cb)
    if current.sound then
        local soundInfo = exports.xsound:getInfo(current.sound.plate)
        if soundInfo then
            exports.xsound:Destroy(current.sound.plate)
        end
        current.sound = nil
    end
    TriggerServerEvent("sith-hud:server:updateSound", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)), true, true)
    SendReactMessage("setRadio", "{}")
    cb({ "ok" })
end)

-- Client event to play sound for the current vehicle
RegisterNetEvent("sith-hud:client:playSound", function(soundData)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 and GetVehicleNumberPlateText(vehicle) == soundData.plate then
        exports.xsound:PlayUrl(soundData.plate, soundData.url, soundData.volume / 100, false)
        current.sound = soundData
        SendReactMessage("setRadio", soundData)
    end
end)

-- Client event to update sound state
RegisterNetEvent("sith-hud:client:updateSound", function(soundData)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 or GetVehicleNumberPlateText(vehicle) ~= soundData.plate then
        return
    end

    local soundInfo = exports.xsound:getInfo(current.sound.plate)
    if not soundInfo and current.sound.isPlaying then
        exports.xsound:PlayUrl(current.sound.plate, current.sound.url, 0.1, false)
        Wait(1000)
        exports.xsound:setTimeStamp(current.sound.plate, current.sound.timeStamp or 0)
    end

    if not soundData.isPlaying then
        exports.xsound:Pause(soundData.plate)
        if soundInfo then
            current.sound.maxDuration = exports.xsound:getMaxDuration(current.sound.plate)
            current.sound.timeStamp = exports.xsound:getTimeStamp(current.sound.plate)
        end
    else
        exports.xsound:Resume(soundData.plate)
        exports.xsound:setTimeStamp(soundData.plate, soundData.timeStamp)
    end
    SendReactMessage("setRadio", current.sound)
end)

-- Thread to monitor and update music playback
CreateThread(function()
    while cfg.useMusicPlayer do
        if current.sound then
            local maxDuration = exports.xsound:soundExists(current.sound.plate) and exports.xsound:getMaxDuration(current.sound.plate) or 0
            local timeStamp = exports.xsound:soundExists(current.sound.plate) and exports.xsound:getTimeStamp(current.sound.plate) or 0

            if exports.xsound:soundExists(current.sound.plate) then
                SendReactMessage("setRadio", { maxDuration = maxDuration, timeStamp = timeStamp })

                if maxDuration < timeStamp and current.sound.musicId and current.sound.isPlaying then
                    local playlists = json.decode(GetResourceKvpString("playlists")) or {}
                    if #playlists > 0 then
                        local tracks = current.sound.favorite and playlists or playlists[current.sound.playlistId].musics
                        local nextTrack = tracks[current.sound.musicId + 1] or tracks[1]
                        if nextTrack then
                            playSound(nextTrack)
                        end
                    end
                end
            end
            Wait(1000)
        else
            Wait(2000)
        end
    end
end)
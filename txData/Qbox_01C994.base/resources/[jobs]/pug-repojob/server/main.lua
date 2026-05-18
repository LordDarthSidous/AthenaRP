local activeRepoJobs = {}

RegisterNetEvent("Pug:Server:StartRepoJob", function(RandomID)
    local src = source
    local token = RandomID
    activeRepoJobs[src] = {
        token = token,
    }
end)

local function GetIdentifiers(source, idtype)
	local identifiers = GetPlayerIdentifiers(source)
	for _, identifier in pairs(identifiers) do
		if string.find(identifier, idtype) then
			return identifier
		end
	end
	return nil
end

local function round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

local function GetRepoRep(Player,CitizenId)
    if Framework == "ESX" then
        local Result = MySQL.query.await('SELECT * FROM pug_repojob WHERE citizenid = ?', {CitizenId})
        if Result[1] then
            return tonumber(Result[1].reporep)
        else
            MySQL.insert.await('INSERT INTO pug_repojob (citizenid, reporep) VALUES (?,?)', {
                CitizenId, 0
            })
            return 0
        end
    else
        if Player.PlayerData.metadata['reporep'] ~= nil then
            return tonumber(Player.PlayerData.metadata['reporep'])
        else
            Player.SetMetaData("reporep", 0)
            Player.Save()
            return 0
        end
    end
end

RegisterNetEvent("Pug:Server:FinishReoJob", function(rank)
    local src = source
    local jobData = activeRepoJobs[src]
    if not jobData then
        print(("[RepoJob] Player [%d] tried finishing with no active job."):format(src))
        DropPlayer(src, "[RepoJob] Player [%d] tried finishing with no active job")
        return
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    if #(playerCoords - vector3(jobData.token.x, jobData.token.y, jobData.token.z)) > 4.0 then
        print(("[RepoJob] Player [%d] tried finishing with no active job."):format(src))
        DropPlayer(src, "[RepoJob] Player [%d] tried finishing with no active job")
        return
    end

    local Player = Config.FrameworkFunctions.GetPlayer(src)
    local RepoRank = Config.RepoProgression[rank]
    local Pay = math.random(Config.MinimalPay, Config.MaximumPay)
    local FinalPay = round(Pay * RepoRank.Multiplier)
    local CID = Player.PlayerData.citizenid
    Player.AddMoney('cash', FinalPay)
    local RepoRep = GetRepoRep(Player, CID)
    local RepPay = math.random(Config.EarnableRepMin, Config.EarnableRepMax)
    local FinalRep = round(RepPay + RepoRep)
    if Framework == "ESX" then
        local Result = MySQL.query.await('SELECT * FROM pug_repojob WHERE citizenid = ?', {CID})
        if Result[1] then
            MySQL.update('UPDATE pug_repojob SET reporep = ? WHERE citizenid = ?', { FinalRep, CID })
        end
    else
        Player.SetMetaData("reporep", FinalRep)
    end
    TriggerClientEvent('Pug:client:RepoNotifyEvent', src, '+'..RepPay..Config.LangT["RepoRep"], 'success')
    local RareItemDrop = math.random(1, 100)
    if RareItemDrop <= Config.RareItemDropChance then
        if GetResourceState("avp_inv_4") == 'started' then
            exports["avp_inv_4"]:AddItem(src, Config.RareItemDropItem, 1)
        elseif GetResourceState("ox_inventory") == 'started' then
            exports.ox_inventory:AddItem(src, Config.RareItemDropItem, 1)
        else
            Player.AddItem(Config.RareItemDropItem, 1)
        end
    end
    activeRepoJobs[src] = nil
end)

if Framework == "QBCore" then
    FWork.Commands.Add("tptow", "Garage 1 Teleport", {}, false, function(source)
        TriggerClientEvent('Pug-TpTow', source)
    end,"admin")
    FWork.Commands.Add("getrepo", "Request a repo/tow driver", {{name = "Message", help = "information"}}, false, function(source, args)
        if args[1] then
            local src = source
            local Player = Config.FrameworkFunctions.GetPlayer(src)
            local PlayerInfo = {
                FirstName = Player.PlayerData.charinfo.firstname,
                LastName = Player.PlayerData.charinfo.lastname,
                Source = src,
            }
            TriggerClientEvent("Pug:client:GetRepoWorker",-1, args[1], PlayerInfo)
        else
            TriggerClientEvent('Pug:client:RepoNotifyEvent', source, Config.LangT["MissingText"], 'error')
        end
    end)
else
    FWork.RegisterCommand('tptow', "admin", function(xPlayer, args, showError)
        xPlayer.triggerEvent("Pug-TpTow")
    end, false, {help = "Admin tp to TowJob"})
    FWork.RegisterCommand('getrepo', 'user', function(xPlayer, args, showError)
        if args[1] then
            local src = source
            local Player = Config.FrameworkFunctions.GetPlayer(src)
            local PlayerInfo = {
                FirstName = Player.PlayerData.charinfo.firstname,
                LastName = Player.PlayerData.charinfo.lastname,
                Source = src,
            }
            for _, v in pairs(Config.FrameworkFunctions.GetPlayers()) do
                TriggerClientEvent("Pug:client:GetRepoWorker",v, args[1], PlayerInfo)
            end
        else
            TriggerClientEvent('Pug:client:RepoNotifyEvent', source, Config.LangT["MissingText"], 'error')
        end
    end, false, {help = "Request a repo/tow driver"})
end
RegisterNetEvent("Pug:server:SendPlayerRepoMessage", function(Ply, Message)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    local PlayerInfo = {
        FirstName = Player.PlayerData.charinfo.firstname,
        LastName = Player.PlayerData.charinfo.lastname,
    }
    TriggerClientEvent("chatMessage",Ply, "TOW/REPO MESSAGE", "warning", " ID ["..src.."] ".. PlayerInfo.FirstName .. " " .. PlayerInfo.LastName.. " | "..Message)
end)

if Framework == "QBCore" then
    FWork.Functions.CreateUseableItem("reponote", function(source, item)
        local src = source
        local pCoords = GetEntityCoords(GetPlayerPed(src))
        for _, v in pairs(Config.FrameworkFunctions.GetPlayers()) do
            local Player = Config.FrameworkFunctions.GetPlayer(v)
            if Player ~= nil then
                local tCoords = GetEntityCoords(GetPlayerPed(v))
                local dist = #(pCoords - tCoords)
                if dist <= 4.0 then
                    if Config.InventoryType == "ox_inventory" or Config.InventoryType == "qs-inventory" and Framework == "ESX" then
                        TriggerClientEvent('chat:addMessage', v,  {
                            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>[Repo Verification Note]</strong><br> <strong>Repo Worker:</strong> {0} {1}<br><strong>Vehicle Plate:</strong> {2} <br><strong>Vehicle Model:</strong> {3}',
                            args = {
                                item.metadata.firstname,
                                item.metadata.lastname,
                                item.metadata.vehiclePlate,
                                item.metadata.vehicleModel
                            }
                        })
                    else
                        TriggerClientEvent('chat:addMessage', v,  {
                            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>[Repo Verification Note]</strong><br> <strong>Repo Worker:</strong> {0} {1}<br><strong>Vehicle Plate:</strong> {2} <br><strong>Vehicle Model:</strong> {3}',
                            args = {
                                item.info.firstname,
                                item.info.lastname,
                                item.info.vehiclePlate,
                                item.info.vehicleModel
                            }
                        })
                    end
                end
            end
        end
    end)
    FWork.Functions.CreateUseableItem("towremote", function(source, item)
        local src = source
        TriggerClientEvent("Pug:Clent:TowTruckRemoteMenu", src)
    end)
elseif Framework == "ESX" then
    FWork.RegisterUsableItem("reponote", function(source, item, ItemInfoForESXOxInventory)
        local src = source
        local pCoords = GetEntityCoords(GetPlayerPed(src))
        for _, v in pairs(Config.FrameworkFunctions.GetPlayers()) do
            local Player = Config.FrameworkFunctions.GetPlayer(v)
            if Player ~= nil then
                local tCoords = GetEntityCoords(GetPlayerPed(v))
                local dist = #(pCoords - tCoords)
                if dist <= 5.0 then
                    if Config.InventoryType == "qs-inventory" then
                        TriggerClientEvent('chat:addMessage', v,  {
                            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>[Repo Verification Note]</strong><br> <strong>Repo Worker:</strong> {0} {1}<br><strong>Vehicle Plate:</strong> {2} <br><strong>Vehicle Model:</strong> {3}',
                            args = {
                                item.info.firstname,
                                item.info.lastname,
                                item.info.vehiclePlate,
                                item.info.vehicleModel
                            }
                        })
                    else
                        TriggerClientEvent('chat:addMessage', v,  {
                            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>[Repo Verification Note]</strong><br> <strong>Repo Worker:</strong> {0} {1}<br><strong>Vehicle Plate:</strong> {2} <br><strong>Vehicle Model:</strong> {3}',
                            args = {
                                ItemInfoForESXOxInventory.metadata.firstname,
                                ItemInfoForESXOxInventory.metadata.lastname,
                                ItemInfoForESXOxInventory.metadata.vehiclePlate,
                                ItemInfoForESXOxInventory.metadata.vehicleModel
                            }
                        })
                    end
                end
            end
        end
	end)
	FWork.RegisterUsableItem("towremote", function(source)
        local src = source
        TriggerClientEvent("Pug:Clent:TowTruckRemoteMenu", src)
	end)
end

local activeDeposits = {} 
RegisterNetEvent("Pug:server:ToggleTruckDeposite", function(take)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    if not Player then return end

    local BankKey = (Config.Currency == "cash" and "cash") or "bank"
    local amount  = Config.RepoTruckDeposit

    if take then
        if activeDeposits[src] then return end

        local BankBalance = Config.Currency == "cash" and Player.PlayerData.money.cash or Player.PlayerData.money.bank
        if BankBalance >= amount then
            Player.RemoveMoney(BankKey, amount)
            activeDeposits[src] = true
            TriggerClientEvent('Pug:client:RepoNotifyEvent', src, '-'..amount..' Deposited.', 'success')
        else
            TriggerClientEvent('Pug:client:RepoNotifyEvent', src, Config.LangT["NotEnoughMoney"], 'error')
        end
    else
        if not activeDeposits[src] then return end
        activeDeposits[src] = nil
        Player.AddMoney(BankKey, amount)
    end
end)
AddEventHandler('playerDropped', function()
    activeDeposits[source] = nil
end)


RegisterServerEvent('Pug:server:ToggleRepoItem', function(bool, item, amount, info)
    local src = source
    MySQL.Async.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(src),
        GetIdentifiers(src, 'license'),
        GetIdentifiers(src, 'discord'),
        GetIdentifiers(src, 'ip'),
        "BANNED BY PUG | Reach out to staff to appeal. - Tell them to reach out to pug with the ban message. Tried to give himself an item through a cheat menu",
        2145913200,
        'RepoJob'
    })
    DropPlayer(src, "BANNED BY PUG | Reach out to staff to appeal. - Tell them to reach out to pug with the ban message. Tried to give himself an item through a cheat menu")
end)


RegisterNetEvent("Pug:server:AddRepoItem", function(plate, model)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    local info = {
        firstname = Player.PlayerData.charinfo.firstname,
        lastname = Player.PlayerData.charinfo.lastname,
        vehiclePlate = plate,
        vehicleModel = model,
    }
    if string.lower(Config.InventoryType) == "qs-inventory" then
        exports['qs-inventory']:AddItem(src, "reponote", 1, false, info)
    elseif GetResourceState("avp_inv_4") == 'started' then
        exports["avp_inv_4"]:AddItem(src, "reponote", 1, info)
    elseif GetResourceState("ox_inventory") == 'started' then
        exports.ox_inventory:AddItem(src, "reponote", 1, info)
    else
        Player.AddItem("reponote", 1, false, info)
    end
    if GetResourceState("avp_inv_4") == 'started' then
        exports["avp_inv_4"]:AddItem(src, "towremote", 1, info)
    elseif GetResourceState("ox_inventory") == 'started' then
        exports.ox_inventory:AddItem(src, "towremote", 1)
    else
        Player.AddItem("towremote", 1)
    end
    if Framework == "QBCore" then
        TriggerClientEvent('inventory:client:ItemBox', src, FWork.Shared.Items["reponote"], "add")
        TriggerClientEvent('inventory:client:ItemBox', src, FWork.Shared.Items["towremote"], "add")
    end
end)

RegisterNetEvent("Pug:server:RemoveRepoLetter", function()
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    if Config.FrameworkFunctions.GetItemByName(src, "reponote", 1) then
        Player.RemoveItem("reponote", 1)
        if Framework == "QBCore" then
            TriggerClientEvent('inventory:client:ItemBox', src, FWork.Shared.Items["reponote"], "remove")
            TriggerClientEvent('inventory:client:ItemBox', src, FWork.Shared.Items["towremote"], "remove")
        end
    end
    if Config.FrameworkFunctions.GetItemByName(src, "towremote", 1) then
        Player.RemoveItem("towremote", 1)
        if Framework == "QBCore" then
            TriggerClientEvent('inventory:client:ItemBox', src, FWork.Shared.Items["towremote"], "remove")
        end
    end
end)

Config.FrameworkFunctions.CreateCallback('Pug:server:GetReopRep', function(source, cb)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    if not Player then 
        cb(0)
    else
        local CID = Player.PlayerData.citizenid
        local Rep = GetRepoRep(Player,CID)
        Wait(100)
        cb(Rep)
    end
end)

Config.FrameworkFunctions.CreateCallback('Pug:server:GetPlayerRepoJob', function(source, cb)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    if Player ~= nil then
        local BankBalance
        if Config.Currency == "bank" then
            BankBalance = Player.PlayerData.money.bank
        else
            BankBalance = Player.PlayerData.money.cash
        end
        if BankBalance >= Config.RepoTruckDeposit then
            if Config.JobReequired then
                if Player.PlayerData.job.name == Config.JobName then
                    cb(true)
                else
                    TriggerClientEvent("Pug:client:RepoNotifyEvent", src, Config.LangT["NotRepoEmployee"], "error")
                    cb(false)
                end
            else
                cb(true)
            end
        else
            TriggerClientEvent("Pug:client:RepoNotifyEvent", src, Config.LangT["MissingMoney"].. Config.RepoTruckDeposit - BankBalance, "error")
            cb(false)
        end
    else
        cb(false)
    end
end)

local Key = {}
RegisterNetEvent("Pug:server:CraftRepoParts", function(data)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    local MainItem = Config.CraftingParts[data.item]
    local CanCraftItem = true
    for k, v in pairs(MainItem.Parts) do
        local Item = Config.FrameworkFunctions.GetItemByName(src, k, v.Amount)
        if Item then
            local Amount
            if Framework == "QBCore" then
                Amount = Item.amount
            else
                Amount = Item.count
            end
            if Amount >= v.Amount then
            else
                TriggerClientEvent('Pug:client:RepoNotifyEvent', src, Config.LangT["Missing"].. v.Amount - Amount.."x "..k, 'error')
                CanCraftItem = false
                break
            end
        else
            TriggerClientEvent('Pug:client:RepoNotifyEvent', src, Config.LangT["Missing"]..k, 'error')
            CanCraftItem = false
            break
        end
    end
    Wait(100)
    if CanCraftItem then
        for k, v in pairs(MainItem.Parts) do
            Player.RemoveItem(k, v.Amount)
        end
        Key[src] = true
        TriggerClientEvent("Pug:client:CraftRepoParts", src,data)
    end
end)

RegisterNetEvent("Pug:Server:FinishCraft", function(data, WhatsThis)
    local src = source
    local item = Config.CraftingParts[data.item]
    if item ~= nil then
        if Key[src] then
            Key[src] = nil
            local Player = Config.FrameworkFunctions.GetPlayer(src)
            if WhatsThis then
                for k, v in pairs(item.Parts) do
                    if GetResourceState("avp_inv_4") == 'started' then
                        exports["avp_inv_4"]:AddItem(src, k, v.Amount)
                    elseif GetResourceState("ox_inventory") == 'started' then
                        exports.ox_inventory:AddItem(src, k, v.Amount)
                    else
                        Player.AddItem(k, v.Amount)
                    end
                    if Framework == "QBCore" then
                        TriggerClientEvent('inventory:client:ItemBox', src, FWork.Shared.Items[k], "add")
                    end
                end
            else
                if GetResourceState("avp_inv_4") == 'started' then
                    exports["avp_inv_4"]:AddItem(src, data.item, 1, info)
                elseif GetResourceState("ox_inventory") == 'started' then
                    exports.ox_inventory:AddItem(src, data.item, 1, info)
                else
                    Player.AddItem(data.item, 1, false, info)
                end
                if Framework == "QBCore" then
                    TriggerClientEvent('inventory:client:ItemBox', src, FWork.Shared.Items[data.item], "add")
                end
            end
        else
            MySQL.Async.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                GetPlayerName(src),
                GetIdentifiers(src, 'license'),
                GetIdentifiers(src, 'discord'),
                GetIdentifiers(src, 'ip'),
                "BANNED BY PUG | Reach out to staff to appeal. - ^2Player with ID: "..src.. " Was trying to give themselves an invalid item with cheats. Player is hacking.",
                2145913200,
                'RepoJob'
            })
            DropPlayer(src, "BANNED BY PUG | Reach out to staff to appeal. - ^2Player with ID: "..src.. " Was trying to give themselves an invalid item with cheats. Player is hacking.")
            print("^2Player with ID: "..src.. " Was trying to give themselves an invalid item with cheats. Player is hacking.")
        end
    else
        MySQL.Async.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(src),
            GetIdentifiers(src, 'license'),
            GetIdentifiers(src, 'discord'),
            GetIdentifiers(src, 'ip'),
            "BANNED BY PUG | Reach out to staff to appeal. - ^2Player with ID: "..src.. " Was trying to give themselves an invalid item.",
            2145913200,
            'RepoJob'
        })
        DropPlayer(src, "BANNED BY PUG | Reach out to staff to appeal. - ^2Player with ID: "..src.. " Was trying to give themselves an invalid item")
        print("^2Player with ID: "..src.. " Was trying to give themselves an invalid item")
    end
end)

-- lb-phone email event support
RegisterNetEvent("Pug:Server:SendLbPhoneMailTowJob", function(VehName, LicensePlate)
    local src = source
    local MyNumber = exports["lb-phone"]:GetEquippedPhoneNumber(src)
    local MyEmail = exports["lb-phone"]:GetEmailAddress(MyNumber)
    local success, id = exports["lb-phone"]:SendMail({
        to = MyEmail,
        subject = Config.LangT["EmailSender"],
        message = Config.LangT["EmailMessage1"] .. VehName .. Config.LangT["EmailMessage2"]..LicensePlate..".",
    })
end)

Config.FrameworkFunctions.CreateCallback('Pug:serverCB:RepoIsVehiclePlayerOwnd', function(source, cb, plate)
    if Framework == "QBCore" then
        local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
        if result then
            cb(result)
        else
            cb(false)
        end
    else
        local result = MySQL.scalar.await('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate})
        if result then
            cb(result)
        else
            cb(false)
        end
    end
end)

Config.FrameworkFunctions.CreateCallback('Pug:serverCB:RepoJobGetPlayerJob', function(source, cb)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    if Player then
        if Player.PlayerData.job.name == Config.JobName then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

CreateThread(function()
    if Framework == "QBCore" then
        if GetResourceState("qbx_core") ~= 'started' then 
            Wait(1000)
            if GetResourceState("qs-inventory") == 'started' then
                print("^2MAKE SURE PUG-REPO JOB STARTS BEFORE QS-INVENTORY IN YOUR SERVER.CFG")
            end
            local ItemsToAdd = {
                ["towremote"] = {
                    label = "Tow Remote",
                    weight = 1000,
                    image = "towremote.png",
                    unique = false,
                    useable = true,
                    shouldClose = true,
                    combinable = false,
                    description = "[useable] | [G] when in tow truck to lower and raise bed, [E] to pick the hook up and put the hook down",
                },
                ["reponote"] = {
                    label = "Repo Note",
                    weight = 500,
                    image = "reponote.png",
                    unique = false,
                    useable = true,
                    shouldClose = true,
                    combinable = false,
                    description = "[useable] | [G] when in tow truck to lower and raise bed, [E] to pick the hook up and put the hook down",
                },
            }
            for k, v in pairs(ItemsToAdd) do
                exports[Config.CoreName]:AddItem(k, {
                    name = k,
                    label = v.label,
                    weight = v.weight,
                    type = 'item',
                    image = v.image,
                    unique = v.unique,
                    useable = v.useable,
                    shouldClose = v.shouldClose,
                    combinable = v.combinable,
                    description = v.description,
                })
            end
        end
    elseif Framework == "ESX" then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `pug_repojob` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `citizenid` varchar(50) DEFAULT NULL,
                `reporep` int(11) DEFAULT NULL,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
        ]])
    end
end)
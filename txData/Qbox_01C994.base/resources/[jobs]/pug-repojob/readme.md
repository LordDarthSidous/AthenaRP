# Pug RepoJob.
For any questions please contact me here: here https://discord.gg/jYZuWYjfvq.
For any of my other scripts you can purchase here: https://pug-webstore.tebex.io/category/custom-scripts

# If you are a QBCore framework the script is basically drag and drop.
# Esx will as well be mostly drag and drop with config changes.
--
# Installation (ALL FRAMEWORKS)
Add the item pngs found in pug-repojob/itemPNGS to your inventory.
Thouroughly read the config and adjust to you liking. (VERY IMPORTANT)
--

# (ESX) es_extended\client/functions.lua and replace the ESX.Game.DeleteVehicle with this.
ESX.Game.DeleteVehicle = function(vehicle)
	SetEntityAsMissionEntity(vehicle,  false,  true)
	DeleteVehicle(vehicle)
    TriggerEvent("Pug:client:PutFlatbedAwayCustomEvent")
end
--

--
# (ESX & QBX ONLY) - Install this in to your ox_inventory/data/items.lua
['towremote'] = {
    label = 'Tow Remote',
    weight = 100,
},
['reponote'] = {
    label = 'Tow Note',
    weight = 100,
},
--

# (OPTIONAL)
Install the sound files in the pug-repojob/InteractSoundFiles into [standalone]/interact-sound/client/html/sounds if you want the 4 sound effects along with the script
(This may require a server restart to work)

# (OPTIONAL/QBCORE) If you want to allow players to own and store a flatbed3 truck you will need to add this event to your delete vehicle function so that the flatbed is not left behind just floating when you park it.
# Go to qb-core/client/functions.lua and replace the QBCore.Functions.DeleteVehicle() function with this. 
function QBCore.Functions.DeleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
    TriggerEvent("Pug:client:PutFlatbedAwayCustomEvent")
end

# Quick commands and things to know
/tptow to go to the repo job ped (admin only)
/getrepo command and /reporply command to request and reply to repo drivers
Pressing [G] when in the driver seat of a flatbed3 whill lower or raise the flatbed
To grab the towhook you need to have the flatbed down, go to the top of the flatbed and press [E]
To put a hook onto a vehicle you just press [E] while close to a vehicle and have the tow hook in your hand
To pickup a hook that is on a car or on the ground you just press [E]

(credits to I'm Not MentaL, Yoha, SxY & TheF3nt0n for the original free model here: https://www.gta5-mods.com/vehicles/mtl-flatbed-tow-truck)

# PUG-REPOJOB: For any questions please contact me here: https://discord.com/invite/jYZuWYjfvq

PREVIEW HERE:(VERY SOON)

(OPEN SOURCE)

​Full QBCore & ESX Compatibility. (supports custom qb-core names and all qb custom file dependency names)

This Ultimate Repo Job Script offers a thrilling and immersive experience for FiveM servers. With advanced flatbed and towing functionality, in-depth job missions, and a chance for angry car owners to come out and defend their vehicles, players will be hooked. with over 250 pickup locations, 40+ pre-configured cars, customizable progression and rare item drops, custom crafting tables, and an extensive config file, making it easy to tailor the repo job to your server's needs. This script also supports multiple languages and integrates seamlessly with other systems while running at an impressive 0.0 ms resmon.

Config: https://i.imgur.com/ExmzFZI.png
Readme: https://i.imgur.com/MFK7892.png

This completely configurable script consist of:
● Full development support and custom script adjustment request support.
● Advanced flatbed functionality with retractable capabilities.
● Advanced towing functionality with immersive capabilities.
● Advanced methods of making sure the vehicles NEVER poof unlike other vehicle related scripts.
● 250+ different vehicle pickup locations already configured and all changeable.
● 40+ pre configured cars to to pickup.
● In-depth job that offeres an immersive experience of being a repo man.
● A chance angry car owners can come out and defend there vehicle with mele weapons.
● 3 pre configured locations to drop the repoed vehicle off to.
● Unlock progression to obtain items configured by you.
● /getrepo command and /reporply command to request and reply to repo drivers.
● Custom Crafting tables that require progression and unlocks to craft things.
● Very extensive config.lua to help easily change the script with very little effort.
● Custom configurable lang system to support multiple languages.
● Support for other core names, other target systems and any resource name changes.
● Runs at 0.0 ms resmon.

Requirements/Dependencies consist of:
QBCore OR ESX (other frameworks will work but not supported)
qb-menu OR ox_lib (ps-ui or any qb-menu resource name changed will work)
qb-target OR ox_target (any qb-inventory resource name changed will work)
cfg = {
    debug = false,
    useSettings = true, -- if you set to false, /hud command will be cannot use anymore
    useMusicPlayer = true,
    settingsCommand = "hud",
    musicCommand = 'music',
    focusCommand = 'focus',
    
    statusInterval = 500,
    topInfosInterval = 1000,
    speedoInterval = 0,
    locationInterval = 250,
    minimapScale = 1100, -- if you using colored map, change to 1100

    showTopInfos = false,
    showServerImage = false,
    useRealTime = true, -- if you set to true, will be used real life time
    useMinimapBorder = true,
    showCompass = true,
    showLocation = true,
    notifyStyle = 1, -- 1 / 2 / 3
    notifyPosition = 'top-center', -- top-left / top-center / top-right --- bottom-left / bottom-center / bottom-right

    serverName = 'Un-named',
    serverDesc = 'RP',

    currency = {
        language = 'en-US',
        currency = 'USD'
    },

    cancelProgress = {
        command = "cancel",
        key = "DELETE",
        description = "Cancel Action"
    },

    seatbeltWarnSound = true,
    seatbeltWarnVolume = 1.0,

    defaultSettings = {
        statusType = 'modern', -- modern / classic
        statusStyle = 1, -- 1 to 7
        statusColors = {}, -- dont touch
        topInfosStyle = 1, -- 1 to 3
        carhudStyle = 1, -- 1 to 5
        progressStyle = 1, -- 1 to 2
        speedType = 'mph', -- kmh / mph
        mapStyle = 'square', -- circle / square
        mapVisibility = 'always', -- always / onlyInVehicle
        statusSize = 100,
        carhudSize = 100,
        minimapX = 0,
        cinematic = false,
        compassColor = {
            primary = '#FFFFFF',
            secondary = '#f6ff00'
        }
    },

    status = {
        {
            name = 'mic',
            icon = 'mic',
            label = 'Mic',
            value = 66,
            rangeLabel = 'Normal',
            color = 'white'
        },
        {
            name = 'health',
            icon = 'health',
            label = 'Health',
            value = 100,
            color = 'red'
        },
        {
            name = 'armor',
            icon = 'armor',
            label = 'Armor',
            value = 0,
            color = 'darkblue'
        },
        {
            name = 'hunger',
            icon = 'hunger',
            label = 'Hunger',
            value = 50,
            color = 'yellow'
        },
        {
            name = 'thirst',
            icon = 'thirst',
            label = 'Thirst',
            value = 50,
            color = 'lightblue'
        },
        {
            name = 'stamina',
            icon = 'stamina',
            label = 'Stamina',
            value = 50,
            color = 'lightgreen'
        },
        {
            name = 'stress',
            icon = 'stress',
            label = 'Stress',
            value = 50,
            color = 'brown'
        }
    },

    topInfos = {
        {
            id = 'playerCount',
            icon = 'playerCount',
            color = 'theme',
            label = 'Server Online',
            value = '347',
            row = 1
        },
        {
            id = 'time',
            icon = 'time',
            color = 'theme',
            label = 'Server Time',
            value = '19 =05'
        },
        {
            id = 'job',
            icon = 'job',
            color = 'theme',
            label = 'Job',
            value = 'Police Officer',
            row = 1
        },
        {
            id = 'fullname',
            icon = 'fullname',
            color = 'theme',
            label = 'Fullname',
            value = 'Erza Baba',
            secondValue = '(252)',
            row = 1
        },
        {
            id = 'cash',
            icon = 'cash',
            color = 'cash',
            label = 'Cash',
            value = '31000',
            money = true,
            row = 2
        },
        {
            id = 'bank',
            icon = 'bank',
            color = 'bank',
            label = 'Bank',
            value = '62000',
            money = true,
            row = 2
        }
    },

    colors = {
        theme = {
            primary = '#ABEF1B',
            secondary = '#219510'
        },
        cash = {
            primary = '#58FF69',
            secondary = '#10952D'
        },
        bank = {
            primary = '#1AE89E',
            secondary = '#10955D'
        },
        purple = {
            primary = '#B04AFF',
            secondary = '#672D95'
        },
        pink = {
            primary = '#FB32FF',
            secondary = '#912E93'
        },
        green = {
            primary = '#78FC4A',
            secondary = '#49962E'
        },
        lightgreen = {
            primary = '#42FF9A',
            secondary = '#28995D'
        },
        white = {
            primary = '#FFFFFF',
            secondary = '#999999'
        },
        red = {
            primary = '#FF4242',
            secondary = '#992828'
        },
        yellow = {
            primary = '#FF7542',
            secondary = '#994628'
        },
        darkblue = {
            primary = '#7C6DFF',
            secondary = '#4A4299'
        },
        lightblue = {
            primary = '#42FFFF',
            secondary = '#289999'
        },
        brown = {
            primary = '#FFAA7A',
            secondary = '#FC8A4A'
        },
        success = {
            primary = '#4BC1FF',
            secondary = '#104159'
        },
        error = {
            primary = '#FF4B4B',
            secondary = '#582020'
        },
        inform = {
            primary = '#FFDB4B',
            secondary = '#595110'
        }
    },

    voiceRanges = {
        ['saltychat'] = {
            ["3.5"] = 25,
            ["8"] = 50,
            ["15"] = 75,
            ["32"] = 100
        },
        ['other'] = {
            ["1.5"] = 33,
            ["3.0"] = 66,
            ["6.0"] = 100
        },
    },

    useStress = true,
    MinimumStress = 50,         -- Minimum Stress Level For Screen Shaking
    MinimumSpeedUnbuckled = 50, -- Going Over This Speed Unbuckled Will Cause Stress
    MinimumSpeed = 100,        -- Going Over This Speed While Buckled Will Cause Stress
    StressChance = 0.1,
    WhitelistedWeaponArmed = { -- Disable showing armed icon from weapons in this table
        [`weapon_petrolcan`] = true,
        [`weapon_hazardcan`] = true,
        [`weapon_fireextinguisher`] = true,
        [`weapon_dagger`] = true,
        [`weapon_bat`] = true,
        [`weapon_bottle`] = true,
        [`weapon_crowbar`] = true,
        [`weapon_flashlight`] = true,
        [`weapon_golfclub`] = true,
        [`weapon_hammer`] = true,
        [`weapon_hatchet`] = true,
        [`weapon_knuckle`] = true,
        [`weapon_knife`] = true,
        [`weapon_machete`] = true,
        [`weapon_switchblade`] = true,
        [`weapon_nightstick`] = true,
        [`weapon_wrench`] = true,
        [`weapon_battleaxe`] = true,
        [`weapon_poolcue`] = true,
        [`weapon_briefcase`] = true,
        [`weapon_briefcase_02`] = true,
        [`weapon_garbagebag`] = true,
        [`weapon_handcuffs`] = true,
        [`weapon_bread`] = true,
        [`weapon_stone_hatchet`] = true,
        [`weapon_grenade`] = true,
        [`weapon_bzgas`] = true,
        [`weapon_molotov`] = true,
        [`weapon_stickybomb`] = true,
        [`weapon_proxmine`] = true,
        [`weapon_snowball`] = true,
        [`weapon_pipebomb`] = true,
        [`weapon_ball`] = true,
        [`weapon_smokegrenade`] = true,
        [`weapon_flare`] = true
    },

    WhitelistedWeaponStress = { -- Disable gaining stress from weapons in this table
        [`weapon_petrolcan`] = true,
        [`weapon_hazardcan`] = true,
        [`weapon_fireextinguisher`] = true
    },

    VehClassStress = { -- Enable/Disable gaining stress from vehicle classes in this table
        ['0'] = true,         -- Compacts
        ['1'] = true,         -- Sedans
        ['2'] = true,         -- SUVs
        ['3'] = true,         -- Coupes
        ['4'] = true,         -- Muscle
        ['5'] = true,         -- Sports Classics
        ['6'] = true,         -- Sports
        ['7'] = true,         -- Super
        ['8'] = true,         -- Motorcycles
        ['9'] = true,         -- Off Road
        ['10'] = true,        -- Industrial
        ['11'] = true,        -- Utility
        ['12'] = true,        -- Vans
        ['13'] = false,       -- Cycles
        ['14'] = false,       -- Boats
        ['15'] = false,       -- Helicopters
        ['16'] = false,       -- Planes
        ['18'] = false,       -- Emergency
        ['19'] = false,       -- Military
        ['20'] = false,       -- Commercial
        ['21'] = false        -- Trains
    },

    WhitelistedVehicles = { -- Disable gaining stress from speeding in any vehicle in this table
        --[`adder`] = true
    },

    WhitelistedJobs = { -- Disable stress completely for players with matching job or job type
        ['leo'] = true,
        ['ambulance'] = true
    },

    Intensity = {
        ['blur'] = {
            [1] = {
                min = 50,
                max = 60,
                intensity = 1500,
            },
            [2] = {
                min = 60,
                max = 70,
                intensity = 2000,
            },
            [3] = {
                min = 70,
                max = 80,
                intensity = 2500,
            },
            [4] = {
                min = 80,
                max = 90,
                intensity = 2700,
            },
            [5] = {
                min = 90,
                max = 100,
                intensity = 3000,
            },
        }
    },

    EffectInterval = {
        [1] = {
            min = 50,
            max = 60,
            timeout = math.random(50000, 60000)
        },
        [2] = {
            min = 60,
            max = 70,
            timeout = math.random(40000, 50000)
        },
        [3] = {
            min = 70,
            max = 80,
            timeout = math.random(30000, 40000)
        },
        [4] = {
            min = 80,
            max = 90,
            timeout = math.random(20000, 30000)
        },
        [5] = {
            min = 90,
            max = 100,
            timeout = math.random(15000, 20000)
        }
    },

    locale = 'en',
    locales = {
        ['en'] = {
            toggleseatbelt = 'Toggle Seatbelt',
            location = 'Location',
            time = 'Time',
            id = 'ID',
            kmh = 'KM/H',
            mph = 'MPH',
            inform = 'Information',
            error = 'Error',
            success = 'Success',
            status = 'STATUS TYPE',
            statusColor = 'STATUS COLOR',
            speedometer = 'SPEEDOMETER TYPE',
            hudSettings = 'HUD SETTINGS',
            exit = 'EXIT',
            classicHud = 'Classic Status',
            classicHudDesc =
                'Lorem ipsum dolor sit amet consectetur. Interdum amet odioegestas hac porta netus pretium eu.',
            modernHud = 'Modern Status',
            modernHudDesc =
                'Lorem ipsum dolor sit amet consectetur. Interdum amet odioegestas hac porta netus pretium eu.',
            statusColorHeader = 'Status Color',
            statusColorDesc =
                'Lorem ipsum dolor sit amet consectetur. Interdum amet odioegestas hac porta netus pretium eu.',
            speedometerHeader = 'Speedometer',
            speedometerDesc =
                'Lorem ipsum dolor sit amet consectetur. Interdum amet odioegestas hac porta netus pretium eu.',
            hudSettingsHeader = 'Hud Settings',
            hudSettingsDesc =
                'Lorem ipsum dolor sit amet consectetur. Interdum amet odioegestas hac porta netus pretium eu.',
            music = 'Music',
            playlists = 'Playlists',
            favorites = 'Favorites',
            createPlaylist = 'Create Playlist',
            lastPlaylist = 'Last Playlist',
            playlist = 'Playlist',
            playlistName = 'Playlist Name',
            playlistPhoto = 'Playlist Photo',
            cancel = 'Cancel',
            addMusic = 'Add Music',
            musicLink = 'Music Link',
            editPlaylist = 'Edit Playlist',
            favoriteMusics = 'Favorited Musics',
            noActiveMusic = 'There is no active music',
            enterMusicLink = 'Enter YouTube link...',
            statusKey = 'Status',
            primary = 'Primary',
            secondary = 'Secondary',
            topInfo = 'Top Info',
            speedType = 'Speed Type',
            mapStyle = 'Map Style',
            circle = 'Circle',
            square = 'Square',
            mapVisibility = 'Map Visibility',
            statusSize = 'Status Size',
            carhudSize = 'Carhud Size',
            choose = 'Choose',
            onlyInVehicle = 'Only in Vehicle',
            always = 'Always',
            on = 'On',
            off = 'Off',
            moveIt = 'Move It',
            defaultAll = 'Default All',
            progressStyle = 'Progress Style',
            compassColor = 'Compass Color',
            minimapX = 'Minimap Border X Offset'
        }
    }
}

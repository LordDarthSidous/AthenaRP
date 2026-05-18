fx_version 'cerulean'
game 'gta5'
author 'Lord Darth Sidious'
lua54 'yes'

client_script 'client/*.lua'
server_script 'server.lua'

shared_scripts {
    'shared/cfg.lua',
    'shared/utils.lua',
    'shared/shared.lua',
}

ui_page 'web/dist/index.html'
files {
    'web/dist/*',
    'web/dist/**/*',
}

escrow_ignore {
    'client/seatbelt.lua',
    'client/stress.lua',
    'client/progress.lua',
    'shared/*.lua',
}
dependency '/assetpacks'
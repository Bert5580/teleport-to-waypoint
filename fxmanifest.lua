-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'sfx_ttwp - cleaned by ChatGPT'
description 'Teleport-To-Waypoint (standalone) with cooldowns, safety checks, and vehicle support.'
version '1.1.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

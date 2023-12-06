fx_version 'cerulean'
game 'gta5'

description 'Jens-CarRent'
version '1.0.0'

shared_scripts { 
	'@qb-core/import.lua',
	'config.lua'
}

client_scripts {
    'client.lua',
    'gui.lua',
} 

server_script 'server.lua'


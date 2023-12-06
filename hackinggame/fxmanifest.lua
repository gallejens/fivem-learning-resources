fx_version 'cerulean'
game 'gta5'

description 'Jens-HackingGame'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts { 
	'@qb-core/import.lua',
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

files {
    'html/*'
}

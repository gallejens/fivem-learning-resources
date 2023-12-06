fx_version 'cerulean'
game 'gta5'

description 'Jens-HumaneLabs'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts { 
	'@qb-core/import.lua',
	'config.lua'
}

client_scripts {
    'client/*'
}

server_scripts {
    'server/*'
}

files {
    'html/*'
}

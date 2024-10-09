fx_version 'cerulean'

Description 'nw-containermission created by nowiex'

game 'gta5'
version '1.0.0'

shared_script {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client/main.lua',
}

server_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'server/main.lua',
}

escrow_ignore {
	'config.lua',
}

lua54 'yes'
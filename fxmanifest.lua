

fx_version 'cerulean'; game 'gta5'; lua54 'yes'

client_script {'client/*.lua'}
server_script {'server/*.lua', '@oxmysql/lib/MySQL.lua'}
shared_script {'shared/*.lua', '@ox_lib/init.lua'}

-- ui_page 'http://localhost:3000/'
ui_page 'dist/index.html'
files {'dist/index.html', 'dist/assets/**'}

escrow_ignore {
    'server/*.lua',
    'shared/*.lua'
}
dependency '/assetpacks'

server_exports {
    "getCountOnDuty"
}
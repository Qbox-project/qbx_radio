fx_version 'cerulean'
game 'gta5'

description 'QBX-Radio'
repository 'https://github.com/Qbox-project/qbx_radio'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/import.lua',
    '@qbx_core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

client_script 'client.lua'

server_script 'server.lua'

modules {
    'qbx_core:playerdata',
    'qbx_core:utils',
}

ui_page('html/ui.html')

files {'html/ui.html', 'html/js/script.js', 'html/css/style.css', 'html/img/radio.png'}

lua54 'yes'
use_experimental_fxv2_oal 'yes'

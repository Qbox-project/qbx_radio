fx_version 'cerulean'
game 'gta5'

description 'qbx_radio'
repository 'https://github.com/Qbox-project/qbx_radio'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/utils.lua',
    '@qbx_core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
}

server_script 'server/main.lua'

ui_page('html/ui.html')

files {
    'html/ui.html',
    'html/js/script.js',
    'html/css/style.css',
    'html/img/radio.png',
    'config/shared.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'

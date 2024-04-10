fx_version 'cerulean'
game 'gta5'
version '1.0.0'

description 'qbx_radio'
repository 'https://github.com/Qbox-project/qbx_radio'

ox_lib 'locale'
shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
}

server_script 'server/main.lua'

ui_page "html/index.html"

files {
    'html/index.html',
    'html/js/script.js',
    'html/css/style.css',
    'html/img/radio.png',
    'config/shared.lua',
    'config/client.lua',
    'locales/*.json'
}

dependency 'pma-voice'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

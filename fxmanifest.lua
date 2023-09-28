fx_version 'cerulean'
game 'gta5'

description 'QB-Radio'
version '1.0.0'

shared_scripts {
  '@ox_lib/init.lua',
  '@qbx_core/imports.lua',
  'config.lua'
}

client_scripts {
  'client.lua'
}

modules {
  'qbx_core:playerdata',
  'qbx_core:utils',
}

server_script 'server.lua'

ui_page('html/ui.html')

files {'html/ui.html', 'html/js/script.js', 'html/css/style.css', 'html/img/radio.png'}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
awful = require 'awful'

hotkeys =
  global: {}

modkey = 'Mod4'
mod = {modkey, nil}
modShift = {modkey, 'Shift'}
enter = 'Return'

spawn = awful.util.spawn
terminal = 'urxvt'
filemanager = 'thunar'
top = terminal .. ' -e htop'

killClientUnderMouse = ->
  hoveredOverClient = mouse.object_under_pointer!
  hoveredOverClient\kill!
  return

globalHotkeys = {
  awful.key modShift, 'r', awesome.restart
  awful.key mod, enter, -> spawn terminal
  awful.key modShift, 'q', awesome.quit
  awful.key mod, 'e', -> spawn filemanager
  awful.key mod, 'c', killClientUnderMouse
  awful.key mod, 't', -> spawn top
  awful.key mod, 'u', -> spawn terminal .. ' -hold -e packer -Syyu'
  awful.key mod, 'a', -> spawn alsaMixer
  awful.key modShift, 's', -> spawn shutdownCommand
}

for k, v in pairs globalHotkeys
	hotkeys.global = awful.util.table.join hotkeys.global, v

return hotkeys
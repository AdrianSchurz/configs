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
browser = 'chromium'
guiEditor = 'atom'
guiEditorAlt = 'subl'
top = terminal .. ' -e htop'
shutdown = 'sudo shutdown 0'
pulseAudioControl = 'env GTK_THEME=Adwaita pavucontrol'
update = terminal .. ' -hold -e packer -Syyu'
gitGUILightTheme = 'env GTK_THEME=Adwaita gitg'
lockWorkstation = 'xscreensaver-command --lock'

killClientUnderMouse = ->
  hoveredOverClient = mouse.object_under_pointer!
  hoveredOverClient\kill!
  return

cycleLayouts = -> awful.layout.inc clientLayouts, 1

globalHotkeys = {
  awful.key modShift, 'r',    awesome.restart
  awful.key mod,      enter,  -> spawn terminal
  awful.key modShift, 'q',    awesome.quit
  awful.key mod,      'e',    -> spawn filemanager
  awful.key mod,      'c',    killClientUnderMouse
  awful.key mod,      't',    -> spawn top
  awful.key mod,      'u',    -> spawn update
  awful.key mod,      'a',    -> spawn pulseAudioControl
  awful.key modShift, 's',    -> spawn shutdown
  awful.key mod,      'g',    -> spawn gitGUILightTheme
  awful.key mod,      'w',    -> spawn browser
  awful.key mod,      'q',    -> spawn guiEditor
  awful.key modShift, 'q',    -> spawn guiEditorAlt
  awful.key mod,      'Tab',  cycleLayouts
  awful.key mod,      'l',    -> spawn lockWorkstation
}

for k, v in pairs globalHotkeys
	hotkeys.global = awful.util.table.join hotkeys.global, v

return hotkeys

awful = require 'awful'

hotkeys =
  global: {}

modkey = 'Mod4'
mod = {modkey, nil}
modShift = {modkey, 'Shift'}
enter = 'Return'

spawn = awful.util.spawn
terminal = 'urxvt'
fileManager = 'pcmanfm'
fileManagerAlt = 'thunar'
browser = 'env GTK2_RC_FILES=/usr/share/themes/Crux/gtk-2.0/gtkrc firejail opera'
browserAlt = 'firejail chromium'
guiEditor = 'atom'
guiEditorAlt = 'subl'
top = terminal .. ' -e htop'
shutdown = 'sudo shutdown 0'
pulseAudioControl = 'env GTK_THEME=Crux pavucontrol'
update = terminal .. ' -hold -e packer -Syyu'
startFeedAggregator = terminal .. ' -e newsbeuter'
gitGUILightTheme = 'env GTK_THEME=Crux gitg'
lockWorkstation = 'xscreensaver-command --lock'

killClientUnderMouse = ->
  hoveredOverClient = mouse.object_under_pointer!
  hoveredOverClient\kill!
  return

globalHotkeys = {
  awful.key modShift, 'r',    awesome.restart
  awful.key mod,      enter,  -> spawn terminal
  awful.key modShift, 'q',    awesome.quit
  awful.key mod,      'e',    -> spawn fileManager
  awful.key modShift, 'e',    -> spawn fileManagerAlt
  awful.key mod,      'c',    killClientUnderMouse
  awful.key mod,      't',    -> spawn top
  awful.key mod,      'u',    -> spawn update
  awful.key mod,      'a',    -> spawn pulseAudioControl
  awful.key modShift, 's',    -> spawn shutdown
  awful.key mod,      'g',    -> spawn gitGUILightTheme
  awful.key mod,      'w',    -> spawn browser
  awful.key modShift, 'w',    -> spawn browserAlt     
  awful.key mod,      'q',    -> spawn guiEditor
  awful.key modShift, 'q',    -> spawn guiEditorAlt
  awful.key mod,      'l',    -> spawn lockWorkstation
  awful.key mod,      'v',    -> spawn startFeedAggregator
}

for k, v in pairs globalHotkeys
	hotkeys.global = awful.util.table.join hotkeys.global, v

return hotkeys

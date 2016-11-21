awful = require 'awful'

hotkeys =
  global: {}

modkey = 'Mod4'
mod = {modkey, nil}
modShift = {modkey, 'Shift'}
enter = 'Return'
spawn = awful.util.spawn

gtkTheme = 'Crux'
specifyGTK2Theme = 'env GTK2_RC_FILES=/usr/share/themes/' .. gtkTheme .. '/gtk-2.0/gtkrc '
specifyGTK3Theme = 'env GTK_THEME=' .. gtkTheme .. ' '

terminal = 'urxvt'
fileManager = 'pcmanfm'
browser = specifyGTK2Theme .. 'firejail opera'
browserAlt = 'firejail chromium'
guiEditor = 'subl3'
top = terminal .. ' -e htop'
shutdown = 'sudo shutdown 0'
pulseAudioControl = specifyGTK3Theme .. 'pavucontrol'
systemUpdate = terminal .. ' -hold -e packer -Syyu'
startFeedAggregator = terminal .. ' -e newsbeuter'
gitGUI = specifyGTK3Theme .. 'gitg'
lockWorkstation = 'xscreensaver-command --lock'
bookmarksGUI = '~/dev/repos/buku_run/buku_run'

killClientUnderMouse = ->
  hoveredOverClient = mouse.object_under_pointer!
  hoveredOverClient\kill!
  return

globalHotkeys = {
  awful.key modShift, 'r',    awesome.restart
  awful.key mod,      enter,  -> spawn terminal
  awful.key modShift, 'q',    awesome.quit
  awful.key mod,      'e',    -> spawn fileManager
  awful.key mod,      'c',    killClientUnderMouse
  awful.key mod,      't',    -> spawn top
  awful.key mod,      'u',    -> spawn systemUpdate
  awful.key mod,      'a',    -> spawn pulseAudioControl
  awful.key modShift, 's',    -> spawn shutdown
  awful.key mod,      'g',    -> spawn gitGUI
  awful.key mod,      'w',    -> spawn browser
  awful.key modShift, 'w',    -> spawn browserAlt     
  awful.key mod,      'q',    -> spawn guiEditor
  awful.key mod,      'l',    -> spawn lockWorkstation
  awful.key mod,      'v',    -> spawn startFeedAggregator
  awful.key mod,      'b',    -> spawn bookmarksGUI
}

for k, v in pairs globalHotkeys
	hotkeys.global = awful.util.table.join hotkeys.global, v

return hotkeys

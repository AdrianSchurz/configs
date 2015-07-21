inspect = require 'inspect'
awful = require 'awful'
gears = require 'gears'

require 'logging.file'
logger = logging.file '/home/ulmeyda/.config/awesome/rc.lua.log'

logPreviousStartupErrors = ->
  if awesome.startup_errors
      logger\error 'error during previous startup:'
      logger\error awesome.startup_errors

--logPreviousStartupErrors!

wallpaper = '/home/ulmeyda/media/wallpapers/catbug_wallpaper.png'
gears.wallpaper.maximized wallpaper, 1, true
inspect = require 'inspect'
require 'logging.file'

awful = require 'awful'
gears = require 'gears'                   
-- wibox = require 'wibox'
-- beautiful = require 'beautiful'
-- vicious = require 'vicious'
-- naughty = require 'naughty'
-- lain = require 'lain'
-- uzful = require 'uzful'
-- filesystem = require 'lfs'
-- awful.rules = require 'awful.rules'
-- awmodoro = require 'awmodoro'
-- alttab = require 'awesome_alttab'
-- _ = require 'underscore'
-- require 'awful.autofocus'

logPath = '/home/ulmeyda/.config/awesome/rc.lua.log'
--logger = logging.file logPath

logPreviousStartupErrors = ->
  if awesome.startup_errors
      logger\error 'error during previous startup:'
      logger\error awesome.startup_errors

--logPreviousStartupErrors!

wallpaper = '/home/ulmeyda/media/wallpapers/catbug_wallpaper.png'
gears.wallpaper.maximized wallpaper, 1, true
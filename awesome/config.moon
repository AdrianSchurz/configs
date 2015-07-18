require 'logging.file'
inspect = require 'inspect'
logger = logging.file '/home/ulmeyda/.config/awesome/rc.lua.log'
gears = require 'gears'

wallpaper = '/home/ulmeyda/media/wallpapers/catbug_wallpaper.png'
gears.wallpaper.maximized wallpaper, 1, true
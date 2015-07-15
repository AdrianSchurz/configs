require 'logging.file'
inspect = require 'inspect'
gears = require 'gears'

logger = logging.file '/home/ulmeyda/.config/awesome/rc.moon.log'

wallpaper = '/home/ulmeyda/media/wallpapers/catbug_wallpaper.png'
gears.wallpaper.maximized wallpaper, 1, true
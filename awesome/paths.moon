paths = {}

home = os.getenv 'HOME'
paths.wallpapers = home .. '/tag/wallpaper/-/not-used/-/not-processed/@@/'
config = home .. '/.config/awesome'
paths.log = config .. '/'
paths.theme = config .. '/themes/pro-dark/theme.lua'

paths.ambientSounds = home .. '/tag/music/ambient/mp3/@@/'

return paths

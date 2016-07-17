paths = {}

home = os.getenv 'HOME'
paths.wallpapers = home .. '/media/wallpapers/'
config = home .. '/.config/awesome'
paths.log = config .. '/'
paths.theme = config .. '/themes/pro-dark/theme.lua'

return paths

inspect = require 'inspect'
require 'logging.file'

awful = require 'awful'
gears = require 'gears'
uzful = require 'uzful'                
beautiful = require 'beautiful'
filesystem = require 'lfs'
_ = require 'underscore'
wibox = require 'wibox'
-- vicious = require 'vicious'
-- naughty = require 'naughty'
-- lain = require 'lain'
-- awful.rules = require 'awful.rules'
-- awmodoro = require 'awmodoro'
-- alttab = require 'awesome_alttab'
-- require 'awful.autofocus'

home = os.getenv "HOME"
logPath = home .. "/.config/awesome/"
logFileName = "rc.lua.log"
logger = logging.file logPath .. logFileName

logPreviousStartupErrors = ->
  if awesome.startup_errors
      logger\error 'error during previous startup:'
      logger\error awesome.startup_errors

logRuntimeErrors = ->
  doneWithPreviousError = true
  awesome.connect_signal "debug:error", (error) ->
    if not doneWithPreviousError
      return
    else
      doneWithPreviousError = false
      logger\error error
      doneWithPreviousError = true

handleStartupAndRuntimeErrors = ->
  logPreviousStartupErrors!
  logRuntimeErrors!
  return

enableGraphAutoCaching = ->
  uzful.util.patch.vicious!

fixJavaGUI = ->
  awful.util.spawn_with_shell 'wmname LG3D'

disableCursorAnimations = ->
  oldspawn = awful.util.spawn
  awful.util.spawn = (spawnee) ->
    oldspawn(spawnee, false)

setupTheme = ->
  theme = "/usr/share/awesome/themes/pro/themes/pro-dark/theme.lua"
  beautiful.init theme

compileListOfWallpapers = (folder) ->
  listOfWallpapers = {}
  fileNames = filesystem.dir folder --TODO error handling
  for fileName in pairs fileNames
    print fileName
  for fileName in pairs fileNames
    if notJustAFolder fileName
      table.insert listOfWallpapers, fileName
  return listOfWallpapers

chooseRandomly = (aTable, quantity) ->
  if #aTable == 0 or quantity < 1
    return nil
  else
    chosenOnes = {}
    for itemsChosen = 1, quantity
      randomIndex = math.random #aTable
      choice = table.remove aTable, randomIndex
      table.insert chosenOnes, choice
    return chosenOnes

selectWallpapers = (wallpapers, quantity) ->
  return chooseRandomly wallpapers, quantity

setWallpapers = (wallpapers, folder) ->
  for screen = 1, screen.count!
    wallpaper = folder .. wallpapers[screen]
    gears.wallpaper.maximized wallpaper, screen, true

setupWallpapers = ->
  wallpaperFolder = home .. '/media/wallpapers/'
  allWallpapers = compileListOfWallpapers wallpaperFolder
  chosenOnes = selectWallpapers allWallpapers, screen.count!
  setWallpapers chosenOnes, folder

populateLayouts = ->
  tileLayout = awful.layout.suit.tile
  tileTopLayout = awful.layout.suit.tile.top
  layouts = { tileLayout, tileTopLayout }
  return layouts

populateTags = (layouts) ->
  tags = {}
  numberOfTagsPerScreen = 4
  defaultTag = "  "
  createTagList = ->
    tagList = {}
    for index = 1, numberOfTagsPerScreen
      table.insert tagList, defaultTag
    return tagList
  for screen = 1, screen.count!
    tagList = createTagList!
    defaultLayout = layouts[1]
    tags[screen] = awful.tag(tagList, screen, defaultLayout)
  return tags

defaultTags = ->
  tags = {}
  tagsPerScreen = 4
  defaultTag = '  '
  for index = 1, tagsPerScreen
    table.insert tags, defaultTag
  return tags

defineTags = (screen, screenIndex) ->
  tags = defaultTags!
  awful.tag tags, screenIndex, layout

_.each screen, defineTags
-- for every screen, I call awful.tag with a new defaultTagList,
-- the screens index and the default layout
-- setupTagLists = ->
--   tagList =
--     buttons: {}

--   attachDefaultTagList = (screen, screenIndex) ->
--     tagList[screenIndex] = awful.widget.taglist screenIndex, awful.widget.taglist.filter.all, tagList.buttons)
--   defaultTags = ->
--     tags = {}
--     numberOfTagsPerScreen = 4
--     defaultTag = '  '
--     table.
--   _.each screen, attachDefaultTagList

--entry point
handleStartupAndRuntimeErrors!
enableGraphAutoCaching!
fixJavaGUI!
disableCursorAnimations!
setupTheme!
setupWallpapers!
layouts = populateLayouts!
defaultLayout = layouts[1]
--tags = setupTagLists defaultLayout

wallpaper = '/home/ulmeyda/media/wallpapers/catbug_wallpaper.png'
gears.wallpaper.maximized wallpaper, 1, true

tags =
  buttons: {}
screenIndex = 1
tagListConstructor = awful.widget.taglist
filterAll = awful.widget.taglist.filter.all
buttons = tags.buttons
taglist = tagListConstructor screenIndex, filterAll, buttons
table.insert tags, taglist
print inspect wibox
left_layout = wibox.layout.fixed.horizontal!
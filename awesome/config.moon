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

isJpgOrPng = (fileName) ->
  if fileName == '.' or fileName == '..' --TODO
    return false
  else
    return true

compileListOfWallpapers = (folder) ->
  listOfWallpapers = {}
  for fileName in filesystem.dir folder
    if isJpgOrPng fileName
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
  setWallpapers chosenOnes, wallpaperFolder

setupPanel = ->
  widgetBoxes = {}
  for screenIndex = 1, screen.count!
    widgetBoxes[screenIndex] = {}
    widgetBoxOptions =
      position: 'top'
      screen: screenIndex
      height: '22'
    widgetBox = widgetBoxes[screenIndex]
    widgetBox = awful.wibox widgetBoxOptions
    widgetBox\set_bg beautiful.panel

--entry point
handleStartupAndRuntimeErrors!
enableGraphAutoCaching!
fixJavaGUI!
disableCursorAnimations!

setupWallpapers!
setupTheme!
setupPanel!
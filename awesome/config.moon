inspect = require 'inspect'
require 'logging.file'

awful = require 'awful'
gears = require 'gears'
uzful = require 'uzful'
beautiful = require 'beautiful'
filesystem = require 'lfs'
_ = require 'underscore'
wibox = require 'wibox'
lain = require 'lain'
-- vicious = require 'vicious'
-- naughty = require 'naughty'
-- awful.rules = require 'awful.rules'
-- awmodoro = require 'awmodoro'
-- alttab = require 'awesome_alttab'
-- require 'awful.autofocus'

home = os.getenv "HOME"
logPath = home .. "/.config/awesome/"
logFileName = "rc.lua.log"
logger = logging.file logPath .. logFileName

widgetBoxes = {}

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
  widgetBox = {}
  widgetBoxOptions =
    position: 'top'
    screen: screenIndex
    height: '22'
  widgetBox = awful.wibox widgetBoxOptions
  widgetBox\set_bg beautiful.panel
  return widgetBox

createWidgetboxes = ->
  for screenIndex = 1, screen.count!
    table.insert widgetBoxes, setupPanel!

createCpuGraph = ->
  cpuGraphOptions =
    fgcolor: '#D0752A'
    bgcolor: beautiful.bg_systray
    load:
      interval: 20
      text: ' <span size="x-small"><span color="#666666">$1</span>' .. '  <span color="#9A9A9A">$2</span>' .. '  <span color="#DDDDDD">$3</span></span>'
    big:
      width: 400
      height: 100
      interval: 1
    small:
      width: 42
      height: beautiful.menu_height
      interval: 1
  cpuGraph = uzful.widget.cpugraphs cpuGraphOptions
  return cpuGraph

createCpuWidget = (graph) ->
  cpuWidgetOptions =
    widget: graph.big.layout
    position: 'top'
    align: 'right'
    width: graph.big.width
    height: graph.big.height
  cpuWidget = uzful.widget.infobox cpuWidgetOptions
  return nil

memoryWidget = {}
cpuGraph = {}
addToLayouts = ->
  rightLayout = wibox.layout.fixed.horizontal!
  rightLayout\add cpuGraph.small.widget

  widget_display_l = wibox.widget.imagebox!
  widget_display_l\set_image beautiful.widget_display_l
  widget_display_r = wibox.widget.imagebox!
  widget_display_r\set_image beautiful.widget_display_r
  rightLayout\add widget_display_l
  rightLayout\add memoryWidget
  rightLayout\add widget_display_r

  layout = wibox.layout.align.horizontal!
  layout\set_right rightLayout
  widgetBoxes[1]\set_widget layout
  return nil

setupCpuGraph = ->
  enableGraphAutoCaching!
  cpuGraph = createCpuGraph!
  createCpuWidget cpuGraph

setupMemoyUsage = ->
  markup = lain.util.markup
  options =
    settings: ->
    --widget\set_markup space3 .. roundToDecimal(mem_now.used/1000, 1) .. "G" .. markup.font(myFont, " ")
  memoryUsage = lain.widgets.mem options
  widgetBox = wibox.widget.imagebox!
  widgetBox\set_image beautiful.widget_mem
  memoryWidget = wibox.widget.background!
  memoryWidget\set_widget memoryInUsage
  memoryWidget\set_bgimage beautiful.widget_display


setupPanels = ->
  createWidgetboxes!
  setupCpuGraph!
  setupMemoyUsage!
  addToLayouts!

--entry point
handleStartupAndRuntimeErrors!
fixJavaGUI!
disableCursorAnimations!

setupWallpapers!
setupTheme!
setupPanels!
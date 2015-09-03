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
paths = require 'paths'
-- awful.rules = require 'awful.rules'
-- vicious = require 'vicious'
-- naughty = require 'naughty'
-- lain = require 'lain'
-- awful.rules = require 'awful.rules'
-- awmodoro = require 'awmodoro'
-- alttab = require 'awesome_alttab'
-- require 'awful.autofocus'

logPath = paths.log
logFileName = "rc.lua.log"
logger = logging.file logPath .. logFileName

widgetBoxes = {}

oldPrint = print
print = (printee) ->
  oldPrint inspect printee


logPreviousStartupErrors = ->
  if awesome.startup_errors
      logger\error 'error during previous startup:'
      logger\error awesome.startup_errors
  return

logRuntimeErrors = ->
  doneWithPreviousError = true
  awesome.connect_signal "debug:error", (error) ->
    if not doneWithPreviousError
      return
    else
      doneWithPreviousError = false
      logger\error error
      doneWithPreviousError = true
  return

handleStartupAndRuntimeErrors = ->
  logPreviousStartupErrors!
  logRuntimeErrors!
  return

enableGraphAutoCaching = ->
  uzful.util.patch.vicious!
  return

fixJavaGUI = ->
  awful.util.spawn_with_shell 'wmname LG3D'
  return

disableCursorAnimations = ->
  oldspawn = awful.util.spawn
  awful.util.spawn = (spawnee) ->
    oldspawn(spawnee, false)
  return

setUpTheme = ->
  beautiful.init paths.theme
  return

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
    return
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
  return

setUpWallpapers = ->
  wallpaperFolder = paths.wallpapers
  allWallpapers = compileListOfWallpapers wallpaperFolder
  chosenOnes = selectWallpapers allWallpapers, screen.count!
  setWallpapers chosenOnes, wallpaperFolder
  return

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
    table.insert widgetBoxes, setUpPanel screenIndex
  return

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
  return

memoryWidget = {}
cpuGraph = {}
addToLayouts = ->
  rightLayout = wibox.layout.fixed.horizontal!
  rightLayout\add cpuGraph.small.widget

  widget_display_l = wibox.widget.imagebox!
  widget_display_l\set_image beautiful.widget_display_l
  widget_display_r = wibox.widget.imagebox!
  widget_display_r\set_image beautiful.widget_display_r
  widget_display_c = wibox.widget.imagebox!
  widget_display_c\set_image beautiful.widget_display_c
  
  rightLayout\add widget_display_l
  rightLayout\add memoryWidget
  rightLayout\add widget_display_c

  rightLayout\add dateWidget

  rightLayout\add widget_display_r

  layout = wibox.layout.align.horizontal!
  layout\set_right rightLayout
  widgetBoxes[1]\set_widget layout
  return

onMouseLeave = (widget, action) ->
  mouseLeaveSignal = 'mouse::leave'
  widget\connect_signal mouseLeaveSignal, action

onMouseEnter = (widget, action) ->
  mouseEnterSignal = 'mouse::enter'
  widget\connect_signal mouseEnterSignal, action

setUpDetailedGraphOnHover = (graph) ->
  showDetailedGraph = ->
    cpuWidget\update!
    cpuWidget\show!
    return
  onMouseEnter graph, showDetailedGraph

  hideDetailedGraph = cpuWidget.hide
  onMouseLeave graph, hideDetailedGraph

setUpCpuGraph = ->
  enableGraphAutoCaching!
  cpuGraph = createCpuGraph!
  createCpuWidget cpuGraph
  setUpDetailedGraphOnHover cpuGraph.small.widget 
  return

setUpMemoryUsage = ->
  roundToOneDecimal = (number) ->
    oneOrderOfMagnitude = 10
    scaledUp = number * oneOrderOfMagnitude + 0.5
    rounded = math.floor scaledUp
    scaledDownAgain = rounded / oneOrderOfMagnitude
    return scaledDownAgain
  options =
    settings: ->
      memoryScaledToGB = mem_now.used/1000
      memoryRounded = roundToOneDecimal memoryScaledToGB
      memoryAsDisplayed = memoryRounded .. "G"
      widget\set_markup memoryAsDisplayed

  memoryUsage = lain.widgets.mem options
  memoryWidget = wibox.widget.background!
  memoryWidget\set_widget memoryUsage
  memoryWidget\set_bgimage beautiful.widget_display
  return


switchTimeDateOnHover = (clock, calendar) ->
  showDate = ->
    dateWidget\set_widget calendar
    return
  onMouseEnter dateWidget, showDate
  showTime = ->
    dateWidget\set_widget clock
    return
  onMouseLeave dateWidget, showTime


setUpDate = ->
  hoursAndMinutes = '%H:%M'
  clock = awful.widget.textclock hoursAndMinutes
  monthsAndDays = '%m-%d'
  calendar = awful.widget.textclock monthsAndDays

  dateWidget = wibox.widget.background!
  dateWidget\set_widget clock
  dateWidget\set_bgimage beautiful.widget_display
  switchTimeDateOnHover clock, calendar
  return

setUpTasklist = ->
tasklist[1] = awful.widget.tasklist 1, awful.widget.tasklist.filter.currenttags, {}

setUpPanels = ->
  createWidgetboxes!
  setUpCpuGraph!
  setUpMemoryUsage!
  setUpDate!
  setUpTasklist!
  addToLayouts!
  return

--entry point
handleStartupAndRuntimeErrors!
fixJavaGUI!
disableCursorAnimations!

setUpWallpapers!
setUpTheme!
setUpPanels!

modkey = 'Mod4'
terminal = 'urxvt'
spawn = awful.util.spawn

mod = {modkey, nil}
modShift = {modkey, 'Shift'}
enter = 'Return'
runTerminal = ->
  return
hotkeyTerminal = awful.key mod, enter, runTerminal
hotkeyRestartAwesome = awful.key modShift, 'r', awesome.restart

globalkeys = awful.util.table.join hotkeyTerminal, hotkeyRestartAwesome

root.keys globalkeys
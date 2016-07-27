inspect = require 'inspect'
require 'logging.file'

awful = require 'awful'
gears = require 'gears'
uzful = require 'uzful'
beautiful = require 'beautiful'
filesystem = require 'lfs'
wibox = require 'wibox'
lain = require 'lain'
paths = require 'paths'
awful.rules = require 'awful.rules'
awmodoro = require 'awmodoro'
require 'awful.autofocus'
hotkeys = require 'hotkeys'
mpd = require 'mpd'

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

setUpLogging = ->
  logPath = paths.log
  logFileName = "rc.lua.log"
  logger = logging.file logPath .. logFileName

logErrors = ->
  setUpLogging!
  logPreviousStartupErrors!
  logRuntimeErrors!
  return

logErrors!

fixJavaGUI = ->
  awful.util.spawn_with_shell 'wmname LG3D'
  return

fixJavaGUI!

disableCursorAnimations = ->
  oldspawn = awful.util.spawn
  awful.util.spawn = (spawnee) ->
    oldspawn(spawnee, false)
  return

disableCursorAnimations!

initializeRNG = ->
  math.randomseed os.time!
  return

initializeRNG!

setUpTheme = ->
  beautiful.init paths.theme
  return

setUpTheme!

setWallpapers = (wallpapers, folder) ->
  for screen = 1, screen.count!
    wallpaper = folder .. wallpapers[screen]
    gears.wallpaper.maximized wallpaper, screen, true
  return

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

isNotDirectory = (fileName) ->
  return not (fileName == '.' or fileName == '..')

compileListOfWallpapers = ->
  listOfWallpapers = {}
  path = paths.wallpapers
  for fileName in filesystem.dir path
    fileAttributes = filesystem.attributes path .. fileName
    if fileAttributes.mode == 'file'
      table.insert listOfWallpapers, fileName
  return listOfWallpapers

setUpWallpapers = ->
  wallpaperFolder = paths.wallpapers
  allWallpapers = compileListOfWallpapers!
  chosenOnes = selectWallpapers allWallpapers, screen.count!
  setWallpapers chosenOnes, wallpaperFolder
  return

setUpWallpapers!

musicPlayer ={}
panels = {}
tagPanel = {}
taskbar = {}
memoryUsage = {}
cpuGraph = {}
cpuWidget = {}
dateWidget = {}
promptWidget = {}
clientLayouts = {}
pomodoro = {}
sysTray =  {}

setupMusicplayer = ->
  musicPlayer = mpd\connect!
  musicPlayer\clear!

  defaultAmbientFile = 'tng-bridge.mp4'
  musicPlayer\add paths.ambientSounds .. defaultAmbientFile
  return

setupMusicplayer!

defineClientLayouts = ->
  clientLayouts = {awful.layout.suit.tile, awful.layout.suit.tile.top}
  return

defineClientLayouts!

createCpuGraph = ->
  cpuGraphOptions =
    fgcolor: '#D0752A'
    bgcolor: beautiful.bg_systray
    load:
      interval: 20
      text: '  <span size="x-small"><span color="#666666">$1</span>' ..
            '  <span color="#9A9A9A">$2</span>' ..
            '  <span color="#DDDDDD">$3</span></span>'
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

layoutWidgets = ->
  for screenIndex = 1, screen.count!
    leftPartialLayout = wibox.layout.fixed.horizontal!
    rightPartialLayout = wibox.layout.fixed.horizontal!
    layout = wibox.layout.align.horizontal!

    layout\set_left leftPartialLayout
    layout\set_right rightPartialLayout
    layout\set_middle taskbar[screenIndex]

    memoryWidget = wibox.widget.background!
    memoryWidget\set_widget memoryUsage
    memoryWidget\set_bgimage beautiful.widget_display

    widgetBackgroundLeftEnd = wibox.widget.imagebox!
    widgetBackgroundLeftEnd\set_image beautiful.widget_display_l
    widgetBackgroundRightEnd = wibox.widget.imagebox!
    widgetBackgroundRightEnd\set_image beautiful.widget_display_r
    widgetBackgroundInBetweenWidgets = wibox.widget.imagebox!
    widgetBackgroundInBetweenWidgets\set_image beautiful.widget_display_c

    leftPartialLayout\add tagPanel[screenIndex]

    rightPartialLayout\add promptWidget[screenIndex]
    rightPartialLayout\add cpuGraph.small.widget
    rightPartialLayout\add widgetBackgroundLeftEnd
    rightPartialLayout\add memoryWidget
    rightPartialLayout\add widgetBackgroundInBetweenWidgets
    rightPartialLayout\add dateWidget
    rightPartialLayout\add widgetBackgroundRightEnd

    if screenIndex == 1
      rightPartialLayout\add sysTray

    panels[screenIndex]\set_widget layout
  return

onMouseLeave = (widget, action) ->
  widget\connect_signal 'mouse::leave', action
  return

onMouseEnter = (widget, action) ->
  widget\connect_signal 'mouse::enter', action
  return

setUpDetailedGraphOnHover = (graph) ->
  showDetailedGraph = ->
    cpuWidget\update!
    cpuWidget\show!
    return

  onMouseEnter graph, showDetailedGraph
  hideDetailedGraph = cpuWidget.hide
  onMouseLeave graph, hideDetailedGraph
  return

enableGraphAutoCaching = ->
  uzful.util.patch.vicious!
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
  return

createTaskbar = ->
  for screenIndex = 1, screen.count!
    raiseClientOnClick = awful.button {}, 1, (aClient) ->
      if aClient == client.focus
         aClient.minimized = true
      else
         aClient.minimized = false
         client.focus = aClient
         aClient\raise!
    taskbarButtons = awful.util.table.join raiseClientOnClick
    taskbar[screenIndex] = awful.widget.tasklist screenIndex, awful.widget.tasklist.filter.currenttags, taskbarButtons
  return

numberOfTags = {}
createTags = ->
  numberOfTags = 5
  -- this theme seems to enforce two character tag names
  defaultTagName = "  "
  tagNames =  {}
  for tagIndex = 1, numberOfTags
    tagNames[tagIndex] = defaultTagName
  defaultLayout = clientLayouts[1]
  for screenIndex = 1, screen.count!
    tags = {}
    tagMouseButtons = awful.button {}, 1, awful.tag.viewonly
    tags[screenIndex] = awful.tag tagNames, screenIndex, defaultLayout
    tagPanel[screenIndex]  = awful.widget.taglist screenIndex, awful.widget.taglist.filter.all, tagMouseButtons
  return

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
      return

  memoryUsage = lain.widgets.mem options
  return

setUpCpuGraph = ->
  enableGraphAutoCaching!
  cpuGraph = createCpuGraph!
  createCpuWidget cpuGraph
  setUpDetailedGraphOnHover cpuGraph.small.widget
  return

setUpPomodoro = ->
  widgetOptions =
    screen: 1
    position: 'bottom'
    height: 4
  pomodoroWidget = awful.wibox widgetOptions
  pomodoroWidget.visible = false

  colorGradient =
    type: 'linear'
    from: {0,0}
    to: {pomodoroWidget.width, 0}
    stops: {{0, "#AECF96"},{0.5, "#88A175"},{1, "#FF5656"}}

  options =
    minutes: 25
    do_notify: true
    active_bg_color: '#313131'
    paused_bg_color: '#7746D7'
    fg_color: colorGradient
    width: pomodoroWidget.width
    height: pomodoroWidget.height
    begin_callback: ->
      pomodoroWidget.visible = true
      musicPlayer\play!
      return
    finish_callback: ->
      pomodoroWidget.visible = false
      musicPlayer\stop!
      return
    pause_callback: ->
      musicPlayer\pause!
      return
    resume_callback: ->
      musicPlayer\unpause!
      return

  pomodoro = awmodoro.new options
  pomodoroWidget\set_widget pomodoro

setUpRunCommand = ->
  for screenIndex = 1, screen.count!
    promptWidget[screenIndex] = awful.widget.prompt!

setUpSystray = ->
  sysTray = wibox.widget.systray!

createWidgets = ->
  setUpCpuGraph!
  setUpMemoryUsage!
  setUpDate!
  setUpPomodoro!
  setUpRunCommand!
  setUpSystray!

setUpPanel = (screenIndex) ->
  panel = {}
  options =
    position: 'top'
    screen: screenIndex
    height: '22'
  panel = awful.wibox options
  panel\set_bg beautiful.panel
  return panel

createPanelForEachScreen = ->
  for screenIndex = 1, screen.count!
    table.insert panels, setUpPanel screenIndex
  return

setUpPanels = ->
  createPanelForEachScreen!
  createWidgets!
  createTags!
  createTaskbar!
  layoutWidgets!
  return

setUpPanels!

borderColorWhenFocused = '#D0752A'
borderColorWhenUnfocused = '#343434'

clientHotkeys = {}
clientButtons = {}

defineClientButtons = ->
  modkey = 'Mod4'
  mod = {modkey, nil}

  leftMouseButton = 1
  rightMouseButton = 3
  mouseWheelUp = 5
  mouseWheelDown = 4

  moveClient = awful.button mod, leftMouseButton, ->
    awful.mouse.client.move!
    return
  resizeClient = awful.button mod, rightMouseButton, ->
    awful.mouse.client.resize!
    return
  nextTag = awful.button mod, mouseWheelUp, (tag) ->
    currentScreen = awful.tag.getscreen tag
    awful.tag.viewnext currentScreen
    return
  previousTag = awful.button mod, mouseWheelDown, (tag) ->
    currentScreen = awful.tag.getscreen tag
    awful.tag.viewprev currentScreen
    return

  clientButtons = awful.util.table.join moveClient, resizeClient, nextTag,
    previousTag
  return

defineClientButtons!

defineAwesomeRules = ->
  awful.rules.rules = {}
  matchAllWindows = {}
  applyDefaultPropertiesToAllWindows =
    rule: matchAllWindows
    properties:
      border_width: 1
      border_color: borderColorWhenUnFocused
      focus: awful.client.focus.filter
      size_hints_honor: false
      raise: true
      keys: clientHotkeys
      buttons: clientButtons
  table.insert awful.rules.rules, applyDefaultPropertiesToAllWindows
  return

defineAwesomeRules!

setUpHotkeys = ->
  spawn = awful.util.spawn

  terminal = 'urxvt'
  terminal_retro = 'cool-retro-term'

  modkey = 'Mod4'
  mod = {modkey, nil}
  modShift = {modkey, 'Shift'}

  enter = 'Return'
  leftMouseButton = 1
  rightMouseButton = 2
  mouseWheelUp = 5
  mouseWheelDown = 4

  hotkeyRetroTerminal = awful.key modShift, enter, -> spawn terminal_retro
  cleanForCompletion = (command, cursorPosition, nComp, shell) ->
    term = false
    if command\sub(1,1) == ':'
      term = true
      command = command\sub 2
      cursorPosition = cursorPosition - 1
    command, cursorPosition = awful.completion.shell command, cursorPosition,
      nComp, shell
    if term == true
      command = ':' .. command
      cursorPosition = cursorPosition + 1
    return command, cursorPosition

  promptOptions =
    prompt: '>_ '

  checkForTerminal = (command) ->
    if command\sub(1,1) == ':'
      command = terminal .. ' -e "' .. command\sub(2) .. '"'
    awful.util.spawn command
  cache = awful.util.getdir 'cache'
  historyDirectory = cache .. '/history'
  runCommand = ->
    awful.prompt.run promptOptions, promptWidget[mouse.screen].widget,
      checkForTerminal, cleanForCompletion, historyDirectory
  hotkeyRunCommand = awful.key mod,      'space', runCommand

  hotkeyStartPomodoro = awful.key mod, 'p', pomodoro\toggle
  hotkeyStopPomodoro = awful.key modShift, 'p', pomodoro\finish

  globalkeys = awful.util.table.join hotkeyRunCommand, hotkeyStartPomodoro, hotkeyStopPomodoro

  for tagNumber = 1, numberOfTags
    -- warning: magic number ahead
    theOneMagicNumberToRuleThemAll = 9
    tagIdentifier = '#' .. tagNumber + theOneMagicNumberToRuleThemAll -- magic much?
    showTag = ->
      screen = mouse.screen
      tagOnScreen = awful.tag.gettags screen
      tag = tagOnScreen[tagNumber]
      if tag
        awful.tag.viewonly tag
    hotkeyShowTag = awful.key mod, tagIdentifier, showTag

    sendClientToTag = ->
      if client.focus
        screen = client.focus.screen
        tags = awful.tag.gettags screen
        tag = tags[tagNumber]
        if tag
          awful.client.movetotag tag
    hotkeySendClientToTag = awful.key modShift, tagIdentifier, sendClientToTag
    globalkeys = awful.util.table.join globalkeys, hotkeyShowTag, hotkeySendClientToTag

  root.keys awful.util.table.join globalkeys, hotkeys.global

  wheelUpPreviousTag = awful.button mod, mouseWheelUp, awful.tag.viewnext
  wheelDownNextTag = awful.button mod, mouseWheelDown, awful.tag.viewprev

  buttonsWhenHoveringRootWindow = awful.util.table.join wheelUpPreviousTag, wheelDownNextTag
  root.buttons buttonsWhenHoveringRootWindow

  switchToTagOnClick = awful.button {}, leftMouseButton, awful.tag.viewonly

  tagPanel.buttons = awful.util.table.join switchToTagOnClick
  return

setUpHotkeys!

focusAndHighlightClientUnderMouse = ->
  client.connect_signal 'manage', (aClient, startup) ->
    aClient\connect_signal 'mouse::enter', (anotherClient) ->
      if (awful.layout.get anotherClient.screen ~= awful.layout.suit.magnifier) and (awful.client.focus.filter anotherClient)
        client.focus = anotherClient
      return
    return

  client.connect_signal 'focus', (c) ->
    c.border_color = borderColorWhenFocused
    return

  client.connect_signal 'unfocus', (c) ->
    c.border_color = borderColorWhenUnfocused
    return

focusAndHighlightClientUnderMouse!

local gears      = require('gears')
local awful      = require('awful')
local wibox      = require('wibox')
local beautiful  = require('beautiful')
local vicious    = require('vicious')
local naughty    = require('naughty')
local lain       = require('lain')
local uzful      = require('uzful')
local filesystem = require('lfs')
awful.rules      = require('awful.rules')
local awmodoro   = require('awmodoro')
local alttab     = require('awesome_alttab')
local _          = require('underscore')
local inspect    = require('inspect')
require('awful.autofocus')
require('logging.file')

-- hotkey documentation
---------------------------------------------------
-- mod+e                        filemanager(thunar)
-- mod+w                        browser(chromium)
-- mod+q                        editor(sublime)
-- mod+left drag client         move client
-- mod+right drag client border resize client
-- mod+#                        switch to tag #
-- mod+shift+#                  send client to tag #
-- mod+f                        make client full screen
-- mod+n                        minimize client
-- mod+c                        kill client
-- mod+space                    command prompt; keyword ":" executes command in a terminal
-- mod+shift+r                  restart awesome
-- mod+p                        start/pause/resume pomodoro session of 25 minutes
-- mod+shift+p                  end pomodoro session
---------------------------------------------------

local home   = os.getenv("HOME")
local wallpaperFolder = home .. "/media/wallpapers/"
local logPath = home .. "/.config/awesome/"
local logFileName = "rc.lua.log"
local logger = logging.file(logPath .. logFileName)

logger:info("rc.lua start")

function logPreviousStartupErrors()
  if awesome.startup_errors then
      logger:error('error during previous startup:')
      logger:error(awesome.startup_errors)
  end
end

function logRuntimeErrors()
  local doneWithPreviousError = true
  awesome.connect_signal("debug::error", function(error)
    if not doneWithPreviousError then
      return
    else
      doneWithPreviousError = false
      logger:error(error)
      doneWithPreviousError = true
    end
  end)
end

function enableGraphAutoCaching()
  uzful.util.patch.vicious()
end

function setupTheme()
  local theme = "/usr/share/awesome/themes/pro/themes/pro-dark/theme.lua"
  beautiful.init(theme)
end

function populateLayouts()
  local tileLayout = awful.layout.suit.tile
  local tileTopLayout = awful.layout.suit.tile.top
  local layouts = { tileLayout, tileTopLayout }
  return layouts
end

function populateTags(layouts)
  local tags = {}
  local numberOfTagsPerScreen = 4
  local defaultTag = "  "
  local createTagList = function()
    local tagList = {}
    for tagIndex = 1, numberOfTagsPerScreen do
      tagList[tagIndex] = defaultTag
    end
    return tagList
  end
  for screen = 1, screen.count() do
    local tagList = createTagList()
    local defaultLayout = layouts[1]
    tags[screen] = awful.tag(tagList, screen, defaultLayout)
  end
  return tags
end

function notJustAFolder(fileName)
  local aFolder = false
  if fileName == "." or fileName == ".." then
    aFolder = true
  end
  return not aFolder
end

function compileListOfWallpapers(folder)
  local listOfWallpapers = {}
  local index = 1
  for file in filesystem.dir(folder) do --TODO error handling
    if notJustAFolder(file) then
      listOfWallpapers[index] = file
      index = index + 1
    end
  end
  return listOfWallpapers
end

function tableLength(aTable)
  if aTable[1] == nil then
    return 0
  else
    function mapToOne (entry)
      return 1
    end
    function sum (first, second)
      return first + second
    end
    local oneForEach = _.map(aTable, mapToOne)
    local sumTotal = _.reduce(oneForEach, sum)
    return sumTotal
  end
end

function tableEmpty(aTable)
  return tableLength(aTable) == 0
end

function tableCopy(aTable)
  function mapToItself (entry)
    return entry
  end
  return _.map(aTable, mapToItself)
end

function chooseRandomly(aTable, quantity)
  if aTable[1] == nil or quantity < 1 then
    return nil
  else
    local chosenOnes = {}
    for itemsChosen = 1, quantity do
      local inputLength = tableLength(aTable)
      local randomIndex = math.random(inputLength)
      local choice = table.remove(aTable, randomIndex)
      table.insert(chosenOnes, choice)
    end
    return chosenOnes
  end
end

function selectWallpapers(wallpapers, quantity)
  return chooseRandomly(wallpapers, quantity)
end

function setWallpapers(wallpapers, folder)
  for screen = 1, screen.count() do
      local wallpaper = folder .. wallpapers[screen]
      gears.wallpaper.maximized(wallpaper, screen, true)
  end
end

function setupWallpapers(folder)
  local allWallpapers = compileListOfWallpapers(folder)
  local chosenOnes = selectWallpapers(allWallpapers, screen.count())
  setWallpapers(chosenOnes, folder)
end

function runInTerminalOnKeyword (command)
  local keyword = ":"
  if command:sub(1,1) == keyword then
    command = terminal .. ' -e "' .. command:sub(2) .. '"'
  end
  awful.util.spawn(command)
end

function cleanForCompletion (command, cur_pos, ncomp, shell)
   local term = false
   if command:sub(1,1) == ":" then
      term = true
      command = command:sub(2)
      cur_pos = cur_pos - 1
   end
   command, cur_pos =  awful.completion.shell(command, cur_pos,ncomp,shell)
   if term == true then
      command = ':' .. command
      cur_pos = cur_pos + 1
   end
   return command, cur_pos
end

function roundToDecimal(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function defineSomeMarkupShit()
  markup = lain.util.markup
  space3 = markup.font("Terminus 3", " ")
  space2 = markup.font("Terminus 2", " ")
  vspace1 = '<span font="Terminus 3"> </span>'
  vspace2 = '<span font="Terminus 3">  </span>'
end

function fixJavaGUI()
  awful.util.spawn_with_shell("wmname LG3D")
end

local oldspawn = awful.util.spawn
  awful.util.spawn = function (s)
    oldspawn(s, false)
end

-- entry point
local modkey      = "Mod4"
local terminal    = "urxvt"
local browser     = "chromium"
local filemanager = "thunar"
local sublime     = "subl"
local noise       = "/home/ulmeyda/projects/2397120/noise.sh 25"
local cmdLock     = "xscreensaver-command --lock"
local exec        = function (s) oldspawn(s, false) end
local shexec      = awful.util.spawn_with_shell

logPreviousStartupErrors()
logRuntimeErrors()
enableGraphAutoCaching()
fixJavaGUI()
setupTheme()
setupWallpapers(wallpaperFolder)
local layouts = populateLayouts()
local tags = populateTags(layouts)

defineSomeMarkupShit()

clockgf = beautiful.clockgf

-- widgets
infoBox = { cpu = {} }

pomowibox = awful.wibox({ position = "bottom", screen = 1, height=4})
pomowibox.visible = false
local pomodoro = awmodoro.new({
    minutes             = 25,
    do_notify           = true,
    active_bg_color     = '#313131',
    paused_bg_color     = '#7746D7',
    fg_color            = {type = "linear", from = {0,0}, to = {pomowibox.width, 0}, stops = {{0, "#AECF96"},{0.5, "#88A175"},{1, "#FF5656"}}},
    width               = pomowibox.width,
    height              = pomowibox.height,

    begin_callback = function()
        for s = 1, screen.count() do
            -- TODO set unneccessary things invisible
        end
        pomowibox.visible = true
    end,

    finish_callback = function()
        for s = 1, screen.count() do
            mywibox[s].visible = true
        end
        pomowibox.visible = false
    end})
pomowibox:set_widget(pomodoro)

-- cpu
cpuGraph = uzful.widget.cpugraphs({
    fgcolor = "#D0752A", bgcolor = beautiful.bg_systray,
    load = { interval = 20,
        text = ' <span size="x-small"><span color="#666666">$1</span>' ..
               '  <span color="#9A9A9A">$2</span>' ..
               '  <span color="#DDDDDD">$3</span></span>' },
    big = { width = 400, height = 100, interval = 1 },
    small = { width = 42, height = beautiful.menu_height, interval = 1 } })

infoBox.cpu = uzful.widget.infobox({
        position = "top", align = "right",
        widget = cpuGraph.big.layout,
        height = cpuGraph.big.height,
        width = cpuGraph.big.width })

detailed_graphs = uzful.menu.toggle_widgets()

spr = wibox.widget.imagebox()
spr:set_image(beautiful.spr)
spr4px = wibox.widget.imagebox()
spr4px:set_image(beautiful.spr4px)
spr5px = wibox.widget.imagebox()
spr5px:set_image(beautiful.spr5px)

widget_display = wibox.widget.imagebox()
widget_display:set_image(beautiful.widget_display)
widget_display_r = wibox.widget.imagebox()
widget_display_r:set_image(beautiful.widget_display_r)
widget_display_l = wibox.widget.imagebox()
widget_display_l:set_image(beautiful.widget_display_l)
widget_display_c = wibox.widget.imagebox()
widget_display_c:set_image(beautiful.widget_display_c)

myFont = "Source Code Pro"
memoryInUsage = lain.widgets.mem({
    settings = function()
        widget:set_markup(space3 .. roundToDecimal(mem_now.used/1000, 1) .. "G" .. markup.font(myFont, " "))
    end
})

widget_mem = wibox.widget.imagebox()
widget_mem:set_image(beautiful.widget_mem)
memwidget = wibox.widget.background()
memwidget:set_widget(memoryInUsage)
memwidget:set_bgimage(beautiful.widget_display)

-- clock/calendar
mytextclock    = awful.widget.textclock(markup(clockgf, space3 .. "%H:%M" .. markup.font(myFont, " ")))
mytextcalendar = awful.widget.textclock(markup(clockgf, space3 .. "%a %d %b"))

widget_clock = wibox.widget.imagebox()
widget_clock:set_image(beautiful.widget_clock)

clockwidget = wibox.widget.background()
clockwidget:set_widget(mytextclock)
clockwidget:set_bgimage(beautiful.widget_display)

-- taglist
mytaglist         = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag))

-- tasklist
mytasklist         = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

-- panel
mywibox           = {}
mypromptbox       = {}
mylayoutbox       = {}

for s = 1, screen.count() do

    mypromptbox[s] = awful.widget.prompt()

    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end)))

    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    mywibox[s] = awful.wibox({ position = "top", screen = s, height = "22" })

    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(spr5px)
    left_layout:add(mytaglist[s])
    left_layout:add(spr5px)

    local right_layout = wibox.layout.fixed.horizontal()

    right_layout:add(mypromptbox[s])

    right_layout:add(cpuGraph.small.widget)

    right_layout:add(spr)

    right_layout:add(widget_display_l)
    right_layout:add(memwidget)
    right_layout:add(widget_display_r)
    right_layout:add(spr5px)

    right_layout:add(spr)

    right_layout:add(widget_display_l)
    right_layout:add(clockwidget)
    right_layout:add(widget_display_r)
    right_layout:add(spr5px)

    right_layout:add(spr)


    if s == 1 then
        right_layout:add(spr5px)
        right_layout:add(wibox.widget.systray())
        right_layout:add(spr5px)
    end

    right_layout:add(mylayoutbox[s])

    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_bg(beautiful.panel)

    mywibox[s]:set_widget(layout)
end

-- mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ modkey }, 4, awful.tag.viewnext),
    awful.button({ modkey }, 5, awful.tag.viewprev)
    )
)

-- key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,          }, "F12", function () exec(cmdLock) end),
    awful.key({ modkey,          }, "p", function ()
          pomodoro:toggle()
          awful.util.spawn(noiseGenerator)
        end),
    awful.key({ modkey, "Shift" }, "p", function () pomodoro:finish() end),
    awful.key({ modkey, "Shift"   }, "r", awesome.restart),
    awful.key({ modkey,           }, "e", function () exec(filemanager) end),
    awful.key({ modkey,           }, "w", function () exec(browser) end),
    awful.key({ modkey,           }, "q", function () exec(sublime) end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "Return", function () exec(terminal) end),
    awful.key({ modkey,           }, "space",
              function () awful.prompt.run({prompt="Run:"},
                                           mypromptbox[mouse.screen].widget,
                                           runInTerminalOnKeyword,
                                           cleanForCompletion,
                                           awful.util.getdir("cache") .. "/history") end)
)

local wa = screen[mouse.screen].workarea
ww = wa.width
wh = wa.height
-- (panel height)
ph = 22

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",        function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "c",        function (c)
      c:kill()
      awful.mouse.client.focus()
      end),
    awful.key({ modkey,           }, "n",        function (c) c.minimized = true end)
)

for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize),
    awful.button({ modkey }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
    awful.button({ modkey }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end))

root.keys(globalkeys)
-- rules
awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     size_hints_honor = false,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
}

-- signals
client.connect_signal("manage", function (c, startup)
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

clockwidget:connect_signal("mouse::enter", function() clockwidget:set_widget(mytextcalendar) end)
clockwidget:connect_signal("mouse::leave", function() clockwidget:set_widget(mytextclock) end)
cpuGraph.small.widget:connect_signal("mouse::leave", infoBox.cpu.hide)
cpuGraph.small.widget:connect_signal("mouse::enter", function ()
      if detailed_graphs.visible() then
        infoBox.cpu:update()
        infoBox.cpu:show()
    end
end)
client.connect_signal("focus", function(c)
  c.border_color = "#D0752A"
  c.border_width = 1
  end)
client.connect_signal("unfocus", function(c)
  c.border_color = "#343434"
  c.border_width = 1
  end)

logger:info("rc.lua end")

_ = require 'underscore'
inspect = require 'inspect'

--package.path = "/usr/share/awesome/lib/awful/layout/suit/?.lua;/usr/share/awesome/lib/awful/layout/?/init.lua;/usr/share/awesome/lib/awful/?/init.lua;/usr/share/awesome/lib/awful/?.lua;/usr/share/awesome/lib/?/init.lua;/usr/share/awesome/lib/?.lua;/usr/share/lua/5.3/?/init.lua;/usr/share/lua/5.3/?.lua;/home/ulmeyda/repositories/configs/awesome/?.moon;/usr/share/lua/5.3/?.lua;/usr/share/lua/5.3/?/init.lua;/usr/lib/lua/5.3/?.lua;/usr/lib/lua/5.3/?/init.lua;./?.lua;./?/init.lua;/home/ulmeyda/.config/awesome/?.lua;/home/ulmeyda/.config/awesome/?/init.lua;/etc/xdg/awesome/?.lua;/etc/xdg/awesome/?/init.lua;/usr/share/awesome/lib/?.lua;/usr/share/awesome/lib/?/init.lua;/usr/share/awesome/lib/awful/widget/?.lua"

patchRequire = ->
	-- print require calls, assume 1 or 2 '.' separated args
	-- only call with the part after the separator unless it
	-- starts with 'moonscript'
	oldRequire = require
	require = (module) ->
		print module .. ' -> '
		moduleElements = {}
		for word in string.gmatch module, '([^.]+)'
			table.insert moduleElements, word
		if moduleElements[1] == 'moonscript' or moduleElements[1] == 'lgi'
			print module
			oldRequire module
		else
			length = #moduleElements
			print moduleElements[length]
			oldRequire moduleElements[length]

	rawset _G, 'require', require

describe 'awesome config', ->
    mockObject = {}
    awful =
        name: 'awful'
        mock: mockObject
    client =
    	name: 'client'
    	mock: mockObject
    completion =
    	name: 'completion'
    	mock: mockObject
    layout =
    	name: 'layout'
    	mock: mockObject
    placement =
    	name: 'placement'
    	mock: mockObject
    prompt =
    	name: 'prompt'
    	mock: mockObject
    screen =
    	name: 'screen'
    	mock: mockObject
    tag =
    	name: 'tag'
    	mock: mockObject
    util =
    	name: 'util'
    	mock: mockObject
    widget =
    	name: 'widget'
    	mock: mockObject
    keygrabber=
    	name: 'keygrabber'
    	mock: mockObject
    menu =
    	name: 'menu'
    	mock: mockObject
    mouse =
    	name: 'mouse'
    	mock: mockObject
    remote =
    	name: 'remote'
    	mock: mockObject
    key =
    	name: 'key'
    	mock: mockObject
    button =
    	name: 'button'
    	mock: mockObject
    wibox = 
    	name: 'wibox'
    	mock: mockObject
    startupNotification =
    	name: 'startup_notification'
    	mock: mockObject
    tooltip =
    	name: 'tooltip'
    	mock: mockObject
    ewmh =
    	name: 'ewmh'
    	mock: mockObject
    titlebar =
    	name: 'titlebar'
    	mock: mockObject
    mocks = {awful, client, completion, layout, placement, prompt, screen, tag, widget, util, keygrabber, menu, mouse, remote, key, button, wibox, startupNotification, tooltip, ewmh, titlebar}
    for index, mock in ipairs mocks
        print 'mocking ' .. mock.name
    	rawset _G, mock.name, mock.mock
        name = mock.name
        package.loaded[name] = mockObject

	--patchRequire!

	it 'should set wallpaper using gears', ->
		saneArguments = false
		callCount = 0
		mockMaximized = (surface, screen, ignoreAspect, offset) ->
			firstArgString = type(surface) == "string"
			secondArgNumber = type(screen) == 'number'
			thirdArgBoolean = type(ignoreAspect) == 'boolean'
			callCount += 1
			saneArguments = firstArgString and secondArgNumber and thirdArgBoolean
		
		mockGears =
			wallpaper:
				maximized: mockMaximized

		package.loaded.gears = mockGears

		require 'config'

		assert.equals callCount, 1
		assert.is_true saneArguments

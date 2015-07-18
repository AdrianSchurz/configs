_ = require 'underscore'
inspect = require 'inspect'

package.path = "/usr/share/awesome/lib/?/init.lua;/usr/share/awesome/lib/?.lua;/usr/share/lua/5.3/?/init.lua;/usr/share/lua/5.3/?.lua;/home/ulmeyda/repositories/configs/awesome/?.moon;/usr/share/lua/5.3/?.lua;/usr/share/lua/5.3/?/init.lua;/usr/lib/lua/5.3/?.lua;/usr/lib/lua/5.3/?/init.lua;./?.lua;./?/init.lua;/home/ulmeyda/.config/awesome/?.lua;/home/ulmeyda/.config/awesome/?/init.lua;/etc/xdg/awesome/?.lua;/etc/xdg/awesome/?/init.lua;/usr/share/awesome/lib/?.lua;/usr/share/awesome/lib/?/init.lua"

describe 'awesome config', ->

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
		
		-- replace module retrieved by 'require("gears")' and spy on it
		package.loaded.gears = mockGears

		-- run the config
		require 'config'

		assert.equals callCount, 1
		assert.is_true saneArguments

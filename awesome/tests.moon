_ = require 'underscore'
inspect = require 'inspect'

describe 'awesome config', ->
    modulesToMock = {
        'awesome','awful', 'client', 'completion',
        'layout', 'placement', 'prompt', 'screen',
        'tag', 'util', 'widget', 'keygrabber',
        'menu', 'mouse', 'remote', 'key', 'button',
        'wibox', 'startup_notification', 'tooltip',
        'ewmh', 'titlebar', 'beautiful', 'logging'
    }
    emptyObject = {}

    addToGlobalContext = (moduleName) ->
        rawset _G, moduleName, emptyObject

    setLoaded = (moduleName) ->
        package.loaded[moduleName] = emptyObject

    _.each modulesToMock, (moduleName) ->
        addToGlobalContext moduleName
        setLoaded moduleName

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

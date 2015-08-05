underscore = require 'underscore'
inspect = require 'inspect'

oldPrint = print
print = (output) ->
    oldPrint inspect output

modulesToMock = {
        'awesome','awful', 'client', 'completion',
        'layout', 'placement', 'prompt', 'screen',
        'tag', 'util', 'widget', 'keygrabber',
        'menu', 'mouse', 'remote', 'key', 'button',
        'wibox', 'startup_notification', 'tooltip',
        'ewmh', 'titlebar', 'beautiful', 'uzful'
    }

mockExceptions = {
    'inspect',
    'underscore'
}

modulesToMock = underscore.select modulesToMock, (moduleName) ->
    return not underscore.contains mockExceptions, moduleName

emptyObject = {}

addToGlobalContext = (moduleName) ->
        rawset _G, moduleName, emptyObject

setLoaded = (moduleName) ->
        package.loaded[moduleName] = emptyObject

setupOrResetGlobalContext = ->
    underscore.each modulesToMock, addToGlobalContext

markMocksLoaded = ->
    underscore.each modulesToMock, setLoaded

describe 'awesome config', ->
    randomize!

    setup ->
        setupOrResetGlobalContext!
        markMocksLoaded!

    before_each ->
        mockAwesome =
            connect_signal: ->
        mockUzful =
            util:
                patch:
                    vicious: ->
        mockAwful =
            util:
                spawn_with_shell: ->
            layout:
                suit:
                    tile:
                        top: emptyObject
            tag: ->
            widget:
                taglist: {}
            wibox: ->
                widgetBox =
                    set_bg: ->
                return widgetBox

        taglist =
            filter:
                all: {}
        taglistMeta =
            __call: ->
        setmetatable taglist, taglistMeta
        mockAwful.widget.taglist = taglist

        mockWibox =
            layout:
                fixed:
                    horizontal: ->
        mockBeautiful =
            init: ->

        fileNames = {'.', '..', 'dick', 'butt'}
        iterator = => return table.remove fileNames
        mockFileSystem =
            dir: => return iterator, nil
        mockScreen =
            count: -> return 2

        package.loaded.uzful = mockUzful
        package.loaded.awful = mockAwful
        package.loaded.beautiful = mockBeautiful
        package.loaded.lfs = mockFileSystem
        package.loaded.wibox = mockWibox
        rawset _G, 'screen', mockScreen
        rawset _G, 'awesome', mockAwesome

    after_each ->
       setupOrResetGlobalContext!
       markMocksLoaded!

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

		assert.equals 2, callCount
		assert.is_true saneArguments



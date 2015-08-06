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
        'ewmh', 'titlebar', 'beautiful', 'uzful',
        'gears'
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
    numberOfScreens = {}

    setup ->
        setupOrResetGlobalContext!
        markMocksLoaded!

    before_each ->
        numberOfScreens = 2
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
            count: -> return numberOfScreens
        mockGears =
            wallpaper:
                maximized: ->

        package.loaded.uzful = mockUzful
        package.loaded.awful = mockAwful
        package.loaded.beautiful = mockBeautiful
        package.loaded.lfs = mockFileSystem
        package.loaded.wibox = mockWibox
        package.loaded.gears = mockGears
        rawset _G, 'screen', mockScreen
        rawset _G, 'awesome', mockAwesome

    after_each ->
        setupOrResetGlobalContext!
        markMocksLoaded!
        package.loaded.config = nil

	it 'should set wallpaper using gears', ->
		saneArguments = false
		callCount = 0
		mockMaximized = (surface, screen, ignoreAspect, offset) ->
			firstArgString = type(surface) == "string"
			secondArgNumber = type(screen) == 'number'
			thirdArgBoolean = type(ignoreAspect) == 'boolean'
			callCount += 1
			saneArguments = firstArgString and secondArgNumber and thirdArgBoolean
        package.loaded.gears.wallpaper.maximized = mockMaximized

		require 'config'

		assert.equals numberOfScreens, callCount
		assert.is_true saneArguments

    it 'should create a widget box', ->
        widgetboxesCreated = 0
        widgetboxBackgroundsSet = 0
        widgetbox =
            set_bg: -> widgetboxBackgroundsSet += 1
        createWidgetbox = ->
            widgetboxesCreated += 1
            return widgetbox
        package.loaded.awful.wibox = createWidgetbox

        require 'config'

        assert.equals numberOfScreens, widgetboxesCreated
        assert.equals numberOfScreens, widgetboxBackgroundsSet



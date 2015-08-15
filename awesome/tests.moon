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
        'gears', 'lain'
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
    numberOfScreens = emptyObject
    mockCpuGraph = emptyObject

    run = ->
        require 'config'

    setup ->
        setupOrResetGlobalContext!
        markMocksLoaded!


    before_each ->
        numberOfScreens = 2

        mockAwesome =
            connect_signal: ->
        rawset _G, 'awesome', mockAwesome

        mockWidget =
            set_markup: ->
        rawset _G, 'widget', mockWidget

        mockCpuGraph =
            big:
                layout: emptyObject
                width: emptyObject
                height: emptyObject
            small: emptyObject

        mockUzful =
            util:
                patch:
                    vicious: ->
            widget:
                cpugraphs: (parameter) ->
                    return mockCpuGraph
                infobox: ->
        package.loaded.uzful = mockUzful

        mockAwful =
            util:
                spawn_with_shell: ->
            layout:
                suit:
                    tile:
                        top: emptyObject
            tag: ->
            widget:
                taglist: emptyObject
            wibox: ->
                widgetBox =
                    set_bg: ->
                    set_widget: ->
                return widgetBox

        taglist =
            filter:
                all: emptyObject
        taglistMeta =
            __call: ->
        setmetatable taglist, taglistMeta
        mockAwful.widget.taglist = taglist
        package.loaded.awful = mockAwful

        mockLayoutHorizontal =
            add: ->
            set_right: ->
        mockWibox =
            layout:
                fixed:
                    horizontal: -> return mockLayoutHorizontal
                align:
                    horizontal: -> return mockLayoutHorizontal

        mockBeautiful =
            init: ->
        package.loaded.beautiful = mockBeautiful

        fileNames = {'.', '..', 'dick', 'butt'}
        iterator = => return table.remove fileNames
        mockFileSystem =
            dir: => return iterator, nil
        package.loaded.lfs = mockFileSystem

        mockScreen =
            count: -> return numberOfScreens
        rawset _G, 'screen', mockScreen

        mockGears =
            wallpaper:
                maximized: ->
        package.loaded.gears = mockGears
        rawset _G, 'screen', mockScreen
        rawset _G, 'awesome', mockAwesome

    after_each ->
        setupOrResetGlobalContext!
        markMocksLoaded!
        package.loaded.config = nil

	it 'should set wallpapers using gears', ->
		saneArguments = false
		callCount = 0
		mockMaximized = (surface, screen, ignoreAspect, offset) ->
			firstArgString = type(surface) == 'string'
			secondArgNumber = type(screen) == 'number'
			thirdArgBoolean = type(ignoreAspect) == 'boolean'
			callCount += 1
			saneArguments = firstArgString and secondArgNumber and thirdArgBoolean
        package.loaded.gears.wallpaper.maximized = mockMaximized

		run!

		assert.equals numberOfScreens, callCount
		assert.is_true saneArguments

    it 'should create a widget box for each screen', ->
        widgetboxesCreated = 0
        widgetboxBackgroundsSet = 0
        widgetbox =
            set_bg: -> widgetboxBackgroundsSet += 1
            set_widget: ->
        createWidgetbox = ->
            widgetboxesCreated += 1
            return widgetbox
        package.loaded.awful.wibox = createWidgetbox

        run!

        assert.equals numberOfScreens, widgetboxesCreated
        assert.equals numberOfScreens, widgetboxBackgroundsSet

    it 'should initialise theme once', ->
        callsToInit = 0
        initSpy = (path) ->
            callsToInit += 1
            assert.is_true type(path) == 'string'
        package.loaded.beautiful.init = initSpy

        run!

        assert.equals 1, callsToInit

    it 'should call spawn with parameter false (disables cursor animation)', ->
        spawnSpy = (command, parameter) ->
            assert.is_false parameter
        package.loaded.awful.util.spawn = spawnSpy

        run!

        package.loaded.awful.util.spawn 'dickbutt'

    it 'should issue command "wmname LG3D" once to fix java gui', ->
        commandsIssued = 0
        spawn_with_shellSpy = (command) ->
            if command == 'wmname LG3D'
                commandsIssued += 1
        package.loaded.awful.util.spawn_with_shell = spawn_with_shellSpy

        run!

        assert.equals 1, commandsIssued

    describe 'cpu graph widget', ->
        it 'should enable graph auto caching', ->
            viciousPatched = false
            patchSpy = ->
                viciousPatched = true
            package.loaded.uzful.util.patch.vicious = patchSpy

            run!

            assert.is_true viciousPatched

        it 'should create a cpu graph widget', ->
            graphCreated = false
            cpugraphsSpy = ->
                graphCreated = true
                return mockCpuGraph
            package.loaded.uzful.widget.cpugraphs = cpugraphsSpy

            run!

            assert.is_true graphCreated

        it 'should create a box to show the cpu graph in', -> -- TODO test description probably not accurate
            boxCreated = false
            createInfoBoxSpy = ->
                boxCreated = true
            package.loaded.uzful.widget.infobox = createInfoBoxSpy

            run!

            assert.is_true boxCreated

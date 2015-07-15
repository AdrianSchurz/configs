local inspect = require('inspect')
require('logging.file')
local logPath = '/home/ulmeyda/.config/awesome/rc.lua.log'
local logger =  logging.file(logPath)

awesomeLibPath = '/usr/share/awesome/lib/'
luaLibPath = '/usr/share/lua/5.3/'
moonConfigPath = '/home/ulmeyda/repositories/configs/awesome/'

patternForFolder = '?/init.lua'
patternForLuaFile = '?.lua'
patternForMoonFile = '?.moon'
delimiter = ';'

awesomeLibFolderPattern = awesomeLibPath .. patternForFolder .. delimiter
awesomeLibFilePattern = awesomeLibPath .. patternForLuaFile .. delimiter
luaLibFolderPattern = luaLibPath .. patternForFolder .. delimiter
luaLibFilePattern = luaLibPath .. patternForLuaFile .. delimiter
moonConfigPattern = moonConfigPath .. patternForMoonFile .. delimiter

awesomeLibs = awesomeLibFolderPattern .. awesomeLibFilePattern
luaLibs = luaLibFolderPattern .. luaLibFilePattern
pathsToAdd = awesomeLibs .. luaLibs .. moonConfigPattern

-- now that we've spent that much time on getting the paths right...
package.path = pathsToAdd .. package.path
-- ...that was boring, kill me

require('moonscript')
require('rc')
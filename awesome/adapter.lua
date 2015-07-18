local inspect = require('inspect')
local logging = require('logging')
local logPath = '/home/ulmeyda/.config/awesome/rc.lua.log'
local logger =  logging.file(logPath)

local awesomeLibPath = '/usr/share/awesome/lib/'
local luaLibPath = '/usr/share/lua/5.3/'
local moonConfigPath = '/home/ulmeyda/repositories/configs/awesome/'

local patternForFolder = '?/init.lua'
local patternForLuaFile = '?.lua'
local patternForMoonFile = '?.moon'
local delimiter = ';'

local awesomeLibFolderPattern = awesomeLibPath .. patternForFolder .. delimiter
local awesomeLibFilePattern = awesomeLibPath .. patternForLuaFile .. delimiter
local luaLibFolderPattern = luaLibPath .. patternForFolder .. delimiter
local luaLibFilePattern = luaLibPath .. patternForLuaFile .. delimiter

local moonConfigPattern = moonConfigPath .. patternForMoonFile .. delimiter
local awesomeLibs = awesomeLibFolderPattern .. awesomeLibFilePattern
local luaLibs = luaLibFolderPattern .. luaLibFilePattern

local pathsToAdd = awesomeLibs .. luaLibs .. moonConfigPattern
package.path = pathsToAdd .. package.path

require('moonscript')
require('config')
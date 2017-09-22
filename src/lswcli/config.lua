#!/usr/bin/env lua

local os = require('os')
local io = require('io')
local lfs = require('lfs')

local config = {
  _configPath = os.getenv('HOME') .. '/.config/lsw'
}


function config.readConfig(self)
  local rc = lfs.attributes(
    config._configPath .. '/rc.lua')
  if rc and rc.mode == 'file' then
    package.path = package.path .. ';' .. config._configPath .. '/?.lua'
    return require('rc')
  end
  return nil
end

function config.writeConfig(self, apiKey)
  local configDir = string.gsub(config._configPath, "(.*)/(.*)", "%1")
  lfs.mkdir(configDir)
  lfs.mkdir(config._configPath)
  local fd = io.open(config._configPath .. '/rc.lua', 'w')
  fd:write("return { apiKey = '" .. apiKey  .. "' }\n")
  fd:close()
end

return config

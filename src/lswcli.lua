#!/usr/bin/env lua

local lsw = require('lsw')
local os = require('os')
local io = require('io')

local client = {
  configPath = os.getenv('HOME') .. '/.config/lsw'
}

function client.lease(self)
  if arg[2] and arg[3] then
    if not client.lsw.setLease(arg[2], arg[3]) then
      os.exit(1)
    end
  else
    os.exit(1)
  end
end

function client.list(self)
  local bareMetals = client.lsw.getMetals()
  print('>> baremetal')
  for location, metals in pairs(bareMetals or {}) do
    print("   - location:\t" .. location)
    for _, metal in pairs(metals or {}) do
      print("     - name/id:\t" .. metal.serverName .. ' / ' .. metal.bareMetalId)
      print("       hw:\t" .. metal.server.serverType .. ' / ' .. metal.server.processorType ..
       ' (' .. metal.server.numberOfCpus .. 'x' .. metal.server.numberOfCores .. '@' .. metal.server.processorSpeed ..')')
      print("          \t" .. metal.server.ram .. ' ram / ' .. metal.server.hardDisks .. ' disks')
    end
  end
end

function client.password(self)
  if arg[2] then
    local password = client.lsw.getPassword(arg[2])
    print('>> passwords')
    print("   default:\t" .. password.rootPassword)
    print("   rescue:\t" .. password.rescueModePassword)
  else
    os.exit(1)
  end
end

function client.reboot(self)
  if arg[2] then
    if not client.lsw.rebootMetal(arg[2]) then
      os.exit(1)
    end
  end
end

function client.rescue(self)
  if arg[2] then
    local images = client.lsw.getRescueImages()
    print('>> available images')
    for k, v in pairs(images) do
      print('   ' .. k .. ') ' .. v.rescueImage.name)
    end
    repeat
      io.write("\n   > choose an image: ")
      io.flush()
      image = tonumber(io.read())
    until images[image]

    if client.lsw.setRescueImage(arg[2], images[image].rescueImage.id) then
      os.exit(0)
    end
  end
  os.exit(1)
end

function client.run(self)
  package.path = package.path .. ';' .. client.configPath .. '/?.lua'
  client:readConfig()

  client.lsw = lsw:init(client.config.apiKey)

  if arg[1] == 'lease' then client:lease() end
  if arg[1] == 'list' then client:list() end
  if arg[1] == 'password' then client:password() end
  if arg[1] == 'reboot' then client:reboot() end
  if arg[1] == 'rescue' then client:rescue() end
end

function client.readConfig(self)
  local fd = io.open(client.configPath .. '/rc.lua', 'r')
  if fd then
    client.config = require('rc')
    fd:close()
  else
    print('create config in ~/.config/lsw/rc.lua')
    os.exit(1)
  end
end

client.run()

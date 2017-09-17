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

function client.show(self)
  if arg[2] then
    local metal = client.lsw.getMetal(arg[2])
    print('>> ' .. metal.server.serverType .. ' (' .. metal.serverName .. ' / ' .. metal.bareMetalId .. ")\n")
    print('   - contract')
    print("     sla:\t" .. metal.serviceLevelAgreement.sla)
    print("     price:\t" .. metal.serverHostingPack.serverPrice)
    print("     start:\t" .. metal.serverHostingPack.startDate)
    print("     end:\t" .. (metal.serverHostingPack.endDate or '-'))
    print("     term:\t" .. metal.serverHostingPack.contractTerm)
    print()
    print('   - hardware')
    print("     cpu:\t" .. metal.server.numberOfCpus .. 'x' .. metal.server.numberOfCores .. ' @ ' .. metal.server.processorSpeed ..
      ' (' .. metal.server.processorType .. ')')
    print("     ram:\t" .. metal.server.ram)
    print("     disks:\t" .. metal.server.hardDisks)
    print("     mac:")
    for _, v in pairs(metal.network.macAddresses.mac or {}) do
      print('       - ' .. v)
    end

    local switch = client.lsw.getSwitchState(metal.bareMetalId)
    print("     switch:\t" .. switch.switchNode .. ' / ' .. switch.status)

    local power = client.lsw.getPowerState(metal.bareMetalId)
    print("     power:\t" .. power.status)

    if (metal.network or {}).ipmi then
      print()
      print('   - ipmi')
      print("     ip:\t" .. metal.network.ipmi.ip)
      print("     netmask:\t" .. metal.network.ipmi.netmask)
      print("     gateway:\t" .. metal.network.ipmi.gateway)
    end

    local ips = client.lsw.getIp(metal.bareMetalId)
    print()
    print('   - ip')
    for _, v in pairs(ips or {}) do
      if v.ip.nullRouted then nullRoute = 'enabled' else nullRoute = 'disabled' end
      print()
      print("     ip:\t" .. v.ip.ip)
      print("     gateway:\t" .. v.ip.ipDetails.gateway)
      print("     netmask:\t" .. v.ip.ipDetails.mask)
      print("     ptr:\t" .. (v.ip.reverseLookup or '-'))
      print("     nullroute:\t" .. nullRoute)
    end

    local leases = client.lsw.getLeases(metal.bareMetalId)
    print()
    print('   - leases')
    for _, v in pairs(leases or {}) do
      print()
      print("     ip:\t" .. v.ip)
      print("     mac:\t" .. v.mac)
      print('     - options')
      for _, o in pairs(v.options or {}) do
        print('       ' .. o.name .. ': ' .. o.value)
      end
    end
    print()
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

function client.rmleases(self)
  if arg[2] then
    if not client.lsw.rmLeases(arg[2]) then
      os.exit(1)
    end
  else
    os.exit(1)
  end
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
  if arg[1] == 'rmleases' then client:rmleases() end
  if arg[1] == 'show' then client:show() end
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

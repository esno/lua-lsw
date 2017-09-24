local lswCliShell = require('lswcli.shell')
local lswBareMetals = require('leaseweb.bareMetals')
local lswConfig = require('lswcli.config')
local lswInstallation = require('leaseweb.bareMetalInstallation')
local posix = require('posix')

local bareMetal = {
  cmd = 'bareMetal',
  desc = 'manage your bare metal servers',
  config = lswConfig:readConfig(),
  metals = {}
}

function bareMetal.ls(self)
  bareMetal.metals = lswBareMetals:init(bareMetal.config.apiKey).listServers()
  for _, v in pairs(bareMetal.metals or {}) do
    print(v.bareMetalId .. "\t" .. v.serverName .. '/' .. v.serverType .. "\t" .. (v.reference or "-"))
  end
end

function bareMetal.info(self)
  if not bareMetal.selected and not bareMetal.metals[bareMetal.selected] then
    print('no server selected')
    return nil
  end

  local metal = bareMetal.metals[bareMetal.selected].retrieveBareMetal()
  print(metal.bareMetalId .. "\t" .. metal.serverName .. "\t" .. metal.serverType .. "\t -- " .. (metal.reference or '-'))
  print()
  print("location:\t" .. metal.location.site .. ' / ' .. metal.location.cabinet)
  print()
  print("h/w:\t\t" .. metal.server.serverType .. ' / ' .. metal.server.processorType)
  print("cpu:\t\t" .. metal.server.numberOfCpus .. 'x' .. metal.server.numberOfCores .. '@' .. metal.server.processorSpeed ..
    "\t\tram:\t" .. metal.server.ram)
  print("disks:\t\t" .. metal.server.hardDisks .. "\t\traid:\t" .. metal.server.hardwareRaid)
  print()
  print("network:\t" .. metal.network.dataPack)
  for _, v in pairs(metal.network.macAddresses.mac or {}) do
    print("\t\t" .. v)
  end
  print("ipmi:\t\t" .. 'address ' .. metal.network.ipmi.ip)
  print("\t\t" .. 'netmask ' .. metal.network.ipmi.netmask)
  print("\t\t"  .. 'gateway ' .. metal.network.ipmi.gateway)
  print()
  print("contract:\t" .. metal.serverHostingPack.startDate .. ' - ' .. (metal.serverHostingPack.endDate or 'open') ..
    ' (' .. metal.serverHostingPack.contractTerm .. ')')
  print("\t\t" .. metal.serviceLevelAgreement.sla)
  print("\t\t" .. metal.serverHostingPack.serverPrice .. ' € (' .. (metal.network.ipsAssigned - metal.network.ipsFreeOfCharge) .. 'x' ..
    (metal.network.excessIpsPrice or '0') .. ' €)')
end

function bareMetal.passwd(self)
  if not bareMetal.selected and not bareMetal.metals[bareMetal.selected] then
    print('no server selected')
    return nil
  end

  local metal = bareMetal.metals[bareMetal.selected]
  local password = metal.retrievePassword()

  if password then
    print('root:\t' .. password.rootPassword)
    print('rescue:\t' .. password.rescueModePassword)
  end
end

function bareMetal.reboot(self)
  if not bareMetal.selected and not bareMetal.metals[bareMetal.selected] then
    print('no server selected')
    return nil
  end

  local metal = bareMetal.metals[bareMetal.selected]
  if not metal.reboot() then
    print('failed to request reboot')
  end
end

function bareMetal.ref(self)
  if not bareMetal.selected and not bareMetal.metals[bareMetal.selected] then
    print('no server selected')
    return nil
  end

  local input = lswCliShell:prompt('reference')
  bareMetal.metals[bareMetal.selected].updateBareMetal(input)
end

function bareMetal.rescue(self)
  if not bareMetal.selected and not bareMetal.metals[bareMetal.selected] then
    print('no server selected')
    return nil
  end

  local metal = bareMetal.metals[bareMetal.selected]
  local lswRescueImages = require('leaseweb.rescueImages')
  local os = lswRescueImages:init(bareMetal.config.apiKey).listRescueImages()

  for k, v in pairs(os or {}) do
    print(k .. ') ' .. v.rescueImage.name)
  end

  repeat
    input = tonumber(lswCliShell:prompt('rescue [' .. metal.serverName .. ']'))
  until os[input]

  if not metal.launchRescueMode(os[input].rescueImage.id) then
    print('failed to launch rescue mode')
  else
    print('initializing rescue mode...')
    repeat
      if status then
        posix.sleep(60)
      end
      local status = metal.retrieveInstallationStatus()
    until status.description == lswInstallation.status._NORMAL
    local password = metal.retrievePassword()
    print('rescue password is ' .. lswCliShell:white(password.rescueModePassword))
  end
end

function bareMetal.select(self)
  if not next(bareMetal.metals) then
    bareMetal.metals = lswBareMetals:init(bareMetal.config.apiKey).listServers()
  end
  for k, v in pairs(bareMetal.metals or {}) do
    print(k .. ') ' .. v.serverName .. ' / ' .. (v.reference or '-'))
  end
  repeat
  	input = tonumber(lswCliShell:prompt('select'))
  until bareMetal.metals[input]
  bareMetal.selected = input
end

function bareMetal.status(self)
  if not bareMetal.selected and not bareMetal.metals[bareMetal.selected] then
    print('no server selected')
    return nil
  end

  local power = bareMetal.metals[bareMetal.selected].retrievePowerStatus()
  local switch = bareMetal.metals[bareMetal.selected].retrieveSwitchPortStatus()
  local ips = bareMetal.metals[bareMetal.selected].listIps()
  local inst = bareMetal.metals[bareMetal.selected].retrieveInstallationStatus()

  if power.status == 'on' then
    powerStatus = lswCliShell:green(power.status)
  else
    powerStatus = lswCliShell:red(power.status)
  end

  if switch.status == 'open' then
    switchStatus = lswCliShell:green(switch.status)
  else
    switchStatus = lswCliShell:red(switch.status)
  end

  print("power:\t" .. powerStatus .. "\t\tswitch:\t" .. switchStatus)
  if next(ips or {}) then print() end
  for k, v in pairs(ips or {}) do
    if v.nullRouted then
      nullRouted = lswCliShell:red('null-routed')
    else
      nullRouted = lswCliShell:green('routed')
    end
    print(v.ip .. "\t\t" .. nullRouted)
  end
  if inst.code == 1000 then
    instCode = lswCliShell:green(inst.code)
  else
    instCode = lswCliShell:red(inst.code)
  end
  print()
  print(instCode .. ":\t\t\t" .. inst.description)
end

local commands = {
  { cmd = 'info', desc = 'prints detailed information about the selected server',
    func = bareMetal.info },
  { cmd = 'ls', desc = 'shows all bareMetal servers',
    func = bareMetal.ls },
  { cmd = 'passwd', desc = 'fetch server passwords',
    func = bareMetal.passwd },
  { cmd = 'reboot', desc = 'reboot server',
    func = bareMetal.reboot },
  { cmd = 'ref', desc = 'update server reference',
    func = bareMetal.ref },
  { cmd = 'rescue', desc = 'boot a rescue image',
    func = bareMetal.rescue },
  { cmd = 'select', desc = 'select a server',
    func = bareMetal.select },
  { cmd = 'status', desc = 'prints information about server status',
    func = bareMetal.status }
}

function bareMetal.run(self)
  local running = true
  while running do
    if bareMetal.selected then postfix = ' [' .. bareMetal.metals[bareMetal.selected].serverName .. ']' end
    local cmd = lswCliShell:prompt(bareMetal.cmd .. (postfix or ''))
    if cmd == 'help' then
      lswCliShell:help(commands)
    elseif cmd == 'exit' or cmd == ':q' then
      running = false
    else
      for _, v in pairs(commands or {}) do
        if cmd == v.cmd then v:func() end
      end
    end
  end
end

return bareMetal

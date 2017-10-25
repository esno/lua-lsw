local os = require('os')
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

function bareMetal.ips(self)
  if not bareMetal.selected and not bareMetal.metals[bareMetal.selected] then
    print('no server selected')
    return nil
  end

  local metal = bareMetal.metals[bareMetal.selected]
  local ips = metal.listIps()

  print("ip\t\tgw\t\tnetmask")
  for k, v in pairs(ips or {}) do
    print(v.ip .. "\t" .. v.ipDetails.gateway .. "\t" .. v.ipDetails.mask)
  end
end

function bareMetal.leases(self)
  if not bareMetal.selected and not bareMetal.metals[bareMetal.selected] then
    print('no server selected')
    return nil
  end
  local metal = bareMetal.metals[bareMetal.selected]
  local leases = metal.listLeases()
  for _, v in pairs(leases or {}) do
    print(v.ip .. "\t" .. v.mac)
    for _, l in pairs(v.options or {}) do
      print(' ' .. l.name .. ': ' .. l.value)
    end
  end
end

function bareMetal.ls(self)
  bareMetal.metals = lswBareMetals:init(bareMetal.config.apiKey).listServers()
  for _, v in pairs(bareMetal.metals or {}) do
    print(v.bareMetalId .. "\t" .. v.serverName .. '/' .. v.serverType .. "\t" .. (v.reference or "-"))
  end
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
  local OS = lswRescueImages:init(bareMetal.config.apiKey).listRescueImages()

  for k, v in pairs(OS or {}) do
    print(k .. ') ' .. v.rescueImage.name)
  end

  repeat
    input = tonumber(lswCliShell:prompt('rescue [' .. metal.serverName .. ']'))
  until OS[input]

  if not metal.launchRescueMode(OS[input].rescueImage.id) then
    local status = metal.retrieveInstallationStatus()
    if status.description == lswInstallation.status._RESCUE then
      print('rescue mode already initializing. please wait')
    else
      print('failed to launch rescue mode')
    end
  else
    local startTime = os.time()
    print('initializing rescue mode...')
    repeat
      if status then
        posix.sleep(60)
      end
      local status = metal.retrieveInstallationStatus()
    until status.description == lswInstallation.status._NORMAL
    local endTime = os.time()
    print('rescue mode initialized after ' .. (endTime - startTime) .. ' seconds')
    repeat
      input = lswCliShell:prompt('ssh (y/n)')
    until input == 'y' or input == 'n'
    if input == 'y' then bareMetal.ssh() end
  end
end

function bareMetal.rmleases(self)
  if not bareMetal.selected and not bareMetal.metals[bareMetal.selected] then
    print('no server selected')
    return nil
  end

  if not bareMetal.metals[bareMetal.selected].deleteLeases() then
    print('cannot delete leases')
    return nil
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

function bareMetal.ssh(self)
  if not bareMetal.selected and not bareMetal.metals[bareMetal.selected] then
    print('no server selected')
    return nil
  end

  local metal = bareMetal.metals[bareMetal.selected]
  local ips = metal.listIps()
  local password = metal.retrievePassword().rescueModePassword

  local sshCmd = "sshpass -p '" .. password ..
    "' ssh root@" .. ips[1].ip ..
    ' -o StrictHostKeyChecking=no' ..
    ' -o UserKnownHostsFile=/dev/null' ..
    ' -o PasswordAuthentication=yes'

  print('WARNING: host key checking is disabled!')
  os.execute(sshCmd)
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
  { cmd = 'ips', desc = 'shows ip address information',
    func = bareMetal.ips },
  { cmd = 'leases', desc = 'shows all dhcp leases',
    func = bareMetal.leases },
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
  { cmd = 'rmleases', desc = 'delete all dhcp leases',
    func = bareMetal.rmleases },
  { cmd = 'select', desc = 'select a server',
    func = bareMetal.select },
  { cmd = 'ssh', desc = 'open remote shell',
    func = bareMetal.ssh },
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

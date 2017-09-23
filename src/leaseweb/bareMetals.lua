local lswRest = require('leaseweb.rest')
local lswBareMetal = require('leaseweb.bareMetal')
local lswBareMetalSwitch = require('leaseweb.bareMetalSwitch')
local lswBareMetalPower = require('leaseweb.bareMetalPower')
local lswBareMetalIp = require('leaseweb.bareMetalIp')
local lswBareMetalNetworkUsage = require('leaseweb.bareMetalNetworkUsage')
local lswBareMetalPassword = require('leaseweb.bareMetalPassword')
local lswBareMetalInstallation = require('leaseweb.bareMetalInstallation')
local lswBareMetalDhcp = require('leaseweb.bareMetalDhcp')
local lswBareMetalRescueMode = require('leaseweb.bareMetalRescueMode')

local module = {}

function module.init(self, apiKey)
  module.apiKey = apiKey
  local bareMetals = {}

  bareMetals.listServers = function()
    local s, bm = lswRest:get(
      '/v1/bareMetals/', apiKey)

    if s == 200 then
      local result = {}
      for k, v in pairs(bm['bareMetals'] or {}) do
        table.insert(result, module:mkBareMetal(v['bareMetal']))
      end
      return result
    end
    return nil
  end

  return bareMetals
end

function module.mkBareMetal(self, instance)
  local bareMetal = instance
  local bm = lswBareMetal:init(module.apiKey, instance.bareMetalId)
  local sp = lswBareMetalSwitch:init(module.apiKey, instance.bareMetalId)
  local p = lswBareMetalPower:init(module.apiKey, instance.bareMetalId)
  local ip = lswBareMetalIp:init(module.apiKey, instance.bareMetalId)
  local nu = lswBareMetalNetworkUsage:init(module.apiKey, instance.bareMetalId)
  local pw = lswBareMetalPassword:init(module.apiKey, instance.bareMetalId)
  local inst = lswBareMetalInstallation:init(module.apiKey, instance.bareMetalId)
  local dhcp = lswBareMetalDhcp:init(module.apiKey, instance.bareMetalId)
  local rm = lswBareMetalRescueMode:init(module.apiKey, instance.bareMetalId)

  bareMetal.retrieveBareMetal = bm.retrieveBareMetal
  bareMetal.updateBareMetal = bm.updateBareMetal

  bareMetal.retrieveSwitchPortStatus = sp.retrieveSwitchPortStatus
  bareMetal.openSwitchPort = sp.openSwitchPort
  bareMetal.closeSwitchPort = sp.closeSwitchPort

  bareMetal.retrievePowerStatus = p.retrievePowerStatus
  bareMetal.reboot = p.reboot
  bareMetal.launchRescueMode = rm.launchRescueMode

  bareMetal.listIps = ip.listIps
  bareMetal.retrieveIp = ip.retrieveIp
  bareMetal.updateIp = ip.updateIp

  bareMetal.retrieveNetworkUsage = nu.retrieveNetworkUsage
  bareMetal.retrieveBandwidthUsage = nu.retrieveBandwidthUsage
  bareMetal.retrieveDataTrafficUsage = nu.retrieveDataTrafficUsage

  bareMetal.retrievePassword = pw.retrievePassword

  bareMetal.retrieveInstallationStatus = inst.retrieveInstallationStatus

  bareMetal.listLeases = dhcp.listLeases
  bareMetal.createLease = dhcp.createLease
  bareMetal.retrieveLease = dhcp.retrieveLease
  bareMetal.deleteLease = dhcp.deleteLease
  bareMetal.deleteLeases = dhcp.deleteLeases

  return bareMetal
end

return module

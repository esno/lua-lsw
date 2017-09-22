local lswRest = require('lsw.rest')
local lswBareMetal = require('lsw.bareMetal')
local lswBareMetalSwitch = require('lsw.bareMetalSwitch')
local lswBareMetalPower = require('lsw.bareMetalPower')
local lswBareMetalIp = require('lsw.bareMetalIp')
local lswBareMetalNetworkUsage = require('lsw.bareMetalNetworkUsage')
local lswBareMetalPassword = require('lsw.bareMetalPassword')
local lswBareMetalInstallation = require('lsw.bareMetalInstallation')

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

  bareMetal.retrieveBareMetal = bm.retrieveBareMetal
  bareMetal.updateBareMetal = bm.updateBareMetal

  bareMetal.retrieveSwitchPortStatus = sp.retrieveSwitchPortStatus
  bareMetal.openSwitchPort = sp.openSwitchPort
  bareMetal.closeSwitchPort = sp.closeSwitchPort

  bareMetal.retrievePowerStatus = p.retrievePowerStatus
  bareMetal.reboot = p.reboot

  bareMetal.listIps = ip.listIps
  bareMetal.retrieveIp = ip.retrieveIp
  bareMetal.updateIp = ip.updateIp

  bareMetal.retrieveNetworkUsage = nu.retrieveNetworkUsage
  bareMetal.retrieveBandwidthUsage = nu.retrieveBandwidthUsage
  bareMetal.retrieveDataTrafficUsage = nu.retrieveDataTrafficUsage

  bareMetal.retrievePassword = pw.retrievePassword

  bareMetal.retrieveInstallationStatus = inst.retrieveInstallationStatus

  return bareMetal
end

return module

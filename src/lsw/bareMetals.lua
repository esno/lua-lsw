local lswRest = require('lsw.rest')
local lswBareMetal = require('lsw.bareMetal')
local lswBareMetalSwitch = require('lsw.bareMetalSwitch')
local lswBareMetalPower = require('lsw.bareMetalPower')
local lswBareMetalIp = require('lsw.bareMetalIp')

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

  bareMetal.retrieveBareMetal = bm.retrieveBareMetal
  bareMetal.updateBareMetal = bm.updateBareMetal

  bareMetal.retrieveSwitchPortStatus = sp.retrieveSwitchPortStatus
  bareMetal.openSwitchPort = sp.openSwitchPort
  bareMetal.closeSwitchPort = sp.closeSwitchPort

  bareMetal.retrievePowerStatus = p.retrievePowerStatus

  bareMetal.listIps = ip.listIps
  bareMetal.retrieveIp = ip.retrieveIp
  bareMetal.updateIp = ip.updateIp

  return bareMetal
end

return module

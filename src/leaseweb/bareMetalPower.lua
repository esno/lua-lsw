local lswRest = require('leaseweb.rest')

local module = {}

function module.init(self, apiKey, bareMetalId)
  module.apiKey = apiKey
  local power = {}

  power.retrievePowerStatus = function()
    local s, p = lswRest:get(
      '/v1/bareMetals/' .. bareMetalId .. '/powerStatus',
      apiKey)

    if s == 200 then
      return p['powerStatus']
    end
    return nil
  end

  power.reboot = function()
    local s, p = lswRest:post(
      '/v1/bareMetals/' .. bareMetalId .. '/powerCycle',
      apiKey)

    if s == 202 then
      return true
    end
    return nil
  end

  return power
end

return module

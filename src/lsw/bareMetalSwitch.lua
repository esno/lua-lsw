local lswRest = require('lsw.rest')

local module = {}

function module.init(self, apiKey, bareMetalId)
  module.apiKey = apiKey
  local switchPort = {}

  switchPort.retrieveSwitchPortStatus = function()
    local s, sp = lswRest:get(
      '/v1/bareMetals/' .. bareMetalId .. '/switchPort',
      apiKey)

    if s == 200 then
      return sp['switchPort']
    end
    return nil
  end

  switchPort.openSwitchPort = function()
    local s, sp = lswRest:post(
      '/v1/bareMetals/' .. bareMetalId .. '/switchPort/open',
      apiKey)

    if s == 200 then
      return sp['switchPort']
    end
    return nil
  end

  switchPort.closeSwitchPort = function()
    local s, sp = lswRest:post(
      '/v1/bareMetals/' .. bareMetalId .. '/switchPort/close',
      apiKey)

    if s == 200 then
      return sp['switchPort']
    end
    return nil
  end

  return switchPort
end

return module

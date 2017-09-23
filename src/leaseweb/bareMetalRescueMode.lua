local lswRest = require('leaseweb.rest')

local module = {}

function module.init(self, apiKey, bareMetalId)
  module.apiKey = apiKey
  local rescue = {}

  rescue.launchRescueMode = function(id)
    local s, r = lswRest:post(
      '/v1/bareMetals/' .. bareMetalId .. '/rescueMode',
      apiKey,
      { osId = id })

    if s == 200 then
      return true
    end
    return nil
  end

  return rescue
end

return module

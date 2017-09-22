local lswRest = require('lsw.rest')

local module = {}

function module.init(self, apiKey, bareMetalId)
  module.apiKey = apiKey
  local password = {}

  password.retrievePassword = function()
    local s, p = lswRest:get(
      '/v1/bareMetals/' .. bareMetalId .. '/rootPassword',
      apiKey)

    if s == 200 then
      return p
    end
    return nil
  end

  return password
end

return module

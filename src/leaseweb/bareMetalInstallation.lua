local lswRest = require('leaseweb.rest')

local module = {}

function module.init(self, apiKey, bareMetalId)
  module.apiKey = apiKey
  local install = {}

  install.retrieveInstallationStatus = function()
    local s, inst = lswRest:get(
      '/v1/bareMetals/' .. bareMetalId .. '/installationStatus',
      apiKey)

    if s == 200 then
      return inst['installationStatus']
    end
    return nil
  end

  return install
end

return module

local lswRest = require('leaseweb.rest')

local module = {}

function module.init(self, apiKey)
  module.apiKey = apiKey
  local rescue = {}

  rescue.listRescueImages = function()
    local s, r = lswRest:get(
      '/v1/rescueImages',
      apiKey)

    if s == 200 then
      return r['rescueImages']
    end
    return nil
  end

  return rescue
end

return module

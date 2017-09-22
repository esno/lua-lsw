local lswRest = require('lsw.rest')

local module = {}

function module.init(self, apiKey, bareMetalId)
  module.apiKey = apiKey
  local bareMetal = {}

  bareMetal.retrieveBareMetal = function()
    local s, bm = lswRest:get(
      '/v1/bareMetals/' .. bareMetalId, apiKey)

    if s == 200 then
      return bm['bareMetal']
    end
    return nil
  end

  bareMetal.updateBareMetal = function(reference)
    local s, bm = lswRest:put(
      '/v1/bareMetals/' .. bareMetalId,
      apiKey,
      { reference = reference })

    if s == 200 then
      return bm['bareMetal']
    end
    return nil
  end

  return bareMetal
end

return module

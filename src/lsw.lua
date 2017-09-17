local lswRest = require('lswrest')

local lsw = {}

function lsw.init(self, apiKey)
  local client = {
    apiKey = apiKey
  }

  client.getMetals = function()
    local s, bareMetals = lswRest:get('/v1/bareMetals', client.apiKey)
    if s == 200 then
      local result = {}
      for _, bareMetal in pairs(bareMetals['bareMetals'] or {}) do
        local m = client.getMetal(bareMetal['bareMetal']['bareMetalId'])
        if not result[m.location.site] then result[m.location.site] = {} end
        table.insert(result[m.location.site], m)
      end
      return result
    end
    return nil
  end

  client.getMetal = function(id)
    local s, m = lswRest:get('/v1/bareMetals/' .. id, client.apiKey)
    if s == 200 then
      return m['bareMetal']
    end
    return nil
  end

  client.getPassword = function(id)
    local s, p = lswRest:get(
      '/v1/bareMetals/' .. id .. '/rootPassword',
      client.apiKey)
    return p
  end

  client.setLease = function(id, bootFile)
    local s = lswRest:post(
      '/v1/bareMetals/' .. id .. '/leases',
      client.apiKey,
      { bootFileName = bootFile })
    if s == 204 then return true end
    return nil
  end

  client.getRescueImages = function()
    local s, i = lswRest:get('/v1/rescueImages', client.apiKey)
    return i.rescueImages
  end

  client.rebootMetal = function(id)
    local s = lswRest:post(
      '/v1/bareMetals/' .. id .. '/powerCycle',
      client.apiKey)
    if s == 202 then return true end
    return nil
  end

  client.setRescueImage = function(idBareMetal, idRescueImage)
    local s = lswRest:post(
      '/v1/bareMetals/' .. idBareMetal .. '/rescueMode',
      client.apiKey,
      { osId = idRescueImage }
    )
    if s == 200 then return true end
    return nil
  end

  return client
end

return lsw

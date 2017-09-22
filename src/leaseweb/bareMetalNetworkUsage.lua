local lswRest = require('leaseweb.rest')

local module = {}

function module.init(self, apiKey, bareMetalId)
  module.apiKey = apiKey
  local network = {}

  network.retrieveUsage = function(context, from, to, png)
    local u = '/v1/bareMetals/' .. bareMetalId .. '/networkUsage' .. context
    local r = { dateFrom = from, dateTo = to }
    local s, nu = nil, nil

    if png then
      s, nu = lswRest:getPng(u, apiKey, r)
    else
      s, nu = lswRest:get(u, apiKey, r)
    end

    if s == 200 then
      return nu
    end
    return nil
  end

  network.retrieveNetworkUsage = function(from, to, png)
    return network.retrieveUsage('', from, to, png)
  end

  network.retrieveBandwidthUsage = function(from, to, png)
    return (network.retrieveUsage('/bandwidth', from, to, png) or {})['bandwidth']
  end

  network.retrieveDataTrafficUsage = function(from, to, png)
    return (network.retrieveUsage('/datatraffic', from, to, png) or {})['datatraffic']
  end

  return network
end

return module

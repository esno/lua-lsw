local lswRest = require('lsw.rest')

local module = {}

function module.init(self, apiKey, bareMetalId)
  module.bareMetalId = bareMetalId
  module.apiKey = apiKey
  local ips = {}

  ips.listIps = function()
    local s, bmips = lswRest:get(
      '/v1/bareMetals/' .. bareMetalId .. '/ips',
      apiKey)

    if s == 200 then
      local result = {}
      for k, v in pairs(bmips['ips'] or {}) do
        local i = v['ip']
        i.updateIp = function(reverseLookup, nullRouted)
          return ips.updateIp(i['ip'], reverseLookup, nullRouted)
        end
        table.insert(result, i)
      end
      return result
    end
    return nil
  end

  ips.retrieveIp = function(ip)
    local s, bmip = lswRest:get(
      '/v1/bareMetals/' .. bareMetalId .. '/ips/' .. ip,
      apiKey)

    if s == 200 then
      bmip['ip'].updateIp = function(reverseLookup, nullRouted)
        return ips.updateIp(ip, reverseLookup, nullRouted)
      end
      return bmip['ip']
    end
    return nil
  end

  ips.updateIp = function(ip, reverseLookup, nullRouted)
    if nullRouted == true then nR = 1 else nR = 0 end
    local s, bmip = lswRest:put(
      '/v1/bareMetals/' .. bareMetalId .. '/ips/' .. ip,
      apiKey,
      {
        reverseLookup = reverseLookup,
        nullRouted = nR
      })

    if s == 200 then
      bmip['ip'].updateIp = function(reverseLookup, nullRouted)
        return ips.updateIp(ip, reverseLookup, nullRouted)
      end
      return bmip['ip']
    end
    return nil
  end

  return ips
end

return module

local lswRest = require('leaseweb.rest')

local module = {}

function module.init(self, apiKey, bareMetalId)
  module.apiKey = apiKey
  local dhcp = {}

  dhcp.listLeases = function()
    local s, d = lswRest:get(
      '/v1/bareMetals/' .. bareMetalId .. '/leases',
      apiKey)

    if s == 200 then
      local result = {}
      for _, v in pairs(d['leases'] or {}) do
        v.deleteLease = function()
          return dhcp.deleteLease(v['mac'])
        end
        table.insert(result, v)
      end
      return result
    end
    return nil
  end

  dhcp.createLease = function(bootFileName, bootServerHostName, domainNameServerIp)
    local s, d = lswRest:post(
      '/v1/bareMetals/' .. bareMetalId .. '/leases',
      apiKey,
      {
        bootFileName = bootFileName,
        bootServerHostname = bootServerHostName,
        domainNameServerIp = domainNameServerIp
      })

    if s == 204 then
      return true
    end
    return nil
  end

  dhcp.deleteLeases = function()
    local s, d = lswRest:delete(
      '/v1/bareMetals/' .. bareMetalId .. '/leases',
      apiKey)

    if s == 200 then
      return true
    end
    return nil
  end

  dhcp.retrieveLease = function(mac)
    local s, d = lswRest:get(
      '/v1/bareMetals/' .. bareMetalId .. '/leases/' .. mac,
      apiKey)

    if s == 200 then
      d.deleteLease = function()
        return dhcp.deleteLease(mac)
      end
      return d
    end
    return nil
  end

  dhcp.deleteLease = function(mac)
    local s, d = lswRest:delete(
      '/v1/bareMetals/' .. bareMetalId .. '/leases/' .. mac,
      apiKey)

    if s == 204 then
      return true
    end
    return nil
  end

  return dhcp
end

return module

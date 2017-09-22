local lswRest = require('lsw.rest')

local module = {}

function module.init(self, apiKey)
  local os = {}

  os.listOperatingSystems = function()
    local s, o = lswRest:get(
      '/v1/operatingSystems',
      apiKey)

    if s == 200 then
      return r['operatingSystems']
    end
    return nil
  end

  os.retrieveOperatingSystem = function(id)
    local s, o = lswRest:get(
      '/v1/operatingSystems/' .. id,
      apiKey)

    if s == 200 then
      return o['operatingSystem']
    end
    return nil
  end

  os.listControlPanels = function(id)
    local s, c = lswRest:get(
      '/v1/operatingSystems/' .. id .. '/controlPanels',
      apiKey)

    if s == 200 then
      return c['controlPanels']
    end
    return nil
  end

  os.retrieveControlPanel = function(osId, panelId)
    local s, c = lswRest:get(
      '/v1/operatingSystems/' .. osId .. '/controlPanels/' .. panelId,
      apiKey)

    if s == 200 then
      return c['controlPanel']
    end
    return nil
  end

  os.retrievePartitionSchema = function(osId, bareMetalId)
    local s, p = lswRest:get(
      '/v1/operatingSystems/' .. osId .. 'partitionSchema?serverPackId=' .. bareMetalId,
      apiKey)

    if s == 200 then
      return p
    end
    return nil
  end

  return os
end

return module

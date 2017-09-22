local lswRest = require('leaseweb.rest')

local module = {}

function module.init(self, apiKey)
  local os = {}

  os.listOperatingSystems = function()
    local s, o = lswRest:get(
      '/v1/operatingSystems',
      apiKey)

    if s == 200 then
      local result = {}
      for _, v in pairs(r['operatingSystems'] or {}) do
        v.listControlPanels = function()
          return os.listControlPanels(v['id'])
        end
        v.retrieveControlPanel = function(id)
          return os.retrieveControlPanel(v['id'], id)
        end
        v.retrievePartitionSchema = function(id)
          return os.retrievePartitionSchema(v['id'], id)
        end
        table.insert(result, v)
      end
      return result
    end
    return nil
  end

  os.retrieveOperatingSystem = function(id)
    local s, o = lswRest:get(
      '/v1/operatingSystems/' .. id,
      apiKey)

    if s == 200 then
      local result = o['operatingSystem']
      result.listControlPanels = function()
        return os.listControlPanels(result['id'])
      end
      result.retrieveControlPanel = function(id)
        return os.retrieveControlPanel(result['id'], id)
      end
      result.retrievePartitionSchema = function(id)
        return os.retrievePartitionSchema(result['id'], id)
      end
      return result
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

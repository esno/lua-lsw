local cjson = require('cjson')
local https = require('ssl.https')
local ltn12 = require('ltn12')

local rest = {
  api = 'https://api.leaseweb.com'
}

local _toJson = function(t)
  local json = cjson.new()
  return json.encode(t)
end

local _toTable = function(s)
  local json = cjson.new()
  return json.decode(s)
end

function rest.call(self, url, method, apiKey, header, request)
  local reqBody = nil
  local headers = header or {}
  headers['x-lsw-auth'] = apiKey

  if request then
    reqBody = _toJson(request)
    headers['content-type'] = 'application/json'
    headers['content-length'] = #reqBody
    reqBody = ltn12.source.string(reqBody)
  end
  local respBody = {}
  local resp, respStatus, respHeader = https.request{
    method = method,
    headers = headers,
    source = reqBody,
    sink = ltn12.sink.table(respBody),
    url = rest.api .. url
  }
  if respHeader['content-type']:match('application/json') then
    return respStatus, _toTable(respBody[1])
  elseif respHeader['content-type']:match('image/png') then
    return respStatus, respBody[1]
  else
    return respStatus
  end
  return nil
end

function rest.delete(self, url, apiKey)
  return rest:call(url, 'DELETE', apiKey, nil, nil)
end

function rest.get(self, url, apiKey, request)
  return rest:call(url, 'GET', apiKey, request, nil)
end

function rest.getPng(self, url, apiKey, request)
  local h = {
    ['Accept'] = 'image/png'
  }
  return rest:call(url, 'GET', apiKey, request, nil)
end

function rest.post(self, url, apiKey, request)
  return rest:call(url, 'POST', apiKey, request, nil)
end

function rest.put(self, url, apiKey, request)
  return rest:call(url, 'PUT', apiKey, request, nil)
end

return rest

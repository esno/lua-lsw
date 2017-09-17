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

function rest.get(self, url, apiKey)
  local respBody = {}
  local resp, respStatus, respHeader = https.request{
    method = 'GET',
    headers = {
      ['x-lsw-auth'] = apiKey
    },
    sink = ltn12.sink.table(respBody),
    url = rest.api .. url
  }
  if respHeader['content-type']:match('application/json') then
    return respStatus, _toTable(respBody[1])
  else
    print(respBody[1])
  end
  return nil
end

function rest.post(self, url, apiKey, request)
  local reqBody = nil
  local headers = {
    ['x-lsw-auth'] = apiKey
  }
  if request then
    reqBody = _toJson(request)
    headers['content-type'] = 'application/json'
    headers['content-length'] = #reqBody
    reqBody = ltn12.source.string(reqBody)
  end
  local respBody = {}
  local resp, respStatus, respHeader = https.request{
    method = 'POST',
    headers = headers,
    source = reqBody,
    sink = ltn12.sink.table(respBody),
    url = rest.api .. url
  }
  if respHeader['content-type']:match('application/json') then
    return respStatus, _toTable(respBody[1])
  else
    print(respBody[1])
  end
  return nil
end

function rest.delete(self, url, apiKey)
  local resp, respStatus, respHeader = https.request{
    method = 'DELETE',
    headers = {
      ['x-lsw-auth'] = apiKey
    },
    url = rest.api .. url
  }
  return respStatus
end

return rest

local io = require('io')

local lswCliShell = {}

function lswCliShell.blue(self, text)
  return "\027[0;34m" .. text .. "\027[0m"
end

function lswCliShell.green(self, text)
  return "\027[0;32m" .. text .. "\027[0m"
end

function lswCliShell.red(self, text)
  return "\027[0;31m" .. text .. "\027[0m"
end

function lswCliShell.white(self, text)
  return "\027[1;37m" .. text .. "\027[0m"
end

function lswCliShell.yellow(self, text)
  return "\027[1;33m" .. text .. "\027[0m"
end

function lswCliShell.help(self, commands)
  print('the following commands are available')
  for k, v in pairs(commands or {}) do
    print("\t" .. v.cmd .. "\t\t" .. v.desc)
  end
end

function lswCliShell.prompt(self, prefix)
  if prefix then prefix = prefix .. ' ' end
  io.write(lswCliShell:blue((prefix or '')) .. '> ')
  return io.read()
end

return lswCliShell

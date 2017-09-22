local io = require('io')

local lswCliShell = {}

function lswCliShell.help(self, commands)
  print('the following commands are available')
  for k, v in pairs(commands or {}) do
    print("\t" .. v.cmd .. "\t\t" .. v.desc)
  end
end

function lswCliShell.prompt(self, prefix)
  if prefix then prefix = prefix .. ' ' end
  io.write((prefix or '') .. '> ')
  return io.read()
end

return lswCliShell

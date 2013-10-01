local Server = require "server"

local server = Server()

server:boot()

for k, v in pairs(server.table) do
	print(k, v)
end

server.ptable:flush()

server:start()

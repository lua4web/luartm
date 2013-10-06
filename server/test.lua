local serpent = require "serpent"

local Server = require "server"

local server = Server()

server:boot()

print "== TABLE =="
for k, v in pairs(server.table) do
	print(k, v)
end
print()

print "== CONTEXT =="
for k, v in pairs(server.refser.context) do
	print(k, v)
end
print()



server.ptable:flush()

server:start()

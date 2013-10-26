local Client = require "Client"
local client = Client()
client:connect()

local t = client.table

t[1] = 2
t[2] = t
t.foo = "bar"

client:close()

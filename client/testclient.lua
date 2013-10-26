local serpent = require "serpent"

local client = require "client"

local h = client()
h:connect()

local t = h.table

print(t[1])

local serpent = require "serpent"

local client = require "client"

local h = client()
h:connect()

local t = h.table

t[6] = {}
t[7] = t[6]

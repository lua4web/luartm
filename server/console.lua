local socket = require "socket"
local cl = socket.connect("127.0.0.1", 7733)

local s, r
repeat
	s = io.read()
	if s ~= "" then
		cl:send(s .. "\r\n")
		r = assert(cl:receive())
		print(r)
	end
until s == ""

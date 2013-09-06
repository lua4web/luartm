local corelib = require "coreapi"
local core = corelib()
assert(core:boot())

local s
repeat
	s = io.read()
	if s ~= "" then
		print(assert(core:execute(s)))
	end
until s == ""

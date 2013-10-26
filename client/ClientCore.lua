local class = require "30log"
local socket = require "socket"
local refser = require "refser"

local ClientCore = class()
ClientCore.__name = "luartm client"

function ClientCore:__init(options)
	options = options or {}
	self.host = options.host or "127.0.0.1"
	self.port = 7733
	self.refser = refser.new()
	self.table = {}
	self.refser:save(self.table)
end

ClientCore.commandlist = {
	index = 1,
	newindex = 2,
	flush = 3,
	gettop = 4
}

function ClientCore:connect()
	self.socket = assert(socket.connect(self.host, self.port))
end

function ClientCore:execute(...)
	local request = assert(self.refser:save(...))
	assert(self.socket:send(request .. "\r\n"))
	local responce = assert(self.socket:receive())
	local responce_tuple = table.pack(assert(self.refser:load(responce)))
	assert(responce_tuple[2], responce_tuple[3])
	return table.unpack(responce_tuple, 3, responce_tuple[1] + 1)
end

function ClientCore:index(t, k)
	return self:execute(self.commandlist.index, t, k)
end

function ClientCore:newindex(t, k, v)
	return self:execute(self.commandlist.newindex, t, k, v)
end

function ClientCore:flush()
	return self:execute(self.commandlist.flush)
end

function ClientCore:gettop()
	return self:execute(self.commandlist.gettop)
end

function ClientCore:close()
	if self.socket then
		self.socket:close()
	end
end

return ClientCore

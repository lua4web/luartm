local class = require "30log"
local socket = require "socket"
local refser = require "refser"

local client = class()
client.__name = "luartm client"

function client:__init(options)
	options = options or {}
	self.host = options.host or "127.0.0.1"
	self.port = 7733
	self.refser = refser.new()
	self.table = {}
	self.refser:save(self.table)
end

client.commandlist = {
	index = 1,
	newindex = 2,
	flush = 3,
	gettop = 4
}

function client:connect()
	self.socket = assert(socket.connect(self.host, self.port))
end

function client:execute(...)
	local request = assert(self.refser:save(...))
	assert(self.socket:send(request .. "\r\n"))
	local responce = assert(self.socket:receive())
	local responce_tuple = table.pack(assert(self.refser:load(responce)))
	assert(responce_tuple[2], responce_tuple[3])
	return table.unpack(responce_tuple, 3, responce_tuple[1] + 1)
end

function client:index(t, k)
	return self:execute(self.commandlist.index, t, k)
end

function client:newindex(t, k, v)
	return self:execute(self.commandlist.newindex, t, k, v)
end

function client:flush()
	return self:execute(self.commandlist.flush)
end

function client:gettop()
	return self:execute(self.commandlist.gettop)
end

function client:disconnect()
	if self.socket then
		self.socket:close()
	end
end

return client

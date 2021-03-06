local class = require "30log"
local ptable = require "ptable"
local socket = require "socket"
local copas = require "copas"

local Server = class()

local Handler = class()

function Handler:__init(socket)
	self.socket = socket
	self.host, self.port = socket:getpeername()
end

function Handler:send(s)
	if Server.debug then
		print("Sending " .. s)
	end
	
	copas.send(self.socket, s .. "\r\n")
end

function Handler:receive()
	local s = copas.receive(self.socket)
	
	if Server.debug then
		if s then
			print("Received " .. s)
		end
	end
	
	return s
end

Server.debug = false

function Server:__init(options)
	self.options = options or {}
	self.host = self.options.host or "127.0.0.1"
	self.port = self.options.port or 7733
	self.filename = self.options.filename
	
	self.ptable = ptable(self.filename)
	self.table = self.ptable.table
	self.refser = self.ptable.refser
end

function Server:start()
	self.server = assert(socket.bind(self.host, self.port))
	
	local function handler(skt)
		return self:handle(Handler(skt))
	end
	
	copas.addserver(self.server, handler)
	
	copas.loop()
end

Server.commandlist = {
	[1] = "index",
	[2] = "newindex",
	[3] = "flush",
	[4] = "gettop"
}

function Server:gettop()
	return true, self.refser.context.n
end

function Server:execute(s)
	local ok, code, a, b, c = self.refser:load(s)
	
	if not ok then
		return false, code
	end
	
	if not ((type(code) == "number") and (code == code)) then
		return false, "opcode must be a number"
	end
	
	if not self.commandlist[code] then
		return false, "unknown opcode " .. code
	end
	
	return self[self.commandlist[code]](self, s, a, b, c)
end

function Server:index(s, t, k)
	if type(t) ~= "table" then
		return false, "attempt to index nontable"
	end
	
	if (k == nil) or (k ~= k) then
		return false, "attempt to use nil or NaN as key"
	end
	
	return true, t[k]
end

function Server:newindex(s, t, k, v)
	if type(t) ~= "table" then
		return false, "attempt to index nontable"
	end
	
	if (k == nil) or (k ~= k) then
		return false, "attempt to use nil or NaN as key"
	end
	
	self.ptable:log(s:sub(3))
	t[k] = v
	
	return true
end

function Server:flush()
	self.ptable:flush()
	
	return true
end

function Server:handle(h)
	if Server.debug then
		print("Accepted connection from " .. h.host .. ":" .. h.port)
	end
	
	local s
	local ok, a, b
	while true do
		s = h:receive()
		if s then
			ok, a, b = self:execute(s)
			h:send(self.refser:save(ok, a, b))
			if not ok then
				break
			end
		else
			break
		end
	end
	
	if Server.debug then
		print("Closed connection.")
	end
end

return Server

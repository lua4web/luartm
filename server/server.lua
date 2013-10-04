local class = require "30log"
local ptable = require "ptable"
local socket = require "socket"
local copas = require "copas"


local Handler = class()

function Handler:__init(socket)
	self.socket = socket
end

function Handler:send(s)
	print("Sending " .. s)
	
	copas.send(self.socket, s .. "\r\n")
end

function Handler:receive()
	local s = copas.receive(self.socket)
	
	if s then
		print("Received " .. s)
	end
	
	return s
end

function Handler:getpeername()
	return ("%s:%d"):format(self.socket:getpeername())
end

local server = class()

function server:__init(options)
	self.options = options or {}
	self.host = self.options.host or "127.0.0.1"
	self.port = self.options.port or 7733
end

function server:boot()
	self.ptable = ptable(self.options)
	self.table = self.ptable.table
	self.refser = self.ptable.refser
end

function server:start()
	self.server = socket.bind(self.host, self.port)
	
	local function handler(skt)
		return self:handle(Handler(skt))
	end
	
	copas.addserver(self.server, handler)
	
	copas.loop()
end

function server:handshake(h)
	-- send version?

	h:send(tostring(self.refser.context.n))
end

function server:handle(h)
	print("Accepted connection from " .. (h:getpeername()))
	
	self:handshake(h)
	
	local s
	local ok, code, t, k, v
	while true do
		s = h:receive()
		if s then
			ok, code, t, k, v = self.refser:load(s)
			if not ok then
				h:send(code)
				break
			end
			
			if code == 1 then
				h:send(self.refser:save(true, t[k]))
			elseif code == 2 then
				self.ptable:rawlog(s:sub(3))
				self.ptable:newindex(t, k, v)
				h:send(self.refser:save(true))
			end
		else
			break
		end
	end
	
	print("Closed connection.")
end

return server

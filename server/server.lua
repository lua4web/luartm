local class = require "30log"
local ptable = require "ptable"
local socket = require "socket"
local copas = require "copas"

local server = class()

function server:__init(options)
	self.options = options or {}
	self.host = self.options.host or "127.0.0.1"
	self.port = self.options.port or 7733
	self.options.dontlog = true
end

function server:boot()
	self.ptable = ptable(self.options)
	self.table = self.ptable.table
	self.refser = self.ptable.refser
end

function server:start()
	self.server = socket.bind(self.host, self.port)
	
	local function handler(skt)
		return self:handle(copas.wrap(skt))
	end
	
	copas.addserver(self.server, handler)
	
	copas.loop()
end

function server:handle(skt)
	print("Accepted connetion...")

	local s
	local ok, code, t, k, v
	while true do
		s = skt:receive()
		if s then
			print("Received " .. s)
			
			ok, code, t, k, v = self.refser:load(s)
			if not ok then
				skt:send(code)
				skt:send("\r\n")
				break
			end
			
			if code == 1 then
				skt:send(self.refser:save(true, t[k]))
				skt:send("\r\n")
			elseif code == 2 then
				self.ptable:rawlog(s:sub(3))
				t[k] = v
				skt:send(self.refser:save(true))
				skt:send("\r\n")
			end
		else
			break
		end
	end
	
	print("Closed connetion.")
end

return server

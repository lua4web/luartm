local class = require "30log"
local socket = require "socket"
local refser = require "refser"

local client = class()

function client:__init(options)
	options = options or {}
	self.host = options.host or "127.0.0.1"
	self.port = 7733
	self.refser = refser.new()
	self.context = self.refser.context
	self.table = {}
	self.refser:save(self.table)
	
	self.itemmt = {}
	function self.itemmt.__index(t, k)
		local msg = self.refser:save(1, t, k)
		self.socket:send(msg)
		self.socket:send("\r\n")
		return select(3, self.refser:load(self.socket:receive()))
	end
	
	function self.itemmt.__newindex(t, k, v)
		local msg = self.refser:save(2, t, k, v)
		self.socket:send(msg)
		self.socket:send("\r\n")
		self.socket:receive()
	end
	
	self.contextmt = {}
	function self.contextmt.__index(t, k)
		if type(k) == "number" then
			local newtable = {}
			setmetatable(newtable, self.itemmt)
			rawset(t, k, newtable)
			rawset(t, newtable, k)
			return newtable
		end
	end
	
	setmetatable(self.table, self.itemmt)
	setmetatable(self.context, self.contextmt)
end

function client:connect()
	self.socket = socket.connect(self.host, self.port)
	self.refser.context.n = tonumber(self.socket:receive())
end

function client:disconnect()
	if self.socket then
		self.socket:close()
	end
end

return client

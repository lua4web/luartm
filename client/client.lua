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
	
	setmetatable(self.table, self.itemmt)
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

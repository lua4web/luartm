local class = require "30log"
local socket = require "socket"
local refser = require "refser"

local client = class()

function client:__init(options)
	options = options or {}
	self.host = options.host or "127.0.0.1"
	self.port = 7733
	self.refser = refser.new{
		doublecontext = true
	}
	self.context = self.refser.context
	self.table = {}
	self.refser:save(self.table)
end

function client:connect()
	self.socket = socket.connect(self.host, self.port)
end

function client:disconnect()
	if self.socket then
		self.socket:close()
	end
end

function client:index()

function client

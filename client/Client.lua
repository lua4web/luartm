local ClientCore = require "ClientCore"

local Client = ClientCore:extends()
Client.__name = "luartm client wrapper"

function Client:__init(options)
	self.super.__init(self, options)
	
	self.itemmt = {}
	function self.itemmt.__index(t, k)
		return self:index(t, k)
	end
	
	function self.itemmt.__newindex(t, k, v)
		return self:newindex(t, k, v)
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
	
	function self.contextmt.__newindex(t, k, v)
		local newtable
		if type(k) == "table" then
			newtable = k
		elseif type(v) == "table" then
			newtable = v
		end
		
		if newtable then
			setmetatable(newtable, self.itemmt)
		end
		
		rawset(t, k, v)
	end
	
	setmetatable(self.table, self.itemmt)
	setmetatable(self.refser.context, self.contextmt)
end

function Client:connect()
	self.super.connect(self)
	self.refser.context.n = self:gettop()
end

return Client

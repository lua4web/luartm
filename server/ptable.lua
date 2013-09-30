local lfs = require "lfs"
local stringx = require "pl.stringx"
local class = require "30log"
local refser = require "refser"

local ptable = class()

function ptable:__init(options)
	if not options or type(options) == "string" then
		self.base = options or "ptable"
	else
		self.base = options.base or "ptable"
		self.savesnapshots = options.savesnapshots
		self.autoflushrate = options.autoflushrate
	end
	
	self:getfilecount()
	
	self:setmts()
	
	self.refser = refser.new()
	self:resetcontext()
	
	self.counter = 0
	
	self:boot()
	
	self.handler = self:open "a"
end

function ptable:getfilecount()
	self.filecount = 0
	local id
	for filename in lfs.dir(".") do
		if lfs.attributes(filename, "mode") == "file" then
			if stringx.startswith(filename, self.base) then
				id = filename:sub(#self.base + 1)
				if stringx.isdigit(id) then
					id = tonumber(id)
					if id > self.filecount then
						self.filecount = id
					end
				end
			end
		end
	end
end

function ptable:setmts()
	self.itemmt = {}
	function self.itemmt.__newindex(t, k, v)
		self.handler:write(self.refser:save(t, k, v), "\n")
		
		self.handler:flush()
		
		rawset(t, k, v)
		
		if self.autoflushrate then	
			self.counter = (self.counter + 1) % self.autoflushrate
			if self.counter == 0 then
				self:flush()
			end
		end
	end
	
	self.contextmt = {}
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
end

function ptable:resetcontext()
	self.refser:setcontext(setmetatable({}, self.contextmt))
end

function ptable:boot()
	local readhandler = self:open "r"
	
	if not readhandler then
		self.table = {}
		self:flush()
	else
		local snapshot = readhandler:read()
		local ok
		ok, self.table = self.refser:load(snapshot)
		
		if not ok then
			self.filecount = self.filecount - 1
			return self:boot()
		end
		
		local entry, ok, t, k, v
		while true do
			entry = readhandler:read()
			if not entry then
				break
			else
				ok, t, k, v = self.refser:load(entry)
				
				if not ok then
					self.filecount = self.filecount - 1
					return self:flush()
				end
				
				rawset(t, k, v)
			end
		end
		
		readhandler:close()
	end
end
	

function ptable:flush()
	self.filecount = self.filecount + 1
	self:resetcontext()
	
	local writehandler = self:open "w"
	writehandler:write(self.refser:save(self.table), "\n")
	writehandler:close()
	
	if self.handler then
		self.handler:close()
	end
	
	if not self.savesnapshots then
		os.remove(self.base .. (self.filecount - 1))
	end
	
	self.handler = self:open "a"
end

function ptable:open(mode)
	return io.open(self.base .. self.filecount, mode)
end

function ptable:rawlog(s)
	self:handler:write(s, "\n")
	self:handler:flush()
end

return ptable

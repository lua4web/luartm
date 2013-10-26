local class = require "30log"
local refser = require "refser"

local ptable = class()

function ptable:__init(filename)
	self.filename = filename or "ptable"
	self.tempfilename = self.filename .. "~"
	self.refser = refser.new()
	self:boot()
end

function ptable:resetcontext()
	if self.refser.context.n > 0 then
		self.refser:setcontext({})
	end
end

function ptable:boot()
	self:resetcontext()
	
	local readhandler = io.open(self.filename, "r")
	
	if not readhandler then
		self.table = {}
		self:flush()
	else
		local snapshot = readhandler:read()
		local ok
		ok, self.table = self.refser:load(snapshot)
		
		assert(ok, "failed to load snapshot from " .. self.filename)
		
		local entry, ok, t, k, v
		while true do
			entry = readhandler:read()
			if not entry then
				break
			else
				ok, t, k, v = self.refser:load(entry)
				
				if ok ~= 3 then
					self:flush()
					break
				end
				
				rawset(t, k, v)
			end
		end
		
		readhandler:close()
	end
end

function ptable:flush()
	if self.appendhandler then
		self.appendhandler:close()
		self.appendhandler = nil
	end
	
	self:resetcontext()
	
	local writehandler = io.open(self.tempfilename, "w")
	writehandler:write(self.refser:save(self.table), "\n")
	writehandler:close()
	
	os.rename(self.tempfilename, self.filename)
end

function ptable:log(s)
	if not self.appendhandler then
		self.appendhandler = io.open(self.filename, "a")
	end
	
	self.appendhandler:write(s, "\n")
	self.appendhandler:flush()
end

return ptable

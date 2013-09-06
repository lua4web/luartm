local refser = require "refser"
local core = --[[require "lrtm.server.core"]]require "core"

-- extened core with raw string commands api
local coreapi = core:extends()

coreapi.commands = {
	[1] = "index";
	[2] = "newtable";
	[3] = "newindex";
}

function coreapi:__init()
	coreapi.super.__init(self)
	self.refser = refser.new{
		doublecontext = true
	}
	self.context = self.refser.context
end

-- loads table
function coreapi:boot()
	coreapi.super.boot(self)
	self.refser:save(self.table)
	return true
end

-- runs command
function coreapi:run(command, ...)
	if self.debug then print("Running ", command, ...) end
	if type(command) ~= "number" then
		return nil, ("attempt to use a %s value as command code"):format(type(command))
	elseif command ~= command then
		return nil, "attempt to use NaN as command code"
	elseif not self.commands[command] then
		return nil, ("unknown command code %s"):format(tostring(command))
	else
		return self[self.commands[command]](self, ...)
	end
end

-- decodes string
function coreapi:decode(s)
	return self.refser:load(s)
end

-- encodes tuple
function coreapi:encode(...)
	if self.debug then print("Encoding ", ...) end
	local s, err = self.refser:save(...)
	if not s then
		return s, err
	else
		return true, s
	end
end

-- returns encoded message or error report
function coreapi:encodemsg(...)
	local ok, s = self:encode(...)
	if not ok then
		return self:encode(ok, s)
	else
		return s
	end
end

-- executes string
-- returns encoded result
function coreapi:execute(s)
	if self.debug then print("Executing " .. s) end
	local commandtuple = table.pack(self:decode(s))
	if self.debug then print("Command tuple:") end
	for i, v in ipairs(commandtuple) do
		if self.debug then print(i, ":", v) end
	end
	if not commandtuple[1] then
		return self:encodemsg(commandtuple[1], commandtuple[2])
	else
		local resulttuple = table.pack(self:run(table.unpack(commandtuple, 2, 1 + commandtuple[1])))
		if not resulttuple[1] then
			return self:encodemsg(resulttuple[1], resulttuple[2])
		else
			return self:encodemsg(table.unpack(resulttuple, 1, 1 + resulttuple[1]))
		end
	end
end

return coreapi

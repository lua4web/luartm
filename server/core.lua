local class = require "30log"
local refser = require "refser"

-- core server class
-- all functions must return true + result in case of success, false(nil) + error message otherwise
-- commands must return count of returned values as first return value(in case of success)
local core = class()

core.commands = {
	[1] = "index";
	[2] = "newtable";
	[3] = "newindex";
}

function core:__init()
	self.refser = refser.new{
		doublecontext = true
	}
	self.context = self.refser.context
	
	self.newtables = {}
end

-- loads table
function core:boot()
	self.table = {}
	self.refser:save(self.table)
	return true
end

-- runs command
function core:run(command, ...)
	print("Running ", command, ...)
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
function core:decode(s)
	return self.refser:load(s)
end

-- encodes tuple
function core:encode(...)
	print("Encoding ", ...)
	local s, err = self.refser:save(...)
	if not s then
		return s, err
	else
		return true, s
	end
end

-- returns encoded message or error report
function core:encodemsg(...)
	local ok, s = self:encode(...)
	if not ok then
		return select(2, self:encode(ok, s))
	else
		return s
	end
end

-- executes string
-- returns encoded result
function core:execute(s)
	print("Executing " .. s)
	local commandtuple = table.pack(self:decode(s))
	print("Command tuple:")
	for i, v in ipairs(commandtuple) do
		print(i, ":", v)
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

-- checks whether x is a known value
function core:isknown(x)
	return type(x) ~= "table" or self.context[x]
end

-- checks whether t is a table known to server and k isn't nil, NaN or unknown value
function core:canindex(t, k)
	if type(t) ~= "table" then
		return nil, ("attempt to index a %s value"):format(type(t))
	elseif not self:isknown(t) then
		return nil, "attempt to index unknown table"
	elseif k == nil then
		return nil, "attempt to use nil as key"
	elseif k ~= k then
		return nil, "attempt to use NaN as key"
	elseif not self:isknown(k) then
		return nil, "attempt to use unknown table as key"
	else 
		return true
	end
end

-- perfoms simple read
function core:index(t, k)
	print("Indexing ", t, k)
	local ok, err = self:canindex(t, k)
	if not ok then
		return ok, err
	else
		return 1, rawget(t, k)
	end
end

-- creates new table in the context
-- returns its id
function core:newtable()
	print("Newtable")
	local newtable = {}
	self.refser:save(newtable)
	self.newtables[newtable] = true
	return 1, self.context.n
end

-- perfoms write
function core:newindex(t, k, v)
	print("Newindex", t, k, v)
	local ok, err = self:canindex(t, k)
	if not ok then
		return ok, err
	elseif not self:isknown(v) then
		return nil, "attempt to use unknown table as value"
	else
		rawset(t, k, v)
		return 0
	end
end

return core

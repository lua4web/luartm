local class = require "30log"

-- core server class
local core = class()

core.debug = true

function core:__init()
	
end

-- loads table
function core:boot()
	self.table = {}
	return true
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

-- perfoms read
function core:index(t, k)
	if self.debug then print("Indexing ", t, k) end
	local ok, err = self:canindex(t, k)
	if not ok then
		return ok, err
	else
		return 1, t[k]
	end
end

-- perfoms write
function core:newindex(t, k, v)
	if self.debug then print("Newindex", t, k, v) end
	local ok, err = self:canindex(t, k)
	if not ok then
		return ok, err
	elseif not self:isknown(v) then
		return nil, "attempt to use unknown table as value"
	else
		t[k] = v
		return 0
	end
end

return core

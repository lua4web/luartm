local core = --[[require "lrtm.server.core"]]require "core"

-- extened core with persistance
local corepersist = core:extends()

corepersist.commands[10] = "flush"

function corepersist:__init()
	coreapi.super.__init(self)
	-- ...
end

-- loads table
function corepersist:boot()
	-- ... 
end

return coreapi

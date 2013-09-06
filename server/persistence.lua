local coreapi = --[[require "lrtm.server.coreapi"]]require "coreapi"

-- extened core with persistance
local corepersist = coreapi:extends()

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

local IsValid = IsValid
local ipairs = ipairs
timer.Destroy('HostnameThink')

function ENTITY:IsConstrained()
	local c = self.Constraints
	if c then
		for k, v in ipairs(c) do
			if v:IsValid() then
				return true
			end
			c[k] = nil
		end
	end
	return false
end
-- красиво но не так как надо
//_G.RunString 		  = function() end -- We dont use these.
//_G.RunStringЕx 		= function() end
//_G.CompileString 	= function() end
//_G.CompileFile 		= function() end

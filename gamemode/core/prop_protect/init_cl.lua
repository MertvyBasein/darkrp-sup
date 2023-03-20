rp.pp = rp.pp or {}

--
-- Hooks
--
function GM:CanTool(pl, trace, tool)
	local ent = trace.Entity
	return IsValid(ent) and (ent:GetNetVar('PropIsOwned') == true)
end

hook('PhysgunPickup', 'pp.PhysgunPickup', function(pl, ent)
	return false
end)

function GM:GravGunPunt(pl, ent)
	return pl:IsSuperAdmin()
end

function GM:GravGunPickupAllowed(pl, ent)
	return false
end

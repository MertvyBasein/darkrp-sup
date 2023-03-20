local Tag = "propkill"
AddCSLuaFile()
if CLIENT then
	hook("PhysgunPickup", Tag, function(pl, ent)
		if not ent:IsWorld() then return end
		ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end)

	return
end

do
	local ignore

	hook("PhysgunPickup", Tag, function(pl, ent)
		if ent:IsPlayer() then return end

		if canTouch and not ent:CreatedByMap() and not (ent:GetCollisionGroup() == COLLISION_GROUP_WORLD) then
			ent.Old_ColGroup = ent:GetCollisionGroup() or COLLISION_GROUP_NONE
			ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		end
	end)
end

hook("PlayerSpawnedVehicle", Tag, function(pl, ent)
	ent:SetCollisionGroup(COLLISION_GROUP_PLAYER)
end)

hook("PlayerEnteredVehicle", Tag, function(pl, ent)
	ent:SetCollisionGroup(COLLISION_GROUP_PLAYER)
end)

hook("PlayerLeaveVehicle", Tag, function(pl, ent)
	timer.Simple(1, function()
		if IsValid(ent) then
			ent:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		end
	end)
end)

hook("PhysgunDrop", Tag, function(pl, ent)
	if ent:IsPlayer() then return end
	ent:SetPos(ent:GetPos())

	if ent.Old_ColGroup then
		ent:SetCollisionGroup(ent.Old_ColGroup)
		ent.Old_ColGroup = nil
	end

	local phys = ent:GetPhysicsObject()

	if IsValid(phys) then
		phys:AddAngleVelocity(phys:GetAngleVelocity() * -1)
	end
end)
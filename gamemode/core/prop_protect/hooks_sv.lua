local oktools = {
	["#Tool.advdupe2.name"] = true,
	-- ["#Tool.stacker.name"] 	= true
}
hook('PlayerSpawnProp', 'pp.PlayerSpawnProp', function(pl, mdl)
	local tool = pl:GetTool()
	if (pl:IsSuperAdmin()) then return true end
	if pl.lastPropSpawn and (pl.lastPropSpawn > CurTime()) and ((tool == nil) or not oktools[tool.Name]) then
		rp.Notify(pl,1,'Чуть-чуть медленнее')
		return false
	end

	pl.lastPropSpawn 		= CurTime() + 2
end)

local FindInSphere = ents.FindInSphere

hook('PlayerSpawnedVehicle', 'pp.PlayerSpawnedVehicle', function(pl, ent)
	ent:CPPISetOwner(pl)
	return pl:IsSuperAdmin()
end)

hook('PlayerSpawnedSENT', 'pp.PlayerSpawnedSENT', function(pl, ent)
	ent:CPPISetOwner(pl)
end)

function GM:CanTool(pl, trace, tool)
	return rp.pp.PlayerCanTool(pl, trace.Entity, tool)
end

local aaitem = {
	["gmod_button"] = true,
	["spawned_money"] = true,
	["keypad"] = true,
	["gmod_light"] = true,
}
--
hook('PhysgunPickup', 'pp.PhysgunPickup', function(pl, ent)
	if ent:IsVehicle() || ent:GetClass() == 'gmod_sent_vehicle_fphysics_wheel' then return false end
	--if (ent.parent or ent:GetClass() == 'metahub_camera') and pl:IsSuperAdmin() then return true end
end)

local vec = Vector(0,0,0)

function GM:GravGunOnPickedUp(pl, ent)
	if ent.UseRagdoll then return true end
	if (pl:IsSuperAdmin()) then return true end
	if (string.match(ent:GetClass(), "ch_")) then return true end

	if ent:IsConstrained() then
		DropEntityIfHeld(ent)
	end
end

function GM:GravGunPunt(pl, ent)
	if (pl:IsSuperAdmin()) then return true end

	DropEntityIfHeld(ent)
	return false
end

function GM:OnPhysgunReload(wep, pl)
	return false
end

function GM:GravGunPickupAllowed(pl, ent)
	if (ent:IsValid() and ent.GravGunPickupAllowed) then
		return ent:GravGunPickupAllowed(pl)
	end

	return true
end

local nodamage = {
	prop_fix		= true,
	prop_physics 	= true,
	prop_dynamic 	= true,
	donation_box 	= true,
	gmod_winch_controller = true,
	gmod_poly 		= true,
	gmod_button 	= true,
	gmod_balloon 	= true,
	gmod_cameraprop = true,
	gmod_emitter 	= true,
	gmod_light 		= true,
	keypad          = true,
    gmod_poly       = true,
    ent_picture 	= true
}

local nocolide = {
	prop_fix		= true,
	prop_physics 		= true,
	prop_dynamic 		= true,
	func_door 			= true,
	func_door_rotating	= true,
	prop_door_rotating	= true,
	spawned_food		= false,
	func_movelinear 	= true,
	ent_picture 		= true
}


hook.Add('PlayerShouldTakeDamage', 'AntiPK_PlayerShouldTakeDamage', function(victim, attacker)
	if nodamage[attacker:GetClass()] or (victim:IsPlayer() and victim:InVehicle()) then
		return false
	end
end)

--hook.Add('EntityTakeDamage', 'AntiPK.EntityTakeDamage', function(pl, dmginfo)
--	if (dmginfo:GetDamageType() == DMG_CRUSH) then
--		return true
--	end
--end)

hook.Add('ShouldCollide', 'AntiPK_NoColide', function(ent1, ent2)
	if IsValid(ent1) and IsValid(ent2) and ent1:GetClass() == 'metahub_seed' and ent2:IsPlayer() then return false end
	if IsValid(ent1) and IsValid(ent2) and nocolide[ent1:GetClass()] and nocolide[ent2:GetClass()] or ent2:IsVehicle() then
		return false
	end
end)

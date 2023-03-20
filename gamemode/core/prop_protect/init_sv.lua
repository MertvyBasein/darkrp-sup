local string 	= string
local IsValid 	= IsValid
local util 		= util

rp.pp = rp.pp or {}

local toolFuncs = {
	[0] = function(pl)
		return true
	end,
	[1] = function(pl)
		if deadlib.GetHigherRanks("vip", pl:GetUserGroup()) then
			return true
		else
			return false
		end
	end,
	[2] = PLAYER.IsAdmin,
	[3] = PLAYER.IsSuperAdmin,
	[4] = function(pl)
		local BuilderPackage = tobool(pl:GetPData('BuilderPackage', false))
		local isVIP = deadlib.GetHigherRanks("vip", pl:GetUserGroup())

		if BuilderPackage or isVIP or pl:IsSuperAdmin() then
			return true
		else
			return false
		end
	end
}

rp.pp.BlockedTools = {
	['button']		= 0,
	['camera']		= 0,
	['colour']		= 0,
	['fading_door'] = 0,
	['keypad']		= 0,
	['ledscreens']		= 0,
	['lamp']		= 3,
	['light']		= 0,
	['material']	= 0,
	['nocollide']	= 0,
	['precision']	= 0,
	['remover']		= 0,
	['stacker']		= 0,
	['textscreen']	= 0,
	['weld']		= 0,
	['advdupe2']	= 4,
}

function rp.pp.PlayerCanManipulate(pl, ent)
	if pl.sBanned then
		return false
	end

	if IsValid(ent:CPPIGetOwner()) then
		return true
	end

	return (ent:CPPIGetOwner() == pl) or (pl:HasPermission("can_noclip") and IsValid(ent:CPPIGetOwner())) or pl:IsSuperAdmin()
end


local can_dupe = {
	['prop_physics']	= true,
	['keypad']			= true
}


function rp.pp.PlayerCanTool(pl, ent, tool)
	if pl.sBanned then
		return false
	end
	if ent.parent and pl:IsSuperAdmin() then return true end

	local tool = tool:lower()

	if rp.pp.BlockedTools[tool] then
		local canTool = toolFuncs[rp.pp.BlockedTools[tool]](pl)
		if not canTool then
			rp.Notify(pl, NOTIFY_ERROR, 'Недостаточно прав использовать "#" инструмент!', tool)
			return canTool
		end
	end

	local EntTable =
		(tool == "adv_duplicator" and pl:GetActiveWeapon():GetToolObject().Entities) or
		(tool == "advdupe2" and pl.AdvDupe2 and pl.AdvDupe2.Entities) or
		(tool == "duplicator" and pl.CurrentDupe and pl.CurrentDupe.Entities)

	if EntTable then
		for k, v in pairs(EntTable) do
			if not can_dupe[string.lower(v.Class)] then
				rp.Notify(pl, NOTIFY_ERROR, 'Вы не можете создавать дупликаты где содержится - '..v.Class)
				return false
			end
		end
	end

	if ent:IsWorld() then
		return true
	elseif not IsValid(ent) then
		return false
	end

	local cantool = rp.pp.PlayerCanManipulate(pl, ent)

	if (cantool == true) then
		hook.Call('PlayerToolEntity', GAMEMODE, pl, ent, tool)
	end

	return cantool
end

--
-- Workarounds
--
PLAYER._AddCount = PLAYER._AddCount or PLAYER.AddCount
function PLAYER:AddCount(t, ent)
	if IsValid(ent) then
		ent:CPPISetOwner(self)
	end
	return self:_AddCount(t, ent)
end



ENTITY._SetPos = ENTITY._SetPos or ENTITY.SetPos
function ENTITY.SetPos(self, pos)
	//if IsValid(self) and (not util.IsInWorld(pos)) and (not self:IsPlayer()) and (self:GetClass() ~= 'gmod_hands') and ( not string.find(self:GetClass(), 'ch_')) and ( not self:GetClass() == "path_track") then
	//	self:Remove()
	//	return
	//end
	return self:_SetPos(pos)
end

local PHYS = FindMetaTable('PhysObj')
PHYS._SetPos = PHYS._SetPos or PHYS.SetPos
function PHYS.SetPos(self, pos)

  //if IsValid(self) and (not util.IsInWorld(pos)) then
  //
  //	self:Remove()
  //	return
  //end
	return self:_SetPos(pos)
end

ENTITY._SetAngles = ENTITY._SetAngles or ENTITY.SetAngles
function ENTITY:SetAngles(ang)
	if not ang then return self:_SetAngles(ang) end
	ang.p = ang.p % 360
	ang.y = ang.y % 360
	ang.r = ang.r % 360
	return self:_SetAngles(ang)
end

if undo then
	local AddEntity, SetPlayer, Finish =  undo.AddEntity, undo.SetPlayer, undo.Finish
	local Undo = {}
	local UndoPlayer
	function undo.AddEntity(ent, ...)
		if type(ent) ~= "boolean" and IsValid(ent) then table.insert(Undo, ent) end
		AddEntity(ent, ...)
	end

	function undo.SetPlayer(ply, ...)
		UndoPlayer = ply
		SetPlayer(ply, ...)
	end

	function undo.Finish(...)
		if IsValid(UndoPlayer) then
			for k,v in pairs(Undo) do
				v:CPPISetOwner(UndoPlayer)
			end
		end
		Undo = {}
		UndoPlayer = nil

		Finish(...)
	end
end

duplicator.BoneModifiers = {}
duplicator.EntityModifiers['VehicleMemDupe'] = nil
for k, v in pairs(duplicator.ConstraintType) do
	if (k ~= 'Weld') then
		duplicator.ConstraintType[k] = nil
	end
end
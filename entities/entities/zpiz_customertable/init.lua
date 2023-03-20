AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 18
	local ent = ents.Create(self.ClassName)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	ent:SetAngles(angle)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	ent:CPPISetOwner(ply)

	return ent
end

ENT.Initialize 	= ENTITY.CustomerTable_Initialize
ENT.StartTouch 	= ENTITY.CustomerTable_StartTouch
ENT.OnRemove 	= ENTITY.CustomerTable_OnRemove

function ENT:Setowning_ent(ply)
	self:CPPISetOwner(ply)
end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("FoodMode::OpenCashRegMenu")
util.AddNetworkString("FoodMode::CashoutMoney")
util.AddNetworkString("FoodMode::ChangeState")



function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 30
	local ent = ents.Create(self.ClassName)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw + 90, 0)
	ent:SetAngles(angle)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	ent:CPPISetOwner(ply)

	return ent
end

ENT.Initialize = ENTITY.CashRegister_Initialize
ENT.AcceptInput = ENTITY.CashRegister_AcceptInput
ENT.OnRemove = ENTITY.CashRegister_OnRemove

function ENT:Setowning_ent(ply)
	self:CPPISetOwner(ply)
end

function ENT:OnTakeDamage(dmg)
	//zpiz.f.Sign_TakeDamage(self, dmg)
end

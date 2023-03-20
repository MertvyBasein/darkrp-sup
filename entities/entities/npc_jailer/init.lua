AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/hts/comradebear/pm0v3/player/wss/schwarz/co/m38_s1_05_npc.mdl')	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetHullSizeNormal()

	self:CapabilitiesAdd(bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD))
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()

	self:SetMaxYawSpeed(90)
end

function ENT:Use( activator, caller )
    if self.Touched and self.Touched > CurTime() then return end
	self.Touched = CurTime() + 2;
	--if not activator:IsCP() then rp.Notify(activator,1,'Доступно только сотрудникам ГО!') return end
	for k,v in pairs(ents.FindInSphere(activator:GetPos(), 150)) do
		if v:IsPlayer() and v:IsHandcuffed() then
			jail = v
		end
	end
	if not activator:isCP() then return end
	if jail == nil then rp.Notify(activator,1,'Человек должен быть рядом!') return end
	net.Start("MetaHub.JailPlayer")
		net.WriteEntity(jail)
	net.Send(activator)
	jail = nil
end
plib.IncludeCL 'cl_init.lua'
plib.IncludeSH 'shared.lua'

util.AddNetworkString('metahub.regelection')

function ENT:Initialize()
	self:SetModel('models/kayf/humans/group02/man_04.mdl')

	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetMaxYawSpeed(90)

	self:SetTrigger(true)
end

function ENT:Use(activator)
	if self:GetPos():Distance(activator:GetPos()) > 100 then return end
	
	net.Start('metahub.regelection')
	net.Send(activator)
end
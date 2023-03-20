plib.IncludeCL 'cl_init.lua'
plib.IncludeSH 'shared.lua'

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

	self:PhysWake()
end

function ENT:OnTakeDamage(dmg)
	self:Remove()
end

function ENT:Use(activator,caller)
	if activator:IsBanned() then return end
	activator:AddHunger(self:GetTable().FoodEnergy or 1)
	self:Remove()
end

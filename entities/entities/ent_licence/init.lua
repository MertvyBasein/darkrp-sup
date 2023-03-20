plib.IncludeCL 'cl_init.lua'
plib.IncludeSH 'shared.lua'

function ENT:Initialize()
	self:SetModel('models/props_lab/clipboard.mdl')

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysWake()
end

function ENT:Use(pl)
	if pl:IsBanned() then return end

	rp.Notify(pl, NOTIFY_SUCCESS, 'Вы активировали лицензию на оружие.')
	pl:SetNetVar('HasGunlicense', true)

	self:Remove()
end
plib.IncludeCL 'cl_init.lua'
plib.IncludeSH 'shared.lua'

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:PhysWake()

	self:SetNWString('class', self.weaponclass)

	--self:SetTrigger(true)
end

util.AddNetworkString('gun.pick')

net.Receive('gun.pick', function(_, ply)
	local ent = net.ReadEntity()
	if !IsValid(ent) then return end
	if ent:GetClass() ~= 'spawned_weapon' then return end
	if ply:GetPos():Distance(ent:GetPos()) > 80 then return end

	ply:Give(ent.weaponclass)

	ent:Remove()
end)

function ENT:Use(activator, caller)
	--print(activator:GetPos():Distance(self:GetPos()))
	/*if type(self.PlayerUse) == "function" then
		local val = self:PlayerUse(activator, caller)
		if val ~= nil then return val end
	elseif self.PlayerUse ~= nil then
		return self.PlayerUse
	end

	local class = self.weaponclass
	local weapon = ents.Create(class)

	if not weapon:IsValid() then return false end

	if not weapon:IsWeapon() then
		weapon:SetPos(self:GetPos())
		weapon:SetAngles(self:GetAngles())
		weapon:Spawn()
		weapon:Activate()
		self:Remove()
		return
	end

	local CanPickup = hook.Call("PlayerCanPickupWeapon", GAMEMODE, activator, weapon)
	if not CanPickup then return end
	weapon:Remove()

	activator:Give(class)
	weapon = activator:GetWeapon(class)

  if self.clip1 then
  	weapon:SetClip1(self.clip1)
  	weapon:SetClip2(self.clip2 or -1)
  end*/
	
// Так-же от дюпа можно избавиться с помощью SetAmmo
//	activator:GiveAmmo(self.ammoadd or 0, weapon:GetPrimaryAmmoType())

	//self:Remove()
end

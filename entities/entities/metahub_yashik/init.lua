AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self:SetModel("models/Items/ammocrate_smg1.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self.BoxOpen = false
end;

function ENT:Use(ply)

    local seq 

	if self.BoxOpen then return end
	seq = self:LookupSequence("Open")
	self:SetSequence( seq )
	self.BoxOpen = true

    timer.Simple(.3,function()
		if !IsValid(self) then return end
		if !self.BoxOpen then return end 
		seq = self:LookupSequence("Close")
		self:SetSequence( seq )

		ply:GiveAmmo(25, 3) -- Пистолет
		ply:GiveAmmo(40, 4) -- SMG
		ply:GiveAmmo(12, 5) -- 357
		ply:GiveAmmo(60	, 1) -- Пистолет
		ply:GiveAmmo(16, 7) -- ShotGun
		ply:GiveAmmo(3, 8) -- RPG Ammo
		ply:GiveAmmo(3, 11) -- slam
		ply:GiveAmmo(3, 10) -- Granate
		ply:GiveAmmo(6, 13) -- Sniper
		ply:GiveAmmo(6, 6) -- Sniper
		ply:SetHealth(ply:GetMaxHealth())
		ply:SetArmor(ply:GetMaxArmor())
		ply:SetHunger(100,1)
		rp.Notify(ply, 0, "Вы успешно пополнили боекомплект!")

		timer.Simple(.4,function()
			if !IsValid(self) then return end
			seq = self:LookupSequence("idle")
			self:SetSequence( seq )
			self.BoxOpen = false
		end)

	end)
	

end


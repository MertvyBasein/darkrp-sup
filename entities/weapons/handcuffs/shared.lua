SWEP.Contact = ""
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.DrawAmmo = false
SWEP.Base = "weapon_base"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/weapons/c_handcuffs.mdl"
SWEP.WorldModel = "models/weapons/w_handcuffs.mdl"
--util.PrecacheModel( "models/weapons/c_handcuffs.mdl" )
--util.PrecacheModel( "models/weapons/w_handcuffs.mdl" )
SWEP.ViewModelFlip = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.UseHands = true
SWEP.HoldType = "slam"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	local target = self.Owner:getEyeSightHitEntity(nil, nil, function(tar)
		return getEyeSightHitEntityDefaultFilter(tar) and true
	end)

	self.Weapon:SetNextPrimaryFire(CurTime() + .5)
	self.Weapon:SetNextSecondaryFire(CurTime() + .5)

	if SERVER then return end

	net.Start('MetaHub.RestrainPlayer')
	net.WriteEntity(target)
	net.SendToServer()
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	local target = self.Owner:getEyeSightHitEntity(nil, nil, function(tar)
		return getEyeSightHitEntityDefaultFilter(tar) and true
	end)

	self.Weapon:SetNextPrimaryFire(CurTime() + .5)
	self.Weapon:SetNextSecondaryFire(CurTime() + .5)

	if SERVER then return end
	net.Start('MetaHub.EscortPlayer')
	net.WriteEntity(target)
	net.SendToServer()
end

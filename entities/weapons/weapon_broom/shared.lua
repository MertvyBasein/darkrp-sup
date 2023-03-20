SWEP.Author = ""
SWEP.PrintName = "Метла"

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.DrawWeaponInfoBox = true
SWEP.WorldModel = "models/props_c17/pushbroom.mdl"
SWEP.HoldType = "crossbow"

SWEP.SlotPos = 2
SWEP.Slot = 2
SWEP.nowarn = true
SWEP.Category = "RP"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 1

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


SWEP.Primary.Hit			= Sound( "Weapon_Crowbar.Single" )
SWEP.Primary.Damage			= 0

SWEP.HoldPos 			= Vector( 20, 0, 0 )
SWEP.HoldAng			= Vector( -10, -30, 15 )

function SWEP:DrawWorldModel()
	local entOwner = self:GetOwner()
	if not entOwner:IsValid() then
		self:SetRenderOrigin()
		self:SetRenderAngles()
		self:DrawModel()
		return
	end

	self:RemoveEffects(EF_BONEMERGE_FASTCULL)
	self:RemoveEffects(EF_BONEMERGE)
	local iHandBone = entOwner:LookupBone("ValveBiped.Bip01_R_Hand")
	if not iHandBone then
		return
	end

	local vecBone, angBone = entOwner:GetBonePosition(iHandBone)
	if false then
		local offset = angBone:Right() * self.HoldPos.x + angBone:Forward() * self.HoldPos.y + angBone:Up() * self.HoldPos.z

		angBone:RotateAroundAxis( angBone:Right(),	self.HoldAng.x )
		angBone:RotateAroundAxis( angBone:Forward(),	self.HoldAng.y )
		angBone:RotateAroundAxis( angBone:Up(),		self.HoldAng.z )
	else
		local offset = angBone:Right() * self.HoldPos.x + angBone:Forward() * self.HoldPos.y + angBone:Up() * self.HoldPos.z

		angBone:RotateAroundAxis( angBone:Right(),	self.HoldAng.x )
		angBone:RotateAroundAxis( angBone:Forward(),	self.HoldAng.y )
		angBone:RotateAroundAxis( angBone:Up(),		self.HoldAng.z )
	end

	self:SetRenderOrigin(vecBone)
	self:SetRenderAngles(angBone)
	self:DrawModel()
end

function SWEP:PreDrawViewModel()
	return true
end

function SWEP:DrawWorldModelTranslucent()
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end


function SWEP:Hit()
	local tracer = self.Owner:GetEyeTrace()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(self.Primary.Hit)
	if self.Owner:GetPos():Distance(tracer.HitPos) > 100 then return end
	if IsValid(tracer.Entity) and SERVER then
		tracer.Entity:TakeDamage(math.random(0,0), self.Owner, self)
		tracer.Entity:EmitSound("player/footsteps/wood"..math.random(1,4)..".wav", 80)
	end
	local vecSrc = self.Owner:GetShootPos()


	local info = EffectData()
	info:SetNormal( tracer.HitNormal )
	info:SetOrigin( tracer.HitPos )

	util.Effect( "GlassImpact", info )

	if ( SERVER ) then
		util.TraceHull({vecSrc, tracer.HitPos, self.Owner, Vector( -16, -16, -16 ), Vector( 36, 36, 36 )})
	end

end

function SWEP:PrimaryAttack()
	self:Hit()
	self:SetNextPrimaryFire(CurTime()+1)
end

function SWEP:SecondaryAttack()
	self:Hit()
	self:SetNextSecondaryFire(CurTime()+5)
end
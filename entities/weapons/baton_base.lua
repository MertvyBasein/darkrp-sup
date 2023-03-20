AddCSLuaFile()

SWEP.Base = 'weapon_rp_base'

if CLIENT then
	SWEP.PrintName = 'Baton Base'
	SWEP.Slot = 2
	SWEP.DrawCrosshair = true
end
-- SWEP.Color = Color(255, 255, 255, 255)

SWEP.ViewModel = Model('models/weapons/v_stunbaton.mdl')
SWEP.WorldModel = Model('models/weapons/w_stunbaton.mdl')

SWEP.Primary.Sound = Sound('Weapon_StunStick.Swing')

SWEP.UseHands = false

SWEP.HitDistance = 150

SWEP.Melee = {
	DotRange = 0.70721, -- Max dot product for a hull trace to hit. 1/sqrt(2)
	HullRadius = 1.732, -- Test amount of the forward vector for the end point oof the hull trace. sqrt(3)
	TestHull = Vector(16, 16, 16), -- Test hull mins/maxs
	Mask = MASK_SHOT_HULL -- Mask to use for melee trace
}

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self._Reload.Sound = Sound('npc/combine_soldier/vo/administer.wav')
end

function SWEP:Deploy()
	if (not IsValid(self.Owner)) then return false end
	
	return true
end

function SWEP:ResetStick()
	if (not IsValid(self:GetOwner())) then return end

	if SERVER then
		self:SetMaterial() -- clear material
	end
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self:SetHoldType('melee')

	timer.Simple(0.3, function()
		if IsValid(self) then
			self:SetHoldType('normal')
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				vm:SendViewModelMatchingSequence(vm:LookupSequence('idle01'))
			end
		end
	end)

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:EmitSound(self.Primary.Sound)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
end

function SWEP:Reload()
	if (not IsValid(self.Owner)) or (not self:CanReload()) then return end

	self:SetNextReload(CurTime() + self._Reload.Delay)

	self:SetHoldType('melee')

	timer.Simple(1, function()
		if not IsValid(self) then return end
		self:SetHoldType('normal')
	end)

	self.Owner:EmitSound(self._Reload.Sound)
end

function SWEP:OnRemove(wep)
	if (not IsValid(self.Owner)) then return true end
	
	self:ResetStick()
end

function SWEP:GetTrace()
	local tMelee = self.Melee
	local pPlayer = self:GetOwner()
	pPlayer:LagCompensation(true)

	local vSrc     = pPlayer:EyePos()
	local vForward = pPlayer:GetAimVector()
	local vEnd     = vSrc + vForward * 60

	local tbl = {
		start = vSrc,
		endpos = vEnd,
		mask = self.Melee.Mask,
		filter = pPlayer
	}

	local tr    = util.TraceLine(tbl)
	local bMiss = tr.Fraction == 1

	if (bMiss) then
		-- Hull is +/- 16, so use cuberoot of 3 to determine how big the hull is from center to the corner point
		tbl.endpos = vEnd - vForward * tMelee.HullRadius
		tbl.mins = -tMelee.TestHull
		tbl.maxs = tMelee.TestHull
		tbl.output = tr

		util.TraceHull(tbl)
		bMiss = tr.Fraction == 1 or tr.Entity == NULL

		if (not bMiss) then
			local vTarget = tr.Entity:GetPos() - vSrc
			vTarget:Normalize()

			-- Make sure they are sort of facing the guy at least
			if (vTarget:Dot(vForward) < tMelee.DotRange) then
				-- Force amiss
				tr.Fraction = 1
				tr.Entity = NULL
				bMiss = true
			else
				util.FindHullIntersection(tbl, tr)
				bMiss = tr.Fraction == 1 or tr.Entity == NULL
			end
		end
	else
		bMiss = tr.Entity == NULL
	end

	pPlayer:LagCompensation(false)
	return tr
end

function SWEP:Holster(wep)
	self:OnRemove(wep)
	return true
end
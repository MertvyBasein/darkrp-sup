AddCSLuaFile()

SWEP.Base = 'weapon_rp_base'

if CLIENT then
	SWEP.PrintName				= 'Кулаки'
	SWEP.Slot					= 2
	SWEP.SlotPos				= 2
	SWEP.Author					= ''
	SWEP.Instructions			= ''
end
SWEP.HoldType				= 'fist'
SWEP.ViewModel				= Model('models/weapons/c_arms.mdl')

local Damage 				= 10
local ComboDamage 			= 20
local HitDistance			= 48

local NextMelee				= 0
local NextIdle				= 0
local Combo					= 0

local SwingSound = Sound('WeaponFrag.Throw')
local WorldSound = Sound('Flesh.ImpactHard')
local PlayerSound = Sound('Flesh_Bloody.ImpactHard')
local SpecialSound = Sound('physics/flesh/flesh_break1.wav')

function SWEP:UpdateNextIdle()
	if not IsValid(self.Owner) then return end
	local vm = self.Owner:GetViewModel()
	if not IsValid(vm) then return end
	NextIdle = CurTime() + vm:SequenceDuration()
end

function SWEP:PrimaryAttack()
	self:Punch(true)
end

function SWEP:SecondaryAttack()
	self:Punch(false)
end

function SWEP:Punch(hand)
	if not IsValid(self.Owner) then return end
	-- true = left, false = right
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	local seq = "fists_right"
	if hand then seq = "fists_left" end
	if Combo >= 2 then
		seq = "fists_uppercut"
	end
	
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(seq))
	
	self:EmitSound(SwingSound)
	
	self:UpdateNextIdle()
	NextMelee = CurTime() + 0.2
	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

function SWEP:DealDamage()
	if not IsValid(self.Owner) then return end
	
	local anim = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())
	
	self.Owner:LagCompensation(true)
	
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * HitDistance,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	})
	
	if not IsValid(tr.Entity) then 
		tr = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * HitDistance,
			filter = self.Owner,
			mins = Vector(-10, -10, -8),
			maxs = Vector(10, 10, 8),
			mask = MASK_SHOT_HULL
		})
	end
	
	self.Owner:LagCompensation(false)
	
	local ent = tr.Entity and tr.Entity:IsPlayer()
	
	if tr.Hit then
		self:EmitSound(WorldSound)
		self:EmitSound('physics/flesh/flesh_break1.wav')
		if ent then
			self:EmitSound(PlayerSound)
		end
	end
	
	local hit = false
	
	if SERVER and IsValid(tr.Entity) and (tr.Entity:IsPlayer() or (tr.Entity:Health() > 0)) then
		local dmginfo = DamageInfo()
	
		local attacker = self.Owner
		if not IsValid(attacker) then attacker = self end
		dmginfo:SetAttacker(attacker)

		dmginfo:SetInflictor(self)
		dmginfo:SetDamage(Damage)

		if anim == 'fists_left' then
			dmginfo:SetDamageForce(self.Owner:GetRight() * 4912 + self.Owner:GetForward() * 9998)
		elseif anim == 'fists_right' then
			dmginfo:SetDamageForce(self.Owner:GetRight() * -4912 + self.Owner:GetForward() * 9989)
		elseif anim == 'fists_uppercut' then
			dmginfo:SetDamageForce(self.Owner:GetUp() * 5158 + self.Owner:GetForward() * 10012)
			dmginfo:SetDamage(ComboDamage)
		end

		tr.Entity:TakeDamageInfo(dmginfo)
		hit = true
	end
	
	if SERVER and IsValid(tr.Entity) then
		local phys = tr.Entity:GetPhysicsObject()
		if IsValid(phys) then
			phys:ApplyForceOffset(self.Owner:GetAimVector() * 80 * phys:GetMass(), tr.HitPos)
		end
	end
	
	if SERVER then
		if hit and (anim ~= 'fists_uppercut') then
			Combo = Combo + 1
		else
			Combo = 0
		end
	end
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence('fists_draw'))
	
	self:UpdateNextIdle()
	
	if SERVER then
		Combo = 0
	end
	
	return true
end

function SWEP:Think()
	-- Cache values to prevent Think lag
	local vm = self.Owner:GetViewModel()
	local curtime = CurTime()
	local idletime = NextIdle
	local meleetime = NextMelee
	
	if (idletime > 0) and (CurTime() > idletime) then
		vm:SendViewModelMatchingSequence(vm:LookupSequence('fists_idle_0' .. math.random(1, 2)))
		self:UpdateNextIdle()
	end
	
	if (meleetime > 0 and CurTime() > meleetime) then
		self:DealDamage()
		NextMelee = 0
	end
	
	if SERVER and CurTime() > self:GetNextPrimaryFire() + 0.1 then
		Combo = 0
	end
end

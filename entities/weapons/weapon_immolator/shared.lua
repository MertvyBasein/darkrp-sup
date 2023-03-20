include('particletrace.lua')
AddCSLuaFile( "particletrace.lua" )

local sndAttackLoop = Sound("fire_large")
local sndSprayLoop = Sound("ambient.steam01")
local sndAttackStop = Sound("ambient/_period.wav")
local sndIgnite = Sound("PropaneTank.Burst")

if (SERVER) then
	AddCSLuaFile("shared.lua");
end
if ( CLIENT ) then

	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 58
	SWEP.Category			= "CP"
	SWEP.PrintName			= "Иммолятор"
	SWEP.Slot				= 5
	SWEP.SlotPos			= 7
end
SWEP.HoldType			= "shotgun"
SWEP.Spawnable			= true
SWEP.AdminOnly			= true

SWEP.Instructions = "ЛКМ - разжечь.";

SWEP.ViewModel			= "models/weapons/v_cremato2.mdl"
SWEP.WorldModel			= "models/weapons/w_immolator.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay			= 0.
SWEP.Primary.Ammo			= ""


SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Delay		= 0.
SWEP.Secondary.Ammo			= ""

function SWEP:Initialize()

	self:SetHoldType(self.HoldType)
	self.EmittingSound = false
	util.PrecacheModel("models/player/charple.mdl")

end

function SWEP:Think()
	if self.Owner:KeyReleased(IN_ATTACK) then
		self:StopSounds()
	end
end

function SWEP:PrimaryAttack()
	local curtime = CurTime()
	local InRange = false

	self.Weapon:SetNextSecondaryFire( curtime + 0.8 )
	self.Weapon:SetNextPrimaryFire( curtime + self.Primary.Delay )
	
	if self.Owner:WaterLevel() > 1 then 
	self:StopSounds() 
	return end
	
	if not self.EmittingSound then
		self.Weapon:EmitSound(sndAttackLoop)
		self.EmittingSound = true
	end
	
	self.Owner:MuzzleFlash()
	--self:TakePrimaryAmmo(1)
	
	--if SERVER then
		local PlayerVel = self.Owner:GetVelocity()
		local PlayerPos = self.Owner:GetShootPos()
		local PlayerAng = self.Owner:GetAimVector()
		
		local trace = {}
		trace.start = PlayerPos
		trace.endpos = PlayerPos + (PlayerAng*4096)
		trace.filter = self.Owner
		
		local traceRes = util.TraceLine(trace)
		local hitpos = traceRes.HitPos
		
		local jetlength = (hitpos - PlayerPos):Length()
		if jetlength > 568 then jetlength = 568 end
		if jetlength < 6 then jetlength = 6 end
		
		if self.Owner:Alive() then
			local effectdata = EffectData()
			effectdata:SetOrigin( hitpos )
			effectdata:SetEntity( self.Weapon )
			effectdata:SetStart( PlayerPos )
			effectdata:SetNormal( PlayerAng )
			effectdata:SetScale( jetlength )
			effectdata:SetAttachment( 1 )
			util.Effect( "im_flamepuffs", effectdata )
		end

		if self.DoShoot then

			local ptrace = {}
			ptrace.startpos = PlayerPos + PlayerAng:GetNormalized()*16
			local ang = (traceRes.HitPos - ptrace.startpos):GetNormalized()
			ptrace.func = burndamage
			ptrace.movetype = MOVETYPE_FLY
			ptrace.velocity = ang*728 + 0.5*PlayerVel
			ptrace.model = "none"
			ptrace.filter = {self.Owner}
			ptrace.killtime = (jetlength + 16)/ptrace.velocity:Length()
			ptrace.runonkill = false
			ptrace.collisionsize = 14
			ptrace.worldcollide = true
			ptrace.owner = self.Owner
			ptrace.name = "flameparticle"
			ParticleTrace(ptrace)
			
			self.DoShoot = false
			else
			self.DoShoot = true
	end
end

function SWEP:SecondaryAttack()
end



function Immolate(ent,pos)
	pos = pos or ent:GetPos()
	if SERVER then
		ent:SetModel("models/player/charple.mdl")
		ent:Ignite(math.Rand(30,50),0)
		ent.Removal = CurTime() + 1
		if ent:IsPlayer() then
			ent:Kill()
		end
	end
	
	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	util.Effect( "im_immolate", effectdata )
end

function burndamage(ptres)

	local hitent = ptres.activator
	if hitent:WaterLevel() > 0 then return end
	if not hitent:IsPlayer() and not hitent:IsNPC() and not hitent:IsRagdoll() and hitent:GetClass() ~= "sammyservers_textscreen" and hitent:GetClass() ~= "prop_physics" then return end

	local ttime = ptres.time
	if ttime == 0 then ttime = 0.1 end --Division by zero is bad! D :
	
	local damage = 20
	
	local radius = math.ceil(256*ttime)
	if radius < 16 then radius = 16 end
	

	local healthpercent = 3
	local isnpc = hitent:IsNPC()
	local enthealth = 0
	local enttable = hitent:GetTable()
	
	if isnpc or hitent:IsPlayer() then
		enthealth = hitent:Health()
	end
	if hitent:IsPlayer() then 
		DarkRP.notify(ptres.owner,1,4,"Плохой синтет, это живой человек") 
		return 
	end

	if hitent:GetClass() == "sammyservers_textscreen" then 
		local owner = hitent.pp_owner
		if IsValid(owner) and not owner:IsCP() then 
			hitent:Remove()
			return
		end
	elseif hitent:IsRagdoll() then
		if hitent:GetModel() ~= "models/player/charple.mdl" then
			Immolate(hitent,entpos)
		elseif not hitent.owner then 
			hitent:Remove()
		end
	elseif hitent.UseRagdoll and hitent.UseRagdoll then
		local corpse = hitent.UseRagdoll
		if corpse:GetModel() ~= "models/player/charple.mdl" then
			Immolate(corpse,entpos)
		elseif not corpse.owner then 
			corpse:Remove()
		end
	elseif hitent:IsPlayer() then
		hitent:Ignite(math.Rand(30,50),0)
	end
	
	if (hitent:IsRagdoll() and hitent:GetModel() == "models/player/charple.mdl") then
		local destoyrag = math.random(1,5)
		if destoyrag >= 2 and (hitent.Removal or 0) < CurTime() then --it's your lucky day!
			hitent:Remove()
			if IsValid(hitent.block) then
				hitent.block:Extinguish()
				hitent.block:Remove()
			end 
			-- if not zombie_event.started then
				DarkRP.notify(ptres.owner, 3, 4, "Вы получили награду за очистку улиц.")
				ptres.owner:AddMoney(math.random(500,1000), "Сжигание трупов")
			-- end
		end
	elseif hitent.UseRagdoll and hitent.UseRagdoll and hitent:GetClass() == "prop_physics" then
		local destoyrag = math.random(1,5)
		if destoyrag < 2 or (hitent.Removal or 0) > CurTime() then 
			return 
		end
		local corpse = hitent.UseRagdoll
		corpse:Remove()
		if IsValid(corpse.block) then
			corpse.block:Extinguish()
			corpse.block:Remove()
		end 
		-- if not zombie_event.started then
			DarkRP.notify(ptres.owner, 3, 4, "Вы получили награду за очистку улиц.")
			ptres.owner:AddMoney(math.random(500,1000), "Сжигание трупов")
		-- end
	end

	local us = true
	--if IsValid(hitent) and hitent:GetClass() == "trasher" and us == true and hitent:GetNW2Int("TrashCanDelay") < CurTime() then
		--hitent:Magic(ptres.owner)
	--end
	util.BlastDamage(ptres.owner:GetActiveWeapon(), ptres.owner, ptres.particlepos, radius, damage)
	
	--local reverselottery = math.random(0,healthpercent)
	--if reverselottery == 1 and not hitent.owner then --it's your lucky day!
	--	hitent:Ignite(math.Rand(30,50),0)
	--	if isnpc and enthealth < 32 and hitent:GetMaxHealth() > 24 then
	--	hitent:SetHealth(32) --So we can watch 'em BURN!  >:D
	--	end
	--end
end


function SWEP:StopSounds()
	if self.EmittingSound then
		self.Weapon:StopSound(sndAttackLoop)
		self.Weapon:StopSound(sndSprayLoop)
		self.Weapon:EmitSound(sndAttackStop)
		self.EmittingSound = false
	end	
end


function SWEP:Holster()
	self:StopSounds()
	return true
end

function SWEP:OnRemove()
	self:StopSounds()
	return true
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
	self:SetNextSecondaryFire( CurTime() + self:SequenceDuration())
	self:Idle()
	return true
end

function SWEP:Holster( weapon )
	if ( CLIENT ) then return end

	self:StopIdle()
	
	return true
end

function SWEP:DoIdleAnimation()
	self:SendWeaponAnim( ACT_VM_IDLE )
end

function SWEP:DoIdle()
	self:DoIdleAnimation()

	timer.Adjust( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 0, function()
		if ( !IsValid( self ) ) then timer.Destroy( "weapon_idle" .. self:EntIndex() ) return end

		self:DoIdleAnimation()
	end )
end

function SWEP:StopIdle()
	timer.Destroy( "weapon_idle" .. self:EntIndex() )
end

function SWEP:Idle()
	if ( CLIENT || !IsValid( self.Owner ) ) then return end
	timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration() - 0.2, 1, function()
		if ( !IsValid( self ) ) then return end
		self:DoIdle()
	end )
end
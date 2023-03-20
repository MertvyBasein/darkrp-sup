AddCSLuaFile()

SWEP.Base = 'weapon_rp_base'

if CLIENT then
	SWEP.PrintName = 'Таран'
	SWEP.Slot = 2
	SWEP.Instructions = 'Left click to open doors and unfreeze props\nRight click to ready the ram'
end

SWEP.Spawnable = true
SWEP.Category = "RP"

SWEP.ViewModel = Model("models/weapons/c_rpg.mdl")
SWEP.WorldModel = Model("models/weapons/w_rocket_launcher.mdl")

SWEP.Primary.Sound = Sound('Canals.d1_canals_01a_wood_box_impact_hard3')

SWEP.Primary.Delay = 1

local function ramFadingDoor(ply, trace, ent)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end

    local Owner = ent:CPPIGetOwner()

    -- if CLIENT then return canRam(Owner) end

    -- if not canRam(Owner) then
    --     DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("warrant_required"))
    --     return false
    -- end

    if ent:GetNWBool("IsFadingDoor") then
        ent:Fade()
    end

    return true
end

function SWEP:Deploy()
	if (not IsValid(self.Owner)) then return end

	self.HasDeployed = true
	self.Ironsights = false

	self.NewJump = 0
	self.OldJump = self.Owner:GetJumpPower() or 200
end

function SWEP:OnRemove()
	if (not IsValid(self.Owner)) or (not self.HasDeployed) or CLIENT then return end

	--hook.Call('UpdatePlayerSpeed', GAMEMODE, self.Owner)
	self.Owner:SetJumpPower(self.OldJump)
end

function GetDoorCategoray( door )
	for k, v in pairs( rp.cfg.Doors ) do
		if table.HasValue(v.MapIDs,door:GetDoorID()) then
			return v
		end
	end
end

function SWEP:Holster()
	self:OnRemove()
	return true
end

function SWEP:PrimaryAttack()
	if not IsValid(self.Owner) or CLIENT then return end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self.Owner:LagCompensation(true)
		local tr = self.Owner:GetEyeTrace()
	self.Owner:LagCompensation(false)

	local ent = tr.Entity
	if (not IsValid(ent)) or (self.Owner:EyePos():Distance(tr.HitPos) > self.HitDistance) then return end

	if ent:IsDoor() then
		local tar = ent:DoorGetOwner()
		if IsValid(tar)  then
			if ent.Locked then
				ent:DoorLock(false)
			end
			ent:Fire('open', '', .6)
			ent:Fire('setanimation', 'open', .6)

			self:Ram()
		end
	elseif ent:IsProp() and ent:GetNWBool("IsFadingDoor") then
		local tar = ent:CPPIGetOwner()
		ent:Fade()
		ent.fd_block = CurTime() + 60
		self:Ram()

		timer.Create("FadingDoorUnFade_"..ent:EntIndex(), 60, 1, function()
			if not IsValid(ent) then return end
			if not ent.Faded then return end
			ent:UnFade()
		end)
		--self:Ram()
	-- elseif ent:IsProp() then
	-- 	local tar = ent:CPPIGetOwner()
	-- 	if IsValid(tar) and tar:IsWarranted() then
	-- 		constraint.RemoveAll(ent)
	--
	-- 		local phys = ent:GetPhysicsObject()
	-- 		if IsValid(phys) then
	-- 			phys:EnableMotion(true)
	-- 		end
	--
	-- 		if (not util.IsInWorld(ent:GetPos())) then
	-- 			ent:Remove()
	-- 		end
	--
	-- 		ent.OnPhysgunDrop = nil
	--
	-- 		self:Ram()
	-- 	end
	end
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Ram()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:EmitSound(self.Primary.Sound)
	self.Owner:ViewPunch(Angle(-10, math.random(-5, 5), 0))
end

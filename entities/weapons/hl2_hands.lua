AddCSLuaFile()

if (CLIENT) then
	SWEP.PrintName = "Руки"
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

-- SWEP.Author = "Chessnut"
SWEP.Instructions = "ЛКМ: Кинуть предмет/Ударить\nПКМ: Постучать/Поднять предмет\nПерезарядка: Положить предмет"
SWEP.Purpose = ""
SWEP.Drop = false

SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"

SWEP.ViewTranslation = 4
if CLIENT then
	SWEP.NextAllowedPlayRateChange = 0
end

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Damage = 5
SWEP.Primary.Delay = 0.75

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Secondary.Delay = 0.5

SWEP.ViewModel = Model("models/weapons/c_arms_citizen.mdl")
SWEP.WorldModel = ""

SWEP.UseHands = false
SWEP.LowerAngles = Angle(0, 5, -14)
SWEP.LowerAngles2 = Angle(0, 5, -19)
SWEP.KnockViewPunchAngle = Angle(-1.3, 1.8, 0)

SWEP.FireWhenLowered = true
SWEP.HoldType = "normal"

SWEP.holdDistance = 64
SWEP.maxHoldDistance = 96 -- how far away the held object is allowed to travel before forcefully dropping
SWEP.maxHoldStress = 4000 -- how much stress the held object can undergo before forcefully dropping

-- luacheck: globals ACT_VM_FISTS_DRAW ACT_VM_FISTS_HOLSTER
ACT_VM_FISTS_DRAW = 3
ACT_VM_FISTS_HOLSTER = 2

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)

	self.lastHand = 0
	self.maxHoldDistanceSquared = self.maxHoldDistance ^ 2
	self.heldObjectAngle = angle_zero
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Raised")
end

function SWEP:IsRaised()
	return self:GetRaised()
end

if (CLIENT) then
	function SWEP:PreDrawViewModel(viewModel, weapon, client)
		local hands = player_manager.TranslatePlayerHands(player_manager.TranslateToPlayerModelName(client:GetModel()))

		if (hands and hands.model) then
			viewModel:SetModel(hands.model)
			viewModel:SetSkin(hands.skin)
			viewModel:SetBodyGroups(hands.body)
		end
	end

	-- function SWEP:DoDrawCrosshair(x, y)
	-- 	-- surface.SetDrawColor(255, 255, 255, 66)
	-- 	-- surface.DrawRect(x - 2, y - 2, 4, 4)
	-- end

	function SWEP:CalcViewModelView(vm, oldPos, oldAng, pos, ang)
		local targetValue = 100
		local weaponRaised = self:IsRaised()
		if weaponRaised then
			targetValue = 0
		end

		local fraction = (self.raisedFraction or 100) / 100

		ang:RotateAroundAxis(ang:Right(), -10 * fraction)
		ang:RotateAroundAxis(ang:Forward(), 6 * fraction)

		self.raisedFraction = math.Approach(self.raisedFraction or 100, targetValue, FrameTime() * 128)

		return pos, ang
	end
end

function SWEP:Deploy()
	if (not IsValid(self.Owner)) then
		return
	end

	local viewModel = self.Owner:GetViewModel()

	if (IsValid(viewModel)) then
		viewModel:SetPlaybackRate(1)
		viewModel:ResetSequence(ACT_VM_FISTS_DRAW)
		if CLIENT then
			self.NextAllowedPlayRateChange = CurTime() + viewModel:SequenceDuration()
		end
	end

	self:DropObject()
	return true
end

function SWEP:Precache()
	util.PrecacheSound("npc/vort/claw_swing1.wav")
	util.PrecacheSound("npc/vort/claw_swing2.wav")
	util.PrecacheSound("physics/plastic/plastic_box_impact_hard1.wav")
	util.PrecacheSound("physics/plastic/plastic_box_impact_hard2.wav")
	util.PrecacheSound("physics/plastic/plastic_box_impact_hard3.wav")
	util.PrecacheSound("physics/plastic/plastic_box_impact_hard4.wav")
	util.PrecacheSound("physics/wood/wood_crate_impact_hard2.wav")
	util.PrecacheSound("physics/wood/wood_crate_impact_hard3.wav")
end

function SWEP:OnReloaded()
	self.maxHoldDistanceSquared = self.maxHoldDistance ^ 2
	self:DropObject()
end

function SWEP:Holster()
	if (not IsValid(self.Owner)) then
		return
	end

	local viewModel = self.Owner:GetViewModel()

	if (IsValid(viewModel)) then
		viewModel:SetPlaybackRate(1)
		viewModel:ResetSequence(ACT_VM_FISTS_HOLSTER)
		if CLIENT then
			self.NextAllowedPlayRateChange = CurTime() + viewModel:SequenceDuration()
		end
	end

	return true
end

function SWEP:Think()
	if (not IsValid(self.Owner)) then
		return
	end

	if (CLIENT) then
		local viewModel = self.Owner:GetViewModel()

		if (IsValid(viewModel) and self.NextAllowedPlayRateChange < CurTime()) then
			viewModel:SetPlaybackRate(1)
		end
	else
		local owner = self:GetOwner()
		if owner:KeyPressed(IN_RELOAD) then
			if not self._queueRaised then
				self._queueRaised = true
				timer.Create(
					"handsRaised_" .. self:EntIndex(),
					0.5,
					1,
					function()
						if self then
							self._queueRaised = nil
						end
						if IsValid(owner) then
							local wep = owner:GetActiveWeapon()
							if wep == self then
								if owner:KeyDown(IN_RELOAD) then
									local wepRaised = wep:IsRaised()
									if wepRaised or self.Owner._CanFight then
										wep:SetRaised(not wepRaised)
										wep:SetHoldType(wepRaised and "normal" or "fist")
									end
								end
							end
						end
					end
				)
			end
		end
		if (self:IsHoldingObject()) then
			-- if self:GetOwner():IsRagdolled() then
			-- 	self:DropObject()
			-- end
			local physics = self:GetHeldPhysicsObject()
			local bIsRagdoll = self.heldEntity:IsRagdoll()
			local holdDistance = bIsRagdoll and self.holdDistance * 0.5 or self.holdDistance
			local targetLocation = (self.Owner:GetShootPos() + self.Owner:GetForward() * holdDistance) --[[- self.heldEntity:OBBCenter()--]]

			if (bIsRagdoll) then
				targetLocation.z = math.min(targetLocation.z, self.Owner:GetShootPos().z - 32)
			end

			local entAngles = self.heldEntity:GetAngles()
			local oldAngles = owner.cwHoldingAngles
			local eyeAngles = owner:EyeAngles()
			local oldEyeAngles = owner.cwOriginalEyeAngles
			local diff = eyeAngles.y - oldEyeAngles.y

			self.holdEntity:SetAngles(Angle(entAngles.x, oldAngles.y + diff, oldAngles.z))

			if (not IsValid(physics)) then
				self:DropObject()
				return
			end

			if (physics:GetPos():DistToSqr(targetLocation) > self.maxHoldDistanceSquared) then
				self:DropObject()
			else
				local physicsObject = self.holdEntity:GetPhysicsObject()
				physicsObject:Wake()
				physicsObject:ComputeShadowControl(
					{
						secondstoarrive = 0.01,
						pos = targetLocation,
						angle = self.heldObjectAngle,
						maxangular = 256,
						maxangulardamp = 10000,
						maxspeed = 256,
						maxspeeddamp = 10000,
						dampfactor = 0.8,
						teleportdistance = self.maxHoldDistance * 0.75,
						deltatime = FrameTime()
					}
				)
			end
		end
	end
end

function SWEP:GetHeldPhysicsObject()
	return IsValid(self.heldEntity) and self.heldEntity:GetPhysicsObject() or nil
end

function SWEP:IsHoldingObject()
	return IsValid(self.heldEntity) and IsValid(self.heldEntity.ixHeldOwner) and self.heldEntity.ixHeldOwner == self.Owner
end

function SWEP:PickupObject(entity)
	if (self:IsHoldingObject() or not IsValid(entity) or not IsValid(entity:GetPhysicsObject())) then
		return
	end

	local physics = entity:GetPhysicsObject()
	physics:EnableGravity(false)
	physics:AddGameFlag(FVPHYSICS_PLAYER_HELD)

	entity.ixHeldOwner = self.Owner
	entity.ixCollisionGroup = entity:GetCollisionGroup()
	entity:StartMotionController()
	entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self.heldObjectAngle = entity:GetAngles()
	self.heldEntity = entity

	self.holdEntity = ents.Create("prop_physics")
	self.holdEntity:SetPos(self.heldEntity:GetPos())
	self.holdEntity:SetAngles(self.heldEntity:GetAngles())
	self.holdEntity:SetModel("models/weapons/w_bugbait.mdl")
	self.holdEntity:SetOwner(self.Owner)

	self.holdEntity:SetNoDraw(true)
	self.holdEntity:SetNotSolid(true)
	self.holdEntity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self.holdEntity:DrawShadow(false)

	self.holdEntity:Spawn()

	self.Owner.cwHoldingAngles = entity:GetAngles()
	self.Owner.cwOriginalEyeAngles = self.Owner:EyeAngles()

	local trace = self.Owner:GetEyeTrace()
	local physicsObject = self.holdEntity:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:SetMass(2048)
		physicsObject:SetDamping(0, 1000)
		physicsObject:EnableGravity(false)
		physicsObject:EnableCollisions(false)
		physicsObject:EnableMotion(false)
	end

	self.constraint =
		constraint.Weld(
		self.holdEntity,
		self.heldEntity,
		0,
		trace.Entity:IsRagdoll() and trace.PhysicsBone or 0,
		0,
		true,
		true
	)
end

function SWEP:DropObject(bThrow)
	if (not IsValid(self.heldEntity) or self.heldEntity.ixHeldOwner ~= self.Owner) then
		return
	end

	hook.Run("PlayerDroppedObject", self.Owner, self.heldEntity)

	self.constraint:Remove()
	self.holdEntity:Remove()

	self.heldEntity:StopMotionController()
	self.heldEntity:SetCollisionGroup(self.heldEntity.ixCollisionGroup or COLLISION_GROUP_NONE)

	local physics = self:GetHeldPhysicsObject()
	physics:EnableGravity(true)
	physics:Wake()
	physics:ClearGameFlag(FVPHYSICS_PLAYER_HELD)

	if (bThrow) then
		timer.Simple(
			0,
			function()
				if (IsValid(physics) and IsValid(self.Owner)) then
					physics:AddGameFlag(FVPHYSICS_WAS_THROWN)
					physics:ApplyForceCenter(self.Owner:GetAimVector() * 732)
				end
			end
		)
	end
	self.heldEntity.ixHeldOwner = nil
	self.heldEntity.ixCollisionGroup = nil
	self.heldEntity = nil
end

function SWEP:PlayPickupSound(surfaceProperty)
	local result = "Flesh.ImpactSoft"

	if (surfaceProperty ~= nil) then
		local surfaceName = util.GetSurfacePropName(surfaceProperty)
		local soundName = surfaceName:gsub("^metal$", "SolidMetal") .. ".ImpactSoft"

		if (sound.GetProperties(soundName)) then
			result = soundName
		end
	end

	self.Owner:EmitSound(result, 75, 100, 40)
end

function SWEP:Holster()
	if (not IsFirstTimePredicted() or CLIENT) then
		return
	end

	self:DropObject()
	return true
end

function SWEP:OnRemove()
	if (SERVER) then
		self:DropObject()
	end
end

function SWEP:OwnerChanged()
	if (SERVER) then
		self:DropObject()
	end
end

function SWEP:DoPunchAnimation()
	self.lastHand = math.abs(1 - self.lastHand)

	local sequence = 4 + self.lastHand
	local viewModel = self.Owner:GetViewModel()

	if (IsValid(viewModel)) then
		viewModel:SetPlaybackRate(0.5)
		viewModel:SetSequence(sequence)
		if CLIENT then
			self.NextAllowedPlayRateChange = CurTime() + viewModel:SequenceDuration() * 2
		end
	end
end

function SWEP:PrimaryAttack()
	if (not IsFirstTimePredicted()) then
		return
	end

	if (SERVER and self:IsHoldingObject()) then
		self:DropObject(true)
		return
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if (hook.Run("CanPlayerThrowPunch", self.Owner, self) == false) then
		return
	end

	if (SERVER) then
		self.Owner:EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav")
	end

	self:DoPunchAnimation()

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:ViewPunch(Angle(self.lastHand + 2, self.lastHand + 5, 0.125))

	timer.Simple(
		0.055,
		function()
			if (IsValid(self) and IsValid(self.Owner)) then
				local damage = self.Primary.Damage
				local context = {damage = damage}
				local result = hook.Run("GetPlayerPunchDamage", self.Owner, damage, context)

				if (result ~= nil) then
					damage = result
				else
					damage = context.damage
				end

				self.Owner:LagCompensation(true)
				local data = {}
				data.start = self.Owner:GetShootPos()
				data.endpos = data.start + self.Owner:GetAimVector() * 96
				data.filter = self.Owner
				local trace = util.TraceLine(data)

				if (SERVER and trace.Hit) then
					local entity = trace.Entity

					if (IsValid(entity)) then
						local damageInfo = DamageInfo()
						damageInfo:SetAttacker(self.Owner)
						damageInfo:SetInflictor(self)
						damageInfo:SetDamage(damage)
						damageInfo:SetDamageType(DMG_SLASH)
						damageInfo:SetDamagePosition(trace.HitPos)
						damageInfo:SetDamageForce(self.Owner:GetAimVector() * 1024)
						entity:DispatchTraceAttack(damageInfo, data.start, data.endpos)

						self.Owner:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 80)
					end
				end

				hook.Run("PlayerThrowPunch", self.Owner, trace)
				self.Owner:LagCompensation(false)
			end
		end
	)
end

function SWEP:SecondaryAttack()
	if (not IsFirstTimePredicted()) then
		return
	end

	local data = {}
	data.start = self.Owner:GetShootPos()
	data.endpos = data.start + self.Owner:GetAimVector() * 84
	data.filter = {self, self.Owner}
	local trace = util.TraceLine(data)
	local entity = trace.Entity

	if CLIENT then
		local viewModel = self.Owner:GetViewModel()

		if (IsValid(viewModel)) then
			viewModel:SetPlaybackRate(0.5)
			if CLIENT then
				self.NextAllowedPlayRateChange = CurTime() + viewModel:SequenceDuration() * 2
			end
		end
	end

	if (SERVER and IsValid(entity)) then
		if (entity:isDoor()) then
			if (hook.Run("CanPlayerKnock", self.Owner, entity, self) == false) then
				return
			end
			self.Owner:ViewPunch(self.KnockViewPunchAngle)
			self.Owner:EmitSound("physics/wood/wood_crate_impact_hard" .. math.random(2, 3) .. ".wav")
			self.Owner:SetAnimation(PLAYER_ATTACK1)

			self:DoPunchAnimation()
			self:SetNextSecondaryFire(CurTime() + 0.4)
			self:SetNextPrimaryFire(CurTime() + 1)
		elseif entity:IsPlayer() then
			local direction = self.Owner:GetAimVector() * 300
			direction.z = 0
			entity:SetVelocity(direction)

			self.Owner:EmitSound("Weapon_Crossbow.BoltHitBody")
			self:SetNextSecondaryFire(CurTime() + 1.5)
			self:SetNextPrimaryFire(CurTime() + 1.5)
		elseif (entity:FCanPickUp(self.Owner) ) then
			self:PickupObject(entity)
			self:PlayPickupSound(trace.SurfaceProps)
			self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
		end
	end
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then
		return
	end
	if SERVER then
		if IsValid(self.heldEntity) then
			self:DropObject()
		end
	end
end

local allowedHoldableClasses = {
	["prop_ragdoll"] = true,
	["rx_printer_1"] = true,
	["rx_printer_2"] = true,
	["rx_printer_3"] = true,
	["prop_physics"] = true,
	["prop_physics_override"] = true,
	["prop_physics_multiplayer"] = true,
	["entity_radio"] = true,
	["fallout_radio"] = true,
	["ration"] = true,
	["food"] = true,
	["item_armor_1"] = true,
	["item_armor_2"] = true,
	["item_health_1"] = true,
	["item_health_2"] = true,
	["ent_c4"] = true,
	["paper"] = true
}
hook.Add(
	"CanPlayerHoldObject",
	"handsCanHolding",
	function(ply, entity)
		if allowedHoldableClasses[entity:GetClass()] then
			return true
		end
	end
)

hook.Add(
	"CanPlayerThrowPunch",
	"handsCanKnocked",
	function(owner, wep)
		if not wep:IsRaised() then
			return false
		end
	end
)


hook.Add("PlayerCanTaunt", "handsCheckHold", function(ply, name)
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) or wep:GetClass() ~= "hl2_hands" then return end
	if not wep:IsHoldingObject() then return end
	wep:DropObject()
end)
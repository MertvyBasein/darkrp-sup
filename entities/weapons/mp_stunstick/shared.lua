AddCSLuaFile()

SWEP.PrintName = "Демократизатор"

if (CLIENT) then
	SWEP.Slot = 0
	SWEP.SlotPos = 2
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Category = "MetaHub"
SWEP.Author = "MetaHub"
SWEP.Instructions = "Мирный - Урон 0 | Стан 4 секунды \n Подавление - Урон 5 | Стан 3 секунды \n Перевоспитание - Урон 10 | Стан  2 секунды \n Избиение - Урон 20 | Стан 0 секунд"
SWEP.Purpose = ""
SWEP.Drop = false
SWEP.HoldType = "normal"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.ViewModelFOV = 47
SWEP.ViewModelFlip = false

SWEP.AnimPrefix = "melee"
SWEP.ViewTranslation = 4

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Damage = 5
SWEP.Primary.Delay = 0.7

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.ViewModel = Model("models/weapons/c_stunstick.mdl")
SWEP.WorldModel = Model("models/weapons/w_stunbaton.mdl")

SWEP.UseHands = true
SWEP.LowerAngles = Angle(15, -10, -20)
SWEP.FireWhenLowered = true

SWEP.Activated = false
SWEP.ActiveDamage = true

SWEP.Damage = 0
SWEP.Stun = 4
SWEP.Power = 255

SWEP.Modes = {
	{name = "Мирный", dmg = 0, stun = 4, power = 350},
	{name = "Подавление", dmg = 5, stun = 3, power = 300},
	{name = "Перевоспитание", dmg = 10, stun = 2, power = 255},
	{name = "Избиение", dmg = 20, power = 255},
}

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Activated")
end

function SWEP:Precache()
	util.PrecacheSound("weapons/stunstick/stunstick_swing1.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_swing2.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_impact1.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_impact2.wav")
	util.PrecacheSound("weapons/stunstick/spark1.wav")
	util.PrecacheSound("weapons/stunstick/spark2.wav")
	util.PrecacheSound("weapons/stunstick/spark3.wav")
end

function SWEP:Initialize()
	self:SetHoldType("normal")
	if SERVER then
		self:SetMode(1)
	end
end

-- if replaceModels[self.Owner:GetModel()] then
-- 	self.Owner.PrevModel = self.Owner:GetModel()
-- 	self.Owner:SetModel(replaceModels[self.Owner:GetModel()])
-- end
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if self.Owner:KeyDown(IN_USE) then
		if SERVER then
			if self:GetActivated() then
				self:TurnOff()
			else
				self:TurnOn()
			end
		end
		return
	end
	if not self:GetActivated() then return end
	self:EmitSound("weapons/stunstick/stunstick_swing" .. math.random(1, 2) .. ".wav", 70)
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:ViewPunch(Angle(1, 0, 0.125))
	self.Owner:LagCompensation(true)
	local data = {}
	data.start = self.Owner:GetShootPos()
	data.endpos = data.start + self.Owner:GetAimVector() * 72
	data.filter = self.Owner
	local trace = util.TraceLine(data)
	self.Owner:LagCompensation(false)

	if (SERVER and trace.Hit) then
		local effect = EffectData()
		effect:SetStart(trace.HitPos)
		effect:SetNormal(trace.HitNormal)
		effect:SetOrigin(trace.HitPos)
		util.Effect("StunstickImpact", effect, true, true)

		self.Owner:EmitSound("weapons/stunstick/stunstick_impact" .. math.random(1, 2) .. ".wav")
		local entity = trace.Entity
		if not IsValid(entity) or not entity:IsPlayer() or entity:IsCP() and not entity:GetNWBool("NoStun") then return end
		if entity:GetNetVar('AdminMode') then rp.Notify(self.Owner,1,'Администратора нельзя ударить дубинкой') return end
		rp.Notify(entity,2,self.Owner:Name() .. " перевоспитывает вас")
		self.Owner:AddQuest('stunstick', 1)
		local dmg = self.Damage
		dmg = math.Clamp(dmg, 0, entity:Health() - 5) -- убираем летальность
		local damageInfo = DamageInfo()
		damageInfo:SetAttacker(self.Owner)
		damageInfo:SetInflictor(self)
		damageInfo:SetDamage(self.Damage or 5)
		damageInfo:SetDamageType(DMG_CLUB)
		damageInfo:SetDamagePosition(trace.HitPos)
		entity:TakeDamageInfo(damageInfo)
		if self.Stun and not self.target then
			entity:Freeze(true)
			self.target = true
			timer.Create("mp_freeze_" .. entity:SteamID64(), self.Stun, 1, function()
				if IsValid(self) then
					self.target = nil
				end
				if IsValid(entity) then
					entity:Freeze(false)
				end
			end)
		end

		netstream.Start(entity, "PainAndCrying", self.Power)
		entity.UntilFall = (entity.UntilFall or 0) + 1 or 0
	end
end

function SWEP:OnLowered()
	if SERVER then
		self:SetActivated(false)
	end

	self:SetNW2Bool("angry", false)
	self:SetHoldType("normal")
end

function SWEP:Holster(nextWep)
	self:OnLowered()

	return true
end

function SWEP:SecondaryAttack()
	self.Owner:LagCompensation(true)
	local data = {}
	data.start = self.Owner:GetShootPos()
	data.endpos = data.start + self.Owner:GetAimVector() * 72
	data.filter = self.Owner
	data.mins = Vector(-8, -8, -30)
	data.maxs = Vector(8, 8, 10)
	local trace = util.TraceHull(data)
	local entity = trace.Entity
	self.Owner:LagCompensation(false)
	if (SERVER and IsValid(entity)) then
		local pushed
		if entity:GetNetVar('AdminMode') then rp.Notify(self.Owner,1,'Администратора нельзя толкать дубинкой') return end
		if (entity:isDoor()) then
			if (hook.Run("PlayerCanKnock", self.Owner, entity) == false) then return end
			self.Owner:ViewPunch(Angle(-1.3, 1.8, 0))
			self.Owner:EmitSound("physics/plastic/plastic_box_impact_hard" .. math.random(1, 4) .. ".wav")
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self:SetNextSecondaryFire(CurTime() + 0.4)
			self:SetNextPrimaryFire(CurTime() + 1)
		elseif (entity:IsPlayer()) then
			local direction = self.Owner:GetAimVector() * (300 + 1 * 3)
			direction.z = 0
			entity:SetVelocity(direction)
			local emitsounds = {"npc/metropolice/vo/move.wav", "npc/metropolice/vo/movealong.wav", "npc/metropolice/vo/movealong3.wav", "npc/metropolice/vo/movebackrightnow.wav", "npc/metropolice/vo/moveit.wav", "npc/metropolice/vo/moveit2.wav"}

			if self.Owner:isCP() then
				self.Owner:EmitSound(emitsounds[math.random(#emitsounds)])
			end

			pushed = true
		else
			local physObj = entity:GetPhysicsObject()

			if (IsValid(physObj)) then
				physObj:SetVelocity(self.Owner:GetAimVector() * 180)
			end

			pushed = true
		end

		if (pushed) then
			self:SetNextSecondaryFire(CurTime() + 1.5)
			self:SetNextPrimaryFire(CurTime() + 1.5)
			self.Owner:EmitSound("weapons/crossbow/hitbod" .. math.random(1, 2) .. ".wav")
			local model = string.lower(self.Owner:GetModel())
			local owner = self.Owner
			-- if (nut.anim.getModelClass(model) == "metrocop") then
			local anim = self:LookupSequence("pushplayer")
			-- self.Owner:SetSequence(anim)
			-- end
		end
	end
end

local STUNSTICK_GLOW_MATERIAL = Material("effects/stunstick")
local STUNSTICK_GLOW_MATERIAL2 = Material("effects/blueflare1")
local STUNSTICK_GLOW_MATERIAL_NOZ = Material("sprites/light_glow02_add_noz")
local color_glow = Color(128, 128, 128)

function SWEP:DrawWorldModel()
	self:DrawModel()

	if self:GetActivated() then
		local size = math.Rand(4.0, 6.0)
		local glow = math.Rand(0.6, 0.8) * 255
		local color = Color(glow, glow, glow)
		local attachment = self:GetAttachment(1)

		if (attachment) then
			local position = attachment.Pos
			render.SetMaterial(STUNSTICK_GLOW_MATERIAL2)
			render.DrawSprite(position, size * 2, size * 2, color)
			render.SetMaterial(STUNSTICK_GLOW_MATERIAL)
			render.DrawSprite(position, size, size + 3, color_glow)
		end
	end
end

local NUM_BEAM_ATTACHEMENTS = 9
local BEAM_ATTACH_CORE_NAME = "sparkrear"

function SWEP:PostDrawViewModel()
	if (not self:GetActivated()) then return end
	local viewModel = LocalPlayer():GetViewModel()
	if (not IsValid(viewModel)) then return end
	cam.Start3D(EyePos(), EyeAngles())
	local size = math.Rand(3.0, 4.0)
	local color = Color(255, 255, 255, 50 + math.sin(RealTime() * 2) * 20)
	STUNSTICK_GLOW_MATERIAL_NOZ:SetFloat("$alpha", color.a / 255)
	render.SetMaterial(STUNSTICK_GLOW_MATERIAL_NOZ)
	local attachment = viewModel:GetAttachment(viewModel:LookupAttachment(BEAM_ATTACH_CORE_NAME))

	if (attachment) then
		render.DrawSprite(attachment.Pos, size * 10, size * 15, color)
	end

	for i = 1, NUM_BEAM_ATTACHEMENTS do
		local attachment = viewModel:GetAttachment(viewModel:LookupAttachment("spark" .. i .. "a"))
		size = math.Rand(2.5, 5.0)

		if (attachment and attachment.Pos) then
			render.DrawSprite(attachment.Pos, size, size, color)
		end

		local attachment = viewModel:GetAttachment(viewModel:LookupAttachment("spark" .. i .. "b"))
		size = math.Rand(2.5, 5.0)

		if (attachment and attachment.Pos) then
			render.DrawSprite(attachment.Pos, size, size, color)
		end
	end

	cam.End3D()
end
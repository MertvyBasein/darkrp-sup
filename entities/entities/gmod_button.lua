AddCSLuaFile()
local BaseClass = baseclass.Get("base_anim")

function ENT:SetupDataTables()
	self:NetworkVar("Int",		0,	"Key")
	self:NetworkVar("Bool",	0,	"On")

	self:SetOn(false)
	self.Toggled = false
end

function ENT:Initialize()
	if (SERVER) then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetUseType(ONOFF_USE)

	else
		self.PosePosition = 0
	end
end
-- 4327
function ENT:Use(activator, caller, type, value)
	if (!activator:IsPlayer()) then return end		-- Who the frig is pressing this shit!?

	if (self.Toggled) then
		if (type == USE_ON) then
			self:Toggle(!self:GetOn(), activator)
		end
		return
	end

	if (IsValid(self.LastUser)) then return end		-- Someone is already using this button

	if (self:GetOn()) then
		self:Toggle(false, activator)
		return
	end

	self:Toggle(true, activator)
	self:NextThink(CurTime())
	self.LastUser = activator

end

function ENT:Think()
	if (CLIENT) then
		self:UpdateLever()
	end

	if (SERVER && self:GetOn() && !self.Toggled) then
		if (!IsValid(self.LastUser ) || !self.LastUser:KeyDown(IN_USE)) then
			self:Toggle(false, self.LastUser)
			self.LastUser = nil
		end

		self:NextThink(CurTime())
	end
end

function ENT:Toggle(bEnable, ply)
	local pl = self:CPPIGetOwner()
	pl.UsingKeypad = true

	if (bEnable) then
		numpad.Activate(pl, self:GetKey(), true)
		self:SetOn(true)
	else
		numpad.Deactivate(pl, self:GetKey(), true)
		self:SetOn(false)
	end

	pl.UsingKeypad = false
end

function ENT:UpdateLever()
	local TargetPos = 0.0
	if (self:GetOn()) then TargetPos = 1.0 end

	self.PosePosition = math.Approach(self.PosePosition, TargetPos, FrameTime() * 5.0)

	self:SetPoseParameter("switch", self.PosePosition)
	self:InvalidateBoneCache()
end

function ENT:Draw()
	self:DrawModel()
end
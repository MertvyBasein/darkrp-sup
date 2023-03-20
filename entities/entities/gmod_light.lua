AddCSLuaFile()
local BaseClass = baseclass.Get("base_anim")

ENT.Spawnable			= false
ENT.RenderGroup 		= RENDERGROUP_BOTH

local matLight 		= Material("sprites/light_ignorez")
local MODEL			= Model("models/MaxOfS2D/light_tubular.mdl")

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "On")
	self:NetworkVar("Bool", 1, "Toggle")
	self:NetworkVar("Float", 1, "LightSize")
	self:NetworkVar("Float", 2, "Brightness")
end

function ENT:Initialize()
	if (CLIENT) then
		self.PixVis = util.GetPixelVisibleHandle()
	end

	if (SERVER) then
		self:SetModel(MODEL)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:DrawShadow(false)

		self:PhysWake()
	end
end

function ENT:Think()
	if (CLIENT) then
		if (not self:GetOn()) or (not self:InView()) then return end

		local dlight = DynamicLight(self:EntIndex())

		if (dlight) then
			local c = self:GetColor()

			dlight.Pos = self:GetPos()
			dlight.r = c.r
			dlight.g = c.g
			dlight.b = c.b
			dlight.Brightness = self:GetBrightness()
			dlight.Decay = self:GetLightSize() * 5
			dlight.Size = self:GetLightSize()
			dlight.DieTime = CurTime() + 2
		end
	end
end

function ENT:Toggle()
	self:SetOn(not self:GetOn())
end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Cash Register"
ENT.Category = "FoodMode"
ENT.Model = "models/props_c17/cashregister01a.mdl"
ENT.AutomaticFrameAdvance = true
ENT.DisableDuplicator = false
ENT.RemoveOnJobChange = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "State")
	self:NetworkVar("Float", 0, "SessionEarnings")

	if (SERVER) then
		self:SetState(false)
		self:SetSessionEarnings(0)
	end
end

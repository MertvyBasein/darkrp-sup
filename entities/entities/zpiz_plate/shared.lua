ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Plate"
ENT.Model = "models/maxofs2d/hover_plate.mdl"
ENT.AutomaticFrameAdvance = true
ENT.DisableDuplicator = false

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "FoodIndex")
	self:NetworkVar("Float", 0, "FoodWaitTime")

	if (SERVER) then
		self:SetFoodIndex(-1)
		self:SetFoodWaitTime(-1)
	end
end

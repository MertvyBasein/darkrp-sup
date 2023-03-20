ENT.Base = "base_ai" 
ENT.Type = "ai"
ENT.Category = "VRP | Энтити"

ENT.Spawnable = true
ENT.PrintName		= "Тюряжник"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end

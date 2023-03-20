ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName= "Ящик c принтером"
ENT.Author= ""
ENT.Contact= ""
ENT.Purpose= ""
ENT.Instructions= ""
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "RP"


function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Owners")
end

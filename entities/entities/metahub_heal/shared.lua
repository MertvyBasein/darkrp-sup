ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.PrintName		= "Хилка"
ENT.Category 		= "VRP | Энтити"
ENT.Author			= ""

ENT.Contact    		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= ""

ENT.Spawnable			= true;
ENT.AdminSpawnable		= true;

function ENT:SetupDataTables()
 
    self:NetworkVar( "Int", 0, "Amount" )
 
end
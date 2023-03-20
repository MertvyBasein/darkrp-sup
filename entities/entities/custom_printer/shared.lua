
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Money Printer"
ENT.Category = "RP"
ENT.Author = "DarkRP Developers and <enter name here>"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Hacked")
	self:NetworkVar("Entity", 0, "Ownerz")
	self:NetworkVar("Int", 0, "Money")
	self:NetworkVar("Int", 1, "Speed")
	self:NetworkVar("Int", 2, "Sound")
	self:NetworkVar("Int", 3, "money_have")
	self:NetworkVar("Int", 4, "HP")
	self:NetworkVar("Int", 5, "Armor")
	self:NetworkVar("Int", 6, "Temperature")
	self:NetworkVar("Int", 7, "TemperatureLevel")
	self:NetworkVar("Bool", 1, "TP")
end



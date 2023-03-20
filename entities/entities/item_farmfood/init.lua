AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

local tb = {"models/props/eryk/cabbage.mdl","models/props/eryk/carrot.mdl","models/props/eryk/corn.mdl","models/props/eryk/cucumber.mdl","models/props/eryk/garlic.mdl","models/props/eryk/onion.mdl","models/props/eryk/potato.mdl","models/props/eryk/tomato.mdl","models/props/eryk/pepper.mdl"}

function ENT:Initialize()
	self:SetModel(table.Random(tb))
	self:PhysicsInit(SOLID_VPHYSICS)

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end;

function ENT:Use(ply)

end

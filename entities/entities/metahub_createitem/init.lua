AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self:SetModel("models/grillsprops/fp_guncraft_bench/fp_guncraft_bench.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end;

function ENT:Use(ply)
	net.Start('Craft::Menu')
	net.Send(ply)
end

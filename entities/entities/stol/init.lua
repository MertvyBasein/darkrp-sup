AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetCollisionGroup(5)
    
	self:SetModel('models/props/CS_militia/refrigerator01.mdl')
end

function ENT:Use(a)
    --if a:Team() ~= TEAM_REIX18 and a:Team() ~= TEAM_GANG1 then return end
    net.Start('craft_syringe')
    net.WriteEntity(a)
    net.Send(a)
end
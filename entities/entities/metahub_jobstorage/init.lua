AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

util.AddNetworkString("MetaHub.EStorage.TakeItem")


function ENT:Initialize()
	self:SetModel("models/props_wasteland/kitchen_shelf001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end;

function ENT:Use(ply)
	if ply:Team() ~= TEAM_ZAVOD then return rp.Notify(ply,1,'Вы не можете это выполнить') end
	ply:SendLua([[EvreiOpenStorage()]])

end

net.Receive("MetaHub.EStorage.TakeItem", function(len,ply)

	local action = net.ReadString()

	local exp = false

	for k,v in pairs(ents.FindInSphere(ply:GetPos(), 150)) do
		if v:GetClass() == "metahub_jobstorage" then
			exp = true
		end
	end

	if not exp then return end
	if ply:Team() ~= TEAM_ZAVOD then return end

	if action == "mat" then
		if ply.matcd == nil then ply.matcd = CurTime() end
		if ply.matcd > CurTime() then return rp.Notify(ply,1,"Вы недавно брали комплект материалов! Подождите "..util.TimeToStr(math.Round(ply.matcd - CurTime()))) end
		for i = 1,5 do
			ply:AddInv("item_materials")
		end
		ply.matcd = CurTime() + 120

	end

end)
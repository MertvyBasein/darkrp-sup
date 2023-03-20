AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self:SetModel("models/props_wasteland/controlroom_desk001b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end;

local function GetRandomOrder()
	local maintbl = table.Copy(rp.workbench_materials)
	local rand = {}
	for i = 1,math.random(2,5) do
		local tbl = table.Random(maintbl)
		table.insert(rand, tbl.name)
		table.RemoveByValue(maintbl, tbl)
	end

	return rand

end

function ENT:Use(ply)
	local id = ply:GetItemByClass('item_materials')

	if not id then rp.Notify(ply, 1, 'У вас нету материалов чтобы тут работать!') return end

 	ply.inventory[id] = nil
    ply:UpdateWeight()
    ply:UpdateMysqlData()

	local needitem = GetRandomOrder()
	ply:SetNetVar("WorkBench.Orders", needitem)
	ply:SetNetVar('WorkBench.Inventory', {})
	ply:SetNWInt("WorkBecnh.Time", CurTime() + 15 )
	net.Start("MetaHub.WorkBenchMenu")
	net.Send(ply)

	timer.Create("work.ply"..ply:SteamID64(),14.5,1,function()

		if IsValid(ply) then
			rp.Notify(ply,1,'Вы провалили задание!')
			ply:SetNetVar('WorkBench.Inventory', {})
			ply:SetNetVar('WorkBench.Orders', {})
			ply:SendLua([[if IsValid(frame) then frame:Remove() end]])
		end

	end)

end

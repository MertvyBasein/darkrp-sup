plib.IncludeCL 'cl_init.lua'
plib.IncludeSH 'shared.lua'

util.AddNetworkString("MetaHub.OpenSellMenu")
util.AddNetworkString("MetaHub.SellFarm")

function ENT:Initialize()
	self:SetModel('models/adi/models/wildwestrp/male_08_npc.mdl')

	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetMaxYawSpeed(90)

	self:SetTrigger(true)
end

function ENT:Use(ply)
	if self:GetPos():Distance(ply:GetPos()) > 100 then return end
	local items = {}
	for k,v in pairs(ply:GetInventory()) do
		if v.class == "item_materialsfood" then
			table.insert(items, v)
		end
	end

	if #items == 0 then return rp.Notify(ply,1,"У вас нету предметов для продажи") end

	net.Start('MetaHub.OpenSellMenu')
		net.WriteTable(items or {})
	net.Send(ply)
end

net.Receive("MetaHub.SellFarm", function(len,ply)

	local money = 0
	local farmcoast = 20
	local materialcoast = 25
	local tb = net.ReadTable()

	for k,itemid in pairs(tb) do
		local item = ply.inventory[itemid]
		if item.class == "item_farmfood" then
		 	money = money + farmcoast
	 		ply.inventory[itemid] = nil
	 	elseif item.class == "item_materialsfood" then
	 		money = money + materialcoast
	 		ply.inventory[itemid] = nil
	 	end
	end


	rp.Notify(ply,3,"Вы получили с продажи "..rp.FormatMoney(money))
	ply:AddMoney(money)

    ply:UpdateWeight('inv')
    ply:UpdateMysqlData('inv')

end)
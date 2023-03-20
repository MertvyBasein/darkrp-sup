if !file.IsDir('v_npcs', 'DATA') then file.CreateDir('v_npcs') end

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- plib.IncludeCL 'cl_init.lua'
-- plib.IncludeSH 'shared.lua'

util.AddNetworkString("S")
util.AddNetworkString("G")

function ENT:Initialize()
	self:SetModel('models/Humans/Group01/male_02.mdl')

	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetMaxYawSpeed(90)
	self:SetNWInt("Money", 3000)
	self:SetTrigger(true)
end

-- local shop = {}
-- shop.items = {
-- 		{
-- 			name = "Дипломат с разведданными",
-- 			price = 475,
-- 			count = 0,
-- 			mdl = "models/props_c17/BriefCase001a.mdl",
-- 		},
-- 		{
-- 			name = "Груз Самогона",
-- 			price = 258,
-- 			count = 0,
-- 			mdl = "models/props_junk/glassjug01.mdl"
-- 		},
-- 	}

-- shop.shopitem = {
--     {
--         name = "Сода",
--         price = 100,
--         mdl = "models/props_junk/PopCan01a.mdl"
--     }
-- }

function ENT:Use(p)
	if self:GetPos():Distance(p:GetPos()) > 100 then return end
	local str = util.Compress(util.TableToJSON(self.shop))

	net.Start('S')
	net.WriteEntity(self)
	net.WriteUInt(#str, 10)
	net.WriteData(str, #str)
	net.Send(p)
end

net.Receive('S', function(_,p)
	local exploiter = true
    for _, v in ipairs(ents.FindInSphere(p:GetPos(), 200)) do
        if IsValid(v) and (v:GetClass() == 'npc_sell') then
            exploiter = false
            break
        end
    end

    if exploiter then return end
	
	local npc = net.ReadEntity()
	if npc:GetClass() ~= 'npc_sell' then return end
	
	local what = net.ReadBit()
	local shop = tobool(what) and npc.shop.shopitem or npc.shop.items
	local get = net.ReadUInt(5)
	local itm = shop[get]
	local inv = p.inventory
	
	local count = 0
	
	if !tobool(what) then
		if table.Count(inv) == 0 then
			return rp.Notify(p, 1, 'В инвентаре ничего не найдено.')
		end
		for _, x in pairs(inv) do
		
			if x.save_data.subname:StartWith(itm.name) then
				count = count + 1
				rp.Notify(p, 2, 'Успешно продан предмет: ' .. itm.name)
				p:SendLua([[PlayAction("https://metahub.ru/sell.mp3")]])
				npc:SetNWInt("Money", npc:GetNWInt("Money") - tonumber(itm.price))
				p:AddMoney(tonumber(itm.price))
				p.inventory[_] = nil
				p:UpdateWeight("inv")
				p:UpdateMysqlData("inv")
				p:SyncInventory()
				break
			end
		end
		
		return count == 0 and rp.Notify(p, 1, 'В инвентаре ничего не найдено.') or ''
	end

	local limit = 3
	if #inv ~= 0 and tobool(what) then
		for k,v in pairs(inv) do
			count = v.save_data.subname:StartWith(itm.name) and count + 1 or count
			if v.save_data.subname:StartWith(itm.name) && v.save_data.subname:StartWith('Посылка') then
				limit = 1
			end
		end
	end
	if count >= limit then 
		return rp.Notify(p, 1, 'Больше '..limit..'-х предметов купить нельзя!')
	end
	

	if !p:CanAfford(itm.price) then
		return rp.Notify(p, 1, 'У вас недостаточно средств.')
	end
	/*if p.haveEntNPC && itm.ent then 
		return rp.Notify(p, 1, 'У вас уже есть переносимый предмет! Продайте его.')
	end*/
	p:AddMoney(-itm.price)
	rp.Notify(p, 2, 'Вы купили ' .. itm.name .. ' за ' .. rp.FormatMoney(itm.price) ..'.')
	p:SendLua([[PlayAction("https://metahub.ru/buy.mp3")]])
	npc:SetNWInt("Money", npc:GetNWInt("Money") + tonumber(itm.price))

	/*if itm.ent then
		local trace = {}
		trace.start = p:EyePos()
		trace.endpos = trace.start + p:GetAimVector() * 85
		trace.filter = p
		local tr = util.TraceLine(trace)

		local item = ents.Create(itm.ent)
		item:SetPos(tr.HitPos)
		item.ItemOwner = p
		item:Spawn()
		item:CPPISetOwner(p)
		item:PhysWake()

		p.haveEntNPC = true
		return
	end*/
	if itm.ent then
		p:AddInv(itm.ent)
		return
	end
	table.insert(p.inventory, {
		canuse = false,
		class = "shop_itm",
		color = {a = 123, b = 123, g = 255, r = 0},
		save_data = {
			model = itm.mdl,
			--subname = itm.name .. "\nСтоит: " .. rp.FormatMoney(itm.price) .. '.',
			subname = itm.name,
		},
		weight = 1,
	})

	p:UpdateWeight("inv")
	p:UpdateMysqlData("inv")
	p:SyncInventory()
end)

/*function ENT:Touch(ent)
	local data = self.shop.items
	for k,v in pairs(data) do
		if v.ent == ent:GetClass() then
			if IsValid( ent.ItemOwner ) && table.HasValue(ents.FindInSphere(self:GetPos(), 200), ent.ItemOwner) then
				rp.Notify(ent.ItemOwner, 2, 'Предмет успешно продан!')
				ent.ItemOwner:AddMoney(v.price)
				ent.ItemOwner.haveEntNPC = false
			elseif IsValid( ent.ItemOwner ) then
				rp.Notify(ent.ItemOwner, 1, 'Ваш предмет похоже продал кто-то другой :(')
				ent.ItemOwner.haveEntNPC = false
			end
			ent:Remove()
		end
	end
end*/

net.Receive('G', function(_,p)
	if !p:IsSuperAdmin() then return end

	local z = net.ReadUInt(10)
	local tbl = util.TableToJSON(util.JSONToTable(util.Decompress(net.ReadData(z))), true)
	local z, x = file.Find('v_npcs/*', 'DATA')
	print(#z, #x)
	if #z == 0 then
		file.Write('v_npcs/1.json', tbl)
	else
		file.Write('v_npcs/' .. #z+1 .. '.json', tbl)
	end
	rp.Notify(p, 3, 'НПС успешно создан.')

	for k,v in pairs(ents.FindByClass('npc_sell')) do
		v:Remove()
	end
	local f, _ = file.Find('v_npcs/*', 'DATA')
	if #f == 0 then return end
	for z = 1, #f do
		local npc = util.JSONToTable(file.Read('v_npcs/'.. f[z], "DATA"))
		local ent = ents.Create('npc_sell')
		ent:SetPos(npc.pos)
		npc.pos = nil
		ent:SetAngles(Angle(0, npc.angles.y, npc.angles.z))
		npc.angles = nil
		
		ent:Spawn()
		ent:SetModel(npc.mdl)
		npc.mdl = nil
		ent:SetNWString('N', npc.name)
		npc.name = nil
		ent.shop = {}
		ent.shop.items = {}
		ent.shop.shopitem = {}
		for _, itm in pairs(npc) do
			local g = itm:Split(';')
			if (g[1] == 'Inventory' and !tobool(g[5]) or tobool(g[6])) then
				if g[1] == 'Inventory' then
					ent.shop.items[#ent.shop.items + 1] = {
						mdl = g[2];
						name = g[3];
						price = g[4];
					}
				else
					ent.shop.items[#ent.shop.items + 1] = {
						mdl = g[2];
						ent = g[3];
						name = g[4];
						price = g[5];
					}		
				end
			else
				/*ent.shop.shopitem[#ent.shop.shopitem + 1] = {
					mdl = g[1];
					name = g[2];
					price = g[3];
				}*/
				if g[1] == 'Inventory' then
					ent.shop.shopitem[#ent.shop.shopitem + 1] = {
						mdl = g[2];
						name = g[3];
						price = g[4];
					}
				else
					ent.shop.shopitem[#ent.shop.shopitem + 1] = {
						mdl = g[2];
						ent = g[3];
						name = g[4];
						price = g[5];
					}		
				end
			end
		end
	end
end)

hook.Add("InitPostEntity", "FL", function()
	timer.Simple(15, function()
	for k,v in pairs(ents.FindByClass('npc_sell')) do
		v:Remove()
	end
	local f, _ = file.Find('v_npcs/*', 'DATA')
	if #f == 0 then return end
	for z = 1, #f do
		local npc = util.JSONToTable(file.Read('v_npcs/'.. f[z], "DATA"))
		local ent = ents.Create('npc_sell')
		ent:SetPos(npc.pos)
		npc.pos = nil
		ent:SetAngles(Angle(0, npc.angles.y, npc.angles.z))
		npc.angles = nil
		
		ent:Spawn()
		ent:SetModel(npc.mdl)
		npc.mdl = nil
		ent:SetNWString('N', npc.name)
		npc.name = nil
		ent.shop = {}
		ent.shop.items = {}
		ent.shop.shopitem = {}
		for _, itm in pairs(npc) do
			local g = itm:Split(';')
			if (g[1] == 'Inventory' and !tobool(g[5]) or tobool(g[6])) then
				if g[1] == 'Inventory' then
					ent.shop.items[#ent.shop.items + 1] = {
						mdl = g[2];
						name = g[3];
						price = g[4];
					}
				else
					ent.shop.items[#ent.shop.items + 1] = {
						mdl = g[2];
						ent = g[3];
						name = g[4];
						price = g[5];
					}		
				end
			else
				/*ent.shop.shopitem[#ent.shop.shopitem + 1] = {
					mdl = g[1];
					name = g[2];
					price = g[3];
				}*/
				if g[1] == 'Inventory' then
					ent.shop.shopitem[#ent.shop.shopitem + 1] = {
						mdl = g[2];
						name = g[3];
						price = g[4];
					}
				else
					ent.shop.shopitem[#ent.shop.shopitem + 1] = {
						mdl = g[2];
						ent = g[3];
						name = g[4];
						price = g[5];
					}		
				end
			end
		end
	end
	end)
end)

hook.Add("PostCleanupMap", "FL", function()
	local f, _ = file.Find('v_npcs/*', 'DATA')
	for z = 1, #f do
		local npc = util.JSONToTable(file.Read('v_npcs/'.. f[z], "DATA"))
		local ent = ents.Create('npc_sell')
		ent:SetPos(npc.pos)
		npc.pos = nil
		ent:SetAngles(Angle(0, npc.angles.y, npc.angles.z))
		npc.angles = nil
		
		ent:Spawn()
		ent:SetModel(npc.mdl)
		npc.mdl = nil
		ent:SetNWString('N', npc.name)
		npc.name = nil
		ent.shop = {}
		ent.shop.items = {}
		ent.shop.shopitem = {}
		for _, itm in pairs(npc) do
			local g = itm:Split(';')
			if tobool(g[4]) then
					ent.shop.items[#ent.shop.items + 1] = {
						mdl = g[1];
						name = g[2];
						price = g[3];
					}
			else
				ent.shop.shopitem[#ent.shop.shopitem + 1] = {
					mdl = g[1];
					name = g[2];
					price = g[3];
				}
			end
		end
	end
end)


concommand.Add("cleanup", function(p)
	if p:IsSuperAdmin() then game.CleanUpMap() end
end)
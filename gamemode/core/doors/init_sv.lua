util.AddNetworkString('rp.keysMenu')

function ENTITY:DoorIndex()
	return (self:EntIndex() - game.MaxPlayers())
end

function ENTITY:DoorLock(locked)
	self.Locked = locked
	if (locked == true) then
		self:Fire('lock', '', 0)
	elseif (locked == false) then
		self:Fire('unlock', '', 0)
	end
end

function ENTITY:DoorOwn(pl)
	pl:SetVar('doorCount', (pl:GetVar('doorCount') or 0) + 1, false, false)
	self:SetNetVar('DoorData', {Owner = pl})
end

function ENTITY:DoorUnOwn()
	if IsValid(self:DoorGetOwner()) then
		self:DoorGetOwner():SetVar('doorCount', (self:DoorGetOwner():GetVar('doorCount') or 0) - 1, false, false)
	end
	self:DoorLock(false)
	self:SetNetVar('DoorData', nil)
end

function ENTITY:DoorCoOwn(pl)
	local data = self:GetNetVar('DoorData') or {}
	data.CoOwners =  data.CoOwners or {}
	data.CoOwners[#data.CoOwners + 1] = pl
	self:SetNetVar('DoorData', data)
end

function ENTITY:DoorUnCoOwn(pl)
	local data = self:GetNetVar('DoorData') or {}
	table.RemoveByValue(data.CoOwners or {}, pl)
	self:SetNetVar('DoorData', data)
end

function ENTITY:DoorSetOrgOwn(bool)
	local data = self:GetNetVar('DoorData') or {}
	data.OrgOwn = bool
	self:SetNetVar('DoorData', data)
end

function ENTITY:DoorSetTitle(title)
	local data = self:GetNetVar('DoorData') or {}
	data.Title = title
	self:SetNetVar('DoorData', data)
end

function ENTITY:DoorSetTeam(t)
	self:SetNetVar('DoorData', {Team = t})
end

function ENTITY:DoorSetGroup(g)
	self:SetNetVar('DoorData', {Group = g})
end

function ENTITY:DoorSetOwnable(ownable)
	if (ownable == true) then
		self:SetNetVar('DoorData', false)
	elseif (ownable == false) then
		self:SetNetVar('DoorData', nil)
	end
end

function PLAYER:DoorUnOwnAll()
	for k, v in ipairs(ents.GetAll()) do
		if IsValid(v) and v:IsDoor() then 
			if v:DoorOwnedBy(self) then
				v:DoorUnOwn()
			elseif v:DoorCoOwnedBy(self) then
				v:DoorUnCoOwn(self)
			end
		end
	end
end

//
// Load door data
//
local db = rp._Stats

rp.DoorTable = {}

local function loadDoorData()
	for k, v in ipairs(ents.GetAll()) do
		if v:IsDoor() then
			v:Fire('unlock', '', 0)
			v.Locked = false
		end
	end
	db:Query('SELECT * FROM rp_doordata WHERE Map="' .. string.lower(game.GetMap()) .. '";', function(data)


		table.Merge(rp.DoorTable,data)

		for k, v in ipairs(data or {}) do
			local ent = Entity(v.Index + game.MaxPlayers())
			if IsValid(ent) then
				if (v.Title ~= nil) and (v.Title ~= 'NULL') then -- fuck you if you rethink im redoing the door data
					ent:DoorSetTitle(v.Title)
				end

				if (v.Team ~= nil) and (v.Team ~= 'NULL') then
					ent:DoorSetTeam(tonumber(v.Team))
				end

				if (v.Group ~= nil) and (v.Group ~= 'NULL') then
					ent:DoorSetGroup(v.Group)
				end

				if (v.Ownable ~= nil) and (v.Team == nil or v.Team == 'NULL') and (v.Group == nil or v.Group == 'NULL') then
					ent:DoorSetOwnable(tobool(v.Ownable))
				end 

				if (v.Locked ~= nil) and (v.Locked ~= 'NULL') then
					ent:DoorLock(tobool(v.Locked))
				end
			end
		end
	end)
end
hook('InitPostEntity', 'DoorData.InitPostEntity', loadDoorData)


local function storeDoorData(ent)
	db:Query('INSERT INTO rp_doordata(`Index`,`Map`,`Title`,`Team`,`Group`,`Ownable`,`Locked`) VALUES(?,?,?,?,?,?,?)', ent:DoorIndex(), string.lower(game.GetMap()), ent:DoorGetTitle() or 'NULL', ent:DoorGetTeam() or 'NULL', ent:DoorGetGroup() or 'NULL', (ent:DoorIsOwnable() and 0 or 1), (ent.Locked and 1 or 0))
end

local function SaveDoor(ent)
	db:Query('DELETE FROM `rp_doordata` WHERE `Index` = "' .. ent:DoorIndex() .. '"')
	timer.Simple(1,function()
		db:Query('INSERT INTO rp_doordata(`Index`,`Map`,`Title`,`Team`,`Group`,`Ownable`,`Locked`) VALUES(?,?,?,?,?,?,?)', ent:DoorIndex(), string.lower(game.GetMap()), ent:DoorGetTitle() or 'NULL', ent:DoorGetTeam() or 'NULL', ent:DoorGetGroup() or 'NULL', (ent:DoorIsOwnable() and 0 or 1), (ent.Locked and 1 or 0))
	end)
end

//
// Admin Commands
//
concommand.Add('set_nobuy_door', function(pl, text, args)
	if pl:IsSuperAdmin() then
		local ent = pl:GetEyeTrace().Entity
		if IsValid(ent) and ent:IsDoor() then
			pl:DoorUnOwnAll()
			ent:SetNetVar('DoorData', false)
			timer.Simple(1,function()
				SaveDoor(ent)
				pl:ChatPrint('Дверь ' .. ent:DoorIndex() .. ' Теперь не продается ')
			end)
		end
	else
		rp.FlashNotify(pl,'Pablo',"Ты че там тыкаешь, олух!")
	end
end)

concommand.Add('set_yesbuy_door', function(pl, text, args)
	if pl:IsSuperAdmin() then
		local ent = pl:GetEyeTrace().Entity
		if IsValid(ent) and ent:IsDoor() then
			pl:DoorUnOwnAll()
			ent:SetNetVar('DoorData', nil)
			timer.Simple(1,function()
				SaveDoor(ent)
				pl:ChatPrint('Дверь ' .. ent:DoorIndex() .. ' Теперь продается ')
			end)
		end
	else
		rp.FlashNotify(pl,'Pablo',"Ты че там тыкаешь, олух!")
	end
end)

concommand.Add('setteamown', function(pl, text, args)
	if pl:IsSuperAdmin() then
		if pl:IsSuperAdmin() then
			local ent = pl:GetEyeTrace().Entity
			if IsValid(ent) and ent:IsDoor() then
				ent:DoorUnOwn()
				ent:DoorSetTeam(tonumber(args[1]))
				timer.Simple(1,function()
					SaveDoor(ent)
					pl:ChatPrint('Дверь ' .. ent:DoorIndex() .. ' Теперь для ' .. args[1])
				end)
			end
		end	
	else
		rp.FlashNotify(pl,'Pablo',"Ты че там тыкаешь, олух!")
	end	
end)

concommand.Add('setgroupown', function(pl, text, args)
	if pl:IsSuperAdmin() then
		local ent = pl:GetEyeTrace().Entity
		if IsValid(ent) and ent:IsDoor() then
			ent:DoorUnOwn()
			ent:DoorSetGroup(args[1])
			timer.Simple(1,function()
				SaveDoor(ent)
				pl:ChatPrint('Дверь ' .. ent:DoorIndex() .. ' Теперь для ' .. args[1])
			end)
		end
	else
		rp.FlashNotify(pl,'Pablo',"Ты че там тыкаешь, олух!")
	end	
end)

concommand.Add('setlocked', function(pl, text, args)
	if pl:IsSuperAdmin() then
		local ent = pl:GetEyeTrace().Entity
		if IsValid(ent) and ent:IsDoor() then
			rp.Notify(pl, NOTIFY_GENERIC, (ent.Locked and 'Открыто' or 'Закрыто' ))
			ent:DoorLock(not ent.Locked)
		end
	end
end)


//
// Commands
//
concommand.Add('buydoor', function(pl, text, args)
	if (pl:GetVar('doorCount') or 0) >= 8 then
		rp.Notify(pl, NOTIFY_ERROR, 'Вы достигли максимального количества купленных дверей!')
		return
	end

	local cost = pl:Wealth(rp.cfg.DoorCostMin, rp.cfg.DoorCostMax)

	if not pl:CanAfford(cost) then
		rp.Notify(pl, NOTIFY_ERROR, 'У вас не хватает средств для покупки двери.')
		return
	end

	local ent = pl:GetEyeTrace().Entity
	if IsValid(ent) and ent:IsDoor() and ent:DoorIsOwnable() and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then
		pl:TakeMoney(cost)
		rp.Notify(pl, NOTIFY_SUCCESS, 'Вы купили дверь за #.', rp.FormatMoney(cost))
		ent:DoorOwn(pl)
	end
end)

concommand.Add('addcoowner', function(pl, text, args)
	local ent = pl:GetEyeTrace().Entity
	local co = rp.FindPlayer(args[1])

	if IsValid(ent) and ent:IsDoor() and ent:DoorOwnedBy(pl) and (co ~= nil) and (co ~= pl) and not ent:DoorCoOwnedBy(co) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then
		rp.Notify(pl, NOTIFY_SUCCESS, '# был добавлен в Вашу дверь.', co)
		rp.Notify(co, NOTIFY_SUCCESS, '# добавил Вас в свою дверь.', pl)
		ent:DoorCoOwn(co)
	end
end)

concommand.Add('removecoowner', function(pl, text, args)
	local ent = pl:GetEyeTrace().Entity
	local co = rp.FindPlayer(args[1])

	if IsValid(ent) and ent:IsDoor() and ent:DoorOwnedBy(pl) and (co ~= nil) and ent:DoorCoOwnedBy(co) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then
		rp.Notify(pl, NOTIFY_SUCCESS, '# был удалён из Вашей двери.', co)
		rp.Notify(co, NOTIFY_SUCCESS, '# удалил из своей двери.', pl)
		ent:DoorUnCoOwn(co)
	end
end)

concommand.Add('selldoor', function(pl, text, args)
	local ent = pl:GetEyeTrace().Entity
	if IsValid(ent) and ent:IsDoor() and ent:DoorOwnedBy(pl) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then
		pl:AddMoney(rp.cfg.DoorCostMin)
		rp.Notify(pl, NOTIFY_SUCCESS, 'Вы продали # за #.', rp.FormatMoney(rp.cfg.DoorCostMin))
		ent:DoorUnOwn(pl)
	end
end)

concommand.Add('settitle', function(pl, text, args)
	if (text == '') then return end
	local ent = pl:GetEyeTrace().Entity
	if IsValid(ent) and ent:IsDoor() and ent:DoorOwnedBy(pl) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) then
		rp.Notify(pl, NOTIFY_GENERIC, 'Название изменено.')
		ent:DoorSetTitle(string.sub(args[1], 1, 25))
	end
end)

concommand.Add('orgown', function(pl, text, args)
	local ent = pl:GetEyeTrace().Entity
	if IsValid(ent) and ent:IsDoor() and ent:DoorOwnedBy(pl) and (ent:GetPos():DistToSqr(pl:GetPos()) < 13225) and pl:GetOrg() then
		rp.Notify(pl, NOTIFY_GENERIC, (ent:DoorOrgOwned() and 'Владение организации запрещено.' or 'Владение организации разрешено.'))
		ent:DoorSetOrgOwn(not ent:DoorOrgOwned())
	end
end)

concommand.Add('sellall', function(pl, text, args)
	if (pl:GetVar('doorCount') or 0) <= 0 then
		rp.Notify(pl, NOTIFY_ERROR, 'У вас нет дверей для продажи.')
		return
	end
	local count = pl:GetVar('doorCount')

	if count == 0 then return false end

	local amt = (count * rp.cfg.DoorCostMin)

	pl:DoorUnOwnAll()

	pl:AddMoney(amt)

	rp.Notify(pl, NOTIFY_SUCCESS, 'Вы продали # дверей за #.', count, rp.FormatMoney(amt))
end)

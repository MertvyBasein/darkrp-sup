rp.orgs = rp.orgs or {}
rp.orgs.cached = rp.orgs.cached or {}

require('pcolor')

util.AddNetworkString('rp.OrgsMenu')
util.AddNetworkString('rp.SetOrgMoTD')
util.AddNetworkString('org.setflag')

local db = rp._Stats

net.Receive('org.setflag', function(_,ply)
	local imgurid = net.ReadString()

	if !IGS.CanAfford(ply, 250) then return rp.Notify(ply,1,'Вы не можете себе это позволить! (250р)') end

	ply:AddIGSFunds(-250)

	db:Query('UPDATE orgs SET Flag=? WHERE Name=?', imgurid, ply:GetOrg(), function()
		local orgdata = ply:GetOrgData()
		orgdata.Flag = imgurid

		ply:SetOrgData(orgdata)

		rp.Notify(ply,NOTIFY_SUCCESS,'Вы изменили флаг клана!')
	end)
end)

-- Creation & Modification
function rp.orgs.Exists(name, cback)
	db:Query('SELECT COUNT("Name") FROM orgs WHERE Name=?;', name, function(count)
		cback(count[1]['COUNT("Name")'] and tonumber(count[1]['COUNT("Name")']) > 0)
	end)
end

function rp.orgs.Create(steamid, name, color, callback)
	db:Query('INSERT INTO orgs(Owner, Name, Color, MoTD, Flag) VALUES(?, ?, ?, ?, ?);', steamid, name, pcolor.ToHex(color), 'Welcome to ' .. name .. '!', 'P4VmqOM', function()
		db:Query('INSERT INTO org_rank(Org, RankName, Weight, Invite, Kick, Rank, MoTD) VALUES(?, ?, ?, ?, ?, ?, ?),(?, ?, ?, ?, ?, ?, ?);', name, 'Owner', 100, 1, 1, 1, 1, name, 'Member', 1, 0, 0, 0, 0, function()
			rp.orgs.cached[name] = {
				Members = {},
				Ranks = {
					Owner = {
						Org=name,
						RankName='Owner',
						Weight=100,
						Invite=true,
						Kick=true,
						Rank=true,
						MoTD=true
					},
					Members = {
						Org=name,
						RankName='Member',
						Weight=1,
						Invite=false,
						Kick=false,
						Rank=false,
						MoTD=false
					}
				}
			}
		
			rp.orgs.Join(steamid, name, 'Owner', callback)
		end)
	end)
end

function rp.orgs.Remove(name, callback)
	db:Query('DELETE FROM orgs WHERE Name=?;', name, function()
		db:Query('DELETE FROM org_player WHERE Org=?;', name, function()
			db:Query('DELETE FROM org_rank WHERE Org=?;', name, function()
				for k, v in ipairs(rp.orgs.GetOnlineMembers(name)) do
					v:SetOrg(nil, nil)
					v:SetOrgData(nil)
					rp.Notify(v, NOTIFY_ERROR, "# был распущен!", name)
				end
				
				rp.orgs.cached[name] = nil
				
				if callback then callback() end
			end)
		end)
	end)
end

function rp.orgs.Quit(steamid, callback)
	db:Query('DELETE FROM org_player WHERE SteamID=?;', steamid, callback)
end

function rp.orgs.SetMoTD(org, motd, callback)
	db:Query('UPDATE orgs SET MoTD=? WHERE Name=?', motd, org, function() -- this line was not playing nice
		for k, v in ipairs(rp.orgs.GetOnlineMembers(org)) do
			local dat = v:GetOrgData()
			dat.MoTD = motd
			v:SetOrgData(dat)
		end
		if callback then callback() end
	end)
end

function rp.orgs.SetColor(org, color, callback)
	db:Query('UPDATE orgs SET Color=? WHERE Name=?', pcolor.ToHex(color), org, function()
		for k, v in ipairs(rp.orgs.GetOnlineMembers(org)) do
			v:SetOrg(org, color)
		end
		if callback then callback() end
	end)
end


-- Members
function PLAYER:SetOrg(name, color)
	self:SetNetVar('Org', name)
	self:SetNetVar('OrgColor', color)
end

function rp.orgs.Join(steamid, org, rank, callback)
	rp.orgs.cached[org].Members[steamid] = {
		SteamID=steamid,
		Org=org,
		Rank=rank
	}
	
	db:Query('INSERT INTO org_player(SteamID, Org, Rank) VALUES(?, ?, ?);', steamid, org, rank, callback)
end

function rp.orgs.Kick(steamid, callback)
	local pl = rp.FindPlayer(steamid)
	if (pl) then steamid = pl:SteamID64() end
	
	db:Query('DELETE FROM org_player WHERE SteamID=?;', steamid, function()
		if IsValid(pl) then
			rp.Notify(rp.orgs.GetOnlineMembers(pl:GetOrg()), NOTIFY_ERROR, '# кикнут из организации #.', pl, pl:GetOrg())
			rp.Notify(pl, NOTIFY_ERROR, 'Вы были кикнуты из организации #.', pl:GetOrg())
			pl:SetOrg(nil, nil)
			pl:SetOrgData(nil)
		end
		
		if callback then callback() end
	end)
end

function rp.orgs.GetMembers(org, callback)
	db:Query("SELECT * FROM org_rank WHERE Org=? ORDER BY Weight DESC;", org, function(ranks)
		db:Query('SELECT org_player.SteamID, org_player.Rank, player_data.Name FROM org_player LEFT JOIN player_data ON org_player.SteamID = player_data.SteamID WHERE org_player.Org = ?;', org, function(members)
		
			rp.orgs.cached[org] = {
				Ranks = {},
				Members = {},
				RanksOrdered = ranks
			}
			
			for k, v in ipairs(ranks) do
				rp.orgs.cached[org].Ranks[v.RankName] = v
			end
			
			for k, v in ipairs(members) do
				rp.orgs.cached[org].Members[v.SteamID] = v
			end
			
			if (callback) then callback(members, ranks) end
		end)
	end)
end

function rp.orgs.GetMemberCount(name, cback)
	db:Query('SELECT COUNT("Name") FROM org_player WHERE Org=?;', name, function(count)
		cback(count[1]['COUNT("Name")'] and tonumber(count[1]['COUNT("Name")']) or 0)
	end)
end

-- Ranks
function PLAYER:SetOrgData(d)
	self:SetNetVar('OrgData', d)
end

function rp.orgs.RecalculateWeights(org, ranks)
	table.SortByMember(ranks, 'Weight', true)
	
	local mems = rp.orgs.GetOnlineMembers(org)
	
	for k, v in ipairs(ranks) do
		local newWeight = 1 + math.floor(((k - 1) / (#ranks - 1)) * 99)
		
		if (newWeight != v.Weight) then		
			for _, pl in pairs(mems) do
				local od = pl:GetOrgData()
				if (od.Rank == v.RankName) then
					od.Weight = v.Weight
					pl:SetOrgData(od)
				end
			end
			
			db:Query('UPDATE org_rank SET Weight=? WHERE Org=? AND RankName=?', newWeight, org, v.RankName)
		end
		
		rp.orgs.cached[org].Ranks[v.RankName].Weight = newWeight
	end
end

function rp.orgs.CanTarget(pl, targID)
	if (!pl:GetOrg()) then return false end
	if (pl:SteamID64() == targID) then return false end
	if (#tostring(targID) != 17) then return false end
	
	if (!rp.orgs.cached[pl:GetOrg()]) then rp.orgs.GetMembers(pl:GetOrg()) end
	
	local targrank = rp.orgs.cached[pl:GetOrg()].Ranks[rp.orgs.cached[pl:GetOrg()].Members[targID].Rank] or rp.orgs.cached[pl:GetOrg()].RanksOrdered[#rp.orgs.cached[pl:GetOrg()].RanksOrdered]
	if (pl:GetOrgData().Perms.Weight <= targrank.Weight) then return false end
	
	return true
end

-- Load data
local function SetOrg(pl, d)
	pl:SetOrg(d.Name, pcolor.FromHex(d.Color))
	local r = d.OrgData
	pl:SetOrgData({
		Rank 	= d.Rank or r.Perms.RankName,
		MoTD 	= d.MoTD,
		Flag 	= d.Flag,
		Perms 	= {
			Weight 	= r.Perms.Weight,
			Owner 	= (r.Perms.Weight == 100),
			Invite 	= r.Perms.Invite,
			Kick 	= r.Perms.Kick,
			Rank 	= r.Perms.Rank,
			MoTD 	= r.Perms.MoTD,
		}
	})
end


hook('PlayerAuthed', 'rp.orgs.PlayerAuthed', function(pl)
--concommand.Add('or', function(pl)
	local steamid = pl:SteamID64()
	db:Query('SELECT * FROM org_player LEFT JOIN orgs ON org_player.Org = orgs.Name WHERE org_player.SteamID=' .. steamid .. ';', function(data)
		local d = data[1]
		if d then
			d.OrgData = {}
			db:Query('SELECT * FROM org_rank WHERE Org = "' .. d.Org .. '" AND RankName = "' .. d.Rank .. '";', function(data)
				local _d = data[1]
				if _d then
					d.OrgData.Perms = _d
					SetOrg(pl, d)
				end
			end)
		end
	end)
end)


-- Commands

concommand.Add('createorg', function(pl, text, args)
	local name = string.Trim(args[1] or '')

	if (pl:GetOrg() ~= nil) then
		rp.Notify(pl, NOTIFY_ERROR, 'Вам нужно покинуть организацию чтобы создать новую.')
		return
	end

	if (string.len(name) < 2) then
		rp.Notify(pl, NOTIFY_ERROR, 'Пожалуйста, сделайте название своей организации длиннее чем 2 буквы.')
		return
	end

	if (string.len(name) > 20) then
		rp.Notify(pl, NOTIFY_ERROR, 'Пожалуйста, сделайте название своей организации короче чем чем 20 букв.')
		return
	end

	rp.orgs.Exists(name, function(exists)
		if (!IsValid(pl)) then return end
		
		if (exists) then
			rp.Notify(pl, NOTIFY_ERROR, 'Это имя уже занято. Пожалуйста выберите другое!')
			return
		end

		if not pl:CanAfford(rp.cfg.OrgCost) then
			rp.Notify(pl, NOTIFY_ERROR, 'Вы не можете позволить себе создать организацию.')
			return
		end

		local color = Color(255,255,255)
		local start = SysTime()
		rp.orgs.Create(pl:SteamID64(), name, color, function()
			pl:TakeMoney(rp.cfg.OrgCost)
			pl:SetOrg(name, color)
			local orgdata = rp.orgs.BaseData['Owner']
			orgdata.MoTD = 'Welcome to ' .. name .. '!'
			orgdata.Flag = 'https://img.icons8.com/sf-regular/48/4D4D4D/safety-collection-place.png'
			pl:SetOrgData(orgdata)
			rp.Notify(pl, NOTIFY_SUCCESS, 'Вы успешно создали свою организацию.')
		end)
	end)
end)

net('rp.SetOrgMoTD', function(len, pl)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Owner then return end

	local motd = net.ReadString()
	rp.orgs.SetMoTD(pl:GetOrg(), motd, function()
		rp.Notify(pl, NOTIFY_SUCCESS, 'Вы изменили вашу организацию MoTD.')
	end)
end)

concommand.Add('setorgcolor', function(pl, text, args)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Owner then return end

	local color = Color(tonumber(args[1] or 255), tonumber(args[2] or 255), tonumber(args[3] or 255))

	rp.orgs.SetColor(pl:GetOrg(), color, function()
		rp.Notify(pl, NOTIFY_SUCCESS, 'Вы изменили цвет организации.')
	end)
end)

concommand.Add('orgmenu', function(pl, text, args)
	if not pl:GetOrg() then return end

	rp.orgs.GetMembers(pl:GetOrg(), function(members, ranks)
		net.Start('rp.OrgsMenu')
			local rankref = {}

			net.WriteUInt(#ranks, 4)
			for k, v in ipairs(ranks) do
				net.WriteString(v.RankName)
				net.WriteUInt(v.Weight, 7)
				net.WriteBool(v.Invite)
				net.WriteBool(v.Kick)
				net.WriteBool(v.Rank)
				net.WriteBool(v.MoTD)
				
				rankref[v.RankName] = v.RankName
			end
			
			net.WriteUInt(#members, 8)
			for k, v in ipairs(members) do
				net.WriteString(v.SteamID)
				net.WriteString(v.Name)
				net.WriteString(rankref[v.Rank] or ranks[#ranks].Rank) -- fix for players being a rank that doesnt exist
			end

		net.Send(pl)
	end)
end)

util.AddNetworkString('rp.OrgsMenus')

net('rp.OrgsMenus', function(_,pl)
	if not pl:GetOrg() then return end

	rp.orgs.GetMembers(pl:GetOrg(), function(members, ranks)
		net.Start('rp.OrgsMenus')
			local rankref = {}

			net.WriteUInt(#ranks, 4)
			for k, v in ipairs(ranks) do
				net.WriteString(v.RankName)
				net.WriteUInt(v.Weight, 7)
				net.WriteBool(v.Invite)
				net.WriteBool(v.Kick)
				net.WriteBool(v.Rank)
				net.WriteBool(v.MoTD)
				
				rankref[v.RankName] = v.RankName
			end
			
			net.WriteUInt(#members, 8)
			for k, v in ipairs(members) do
				net.WriteString(v.SteamID)
				net.WriteString(v.Name)
				net.WriteString(rankref[v.Rank] or ranks[#ranks].Rank) -- fix for players being a rank that doesnt exist
			end

		net.Send(pl)
	end)
end)

concommand.Add('quitorg', function(pl, text, args)
	if not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms then return end
	if (!rp.orgs.cached[pl:GetOrg()]) then rp.orgs.GetMembers(pl:GetOrg()) end
	
	if (pl:GetOrgData().Rank == "Stuck") and (not pl:IsRoot()) then
		rp.Notify(pl, NOTIFY_ERROR, 'Вы застряли! >:)')
		return
	end -- EASTER EGGS
	
	if pl:GetOrgData().Perms.Owner then
		rp.orgs.Remove(pl:GetOrg())
	else
		rp.orgs.Quit(pl:SteamID64(), function()
			rp.orgs.cached[pl:GetOrg()].Members[pl:SteamID64()] = nil
		
			rp.Notify(rp.orgs.GetOnlineMembers(pl:GetOrg()), NOTIFY_ERROR, '# вышел из #!', pl, pl:GetOrg())
			pl:SetOrg(nil, nil)
			pl:SetOrgData(nil)
		end)
	end
end)

concommand.Add('orgkick', function(pl, text, args)
	if not args[1] or not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Kick or not rp.orgs.CanTarget(pl, args[1]) then return end
	
	rp.orgs.cached[pl:GetOrg()].Members[args[1]] = nil
	
	rp.orgs.Kick(args[1])
end)

concommand.Add('orginvite', function(pl, text, args)
	if not args[1] or not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Invite then return end
	local targ = rp.FindPlayer(args[1])
	
	if (targ:GetOrg()) then return end
	
	if (!rp.orgs.cached[pl:GetOrg()]) then rp.orgs.GetMembers(pl:GetOrg()) end

	local org = pl:GetOrg()

	rp.orgs.GetMemberCount(org, function(count)
		if (!IsValid(pl)) then return end
		
		local lim = (500)
		if (count >= lim) then
			rp.Notify(pl, NOTIFY_ERROR, 'Вы достигли максимального количество # членов в организации!', lim)
			return
		end

		if not IsValid(targ) then return end
		
		if (targ.OrgInvites and targ.OrgInvites[org]) then return end
		targ.OrgInvites = targ.OrgInvites or {}
		targ.OrgInvites[org] = true
		GAMEMODE.ques:Create("Хотели бы вы присоединиться " .. org, util.CRC(pl:SteamID() .. targ:SteamID()), targ, 300, function(resp)
			if (tobool(resp) == true)  then
				db:Query("SELECT * FROM org_rank WHERE Org=? AND Weight=1;", pl:GetOrg(), function(data)
					rp.orgs.Join(targ:SteamID64(), org, data[1].RankName, function()
						targ:SetOrg(org, pl:GetOrgColor())
						local orgdata = {
							Rank = data[1].RankName,
							MoTD = pl:GetOrgData().MoTD,
							Flag = pl:GetOrgData().Flag,
							Perms = {
								Weight = data[1].Weight,
								Owner = (data[1].Weight == 100),
								Invite = data[1].Invite,
								Kick = data[1].Kick,
								Rank = data[1].Rank,
								MoTD = data[1].MoTD
							}
						}
						
						targ:SetOrgData(orgdata)
						
						rp.orgs.cached[pl:GetOrg()].Members[targ:SteamID64()] = {
							SteamID=targ:SteamID64(),
							Org=org,
							Rank=data[1].RankName
						}
						
						rp.Notify(rp.orgs.GetOnlineMembers(targ:GetOrg()), NOTIFY_SUCCESS, '# присоединился к #.', targ, targ:GetOrg())
						targ.OrgInvites[org] = nil
					end)
				end)
			end	
		end)
	end)
end)

concommand.Add('orgsetrank', function(pl, text, args)
	if not args[1] or not pl:GetOrg() or not pl:GetOrgData() or not pl:GetOrgData().Perms or not pl:GetOrgData().Perms.Rank or not rp.orgs.CanTarget(pl, args[1]) then return end
	
	local rankName = args[2]
	local cache = rp.orgs.cached[pl:GetOrg()].Ranks
	
	if (!cache[rankName] or pl:GetOrgData().Perms.Weight <= cache[rankName].Weight) then return end
	
	db:Query('SELECT * FROM org_rank WHERE Org=?', pl:GetOrg(), function(ranks)
		for k, v in ipairs(ranks) do
			if (v.RankName == rankName) then
				db:Query("UPDATE org_player SET Rank=? WHERE SteamID=?;", rankName, args[1])
				
				local targ = rp.FindPlayer(args[1])
				if (targ) then
					local od = targ:GetOrgData()
					
					targ:SetOrgData({
						Rank 	= v.RankName,
						MoTD 	= od.MoTD,
						Flag =  od.Flag,
						Perms 	= {
							Weight 	= v.Weight,
							Owner 	= (v.Weight == 100),
							Invite 	= v.Invite,
							Kick 	= v.Kick,
							Rank 	= v.Rank,
							MoTD 	= v.MoTD
						}
					})
					
					rp.Notify(targ, NOTIFY_GENERIC, '# установил ваш ранг #.', pl, rankName)
					rp.Notify(pl, NOTIFY_GENERIC, '# добавлен #.', targ, rankName)
				else					
					rp.Notify(pl, NOTIFY_GENERIC, '# добавлен #.', args[1], rankName)
				end
				
				rp.orgs.cached[pl:GetOrg()].Members[args[1]].Rank = rankName
				
				return
			end
		end
		
		rp.Notify(pl, NOTIFY_ERROR, 'неизвестный ранг #.', rankName)
	end)
end)

concommand.Add('orgrank', function(pl, text, args)
	local perms = pl:GetOrg() and pl:GetOrgData() and pl:GetOrgData().Perms
	
	if (!args[1] or !perms or !perms.Owner) then return end

	if (!rp.orgs.cached[pl:GetOrg()]) then rp.orgs.GetMembers(pl:GetOrg()) end
	
	local rankName = args[1]
	local newName
	local weight
	local invite
	local kick
	local rank
	local motd
	
	if (args[6]) then
		weight = tonumber(args[2])
		invite = args[3]
		kick = args[4]
		rank = args[5]
		motd = args[6]
	else
		newName = args[2]
	end
	
	db:Query('SELECT * FROM org_rank WHERE Org=?', pl:GetOrg(), function(ranks)
		for k, v in ipairs(ranks) do
			if (v.RankName == rankName) then
				if (newName) then
					db:Query("UPDATE org_rank SET RankName=? WHERE Org=? AND RankName=?", newName, pl:GetOrg(), rankName, function()
						db:Query("UPDATE org_player SET Rank=? WHERE Org=? AND Rank=?;", newName, pl:GetOrg(), rankName)
						
						rp.Notify(pl, NOTIFY_SUCCESS, 'Ранг # переименован в #.', rankName, newName)
						
						for k, v in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrg())) do
							if (v:GetOrgData().Rank == rankName) then
								local orgData = v:GetOrgData()
								orgData.Rank = newName
								v:SetOrgData(orgData)
							end
						end
						
						for k, v in pairs(rp.orgs.cached[pl:GetOrg()].Members) do
							if (v.Rank == rankName) then
								v.Rank = newName
							end
						end
						
						rp.orgs.cached[pl:GetOrg()].Ranks[newName] = rp.orgs.cached[pl:GetOrg()].Ranks[rankName]
						rp.orgs.cached[pl:GetOrg()].Ranks[newName].RankName = newName
						rp.orgs.cached[pl:GetOrg()].Ranks[rankName] = nil
					end)
					
					return
				end
				
				if (weight != v.Weight) then
					if (v.Weight == 100 or v.Weight == 1) then
						rp.Notify(pl, NOTIFY_ERROR, 'Вы не можете изменить Высший и Низший ранги.')
						return
					end
					
					v.Weight = weight
					rp.orgs.RecalculateWeights(pl:GetOrg(), ranks)
					return
				end
				
				db:Query("UPDATE org_rank SET Invite=?, Kick=?, Rank=?, MoTD=? WHERE Org=? AND RankName=?;", invite, kick, rank, motd, pl:GetOrg(), rankName, function()
					rp.Notify(pl, NOTIFY_SUCCESS, 'Ранг # обновлен.', rankName)
					
					for k, v in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrg())) do
						if (v:GetOrgData().Rank == rankName) then
							v:SetOrgData({
								Rank 	= rankName,
								MoTD 	= v:GetOrgData().MoTD,
								Flag 	= v:GetOrgData().Flag,
								Perms 	= {
									Weight 	= weight,
									Owner 	= (weight == 100),
									Invite 	= tobool(invite),
									Kick 	= tobool(kick),
									Rank 	= tobool(rank),
									MoTD 	= tobool(motd)
								}
							})
						end
					end
					
					local cache = rp.orgs.cached[pl:GetOrg()].Ranks[rankName]
					cache.Invite = tobool(invite)
					cache.Kick = tobool(kick)
					cache.Rank = tobool(rank)
					cache.MoTD = tobool(motd)
				end)
				
				return
			end
		end
		
		-- Insert time!
		if (#ranks >= (5)) then
			rp.Notify(pl, NOTIFY_ERROR, 'Максимальный ранг достигнут.')
			return
		end
		
		db:Query("INSERT INTO org_rank(Org, RankName, Weight, Invite, Kick, Rank, MoTD) VALUES(?, ?, ?, ?, ?, ?, ?);", pl:GetOrg(), rankName, weight, invite, kick, rank, motd, function()
			rp.orgs.cached[pl:GetOrg()].Ranks[rankName] = ranks[table.insert(ranks, {
				Org = pl:GetOrg(),
				RankName = rankName,
				Weight = weight,
				Invite = tobool(invite),
				Kick = tobool(kick),
				Rank = tobool(rank),
				MoTD = tobool(motd)
			})]
			
			rp.orgs.RecalculateWeights(pl:GetOrg(), ranks)
			
			rp.Notify(pl, NOTIFY_SUCCESS, 'Ранг # Создан.', rankName)
		end)
	end)
end)

concommand.Add('orgrankremove', function(pl, text, args)
	local perms = pl:GetOrg() and pl:GetOrgData() and pl:GetOrgData().Perms
	
	if (!args[1] or !perms or !perms.Owner) then return end
	
	if (!rp.orgs.cached[pl:GetOrg()]) then rp.orgs.GetMembers(pl:GetOrg()) end
	
	local rankName = args[1]
	
	db:Query("SELECT * FROM org_rank WHERE Org=? ORDER BY Weight DESC", pl:GetOrg(), function(ranks)
		for k, v in ipairs(ranks) do
			if (v.RankName == rankName) then
				if (k == 1 or k == #ranks) then
					rp.Notify(pl, NOTIFY_ERROR, 'Вы не можете удалить высший и низший ранг.')
					return
				end
				
				local nextRank = ranks[k+1]
				db:Query("UPDATE org_player SET Rank=? WHERE Org=? AND Rank=?", nextRank.RankName, pl:GetOrg(), rankName)
				db:Query("DELETE FROM org_rank WHERE Org=? AND RankName=?", pl:GetOrg(), rankName)
				for _, pl in ipairs(rp.orgs.GetOnlineMembers(pl:GetOrg())) do
					local od = pl:GetOrgData()
					
					if (od.Rank == rankName) then
						od = {
							Rank 	= nextRank.RankName,
							MoTD 	= od.MoTD,
							Flag 	= od.Flag,
							Perms 	= {
								Weight 	= nextRank.Weight,
								Owner 	= (nextRank.Weight == 100),
								Invite 	= nextRank.Invite,
								Kick 	= nextRank.Kick,
								Rank 	= nextRank.Rank,
								MoTD 	= nextRank.MoTD,
							}
						}
						
						pl:SetOrgData(od)
					end
				end
				
				for _, mem in pairs(rp.orgs.cached[pl:GetOrg()].Members) do
					if (mem.Rank == rankName) then
						mem.Rank = nextRank.Name
					end
				end
				
				rp.orgs.cached[pl:GetOrg()].Ranks[rankName] = nil
				
				rp.Notify(pl, NOTIFY_SUCCESS, 'Ранг # удалён.', rankName)
				
				return
			end
		end
		
		rp.Notify(pl, NOTIFY_ERROR, 'неизвестный ранг #.', rankName)
	end)
end)

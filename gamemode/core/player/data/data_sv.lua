rp.data = rp.data or {}
local db = rp._Stats

function rp.data.LoadPlayer(pl, cback)
	db:Query('SELECT * FROM player_data WHERE SteamID=' .. pl:SteamID64() .. ';', function(_data)
		local data = _data[1] or {}

		if IsValid(pl) then
			if (#_data <= 0) then
				db:Query([[INSERT INTO player_data(SteamID, Name, Money, Privilege, BonusTime, inventory, inventory_bank, gang, gang_rank, accessories, permaweps)
				VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);]], pl:SteamID64(), pl:SteamName(), rp.cfg.StartMoney, '[]', 0, '[]', '[]', '', '', '[]', '')
				pl.permaweps = {}
				net.Start('VRP.OpenCharacterMenu')
				net.Send(pl)

				data = {
					SteamID = pl:SteamID64(),
					Name = pl:SteamName(),
					Money = rp.cfg.StartMoney,
					Privilege = {},
					BonusTime = 0,
					inventory = {},
					inventory_bank = {},
					accessories = {},
					permaweps = ''
				}
			else
				data.inventory 		= util.JSONToTable(data.inventory) or {}
				data.inventory_bank = util.JSONToTable(data.inventory_bank) or {}
				data.Privilege 		= util.JSONToTable(data.Privilege)	or {}
			end

			pl.inventory = data.inventory
			pl.bank = data.inventory_bank

			pl.permaweps = string.Split(data.permaweps or '', ' ')

			nw.WaitForPlayer(pl, function()
				if data.Name and (data.Name ~= pl:SteamName()) then
					pl:SetNetVar('Name', data.Name)
				end		

				pl:SetNetVar('Money', data.Money or rp.cfg.StartMoney)
				pl:SetNetVar('bonustime', data.BonusTime or 0)
				pl:SetNetVar('TotalTime', data.TotalTime or 1)

				pl:SetVar('lastpayday', CurTime() + 180, false, false)
				pl:SetVar('DataLoaded', true)

				pl:SyncInventory()

				hook.Call('PlayerDataLoaded', GAMEMODE, pl, data)

				pl:SendLua([[hook.Call('PlayerDataLoaded', GAMEMODE)]])
				pl:SetNWBool('PlayerDataLoaded', true)

			end)

			if cback then cback(data) end
		end
	end)
end

hook.Add('PlayerDataLoaded', 'CheckGroupExpires', function(pl, data)
	local info = data.Privilege

	if info.exp then
		if os.time() > info.exp then
			pl:svtext(Color(90, 150, 230), '[MP] ', Color(255,255,255), pl:Name() .. ', ваша привилегия истекла!')
	
			local first  = (info.old == "user") and "removeuserid" or "adduserid"
	
			RunConsoleCommand("ulx", first, pl:SteamID(), info.old)
			RemoveTPrivilege(pl:SteamID64())
		end
	end
end)


hook.Add('PlayerDataLoaded', 'UnlockedJobs', function(pl)
    db:Query('SELECT * FROM rp_unlocks WHERE SteamID=' .. pl:SteamID64() .. ';', function(_data)
        local data = _data[1] or {}

        if IsValid(pl) and (#_data <= 0) then
            db:Query('INSERT INTO rp_unlocks(SteamID, JobUnlocks) VALUES(?, ?);', pl:SteamID64(), '[]')
        end

        local jTable = (#_data > 0) and util.JSONToTable(data.JobUnlocks) or {}
        pl:SetNetVar('JobUnlocks',  jTable)
    end)
end)

hook.Add('PlayerDataLoaded', 'OtherStuff', function(pl, data)
	//local PointsHistory = istable(data.PointsHistory) and util.JSONToTable(data.PointsHistory) or {}
	//pl:SetNetVar('PointsHistory', PointsHistory)
	//pl:SetNetVar('LPoints', data.LPoints or 0)
	//pl:SetNetVar('VPoints', data.VPoints or 0)

	local sModel = 'models/hts/comradebear/pm0v3/player/citizens/default_male_06.mdl'
	local model = pl:GetPData('CitizenModel', sModel)
	local static = math.random(121121, 123123)
	local fakenum = math.random(100, 999)

    local AcsTable = (#data.accessories > 0) and util.JSONToTable(data.accessories) or {}
    pl:SetNetVar('rp.Accessories',  AcsTable)

	pl:SetNetVar('Static', data.id or static)
	pl:SetNetVar('bonustime', data.BonusTime or 0)
	--pl:SetNetVar('CitizenModel', model)
	pl:SetNetVar('rp.LastReport', 0)
	pl:SetNetVar('rp.ReportClaimed', false)
	--pl:SetNetVar("MetaHub.Company", {})
	pl:SyncInventory() -- на всякий случай

	pl:SetNWFloat('MH_Stamina', 1000.0)
	pl:SelectWeapon('keys')
	pl:SetModel(model)
end)

function GM:PlayerAuthed(pl)
	rp.data.LoadPlayer(pl)
end

function rp.data.SetName(pl, name, cback)
	db:Query('UPDATE player_data SET Name=? WHERE SteamID=' .. pl:SteamID64() .. ';', name, function(data)
		pl:SetNetVar('Name', name)
		if cback then cback(data) end
	end)
end

function rp.data.GetNameCount(name, cback)
	db:Query('SELECT COUNT(*) as `count` FROM player_data WHERE Name=?;', name, function(data)
		if cback then cback(tonumber(data[1].count) > 0) end
	end)
end

function rp.data.GetCidCount(name, cback)
	db:Query('SELECT COUNT(*) as `count` FROM player_data WHERE id=?;', name, function(data)
		if cback then cback(tonumber(data[1].count) > 0) end
	end)
end

function rp.data.SetMoney(pl, amount, cback)
	db:Query('UPDATE player_data SET Money=? WHERE SteamID=' .. pl:SteamID64() .. ';', amount, cback)
end

function rp.data.PayPlayer(pl1, pl2, amount)
	if not IsValid(pl1) or not IsValid(pl2) then return end
	pl1:TakeMoney(amount, 'Передача денег -> ' .. pl2:SteamID64())
	pl2:AddMoney(amount, 'Передача денег <- ' .. pl1:SteamID64())
end

function rp.data.IsLoaded(pl)
	if IsValid(pl) and (pl:GetVar('DataLoaded') ~= true) then
		local timerName = "PlayerReload:" .. pl:UniqueID()

		file.Append('data_load_err.txt', os.date() .. '\n' .. pl:Name() .. '\n' .. pl:SteamID() .. '\n' .. pl:SteamID64() .. '\n' .. debug.traceback() .. '\n\n')
		rp.Notify(pl, NOTIFY_ERROR,  'ВАШИ ДАННЫЕ НЕ ЗАГРУЖЕНЫ. ПОЖАЛУЙСТА, ПОДОЖДИТЕ. ЕСЛИ ЭТО СЛУЧИТСЯ СНОВА, ПОЖАЛУЙСТА, СООБЩИТЕ НАМ ОБ ЭТОМ!')

		if timer.Exists(timerName) then return false end

		timer.Create(timerName, 1, 15, function()
			if rp.data.IsLoaded(pl) then timer.Remove(timerName) return true end
			SendMsg("Неудачная попытка загрузить данные игрока " .. pl:NameID() .. " (" .. (5 - timer.RepsLeft(timerName)) .. "/5)", "alert")
			rp.data.LoadPlayer(pl)
		end)

		return false
	end
	return true
end

//hook('InitPostEntity', 'data.InitPostEntity', function()
//	db:Query('UPDATE player_data SET Money=' .. rp.cfg.StartMoney .. ' WHERE Money <' ..  rp.cfg.StartMoney/2)
//end)

local math = math

function PLAYER:AddMoney(amount, description)
	if not rp.data.IsLoaded(self) then return end

	local total = self:GetMoney() + math.floor(amount)
	rp.data.SetMoney(self, total)
	self:SetNetVar('Money', total)

	if not description then return end

	db:Query('INSERT INTO rp_moneylog(Name, SteamID64, Money, Description) VALUES(?, ?, ?, ?);', self:Name(), self:SteamID64(), amount, description)
end

function OfflineAddMoney(amount, steamid, description)
	local steamid64 = util.SteamIDTo64(steamid) != "0" and util.SteamIDTo64(steamid) or steamid
	local ply = rp.FindPlayer(steamid)
	if IsValid(ply) and rp.data.IsLoaded(ply) then ply:AddMoney(amount, description) return end

	db:Query('SELECT Money FROM player_data WHERE SteamID=' .. steamid64 .. ';', function(_data)
	  local data = _data[1] or {}
	  if (#_data <= 0) then ErrorNoHalt( "OfflineAddMoney: В базе данных отсутствует игрок с идентификатором" .. steamid64) return end

	  local mCount = data['Money']
	  local total = mCount + math.floor(amount)
	  db:Query('UPDATE player_data SET Money=? WHERE SteamID=' ..steamid64 .. ';', total)
	  print('выдал '..steamid..' $'..amount)
	end)
end

function PLAYER:TakeMoney(amount, description)
	self:AddMoney(-math.abs(amount), description)
end

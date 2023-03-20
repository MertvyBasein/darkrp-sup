
function PLAYER:AddHealth(amt)
	self:SetHealth(self:Health() + amt)
end

function PLAYER:GiveAmmos(amount, show)
	for k, v in ipairs(rp.ammoTypes) do
		self:GiveAmmo(amount, v.ammoType, show)
	end
end

---------------------------------------------------------
-- RP names
---------------------------------------------------------

rp.AddCommand('rpname', function(ply, args)
	local canChange = false
  	--for k, v in ipairs(ents.FindInSphere(ply:GetPos(), 200)) do
  	--    if IsValid(v) and (v:GetClass() == 'npc_changename') then
  	--        canChange = true
  	--        break
  	--    end
  	--end
  	--if !canChange then
  	--	rp.Notify(ply, NOTIFY_ERROR, 'Для смены ника обратитесь к НПС.')
		--return ""
  	--end
  	if ply.NextNameChange and ply.NextNameChange > CurTime() then
		rp.Notify(ply, NOTIFY_ERROR, 'Пожалуйста, подождите # секунд чтобы сделать это.', math.ceil(ply.NextNameChange - CurTime()))
		return ""
	end

	local len = string.len(args)

	if len > 40 then
		rp.Notify(ply, NOTIFY_ERROR, 'RP имя должно быть короче # символов.', 40)
		return ""
	elseif len < 3 then
		rp.Notify(ply, NOTIFY_ERROR, 'RP имя должно быть длиннее # символов.', 2)
		return ""
	end

	if !ply:CanAfford(rp.cfg.ChangeNamePrice) then
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете себе это позволить.')
		return ""
	end
	if args == "" || !args then
		rp.Notify(ply, NOTIFY_ERROR, 'Введите имя и фамилию.')
		return ""
	end

	local spaces = 0
	for i=1,#args do
		if args[i] == ' ' then
			spaces = spaces + 1
		end
	end
	
	if spaces < 1 then
		rp.Notify(ply, NOTIFY_ERROR, 'В вашем нике должно присутствовать имя и фамилия!')
		return ""
	elseif spaces > 1 then
		rp.Notify(ply, NOTIFY_ERROR, 'В вашем нике не должно присутствовать отчество (3 слово).')
		return ""
	end

	rp.data.GetNameCount(args, function(taken)
		if taken then rp.Notify(ply, NOTIFY_ERROR, 'Никнейм уже занят.') return "" end

		rp.NotifyAll(NOTIFY_GENERIC, '# сменил ролевое имя на #', ply:SteamName(), args)
		rp.data.SetName(ply, args)
		ply:AddMoney(-rp.cfg.ChangeNamePrice)

		ply.NextNameChange = CurTime() + 60
	end)
	
	return ""
end)
:AddAlias 'name'
:AddAlias 'nick'
:AddParam(cmd.STRING)

hook("PlayerDataLoaded", "RP:RestorePlayerData", function(pl, data)
	pl:NewData()
end)

hook("PlayerDisconnect","RP:RemoveENT", function(pl)
	for k, v in ipairs(ents.GetAll()) do
		if (v.ItemOwner == pl) and v.RemoveOnDisconnect then
			v:Remove()
		end
	end
end)

---------------------------------------------------------
-- Admin/automatic stuff
---------------------------------------------------------
function PLAYER:ChangeAllowed(t)
	if not self.bannedfrom then return true end
	if self.bannedfrom[t] == 1 then return false else return true end
end

function PLAYER:TeamUnBan(Team)
	if not IsValid(self) then return end
	if not self.bannedfrom then self.bannedfrom = {} end
	self.bannedfrom[Team] = 0
end

function PLAYER:TeamBan(t, time)
	if not self.bannedfrom then self.bannedfrom = {} end
	t = t or self:Team()
	self.bannedfrom[t] = 1

	if time == 0 then return end
	timer.Simple(time or 180, function()
		if not IsValid(self) then return end
		self:TeamUnBan(t)
	end)
end

function PLAYER:NewData()
	if not IsValid(self) then return end

	self:SetTeam(1)

	self:GetTable().LastVoteCop = CurTime() - 61
end


---------------------------------------------------------
-- Teams/jobs
---------------------------------------------------------
function PLAYER:ChangeTeam(t, force)
	local prevTeam = self:Team()

 -- 	if self:isRestrained() or self:isEscorting() then
	-- 	self:Notify(NOTIFY_ERROR, 'Вы не можете сменить работу находясь в наручниках!')
	-- 	return false
	-- end
	if rp.teams[self:Team()].mayor and nw.GetGlobal('lockdown') then
		nw.SetGlobal("lockdown", false)
    	nw.SetGlobal("lockdown_kd", CurTime() + LockDownConfig.Next)
    	rp.Notify(self, NOTIFY_GENERIC, "Сбор у ратуши был завершён!")
    	SendMessageAll(Color(200, 0, 0), "Сбор у ратуши был завершён!")
    end
	if self:IsArrested() and not force then
		self:Notify(NOTIFY_ERROR, 'Вы не можете сменить работу в течении #!', 'arrested')
		return false
	end

	if self:IsFrozen() and not force then
		self:Notify(NOTIFY_ERROR, 'Вы не можете сменить работу в течении #!', 'frozen')
		return false
	end

	if (not self:Alive()) and not force then
		self:Notify(NOTIFY_ERROR, 'Вы не можете сменить работу в течении #!', 'dead')
		return false
	end

	if self.FSpectating then
		self:Notify(NOTIFY_ERROR, 'Вы не можете сменить работу в режиме наблюдения!')
		return false
	end

	if self:IsWanted() and not force and self:Team() != 1 and not table.HasValue( {TEAM_CITIZEN, TEAM_VORTRAB, TEAM_BICH2, TEAM_SEAL1,TEAM_SEAL2,TEAM_SEAL3,TEAM_SEAL4,TEAM_SEAL5, TEAM_GUNSHOP, TEAM_GANG2, TEAM_GANG3, TEAM_GANG3POVAR, TEAM_GANG4, TEAM_GANG5, TEAM_GFAST, TEAM_GFAST2, TEAM_GANG6, TEAM_ARMY2, TEAM_BANG1, TEAM_BANG2, TEAM_BANG3, TEAM_GSPY, TEAM_BARNEY, TEAM_KLEINER, TEAM_ALYX, TEAM_FREEMAN, TEAM_BAND1, TEAM_BAND2, TEAM_BAND3, TEAM_BAND4, TEAM_ZOMBIE1, TEAM_ZOMBIE2, TEAM_ZOMBIE3, TEAM_ZOMBIE4}, t ) then
		self:Notify(NOTIFY_ERROR, 'Вы не можете сменить работу в течении #!', 'wanted')
		return false
	end

	if t ~= rp.DefaultTeam and not self:ChangeAllowed(t) and not force then
		rp.Notify(self, NOTIFY_ERROR, 'В настоящее время эта работа недоступна для вас.')
		return false
	end

	if self.LastJob and rp.cfg.ChangeJobTime - (CurTime() - self.LastJob) >= 0 and not force then
		self:Notify(NOTIFY_ERROR, 'Нужно подождать # секунд чтобы сделать это!', math.ceil(rp.cfg.ChangeJobTime - (CurTime() - self.LastJob)))
		return false
	end

	if self:IsDisguised() then self:UnDisguise() end

	if self:GetNWString("infection") != '' and not force then
		rp.Notify(self, 1, 'Вы не можете сменить профессию пока болеете!')
		return false
	end

	if self.IsBeingDemoted then
		self:TeamBan()
		self.IsBeingDemoted = false
		self:ChangeTeam(1, true)
		GAMEMODE.vote.DestroyVotesWithEnt(self)
		rp.Notify(self, NOTIFY_ERROR, 'Вы попытались избежать увольнения. Хорошая попытка, но вы всё равно были уволены.')

		return false
	end

	if prevTeam == t then
		rp.Notify(self, NOTIFY_ERROR, 'Вы уже на этой работе!')
		return false
	end

	local TEAM = rp.teams[t]
	if not TEAM then return false end

	-- local data = {}

	-- for k, v in pairs(player.GetAll()) do
	-- 	if v:IsCMD() then table.insert(data, v) end
	-- end
	-- if TEAM.cp == true and t != TEAM_MAYOR then
	-- 	if not GetGlobalBool('needgo') and not self:isCP() and #data > 0 and not self:GetNWBool('CPAccess') and not force then
	-- 		rp.Notify(self, NOTIFY_ERROR, 'Набор в Гражданскую Оборону закрыт!')
	-- 		return false
	-- 	end
	-- end

	-- if self:GetNWBool('CPAccess') then self:SetNWBool('CPAccess', false) end

	if TEAM.vip and (not self:isVIP()) then
		rp.Notify(self, NOTIFY_ERROR, 'Вам нужен статус VIP.')
		return
	end
	if TEAM.premium and (not self:isPREMIUM()) then
		rp.Notify(self, NOTIFY_ERROR, 'Вам нужен статус Премиум.')
		return
	end
	//if TEAM.playtime and (self:GetPlayTime()*60 < TEAM.playtime) and (not self:isVIP()) then
	//	rp.Notify(self, NOTIFY_ERROR, 'Вам нужно # часов игрового времени или статус VIP для этой работы!', TEAM.playtime/3600)
	//	return false
	//end

	if TEAM.CannotOwnDoors then
		if (self:GetVar('doorCount') or 0) <= 0 then

		else
			local count = self:GetVar('doorCount')
			local amt = (count * rp.cfg.DoorCostMin)
			self:DoorUnOwnAll()
			self:AddMoney(amt)
			rp.Notify(self, NOTIFY_SUCCESS, 'Вы продали # дверей за #.', count, rp.FormatMoney(amt))
		end
	end

    if type(TEAM.NeedChange) == "number" and self:Team() ~= TEAM.NeedChange then
        rp.Notify(self, 1, 'Вы должны быть ' .. team.GetName(TEAM.NeedChange) .. ' чтобы стать ' .. TEAM.name)
        return ""
    end

	if TEAM.customCheck and not TEAM.customCheck(self) then
		rp.Notify(self, NOTIFY_ERROR, 'Вам не доступно')
		return false
	end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  --[[if TEAM.type and not self:NearJobNPC(TEAM.type, TEAM.team) and not force then
  	  rp.Notify(self, NOTIFY_ERROR, 'Поговорите с NPC для трудоустройства.')
      return false
  end]]
	if TEAM.time ~= nil && tonumber(self:GetPlayTime()) < TEAM.time/60 && !(self:IsVIP() || self:isPREMIUM()) then
		rp.Notify(self, NOTIFY_ERROR, 'Вам необходимо отыграть ' .. util.TimeToStr(TEAM.time-self:GetPlayTime() * 60) .. ' для разблокировки этой профессии')
		return false
	end

  -- if self:Team() == TEAM_WLM and not table.HasValue({TEAM_CITIZEN, TEAM_LOA1, TEAM_LOA2, TEAM_VORTRAB}, t) then
  -- 	rp.Notify(self, NOTIFY_ERROR, 'Вы не можете трудоустроится без професии Гражданина или Лоялиста.')
  -- 	return false
  -- end
  -- if self:Team() == TEAM_WLM and table.HasValue({TEAM_CITIZEN, TEAM_LOA1, TEAM_LOA2, TEAM_VORTRAB}, t) then
  -- 	local sphere = ents.FindInBox(Vector(-4293, 8418, 4331), Vector(-5663, 10352, 3773))
  -- 	if not table.HasValue(sphere, self) then rp.Notify(self, NOTIFY_ERROR, 'А ты у нас самый умный? Пройди сначала вокзал (=') return false end
  -- end

  --[[if (TEAM.unlockCost and not table.HasValue(self:GetNetVar('JobUnlocks'), TEAM.command) and not self:IsBot() and not TEAM.dontunlockCostvip and self:IsVIP()) then
  	return false
  end]]
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	if not self:GetVar("Priv"..TEAM.command) and not force then
		local max = TEAM.max
		if max ~= 0 and -- No limit
		(max >= 1 and team.NumPlayers(t) >= max or -- absolute maximum
		max < 1 and (team.NumPlayers(t) + 1) / #player.GetAll() > max) then -- fractional limit (in percentages)
			rp.Notify(self, NOTIFY_ERROR, 'Лимит исчерпан.')
			return false
		end
	end

	if TEAM.PlayerChangeTeam then
		local val = TEAM.PlayerChangeTeam(self, prevTeam, t)
		if val ~= nil then
			return val
		end
	end

	local hookValue = hook.Call("playerCanChangeTeam", nil, self, t, force)
	if hookValue == false then return false end

	local isMayor = rp.teams[prevTeam] and rp.teams[prevTeam].mayor

	rp.NotifyAll(NOTIFY_GENERIC, '# стал #.', self:Name(), TEAM.name)

	if self:GetNetVar("HasGunlicense") then
		self:SetNetVar("HasGunlicense", nil)
	end

	self.PlayerModel = nil

	self.LastJob = CurTime() + 60

	for k, v in ipairs(ents.GetAll()) do
		if (v.ItemOwner == self) and v.RemoveOnJobChange then
			if not v.IsPrinter then v:Remove() end
			if v.IsPrinter and TEAM.cp then v:Remove() end
		end
	end

	if (self:GetNetVar('job') ~= nil) then
		self:SetNetVar('job', nil)
	end

	self:SetVar('lastpayday', CurTime() + 300, false, false)
	self:SetTeam(t)
	hook.Call("OnPlayerChangedTeam", GAMEMODE, self, prevTeam, t)
	if self:InVehicle() then self:ExitVehicle() end

	self:StripWeapons()
	self:Spawn()

	return true
end

hook('PlayerThink', function(pl)
	if (pl:GetVar('lastpayday') ~= nil) and (pl:GetVar('lastpayday') < CurTime()) then
		pl:PayDay()
	end
end)

---------------------------------------------------------
-- Money
---------------------------------------------------------

local bonusPayDay = {}

bonusPayDay['vip'] = 1.2
bonusPayDay['premium'] = 1.5
bonusPayDay['gold'] = 1.6
bonusPayDay['uberadmin'] = 2
bonusPayDay['superadmin'] = 2

function PLAYER:PayDay()
	if not IsValid(self) then return end
	if not self:IsArrested() then
		local amount = self:GetSalary() or 0

		local bonusPay = bonusPayDay[self:GetUserGroup()]
		if bonusPay then amount = amount * bonusPay end

		local allowance = 0

	 	--[[for k, v in pairs(rp.CPoints) do
	 		if rp.CPoints[k].owner == rp.teams[self:Team()].targetname then
	 			allowance = allowance + rp.CPoints[k].rewards
	 		end
	 	end]]

		//if player.GetCount() < 5 then
		//	rp.Notify(self, NOTIFY_ERROR, 'Вы не получили бонус за территории из-за маленького количества игроков (<5)!')
		//	allowance = 0
		//end

		/*if self:IsAFK() then
			rp.Notify(self, NOTIFY_ERROR, 'Вы не получили бонус за территории из-за того что вы в афк!')
			allowance = 0
		end*/

		-- local amount_event = hook.Call("PlayerPayDay", GAMEMODE, self, amount)
		-- if amount_event then amount = amount_event end

		if amount == 0 then
			rp.Notify(self, NOTIFY_ERROR, 'Вы безработный и вы не получаете зарплату!')
		else
			--local tax = (self:GetVar('doorCount') or 0) * self:Wealth(rp.cfg.DoorTaxMin, rp.cfg.DoorTaxMax)

			--if self:CanAfford(tax) then
					if !rp.teams[self:Team()].targetname then
						self:AddMoney((amount + allowance))
					else
						self:AddMoney((amount + allowance))
					end

					local text = 'Зарплата! Вы получили #'
					if allowance > 0 then text = text .. ' (+# за территории)' end
					--if tax > 0 then text = text .. ' - # налог' end

					rp.Notify(self, NOTIFY_SUCCESS, text, rp.FormatMoney(amount), rp.FormatMoney(allowance), rp.FormatMoney(0))


					if bonusPay and self:GetSalary() > 0 then
						local money = self:GetSalary() * (bonusPay - 1)
						rp.Notify(self, NOTIFY_SUCCESS, 'Вы получили бонус # за привилегию!', rp.FormatMoney(money))
						self:AddMoney(money)
					end


			--else
			--	rp.Notify(self, NOTIFY_ERROR, 'Вы не смогли уплатить налоги! Ваша собственность отобрана у вас!')
			--	self:DoorUnOwnAll()
			--end
		end
	else
		rp.Notify(self, NOTIFY_ERROR, 'Зарплата пропущена! (Вы под арестом)')
	end
	self:SetVar('lastpayday', CurTime() + 300, false, false)
end

---------------------------------------------------------
-- Items
---------------------------------------------------------
function PLAYER:DropDRPWeapon(weapon)
	local ammo = self:GetAmmoCount(weapon:GetPrimaryAmmoType())
	self:DropWeapon(weapon) -- Drop it so the model isn't the viewmodel

	local ent = ents.Create("spawned_weapon")
	local model = (weapon:GetModel() == "models/weapons/v_physcannon.mdl" and "models/weapons/w_physics.mdl") or weapon:GetModel()

	ent.ShareGravgun = true
	ent:SetPos(self:GetShootPos() + self:GetAimVector() * 30)
	ent:SetModel(model)
	ent:SetSkin(weapon:GetSkin())
	ent.weaponclass = weapon:GetClass()
	ent.nodupe = true
	ent.clip1 = weapon:Clip1()
	ent.clip2 = weapon:Clip2()
	ent.ammoadd = ammo // Раньше это значение было в RemoveAmmo

	local wepTable = weapons.Get(weapon:GetClass())

  if wepTable then
		self:RemoveAmmo(wepTable.Primary.DefaultClip - wepTable.Primary.ClipSize, weapon:GetPrimaryAmmoType())
	end

	ent:Spawn()

	weapon:Remove()
end

timer.Create('PlayerThink', 5, 0, function()
	local pls = player.GetAll()
	for i = 1, #pls do
		if IsValid(pls[i]) then
			hook.Call('PlayerThink', GAMEMODE, pls[i])
		end
	end
end)

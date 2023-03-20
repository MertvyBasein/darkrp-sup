rp.ArrestedPlayers = rp.ArrestedPlayers or {}

function PLAYER:IsWarranted()
	return (self.HasWarrant == true)
end
-----------------------------------------------------------------------------
-- Warrant
-----------------------------------------------------------------------------
function PLAYER:Warrant(actor, reason)
	self.HasWarrant = true
	timer.Simple(rp.cfg.WarrantTime, function()
		if IsValid(self) then
			self:UnWarrant()
		end
	end)
	rp.FlashNotifyAll('Новости', '# приказывает обыскать #.\nПричина: #', actor, self, reason, (IsValid(actor) and actor or 'Авто-ордер'))
	hook.Call('playerWarranted', GAMEMODE, self, actor, reason)
end

function PLAYER:UnWarrant(actor)
	rp.NotifyAll(1, 'Ордер на обыск # истёк.', self)
	self.HasWarrant = nil
	hook.Call('playerUnWarranted', GAMEMODE, self, actor)
end
-----------------------------------------------------------------------------
-- Wanted
-----------------------------------------------------------------------------
function PLAYER:Wanted(actor, reason)
	self.CanEscape = nil
	if self:IsCP() then return end
	self:SetNetVar('IsWanted', true)
	self:SetNetVar('WantedReason', reason)
	timer.Create('Wanted' .. self:SteamID64(), rp.cfg.WantedTime, 1, function()
		if IsValid(self) then
			self:UnWanted()
		end
	end)
	local police = ''
	if actor == nil then
		police = 'Камера '
	else
		police = actor
	end
	-- for k,v in pairs(player.GetAll()) do
	-- 	if v:IsCP() then
	-- 		v:svtext(Color(90,150,230),'[Розыск] ',police,Color(255,255,255),'объявил в розыск ',self,Color(255,255,255),Color(255,255,255),'по причине: ',Color(255,30,30),reason)
	-- 	end
	-- end

	rp.FlashNotifyAll('Новости', '# разыскивается!\nПричина: #\nПриказ выдал: #', self, reason, (IsValid(actor) and actor or 'Авто-розыск'))
	hook.Call('playerWanted', GAMEMODE, self, actor, reason)
end

function PLAYER:UnWanted(actor)
	self:SetNetVar('IsWanted', nil)
	self:SetNetVar('WantedReason', nil)
	timer.Destroy('Wanted' .. self:SteamID64())
	hook.Call('playerUnWanted', GAMEMODE, self, actor)
end
-----------------------------------------------------------------------------
-- Arrest
-----------------------------------------------------------------------------
local jails = rp.cfg.JailPos[game.GetMap()]
function PLAYER:Arrest(actor, reason, time)
	local time = time or 900 //rp.cfg.ArrestTime
	timer.Create('Arrested' .. self:SteamID64(), time, 1, function()
		if IsValid(self) then
			self:UnArrest()
		end
	end)

	self:SetNetVar('ArrestedInfo', {Release = CurTime() + time})
	if self:IsWanted() then self:UnWanted() end

	rp.ArrestedPlayers[self:SteamID64()] = true

	self:StripWeapons()
	self:SetHunger(100)
	self:SetHealth(100)
	self:SetArmor(0)

	rp.FlashNotifyAll('Новости', '# был арестован.', self)
	for k,v in pairs(player.GetAll()) do

		v:svtext(Color(90,150,230),'[Аресты] ',actor,Color(255,255,255),'посадил ',self,Color(255,255,255),'на ',Color(255,255,255),tostring(time),Color(255,255,255),' по причине: ',Color(255,30,30),reason)

	end
	-- if IsValid(actor) then
	-- 	actor:AddQuest('arrest', 1)
	-- end
	hook.Call('PlayerArrested', GAMEMODE, self, actor)

	self:Spawn(util.FindEmptyPos(jails[math.random(#jails)]))
	self.CanEscape = true
end

function PLAYER:UnArrest(actor)
	self:SetNetVar('ArrestedInfo', nil)
	timer.Destroy('Arrested' .. self:SteamID64())
	rp.ArrestedPlayers[self:SteamID64()] = nil
	timer.Simple(0.3, function() -- fucks up otherwise
		local _, pos = GAMEMODE:PlayerSelectSpawn(self)
		self:Spawn(pos)
		self:SetHealth(100)
		hook.Call('PlayerLoadout', GAMEMODE, self)
		--rp.FlashNotifyAll('Новости', '# был выпущен из тюрьмы.', self)
		hook.Call('playerUnArrested', GAMEMODE, self, actor)
	end)
end
-----------------------------------------------------------------------------
-- Commands
-----------------------------------------------------------------------------
-- rp.AddCommand('911', function(pl, message)
-- 	chat.Send('911', pl, message)
-- end)
-- :AddParam(cmd.STRING)

rp.AddCommand('want', function(pl, targ, text)
	if not pl:IsCP() and not pl:IsMayor() then return end

	if targ:IsWanted() then
		rp.Notify(pl, NOTIFY_ERROR, '# yже разыскивается полицией!', targ)
	else
		targ:Wanted(pl, text)
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.STRING)

rp.AddCommand('unwant', function(pl, targ, text)
	if not pl:IsCP() and not pl:IsMayor() then return end
	if not targ:IsWanted() then
		rp.Notify(pl, NOTIFY_ERROR, '# не разыскивается полицией!', targ)
	else
		targ:UnWanted(pl)
	end
end)
:AddParam(cmd.PLAYER_ENTITY)

rp.AddCommand('warrant', function(pl, targ, text)
	if not pl:IsCP() and not pl:IsMayor() then return end

	if not pl:IsChief() and not nw.GetGlobal('lockdown') then
		return rp.Notify(pl,0,'Вы не можете получить ордер на обыск без комендантского часа.')
	end

	if targ:IsWarranted() then
		rp.Notify(pl, NOTIFY_ERROR, '# yже есть ордер!', targ)
	else
	    if not rp.teams[pl:Team()] or not rp.teams[pl:Team()].mayor then -- No need to search through all the teams if the player is a mayor
	        local mayors = {}

			for k,v in pairs(rp.teams) do
	            if v.mayor then
	                table.Add(mayors, team.GetPlayers(k))
	            end
	        end

			if #mayors > 0 then
				local mayor = table.Random(mayors)
				local question = pl:Name() .. ' запрашивает\nордер на обыск ' .. targ:Name() .. '\nПричина: ' .. text
				GAMEMODE.ques:Create(question, targ:EntIndex() .. 'warrant', mayors[1], 40, function(ret)
					if not tobool(ret) then
						rp.Notify(pl, NOTIFY_ERROR, 'Мэр ' .. mayor:Name() .. ' отклонил ваш запрос на ордер.')
						return
					end
					if IsValid(targ) then
						targ:Warrant(pl, text)
					end
				end, pl, targ, text)
				rp.Notify(pl, NOTIFY_SUCCESS, 'Запрос на ордер отправлен мэру ' .. mayor:Name())
				return ''
			end
		end
		if IsValid(targ) then
			targ:Warrant(pl, text)
		end

		return ''
	end
end)
:AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.STRING)

rp.AddCommand('unwarrant', function(pl, targ, text)
	if not pl:IsCP() and not pl:IsMayor() then return end
	if not targ:IsWarranted() then
		rp.Notify(pl, NOTIFY_ERROR, 'На # нет ордера!', targ)
	else
		targ:UnWarrant(pl)
	end
end)
:AddParam(cmd.PLAYER_ENTITY)

local bounds = rp.cfg.Jails[game.GetMap()]
-- if bounds then
-- 	hook('PlayerThink', function(pl)
-- 		if IsValid(pl) and pl:IsArrested() and pl.CanEscape and (not pl:InBox(bounds[1], bounds[2])) then
-- 			rp.ArrestedPlayers[pl:SteamID64()] = nil
-- 			pl:SetNetVar('ArrestedInfo', nil)
-- 			timer.Destroy('Arrested' .. pl:SteamID64())

-- 			pl:Wanted(nil, 'Побег из тюрьмы')

-- 			hook.Call('PlayerLoadout', GAMEMODE, pl)
-- 		end
-- 	end)
-- end

-- hook('PlayerEntityCreated', function(pl)
-- 	if rp.ArrestedPlayers[pl:SteamID64()] then
-- 		pl:Arrest(nil) -- Disconnecting to avoid arrest
-- 	end
-- end)

hook('PlayerDeath', function(pl, killer, dmginfo)
	--if (!killer:IsPlayer()) then return end
--
	--if pl:IsWanted() and killer:IsCP() and (pl ~= killer) and (killer ~= game.GetWorld()) then
	--	pl:UnWanted()
	--end

	if !IsValid(pl) then return end

	if pl:IsWanted() then pl:UnWanted() end
end)

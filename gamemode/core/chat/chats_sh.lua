if (CLIENT) then
	cvar.Register 'oocchat_enable'
		:SetDefault(true, true)
		:AddMetadata('Catagory', 'Чат')
		:AddMetadata('Menu', 'Отображать OOC чат')
end

AGroups = {
	"helper",
	"dmoderator",
	"dadmin",
	"moderator",
	"mladmin",
	"admin",
	"stadmin",
	"headadmin",
	"eventer",
	"spectator",
	"curator",
	"superadmin",
}
ARanks = {
   ['helper'] = 'Хэлпер',
   ['moderator'] = 'Модератор',
   ['mladmin'] = 'Мл.администратор',
   ['dmoderator'] = 'Д.Модератор',
   ['admin'] = 'Администратор',
   ['dadmin'] = 'Д.Администратор',
   ['stadmin'] = 'Ст.Администратор',
   ['headadmin'] = 'Гл.Админ',
   ['eventer'] = 'Инвентолог',
   ['spectator'] = 'Следящий',
   ['curator'] = 'Куратор',
   ['superadmin'] = 'Игрок'
}

local function writemsg(pl, v)
    net.WritePlayer(pl)
    net.WriteString(v)
end

local function readmsg(c, p)
    c = c or ''
    p = p or ''
    local pl = net.ReadPlayer()
    local msg = net.ReadString()

    if IsValid(pl) then
        return /*c, p,*/ Color(255,40,40), '[' .. (ARanks[pl:GetUserGroup()] or pl:GetUserGroup()) .. '] ', pl:GetJobColor(), pl:Name(), rp.col.White, ': ' .. msg
    else
        return /*c, p,*/ Color(255,40,40), '[Unknown] ', rp.col.Gray, 'Unknown: ', rp.col.White, msg
    end
end

function encodeURI(str)
	if (str) then
		str = string.gsub (str, "\n", "\r\n")
		str = string.gsub (str, "([^%w ])",
			function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string.gsub (str, " ", "+")
	end
	return str
end

local function tts(txt, pl)
	pl.NextPlayTTS = pl.NextPlayTTS or 0
	if pl.NextPlayTTS and CurTime() > pl.NextPlayTTS then
		sound.PlayURL('https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=' .. encodeURI(txt) ..'&tl=ru','2d',function(station)
			if IsValid(station) then
				station:SetVolume(.5)
				station:Play()
				pl.NextPlayTTS = CurTime() + station:GetLength()
			end
		end)
	end
end

chat.Register 'AdminChat'
:Write(writemsg)
:Read(function()

    return readmsg(Color(60, 150, 250), '[A-ЧАТ] ')

end)
:Filter(function(pl)
     	return table.Filter(player.GetAll(), function(v)
        	return table.HasValue(AGroups, v:GetUserGroup())
    end)
end)

local function writemsg(pl, v)
	net.WritePlayer(pl)
	net.WriteString(v)
end

local function readmsg(c, p)
	c = c or ''
	p = p or ''
	local pl = net.ReadPlayer()
	local msg = net.ReadString()
	if IsValid(pl) then

		return /*c, p,*/ pl:GetJobColor(), pl:Name(), rp.col.White, ': ' .. msg

	else
		return /*c, p,*/ rp.col.Gray, 'Unknown: ', rp.col.White, msg
	end
end

local function readmsgother(c, p)
	c = c or ''
	p = p or ''
	local pl = net.ReadPlayer()
	local msg = net.ReadString()
	if IsValid(pl) then
		return /*c, p,*/ pl:GetJobColor(), pl:Name(), rp.col.White, ': ' .. msg
	else
		return /*c, p,*/ rp.col.Gray, 'Unknown: ', rp.col.White, msg
	end
end

local col = rp.col

chat.Register 'Local'
	:Write(writemsg)
	:Read(readmsgother)
	:SetLocal(250)

chat.Register 'Whisper'
	:Write(writemsg)
	:Read(function()
		return readmsg(col.Red, '[Шепот] ')
	end)
	:SetLocal(90)

chat.Register 'Yell'
	:Write(writemsg)
	:Read(function()
		return readmsg(col.Red, '[Крик] ')
	end)
	:SetLocal(600)

chat.Register 'LOOC'
	:Write(writemsg)
	:Read(function()
		return readmsg(col.Red, '[LOOC] ')
	end)
	:SetLocal(250)

chat.Register 'DO'
	:Write(writemsg)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			return pl:GetJobColor(), net.ReadString() .. ' - ' .. pl:Name()
		end
	end)
	:SetLocal(250)


chat.Register 'Me'
	:Write(writemsg)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			return pl:GetJobColor(), pl:Name() .. ' - ' .. net.ReadString()
		end
	end)
	:SetLocal(250)

chat.Register 'Prize'
	:Write(writemsg)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			return Color(90,150,230),' [Новогодний подарок] ',pl:GetJobColor(), pl:Name(), Color(255,255,255),' выбил с новогоднего подарка ',Color(255,0,0),'['..net.ReadString()..']'
		end
	end)
	:SetLocal(250)

chat.Register 'Ad'
	:Write(writemsg)
	:Read(function()
		return readmsg(col.Red, '[Объявление] ')
	end)

chat.Register 'Radio'
	:Write(function(channel, pl, message)
		net.WriteUInt(channel, 8)
		writemsg(pl, message)
	end)
	:Read(function()
		return readmsg(col.Grey, '[Канал ' .. net.ReadUInt(8) .. '] ')
	end)
	:Filter(function(channel, pl, message)
		return table.Filter(player.GetAll(), function(v)
			return v.RadioChannel and (v.RadioChannel == pl.RadioChannel)
		end)
	end)

chat.Register 'Broadcast'
	:Write(writemsg)
	:Read(function()
		return readmsg(col.Red, '[Громкоговоритель] ')
	end)

chat.Register 'Group'
	:Write(writemsg)
	:Read(function()
		local pl = net.ReadPlayer()
		local msg = net.ReadString()
		local teams = pl:GetNetVar('MetaHub.DisguiseTeam') != nil and RPExtraTeams[pl:GetNetVar('MetaHub.DisguiseTeam')].cp or false
		if IsValid(pl) then
			/*if pl:isCP() then
				return col.Blue, '[ГО - '.. (pl:GetNetVar('job') or 'Сотрудник ГО')..'] ', pl:GetJobColor(), pl:Name(), ': ', rp.col.White, msg
			elseif pl:IsRebels() and pl:IsDisguised() then
				return col.Pink, '[РАЦИЯ] ', team.GetColor(pl:Team()), team.GetName(pl:Team()), ' ', Color(255,94,64), pl:Name(), ': ', rp.col.White, msg
			else
				return col.Pink, '[РАЦИЯ] ', pl:GetJobColor(), pl:GetJobName(), ' ', Color(255,94,64), pl:Name(), ': ', rp.col.White, msg
			end*/
			return pl:GetJobColor(), pl:GetJobName(), ' ', Color(255,94,64), pl:Name(), ': ', rp.col.White, msg
		end
	end)
	:Filter(function(pl)
		return table.Filter(player.GetAll(), function(v)
			return (rp.groupChats[v:Team()] and rp.groupChats[v:Team()][pl:Team()]) or (v == pl)
		end)
	end)

chat.Register 'OOC'
	:Write(writemsg)
	:Read(function()
		if cvar.GetValue('oocchat_enable') then
			return readmsg(col.OOC, '[OOC] ')
		end
	end)

chat.Register 'PM'
	:Write(function(pl, targ, msg)
		net.WritePlayer(pl)
		net.WritePlayer(targ)
		net.WriteString(msg)
	end)
	:Read(function()
		local pl, targ = net.ReadPlayer(), net.ReadPlayer()

		local isTarget = (targ == LocalPlayer())
		local user = (isTarget and pl or targ)

		return ui.col.Yellow, '[PM '.. (isTarget and 'ОТ' or 'К') .. '] ', user:GetJobColor(), user:Name(), ': ', ui.col.White, net.ReadString()
	end)
	:Filter(function(pl, targ, msg)
		return {targ, pl}
	end)

chat.Register 'Roll'
	:Write(function(pl, num)
		net.WritePlayer(pl)
		net.WriteUInt(num, 8)
	end)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			return pl:GetJobColor(), pl:Name() .. ' ', rp.col.White, 'кинул и выпало ', col.Pink, tostring(net.ReadUInt(8)), col.White, ' из 100.'
		end
	end)
	:SetLocal(250)

chat.Register 'Dice'
	:Write(function(pl, num1, num2)
		net.WritePlayer(pl)
		net.WriteUInt(num1, 8)
		net.WriteUInt(num2, 8)
	end)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			return pl:GetJobColor(), pl:Name() .. ' ', rp.col.White, 'кинул и выпало ', col.Pink, tostring(net.ReadUInt(8)), col.White, ' и ', col.Pink, tostring(net.ReadUInt(8)), '.'
		end
	end)
	:SetLocal(250)

chat.Register 'Cards'
	:Write(function(pl, card)
		net.WritePlayer(pl)
		net.WriteString(card)
	end)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			return pl:GetJobColor(), pl:Name() .. ' ', rp.col.White, 'вытянул ', col.Pink, net.ReadString(), col.White, '.'
		end
	end)
	:SetLocal(250)

chat.Register 'Coin'
	:Write(function(pl, card)
		net.WritePlayer(pl)
		net.WriteString(card)
	end)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			return pl:GetJobColor(), pl:Name() .. ' ', rp.col.White, 'подбросил и выпало ', col.Pink, net.ReadString(), col.White, '.'
		end
	end)
	:SetLocal(250)

chat.Register 'CIDShow'
	:Write(function(pl, chance)
		net.WritePlayer(pl)
		net.WriteUInt(chance, 8)
	end)
	:Read(function()
		local pl = net.ReadPlayer()
		local chance = net.ReadUInt(8)
		local wanted, reason = pl:IsWanted(), (pl:GetWantedReason() or '#ERROR')



		if IsValid(pl) and pl:Team() == TEAM_BARNEY then
			return pl:GetJobColor(),pl:Name(),Color(255,255,255),': предъявил CID карту ID #'..pl:GetID(),Color(105, 145, 255),' [C17.MPF.PCU.01 #' .. pl:GetNWString('FakeNomer') .. ']',ui.col.Red, wanted and ' В розыске! (' .. reason ..')'
		end

		if IsValid(pl) and not pl:IsDisguised() then
			return pl:GetJobColor(),pl:Name(),Color(255,255,255),': предъявил CID карту ID #'..pl:GetID(),pl:GetJobColor(),' [',pl:GetJobName()..']', ui.col.Red, wanted and ' В розыске! (' .. reason ..')'
		end

		if IsValid(pl) and pl:IsDisguised() and chance < 20 then
    		return pl:GetJobColor(),pl:Name(),Color(255,255,255),': предъявил CID карту ID #',ui.col.Red,'ERROR', ui.col.Red, wanted and ' В розыске! (' .. reason ..')'
		elseif IsValid(pl) and pl:IsDisguised() and RPExtraTeams[pl:GetNetVar('MetaHub.DisguiseTeam')].cp then
    		return pl:GetJobColor(),pl:Name(),Color(255,255,255),': предъявил CID карту ID #'..pl:GetID(),pl:GetJobColor(),' [',pl:GetJobName()..' #'.. pl:GetNWString('FakeNomer') ..']', ui.col.Red, wanted and ' В розыске! (' .. reason ..')'
		else
    		return pl:GetJobColor(),pl:Name(),Color(255,255,255),': предъявил CID карту ID #'..pl:GetID(),pl:GetJobColor(),' [',pl:GetJobName()..']', ui.col.Red, wanted and ' В розыске! (' .. reason ..')'
		end
	end)
	:SetLocal(250)

chat.Register 'TryCommand'
	:Write(function(pl, chance, msg)
		net.WritePlayer(pl)
		net.WriteUInt(chance, 8)
		net.WriteString(msg)
	end)
	:Read(function()
		local pl = net.ReadPlayer()
		local chance = net.ReadUInt(8)
		local message = net.ReadString()
		local wanted = pl:IsWanted()

		if IsValid(pl) then
			return pl:GetJobColor(), pl:Name() .. ' ', rp.col.White, message .. ' ', chance > 50 and Color(50,255,50) or Color(255,50,50), chance > 50 and 'удачно' or 'неудачно'
		end
	end)
	:SetLocal(250)

	chat.Register 'Desiases'
		:Write(function(pl, text)
			net.WritePlayer(pl)
			net.WriteString(text)
		end)
		:Read(function()
			local pl = net.ReadPlayer()
			local text = net.ReadString()

				return Color(60,150,250), pl:Name() .. ' ' .. text
		end)
		:SetLocal(250)

local LotteryPeople = {}
local LotteryON = false
local LotteryAmount = 0
local CanLottery = CurTime()
local lottoStarter

local function EnterLottery(answer, ent, initiator, target, TimeIsUp)
	if tobool(answer) and not table.HasValue(LotteryPeople, target) then
		if not target:CanAfford(LotteryAmount) then
			rp.Notify(target, NOTIFY_ERROR, 'Вы не можете позволить себе это!')
			return
		end
		table.insert(LotteryPeople, target)
		target:AddMoney(-LotteryAmount, 'Принял участие в лотерее')
		rp.Notify(target, NOTIFY_SUCCESS, 'Вы участвуете в лотерее за #.', rp.FormatMoney(LotteryAmount))
	elseif answer ~= nil and not table.HasValue(LotteryPeople, target) then
		rp.Notify(target, NOTIFY_GENERIC, 'Вы не участвует в лотерее.')
	end

	if TimeIsUp then
		LotteryON = false
		CanLottery = CurTime() + 300
		if table.Count(LotteryPeople) == 0 then
			rp.NotifyAll(NOTIFY_GENERIC, 'Никто не участвовал в лотерее.')
			return
		end

		if (#LotteryPeople > 1) then
			local chosen 	= LotteryPeople[math.random(1, #LotteryPeople)]
			local amount 	= (#LotteryPeople * LotteryAmount)
			local tax 		= amount * 0.05

			chosen:AddMoney(amount - tax, 'Выигрыш в лотерее')
			if IsValid(lottoStarter) then
				lottoStarter:AddMoney(tax, 'Комиссия от лотереи')
				rp.Notify(lottoStarter, NOTIFY_SUCCESS, 'Вы получили с лотереи #.', rp.FormatMoney( tax))
			end
			rp.NotifyAll(NOTIFY_SUCCESS, '# выиграл # в лотерее!', chosen, rp.FormatMoney(amount - tax))
		else
			local ret = LotteryPeople[1]
			if IsValid(ret) then
				ret:AddMoney(LotteryAmount, 'Возвращение денег (лотерея)')
				rp.Notify(ret, NOTIFY_ERROR, 'Никто не участвовал в лотерее, поэтому ваши деньги были возвращены.')
			end
			if IsValid(lottoStarter) then
				rp.Notify(lottoStarter, NOTIFY_ERROR, 'Вы получили с лотереи $0, потому что никто не участвовал в лотерее.')
			end
		end
	end
end

local function DoLottery(ply, amount)
	if not (ply:Team() == TEAM_SS6) then
		rp.Notify(ply, NOTIFY_ERROR, 'Неправильная работа для этого!')
		return
	end

	if #player.GetAll() <= 2 or LotteryON then
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете начать лотерею прямо сейчас.')
		return
	end

	if CanLottery > CurTime() then
		rp.Notify(ply, NOTIFY_ERROR, 'Пожалуйста, подождите # секунд, чтобы начать новую лотерею.', math.Round(CanLottery - CurTime()))
		return
	end

	amount = tonumber(amount)
	if not amount then
		rp.Notify(ply, NOTIFY_GENERIC, 'Пожалуйста, установ цену на вход ($#-$#).', rp.cfg.MinLotto, rp.cfg.MaxLotto)
		return
	end

	lottoStarter = ply
	LotteryAmount = math.Clamp(math.floor(amount), rp.cfg.MinLotto, rp.cfg.MaxLotto)

	hook.Call('lotteryStarted', GAMEMODE, ply)

	rp.NotifyAll(NOTIFY_GENERIC, 'Лотерея началась!')

	LotteryON = true
	LotteryPeople = {}
	table.foreach(player.GetAll(), function(k, v)
		if v ~= ply then
			GAMEMODE.ques:Create('Проводится лотерея!\nУчаствовать за ' .. rp.FormatMoney(LotteryAmount) .. '?', 'lottery'..tostring(k), v, 30, EnterLottery, ply, v)
		end
	end)
	timer.Create('Lottery', 30, 1, function() EnterLottery(nil, nil, nil, nil, true) end)
	return
end
rp.AddCommand('lottery', DoLottery)
:AddParam(cmd.STRING)


util.AddNetworkString("StartСurfew")
util.AddNetworkString("StopСurfew")
util.AddNetworkString("OpenLockDownMenu")

local function formatTime(time)
    local tmp = tonumber(time)

    local s = tmp % 60
    tmp = math.floor(tmp / 60)
    local m = tmp % 60
    tmp = math.floor(tmp / 60)
    local h = tmp % 24
    tmp = math.floor(tmp / 24)
    local d = tmp % 7

    if d > 1 then
        return string.format( "i д. %02i ч. %02i мин.", d, h, m )
    elseif d < 1 and h > 1 then
        return string.format( "%02i ч. %02i мин.", h, m )
    elseif h < 1 and m > 1 then
        return string.format( "%02i мин.", m )
    elseif m < 1 and s > 1 then
        return string.format( "%02i сек.", s )
    end
end

LockDownConfig = {}

LockDownConfig.Time = 1200 -- Время, через которое КЧ автоматически закончится
LockDownConfig.Next = 600  -- КД между КЧ

LockDownConfig[1] = {
    reason = "Военное положение", -- Причина КЧ
    help = "Жителям запрещено находится на улице" -- Рекомендации игрокам
}
LockDownConfig[2] = {
    reason = "Геноцид евреев/криминальных лиц",
    help = "Жителям запрещено находится на улице"
}
LockDownConfig[3] = {
    reason = "Вывоз евреев/криминала и т.д в конц.лагерь",
    help = "Жителям разрешено находится на улице"
}
LockDownConfig[4] = {
    reason = "Проверка и обыск домов",
    help = "Жителям разрешено находится на улице"
}

-- RadiantLockDown_Value = lockdown
-- RadiantLockDown_TimeLeft = lockdown_left
-- RadiantLockDown_Reason = lockdown_reason
-- RadiantLockDown_KD = lockdown_kd

net.Receive("StartСurfew", function(len, ply)

	if not (ply:Team() == TEAM_SS6) then
		return rp.Notify(ply, NOTIFY_ERROR, 'Неправильная работа для этого!')
	end

	local num = net.ReadInt(3)

	if (nw.GetGlobal("lockdown_kd") or 0) > CurTime() then
		local nicetime = formatTime(math.Round((nw.GetGlobal("lockdown_kd") or 0) - CurTime()))
	    ply:SendMessage(Color(0, 0, 0), "[ВВ2] ", Color(255, 255, 255), "Недавно уже был комендантский час! Повторите попытку через " .. nicetime)

	    return
	end

    nw.SetGlobal("lockdown", true)
    nw.SetGlobal("lockdown_left", CurTime() + 1200)
    -- nw.SetGlobal("lockdown_reason", LockDownConfig[num]["reason"])

    timer.Create("RemoveCurfew", LockDownConfig.Time, 1, function()
        nw.SetGlobal("lockdown", false)
    end)

    --for _, v in pairs(player.GetAll()) do
        --v:ConCommand("play npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav\n")
    --end
    BroadcastLua([[sound.PlayURL('https://gmod-modern.ru/sirena.mp3', '', function() end)]])

    rp.Notify(ply, NOTIFY_GENERIC, "Фюрер объявил комендантский час!")
    SendMessageAll(Color(200, 0, 0), "Фюрер объявил комендантский час!")
    -- SendMessageAll(Color(200, 0, 0), LockDownConfig[num]["help"])
end)





function StopThisFuckingLockDown(len, ply)
	if !nw.GetGlobal("lockdown") then return end

	if not (ply:Team() == TEAM_SS6) then
		return rp.Notify(ply, NOTIFY_ERROR, 'Неправильная работа для этого!')
	end

    timer.Remove("RemoveCurfew")
    nw.SetGlobal("lockdown", false)
    nw.SetGlobal("lockdown_kd", CurTime() + LockDownConfig.Next)
    rp.Notify(ply, NOTIFY_GENERIC, "Фюрер отменил комендантский час")
    SendMessageAll(Color(200, 0, 0), "Фюрер отменил комендантский час")
end

net.Receive("StopСurfew", StopThisFuckingLockDown)


function rp.lockdown_menu(pl)
	if (pl ~= nil) and not (ply:Team() == TEAM_SS6) then
		return rp.Notify(pl, NOTIFY_ERROR, 'Неправильная работа для этого!')
	end

        net.Start("OpenLockDownMenu")
        net.Send(pl)

	return
end

rp.AddCommand('lockdown', rp.lockdown_menu)
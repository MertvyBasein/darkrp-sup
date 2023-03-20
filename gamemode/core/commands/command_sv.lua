---------------------------------------------------------
-- Shipments
---------------------------------------------------------
local function DropWeapon(pl)
	local ent = pl:GetActiveWeapon()
	if not IsValid(ent) then
		return
	end

	if ent.permaWep then
		pl:svtext(Color(255,94,64),'[Оружие] ',Color(255,255,255),"Вы не можете выкинуть донат оружие.")
		return
	end

	if ent.copweapon then
		rp.Notify(pl,NOTIFY_ERROR,'Нельзя выбросить оружие профессии')
		return
	end

	local canDrop = hook.Call('CanDropWeapon', GAMEMODE, pl, ent)

	if not canDrop then
		rp.Notify(pl, NOTIFY_ERROR, 'Нельзя выбросить это оружие!')
		return
	end

	if ent:GetClass() == 'mp_stunstick' then
		if pl:IsCP() then rp.Notify(pl,1,'Нельзя выкидывать оружие профессии!') return end
		local ent = ents.Create('item_stun')
		ent:SetPos(pl:GetShootPos() + pl:GetAimVector() * 30)
		ent:Spawn()
		pl:StripWeapon('mp_stunstick')
		return
	end

	if ent:GetClass() == 'handcuffs_rebels' then
		local ent = ents.Create('item_cuffs')
		ent:SetPos(pl:GetShootPos() + pl:GetAimVector() * 30)
		ent:Spawn()
		pl:StripWeapon('handcuffs_rebels')
		return
	end

	timer.Simple(1, function()
		if IsValid(pl) and IsValid(ent) and ent:GetModel() then
			pl:DropDRPWeapon(ent)
		end
	end)
end
rp.AddCommand('drop', DropWeapon)

local function SetPrice(pl, args)
	local amount = tonumber(args)

	local tr = util.TraceLine({
		start = pl:EyePos(),
		endpos = pl:EyePos() + pl:GetAimVector() * 85,
		filter = pl
	})

	if not IsValid(tr.Entity) then rp.Notify(pl, NOTIFY_ERROR, 'Вы должны смотреть на предмет!') return '' end

	if IsValid(tr.Entity) and tr.Entity.MaxPrice and (tr.Entity.ItemOwner == pl) then
		tr.Entity:Setprice(math.Clamp(amount, tr.Entity.MinPrice, tr.Entity.MaxPrice))
	else
		rp.Notify(pl, NOTIFY_ERROR, 'Вы не можете установить цену на этот предмет!')
	end

	return ''
end
rp.AddCommand('setprice', SetPrice)
:AddParam(cmd.NUMBER)
:AddAlias 'price'

local function BuyPistol(ply, args)
	if ply:IsArrested() then
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не допущены к покупке этого предмета.')
		return ''
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	local class = nil
	local model = nil

	local shipment
	local price = 0
	for k,v in pairs(rp.shipments) do
		if v.seperate and string.lower(v.name) == string.lower(args) and GAMEMODE:CustomObjFitsMap(v) then
			shipment = v
			class = v.entity
			model = v.model
			price = v.pricesep
			local canbuy = false

			if tblEnt.allowed[ply:Team()] then
				canbuy = true
			end

			if v.customCheck and not v.customCheck(ply) then
				rp.Notify(ply, NOTIFY_ERROR, 'Вы не допущены к покупке этого предмета.')
				return ''
			end

			if not canbuy then
				rp.Notify(ply, NOTIFY_ERROR, 'Вы не допущены к покупке этого предмета.')
				return ''
			end
		end
	end

	if not class then
		rp.Notify(ply, NOTIFY_ERROR, 'Эта вещь недоступна.')
		return ''
	end

	if not ply:CanAfford(price) then
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете позволить себе это!')
		return ''
	end

	local weapon = ents.Create('spawned_weapon')
	weapon:SetModel(model)
	weapon.weaponclass = class
	weapon.ShareGravgun = true
	weapon:SetPos(tr.HitPos)
	weapon.ammoadd = weapons.Get(class) and weapons.Get(class).Primary.DefaultClip
	weapon.nodupe = true
	weapon:Spawn()

	if shipment.onBought then
		shipment.onBought(ply, shipment, weapon)
	end
	hook.Call('playerBoughtPistol', nil, ply, shipment, weapon)

	if IsValid( weapon ) then
		ply:AddMoney(-price, 'Покупка ' .. args)
		rp.Notify(ply, NOTIFY_SUCCESS, 'Вы купили # за #.', args, rp.FormatMoney(price))
	else
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не в состоянии купить эту вещь.')
	end

	return ''
end
rp.AddCommand('buy', BuyPistol)
:AddParam(cmd.STRING)

local function BuyShipment(ply, args)
	if ply.LastShipmentSpawn and ply.LastShipmentSpawn > (CurTime() - 1) then
		rp.Notify(ply, NOTIFY_ERROR, 'Подождите прежде чем спавнить товар.')
		return ''
	end
	ply.LastShipmentSpawn = CurTime()

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if ply:IsArrested() then
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не допущены к покупке этого предмета.')
		return ''
	end

	local found = false
	local foundKey
	for k,v in pairs(rp.shipments) do
		if string.lower(args) == string.lower(v.name) and not v.noship and GAMEMODE:CustomObjFitsMap(v) then
			found = v
			foundKey = k
			local canbecome = false
			for a,b in pairs(v.allowed) do
				if ply:Team() == a then
					canbecome = true
				end
			end

			if v.customCheck and not v.customCheck(ply) then
				rp.Notify(ply, NOTIFY_ERROR, 'Вы не допущены к покупке этого предмета.')
				return ''
			end

			if not canbecome then
				rp.Notify(ply, NOTIFY_ERROR, 'Неправильная работа для этого!')
				return ''
			end
		end
	end

	if not found then
		rp.Notify(ply, NOTIFY_ERROR, 'Эта вещь недоступна.')
		return ''
	end

	local cost = found.price

	if not ply:CanAfford(cost) then
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете позволить себе это!')
		return ''
	end

	local crate = ents.Create(found.shipmentClass or 'spawned_shipment')

	-- crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
	-- crate:Spawn()

	crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
    crate:Spawn()
    crate:Activate()
    crate:SetCollisionGroup(0)
    crate:SetCustomCollisionCheck(true)
    crate:CollisionRulesChanged()
	
	if found.shipmodel then
		crate:SetModel(found.shipmodel)
	end
	crate:SetContents(foundKey, found.amount)

	if rp.shipments[foundKey].onBought then
		rp.shipments[foundKey].onBought(ply, rp.shipments[foundKey], weapon)
	end
	hook.Call('playerBoughtShipment', nil, ply, rp.shipments[foundKey], weapon)

	if IsValid( crate ) then
		ply:AddMoney(-cost, 'Покупка ящик с ' .. args)
		rp.Notify(ply, NOTIFY_SUCCESS, 'Вы купили # за #.', args, rp.FormatMoney(cost))

		hook.Call('PlayerBoughtItem', GAMEMODE, ply, rp.shipments[foundKey].name .. ' Shipment', cost, ply:GetMoney())
	else
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не в состоянии купить эту вещь.')
	end

	return ''
end
rp.AddCommand('buyshipment', BuyShipment)
:AddParam(cmd.STRING)

local function BuyAmmo(ply, args)
	if ply:IsArrested() then
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не допущены к покупке этого предмета.')
		return ''
	end

	local found
	for k,v in pairs(rp.ammoTypes) do
		if v.ammoType == args then
			found = v
			break
		end
	end

	if not found or (found.customCheck and not found.customCheck(ply)) then
		rp.Notify(ply, NOTIFY_ERROR, 'Эта вещь недоступна.')
		return ''
	end

	if not ply:CanAfford(found.price) then
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете позволить себе это!')
		return ''
	end

	rp.Notify(ply, NOTIFY_SUCCESS, 'Вы купили # за #.', found.name, rp.FormatMoney(found.price))
	ply:AddMoney(-found.price, 'Покупка ' .. found.name)

	ply:GiveAmmo(found.amountGiven, found.ammoType)

	return ''
end
rp.AddCommand('buyammo', BuyAmmo)
:AddParam(cmd.STRING)

---------------------------------------------------------
-- Jobs
---------------------------------------------------------
local function ChangeJob(ply, args)
 	if ply:IsArrested() then
 		rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете изменить работу прямо сейчас.')
 		return ''
 	end

 	if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
 		rp.Notify(ply, NOTIFY_ERROR, 'Нужно подождать # секунд чтобы сделать это!', math.ceil(10 - (CurTime() - ply.LastJob)))
 		return ''
 	end
 	ply.LastJob = CurTime()

 	if not ply:Alive() then
 		rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете изменить работу прямо сейчас.')
 		return ''
 	end

 	local len = string.len(args)

 	if len < 3 then
 		rp.Notify(ply, NOTIFY_ERROR, 'Название работы должно быть больше чем # буква.', 2)
 		return ''
 	end

 	if len > 25 then
 		rp.Notify(ply, NOTIFY_ERROR, 'Название работы должно быть меньше чем  # букв.', 26)
 		return ''
 	end

 	local canChangeJob, message, replace = hook.Call('canChangeJob', nil, ply, args)
 	if canChangeJob == false then
 		rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете изменить работу прямо сейчас.')
 		return ''
 	end

 	local job = replace or args
 	rp.NotifyAll(NOTIFY_GENERIC, '# стал #.', ply, job)

 	ply:SetNetVar('job', job)
 	return ''
end
rp.AddCommand('job', ChangeJob)
:AddParam(cmd.STRING)
local function FinishDemote(vote, choice)
	local target = vote.target

	target.IsBeingDemoted = nil
	if choice == 1 then
		target:TeamBan()
		if target:Alive() then
			target:ChangeTeam(rp.DefaultTeam, true)
		else
			target.demotedWhileDead = true
		end

		rp.NotifyAll(NOTIFY_GENERIC, '# был уволен.', target)
	else
		rp.NotifyAll(NOTIFY_GENERIC, '# не был уволен.', target)
	end
end
local function Demote(ply, args)
	local tableargs = string.Explode(' ', args)
	if #tableargs == 1 then
		rp.Notify(ply, NOTIFY_ERROR, 'Вам нужно указать причину.')
		return ''
	end
	local reason = ''
	for i = 2, #tableargs, 1 do
		reason = reason .. ' ' .. tableargs[i]
	end
	reason = string.sub(reason, 2)
	if string.len(reason) > 99 then
		rp.Notify(ply, NOTIFY_ERROR, 'Ваша причина увольнения должна быть длиннее # символов.', 100)
		return ''
	end
	local p = player.Find(tableargs[1])
	if p == ply then
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете уволить себя.')
		return ''
	end

	local canDemote, message = hook.Call('CanDemote', GAMEMODE, ply, p, reason)
	if canDemote == false then
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете голосовать.')
		return ''
	end

	if p then
		if ply:GetTable().LastVoteCop and CurTime() - ply:GetTable().LastVoteCop < 80 then
			rp.Notify(ply, NOTIFY_ERROR, 'Нужно подождать # секунд чтобы сделать это!',  math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)))
			return ''
		end
		if not rp.teams[p:Team()] or rp.teams[p:Team()].candemote == false then
			rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете голосовать.')
		else
			-- rp.Chat(CHAT_NONE, p, colors.Yellow, '[Увольнение] ', ply, 'Я желаю уволить тебя с работы. Причина: ' .. reason)

			rp.NotifyAll(NOTIFY_GENERIC, '# запустил голосование об увольнении #.', ply, p)
			p.IsBeingDemoted = true

			hook.Call('playerDemotePlayer', GAMEMODE, ply, p, reason)

			GAMEMODE.vote:create(p:Nick() .. ':\nПричина увольнения:\n'..reason, 'demote', p, 20, FinishDemote,
			{
				[p] = true,
				[ply] = true
			}, function(vote)
				if not IsValid(vote.target) then return end
				vote.target.IsBeingDemoted = nil
			end)
			ply:GetTable().LastVoteCop = CurTime()
		end
		return ''
	else
		rp.Notify(ply, NOTIFY_ERROR, 'Невозможно найти #.', tostring(args))
		return ''
	end
end
rp.AddCommand('demote', Demote)
-- :AddParam(cmd.PLAYER_ENTITY)
:AddParam(cmd.STRING)

---------------------------------------------------------
-- Talking
---------------------------------------------------------

local function PM(pl, targ, message)
	if targ:GetNWBool('AMask') then rp.Notify(pl,1,'Игрок не найден!') return end
	chat.Send('PM', pl, targ, message)
	targ.LastPM = pl
end
rp.AddCommand('pm', PM):AddParam(cmd.PLAYER_ENTITY):AddParam(cmd.STRING)

rp.AddCommand('re', function(pl, message)
	local targ = pl.LastPM
	if not IsValid(targ) then return NOTIFY_ERROR, 'Там никого нет чтобы ответить' end
	if targ:GetNWBool('AMask') then return end
	chat.Send('PM', pl, targ, message)
	targ.LastPM = pl
end)
:AddParam(cmd.STRING)

local function Whisper(pl, targ, message)
	chat.Send('Whisper', pl, targ, message)
	plogs.PlayerLog(pl, 'Чат', pl:NameID() .. ' сказал шепотом: ' .. string.Trim(targ), { ['Name'] 	= pl:Name(), ['SteamID']	= pl:SteamID() })
end
rp.AddCommand('whisper', Whisper):AddParam(cmd.STRING):AddAlias('w')

local function Yell(pl, targ, message)
	chat.Send('Yell', pl, targ, message)
	plogs.PlayerLog(pl, 'Чат', pl:NameID() .. ' крикнул: ' .. string.Trim(targ), { ['Name']	= pl:Name(), ['SteamID']	= pl:SteamID() })
end
rp.AddCommand('yell', Yell):AddParam(cmd.STRING):AddAlias('y')

local function Me(pl, targ, message)
	chat.Send('Me', pl, targ, message)
	plogs.PlayerLog(pl, 'Чат', pl:NameID() .. ' совершил РП-отыгровку: ' .. string.Trim(targ), { ['Name'] = pl:Name(), ['SteamID']	= pl:SteamID() })
end
rp.AddCommand('me', Me):AddParam(cmd.STRING)

local function OOC(pl, targ, message)
	chat.Send('OOC', pl, targ, message)
	plogs.PlayerLog(pl, 'Чат', pl:NameID() .. ' сказал в OOC чат: ' .. string.Trim(targ), { ['Name'] = pl:Name(), ['SteamID']	= pl:SteamID() })
end
rp.AddCommand('ooc', OOC):AddParam(cmd.STRING):AddAlias('/')

local function AdminChat(pl, targ, message)
	if not table.HasValue(AGroups,pl:GetUserGroup()) then rp.Notify(pl, 1, "У вас нету доступа к админ-чату!") return end
  chat.Send('AdminChat', pl, targ, message)
end
rp.AddCommand('AdminChat', AdminChat):AddParam(cmd.STRING):AddAlias 'a':AddAlias 'achat'

local function LOOC(pl, targ, message)
	chat.Send('LOOC', pl, targ, message)
	plogs.PlayerLog(pl, 'Чат', pl:NameID() .. ' сказал в LOOC чат: ' .. string.Trim(targ), { ['Name'] 	= pl:Name(), ['SteamID']	= pl:SteamID() })
end
rp.AddCommand('looc', LOOC):AddParam(cmd.STRING):AddAlias('l')

local function DO(pl, targ, message)
	chat.Send('DO', pl, targ, message)
	plogs.PlayerLog(pl, 'Чат', pl:NameID() .. ' сказал в DO (IT) чат: ' .. string.Trim(targ), { ['Name'] = pl:Name(), ['SteamID']	= pl:SteamID() })
end
rp.AddCommand('do', DO):AddParam(cmd.STRING):AddAlias('it')


local function TRY(pl, message)
	local chance = math.random(1, 100)
	chat.Send('TryCommand', pl, chance, message)
	plogs.PlayerLog(pl, 'Чат', pl:NameID() .. ' сказал в TRY чат: ' .. string.Trim(message), { ['Name']	= pl:Name(), ['SteamID']	= pl:SteamID() })
end
rp.AddCommand('try', TRY):AddParam(cmd.STRING)

local function PlayerAdvertise(pl, targ, message)
	local cost = rp.cfg.AdvertCost
	if not pl:CanAfford(cost) then rp.Notify(pl, NOTIFY_ERROR, 'Вы не можете позволить себе это!') return end

	pl:AddMoney(-cost)
	rp.Notify(pl, NOTIFY_SUCCESS, 'Вы купили # за #.', 'рекламу', rp.FormatMoney(cost))
	chat.Send('Ad', pl, targ, message)
	plogs.PlayerLog(pl, 'Чат', pl:NameID() .. ' сказал в Advert чат: ' .. string.Trim(targ), { ['Name']	= pl:Name(), ['SteamID']	= pl:SteamID() })
end
rp.AddCommand('advert', PlayerAdvertise):AddParam(cmd.STRING):AddAlias('ad')

local function MayorBroadcast(pl, targ, message)
	if not pl:IsMayor() then return end
	chat.Send('Broadcast', pl, targ, message)
	plogs.PlayerLog(pl, 'Чат', pl:NameID() .. ' сказал в Broadcast чат: ' .. string.Trim(targ), { ['Name']	= pl:Name(), ['SteamID']	= pl:SteamID() })
end
rp.AddCommand('broadcast', MayorBroadcast):AddParam(cmd.STRING):AddAlias('b')

local function GroupMsg(pl, targ, message)
	chat.Send('Group', pl, targ, message)
	plogs.PlayerLog(pl, 'Чат', pl:NameID() .. ' сказал в Group чат: ' .. string.Trim(targ), { ['Name']	= pl:Name(), ['SteamID']	= pl:SteamID() })
end
rp.AddCommand('group', GroupMsg):AddParam(cmd.STRING):AddAlias('g')

---------------------------------------------------------
-- Money
---------------------------------------------------------
local function GiveMoney(ply, args, text)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():DistToSqr(ply:GetPos()) < 22500 then
		local amount = math.floor(tonumber(args))

		if amount < 1 then
			rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете передать меньше чем $1.')
			return
		end

		if not ply:CanAfford(amount) then
			rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете позволить себе это!')
			return ''
		end
		/*if !ply:GetNetVar('VRP:Banking:Account') then
			rp.Notify(ply, NOTIFY_ERROR, 'У вас не оформлен лицевой счет в банке!')
			return
		end
		if !trace.Entity:GetNetVar('VRP:Banking:Account') then
			rp.Notify(ply, NOTIFY_ERROR, 'У игрока не оформлен лицевой счет в банке!')
			return
		end*/

		rp.data.PayPlayer(ply, trace.Entity, amount)

		hook.Call('PlayerGaveMoney', GAMEMODE, ply, trace.Entity, amount, ply:GetMoney(), trace.Entity:GetMoney())

		rp.Notify(trace.Entity, NOTIFY_SUCCESS, '# дал вам #.', ply, rp.FormatMoney(amount))
		rp.Notify(ply, NOTIFY_SUCCESS, 'Вы дали # #.', trace.Entity, rp.FormatMoney(amount))
	else
		rp.Notify(ply, NOTIFY_ERROR, 'Вам нужно смотреть на игрока.')
	end
	return ''
end
rp.AddCommand('give', GiveMoney)
:AddParam(cmd.NUMBER)

local function DropMoney(ply, args)
	local amount = math.floor(tonumber(args))

	if amount <= 1 then
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете бросить меньше чем $1.')
		return ''
	end

	if not ply:CanAfford(amount) then
		rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете позволить себе это!')
		return ''
	end

	ply:AddMoney(-amount, 'Выбрасывание денег')

	ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)

	hook.Call('PlayerDropRPMoney', GAMEMODE, ply, amount, ply:GetMoney())

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	rp.SpawnMoney(tr.HitPos, amount)

	return ''
end
rp.AddCommand('dropmoney', DropMoney)
:AddParam(cmd.NUMBER)
:AddAlias 'moneydrop'

local broadcastlist = {
     ["Обнаружено тяжкое несоотвествие"] = "npc/overwatch/cityvoice/f_capitalmalcompliance_spkr.wav",
     ["Ваш квартал обвиняется в недоносительстве. Штраф - 5 пищ.единиц"] = "npc/overwatch/cityvoice/f_rationunitsdeduct_3_spkr.wav",
     ["Судебное разбирательство отменено. Казнь - по усмотрению"] = "npc/overwatch/cityvoice/f_protectionresponse_5_spkr.wav",
     ["Отказ от сотрудничества - выселение в нежилое пространство"] = "npc/overwatch/cityvoice/f_trainstation_offworldrelocation_spkr.wav",
     ["Вы обвиняетесь в антиобщественной деятельности первого уровня"] = "npc/overwatch/cityvoice/f_anticivil1_5_spkr.wav",
     ["Введен код действия при беспорядках"] = "npc/overwatch/cityvoice/f_unrestprocedure1_spkr.wav",
     ["О противоправном поведении немедленно доложить силам ГО"] = "npc/overwatch/cityvoice/f_innactionisconspiracy_spkr.wav",
     ["Вниманию юнитам ГО! Приговор выносить по усмотрению"] = "npc/overwatch/cityvoice/f_protectionresponse_4_spkr.wav",
     ["Вам предъявлено обвинение в социальной угрозе, уровень 1"] = "npc/overwatch/cityvoice/f_sociolevel1_4_spkr.wav",
     ["Вам предъявлено обвинение в социальной угрозе, уровень 5"] = "npc/overwatch/cityvoice/f_ceaseevasionlevelfive_spkr.wav",
     ["Вы обвиняетесь во множественных нарушениях"] = "npc/overwatch/cityvoice/f_citizenshiprevoked_6_spkr.wav",
     ["Отряду ГО: признаки антиобщественной деятельности"] = "npc/overwatch/cityvoice/f_anticivilevidence_3_spkr.wav",
     ["Внимание! Уклонистское поведение. Неподчинение обвиняемого"] = "npc/overwatch/cityvoice/f_evasionbehavior_2_spkr.wav",
     ["Обнаружены локальные беспорядки"] = "npc/overwatch/cityvoice/f_localunrest_spkr.wav",
     ["Неопознанное лицо! Подтвердите статус в отделе ГО"] = "npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav",
     ["Вниманию наземных сил! В сообществе найден нарушитель"] = "npc/overwatch/cityvoice/f_anticitizenreport_spkr.wav",
     ["Внимание! В квартале потенциальный источник вреда обществу"] = "npc/overwatch/cityvoice/f_trainstation_inform_spkr.wav",
     ["Вниманию отряда ГО, обнаружено уклонение от надзора"] = "npc/overwatch/cityvoice/f_protectionresponse_1_spkr.wav",
     ["Сотрудничество с отрядом ГО награждается полным пищ.рационом"] = "npc/overwatch/cityvoice/f_trainstation_cooperation_spkr.wav",
     ["Производится проверка данных. Занять места для инспекции"] = "npc/overwatch/cityvoice/f_trainstation_assemble_spkr.wav",
     ["Жилому кварталу, занять места для инспекции"] = "npc/overwatch/cityvoice/f_trainstation_assumepositions_spkr.wav",
     ["Директива 2. Сдерживать вторжение извне"] = "npc/overwatch/cityvoice/fprison_containexogens.wav",
     ["Внимание! Отключены системы наблюдения и обнаружения"] = "npc/overwatch/cityvoice/fprison_detectionsystemsout.wav",
     ["Угроза вторжения! Во вторжении может участвовать Фримен"] = "npc/overwatch/cityvoice/fprison_freemanlocated.wav",
     ["Провал миссии влечет выселение в нежилое пространство"] = "npc/overwatch/cityvoice/fprison_missionfailurereminder.wav",
     ["Обнаружена аномальная, внешняя активность"] = "npc/overwatch/cityvoice/fprison_nonstandardexogen.wav",
     ["Отключены ограничители периметра, всем принять участие в сдерживании"] = "npc/overwatch/cityvoice/fprison_restrictorsdisengaged.wav",
}

local function playersendbroad(args)
	for k,v in pairs(ents.FindByClass("codes_speaker")) do
		v:EmitSound(args, 85)
	end
end

local function AllianceBroadcast(ply, args)
	//if ply:Team() != TEAM_DISK then
	//	rp.Notify(ply, 1, "Вы не можете использовать /broadcast")
	//	return ""
	//end
	print(args)
	if not broadcastlist[args] then
		rp.Notify(ply, 1, "Такой траснялции не существует!")
		return ""
	end

    if ply.cdcmd and ply.cdcmd > CurTime() then
        ply:SendCText([[Color(255,255,255), "Подождите ещё ]] .. math.Round(ply.cdcmd - CurTime()) .. [[ секунд!"]])
        return
    end

	local sound = broadcastlist[args]

	for k,v in pairs(player.GetAll()) do
		v:svtext(Color(90,150,230),'[Вещание] ',Color(255,255,255),args)
	end

	playersendbroad(sound)

	ply.cdcmd = CurTime() + 120



	return ''
end
rp.AddCommand('abroadcast', AllianceBroadcast)
:AddParam(cmd.STRING)
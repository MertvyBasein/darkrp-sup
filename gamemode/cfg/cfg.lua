rp.cfg.CustomerExtraWaitTime = 30
rp.cfg.CustomersSpawnRate = 30
rp.cfg.CustomersSpawnChance = 99 -- (1-100)
rp.cfg.normalsalary = 100

rp.accessories = rp.accessories or {}
rp.accessories_list = accessories_list or {}

rp.trash_system = rp.trash_system or {}

rp.trash_system.position = {
	{
		pos = Vector(3598, 9206, -152),
		--ang = Angle(55, 173, 0),
	},
	{

		pos = Vector(3685, 11982, -152),
		--ang = Angle(12, 93, 0),
	},
	{
		pos = Vector(6275, 13380, -152),
		--ang = Angle(42, 31, 0),
	},
	{
		pos = Vector(4869, 11685, -152),
		--ang = Angle(71, 145, 0),
	},
	{
		pos = Vector(350, 8477, -151),
		--ang = Angle(33, 138, 0),
	},
	{
		pos = Vector(316, 4946, -148),
		--ang = Angle(46, -157, 0),
	}
}
rp.cfg.f4actions = {
	{
		name = 'Выбросить деньги',
		icon = 'https://img.icons8.com/ios-glyphs/256/FFFFFF/money--v1.png',
		doclick = function(f)
			f:Remove()
			Derma_StringRequest('Выбросить пачку денег', 'Введите сумму', '', function(a)
				cmd.Run('dropmoney', tostring(a))
			end)
		end,
	},

	{
		name = 'Передать деньги',
		icon = 'https://img.icons8.com/ios-glyphs/256/FFFFFF/money--v1.png',
		doclick = function(f)
			f:Remove()
			Derma_StringRequest('Передать деньги', 'Введите сумму', '', function(a)
				cmd.Run('give', tostring(a))
			end)
		end,
	},
	{
		name = 'Сменить RP Имя',
		icon = 'https://img.icons8.com/external-kiranshastry-solid-kiranshastry/256/FFFFFF/external-id-card-interface-kiranshastry-solid-kiranshastry.png',
		doclick = function(f)
			f:Remove()
			Derma_StringRequest('Сменить RP Имя', 'Имя', '', function(a)
				cmd.Run('rpname', tostring(a))
			end)
		end,
	},
	{
		name = 'Выбросить текущее оружие',
		icon = 'https://img.icons8.com/ios-filled/256/FFFFFF/gun.png',
		doclick = function(f)
			f:Remove()
			cmd.Run('drop')
		end,
	},
	{
		name = 'Продать все двери',
		icon = 'https://img.icons8.com/ios-glyphs/256/FFFFFF/door.png',
		doclick = function(f)
			f:Remove()
			cmd.Run('sellall')
		end,
	},	
	{
		name = 'Уволить игрока',
		icon = 'https://img.icons8.com/ios-glyphs/256/FFFFFF/money--v1.png',
		doclick = function(f)
			uiplayerrequest(player.GetAll(), function(v)
				Derma_StringRequest('Причина увольнения', 'Напишите причину', '', function(a)
					if IsValid(v) then
						rp.RunCommand('demote', v:SteamID(), a)
					end
				end)
			end)
		end,
	},
	{
		name = 'Кинуть кубик',
		icon = 'https://img.icons8.com/ios-filled/256/FFFFFF/dice.png',
		doclick = function(f)
			f:Remove()
			cmd.Run('roll', 100)
		end,
	},
	--{
	--	name = 'Уволить игрока',
	--	icon = 'https://img.icons8.com/ios-glyphs/256/FFFFFF/money--v1.png',
	--	doclick = function(f)
	--		f:Remove()
	--	end,
	--},
	{
		name = 'Заказать убийство',
		icon = 'https://img.icons8.com/ios-filled/256/FFFFFF/skull.png',
		doclick = function(f)
			uiplayerrequest(player.GetAll(), function(v)
				Derma_StringRequest('Награда', 'Пишите число ниже', '', function(a)
					cmd.Run('hit', '"'..v:Name()..'"', tostring(a))
				end)
			end)
			--local m = DermaMenu()
			--for k, v in pairs(player.GetAll()) do
			--	if v == LocalPlayer() then continue end
			--	m:AddOption(v:Name(), function()
			--		Derma_StringRequest('Награда', 'Пишите число ниже', '', function(a)
			--			cmd.Run('hit', '"'..v:Name()..'"', tostring(a))
			--		end)
			--	end)
			--end
			--m:Open()
		end,
	},

	{
		name = 'Подать в розыск',
		acs  = function(p)
			return p:IsCP()	
		end,
		icon = 'https://img.icons8.com/ios-filled/256/FFFFFF/star--v1.png',
		doclick = function(f)
			uiplayerrequest(player.GetAll(), function(v)
				Derma_StringRequest('Розыск', 'Причина розыска?', '', function(a)
					if IsValid(v) then
						rp.RunCommand('want', v:SteamID(), a)
					end
				end)
			end)
		end,
	},
	{
		name = 'Снять розыск',
		acs  = function(p)
			return p:IsCP()	
		end,
		icon = 'https://img.icons8.com/ios-filled/256/FFFFFF/star--v1.png',
		doclick = function(f)
			uiplayerrequest(player.GetAll(), function(v)
				Derma_StringRequest('Розыск', 'Причина розыска?', '', function(a)
					if IsValid(v) then
						rp.RunCommand('unwant', v:SteamID(), a)
					end
				end)
			end)
		end,
	},
	{
		name = 'Управление городом',
		acs  = function(p)
			return p:IsMayor()	
		end,
		icon = 'https://img.icons8.com/material/256/FFFFFF/building-with-top-view.png',
		doclick = function(f)
			f:Remove()
			RunConsoleCommand('say', '/mmenu')
		end,
	},
	{
		name = 'Запустить лотерею',
		acs  = function(p)
			return p:IsMayor()	
		end,
		icon = 'https://img.icons8.com/material/256/FFFFFF/building-with-top-view.png',
		doclick = function(f)
			f:Remove()
			Derma_StringRequest('Напишите сумму для запуска лотереи', 'Сумма', '', function(a)
				RunConsoleCommand('say', '/lottery', a)
			end)
		end,
	},
}

rp.cfg.StartMoney 		= 10000
rp.cfg.ChangeNamePrice  = 250
rp.cfg.HitMinCost = 100
rp.cfg.HitCoolDown = 120
rp.cfg.HitMaxCost = 1000

rp.cfg.DropMoneyOnDeath = true
rp.cfg.DeathFee 		= 500

rp.cfg.AdvertCost		= 100

rp.cfg.HungerRate 		= 1200 --1800

rp.cfg.DoorTaxMin		= 10
rp.cfg.DoorTaxMax		= 500
rp.cfg.DoorCostMin		= 100
rp.cfg.DoorCostMax 		= 2000
rp.cfg.admin_job 		= TEAM_NONRP

rp.cfg.PropLimit 		= 40
rp.cfg.RagdollDelete	= 60
rp.cfg.ChangeJobTime	= 30

-- Speed
rp.cfg.WalkSpeed 		= 100
rp.cfg.RunSpeed 		= 280

-- Afk
rp.cfg.AfkDemote 		= (60*60)*1
rp.cfg.AfkPropRemove 	= (60*60)*3
rp.cfg.AfkDoorSell 		= (60*60)*3

-- Jail
rp.cfg.WantedTime		= 600
rp.cfg.WarrantTime		= 300
rp.cfg.ArrestTime	 	= 300

-- Lotto
rp.cfg.MinLotto 		= 1000
rp.cfg.MaxLotto 		= 50000

rp.cfg.DisallowDrop = {
	arrest_stick 	= true,
	door_ram 		= true,
	gmod_camera 	= true,
	gmod_tool 		= true,
	keys 			= true,
	med_kit 		= true,
	pocket 			= true,
	fl_inv          = true,
	stunstick 		= false,
	unarrest_stick 	= false,
	weapon_keypadchecker = true,
	weapon_physcannon = true,
	weapon_physgun 	= true,
	weaponchecker 	= true,
	weapon_fists 	= true
}

rp.cfg.DefaultWeapons = { 'weapon_physcannon', 'weapon_physgun', 'gmod_tool', 'keys', "buu_lantern", "surrender","weapon_fists" }

rp.cfg.TextSrceenFonts = {
	'Tahoma'
}

-- Spawn
rp.cfg.SpawnDisallow = {
	prop_physics		= true,
	ent_textscreen 		= true,
	metal_detector		= true,
	gmod_light 			= true,
	gmod_lamp 			= true,
	keypad 				= true,
	gmod_button 		= true,
	gmod_cameraprop 	= true
}

// Green-Zone
rp.cfg.Spawns = {
    rp_miamitown = {
        Vector(-6380, -1485, -633),
        Vector(-3587, 316, -332)
    },
}


rp.cfg.SpawnPos = rp.cfg.SpawnPos or {
    rp_miamitown = {
        Vector(-10949.776367, 7246.763184, -2699.968750),
        Vector(-10805.339844, 7244.833496, -2699.968750),
        Vector(-10645.417969, 7242.695313, -2699.968750),
        Vector(-10560.835938, 7345.487305, -2699.968750),
        Vector(-10559.153320, 7470.144531, -2699.968750),
        Vector(-10557.352539, 7604.716309, -2699.968750),
        Vector(-10555.832031, 7718.456055, -2699.968750),
        Vector(-10700.412109, 7720.388672, -2699.968750),
        Vector(-10846.886719, 7722.345703, -2699.968750),
        Vector(-11005.418945, 7724.463379, -2699.968750),
        Vector(-11007.859375, 7541.771484, -2699.968750),
        Vector(-11009.609375, 7410.638672, -2699.968750)
    },
}

// Позиции тюрьмы
rp.cfg.JailPos = {
	rp_berlin_ww2 = {
		Vector(4667, 6033, -318),
		Vector(4724, 6034, -318),
		Vector(4839, 6036, -317),
		Vector(4841, 5967, -317),
		Vector(4725, 5965, -318),
		Vector(4641, 5964, -318),
	}
}

// Позиции окончания тюрьмы	(авто-побег)
rp.cfg.Jails = {
	rp_berlin_ww2 = {
		
	}
}

rp.cfg.weapontablez = {
	['Легкое'] = {
		'm9k_colt1911',
		'm9k_coltpython',
		'm9k_deagle',
		'm9k_glock',
		'm9k_usp',
		'm9k_hk45',
		'm9k_m29satan',
		'm9k_m92beretta',
		'm9k_luger',
		'm9k_ragingbull',
		'm9k_scoped_taurus',
		'm9k_remington1858',
		'm9k_model3russian',
		'm9k_model500',
		'm9k_model627',
		'm9k_sig_p229r',
		-- submachines
		'm9k_honeybadger',
		'm9k_bizonp19',
		'm9k_smgp90',
		'm9k_mp5',
		'm9k_mp7',
		'm9k_ump45',
		'm9k_usc',
		'm9k_kac_pdw',
		'm9k_vector',
		'm9k_magpulpdr',
		'm9k_mp40',
		'm9k_mp5sd',
		'm9k_mp9',
		'm9k_sten',
		'm9k_tec9',
		'm9k_thompson',
		'm9k_uzi',
		-- knife
		'knife'
	},
	['Тяжелое'] = {
		'm9k_winchester73',
		'm9k_acr',
		'm9k_ak47',
		'm9k_ak74',
		'm9k_amd65',
		'm9k_val',
		'm9k_f2000',
		'm9k_famas',
		'm9k_g36',
		'm9k_m14sp',
		'm9k_m16a4_acog',
		'm9k_m4a1',
		'm9k_scar',
		'm9k_vikhr',
		'm9k_auga3',
		'm9k_tar21',
		'm9k_fal',
		'm9k_g36',
		'm9k_m416',
		'm9k_g3a3',
		'm9k_l85',
		-- shotgun
		'm9k_m3',
		'm9k_browningauto5',
		'm9k_dbarrel',
		'm9k_ithacam37',
		'm9k_mossberg590',
		'm9k_jackhammer',
		'm9k_remington870',
		'm9k_spas12',
		'm9k_striker12',
		'm9k_usas',
		'm9k_1897winchester',
		'm9k_1887winchester',
		-- sniper
		'm9k_aw50',
		'm9k_barret_m82',
		'm9k_m98b',
		'm9k_svu',
		'm9k_sl8',
		'm9k_intervention',
		'm9k_m24',
		'm9k_psg1',
		'm9k_remington7615p',
		'm9k_dragunov',
		'm9k_svt40',
		'm9k_contender',
		-- puliki
		'm9k_ares_shrike',
		'm9k_fg42',
		'm9k_minigun',
		'm9k_m1918bar',
		'm9k_m249lmg',
		'm9k_m60',
		'm9k_pkm',
		--HL2
		'weapon_crossbow',
		'weapon_shotgun',
		'weapon_rpg',
		--DONATE
		'weapon_ak47_phoen',
	},
	['all'] = {},
}

rp.cfg.default_spawns = {
        Vector(-10949.776367, 7246.763184, -2699.968750),
        Vector(-10805.339844, 7244.833496, -2699.968750),
        Vector(-10645.417969, 7242.695313, -2699.968750),
        Vector(-10560.835938, 7345.487305, -2699.968750),
        Vector(-10559.153320, 7470.144531, -2699.968750),
        Vector(-10557.352539, 7604.716309, -2699.968750),
        Vector(-10555.832031, 7718.456055, -2699.968750),
        Vector(-10700.412109, 7720.388672, -2699.968750),
        Vector(-10846.886719, 7722.345703, -2699.968750),
        Vector(-11005.418945, 7724.463379, -2699.968750),
        Vector(-11007.859375, 7541.771484, -2699.968750),
        Vector(-11009.609375, 7410.638672, -2699.968750),
}

timer.Simple(.1, function()
	rp.cfg.TeamSpawns = {
		rp_miamitown = {
			[TEAM_CITIZEN] = {
		        Vector(-10949.776367, 7246.763184, -2699.968750),
		        Vector(-10805.339844, 7244.833496, -2699.968750),
		        Vector(-10645.417969, 7242.695313, -2699.968750),
		        Vector(-10560.835938, 7345.487305, -2699.968750),
		        Vector(-10559.153320, 7470.144531, -2699.968750),
		        Vector(-10557.352539, 7604.716309, -2699.968750),
			},
	
		},
	}
end)

rp.cfg.donateshop = {
	{
		name = '5.000 РМ',
		price = 50,
		icon = 'https://media.discordapp.net/attachments/889467059707199498/1042532113347518474/Frame_24_1.png',
		cat = 'Игровая валюта',
		description = "Вы получите 5.000 РМ",
		func = function(ply)
			ply:AddMoney(5000)
		end
	},
	{
		name = '10.000 РМ',
		price = 90,
		icon = 'https://media.discordapp.net/attachments/889467059707199498/1042532113032937472/Frame_25_1.png',
		cat = 'Игровая валюта',
		description = "Вы получите 10.000 РМ",
		func = function(ply)
			ply:AddMoney(10000)
		end
	},
	{
		name = '20.000 РМ',
		price = 125,
		icon = 'https://media.discordapp.net/attachments/889467059707199498/1042532112668049418/Frame_26_1.png',
		cat = 'Игровая валюта',
		description = "Вы получите 20.000 РМ",
		func = function(ply)
			ply:AddMoney(20000)
		end
	},
	{
		name = '50.000 РМ',
		price = 210,
		icon = 'https://media.discordapp.net/attachments/889467059707199498/1042532112374440077/Frame_27_1.png',
		cat = 'Игровая валюта',
		description = "Вы получите 50.000 РМ",
		func = function(ply)
			ply:AddMoney(50000)
		end
	},

	{
		name = '100.000 РМ',
		price = 380,
		icon = 'https://media.discordapp.net/attachments/889467059707199498/1042532112047276052/Frame_28_1.png',
		cat = 'Игровая валюта',
		description = "Вы получите 100.000 РМ",
		func = function(ply)
			ply:AddMoney(100000)
		end
	},


	//{
	//	name = '1 Час',
	//	price = 25,
	//	icon = 'https://media.discordapp.net/attachments/889467059707199498/1042531637587619911/Frame_29.png',
	//	cat = 'Игровое время',
	//	description = "Вы получите 1 час",
	//	func = function(ply)
	//		rp.TimeSys.AddTime(ply, 60)
	//	end
	//},
	//{
	//	name = '5 Часов',
	//	price = 75,
	//	icon = 'https://media.discordapp.net/attachments/889467059707199498/1042531637205934131/Frame_30.png',
	//	cat = 'Игровое время',
	//	description = "Вы получите 5 часов",
	//	func = function(ply)
	//		rp.TimeSys.AddTime(ply, 300)
	//	end
	//},
	//{
	//	name = '10 Часов',
	//	price = 100,
	//	icon = 'https://media.discordapp.net/attachments/889467059707199498/1042531636719390770/Frame_31.png',
	//	cat = 'Игровое время',
	//	description = "Вы получите 10 часов",
	//	func = function(ply)
	//		rp.TimeSys.AddTime(ply, 600)
	//	end
	//},
	//{
	//	name = '20 Часов',
	//	price = 175,
	//	icon = 'https://media.discordapp.net/attachments/889467059707199498/1042531636358688828/Frame_32.png',
	//	cat = 'Игровое время',
	//	description = "Вы получите 20 часов",
	//	func = function(ply)
	//		rp.TimeSys.AddTime(ply, 1200)
	//	end
	//},
	//{
	//	name = '50 Часов',
	//	price = 235,
	//	icon = 'https://media.discordapp.net/attachments/889467059707199498/1042531635821822054/Frame_33.png',
	//	cat = 'Игровое время',
	//	description = "Вы получите 50 часов",
	//	func = function(ply)
	//		rp.TimeSys.AddTime(ply, 3000)
	//	end
	//},
	//{
	//	name = '100 Часов',
	//	price = 350,
	//	icon = 'https://media.discordapp.net/attachments/889467059707199498/1042531635821822054/Frame_33.png',
	//	cat = 'Игровое время',
	//	description = "Вы получите 100 часов",
	//	func = function(ply)
	//		rp.TimeSys.AddTime(ply, 6000)
	//	end
	//},
	//{
	//	name = '200 Часов',
	//	price = 500,
	//	icon = 'https://media.discordapp.net/attachments/889467059707199498/1042531634982957187/Frame_35.png',
	//	cat = 'Игровое время',
	//	description = "Вы получите 200 часов",
	//	func = function(ply)
	//		rp.TimeSys.AddTime(ply, 12000)
	//	end
	//}, 

-- 	{
-- 		name = 'VIP на месяц',
-- 		price = 250,
-- 		icon = 'https://media.discordapp.net/attachments/889467059707199498/1042532138861465740/Frame_11_1.png',
-- 		cat = 'Привилегии',
-- 		description = [[Вы получаете:
-- VIP привилегию
-- Увеличенный лимит пропов
-- Увеличенная ЗП
-- VIP Профессии
-- Разблокировку всех профессиий
-- Доступ к VIP профессиям
-- VIP в Discord канале]],
-- 		func = function(ply)
-- 			RunConsoleCommand("sam", "setrankid", ply:SteamID(), "vip", "30d")
-- 		end
-- 	},

		{
		name = 'VIP навсегда',
		price = 500,
		icon = 'https://media.discordapp.net/attachments/889467059707199498/1042532138500751451/Frame_12_1.png',
		cat = 'Привилегии',
		description = [[Вы получаете:
VIP привилегию
Увеличенный лимит пропов
Увеличенная ЗП
VIP Профессии
Разблокировку всех профессиий
Доступ к VIP профессиям
VIP в Discord канале]],
		func = function(ply)
			RunConsoleCommand("sam", "setrankid", ply:SteamID(), "vip", "0")
		end
	},
	//{
	//	name = 'Боевой пропуск',
	//	price = 200,
	//	icon = 'https://media.discordapp.net/attachments/909155458797936660/1060250847323369572/ticket.png',
	//	cat = 'Остальное',
	//	description = "Вы получите доступ к боевому пропуску на 1 сезон",
	//	func = function(ply)
	//		ply:SetBPPremium(true)
	//	end
	//},
--	 {
--	 	name = 'Premium на месяц',
--	 	price = 250,
--	 	icon = 'https://imgur.com/H2XMpYQ.png',
--	 	cat = 'Привилегии',
--	 	description = "Вы получите Премиум Статус\nУбирает лимит по времени и разблокирует все профессии\nПрибавкпа к зарплата 40%!",
--	 	func = function(ply)
--	 		RunConsoleCommand("sam", "setrankid", ply:SteamID(), "premium", "30d")
--	 	end
--	 },
--
--
--	 {
--	 	name = 'Premium навсегда',
--	 	price = 1000,
--	 	icon = 'https://imgur.com/H2XMpYQ.png',
--	 	cat = 'Привилегии',
--	 	description = "Вы получите Премиум Статус\nУбирает лимит по времени и разблокирует все профессии\nПрибавкпа к зарплата 40%!",
--	 	func = function(ply)
--	 		RunConsoleCommand("sam", "setrankid", ply:SteamID(), "premium", "0")
--	 	end
--	 },
	/* {
	 	name = 'Пистолет ТТ',
	 	price = 350,
	 	icon = 'https://media.discordapp.net/attachments/889467059707199498/1042531376605446204/Frame_36.png',
	 	cat = 'Оружия',
	 	description = "Вы получите Пистолет ТТ",
	 	func = function(ply)
	 		ply:GiveDonateWeapon("robotnik_waw_tok")
	 	end
	 },

	 {
	 	name = 'ППШ-41',
	 	price = 650,
	 	icon = 'https://media.discordapp.net/attachments/889467059707199498/1042531376295071754/Frame_37.png',
	 	cat = 'Оружия',
	 	description = "Вы получите ППШ-41",
	 	func = function(ply)
	 		ply:GiveDonateWeapon("robotnik_waw_ppsh")
	 	end
	 },
	 {
	 	name = 'Огнемет',
	 	price = 1000,
	 	icon = 'https://media.discordapp.net/attachments/889467059707199498/1042531375951126638/Frame_38.png',
	 	cat = 'Оружия',
	 	description = "Вы получите Огнемет",
	 	func = function(ply)
	 		ply:GiveDonateWeapon("robotnik_waw_m2")
	 	end
	 },*/
	 {
	 	name = 'Двуствольное ружьё',
	 	price = 1000,
	 	icon = 'https://media.discordapp.net/attachments/889467059707199498/1042531375288438804/Frame_40.png',
	 	cat = 'Оружия',
	 	description = "Вы получите Двуствольное ружьё",
	 	func = function(ply)
	 		ply:GiveDonateWeapon("robotnik_waw_db")
	 	end
	 },
	 {
	 	name = 'ПТРС-41',
	 	price = 1000,
	 	icon = 'https://media.discordapp.net/attachments/889467059707199498/1042531375615590430/Frame_39.png',
	 	cat = 'Оружия',
	 	description = "Вы получите ПТРС-41",
	 	func = function(ply)
	 		ply:GiveDonateWeapon("robotnik_waw_ptrs")
	 	end
	 },
	-- {
	-- 	name = 'Боевой пропуск',
	-- 	price = 200,
	-- 	icon = 'https://i.imgur.com/mMthbjk.png',
	-- 	cat = 'Остальное',
	-- 	description = "Вы получите доступ к боевому пропуску на 1 сезон",
	-- 	func = function(ply)
	-- 		ply:SetBPPremium(true)
	-- 	end
	-- },
/*
	{
		name = 'Комплект "Новичка"',
		price = 250,
		icon = 'https://media.discordapp.net/attachments/889467059707199498/1042532142988660826/Frame_8_1.png',
		cat = 'Остальное',
		description = [[Вы получаете:
- 20000 РМ
- VIP на 7 дней
- 25 донат рублей]],
		func = function(ply)
			ply:AddMoney(20000)
			--ply:SetBPPremium(true)
			RunConsoleCommand("sam", "setrankid", ply:SteamID(), "vip", "7d")
		end
	},
	{
		name = 'Комплект "Любителя"',
		price = 375,
		icon = 'https://media.discordapp.net/attachments/889467059707199498/1042532142384676874/Frame_9_1.png',
		cat = 'Остальное',
		description = [[Вы получаете:
- 35000 РМ
- VIP на 14 дней]],
		func = function(ply)
			ply:AddMoney(35000)
			--ply:SetBPPremium(true)
			RunConsoleCommand("sam", "setrankid", ply:SteamID(), "vip", "14d")
		end
	},
	{
		name = 'Комплект "Профи"',
		price = 650,
		icon = 'https://media.discordapp.net/attachments/889467059707199498/1042532139343822948/Frame_10_1.png',
		cat = 'Остальное',
		description = [[Вы получаете:
- 50000 РМ
- VIP на 30 дней]],
		func = function(ply)
			ply:AddMoney(50000)
			--ply:SetBPPremium(true)
			RunConsoleCommand("sam", "setrankid", ply:SteamID(), "vip", "30d")
		end
	},
*/
}

rp.skills = {}
rp.skills.SKILL_JAIL = {
	Name = 'Судью на мыло - Уменьшен срок в тюрьме', 
	Icon = 'sup/gui/skills/ziptie.png',
 	Description = 'Уменьшен срок в тюрьме',
 	MaxLevel = 3, 
 	Hooks = {
 		[0] = function() return rp.cfg.ArrestTime        end,
 		[1] = function() return rp.cfg.ArrestTime * 0.85 end, 
 		[2] = function() return rp.cfg.ArrestTime * 0.7  end,
 		[3] = function() return rp.cfg.ArrestTime * 0.4  end
 	}, 
 	Price = {
 		[1] = 90, 
 		[2] = 90, 
 		[3] = 90
 	}
}

rp.skills.SKILL_GIFT = {
	Name = 'Подарки - x2 Шанс выпадения рпг из подарка',
	Icon = 'sup/gui/skills/mystery.png',
	Description = 'x2 Шанс выпадения рпг из подарка',
	Hooks = {
		[0] = function() return 20 end,
		[1] = function() return 40 end,
		[2] = function() return 60 end,
		[3] = function() return 80 end,
	},
	Price = {
		90,
		90,
		90
	}
}

rp.skills.SKILL_LOCKPICK = {
	Name = 'Домушник - Экстра-скорость взлома', 
	Icon = 'sup/gui/skills/lockpick.png',
 	Description = 'Экстра-скорость взлома',
 	MaxLevel = 3, 
 	Hooks = {
 		[0] = function() return 1                  end,
 		[1] = function() return 0.8                end, 
 		[2] = function() return 0.75               end,
 		[3] = function() return 0.65               end
 	}, 
 	Price = {
 		[1] = 90, 
 		[2] = 90, 
 		[3] = 90
 	}
}

--я примерно понял как это делать но я тупой
rp.skills.SKILL_HACK = {
	Name = 'Хакер - Скорость взлома кейпада',
	Icon = 'sup/gui/skills/keypadcracking.png',
	Description = 'Скорость взлома кейпада',
	MaxLevel = 4, 
	Hooks = {
		[0] = function() return 1 end,
		[1] = function() return 0.5 end,
		[2] = function() return 0.35 end,
		[3] = function() return 0.2 end,
	},
	Price = {
	[1]	= 90,
	[2]	= 90,
	[3] = 90,
	[4] = 90
	}
}

rp.skills.SKILL_SCAVENGE = {
	Name = 'Мусорщик - Увеличевает шанс выпадения',
	Icon = 'sup/gui/skills/scavenger.png',
	Description = 'Увеличевает шанс выпадения',
	Hooks = {
		[0] = function() return 20 end,
		[1] = function() return 40 end,
		[2] = function() return 60 end,
		[3] = function() return 80 end,
	},
	Price = {
		90,
		90,
		90
	}
}

rp.skills.SKILL_HUNGER = {
	Name = 'Большой живот - В вас будет вмещатся много еды',
	Icon = 'sup/gui/skills/hunger.png',
	Description = 'В вас будет вмещатся много еды',
	Hooks = {
		[0] = function(HFM_Hunger) return  100 end,
		[1] = function(hHFM_Hunger) return 125 end,
		[2] = function(HFM_Hunger) return 150 end,
		[3] = function(HFM_Hunger) return 175 end,
		[4] = function(HFM_Hunger) return 200 end,
	},
	Price = {
		90,
		90,
		90,
		90
	}
}


rp.skills.SKILL_FALL = {
	Name = 'Лёгкие ноги - маленький урон от падения',
	Icon = 'sup/gui/skills/fall.png',
	Description = 'маленький урон от падения',
	Hooks = {
		--[0] = function(damage) return damage end,
		--[1] = function(damage) return damage * 0.9 end,
		--[2] = function(damage) return damage * 0.85 end,
		--[3] = function(damage) return damage * 0.8 end,
	},
	Price = {
    [1] = 90,
	[2] = 90,
	[3] = 90,
	}
}
rp.skills.SKILL_JUMP = {
    Name = 'Прыгун - Увеличевает высоту прыжка',
    Icon = 'sup/gui/skills/jump.png',
    Description = 'Вверх к небесам',
    MaxLevel = 3,
    Hooks = {
        [0] = function() return 1 end,
        [1] = function() return 1.1 end,
        [2] = function() return 1.15 end,
        [3] = function() return 1.2 end
    },
    Price = {
    [1] = 90,
    [2] = 90,
    [3] = 90
    }
}

rp.skills.SKILL_RUN = {
    Name = 'Бегун - Увеличевает скорость бега',
    Icon = 'sup/gui/skills/run.png',
    Description = 'Беги как Флэш',
    MaxLevel = 5,
    Hooks = {
        [0] = function(speed, max) return 1 end,
        [1] = function(speed, max) return 1.02 end,
        [2] = function(speed, max) return 1.05 end,
        [3] = function(speed, max) return 1.1 end,
    },
    Price = {
    [1] = 90,
    [2] = 90,
    [3] = 90,
    [4] = 90
    }
}

--canHavy
rp.cfg.Havygun = {"m9k_ithacam37","m9k_m1918bar","m9k_winchester73","m9k_acr","m9k_scar","m9k_m416","m9k_vikhr","m9k_auga3","m9k_tar21","m9k_amd65","m9k_ak74", "m9k_val","m9k_f2000","m9k_fal","m9k_jackhammer","m9k_remington7615p","m9k_psg1","m9k_ares_shrike","m9k_fg42","m9k_m249lmg","m9k_m3","m9k_browningauto5","m9k_spas12","m9k_m24","m9k_sl8","m9k_aw50","m9k_m60","m9k_pkm","m9k_svu","m9k_intervention","m9k_m98b","m9k_barret_m82","m9k_dragunov","m9k_svt40","m9k_1887winchester","m9k_usas","m9k_1897winchester","m9k_striker12","m9k_remington870","m9k_mossberg590","m9k_dbarrel","swb_ak47","swb_awp","swb_famas","swb_g3sg1","swb_galil","swb_m249","swb_m3super90","swb_m4a1","swb_sg550","swb_sg552","swb_aug","swb_scout","swb_xm1014","m9k_ak47","m9k_m4a1","m9k_g36","m9k_l85","m9k_m14sp","m9k_m16a4_acog","m9k_an94","m9k_g3a3","m9k_famas","swb_ak47","swb_awp","swb_famas", "swb_p90", "swb_g3sg1", "swb_galil", "swb_m249", "swb_m3super90", "swb_m4a1", "swb_sg550", "swb_sg552", "swb_aug", "swb_scout", "swb_xm1014"}
--canLite
rp.cfg.Litegun = {"m9k_honeybadger","m9k_bizonp19","m9k_smgp90","m9k_mp5","m9k_mp7","m9k_ump45","m9k_usc","m9k_kac_pdw","m9k_vector","m9k_magpulpdr","m9k_mp40","m9k_mp5sd","m9k_mp9","m9k_sten","m9k_thompson","m9k_uzi"}
--canVzri
rp.cfg.Vzri = {"weapon_c4","weapon_hegrenade"}

MsgC(Color(90, 150, 230), '[nekiyman] ', Color(255, 222, 102), 'Gamemode reloaded ' .. os.date('%H:%M:%S - %d/%m/%Y', os.time()) .. '\n')
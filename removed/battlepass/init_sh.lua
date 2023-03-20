battlepass = {}

battlepass.RewardTable = {
	{
		["free"] = {
			name = "2 Часа",
			img = "https://i.imgur.com/1P8XvU0.png",
			lvl = 2,
			action = function(ply)
				rp.TimeSys.AddTime(ply, 120)
			end,
		},
		["paid"] = {
			name = "3 Часа",
			img = "https://i.imgur.com/1P8XvU0.png",
			lvl = 2,
			action = function(ply)
				rp.TimeSys.AddTime(ply, 180)
			end,
		},
	},
	{
		["free"] = {
			name = "750$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 3,
			action = function(ply)
				ply:AddMoney(750)
			end,
		},
		["paid"] = {
			name = "50 Рублей",
			img = "https://i.imgur.com/AsEm02Q.png",
			lvl = 3,
			action = function(ply)
				ply:AddIGSFunds(50, "Награда за BP")
			end,
		},
	},
	{
		["free"] = {
			name = "250$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 4,
			action = function(ply)
				ply:AddMoney(250)
			end,
		},
		["paid"] = {
			name = "2500$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 4,
			action = function(ply)
				ply:AddMoney(2500)
			end,
		},
	},
	{
		["free"] = {
			name = "2500$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 5,
			action = function(ply)
				ply:AddMoney(2500)
			end,
		},
		["paid"] = {
			name = "VIP - 1 Неделя",
			img = "https://i.imgur.com/Eqjdr0v.png",
			lvl = 5,
			action = function(ply)
				RunConsoleCommand("sam", "setrankid", ply:SteamID(), "vip", "7d")
			end,
		},
	},
	{
		["free"] = {
			name = "50 Рублей",
			img = "https://i.imgur.com/AsEm02Q.png",
			lvl = 6,
			action = function(ply)
				ply:AddIGSFunds(50, "Награда за BP")
			end,
		},
		["paid"] = {
			name = "Сомбреро",
			mdl = "models/gmod_tower/sombrero.mdl",
			lvl = 6,
			action = function(ply)
				ply:GiveAccessory(7)
			end,
		},
	},
	{
		["free"] = {
			name = "1000$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 7,
			action = function(ply)
				ply:AddMoney(1000)
			end,
		},
		["paid"] = {
			name = "50 Рублей",
			img = "https://i.imgur.com/AsEm02Q.png",
			lvl = 7,
			action = function(ply)
				ply:AddIGSFunds(50, "Награда за BP")
			end,
		},
	},
	{
		["free"] = {
			name = "5 Часов",
			img = "https://i.imgur.com/1P8XvU0.png",
			lvl = 8,
			action = function(ply)
				rp.TimeSys.AddTime(ply, 300)
			end,
		},
		["paid"] = {
			name = "5 Часов",
			img = "https://i.imgur.com/1P8XvU0.png",
			lvl = 8,
			action = function(ply)
				rp.TimeSys.AddTime(ply, 300)
			end,
		},
	},
	{
		["free"] = {
			name = "250$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 9,
			action = function(ply)
				ply:AddMoney(250)
			end,
		},
		["paid"] = {
			name = "3500$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 9,
			action = function(ply)
				ply:AddMoney(3500)
			end,
		},
	},
	{
		["free"] = {
			name = "Рюкзак",
			mdl = "models/vex/seventysix/backpacks/backpack_01.mdl",
			lvl = 10,
			action = function(ply)
				ply:GiveAccessory(9)
			end,
		},
		["paid"] = {
			name = "VIP - 1 месяц",
			img = "https://i.imgur.com/Eqjdr0v.png",
			lvl = 10,
			action = function(ply)
				RunConsoleCommand("sam", "setrankid", ply:SteamID(), "vip", "30d")
			end,
		},
	},
	{
		["free"] = {
			name = "250$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 11,
			action = function(ply)
				ply:AddMoney(250)
			end,
		},
		["paid"] = {
			name = "3000$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 11,
			action = function(ply)
				ply:AddMoney(3000)
			end,
		},
	},
	{
		["free"] = {
			name = "50 Рублей",
			img = "https://i.imgur.com/AsEm02Q.png",
			lvl = 12,
			action = function(ply)
				ply:AddIGSFunds(50, "Награда за BP")
			end,
		},
		["paid"] = {
			name = "50 Рублей",
			img = "https://i.imgur.com/AsEm02Q.png",
			lvl = 12,
			action = function(ply)
				ply:AddIGSFunds(50, "Награда за BP")
			end,
		},
	},
	{
		["free"] = {
			name = "2500$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 13,
			action = function(ply)
				ply:AddMoney(2500)
			end,
		},
		["paid"] = {
			name = "7 Часов",
			img = "https://i.imgur.com/1P8XvU0.png",
			lvl = 13,
			action = function(ply)
				rp.TimeSys.AddTime(ply, 420)
			end,
		},
	},
	{
		["free"] = {
			name = "250$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 14,
			action = function(ply)
				ply:AddMoney(250)
			end,
		},
		["paid"] = {
			name = "3000$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 14,
			action = function(ply)
				ply:AddMoney(3000)
			end,
		},
	},
	{
		["free"] = {
			name = "VIP - 3 Дня",
			img = "https://i.imgur.com/Eqjdr0v.png",
			lvl = 15,
			action = function(ply)
				RunConsoleCommand("sam", "setrankid", ply:SteamID(), "vip", "3d")
			end,
		},
		["paid"] = {
			name = "Корона",
			mdl = "models/devinity/accessories/regular_content/01_unique/07_head/01_hat/prince_tavishs_crown_01/prince_tavishs_crown_01.mdl",
			lvl = 15,
			action = function(ply)
				ply:GiveAccessory(6)
			end,
		},
	},
	{
		["free"] = {
			name = "250$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 16,
			action = function(ply)
				ply:AddMoney(250)
			end,
		},
		["paid"] = {
			name = "50 Рублей",
			img = "https://i.imgur.com/AsEm02Q.png",
			lvl = 16,
			action = function(ply)
				ply:AddIGSFunds(50, "Награда за BP")
			end,
		},
	},
	{
		["free"] = {
			name = "250$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 17,
			action = function(ply)
				ply:AddMoney(250)
			end,
		},
		["paid"] = {
			name = "2500$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 17,
			action = function(ply)
				ply:AddMoney(2500)
			end,
		},
	},
	{
		["free"] = {
			name = "Сомбреро",
			mdl = "models/gmod_tower/sombrero.mdl",
			lvl = 18,
			action = function(ply)
				ply:GiveAccessory(7)
			end,
		},
		["paid"] = {
			name = "Цилиндр",
			mdl = "models/gmod_tower/tophat.mdl",
			lvl = 18,
			action = function(ply)
				ply:GiveAccessory(8)
			end,
		},
	},
	{
		["free"] = {
			name = "250$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 19,
			action = function(ply)
				ply:AddMoney(250)
			end,
		},
		["paid"] = {
			name = "3000$",
			mdl = "models/props/cs_assault/money.mdl",
			lvl = 19,
			action = function(ply)
				ply:AddMoney(3000)
			end,
		},
	},

	[-1] = {
		name = "500$",
		mdl = "models/props/cs_assault/money.mdl",
		lvl = 1,
		action = function(ply)
			ply:AddMoney(500)
		end,
	},

	[-2] = {
		name = "PREMIUM на Неделю",
		img = 'https://imgur.com/H2XMpYQ.png',
		mdl = 'models/error.mdl',
		lvl = 20,
		action = function(ply)
			RunConsoleCommand("sam", "setrankid", ply:SteamID(), "premium", "7d")
		end,
	},
}

local challanges = {}

local eventListen = hook.Add
function battlepass.AddChallange(tParams)
	local id, hook = #challanges + 1, tParams["Hook"]
	if (hook == nil) then return end
	challanges[id] = {
		id = id,
		name = (tParams["Name"] || id),
		event = hook,
		desc = (tParams['Desc'] or 'Без описания'),
		require = (tParams["Required"] || 10),
		xp = (tParams["XP"] || 20)
	}

	if (SERVER && hook:find("Player")) then
		local increment = (tParams["Increment"] || 1)
		eventListen(hook, "BattlePass::"..id, tParams["CustomFunc"] || function(ply)
			if (ply:IsActiveBPChallange(id) == false) then return end

			ply:AddBPChallangeProgress(id, increment)
		end)
	end
end

battlepass.AddChallange{
	Name = "Лицевой счёт",
	Hook = "PlayerBankCreate",
	Desc = "Откройте лицевой счет в банке ",
	Required = 1,
	XP = 20
}

battlepass.AddChallange{
	Name = "Вор-домушник",
	Hook = "PlayerLockpick",
	Desc = "Необходимо взломать отмычкой дверь 5 раз! ",
	Required = 5,
	XP = 20
}

battlepass.AddChallange{
	Name = "Хакер-анонимус",
	Hook = "PlayerKeypadCrack",
	Required = 5,
	Desc = "Взломайте кейпад-крякером кейпад 5 раз! ",
	XP = 20
}

battlepass.AddChallange{
	Name = "Мирная жизнь",
	Hook = "PlayerCitiz",
	Desc = "Зайдите за рабочий класс ",
	Required = 1,
	XP = 20
}

battlepass.AddChallange{
	Name = "Народный защитник",
	Hook = "PlayerPolice",
	Required = 1,
	Desc = "Зайдите за полицию ",
	XP = 20
}

battlepass.AddChallange{
	Name = "Разбой с ограблением",
	Hook = "PlayerGangs",
	Required = 1,
	Desc = "Зайдите за фракцию Криминал ",
	XP = 20
}

battlepass.AddChallange{
	Name = "Шахтерское Ремесло",
	Hook = "PlayerRuda",
	Required = 200,
	Desc = "Добудьте 200 руды ",
	XP = 20
}

-- battlepass.AddChallange{
-- 	Name = "Фермерское дело",
-- 	Hook = "PlayerEgg",
-- 	Required = 80,
-- 	Desc = "Соберите 80 яиц ",
-- 	XP = 20
-- }

-- battlepass.AddChallange{
-- 	Name = "Легальный гражданин",
-- 	Hook = "PlayerPassport",
-- 	Required = 3,
-- 	Desc = "Покажите свой паспорт ",
-- 	XP = 60
-- }

-- battlepass.AddChallange{
-- 	Name = "Поварское дело",
-- 	Hook = "PlayerCook",
-- 	Required = 10,
-- 	Desc = "Приготовьте блюда за повара ",
-- 	XP = 60
-- }

battlepass.AddChallange{
	Name = "Овощная диета",
	Hook = "PlayerFarm",
	Required = 20,
	Desc = "Соберите 20 овощей в ферме ",
	XP = 20
}

/*
battlepass.AddChallange{
	Name = "Напечатать на принтере деньги",
	Hook = "PlayerMoneyPrint",
	Required = 5000,
	XP = 35
}

battlepass.AddChallange{
	Name = "Зайти за профессию 'Наёмник'",
	Hook = "PlayerTeamHunter",
	Required = 1,
	XP = 35
}

battlepass.AddChallange{
	Name = "Выиграйте выборы Фюрера",
	Hook = "PlayerOnFurer",
	Required = 1,
	XP = 20
}
--
battlepass.AddChallange{
	Name = "Собрать 15 овощей в конц лагере",
	Hook = "PlayerFarm",
	Required = 15,
	XP = 30
}

battlepass.AddChallange{
	Name = "Начать захват территории",
	Hook = "PlayerCapt",
	Required = 1,
	XP = 30
}

battlepass.AddChallange{
	Name = "Зайти за профессию 'Партизан КА'",
	Hook = "PlayerPartizan",
	Required = 1,
	XP = 30
}
--
battlepass.AddChallange{
	Name = "Собрать 15 материалов в конц лагере",
	Hook = "PlayerMaterials",
	Required = 15,
	XP = 30
}*/

--battlepass.AddChallange{
--	Name = "Выиграть в казино 3 раза (Рулетка)",
--	Hook = "PlayerPCasino",
--	Required = 3,
--	XP = 25
--}

--battlepass.AddChallange{
--	Name = "Приготовить 20 блюд за повара",
--	Hook = "PlayerCook",
--	Required = 20,
--	XP = 40
--}

battlepass.Challanges = challanges

local PLAYER = PLAYER || FindMetaTable("Player")

function PLAYER:GetBPLevel()
	return self:GetNWInt("BPLevel", 0)
end

function PLAYER:GetBPXP()
   return self:GetNWInt("BPXP", 0)
end

function PLAYER:IsBPPremium()
   return self:GetNWBool("BPPremium", false)
end

function PLAYER:IsActiveBPChallange(iChallangeID)
	return (self:GetNetVar("BPChallanges")[iChallangeID] ~= nil)
end

function PLAYER:GetBPChallangeProgress(iChallangeID)
	return (self:GetNetVar("BPChallanges")[iChallangeID] || 0)
end

local RewardTable = battlepass.RewardTable
function PLAYER:CanClaimBPReward(iRewardID, bPaidOrFree)
	local RewardTable = RewardTable[iRewardID]
	if (RewardTable == nil || bPaidOrFree && self:GetNWBool("BPPremium") == false) then return false end
	local reward = (RewardTable[bPaidOrFree && "paid" || "free"] || RewardTable)

	return (self:GetBPLevel() >= (reward.lvl || 0))
end

function PLAYER:HasClaimBPReward(iRewardID, bPaidOrFree)
	local claimed, RewardTable = self:GetNetVar("BPClaimed")[iRewardID], RewardTable[iRewardID]
	if (RewardTable == nil || claimed == true) then return false end

	return (claimed == nil || ((RewardTable["paid"] == nil || RewardTable["free"] == nil) && claimed[iRewardID] == nil || claimed[bPaidOrFree && 1 || 0] == nil))
end
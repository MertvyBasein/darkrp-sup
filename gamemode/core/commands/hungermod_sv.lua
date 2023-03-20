local CurTime 		= CurTime
local math_abs		= math.abs
local math_clamp	= math.Clamp
local math_max 		= math.max

// Пусть побудет тут, мало-ли, когда-нибудь понадобится
//local shouldHunger = hook.Call('PlayerHasHunger', GAMEMODE, v)


timer.Create('HungerUpdate', 20, 0, function()
	for k, v in ipairs(player.GetAll()) do
		if IsValid(v) and v:Alive() then

			-- if v:IsOTA() and v:Team() ~= TEAM_BANG3 and v:Team() ~= TEAM_CREMATOR and v:Team() ~= TEAM_STALKER then
			-- 	if v:GetNetVar('OTAEnergy', 100) > 0 then
			-- 		v:SetNetVar('OTAEnergy', v:GetNetVar('OTAEnergy', 100) - 1)
			-- 	end
			-- 	local hung = v:GetNetVar('OTAEnergy', 100)
			-- 	local sTable = rp.teams[v:Team()].speed or {100, 280}

			-- 	local walk = math.Clamp(sTable[1] * (hung / 80) , 50, sTable[1])
			-- 	local run = math.Clamp(sTable[2] * (hung / 80) , 75, sTable[2])

			-- 	v:SetWalkSpeed(walk)
			-- 	v:SetRunSpeed(run)

			-- 	//print(v:NameID(), hung, walk)
			-- 	continue
			if v:GetNetVar('AdminMode') then
				v:SetNetVar('Energy', CurTime() + rp.cfg.HungerRate)
				continue
			end

			local dHunger = rp.cfg.HungerRate + CurTime()

			if v:InSpawn() then
				v:SetNetVar('Energy', (v:GetNetVar('Energy') or dHunger) + 20)
				continue
			end

			if v:GetHunger() > 0  then continue end

			v:SetHealth(v:Health() - 5)
			--v:EmitSound(Sound('vo/npc/male01/moan0' .. math.random(1, 5) .. '.wav', 65))
			rp.Notify(v,2,'Вы голодаете вам нужно покушать!')
			if (v:Health() <= 0) then v:Kill() end
		end
	end
end)

hook('PlayerSpawn', function(pl)
	if pl:GetNetVar('Energy') then
		pl:SetNetVar('Energy', CurTime() + rp.cfg.HungerRate)
	end
end)

hook('PlayerEntityCreated', function(pl)
	pl:SetNetVar('Energy', CurTime() + rp.cfg.HungerRate)
end)

function PLAYER:SetHunger(amount, noclamp)
	if noclamp then
		amount = math_max(0, (amount/100 * rp.cfg.HungerRate))
	else
		amount = math_clamp((amount/100 * rp.cfg.HungerRate), 0, rp.cfg.HungerRate)
	end
	self:SetNetVar('Energy', CurTime() + amount)
end

function PLAYER:AddHunger(amount)
	self:SetHunger(self:GetHunger() + amount)
end

function PLAYER:TakeHunger(amount)
	self:AddHunger(-math_abs(amount))
end

local function BuyFood(pl, args)
	if args == '' then return '' end
	if not rp.Foods[args] then return '' end

	if pl:GetCount('Food') >= 15 then
		pl:Notify(NOTIFY_ERROR, 'Вы достигли лимита еды!')
		return
	end

	local trace = {}
	trace.start = pl:EyePos()
	trace.endpos = trace.start + pl:GetAimVector() * 85
	trace.filter = pl

	local tr = util.TraceLine(trace)

	if pl:Team() != TEAM_COOK and team.NumPlayers(TEAM_COOK) > 0 then
		pl:Notify(NOTIFY_ERROR, 'Есть повар. Вы не можете это сделать!')
		return ''
	end

	if not rp.Foods[args] then return end

	local cost = rp.Foods[args].price
	if pl:CanAfford(cost) then
		pl:AddMoney(-cost, 'Покупка ' .. args)
	else
		pl:Notify(NOTIFY_ERROR, 'Вы не можете позволить себе это!')
		return ''
	end

	rp.Notify(pl, NOTIFY_SUCCESS, 'Вы купили # за #.', args, rp.FormatMoney(cost))

	local SpawnedFood = ents.Create('spawned_food')
	SpawnedFood:SetPos(tr.HitPos)
	SpawnedFood:SetModel(rp.Foods[args].model)
	SpawnedFood.FoodEnergy = rp.Foods[args].energy
	SpawnedFood.ItemOwner = pl
	SpawnedFood:Spawn()

	pl:_AddCount('Food', SpawnedFood)
	return ''
end
rp.AddCommand('buyfood', BuyFood)
:AddParam(cmd.STRING)

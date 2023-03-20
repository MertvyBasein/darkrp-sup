local blockTypes = {"Physgun1", "Spawning1", "Toolgun1"}

local checkModel = function(model) return model ~= nil and (CLIENT or util.IsValidModel(model)) end
local requiredTeamItems = {"color", "model", "weapons", "command", "max"}
local validShipment = {model = checkModel, "entity", "price", "amount", "seperate", "allowed"}
local validVehicle = {"name", model = checkModel, "price"}
local validEntity = {"ent", model = checkModel, "price", "max", "cmd", "name"}
local function checkValid(tbl, requiredItems)
	for k, v in pairs(requiredItems) do
		local isFunction = type(v) == "function"

		if (isFunction and not v(tbl[k])) or (not isFunction and tbl[v] == nil) then
			return isFunction and k or v
		end
	end
end

rp.teams = {}
function rp.addTeam(Name, CustomTeam)
	CustomTeam.name = Name

	local corrupt = checkValid(CustomTeam, requiredTeamItems)
	if corrupt then ErrorNoHalt("Corrupt team \"" ..(CustomTeam.name or "") .. "\": element " .. corrupt .. " is incorrect.\n") end

	table.insert(rp.teams, CustomTeam)
	team.SetUp(#rp.teams, Name, CustomTeam.color)
	local t = #rp.teams
	CustomTeam.team = t

	// Нам как-бы оно вообще не нужно, но оставлю так..
	CustomTeam.category = CustomTeam.category or "Профессии"

	timer.Simple(0, function() GAMEMODE:AddTeamCommands(CustomTeam, CustomTeam.max) end)

	for k, v in pairs(CustomTeam.spawns or {}) do
		rp.cfg.TeamSpawns[k] = rp.cfg.TeamSpawns[k] or {}
		rp.cfg.TeamSpawns[k][t] = v
	end

	// Precache model here. Not right before the job change is done
	if type(CustomTeam.model) == "table" then
		for k,v in pairs(CustomTeam.model) do util.PrecacheModel(v) end
	else
		util.PrecacheModel(CustomTeam.model)
	end
	return t
end

rp.teamDoors = {}
function rp.AddDoorGroup(name, col, ...)
	local varargs = {...}

	local targetteams
	if isstring(varargs[1]) then
		targetteams = {}
		for k,v in pairs(rp.teams) do
			if v.targetname == varargs[1] then
				targetteams[k] = true
			end
		end
	end

	if (isnumber(col)) then
		table.insert(varargs, 1, col)
		col = team.GetColor(col)
	end

	rp.teamDoors[name] = rp.teamDoors[name] or {Color = col, Teams = {}}
	if targetteams then rp.teamDoors[name].Teams = targetteams return end

	for k, v in ipairs(varargs) do
		rp.teamDoors[name].Teams[v] = true
	end
end

rp.shipments = {}
function rp.AddShipment(name, category, model, entity, price, Amount_of_guns_in_one_shipment, Sold_seperately, price_seperately, noshipment, classes, shipmodel, CustomCheck)
	local tableSyntaxUsed = type(model) == "table"

	local AllowedClasses = classes or {}
	if not classes then
		for k,v in ipairs(team.GetAllTeams()) do
			table.insert(AllowedClasses, k)
		end
	end

	local price = tonumber(price)
	local shipmentmodel = shipmodel or "models/Items/item_item_crate.mdl"

	local customShipment = tableSyntaxUsed and model or
		{model = model, entity = entity, price = price, amount = Amount_of_guns_in_one_shipment,
		seperate = Sold_seperately, pricesep = price/Amount_of_guns_in_one_shipment, noship = noshipment, allowed = AllowedClasses,
		shipmodel = shipmentmodel, customCheck = CustomCheck, weight = 5}

	customShipment.pricesep = (price_seperately or (customShipment.price/customShipment.amount))
	customShipment.seperate = customShipment.separate or customShipment.seperate
	customShipment.name = name
	customShipment.category = category == nil and "Другое" or category
	customShipment.allowed = customShipment.allowed or {}

	local temp = customShipment.allowed
	customShipment.allowed = {}

	for k, v in ipairs(temp) do // customShipment.allowed
		customShipment.allowed[v] = true
	end

	local corrupt = checkValid(customShipment, validShipment)
	if corrupt then ErrorNoHalt("Corrupt shipment \"" .. (name or "") .. "\": element " .. corrupt .. " is corrupt.\n") end

	if SERVER then
		rp.nodamage[customShipment.entity] = true
	end

	rp.inv.Wl[customShipment.entity] = name

	table.insert(rp.shipments, customShipment)
	util.PrecacheModel(customShipment.model)
end

/*---------------------------------------------------------------------------
Decides whether a custom job or shipmet or whatever can be used in a certain map
---------------------------------------------------------------------------*/
function GM:CustomObjFitsMap(obj)
	if not obj or not obj.maps then return true end

	local map = string.lower(game.GetMap())
	for k,v in pairs(obj.maps) do
		if string.lower(v) == map then return true end
	end
	return false
end

rp.entities = {}
rp.EntityMap = {}
function rp.AddEntity(name, entity, model, price, max, command, classes, pocket)
	local tableSyntaxUsed = type(entity) == "table"

	local tblEnt = tableSyntaxUsed and entity or
		{ent = entity, model = model, price = price, max = max,
		cmd = command, allowed = classes, pocket = pocket}
	tblEnt.name = name
	tblEnt.allowed = tblEnt.allowed or {}
	tblEnt.catagory = tblEnt.catagory or 'Разное'

	if type(tblEnt.allowed) == "number" then
		tblEnt.allowed = {tblEnt.allowed}
	end

	if #tblEnt.allowed == 0 then
		for k,v in ipairs(team.GetAllTeams()) do
			table.insert(tblEnt.allowed, k)
		end
	end

	local corrupt = checkValid(tblEnt, validEntity)
	if corrupt then ErrorNoHalt("Corrupt Entity \"" .. (name or "") .. "\": element " .. corrupt .. " is corrupt.\n") end

	if SERVER then
		rp.nodamage[entity] = true
	end

	local allowed = {}
	for k, vv in ipairs(tblEnt.allowed) do
		if type(vv) == 'string' then
			for k,v in pairs(rp.teams) do
				if v.targetname == vv || v.type == vv then
					allowed[k] = true
				end
			end
			continue
		end
		allowed[vv] = true
	end
	tblEnt.allowed = allowed

	table.insert(rp.entities, tblEnt)
	rp.EntityMap[tblEnt.ent] = tblEnt
	timer.Simple(0, function() GAMEMODE:AddEntityCommands(tblEnt) end)

	if (tblEnt.pocket ~= false) then
		rp.inv.Wl[tblEnt.ent] = name
	end

	util.PrecacheModel(tblEnt.model)
end

rp.Foods = {}
function rp.AddFoodItem(name, mdl, energy, price)
	rp.Foods[name] = {name = name, model = mdl, energy = energy, price = price} -- to laz
	rp.Foods[#rp.Foods + 1] = {name = name, model = mdl, energy = energy, price = price}

	util.PrecacheModel(mdl)
end

rp.CopItems = {}
function rp.AddCopItem(name, price, model, weapon, callback)
	if istable(price) then
		rp.CopItems[name] = {
			Name = name,
			Price = price.Price,
			Model = Model(price.Model),
			Weapon = price.Weapon,
			Callback = price.Callback
		}
	else
		rp.CopItems[name] = {
			Name = name,
			Price = price,
			Model = Model(model),
			Weapon = weapon,
			Callback = callback
		}
	end
end

rp.Drugs = {}
function rp.AddDrug(name, ent, model, cost, class)
	local tab = {Name = name, Class = ent, Model = model, BuyPrice = math.ceil(cost * .50)}
	rp.Drugs[#rp.Drugs + 1] = tab
	rp.Drugs[ent] = tab
	rp.AddShipment(name, model, ent, math.ceil(cost * 10), 10, false, math.ceil(cost * 1.3), false, {class})
end

rp.Weapons = {}
rp.WeaponsMap = {}
function rp.AddWeapon(name, model, entity, price, classes)
	local price_seperately = price/10*1.25

	local inf = {
		Name = name,
		Class = entity,
		Model = Model(model),
		BuyPrice = math.ceil((price/10) * 0.5)
	}

	rp.Weapons[#rp.Weapons + 1] = inf
	rp.WeaponsMap[entity] = inf

	rp.AddShipment(name, model, entity, price, 10, true, price_seperately, false, classes)
end

rp.groupChats = {}
function rp.addGroupChat(...)
	local varargs = {...}
	local classes = {}
	if isstring(varargs[1]) then
		for k,v in pairs(rp.teams) do
			if v.targetname == varargs[1] then
				table.insert(classes, k)
			end
		end
	else
		classes = varargs
	end
	table.foreach(classes, function(k, class)
		rp.groupChats[class] = {}
		table.foreach(classes, function(k, class2)
			rp.groupChats[class][class2] = true
		end)
	end)
end

rp.ammoTypes = {}
function rp.AddAmmoType(ammoType, name, model, price, amountGiven, customCheck)
	game.AddAmmoType {
		name = ammoType,
		dmgtype = DMG_BULLET,
	}

	table.insert(rp.ammoTypes, {
		ammoType = ammoType,
		name = name,
		model = model,
		price = price,
		amountGiven = amountGiven,
		customCheck = customCheck
	})
end

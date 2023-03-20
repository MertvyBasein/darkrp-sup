local ITEM = {}

ITEM.class = "spawned_food"

ITEM.color = Color(0,255,123)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 1
end


function ITEM.SaveItemData(ent)
	local tb = {}

	tb['model'] = ent:GetModel()
	tb['energy'] = ent.FoodEnergy
	tb['subname'] = ent.subname
	tb['foodIndex'] = ent.foodIndex

	return tb
end

function ITEM.LoadItemData(ent, tb)
	ent:SetModel(tb['model'])
	ent.FoodEnergy = tb.energy or 0
	ent.subname = tb.subname or "N/A"
	ent.foodIndex = tb.foodIndex
end


function ITEM.OnUse(ply, tb)
	ply:AddHunger(tb.save_data.energy)
	ply:SendLua([[PlayAction("https://metahub.ru/eat.mp3")]])
	--ply:EmitSound("flamerp/eat.ogg")
	return nil
end

rp.inventory.AddItemSupport(ITEM)

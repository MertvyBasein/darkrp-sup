local ITEM = {}
ITEM.class = "item_test"
ITEM.color = Color(104, 109, 224)
ITEM.CanUse = false

function ITEM.OnUse(ply, tb)
	return
end

function ITEM.CalculateWeight(tb)
	return 1
end
function ITEM.SaveItemData(ent,aa)
	local tb = {}
	tb['subname'] = 'Пипися'
	tb['model'] = ent:GetModel()
	tb['icon'] = "https://i.imgur.com/C65gGo9.png"

	return tb
end
function ITEM.LoadItemData(ent, tb)

end
rp.inventory.AddItemSupport(ITEM)

local ITEM = {}
ITEM.class = "item_inject"
ITEM.color = Color(104, 109, 224)
ITEM.CanUse = true

function ITEM.OnUse(ply, tb)
	ply:Give(tb.save_data['swep'])
	ply:SelectWeapon(tb.save_data['swep'])
	local e = ''
	for z, x in pairs(craft.recipe) do
		if x.swep == tb.save_data['swep'] then e = z break end
	end
	ply:GetActiveWeapon():SetNWString('Name', e)
end

function ITEM.CalculateWeight(tb)
	return 1
end
function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = ent.subname
	tb['model'] = ent:GetModel()
	tb['swep'] = ent.swep

	return tb
end
function ITEM.LoadItemData(ent, tb)
	ent:SetModel(tb['model'])
	ent.subname = tb.subname or "N/A"
	ent.swep = tb.swep or "sex_syringe1"
end
rp.inventory.AddItemSupport(ITEM)
local ITEM = {}
ITEM.class = "item_materials"
ITEM.color = Color(152, 152, 152)
ITEM.CanUse = false
ITEM.Drop = true

function ITEM.CalculateWeight(tb)
	return 2
end

function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Материалы'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}
ITEM.class = "item_materialsfood"
ITEM.color = Color(152, 152, 152)
ITEM.CanUse = false
ITEM.Drop = true

function ITEM.CalculateWeight(tb)
	return 4
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Готовый материал'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}
ITEM.class = "metahub_seed"
ITEM.color = Color(152, 152, 152)
ITEM.CanUse = false
ITEM.Drop = true

function ITEM.CalculateWeight(tb)
	return 2
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Семена'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}
ITEM.class = "item_farmfood"
ITEM.color = Color(152, 152, 152)
ITEM.CanUse = false
ITEM.Drop = true

function ITEM.CalculateWeight(tb)
	return 4
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Фермерский продукт'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "item_clothes"
ITEM.color = Color(149, 165, 166)
ITEM.CanUse = false

function ITEM.CalculateWeight(tb)
	return 7
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Одежда'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)
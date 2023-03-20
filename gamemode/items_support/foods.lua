local ITEM = {}

ITEM.class = "metahub_pineapple"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 30% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(30)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_orange"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 30% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(30)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_peanuts"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 50% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(50)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_banana"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 30% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(30)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_beer"

ITEM.color = Color(90,150,230)

ITEM.CanUse = false

function ITEM.CalculateWeight(tb)
	return 2
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 50% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_bread"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 50% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(50)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_breenwater"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 30% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(50)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_peer"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 30% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(30)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_coffe"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 50% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(50)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_coco"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 40% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(40)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_sneck"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 50% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(50)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_popcorn"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 50% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(50)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_ration"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 65% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(65)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_rationgo"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 100% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(100)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_cheese"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 30% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(30)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_choco"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 25% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(25)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)

local ITEM = {}

ITEM.class = "metahub_apple"

ITEM.color = Color(90,150,230)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	return 5
end


function ITEM.SaveItemData(ent)
	local tb = {}
	tb['subname'] = 'Восстанавливает 30% голода'
	tb['model'] = ent:GetModel()

	return tb
end

function ITEM.OnUse(ply, tb)
	ply:AddHunger(30)
	ply:EmitSound("physics/flesh/flesh_impact_hard4.wav")
	return nil
end

function ITEM.LoadItemData(ent, tb)
end

rp.inventory.AddItemSupport(ITEM)
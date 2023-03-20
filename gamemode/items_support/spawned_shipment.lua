local ITEM = {}

ITEM.class = "spawned_shipment"

ITEM.color = Color(255,155,55)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	local weight_per_item = rp.inventory.CustomWeight[rp.shipments[tb['content']].entity] or 3
	weight_per_item = weight_per_item * tb['count']

	return weight_per_item
end

function ITEM.SaveItemData(ent)
	local tb = {}

	local content = ent:Getcontents() or ''
	local contents = rp.shipments[content]
	contents = contents.name

	tb['subname'] = contents
	tb['model'] = ent:GetModel()
	tb['clip1'] = ent.clip1
	tb['clip2'] = ent.clip2
	local class = rp.shipments[ent:Getcontents()].entity
	tb['ammoadd'] = ent.ammoadd or (weapons.Get(class) and weapons.Get(class).Primary.DefaultClip)
	tb['content'] = ent:Getcontents() or ''
	tb['count'] = ent:Getcount() or 1

	return tb
end

function ITEM.LoadItemData(ent, tb)
	ent:Setcontents(tb['content'])
	ent:Setcount(tb['count'])
end

function ITEM.OnUse(ply, tb)
	local wep = rp.shipments[tb['save_data']['content']]
	if not wep then return nil end

	if wep['entity'] == "ent_licence" then
		rp.notify(ply, 3, 4, "Вы активировали лицензию!")
		ply:SetNetVar("rp.HasGunLicense", true)

		tb['save_data']['count'] = tb['save_data']['count'] - 1
		if tb['save_data']['count'] <= 0 then return nil end

		return tb
	end

	if wep['entity'] == "ent_disguise" then
		local spawn_pos = util.QuickTrace( ply:GetShootPos(),ply:GetAimVector() * 100, ply ).HitPos
		local item = ents.Create( "ent_disguise" )
		item:SetPos( spawn_pos )
		item:Spawn()

		tb['save_data']['count'] = tb['save_data']['count'] - 1
		if tb['save_data']['count'] <= 0 then return nil end

		return tb
	end

	ply:Give(wep['entity'], true)
	local weapon = ply:GetWeapon(wep['entity'])
	if tb['save_data']['clip1'] then
		weapon:SetClip1(tb['save_data']['clip1'])
		weapon:SetClip2(tb['save_data']['clip2'] or -1)
	end

	ply:GiveAmmo(tb['save_data']['ammoadd'] or 0, weapon:GetPrimaryAmmoType())

	tb['save_data']['count'] = tb['save_data']['count'] - 1

	if tb['save_data']['count'] <= 0 then return nil end

	tb['weight'] = rp.inventory.Items[tb['class']].CalculateWeight(tb['save_data']) or rp.inventory.def_weight

	return tb
end

rp.inventory.AddItemSupport(ITEM)
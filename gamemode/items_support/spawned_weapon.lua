local ITEM = {}

ITEM.class = "spawned_weapon"

ITEM.color = Color(167, 66, 244)

ITEM.CanUse = true

function ITEM.CalculateWeight(tb)
	local weight_per_item = rp.inventory.CustomWeight[tb['weaponclass']] or 3

	return weight_per_item
end


function ITEM.SaveItemData(ent)
	local tb = {}

	tb['model'] = ent:GetModel()
	if ent.weaponclass ~= nil and weapons.Get(ent.weaponclass) ~= nil then
		tb['subname'] = weapons.Get(ent.weaponclass).PrintName or "Unknown"
	else
		if ent.weaponclass == 'ent_licence' then
			tb['subname'] = "Разрешение на оружие"
		elseif ent.weaponclass == 'ent_disguise' then
			tb['subname'] = "Маскировка"
		else
			tb['subname'] = "Unknown"
		end
	end
	tb['weaponclass'] = ent.weaponclass
	tb['clip1'] = ent.clip1
	tb['clip2'] = ent.clip2
	tb['ammoadd'] = ent.ammoadd

	return tb
end

function ITEM.LoadItemData(ent, tb)
	ent:SetModel(tb['model'])

	ent.weaponclass = tb['weaponclass']
	ent.clip1 = tb['clip1']
	ent.clip2 = tb['clip2']
	ent.ammoadd = tb['ammoadd']
end

function ITEM.OnUse(ply, tb)
	if tb['save_data']['weaponclass'] == "ent_licence" then
		rp.notify(ply, 3, 4, "Вы активировали лицензию!")
		ply:SetNetVar("rp.HasGunLicense", true)
		return nil
	end

	if tb['save_data']['weaponclass'] == "ent_disguise" then
		local spawn_pos = util.QuickTrace( ply:GetShootPos(),ply:GetAimVector() * 100, ply ).HitPos
		local item = ents.Create( "ent_disguise" )
		item:SetPos( spawn_pos )
		item:Spawn()

		return nil
	end


	ply:Give(tb['save_data']['weaponclass'], true)
	local weapon = ply:GetWeapon(tb['save_data']['weaponclass'])

	if tb['save_data']['clip1'] then
		weapon:SetClip1(tb['save_data']['clip1'])
		weapon:SetClip2(tb['save_data']['clip2'] or -1)
	end

	ply:GiveAmmo(tb['save_data']['ammoadd'] or 0, weapon:GetPrimaryAmmoType())

	return nil
end

rp.inventory.AddItemSupport(ITEM)

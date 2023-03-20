rp.AddEntity("Денежный станок", {
  ent = "moneyprinter_tier1",
  model = "models/imperator/printer.mdl",
  price = 3500,
  max = 2,
  allowed = {'rofl', 'works', 'gangs', 'mafia', 'Антигитлеровская коалиция', 'usa'},
  category = "Нелегальное",
  cmd = "/buytier1printer",
  onSpawn = function(ent, pl)
    ent:CPPISetOwner(pl)
  end
})


rp.AddEntity("Лицензия на оружие", {
  ent = "ent_licence",
  model = "models/props_lab/clipboard.mdl",
  price = 250,
  max = 1,
  allowed = {'Третий рейх'},
  category = "Легальное",
  cmd = "/",
  onSpawn = function(ent, pl)
    ent:CPPISetOwner(pl)
  end
})

rp.AddEntity('Радио', {
  ent = "media_radio",
  model = "models/props_lab/citizenradio.mdl",
  price = 500,
  max = 1,
  allowed = TEAM_RADIO,
  category = "Легальное",
  cmd = "/medirarido",
  onSpawn = function(ent, pl)
    ent:CPPISetOwner(pl)
  end
})


rp.AddEntity("Плита", {
  ent = "hfm_stove",
  model = "models/props_c17/furnitureStove001a.mdl",
  price = 3500,
  max = 1,
  allowed = {'work'},
  category = "Легал",
  cmd = "/buer1printer",
  onSpawn = function(ent, pl)
    ent:CPPISetOwner(pl)
  end
})
--
--rp.AddEntity("Walter P38", {
--  ent = "moneyprinter_tier1",
--  model = "models/weapons/w_waw_waltherp38.mdl",
--  price = 600,
--  max = 1,
--  allowed = {TEAM_ORUMAST},
--  category = "Нелегальное",
--  cmd = "/buytier1printer",
--})
-- мастер

rp.AddShipment('Walter P38', 'Оружие' ,'models/weapons/tfa_doi/w_p38.mdl', 'tfa_doip38', 17500, 3, true, 999999, false, {TEAM_ORUMAST, TEAM_ORUBAR})
rp.AddShipment('С96 Mauser', 'Оружие' ,'models/weapons/tfa_doi/w_c96.mdl', 'tfa_doic96', 19500, 3, true, 999999, false, {TEAM_ORUMAST, TEAM_ORUBAR})
rp.AddShipment('C96 Carbine', 'Оружие' ,'models/weapons/tfa_doi/w_c96_carbine.mdl', 'tfa_doic96carbine', 22500, 3, true, 999999, false, {TEAM_ORUMAST, TEAM_ORUBAR})
rp.AddShipment('Kar98k', 'Оружие' ,'models/weapons/tfa_doi/w_kar98k.mdl', 'tfa_doik98', 31250, 3, true, 999999, false, {TEAM_ORUMAST, TEAM_ORUBAR})
rp.AddShipment('Gewehr 43', 'Оружие' ,'models/weapons/tfa_doi/w_g43.mdl', 'tfa_doig43', 35500, 3, true, 999999, false, {TEAM_ORUMAST, TEAM_ORUBAR})
rp.AddShipment('MP40', 'Оружие' ,'models/weapons/tfa_doi/w_mp40.mdl', 'tfa_doimp40', 43000, 3, true, 999999, false, {TEAM_ORUMAST, TEAM_ORUBAR})
rp.AddShipment('FG42', 'Оружие' ,'models/weapons/tfa_doi/w_fg42.mdl', 'tfa_doifg42', 44500, 3, true, 999999, false, {TEAM_ORUMAST, TEAM_ORUBAR})
rp.AddShipment('STG-44', 'Оружие' ,'models/weapons/tfa_doi/w_stg44.mdl', 'tfa_doistg44', 57500, 3, true, 999999, false, {TEAM_ORUMAST, TEAM_ORUBAR})

-- барон

rp.AddShipment('MG34', 'Оружие' ,'models/weapons/tfa_doi/w_mg34.mdl', 'tfa_doimg34', 67500, 3, true, 999999, false, {TEAM_ORUBAR})
rp.AddShipment('MG42', 'Оружие' ,'models/weapons/tfa_doi/w_mg42.mdl', 'tfa_doimg42', 75000, 3, true, 999999, false, {TEAM_ORUBAR})

-- Контрабандист

rp.AddShipment('Взломщик кейпадов', 'Вещи' ,'models/weapons/w_c4.mdl', 'keypad_cracker', 2000, 1, true, 999999, false, {TEAM_KONTRABAND})
rp.AddShipment('Отмычка', 'Вещи' ,'models/weapons/w_crowbar.mdl', 'lockpick', 1000, 1, true, 999999, false, {TEAM_KONTRABAND})

rp.AddShipment('SW1917', 'Оружие' ,'models/weapons/tfa_doi/w_sw1917.mdl', 'tfa_doisw1917', 17500, 3, true, 999999, false, {TEAM_KONTRABAND})
rp.AddShipment('Colt M1911', 'Оружие' ,'models/weapons/tfa_doi/w_m1911.mdl', 'tfa_doim1911', 17500, 3, true, 999999, false, {TEAM_KONTRABAND})
rp.AddShipment('SpringField', 'Оружие' ,'models/weapons/tfa_doi/w_springfield.mdl', 'tfa_doispringfield', 37500, 3, true, 999999, false, {TEAM_KONTRABAND})
rp.AddShipment('M1 Garand', 'Оружие' ,'models/weapons/tfa_doi/w_m1garand.mdl', 'tfa_doim1garand', 40000, 3, true, 999999, false, {TEAM_KONTRABAND})
rp.AddShipment('M1A1 Carbine', 'Оружие' ,'models/weapons/tfa_doi/v_m1carbine.mdl', 'tfa_doim1carbine', 42500, 3, true, 999999, false, {TEAM_KONTRABAND})
rp.AddShipment('Thompson', 'Оружие' ,'models/weapons/tfa_doi/v_thompsonm1a1.mdl', 'tfa_doithompsonm1a1', 45500, 3, true, 999999, false, {TEAM_KONTRABAND})
rp.AddShipment('BAR', 'Оружие' ,'models/weapons/tfa_doi/w_bar.mdl', 'tfa_doim1918', 57500, 3, true, 999999, false, {TEAM_KONTRABAND})
rp.AddShipment('Browning M1919', 'Оружие' ,'models/weapons/tfa_doi/w_m1919.mdl', 'tfa_doim1919', 75000, 3, true, 999999, false, {TEAM_KONTRABAND})

-- Кулинар

rp.AddShipment('Банка бобов', 'Еда' ,'models/weapons/food/can_b.mdl', 'weapon_food_can_bob', 100, 1, true, 999999, false, {TEAM_KULINAR})
rp.AddShipment('Банка мяса', 'Еда' ,'models/weapons/food/can_m.mdl', 'weapon_food_can_meat', 150, 1, true, 999999, false, {TEAM_KULINAR})


-- Бармен
rp.AddShipment('Кола', 'Напитки' ,'models/weapons/food/cola.mdl', 'weapon_food_cola', 50, 1, true, 999999, false, {TEAM_BARMEN})
rp.AddShipment('Пиво', 'Напитки' ,'models/weapons/food/reanimated.mdl', 'weapon_food_reanimated', 100, 1, true, 999999, false, {TEAM_BARMEN})
rp.AddShipment('Водка', 'Напитки' ,'models/weapons/food/meteglin.mdl', 'weapon_food_meteglin', 200, 1, true, 999999, false, {TEAM_BARMEN})
rp.AddShipment('Виски', 'Напитки' ,'models/weapons/food/fire_water.mdl', 'weapon_food_fire', 300, 1, true, 999999, false, {TEAM_BARMEN})


hook.Call('rp.AddEntities', GAMEMODE)

-- -- Ammo
rp.AddAmmoType('Pistol', 'Патроны для пистолета', 'models/Items/BoxSRounds.mdl', 30, 25)
rp.AddAmmoType('buckshot', 'Картечь для дробовика', 'models/Items/BoxBuckshot.mdl', 30, 15)
rp.AddAmmoType('smg1', 'СМГ Патроны', 'models/Items/BoxSRounds.mdl', 30, 45)
rp.AddAmmoType('ar2', 'Крупнокалиберные патроны', 'models/Items/BoxSRounds.mdl', 30, 60)
rp.AddAmmoType('357', 'Патроны для револьвера', 'models/Items/BoxSRounds.mdl', 30, 60)
rp.AddAmmoType('SniperPenetratedRound', 'Патроны для снайперки', 'models/Items/BoxSRounds.mdl', 30, 60)
rp.AddAmmoType('AirboatGun', 'Патроны для винчестера', 'models/Items/BoxSRounds.mdl', 30, 60)
--rp.AddAmmoType('m9k_ammo_artillery', 'Снаряды для артиллерии', 'models/Items/BoxSRounds.mdl', 350, 60)

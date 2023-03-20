function PLAYER:GetID()
    return self:GetNetVar("Static") or 'BOT'
end
function PLAYER:GetStatic()
    return self:GetNetVar("Static") or 'BOT'
end

local delete_classes = {
  'prop_*',
  'keypad',
  'keypad_wire',
  'sammyservers_textscreen'
}

TEAM_CITIZEN = rp.addTeam('Местный', {
    color = Color(0, 135, 5, 255),
    model = {
        "models/citizens/pavka/male_01.mdl",
        "models/citizens/pavka/male_02.mdl",
        "models/citizens/pavka/male_03.mdl",
        "models/citizens/pavka/male_04.mdl",
        "models/citizens/pavka/male_05.mdl",
        "models/citizens/pavka/male_06.mdl",
        "models/citizens/pavka/male_07.mdl",
        "models/citizens/pavka/male_08.mdl",
        "models/citizens/pavka/male_09.mdl",
        "models/citizens/pavka/male_10.mdl",
        "models/citizens/pavka/male_11.mdl",
        "models/citizens/pavka/female_01.mdl",
        "models/citizens/pavka/female_02.mdl",
        "models/citizens/pavka/female_03.mdl",
        "models/citizens/pavka/female_04.mdl",
        "models/citizens/pavka/female_06.mdl",
        "models/citizens/pavka/female_07.mdl"
    },   
    description = [[
● Обычный гражданин, ищущий своих приключений.]],
    weapons = {},
    command = 'citizen',
    max = 0,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    citizen = true,
    spawndefault = true,
    sortOrder = 1,
    citizen = true,
    category = '1.Мирные жители',
    PlayerSpawn = function(ply)
        --local skins = {0, 3}
        ply:SetSkin(math.random(6))
        ply:SetBodygroup(1, math.random(0,12))
        ply:SetBodygroup(2, math.random(0,7))
        ply:SetBodygroup(3, math.random(0,2))
        ply:SetBodygroup(4, math.random(0,1))
       --ply:SetBodygroup(6, 0)
       --ply:SetWalkSpeed(100)
       --ply:SetMaxHealth(100)
       --ply:SetMaxArmor(100)

        --ply:StripWeapon('gmod_tool')
        --ply:StripWeapon('weapon_physgun')
        --ply:StripWeapon('weapon_physcannon')
    end
})

------------1.Мирные жители------------


TEAM_MINER = rp.addTeam('Шахтёр', {
   color = Color(24, 213, 255, 255),
   model = {
        'models/chernozemsk/miner1.mdl',
        'models/chernozemsk/miner2.mdl'
   },
   description = [[.]],
   weapons = {'ch_mining_pickaxe'},
   command = 'miner',
   max = 4,
   salary = rp.cfg.normalsalary,
   admin = 0,
   vote = false,
   sortOrder = 2,
   hasLicense = false,
   category = '1.Мирные жители',
   spawndefault = true,
   candemote = false,
})

TEAM_GUN = rp.addTeam('Оружейник', {
    color = Color(255, 140, 0, 255),
    model = {'models/player/gesource_mishkin.mdl'},
    description = [[
● Вы Оружейник!
● Торгуйте оружием - получайте с этого прибыль.
● Получите лиценизию на торговлю у мэра.]],
    weapons = {},
    command = 'gundealer',
    max = 4,
    salary = rp.cfg.normalsalary,
    admin = 0,
    vote = false,
    sortOrder = 3,
    category = '1.Мирные жители',
    hasLicense = false,
    spawndefault = true,
})

TEAM_SB_OWNER = rp.addTeam('Бизнесмен', {
    color = Color(33, 194, 154, 255),
    model = {'models/player/magnusson.mdl'},
   description = [[
● Вы Бизнесмен!
● Придумывайте уникальные способы заработка.
● Воплощайте их в реальность.]],
    weapons = {},
    command = 'bisnesmam',
    max = 3,
    salary = rp.cfg.normalsalary,
    admin = 0,
    vote = false,
    sortOrder = 4,
    category = '1.Мирные жители',
    hasLicense = false,
    spawndefault = true,
})

--
TEAM_FARMER = rp.addTeam('Старушка', {
    color = Color(107, 52, 52, 255),
    model = {'models/rashkinsk/staruska.mdl'},
    description = [[
● Не успели выйти на пенсию до пенсионной реформы? 
● Ну тогда самое время пойти в БИЗНЕС, как раз дачный участок, наверняка, есть.
● Старушка - Занимайтесь садоводством, продавайте овощи прямо с грядки и получайте за это деньги!
● Не забудьте забрать новый выпуск телепрограммы с почты,
● а то сериальчики сами себя не посмотрят.]],
    weapons = {},
    command = 'farmer',
    max = 3,
    salary = rp.cfg.normalsalary,
    admin = 0,
    vote = false,
    hasLicense = false,
    spawndefault = true,
    sortOrder = 6,
    category = '1.Мирные жители',  
})

TEAM_BIT = rp.addTeam('Майнер', {
    color = Color(228, 232, 0, 255),
    model = {'models/player/gesource_boris.mdl'},
    description = [[
● Не успели закончить школу, как сразу пошли майнить, идея кнш такая се, но прибыль есть. 
● Ставь битмайнер, прокачивай его и получай бабки, но смотри, Мэр может и налог поднять так что дерзай!.]],
    weapons = {},
    command = 'bit',
    max = 3,
    salary = rp.cfg.normalsalary,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = '1.Мирные жители',
    sortOrder = 7,
    spawndefault = true,  
})

TEAM_PD_BANKER = rp.addTeam('Банкир', {
    color = Color(4, 209, 83, 255),
    model = {'models/player/lapenko_casual.mdl'},
    description = [[
● Вы Банкир!
● Банкир работает на государственном хранилище.
● Принимайте вклады других людей.
● Наймите охрану для защиты.
● Так же, можете брать под хранение принтеры]],
    weapons = {},
    command = 'pdbanker',
    max = 1,
    salary = rp.cfg.normalsalary * 2,
    admin = 0,
    vote = false,
    sortOrder = 8,
    banker = true,
    category = '1.Мирные жители',
    hasLicense = true,
    spawndefault = true,   
})

TEAM_COOK = rp.addTeam('Повариха', {
    color = Color(204, 61, 0, 255),
    model = {'models/player/alyx.mdl'},
    description = [[
● Вы Повар, готовите еду и после продаете, занимаете ларьки и тусуете в них.
● Зарабатываете на этом деньги короче.
● Можете поставить ларёк, чтобы выставлять туда еду на продажу, 
● Наблюдая за тем, как другие чуваки греют свою еду за деньги!]], 
    weapons = {'tfa_nmrih_kknife'},
    command = 'cook',
    max = 5,
    salary = rp.cfg.normalsalary,
    admin = 0,
    vote = false,
    cook = true,
    sortOrder = 9,
    spawndefault = true,
    category = '1.Мирные жители',
})

TEAM_MEDIC = rp.addTeam('Санитар', {
    color = Color(47, 79, 79, 255),
    model = {"models/player/lapenko_engineer.mdl"},
   description = [[
● Вы Санитар!
● Лечите жителей города от шизы - получайте с этого прибыль.
● У вас есть собственная псих-больница.]], 
    weapons = {'med_kitt'},
    command = 'medic',
    max = 5,
    salary = rp.cfg.normalsalary * 5,
    admin = 0,
    vote = false,
    medic = true,
    sortOrder = 10,
    category = '1.Мирные жители',
    spawndefault = true,
    medic = true,
})


TEAM_HOBO = rp.addTeam('Бездомный', {
   color = Color(94, 50, 0, 255),
   model = {'models/player/corpse1.mdl'},
   description = [[
● Вы Бомж, у вас нету дома!
● Вы вынуждены просить еду и деньги.
● Постройте дом из дощечек и подручного мусора.]], 
   weapons = {'weapon_bomj_molochkov'},
   command = 'Hobo',
   max = 5,
   salary = 0,
   admin = 0,
   vote = false,
   hobo = true,
   sortOrder = 11,
   spawndefault = true,
   category = '1.Мирные жители',
})

----2.Криминал------

TEAM_JACKET = rp.addTeam('Куртка', {
    color = Color(228, 64, 64, 255),
    model = {'models/splinks/hotline_miami/jacket/player_jacket.mdl'},
   description = [[
● Вы Куртка.
● Ваша задача выполнять заказы на исключительно плохих людей(и русскую мафию)
● О вас не должна знать полиция, иначе будет очень плохо.
● Иногда у вас случаются припадки и вы становитесь отбитым нахуй на голову.]], 
    weapons = {'swep_disguise_briefcase','tfa_nmrih_bcd', 'weapon_cuff_rope','swb_css_mac10','keypad_cracker','lockpick','climb_swep'},
    command = 'jacket',
    max = 1,
    salary = 0,
    admin = 0,
    vote = false,
    sortOrder = 12,
    category = '2.Криминал',
    PlayerLoadout = function(ply) GAMEMODE:SetPlayerSpeed(ply, rp.cfg.WalkSpeed * 1.2, rp.cfg.RunSpeed * 1.4) ply:SetHealth(200) ply:SetMaxHealth(200) ply:SetArmor(100) return CLIENT end,
    vip = true,
    spawndefault = true,
    type = "gang",
    PlayerDeath = function(ply, weapon, killer)
        ply:TeamBan()
        ply:ChangeTeam(1, true)
        --sendPopup('Городские новости', 'Jacket мёртв!','')
        rp.FlashNotifyAll('Городские Новости', 'Джекет мёртв')
    end,
})
--
TEAM_MOB = rp.addTeam("Глава Колумбийцев", {
    color = Color(83, 16, 102, 255),
    model = {
        "models/player/assasinge/tubbs.mdl",
    },
   description = [[

● Вы глава Колумбийской Мафии, ваши враги это Русская Мафия
● Вы 2.Криминальное лицо этого города!]],
    weapons = {"tfa_nmrih_lpipe","lockpick","weapon_ciga","weapon_cuff_rope"},
    command = "mobboss",
    max = 1,
    salary = rp.cfg.normalsalary * 3,
    admin = 0,
    vote = false,
    sortOrder = 13,
    spawndefault = true,
    category = "2.Криминал",
    type = "gang",
})

TEAM_GANG = rp.addTeam("Колумбиец", {
    color = Color(152, 19, 189, 255),
    model = {
        "models/player/suits/male_02_open.mdl",
        "models/player/suits/male_01_open.mdl",
        "models/player/suits/male_01_open.mdl",
        "models/player/suits/male_04_open.mdl",
        "models/player/suits/male_05_open.mdl",
        "models/player/suits/male_06_open.mdl",
        "models/player/suits/male_07_open.mdl",
        "models/player/suits/male_08_open.mdl",
        "models/player/suits/male_09_open.mdl"
    },
   description = [[

● Ваши враги это русские.
● Подчинаетесь только Главарю]],
    weapons = {"tfa_nmrih_lpipe"},
    command = "gangster",
    max = 10,
    salary = rp.cfg.normalsalary,
    admin = 0,
    vote = false,
    sortOrder = 14,
    type = "gang",
    spawndefault = true,
    category = "2.Криминал",
})

TEAM_MANIACC = rp.addTeam('Маньяк', {
    color = Color(228, 64, 64, 255),
    model = {"models/player/lapenko_shershen.mdl"},
    description = [[

● Эх, сейчас бы кого-нибудь попиздить чем-нибудь интересным.

✔ Правила:
● Вам Разрешено иметь тяжёлое оружие
● Вам нельзя грабить.
● Вам нельзя объединяться с бандами]], 

    weapons = {'swep_disguise_briefcase','tfa_nmrih_machete', 'weapon_cuff_rope'},
    command = 'maniac',
    max = 2,
    salary = 0,
    admin = 0,
    vote = false,
    sortOrder = 15,
    spawndefault = true,
    category = '2.Криминал',
    vip = true,
    PlayerLoadout = function(ply)
        ply:SetHealth(100) -- ХП
        ply:SetMaxHealth(100)
        ply:SetArmor(50)
    end,
})
--
TEAM_KAMA = rp.addTeam("Главарь Русской Мафии", {
    color = Color(22, 102, 89, 255),
    model = "models/player/assasinge/crockett.mdl",
   description = [[.]],      
    weapons = {"tfa_nmrih_bat","lockpick","weapon_ciga","weapon_cuff_rope"},
    command = "kama",
    max = 1,
    salary = rp.cfg.normalsalary * 2,
    admin = 0,
    vote = false,
    sortOrder = 16,
    spawndefault = true,
    category = "2.Криминал",
})

TEAM_HACH = rp.addTeam("Русский", {
    color = Color(18, 179, 152, 255),
    model = {
        "models/hotlinemiami/russianmafia/mafia02pm.mdl",
        "models/hotlinemiami/russianmafia/mafia04pm.mdl",
        "models/hotlinemiami/russianmafia/mafia07pm.mdl",
        "models/hotlinemiami/russianmafia/mafia08pm.mdl",
        "models/hotlinemiami/russianmafia/mafia09pm.mdl",
    },
   description = [[]],      
    weapons = {"tfa_nmrih_bat","weapon_ciga"},
    command = "hach",
    max = 10,
    salary = rp.cfg.normalsalary,
    admin = 0,
    vote = false,
    sortOrder = 17,
    spawndefault = true,
    category = "2.Криминал",
})

TEAM_BANTANK = rp.addTeam("Громила", {
    color = Color(130, 130, 135, 255),
    model = "models/player/phoenix.mdl",
   description = [[

● АЭ эбелех1а ялда.
● Живешь по понятием ауе все дела, каждый день суета, жизнь ворам хуй мусорам.
● ты смари широкий бэляяя я вахуе!]],  
    weapons = {"weapon_superfists","weapon_ciga"},
    command = "banditblyat",
    max = 1,
    salary = 100,
    admin = 0,
    vote = false,
    sortOrder = 18,
    PlayerLoadout = function(ply)
        ply:SetHealth(200) -- ХП
        ply:SetMaxHealth(200)
        ply:SetArmor(100)
        ply:StripWeapon( "weapon_fists" )
    end,  
    PlayerSpawn = function(ply)
        local scale = 1.2
        ply:SetModelScale( scale, 0 )
        ply:SetViewOffset( Vector(0, 0, 64) * scale )
        ply:SetViewOffsetDucked( Vector(0, 0, 28) * scale )
    end, 
    category = "2.Криминал",
    spawndefault = true,
    vip = true,
})

TEAM_VOR = rp.addTeam("Вор", {
    color = Color(75, 75, 75, 255),
    model = {"models/player/robber.mdl"},
    description = [[
● Любитель взламывать и выносить хаты, а так же продавать свои услуги различным группировкам.
● Это че за пиздюк еще?.]],
    weapons = {"lockpick"},
    command = "vor",
    max = 3,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    sortOrder = 19,
    spawndefault = true,
    category = "2.Криминал",
})

TEAM_VORVIP = rp.addTeam("Блатной Вор", {
    color = Color(75, 75, 75, 255),
    model = {"models/player/lapenko_sdohni_ili_umri.mdl"},
    description = [[

● Блатной Вор, думаешь так просто? аа нееет.
● ты самый лучший Вор в Дагестане, тебе даже шпак не составит труда украсть.
● У тебя даже ствол есть, чтобы если разробрки начнутся, как очкошник ствол дастать.]],
    weapons = {"lockpick", "keypad_cracker"},
    command = "vorvip",
    max = 2,
    salary = 150,
    admin = 0,
    vote = false,
    hasLicense = false,
    sortOrder = 20, 
    spawndefault = true,
    vip = true,
    category = "2.Криминал",
})


TEAM_HITMAN = rp.addTeam("Наемный убийца", {
    color = Color(82, 51, 51, 255),
    model = "models/player/lapenko_journalist.mdl",
       description = [[

● аДИН Люле КЕбаб палажста.
● Вы Наемный убица.
● Стреляй там тут, тюда сюда жиесь куда пакайфу ну что эта заказ был тока барат.]],
    weapons = {"lockpick", "tfa_nmrih_bat"},
    command = "hitman",
    max = 3,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    sortOrder = 21,
    spawndefault = true,
    category = "2.Криминал",
})

TEAM_DRUG = rp.addTeam("Барыга", {
    color = Color(31, 174, 233, 255),
    model = {"models/player/lapenko_shershen.mdl"},
   description = [[

● Насвай уже надаел фсем прадавай снус
● Раскумарет жиесь сразу после первага захода.
● Торгуйся, но опасаися мусаров.]],
    weapons = {"weapon_biggiebong"},
    command = "drug",
    max = 2,
    salary = rp.cfg.normalsalary * 5,
    admin = 0,
    vote = false,
    sortOrder = 22,
    spawndefault = true,
    category = "2.Криминал",
})
----------------2.Криминал заработники бли----------
TEAM_CIGAR = rp.addTeam('СнюсоМейкер', {
    color = Color(255, 207, 72, 255),
    model = {'models/player/eli.mdl'},
    description = [[
● Вы СнюсоМейкер !
● Покупаешь снюсопроизводитель/заполняешь по рецепту
● Ждешь пока изготовиться, cобираешь все в коробку.
★ Найди скупщика снюса и продай ему. (обычно он ошивается за по переулкам)]],   
    weapons = {},
    command = 'cigar',
    max = 3,
    salary = 0,
    admin = 0,
    sortOrder = 23,
    vote = false,
    spawndefault = true,
    category = '2.Криминал',
})

TEAM_NASVAI = rp.addTeam('НасвайМейкер', {
    color = Color(4, 209, 83, 255),
    model = {'models/player/hazmat/colorable_hazmat.mdl'},
   description = [[
● Вы НасвайМейкер!
● Покупаешь тазик/заполняешь по рецепту.
● Минимальная доза на продажу готова. Нажи по ней E и неси её скупщику.]],   
    weapons = {},
    command = 'methcook',
    max = 3,
    salary = 0,
    admin = 0,
    vote = false,
    category = '2.Криминал',
    spawndefault = true,
    hasLicense = false,
    sortOrder = 24,
})

----МВД--------

TEAM_GEBNYA = rp.addTeam('О.М.О.Н', {
    color = Color(25, 50, 170, 255),
    model = {
        'models/player/kerry/policeru_01_omon.mdl',
        'models/player/kerry/policeru_02_omon.mdl',
        'models/player/kerry/policeru_03_omon.mdl',
        'models/player/kerry/policeru_04_omon.mdl',
        'models/player/kerry/policeru_05_omon.mdl',
        'models/player/kerry/policeru_06_omon.mdl',
        'models/player/kerry/policeru_07_omon.mdl',
    },
   description = [[
● Отряд Гэбня, особый секретный отряд Сургута, 
● Который создали еще при СССР, ведет слежку за самыми крупными преступными группировками, 
● Следит за полицией и возможно даже за самим Мэром. Подчиняется только Главе отряда Гэбня.]],   
    weapons = {'unarrest_baton','swep_disguise_briefcase', 'door_ram', 'cp_helper', 'handcuffs', 'nightstick', 'salute','swb_css_mp5', 'swb_css_usp'},
    command = 'gebnya',
    max = 10,
    salary = 700,
    admin = 0,
    candemote = true,
    hasLicense = true,
    police = true,
    CannotOwnDoors = true,
    sortOrder = 25,
    category = '3.Правоохранительные органы', 
    vip = true,
    PlayerLoadout = function(ply) ply:SetHealth(255) ply:SetArmor(255) end,
})

TEAM_GLGEBNYA = rp.addTeam('Глава О.М.О.Н', {
    color = Color(25, 25, 170, 255),
    model = {
        'models/player/kerry/policeru_01_omon.mdl',
        'models/player/kerry/policeru_02_omon.mdl',
        'models/player/kerry/policeru_03_omon.mdl',
        'models/player/kerry/policeru_04_omon.mdl',
        'models/player/kerry/policeru_05_omon.mdl',
        'models/player/kerry/policeru_06_omon.mdl',
        'models/player/kerry/policeru_07_omon.mdl',
    },
   description = [[
● Отряд Гэбня, особый секретный отряд Сургута, который создали еще при СССР, 
● ведет слежку за самыми крупными преступными группировками, следит за полицией и возможно даже за самим Мэром. 
● Руководитe всем отрядом Гэбня. Никому не подчиняется.]],  
    weapons = {'unarrest_baton','swep_disguise_briefcase','door_ram', 'cp_helper', 'handcuffs', 'nightstick', 'salute', 'swb_css_mp5', 'swb_css_fiveseven'},
    command = 'glgebnya',
    max = 1,
    salary = 1800,
    admin = 0,
    candemote = true,
    hasLicense = true,
    police = true,
    CannotOwnDoors = true,
    sortOrder = 26,
    category = '3.Правоохранительные органы', 
    PlayerLoadout = function(ply) ply:SetHealth(200) ply:SetArmor(200) end,
})

TEAM_CHIEF = rp.addTeam('Шеф Полиции', {
    color = Color(5, 0, 79, 255),
    model = {'models/kerry/player/police_ru_future.mdl'},
   description = [[
● В армии Вам постоянно харкали в ебало, но вы достойно терпели все унижения. 
● Из-за того, что Вы терпила - вам дали повышение в виде руководства над всей полицией города.]],  
    weapons = {'unarrest_baton','swb_css_fiveseven','swb_css_ump','door_ram', 'cp_helper', 'handcuffs', 'nightstick', 'salute'},
    command = 'chief',
    max = 1,
    salary = 1700,
    admin = 0,
    candemote = true,
    hasLicense = true,
    police = true,
    PoliceChief = true,
    CannotOwnDoors = true,
    sortOrder = 27,
    category = '3.Правоохранительные органы', 
    PlayerLoadout = function(ply) ply:SetArmor(255) end,
})

TEAM_POLICE = rp.addTeam('Полицейский', {
    color = Color(16, 0, 240, 255),
    model = {
        'models/player/kerry/policeru_01.mdl',
        'models/player/kerry/policeru_02.mdl',
        'models/player/kerry/policeru_03.mdl',
        'models/player/kerry/policeru_04.mdl',
        'models/player/kerry/policeru_05.mdl',
        'models/player/kerry/policeru_06.mdl',
        'models/player/kerry/policeru_07.mdl',
    },
   description = [[
● В школе вы постоянно стучали на всех и вам давали пиздюлей. 
● Сейчас вы продолжаете стучать на всех, только теперь вы даете всем пизды. 
● Стойте на защите своего родного города.]],    
    weapons = {'unarrest_baton','door_ram', 'cp_helper', 'handcuffs', 'nightstick', 'salute', 'swb_css_usp'},
    command = 'cp',
    max = 10,
    salary = 600,
    admin = 0,
    candemote = true,
    hasLicense = true,
    police = true,
    CannotOwnDoors = true,
    sortOrder = 28,
    category = '3.Правоохранительные органы', 
    PlayerLoadout = function(ply) ply:SetHealth(100) ply:SetArmor(100) end,
})

TEAM_POLICEMEDIC = rp.addTeam('Полицейский-поддержка', {
    color = Color(16, 0, 100, 255),
    model = {
        'models/player/kerry/policeru_01_patrol.mdl',
        'models/player/kerry/policeru_02_patrol.mdl',
        'models/player/kerry/policeru_03_patrol.mdl',
        'models/player/kerry/policeru_04_patrol.mdl',
        'models/player/kerry/policeru_05_patrol.mdl',
        'models/player/kerry/policeru_06_patrol.mdl',
        'models/player/kerry/policeru_07_patrol.mdl',
    },
   description = [[
● Помогайте своим во время перестрелок и прочих ситуаций, ваша задача спасти всех бойцов полицейского участка. 
● Вы имеете право лечить только полицейских.]],  
    weapons = {'unarrest_baton','door_ram', 'cp_helper', 'handcuffs', 'swb_css_usp', 'weapon_medkit', 'weapon_armorkit', 'salute', 'nightstick'},
    command = 'cpmedic',
    max = 5,
    salary = 600,
    admin = 0,
    candemote = true,
    hasLicense = true,
    police = true,
    CannotOwnDoors = true,
    sortOrder = 29,
    category = '3.Правоохранительные органы',
    PlayerLoadout = function(ply) ply:SetHealth(150) ply:SetArmor(100) end,
})          
TEAM_MAYOR = rp.addTeam('Мэр Города', {
    color = Color(150, 20, 20, 255),
    model = {'models/player/gesource_valentin.mdl'},
   description = [[
● Вы мэр. Бывший авторитет 90-х.
● Руководствуйте своими шестёрками из полиции и 'грабьте' благоустраивайте город.]],  
    weapons = {'unarrest_baton','handcuffs', 'nightstick', 'salute'},
    command = 'mayor',
    max = 1,
    salary = 2000,
    vote = true,
    candemote = true,
    hasLicense = true,
    mayor = true,
    PoliceChief = true,
    CannotOwnDoors = true,
    sortOrder = 30,
    category = '3.Правоохранительные органы',
    PlayerLoadout = function(ply) ply:SetHealth(100)  ply:SetArmor(100) end,
    PlayerSpawn = function(ply, weapon, killer)
       if ply:Team() == TEAM_MAYOR then
            DarkRP.notify( ply, 1, 4, "Так как вы только стали Мэром" )
            DarkRP.notify( ply, 1, 4, "Вы получили бессмертие на ".. timed .." секунд!" )
            ply:GodEnable()
       end
     
       timer.Simple( 300, function()
            DarkRP.notify( ply, 1, 4, "Вы снова смертны." )
            ply:GodDisable()
       end )
    end,   
    PlayerDeath = function(ply, weapon, killer)
        ply:TeamBan()
        ply:ChangeTeam(1, true)
        --sendPopup('Городские новости', 'Jacket мёртв!','')
        rp.FlashNotifyAll('Городские Новости', 'Мэр Города мёртв')
        for _, ent in ipairs(delete_classes) do
             for k,v in ipairs(ents.FindByClass(ent)) do if v:CPPIGetOwner() == ply then v:Remove() end end 
        end        
    end,
    AfterJobChanged = function(ply, new) 
        for _, ent in ipairs(delete_classes) do
             for k,v in ipairs(ents.FindByClass(ent)) do if v:CPPIGetOwner() == ply then v:Remove() end end 
        end
    end,
})

TEAM_GUARD = rp.addTeam("Телохранитель", {
    color = Color(20, 20, 20, 255),
    model = "models/player/gesource_bond.mdl",
   description = [[

● Ты - Телохранитель.
● Тебе всегда нужно быть рядом с Мэрам и защищать от любых напастей любой ценой!
● Ты просто ОБЯЗАН быть с ним и сопровождать их во всех делах!
● Будь бдителен! Все хотят занять пост Мэра!]],
    weapons = {"dag_pm","swep_radiodevice"},
    command = "guard",
    max = 3,
    salary = rp.cfg.normalsalary * 4,
    admin = 0,
    vote = true,
    hasLicense = true,
    hasRadio = true,
    sortOrder = 31,
    category = "3.Правоохранительные органы",
    PlayerLoadout = function(ply) ply:SetHealth(100)  ply:SetArmor(100) end,
    PlayerDeath = function(ply, weapon, killer)
        ply:TeamBan()
        ply:ChangeTeam(1, true)
        --sendPopup('Городские новости', 'Jacket мёртв!','')
        rp.FlashNotifyAll('Городские Новости', 'Телохранитель мёртв')
        for _, ent in ipairs(delete_classes) do
             for k,v in ipairs(ents.FindByClass(ent)) do if v:CPPIGetOwner() == ply then v:Remove() end end 
        end        
    end,
    type = "gos",
    AfterJobChanged = function(ply, new) 
        for _, ent in ipairs(delete_classes) do
             for k,v in ipairs(ents.FindByClass(ent)) do if v:CPPIGetOwner() == ply then v:Remove() end end 
        end
    end,
})

rp.DefaultTeam = TEAM_CITIZEN

--rp.addGroupChat(TEAM_WLM)
--rp.addGroupChat('Третий рейх')
--rp.addGroupChat('СССР')
--rp.addGroupChat('США')

-- не ставить колор_вайт
/*rp.AddDoorGroup('США', Color(255,255,255), 'США') 
rp.AddDoorGroup('Армия Крайова', Color(255, 255, 255), 'СССР')
rp.AddDoorGroup('ВС Италия', Color(255, 255, 255), 'Третий рейх')
rp.AddDoorGroup('СССР', Color(255, 255, 255), 'СССР')
rp.AddDoorGroup('Тюрьма', Color(52, 94, 52), 'Третий рейх')
rp.AddDoorGroup('Рейхсминистерство', Color(255, 255, 255), 'Третий рейх')
rp.AddDoorGroup('Лагерь', Color(255, 255, 255), 'Третий рейх')
rp.AddDoorGroup('Оружейный склад', Color(255, 255, 255), 'Третий рейх')

rp.AddDoorGroup('Гетто', Color(255, 255, 255), 'Третий рейх')

rp.AddDoorGroup('Рейхстаг', Color(52, 94, 52), 'Третий рейх')
rp.AddDoorGroup('Вермахт', Color(52, 94, 52), 'Третий рейх')
rp.AddDoorGroup('Суд', Color(52, 94, 52), 'Третий рейх')
rp.AddDoorGroup("Больница", Color(255, 255, 255), TEAM_FELDSHER, TEAM_DOC)

rp.AddDoorGroup('Ресторан', Color(255, 255, 255), TEAM_UMAFIA, TEAM_SMAFIA, TEAM_KMAFIA, TEAM_MBMAFIA, TEAM_DMAFIA)
rp.AddDoorGroup('Вокзал', Color(255, 255, 255), 'Третий рейх')

rp.AddDoorGroup('Банк', Color(255,255,255), TEAM_BANKER)

rp.AddDoorGroup("Кинотеатр", Color(255, 255, 255), TEAM_KINE)

rp.AddDoorGroup("Клуб", Color(255, 255, 255), TEAM_CLUBDIR)

rp.AddDoorGroup('Главное Управление СС', Color(52, 94, 52), 'Третий рейх')*/
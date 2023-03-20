local nodraw = {
 CHudHealth      = true,
 CHudBattery     = true,
 CHudSuitPower   = true,
 CHudAmmo        = true,
 CHudSecondaryAmmo = true,
 CHudWeaponSelection = true
}
function GM:HUDShouldDraw(name)
 if nodraw[name] or ((name == 'CHudDamageIndicator') and (not LocalPlayer():Alive())) then
     return false
 end
 local wep = IsValid(LocalPlayer()) and LocalPlayer():GetActiveWeapon()
 if (IsValid(wep) and wep:GetClass() == 'gmod_camera') then return (name == 'CHudGMod') end

 return true
end

surface.CreateFont("FlameUI.WeaposSelector_TAB", {
    size = ScreenScale(7),
    weight = 1000,
    antialias = true,
    extended = true,
    font = "Roboto"
})

surface.CreateFont("FlameUI.WeaposSelector", {
    size = ScreenScale(6),
    weight = 350,
    antialias = true,
    extended = true,
    font = "Roboto"
})

local categories = {'Строительство', 'Roleplay', 'Оружие', 'Другое', 'Ножи', 'Вейпы'}

local weaponMap = {
    weapon_physgun = {
        Name = 'Физган',
        Slot = 1
    },
    weapon_physcannon = {
        Name = 'Грави пушка',
        Slot = 1
    },
    gmod_tool = {
        Name = 'Тулган',
        Slot = 1,
    },
    weapon_rpg = {
        Name = 'RPG',
        Slot = 3
    },
    weapon_crossbow = {
        Name = 'Арбалет',
        Slot = 3
    },
    weapon_crowbar = {
        Name = 'Лом',
        Slot = 3
    },
    weapon_slam = {
        Name = 'SLAM',
        Slot = 3
    },
    weapon_stunstick = {
        Name = 'Дубинка',
        Slot = 4
    },
    stun_baton = {
        Slot = 4
    },
    arrest_baton = {
        Slot = 4
    },
    door_ram = {
        Slot = 4
    },
    unarrest_baton = {
        Slot = 4
    },
    weapon_taser = {
        Slot = 3
    },
    weaponchecker = {
        Slot = 2
    },
    weapon_pimphand = {
        Slot = 4
    },
    weapon_burgatron = {
        Slot = 4
    },
    weapon_ak47_phoen = {
        Slot = 3
    },
    awpdragon = {
        Slot = 3
    },
}

local function getWeaponSlot(wep)
    if string.sub(wep:GetClass(), 1, 3) == "m9k" then return 3 end
    if string.sub(wep:GetClass(), 1, 4) == "csgo" or string.sub(wep:GetClass(), #wep:GetClass() - 4, #wep:GetClass()) == "ghost" then return 5 end
    if string.sub(wep:GetClass(), 1, 11) == "weapon_cuff" then return 2 end
    if string.sub(wep:GetClass(), 1, 11) == "weapon_vape" then return 6 end

    if (wep.GetSwitcherSlot) then
        wep.Slot = wep:GetSwitcherSlot()
    end

    local map = weaponMap[wep:GetClass()]

    return (map and map.Slot) or (wep.Slot and math.Clamp(wep.Slot, 2, 4)) or 2
end

local wepsCache = {}
local weaponsByCategory = {}
local weaponsByOrder = {}
local weaponsByClass = {}
local selectedWeapon = -1
local lastCache = CurTime()

local function ensureWeapons(force)
    local weps = LocalPlayer():GetWeapons()

    if (lastCache <= CurTime() or force) then
        wepsCache = weps
        table.Empty(weaponsByCategory)
        table.Empty(weaponsByOrder)
        table.Empty(weaponsByClass)

        for k, cat in ipairs(categories) do
            local wepSlot = k
            weaponsByCategory[wepSlot] = {}

            for _, wep in pairs(weps) do
                if (getWeaponSlot(wep) == wepSlot) then
                    local ind = table.insert(weaponsByCategory[wepSlot], {
                        ID = #weaponsByOrder + 1,
                        Class = wep:GetClass(),
                        Name = (weaponMap[wep:GetClass()] and weaponMap[wep:GetClass()].Name) or wep.PrintName or wep:GetClass()
                    })

                    weaponsByOrder[#weaponsByOrder + 1] = weaponsByCategory[wepSlot][ind]
                    weaponsByClass[wep:GetClass()] = weaponsByCategory[wepSlot][ind]
                end
            end
        end
    end

    if (selectedWeapon == 0 and IsValid(LocalPlayer():GetActiveWeapon()) and weaponsByClass[LocalPlayer():GetActiveWeapon():GetClass()]) then
        selectedWeapon = weaponsByClass[LocalPlayer():GetActiveWeapon():GetClass()].ID
    end

    lastCache = CurTime() + 0.25
end

local showTime = 0
local fadeTime = 0
local w, h = ScrW() * .12, 35

hook.Add("HUDPaint", "FlameRP.WeaposSelector", function()
    if LocalPlayer():InVehicle() then return end
    local st = SysTime()
    if (showTime + 0.25 <= st) then return end
    ensureWeapons()
    local a

    if (showTime <= st) then
        a = Lerp((st - showTime) / 0.1, 255, 0)
    else
        a = Lerp((st - fadeTime) / 0.1, 0, 255)
    end

    local not_clear_cat = 0

    for k, cat in ipairs(categories) do
        if #weaponsByCategory[k] < 1 then continue end
        not_clear_cat = not_clear_cat + 1
    end

    local x, y = (ScrW() - not_clear_cat * (w + 3)) * 0.5, 35
    local last_checked = 0

    for k, cat in ipairs(categories) do
        if table.Count(weaponsByCategory[k]) < 1 then continue end
        last_checked = last_checked + 1
        local x, y = x + ((last_checked - 1) * (w + 3)), y
        local wepSlot = k
        DrawBox(x, y, w, h, Color(0, 0, 0, a-15), Color(0, 0, 0, a-255))
        frametext(wepSlot .. '. ' .. cat, 'FlameUI.WeaposSelector_TAB', x + (w * 0.5), y + (h * 0.5), Color(255, 255, 255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, Color(0, 0, 0, a))

        for i, wep in ipairs(weaponsByCategory[wepSlot]) do
            local y = y + (i * (h + 3))
            DrawBox(x, y, w, h, Color(20, 20, 20, a - 105), Color(0, 0, 0, a-255))

            if (wep.ID == selectedWeapon) then
                DrawBox(x, y, w, h, Color(142, 142, 142, a-75), Color(0, 0, 0, a-255))
                --elseif IsValid(LocalPlayer():GetActiveWeapon()) and wep and wep.ID == weaponsByClass[LocalPlayer():GetActiveWeapon():GetClass()].ID then
            elseif IsValid(LocalPlayer():GetActiveWeapon()) and wep and weaponsByClass[LocalPlayer():GetActiveWeapon():GetClass()] and wep.ID == weaponsByClass[LocalPlayer():GetActiveWeapon():GetClass()].ID then
                DrawBox(x, y, w, h, Color(20, 20, 20, a - 105), Color(0, 0, 0, a-255))
            end

            frametext(wep.Name, 'FlameUI.WeaposSelector', x + (w * 0.5), y + (h * 0.5), Color(255, 255, 255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, Color(0, 0, 0, a))
        end
    end
end)

local lastSnd = 0

hook.Add('PlayerBindPress', 'rp.wepswitch.PlayerBindPress', function(pl, bind, pressed)
    if (not pressed) then return end
    if (not LocalPlayer():Alive()) then return end

    if (not IsValid(LocalPlayer():GetActiveWeapon())) then
        if table.Count(LocalPlayer():GetWeapons()) > 1 then
            RunConsoleCommand("use", table.Random(LocalPlayer():GetWeapons()):GetClass())
        end

        return
    end

    if (table.Count(LocalPlayer():GetWeapons()) <= 1) then return end
    local wep = pl:GetActiveWeapon()
    if IsValid(wep) and wep.SWBWeapon and wep.dt and (wep.dt.State == SWB_AIMING) and wep.AdjustableZoom then return end
    if LocalPlayer():InVehicle() then return end
    if ((bind == 'invprev') or (bind == 'invnext') or (string.sub(bind, 1, 4) == 'slot')) and (not pl:KeyDown(IN_ATTACK)) then
        if (string.sub(bind, 1, 3) == 'inv') then
            if (showTime < SysTime()) then
                ensureWeapons(true)
                selectedWeapon = weaponsByClass[LocalPlayer():GetActiveWeapon():GetClass()].ID
            end

            local scroll = (bind == 'invprev') and -1 or 1
            selectedWeapon = selectedWeapon + scroll

            if (not weaponsByOrder[selectedWeapon]) then
                selectedWeapon = (scroll == 1 and 1) or #weaponsByOrder
            end
        else -- using number keys
            if (showTime < SysTime()) then
                ensureWeapons(true)
                fadeTime = SysTime()
            end

            local slot = tonumber(string.sub(bind, -1))
            if (not categories[slot]) then return end
            if #weaponsByCategory[slot] < 1 then return end

            if (weaponsByCategory[slot][1]) then
                local found = false

                for k, v in ipairs(weaponsByCategory[slot]) do
                    if (v.ID == selectedWeapon) then
                        found = true

                        if (weaponsByCategory[slot][k + 1]) then
                            selectedWeapon = v.ID + 1
                        else
                            selectedWeapon = weaponsByCategory[slot][1].ID
                        end

                        break
                    end
                end

                if (not found) then
                    selectedWeapon = weaponsByCategory[slot][1].ID
                end
            end
        end

        ensureWeapons(true)
        showTime = SysTime() + 2

        if (lastSnd < SysTime() - 0.05) then
            surface.PlaySound("xpgui/submenu/submenu_dropdown_rollover_01.wav")
            lastSnd = SysTime()
        end
    elseif (showTime > SysTime() and bind == '+attack') then
        if (IsValid(LocalPlayer():GetActiveWeapon()) and weaponsByOrder[selectedWeapon] and weaponsByClass[LocalPlayer():GetActiveWeapon():GetClass()] and selectedWeapon ~= weaponsByClass[LocalPlayer():GetActiveWeapon():GetClass()].ID) then
            RunConsoleCommand('use', weaponsByOrder[selectedWeapon].Class)
        end

        showTime = 0
        surface.PlaySound("xpgui/submenu/submenu_dropdown_select_01.wav")

        return true
    elseif (bind == 'phys_swap') then
        showTime = 0
    end
end)

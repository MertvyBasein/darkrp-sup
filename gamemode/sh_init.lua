rp 		= rp or {}
rp.cfg 	= rp.cfg or {}
rp.inv 	= rp.inv or {Data = {}, Wl = {}}

PLAYER	= FindMetaTable 'Player'
ENTITY	= FindMetaTable 'Entity'
VECTOR	= FindMetaTable 'Vector'
rp = rp or {}
rp.config = rp.config or {}
rp.util = rp.util or {}
rp.ents_list = rp.ents_list or {}

if (SERVER) then
	require 'mysql'
else
	require 'cvar'
end
require 'nw'
require 'pon'
require 'term'
require 'cmd'
require 'chat'

rp.include = function(f)
	if string.find(f, '_sv.lua') then
		return plib.IncludeSV(f)
	elseif string.find(f, '_cl.lua') then
		return plib.IncludeCL(f)
	else
		return plib.IncludeSH(f)
	end
end
rp.include_dir = function(dir, recursive)
	local fol = dir .. '/'
	local files, folders = file.Find(fol .. '*', 'LUA')
	for _, f in ipairs(files) do
		rp.include(fol .. f)
	end
	if (recursive ~= false) then
		for _, f in ipairs(folders) do
			rp.include_dir(dir .. '/' .. f)
		end
	end
end

GM.Name 	= 'DarkRP'

plib.IncludeSV 'darkrp/gamemode/db.lua'

plib.IncludeSH 'darkrp/gamemode/cfg/cfg.lua'
plib.IncludeSH 'darkrp/gamemode/cfg/colors.lua'
--rp.include_dir 'darkrp/gamemode/core/player/gangs'
rp.include_dir 'darkrp/gamemode/util'

rp.include_dir('darkrp/gamemode/core', false)
rp.include_dir 'darkrp/gamemode/core/sandbox'
rp.include_dir('darkrp/gamemode/core/chat', false)
rp.include_dir 'darkrp/gamemode/core/player'
//rp.include_dir 'darkrp/gamemode/core/credits'
rp.include_dir 'darkrp/gamemode/core/ui'
rp.include_dir('darkrp/gamemode/core/prop_protect', false)
//rp.include_dir 'darkrp/gamemode/core/cosmetics'
rp.include_dir('darkrp/gamemode/core/makethings', false)
rp.include_dir('darkrp/gamemode/core/commands', false)
rp.include_dir('darkrp/gamemode/core/smallscripts', false)
//rp.include_dir('darkrp/gamemode/core/cop_stats', false) // new
rp.include_dir('darkrp/gamemode/core/hud', false)

//rp.include_dir 'darkrp/gamemode/core/somemodules'

plib.IncludeSH 'darkrp/gamemode/cfg/jobs.lua'

-- plib.IncludeSH('darkrp/gamemode/cfg/doors/'.. game.GetMap() .. '.lua')

plib.IncludeSH 'darkrp/gamemode/cfg/entities.lua'

rp.include_dir('darkrp/gamemode/core/doors', false)
rp.include_dir 'darkrp/gamemode/core/somemodules'

--plib.IncludeSH 'darkrp/gamemode/cfg/terms.lua'
plib.IncludeSV 'darkrp/gamemode/cfg/limits.lua'

-- local _, dir = file.Find( "darkrp/gamemode/core/somemodules/*", "LUA" )
-- for k,v in ipairs(dir) do
--     for _, f in ipairs( file.Find( "darkrp/gamemode/core/somemodules/" .. v .. "/*_sh.lua", "LUA" ) ) do
--         if CLIENT then
--             include( "darkrp/gamemode/core/somemodules/" .. v .. "/" .. f )
--         else
--             AddCSLuaFile( "darkrp/gamemode/core/somemodules/" .. v .. "/" .. f )
--             include( "darkrp/gamemode/core/somemodules/" .. v .. "/" .. f )
--         end
--     end
--
--     for _, f in ipairs( file.Find( "darkrp/gamemode/core/somemodules/" .. v .. "/*_cl.lua", "LUA" ) ) do
--         if CLIENT then
--             include( "darkrp/gamemode/core/somemodules/" .. v .. "/" .. f )
--         else
--             AddCSLuaFile( "darkrp/gamemode/core/somemodules/" .. v .. "/" .. f )
--         end
--     end
--     for _, f in ipairs( file.Find( "darkrp/gamemode/core/somemodules/" .. v .. "/*_sv.lua", "LUA" ) ) do
--         if SERVER then
--             include( "darkrp/gamemode/core/somemodules/" .. v .. "/" .. f )
--         end
--     end
-- end

function PLAYER:IsSuperAdmin()
    return table.HasValue({'superadmin', 'founder'}, self:GetUserGroup())
end

local function RemoveSandboxTabs()
        local AccsesGroup = {"superadmin"}
        local tabstoremove = {
                language.GetPhrase("spawnmenu.content_tab"),
                language.GetPhrase("spawnmenu.category.npcs"),
                language.GetPhrase("spawnmenu.category.entities"),
                language.GetPhrase("spawnmenu.category.weapons"),
                language.GetPhrase("spawnmenu.category.vehicles"),
                language.GetPhrase("spawnmenu.category.postprocess"),
                language.GetPhrase("spawnmenu.category.dupes"),
                language.GetPhrase("spawnmenu.category.saves"),
                language.GetPhrase("simfphys")
        }

        if !table.HasValue(AccsesGroup, LocalPlayer():GetUserGroup()) then
            for k, v in pairs(g_SpawnMenu.CreateMenu.Items) do
                if table.HasValue(tabstoremove, v.Tab:GetText()) then
                    g_SpawnMenu.CreateMenu:CloseTab(v.Tab, true)
                    RemoveSandboxTabs()
                end
            end
        end
    end

hook.Add("SpawnMenuOpen", "blockmenutabs", RemoveSandboxTabs)


local list = {}

local function LoadList()
    list = {
        {
            {
                name = "Сдаться",
                anim = UAnim.ANIMATION_SURRENDER,
                category = "Военные",
            },
            {
                name = "Отдать честь",
                anim = UAnim.ANIMATION_SALUTE,
                category = "Военные",
            },
            {
                name = "Дэб",
                anim = UAnim.ANIMATION_DAB,
                category = "Вспомогательные",
            },
            {
                name = "Руки за спину",
                anim = UAnim.ANIMATION_CROSSARMS,
                category = "Общие",
            },
            {
                name = "Скрестить руки",
                anim = UAnim.ANIMATION_CROSSARMSLOW,
                category = "Общие",
            },
            {
                name = "Осмотр",
                anim = UAnim.ANIMATION_LOOKUP,
                category = "Общие",
            },
            {
                name = "Показать пальцем",
                anim = UAnim.ANIMATION_POINT,
                --time = 3,
                category = "Общие",
            },
            {
                name = "Поднять руку",
                anim = UAnim.ANIMATION_HIGHFIVE,
                category = "Военные",
            }

        },
        {
            {
                act = "taunt_dance_base",
                name = "Танец",
                console = "dance",
                icon = "icon16/tag_red.png",
                category = "Танцы",
            },
            {
                act = "taunt_muscle_base",
                name = "Распутный танец",
                console = "muscle",
                icon = "icon16/tag_red.png",
                category = "Танцы",
            },
            {
                act = "taunt_robot_base",
                name = "Танец робота",
                console = "robot",
                icon = "icon16/tag_red.png",
                category = "Танцы",
            }
        },
        {
            {
                act = "gesture_wave_original",
                name = "Помахать",
                console = "wave",
                icon = "icon16/tag_orange.png",
                category = "Вспомогательные",
            },
            {
                act = "gesture_bow_original",
                name = "Поклон",
                console = "bow",
                icon = "icon16/tag_orange.png",
                category = "Вспомогательные",
            },
            {
                act = "gesture_becon_original",
                name = "Позвать",
                console = "becon",
                icon = "icon16/tag_orange.png",
                category = "Вспомогательные",
            }
        },
        {
            {
                act = "taunt_zombie_original",
                name = "Имитация зомби",
                console = "zombie",
                icon = "icon16/tag_yellow.png",
                category = "Вспомогательные",
            },
            {
                act = "taunt_laugh_base",
                name = "Смех",
                console = "laugh",
                icon = "icon16/tag_yellow.png",
                category = "Общие",
            },
            {
                act = "taunt_persistence_base",
                name = "Лев",
                console = "pers",
                icon = "icon16/tag_yellow.png",
                category = "Вспомогательные",
            },
            {
                act = "taunt_cheer_base",
                name = "Радость",
                console = "cheer",
                icon = "icon16/tag_yellow.png",
                category = "Вспомогательные",
            }
        },
        {
            {
                act = "gesture_agree_original",
                name = "Согласен",
                console = "agree",
                icon = "icon16/tag_green.png",
                category = "Общие",
            },
            {
                act = "gesture_disagree_original",
                name = "Не согласен",
                console = "disagree",
                icon = "icon16/tag_green.png",
                category = "Общие",
            }
        },
        {
            {
                act = "gesture_signal_halt_original",
                name = "Остановиться",
                console = "halt",
                icon = "icon16/tag_purple.png",
                category = "Военные",
            },
            {
                act = "gesture_signal_group_original",
                name = "Сгруппироваться",
                console = "group",
                icon = "icon16/tag_purple.png",
                category = "Военные",
            },
            {
                act = "gesture_signal_forward_original",
                name = "Вперёд",
                console = "forward",
                icon = "icon16/tag_purple.png",
                category = "Военные",
            }
        }
    }
end

if UAnim then
    LoadList()
end

hook.Add("UAnim.Initialed", "LoadTaunts", LoadList)

if SERVER then
    local function ResetAnim(ply)
        if not IsValid(ply) then return end
        if not ply.Taunted then return end

        if timer.Exists("taunt_" .. tostring(ply)) then
            timer.Destroy("taunt_" .. tostring(ply))
        end

        if ply.LuaAnim then
            ply:ResetBoneAnims()
            --ply:SetNetVar("IgnoreIsTalking", nil)
            ply.LuaAnim = nil
            ply.AnimLocked = nil
        end

        ply.LuaAnim = nil
        ply.AnimLocked = nil
        ply.Taunted = nil
    end

    netstream.Hook("SendTaunt", function(ply, cur, ang, time, num, anim_name)
        if not ply:Alive() then return end
        if ply.Taunted or ply.animationIndex or ply.LuaAnim then return end
        if (ply.AnimLocked or 0) > CurTime() then return end
        -- if ply:isRestrained() then return end
        -- if ply:isEscorting() then return end
        -- if ply:isEscorted() then return end
        --if IsValid(ply:GetUseEntity()) then return end -- Не знаю, почему, но ломаются предметы, какие держишь
        local can, reason = hook.Run("PlayerCanTaunt", ply, anim_name)

        if can == false then
            DarkRP.notify(ply, 0, 4, reason or "Вы не можете использовать эту анимацию")

            return
        end

        -- local keys = ply:GetWeapon("keys")
        -- if IsValid(keys) then
        --  ply:SetActiveWeapon(keys)
        -- end
        local keys = ply:HasWeapon("keys")
        if keys then
            ply:SelectWeapon("keys")
        end
        time = time - 1

        if cur == 1 then
            ply.AnimLocked = CurTime() + time
            ply.Taunted = true
            ply:SetEyeAngles(ang)

            timer.Create("taunt_" .. tostring(ply), time, 1, function()
                ResetAnim(ply)
            end)
        elseif cur == 2 then
            if not num or not list[1][num] then return end
            ply.AnimLocked = nil
            ply.Taunted = true
            ply:executeAnimation(list[1][num].anim)
            ply.LuaAnim = true
            --ply:SetNetVar("IgnoreIsTalking", true)

            if time then
                timer.Create("taunt_" .. tostring(ply), time, 1, function()
                    ResetAnim(ply)
                end)
            end
        end
    end)

    netstream.Hook("StopTaunt", ResetAnim)

    hook.Add("OnHandcuffed", "LuaAnim", function(ply, target)
        ResetAnim(target)

        if ply:GetActiveWeapon() and ply:GetActiveWeapon():GetClass() ~= "weapon_handcuffed" then
            if ply:HasWeapon('weapon_handcuffed') then ply:SelectWeapon("weapon_handcuffed") end
        end
    end)
end

hook.Add("PlayerShouldTaunt", "DrawTaunt", function(ply)
    if ply.LuaAnim then return false end

    return (ply.AnimLocked or 0) > CurTime()
end)

hook.Add("PlayerSwitchWeapon", "NoBagouse", function(ply)
    if CurTime() > (ply.AnimLocked or 0) and not ply.LuaAnim then return end

    return true
end)

function GetTauntList()
    return list
end

if SERVER then return end

hook.Add("CreateMove", "DisableRoaming", function(cmd)
    if (LocalPlayer().AnimLocked or 0) > CurTime() then
        if (LocalPlayer().TauntCamera) then return LocalPlayer().TauntCamera:CreateMove(cmd, LocalPlayer(), ((LocalPlayer().AnimLocked or 0) > CurTime())) end
    end
end)

hook.Add("CalcView", "DisableRoaming", function(ply, pos, ang, fov)
    if (ply.TauntCamera) then
        local view = {
            origin = pos,
            angles = ang,
            drawviewer = true
        }

        return ply.TauntCamera:CalcView(view, ply, ((ply.AnimLocked or 0) > CurTime()))
    end
end)

local binds = {
    ["+moveright"] = true,
    ["+moveleft"] = true,
    ["+forward"] = true,
    ["+back"] = true,
    ["+duck"] = true,
    ["+jump"] = true,
    ["+use"] = true
}

hook.Add("PlayerBindPress", "DisableRoaming", function(pl, bind)
    if not LocalPlayer().LuaAnim then return end
    if not binds[bind] then return end
    LocalPlayer().TauntCamera = nil
    LocalPlayer().LuaAnim = nil
    LocalPlayer().AnimLocked = 0
    netstream.Start("StopTaunt")

    return true
end)

hook.Add("PlayerSwitchWeapon", "DisableRoaming", function(pl)
    if (LocalPlayer().AnimLocked or 0) > CurTime() then return true end -- Остановить таунт нельзя
    if not LocalPlayer().LuaAnim then return end
    LocalPlayer().TauntCamera = nil
    LocalPlayer().LuaAnim = nil
    LocalPlayer().AnimLocked = 0
    netstream.Start("StopTaunt")

    return true
end)

function GonzoTauntCamera()
    local CAM = {}
    CAM.WasOn = false
    CAM.CustomAngles = LocalPlayer():GetAngles()
    CAM.PlayerLockAngles = nil
    CAM.InLerp = 0
    CAM.OutLerp = 1
    --
    -- Draw the local player if we're active in any way
    --
    CAM.ShouldDrawLocalPlayer = function(self, ply, on) return on or self.OutLerp < 1 end

    --
    -- Implements the third person, rotation view (with lerping in/out)
    --
    CAM.CalcView = function(self, view, ply, on)
        if (not ply:Alive() or not IsValid(ply:GetViewEntity()) or ply:GetViewEntity() ~= ply) then return end

        if (self.WasOn ~= on) then
            if (on) then
                self.InLerp = 0
            end

            if (not on) then
                self.OutLerp = 0
            end

            self.WasOn = on
        end

        if (not on and self.OutLerp >= 1) then
            self.CustomAngles = view.angles * 1
            self.PlayerLockAngles = nil
            self.InLerp = 0

            return
        end

        if (self.PlayerLockAngles == nil) then return end
        --
        -- Simple 3rd person camera
        --
        local TargetOrigin = view.origin - self.CustomAngles:Forward() * 100

        local tr = util.TraceHull({
            start = view.origin,
            endpos = TargetOrigin,
            mask = MASK_SHOT,
            filter = player.GetAll(),
            mins = Vector(-8, -8, -8),
            maxs = Vector(8, 8, 8)
        })

        TargetOrigin = tr.HitPos + tr.HitNormal

        if (self.InLerp < 1) then
            self.InLerp = self.InLerp + FrameTime() * 5.0
            view.origin = LerpVector(self.InLerp, view.origin, TargetOrigin)
            view.angles = LerpAngle(self.InLerp, self.PlayerLockAngles, self.CustomAngles)

            return view
        end

        if (self.OutLerp < 1) then
            self.OutLerp = self.OutLerp + FrameTime() * 3.0
            view.origin = LerpVector(1 - self.OutLerp, view.origin, TargetOrigin)
            view.angles = LerpAngle(1 - self.OutLerp, self.PlayerLockAngles, self.CustomAngles)

            return view
        end

        view.angles = self.CustomAngles * 1
        view.origin = TargetOrigin

        return view
    end

    --
    -- Freezes the player in position and uses the input from the user command to
    -- rotate the custom third person camera
    --
    CAM.CreateMove = function(self, cmd, ply, on)
        if (not ply:Alive()) then
            on = false
        end

        if (not on) then return end

        if (self.PlayerLockAngles == nil) then
            self.PlayerLockAngles = self.CustomAngles * 1
        end

        --
        -- Rotate our view
        --
        self.CustomAngles.pitch = self.CustomAngles.pitch + cmd:GetMouseY() * 0.01
        self.CustomAngles.yaw = self.CustomAngles.yaw - cmd:GetMouseX() * 0.01
        --
        -- Lock the player's controls and angles
        --
        cmd:SetViewAngles(self.PlayerLockAngles)
        cmd:ClearButtons()
        cmd:ClearMovement()

        return true
    end

    return CAM
end

function StartTaunt(an, num)
    if (LocalPlayer().AnimLocked or 0) > CurTime() or LocalPlayer().LuaAnim then return end
    --if IsValid(LocalPlayer():GetUseEntity()) then return end
    local can, reason = hook.Run("PlayerCanTaunt", LocalPlayer(), an.name)
    if can == false then
        notification.AddLegacy( reason or "Вы не можете использовать эту анимацию", NOTIFY_ERROR, 4 )

        return
    end
    local cur = an.act and 1 or 2
    local tim, ang = (an.time or 600), EyeAngles()

    if cur == 1 then
        RunConsoleCommand("act2", an.console)
        local i = LocalPlayer():LookupSequence(an.act)
        tim = LocalPlayer():SequenceDuration(i)
    else
        LocalPlayer().LuaAnim = true
    end

    LocalPlayer().AnimLocked = CurTime() + tim
    LocalPlayer().TauntCamera = GonzoTauntCamera()
    netstream.Start("SendTaunt", cur, ang, tim, num, an.name)

    timer.Create("TauntCamera", tim, 1, function()
        LocalPlayer().TauntCamera = nil
    end)
end

local list = {}
--list[""] = function(ply) return ply:isBandit() or ply:isCP() end -- Если Бандит или Альянс - не может
list["Радость"] = function(ply) return ply:isCP() or ply:Team() == TEAM_GMAN end -- Если Альянс - не может
list["Лев"] = function(ply) return ply:isCP() or ply:Team() == TEAM_GMAN  end
list["Смех"] = function(ply) return ply:isCP() end
list["Имитация зомби"] = function(ply) return ply:isCP() or ply:Team() == TEAM_GMAN end
list["Танец робота"] = function(ply) return ply:isCP() or ply:Team() == TEAM_GMAN end
list["Распутный танец"] = function(ply) return ply:isCP() or ply:Team() == TEAM_GMAN end
list["Танец"] = function(ply) return ply:isCP() or ply:Team() == TEAM_GMAN end
list["Дэб"] = function(ply) return ply:isCP() or ply:Team() == TEAM_GMAN or not ply:CheckGroup('premium') end
-----------------------
list["Сдаться"] = function(ply) return ply:Team() == TEAM_GMAN end
list["Салютовать"] = function(ply) return ply:Team() == TEAM_GMAN end
list["Поднять руку"] = function(ply) return false end



local function LoadCFG(ply, name)
    if not list[name] then return end
    local should = list[name](ply)
    if should then
        return false
    end
end

hook.Add("PlayerCanTaunt", "TauntConfig", LoadCFG)

hook.Add("PlayerCanTaunt", "_TauntCheckSit", function(ply, anim)
    local veh = ply:GetVehicle()
    if IsValid(veh) then
        return false, "Вы не можете использовать анимации сидя."
    end
end)

hook.Remove("PlayerTick", "TickWidgets")
hook.Remove("PlayerTick","TickWidgets")
hook.Remove("Think", "CheckSchedules")
hook.Remove("LoadGModSave", "LoadGModSave")
timer.Destroy("HostnameThink")
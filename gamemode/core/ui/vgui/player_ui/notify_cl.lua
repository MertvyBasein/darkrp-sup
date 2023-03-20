net.Receive("rp.notify", function()
    notification.AddLegacy(net.ReadString(), net.ReadUInt(8), net.ReadUInt(8))
end)

cvar.Register 'notification_sound'
    :SetDefault(true, true)
    :AddMetadata('Catagory', 'Звуки')
    :AddMetadata('Menu', 'Звук уведомлений')
    
notification = {}
--[[ local notifyTypes = {
    [NOTIFY_GENERIC] = {
        Color = Color(255, 155, 55),
        Icon = Material("materials/flamerp/notify/info.png", "smooth")
    },
    [NOTIFY_ERROR] = {
        Color = Color(225, 0, 0),
        Icon = Material("materials/flamerp/notify/error.png", "smooth")
    },
    [NOTIFY_UNDO] = {
        Color = Color(255, 255, 0),
        Icon = Material("materials/flamerp/notify/undo.png", "smooth")
    },
    [NOTIFY_SUCCESS] = {
        Color = Color(0, 180, 50),
        Icon = Material("materials/flamerp/notify/info.png", "smooth")
    },
    [NOTIFY_HINT] = {
        Color = Color(0, 0, 0),
        Icon = Material("materials/flamerp/notify/hint.png", "smooth")
    }
}--]]
NOTIFY_GENERIC = 0
NOTIFY_ERROR = 1
NOTIFY_UNDO = 2
NOTIFY_SUCCESS = 3
NOTIFY_HINT = 4
NOTIFY_CLEANUP = NOTIFY_UNDO

local notifyTypes = {
    [NOTIFY_GENERIC] = {
        Color = Color(33, 150, 240),
        Icon = Material("icon16/information.png", "smooth")
    },
    [NOTIFY_ERROR] = {
        Color = Color(244, 67, 54),
        Icon = Material("icon16/cancel.png", "smooth")
    },
    [NOTIFY_UNDO] = {
        Color = Color(94, 122, 136),
        Icon = Material("icon16/wrench.png", "smooth")
    },
    [NOTIFY_SUCCESS] = {
        Color = Color(66, 115, 54),
        Icon = Material("icon16/tick.png", "smooth")
    },
    [NOTIFY_HINT] = {
        Color = Color(142, 103, 56),
        Icon = Material("icon16/zoom.png", "smooth")
    }
}

for k, v in pairs(notifyTypes) do
    v.BarColor = v.Color:Copy()
    v.BarColor.a = 50
end

Notices = Notices or {}

for k, v in pairs(Notices) do
    if IsValid(v) then
        v:Remove()
    end

    Notices[k] = nil
end

function notification.AddProgress(uid, text)
end

function notification.Kill(uid)
    if IsValid(Notices[uid]) then
        Notices[uid].StartTime = SysTime()
        Notices[uid].Length = 0.8
    end
end

function notification.AddLegacy(text, type, length)
    type = math.Clamp(type or 0, 0, 4)
    text = tostring(text):Trim()

    if (text:sub(1, 1) == "#") then
        text = language.GetPhrase(text)
    end

    local parent

    if GetOverlayPanel then
        parent = GetOverlayPanel()
    end

    local panel = vgui.Create("NoticePanel", parent)
    panel.NotifyType = type
    panel.StartTime = SysTime()
    panel.Length = length
    panel.VelX = 0
    panel.VelY = 0
    panel.fx = ScrW() + 200
    panel.fy = ScrH()

    panel:SetText(text)
    panel:SetPos(panel.fx, panel.fy)
    panel:SetMouseInputEnabled(false)
    table.insert(Notices, panel)
    MsgC(Color(255, 255, 255), "[", notifyTypes[type].Color, "Notification", Color(255, 255, 255), "] ", Color(255, 255, 255), text .. "\n")

    if (cvar.GetValue("notification_sound")) then
        surface.PlaySound("ambient/water/drip4.wav")
    end
end

-- This is ugly because it"s ripped straight from the old notice system
local function UpdateNotice(number, panel, count)
    local x = panel.fx
    local y = panel.fy
    local w = panel:GetWide() + 16
    local h = panel:GetTall() + 16
    local ideal_y = ScrH() - (count - number) * (h - 12) - 150
    local ideal_x = ScrW() - w - 20
    local timeleft = panel.StartTime - (SysTime() - panel.Length)

    if (timeleft < 0.2) then
        ideal_x = ideal_x + w * 2
    end

    local spd = FrameTime() * 15
    y = y + panel.VelY * spd
    x = x + panel.VelX * spd
    local dist = ideal_y - y
    panel.VelY = panel.VelY + dist * spd * 1

    if (math.abs(dist) < 2 and math.abs(panel.VelY) < 0.1) then
        panel.VelY = 0
    end

    local dist = ideal_x - x
    panel.VelX = panel.VelX + dist * spd * 1

    if (math.abs(dist) < 2 and math.abs(panel.VelX) < 0.1) then
        panel.VelX = 0
    end

    panel.VelX = panel.VelX * (0.9 - FrameTime() * 8)
    panel.VelY = panel.VelY * (0.9 - FrameTime() * 8)
    panel.fx = x
    panel.fy = y
    panel:SetPos(panel.fx, panel.fy)
end

hook.Add("Think", "NotificationThink", function()
    for k, v in ipairs(Notices) do
        UpdateNotice(k, v, #Notices)

        if IsValid(v) and v:KillSelf() then
            table.remove(Notices, k)
        end
    end
end)

local PANEL = {}

function PANEL:Init()
    self.NotifyType = NOTIFY_GENERIC
    self.Label = vgui.Create("DLabel", self)
    self.Label:SetFont(GetFont(9))
    self.Label:SetTextColor(Color(255, 255, 255))
    self.Label:SetExpensiveShadow(1, Color(0, 0, 0))
    self.Label:SetPos(30, 4)
end

function PANEL:SetText(txt)
    self.Label:SetText(txt)
    self:SizeToContents()
end

function PANEL:SizeToContents()
    self.Label:SizeToContents()
    self:SetWidth(self.Label:GetWide() + 42)
    self:SetHeight(27)
    self:InvalidateLayout()
end

function PANEL:KillSelf()
    if (self.StartTime + self.Length < SysTime()) then
        self:Remove()

        return true
    end

    return false
end

function PANEL:Paint(w, h)
    if (hook.Call("HUDShouldDraw", GAMEMODE, "Notifications") == false) then return end
    local timeleft = self.StartTime - (SysTime() - self.Length)
    local inf = notifyTypes[self.NotifyType]
    framework(self, 5)
    DrawBox(0, 0, w, h, Color(0,0,0,150), Color(0,0,0,0))
    DrawBox(w-4, 0, 4, h, inf.Color, Color(0,0,0,0))
    --DrawBox(30, 0, (w - 30) * (timeleft / self.Length), h, inf.BarColor, inf.BarColor)
    surface.SetMaterial(inf.Icon)
    surface.SetDrawColor(255, 255, 255)
    surface.DrawTexturedRect(5, 4, 18, 18)
end

vgui.Register("NoticePanel", PANEL, "DPanel")

concommand.Add("ntest", function()
    for i = 0, 4 do
        notification.AddLegacy(("This is a test notification."):rep(math.random(1, 3)), i, 5)
    end
end)

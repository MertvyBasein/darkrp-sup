plib.IncludeSH 'shared.lua'

local color_white = ui.col.White:Copy()
local color_black = ui.col.Black:Copy()

local complex_off = Vector(0, 0, 9)

local ang = Angle(0, 90, 90)

texture.Create('idCard'):SetFormat('png'):Download('https://img.icons8.com/ios-filled/512/FFFFFF/biometric-passport.png')

function ENT:Draw()
	self:DrawModel()

	local bone = self:LookupBone('ValveBiped.Bip01_Head1')
	pos = self:GetBonePosition(bone) + complex_off

	ang.y = (LocalPlayer():EyeAngles().y - 90)

	local inView, dist = self:InDistance(150000)

	if (not inView) then return end

	local alpha = 255 - (dist/590)
	color_white.a = alpha
	color_black.a = alpha

	local x = math.sin(CurTime() * math.pi) * 30

	cam.Start3D2D(pos, ang, 0.05)
		draw.NPCTitle("Джордж", "Нажмите [E] для взаимодействия", 0, -125, texture.Get('idCard') or Material('icon16/car.png'))
	cam.End3D2D()
    --self.TraceInfo = "<font=" .. GetFont(10) .. "><color=255,255,255>Джордж</color></font>\n<font=" .. GetFont(8) .. ">[E] для действия</font>"
end

local function changeNameNextStep()
    if IsValid(NameFrame) then NameFrame:Remove() end
    NameFrame = vgui.Create("XPFrame")
    NameFrame:SetTitle("Изменение имени // Дикий запад")
    NameFrame:SetNoRounded(true)
    NameFrame:SetSize(370, 150)
    NameFrame:Center()
    NameFrame.PaintOver = function(self, w, h)
        local y_spacer = 35
        frametext('Введите ваше новое имя и фамилию', 'xpgui_small', w/2, y_spacer, Color(255,255,255), 1, 0, Color(0,0,0,100))
    end

    local name = vgui.Create('XPTextEntry', NameFrame)
    surface.SetFont('xpgui_small')
    local x, y = surface.GetTextSize('Введите ваше новое имя и фамилию')
    name:DockMargin(8, y+5, 8, 0)
    name:SetPlaceholderText('Имя')
    name:Dock(TOP)

    local surname = vgui.Create('XPTextEntry', NameFrame)
    surname:DockMargin(8, 4, 8, 0)
    surname:SetPlaceholderText('Фамилия')
    surname:Dock(TOP)

    local change_nameconfirm = vgui.Create('XPButton', NameFrame)
    change_nameconfirm:Dock(TOP)
    change_nameconfirm:DockMargin(8, 4, 8, 0)
    change_nameconfirm:SetText('Поменять имя')
    change_nameconfirm.DoClick = function(self, w, h)
        if name:GetText() == '' then
            notification.AddLegacy('Введите имя.', NOTIFY_ERROR, 3)
            return
        elseif surname:GetText() == '' then
            notification.AddLegacy('Введите фамилию.', NOTIFY_ERROR, 3)
            return
        end
        local fN = name:GetText() .. ' ' .. surname:GetText()
        Derma_StringRequest(
            "Подтверждение", 
            "Подтвердите смену имени и фамилии за "..rp.FormatMoney(rp.cfg.ChangeNamePrice).." введя их (" .. fN .. ')',
            "",
            function(text)
                if text == fN then
                    if IsValid(NameFrame) then NameFrame:Remove() end
                    cmd.Run( 'rpname', fN )
                else
                    notification.AddLegacy('Имя и фамилия не совпадают, смена отменена.', NOTIFY_ERROR, 3)
                end
            end)
    end
end

local function changeNameMenu()
    if IsValid(NameFrame) then NameFrame:Remove() end
    NameFrame = vgui.Create("XPFrame")
    NameFrame:SetTitle("Изменение имени // Дикий запад")
    NameFrame:SetNoRounded(true)
    NameFrame:SetSize(370, 145)
    NameFrame:Center()
    NameFrame.PaintOver = function(self, w, h)
        local y_spacer = 35
        local x, y = frametext('Пссс... я тут могу поменять имя в твоем паспорте', 'xpgui_small', w/2, y_spacer, Color(255,255,255), 1, 0, Color(0,0,0,100))
        y_spacer = y_spacer + y
        local x, y = frametext('Это все легально... почти...', 'xpgui_small', w/2, y_spacer, Color(255,255,255), 1, 0, Color(0,0,0,100))
        y_spacer = y_spacer + y
        local x, y = frametext('Но это будет тебе стоить всегo ' .. rp.FormatMoney(rp.cfg.ChangeNamePrice), 'xpgui_small', w/2, y_spacer, Color(255,255,255), 1, 0, Color(0,0,0,100))
    end

    local next_step = vgui.Create('XPButton', NameFrame)
    next_step:SetSize(NameFrame:GetWide()-10, 35)
    next_step:SetPos(5, NameFrame:GetTall()-40)
    next_step:SetText('Поменять имя')
    next_step.DoClick = function(self, w, h)
        changeNameNextStep()
    end
end

net.Receive('MetaHub.CNameMenu', changeNameMenu)
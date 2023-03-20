
local function ChangeLaws()
	if (not LocalPlayer():IsMayor()) then return end
	local Laws = nw.GetGlobal 'TheLaws' or ''

	local fr = ui.Create('ui_frame', function(self)
		self:SetSize(ScrW() * .2, ScrH() * .3)
		self:Center()
		self:SetTitle('Законы')
		self:MakePopup()
	end)

	local x, y = fr:GetDockPos()
	local e = ui.Create('DTextEntry', function(self, p)
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - 10, p:GetTall() - y - 65)
		self:SetMultiline(true)
		self:SetValue(Laws)
		self.OnTextChanged = function()
			Laws = self:GetValue()
		end
	end, fr)

	e = ui.Create('DButton', function(self, p)
		x, y = e:GetPos()
		y = y + e:GetTall() + 5
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - 10, 25)
		self:SetText('Сохранить')
		self.DoClick = function()
			if string.len(Laws) <= 3 then LocalPlayer():ChatPrint('Текст закона слишком короткий.') return end
			if #string.Wrap('DermaDefault', Laws, 325 - 10) >= 15 then LocalPlayer():ChatPrint('Доска законов переполнена.') return end
			net.Start('rp.SendLaws')
				net.WriteString(string.Trim(Laws))
			net.SendToServer()
		end
	end, fr)

	e = ui.Create('DButton', function(self, p)
		x, y = e:GetPos()
		y = y + e:GetTall() + 5
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - 10, 25)
		self:SetText('Сбросить законы')
		self.DoClick = function()
			LocalPlayer():ConCommand('say /resetlaws')
			p:Close()
		end
	end, fr)
end
concommand.Add('LawEditor', ChangeLaws)

surface.CreateFont("rp.LockDown", {
    font = "Roboto",
    size = ScreenScale(8.02),
    weight = 1000,
    extended = true
})

local function FormatTime(time)
    local s = time % 60
    time = math.floor(time / 60)
    local m = time % 60
    time = math.floor(time / 60)
    local h = time % 24
    time = math.floor(time / 24)
    local d = time % 7

    if d > 1 then
        return string.format("%iд %02iч %02iм", d, h, m)
    elseif d < 1 and h > 1 then
        return string.format("%02iч %02iм", h, m)
    elseif h < 1 and m > 1 and s > 0 then
        return string.format("%02iм %02iс", m, s)
    elseif h < 1 and m > 1 then
        return string.format("%02iм 00c", m)
    end
end

net.Receive("OpenLockDownMenu", function()
    local Frame = vgui.Create("XPFrame")
    Frame:SetSize(600, 250)
    Frame:Center()
    Frame:SetTitle("Управление комендантским часом")
    --Frame:SetDraggable(false)
  --  Frame:ShowCloseButton(false)
    Frame:MakePopup()
    Frame:SetAlpha(0)
    Frame:AlphaTo(255, 0.2)
    local tallbal = ScrH() * .4 * .067

    --Frame.Paint = function(self, w, h)
    --    framework(self, 5)
    --    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
    --    draw.RoundedBox(0, 0, 0, w, tallbal, Color(0, 0, 0, 200))
    --    draw.RoundedBox(0, 0, h - tallbal, w, tallbal, Color(0, 0, 0, 200))
    --    frametext("Управление комендантским часом", GetFont(15), w * .5, tallbal * .5, Color(255, 255, 255), 1, 1)
    --end

   -- local main_hide = vgui.Create("XPButton", Frame)
    --main_hide:SetSize(tallbal - 4, tallbal - 4)
    --main_hide:SetPos(Frame:GetWide() - 26, 2)
    --main_hide:SetText("")
--
    --main_hide.Paint = function(this, w, h)
    --    if (this.Depressed or this.m_bSelected) then
    --        draw.RoundedBox(0, 0, 0, w, h, Color(255, 155, 55, 150))
    --    elseif (this.Hovered) then
    --        draw.RoundedBox(0, 0, 0, w, h, Color(255, 155, 55, 75))
    --    else
    --        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
    --    end
--
    --    frametext("X", GetFont(15), w * .5, h * .5, Color(255, 255, 255), 1, 1)
    --end
--
    --main_hide.DoClick = function(self)
    --    surface.PlaySound("garrysmod/ui_click.wav")
--
    --    Frame:AlphaTo(0, 0.2, 0, function()
    --        if IsValid(Frame) then
    --            Frame:Remove()
    --        end
    --    end)
    --end

    surface.SetFont("rp.LockDown")
    local text = "Текущее состояние комендантского часа: "
    local width, height = surface.GetTextSize(text)
    surface.SetFont("rp.LockDown")
    local text2 = "Время до автоматического отключения: "
    local width2, height2 = surface.GetTextSize(text2)
    local reason
    local upper_panel = vgui.Create("DPanel", Frame)
    upper_panel:Dock(TOP)
    upper_panel:DockMargin(-4, -4, -4, 0)
    upper_panel:SetTall(80)

    upper_panel.Paint = function(self, w, h)
        draw.WordBox(0, 6, 4, text, "rp.LockDown", Color(0, 0, 0, 0), Color(255, 255, 255, 215))

        if nw.GetGlobal("lockdown") then
            draw.WordBox(0, 6 + width, 4, "Запущен", "rp.LockDown", Color(0, 0, 0, 0), Color(0, 255, 0, 215))
            draw.WordBox(0, 6, 25, "Причина комендантского часа: " .. nw.GetGlobal("lockdown_reason"), "rp.LockDown", Color(0, 0, 0, 0), Color(255, 255, 255, 215))
            draw.WordBox(0, 6, 45, "Время до автоматического отключения: ", "rp.LockDown", Color(0, 0, 0, 0), Color(255, 255, 255, 215))
            draw.WordBox(0, 6 + width2, 45, FormatTime(math.floor(nw.GetGlobal("lockdown_left") - CurTime())), "rp.LockDown", Color(0, 0, 0, 0), Color(255, 255, 255, 215))
        else
            draw.WordBox(0, 6 + width, 4, "Отключен", "rp.LockDown", Color(0, 0, 0, 0), Color(255, 0, 0, 215))
            draw.WordBox(0, 6, 25, "Причина комендантского часа: КЧ отсутствует!", "rp.LockDown", Color(0, 0, 0, 0), Color(255, 255, 255, 215))
        end
    end

    local lower_panel = vgui.Create("DPanel", Frame)
    lower_panel:Dock(TOP)
    lower_panel:SetTall(200 - 56)
    lower_panel:DockMargin(-4, 0, -4, 0)
    lower_panel.Paint = function(self, w, h) end

    local pb1 = lower_panel:Add("XPButton")
    pb1:Dock(BOTTOM)
    pb1:SetTall(70)
    pb1:DockMargin(200, 15, 200, 15)
    pb1:SetText(nw.GetGlobal("lockdown") and "Отменить" or "Принять")

    pb1.Paint = function(this, w, h)
        if (this.Depressed or this.m_bSelected) then
            draw.RoundedBox(7, 0, 0, w, h, Color(152, 152, 152,135))
        elseif (this.Hovered) then
            draw.RoundedBox(7, 0, 0, w, h, Color(152, 152, 152, 35))
        end
        draw.RoundedBox(7, 0, 0, w, h, Color(152, 152, 152, 30))

       -- frametext(nw.GetGlobal("lockdown") and "Отменить комендантский час" or "Запустить комендантский час", "rp.LockDown", w * .5, h * .5, Color(255, 255, 255), 1, 1)
    end

    if not nw.GetGlobal("lockdown") then
        local DComboBox = vgui.Create("XPComboBox", lower_panel)
        DComboBox:SetSize(300, 25)
        DComboBox:SetPos(300 - 250 / 2, 0)
       -- DComboBox:SetSortItems(false)
        DComboBox:SetValue("Выберите причину комендантского часа")
   
        DComboBox:AddChoice("Военное положение")
		DComboBox:AddChoice("Геноцид евреев/криминальных лиц")
		DComboBox:AddChoice("Вывоз евреев/криминала и т.д в конц.лагерь")
		DComboBox:AddChoice("Проверка и обыск домов")

        DComboBox.OnSelect = function(panel, index, value)
            if value == "Военное положение" then
                reason = 1
            elseif value == "Геноцид евреев/криминальных лиц" then
                reason = 2
            elseif value == "Вывоз евреев/криминала и т.д в конц.лагерь" then
                reason = 3
            elseif value == "Проверка и обыск домов" then
            	reason = 4
            end
        end

        function Frame:Think()
            if DComboBox:GetValue() ~= "Выберите причину комендантского часа" then
                pb1:SetDisabled(false)
            else
                pb1:SetDisabled(true)
            end
        end
    end

    pb1.DoClick = function()
        surface.PlaySound("garrysmod/ui_click.wav")

        if nw.GetGlobal("lockdown") then
            net.Start("StopСurfew")
            net.SendToServer()
            Frame:AlphaTo(0, 0.1, 0)

            timer.Simple(0.1, function()
                Frame:Close()
            end)
        else
            net.Start("StartСurfew")
            net.WriteInt(tonumber(reason), 3)
            net.SendToServer()
            Frame:AlphaTo(0, 0.1, 0)

            timer.Simple(0.1, function()
                Frame:Close()
            end)
        end
    end

    

end)
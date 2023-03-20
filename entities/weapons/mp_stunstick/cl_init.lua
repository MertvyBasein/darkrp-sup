include("shared.lua")

function SWEP:Reload()
	if (self.nextup or 0) > CurTime() then return end
	self.nextup = CurTime() + 1
	if self:GetActivated() then
		return
	end
	if IsValid(main_terminal_menu) then main_terminal_menu:Remove() end

	main_terminal_menu = vgui.Create('eFrame')
	main_terminal_menu:SetSize(600,200)
	main_terminal_menu:Center()
	main_terminal_menu:MakePopup()
	main_terminal_menu:ShowCloseButton(false)
	main_terminal_menu.title = 'CMB.STUNSTICK'
	main_terminal_menu:SetDraggable(false)
    main_terminal_menu:ShowCloseButton(false)
    main_terminal_menu:SetAlpha(0)
    main_terminal_menu:AlphaTo(255, 0.2)

	-- local logol = vgui.Create("DImage",main_terminal_menu)
	-- logol:SetImage( "materials/union/logo.png" )
	-- logol:SetSize(36,36)
	-- logol:SetPos(0,0)

	-- local face = vgui.Create("DLabel",main_terminal_menu)
	-- face:SetText("CMB.STUNSTICK #" .. LocalPlayer():GetID())
	-- face:SetPos(logol:GetWide()*1.5,0)
	-- face:SizeToContents()
	-- face:SetColor(Color(255,255,255))

	local right, height = false, 40
	local w,h = 215, 45

	for num, tbl in pairs(self.Modes) do
		local x = right and main_terminal_menu:GetWide()/2+40 or main_terminal_menu:GetWide()/2 - 255
		local but = vgui.Create("DButton",main_terminal_menu)
		but:SetFont(GetFont(9))
		but:SetSize(w, h)
		but:SetText('')
		but.Paint = function(self, w, h)
    	    if (self.Depressed or self.m_bSelected) then
    	        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
    	    elseif (self.Hovered) then
    	        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 75))
    	    else
    	        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
    	    end
		
		    frametext(tbl.name, GetFont(9), w * .5, h * .5, Color(255, 255, 255), 1, 1)
		end
		but:SetPos(x, height) -- main_terminal_menu:GetWide()/2+40,80 / main_terminal_menu:GetWide()/2-overlook:GetWide()-40,160
		but.DoClick = function(self)
			netstream.Start("Stunstick.ChangeMode", num)
			if IsValid(main_terminal_menu) then main_terminal_menu:Remove() end
		end
		if right then
			height = height + 80
		end
		right = not right
	end
	return
end

local cur_power, damaged = 0, false

netstream.Hook("PainAndCrying", function(power)
	damaged = true
	cur_power = power
end)

function HUDDamage()
	if not LocalPlayer().DamagedByCP then return end
	cur_power = cur_power - 1
	if cur_power == 0 then
		damaged = false
	end
	draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(255, 255, 255, math.Clamp(cur_power, 0, 255)))
end

hook.Add("HUDPaint", "Stunstick.Pain", HUDDamage)

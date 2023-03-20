local esc = {}

local cache = {}
http.Fetch('https://modern-project.myarena.site/servers.json', function(b)
	local data = util.JSONToTable(b)
	cache = data.servers
end)

local function openServerList()
	if IsValid(escape) then escape:Remove() end
	
	escape = vgui.Create("Panel")
	escape:SetSize(ScrW(),ScrH())
	escape:MakePopup()
	escape:Center()
	escape.Paint = function(self, w, h)
		surface.DrawPanelBlur(self, 4)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,160))
	end

	local pnl = vgui.Create('Panel', escape)
	pnl:SetSize(300,50)
	pnl:SetPos(50, 50)
	pnl.Paint = function(self, w, h)
		draw.SimpleText("Список серверов", 'xpgui_huge', 0, 0, Color(255,255,255), 0, 0)
	end

	local scr = vgui.Create('XPScrollPanel', escape)
	scr:SetPos(50, 96)
	scr:SetSize(ScrW()-100, ScrH()-96-54)
	scr:InvalidateParent(true)
	scr:GetVBar():SetWide(0)

	local il = vgui.Create('DIconLayout', scr)
	il:Dock(FILL)
	il:SetSpaceX(24)
	il:SetSpaceY(24)

	for k,v in pairs(cache) do
		local el = vgui.Create('Panel', il)
		el:SetSize( (scr:GetWide()-48)/3, (scr:GetTall()-48)/3 )
		el.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,150))
			surface.SetMaterial( (surface.GetWeb(v.icon) or Material('error')) )
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, 0, w/4, h)

			local x, _y = draw.SimpleText(v.name, 'xpgui_medium', (w+w/4)/2, 6, Color(255,255,255),1)

			local wrap = string.Split(rp.util.textWrap(v.description, 'xpgui_small', w-w/4-8), '\n')
			local y = _y+6
			for k,v in pairs(wrap) do
				local xx, yy = draw.SimpleText(v, 'xpgui_small', w/4+4, y, Color(255,255,255))
				y = y + yy
			end

			if !v.open then
				draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,220))
				draw.SimpleText('Технические работы!', 'xpgui_huge', (w+w/4)/2, h/2, Color(255,0,0),1,1)
			end
		end
		if v.open then
			local join = vgui.Create('XPButton', el)
			join:SetSize(el:GetWide()-(el:GetWide()/4)-8, 25)
			join:SetPos(el:GetWide()/4+4, el:GetTall()-30)
			join:SetText'Присоединиться'
			join.DoClick = function(self)
				permissions.AskToConnect( v.ip )
			end
		end

	end
end

function esc.openMenu()
	escape = vgui.Create("Panel")
	escape:SetSize(ScrW(),ScrH())
	escape:MakePopup()
	escape:Center()
	escape.Paint = function(self, w, h)
		surface.DrawPanelBlur(self, 4)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,160))
	end

	local buttons = {
		{
			Name = 'Выйти из игры',
			DoClick = function()
				RunConsoleCommand('gamemenucommand', 'quit')
			end
		},
		{
			Name = 'Отключиться',
			DoClick = function()
				RunConsoleCommand('gamemenucommand', 'Disconnect')
			end
		},
		{
			Name = 'Настройки',
			DoClick = function()
				escape:Remove()
				gui.ActivateGameUI()
				RunConsoleCommand('gamemenucommand', 'openoptionsdialog')
			end,
			Margin = 10
		},
		{
			Name = 'Контент сервера',
			DoClick = function()
				gui.OpenURL('https://steamcommunity.com/sharedfiles/filedetails/?id=2335610175')
			end
		},
		{
			Name = 'Группа ВК',
			DoClick = function()
				gui.OpenURL('https://vk.com/metahubrp')
			end,
			Margin = 10
		},
		{
			Name = 'Список серверов',
			DoClick = function()
				openServerList()
			end,
			Margin = 10
		},
		{
			Name = 'Открыть старое меню',
			DoClick = function()
				escape:Remove()
				gui.ActivateGameUI()
			end
		}
	}
	
	local pnl = vgui.Create('Panel', escape)
	pnl:SetSize(300,48)
	pnl:SetPos(48, 48)
	pnl.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, XPGUI.ButtonColor)
		local _, y = draw.SimpleText(LocalPlayer():Name(), 'xpgui_huge', 52, 0, Color(255,255,255), 0, 0)
		draw.SimpleText(ARanks[LocalPlayer():GetUserGroup()] or LocalPlayer():GetUserGroup(), 'xpgui_small', 52, y-6, Color(255,40,40), 0, 0)
	end

	local btn = vgui.Create('AvatarImage', pnl)
	btn:SetSize(38,38)
	btn:SetPos(6, 6)
	btn:SetPlayer(LocalPlayer(), 64)

	local y = ScrH()
	for k,v in pairs(buttons) do
		local btn = vgui.Create('XPButton', escape)
		btn:SetSize(ScreenScale(115), ScreenScale(21))
		btn:SetPos(48, y-btn:GetTall()-48)
		btn:SetText(v.Name)
		btn:SetFont('xpgui_huge')
		btn.DoClick = v.DoClick
		y = y - ScreenScale(21)-ScreenScale(2)-(v.Margin or 0)
	end

	/*local servers = {
		{
			name = 'ТЕСТОВЫЙ СЕРВЕР',
			ip = '127.0.0.1:27077',
			img = Material('icon.png')
		}
	}

	local serv = vgui.Create("XPScrollPanel", escape)

	local srvW, srvH = ScreenScale(150), ScreenScale(40)

	serv:SetSize(srvW,(srvH+2)*3)
	serv:SetPos(escape:GetWide()-serv:GetWide()-48, 48)*/

	/*for k,v in pairs(servers) do
		local b = vgui.Create('Panel', serv)
		b:SetSize(serv:GetWide(), srvH)
		b:SetText''
		b.Paint = function(self, w, h)
			surface.SetMaterial(v.img)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, 0, w, h)

			draw.SimpleText(v.name, 'xpgui_small', 7, h-3, Color(255,255,255), 0, TEXT_ALIGN_BOTTOM)
		end

		local join = vgui.Create('DButton', b)

		surface.SetFont('xpgui_small')
		local w, h = surface.GetTextSize(v.name)

		join:SetSize(100,h)
		join:SetPos(7+w+10, b:GetTall()-join:GetTall()-3)
		join:SetText''
		join.DoClick = function(self)
			permissions.AskToConnect( v.ip )
		end
		join.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,225))
			draw.SimpleText('ПОДКЛЮЧИТЬСЯ', 'xpgui_tiny2', w/2, h/2, Color(255,255,255), 1, 1)
		end
	end*/
end

hook.Add('PreRender', 'Escape', function()
	if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
		if IsValid(escape) then
			gui.HideGameUI()
			escape:Remove()
		else
			gui.HideGameUI()
			esc.openMenu()
		end
	end
end)
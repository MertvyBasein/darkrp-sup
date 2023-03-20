include("shared.lua")
function ENT:Draw()
	self:DrawModel()

	local inView, dist = self:InDistance(125000)
	if (not inView) then return end
		self:Draw_MainInfo()
	 
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw_MainInfo()
	local Pos = self:GetPos() - Vector(0,0,0)
	local ang = self:GetAngles()

	ang:RotateAroundAxis(ang:Up(), 180)
	ang:RotateAroundAxis(ang:Forward(), 90)
	local status
	local sState = self:GetState()

	if (sState) then
		status = "Open"
	else
		status = "Close"
	end
	local green, red = Material("icon16/bullet_green.png"), Material("icon16/bullet_red.png")
	cam.Start3D2D(Pos+ang:Up()*-5.5, ang, 0.1)
		local w, h = draw.DrawText(self:GetNWString("PropOwnedd") or "N/A", "MetaHub.Font20", -23, -110, color_white,1,1)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(sState and green or red)
		surface.DrawTexturedRect(30, -122, 20, 20)
		--
		-- if (sState) then
		-- 	surface.SetDrawColor(0, 0, 0, 100)
		-- 	surface.SetMaterial(zpiz.default_materials["zpiz_button"])
		-- 	surface.DrawTexturedRect(-150, -280, 300, 80)
		-- 	draw.DrawText(zpiz.language.OpenSign_Revenue .. zpiz.config.Currency .. self:GetSessionEarnings(), "zpiz_vgui_font03", 0, -250, zpiz.default_colors["white01"], TEXT_ALIGN_CENTER)
		-- end


	cam.End3D2D()
end


net.Receive('FoodMode::OpenCashRegMenu', function()
	if IsValid(CashRegMenu) then CashRegMenu:Remove() end

	local CashRegister = net.ReadEntity()

	CashRegMenu = vgui.Create("XPFrame")
	CashRegMenu:SetTitle("Кассовый Аппарат")
	CashRegMenu:SetSize(400, 175)
	CashRegMenu:Center()

	CashRegMenu.PaintOver = function(self, w, h)
		frametext('Денег в кассе: ' .. rp.FormatMoney(CashRegister:GetSessionEarnings() or 0), 'xpgui_big', w / 2, 60, Color(255, 255, 255), 1, 1, Color(0, 0, 0, 100))
	end

	local close_open = vgui.Create('XPButton', CashRegMenu)
	close_open:Dock(BOTTOM)
	close_open:DockMargin(5,0,5,5)
	close_open:SetText(CashRegister:GetState() and 'Закрыть заведение' or 'Открыть заведение')
	close_open.DoClick = function(self, w, h)
		net.Start("FoodMode::ChangeState")
		net.SendToServer()

		CashRegMenu:Close()
	end

	local pickup_money = vgui.Create('XPButton', CashRegMenu)
	pickup_money:Dock(BOTTOM)
	pickup_money:DockMargin(5,0,5,5)
	pickup_money:SetText('Снять деньги')
	pickup_money.DoClick = function(self, w, h)
		net.Start("FoodMode::CashoutMoney")
		net.SendToServer()

		CashRegMenu:Close()
	end
end)

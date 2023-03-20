plib.IncludeSH 'shared.lua'

local color_white = ui.col.White:Copy()
local color_black = ui.col.Black:Copy()

local complex_off = Vector(0, 0, 9)

local ang = Angle(0, 90, 90)

texture.Create('ChiefSklad'):SetFormat('png'):Download('https://img.icons8.com/ios-filled/512/FFFFFF/bossy.png')

function ENT:Draw()
	self:DrawModel()

	local bone = self:LookupBone('ValveBiped.Bip01_Head1')
	pos = self:GetBonePosition(bone) + complex_off

	ang.y = (LocalPlayer():EyeAngles().y - 90)

	local inView, dist = self:InDistance(150000)

	if (not inView)  then return end

	local alpha = 255 - (dist/590)
	color_white.a = alpha
	color_black.a = alpha

	local x = math.sin(CurTime() * math.pi) * 30

	cam.Start3D2D(pos, ang, 0.05)
		draw.NPCTitle("Начальник склада", "Нажмите [E] для взаимодействия", 0, -125, texture.Get('ChiefSklad') or Material('icon16/car.png'))
	cam.End3D2D()
	--self.TraceInfo = "<font=" .. GetFont(10) .. "><color=255,255,255>Начальник склада</color></font>\n<font=" .. GetFont(8) .. ">[E] для действия</font>"
end

net.Receive("MetaHub.OpenSellMenu",function()
	local gradient_u = Material("vgui/gradient_up")
	local tb = net.ReadTable()
	local tosell = {}
	local coast = 0
	local WHSize = (ScrW() + ScrH()) / 1.8
	local frame = vgui.Create("XPFrame")
	frame:SetSize(ScrW() * .5, ScrH() * .6)
	frame:Center()
	frame:SetTitle("Начальник склада")
	frame:InvalidateParent(true)
	--frame:SetBackgroundBlur(true)

	local L_Panel = vgui.Create("XPScrollPanel", frame)
	L_Panel:Dock(LEFT)
	L_Panel:SetWide(frame:GetWide() / 2 - 10)
	L_Panel:DockMargin(10, 5, 5, 5)
	L_Panel:InvalidateParent(true)
	L_Panel.VBar:SetWide(3)
	-- L_Panel:Receiver( "myDNDname", function(self, panels, bDoDrop, Command, x, y)
	-- 	pnl = panels[1]
	-- end)
	L_Panel.Paint = nil

	local R_Panel = vgui.Create("DPanel", frame)
	R_Panel:Dock(RIGHT)
	R_Panel:SetWide(frame:GetWide() / 2 - 10)
	R_Panel:DockMargin(10, 5, 5, frame:GetTall() / 2 - 50)
	R_Panel:InvalidateParent(true)
	R_Panel:Receiver( "myDNDname", function(self, panels, bDoDrop, Command, x, y)
		pnl = panels[1]
		if bDoDrop and pnl.ToDrag then
			AddSellSlot(pnl.model:GetModel())
			pnl.model:SetModel("")
			pnl.ToDrag = false
			coast = coast + pnl.coast
			table.insert(tosell, pnl.class)
		end
	end)
	R_Panel.Paint = function(self,w,h)
		draw.RoundedBox(5, 0, 0, w, h, Color(0, 0, 0, 80))
	end

    local SellItems = vgui.Create("DIconLayout", R_Panel)
    SellItems:Dock(FILL)
    SellItems:SetSpaceY(1)
    SellItems:SetSpaceX(1)
    SellItems:DockMargin(3, 3, 1, 1)

	function AddSellSlot(mdl)

	    local item = SellItems:Add("DPanel")
        item:SetTall(R_Panel:GetTall() / 5 + 10)
        item:SetWide(R_Panel:GetWide() / 4 - 21)
    
        item.Paint = function(self,w,h)

            draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,100))

            surface.SetDrawColor(152, 152, 152, 55)
    
        end

		item.model = vgui.Create("DModelPanel", item)
		item.model:Dock(FILL)
		item.model:DockPadding(0, 30, 0, 30)
		item.model.Model = true
        item.model:SetModel( mdl )
        

		local mn, mx = item.model.Entity:GetRenderBounds()
		local size = 0
		size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
		size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
		size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
		item.model:SetMouseInputEnabled(false)
		item.model:SetFOV(WHSize * 0.035)
		item.model:SetCamPos(Vector(size, size, size))
		item.model:SetLookAt((mn + mx) * (WHSize * 0.0005))
		item.model.OnCursorEntered = function() XPGUI.PlaySound("xpgui/submenu/submenu_dropdown_rollover_01.wav") end
		item.model.OnDepressed = function() XPGUI.PlaySound("xpgui/sidemenu/sidemenu_click_01.wav") end
		item.model.DoClick = function(slf) end
		item.model.LayoutEntity = function(ent) return end

    end


	local SellBtn = vgui.Create("XPButton", R_Panel)
	SellBtn:Dock(BOTTOM)
	SellBtn:DockMargin(5, 0, 5, 5)
	SellBtn.PaintOver = function(self,w,h)
		draw.SimpleText("Продать за "..rp.FormatMoney(coast), "xpgui_medium", w/2,h/2,Color(255,255,255),1,1)
	end
	SellBtn.DoClick = function()

		net.Start("MetaHub.SellFarm")
		net.WriteTable(tosell)
		net.SendToServer()
		frame:Remove()

	end

    local OItems = vgui.Create("DIconLayout", L_Panel)
    OItems:Dock(FILL)
    OItems:SetSpaceY(1)
    OItems:SetSpaceX(1)
    OItems:DockMargin(3, 1, 3, 1)
    local slots = 35
   	for k,v in pairs(LocalPlayer():GetInventory()) do
   		slots = slots - 1
        local item = OItems:Add("DPanel")
        item:SetTall(L_Panel:GetTall() / 5 - 30)
        item:SetWide(L_Panel:GetWide() / 5 - 2)
        item.ToDrag = true
        item.class = k
        item.coast = v.class == "item_farmfood" and 20 or 25
        item:Droppable( "myDNDname" )

        local item_col = v.color

        item.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,100))
            surface.SetDrawColor(item_col.r, item_col.g, item_col.b, 55)
        end

		item.model = vgui.Create("DModelPanel", item)
		item.model:Dock(FILL)
		item.model:DockPadding(0, 30, 0, 30)
		item.model.Model = true

        if v.save_data['model'] ~= nil then
            item.model:SetModel( v.save_data['model'] )
        elseif v.def_model ~= nil then
            item.model:SetModel( v.def_model )
        else
            item.model:SetModel( 'models/props_borealis/bluebarrel001.mdl' )
        end

		local mn, mx = item.model.Entity:GetRenderBounds()
		local size = 0
		size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
		size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
		size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
		item.model:SetMouseInputEnabled(false)
		item.model:SetFOV(WHSize * 0.035)
		item.model:SetCamPos(Vector(size, size, size))
		item.model:SetLookAt((mn + mx) * (WHSize * 0.0005))
		item.model.OnCursorEntered = function() XPGUI.PlaySound("xpgui/submenu/submenu_dropdown_rollover_01.wav") end
		item.model.OnDepressed = function() XPGUI.PlaySound("xpgui/sidemenu/sidemenu_click_01.wav") end
		item.model.DoClick = function(slf) end
		item.model.LayoutEntity = function(ent) return end

   	end

    for i =1,slots do

        local item = OItems:Add("DPanel")
        item:SetTall(L_Panel:GetTall() / 5 - 30)
        item:SetWide(L_Panel:GetWide() / 5 - 2)
    
        item.Paint = function(self,w,h)

            draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,100))

            surface.SetDrawColor(152, 152, 152, 55)
    
        end
    end

end)
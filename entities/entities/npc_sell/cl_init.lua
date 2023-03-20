plib.IncludeSH 'shared.lua'

local color_white = ui.col.White:Copy()
local color_black = ui.col.Black:Copy()

local complex_off = Vector(0, 0, 9)

local ang = Angle(0, 90, 90)

texture.Create('Delivery'):SetFormat('png'):Download('https://img.icons8.com/ios-filled/512/FFFFFF/delivered-box.png')

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
        draw.NPCTitle(self:GetNWString("N") ~= '' and self:GetNWString("N") or 'Яна Цист', "Нажмите [E] для взаимодействия", 0, -125, texture.Get('Delivery') or Material('icon16/car.png'))
    cam.End3D2D()
	--self.TraceInfo = "<font=" .. GetFont(10) .. "><color=255,255,255>"..self:GetNWString("N") ~= '' and self:GetNWString("N") or 'Яна Цист'.."</color></font>\n<font=" .. GetFont(8) .. ">[E] для действия</font>"
end
do
local hash = Color(0,0,0,155)
local back = Color(0,0,0,100)
local frame
net.Receive("S",function()
	local ent = net.ReadEntity()
	local s = net.ReadUInt(10)
	local dt = util.JSONToTable(util.Decompress(net.ReadData(s)))

	if IsValid(frame1) then frame1:Remove() return end

	frame1 = vgui.Create('QFrame')

	frame = vgui.Create("DPanel", frame1)
	frame:SetSize(ScrW() *.6, ScrH() *.65)
	frame:Center()
	--frame:SetTitle('Магазин // Богдан слушает')
	frame:InvalidateParent(true)
	frame.Paint = nil

	local L_Panel = vgui.Create("DPanel", frame)
	L_Panel:Dock(LEFT)
	L_Panel:SetWide(frame:GetWide() / 2 - 15)
	L_Panel:DockMargin(10, 5, 10, 5)
	L_Panel.Paint = function(self,w,h)
		draw.RoundedBox(5, 0, 0, w, h, hash)
	end

	local R_Panel = vgui.Create("DPanel", frame)
	R_Panel:Dock(RIGHT)
	R_Panel:SetWide(frame:GetWide() / 2 - 15)
	R_Panel:DockMargin(10, 5, 10, 5)
	R_Panel.Paint = function(self,w,h)
		draw.RoundedBox(5, 0, 0, w, h, hash)
	end

	local L_TOP_Panel = vgui.Create("DPanel", L_Panel)
	L_TOP_Panel:Dock(TOP)
	L_TOP_Panel:SetTall(50)
	L_TOP_Panel.Paint = function(self,w,h)
		draw.RoundedBox(0, 0, 0, w, h, back)
		frametext(LocalPlayer():GetName(), "xpgui_medium", 5,0, color_white, 0,0)
		frametext(rp.FormatMoney(LocalPlayer():GetMoney()), "xpgui_tiny", 5,25, color_white, 0,0)
	end

	local L_Scroll_Panel = vgui.Create('XPScrollPanel', L_Panel)
	L_Scroll_Panel:Dock(FILL)
	L_Scroll_Panel.VBar:SetWide(3)

	for k,v in pairs(dt.shopitem) do
		local button = vgui.Create("XPButton", L_Scroll_Panel)
		button:Dock(TOP)
		button:SetTall(50)
		button:SetText("")
		button:SetToolTip("Предмет, скорее всего его можно продать...")
		button.PaintOver = function(self,w,h)
			frametext(v.name, "xpgui_medium", 55,h/2, color_white, 0,1)
			frametext(rp.FormatMoney(v.price), "xpgui_medium", w-2,h, color_white, 2,4)
		end
		button.DoClick = function()
			net.Start('S')
			net.WriteEntity(ent)
			net.WriteBit(1)
			net.WriteUInt(k,5)
			net.SendToServer()
		end

		local model = vgui.Create( "rp_modelicon", button )
		model:SetSize( button:GetTall() - 10, button:GetTall() - 10 )
		model:SetPos( 5, 5 )
		model:SetModel( v.mdl )
	end

	local R_TOP_Panel = vgui.Create("DPanel", R_Panel)
	R_TOP_Panel:Dock(TOP)
	R_TOP_Panel:SetTall(50)
	R_TOP_Panel.Paint = function(self,w,h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
		frametext(ent:GetNWString("N") ~= '' and ent:GetNWString("N") or 'Яна Цист', "xpgui_medium", 5,0, color_white, 0,0)
		frametext(rp.FormatMoney(ent:GetNWInt("Money")), "xpgui_tiny", 5,25, color_white, 0,0)
	end

	local R_Scroll_Panel = vgui.Create('XPScrollPanel', R_Panel)
	R_Scroll_Panel:Dock(FILL)
	R_Scroll_Panel.VBar:SetWide(3)

	local myitems = {}

	for k,v in pairs(dt.items) do
		local button = vgui.Create("XPButton", R_Scroll_Panel)
		button:Dock(TOP)
		button:SetTall(50)
		button:SetText("")
		button:SetToolTip("Предмет, скорее всего его можно продать...")
		button.PaintOver = function(self,w,h)
			frametext(v.name, "xpgui_medium", 55,h/2, color_white, 0,1)
			frametext(rp.FormatMoney(v.price), "xpgui_medium", w-2,h, color_white, 2,4)
		end
		button.DoClick = function()
			net.Start('S')
			net.WriteEntity(ent)
			net.WriteBit(0)
			net.WriteUInt(k,5)
			net.SendToServer()
		end



		local model = vgui.Create( "rp_modelicon", button )
		model:SetSize( button:GetTall() - 10, button:GetTall() - 10 )
		model:SetPos( 5, 5 )
		model:SetModel( v.mdl )
		model.PaintOver = function(self,w,h)
			frametext(LocalPlayer():GetItemsCount(v.name), "xpgui_tiny", w-2,h, color_white, 2,4)
		end

	end

end)
end

do
-- Дядя Богдан
-- models/player/odessa.mdl
-- models/props_junk/PopCan01a.mdl;Водичка;250;1
-- models/props_junk/plasticbucket001a.mdl;Банка краски;250;0
concommand.Add('create_ui', function(p)
	if !p:IsSuperAdmin() then return end
	local tbl = {}
	local fr = vgui.Create("XPFrame")
	fr:SetSize(ScrW() * .4, ScrH() * .5)
	fr:SetTitle('Создать НПС // Позеры не поймут')
	fr:Center()

	local scrl = vgui.Create("XPScrollPanel", fr)
	scrl:Dock(FILL)

	fr.ph = vgui.Create( "DTextEntry", scrl )
	fr.ph:Dock( TOP )
	fr.ph:DockMargin( 5, 5, 5, 5 )
	fr.ph:SetPlaceholderText( 'Имя' )
	fr.ph.name = 1
	tbl[#tbl + 1] = fr.ph

	fr.ph = vgui.Create( "DTextEntry", scrl )
	fr.ph:Dock( TOP )
	fr.ph:DockMargin( 5, 5, 5, 5 )
	fr.ph:SetPlaceholderText( 'Модель' )
	fr.ph.mdl = 1
	tbl[#tbl + 1] = fr.ph

	fr.btn = vgui.Create("XPButton", fr)
	fr.btn:Dock(BOTTOM)
	fr.btn:SetText("Создать")
	fr.btn.DoClick = function()
		local newtbl = {}
		for z = 1, #tbl do
			if tbl[z].name then 
				newtbl.name = tbl[z]:GetValue() 
			elseif tbl[z].mdl then
				newtbl.mdl = tbl[z]:GetValue()
			else
				newtbl[z] = tbl[z]:GetValue()
			end
		end
		newtbl.pos = LocalPlayer():GetPos()
		newtbl.angles = LocalPlayer():GetAngles()
		local dat = util.Compress(util.TableToJSON(newtbl))
		net.Start('G')
		net.WriteUInt(#dat, 10)
		net.WriteData(dat, #dat)
		net.SendToServer()
		fr:Remove() fr = nil
	end

	fr.btn = vgui.Create("XPButton", fr)
	fr.btn:Dock(LEFT)
	fr.btn:SetText("+")
	fr.btn.DoClick = function()
		fr.ph = vgui.Create( "DTextEntry", scrl )
		tbl[#tbl + 1] = fr.ph
		fr.ph:Dock( TOP )
		fr.ph:DockMargin( 5, 5, 5, 5 )
		fr.ph:SetPlaceholderText( '(Entity;ent_class or Inventory;Модель предмета);Название предмета;Цена;Продать_купить;' )
	end

	fr.btn = vgui.Create("XPButton", fr)
	fr.btn:Dock(RIGHT)
	fr.btn:SetText("-")
	fr.btn.DoClick = function()
		if #tbl == 0 then return end
		tbl[#tbl]:Remove()
		tbl[#tbl] = nil
	end

end)
end
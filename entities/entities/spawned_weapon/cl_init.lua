plib.IncludeSH 'shared.lua'

local buttonWide = 270
local buttonTall = 65

surface.CreateFont("xpgui3d_bold", {size = 80, weight = 450, antialias = true, extended = true, font = "Roboto Condensed"})
surface.CreateFont("xpgui3d_medium", {size = 40, weight = 300, antialias = true, extended = true, font = "Roboto Condensed"})

function ENT:Draw()
	self:DrawModel()

	if LocalPlayer():GetPos():Distance(self:GetPos()) > 80 then return end

	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang.z = 45
	ang.y = (LocalPlayer():EyeAngles().y - 90)
	ang:RotateAroundAxis(ang:Right(), 0)

	--cam.Start3D2D(pos + ang:Up() * 4, ang, 0.03)
	if ui3d2d.startDraw(pos+ ang:Up() * 6, ang, .03) then
		local _, a = draw.SimpleText(self:GetNWString('class', 'None'), "xpgui3d_bold", 0, -50, Color(255, 255, 255))
		draw.OutlinedBox(0, -50+a+5, buttonWide, buttonTall, color_white, color_black, 6)
		draw.SimpleText('Положить в сумку', 'xpgui3d_medium', 15, -50+a+19, color_black)
		if ui3d2d.isHovering(0, -50+a+5, buttonWide, buttonTall) then
			draw.OutlinedBox(0, -50+a+5, buttonWide, buttonTall, color_black, color_white, 6)
			draw.SimpleText('Положить в сумку', 'xpgui3d_medium', 15, -50+a+19, color_white)
			if ui3d2d.isPressed() then
				net.Start('pickupitem_inv')
				net.WriteEntity(self)
				net.SendToServer()
			end
		end
		draw.OutlinedBox(buttonWide+5, -50+a+5, buttonWide, buttonTall, color_black, color_white, 6)
		draw.SimpleText('Взять в руки', 'xpgui3d_medium', buttonWide+55, -50+a+19, color_white)
		if ui3d2d.isHovering(buttonWide+5, -50+a+5, buttonWide, buttonTall) then
			draw.OutlinedBox(buttonWide+5, -50+a+5, buttonWide, buttonTall, color_white, color_black, 6)
			draw.SimpleText('Взять в руки', 'xpgui3d_medium', buttonWide+55, -50+a+19, color_black)
			if ui3d2d.isPressed() then
				net.Start('gun.pick')
				net.WriteEntity(self)
				net.SendToServer()
			end
		end
		--print(self:WorldToLocal(LocalPlayer():GetEyeTrace().HitPos))
		ui3d2d.endDraw()
	end
	--cam.End3D2D()
end
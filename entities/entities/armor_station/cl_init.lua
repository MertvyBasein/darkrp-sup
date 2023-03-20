plib.IncludeSH 'shared.lua'

local LocalPlayer = LocalPlayer
local Color = Color
local cam = cam
local draw = draw
local Angle = Angle
local Vector = Vector
local CurTime = CurTime

local mic = Material("sup/entities/microwave.png")

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local inView, dist = self:InDistance(150000)

	if (not inView) then return end

	color_white.a = 255 - (dist/590)
	color_black.a = color_white.a

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), math.sin(CurTime() * math.pi) * -45)

	cam.Start3D2D(pos, ang, 0.070)
		draw.SimpleTextOutlined('Микроволновка', '3d2d', 0, -450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		draw.SimpleTextOutlined('Цена: $' .. self:Getprice(), '3d2d', 0, -450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)	
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(mic)
			surface.DrawTexturedRect(-64, -700, 128, 128)		
	cam.End3D2D()

	ang:RotateAroundAxis(ang:Right(), 180)

	cam.Start3D2D(pos, ang, 0.070)
		draw.SimpleTextOutlined('Микроволновка', '3d2d', 0, -450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		draw.SimpleTextOutlined('Цена: $' .. self:Getprice(), '3d2d', 0, -450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(mic)
			surface.DrawTexturedRect(-64, -700, 128, 128)			
	cam.End3D2D()
end
include('shared.lua')

local LocalPlayer = LocalPlayer
local Color = Color
local cam = cam
local draw = draw
local Angle = Angle
local Vector = Vector

local color_white = Color(255,255,255)
local color_black = Color(0,0,0)

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local inView, dist = self:InDistance(125000)

	if (not inView) then return end

	color_white.a = 255 - (dist/500)
	color_black.a = color_white.a

	if not IsValid(self:Getowning_ent()) or not IsValid(self:Getrecipient()) then return end

	local amount = tostring(self:Getamount()) or '0'
	local owner = (IsValid(self:Getowning_ent()) and self:Getowning_ent().Name and self:Getowning_ent():Name()) or 'N/A'
	local recipient = (self:Getrecipient().Name and self:Getrecipient():Name()) or 'N/A'

	surface.SetFont('ChatFont')
	local TextWidth = surface.GetTextSize('Уплата: ' .. recipient .. '\n$' .. amount .. '\nПодпись: ' .. owner)

	cam.Start3D2D(pos + ang:Up() * 0.9, ang, 0.012)
		draw.SimpleTextOutlined('Уплата: ' .. recipient, '3d2d', -TextWidth*0.5, -150, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)	
		draw.SimpleTextOutlined('$' .. amount, '3d2d', -TextWidth*0.5, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)	
		draw.SimpleTextOutlined('Подпись: ' .. owner, '3d2d', -TextWidth*0.5, 130, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)	
	cam.End3D2D()
end
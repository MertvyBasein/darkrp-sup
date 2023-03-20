include('shared.lua')

local LocalPlayer = LocalPlayer
local Color = Color
local cam = cam
local draw = draw
local Angle = Angle
local Vector = Vector
local render = render
local CurTime = CurTime

local color_white = Color(255,255,255)
local color_black = Color(0,0,0)

function ENT:Draw3D2D()
	self:DrawModel()

	self:drawFloatingGun()
	self:drawInfo()
end

function ENT:drawFloatingGun()
	if (not IsValid(self:GetgunModel())) or (self:Getcount() == 0) then return end

	local pos = self:GetPos()
	local ang = self:GetAngles()

	-- Position the gun
	local gunPos = self:GetAngles():Up() * 40 + ang:Up() * (math.sin(CurTime() * 3) * 8)
	self:GetgunModel():SetPos(pos + gunPos)

	-- Make it dance
	ang:RotateAroundAxis(ang:Up(), (CurTime() * 180) % 360)
	self:GetgunModel():SetAngles(ang)

	self:GetgunModel():DrawModel()
end

function ENT:drawInfo()
	local content = self:Getcontents() or ''
	local contents = rp.shipments[content]
	if not contents then return end
	contents = contents.name

	local pos = self:GetPos()
	local ang = self:GetAngles()
	local inView, dist = self:InDistance(150000)

	if (not inView) then return end

	color_white.a = 255 - (dist/590)
	color_black.a = color_white.a

	ang:RotateAroundAxis(ang:Forward(), 90)

	cam.Start3D2D(pos + ang:Up() * 17, ang, 0.035)
		draw.SimpleTextOutlined('Содержит:', '3d2d', 0, -520, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined(contents, '3d2d', 0, -520, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		draw.SimpleTextOutlined('Осталось:', '3d2d', 0, -200, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined(self:Getcount() .. '/10', '3d2d', 0, -200, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	cam.End3D2D()
end
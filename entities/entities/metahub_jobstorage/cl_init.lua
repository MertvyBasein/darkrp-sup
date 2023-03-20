include("shared.lua");

function ENT:Initialize()	

end;
ENT.RenderGroup = RENDERGROUP_BOTH
texture.Create('storage_')
	:SetFormat('png')
	:Download('https://img.icons8.com/material-rounded/512/FFFFFF/storage.png')
	
local color_white = Color(255,255,255)
function ENT:Draw()
	self:DrawModel()

	local inView, dist = self:InDistance(150000)

	if (not inView) then return end

	local alpha = 255 - (dist/590)
	color_white.a = alpha
	color_black.a = alpha

	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang.y = (LocalPlayer():EyeAngles().y - 90)
	ang.z = 90

	cam.Start3D2D(pos + ang:Right()*-51, ang, 0.05)
		draw.NPCTitle("Склад", "Нажмите [E] для взаимодействия", 0, -125, texture.Get('storage_') or Material('icon16/car.png'))
	cam.End3D2D()
end;

function EvreiOpenStorage()

	local frame = vgui.Create("XPFrame")
	frame:SetSize(ScrW() * .2, ScrH() * .2)
	frame:Center()
	frame:SetTitle("Склад")
	frame:InvalidateParent(true)
	
	local MainFrame = vgui.Create('DPanel', frame)
	MainFrame:Dock(FILL)
	MainFrame:DockMargin(5, 5, 5, 5)
	MainFrame:InvalidateParent(true)
	MainFrame.Paint = nil
	
	local L_Panel = vgui.Create('XPButton', MainFrame)
	L_Panel:Dock(FILL)
	L_Panel:SetText('Взять набор')
	L_Panel.DoClick = function()

		net.Start("MetaHub.EStorage.TakeItem")
			net.WriteString('farm')
		net.SendToServer()

	end

end
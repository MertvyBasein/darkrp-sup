plib.IncludeSH 'shared.lua'

local color_white = ui.col.White:Copy()
local color_black = ui.col.Black:Copy()

local complex_off = Vector(0, 0, 9)

local ang = Angle(0, 90, 90)

texture.Create('Elections'):SetFormat('png'):Download('https://img.icons8.com/ios-filled/512/FFFFFF/elections.png')

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
		draw.NPCTitle("Выборы Мэра", "Нажмите [E] для взаимодействия", 0, -125, texture.Get('Elections') or Material('icon16/car.png'))
	cam.End3D2D()
	--self.TraceInfo = "<font=" .. GetFont(10) .. "><color=255,255,255>Выборы Фюрера</color></font>\n<font=" .. GetFont(8) .. ">[E] для действия</font>"
end

net.Receive('metahub.regelection',function()

	Derma_Query( "Вы действительно хотите записаться на выборы? Это вам обойдется в 2.500", "Подтверждение", "Да", function()
		net.Start("MetaHub.EnterElection")
		net.SendToServer()
	end, "Нет")

end)
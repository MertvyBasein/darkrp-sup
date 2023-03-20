include('shared.lua')

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Initialize()
	
end

texture.Create('Nadziratel'):SetFormat('png'):Download('https://img.icons8.com/ios-filled/512/FFFFFF/prison-building.png')

function ENT:Draw() 
	self:DrawModel() 
	self:SetSequence(4)

    if self:GetPos():Distance(LocalPlayer():GetPos()) < 300 then
		local Ang = LocalPlayer():GetAngles()

		Ang:RotateAroundAxis( Ang:Forward(), 90)
		Ang:RotateAroundAxis( Ang:Right(), 90)

		cam.Start3D2D(self:GetPos()+self:GetUp()*80, Ang, 0.05)
			draw.NPCTitle("Надзиратель", "Нажмите [E] для взаимодействия", 0, 0, texture.Get('Nadziratel') or Material('icon16/car.png'))
		cam.End3D2D()
		--self.TraceInfo = "<font=" .. GetFont(10) .. "><color=255,255,255>Вольфганг</color></font>\n<font=" .. GetFont(8) .. ">[E] для действия</font>"
	end
end

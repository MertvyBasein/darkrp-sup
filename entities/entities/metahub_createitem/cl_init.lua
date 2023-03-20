include("shared.lua");

function ENT:Initialize()	

end;

texture.Create('toolIco')
	:SetFormat('png')
	:Download('https://img.icons8.com/ios-filled/256/FFFFFF/blueprint.png')

function ENT:Draw()
	self:DrawModel();

    if self:GetPos():Distance(LocalPlayer():GetPos()) < 300 then
		local Ang = LocalPlayer():GetAngles()

		Ang:RotateAroundAxis( Ang:Forward(), 90)
		Ang:RotateAroundAxis( Ang:Right(), 90)
	
		cam.Start3D2D(self:GetPos()+self:GetUp()*60, Ang, 0.07)
			draw.NPCTitle("Стол создания", "Нажмите [E] для взаимодействия", 0, 0, texture.Get('toolIco') or Material('icon16/car.png'))
		cam.End3D2D()
	end
end;
include("shared.lua")


surface.CreateFont("chicken_one", {
	font = "Roboto",
	size = 90,
	weight = 800,
})

surface.CreateFont("chicken_two", {
	font = "Roboto",
	size = 50,
	weight = 900,
})

function ENT:Draw()


	self:DrawModel()


    if self:GetPos():Distance(LocalPlayer():GetPos()) < 300 then
        local Ang = LocalPlayer():GetAngles()

        Ang:RotateAroundAxis( Ang:Forward(), 90)
        Ang:RotateAroundAxis( Ang:Right(), 90)
    
        cam.Start3D2D(self:GetPos()+self:GetUp()*80, Ang, 0.05)
            draw.NPCTitle("Проповедник", "Нажмите [E] для взаимодействия", 0, 0, Material("materials/modern/cross.png", "smooth"))
        cam.End3D2D()
        --self.TraceInfo = "<font=" .. GetFont(10) .. "><color=255,255,255>Армия США</color></font>\n<font=" .. GetFont(8) .. ">[E] для открытия меню</font>"
    end
	
end


net.Receive("PropovedMenu", function()
	Derma_StringRequest("Количество", "Сколько вы хотите пожертвовать?", "", function(a)

		net.Start("PropovedMinusMoney")
			net.WriteUInt(a, 32)
		net.SendToServer()
	end)

end)
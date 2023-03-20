include("shared.lua");

function ENT:Initialize()	

end;


function ENT:Draw()
	self:DrawModel();

	self.TraceInfo = "<font=" .. GetFont(10) .. "><color=255,51,0>Фермерский продукт</color></font>"

end;
include("shared.lua");

function ENT:Initialize()	

end;


function ENT:Draw()
	self:DrawModel();

	self.TraceInfo = "<font=" .. GetFont(10) .. "><color=255,51,0>Одежда</color></font>\n<font=" .. GetFont(8) .. ">Когда-то классно сидела на ком-то</font>"

end;
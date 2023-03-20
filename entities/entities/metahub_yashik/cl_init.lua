include("shared.lua");

function ENT:Initialize()	

end;

ENT.TraceInfo = "<font=" .. GetFont(10) .. "><color=255,51,0>Ящик с провизией</color></font>\n<font=" .. GetFont(8) .. ">Пополняет ваши боеприпасы, еду, здоровье и броню</font>"


function ENT:Draw()
	self:DrawModel();
end;
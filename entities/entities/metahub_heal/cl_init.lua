include("shared.lua");

function ENT:Initialize()	

end;


function ENT:Draw()
	self:DrawModel();
	if LocalPlayer():IsCP() then
		self.TraceInfo = "<font=" .. GetFont(10) .. "><color=255,51,0>Хил станция</color></font>\n<font=" .. GetFont(8) .. ">Восстанавливает ваше здоровье </font>\n<font=" .. GetFont(8) .. ">Зарядов: <color=255,255,0>"..self:GetAmount().."/25</color> </font>"
	else
		self.TraceInfo = "<font=" .. GetFont(10) .. "><color=255,51,0>Хил станция</color></font>\n<font=" .. GetFont(8) .. ">Восстанавливает ваше здоровье </font>\n<font=" .. GetFont(8) .. ">Цена: <color=255,255,0>250 Т</color> </font>"
	end
end;
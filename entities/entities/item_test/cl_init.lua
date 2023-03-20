include("shared.lua");

function ENT:Initialize()	

end;


function ENT:Draw()
	self:DrawModel();
	self.TraceInfo = "<font=" .. GetFont(10) .. "><center><color=156,156,156>TestItem</color></center></font>"
end
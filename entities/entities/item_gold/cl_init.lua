include("shared.lua");

function ENT:Initialize()	

end;


function ENT:Draw()
	self:DrawModel();
	local title = "Слиток золота"
	if self:GetModel() == "models/jessev92/payday2/item_bag_loot.mdl" then
		self.TraceInfo = "<font=" .. GetFont(10) .. "><center><color=156,156,156>Сумка с деньгами\n</color></center></font>"
	else
		self.TraceInfo = "<font=" .. GetFont(10) .. "><center><color=243,156,18>".. title .."\n</color></center></font><font=" .. GetFont(10) .. "><color=243,156,18>Количество: ".. rp.FormatMoney(self:GetNWInt("Gold.Money")) .."</color></font>"
	end
end
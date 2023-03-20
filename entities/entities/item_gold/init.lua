AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self:SetModel("models/money/goldbar.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end;

function ENT:Use(ply)

	if self:GetNWInt('Gold.Money', 0) > 0 then
		ply:SetNWInt('MetaHub.Robbery.Money', ply:GetNWInt('MetaHub.Robbery.Money') + self:GetNWInt("Gold.Money"))
		rp.Notify(ply,0,"+"..rp.FormatMoney(self:GetNWInt("Gold.Money")))

		local defaultspeed = rp.cfg.RunSpeed
		local defaultspeed2 = rp.cfg.WalkSpeed
		local goldcount = ply:GetNWInt("MetaHub.Robbery.Money", 0)
		
		ply:SetRunSpeed( defaultspeed - (goldcount / 150) )
		ply:SetWalkSpeed( defaultspeed2 - (goldcount / 300) )

		self:Remove()
	end

end

hook.Add("PlayerDeath", "MetaHub.BankRobbery",function(ply)

	if ply:GetNWInt("MetaHub.Robbery.Money", 0) > 0 then

		local pocket = ents.Create("item_gold")
		pocket:SetPos(ply:GetPos())
		pocket:Spawn()
		pocket:SetModel("models/jessev92/payday2/item_bag_loot.mdl")
		pocket:SetNWInt("Gold.Money", ply:GetNWInt("MetaHub.Robbery.Money"))
		ply:SetNWInt("MetaHub.Robbery.Money", 0)

		timer.Simple(120,function()

			if IsValid(self) then
				self:Remove()
			end

		end)

	end

end)

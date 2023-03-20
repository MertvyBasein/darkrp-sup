AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self:SetModel("models/props_combine/health_charger001.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetAmount(25)
end;

function ENT:Use(ply)
	--if GetRaid() then return end
    if ply:IsCP() then
    	if self:GetAmount() <= 0 and ply:Team() != TEAM_GRID then rp.Notify(ply,1,'В раздатчике закончились хил-пластины, позовите GRID') return end
    	if self:GetAmount() <= 0 and ply:Team() == TEAM_GRID then
    		self:SetAmount(25)
    		rp.Notify(ply, 0, "Вы пополнили хил станцию")
    	end
    	if ply:Health() == ply:GetMaxHealth() then return end
    	self:SetAmount(self:GetAmount() - 1)
    	ply:SetHealth(ply:GetMaxHealth())
    	rp.Notify(ply, 0, "Вы успешно восстановили свою здоровье!")
    else
    	if ply:Health() == ply:GetMaxHealth() then return end
    	if not ply:CanAfford(250) then return rp.Notify(ply, 1, "У вас недостаточно токенов!") end
    	ply:AddMoney(-250)
    	rp.Notify(ply, 0, "Вы купили хил-заряд за "..rp.FormatMoney(250))
    	ply:SetHealth(ply:GetMaxHealth())
    end

end

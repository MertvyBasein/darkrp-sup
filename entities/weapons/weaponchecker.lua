AddCSLuaFile()
SWEP.Base = 'weapon_rp_base'

if CLIENT then
	SWEP.PrintName 		= 'Проверка на оружие'
	SWEP.Slot 			= 3
	SWEP.SlotPos 		= 0
	SWEP.Instructions 	= ''
end

SWEP.ViewModel 		= Model('models/weapons/v_hands.mdl')
SWEP.ViewModelFOV 	= 62

SWEP.Spawnable = true
SWEP.Category = 'RP'
SWEP.Primary.Delay = 2

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if CLIENT then return end

	local ent = self.Owner:GetEyeTrace().Entity

	if (not IsValid(ent)) or (not ent:IsPlayer()) or (self.Owner:GetPos():Distance(ent:GetPos()) > self.HitDistance) then return end

	if ent:IsPlayer() then
		net.Start('MetaHub.SearchMenu')
		net.WriteEntity(ent)
		net.Send(self.Owner)

		-- local BlackWep = {}
		-- local GreenWep = ent:GetTeamTable().weapons
		-- local GreenWep2 = ent:GetTeamTable().jobweapons or {}
		-- local HasWep = ent:GetWeapons()
		-- for k, v in pairs( HasWep ) do
		-- 	if !table.HasValue(GreenWep , v:GetClass()) then
		-- 		if !table.HasValue(GreenWep2 , v:GetClass()) then
		-- 			if !table.HasValue(rp.cfg.DefaultWeapons,v:GetClass()) then
		-- 				table.insert(BlackWep,v:GetClass())
		-- 			end
		-- 		end
		-- 	end
		-- end
		-- net.Start('WeaponChecker')
		-- net.WriteTable(BlackWep)
		-- net.Send(self.Owner)

		hook.Call('playerWeaponsChecked', GAMEMODE, self.Owner, ent)
	end
end

if SERVER then
	util.AddNetworkString('WeaponChecker')
else
	net.Receive('WeaponChecker', function( len)
		local Tb = net.ReadTable()
		chat.AddText(rp.col.White, 'Нелегальное оружие:')
		for k, v in pairs(Tb) do
			if weapons.Get(v) then
				chat.AddText(rp.col.Red, ('- ' .. weapons.Get(v).PrintName))
			end
		end
	end)
end

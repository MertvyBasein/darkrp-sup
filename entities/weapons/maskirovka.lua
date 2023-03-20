AddCSLuaFile()

SWEP.Base = 'weapon_rp_base'

if CLIENT then
	SWEP.PrintName = 'Маскировка'
	SWEP.Slot = 2
	SWEP.Instructions = 'Левый клик - маскировка'
end

SWEP.Spawnable = true
SWEP.Category = "RP"
SWEP.WorldModel = Model('models/props_c17/BriefCase001a.mdl')
SWEP.ViewModel = Model("models/weapons/v_hands.mdl")

SWEP.Primary.Delay = 1

function SWEP:DrawWorldModel()
	return false
end

function SWEP:PrimaryAttack()
	-- if not IsValid(self.Owner) then return end
	if CLIENT then
		rp.ShowDisguise()
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

end

function SWEP:Reload()
	if not IsValid(self.Owner) then return end
	if not self.Owner:IsDisguised() then return end
	if SERVER then
		self.Owner:UnDisguise()
		self.Owner:SetNetVar('MetaHub.DisguiseTeam', nil)
		GAMEMODE:PlayerSetModel(self.Owner)
		rp.Notify(self.Owner, 0, 'Маскировка снята!')
	end
end

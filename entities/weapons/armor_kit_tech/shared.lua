if SERVER then
    AddCSLuaFile("shared.lua")
end

SWEP.PrintName = "Арморкит"
SWEP.Slot = 5
SWEP.SlotPos = 0
SWEP.Description = ""
SWEP.Contact = ""
SWEP.Purpose = "" 
SWEP.Author = "ГО"
SWEP.Instructions = ""
SWEP.IsDarkRPMedKit = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "ГО"

SWEP.ViewModel = "models/weapons/c_medkit.mdl"
SWEP.WorldModel = "models/weapons/w_medkit.mdl"
SWEP.UseHands = true

SWEP.Primary.Recoil = 0
SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = true
SWEP.Primary.Delay = 0.1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Recoil = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Delay = 0.1
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetHoldType( "slam" )
end

function SWEP:PrimaryAttack()

    if not IsValid(self:GetOwner()) then return end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if CLIENT then return end

    local ply = self:GetOwner()

    ply:LagCompensation(true)
    local found = ply:GetEyeTrace().Entity
    ply:LagCompensation(false)

    if not found or not IsValid(found) or not found:IsPlayer() or not found:Alive() or not ply:Alive() or ply:GetPos():Distance(found:GetPos()) > 85 then return end

    local armor = found:Armor() or 100
    local maxarmor = found:GetMaxArmor() or 100

    if armor < maxarmor and found:Team() ~= TEAM_GORDON then
        local int_armor = math.min(found:Armor() + 3, maxarmor)
        found:SetArmor(int_armor)
        ply:EmitSound("HL1/fvox/buzz.wav", 150, armor / maxarmor * 100, 1, CHAN_AUTO)
    end
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    if CLIENT then return end
    local ply = self:GetOwner()
    local maxarmor = ply:GetMaxArmor() or 100
    local armor = ply:Armor() or 100
    if ply and ply:Alive() then
        if armor < maxarmor then
            local int_armor = math.min(ply:Armor() + 1, maxarmor)
            ply:SetArmor(int_armor)
            ply:EmitSound("items/battery_pickup.wav", 150, armor / maxarmor * 100, 1, CHAN_AUTO)
        end
    end
end

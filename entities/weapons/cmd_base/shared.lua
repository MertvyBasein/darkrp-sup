SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "RP"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 0
SWEP.Primary.NumShots = -1
SWEP.Primary.Delay = 3
SWEP.Primary.Distance = 75
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 3


SWEP.ViewModel = Model("models/weapons/v_hands.mdl")

SWEP.cmd    = "rob"

function SWEP:Initialize()
end

function SWEP:DrawWorldModel()
end

function SWEP:Reload()
end

function SWEP:Think()
	self:SetHoldType( "normal" )
end

function SWEP:PrimaryAttack()
	if not self.NextPrimaryAttack then
		self.NextPrimaryAttack = 0
	end

	if self.NextPrimaryAttack > CurTime() then return end
	if CLIENT then RunConsoleCommand("rp", self.cmd) end
	self.NextPrimaryAttack = CurTime() + 1
    if SERVER then
        local s

        if istable(self.Sound1) then
            s = self.Sound1[math.random(#self.Sound1)]
        else
            s = self.Sound1
        end

		if s then self.Owner:EmitSound(s) end
	end
end

function SWEP:SecondaryAttack()
	if not self.NextSecondaryAttack then
		self.NextSecondaryAttack = 0
	end

	if self.NextSecondaryAttack > CurTime() then return end
	self.NextSecondaryAttack = CurTime() + 3

	if SERVER then
        local s

        if istable(self.Sound2) then
            s = self.Sound2[math.random(#self.Sound2)]
        else
            s = self.Sound2
        end
		if s then self.Owner:EmitSound(s) end
	end
end

function SWEP:DrawHUD()
end

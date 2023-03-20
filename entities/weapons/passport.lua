SWEP.PrintName				= "Паспорт"
SWEP.Author					= ""
SWEP.Spawnable				= true
SWEP.Category				= "Other"

SWEP.PrintName = 'Паспорт'
SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/props_lab/clipboard.mdl"
SWEP.WorldModel = "models/props_lab/clipboard.mdl"
SWEP.Spawnable = true



SWEP.AnimPrefix	 			= "rpg"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Slot					= 0
SWEP.SlotPos				= 0

SWEP.DrawCrosshair = true

SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

function SWEP:Holster(wep)
	self.Weapon:SendWeaponAnim(ACT_VM_UNDEPLOY_2)
	return true
end

function SWEP:PrimaryAttack()
	if (SERVER) then
		local trace = self:GetOwner():GetEyeTrace()
		local pl = trace.Entity

		if not IsValid(self:GetOwner()) then return end
		if not IsValid(pl) then return end
		if not self:GetOwner():IsPlayer() then return end
		if not pl:IsPlayer() then return end
		if self:GetOwner():GetPos():DistToSqr(pl:GetPos()) > 10000 then return end

		rp.Notify(self:GetOwner(), 0, 'Вы предложили ' .. pl:Name() .. ' посмотреть ваш паспорт')
		GAMEMODE.ques:Create(self:GetOwner():Name() .. " хочет показать паспорт" ,  pl:EntIndex() .. 'orginv', pl,  10, function(result)
			if not IsValid(self) then return end
			if not IsValid(self:GetOwner()) then return end
			if not IsValid(pl) then return end
			if not self:GetOwner():IsPlayer() then return end
			if not pl:IsPlayer() then return end

			if not tobool(result) then return rp.Notify(self:GetOwner(), 1, pl:Name() .. ' отказался смотреть на ваш паспорт') end
			net.Start('VRP.Passport')
			net.WriteEntity(self:GetOwner())
			net.Send(pl)
			hook.Run('PlayerPassport', self:GetOwner())

			rp.Notify(self:GetOwner(), 0, pl:Name() .. ' посмотрел ваш паспорт')
			self.Owner:ConCommand("say /me показал свой паспорт человеку напротив.")
		 end)
	end
	self.Weapon:SetNextPrimaryFire(CurTime() + 5)
	self.Weapon:SetNextSecondaryFire(CurTime() + 5)
end

function SWEP:SecondaryAttack()
	if (SERVER) then
		self.Owner:ConCommand("say /me посмотрел свой паспорт.")
		net.Start('VRP.Passport')
		net.WriteEntity(self:GetOwner())
		net.Send(self:GetOwner())
	end
	self.Weapon:SetNextPrimaryFire(CurTime() + 5)
	self.Weapon:SetNextSecondaryFire(CurTime() + 5)
end

function SWEP:Initialize()

	self:SetHoldType( "slam" )

end

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

local nodos = {Vector(0, 2, 0),Angle(0, 0, -180)}

function SWEP:GetViewModelPosition( pos, ang )
    pos = pos + ang:Right() * 9 + ang:Forward() * 25 + ang:Up() * -9

    ang:RotateAroundAxis( ang:Right(), 90 )
    ang:RotateAroundAxis( ang:Up(), 0 )

    return pos, ang
end

function SWEP:DrawWorldModel()
    local entOwner = self:GetOwner()

    if not entOwner:IsValid() then
        self:SetRenderOrigin()
        self:SetRenderAngles()
        self:DrawModel()

        return
    end

    self:RemoveEffects(EF_BONEMERGE_FASTCULL)
    self:RemoveEffects(EF_BONEMERGE)
    local iHandBone = entOwner:LookupBone("ValveBiped.Bip01_R_Hand")
    if not iHandBone then return end
    local vecBone, angBone = entOwner:GetBonePosition(iHandBone)

    if false then
        local forward = angBone:Forward()
        angBone:RotateAroundAxis(forward, 70)
        local right = angBone:Right()
        angBone:RotateAroundAxis(right, -160)
        local up = angBone:Up()
        angBone:RotateAroundAxis(up, 30)
        vecBone:Sub(angBone:Up() * 2.5)
        vecBone:Sub(angBone:Right() * 0)
    else
        local forward = angBone:Forward()
        angBone:RotateAroundAxis(forward, 90)
        local right = angBone:Right()
        angBone:RotateAroundAxis(right, 90)
        local up = angBone:Up()
        angBone:RotateAroundAxis(up, 90)
        vecBone:Sub(angBone:Up() * 5)
        vecBone:Sub(angBone:Right() * -.5)
    end

    self:SetRenderOrigin(vecBone + nodos[1])
    self:SetRenderAngles(angBone + nodos[2])
    self:DrawModel()
end

end

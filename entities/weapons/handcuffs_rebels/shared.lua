SWEP.Contact = ""
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.DrawAmmo = false
SWEP.Base = "weapon_base"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/grinchfox/weapons/handcuffs/c_handcuffs.mdl"
SWEP.WorldModel = "models/grinchfox/weapons/handcuffs/w_handcuffs.mdl"
SWEP.ViewModelFlip = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.UseHands = true
SWEP.HoldType = "slam"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false


function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end

	local target = self.Owner:getEyeSightHitEntity(nil, nil, function(tar)
		return getEyeSightHitEntityDefaultFilter(tar) and true
	end)
	if not IsValid(target) then return end
	self:SetNextPrimaryFire(CurTime() + 1)
	if not target:IsPlayer() then return end
	if target:InVehicle() then target:ExitVehicle() end
	if target:InSpawn() then return rp.Notify(self.Owner, NOTIFY_ERROR, 'На спавне запрещено использовать наручники.') end
	if target:GetNetVar('AdminMode') then return rp.Notify(self.Owner, NOTIFY_ERROR, 'На администратора нельзя надеть наручники.') end

	if target == nil then return end

	if  (self:GetOwner():EyePos():Distance(target:GetPos()) < 150) and  (target:GetNWBool('isHandcuffed') == false) then

		target:ManipulateBoneAngles(target:LookupBone('ValveBiped.Bip01_L_UpperArm'), Angle(20, 8.8, 0)) -- Left UpperArm
		target:ManipulateBoneAngles(target:LookupBone('ValveBiped.Bip01_L_Forearm'), Angle(15, 0, 0)) -- Left ForeArm
		target:ManipulateBoneAngles(target:LookupBone('ValveBiped.Bip01_L_Hand'), Angle(0, 0, 75)) -- Left Hand
		target:ManipulateBoneAngles(target:LookupBone('ValveBiped.Bip01_R_Forearm'), Angle(-15, 0, 0)) -- Right Forearm
		target:ManipulateBoneAngles(target:LookupBone('ValveBiped.Bip01_R_Hand'), Angle(0, 0, -75)) -- Right Hand
		target:ManipulateBoneAngles(target:LookupBone('ValveBiped.Bip01_R_UpperArm'), Angle(-20, 16.6, 0)) -- Right Upperarm
		if not SERVER then return end

		target:SetNWBool('isHandcuffed', true)
		target:EmitSound('glorifiedhandcuffs/handcuffed.wav')

		target:SetWalkSpeed(rp.cfg.WalkSpeed/2.5)
		target:SetRunSpeed(rp.cfg.RunSpeed/2.5)

		target.HandcuffedWeapons = {}
		target.HandcuffedWeaponAmmo = {}
		target.HandcuffedWeaponAmmoType = {}

		local weps = target:GetWeapons()

		for i, v in ipairs(weps) do
			target.HandcuffedWeapons[i] = {v:GetClass(),v.donate}
			target.HandcuffedWeaponAmmo[v:GetPrimaryAmmoType()] = target:GetAmmoCount( v:GetPrimaryAmmoType() )
		end

		target:StripWeapons()


		plogs.PlayerLog(self.Owner, 'Наручники', self.Owner:NameID() .. ' надел стяжки ' .. target:NameID(), {
			['Name'] 	= self.Owner:Name(),
			['SteamID']	= self.Owner:SteamID(),
		})
	end
end


function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end

	local target = self.Owner:getEyeSightHitEntity(nil, nil, function(tar)
		return getEyeSightHitEntityDefaultFilter(tar) and true
	end)

	if not IsValid(target) then return end

	if (not IsValid(target)) then return end
	if (not target:IsPlayer()) then return end
	if target:InVehicle() then target:ExitVehicle() end

	if (self:GetOwner():EyePos():Distance(target:GetPos()) < 250) and (target:GetNWBool('isHandcuffed') == true) then

		self:GiveHandcuffWeaponsBack(target)
		self:GiveHandcuffWeaponAmmoBack(target)

		target:ManipulateBoneAngles(target:LookupBone('ValveBiped.Bip01_L_UpperArm'), Angle(0, 0, 0)) -- Left UpperArm
		target:ManipulateBoneAngles(target:LookupBone('ValveBiped.Bip01_L_Forearm'), Angle(0, 0, 0)) -- Left ForeArm
		target:ManipulateBoneAngles(target:LookupBone('ValveBiped.Bip01_L_Hand'), Angle(0, 0, 0)) -- Left Hand
		target:ManipulateBoneAngles(target:LookupBone('ValveBiped.Bip01_R_Forearm'), Angle(0, 0, 0)) -- Right Forearm
		target:ManipulateBoneAngles(target:LookupBone('ValveBiped.Bip01_R_Hand'), Angle(0, 0, 0)) -- Right Hand
		target:ManipulateBoneAngles(target:LookupBone('ValveBiped.Bip01_R_UpperArm'), Angle(0, 0, 0)) -- Right Upperarm

		if not SERVER then return end
		target:SetNWBool('isHandcuffed', false)
		target:SwitchToDefaultWeapon()

		target:SetWalkSpeed(100)
		target:SetRunSpeed(280)


		plogs.PlayerLog(self.Owner, 'Наручники', self.Owner:NameID() .. ' снял стяжки ' .. target:NameID(), {
			['Name'] 	= self.Owner:Name(),
			['SteamID']	= self.Owner:SteamID(),
		})
	end
end

function SWEP:GiveHandcuffWeaponsBack(pl)
	if not SERVER then return end
	for i, v in ipairs(pl.HandcuffedWeapons) do
		if v[2] == true then pl:Give(v[1], true).donate=true else pl:Give(v[1], true) end
	end
end

function SWEP:GiveHandcuffWeaponAmmoBack(pl)
	if not SERVER then return end
	for k, v in pairs(pl.HandcuffedWeaponAmmo) do
		pl:SetAmmo(v, k)
	end
end

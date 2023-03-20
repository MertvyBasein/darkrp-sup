if SERVER then
	AddCSLuaFile()

	util.AddNetworkString "lockpick_time"
end
if CLIENT then
	SWEP.PrintName = "Отмычка"
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Instructions = "Left click to pick a lock"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = Model('models/weapons/v_crowbar.mdl')
SWEP.WorldModel = Model('models/weapons/w_crowbar.mdl')

SWEP.Spawnable = true
SWEP.Category = "RP"

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""
SWEP.LockPickTime = 30

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

if CLIENT then
	net.Receive("lockpick_time", function(len)
		local wep = net.ReadEntity()
		local time = net.ReadUInt(32)
		wep.LockPickTime = time
		wep.EndPick = CurTime() + time
	end)
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 2)

	if self.IsLockPicking then return end

	local trace = self.Owner:GetEyeTrace()
	local e = trace.Entity

	if (not IsValid(e)) or trace.HitPos:Distance(self.Owner:GetShootPos()) > 100 then
		return
	end


	--if not e.FadingDoor then if (e:GetNetVar('DoorData') == false)  then return end end

	-- if not e.FadingDoor then
	-- 	if (not e:IsDoor()) or (not e:GetPropertyInfo()) then return end
	-- end

	if not e:IsPlayer() and e:IsDoor() then

	self.LockPickTime = 20

	self.IsLockPicking = true


	self.StartPick = CurTime()
	if SERVER then
		net.Start("lockpick_time")
			net.WriteEntity(self)
			net.WriteUInt(self.LockPickTime, 32)
		net.Send(self.Owner)
	end

	self.EndPick = CurTime() + self.LockPickTime

	self:SetHoldType("pistol")

	if SERVER then
		timer.Create("LockPickSounds", 1, self.LockPickTime, function()
			if not IsValid(self) then return end
			local snd = {1,3,4}
			self:EmitSound("weapons/357/357_reload".. tostring(snd[math.random(1, #snd)]) ..".wav", 50, 100)
		end)
	elseif CLIENT then
		self.Dots = self.Dots or ""
		timer.Create("LockPickDots", 0.5, 0, function()
			if not self:IsValid() then timer.Destroy("LockPickDots") return end
			local len = string.len(self.Dots)
			local dots = {[0]=".", [1]="..", [2]="...", [3]=""}
			self.Dots = dots[len]
		end)
	end


	if IsValid(self.Owner) and self.Owner:GetTeamTable().lockpicktime then
		self.LockPickTime = 20 * self.Owner:GetTeamTable().lockpicktime
	else
		self.LockPickTime = 20
	end
	local door_owner = " двери Неизвестно"

	hook.Call('PlayerStartLockpicking', nil, self.Owner, door_owner)

	self.IsLockPicking = true
	self.StartPick = CurTime()
	if SERVER then
		net.Start("lockpick_time")
			net.WriteEntity(self)
			net.WriteUInt(self.LockPickTime, 32)
		net.Send(self.Owner)
	end

	self.EndPick = CurTime() + self.LockPickTime

	self:SetHoldType("pistol")

	if SERVER then
		timer.Create("LockPickSounds", 1, self.LockPickTime, function()
			if not IsValid(self) then return end
			local snd = {1,3,4}
			self:EmitSound("weapons/357/357_reload".. tostring(snd[math.random(1, #snd)]) ..".wav", 50, 100)
		end)
	elseif CLIENT then
		self.Dots = self.Dots or ""
		timer.Create("LockPickDots", 0.5, 0, function()
			if not self:IsValid() then timer.Destroy("LockPickDots") return end
			local len = string.len(self.Dots)
			local dots = {[0]=".", [1]="..", [2]="...", [3]=""}
			self.Dots = dots[len]
		end)
	end

	end

	if e:GetNWBool('IsFadingDoor') == false and e:GetNetVar('DoorData') == nil and not e:GetNWBool('JSRestrained') then return end

	self.LockPickTime = 20

	self.IsLockPicking = true


	self.StartPick = CurTime()
	if SERVER then
		net.Start("lockpick_time")
			net.WriteEntity(self)
			net.WriteUInt(self.LockPickTime, 32)
		net.Send(self.Owner)
	end

	self.EndPick = CurTime() + self.LockPickTime

	self:SetHoldType("pistol")

	if SERVER then
		timer.Create("LockPickSounds", 1, self.LockPickTime, function()
			if not IsValid(self) then return end
			local snd = {1,3,4}
			self:EmitSound("weapons/357/357_reload".. tostring(snd[math.random(1, #snd)]) ..".wav", 50, 100)
		end)
	elseif CLIENT then
		self.Dots = self.Dots or ""
		timer.Create("LockPickDots", 0.5, 0, function()
			if not self:IsValid() then timer.Destroy("LockPickDots") return end
			local len = string.len(self.Dots)
			local dots = {[0]=".", [1]="..", [2]="...", [3]=""}
			self.Dots = dots[len]
		end)
	end


	if IsValid(self.Owner) and self.Owner:GetTeamTable().lockpicktime then
		self.LockPickTime = 20 * self.Owner:GetTeamTable().lockpicktime
	else
		self.LockPickTime = 20
	end
	local door_owner = " двери Неизвестно"

	hook.Call('PlayerStartLockpicking', nil, self.Owner, door_owner)

	self.IsLockPicking = true
	self.StartPick = CurTime()
	if SERVER then
		net.Start("lockpick_time")
			net.WriteEntity(self)
			net.WriteUInt(self.LockPickTime, 32)
		net.Send(self.Owner)
	end

	self.EndPick = CurTime() + self.LockPickTime

	self:SetHoldType("pistol")

	if SERVER then
		timer.Create("LockPickSounds", 1, self.LockPickTime, function()
			if not IsValid(self) then return end
			local snd = {1,3,4}
			self:EmitSound("weapons/357/357_reload".. tostring(snd[math.random(1, #snd)]) ..".wav", 50, 100)
		end)
	elseif CLIENT then
		self.Dots = self.Dots or ""
		timer.Create("LockPickDots", 0.5, 0, function()
			if not self:IsValid() then timer.Destroy("LockPickDots") return end
			local len = string.len(self.Dots)
			local dots = {[0]=".", [1]="..", [2]="...", [3]=""}
			self.Dots = dots[len]
		end)
	end
end

function SWEP:Holster()
	self.IsLockPicking = false
	if SERVER then timer.Destroy("LockPickSounds") end
	if CLIENT then timer.Destroy("LockPickDots") end
	return true
end

function SWEP:Succeed()
	self.IsLockPicking = false
	self:SetHoldType("normal")
	local trace = self.Owner:GetEyeTrace()
	if IsValid(trace.Entity) and not trace.Entity:IsPlayer() and trace.Entity:IsDoor() then
		hook.Call("PlayerLockpick", nil, self.Owner)
		if SERVER then
			trace.Entity:Fire('Unlock')
			trace.Entity:Fire('Open')
		end
		return
	end
	if IsValid(trace.Entity) and trace.Entity.Fire and not trace.Entity:IsPlayer() then

		if not trace.Entity.FadingDoor then

			if (trace.Entity.Locked) then
				trace.Entity.PickedAt = CurTime()
			end
			trace.Entity:DoorLock(not trace.Entity.Locked)
			trace.Entity:Fire("open", "", .6)
			trace.Entity:Fire("setanimation","open",.6)
		else
			trace.Entity:Fade()
			trace.Entity.fd_block = CurTime() + 45
			
			timer.Create("FadingDoorUnFade_"..trace.Entity:EntIndex(), 45, 1, function()
				if not IsValid(trace.Entity) then return end
				if not trace.Entity.Faded then return end
				trace.Entity:UnFade()
			end)
			local name =  IsValid(trace.Entity:CPPIGetOwner()) and trace.Entity:CPPIGetOwner():Name() or ' Неизвестно'
			door_owner = " FD игрока " .. name
		end

		hook.Call('PlayerFinishLockpicking', nil, self.Owner, door_owner, true)
		--hook.Call('SuperSecuritySystem', nil, true, trace.Entity, owner)

	end
	if SERVER then timer.Destroy("LockPickSounds") end
	if CLIENT then timer.Destroy("LockPickDots") end
end

function SWEP:Fail()
	self.IsLockPicking = false
	self:SetHoldType("normal")

	hook.Call('PlayerFinishLockpicking', nil, self.Owner, nil, false)
	if SERVER then timer.Destroy("LockPickSounds") end
	if CLIENT then timer.Destroy("LockPickDots") end
end

function SWEP:Think()
	if self.IsLockPicking then
		local trace = self.Owner:GetEyeTrace()
		if not IsValid(trace.Entity) then
			self:Fail()
		end
		if trace.HitPos:Distance(self.Owner:GetShootPos()) > 100 and not trace.Entity.FadingDoor then
			self:Fail()
		end
		if self.EndPick <= CurTime() then
			if trace.Entity:IsPlayer() and trace.Entity:isRestrained() then
				if SERVER then
					timer.Destroy("LockPickSounds")
					trace.Entity:UnrestrainPlayer(true)
					rp.Notify(trace.Entity, NOTIFY_SUCCESS, 'Вы были освобождены!')
				end
				if CLIENT then timer.Destroy("LockPickDots") end
			else
				self:Succeed()
			end
		end
	end
end

function SWEP:DrawHUD()
	if self.IsLockPicking then
		self.Dots = self.Dots or ""

		local x, y = (ScrW() / 2) - 150, (ScrH() / 2) - 25
		local w, h  = 300, 50

		local time = self.EndPick - self.StartPick
		local status = (CurTime() - self.StartPick)/time

		--rp.ui.DrawProgressBar(x, y, w, h, status, Color(0, 0, 0, 175), Color(0, 0, 0, 150), Color(0, 0, 0, 100))
		--draw.SimpleTextOutlined("Взлом"..self.Dots, "ui.26", ScrW()/2, ScrH()/2, ui.col.White, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, ui.col.Black)

		MetaHubDrawProgress(x, y, w, h-10, status)
		frametext("Взлом"..self.Dots, GetFont(10), ScrW()*.5, ScrH()*.5-5, Color(255,255,255,255), 1, 1)

	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end

function SWEP:DrawWorldModel()
	if (!IsValid(self.Owner)) then return end -- ?

	if (not self.Hand) then
		self.Hand = self.Owner:LookupAttachment("anim_attachment_rh")
	end

	if (not self.Hand) then
		self:DrawModel()
		return
	end

	local hand = self.Owner:GetAttachment(self.Hand)

	if hand then
		self:SetRenderOrigin(hand.Pos + (hand.Ang:Right() * 5.5) + (hand.Ang:Up() * -1.5))

		hand.Ang:RotateAroundAxis(hand.Ang:Right(), 90)
		hand.Ang:RotateAroundAxis(hand.Ang:Up(), 180)

		self:SetRenderAngles(hand.Ang)
	end

	self:DrawModel()
end

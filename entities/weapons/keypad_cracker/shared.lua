AddCSLuaFile()

if(SERVER) then
	util.AddNetworkString("KeypadCracker_Hold")
	util.AddNetworkString("KeypadCracker_Sparks")
end

if(CLIENT) then
	SWEP.PrintName = "Keypad Cracker"
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.Instructions = "Left click to crack keypad"

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/v_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")

SWEP.Spawnable = true
SWEP.Category = "RP"
SWEP.AnimPrefix = "python"

SWEP.Sound = Sound("weapons/deagle/deagle-1.wav")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.KeyCrackTime = 30
SWEP.KeyCrackSound = Sound("buttons/blip2.wav")

SWEP.IdleStance = "slam"

function SWEP:Initialize()
	self:SetHoldType(self.IdleStance)

	if(SERVER) then
		net.Start("KeypadCracker_Hold")
			net.WriteEntity(self)
			net.WriteBit(true)
		net.Broadcast()
	else
		self.NextLine = 0
		self.Lines = {}
		self.ToDel = {}
	end
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.4)

	if IsValid(self.Owner) and self.Owner:GetTeamTable().keypadcracktime then
		self.KeyCrackTime = 30 * self.Owner:GetTeamTable().keypadcracktime
	else
		self.KeyCrackTime = 30
	end

	if(self.IsCracking or not IsValid(self.Owner)) then return end

	local tr = self.Owner:GetEyeTrace()
	local ent = tr.Entity

	if(IsValid(ent) and tr.HitPos:Distance(self.Owner:GetShootPos()) <= 50 and ent:GetClass() == "keypad") then
		self.IsCracking = true
		self.StartCrack = CurTime()
		self.EndCrack = CurTime() + self.KeyCrackTime

		self:SetHoldType("pistol") -- TODO: Send as networked message for other clients to receive


		if(SERVER) then
			net.Start("KeypadCracker_Hold")
				net.WriteEntity(self)
				net.WriteBit(true)
			net.Broadcast()

			timer.Create("KeyCrackSounds: "..self:EntIndex(), 1, self.KeyCrackTime, function()
				if(IsValid(self) and self.IsCracking) then
					self:EmitSound(self.KeyCrackSound, 50, 100)
				end
			end)
		else
			self.Dots = self.Dots or ""

			local entindex = self:EntIndex()
			timer.Create("KeyCrackDots: "..entindex, 0.5, 0, function()
				if(not IsValid(self)) then
					timer.Destroy("KeyCrackDots: "..entindex)
				else
					local len = string.len(self.Dots)
					local dots = {[0] = ".", [1] = "..", [2]= "...", [3] = ""}

					self.Dots = dots[len]
				end
			end)
		end
		hook.Call('PlayerStartKeypadCrack', nil, self.Owner, tr.Entity)
	end
end

function SWEP:Holster()
	self.IsCracking = false

	if(SERVER) then
		timer.Destroy("KeyCrackSounds: "..self:EntIndex())
	else
		timer.Destroy("KeyCrackDots: "..self:EntIndex())
	end

	return true
end

function SWEP:Reload()
	return true
end

function SWEP:Succeed()
	self.IsCracking = false

	local tr = self.Owner:GetEyeTrace()
	local ent = tr.Entity
	self:SetHoldType(self.IdleStance)

	if SERVER and IsValid(ent) and (tr.HitPos:Distance(self.Owner:GetShootPos()) <= 50) and (ent:GetClass() == "keypad") then
		hook.Call("PlayerKeypadCrack", nil, self.Owner)

		ent:Process(true)

		net.Start("KeypadCracker_Hold")
			net.WriteEntity(self)
			net.WriteBit(true)
		net.Broadcast()

		net.Start("KeypadCracker_Sparks")
			net.WriteEntity(ent)
		net.Broadcast()

		hook.Call('PlayerFinishKeypadCrack', nil, self.Owner, ent)
	end

	if(SERVER) then
		timer.Destroy("KeyCrackSounds: "..self:EntIndex())
	else
		timer.Destroy("KeyCrackDots: "..self:EntIndex())
	end
end

function SWEP:Fail()
	self.IsCracking = false

	self:SetHoldType(self.IdleStance)

	if(SERVER) then
		net.Start("KeypadCracker_Hold")
			net.WriteEntity(self)
			net.WriteBit(true)
		net.Broadcast()

		timer.Destroy("KeyCrackSounds: "..self:EntIndex())
	else
		timer.Destroy("KeyCrackDots: "..self:EntIndex())
	end
end

function SWEP:Think()
	if (not self.StartCrack) or (not self.EndCrack) then
		self.StartCrack = 0
		self.EndCrack = 0
	end

	if(self.IsCracking and IsValid(self.Owner)) then
		local tr = self.Owner:GetEyeTrace()

		if(not IsValid(tr.Entity) or tr.HitPos:Distance(self.Owner:GetShootPos()) > 50 or tr.Entity:GetClass() ~= "keypad") then
			self:Fail()
		elseif(self.EndCrack <= CurTime()) then
			self:Succeed()
		end
	else
		self.StartCrack = 0
		self.EndCrack = 0
	end

	self:NextThink(CurTime())
	return true
end

if(CLIENT) then
	local off = Vector(15.43, 1.28, -2.63)
	function SWEP:PostDrawViewModel(vm, wep, pl)
		local pos = vm:GetPos()
		local ang = vm:GetAngles()
		ang:RotateAroundAxis(ang:Up(), 85.12)
		ang:RotateAroundAxis(ang:Right(), -179.11)
		ang:RotateAroundAxis(ang:Forward(), -132.35)

		local w, h = 475, 295
		local st = SysTime()

		for k, v in ipairs(self.ToDel or {}) do
			if (!self.Lines[v - (k - 1)]) then break end

			table.remove(self.Lines, v - (k - 1))
		end
		table.Empty(self.ToDel)

		if (self.IsCracking) then
			if (SysTime() > self.NextLine) then
				self.NextLine = SysTime() + math.Rand(0, 0.15)
				for i=1, math.random(math.Clamp(500 - #self.Lines, 0, 50)) do
					table.insert(self.Lines, {
						w = math.random(50),
						y = math.random(h),
						st = SysTime(),
						spd = math.Rand(1, 2)
					})
				end
			end
		end

		cam.Start3D2D(vm:LocalToWorld(off), ang, 0.005)
			surface.SetDrawColor(255, 255, 255)
			surface.SetFont("ui.40")
			if (!self.IsCracking) then
				self.WordOfTheDay = nil
				surface.SetTextColor(255, 255, 255)
				local txt = "Готов к взлому!"
				local tw = surface.GetTextSize(txt)
				surface.SetTextPos((w - tw) * 0.5, 145)
				surface.DrawText(txt)
			else
				if (!self.WordOfTheDay) then
					if (math.random(100) % 5 < 3) then -- verb noun
						self.WordOfTheDay = "Взлом Кейпада!"
					else -- other meme
						self.WordOfTheDay = table.Random({"keypad:Crack()", "SELECT `passKey`", "sudo rm -rf /", "Подбор пароля", "SELECT 'password'"})
					end
				end

				self.StartCrack = self.StartCrack or CurTime()

				if (self.EndCrack) then
					local x, y = (w / 2) - 175, 140
					rp.ui.DrawProgress(x, y, 350, 50, (CurTime() - self.StartCrack) / (self.EndCrack - self.StartCrack), true)
				end

				local tw = surface.GetTextSize(self.WordOfTheDay)
				surface.SetTextPos((w - tw) * 0.5, 145)
				local bw = 125 - (math.sin(st * math.pi * 2) * 125)
				surface.SetTextColor(bw, bw, bw)
				surface.DrawText(self.WordOfTheDay)
			end
		cam.End3D2D()
	end

	function SWEP:DrawHUD()
	end

	SWEP.UpAngle = Angle(8, 0, 0)

	SWEP.UpperPercent = 1
	SWEP.SwayScale = 0

	function SWEP:GetViewModelPosition(pos, ang)
		if(self.IsCracking) then
			local delta = FrameTime() * 1
			self.UpperPercent = math.Clamp(self.UpperPercent + delta, 0, 1)
		else
			local delta = FrameTime() * 1.75
			self.UpperPercent = math.Clamp(self.UpperPercent - delta, 0, 1)
		end

		ang:RotateAroundAxis(ang:Forward(), self.UpAngle.p * self.UpperPercent)
		ang:RotateAroundAxis(ang:Right(), self.UpAngle.p * self.UpperPercent)
		return self.BaseClass.GetViewModelPosition(self, pos, ang)
	end

	net.Receive("KeypadCracker_Hold", function()
		local ent = net.ReadEntity()
		local state = (net.ReadBit() == 1)

		if(IsValid(ent) and ent:IsWeapon() and ent:GetClass() == "keypad_cracker" and (not game.SinglePlayer()) and ent.SetHoldType) then
			if(not state) then
				ent:SetHoldType(ent.IdleStance)
				ent.IsCracking = false
			else
				ent:SetHoldType("pistol")
				ent.IsCracking = true
			end
		end
	end)

	net.Receive("KeypadCracker_Sparks", function()
		local ent = net.ReadEntity()

		if(IsValid(ent)) then
			local vPoint = ent:GetPos()
			local effect = EffectData()
			effect:SetStart(vPoint)
			effect:SetOrigin(vPoint)
			effect:SetEntity(ent)
			effect:SetScale(2)
			util.Effect("cball_bounce", effect)

			ent:EmitSound("buttons/combine_button7.wav", 100, 100)
		end
	end)
end
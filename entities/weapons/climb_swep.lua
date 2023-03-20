SWEP.Distance = 75
SWEP.Count = 8
SWEP.RefreshRate = 1
SWEP.PushDistance = 100
SWEP.AllowedWeaponTypes = {
	['pistol'] = true,
	['melee'] = true,
	['melee2'] = true,
	['knife'] = true
}
SWEP.Cooldown = 1

if (SERVER) then
	AddCSLuaFile()

	SWEP.Weight = 0
	SWEP.AutoSwitchFrom = false
	SWEP.AutoSwitchTo = false

	util.AddNetworkString('ShouldRoll')
	util.AddNetworkString('ShouldSlide')

else
	SWEP.PrintName = 'Паркур'
	SWEP.Slot = 2
	SWEP.SlotPos = 2
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = ''
SWEP.Purpose = 'To Climb'
SWEP.Instructions = 'Jump with left click\nHold/let go with right click\nPush with left click\nRoll with reload'
SWEP.Category = 'RP'

SWEP.Spawnable = true
SWEP.ViewModel = 'models/weapons/v_hands.mdl'
SWEP.WorldModel = 'models/weapons/w_hands.mdl'

SWEP.Base = 'weapon_rp_base'

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = 'none'

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = 'none'

SWEP.HoldType = 'normal'


if (CLIENT) then
	local mat = Material('icon16/add.png')
	local lasttime = os.time()
	function SWEP:DrawHUD()
 		if (self.Owner != LocalPlayer()) then return end

		local count = self.Owner:GetNetVar('Jumps', 0) or 0

		surface.SetDrawColor(Color(255, 255, 255))
		surface.SetMaterial(mat)
		local m = self.Count * 32 //max width, so we can just subtract #yolo
		for i=1, count do
			local x = i * 32

			surface.DrawTexturedRect(ScrW() - x, ScrH() - 42, 32, 32)
		end

		if (count == self.Count or self.Owner:GetNetVar('IsHolding', 0) == 1) then return end

		local progress = os.time() - lasttime
		if ((os.time() - lasttime) >= self.RefreshRate) then
			lasttime = os.time()
		end
	end

	local roll = false
	local pi, tp = 0, 0
	net.Receive('ShouldRoll', function()
		roll = true
		tp = LocalPlayer():EyeAngles().p
		pi = tp - 360
	end)

	local orig, sliding = false, false
	local origa, s1, s2 = 0, 0, 0
	net.Receive('ShouldSlide', function()
		sliding = net.ReadBool()
		origa = LocalPlayer():EyeAngles().p
		s1 = LocalPlayer():EyeAngles().p
		s2 = 90
	end)

	hook.Add('CalcView', 'DoTheROll', function(ply, pos, ang, fov)
		if (roll) then
			local view = GAMEMODE:CalcView(ply, pos, ang, fov)
			pi = math.Approach(pi, tp, FrameTime() * 625)
			if (pi == tp) then roll = false end
			view.angles.p = pi
			return view
		end

		if (sliding) then //start effect
			orig = true

			local view = GAMEMODE:CalcView(ply, pos, ang, fov)
			s1 = math.Approach(s1, s2, FrameTime() * 625)
			view.angles.p = s1
			return view
		end

		if (sliding != orig) then //end effect
			local view = GAMEMODE:CalcView(ply, pos, ang, fov)
			s1 = math.Approach(s1, origa, FrameTime() * 625)
			if (s1 == origa) then sliding = false orig = false end
			view.angles.p = s1
			return view
		end
	end)

else

	function SWEP:ResetVelocity()
		self.Owner:SetLocalVelocity(Vector(0, 0, 0))
	end

	function SWEP:IsOnWall()

		if (!IsValid(self.Owner)) then return false end
		if (self.Owner.IsHolding) then return true end

		local tr = self.Owner:GetEyeTrace()//util.TraceLine(trace)
		if (IsValid(tr.Entity) and tr.Entity:IsPlayer()) then  return false end
		if (tr.HitPos:DistToSqr(self.Owner:EyePos()) <= math.pow(self.Distance, 2)) then  return true end


		return false
	end

	function SWEP:CanJump()
		if (!IsValid(self.Owner) or self.Owner:OnGround()) then return false end
		local ang = self.Owner:EyeAngles()
		if (ang.p > 0) then return false end

		self.LastUsed = self.LastUsed or os.time()
		if ((os.time() - self.LastUsed) >= self.Cooldown and self.Owner.Count > 0 and self:IsOnWall()) then
			self.LastUsed = os.time()
			return true
		end

		return false
	end

	local lasttime = os.time()
	function SWEP:Think()
		if (!IsValid(self.Owner)) then return end

		if (self.Owner.IsHolding) then
			if (self.Owner:KeyPressed(IN_JUMP)) then //jump off
				self.Owner.IsHolding = false
				if (self.Owner:GetNetVar('IsHolding') ~= 0) then
					self.Owner:SetNetVar('IsHolding', 0)
				end
				self.Owner:SetMoveType(MOVETYPE_WALK)
				self:ResetVelocity()
			elseif (self.Owner:KeyPressed(IN_SPEED)) then //slide
				self.Owner.IsHolding = false
				if (self.Owner:GetNetVar('IsHolding') ~= 0) then
					self.Owner:SetNetVar('IsHolding', 0)
				end
				self.Owner:SetMoveType(MOVETYPE_WALK)
				self:ResetVelocity()
				self.Owner:EmitSound(Sound('npc/zombie/foot_slide1.wav'))

				self.Owner.IsSliding = true
				net.Start('ShouldSlide')
					net.WriteBool(true)
				net.Send(self.Owner)
			end
		end

		if (self.Owner.Count == self.Count or self.Owner.IsHolding or self.Owner.InJump or self.Owner.IsSliding or !self.Owner:IsOnGround()) then return end

		self.Lasttime = self.Lasttime or os.time()
		local progress = os.time() - self.Lasttime
		if ((os.time() - self.Lasttime) >= self.RefreshRate) then
			self.Lasttime = os.time()

			self.Owner.Count = self.Owner.Count + 1
			self.Owner:SetNetVar('Jumps', self.Owner.Count)
		end
	end

	hook.Add('OnPlayerHitGround', 'DoRoll', function(ply)
		if (ply.ShouldRoll) then
			net.Start('ShouldRoll')
			net.Send(ply)

			timer.Simple(2, function()
				ply.ShouldRoll = false
			end)
		end

		if (ply.IsSliding) then
			net.Start('ShouldSlide')
				net.WriteBool(false)
			net.Send(ply)

			timer.Simple(2, function()
				ply.IsSliding = false
			end)
		end

		ply.IsHolding = false
		ply.InJump = false
	end)

	hook.Add('GetFallDamage', 'StopRollSlideDamage', function(ply, hit, dmg)
		if (ply.IsSliding or ply.ShouldRoll) then
			return 0
		end
	end)

	hook.Add('PlayerDeath', 'StopStuck', function(ply)
		ply.IsHolding = false
		if (ply:GetNetVar('IsHolding') ~= 0) then
			ply:SetNetVar('IsHolding', 0)
		end
		ply:SetMoveType(MOVETYPE_WALK)
	end)

	hook.Add('PlayerSpawn', 'SetCOunt', function(ply)
		ply.Count = 5
	end)

	hook.Add('KeyPress', 'DropPlayer', function(ply, key)
		if (!IsFirstTimePredicted()) then return end

		if (ply.IsHolding and key == IN_JUMP) then
			ply.IsHolding = false
			if (ply:GetNetVar('IsHolding') ~= 0) then
				ply:SetNetVar('IsHolding', 0)
			end
			ply:SetMoveType(MOVETYPE_WALK)
			//self:ResetVelocity()
		end
	end)
	hook.Remove('ShouldCollide', 'CHeckIfPlayerIsBeingAWhoreAndHOldingTHemselves')
	/*hook.Add('ShouldCollide', 'CHeckIfPlayerIsBeingAWhoreAndHOldingTHemselves', function(ent1, ent2)
		if (ent1:IsPlayer() and ent1.IsHolding and ent2:GetClass() == 'prop_physics' or ent2:IsPlayer() and ent2.IsHolding and ent1:GetClass() == 'prop_physics') then
			return false
		end
	end)*/
end
function SWEP:Equip()
	if (SERVER) then
		self.Owner.IsHolding = false
		self.Owner:SetNetVar('IsHolding', 0)
		self.Owner:SetMoveType(MOVETYPE_WALK)
		self:ResetVelocity()

		self.Owner.Count = self.Owner.Count or self.Count
		self.Owner:SetNetVar('Jumps', self.Owner.Count)
	end
end

function SWEP:Holster() //for switching
	if (SERVER) then
		self.Owner:DrawViewModel(true)

		if (!self.Owner.IsHolding) then
			self.Owner:DropToFloor()
		end
	end

	return true
end

function SWEP:PrimaryAttack()
	if (SERVER) then
		if (!IsFirstTimePredicted()) then return end

		local tr = self.Owner:GetEyeTrace()
		if (tr.Entity and tr.Entity:IsPlayer() and tr.Entity.IsHolding and (tr.Entity:GetPos():DistToSqr(self.Owner:GetPos()) <= math.pow(self.PushDistance, 2))) then
			tr.Entity:SetNetVar('IsHolding', 0)
			tr.Entity.IsHolding = false
			self.Owner:SetMoveType(MOVETYPE_WALK)
			self:ResetVelocity()

			return
		end

		if (!self:CanJump()) then  return end

		if (IsValid(tr.Entity) and tr.Entity:IsPlayer() or tr.Entity:IsVehicle()) then  return end

		self.Owner.Count = self.Owner.Count - 1
		self.Owner:SetNetVar('Jumps', self.Owner.Count)

		self.Owner.IsHolding = false
		self.Owner:SetNetVar('IsHolding', 0)
		self.Owner:SetMoveType(MOVETYPE_WALK)
		self:ResetVelocity()

		self.Owner:EmitSound(Sound('npc/combine_soldier/gear4.wav'), 75, 100)
		self.Owner:ViewPunch(Angle(-10, 0, 0))
		self.Owner:SetLocalVelocity(self.Owner:GetVelocity() * -1) //reset

		self.Owner:SetLocalVelocity(self.Owner:GetAimVector() * 440)
			//self.Owner:SetLocalVelocity((self.Owner:GetForward() * self.Owner:GetJumpPower()) + Vector(0, 0, self.Owner:GetJumpPower()))
		self.Owner.InJump = true
	end
end

function SWEP:SecondaryAttack()
	if (SERVER) then
		if (!IsFirstTimePredicted()) then return end

		if (self.Owner:IsOnGround() or !IsValid(self.Owner)) then return end

		local tr = self.Owner:GetEyeTrace()
		if (!self.Owner.IsHolding) then
			if (tr.HitPos:DistToSqr(self.Owner:GetPos()) > math.pow(self.Distance, 2)) then  return end
		end

		if (tr.Entity and tr.Entity:IsPlayer()) then  return end

		self.Owner.IsHolding = !self.Owner.IsHolding

		local int = self.Owner.IsHolding and 1 or 0
		if (int == 1) then
			self.Owner:ViewPunch(Angle(10, 0, 0))
			self.Owner:SetCustomCollisionCheck(true)


			self.Owner.MoveType = self.Owner:GetMoveType()
			self.Owner:SetMoveType(MOVETYPE_NONE)

			if (IsValid(tr.Entity) and tr.Entity:GetClass() == 'prop_physics') then
				self.Owner.HoldingOnto = tr.Entity:EntIndex()
				self.Owner.LastEntityPos = tr.Entity:GetPos()
			end
		else

			self.Owner:SetMoveType(MOVETYPE_WALK)
			self:ResetVelocity()
			self.Owner:SetCustomCollisionCheck(false)
		end

			//self.Owner:SetNetVar('IsHolding', int)
		self.Owner.InJump = !self.Owner.IsHolding
	end
end

function SWEP:Reload()
	if (SERVER) then
		if (!IsFirstTimePredicted()) then return end

		if (self.Owner.InJump) then
			self.Owner.ShouldRoll = !self.Owner.ShouldRoll
		end
	end

	return true
end

function SWEP:Deploy()
	self.Owner:DrawViewModel(false)
end

function SWEP:DrawWorldModel()
	return false
end

function SWEP:DrawViewModel()
	return false
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:DrawShadow(false)

	self.Count = hook.Call('GetClimbs', GAMEMODE, self.Owner) or self.Count
end

/*hook.Add('Move', 'ShouldChangePosition', function(ply, data)
	if (ply:GetNetVar('IsHolding', 0) == 1) then
		data:SetLocalVelocity(Vector(0, 0, 0))
		return true
	end
end)*/

hook.Add('PlayerSwitchWeapon', 'AllowSwitchingWhenOnLedge', function(pl, wep1, wep2)
	if IsValid(pl) and IsValid(wep1) and IsValid(wep2) and pl.IsHolding and (wep1:GetClass() == 'weapon_climb') then
		if (not wep1.AllowedWeaponTypes[(wep2:GetHoldType() or 'normal')]) then
			return true
		end
	end
end)

nw.Register 'IsHolding'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetLocalPlayer()

nw.Register 'Jumps'
	:Write(net.WriteUInt, 8)
	:Read(net.ReadUInt, 8)
	:SetLocalPlayer()
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


function SWEP:TurnOff()
	self:SetActivated(false)

	local sequence = "deactivatebaton"
	self:SetHoldType("normal")
	self.Owner:EmitSound("weapons/stunstick/spark"..math.random(1, 2)..".wav", 100, math.random(90, 110))
	self:SetNW2Bool("Angry", false)
end

function SWEP:TurnOn()
	self:SetActivated(true)

	local sequence = "activatebaton"
	self.Owner:EmitSound("weapons/stunstick/spark3.wav", 100, math.random(90, 110))
	self:SetHoldType("grenade")
	self:SetNW2Bool("Angry", true)
	--self.Owner:ResetSeq(sequence) -- Если будем делать реплейс на модельку нпс, то это анимация включения палки
end

function SWEP:Reload()
	if self:GetActivated() then
		self:TurnOff()
	end
	return
end

function SWEP:SetMode(num, notify, should)
	local tbl = self.Modes[num]
	self.Damage, self.Stun, self.Power = tbl.dmg, tbl.stun, (tbl.power or 255)
	if notify then
		DarkRP.notify(self.Owner, 0, 4, "Выбран режим " .. tbl.name)
	end
	if should then
		self:TurnOn()
	end
end

netstream.Hook("Stunstick.ChangeMode", function(ply, mode)
	if not IsValid(ply:GetActiveWeapon()) or ply:GetActiveWeapon():GetClass() ~= "mp_stunstick" then
		return
	end
	local wep = ply:GetActiveWeapon()
	if not wep.Modes[mode] then
		mode = 1
	end
	wep:SetMode(mode, true, true)
end)

hook.Remove("OnPlayerChangedTeam", "MP.SetNoStuck", function(ply, old, new)
	local tbl = RPExtraTeams[new]
	ply:SetNetVar("NoStun", tbl.nostun)
end)
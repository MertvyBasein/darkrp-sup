PLAYER.SteamName = PLAYER.SteamName or PLAYER.Name

function PLAYER:Name()
	return (IsValid(self) and (self:GetNetVar('Name') or self:SteamName()) or "Unknown")
end
PLAYER.Nick 	= PLAYER.Name
PLAYER.GetName 	= PLAYER.Name

function PLAYER:GetMoney()
	return (self:GetNetVar('Money') or rp.cfg.StartMoney)
end

function PLAYER:GetCredits()
	return (self:GetNetVar('Credits') or 0)
end

local math_round 	= math.Round
local math_max 		= math.max
local CurTime 		= CurTime

function PLAYER:GetHunger()
	return self:Alive() and math_max(math_round((((self:GetNetVar('Energy') or (CurTime() + rp.cfg.HungerRate)) - CurTime()) / rp.cfg.HungerRate) * 100, 0), 0) or 100
end

local math_floor 	= math.floor
local math_min 		= math.min
function PLAYER:Wealth(min, max)
	return math_min(math_floor(min + ((max - min) * (self:GetMoney()/25000000))), max)
end

function PLAYER:HasLicense()
	return (self:GetNetVar('HasGunlicense') or self:GetJobTable().hasLicense)
end

function PLAYER:GetPlayTime()
	return self:GetNetVar('TotalTime') or 0
end

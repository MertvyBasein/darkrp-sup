function PLAYER:CanAfford(amount)
	if SERVER and (not rp.data.IsLoaded(self)) then return false end

	if amount then
		amount = math.floor(amount)
		return (amount >= 0) and ((self:GetMoney() - amount) >= 0)
	end
	return false
end

local PLAYER = FindMetaTable("Player")

local vipRanks = {
	['superadmin'] = true,
	['manager'] = true,
	['globaladmin'] = true,
	['headadmin'] = true,
	['admin'] = true,
	['moderator'] = true,
	['vip'] = true
}

local premRanks = {
	['superadmin'] = true,
	['manager'] = true,
	['globaladmin'] = true,
	['headadmin'] = true,
	['admin'] = true,
	['moderator'] = true,
	['vip'] = true
}

function PLAYER:isVIP()
    return vipRanks[self:GetUserGroup()]
end

function PLAYER:isPREMIUM()
    return premRanks[self:GetUserGroup()]
end

function PLAYER:InNLRZone()
    if self:Alive() and self:GetNetVar('NLR') then
        return (self:GetPos():Distance(self:GetNetVar('NLR').Pos) < 300)
    end
    return false
end

function PLAYER:GetNLRTime()
    if self:Alive() and self:GetNetVar('NLR') then
        return math.Round(self:GetNetVar('NLR').Time - CurTime(), 0)
    end
end

function SendMsg(msg, stg)
    if stg == 'server' then
        MsgC(Color(137, 222, 255), '[MetaHub] ', Color(137, 222, 255), msg .. '\n')
    elseif stg == 'client' then
        MsgC(Color(137, 222, 255), '[MetaHub] ', Color(255, 222, 102), msg .. '\n')
    elseif stg == 'shared' then
        MsgC(Color(137, 222, 255), '[MetaHub] ', Color(255, 222, 102), msg .. '\n')
    elseif stg == 'plug' then
        MsgC(Color(137, 222, 255), '[MetaHub] ', Color(100, 255, 0), msg .. '\n')
    elseif stg == 'alert' then
        MsgC(Color(137, 222, 255), '[MetaHub] ', Color(225, 0, 0), msg .. '\n')
    end
end
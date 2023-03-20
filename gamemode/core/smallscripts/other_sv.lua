hook.Add('PlayerUse','SuperFadingDoorSystem',function(ply,ent)
	if ent:GetNWBool('fadingfix') == "true" then
		if ent:CPPIGetOwner() == ply then
			ent:Fade()
			timer.Simple(10, function()
				if !IsValid(ent) then return end
				ent:UnFade()
			end)
		end
	end
end)

function viv_use_killing_pills(ply)
	if ply:GetActiveWeapon():IsValid() then
		if ply:HasWeapon( "viv_pills_killed" ) then
			ply:StripWeapon("viv_pills_killed")
			ply:ConCommand("say /me проглатил таблетку")
			if ply:IsValid() then
				ply:Kill()
			end
		end
	end
end

concommand.Add("bpxpadd", function(ply)
	if not ply:IsSuperAdmin() then return end
	ply:SetNWInt("BPXP", ply:GetNWInt("BPXP") + 100)
end)

concommand.Add( "viv_use_killing_pills", function( ply, cmd, args )
	viv_use_killing_pills(ply)
end)

hook.Add("OnPlayerChangedTeam", "BP::CHECKTEAM", function(ply) 
	if ply:Team() == TEAM_HUNTER then hook.Call("PlayerTeamHunter", nil, ply) end

	if ply:Team() == TEAM_CCCR then hook.Call("PlayerPartizan", nil, ply) end

	if rp.teams[ply:Team()].targetname == "Красная Армия" then hook.Call("PlayerArmy", nil, ply) end
end)




-----
local ply = FindMetaTable("Player")
local ent = FindMetaTable("Entity")


local rp    = rp
local REG   = debug.getregistry()
local PLY   = REG.Player -- это хаки
local VEC   = REG.Vector
GAMEMODE    = GM or GAMEMODE or {}
DarkRP      = DarkRP or {}

local function erar(sas)
	print("[DRPFix] " .. sas)
end


function ply:GetAgendaText()
	return nw.GetGlobal('Agenda;' .. self:Team())
end
function DarkRP.setPreferredJobModel(_,model)
	RunConsoleCommand( "model", model )
end
function ply:getEyeSightHitEntity(searchDistance, hitDistance, filter)
    searchDistance = searchDistance or 100
    hitDistance = (hitDistance or 15) * (hitDistance or 15)

    filter = filter or function(p) return p:IsPlayer() and p ~= self end

    self:LagCompensation(true)

    local shootPos = self:GetShootPos()
    local entities = ents.FindInSphere(shootPos, searchDistance)
    local aimvec = self:GetAimVector()

    local smallestDistance = math.huge
    local foundEnt

    for k, ent in pairs(entities) do
        if not IsValid(ent) or filter(ent) == false then continue end

        local center = ent:GetPos()

        -- project the center vector on the aim vector
        local projected = shootPos + (center - shootPos):Dot(aimvec) * aimvec

        if aimvec:Dot((projected - shootPos):GetNormalized()) < 0 then continue end

        -- the point on the model that has the smallest distance to your line of sight
        local nearestPoint = ent:NearestPoint(projected)
        local distance = nearestPoint:DistToSqr(projected)

        if distance < smallestDistance then
            local trace = {
                start = self:GetShootPos(),
                endpos = nearestPoint,
                filter = {self, ent}
            }
            local traceLine = util.TraceLine(trace)
            if traceLine.Hit then continue end

            smallestDistance = distance
            foundEnt = ent
        end
    end

    self:LagCompensation(false)

    if smallestDistance < hitDistance then
        return foundEnt, math.sqrt(smallestDistance)
    end

    return nil
end
function ent:isDoor()
	return self:IsDoor()
end

-----------------------------------------DARKRP-----------------------------------------
function ply:getJobTable()
	for k,v in pairs(rp.teams) do
		if self:GetJob() == k then
			return v
		end
	end
end

local function charWrap(text, pxWidth)
	local total = 0

	text = text:gsub(".", function(char)
		total = total + surface.GetTextSize(char)

		-- Wrap around when the max width is reached
		if total >= pxWidth then
			total = 0
			return "\n" .. char
		end

		return char
	end)

	return text, total
end

function DarkRP.textWrap(text, font, pxWidth)
	local total = 0

	surface.SetFont(font)

	local spaceSize = surface.GetTextSize(' ')
	text = text:gsub("(%s?[%S]+)", function(word)
			local char = string.sub(word, 1, 1)
			if char == "\n" or char == "\t" then
				total = 0
			end

			local wordlen = surface.GetTextSize(word)
			total = total + wordlen

			if wordlen >= pxWidth then
				local splitWord, splitPoint = charWrap(word, pxWidth - (total - wordlen))
				total = splitPoint
				return splitWord
			elseif total < pxWidth then
				return word
			end

			if char == ' ' then
				total = wordlen - spaceSize
				return '\n' .. string.sub(word, 2)
			end

			total = wordlen
			return '\n' .. word
		end)

	return text
end

CustomShipments          = rp.shipments
RPExtraTeams             = rp.teams
DarkRPEntities           = rp.entities
GM.AmmoTypes             = rp.ammoTypes
DarkRP.formatMoney       = rp.FormatMoney
DarkRP.defineChatCommand = rp.AddCommand



function DarkRP.declareChatCommand() end

function PLY:getDarkRPVar(var)
	if var == "money" then return self:GetMoney() end
	if var == "job" then return self:GetJobName() end
	if var == "salary" then return self:GetSalary() end
	if var == "wantedReason" then return self:GetWantedReason() end
	if var == "HasGunlicense" then return self:HasLicense() end
	if var == "wanted" then return self:IsWanted() end
	erar("try to get unknwn drpvar "..var)
end

function PLY:setDarkRPVar(var, ...)
	if var == "money" then self:SetMoney(...) return end
	erar("try to set unknwn drpvar "..var)
end

PLY.canAfford   = PLY.CanAfford
PLY.addMoney    = PLY.AddMoney
PLY.isWanted    = PLY.IsWanted
PLY.GetJob = PLY.GetJob
PLY.isArrested  = PLY.IsArrested
PLY.isCP 		= PLY.IsCP
function DarkRP.notify(ply, msgtype, _, message)
	rp.Notify(ply, msgtype, message)
end


-----------------------------------------VECTOR-----------------------------------------

function VEC:isInSight(filter, ply)
	ply = ply or LocalPlayer()
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = self
	trace.filter = filter
	trace.mask = -1
	local TheTrace = util.TraceLine(trace)

	return not TheTrace.Hit, TheTrace.HitPos
end

-----------------------------------------VECTOR-----------------------------------------
-----------------------------------------DRAW-----------------------------------------

if CLIENT then
	local function safeText(text)
		return string.match(text, "^#([a-zA-Z_]+)$") and text .. " " or text
	end

	DarkRP.deLocalise = safeText

	function draw.DrawNonParsedText(text, font, x, y, color, xAlign)
		return draw.DrawText(safeText(text), font, x, y, color, xAlign)
	end

	function draw.DrawNonParsedSimpleText(text, font, x, y, color, xAlign, yAlign)
		return draw.SimpleText(safeText(text), font, x, y, color, xAlign, yAlign)
	end

	function draw.DrawNonParsedSimpleTextOutlined(text, font, x, y, color, xAlign, yAlign, outlineWidth, outlineColor)
		return draw.SimpleTextOutlined(safeText(text), font, x, y, color, xAlign, yAlign, outlineWidth, outlineColor)
	end

	function surface.DrawNonParsedText(text)
		return surface.DrawText(safeText(text))
	end

	function chat.AddNonParsedText(...)
		local tbl = {...}
		for i = 2, #tbl, 2 do
			tbl[i] = safeText(tbl[i])
		end
		return chat.AddText(unpack(tbl))
	end
end

local list = {
	['npc_satchel'] = true,
	['item_healthkit'] = true
}

hook.Add('OnEntityCreated', 'da', function(ent)
	if list[ent:GetClass()] then
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
end)
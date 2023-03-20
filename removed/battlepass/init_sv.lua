util.AddNetworkString('bp::challangegot')

local challanges = battlepass.Challanges
local copy, randint, remove, min = table.Copy, math.random, table.remove, math.min
function battlepass.ChallangeRandom()
	local challanges = copy(challanges)
	local len = #challanges
	if (len < 1) then return error("Cyphersky durak") end

	local selected = {}
	for i = 1, min(len, 3) do
		local index = randint(#challanges)

		local challange = challanges[index]
		if (challange) then
			selected[challange.id] = 0
		end

		remove(challanges, index)
	end

	return selected
end

local PLAYER, query = PLAYER || FindMetaTable("Player"), sql.Query

local RewardTable = battlepass.RewardTable
local SQLStr, json = SQLStr, util.TableToJSON
function PLAYER:ClaimBPReward(iRewardID, bPaidOrFree)
	local claimed, RewardTable = self:GetNetVar("BPClaimed"), RewardTable[iRewardID]
	if (RewardTable == nil || self:CanClaimBPReward(iRewardID, bPaidOrFree) == false || self:HasClaimBPReward(iRewardID, bPaidOrFree) == false) then return end

	claimed[iRewardID] = (claimed[iRewardID] || {})
	if (RewardTable["paid"] == nil || RewardTable["free"] == nil) then
		claimed[iRewardID] = true
	else
		claimed[iRewardID][bPaidOrFree && 1 || 0] = true
	end

	local reward = (RewardTable[bPaidOrFree && "paid" || "free"] || RewardTable)
	if (reward.action) then
		reward.action(self)
	end

	self:SetNetVar("BPClaimed", claimed)
	query("INSERT INTO `battlepass`(`sid64`, `claimrewards`) VALUES("..self:SteamID64()..", "..SQLStr(json(claimed))..") ON CONFLICT(`sid64`) DO UPDATE SET `claimrewards` = excluded.claimrewards")
end

function PLAYER:SetBPChallangeProgress(iChallangeID, iProgress)
	local challanges, ChallangeTable = self:GetNetVar("BPChallanges"), challanges[iChallangeID]
	if (ChallangeTable == nil || self:IsActiveBPChallange(iChallangeID) == false) then return end

	if (iProgress >= ChallangeTable.require) then
		self:SetBPXP(self:GetBPXP() + ChallangeTable.xp)
		net.Start('bp::challangegot')
		net.WriteUInt(ChallangeTable.xp, 8)
		net.Send(self)
		rp.Notify(self, 0, "Вы выполнили испытание ["..ChallangeTable.name.."] и получили "..ChallangeTable.xp)
		challanges[iChallangeID] = nil
	else
		challanges[iChallangeID] = iProgress
	end

	self:SetNetVar("BPChallanges", challanges)
	query("INSERT INTO `battlepass`(`sid64`, `challanges`) VALUES("..self:SteamID64()..", "..SQLStr(json(challanges))..") ON CONFLICT(`sid64`) DO UPDATE SET `challanges` = excluded.challanges")
end

function PLAYER:AddBPChallangeProgress(iChallangeID, iProgress)
	self:SetBPChallangeProgress(iChallangeID, self:GetBPChallangeProgress(iChallangeID) + iProgress)
end

function PLAYER:SetBPLevel(iLevel)
	self:SetNWInt("BPLevel", iLevel)
	query("INSERT INTO `battlepass`(`sid64`, `level`) VALUES("..self:SteamID64()..", "..iLevel..") ON CONFLICT(`sid64`) DO UPDATE SET `level` = excluded.level")
end

function PLAYER:SetBPXP(iXP)
	self:SetNWInt("BPXP", iLevel)

    local lvl = self:GetBPLevel()
    while (iXP >= 100) do
        iXP = (iXP - 100)
        lvl = lvl + 1
    end

    self:SetNWInt("BPLevel", lvl)
    self:SetNWInt("BPXP", iXP)
	query("INSERT INTO `battlepass`(`sid64`, `level`, `xp`) VALUES("..self:SteamID64()..", "..lvl..", "..iXP..") ON CONFLICT(`sid64`) DO UPDATE SET `level` = excluded.level, `xp` = excluded.xp")
end

function PLAYER:SetBPPremium(bPremium)
	self:SetNWBool("BPPremium", bPremium)
	query("INSERT INTO `battlepass`(`sid64`, `premium`) VALUES("..self:SteamID64()..", "..SQLStr(bPremium)..") ON CONFLICT(`sid64`) DO UPDATE SET `premium` = excluded.premium")
end

function PLAYER:AddBPXP(iXP)
	self:SetBPXP(self:GetBPXP() + iXP)
end

local epoch = os.time
function PLAYER:RandomizeBPChallanges()
	local challanges = battlepass.ChallangeRandom()

	self:SetNetVar("BPChallanges", challanges)
	query("INSERT INTO `battlepass`(`sid64`, `lastchallange`, `challanges`) VALUES("..self:SteamID64()..", "..epoch()..", "..SQLStr(json(challanges))..") ON CONFLICT(`sid64`) DO UPDATE SET `lastchallange` = excluded.lastchallange, `challanges` = excluded.challanges")
end

netstream.Hook("Battlepass::ClaimReward", function(ply, iRewardID, bPaidOrFree)
	if (iRewardID == nil) then return end

	ply:ClaimBPReward(iRewardID, bPaidOrFree)
end)

local players, ipairs = player.GetAll, ipairs
concommand.Add("battlepass_drop", function(ply)
	if (ply:IsSuperAdmin() == false) then return end

	query("DELETE FROM `battlepass`")
	for i, ply in ipairs(players()) do
		ply:SetNWInt("BPLevel", 0)
		ply:SetNWInt("BPXP", 0)
		ply:SetNWBool("BPPremium", false)

		ply:SetNetVar("BPChallanges", {})
		ply:SetNetVar("BPClaimed", {})
	end
end)

hook.Add("Initialize", "Battlepass:Init", function()
	query
	[[
		CREATE TABLE IF NOT EXISTS `battlepass`(
		`sid64` VARCHAR(17) PRIMARY KEY,
		`level` TINYINT NOT NULL DEFAULT 0,
		`xp` TINYINT NOT NULL DEFAULT 0,
		`lastchallange` INT NOT NULL DEFAULT 0,
		`challanges` JSON NOT NULL DEFAULT "[]",
		`claimrewards` JSON NOT NULL DEFAULT "[]",
		`premium` BOOL NOT NULL DEFAULT false)
	]]

	hook.Remove("Initialize", "Battlepass::Init")
end)

local queryv = sql.QueryRow
local function queryc(sSQL, fCallback)
	return fCallback(queryv(sSQL) || {})
end

local unjson, tobool = util.JSONToTable, tobool
hook.Add("PlayerDataLoaded", "Battlepass::PlayerInit", function(ply)
	local challanges, claimed, sid64 = {}, {}, ply:SteamID64()
	queryc("SELECT * FROM `battlepass` WHERE `sid64` = "..sid64, function(data)
		local claimrewards = data.claimrewards
		if (claimrewards) then
			claimed = unjson(claimrewards)
		end

		ply:SetNWInt("BPLevel", tonumber(data.level))
		ply:SetNWInt("BPXP", tonumber(data.xp))
		ply:SetNWBool("BPPremium", tobool(data.premium))

		local lasttime, epoch = data.lastchallange || 0, epoch()
		if (epoch >= (lasttime + 7200)) then
			challanges = battlepass.ChallangeRandom()

			ply.LastChallanges = epoch
			return query("INSERT INTO `battlepass`(`sid64`, `lastchallange`, `challanges`) VALUES("..sid64..", "..epoch..", "..SQLStr(json(challanges))..") ON CONFLICT(`sid64`) DO UPDATE SET `lastchallange` = excluded.lastchallange, `challanges` = excluded.challanges")
		else
			local quests = data.challanges
			if (quests) then
				challanges = unjson(quests)
			end
		end

		ply.LastChallanges = lasttime
	end)

	ply:SetNetVar("BPChallanges", challanges)
	ply:SetNetVar("BPClaimed", claimed)
end)
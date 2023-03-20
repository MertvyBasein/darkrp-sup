AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString('headhunter::menu')
util.AddNetworkString('headhunter::addtarget')

HuntTargets = HuntTargets or {}

function ENT:Initialize()
	self:SetModel("models/ww2rphts/playermodels/waffenss/waffenss_nco_male05_npc.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:PhysWake()
end


function ENT:Use(ply)
	net.Start('headhunter::menu')
	net.WriteTable(HuntTargets)
	net.Send(ply)
end

local pairs, IsValid = pairs, IsValid

do
	local ReadEntity, ReadUInt, FindInSphere = net.ReadEntity, net.ReadUInt, ents.FindInSphere
	net.Receive('headhunter::addtarget', function(_,ply)
		local e, target, price = true, ReadEntity(), ReadUInt(31)
		/*for k,v in pairs(FindInSphere(ply:GetPos(), 200)) do
			if v:GetClass() == 'rp_headhunter' then e = false end
		end*/
	
		--if e then return end
		if ply:Team() ~= TEAM_SHERIF then return rp.Notify(ply, 1, 'Вы не можете это выполнить!') end
		if HuntTargets[target] then return rp.Notify(ply, 1, 'Эта цель уже добавлена!') end
		if !ply:CanAfford(price) then return rp.Notify(ply, 1, 'Вы не можете себе это позволить') end
		if price < 500 then return rp.Notify(ply, 1, 'Вы не можете указать такую маленькую сумму')  end
		if price > 1000 then return rp.Notify(ply, 1, 'Вы не можете указать такую большую сумму')  end

		ply:AddMoney(-price)
		HuntTargets[target] = price

		rp.Notify(ply, NOTIFY_SUCCESS, 'Вы добавили цель!')
	end)
end

hook.Add("PlayerDeath", "DeathReward", function(who,_,attacker)
	if HuntTargets[who] && who ~= attacker then
		attacker:AddMoney(HuntTargets[who])
		rp.Notify(attacker, NOTIFY_SUCCESS, 'Вы убили человека на которого была открыта охота, вам начислен бонус ' .. rp.FormatMoney(HuntTargets[who]))
		HuntTargets[who] = nil
	end
end)
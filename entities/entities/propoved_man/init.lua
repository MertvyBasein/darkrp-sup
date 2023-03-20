util.AddNetworkString("PropovedMenu")
util.AddNetworkString("PropovedMinusMoney")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)

	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE, CAP_TURN_HEAD)
	self:DropToFloor()
	self:SetUseType(SIMPLE_USE)
	self:SetSolid(SOLID_BBOX)
	self:PhysWake()
   	self.Used = nil
end

function ENT:Use(ply)

	net.Start("PropovedMenu")
	net.Send(ply)

	net.Receive("PropovedMinusMoney", function()
		local moneys = net.ReadUInt(32)

		if moneys < 1 then rp.Notify(ply, NOTIFY_ERROR, "Нельзя жертвовать меньше 1$!") return end
		if !ply:CanAfford(moneys) then return rp.Notify(ply,1,'Вы не можете себе это позволить!') end

		if ply:Team() == TEAM_PROPOVEDNIK then rp.Notify(ply, NOTIFY_ERROR, "Вы не можете жертвовать деньги!") return end

		rp.Notify(ply, NOTIFY_GENERIC, "Вы пожертвовали: "..moneys.."$")
		ply:AddMoney(-moneys)

		for k, v in pairs(player.GetAll()) do
			if v:Team() == TEAM_PROPOVEDNIK then
				local perc = moneys * 0.01 * 20
				v:AddMoney(perc)
				rp.Notify(v, NOTIFY_GENERIC, "Вы получили: "..perc.."$ с пожертвований")
			end
		end

	end)
end
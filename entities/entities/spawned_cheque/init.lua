AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_lab/clipboard.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:PhysWake()
end

function ENT:Use(activator, caller)
	local owner = self:Getowning_ent()
	local recipient = self:Getrecipient()
	local amount = self:Getamount() or 0

	if (IsValid(activator) and IsValid(recipient)) and activator == recipient then
		local ownername = (IsValid(owner) and owner:Nick()) or "Disconnected player"
		rp.Notify(activator, NOTIFY_SUCCESS, 'Вы нашли # в чеке, выписанном вам от #.', rp.FormatMoney(amount), (IsValid(owner) and owner or 'Disconnected player'))
		activator:AddMoney(amount, 'Чек <- ' ..  IsValid(owner) and owner or 'Disconnected player')

		hook.Call('PlayerPickupRPCheck', GAMEMODE, activator, (IsValid(owner) and owner or {NameID=function()return'Disconnected player'end,Name=function()return'N/A'end,SteamID=function()return'N/A'end}), amount, activator:GetMoney())
		self:Remove()
	elseif (IsValid(owner) and IsValid(recipient)) and owner ~= activator then
		rp.Notify(activator, NOTIFY_GENERIC, 'Этот чек выписан #.', recipient)
	elseif IsValid(owner) and owner == activator then
		rp.Notify(activator, NOTIFY_SUCCESS, 'Вы разорвали чек.')
		owner:AddMoney(self:Getamount(), 'Чек <- Возврат') -- return the money on the cheque to the owner.

		hook.Call('PlayerVoidedRPCheck', GAMEMODE, activator, recipient, amount, activator:GetMoney())
		self:Remove()
	elseif not IsValid(recipient) then
		self:Remove()
	end
end

function ENT:Touch(ent)
	if ent:GetClass() ~= 'spawned_cheque' or self.hasMerged or ent.hasMerged then return end
	if ent:Getowning_ent() ~= self:Getowning_ent() then return end
	if ent:Getrecipient() ~= self:Getrecipient() then return end

	ent.hasMerged = true

	self:Setamount(self:Getamount() + ent:Getamount())
	ent:Remove()
end

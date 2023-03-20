
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString( "upgrade" )
util.AddNetworkString( "printer_menu" )

local amount = 100			-- Базовое количество печати
local upgrade_cost = 10000	-- Стоимость апгрейда
local timing = 60			-- Базовое время печати
local temp = 30				-- Базовое время тика нагрева
local cool_cost = 5000		-- Стоимость охлаждение
local time_fire = 30		-- Сколько секунд при полном перегреве у игрока до взрыва маника

function ENT:Initialize()
	self:SetModel("models/props_c17/consolebox01a.mdl")
        self:PhysicsInit( SOLID_VPHYSICS )      
        self:SetMoveType( MOVETYPE_VPHYSICS )  
        self:SetSolid( SOLID_VPHYSICS )  
        self:SetUseType( SIMPLE_USE )
		self:DropToFloor()
		self:SetHacked(false)
        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then phys:Wake() end
--[[
	self:SetMoney(1)
	self:SetSound(1)
	self:SetSpeed(1)
	self:SetArmor(1)
	self:SetHP(1)
	self:GetTemperature(0)
	self:GetTemperatureLevel(1)
	self:Getmoney_have(0)
]]--
	self:SetTP(true)
	self.HP = 50
	self.sparking = false
	self.IsMoneyPrinter = true
	timer.Simple(10, function() if IsValid(self) then self:CreateMoneybag() end end)

	self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
	self.sound:SetSoundLevel(60)
	self.sound:PlayEx(1, math.Rand(80,100))
end



function ENT:Use(ply)
if ply != self:GetOwnerz() and !self:GetHacked() then DarkRP.notify( ply, 1, 6, "Это не ваш принтер") return end
net.Start("printer_menu")
net.WriteFloat(self:EntIndex())
net.WriteFloat(self:GetMoney())
net.WriteFloat(self:GetSound())
net.WriteFloat(self:GetSpeed())
net.WriteFloat(self:GetArmor())
net.WriteFloat(self:GetHP())
net.WriteFloat(self:GetTemperature())
net.WriteFloat(self:GetTemperatureLevel())
net.Send(ply)
end

net.Receive( "upgrade", function( len, ply )
local index = net.ReadFloat()
local tip = net.ReadFloat()
local self = ents.GetByIndex(index)
local vipp = false
if deadlib.GetHigherRanks('vip', ply:GetUserGroup()) then vipp = true end
if ply:Team() == TEAM_ADMIN then
	RunConsoleCommand('sam','gban',ply:SteamID(),'600','[Автобан] Админ абуз')
	ply:svtext(Color(0,157,255),'[Автобан] ',Color(255,255,255),'Вы пытались снять деньги с принтера игрока за админ профессию, вы будете заблокированы')
	return
end
if tip == 0 and self:Getmoney_have() > 0 then
DarkRP.notify( ply, 0, 6, "Вы взяли из принтера: "..self:Getmoney_have().."Р")
ply:addMoney(self:Getmoney_have())
self:Setmoney_have(0)
elseif tip == 0 and self:Getmoney_have() == 0 then
DarkRP.notify( ply, 0, 6, "В принтере пусто")
end

if !ply:canAfford(upgrade_cost) and tip != 0 then DarkRP.notify( ply, 0, 6, "Не хватает денег") return end
if vipp == true then num = 6 else num = 3 end

--Скорость
if tip == 1 and self:GetSpeed() != num and ply:canAfford(upgrade_cost) then 
self:SetSpeed(self:GetSpeed()+1) ply:addMoney(-upgrade_cost) 
DarkRP.notify( ply, 0, 6, "Вы потратили на апгрейд: " ..upgrade_cost.."Р")
elseif tip == 1 and self:GetSpeed() == num and !vipp then
DarkRP.notify( ply, 0, 6, "Дальнейшее улучшение только для vip")
end

--Защита
if tip == 2 and self:GetArmor() != num and ply:canAfford(upgrade_cost) then 
self:SetArmor(self:GetArmor()+1) ply:addMoney(-upgrade_cost)
self.Armor = self:GetArmor()*100
DarkRP.notify( ply, 0, 6, "Вы потратили на апгрейд: " ..upgrade_cost.."Р")
elseif tip == 2 and self:GetArmor() == num and !vipp then
DarkRP.notify( ply, 0, 6, "Дальнейшее улучшение только для vip")
end

--Количество печати
if tip == 3 and self:GetMoney() != num and ply:canAfford(upgrade_cost) then 
self:SetMoney(self:GetMoney()+1) ply:addMoney(-upgrade_cost) 
DarkRP.notify( ply, 0, 6, "Вы потратили на апгрейд: " ..upgrade_cost.."Р")
elseif tip == 3 and self:GetMoney() == num and !vipp then
DarkRP.notify( ply, 0, 6, "Дальнейшее улучшение только для vip")
end

--Громкость
if tip == 4 and self:GetSound() != num and ply:canAfford(upgrade_cost) then 
self:SetSound(self:GetSound()+1) ply:addMoney(-upgrade_cost) 
DarkRP.notify( ply, 0, 6, "Вы потратили на апгрейд: " ..upgrade_cost.."Р")
elseif tip == 4 and self:GetSound() == num and !vipp then
DarkRP.notify( ply, 0, 6, "Дальнейшее улучшение только для vip")
end

--Прочность
if tip == 5 and self:GetHP() != num and ply:canAfford(upgrade_cost) then 
self:SetHP(self:GetHP()+1) 
ply:addMoney(-upgrade_cost) 
self.HP = self:GetHP()*100
DarkRP.notify( ply, 0, 6, "Вы потратили на апгрейд: " ..upgrade_cost.."Р")
elseif tip == 5 and self:GetHP() == num and !vipp then
DarkRP.notify( ply, 0, 6, "Дальнейшее улучшение только для vip")
end

--Охлаждение
if tip == 6 and self:GetTemperature() != 2 and ply:canAfford(upgrade_cost) then 
self:SetTemperature(self:GetTemperature()+1) ply:addMoney(-upgrade_cost) 
DarkRP.notify( ply, 0, 6, "Вы потратили на апгрейд: " ..upgrade_cost.."Р")
end


if tip != 7 and tip != 8 then
net.Start("printer_menu")
net.WriteFloat(self:EntIndex())
net.WriteFloat(self:GetMoney())
net.WriteFloat(self:GetSound())
net.WriteFloat(self:GetSpeed())
net.WriteFloat(self:GetArmor())
net.WriteFloat(self:GetHP())
net.WriteFloat(self:GetTemperature())
net.WriteFloat(self:GetTemperatureLevel())
net.Send(ply)
end

if tip == 8 and ply:canAfford(upgrade_cost) then
self:SetTemperatureLevel(0)
DarkRP.notify( ply, 0, 6, "Вы потратили на охлаждение:"..cool_cost.."Р")
ply:addMoney(-cool_cost) 
if timer.Exists("Heat"..self:EntIndex()) then 
DarkRP.notify( ply, 0, 6, "Вы успели охладить принтер")
timer.Remove("Heat"..self:EntIndex()) 
end
end

if tip == 7 then
local aidw = ents.Create("printer_package")
aidw:SetPos(self:GetPos()+Vector(0,0,10))
aidw:SetAngles(self:GetAngles())
aidw:SetOwners(ply)
aidw.Money = self:GetMoney()
aidw.Sound = self:GetSound()
aidw.Speed = self:GetSpeed()
aidw.Armor = self:GetArmor()
aidw.HP = self:GetHP()
aidw.TMP = self:GetTemperature()
aidw.TMPLevel = self:GetTemperatureLevel()
aidw:Spawn()
aidw:Activate()
aidw.Once = true
self:Remove()
end
end)


--[[
if self:GetTemperatureLevel() == 100 then 	
local effectdata = EffectData()
effectdata:SetOrigin(self:GetPos())
effectdata:SetMagnitude(1)
effectdata:SetScale(1)
effectdata:SetRadius(2)
util.Effect("ElectricSpark", effectdata)
timer.Simple(0.5,function() self:SetTP(true) end)
return
end
]]--

function ENT:Think()
--if !IsValid(self:GetOwnerz()) then self:Remove() end

if self:GetTP() == true then 
self:SetTP(false)
if self:GetTemperatureLevel() == 100 then DarkRP.notify( self:GetOwnerz(), 0, 6, "Ваш принтер перегревается!") timer.Create("Heat"..self:EntIndex(),time_fire,1,function() self:Destruct() self:Remove() end) return end
timer.Simple(temp*(1+self:GetTemperature()),function() 
if !IsValid(self) or self:GetTemperature() == 2 then return end
self:SetTemperatureLevel(math.Clamp((self:GetTemperatureLevel()+math.Round(math.Rand(10,25))),0,100)) 
self:SetTP(true) 
end)
end

if self.sound then self.sound:ChangeVolume(1/self:GetSound(), 50 ) end
	if not self.sparking then return end
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetMagnitude(1)
	effectdata:SetScale(1)
	effectdata:SetRadius(2)
	util.Effect("Sparks", effectdata)
end
function ENT:Destruct()
	local effectdata = EffectData()
	effectdata:SetStart(self:GetPos())
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
	DarkRP.notify(self:GetOwnerz(), 1, 4, "Ваш принтер взорвался!")
end

function ENT:CreateMoneybag()
	if not IsValid(self) then return end
	self.sparking = false
	self:Setmoney_have(math.Clamp(self:Getmoney_have()+amount*(self:GetMoney()/2),0,250000))
	timer.Simple(timing/self:GetSpeed(), function() 
	if not IsValid(self) then return end
	self.sparking = true
	timer.Simple(2, function()
		if not IsValid(self) then return end
		self:CreateMoneybag()
	end)
	end)
end
function ENT:OnTakeDamage(dmg)
	
	self.HP = (self.HP-(dmg:GetDamage()/self:GetArmor()))
	if self.HP <= 0 then
			self:Destruct()
			self:Remove()
	end
end
function ENT:OnRemove()
	if self.sound then
		self.sound:Stop()
	end
end

hook.Add( "PlayerDisconnected", "delete_printers", function(ply)
z = 0
for k,v in ipairs(ents.GetAll()) do
if v:GetClass() == "printer_package" and v:GetOwners() == ply then
v:Remove()
z = z + 1
end
if v:GetClass() == "custom_printer" and v:GetOwnerz() == ply then
v:Remove()
z = z + 1
end
end
if z!= 0 then print("Deleted "..z.." printers, owner: "..ply:GetName()) end
end)

hook.Add( "OnPlayerChangedTeam", "delete_printers", function(ply)
z = 0
for k,v in ipairs(ents.GetAll()) do
if v:GetClass() == "printer_package" and v:GetOwners() == ply then
v:Remove()
z = z + 1
end
if v:GetClass() == "custom_printer" and v:GetOwnerz() == ply then
v:Remove()
z = z + 1
end
end
if z!= 0 then print("Deleted "..z.." printers, owner: "..ply:GetName()) end
end)
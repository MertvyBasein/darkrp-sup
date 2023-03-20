AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')
 
function ENT:Initialize()
	self:SetModel("models/items/item_item_crate.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )     
	self:SetMoveType( MOVETYPE_VPHYSICS )  
	self:SetSolid( SOLID_VPHYSICS )       
	self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.Once = false
end

local modelscrack = {"models/items/item_item_crate_chunk09.mdl","models/items/item_item_crate_chunk08.mdl","models/items/item_item_crate_chunk07.mdl","models/items/item_item_crate_chunk02.mdl"}
--- Модели обломков
function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local ent = ents.Create( ClassName )
	ent:SetOwner(ply)
	ent:SetOwners(ply)
	ent:SetPos( SpawnPos )
	ent:SetAngles(ply:GetAngles())
	ent:Spawn()
	ent:Activate()
	return ent
end




local dmg = 0
local dmgg = 0

function ENT:Use(ply,ply)
if self.Once == false then 
self:SetOwners(ply) 
self.Once = true 
self.Money = 1
self.Sound = 1
self.Speed = 1
self.Armor = 1
self.HP = 1
self.TMP = 0
self.TMPLevel = 1
end
self:Remove()

local aidw = ents.Create("custom_printer")
aidw:SetPos(self:GetPos()+Vector(0,0,5))
aidw:SetAngles(self:GetAngles())
aidw:SetOwnerz(self:GetOwners())
aidw:SetMoney(self.Money)
aidw:SetSound(self.Sound)
aidw:SetSpeed(self.Speed)
aidw:SetArmor(self.Armor)
aidw:SetHP(self.HP)
aidw:SetTemperature(self.TMP)
aidw:SetTemperatureLevel(self.TMPLevel)
aidw:Setmoney_have(0)
aidw:Spawn()
aidw:Activate()
end


function ENT:OnTakeDamage( dmginfo )
local k = dmginfo:GetAttacker()
self:GetPhysicsObject():SetVelocity(k:GetAimVector()*100)
dmg = dmginfo:GetDamage()
dmgg = dmg + dmgg
if dmgg > 55 then
self:Remove()
end
end


 
function ENT:OnRemove()
self.sound = CreateSound(self, Sound("physics/wood/wood_crate_break3.wav"))
self.sound:SetSoundLevel(140)
self.sound:PlayEx(1,100)

dmgg = 0

for i = 0,9 do
local button = ents.Create( "prop_physics" )
button:SetModel(table.Random(modelscrack))
button:SetPos(self:GetPos()+Vector(math.Rand(0,20),math.Rand(0,20),25))
button:SetAngles(Angle(math.Rand(0,60),0,math.Rand(0,90)))
button:SetCollisionGroup(20)
button:Spawn()
end

timer.Simple(3,function()
for k,v in ipairs(ents.FindByClass("prop_physics")) do
if table.HasValue(modelscrack,v:GetModel()) then
v:Remove()
end
end
end)
end


--caller:SetDarkRPVar("Energy", caller:getDarkRPVar("Energy")+50)
-- function ENT:OnRemove()
	-- local ply = self:Getowning_ent()
	-- ply.maxFoods = ply.maxFoods and ply.maxFoods - 1 or 0
-- end
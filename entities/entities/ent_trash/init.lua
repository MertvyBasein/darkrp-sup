AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
util.AddNetworkString("OpenTrashDerma")
util.AddNetworkString("RemoveTrash")
util.AddNetworkString("TimerCreateForRespawnTrash")

local models = {
  'models/props_junk/garbage128_composite001a.mdl',
  'models/props_junk/garbage128_composite001b.mdl',
  'models/props_junk/garbage128_composite001c.mdl',
  'models/props_junk/garbage128_composite001d.mdl'
}

function ENT:Initialize()
    self:SetModel(models[math.random(1, #models)])
    //self:SetModel("models/props_junk/garbage128_composite001c.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self.NextUse = true
    local phys = self.Entity:GetPhysicsObject()

    if (phys:IsValid()) then
        phys:EnableMotion(false)
        phys:Wake()
    end
    self:DrawShadow( false ) // Мы пытались...
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator, caller)
    if activator:IsPlayer() then
        if activator:Team() != TEAM_SVEIN then return end
        if activator:GetActiveWeapon():GetClass() != "weapon_broom" then 
            DarkRP.notify(activator,1,4,"У вас в руках должна быть метла!")
            return 
        end
    end

    net.Start("OpenTrashDerma")
    net.WriteEntity(self)
    net.Send(activator)
end

local function reloadTrashList()

    for k,v in pairs(ents.FindByClass('ent_trash')) do
        v:Remove()
    end
    for k,v in pairs(rp.trash_system.position) do
        local ent = ents.Create('ent_trash')
        ent:SetPos(v.pos)
       -- ent:SetAngles(v.ang)
        ent.Model = models
        ent:Spawn()

        ent.rand = v.Loot
    end
end
hook.Add('InitPostEntity', 'trashSpawn', reloadTrashList)

if CurTime() > 60 then reloadTrashList() end

concommand.Add("trash_reload", function(ply)
    if init then return end

    if !ply:IsSuperAdmin() then return end

    for k,v in pairs(ents.FindByClass('ent_trash')) do
        v:Remove()
    end
    for k,v in pairs(rp.trash_system.position) do
        local ent = ents.Create('ent_trash')
        ent:SetPos(v.pos)
       -- ent:SetAngles(v.ang)
        ent.Model = models
        ent:Spawn()

        ent.rand = v.Loot
    end
    MsgC(Color(255,20,20), ply:GetName() .. " Перезапустил мусор")
end)

net.Receive("RemoveTrash", function(len, ply)
    local eTrash = net.ReadEntity()
    local rand = math.random(0, 100)
    local money_found = math.random(150, 200)

    local moneywork = math.random(10, 500)

    if (not IsValid(eTrash)) then return end
    if (not IsValid(ply)) then return end
    if eTrash:GetClass() != 'ent_trash' then return end
    if eTrash:GetPos():DistToSqr(ply:GetPos()) > 10000 then return end

    if ply:Team() == TEAM_SVEIN then
      ply:AddMoney(60, 'Заработок - Мусор')
      DarkRP.notify(ply,3,4,"Вы убрали мусор и получили " .. rp.FormatMoney(moneywork))
      eTrash:Remove()

      if rand > 70 then
        ply:AddMoney(money_found, 'Заработок - Мусор [Chance]')
        DarkRP.notify(ply,3,4,"Вам повезло! Убирая мусор вы нашли в нем " .. rp.FormatMoney(money_found))
      end
    end
end)

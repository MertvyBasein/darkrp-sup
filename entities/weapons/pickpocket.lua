function PLAYER:IsAFK()
	return false
end

if CLIENT then
	SWEP.PrintName = "Украсть деньги"
	SWEP.Instructions = ""
	SWEP.Slot = 1
	SWEP.SlotPos = 9
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author 				= ""
SWEP.Category 				= "HL2RP"

SWEP.ViewModelFOV    		= 62
SWEP.ViewModelFlip    		= false

SWEP.ViewModel        		= ""
SWEP.WorldModel        		= ""

SWEP.HoldType 				= "normal"

SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= 0
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= ""

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= 0
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= ""

SWEP.CheckTime 				= 10
SWEP.AllowedClass 			= "player"
SWEP.ModelDraw 				= false

SWEP.CheckTime 				= 5
SWEP.StealDetection 		= 10
SWEP.MoneyToSteal 			= {100, 250}
SWEP.StealTreshold 			= 150

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsStealing")
    self:NetworkVar("Float", 0, "StartCheckTime")
    self:NetworkVar("Float", 1, "EndCheckTime")
end

function SWEP:Deploy()
	if not self.ModelDraw then
		self.Owner:DrawViewModel(false)
		if SERVER then
			self.Owner:DrawWorldModel(false)
			self:SetHoldType( self.HoldType )
		end
	end
end

function SWEP:EntityCheck(ply)
	if not (IsValid(ply) and ply:IsPlayer() and ply:GetPos():Distance(self.Owner:GetPos()) < 100) then
		return true
	end
	return false
end

local pi 						= math.pi
local cos 						= math.cos
local sin 						= math.sin
local floor 					= math.floor
local ceil 						= math.ceil
local sqrt 						= math.sqrt
local clamp 					= math.Clamp
local rad 						= math.rad
local round 					= math.Round
local Color 					= Color
local draw 						= draw

function MetaHubDrawOutline(x, y, w, h, col)
	col = col or Color(0,0,0)
	surface.SetDrawColor(col)
	surface.DrawOutlinedRect(x,y,w,h)
end

function MetaHubDrawRect(x,y,w,h,col, col_o)
	surface.SetDrawColor(col)
	surface.DrawRect(x,y,w,h)
end

function MetaHubDrawProgress(x, y, w, h, perc)
	local X, Y = 0,0
	local color =Color(255, 255, 255) -- ColorAlpha(Color(255, 255, 255), 100) --Color(255 - (perc * 255), perc * 255, 0, 100)

	--draw.BlurBox(x,y,w,h)
	MetaHubDrawRect(x,y,w,h,Color(0,0,0,100))
	MetaHubDrawRect(x, y,clamp((w * perc), 3, w), h, color)
	MetaHubDrawOutline(x,y,w,h)
end

function SWEP:PrimaryAttack()
	if self:GetIsStealing() then return end

	self:SetNextPrimaryFire(CurTime() + 0.3)

    self:GetOwner():LagCompensation(true)
    local trace = self:GetOwner():GetEyeTrace()
    self:GetOwner():LagCompensation(false)

	if self:EntityCheck(trace.Entity) then return end
	if trace.Entity:GetNetVar('AdminMode') then return end
	if trace.Entity:InSpawn() then return end
	if trace.Entity:IsAFK() then return end

	if not IsFirstTimePredicted() then return end

	self:SetIsStealing(true)
    self:SetStartCheckTime(CurTime())
    self:SetEndCheckTime(CurTime() + self.CheckTime)

    if CLIENT then
        self.Dots = ""
        self.NextDotsTime = CurTime() + 0.5
    end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end

function SWEP:Reload()
	self:PrimaryAttack()
end

function SWEP:Holster()
    self:SetIsStealing(false)
    return true
end

function SWEP:Done(victim, ply)
	if CLIENT then return end
	local money_to_steal = math.random(self.MoneyToSteal[1], self.MoneyToSteal[2])

	if not victim:CanAfford(money_to_steal) then
		rp.Notify(self.Owner, NOTIFY_ERROR, "У игрока не достаточно денег!" )
		return
	end
	if (victim.nextSteal and victim.nextSteal > CurTime()) or not victim:CanAfford(self.StealTreshold) then
		rp.Notify(self.Owner, NOTIFY_ERROR, "Ты хочешь чтобы тебя поймали?! Подожди немного перед повторной попыткой!" )
		return
	end

	victim.nextSteal = CurTime() + 120

	rp.Notify(self.Owner, 3, "Ты украл #!", rp.FormatMoney(money_to_steal) )

    plogs.PlayerLog(self.Owner, 'Воровство', self.Owner:NameID() .. ' своровал у ' .. victim:NameID() .. ' сумму: ' .. rp.FormatMoney(money_to_steal), {
      ['Name']      = self.Owner:Name(),
      ['SteamID']     = self.Owner:SteamID(),
      ['Target Name']   = victim:Name(),
      ['Target SteamID']  = victim:SteamID(),
      ['Сумма украденного'] = rp.FormatMoney(money_to_steal),
      ['Координаты места'] 	= 'Vector('..self.Owner:GetPos().x..', '..self.Owner:GetPos().y..', '..self.Owner:GetPos().z..')'
    })


	timer.Simple(self.StealDetection, function()
		if IsValid(victim) then
			rp.Notify(victim, NOTIFY_ERROR, "Кто-то украл # из вашего кармана!", rp.FormatMoney(money_to_steal))
		end
	end)

	victim:AddMoney(-money_to_steal, 'Деньги украдены игроком ' .. self.Owner:SteamID64())
	self.Owner:AddMoney(money_to_steal, 'Украл деньги у игрока' .. victim:SteamID64())
end

function SWEP:Succeed(victim, ply)
	self:SetIsStealing(false)
	self:GetOwner():LagCompensation(true)
	local trace = self:GetOwner():GetEyeTrace()
	self:GetOwner():LagCompensation(false)
	if self:EntityCheck(trace.Entity) then return end

	self:Done(trace.Entity)
end

function SWEP:Fail()
	self:SetIsStealing(false)
end

function SWEP:Think()
	if self:GetIsStealing() and self:GetEndCheckTime() ~= 0 then
        self:GetOwner():LagCompensation(true)
        local trace = self:GetOwner():GetEyeTrace()
        self:GetOwner():LagCompensation(false)

        if self:EntityCheck(trace.Entity) then
            self:Fail()
        end

        if self:GetEndCheckTime() <= CurTime() then
            self:Succeed()
        end
    end

    if CLIENT and self.NextDotsTime and CurTime() >= self.NextDotsTime then
        self.NextDotsTime = CurTime() + 0.5
        self.Dots = self.Dots or ""
        local len = string.len(self.Dots)
        local dots = {
            [0] = ".",
            [1] = "..",
            [2] = "...",
            [3] = ""
        }
        self.Dots = dots[len]
    end
end

function SWEP:DrawHUD()
    if self:GetIsStealing() and self:GetEndCheckTime() ~= 0 then
        self.Dots = self.Dots or ""

		local x, y = (ScrW() *.5) - 150, (ScrH() *.5) - 25
		local w, h  = 300, 50

		local time = self:GetEndCheckTime() - self:GetStartCheckTime()
		local status = (CurTime() - self:GetStartCheckTime())/time

		MetaHubDrawProgress(x, y, w, h, status)
		draw.SimpleTextOutlined("Лазим по карманам"..self.Dots, GetFont(10), ScrW()*.5, ScrH()*.5, Color(255,255,255,255), 1, 1, 1, Color(0,0,0,255))
    end
end

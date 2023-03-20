function PLAYER:IsAFK()
	return false
end

if CLIENT then
	SWEP.PrintName = "Переодевание в лагерного узника"
	SWEP.Instructions = ""
	SWEP.Slot = 1
	SWEP.SlotPos = 9
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author 				= ""
SWEP.Category 				= "RP"

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
SWEP.StealTreshold 			= 1500

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsJobseting")
    self:NetworkVar("Float", 0, "StartCheckTime")
    self:NetworkVar("Float", 1, "EndCheckTime")
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



function InfinityDrawOutline(x, y, w, h, col)
	col = col or Color(0,0,0)
	surface.SetDrawColor(col)
	surface.DrawOutlinedRect(x,y,w,h)
end

function InfinityDrawRect(x,y,w,h,col, col_o)
	surface.SetDrawColor(col)
	surface.DrawRect(x,y,w,h)
end

function InfinityDrawProgress(x, y, w, h, perc)
	local X, Y = 0,0
	local color =Color(186, 41, 41) -- ColorAlpha(Color(255, 255, 255), 100) --Color(255 - (perc * 255), perc * 255, 0, 100)

	--draw.BlurBox(x,y,w,h)
	InfinityDrawRect(x,y,w,h,Color(0,0,0,100))
	InfinityDrawRect(x, y,clamp((w * perc), 3, w), h, color)
	InfinityDrawOutline(x,y,w,h)
end


function SWEP:PrimaryAttack()
	if self:GetIsJobseting() then return end

	self:SetNextPrimaryFire(CurTime() + 0.3)

    self:GetOwner():LagCompensation(true)
    local trace = self:GetOwner():GetEyeTrace()
    self:GetOwner():LagCompensation(false)

	if self:EntityCheck(trace.Entity) then return end 
	if trace.Entity:Team() == TEAM_ADMIN then return end

	if not IsFirstTimePredicted() then return end

	self:SetIsJobseting(true)
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
    self:SetIsJobseting(false)
    return true
end

function SWEP:Done(victim, ply)
--------------
	if CLIENT then return end

	if IsValid(victim) then
    	if ( victim:Team() == TEAM_LAGERUZNIK  ) then -- ЗАМЕНИТЬ ПРОФУ НА СВОЮ!
    		DarkRP.notify(self.Owner, 4,4, 'Игрок уже переоделся!')
    	else 
    		victim:ChangeTeam(TEAM_LAGERUZNIK,1)
    		DarkRP.notify(self.Owner, 4,4, 'Вы переодели игрока: ' .. victim:Name())
    		--rp.Notify(victim, NOTIFY_ERROR, 'Вас переодел игрок: ' .. self.Owner:Name(),"")
    	end
	end


	
end
function SWEP:Succeed(victim, ply)
	self:SetIsJobseting(false)
	self:GetOwner():LagCompensation(true)
	local trace = self:GetOwner():GetEyeTrace()
	self:GetOwner():LagCompensation(false)
	if self:EntityCheck(trace.Entity) then return end
    
	self:Done(trace.Entity)
end

function SWEP:Fail()
	self:SetIsJobseting(false)
end

function SWEP:Think()
	if self:GetIsJobseting() and self:GetEndCheckTime() ~= 0 then
        self:GetOwner():LagCompensation(true)
        local trace = self:GetOwner():GetEyeTrace()
        self:GetOwner():LagCompensation(false)

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
    if self:GetIsJobseting() and self:GetEndCheckTime() ~= 0 then
        self.Dots = self.Dots or ""

		local x, y = (ScrW() *.5) - 150, (ScrH() *.5) - 25
		local w, h  = 300, 50

		local time = self:GetEndCheckTime() - self:GetStartCheckTime()
		local status = (CurTime() - self:GetStartCheckTime())/time

		InfinityDrawProgress(x, y, w, h, status)
		draw.SimpleTextOutlined("Переодевание"..self.Dots, "defont26", ScrW()*.5, ScrH()*.5, Color(255,255,255,255), 1, 1, 1, Color(0,0,0,255))
    end
end

include("shared.lua")

local blur = Material("pp/blurscreen")
local file, Material, Fetch, find = file, Material, http.Fetch, string.find

local errorMat = Material("debug/debugvertexcolor")
local WebImageCache = {}
function http.DownloadMaterial(url, path, callback)
    if WebImageCache[url] then return callback(WebImageCache[url]) end

    local data_path = "data/".. path
    if file.Exists(path, "DATA") then
        WebImageCache[url] = Material(data_path, "smooth")
        callback(WebImageCache[url])
    else
        Fetch(url, function(img)
            if img == nil or find(img, "<!DOCTYPE HTML>", 1, true) then return callback(errorMat) end
            
            file.Write(path, img)
            WebImageCache[url] = Material(data_path, "smooth")
            callback(WebImageCache[url])
        end, function()
            callback(errorMat)
        end)
    end
end
http.DownloadMaterial("https://mertvybasein.myarena.site/logo.jpg", "mainframetrasnotlogo.png", function(mainframetransnotlogo)
function ENT:Draw()
	self:DrawModel()
	if self:GetPos():Distance(LocalPlayer():GetPos()) < 500  then -- How far people can see printer UI
		
		local Pos = self:GetPos()
		local Ang = self:GetAngles()
		local owner = self:GetOwnerz()
		owner = (IsValid(owner) and owner:Name()) or "Нет владельца"
		local money = self:Getmoney_have()

		Ang:RotateAroundAxis(Ang:Up(), 90)

		cam.Start3D2D(Pos + Ang:Up() * 10.8 + Ang:Forward() * -15 + Ang:Right() * -16.1, Ang, 0.11)
			mfire.DrawMat(0, 0, 275, 275, color_white, mainframetransnotlogo)
			draw.RoundedBox( 0, 0, 0, 275, 275, Color(13, 13, 13, 155) )

			mfire.DrawText("Денежный Принтер", "mfire24", 275/2, 10, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			mfire.DrawText("Владелец: "..owner, "mfire24", 275/2, 35, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			
			mfire.DrawText("Накоплено: " .. DarkRP.formatMoney(money), "mfire24", 275/2, 220, Color(200, 200, 200), TEXT_ALIGN_CENTER)

		cam.End3D2D()
	end
end
--------------------------------------
local p = 0.025
net.Receive( "printer_menu", function( len, ply )
local index = net.ReadFloat()
local Mtier = net.ReadFloat()
local SDtier = net.ReadFloat()
local SPDtier = net.ReadFloat()
local ARMtier = net.ReadFloat()
local HPtier = net.ReadFloat()
local TMPtier = net.ReadFloat()
local TMPLevel = net.ReadFloat()


local QuestionPanel = vgui.Create("DFrame")
QuestionPanel:SetPos( ScrW()/2-300, ScrH()/2-220 )
QuestionPanel:SetSize( 600, 420 )
QuestionPanel:SetTitle( "" )
QuestionPanel:ShowCloseButton(false)
QuestionPanel:MakePopup()
QuestionPanel.Paint = function(self,w,h)
surface.SetMaterial(mainframetransnotlogo)
surface.SetDrawColor(Color(60,60,60,255))	
surface.DrawTexturedRect(0, 1, ScrW() / 2.5, ScrH() / 2)

local k = 40
local z = 62
draw.RoundedBox( 6, 10, k, 315, 30, Color( 160, 160, 160, 135) )
draw.RoundedBox( 6, 10, k,52.5*SPDtier, 30, Color( 20, 200, 255, 135) )
draw.RoundedBox( 6, 290, k, 30, 30, Color( 60, 60, 60, 135) )
draw.SimpleText("Улучшений скорости печати", "mfire20", 20, 5+k, Color(255, 255, 225))
k = k + z
draw.RoundedBox( 6, 10, k, 315, 30, Color( 160, 160, 160, 135) )
draw.RoundedBox( 6, 10, k,52.5*ARMtier, 30, Color( 0, 180, 255, 135) )
draw.RoundedBox( 6, 290, k, 30, 30, Color( 60, 60, 60, 135) )
draw.SimpleText("Улучшений защиты принтера", "mfire20", 20, 5+k, Color(255, 255, 225))
k = k + z
draw.RoundedBox( 6, 10, k, 315, 30, Color( 160, 160, 160, 135) )
draw.RoundedBox( 6, 10, k,52.5*Mtier, 30, Color( 20, 255, 120, 135) )
draw.RoundedBox( 6, 290, k, 30, 30, Color( 60, 60, 60, 135) )
draw.SimpleText("Улучшений количества печати", "mfire20", 20, 5+k, Color(255, 255, 255))
k = k + z
draw.RoundedBox( 6, 10, k, 315, 30, Color( 160, 160, 160, 135) )
draw.RoundedBox( 6, 10, k,52.5*SDtier, 30, Color( 140, 255, 120, 135) )
draw.RoundedBox( 6, 290, k, 30, 30, Color( 60, 60, 60, 135) )
draw.SimpleText("Улучшений громкости печати", "mfire20", 20, 5+k, Color(225, 225, 255))
k = k + z
draw.RoundedBox( 6, 10, k, 315, 30, Color( 160, 160, 160, 135) )
draw.RoundedBox( 6, 10, k,52.5*HPtier, 30, Color( 255, 80, 20, 135) )
draw.RoundedBox( 6, 290, k, 30, 30, Color( 60, 60, 60, 135) )
draw.SimpleText("Улучшений прочности принтера", "mfire20", 20, 5+k, Color(255, 205, 225))
k = k + z
draw.RoundedBox( 6, 10, k, 315, 30, Color( 160, 160, 160, 135) )
draw.RoundedBox( 6, 10, k,157.5*TMPtier, 30, Color( 220, 155, 20, 135) )
draw.RoundedBox( 6, 290, k, 30, 30, Color( 60, 60, 60, 135) )
draw.SimpleText("Улучшений радиатора принтера", "mfire20", 20, 5+k, Color(255, 255, 225))

draw.RoundedBox( 6, 335, 320, 200, 90, Color( 160, 160, 160, 135) )
draw.RoundedBox( 0, 335, math.Clamp(300+(100-TMPLevel+(math.sin(CurTime()*5)*2)/1.1),320,600), 200, math.Clamp(TMPLevel-(math.sin(CurTime()*5)*2)/1.1+10,0,90), Color( 255, 200-TMPLevel, 0, 255) )
end
    local close = vgui.Create("DButton",QuestionPanel)
    close:SetText('')
    close:SetSize(QuestionPanel:GetWide()*.07, 25)
    close:SetPos(QuestionPanel:GetWide() - QuestionPanel:GetWide()*.07,0)
    close.Paint = function(self,w,h)
        draw.RoundedBox(0,0,0,w,h,Color(186,41,41,255))
        frametext("X", "travka.btn", w*.5, h*.5, Color(255, 255, 255, 255), 1, 1)
    end
    close.OnCursorEntered = function(this)
        surface.PlaySound( "garrysmod/ui_hover.wav" )
    end
    close.DoClick = function(self)
        surface.PlaySound( "garrysmod/ui_click.wav" )
        self:SetEnabled(false)
        QuestionPanel:AlphaTo(0,0.3,0,function() 
            if IsValid(QuestionPanel) then 
                QuestionPanel:Remove() 
            end
        end)
    end
--*TMPLevel+(math.sin(CurTime()*5)*2)
local bg = vgui.Create( "DPanel", QuestionPanel ) 
bg:Dock( FILL )
bg.Paint = function(self,w,h)
draw.RoundedBox( 6, 325, 0, 260, 250, Color( 20, 20, 20, 180) )
draw.RoundedBox( 6, 330, 5, 250, 240, Color( 120, 120, 120, 180) )
end
local mdl = vgui.Create( "DModelPanel", bg )
mdl:SetModel("models/props_c17/consolebox01a.mdl")
mdl:SetSize(250,230)
mdl:SetPos(QuestionPanel:GetWide()-270,10)
function mdl:LayoutEntity( ent )
	ent:SetPos(Vector(0,0,40))
	ent:SetModelScale(0.7)
	ent:SetAngles(Angle(25,CurTime()*50,math.tan(CurTime()/5)))
	mdl:SetFOV( 30 )
end

local DermaButton = vgui.Create( "DButton", bg )
DermaButton:SetText( "Забрать деньги" )					
DermaButton:SetPos( QuestionPanel:GetWide()-270, 255 )					
DermaButton:SetSize( 250, 30 )
DermaButton:SetTextColor(Color(255,255,255,180))
DermaButton:SetFont("mfire22")
DermaButton.Paint = function(self,w,h)					
draw.RoundedBox( 6, 0, 0, w, h, Color( 160, 160, 160, 155) )
draw.RoundedBox( 3, 2.5, 2.5, w-5, h-5, Color( 140, 170, 180, 55) )
end
DermaButton.DoClick = function()	
net.Start("upgrade")
net.WriteFloat(index)
net.WriteFloat(0)
net.SendToServer()
timer.Simple(p,function() QuestionPanel:Close() end)
end



--Скорость печати
local DermaImageButton = vgui.Create( "DImageButton", bg )
DermaImageButton:SetPos( 288, 14 )				
DermaImageButton:SetSize( 26, 26 )		
DermaImageButton:SetColor(Color(0,255,255))
DermaImageButton:SetImage( "icon16/arrow_up.png" )	
DermaImageButton.DoClick = function()
if SPDtier == 6 then return end
net.Start("upgrade")
net.WriteFloat(index)
net.WriteFloat(1)
net.SendToServer()
timer.Simple(p,function() QuestionPanel:Close() end)
end

--Защита принтера
local DermaImageButton = vgui.Create( "DImageButton", bg )
DermaImageButton:SetPos( 288, 76 )				
DermaImageButton:SetSize( 26, 26 )		
DermaImageButton:SetColor(Color(0,255,255))
DermaImageButton:SetImage( "icon16/arrow_up.png" )	
DermaImageButton.DoClick = function()	
if ARMtier == 6 then return end			
net.Start("upgrade")
net.WriteFloat(index)
net.WriteFloat(2)
net.SendToServer()
timer.Simple(p,function() QuestionPanel:Close() end)
end

--Количество печати
local DermaImageButton = vgui.Create( "DImageButton", bg )
DermaImageButton:SetPos( 288, 138 )				
DermaImageButton:SetSize( 26, 26 )		
DermaImageButton:SetColor(Color(0,255,255))
DermaImageButton:SetImage( "icon16/arrow_up.png" )	
DermaImageButton.DoClick = function()
if Mtier == 6 then return end				
net.Start("upgrade")
net.WriteFloat(index)
net.WriteFloat(3)
net.SendToServer()
timer.Simple(p,function() QuestionPanel:Close() end)
end

--Громкость печати
local DermaImageButton = vgui.Create( "DImageButton", bg )
DermaImageButton:SetPos( 288, 200 )				
DermaImageButton:SetSize( 26, 26 )		
DermaImageButton:SetColor(Color(0,255,255))
DermaImageButton:SetImage( "icon16/arrow_up.png" )	
DermaImageButton.DoClick = function()	
if SDtier == 6 then return end			
net.Start("upgrade")
net.WriteFloat(index)
net.WriteFloat(4)
net.SendToServer()
timer.Simple(p,function() QuestionPanel:Close() end)
end

--Прочность принтера
local DermaImageButton = vgui.Create( "DImageButton", bg )
DermaImageButton:SetPos( 288, 262 )				
DermaImageButton:SetSize( 26, 26 )		
DermaImageButton:SetColor(Color(0,255,255))
DermaImageButton:SetImage( "icon16/arrow_up.png" )	
DermaImageButton.DoClick = function()	
if HPtier == 6 then return end			
net.Start("upgrade")
net.WriteFloat(index)
net.WriteFloat(5)
net.SendToServer()
timer.Simple(p,function() QuestionPanel:Close() end)
end

--Радиатор принтера
local DermaImageButton = vgui.Create( "DImageButton", bg )
DermaImageButton:SetPos( 288, 324 )				
DermaImageButton:SetSize( 26, 26 )		
DermaImageButton:SetColor(Color(0,255,255))
DermaImageButton:SetImage( "icon16/arrow_up.png" )	
DermaImageButton.DoClick = function()		
if TMPtier == 2 then return end		
net.Start("upgrade")
net.WriteFloat(index)
net.WriteFloat(6)
net.SendToServer()
timer.Simple(p,function() QuestionPanel:Close() end)
end

--Охлаждение
local DermaImageButton = vgui.Create( "DImageButton", bg )
DermaImageButton:SetPos( 550, 305 )				
DermaImageButton:SetSize( 26, 26 )		
DermaImageButton:SetColor(Color(0,150,255))
DermaImageButton:SetImage( "icon16/cog.png" )	
DermaImageButton.DoClick = function()		
net.Start("upgrade")
net.WriteFloat(index)
net.WriteFloat(8)
net.SendToServer()
QuestionPanel:Close()
end

end)

end)

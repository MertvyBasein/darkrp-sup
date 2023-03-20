pScoreboard = pScoreboard or {}

pScoreboard.Ranks = {'superadmin', 'admin'}

pScoreboard.UserActions = {

    ['Скопировать SteamID'] = {
        icon = 'https://i.yapx.ru/MFoCz.png',
        click = function(a)
            SetClipboardText(a:SteamID())
        end
    } ,

    ['Открыть профиль Steam'] = {
        icon = 'https://i.yapx.ru/MFoHg.png',
        click = function(a)
            gui.OpenURL('http://steamcommunity.com/profiles/' .. a:SteamID64())
        end
    }

}

pScoreboard.AdminActions = {

    ['Телепортироваться'] = {
        icon = 'https://i.yapx.ru/MFiTS.png',
        access = tbl,
        click = function(a)
            RunConsoleCommand('sam', 'goto', a:Name() )
        end
    },

    ['Телепортировать'] = {
        icon = 'https://i.yapx.ru/MFiSI.png',
        access = tbl,
        click = function(a)
            RunConsoleCommand('sam', 'bring', a:Name() )
        end
    },

    ['Вернуть'] = {
        icon = 'https://i.yapx.ru/MFiUT.png',
        access = tbl,
        click = function(a)
            RunConsoleCommand('sam', 'return', a:Name() )
        end
    },
    ['Заморозить'] = {
        icon = 'https://i.yapx.ru/MFiVd.png',
        access = tbl,
        click = function(a)
            RunConsoleCommand('sam','freeze', a:Name() )
        end
    },
    ['Разморозить'] = {
        icon = 'https://i.yapx.ru/MFiVd.png',
        access = tbl,
        click = function(a)
            RunConsoleCommand('sam','unfreeze', a:Name() )
        end
    }

}

surface.CreateFont('scrFont2',{font='Roboto Regular',size=18,weight=300,extended=true,antialias=true})surface.CreateFont("scrFont2_shadow",{font="Roboto Regular",extended=true,antialias=true,weight=300,blursize=3,size=18})local a=Material("pp/blurscreen")function draw.Blur(b,c)local d,e=b:LocalToScreen(0,0)local f,g=ScrW(),ScrH()surface.SetDrawColor(255,255,255)surface.SetMaterial(a)for h=1,3 do a:SetFloat("$blur",h/3*(c or 6))a:Recompute()render.UpdateScreenEffectTexture()surface.DrawTexturedRect(d*-1,e*-1,f,g)end end;file.CreateDir("downloaded_assets")local i=file.Exists;local j=file.Write;local k=http.Fetch;local l=Color(255,255,255)local surface=surface;local m=util.CRC;local n=Material("error")local math=math;local o={}function fetch_asset(p)if not p then return n end;if o[p]then return o[p]end;local m=m(p)if i("downloaded_assets/"..m..".png","DATA")then o[p]=Material("data/downloaded_assets/"..m..".png",'smooth mips')return o[p]end;o[p]=n;k(p,function(q)j("downloaded_assets/"..m..".png",q)o[p]=Material("data/downloaded_assets/"..m..".png",'smooth mips')end)return o[p]end;function draw.Icon(d,e,r,s,t,u)surface.SetMaterial(t)surface.SetDrawColor(Color(0,0,0,230))surface.DrawTexturedRect(d+1,e+1,r,s)surface.SetMaterial(t)surface.SetDrawColor(u or Color(255,255,255,255))surface.DrawTexturedRect(d,e,r,s)end

function JobCategoryС(team)
    for k,v in pairs(rp.teams) do
        if v.team == team then
            return v
        end
    end
end


function PLAYER:JobCat()
    return JobCategoryС(self:Team()).category
end



rp.category_jobs = {}
function rp.JobCategory()
    for k,v in pairs(rp.teams) do
        if !table.HasValue(rp.category_jobs, v.category) then 
            table.insert(rp.category_jobs,v.category)
        end
    end
    return rp.category_jobs
end

local a='https://i.yapx.ru/MFfXP.png'
local function b(c,d)end
local function e(f,g,h,i,j,k,l)
    draw.SimpleText(f,g..'_shadow',h+1,i+1,color_black,k,l)
    draw.SimpleText(f,g..'_shadow',h-1,i-1,color_black,k,l)
    draw.SimpleText(f,g,h,i,j,k,l)
end
   local m,n,o
   local function p(q,r)
    local s=draw.RoundedBox
      m=r:Add('DPanel')  
      m:Dock(TOP)
      m:SetTall(50)  
      m.Paint=function(t,c,d)
        s(8,0,0,c,d,ColorAlpha(team.GetColor(q:Team()),150))
        b(c,d)e(q:Name(),"scrFont2",c/2,d/2-8,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        e(team.GetName(q:Team()),"scrFont2",c/2,d/2+10,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
      end
      n=r:Add('DPanel')
      n:Dock(TOP)
      n:DockMargin(0,2,0,2)
      n:SetTall(200)
      n.Paint=function(t,c,d)s(0,0,0,c,d,Color(255,255,255,8))
      end
      local u=TDLib("DModelPanel",n)
      u:Dock(FILL)
      u:SetLookAt(Vector(0,0,55))
      u:SetCamPos(Vector(110,-10,40))
      u:SetFOV(25)u:SetAnimated(true)
      u:SetModel(q:GetModel())
      local v=u.Entity:LookupSequence("pose_standing_02")
      u.Entity:SetSequence(v)
      u.Angles=Angle(0,0,0)
      function u:DragMousePress()
        self.PressX,self.PressY=gui.MousePos()
        self.Pressed=true 
      end

      function u:DragMouseRelease()
        self.Pressed=false 
      end
         function u:LayoutEntity(w)
            if self.Pressed then 
                local x,y=gui.MousePos()
                self.Angles=self.Angles-Angle(0,(self.PressX or x)-x,0)
                self.PressX,self.PressY=gui.MousePos()
            end
            w:SetAngles(self.Angles)
         end
            o=r:Add('DPanel')
            o:Dock(FILL)
            o.Paint=nil
            local z=o:Add('DScrollPanel')
            z:Dock(FILL)
            z.Paint=nil
            z:InvalidateParent(true)
            z.VBar:SetWide(2)
            local A=z.VBar
            A:SetHideButtons(true)
            A.Paint=nil
            A.btnGrip.Paint=function(t,c,d)
                s(8,0,0,c,d,Color(255,255,255,100))
            end
            for B,C in pairs(pScoreboard.UserActions)do 
                local D=z:Add('DButton')
                D:Dock(TOP)
                D:DockMargin(0,1,0,1)
                D:SetText('')
                D:SetTall(48)
                D.DoClick=function()
                    C["click"](q)
                    XPGUI.PlaySound('xpgui/sidemenu/sidemenu_click_01.wav')
                end
            D.OnCursorEntered=function()
                XPGUI.PlaySound('xpgui/submenu/submenu_dropdown_rollover_01.wav')
            end
            D.Paint=function(E,c,d)
                local j=Color(255,255,255,8)
                if E.Hovered then 
                    j=Color(255,255,255,15)
                end
            s(8,0,0,c,d,j)
            b(c,d)e(B,"scrFont2",55,d/2,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            draw.Icon(15,10,25,25,fetch_asset(C.icon),color_white)
            end 
        end
            for B,C in pairs(pScoreboard.AdminActions) do 
                if not LocalPlayer():IsAdmin() then 
                    return 
                end
            local D=z:Add('DButton')
            D:Dock(TOP)
            D:DockMargin(0,1,0,1)
            D:SetText('')D:SetTall(48)
            D.DoClick=function()C["click"](q)
                XPGUI.PlaySound('xpgui/sidemenu/sidemenu_click_01.wav')
            end
            D.Paint=function(E,c,d)
                local j=Color(255,255,255,8)
                if E.Hovered then 
                    j=Color(255,255,255,15)
                end
            D.OnCursorEntered=function()
                XPGUI.PlaySound('xpgui/submenu/submenu_dropdown_rollover_01.wav')
            end
            s(8,0,0,c,d,j)
            b(c,d)
            e(B,"scrFont2",55,d/2,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            draw.Icon(15,10,25,25,fetch_asset(C.icon),color_white)
             end 
          end 
       end
            local function F()
                if m~=nil and m:IsValid() then 
                    m:Remove()
                end
               if n~=nil and n:IsValid() then 
                n:Remove()end
               if o~=nil and o:IsValid() then 
                o:Remove()
               end 
            end
               local G
               local function pScoreboard()
                local s=draw.RoundedBox
                  local H=Color(30,30,30,180)
                  local I=Color(30,30,30,125)
                  local J=Color(60,179,113,150)
                  G=TDLib('DPanel')
                  G:MakePopup()
                  G:SetSize(ScrW()/1.5,ScrH()/1.5)
                  G:Center()
                  G:SetAlpha(1)
                  G:AlphaTo(255,0.2,0)
                  G:SetKeyboardInputEnabled(false)
                  G.Paint=function(self,c,d)
                    draw.Blur(self,5)
                    s(8,0,0,c,d,I) 
                    b(c,d)s(8,0,0,c,50,I)
                    b(c,50)
                    draw.Icon(15,10,30,30,fetch_asset(a),color_white)
                    e(GetHostName(),"scrFont2",60,15,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_LEFT)
                    e(player.GetCount().."/"..game.MaxPlayers()..' онлайн игроков',"scrFont2",scrl:GetWide()/2,d-16,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                  end
                  scrl=TDLib("DScrollPanel",G)
                  scrl:Dock(FILL)
                  scrl:DockMargin(0,52,5,30)
                  scrl.Paint=nil
                  scrl:InvalidateParent(true)
                  scrl.VBar:SetWide(2)
                  local A=scrl.VBar
                  A:SetHideButtons(true)
                  A.Paint=nil
                  A.btnGrip.Paint=function(t,c,d)
                    s(8,0,0,c,d,Color(255,255,255,100))
                  end
                  local K=G:Add('DPanel')
                  K:Dock(RIGHT)
                  K:SetWide(300)
                  K:DockMargin(0,50,0,0)
                  K.Paint=function(t,c,d)
                    s(8,0,0,c,d,I)
                    b(c,d)
                  end
                  p(LocalPlayer(),K)
                  local L={}
                  for M,q in pairs(rp.JobCategory()) do 
                    L[q]={}
                    for N,O in ipairs(player.GetAll()) do 
                        if JobCategoryС(O:Team())==q then 
                            table.insert(L[q],O)
                        end 
                    end 
                  end
                  G.Update=function()
                    scrl:Clear()
                    local P=player.GetAll()
                    table.sort(P,function(Q,R)return 
                        Q:Team()>R:Team()
                    end)
                    for M,q in pairs(P) do 
                        for N,S in pairs(L) do 
                            cat=q:JobCat() 
                            if not IsValid(scrl[cat]) then 
                                if q:JobCat()==N then 
                                    scrl[cat]=TDLib("DCollapsibleCategory",scrl)
                                    scrl[cat]:SetLabel('')
                                    scrl[cat]:Dock(TOP)
                                    scrl[cat]:SetExpanded(true)
                                    scrl[cat].Header:SetTall(35)
                                    scrl[cat].Paint=nil

                                      scrl[cat].Header.Paint=function(self,c,d)
                                        local j=color_white
                                      if self.Hovered then 
                                        j=Color(255,255,255,100)
                                      end
                                      e(N,"scrFont2",5,d/2,j,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
                                    end 
                                 end 
                              end 
                           end
                  local T=TDLib("DButton",scrl[cat])
                  T:SetTall(35)
                  T:Dock(TOP)
                  T:DockMargin(15,1,8,1)
                  T:SetText("")
                  local U=TDLib("AvatarImage",T)
                  U:SetSize(28,28)
                  U:SetPos(5,3)
                  U:SetPlayer(q,28)
                  U.PaintOver=function(self,c,d)
                    surface.SetDrawColor(Color(0,0,0,100))
                    surface.DrawRect(0,0,c,d)
                  end
                  T.Paint=function(self,c,d)
                    if not q:IsValid() then 
                        G:Update() 
                        return 
                    end
                      if self.Hovered then 
                        local V=team.GetColor(q:Team())V.a=255
                        surface.SetDrawColor(V)
                    else 
                        local W=team.GetColor(q:Team())W.a=200
                        surface.SetDrawColor(W)
                    end
                      surface.DrawRect(0,2,c,d-4)
                      surface.SetDrawColor(Color(0,0,0,50))
                      surface.DrawOutlinedRect(0,2,c,d-4)
                      local X=q:Name()
                      local Y=q:GetJobName()
                      local Z=q:Ping() 
                      Z = math.ceil(Z / 1.2) 
                      e(X,"scrFont2",40,d/2,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
                      e(Y,"scrFont2",c/2,d/2,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                      e(Z,"scrFont2",c-10,d/2,color_white,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
                      s(8,0,0,2,d,Color(255,255,255,200))
                end
                  T.OnCursorEntered=function()
                    XPGUI.PlaySound('xpgui/submenu/submenu_dropdown_rollover_01.wav')
                    F()
                    p(q,K)
                  end T.DoClick = function()
                    XPGUI.PlaySound('xpgui/sidemenu/sidemenu_click_01.wav')
                  end 
               end 
            end
                  G:Update()
               end

hook.Add("Initialize","pScoreboardInitialize",function()
    GAMEMODE.ScoreboardShow=nil
    GAMEMODE.ScoreboardHide=nil 
end) 

tex = 'setActive_false' 
hook.Add("ScoreboardShow","pScoreboardShow",function() 
    if not(G==nil) then 
        pScoreboard()
        G:Update()
    else 
        pScoreboard()
    end
return true 
end)

hook.Add("ScoreboardHide","pScoreboardHide",function()
    if IsValid(G) then 
        G:Remove()
    end 
end)
local GM = GM or GAMEMODE
local bg_img     = Material("html/img/bg.jpg")
local gradient_u = Material("vgui/gradient_up")
local gradient_l = Material( "vgui/gradient-l" )
local gradient_r = Material( "vgui/gradient-r" )
local b_bonus
local b_bonus2
local function cleartabs()
    if IsValid(profile) then
        profile:Remove()
    end

    if IsValid(secbase) then
        secbase:Remove()
    end
end

local tg_colors = {
    ['Третий рейх'] = Color(0,230,0),
    ['СССР'] = Color(230,0,0)
}
local surface_SetDrawColor  = surface.SetDrawColor
local surface_DrawRect      = surface.DrawRect

local function DrawRect(x, y, w, h, t)
    if not t then t = 1 end
    surface_DrawRect(x, y, w, t)
    surface_DrawRect(x, y + (h - t), w, t)
    surface_DrawRect(x, y, t, h)
    surface_DrawRect(x + (w - t), y, t, h)
end

local function OutlinedBox(x, y, w, h, col, bordercol, thickness)
    surface_SetDrawColor(col)
    surface_DrawRect(x + 1, y + 1, w - 2, h - 2)

    surface_SetDrawColor(bordercol)
    DrawRect(x, y, w, h, thickness)
end

local function DrawCircle(x, y, radius, seg)
    local cir = {}

    table.insert(cir, {
        x = x,
        y = y
    })

    for i = 0, seg do
        local a = math.rad((i / seg) * -360)

        table.insert(cir, {
            x = x + math.sin(a) * radius,
            y = y + math.cos(a) * radius
        })
    end

    local a = math.rad(0)

    table.insert(cir, {
        x = x + math.sin(a) * radius,
        y = y + math.cos(a) * radius
    })

    surface.DrawPoly(cir)
end

local PANEL = {}

function PANEL:Init()
    self.avatar = vgui.Create("AvatarImage", self)
    self.avatar:SetPaintedManually(true)
    self.button = vgui.Create("DButton", self.avatar)
    self.button:SetText('')
    self.button:SetPaintedManually(true)

    self.button.OnCursorEntered = function(this)
        surface.PlaySound("garrysmod/ui_hover.wav")
    end

    self.button.DoClick = function(this)
        surface.PlaySound("garrysmod/ui_click.wav")

        if self.picked_ply ~= nil then
            gui.OpenURL("http://steamcommunity.com/profiles/".. self.picked_ply)
        end
    end

    self.button.Paint = function(this, w, h)
        if (this.Depressed or this.m_bSelected) then
            surface.SetDrawColor(travka_ui.colors.Hover.r,travka_ui.colors.Hover.g,travka_ui.colors.Hover.b,travka_ui.colors.Hover.a or 100)
        elseif (this.Hovered) then
            surface.SetDrawColor(0,0,0,100)
        else
            surface.SetDrawColor(0,0,0,0)
        end
        
        surface.DrawRect(0,0,w,h)
    end
end

function PANEL:PerformLayout()
    self.avatar:SetSize(self:GetWide(), self:GetTall())
    self.button:SetSize(self:GetWide(), self:GetTall())
end

function PANEL:SetPlayer(ply, size)
    if ply:GetNWBool("HideMe") then
        self.avatar:SetSteamID(ply:SteamID64(), size)
    else
        self.avatar:SetPlayer(ply, size)
    end
    self.picked_ply = ply:SteamID64()
end

function PANEL:SetSteamID(sid, size)
    self.avatar:SetSteamID(sid, size)
    self.picked_ply = sid
end

function PANEL:Paint(w, h)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilPassOperation(STENCILOPERATION_ZERO)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render.SetStencilReferenceValue(1)
    draw.NoTexture()
    surface.SetDrawColor(Color(0, 0, 0, 255))
    DrawCircle(w / 2, h / 2, h / 2, 6)
    render.SetStencilFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilReferenceValue(1)
    self.avatar:PaintManual()
    render.SetStencilEnable(false)
    render.ClearStencil()
end

vgui.Register('fui_avatar', PANEL, 'Panel')

function rp.ToggleF4Menu()
    local frame = vgui.Create("XPFrame")
    frame:SetSize(ScrW() * .65, ScrH() * .65)
    frame:Center()
    frame:SetTitle("Главное меню")

    frame:SetNoRounded(true)

    local keydown = false
        function frame:Think()
            if input.IsKeyDown(KEY_F4) and keydown then

            frame:Remove()

            elseif (not input.IsKeyDown(KEY_F4)) then
                keydown = true
            end
        end

    local left_panel = vgui.Create("XPScrollPanel", frame)
    left_panel:Dock(LEFT)
    left_panel:DockMargin(6, 6, 6, 6)
    left_panel:SetWide(150)
    left_panel.Paint = function(self,w,h)
        draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0, 100))
    end

    local function mainprofile()
    profile = vgui.Create('DPanel', frame)
    profile:Dock(FILL)
    profile:DockMargin(0, 6, 6, 6)
    profile:InvalidateParent(true)
    profile.Paint = function(self,w,h)
        draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,100))
    end

    local profile_model = vgui.Create('DModelPanel', profile)
    profile_model:Dock(LEFT)
    profile_model:SetWide(profile:GetWide() / 2 - 150)
    profile_model:DockMargin(5, 5, 5, 5)
    profile_model:SetModel(LocalPlayer():GetModel())
    local eyepos = profile_model.Entity:GetBonePosition(profile_model.Entity:LookupBone("ValveBiped.Bip01_Head1") or 0)
    profile_model:SetCamPos(eyepos - Vector(-66, 0, 0))
    profile_model:GetEntity():SetSkin(LocalPlayer():GetSkin())
    local rnd = math.random(1,4)
    profile_model.Angles = Angle(0,0,0)
    function profile_model:DragMousePress()
        self.PressX, self.PressY = gui.MousePos()
        self.Pressed = true
    end

    function profile_model:DragMouseRelease()
        self.Pressed = false
    end

    profile_model.LayoutEntity = function(self, ent)
        profile_model:SetFOV(35 + (math.sin(RealTime()))) -- *3.5
        ent:SetSequence(ent:LookupSequence("pose_standing_0"..rnd))


        if not IsValid(ent) then return end
        if ( self.bAnimated ) then
            self:RunAnimation()
        end

        if ( self.Pressed ) then
            local mx, my = gui.MousePos()
            self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
            self.PressX, self.PressY = gui.MousePos()
        end
        ent:SetAngles( self.Angles )
    end

    for i = 1, 7 do
        profile_model:GetEntity():SetBodygroup(i, LocalPlayer():GetBodygroup(i))
    end

    local oldpaint = profile_model.Paint

    profile_model.Paint = function(s,w,h)
        draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0, 100))
        oldpaint(s,w,h)
        frametext(LocalPlayer():GetName(), GetFont(10), w / 2, 2, Color(255,255,255), 1, 0)
    end

    local profile_inventory = vgui.Create('XPScrollPanel', profile)
    profile_inventory:Dock(FILL)
    profile_inventory:DockMargin(0, 5, 5, 5)
    profile_inventory:InvalidateParent(true)
    profile_inventory.VBar:SetWide(3)
    profile_inventory.Paint = function(self,w,h)
        draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0, 100))
    end

    local progress = vgui.Create("DPanel", profile_inventory)
    progress:Dock(TOP)
    progress:DockMargin(3, 2, 3, 2)

    progress.Paint = function(self,w,h)
        draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,55))
        --draw.RoundedBox(5, 0, 0, LocalPlayer():GetStoradeWeight_Inv() / LocalPlayer():GetMaxWeight_Inv() * w, h, Color(152, 152, 152,55))

        --frametext(rp.inventory.FormatWeight(LocalPlayer():GetStoradeWeight_Inv()) .. ' | ' .. rp.inventory.FormatWeight(LocalPlayer():GetMaxWeight_Inv()), GetFont(9), w*.5, h*.5, Color(255,255,255), 1, 1)
        frametext('Инвентарь', GetFont(9), w*.5, h*.5, Color(255,255,255), 1, 1)
    end


    local OItems = vgui.Create("DIconLayout", profile_inventory)
    OItems:Dock(FILL)
    OItems:SetSpaceY(1)
    OItems:SetSpaceX(1)
    OItems:DockMargin(5, 1, 1, 1)
    OItems.Paint = nil

    local slots = 42
    local костыль = (#LocalPlayer():GetInventory() + slots) >=30 and 3 or 2

    local function AddSlot()

        local item = OItems:Add("DPanel")
        item:SetTall(profile_inventory:GetTall() / 6 - костыль)
        item:SetWide(profile_inventory:GetWide() / 6 - костыль)
    
        item.Paint = function(self,w,h)

            draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,100))
    
        end

    end

    for k,v in pairs(LocalPlayer():GetInventory()) do
        slots = slots - 1
        local item = OItems:Add("DPanel")
        item:SetTall(profile_inventory:GetTall() / 6 - костыль)
        item:SetWide(profile_inventory:GetWide() / 6 - костыль)

        local item_col = v.color

        item.Paint = function(self,w,h)
                draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,100))

                surface.SetDrawColor(item_col.r, item_col.g, item_col.b, 55)

                surface.SetMaterial( gradient_u )
                surface.DrawTexturedRectRotated(w, h, w, ScrH()*.4, 45)

        end

        local WHSize = (ScrW() + ScrH()) / 1.8


        if v.save_data['icon'] ~= nil then
            local name = v.class
            local model = vgui.Create("DPanel", item)
            model:Dock(FILL)
            model:DockPadding(0, 30, 0, 30)
            DownloadMaterial(v.save_data['icon'], tostring(name)..".png", function(m)
                model.Paint = function(self,w,h)
                    surface.SetDrawColor(Color(255,255,255))
                    surface.SetMaterial(m)
                    surface.DrawTexturedRect(10,10,w - 20,h - 20)
                end
            end)
        else 
            local model = vgui.Create("DModelPanel", item)
            model:Dock(FILL)
            model:DockPadding(0, 30, 0, 30)
        
            if v.save_data['model'] ~= nil then
                model:SetModel(v.save_data['model'])
            elseif v.def_model ~= nil then
                model:SetModel(v.def_model)
            else
                model:SetModel('models/props_borealis/bluebarrel001.mdl')
            end
        
            local mn, mx = model.Entity:GetRenderBounds()
            local size = 0
            size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
            size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
            size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
            model:SetMouseInputEnabled(false)
            model:SetFOV(WHSize * 0.035)
            model:SetCamPos(Vector(size, size, size))
            model:SetLookAt((mn + mx) * (WHSize * 0.0005))
        
            model.OnCursorEntered = function()
                XPGUI.PlaySound("xpgui/submenu/submenu_dropdown_rollover_01.wav")
            end
        
            model.OnDepressed = function()
                XPGUI.PlaySound("xpgui/sidemenu/sidemenu_click_01.wav")
            end
        
            model.DoClick = function(slf) end
            model.LayoutEntity = function(ent) return end
        end

        -- Old model view

        -- local model = vgui.Create("DModelPanel", item)
        -- model:Dock(FILL)
        -- model:DockPadding(0, 30, 0, 30)

        -- function model:LayoutEntity(Entity)
        --     return
        -- end

        -- model:SetFOV(40)
        -- if v.save_data['model'] ~= nil then
        --     model:SetModel( v.save_data['model'] )
        -- elseif v.def_model ~= nil then
        --     model:SetModel( v.def_model )
        -- else
        --     model:SetModel( 'models/props_borealis/bluebarrel001.mdl' )
        -- end
        -- local min, max = model.Entity:GetRenderBounds()
        -- model:SetCamPos(min:Distance(max) * Vector(0.5, 0.5, 0.2) + Vector(0, 33, 0))
        -- model:SetLookAt((max + min) * .5)

        local button = vgui.Create("XPButton", item)
        button:SetSize(ScrW(), ScrH())
        button:SetText('')

        button:SetToolTip(v.save_data['subname'] or rp.inventory.Languge[v.class] or "N/A")

        button.Paint = function(self,w,h)

            if (self.Depressed or self.m_bSelected) then
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
            elseif (self.Hovered) then
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 75))
            end
        end

        button.DoClick = function(self)
            local menu = vgui.Create("XPMenu", parent)

            if v.canuse then
                menu:AddOption("Использовать", function()

                    surface.PlaySound("garrysmod/ui_click.wav")

                    if v.save_data['count'] ~= nil then
                        v.save_data['count'] = v.save_data['count'] - 1

                        local weight_per_item = rp.inventory.CustomWeight[rp.shipments[v.save_data['content']].entity] or 3
                        weight_per_item = weight_per_item * v.save_data['count']
                        v.weight = weight_per_item

                        if v.save_data['count'] <= 0 then self:SetEnabled(false) item:Remove() end
                    else
                        self:SetEnabled(false)
                        item:Remove()
                        AddSlot()
                    end


                    net.Start("rp.inventory.Use")
                        net.WriteInt(k, 32)
                    net.SendToServer()

                end)
            end
            menu:AddOption(v.class == 'shop_itm' and 'Удалить' or "Выкинуть", function()

                surface.PlaySound("garrysmod/ui_click.wav")
                if v.class == 'shop_itm' then
                    Derma_Query( "Вы уверены что желаете удалить этот предмет?", "Подтверждение", "Да", function()
                        -- self:SetEnabled(false)
                        net.Start("rp.inventory.Delete")
                            net.WriteInt(k, 32)
                        net.SendToServer()
                        item:Remove()
                        AddSlot()
                    end, "Нет" )
                    return
                end

                net.Start("rp.inventory.Drop")
                net.WriteInt(k, 32)
                net.SendToServer()
                item:Remove()
                AddSlot()
            end)

            menu:Open()
        end


        end

        for i =1,slots do

            local item = OItems:Add("DPanel")
            item:SetTall(profile_inventory:GetTall() / 6 - костыль)
            item:SetWide(profile_inventory:GetWide() / 6 - костыль)
    
            item.Paint = function(self,w,h)

                draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,100))
    
            end
        end

    end

    local function jobsmain()


        profile = vgui.Create('XPScrollPanel', frame)
        profile:Dock(FILL)
        profile:DockMargin(0, 6, 6, 6)
        profile:InvalidateParent(true)
        profile.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
        end        


       -- local bar = profile.VBar  
        --bar.Paint = function(this, w, h) end
       -- bar.btnUp.Paint = function(this, w, h) end
        --bar.btnDown.Paint = function(this, w, h) end

        profile.Paint = function(self, w, h)
            surface.SetDrawColor(0,0,0,100)
            surface.DrawRect(0,0,w,h)
        end

        secbase = vgui.Create("DPanel", frame)
        secbase:SetSize(frame:GetWide() * .25, frame:GetTall() - 29)
        secbase:Dock(RIGHT)
        secbase:InvalidateParent(true)
        secbase:SetVisible(false)

        local JobModel = vgui.Create("DModelPanel", secbase)
        JobModel:SetSize(secbase:GetWide() * .6, secbase:GetTall() * .45)
        JobModel:SetPos(secbase:GetWide() * .2, 0)
        JobModel:SetFOV(40)
        JobModel.Angles = Angle(0,0,0)
        function JobModel:DragMousePress()
            self.PressX, self.PressY = gui.MousePos()
            self.Pressed = true
        end

        function JobModel:DragMouseRelease() 
            self.Pressed = false
        end

        function JobModel:LayoutEntity( ent )
            if ( self.bAnimated ) then self:RunAnimation() end

            if ( self.Pressed ) then
                local mx, my = gui.MousePos()
                self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )

                self.PressX, self.PressY = gui.MousePos()
            end

            ent:SetAngles( self.Angles )
        end
        local prevm = vgui.Create("XPButton", secbase)
        prevm:SetSize(secbase:GetWide() * .2, secbase:GetTall() * .45)
        prevm:SetPos(0, 0)
        prevm:SetText("")
        prevm:SetVisible(false)

        prevm.Paint = function(self, w, h)
            if (self.Depressed or self.m_bSelected) then
                drawShadowText("<", "xpgui_medium", w * .5, h * .5, Color(134,28,176, 255), 1, 1)
            elseif (self.Hovered) then
                drawShadowText("<", "xpgui_medium", w * .5, h * .5, Color(180, 180, 180, 255), 1, 1)
            else
                drawShadowText("<", "xpgui_medium", w * .5, h * .5, Color(255, 255, 255, 200), 1, 1)
            end
        end

        prevm.DoClick = function(this)
            surface.PlaySound("garrysmod/ui_click.wav")
            local nextModel = table.FindPrev(v.model, curModel)
            JobModel:SetModel(nextModel)
            curModel = nextModel
        end

        prevm.OnCursorEntered = function(this)
            surface.PlaySound("garrysmod/ui_hover.wav")
        end

        local nextm = vgui.Create("XPButton", secbase)
        nextm:SetSize(secbase:GetWide() * .2, secbase:GetTall() * .45)
        nextm:SetPos(secbase:GetWide() * .8, 0)
        nextm:SetText("")
        nextm:SetVisible(false)

        nextm.Paint = function(self, w, h)
            if (self.Depressed or self.m_bSelected) then
                drawShadowText(">", "xpgui_medium", w * .5, h * .5, Color(134,28,176, 255), 1, 1)
            elseif (self.Hovered) then
                drawShadowText(">", "xpgui_medium", w * .5, h * .5, Color(180, 180, 180, 255), 1, 1)
            else
                drawShadowText(">", "xpgui_medium", w * .5, h * .5, Color(255, 255, 255, 200), 1, 1)
            end
        end

        nextm.DoClick = function(this)
            surface.PlaySound("garrysmod/ui_click.wav")
            local nextModel = table.FindNext(v.model, curModel)
            JobModel:SetModel(nextModel)
            curModel = nextModel
        end

        nextm.OnCursorEntered = function(this)
            surface.PlaySound("garrysmod/ui_hover.wav")
        end

        local setjob = vgui.Create("DButton", secbase)
        setjob:SetSize(secbase:GetWide(), secbase:GetTall() * .05)
        setjob:SetPos(0, secbase:GetTall() - (secbase:GetTall() * .05))
        setjob:SetText("")

        setjob.OnCursorEntered = function(this)
            surface.PlaySound("garrysmod/ui_hover.wav")
        end

        local discription = vgui.Create("RichText", secbase)
        discription:SetSize(secbase:GetWide() - 4, secbase:GetTall() * .45 + 2)
        discription:SetPos(2, secbase:GetTall() * .5 - 4)
        discription.Paint = function(self, w, h)
        end
        discription.PerformLayout = function()
            discription:SetFontInternal( "xpgui_small" )
            discription:SetFGColor( Color( 255, 255, 255 ) )
        end
        local categories = {}

        for i, data in pairs(RPExtraTeams) do
            local tc = data.category or "Другое"
            categories[tc] = categories[tc] or {}
            categories[tc][i] = data
        end

        local panelOpenState = {}

        for name, jobs in pairs(categories) do
            panelOpenState[name] = true
        end

        for name, jobs in pairs(categories) do
            local category = vgui.Create("DPanel", profile)
            category:Dock(TOP)
            category:DockMargin(2,1,2,1)
            category.open = panelOpenState[name]

            if category.open then
                category:SetSize(profile:GetWide(), 28 + ( (profile:GetTall() * .07 + 2) * table.Count(jobs) ))
            else
                category:SetSize(profile:GetWide(), 28)
            end

            function category:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, 29, Color(255, 255, 255, 5))
            end
            local fixes = vgui.Create("XPButton", category)
            fixes:Dock(TOP)
            fixes:SetTall(28)
            fixes:SetText("")
            fixes.Paint = function(this, w, h)
                if (this.Depressed or this.m_bSelected) then
                    surface.SetDrawColor(134,28,176, 50)
                elseif (this.Hovered) then
                    surface.SetDrawColor(155, 155, 155, 50)
                else
                    surface.SetDrawColor(0, 0, 0, 100)
                end
                surface.DrawRect(0,0,w,h)
                drawShadowText(name, "xpgui_small", 30, h/2, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                --draw.RoundedBox(5, 10, 10, 10, 10, Color(255,255,255,255))
                if category.open then 
                    draw.RoundedBox(3, 12, 12, 6, 6, Color(0,0,0,255))
                end
            end

            function fixes:OnMousePressed()
                category.open = not category.open
                if category.open then
                    category:SizeTo(self:GetWide(), 28 + ( (profile:GetTall() * .07 + 2) * table.Count(jobs) ), 0.3)
                else
                    category:SizeTo(self:GetWide(), 28, 0.3)
                end
                panelOpenState[name] = category.open
            end

            for k, v in pairs(jobs) do
                local job = vgui.Create("XPButton", category)
                job:Dock(TOP)
                job:DockMargin(2, 1, 2, 1)
                job:SetTall(profile:GetTall() * .07)
                job:SetContentAlignment(5)
                job:SetText("")
                local c = v.color
                job.Paint = function(this, w, h)
                    if (this.Depressed or this.m_bSelected) then
                        surface.SetDrawColor(134,28,176, 70)
                    elseif (this.Hovered) then
                        if v.max <= team.NumPlayers(k) and v.max > 0 then
                            surface.SetDrawColor(175, 75, 75, 80)
                        else
                            surface.SetDrawColor(155, 155, 155, 70)
                        end
                    else
                        if v.max <= team.NumPlayers(k) and v.max > 0 then
                            surface.SetDrawColor(155, 55, 55, 70)
                        else
                            surface.SetDrawColor(c.r, c.g, c.b, 20)
                        end
                    end
                    surface.DrawRect(0,0,w,h)
                    local x = h + 5
                    if v.vip then
                        x = x + draw.SimpleTextOutlined('[ВИП]', 'xpgui_small', x, h*.5, Color(255,155,55), 0, 1, 1, Color(0,0,0)) + 5
                    end
                    if v.staff then
                        x = x + draw.SimpleTextOutlined('[АДМИН]', 'xpgui_small', x, h*.5, Color(255,155,55), 0, 1, 1, Color(0,0,0)) + 5
                    end
                    drawShadowText(v.name, "xpgui_small", x, h*.5, Color(255, 255, 255, 200), 0, 1)
                    if v.max > 0 then
                        surface.SetFont("xpgui_small")
                        local x1 = surface.GetTextSize(team.NumPlayers(k) .. "/" .. v.max)
                        drawShadowText(team.NumPlayers(k) .. "/" .. v.max, "xpgui_small", w - x1 - 5, h*.5, Color(255, 255, 255, 200), 0, 1)
                    end
                    draw.RoundedBox(0, 5, 5, h - 10, h - 10, Color(155, 155, 155, 70))
                end

                job.OnCursorEntered = function(this)
                    surface.PlaySound("garrysmod/ui_hover.wav")
                end
                local gasd = {
                    "pose_standing_01",
                    "pose_standing_02",
                    "pose_standing_03",
                    "pose_standing_04",
                    "pose_ducking_01"
                }
                job.DoClick = function(this)
                    surface.PlaySound("garrysmod/ui_click.wav")
                    local curModel

                    if type(v.model) == "table" then
                        curModel = table.GetFirstValue(v.model)
                    end

                    if type(v.model) == "table" then
                        JobModel:SetModel(curModel)
                        nextm:SetVisible(true)
                        prevm:SetVisible(true)
                    else
                        JobModel:SetModel(v.model)
                        nextm:SetVisible(false)
                        prevm:SetVisible(false)
                    end
                    JobModel:SetAnimated( true )
                    local dance = JobModel:GetEntity():LookupSequence( gasd[math.random(#gasd)] )
                    JobModel:GetEntity():SetSequence( dance )
                    secbase:SetVisible(true)
                    secbase:MoveTo(frame:GetWide() - secbase:GetWide() - 2, 27, 0.3, 0, -1)

                    prevm.DoClick = function(this)
                        surface.PlaySound("garrysmod/ui_click.wav")
                        local nextModel = table.FindPrev(v.model, curModel)
                        JobModel:SetModel(nextModel)
                        local dance = JobModel:GetEntity():LookupSequence( gasd[math.random(#gasd)] )
                        JobModel:GetEntity():SetSequence( dance )
                        curModel = nextModel
                    end

                    nextm.DoClick = function(this)
                        surface.PlaySound("garrysmod/ui_click.wav")
                        local nextModel = table.FindNext(v.model, curModel)
                        JobModel:SetModel(nextModel)
                        local dance = JobModel:GetEntity():LookupSequence( gasd[math.random(#gasd)] )
                        JobModel:GetEntity():SetSequence( dance )
                        curModel = nextModel
                    end

                    setjob.Paint = function(self, w, h)
                        if (self.Depressed or self.m_bSelected) then
                            surface.SetDrawColor(134,28,176, 50)
                        elseif (self.Hovered) then
                            if v.max <= team.NumPlayers(k) and v.max > 0 then
                                surface.SetDrawColor(175, 75, 75, 80)
                            else
                                surface.SetDrawColor(155, 155, 155, 70)
                            end
                        else
                            if v.max <= team.NumPlayers(k) and v.max > 0 then
                                surface.SetDrawColor(155, 55, 55, 70)
                            else
                                surface.SetDrawColor(0, 0, 0, 200)
                            end
                        end
                        surface.DrawRect(0,0,w,h)

                        drawShadowText("Выбрать", "xpgui_medium", w * .5, h * .5, Color(255, 255, 255, 200), 1, 1)
                    end

                    setjob.DoClick = function(this)
                        if type(v.model) == "table" then
                            for _, team in pairs(team.GetAllTeams()) do
                                if team.Name == v.name then
                                    surface.PlaySound("garrysmod/ui_click.wav")
                                end
                            end
                        end

                       cmd.Run(v.command)
                    end

                    secbase.Paint = function(self, w, h)
                        local col = v.color
                        surface.SetDrawColor(0, 0, 0, 100)
                        surface.DrawRect(0,0,w,h)

                        surface.SetDrawColor(col.r,col.g,col.b,70)
                        surface.DrawRect(0,h * .46,w,h*.036)
                        drawShadowText(v.name, "xpgui_small", w * .5, h * .475, Color(255, 255, 255, 255), 1, 1)
                    end

                    discription:SetText(v.description)
                end

                local model = vgui.Create("DModelPanel", job)
                model:SetSize(job:GetTall() - 10, job:GetTall() - 10)
                model:SetPos(5, 5)

                if type(v.model) == "string" then
                    model:SetModel(v.model)
                else
                    model:SetModel(table.Random(v.model))
                end
            end
        end
    end

    local function mainshop()
        profile = vgui.Create('DPanel', frame)
        profile:Dock(FILL)
        profile:DockMargin(0, 6, 6, 6)
        profile:InvalidateParent(true)
        profile.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,100))
        end
        local fw, fh = frame:GetWide(), frame:GetTall()
        bagr = vgui.Create("DPanel", profile)
        bagr:Dock(FILL)
        bagr:DockMargin(0, 0, 0, 0)
        bagr:InvalidateParent(true)
        bagr.Paint = nil

        local Property = {}
        Property.Categories = {}
        Property.Scroll = vgui.Create("DScrollPanel", bagr)
        Property.Scroll:Dock(FILL)
        Property.Scroll:InvalidateParent(true)
        Property.Scroll.VBar:SetWide(3)
        Property.Scroll:DockMargin(0, 0, 0, 0)
        local bar = Property.Scroll.VBar
        bar:SetHideButtons(true)
        bar.Paint = function(self, w, h) end
        bar.btnUp.Paint = function(self, w, h) end
        bar.btnDown.Paint = function(self, w, h) end

        local function GenerateCategory(name)
            for k, v in pairs(Property.Categories) do
                if v.Title == name then return v end
            end
            
            local AriviaCategory = vgui.Create("AriviaCategory", Property.Scroll)
            AriviaCategory:Dock(TOP)
            AriviaCategory:DockMargin(0, 3, 0, 0)
            AriviaCategory:HeaderTitle(name)

            AriviaCategory.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 50))
            end

            table.insert(Property.Categories, AriviaCategory)
            AriviaCategory.List = vgui.Create("DIconLayout", AriviaCategory)
            AriviaCategory.List:Dock(FILL)
            AriviaCategory.List:DockMargin(5, 5, 0, 0)
            AriviaCategory.List.Paint = function(panel, w, h) end
            AriviaCategory.List:SetSpaceY(5)
            AriviaCategory.List:SetSpaceX(5)

            return AriviaCategory
        end

        for k, v in ipairs(rp.ammoTypes) do
            //if not v.allowed[LocalPlayer():Team()] then continue end
            //if v.customCheck and not v.customCheck(LocalPlayer()) then continue end

            if not Property.Value then Property.Value = v end

            AriviaCategory = GenerateCategory("Патроны")

            local ListItem = vgui.Create("XPButton")
            ListItem:SetSize((Property.Scroll:GetWide() - 20) / 3, 60)
            ListItem:SetText("")

            ListItem.DoClick = function()
                cmd.Run('buyammo', v.ammoType)
            end

            function ListItem:Paint(w, h)

                if (self.Depressed or self.m_bSelected) then
                    draw.RoundedBox(7, 0, 0, w, h, Color(152, 152, 152,135))
                elseif (self.Hovered) then
                    draw.RoundedBox(7, 0, 0, w, h, Color(152, 152, 152, 35))
                end

                draw.RoundedBox(7, 0, 0, w, h, Color(152, 152, 152, 30))

                local x, y = draw.SimpleText(v.name, GetFont(10), 70, 5, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
                draw.SimpleText(rp.FormatMoney(v.price), GetFont(10), 70, 5 + y, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
            end

            local PlayerModel = vgui.Create("DModelPanel", ListItem)
            PlayerModel.LayoutEntity = function() return end

            if istable(v.model) then
                PlayerModel:SetModel(v.model[1])
            else
                PlayerModel:SetModel(v.model)
            end

            PlayerModel:SetPos(0, 0)
            PlayerModel:SetSize(60, 60)
            PlayerModel:SetFOV(22)
            PlayerModel:SetCamPos(Vector(100, 90, 65))
            PlayerModel:SetLookAt(Vector(9, 9, 15))
            AriviaCategory.List:Add(ListItem)
            AriviaCategory:AddNewChild(ListItem)

            PlayerModel.Paint = function(self, w, h)
                if (not IsValid(self.Entity)) then return end
                local x, y = self:LocalToScreen(0, 0)
                self:LayoutEntity(self.Entity)
                local ang = self.aLookAngle

                if (not ang) then
                    ang = (self.vLookatPos - self.vCamPos):Angle()
                end

                cam.Start3D(self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ)
                render.SuppressEngineLighting(true)
                render.SetLightingOrigin(self.Entity:GetPos())
                render.ResetModelLighting(self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255)
                render.SetColorModulation(self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255)
                render.SetBlend(self.colColor.a / 255)

                for i = 0, 6 do
                    local col = self.DirectionalLight[i]

                    if (col) then
                        render.SetModelLighting(i, col.r / 255, col.g / 255, col.b / 255)
                    end
                end

                self:DrawModel()
                render.SuppressEngineLighting(false)
                cam.End3D()
                self.LastPaint = RealTime()
            end

            profile:SetVisible(false)
        end

        for k, v in ipairs(rp.entities) do
            if not v.allowed[LocalPlayer():Team()] then continue end
            if v.customCheck and not v.customCheck(LocalPlayer()) then continue end

            if not Property.Value then
                Property.Value = v
            end

            if v.category then
                AriviaCategory = GenerateCategory(v.category)
            else
                AriviaCategory = GenerateCategory("Другое")
            end

            local ListItem = vgui.Create("XPButton")
            ListItem:SetSize((Property.Scroll:GetWide() - 20) / 3, 60)
            ListItem:SetText("")

            ListItem.DoClick = function()
                cmd.Run(v.cmd:sub(2))
            end

            function ListItem:Paint(w, h)

                if (self.Depressed or self.m_bSelected) then
                    draw.RoundedBox(7, 0, 0, w, h, Color(152, 152, 152,135))
                elseif (self.Hovered) then
                    draw.RoundedBox(7, 0, 0, w, h, Color(152, 152, 152, 35))
                end

                draw.RoundedBox(7, 0, 0, w, h, Color(152, 152, 152, 30))
                local x, y = draw.SimpleText(v.name, GetFont(12), 70, 5, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
                draw.SimpleText(rp.FormatMoney(v.price), GetFont(12), 70, 5 + y, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
            end

            local PlayerModel = vgui.Create("DModelPanel", ListItem)
            PlayerModel.LayoutEntity = function() return end

            if istable(v.model) then
                PlayerModel:SetModel(v.model[1])
            else
                PlayerModel:SetModel(v.model)
            end
            PlayerModel:SetPos(0, 0)
            PlayerModel:SetSize(60, 60)
            PlayerModel:SetFOV(22)
            PlayerModel:SetCamPos(Vector(100, 90, 65))
            PlayerModel:SetLookAt(Vector(9, 9, 15))
            AriviaCategory.List:Add(ListItem)
            AriviaCategory:AddNewChild(ListItem)

            PlayerModel.Paint = function(self, w, h)
                if (not IsValid(self.Entity)) then return end
                local x, y = self:LocalToScreen(0, 0)
                self:LayoutEntity(self.Entity)
                local ang = self.aLookAngle

                if (not ang) then
                    ang = (self.vLookatPos - self.vCamPos):Angle()
                end

                cam.Start3D(self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ)
                render.SuppressEngineLighting(true)
                render.SetLightingOrigin(self.Entity:GetPos())
                render.ResetModelLighting(self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255)
                render.SetColorModulation(self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255)
                render.SetBlend(self.colColor.a / 255)

                for i = 0, 6 do
                    local col = self.DirectionalLight[i]

                    if (col) then
                        render.SetModelLighting(i, col.r / 255, col.g / 255, col.b / 255)
                    end
                end

                self:DrawModel()
                render.SuppressEngineLighting(false)
                cam.End3D()
                self.LastPaint = RealTime()
            end

            profile:SetVisible(true)
        end

        for k, v in ipairs(rp.shipments) do
            if not v.seperate then continue end
            if not v.allowed[LocalPlayer():Team()] then continue end

            if not Property.Value then
                Property.Value = v
            end

            if v.category then
                AriviaCategory = GenerateCategory(v.category)
            else
                AriviaCategory = GenerateCategory("Другое")
            end

            local ListItem = vgui.Create("XPButton")
            ListItem:SetSize((Property.Scroll:GetWide() - 20) / 3, 60)
            ListItem:SetText("")

            ListItem.DoClick = function()
                cmd.Run('buyshipment', v.name)
            end

            function ListItem:Paint(w, h)

                if (self.Depressed or self.m_bSelected) then
                    draw.RoundedBox(7, 0, 0, w, h, Color(152, 152, 152,135))
                elseif (self.Hovered) then
                    draw.RoundedBox(7, 0, 0, w, h, Color(152, 152, 152, 35))
                end

                draw.RoundedBox(7, 0, 0, w, h, Color(152, 152, 152, 30))
                local x, y = draw.SimpleText(v.name, GetFont(12), 70, 5, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
                draw.SimpleText(rp.FormatMoney(v.price), GetFont(12), 70, 5 + y, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
            end

            local PlayerModel = vgui.Create("DModelPanel", ListItem)
            PlayerModel.LayoutEntity = function() return end

            if istable(v.model) then
                PlayerModel:SetModel(v.model[1])
            else
                PlayerModel:SetModel(v.model)
            end
            PlayerModel:SetPos(0, 0)
            PlayerModel:SetSize(60, 60)
            PlayerModel:SetFOV(22)
            PlayerModel:SetCamPos(Vector(100, 90, 65))
            PlayerModel:SetLookAt(Vector(9, 9, 15))
            AriviaCategory.List:Add(ListItem)
            AriviaCategory:AddNewChild(ListItem)

            PlayerModel.Paint = function(self, w, h)
                if (not IsValid(self.Entity)) then return end
                local x, y = self:LocalToScreen(0, 0)
                self:LayoutEntity(self.Entity)
                local ang = self.aLookAngle

                if (not ang) then
                    ang = (self.vLookatPos - self.vCamPos):Angle()
                end

                cam.Start3D(self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ)
                render.SuppressEngineLighting(true)
                render.SetLightingOrigin(self.Entity:GetPos())
                render.ResetModelLighting(self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255)
                render.SetColorModulation(self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255)
                render.SetBlend(self.colColor.a / 255)

                for i = 0, 6 do
                    local col = self.DirectionalLight[i]

                    if (col) then
                        render.SetModelLighting(i, col.r / 255, col.g / 255, col.b / 255)
                    end
                end

                self:DrawModel()
                render.SuppressEngineLighting(false)
                cam.End3D()
                self.LastPaint = RealTime()
            end

            profile:SetVisible(true)
        end

        for k, v in pairs(Property.Categories) do
            timer.Simple(.2, function()
                if not IsValid(v) then return end
                v:ToggleOpened()
            end)
        end

    end

    local function donateshop()

        profile = vgui.Create('DPanel', frame)
        profile:Dock(FILL)
        profile:DockMargin(0, 6, 6, 6)
        profile:InvalidateParent(true)
        profile.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
        end

        local donate_profile = vgui.Create('DPanel', profile)
        donate_profile:Dock(TOP)
        donate_profile:SetTall(32)
        donate_profile.Paint = function(self,w,h)
            draw.RoundedBox(0,  0,  0,  w,  h, Color(0,0,0,40))
            draw.SimpleText('Ваш баланс: '..LocalPlayer():IGSFunds()..'Р', 'xpgui_medium', 10,h/2,Color(255,255,255), 0,1)
        end

        local popoln = vgui.Create('XPButton', donate_profile)
        popoln:Dock(RIGHT)
        popoln:SetWide(100)
        popoln:SetText('Пополнить')
        popoln.DoClick = function()

            Derma_StringRequest('Пополение счета', 'Введите сумму, на которую хотите пополнить счет', '', function(summa)
                summa = tonumber(summa)
                if not isnumber(summa) then return end
                IGS.GetPaymentURL(summa, function(url) gui.OpenURL(url)end)
            end)

        end

        local cupon = vgui.Create('XPButton', donate_profile)
        cupon:Dock(RIGHT)
        cupon:SetWide(100)
        cupon:SetText('Промокод')
        cupon.DoClick = function()

            Derma_StringRequest('Ввод промокода', 'Введите промокод', '', function(promo)
                net.Start('BetterPromos_Use')
                net.WriteString(promo)
                net.SendToServer()
            end)

        end

        local fw, fh = frame:GetWide(), frame:GetTall()

            -- local igslvl = vgui.Create("DPanel", profile)
            -- igslvl:Dock(FILL)
            -- igslvl.Paint = function(self,w,h)
            --     draw.SimpleText('Похоже вы не разу не пополняли ваш донат-счет', 'xpgui_medium', w/2,h/2 - 55,Color(255,255,255), 1,1)
            --     draw.SimpleText('Мы дарим вам бонус на первое пополнение 10%, пополните ваш счет и бонус придет на ваш аккаунт', 'xpgui_medium', w/2,h/2 - 30,Color(255,255,255), 1,1)
            -- end
    
            -- local okbtn = vgui.Create("XPButton", igslvl)
            -- okbtn:Dock(BOTTOM)
            -- okbtn:SetText("Понял!")
            -- okbtn.DoClick = function()
            --     igslvl:Remove()
            -- end

        product_list = vgui.Create("DPanel", profile)
        product_list:Dock(LEFT)
        product_list:SetWide(profile:GetWide() / 2 + 50 - 2)
        product_list:DockMargin(1, 0, 1, 1)
        product_list:InvalidateParent(true)
        product_list.Paint = nil

        purchase_panel = vgui.Create("DPanel", profile)
        purchase_panel:Dock(RIGHT)
        purchase_panel:SetWide(profile:GetWide() / 2 - 60)
        purchase_panel:DockMargin(0, 0, 0, 0)
        purchase_panel:InvalidateParent(true)
        purchase_panel:DockMargin(3, 3, 3, 3)
        purchase_panel.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,60))
            draw.SimpleText('Нажмите на понравившихся товар слева', "xpgui_medium",w/2,h/2,Color(255,255,255),1,1)
            draw.SimpleText('<<<------', "xpgui_big",w/2,h/2 + 50,Color(255,255,255),1,1)
        end

        /*if not IsValid(b_bonus2) then
            b_bonus2 = vgui.Create("DPanel", frame)
            b_bonus2:Dock(BOTTOM)
            b_bonus2:SetTall(30)
            b_bonus2:DockMargin(0, 0, 6, 6)
            b_bonus2.Paint = function(self,w,h)
                OutlinedBox( 0, 0, w, h, Color(0,0,0,100), HSVToColor(CurTime() % 6 * 60, 1, 1), 1)
                draw.SimpleText('Действует X2 донат', "xpgui_medium",w/2,h/2,Color(255,255,255),1,1)
            end
        end*/

        if IGS.PlayerLVL(LocalPlayer()) == nil then
            if not IsValid(b_bonus) then
                b_bonus = vgui.Create("DPanel", frame)
                b_bonus:Dock(BOTTOM)
                b_bonus:SetTall(30)
                b_bonus:DockMargin(0, 0, 6, 6)
                b_bonus.Paint = function(self,w,h)
                    OutlinedBox( 0, 0, w, h, Color(0,0,0,100), HSVToColor(CurTime() % 6 * 60, 1, 1), 1)
                    draw.SimpleText('Дарим вам бонус 10% от суммы пополнения при первом донате', "xpgui_medium",w/2,h/2,Color(255,255,255),1,1)
                end
            end
        end



        local Property = {}
        Property.Categories = {}
        Property.Scroll = vgui.Create("DScrollPanel", product_list)
        Property.Scroll:Dock(FILL)
        Property.Scroll:InvalidateParent(true)
        Property.Scroll.VBar:SetWide(3)
        Property.Scroll:DockMargin(0, 0, 0, 0)
        local bar = Property.Scroll.VBar
        bar:SetHideButtons(true)
        bar.Paint = function(self, w, h) end
        bar.btnUp.Paint = function(self, w, h) end
        bar.btnDown.Paint = function(self, w, h) end

        local function GenerateCategory(name)
            for k, v in pairs(Property.Categories) do
                if v.Title == name then return v end
            end

            local AriviaCategory = vgui.Create("AriviaCategory", Property.Scroll)
            AriviaCategory:Dock(TOP)
            AriviaCategory:DockMargin(0, 3, 0, 0)
            AriviaCategory:HeaderTitle(name)

            AriviaCategory.Paint = function(self, w, h)
                draw.RoundedBox(5, 0, 0, w, h, Color(0, 0, 0, 50))
            end

            table.insert(Property.Categories, AriviaCategory)
            AriviaCategory.List = vgui.Create("DIconLayout", AriviaCategory)
            AriviaCategory.List:Dock(FILL)
            AriviaCategory.List:DockMargin(5, 5, 0, 0)
            AriviaCategory.List.Paint = function(panel, w, h) end
            AriviaCategory.List:SetSpaceY(5)
            AriviaCategory.List:SetSpaceX(5)

            return AriviaCategory
        end

        for k, v in ipairs(rp.cfg.donateshop) do

            if v.icon != '' then
              texture.Create(v.icon)
              :SetSize(500, 500)
              :SetFormat(v.icon:sub(-3) == "jpg" and "jpg" or "png")
              :Download(v.icon, function() end, function() end)
            end

            if not Property.Value then Property.Value = v end

            AriviaCategory = GenerateCategory("Игровая валюта")
            AriviaCategory1 = GenerateCategory("Игровое время")
            AriviaCategory2 = GenerateCategory("Привилегии")
            AriviaCategory3 = GenerateCategory("Остальное")
            AriviaCategory4 = GenerateCategory("Оружия")

            local ListItem = vgui.Create("XPButton")
            ListItem:SetSize((Property.Scroll:GetWide() - 20) / 5 - 3, 100)
            ListItem:SetText("")

            ListItem.DoClick = function()
                if IsValid(purchase_panel) then purchase_panel:Remove() end
                purchase_panel = vgui.Create("DPanel", profile)
                purchase_panel:Dock(RIGHT)
                purchase_panel:SetWide(profile:GetWide() / 2 - 60)
                purchase_panel:InvalidateParent(true)
                purchase_panel:DockMargin(3, 3, 3, 3)
                purchase_panel.Paint = function(self,w,h)
                    draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,100))

                    if v.icon != '' and texture.Get(v.icon) then
                      surface.SetDrawColor(255,255,255,255)
                      surface.SetMaterial(texture.Get(v.icon))
                      surface.DrawTexturedRect(purchase_panel:GetWide() / 2 - ScrW() * .055, purchase_panel:GetTall() / 2 - ScrH() * .20, ListItem:GetWide() * 2, ListItem:GetWide() * 2)
                    end

                end

                local purchase_top = vgui.Create('DPanel', purchase_panel)
                purchase_top:Dock(TOP)
                purchase_top:SetTall(32)
                purchase_top:DockMargin(2, 2, 2, 2)
                purchase_top.Paint = function(self,w,h)
                    draw.RoundedBox(5, 0, 0, w, h, Color(152,152,152,100))
                    draw.SimpleText(v.name,"xpgui_small",w /2, h/2,Color(255,255,255),1,1)
                end

                local purchase_bot = vgui.Create('XPButton', purchase_panel)
                purchase_bot:Dock(BOTTOM)
                purchase_bot:SetTall(32)
                purchase_bot:DockMargin(2, 2, 2, 2)
                purchase_bot.Paint = function(self,w,h)
                    draw.RoundedBox(5, 0, 0, w, h, Color(39, 174, 96,100))
                    draw.SimpleText('Приобрести за '..v.price..' P',"xpgui_small",w /2, h/2,Color(255,255,255),1,1)
                end
                purchase_bot.DoClick = function()
                    net.Start("MetaHub.DonateBuy")
                        net.WriteString(v.name)
                    net.SendToServer()
                end

                local purchase_description = vgui.Create('DPanel', purchase_panel)
                purchase_description:Dock(FILL)
                purchase_description:DockMargin(5, 300, 5, 5)
                purchase_description.Paint = nil

                local RichText = vgui.Create('RichText', purchase_description)
                RichText:Dock(FILL)
                RichText:InsertColorChange(255, 255, 255, 255)
                RichText:AppendText(v.description)

                function RichText:PerformLayout()

                    self:SetFontInternal( "xpgui_small" )
                    self:SetFGColor( Color(255,255,255) )

                end

            end

            local top_name = vgui.Create('DPanel', ListItem)
            top_name:Dock(TOP)
            top_name:SetTall(20)
            top_name.Paint = function(self,w,h)
                draw.RoundedBox(0, 0, 0, w, h, Color(152,152,152,100))
                draw.SimpleText(v.name,"xpgui_tiny",w/2,h/2,Color(255,255,255),1,1)
            end

            local bottom_name = vgui.Create('DPanel', ListItem)
            bottom_name:Dock(BOTTOM)
            bottom_name:SetTall(20)
            bottom_name.Paint = function(self,w,h)
                draw.RoundedBox(0, 0, 0, w, h, Color(152,152,152,100))
                draw.SimpleText(v.price..' Р',"xpgui_small",w/2,h/2,Color(255,255,255),1,1)
            end

            function ListItem:Paint(w, h)

                if (self.Depressed or self.m_bSelected) then
                    draw.RoundedBox(0, 0, 20, w, h - 40, Color(152, 152, 152,135))
                elseif (self.Hovered) then
                    draw.RoundedBox(0, 0, 20, w, h - 40, Color(152, 152, 152, 35))
                end

                if v.icon != '' and texture.Get(v.icon) then
                  surface.SetDrawColor(255,255,255,255)
                  surface.SetMaterial(texture.Get(v.icon))
                  surface.DrawTexturedRect((ListItem:GetWide() *.5) / 2, ListItem:GetTall() *.25, ListItem:GetWide() *.5, ListItem:GetWide() *.5)
                end

                draw.RoundedBox(0, 0, 0, w, h, Color(152, 152, 152, 30))
            end
            


            if v.cat == 'Игровая валюта' then

                AriviaCategory.List:Add(ListItem)
                AriviaCategory:AddNewChild(ListItem)

            elseif v.cat == 'Игровое время' then

                AriviaCategory1.List:Add(ListItem)
                AriviaCategory1:AddNewChild(ListItem)

            elseif v.cat == 'Привилегии' then
                AriviaCategory2.List:Add(ListItem)
                AriviaCategory2:AddNewChild(ListItem)

            elseif v.cat == 'Остальное' then
                AriviaCategory3.List:Add(ListItem)
                AriviaCategory3:AddNewChild(ListItem)

            elseif v.cat == 'Оружия' then
                AriviaCategory4.List:Add(ListItem)
                AriviaCategory4:AddNewChild(ListItem)
            end

            

        end

        for k, v in pairs(Property.Categories) do
            timer.Simple(.2, function()
                if not IsValid(v) then return end
                v:ToggleOpened()
            end)
        end

    end
    
    local function skillsmenu()
    profile = vgui.Create('DPanel', frame)
    profile:Dock(FILL)
    profile:DockMargin(0, 6, 6, 6)
    profile:InvalidateParent(true)

    profile.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
    end

    for k, v in pairs(rp.SkillsCategory) do
        local Skill_Category = vgui.Create('ui_scrollpanel', profile)
        Skill_Category:Dock(TOP)
        Skill_Category:SetTall(200)
        Skill_Category:InvalidateParent(true)
        local Skill_Category_Name = vgui.Create('DPanel', Skill_Category)
        Skill_Category_Name:Dock(TOP)
        Skill_Category_Name:SetTall(50)

        Skill_Category_Name.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
            surface.SetDrawColor(Color(0, 0, 0, 50))
            surface.DrawOutlinedRect(0, 0, w, h)
            draw.SimpleText(v, "xpgui_big", w / 2, h / 2, Color(255, 255, 255), 1, 1)
        end

        local OItems = vgui.Create("DIconLayout", Skill_Category)
        OItems:Dock(FILL)
        OItems:InvalidateParent(true)
        OItems:SetSpaceY(1)
        OItems:SetSpaceX(1)
        OItems:DockMargin(0, 1, 0, 0)
        OItems.Paint = nil

        for kk, vv in SortedPairsByMemberValue(rp.SkillsTable, "RequireProgress", true) do
            if v == vv.Category then
                local skills = OItems:Add("DPanel")
                skills:SetTall(OItems:GetTall() / 3 - 1 + 24)
                skills:SetWide(OItems:GetWide() / 3 - 1)

                skills.Paint = function(self, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
                    surface.SetDrawColor(Color(0, 0, 0, 50))
                    surface.DrawOutlinedRect(0, 0, w, h)
                    draw.SimpleText(kk, "xpgui_big", w / 2, 0, Color(255, 255, 255), 1, 3)

                    if LocalPlayer():GetSkillLevel(kk) == vv.MaxLevel then
                        draw.SimpleText('Максимальный уровень', "xpgui_small", w / 2, h / 2 + 5, Color(255, 255, 255), 1, 1)
                        draw.SimpleText(LocalPlayer():GetSNextLevel(kk) .. '/' .. LocalPlayer():GetSNextLevel(kk), "xpgui_tiny", w - 5, h - 25, Color(255, 255, 255), 2, 0)
                    else
                        draw.SimpleText(LocalPlayer():GetSkillLevel(kk) .. ' уровень', "xpgui_small", w / 2, h / 2 + 5, Color(255, 255, 255), 1, 1)
                        draw.SimpleText(LocalPlayer():GetSkillProgress(kk) .. '/' .. LocalPlayer():GetSNextLevel(kk), "xpgui_tiny", w - 5, h - 25, Color(255, 255, 255), 2, 0)
                    end

                    draw.SimpleText('Прогресс:', "xpgui_tiny", 2, h - 25, Color(255, 255, 255), 0, 0)
                end

                local skillprogress = vgui.Create('DPanel', skills)
                skillprogress:Dock(BOTTOM)
                skillprogress:SetTall(10)

                skillprogress.Paint = function(self, w, h)
                    if LocalPlayer():GetSkillLevel(kk) == vv.MaxLevel then
                        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
                        draw.RoundedBox(0, 0, 0, w, h, Color(156, 156, 156, 155))
                    else
                        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
                        draw.RoundedBox(0, 0, 0, LocalPlayer():GetSkillProgress(kk) / LocalPlayer():GetSNextLevel(kk) * w, h, Color(156, 156, 156, 155))
                    end
                end
            end
        end
    end
end

    local function settings()
        profile = vgui.Create('DPanel', frame)
        profile:Dock(FILL)
        profile:DockMargin(0, 6, 6, 6)
        profile:InvalidateParent(true)
        profile.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
        end

        local scroll = vgui.Create('XPScrollPanel', profile)
        scroll:Dock(FILL)

        for k, v in pairs(cvar.GetTable()) do
            local typ = v:GetMetadata('Type') or "bool"
            if (typ == 'bool') then
                local name = v:GetName()
                local m = vgui.Create("EditablePanel", scroll)
                m:Dock(TOP)
                m:SetTall(21)

                local c = vgui.Create("XPCheckBox", m)
                --c:SetFont('xpgui_small')
                --c:SetText(v:GetMetadata("Menu") or 'n/a')
                c:SetValue(cvar.GetValue(name))
                c:SetPos(5,5)
                c.OnChange = function(self, b)
                    cvar.SetValue(name, not cvar.GetValue(name))
                end

                local label = vgui.Create('DLabel', m)
                    label:SetFont('xpgui_small')
                    label:SetText(v:GetMetadata("Menu") or 'n/a')
                    label:SetPos(25, 2)
                    label:SizeToContents()

            elseif (typ == 'number') then
                local b = vgui.Create("DPanel", scroll)
                b:Dock(TOP)
                b:DockMargin(2, 1, 2, 1)
                b:SetTall(22)

                b.Paint = function()
                    rp.util.DrawShadowText(v:GetMetadata("Menu"), "defont20", 2, 2, WHITE, 0, 0)
                end

                local slider = vgui.Create("XPHorizontalScroller", b)
                slider:SetPos(2, 2)
                slider:SetWide(scroll:GetWide()*.2)
              --  slider:SetValue(tonumber(v:GetValue()))
                slider.OnChange = function(s, val)
                    if(v:GetMetadata("Menu") == 'Размеры F4 меню') then
                        if val < 0.35 then
                            s:SetValue(0.35)
                        elseif val > 1.5 then
                            s:SetValue(1.5)
                        end

                        v:SetValue(s:GetValue())

                        w, h = (ScrW() * 0.45 / 2) * (cvar.GetValue('f4MenuSizes') * 4), (ScrH() * 0.43 / 2) * (cvar.GetValue('f4MenuSizes') * 4)
                        fr:SetSize(w, h)

                    else
                        v:SetValue(val)
                    end
                end
            end
        end
    end

    local function HasTake(client, iRewardID, bPaidOrFree)
       return (client:CanClaimBPReward(iRewardID, bPaidOrFree) && client:HasClaimBPReward(iRewardID, bPaidOrFree))
    end

    local function battlepass_menu()
        profile = vgui.Create('DPanel', frame)
        profile:Dock(FILL)
        profile:DockMargin(0, 6, 6, 6)
        profile:InvalidateParent(true)
        profile.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
        end

        local T_Panel = vgui.Create('DPanel', profile)
        T_Panel:Dock(TOP)
        T_Panel:SetTall(75)
        T_Panel:DockMargin(5, 5, 5, 0)
        T_Panel:InvalidateParent(true)
        --T_Panel.Paint = nil
        T_Panel.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,55))
            frametext("У вас "..LocalPlayer():GetBPLevel().." уровень", "xpgui_huge", w/2,5,Color(255,255,255),1,0)
            local xp = LocalPlayer():GetBPXP()
            draw.RoundedBox(5, 5, h/2 + 10, w - 10, h / 2 - 15, Color(0,0,0,55))
            frametext(xp.." / 100 XP", 'xpgui_small', w/2, h/2 + 10, Color(255,255,255), 1, 0)
            draw.RoundedBox(5, 5, h/2 + 10, xp / 100 * w - 10, h / 2 - 15, Color(152,152,152,55))
        end

        -- local L_Button = vgui.Create("XPButton", T_Panel)
        -- L_Button:Dock(LEFT)
        -- L_Button:SetText("Боевой пропуск")
        -- L_Button:SetWide(T_Panel:GetWide() / 2 - 5)

        -- local R_Button = vgui.Create("XPButton", T_Panel)
        -- R_Button:Dock(FILL)
        -- R_Button:SetText("Задания")

        -- local TP_Panel = vgui.Create('DPanel', profile)
        -- TP_Panel:Dock(TOP)
        -- TP_Panel:SetTall(25)
        -- TP_Panel:DockMargin(8, 5, 8, 0)
        -- TP_Panel:InvalidateParent(true)
        -- TP_Panel.Paint = function(self,w,h)
            -- local xp = LocalPlayer():GetBPXP()
            -- draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,55))
            -- frametext(xp.." / 100 XP", 'xpgui_small', w/2, h/2, Color(255,255,255), 1, 1)
            -- draw.RoundedBox(5, 0, 0, xp / 100 * w, h, Color(152,152,152,55))
        -- end

        local M_Panel = vgui.Create('DPanel', profile)
        M_Panel:Dock(FILL)
        M_Panel:DockMargin(8, 5, 8, 5)
        M_Panel:InvalidateParent(true)
        M_Panel.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(0,0,0,55))
        end

        local horizontal_scroll = vgui.Create("XPHorizontalScroller", M_Panel)
        horizontal_scroll:Dock(FILL)
        horizontal_scroll:SetOverlap( -5 )

        local rewMainPanel_sizey = M_Panel:GetWide() *.8 - 4 * 0.25

        local item = battlepass.RewardTable[-1]

        local reward = vgui.Create("DPanel", horizontal_scroll)
        reward:Dock(LEFT)
        reward:DockMargin(0, 2, 5, 2)
        reward:SetWide(250)
        reward:SetTall(100)
        reward.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,55))
            draw.RoundedBox(5, 5, 5, w- 10, 20, Color(245, 245, 245, 25))
            frametext('1 Уровень', "xpgui_small", w/2, 15, Color(255,255,255), 1, 1)
        end

        local Reward_M = vgui.Create("DModelPanel", reward)
        Reward_M:Dock(FILL)
        Reward_M:DockMargin(5, 30, 5, 5)
        Reward_M:SetModel( item.mdl )

        local WHSize = (ScrW() + ScrH()) / 1.8
        local mn, mx = Reward_M.Entity:GetRenderBounds()
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
        Reward_M:SetMouseInputEnabled(false)
        Reward_M:SetFOV(WHSize * 0.035)
        Reward_M:SetCamPos(Vector(size, size, size))
        Reward_M:SetLookAt((mn + mx) * (WHSize * 0.0005))
        Reward_M.OnCursorEntered = function() XPGUI.PlaySound("xpgui/submenu/submenu_dropdown_rollover_01.wav") end
        Reward_M.OnDepressed = function() XPGUI.PlaySound("xpgui/sidemenu/sidemenu_click_01.wav") end
        Reward_M.DoClick = function(slf) end
        Reward_M.LayoutEntity = function(ent) return end

        if (LocalPlayer():HasClaimBPReward(-1)) then
            local grab = vgui.Create('XPButton', reward)
            grab:Dock(BOTTOM)
            grab:SetTall(25)
            local canclaim = LocalPlayer():CanClaimBPReward(-1)
            grab:SetText(canclaim and "Забрать" or item.name)
            grab.PaintOver = function(self,w,h)
                draw.RoundedBox(5, 0, 0, w, h, canclaim and Color(0,200,0, 55) or Color(200,0,0, 55))
            end
            grab.DoClick = function(self)
                if (HasTake(LocalPlayer(), -1) == false) then return end
                netstream.Start("Battlepass::ClaimReward", -1)


                self:Remove()
            end
        end

        horizontal_scroll:AddPanel(reward)

        local RewardTable = battlepass.RewardTable
        for i= 1, #RewardTable do

        local item = RewardTable[i]

        local rewpnl = vgui.Create("EditablePanel",  horizontal_scroll)
        rewpnl:Dock(LEFT)
        rewpnl:DockMargin(0, 0, 5, 0)
        rewpnl:SetWide(128)
        rewpnl.Paint = function(pnl, w, h)
            draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(color_black, 55))
        end

        local reward = vgui.Create("DPanel", rewpnl)
        reward:Dock(TOP)
        reward:DockMargin(0, 0, 0, 2)
        reward:SetTall(M_Panel:GetTall() / 2 -15)
        reward:SetWide(rewpnl:GetWide())
        reward.Paint = function(self,w,h)
            draw.RoundedBox(5, 5, 5, w- 10, 20, Color(245, 245, 245, 25))
            frametext((i + 1).." Уровень", "xpgui_small", w/2, 15, Color(255,255,255), 1, 1)
        end

        if item['free'].mdl then
            local Reward_M = vgui.Create("DModelPanel", reward)
            Reward_M:Dock(FILL)
            Reward_M:DockMargin(5, 30, 5, 5)
            Reward_M:SetModel( item['free'].mdl )
            local WHSize = (ScrW() + ScrH()) / 1.8
            local mn, mx = Reward_M.Entity:GetRenderBounds()
            local size = 0
            size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
            size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
            size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
            Reward_M:SetMouseInputEnabled(false)
            Reward_M:SetFOV(WHSize * 0.035)
            Reward_M:SetCamPos(Vector(size, size, size))
            Reward_M:SetLookAt((mn + mx) * (WHSize * 0.0005))
            Reward_M.OnCursorEntered = function() XPGUI.PlaySound("xpgui/submenu/submenu_dropdown_rollover_01.wav") end
            Reward_M.OnDepressed = function() XPGUI.PlaySound("xpgui/sidemenu/sidemenu_click_01.wav") end
            Reward_M.DoClick = function(slf) end
            Reward_M.LayoutEntity = function(ent) return end
        elseif item['free'].img then
            local Reward_M = vgui.Create("DPanel", reward)
            Reward_M:Dock(FILL)
            Reward_M:DockMargin(5, 30, 5, 5)
            DownloadMaterial(item['free'].img, tostring(item['free'].lvl).."free.png", function(m)
                Reward_M.Paint = function(self,w,h)
                    surface.SetDrawColor(Color(255,255,255))
                    surface.SetMaterial(m)
                    surface.DrawTexturedRect(10,25,w - 20,h - 50)
                end
            end)
        end


        if (LocalPlayer():HasClaimBPReward(i)) then
            local grab = vgui.Create('XPButton', reward)
            grab:Dock(BOTTOM)
            grab:SetTall(25)
            grab:SetText(LocalPlayer():CanClaimBPReward(i) and "Забрать" or item['free'].name)
            grab.PaintOver = function(self,w,h)
                draw.RoundedBox(5, 0, 0, w, h, LocalPlayer():CanClaimBPReward(i) and Color(0,200,0, 55) or Color(200,0,0, 55))
            end
            grab.DoClick = function(self)
               if (HasTake(LocalPlayer(), i) == false) then return end
                netstream.Start("Battlepass::ClaimReward", i)


                self:Remove()
            end
        end

        local reward = vgui.Create("DPanel", rewpnl)
        reward:Dock(TOP)
        reward:DockMargin(0, 0, 0, 2)
        reward:SetTall(M_Panel:GetTall() / 2 -15)
        reward:SetWide(rewpnl:GetWide())
        reward.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0, 55))
            draw.RoundedBox(5, 5, 5, w- 10, 20, Color(245, 245, 245, 25))
            frametext("Премиум", "xpgui_small", w/2, 15, Color(241, 196, 15), 1, 1)
        end

        if item['paid'].mdl then
            local Reward_M = vgui.Create("DModelPanel", reward)
            Reward_M:Dock(FILL)
            Reward_M:DockMargin(5, 30, 5, 5)
            Reward_M:SetModel( item['paid'].mdl )
            local WHSize = (ScrW() + ScrH()) / 1.8
            local mn, mx = Reward_M.Entity:GetRenderBounds()
            local size = 0
            size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
            size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
            size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
            Reward_M:SetMouseInputEnabled(false)
            Reward_M:SetFOV(WHSize * 0.035)
            Reward_M:SetCamPos(Vector(size, size, size))
            Reward_M:SetLookAt((mn + mx) * (WHSize * 0.0005))
            Reward_M.OnCursorEntered = function() XPGUI.PlaySound("xpgui/submenu/submenu_dropdown_rollover_01.wav") end
            Reward_M.OnDepressed = function() XPGUI.PlaySound("xpgui/sidemenu/sidemenu_click_01.wav") end
            Reward_M.DoClick = function(slf) end
            Reward_M.LayoutEntity = function(ent) return end
        elseif item['paid'].img then
            local Reward_M = vgui.Create("DPanel", reward)
            Reward_M:Dock(FILL)
            Reward_M:DockMargin(5, 30, 5, 5)
            DownloadMaterial(item['paid'].img, tostring(item['paid'].lvl).."paid.png", function(m)
                Reward_M.Paint = function(self,w,h)
                    surface.SetDrawColor(Color(255,255,255))
                    surface.SetMaterial(m)
                    surface.DrawTexturedRect(10,25,w - 20,h - 50)
                end
            end)
        end

        if (LocalPlayer():HasClaimBPReward(i, 1)) then
            local grab = vgui.Create('XPButton', reward)
            grab:Dock(BOTTOM)
            grab:SetTall(25)
            grab:SetText(LocalPlayer():CanClaimBPReward(i, 1) and "Забрать" or item["paid"].name)
            grab.PaintOver = function(self,w,h)
                draw.RoundedBox(5, 0, 0, w, h, LocalPlayer():CanClaimBPReward(i, 1) and Color(0,200,0, 55) or Color(200,0,0, 55))
            end
            grab.DoClick = function(self)
                if (HasTake(LocalPlayer(), i, 1) == false) then return end
                netstream.Start("Battlepass::ClaimReward", i, 1)

                self:Remove()
            end
        end

        horizontal_scroll:AddPanel(rewpnl)

        end
    
        local item = battlepass.RewardTable[-2]

        local reward = vgui.Create("DPanel", horizontal_scroll)
        reward:Dock(LEFT)
        reward:DockMargin(0, 2, 5, 2)
        reward:SetWide(250)
        reward:SetTall(100)
        reward.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,55))
            draw.RoundedBox(5, 5, 5, w- 10, 20, Color(245, 245, 245, 25))
            frametext(#battlepass.RewardTable+2 .. ' Уровень', "xpgui_small", w/2, 15, Color(255,255,255), 1, 1)
        end

        local Reward_M = vgui.Create("DPanel", reward)
        Reward_M:Dock(FILL)
        Reward_M:DockMargin(5, 30, 5, 5)
        --Reward_M:SetModel( item.mdl )

        local WHSize = (ScrW() + ScrH()) / 1.8
        --local mn, mx = Reward_M.Entity:GetRenderBounds()
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
        Reward_M:SetMouseInputEnabled(false)
       -- Reward_M:SetFOV(WHSize * 0.035)
        --Reward_M:SetCamPos(Vector(size, size, size))
        --Reward_M:SetLookAt((mn + mx) * (WHSize * 0.0005))
        Reward_M.OnCursorEntered = function() XPGUI.PlaySound("xpgui/submenu/submenu_dropdown_rollover_01.wav") end
        Reward_M.OnDepressed = function() XPGUI.PlaySound("xpgui/sidemenu/sidemenu_click_01.wav") end
        Reward_M.DoClick = function(slf) end
        Reward_M.LayoutEntity = function(ent) return end
        DownloadMaterial(item.img, tostring(item.lvl).."paid.png", function(m)
                Reward_M.Paint = function(self,w,h)
                    surface.SetDrawColor(Color(255,255,255))
                    surface.SetMaterial(m)
                    surface.DrawTexturedRect(10,25,w - 20,h - 50)
                end
            end)

        if (LocalPlayer():HasClaimBPReward(-2)) then
            local grab = vgui.Create('XPButton', reward)
            grab:Dock(BOTTOM)
            grab:SetTall(25)
            local canclaim = LocalPlayer():CanClaimBPReward(-2)
            grab:SetText(canclaim and "Забрать" or item.name)
            grab.PaintOver = function(self,w,h)
                draw.RoundedBox(5, 0, 0, w, h, canclaim and Color(0,200,0, 55) or Color(200,0,0, 55))
            end
            grab.DoClick = function(self)
                if (HasTake(LocalPlayer(), -2) == false) then return end
                netstream.Start("Battlepass::ClaimReward", -2)


                self:Remove()
            end
        end

        horizontal_scroll:AddPanel(reward)

    end

    local function referalsmenu()
        
        profile = vgui.Create('DPanel', frame)
        profile:Dock(FILL)
        profile:DockMargin(0, 6, 6, 6)
        profile:InvalidateParent(true)
        profile.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
        end

        M_Panel = vgui.Create("DPanel", profile)
        M_Panel:Dock(FILL)
        M_Panel:InvalidateParent(true)
        M_Panel.Paint = nil

        local M_Top_Panel = vgui.Create("DPanel", profile)
        M_Top_Panel:Dock(TOP)
        M_Top_Panel:SetTall(50)
        M_Top_Panel:InvalidateParent(true)
        M_Top_Panel.Paint = nil
        
        local function RMain()

            M_Panel = vgui.Create("DPanel", profile)
            M_Panel:Dock(FILL)
            M_Panel:InvalidateParent(true)
            M_Panel.Paint = nil

            local pinfo = vgui.Create('DPanel', M_Panel)
            pinfo:Dock(TOP)
            pinfo:DockMargin(2, 1, 2, 0)
            pinfo:SetTall(ScrW()*.1)
    
            local avatar = vgui.Create("fui_avatar", pinfo)
            avatar:SetPos(M_Panel:GetWide()*.5 - 115/2, 5)
            avatar:SetTall(115)
            avatar:SetWide(115)
            avatar:SetPlayer(LocalPlayer(), 128)
    
            pinfo.Paint = function(self,w,h)
            
              draw.SimpleText(LocalPlayer():Name(), "xpgui_medium", w*.5, (pinfo:GetTall() + avatar:GetTall()) / 2 - 10, Color(255,255,255,255),1,0)
            end
    
            local promoname = vgui.Create('DPanel', M_Panel)
            promoname:Dock(TOP)
            promoname:DockMargin(2, 1, 2, 1)
            promoname:SetTall(ScrW()*.035)
            
            promoname.Paint = function(self,w,h)     
                draw.SimpleText("Ваш промокод", "xpgui_big", w*.5, h*.25, Color(255,255,255,255),1,1)
                draw.SimpleText(LocalPlayer():SteamID64(), "xpgui_small", w*.5, h*.75, Color(152, 152, 152),1,1)
            end
    
            local promoname = vgui.Create('DPanel', M_Panel)
            promoname:Dock(TOP)
            promoname:DockMargin(2, 1, 2, 1)
            promoname:SetTall(ScrW()*.020)
            
            promoname.Paint = function(self,w,h)     
                draw.SimpleText("Активаций: "..LocalPlayer():GetNetVar("Bonus").activate, "xpgui_medium", w*.5, h / 2, Color(255,255,255,255),1,1)
            end

            local infomenu = vgui.Create('DPanel', M_Panel)
            infomenu:Dock(TOP)
            infomenu:DockMargin(2, 1, 2, 1)
            infomenu:SetTall(ScrW()*.020)
            
            infomenu.Paint = function(self,w,h)
                infomenu:SetCursor("hand")
                draw.SimpleText("Попросите друга ввести в чат /bonus "..LocalPlayer():SteamID64().." (нажмите чтобы скопировать)", "xpgui_medium", w*.5, h / 2, Color(255,255,255,255),1,1)
            end
            infomenu.OnMousePressed = function()

                SetClipboardText('/bonus '..LocalPlayer():SteamID64())
                PlayAction("http://metahub.ru/tts.mp3")

            end
    
            local btn = vgui.Create("XPButton", M_Panel)
            btn:Dock(TOP)
            btn:SetTall(50)
            btn:SetText("")
            btn.Paint = function(self,w,h)
                draw.SimpleText("Получить награду", "xpgui_medium", w/2, h/2, Color(255,255,255), 1, 1)
            end
            btn.DoClick = function()
                RunConsoleCommand('promocode_getreward')
            end
        end
        RMain()

    end

    local function actions()
        profile = vgui.Create('DPanel', frame)
        profile:Dock(FILL)
        profile:DockMargin(0, 6, 6, 6)
        profile:InvalidateParent(true)
        profile.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
        end

        local scroll = vgui.Create('XPScrollPanel', profile)
        scroll:Dock(FILL)
        scroll:DockMargin(0,2,0,0)
        scroll:InvalidateParent(true)
        local sw, sh = scroll:GetSize()

        local x, y = 0, 0
        for k,v in pairs(rp.cfg.f4actions) do
            if (v.acs && v.acs(LocalPlayer())==false) then continue end
            local a = vgui.Create('XPButton', scroll)
            a:SetSize(sw/5-4, sh/3-4)
            a:SetPos(x, y)
            a:SetText''
            a.PaintOver = function(self,w,h)
                draw.RoundedBox(6, 0, h-40, w, 40, XPGUI.ButtonColor)
    
                draw.SimpleText('Действие', 'xpgui_tiny', w/2, h-23, color_white, 1, TEXT_ALIGN_BOTTOM)
                draw.SimpleText(v.name or '', 'xpgui_small', w/2, h-4, color_white, 1, TEXT_ALIGN_BOTTOM)
    
                surface.SetMaterial( surface.GetWeb(v.icon or 'https://img.icons8.com/ios-glyphs/256/FFFFFF/money--v1.png') )
                surface.SetDrawColor(255, 255, 255, 25)
                local scale = 2
                surface.DrawTexturedRect((w-w/scale)/2, (h-40-h/scale)/2, w/scale, h/scale)
            end
            a.DoClick = function()
                v.doclick( frame )
            end

            x = x + sw/5
            if x >= sw then
                x = 0
                y = y + sh/3
            end
        end
    end

    local craft
    function craft()
        local Count = table.Count
        profile = vgui.Create('DPanel', frame)
        profile:Dock(FILL)
        profile:DockMargin(0, 6, 6, 6)
        profile:InvalidateParent(true)
        profile.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
        end

        local scroll = vgui.Create('XPScrollPanel', profile)
        scroll:Dock(LEFT)
        scroll:DockMargin(7,7,0,7)
        scroll:SetWide(profile:GetWide()*.25)
        scroll.Paint = function(self,w,h)
            draw.RoundedBox(6,0,0,w,h,Color(0,0,0,150))
        end
        scroll:GetVBar():SetWide(0)
        
        local model, CHOOSE
        for k,v in pairs(rp.Crafts) do
            local element = vgui.Create('XPButton', scroll)
            element:Dock(TOP)
            element:DockMargin(2,2,2,2)
            element.Paint = function(self,w,h)
                draw.RoundedBox(6,0,0,w,h,Color(0,0,0,125))
                draw.RoundedBox(6,0,0,h,h,Color(0,0,0,180))
    
                draw.SimpleText(v:GetName(), 'xpgui_smaller', h+7,h/2, Color(255,255,255), 0, 1)
            end
            element.DoClick = function()
                CHOOSE = v
                model:SetModel(v:GetModel())
            end
            local eW, eH = element:GetSize()
    
            local _model = vgui.Create('ModelImage', element)
            _model:SetSize(eH-4, eH-4)
            _model:SetPos(1,1)
            _model:SetModel(v:GetModel())
            _model:SetMouseInputEnabled(false)
        end

        CHOOSE = rp.Crafts[1]
        local Inventory = {}

        for k,v in pairs(LocalPlayer().inventory) do
            local class = v.save_data.subname
            if class then
                Inventory[class] = (Inventory[class] or 0) + 1
            end
        end
    
        local info_panel = vgui.Create('DPanel', profile)
        info_panel:Dock(FILL)
        info_panel:DockMargin(7,7,7,7)
        info_panel:DockPadding(7, 60, 7, 7)
        info_panel.Paint = function(self,w,h)
            draw.RoundedBox(6,0,0,w,h,Color(0,0,0,150))
    
            draw.RoundedBox(6,7,7,46,46,Color(0,0,0,150))
            local xText = 7+46+7
            draw.SimpleText(CHOOSE:GetName(), 'xpgui_small', xText, 7, Color(255,255,255))
            draw.SimpleText(CHOOSE:GetDescription(), 'xpgui_tiny', xText, 24, Color(255,255,255))
            --draw.SimpleText('Вы можете скрафтить', 'xpgui_tiny2', xText, 36, Color(0,200,0))
        end
        
        model = vgui.Create('ModelImage', info_panel)
        model:SetSize(34,34)
        model:SetPos(7+(46/2)-(model:GetWide()/2),7+(46/2)-(model:GetTall()/2))
        model:SetModel(CHOOSE:GetModel())

        local recept = vgui.Create('DPanel', info_panel)
        recept:Dock(FILL)
        recept.Paint = function(self,w,h)
            draw.RoundedBox(6,0,0,w,h,Color(0,0,0,150))
            
            local y, needs = 0, CHOOSE:GetNeeds()
            for k,v in pairs(needs) do 
                draw.RoundedBox(6,0,y,w,23,Color( (Inventory[k] and Inventory[k] >= v) and 0 or 255,0,0,100))
                draw.SimpleText(rp.inventory.Languge[k] or k, 'xpgui_tiny', 6, y+23/2, Color(255,255,255), 0, 1)
        
                draw.SimpleText(v..' шт.', 'xpgui_tiny', w-6, y+23/2, Color(255,255,255), TEXT_ALIGN_RIGHT, 1)

                y=y+25
            end

            if Count(needs) <= 0 then
                draw.SimpleText('Ничего не требуется', 'xpgui_tiny', w/2, h/2, Color(255,255,255), 1, 1)
            end
        end
    
        local craft = vgui.Create('XPButton', info_panel)
        craft:Dock(BOTTOM)
        craft:SetText'Создать'
        craft:SetFont('xpgui_small')
        craft:DockMargin(0,7,0,0)
        craft.DoClick = function()
            net.Start('Craft::Create')
            net.WriteUInt(CHOOSE.ID, 8)
            net.SendToServer()
        end
    end
    local tabs = {
        --
        {
            n = 'Инвентарь',
            fun = function()
                cleartabs()
                mainprofile()
            end
        },

        {
            n = 'Действия',
            fun = function()
                cleartabs()
                actions()
            end
        },
        {
            n = 'Работы',
            fun = function()
                cleartabs()
                jobsmain()
            end
        },    
        {
            n = 'Магазин',
            fun = function()
                cleartabs()
                mainshop()
            end
        },
        -- {
        --     n = 'Крафт',
        --     fun = function()
        --         cleartabs()
        --         craft()
        --     end
        -- },
        {
            n = 'Донат',
            fun = function()
                cleartabs()
                donateshop()
            end
        },
        --{
        -- n = 'Боевой пропуск',
        -- fun = function()
        --     cleartabs()
        --     battlepass_menu()
        --   end
        --},
        --{
        --    n = 'Скиллы',
        --    fun = function()
        --      cleartabs()
        --      skillsmenu()
        --    end
        --},
        {
            n = 'Промокоды',
            fun = function(a)
                cleartabs()
                if (a~='bruh')then 
                    RunConsoleCommand("say", "/promomenu")
                    frame:Remove()
                end
            end
        },       
        {
             n = 'Реферал',
             fun = function()
                 cleartabs()
                 referalsmenu()
             end
        },
        {
            n = 'Настройки',
            fun = function()
                cleartabs()
                settings()
            end
        }
    }

    for k,v in pairs(tabs) do
        local button = vgui.Create("XPButton", left_panel)
        button:Dock(TOP)
        button:SetText(v.n)
        button:SetToolTip("")
        button.DoClick = function()
            v.fun()
            LastPage = LastPage or "Инвентарь"
            LastPage = v.n
        end
    end

    if LastPage == nil then
        cleartabs()
        mainprofile()
    else
        for k, v in pairs(tabs) do
            if v.n == LastPage then cleartabs() v.fun('bruh') end
        end
    end

end
GM.ShowSpare2 = rp.ToggleF4Menu

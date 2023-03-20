 local pairs = pairs
 local ipairs = ipairs
 local IsValid = IsValid
 local ents_FindByClass = ents.FindByClass
 local ScrW = ScrW
 local ScrH = ScrH
 local string_Replace = string.Replace
 local string_ToTable = string.ToTable
 local draw_RoundedBox = draw.RoundedBox
 local draw_SimpleText = draw.SimpleText
 local math_Round = math.Round
 local math_floor = math.floor
 local math_sin = math.sin
 local CurTime = CurTime
 local LocalPlayer = LocalPlayer
 local cam_Start3D2D = cam.Start3D2D
 local cam_End3D2D = cam.End3D2D
local surface_SetDrawColor = surface.SetDrawColor
 local surface_DrawRect = surface.DrawRect
local surface_SetMaterial = surface.SetMaterial
 local surface_DrawTexturedRect = surface.DrawTexturedRect
 local surface_SetFont = surface.SetFont
 local surface_SetTextColr = surface.SetTextColor
 local surface_SetTextPos = surface.SetTextPos
 local surface_DrawText = surface.DrawText

concommand.Add( "thispos", function( ply )
  local trace = ply:GetEyeTrace() local this = trace.Entity
  print('Vector('..math.Round(this:GetPos().x)..', '..math.Round(this:GetPos().y)..', '..math.Round(this:GetPos().z)..')')
  print('Angle('..math.Round(this:GetAngles().x)..', '..math.Round(this:GetAngles().y)..', '..math.Round(this:GetAngles().z)..')')
  SetClipboardText('Vector('..math.Round(this:GetPos().x)..', '..math.Round(this:GetPos().y)..', '..math.Round(this:GetPos().z)..')')
end)

RunConsoleCommand('cl_cmdrate', '24')
RunConsoleCommand('cl_updaterate', '24')

  local blur = Material("pp/blurscreen")
 function drawShadowText(text, font, x, y, color, x_a, y_a, color_shadow)
   color_shadow = color_shadow or Color(0, 0, 0)
   draw.SimpleText(text, font, x + 1, y + 1, color_shadow, x_a, y_a)
   local w, h = draw.SimpleText(text, font, x, y, color, x_a, y_a)

   return w, h
 end

 function FindPlayer(info)
     if not info or (info == '') then return end
     info = tostring(info)

     for _, pl in ipairs(player.GetAll()) do
         if (info == pl:SteamID()) then
             return pl
         elseif (info == pl:SteamID64()) then
             return pl
         elseif string.find(string.lower(pl:Name()), string.lower(info), 1, true) ~= nil then
             return pl
         end
     end
 end

 function FindNearestEntity( className, pos, range )
     local nearestEnt;
     range = range ^ 2
     for _, ent in pairs( ents_FindByClass( className ) ) do
         local distance = (pos - ent:GetPos()):LengthSqr()
         if( distance <= range ) then
             nearestEnt = entity
             range = distance
         end
     end

     return nearestEnt;
 end




 function DrawOutlinePanel(w, h, t, col)
     surface_SetDrawColor(col.r, col.g, col.b, col.a)

     surface_DrawRect(0, h - t, w, t)
     surface_DrawRect(0, h - h, w, t)
     surface_DrawRect(w - t, 0, t, h)
     surface_DrawRect(w - w, 0, t, h)
 end

 function DrawOutlineFD(w, h, t, col)
     surface_SetDrawColor(col.r, col.g, col.b, col.a)

     surface_DrawRect(0, h - t, w, t)
     surface_DrawRect(0, h - h, w, t)
     surface_DrawRect(w - t, 0, t, h)
     surface_DrawRect(w - w, 0, t, h)
 end


 function DrawOutline(x, y, w, h, t, col)
     col = col or Color(0,0,0)
     surface_SetDrawColor(col.r, col.g, col.b, col.a)

     surface_DrawRect(x, y + h - t, w, t)
     surface_DrawRect(x, y + h - h, w, t)
     surface_DrawRect(x + w - t, y, t, h)
     surface_DrawRect(x + w - w, y, t, h)
 end

function DrawBlur(panel, amount)
    local x, y = panel:LocalToScreen(0, 0)
    local scrW, scrH = ScrW(), ScrH()

    surface_SetDrawColor(255, 255, 255)
    surface_SetMaterial(blur)
    for i = 1, 3 do
        blur:SetFloat("$blur", (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface_DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    end
end

 function DrawBlurFDSG(panel, amount)
     DrawBlur(panel, amount)
 end
--
 function DrawBlurFD(panel, amount)
     if cvar.GetValue('enable_blur') then
         local x, y = panel:LocalToScreen(0, 0)
         local scrW, scrH = ScrW(), ScrH()


         surface_SetDrawColor(255, 255, 255)
         surface_SetMaterial(blur)
         for i = 1, 3 do
             blur:SetFloat("$blur", (i / 3) * (amount or 6))
             blur:Recompute()
             render.UpdateScreenEffectTexture()
             surface_DrawTexturedRect(x * -1, y * -1, scrW, scrH)
         end
     end

     surface_SetDrawColor(0,0,0,150)
     surface_DrawRect(0,0,panel:GetWide(),panel:GetTall())
 end

 function DrawBlurFD(panel, amount)
     DrawBlurFD(panel, amount)
 end

 function DrawBText(text, font, shadow_font, x, y, color, x_a, y_a, color_shadow)
     color_shadow = color_shadow or Color(0, 0, 0)
     draw_SimpleText(text, shadow_font, x + 1, y + 1, color_shadow, x_a, y_a)
     local w,h = draw_SimpleText(text, font, x, y, color, x_a, y_a)
     return w,h
 end

 function DrawBox(x,y,w,h,col,col_o)
     col_o = col_o or Color(0,0,0,100)
     col = col or Color(0,0,0,200)

     surface.SetDrawColor(col.r, col.g, col.b, col.a)
     surface.DrawRect(x,y,w,h)

     DrawOutline(x, y, w, h, 1, col_o)
 end

 function DrawBlurRect(x, y, w, h, col, col_o)
     col = col or Color(0,0,0,100)
     col_o = col_o or Color(0,0,0,100)

     if cvar.GetValue('enable_blur') then
         local X, Y = 0,0

         surface_SetDrawColor(255,255,255, col.a)
         surface_SetMaterial(blur)

         for i = 1, 3 do
             blur:SetFloat("$blur", (i / 3) * (5))
             blur:Recompute()

             render.UpdateScreenEffectTexture()

             render.SetScissorRect(x, y, x+w, y+h, true)
                 surface_DrawTexturedRect(X * -1, Y * -1, ScrW(), ScrH())
             render.SetScissorRect(0, 0, 0, 0, false)
         end
     end

     DrawBox(x,y,w,h,col, col_o)
 end

hook.Add( "RenderScreenspaceEffects", "MetaHub.Beer", function()

    if LocalPlayer():GetNWBool('Beer') then

        DrawMotionBlur(0.03, 1, 0);

    end

end )


-----------------------------------------------------
do
    local q = {{},{},{},{}}
    local q1, q2, q3, q4 = q[1], q[2], q[3], q[4]
    local drawpoly = surface.DrawPoly
    function surface.DrawQuad( x1, y1, x2, y2, x3, y3, x4, y4 )
        q1.x, q1.y = x1, y1
        q2.x, q2.y = x2, y2
        q3.x, q3.y = x3, y3
        q4.x, q4.y = x4, y4
        drawpoly(q)
    end

    local quv = {{},{},{},{}}
    local quv1, quv2, quv3, quv4 = quv[1], quv[2], quv[3], quv[4]
    local math_min, math_max = math.min, math.max
    function surface.DrawQuadUV( x1, y1, x2, y2, x3, y3, x4, y4 )
        local xmin, ymin = math_max, math_max
        local xmax, ymax = math_min, math_min

        xmin = x1
        if x2 < xmin then xmin = x2 end
        if x3 < xmin then xmin = x3 end
        if x4 < xmin then xmin = x4 end

        ymin = y1
        if y2 < ymin then ymin = y2 end
        if y3 < ymin then ymin = y3 end
        if y4 < ymin then ymin = y4 end

        xmax = x1
        if x2 > xmax then xmax = x2 end
        if x3 > xmax then xmax = x3 end
        if x4 > xmax then xmax = x4 end
        
        ymax = y1
        if y2 > ymax then ymax = y2 end
        if y3 > ymax then ymax = y3 end
        if y4 > ymax then ymax = y4 end

        local dy = ymax - ymin
        local dx = xmax - xmin

        quv1.u, quv1.v = (x1-xmin)/dx, (y1-ymin)/dy
        quv2.u, quv2.v = (x2-xmin)/dx, (y2-ymin)/dy
        quv3.u, quv3.v = (x3-xmin)/dx, (y3-ymin)/dy
        quv4.u, quv4.v = (x4-xmin)/dx, (y4-ymin)/dy

        quv1.x, quv1.y = x1, y1
        quv2.x, quv2.y = x2, y2
        quv3.x, quv3.y = x3, y3
        quv4.x, quv4.y = x4, y4

        drawpoly(quv)
    end

    local drawline = surface.DrawLine
    function surface.DrawOutlinedQuad(x1, y1, x2, y2, x3, y3, x4, y4)
        drawline(x1,y1, x2,y2)
        drawline(x2,y2, x3,y3)
        drawline(x3,y3, x4,y4)
        drawline(x4,y4, x1,y1)
    end
end

do
    local cos, sin = math.cos, math.sin 
    local ang2rad = 3.141592653589/180
    local drawquad = surface.DrawQuad 
    function surface.DrawArc( _x, _y, r1, r2, aStart, aFinish, steps )
        aStart, aFinish = aStart*ang2rad, aFinish*ang2rad 
        local step = (( aFinish - aStart ) / steps)
        local c = steps
        
        local a, c1, s1, c2, s2 
        
        c2, s2 = cos(aStart), sin(aStart)
        for _a = 0, steps - 1 do
            a = _a*step + aStart
            c1, s1 = c2, s2
            c2, s2 = cos(a+step), sin(a+step)
            
            drawquad( _x+c1*r1, _y+s1*r1, 
                         _x+c1*r2, _y+s1*r2, 
                         _x+c2*r2, _y+s2*r2,
                         _x+c2*r1, _y+s2*r1 )
            c = c - 1
            if c < 0 then break end
        end
    end
end

-- Begin the moonshit
-- DRAW QUAD
do
    local cos, sin = math.cos, math.sin 
    local ang2rad = 3.141592653589/180
    local drawline = surface.DrawLine 
    function surface.DrawArcOutline( _x, _y, r1, r2, aStart, aFinish, steps )
        aStart, aFinish = aStart*ang2rad, aFinish*ang2rad 
        local step = (( aFinish - aStart ) / steps)
        local c = steps
        
        local a, c1, s1, c2, s2 
        
        c2, s2 = cos(aStart), sin(aStart)
        drawline( _x+c2*r1, _y+s2*r1, _x+c2*r2, _y+s2*r2 )
        for _a = 0, steps - 1 do
            a = _a*step + aStart
            c1, s1 = c2, s2
            c2, s2 = cos(a+step), sin(a+step)
            
            
            drawline( _x+c1*r2, _y+s1*r2, 
                                                _x+c2*r2, _y+s2*r2 )
            drawline( _x+c1*r1, _y+s1*r1,
                                                _x+c2*r1, _y+s2*r1 )
            c = c - 1
            if c < 0 then break end
        end
        drawline( _x+c2*r1, _y+s2*r1, _x+c2*r2, _y+s2*r2 )
    end
end

do
    local SetFont       = surface.SetFont
    local GetTextSize   = surface.GetTextSize

    local font = 'TargetID'
    local cache = setmetatable({}, {
        __mode = 'k'
    })

    timer.Create('surface.ClearFontCache', 1800, 0, function()
        for i = 1, #cache do
            cache[i] = nil
        end
    end)

    function surface.SetFont(_font)
        font = _font
        return SetFont(_font)
    end

    function surface.GetTextSize(text)
        if (not cache[font]) then
            cache[font] = {}
        end
        if (not cache[font][text]) then
            local w, h = GetTextSize(text)
            cache[font][text] = {
                w = w,
                h = h
            }
            return w, h
        end
        return cache[font][text].w, cache[font][text].h
    end
end

local col_face = Color(255, 255, 255, 255)
local col_shadow = Color(0, 0, 0, 145)
local col_half_shadow = Color(0, 0, 0, 110)

local shadow_x = 1
local shadow_y = 0

function surface.DrawShadowIcon(color, material, xalign, yalign, x, y)
    surface.SetDrawColor(col_shadow)
    surface.SetMaterial(material)
    surface.DrawTexturedRect(xalign, yalign, x, y + 3)

    surface.SetDrawColor(col_half_shadow)
    surface.SetMaterial(material)
    surface.DrawTexturedRect(xalign, yalign, x + shadow_x , y + shadow_y)

    surface.SetDrawColor(color or col_face)
    surface.SetMaterial(material)
    surface.DrawTexturedRect(xalign, yalign, x, y)            
end

function surface.DrawIcon(material, xalign, yalign, x, y, color)
    surface.SetDrawColor(color or col_face)
    surface.SetMaterial(material)
    surface.DrawTexturedRect(xalign, yalign, x, y)  
end
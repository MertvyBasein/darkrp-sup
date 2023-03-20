local parsed_text = {}

hook.Add('HUDPaint','MetaHub.TraceInfo',function()

    local ent = LocalPlayer():GetEyeTrace().Entity
    if IsValid(ent) then
        if ent:GetClass() == 'prop_ragdoll' then
            ent.TraceInfo = "<font=" .. GetFont(10) .. "><color=255,126,126>Бездыханное тело</color></font>"
        end
        if (ent.TraceInfo ~= nil) and (LocalPlayer():GetPos():DistToSqr(ent:GetPos()) < 40000) then
            if not parsed_text[ent:GetClass()] then parsed_text[ent:GetClass()] = {parsed = markup.Parse(ent.TraceInfo), nonparsed = ent.TraceInfo} end
            if parsed_text[ent:GetClass()].nonparsed ~= ent.TraceInfo then parsed_text[ent:GetClass()] = {parsed = markup.Parse( ent.TraceInfo), nonparsed = ent.TraceInfo} end

            local e_pos = (ent:GetPos() + Vector(0,0,ent:OBBMaxs().z))

            local t_w, t_h = parsed_text[ent:GetClass()].parsed:Size()
            t_h = t_h + 2

            if ent.TraceInfo_OffSet ~= nil then e_pos = e_pos + ent.TraceInfo_OffSet end

            e_pos = e_pos:ToScreen()

            DrawBlurRect(e_pos.x - t_w*.5 - 4, e_pos.y - t_h, t_w + 8, t_h, Color(0,0,0,200))
            parsed_text[ent:GetClass()].parsed:Draw( e_pos.x - t_w*.5, e_pos.y - t_h, 0, 0 )
        end
    end

end)

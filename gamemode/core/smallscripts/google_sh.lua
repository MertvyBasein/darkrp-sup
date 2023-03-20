if SERVER then
    util.AddNetworkString("SayTTS")

    hook.Add("PlayerSay", "TTSFTW", function(ply, text, team)
    if ply.sBanned then return end
    if ply:sam_get_pdata("unmute_time") then return false end
        if not team then
             if (ply:HasPurchase("govorilka") or ply:HasPurchase("govorilka_navsegda")) and string.sub(text, 1, 1) ~= "/" and string.sub(text, 1, 1) ~= "!" and string.sub(text, 1, 1) ~= "@" and string.sub(text, 1, 1) ~= "//" and string.sub(text, 1, 1) ~= "///" and string.sub(text, 1, 1) ~= "/pm" and ply:Alive() then
                net.Start("SayTTS")
                net.WriteString(text)
                net.WriteEntity(ply)
                net.Broadcast()
            end
        end
    end)
else
    local char_to_hex = function(c) return string.format("%%%02X", string.byte(c)) end

    local function urlencode(url)
        if url == nil then return end
        url = url:gsub("\n", "\r\n")
        url = url:gsub("([^%w ])", char_to_hex)
        url = url:gsub(" ", "+")

        return url
    end

    net.Receive("SayTTS", function()
        local text = net.ReadString()
        local ply = net.ReadEntity()
        if not IsValid(ply) then return end
        if LocalPlayer():GetPos():Distance(ply:GetPos()) > 1000 then return end

        sound.PlayURL("https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=" .. urlencode(text) .. "&tl=ru", "3d", function(snd)
            if IsValid(snd) and IsValid(ply) then
                snd:SetPos(ply:GetPos())
                snd:SetVolume(1)
                snd:Play()
                snd:Set3DFadeDistance(200, 1000)
                ply.sound = snd
            end
        end)
    end)

    hook.Add("Think", "FollowPlayerSound", function()
        for k, v in pairs(player.GetAll()) do
            if IsValid(v.sound) then
                v.sound:SetPos(v:GetPos())
            end
        end
    end)
end



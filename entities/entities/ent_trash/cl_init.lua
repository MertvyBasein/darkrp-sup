include('shared.lua')

function ENT:Draw()
    self:DrawModel()
    self:DestroyShadow() // Мы пытались...
end

net.Receive("OpenTrashDerma", function()
    local eTrash = net.ReadEntity()
    local pPlayer = LocalPlayer()
    if IsValid(MainTrash) then return end
    MainTrash = vgui.Create("DFrame")
    MainTrash:SetSize(350, 50)
    MainTrash:Center()
    MainTrash:SetTitle("")
    MainTrash:ShowCloseButton(false)
    MainTrash:SetDraggable(false)
    MainTrash.NextSound = CurTime()
		MainTrash.StartClean = CurTime()
		MainTrash.EndClean = MainTrash.StartClean + 3
		MainTrash.Dots = MainTrash.Dots or ""
		timer.Create("LockPickDots", 0.5, 0, function()
        if not MainTrash:IsValid() then
            timer.Destroy("LockPickDots")
						return
        end

        local len = string.len(MainTrash.Dots)
        local dots = {[0] = ".", [1] = "..", [2] = "...", [3] = ""}

        MainTrash.Dots = dots[len]
    end)
    MainTrash.Paint = function(self, w, h)
        framework(self, 5)
        local time = MainTrash.EndClean - MainTrash.StartClean or 0
        local status = (CurTime() - MainTrash.StartClean) / time
        MainTrash.Dots = MainTrash.Dots or ""
        rp.ui.DrawProgressBar(0, 0, w, h, status, Color(0, 0, 0, 175), Color(0, 0, 0, 150), Color(0, 0, 0, 100))
        draw.SimpleTextOutlined("Убираем" .. MainTrash.Dots, GetFont(12), w / 2, h / 2, ui.col.White, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, ui.col.Black)
    end

    MainTrash.Think = function(self)
        local curtime = CurTime()
				if not IsValid(eTrash) and IsValid(MainTrash) then MainTrash:Remove() end
        if IsValid(eTrash) and self.NextSound < curtime then
            eTrash:EmitSound("npc/metropolice/gear" .. math.random(1, 6) .. ".wav")
            self.NextSound = CurTime() + 1
        end

        if IsValid(eTrash) and MainTrash.EndClean < curtime then
            if IsValid(MainTrash) then
                MainTrash:Remove()
            end

            net.Start("RemoveTrash")
            net.WriteEntity(eTrash)
            net.SendToServer()
        end

        if IsValid(eTrash) and pPlayer:GetEyeTrace().Entity ~= eTrash then
            if IsValid(MainTrash) then
                MainTrash:Remove()
            end

            -- net.Start("DropTimerTrash")
            -- net.WriteEntity(eTrash)
            -- net.SendToServer()
        end

    end
end)

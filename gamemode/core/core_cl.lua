timer.Simple(0.5, function()
	//RunConsoleCommand('stopsound')
	local GM = GAMEMODE
end)

-- Вайс чат
local Talkers = {}
hook('PlayerStartVoice', 'rp.hud.PlayerStartVoice', function(pl)
	Talkers[pl] = true
end)

hook('PlayerEndVoice', 'rp.hud.PlayerEndVoice', function(pl)
	Talkers[pl] = nil
end)

hook.Add( "HUDDrawTargetID", "HidePlayerInfo", function()
    return false
end )

local GUIToggled = false
local mouseX, mouseY = ScrW() / 2, ScrH() / 2

function GM:ShowSpare1()
    GUIToggled = not GUIToggled

    if GUIToggled then
        gui.SetMousePos(mouseX, mouseY)
    else
        mouseX, mouseY = gui.MousePos()
    end
    gui.EnableScreenClicker(GUIToggled)
end

local FKeyBinds = {
	["gm_showhelp"] = "ShowHelp",
	["gm_showteam"] = "ShowTeam",
	["gm_showspare1"] = "ShowSpare1",
	["gm_showspare2"] = "ShowSpare2"
}

function GM:PlayerBindPress(ply, bind, pressed)
    local bnd = string.match(string.lower(bind), "gm_[a-z]+[12]?")

    if bnd and FKeyBinds[bnd] and GAMEMODE[FKeyBinds[bnd]] then
        GAMEMODE[FKeyBinds[bnd]](GAMEMODE)
    end

    return
end

cvar.Register 'other_viewbob'
    :SetDefault(false, false)
    :AddMetadata('Catagory', 'Другое')
    :AddMetadata('Menu', 'Отключить покачивание камеры')

local cvar_Get = cvar.GetValue

function GM:CalcView(pPlayer, origin, angles, fov) -- Thx, Clockwork!

	if cvar_Get('other_viewbob') then
		local view = self.BaseClass:CalcView(pPlayer, origin, angles, fov)
		return view
	end

    if (pPlayer:GetMoveType() == 2) then
        if IsValid(pPlayer:GetActiveWeapon()) and not table.HasValue({'swb', 'tfa'}, string.sub(pPlayer:GetActiveWeapon():GetClass(), 1, 3)) then
            local frameTime = FrameTime()
            local approachTime = frameTime * 2
            local curTime = UnPredictedCurTime()

            local info = { speed = 1, yaw = 0.5, roll = 0.5 }

            if (not self.HeadbobAngle) then self.HeadbobAngle = 0 end
            if (not self.HeadbobInfo) then self.HeadbobInfo = info end

            self.HeadbobInfo.yaw = math.Approach(self.HeadbobInfo.yaw, info.yaw, approachTime)
            self.HeadbobInfo.roll = math.Approach(self.HeadbobInfo.roll, info.roll, approachTime)
            self.HeadbobInfo.speed = math.Approach(self.HeadbobInfo.speed, info.speed, approachTime)
            self.HeadbobAngle = self.HeadbobAngle + (self.HeadbobInfo.speed * frameTime)

            local yawAngle = math.sin(self.HeadbobAngle)
            local rollAngle = math.cos(self.HeadbobAngle)

            angles.y = angles.y + (yawAngle * self.HeadbobInfo.yaw)
            angles.r = angles.r + (rollAngle * self.HeadbobInfo.roll)

            local velocity = pPlayer:GetVelocity()
            local eyeAngles = pPlayer:EyeAngles()

            if (not self.VelSmooth) then self.VelSmooth = 0 end
            if (not self.WalkTimer) then self.WalkTimer = 0 end
            if (not self.LastStrafeRoll) then self.LastStrafeRoll = 0 end

            self.VelSmooth = math.Clamp(self.VelSmooth * 0.9 + velocity:Length() * 0.1, 0, 700)
            self.WalkTimer = self.WalkTimer + self.VelSmooth * FrameTime() * 0.05
            self.LastStrafeRoll = (self.LastStrafeRoll * 3) + (eyeAngles:Right():DotProduct(velocity) * 0.0001 * self.VelSmooth * 0.3)
            self.LastStrafeRoll = self.LastStrafeRoll * 0.25
            angles.r = angles.r + self.LastStrafeRoll

            if (pPlayer:GetGroundEntity() ~= NULL) then
                angles.p = angles.p + math.cos(self.WalkTimer * 0.5) * self.VelSmooth * 0.000002 * self.VelSmooth
                angles.r = angles.r + math.sin(self.WalkTimer) * self.VelSmooth * 0.000002 * self.VelSmooth
                angles.y = angles.y + math.cos(self.WalkTimer) * self.VelSmooth * 0.000002 * self.VelSmooth
            end

            velocity = LocalPlayer():GetVelocity().z

            if (velocity <= -1000 and LocalPlayer():GetMoveType() == MOVETYPE_WALK) then
                angles.p = angles.p + math.sin(UnPredictedCurTime()) * math.abs((velocity + 1000) - 16)
            end
        end
    end

    local view = self.BaseClass:CalcView(pPlayer, origin, angles, fov)

    return view
end
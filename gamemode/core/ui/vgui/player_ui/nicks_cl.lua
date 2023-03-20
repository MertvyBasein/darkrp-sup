local cam_Start3D2D   	= cam.Start3D2D
local cam_End3D2D     	= cam.End3D2D
local CurTime 			= CurTime
local IsValid 			= IsValid
local ipairs 			= ipairs
local Color 			= Color
local nw_GetGlobal 		= nw.GetGlobal
local cvar_Get 			= cvar.GetValue
local math_max			= math.max
local math_atan			= math.atan
local math_rad			= math.rad
local math_random		= math.random
local math_floor 		= math.floor

local star 				= Material( "sprites/glow04_noz" )
local Page 				= Material("materials/metahub/c_contract.png", "smooth 1")
local Voice 			= Material("materials/metahub/microphone.png", "smooth 1")
local Crown 			= Material("materials/metahub/crown.png", "smooth 1")
local Event             = Material("materials/metahub/c_technics.png", "smooth 1")
local Flame2 			= Material("materials/metahub/server_logo5.png", "smooth 1")
local Alarm				= Material("materials/metahub/alarm.png", "smooth 1")
local Handcuffs			= Material("materials/metahub/handcuffs.png", "smooth 1")
local Helper            = Material("materials/metahub/helper.png", 'smooth 1')
local King            	= Material("materials/metahub/king.png", 'smooth 1')
local Cat               = Material("materials/metahub/cat.png", 'smooth 1')

cvar.Register("disable_complicated_playertags"):SetDefault(false):AddMetadata("Menu", "Отключить сложный код отображения ника игрока (увеличивает FPS)")
cvar.Register("localplayer_playertag"):SetDefault(false):AddMetadata("Menu", "Отображать свой ник в виде от 3-го лица")

local vec13 = Vector(0, 0, 13)
local vec10 = Vector(0, 0, 10)

local roofcache = {
	["models/tdmcars/bus.mdl"] = Vector()
}
local function getroof(car)
	if car:GetParent():IsValid() and car:GetParent():IsVehicle() then
		car = car:GetParent()
	end

	local mdl = car:GetModel()
	if not roofcache[mdl] then
		roofcache[mdl] = car:WorldToLocal(util.TraceLine{start = car:LocalToWorld(Vector(0, 0, car:OBBMaxs().z)), endpos = car:LocalToWorld(Vector(0, 0, car:OBBMins().z)), filter = function(ent) return ent == car end}.HitPos)
	end
	return car:LocalToWorld(roofcache[mdl]).z
end

local to_draw = {}
local fn = 0
local ffov = 0
local fadedist = 512

local oy = 0
local function AddText(str, font, col)
	surface.SetFont(font)

	local w, h = surface.GetTextSize(str)
	oy = oy - h

	surface.SetFont(font)
	surface.SetTextPos(-w*0.5, oy)
	surface.SetTextColor(Color(0,0,0))
	surface.DrawText(str)

	surface.SetFont(font)

	surface.SetTextPos(-w*0.5, oy)
	surface.SetTextColor(col)
	surface.DrawText(str)

	return w, oy
end

http.Fetch( "https://media.discordapp.net/attachments/909155458797936660/1001509914155438131/admin-with-cogwheels_2.png", function( body) file.Write('adminmode.png', body) end)

http.Fetch( "https://media.discordapp.net/attachments/909155458797936660/1001509929531748352/handcuffs_2.png", function( body) file.Write('arrested.png', body) end)

http.Fetch( "https://media.discordapp.net/attachments/909155458797936660/1001514745460965477/gun.png", function( body) file.Write('gun.png', body) end)

http.Fetch( "https://media.discordapp.net/attachments/909155458797936660/1001514837794357269/star.png", function( body) file.Write('star.png', body) end)

http.Fetch( "https://media.discordapp.net/attachments/909155458797936660/1001515272353619998/microphone_2.png", function( body) file.Write('micro.png', body) end)


local function AddIcon(w, h, ico, col)
	oy = oy - h - 10

	surface.SetDrawColor(col)
	surface.SetMaterial(ico)
	surface.DrawTexturedRect(-w*.5, oy, w, h)
end

local next_z = 0
hook.Add("RenderScene", "NameTags", function(pos, ang, fov)
	fn = FrameNumber()
	ffov = fov
end)
local math_sin 				= math.sin
hook.Add("PostDrawTranslucentRenderables", "3D2DNicks", function(depth, sky)
	if depth or sky then return end
	local isadmin = LocalPlayer():Team() == TEAM_NONRP
	local ang = Angle(0, EyeAngles().y - 90, 90)
	local eyepos = EyePos()
	local incam = LocalPlayer():GetActiveWeapon()
	incam = incam:IsValid() and incam:GetClass() == "gmod_camera"

	local counter = 0
	local cfn = fn-1
	for ply, fn in pairs(to_draw) do
		if not ply:IsValid() then
			to_draw[ply] = nil
			continue
		end

		if not ply:Alive() then continue end

		if cfn ~= fn and (cfn+1)~=fn then continue end

		local eye = ply:EyePos()
		if not cvar_Get("disable_complicated_playertags") then
			local boneId = ply:LookupBone("ValveBiped.Bip01_Head1")
			if boneId then
				eye = (ply:GetBonePosition(boneId))
			else
				eye = ply:EyePos()
			end
		end

		if ply.InVehicle and ply:InVehicle() then
			eye.z = math_max(eye.z + 9, getroof(ply:GetVehicle()) + 5)
		else
			eye.z = eye.z + 11
		end

		if cfn == fn and eyepos:Distance(eye) > fadedist / math_atan(math_rad(incam and 90 or ffov)) then continue end

		counter = counter + 1
		oy = 0

		-- local org = ply:GetGang()
		-- local org_c = ply:GetGangColor()
		local job_name = team.GetName(ply:Team())
		cam_Start3D2D(eye, ang, 0.04)
			if ply:GetMoveType() != MOVETYPE_NOCLIP and not ply:GetNWBool('hidden') then
				
				-- if org then
				-- 	AddText(org, "MetaHub.Font90", org_c)
				-- end
				if ply:GetNetVar('AdminMode') or ply:GetNetVar('EventMode') or ply:GetNWBool('HiddenName') then
					--
				else
					AddText(ply:GetJobName(), "MetaHub.Font80", ply:GetJobColor())
				end


				local w,y = AddText(ply:Nick(), "MetaHub.Font100", ply:GetNWBool('banned') and Color(231, 76, 60) or Color(255,255,255))

				-- if ply:GetNetVar('AdminMode') then
				-- 	surface.SetMaterial(Flame)
				-- 	surface.SetDrawColor(Color(255, 255, 255, 255))
				-- 	surface.DrawTexturedRect(w - 720, y - 175, 115, 100)
				-- end

				 if ply:IsWanted() then
				 	//local cin = (math_sin(CurTime() * 6) + 1) * .5
				 	AddIcon(100, 100, Material("data/star.png"), HSVToColor( CurTime() % 6 * 60, 1, 1 ))
				 	//AddText("В Розыске!", "MetaHub.Font65", HSVToColor( CurTime() % 6 * 60, 1, 1 ))
				 end

				 if ply:HasLicense() then
				 	--AddIcon(70, 70, Page, Color(255, 255, 255))
				 	AddIcon(100, 100, Material("data/gun.png"), HSVToColor( CurTime() % 6 * 60, 1, 1 ))
				 end

				if ply:IsTyping() then
					AddText("Пишет...", "MetaHub.Font70", HSVToColor( CurTime() % 6 * 60, 1, 1 ))
				end
	
				if ply:IsSpeaking() then
					AddIcon(100, 100, Material("data/micro.png"), HSVToColor(CurTime() % 6 * 60, 1, 1))
				end

				if ply:GetNetVar("rp.ReportClaimed") then
					AddText("Разбирает жалобу!", "MetaHub.Font65", Color(255, 0, 0))
				end 

				-- if ply:GetNetVar('AdminMode') and table.HasValue({'superadmin'}, ply:GetUserGroup()) then
				-- 	surface.SetMaterial(Crown)
				-- 	surface.SetDrawColor(Color(255, 255, 255, 255))
				-- 	surface.DrawTexturedRect(w*.5 + 5, y + 35, 70, 70)
				-- 	surface.DrawTexturedRect(-w*.5 - 70, y + 35, 70, 70)
				-- end

				if ply:GetNetVar('AdminMode') then
					AddIcon(100, 100, Material("data/adminmode.png"), HSVToColor(CurTime() % 6 * 60, 1, 1))
				end

				if ply:GetNetVar('EventMode') then
					AddIcon(100, 100, Event, Color(255,255,255))
				end

				if ply:IsArrested() then
					AddIcon(100, 100, Material("data/arrested.png"), HSVToColor(CurTime() % 6 * 60, 1, 1))
				end

				-- if (LocalPlayer():IsHitman() or isadmin) and ply:HasHit() and (ply ~= LocalPlayer()) then
    --   				AddText('Заказ '..rp.FormatMoney(ply:GetHitPrice()), "MetaHub.Font90", Color(200,30,30))
    -- 			end

			end

			if LocalPlayer():GetNetVar('AdminMode') then
				AddText(ply:Health() .. ' HP', "MetaHub.Font70", Color(255, 64, 64))
				if ply:Armor() > 0 then
					AddText(ply:Armor() .. ' Armor', "MetaHub.Font70", Color(64, 64, 255))
				end
			end
		cam_End3D2D()

		if ply:IsFlagSet(FL_FROZEN) and not ply:InVehicle() then
			local attach = ply:GetAttachment( ply:LookupAttachment( "eyes" ) )
				
			if not attach  then continue end
			local stars = 3
				
			for i = 1, stars do
				local time = CurTime() * 3 + ( math.pi * 2 / stars * i )
				local offset = Vector( math.sin( time ) * 5, math.cos( time ) * 5, 7 )
					
				render.SetMaterial( star )
				render.DrawSprite( attach.Pos + offset, 8, 8, Color( 220, 220, 0 ) )
			end
		end
	end
end)

hook.Add("UpdateAnimation", "NameTags", function(pl)
	if not pl:IsPlayer() then return end
	
	local sdlp = pl:ShouldDrawLocalPlayer()
	if pl == LocalPlayer() and (not cvar_Get("localplayer_playertag") or not sdlp) then return end
	
	if not sdlp then
		local shootPos = LocalPlayer():GetShootPos()
		
		local hisPos = pl:GetShootPos()
		if hisPos:DistToSqr(shootPos) > 160000 then return end

		local pos = hisPos - shootPos
		local unitPos = pos:GetNormalized()
		local aimVec = LocalPlayer():GetAimVector()
		if unitPos:Dot(aimVec) < 0.91 then return end

		if not pl:InView() then return end
	end

	to_draw[pl] = fn
end)
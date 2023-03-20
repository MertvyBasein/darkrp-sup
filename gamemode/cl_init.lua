include 'sh_init.lua'

surface.CreateFont('Trebuchet22', {size = 22,  weight = 500,  antialias = true, shadow = false, font = 'roboto'})
surface.CreateFont('3d2d',		  {size = 130, weight = 1700, antialias = true, shadow = true,  font = 'roboto'})
surface.CreateFont("TextForBox", {font = "Trebuchet24",size = 40,weight = 1000,blursize = 0,scanlines = 0,antialias = false,underline = false,italic = false,strikeout = false,symbol = false,rotary = false,shadow = false,additive = false,outline = false,} )
surface.CreateFont("DrawPosInfoFD_Font_Title", {font = "Roboto",size = ScreenScale(6),weight = 600,antialias = true,extended = true,shadow = true})
surface.CreateFont("DrawPosInfoFD_Font_Dist", {font = "Roboto",size = ScreenScale(5),weight = 350,antialias = true,extended = true,shadow = true})
timer.Create('CleanBodys', 60, 0, function()
	RunConsoleCommand('r_cleardecals')
	for k, v in ipairs(ents.FindByClass('class C_ClientRagdoll')) do
		v:Remove()
	end
    //for k, v in ipairs(ents.FindByClass('class C_PhysPropClientside')) do
	//	v:Remove()
	//end
end)

rp.util = rp.util or {}

local blur 						= Material("pp/blurscreen")

function rp.util.DrawBlur(panel, amount)
	local x, y = panel:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 3 do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end

function rp.util.DrawShadowText(text, font, x, y, color, x_a, y_a, color_shadow)
	color_shadow = color_shadow or Color(0, 0, 0,255)
	draw.SimpleText(text, font, x + 1, y + 1, color_shadow, x_a, y_a)
	local w,h = draw.SimpleText(text, font, x, y, color, x_a, y_a)
	return w,h
end

function rp.util.DrawBText(text, font, shadow_font, x, y, color, x_a, y_a, color_shadow)
	color_shadow = color_shadow or Color(0, 0, 0)
	draw.SimpleText(text, shadow_font, x + 1, y + 1, color_shadow, x_a, y_a)
	local w,h = draw.SimpleText(text, font, x, y, color, x_a, y_a)
	return w,h
end

function rp.util.DrawRect(x,y,w,h,col, col_o)
	surface.SetDrawColor(col)
	surface.DrawRect(x,y,w,h)
end

function rp.util.DrawBox(x,y,w,h,col,col_o)
	col_o = col_o or Color(0,0,0,200)
	col = col or Color(0,0,0,150)

	surface.SetDrawColor(col)
	surface.DrawRect(x,y,w,h)

	rp.util.DrawOutline(x, y, w, h, col_o)
end

function rp.util.DrawOutline(x, y, w, h, col)
	col = col or Color(0,0,0)
	surface.SetDrawColor(col)
	surface.DrawOutlinedRect(x,y,w,h)
end

local function charWrap(text, pxWidth)
    local total = 0

    text = text:gsub(".", function(char)
        total = total + surface.GetTextSize(char)

        -- Wrap around when the max width is reached
        if total >= pxWidth then
            total = 0
            return "\n" .. char
        end

        return char
    end)

    return text, total
end

function rp.util.textWrap(text, font, pxWidth)
	local total = 0

	surface.SetFont(font)

	local spaceSize = surface.GetTextSize(' ')
	text = text:gsub("(%s?[%S]+)", function(word)
			local char = string.sub(word, 1, 1)
			if char == "\n" or char == "\t" then
				total = 0
			end

			local wordlen = surface.GetTextSize(word)
			total = total + wordlen

			-- Wrap around when the max width is reached
			if wordlen >= pxWidth then -- Split the word if the word is too big
				local splitWord, splitPoint = charWrap(word, pxWidth - (total - wordlen))
				total = splitPoint
				return splitWord
			elseif total < pxWidth then
				return word
			end

			-- Split before the word
			if char == ' ' then
				total = wordlen - spaceSize
				return '\n' .. string.sub(word, 2)
			end

			total = wordlen
			return '\n' .. word
		end)

	return text
end

rp.util.top_bar 				= ScrH() * .02314815 -- garbage
rp.util.top_bar_c 				= rp.util.top_bar * 0.5

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
local render 					= render
local mesh_Begin 				= mesh.Begin
local mesh_End 					= mesh.End
local mesh_Color 				= mesh.Color
local mesh_Position 			= mesh.Position
local mesh_Normal 				= mesh.Normal
local mesh_AdvanceVertex 		= mesh.AdvanceVertex

rp.util.meshMaterial = CreateMaterial("rp_mesh_material", "UnlitGeneric", {
    ["$basetexture"] = "color/white",
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1,
    ["$nocull"] = 1,
    ["$ignorez"] = 1
})

function rp.util.DrawCircle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, {
		x = x,
		y = y
	})

	for i = 0, seg do
		local a = rad((i / seg) * -360)

		table.insert(cir, {
			x = x + sin(a) * radius,
			y = y + cos(a) * radius
		})
	end

	local a = rad(0)

	table.insert(cir, {
		x = x + sin(a) * radius,
		y = y + cos(a) * radius
	})

	surface.DrawPoly(cir)
end

function rp.util.Draw3DCircle_filled(r2, segCount, col)
    local normal_up = Vector(0, 0, 2)
    local r = col.r
    local g = col.g
    local b = col.b
    local a = col.a
    local wedge_radians = pi * 2 / segCount
    local a0sin = sin(0)
    local a0cos = cos(0)
    local ang
    local a1cos, a1sin
    local p00x, p00y, p11x, p11y, p10x, p10y
    mesh_Begin(MATERIAL_TRIANGLES, segCount * 2 + 2)

    for i = 1, segCount do
        ang = i * wedge_radians
        a1cos = cos(ang)
        a1sin = sin(ang)
        p00x = 0
        p00y = 0
        local p01x = a0cos * r2
        local p01y = a0sin * r2
        p11x = 0
        p11y = 0
        p10x = a1cos * r2
        p10y = a1sin * r2
        mesh_Color(r, g, b, a)
        mesh_Normal(normal_up)
        mesh_Position(Vector(p10x, p10y, 0))
        mesh_AdvanceVertex()
        mesh_Color(r, g, b, a)
        mesh_Normal(normal_up)
        mesh_Position(Vector(p01x, p01y, 0))
        mesh_AdvanceVertex()
        mesh_Color(r, g, b, a)
        mesh_Normal(normal_up)
        mesh_Position(Vector(p00x, p00y, 0))
        mesh_AdvanceVertex()
        mesh_Color(r, g, b, a)
        mesh_Normal(normal_up)
        mesh_Position(Vector(p00x, p00y, 0))
        mesh_AdvanceVertex()
        mesh_Color(r, g, b, a)
        mesh_Normal(normal_up)
        mesh_Position(Vector(p11x, p11y, 0))
        mesh_AdvanceVertex()
        mesh_Color(r, g, b, a)
        mesh_Normal(normal_up)
        mesh_Position(Vector(p10x, p10y, 0))
        mesh_AdvanceVertex()
        a0sin = a1sin
        a0cos = a1cos
    end

    return mesh_End()
end

function rp.util.Draw3DCircle(r1, r2, segCount, gap_modNo, col)
	local normal_up = Vector(0, 0, 2)
    local r = col.r
    local g = col.g
    local b = col.b
    local a = col.a
    local wedge_radians = pi * 2 / segCount
    local a0sin = sin(0)
    local a0cos = cos(0)
    local ang
    local a1cos, a1sin
    local p00x, p00y, p11x, p11y, p10x, p10y
    mesh_Begin(MATERIAL_TRIANGLES, (segCount - floor(segCount / gap_modNo) + 1) * 2)

    for i = 1, segCount + 1 do
        ang = i * wedge_radians
        a1cos = cos(ang)
        a1sin = sin(ang)

        if i % gap_modNo ~= 0 then
            p00x = a0cos * r1
            p00y = a0sin * r1
            local p01x = a0cos * r2
            local p01y = a0sin * r2
            p11x = a1cos * r1
            p11y = a1sin * r1
            p10x = a1cos * r2
            p10y = a1sin * r2
            mesh_Color(r, g, b, a)
            mesh_Normal(normal_up)
            mesh_Position(Vector(p10x, p10y, 0))
            mesh_AdvanceVertex()
            mesh_Color(r, g, b, a)
            mesh_Normal(normal_up)
            mesh_Position(Vector(p01x, p01y, 0))
            mesh_AdvanceVertex()
            mesh_Color(r, g, b, a)
            mesh_Normal(normal_up)
            mesh_Position(Vector(p00x, p00y, 0))
            mesh_AdvanceVertex()
            mesh_Color(r, g, b, a)
            mesh_Normal(normal_up)
            mesh_Position(Vector(p00x, p00y, 0))
            mesh_AdvanceVertex()
            mesh_Color(r, g, b, a)
            mesh_Normal(normal_up)
            mesh_Position(Vector(p11x, p11y, 0))
            mesh_AdvanceVertex()
            mesh_Color(r, g, b, a)
            mesh_Normal(normal_up)
            mesh_Position(Vector(p10x, p10y, 0))
            mesh_AdvanceVertex()
        end

        a0sin = a1sin
        a0cos = a1cos
    end

    return mesh_End()
end

----

hook.Remove("RenderScreenspaceEffects", "RenderColorModify")
hook.Remove("RenderScreenspaceEffects", "RenderBloom")
hook.Remove("RenderScreenspaceEffects", "RenderToyTown")
hook.Remove("RenderScreenspaceEffects", "RenderTexturize")
hook.Remove("RenderScreenspaceEffects", "RenderSunbeams")
hook.Remove("RenderScreenspaceEffects", "RenderSobel")
hook.Remove("RenderScreenspaceEffects", "RenderSharpen")
hook.Remove("RenderScreenspaceEffects", "RenderMaterialOverlay")
hook.Remove("RenderScreenspaceEffects", "RenderMotionBlur")
hook.Remove("RenderScene", "RenderStereoscopy")
hook.Remove("RenderScene", "RenderSuperDoF")
hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
hook.Remove("PostRender", "RenderFrameBlend")
hook.Remove("PreRender", "PreRenderFrameBlend")
hook.Remove("Think", "DOFThink")
hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
hook.Remove("PostDrawEffects", "RenderWidgets")

local eyepos = Vector()
local eyeangles = Angle()
local eyefov = 90
local eyevector = Vector()

hook.Add("RenderScene", "Eye", function(origin, angles, fov)
    eyepos = origin
    eyeangles = angles
    eyefov = fov
    eyevector = angles:Forward()
end)

local meta = FindMetaTable('Entity')
function meta:ShouldHide()
    local pos = self:GetPos()
    return self ~= LocalPlayer() && (eyevector:Dot(pos - eyepos) < 1.5 || pos:DistToSqr(eyepos) > 9000000)
end

function meta:NotInRange()
    local pos = self:GetPos()
    return pos:DistToSqr(eyepos) > 9000000
end

function EyePos() return eyepos end
function EyeAngles() return eyeangles end
function EyeFov() return eyefov end
function EyeVector() return eyevector end

local GM = GAMEMODE
local CalcMainActivity = GM.CalcMainActivity
local UpdateAnimation = GM.UpdateAnimation
local PrePlayerDraw = GM.PrePlayerDraw
local DoAnimationEvent = GM.DoAnimationEvent
local PlayerFootstep = GM.PlayerFootstep
local PlayerStepSoundTime = GM.PlayerStepSoundTime
local TranslateActivity = GM.TranslateActivity

function render.SupportsHDR() return false end
function render.SupportsPixelShaders_2_0() return false end
function render.SupportsPixelShaders_1_4() return false end
function render.SupportsVertexShaders_2_0() return false end
function render.GetDXLevel() return 80 end

LocalPlayer():ConCommand("r_shadowrendertotexture 0")
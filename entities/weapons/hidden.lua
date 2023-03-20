AddCSLuaFile()

SWEP.PrintName = "Невидимость"
SWEP.Category = "CP"
SWEP.Author = ""
SWEP.Purpose = ""

SWEP.Slot = 0
SWEP.SlotPos = 1

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Delay = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

local sounds = {
	["cloak"] = "buttons/button1.wav",
	["cloak2"] = "buttons/button18.wav"
}

function SWEP:Initialize()
	self:SetHoldType( "normal" )
end

function SWEP:PrimaryAttack()
	local owner = self.Owner
	if IsValid(owner) then
		if GetGlobalBool('zombie_started') then
		if SERVER then
			rp.Notify(owner,1,'Во время зомби ивента инвиз не работает!')
		end
		self:SetNextPrimaryFire(CurTime() + 1)
		return
	end
		if owner.hiddencd and owner.hiddencd > CurTime() then rp.Notify(owner,1,'Вы недавно активировали невидимость, подождите '..math.Round(owner.hiddencd - CurTime())..' c.') self:SetNextPrimaryFire(CurTime() + 1) return end
		self:ToggleHidden(owner)
	end

	self:SetNextPrimaryFire(CurTime() + 3)
end

function SWEP:SecondaryAttack()
	return false
end

local function disable_hidden(ply)
	if ply:GetNWBool("hidden") then

		ply:SetRenderMode(RENDERMODE_NORMAL)
		ply:Fire("alpha", 255, 0)

		-- ply:SetNoDraw(false)
		ply:SetNoTarget(false)
		ply:SetNWBool("hidden", false)
		ply.hiddencd = CurTime() + 10
	end
end
function SWEP:ToggleHidden(ply, mode)
	local hidden = ply:GetNWBool("hidden")
	if SERVER and IsValid(ply) then
		if not hidden or mode == 1 then

			ply:SetRenderMode(RENDERMODE_TRANSALPHA)
			ply:Fire("alpha", 0,0)

			ply:SetNoTarget(true)
			ply:SetNWBool("hidden", true)
		elseif hidden or mode == 0 then
			disable_hidden(ply)
		end
	else
		if IsValid(ply) then
			if hidden then
				surface.PlaySound(sounds.cloak2)
			else
				surface.PlaySound(sounds.cloak)
			end
		end
	end
end

if CLIENT then
	surface.CreateFont("Hidden_Font", {
		font = "Lucida Sans Typewriter",
		antialias = true,
		outline = true,
		weight = 800,
		size = 25
	})
	local render = render

	local coeff = 0.02
	local AlphaAdditive = 1.5
	local AlphaPasses = 1.8
	local Bloom_Multiply = 0.5
	local Bloom_Darken = 0.5
	local Bloom_Blur = 0.1
	local Bloom_ColorMul = 0.25
	local Bloom_Passes = 1
	local CurScale = 0.5
	local DrawNightVision = false
	local oldNight = false
	local matNightVision = CreateMaterial("NightVisionMaterial", "UnlitTwoTexture",{
		["$additive"] = "1",
		["$basetexture"] ="_rt_FullFrameFB",
		["$texture2"] = "models/debug/debugwhite",
		["Proxies"] =
		{
			["TextureScroll"] =
			{
				["texturescrollvar"] = "$texture2transform",
				["texturescrollrate"] = "10",
				["texturescrollangle"] = "45"
			}
		}
	})
	matNightVision:SetFloat("$alpha", AlphaAdditive)

	local colorTable = {
		["$pp_colour_addr"] = -1,
		["$pp_colour_addg"] = -0.7,
		["$pp_colour_addb"] = -1,
		["$pp_colour_brightness"] = 0.8,
		["$pp_colour_contrast"]  = 2,
		["$pp_colour_colour"] = 0,
		["$pp_colour_mulr"] = 0 ,
		["$pp_colour_mulg"] = 0.1,
		["$pp_colour_mulb"] = 0
	}

	if render.GetDXLevel() < 80 then
		AlphaPasses = 1
		AlphaAdditive = 0.6
	end

	local function NightVisionFX()
		local hidden = LocalPlayer():GetNWBool("hidden")
		if oldNight != hidden then
			coeff = 0.02
			AlphaAdditive = 1.5
			AlphaPasses = 1.8
			Bloom_Multiply = 0.5
			Bloom_Darken = 0.5
			Bloom_Blur = 0.1
			Bloom_ColorMul = 0.25
			Bloom_Passes = 1
			CurScale = 0.5
			oldNight = hidden
		end

		if hidden then
			if CurScale < 0.995 then
				CurScale = CurScale + coeff * (1 - CurScale)
			end

			for i = 1, AlphaPasses do
				render.UpdateScreenEffectTexture()
				render.SetMaterial(matNightVision)
				render.DrawScreenQuad()
			end

			colorTable["$pp_colour_brightness"] = CurScale * 0.8
			colorTable["$pp_colour_contrast"] = CurScale * 2
			DrawColorModify(colorTable)
			DrawBloom(Bloom_Darken, CurScale * Bloom_Multiply, Bloom_Blur, Bloom_Blur, Bloom_Passes, CurScale * Bloom_ColorMul, 0, 1, 0)
			-- draw.SimpleTextOutlined("СКРЫТНОСТЬ АКТИВИРОВАНА", "Hidden_Font", ScrW() * 0.5, ScrH() * 0.9, Color(255, 100, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0, 0, 0))
		end
	end
	hook.Add("RenderScreenspaceEffects", "NightVisionFX", NightVisionFX)
	hook.Add("HUDPaint", "hidden_hudpaint", function()
		local hidden = LocalPlayer():GetNWBool("hidden")
		if hidden then
			draw.SimpleTextOutlined("СКРЫТНОСТЬ АКТИВИРОВАНА", "Hidden_Font", ScrW() * 0.5, ScrH() * 0.9, Color(255, 100, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color(0, 0, 0))
		end
	end)
end

-- Shared footstep.
hook.Add("PlayerFootstep", "DisableFoots", function( ply, pos, foot, sound, volume, rf )
	if ply:GetNWBool("hidden") == true then
		return true
	end
end)

--

if SERVER then
	hook.Add("PlayerDeath", "PlayerDeathInHidden", function(ply)
		disable_hidden(ply)
	end)

	hook.Add("OnPlayerChangedTeam", "PlayerHiddenChangeTeam", function(ply, old, new)
		disable_hidden(ply)
	end)

	hook.Add("PlayerSwitchWeapon","PlayerHiddenChangeSwep",function(ply,old,new)
		disable_hidden(ply)
	end)
end-- stop skidding

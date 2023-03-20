include("shared.lua")

SWEP.PrintName = "Наручники"
SWEP.Slot = 2
SWEP.SlotPos = 5
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

function surface.DrawPie(x, y, w, h, ang)
    if ang <= 0 then return end
    local w2, h2 = w / 2, h / 2

    if ang >= 360 then
        surface.DrawTexturedRect(x - w2, y - h2, w, h)
    elseif ang < 180 then
        local tc = math.tan(math.min(math.rad(ang), math.rad(45))) * 0.5
        local rc = math.tan(math.rad(math.min(ang - 90, 45))) * 0.5
        local bc = math.tan(math.rad(180 - ang)) * 0.5

        surface.DrawPoly{
        	{ x = x, y = y, u = 0.5, v = 0.5 },
        	{ x = x, y = y - h2, u = 0.5, v = 0 },
        	{ x = x + tc * w, y = y - h2, u = 0.5 + tc, v = 0 },
					ang > 45 and  { x = x + w2, y = y + rc * h, u = 1, v = 0.5 + rc },
					ang > 135 and { x = x + bc * w, y = y + h2, u = 0.5 + bc, v = 1 }
				}
    else
        surface.DrawPoly{
        	{ x = x, y = y - h2, u = 0.5, v = 0 },
					{ x = x + h2, y = y - h2, u = 1, v = 0 },
					{ x = x + h2, y = y + h2, u = 1, v = 1 },
					{ x = x, y = y + h2, u = 0.5, v = 1 }
        }

        local bc = math.tan(math.rad(math.min(ang - 180, 45))) * 0.5
        local lc = math.tan(math.rad(math.min(ang - 270, 45))) * 0.5
        local tc = math.tan(-math.rad(ang)) * 0.5

        surface.DrawPoly{
        	{ x = x, y = y, u = 0.5, v = 0.5 },
					{ x = x, y = y + h2, u = 0.5, v = 1 },
					{ x = x - bc * w, y = y + h2, u = 0.5 - bc, v = 1 },
					ang > 225 and { x = x - w2, y = y - lc * h, u = 0, v = 0.5 - lc },
					ang > 315 and { x = x - tc * w, y = y - h2, u = 0.5 - tc, v = 0 }
        }
    end
end

local mat = Material("sprites/grip")
function SWEP:DrawHUD()
	   local x, y = ScrW(), ScrH()
	    local activeweapon = LocalPlayer():GetActiveWeapon()
	    if IsValid(activeweapon) and activeweapon:GetClass() == "handcuffs" then
	        draw.SimpleTextOutlined( '[ЛКМ] - Надеть/Снять', GetFont(12), x- 10, y - 50, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,140))
					draw.SimpleTextOutlined( '[ПКМ] - Сопровождение', GetFont(12), x- 10, y - 20, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,140))
	    end
//
//	if not (self.working ) or self.Owner.tar == nil then return end
//
//	local start = self.finish - 1
//
//	surface.SetMaterial(mat)
//	surface.SetDrawColor(255, 255, 255, 255)
//	surface.DrawPie(ScrW() / 2, ScrH() / 2, 60, 60, math.min(1, (CurTime() - start) / (self.finish - start)) * 360)
end

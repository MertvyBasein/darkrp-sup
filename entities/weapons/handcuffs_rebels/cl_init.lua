include("shared.lua")

SWEP.PrintName = "Стяжки"
SWEP.Slot = 2
SWEP.SlotPos = 5
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

function SWEP:DrawHUD()
	local x, y = ScrW(), ScrH()
	local activeweapon = LocalPlayer():GetActiveWeapon()
	if IsValid(activeweapon) and activeweapon:GetClass() == "handcuffs_rebels" then
	    draw.SimpleTextOutlined( '[ЛКМ] - Надеть/Снять', GetFont(12), x- 10, y - 20, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,140))
		--draw.SimpleTextOutlined( '[ПКМ] - Сопровождение', GetFont(12), x- 10, y - 20, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color(0,0,0,140))
	 end
end

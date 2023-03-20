local PANEL = {}

local function voiceDrawOutline(x, y, w, h, col)
	col = col or Color(0,0,0)
	surface.SetDrawColor(col)
	surface.DrawOutlinedRect(x,y,w,h)
end

function voiceDrawBox(x,y,w,h,col,col_o)
	col_o = col_o or Color(0,0,0,150)
	col = col or Color(0,0,0,150)

	surface.SetDrawColor(col)
	surface.DrawRect(x,y,w,h)

	voiceDrawOutline(x, y, w, h, col_o)
end

function PANEL:Init()
	self:SetModel(LocalPlayer():GetModel())
	self.bg_col = Color(0,0,0,55)
end

function PANEL:SetBGColor(col)
	self.bg_col = col
end

function PANEL:Paint(w, h)
	voiceDrawBox(0, 0, w, h, ColorAlpha(self.bg_col, 100))
	if self:IsHovered() then
		voiceDrawBox(1, 1, w - 2, h - 2, ColorAlpha(self.bg_col, 150))
	end
end

-- function PANEL:Init()
-- 	self:SetModel(LocalPlayer():GetModel())
-- end

-- function PANEL:Paint(w, h)
-- 	draw.Box(0, 0, w, h, ui.col.Background)
-- 	if self:IsHovered() then
-- 		draw.Box(1, 1, w - 2, h - 2, ui.col.Hover, ui.col.Outline)
-- 	end
-- end

function PANEL:PaintOver(w, h)
	--draw.Outline(0, 0, w, h, ui.col.Outline)
end

vgui.Register('rp_modelicon', PANEL, 'SpawnIcon')
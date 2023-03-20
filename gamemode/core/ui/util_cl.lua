rp.ui = rp.ui or {}

local color_bg 		= ui.col.Background
local color_outline = ui.col.Outline

local math_clamp	= math.Clamp
local Color 		= Color

function rp.ui.DrawBar(x, y, w, h, perc)
	local color = Color(255 - (perc * 255), perc * 255, 0, 255)

	draw.OutlinedBox(x, y, math_clamp((w * perc), 3, w), h, color, color_outline)
end

function rp.ui.DrawProgressBar(x, y, w, h, perc, color, colorbg, colorout)
	local color = color or Color(255 - (perc * 255), perc * 255, 0, 255)
	local colorbg = colorbg or ui.col.Background
	local colorout = colorout or ui.col.Outline
	draw.OutlinedBox(x, y, w, h, colorbg, colorout)
	draw.Box(x + 1, y + 1, math_clamp((w * perc), 3, w - 2), h - 2, color)
end

function rp.ui.DrawProgress(x, y, w, h, perc, noSpacer)
	local color = Color(255 - (perc * 255), perc * 255, 0, 255)

	if (noSpacer) then
		draw.OutlinedBox(x, y, w, h, color_bg, color_outline)
		draw.Box(x + 1, y + 1, math_clamp((w * perc), 3, w - 2), h - 2, color)
	else
		draw.OutlinedBox(x, y, w, h, color_bg, color_outline)
		draw.OutlinedBox(x + 5, y + 5, math_clamp((w * perc) - 10, 3, w), h - 10, color, color_outline)
	end
end

local dcpY
local dcpCT = -1
function rp.ui.DrawCenteredProgress(text, prog)
	surface.SetFont(GetFont(12))
	local w, h = surface.GetTextSize(text)
	w = w + 16
	local x = (ScrW() - w) * 0.5

	if (dcpCT != FrameNumber()) then
		dcpY = ScrH() * 0.15
		dcpCT = FrameNumber()
	end
	local y = dcpY

	surface.SetDrawColor(0,20,0,1020)
	surface.DrawOutlinedRect(x, y, w, h)

	surface.SetDrawColor(0,0,0,100)
	surface.DrawRect(x, y, w, h)

	surface.SetTextPos(x + 8, y)
	surface.SetTextColor(200, 50, 50, (prog and math.abs(math.sin(RealTime() * 2)) or 1) * 255)
	surface.DrawText(text)

	if (prog and prog > 0) then
		surface.SetDrawColor(32,255,32)
		surface.DrawRect(x + prog * w, y, 5, h)
	end

	dcpY = dcpY + h + 5
end

local c = Color
local m1
local dframe
local tallbal = 26

local OutlineF = function(s, w, h, c1)
  surface.SetDrawColor(c1)
  surface.DrawLine(0, h, 0, 0)
  surface.DrawLine(0, 0, w, 0)
  surface.DrawLine(w - 1, 0, w - 1, h)
  surface.DrawLine(w, h - 1, 0, h - 1)
end

local PANEL = {}

function PANEL:Init()
  self:DockPadding(0, 26, 0, 0)
  self.lblTitle:SetPos(5, 3)
  self.lblTitle:SetColor(c(255, 255, 255))
  self.lblTitle:SetFont("ui.20")
  self:SetTitle("")
  self.title = ""
  self:SetBackgroundBlur(true)
  self.btnMaxim:SetVisible(false)
  self.btnMinim:SetVisible(false)
end

function PANEL:GetTitleHeight()
  return 24
end

function PANEL:Paint(w, h)
  framework(self, 5)
  surface.SetDrawColor(0, 0, 0, 150)
  surface.DrawRect(0, 0, w, h)
  surface.DrawRect(0, 0, w, 26)
  frametext(self.title, GetFont(13), w * .5, 0, c(255, 255, 255), 1)

  return true
end

function PANEL:PaintOver(w, h)
  OutlineF(self, w, h, c(0, 0, 0))
end

function PANEL:Focus()
  local panels = {}
  self:SetBackgroundBlur(true)

  for k, v in ipairs(vgui.GetWorldPanel():GetChildren()) do
    if v:IsVisible() and (v ~= self) then
      panels[#panels + 1] = v
      v:SetVisible(false)
    end
  end

  self._OnClose = self.OnClose

  self.OnClose = function()
    for k, v in ipairs(panels) do
      if IsValid(v) then
        v:SetVisible(true)
      end
    end

    self:_OnClose()
  end
end

function PANEL:PerformLayout()
  self.lblTitle:SizeToContents()
  self.btnClose:SetPos(self:GetWide() - 45, 0)
end

vgui.Register("eFrame", PANEL, "DFrame")

// MH \\

function drawRotatedBox( material, x, y, w, h, ang, color )
	surface.SetMaterial(Material(material, "noclamp smooth"))
	surface.SetDrawColor( color or color_white )
	surface.DrawTexturedRectRotated( x, y, w, h, ang )
end

function DrawCircle(posx, posy, radius, progress, color)
    local poly = {}

    poly[1] = { x = posx, y = posy }
    for i = 0, 220 * progress + 0.5 do
        poly[i + 2] = {
            x = math.sin(-math.rad(i / 220 * 360)) * radius + posx,
            y = math.cos(-math.rad(i / 220 * 360)) * radius + posy
        }
    end

    draw.NoTexture()
    surface.SetDrawColor(color)
    surface.DrawPoly(poly)
end

function DrawSimpleCircle(posx, posy, radius, color)
    local poly = {}

    for i = 0, 40 do
        poly[i + 1] = {
            x = math.sin(-math.rad(i / 40 * 360)) * radius + posx,
            y = math.cos(-math.rad(i / 40 * 360)) * radius + posy
        }
    end

    draw.NoTexture()
    surface.SetDrawColor(color)
    surface.DrawPoly(poly)
end

function draw.colorIcon(material, x, y, w, h, c)
	surface.SetMaterial(Material(material, "noclamp smooth"))
	surface.SetDrawColor(c)
	surface.DrawTexturedRect(x, y, w, h)
end

function DrawGlowingText(static, text, font, x, y, color, xalign, yalign)
    local xalign = xalign or TEXT_ALIGN_LEFT
    local yalign = yalign or TEXT_ALIGN_TOP
    local g = static and 1 or math.abs(math.sin((RealTime() - 0.1) * 2))

    for i = 1, 2 do
        draw.SimpleTextOutlined(text, font, x, y, color, xalign, yalign, i, Color(color.r, color.g, color.b, (20 - (i * 5)) * g))
    end

    local w,h = draw.SimpleText(text, font, x, y, color, xalign, yalign)

		return w,h
end
function draw.OutlinedBox2( x, y, w, h, thickness, clr )
	surface.SetDrawColor( clr )
	for i=0, thickness - 1 do
		surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
	end
end

local PANEL = {}
function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:MakePopup()
    self:Center()

    self:SetAlpha(0)
    self:AlphaTo(255, 0.3, 0)

    self.close = ui.Create("DButton", self)
    self.close:SetSize(100, 50)
    self.close:SetPos(self:GetWide() - 100, 0)
    self.close:SetText("")
    self.close.Paint = function(this, w, h)
        draw.SimpleText("Закрыть", GetFont(12), w * .5, 0, Color(255, 255, 255), 1, 0)
    end
    self.close.DoClick = function(s)
        surface.PlaySound("garrysmod/ui_click.wav")
        self:AlphaTo(0, 0.2, 0, function()
            if IsValid(self) then self:Remove() end
        end)
    end
end
function PANEL:Paint( w, h )
    framework(self, 5)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 175))
end
function PANEL:Think()
	if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
		gui.HideGameUI()
		self:Remove()
	end
end
vgui.Register( "QFrame", PANEL, "EditablePanel" )

local PANEL = {}
function PANEL:Init()
    self.scrollBar.scrollButton.Paint = function(s,w,h)
      draw.RoundedBox(0, 0, 0, w, h, Color(240,240,240,200))
    end
end
vgui.Register( "QScroll", PANEL, "ui_scrollpanel" )

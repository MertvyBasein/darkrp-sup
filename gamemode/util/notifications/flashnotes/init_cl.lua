local flashnotes = {}

local PANEL = {}
function PANEL:Init()
	self.Title = ui.Create('DLabel', function(s, p)
		s:SetColor(ui.col.White)
		s:SetFont('xpgui_small')
	end, self)
end

function PANEL:SetInfo(title, text)
	local w, h = 275, 26
	local newW = 0

	text = string.Wrap('xpgui_small', text, w - 10)

	surface.SetFont('xpgui_big')
	local tW = surface.GetTextSize(title)
	newW = tW + 10

	surface.SetFont('xpgui_small')
	for k, v in ipairs(text) do
		if (v ~= '') then
			local tW = surface.GetTextSize(v)
			if (tW > newW) then
				newW = tW
			end

			ui.Create('DLabel', function(s, p)
				s:SetText(v)
				s:SetPos(5, 26 + ((k - 1) * s:GetTall()))
				s:SetColor(ui.col.White)
				s:SetFont('xpgui_small')
				s:SizeToContents()
				h = h + s:GetTall()
			end, self)
		end
	end

	self:SetSize(newW + 10, h + 2)
	self:SetAlpha(0)
	self:FadeIn(0.2)
	self:SetPos(ScrW() * .5 - self:GetWide() * .5, ScrH() * .1)

	self.End = CurTime() + 7.1 --3.4

	self.Title:SetText(title)

	hook('Think', self, function()
		if (self.animation) then
			self.animation:Run()
		end
	end)

	timer.Simple(6, function()
		if IsValid(self) then
			self:FadeOut(0.2, function()
				flashnotes[self.ID] = nil
				self:Remove()
			end)
		end
	end)
end

function PANEL:PerformLayout()
	self.Title:SizeToContents()
	self.Title:SetPos((self:GetWide() * .5) - (self.Title:GetWide() * .5), 1)
end


local color_background = ui.col.Background
local color_outline = ui.col.Outline

local bar_color = ui.col.SUP:Copy()
bar_color.a = 25
local gradtex = surface.GetTextureID("gui/gradient_down")
function PANEL:Paint(w, h)
	if (hook.Call('HUDShouldDraw', GAMEMODE, 'FashNotes') == false) then return end

	draw.OutlinedBox(0, 0, w, h, color_background, color_outline)
	draw.OutlinedBox(0, 0, w, 26, color_background, color_outline)

	draw.Box(0, 0, w, 26, Color(50,50,50,150))

end

function PANEL:FadeIn(speed, cback)
	self.animation = Derma_Anim('Fade Panel', self, function(panel, animation, delta, data)
		panel:SetAlpha(delta * 255)
		if (animation.Finished) then
			self.animation = nil
			if cback then cback() end
		end
	end)

	if (self.animation) then
		self.animation:Start(speed)
	end
end

function PANEL:FadeOut(speed, cback)
	self.animation = Derma_Anim('Fade Panel', self, function(panel, animation, delta, data)
		panel:SetAlpha(255 - (delta * 255))
		if (animation.Finished) then
			self.animation = nil
			if cback then cback() end
		end
	end)

	if (self.animation) then
		self.animation:Start(speed)
	end
end
vgui.Register('rp_flashnotification', PANEL, 'Panel')


function rp.FlashNotify(title, text)
	local note = ui.Create('rp_flashnotification')
	note:SetInfo(title, text)
	note.ID = 1

	for k, v in ipairs(flashnotes) do
		v.ID = v.ID + 1
		local x, y = v:GetPos()
		v:SetPos(x, y + note:GetTall() + 4, 0.2)
	end

	table.insert(flashnotes, 1, note)
end

net('rp.FlashString', function()
	if (not IsValid(LocalPlayer())) then return end
	rp.FlashNotify(net.ReadString(), rp.ReadMsg())
end)

net('rp.FlashTerm', function()
	if (not IsValid(LocalPlayer())) then return end
	rp.FlashNotify(net.ReadString(), net.ReadTerm())
end)

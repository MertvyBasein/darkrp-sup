local PANEL = {}

function PANEL:Init()
	self.AngleSlider = ui.Create('ui_slider', self)
	self.AngleSlider.OnChange = function(s, value)

		self.ModelPanel.Entity:SetAngles(Angle(0, (value - 0.5) * 360, 0))
	end
	self.AngleSlider.Paint = function(s, w, h)
	end

	self.ModelPanel = ui.Create('DModelPanel', self)
	self.ModelPanel:SetMouseInputEnabled(false)
	self.ModelPanel:SetFOV(20)
	self.ModelPanel:SetModel(LocalPlayer():GetModel())
	self.ModelPanel.DrawModel = function(self)
		self.Entity:DrawModel()

		self.Entity:SetEyeTarget(gui.ScreenToVector(gui.MousePos()))
	end
	self.ModelPanel.LayoutEntity = function(self)
		self:RunAnimation()
	end
	self.ModelPanel.Entity.GetPlayerColor = function()
		return LocalPlayer():GetPlayerColor()
	end

	local hz = 60

	if IsValid(self.ModelPanel.Entity) then
		local headBone = self.ModelPanel.Entity:LookupBone('ValveBiped.Bip01_Head1')
		if headBone then
			hz = self.ModelPanel.Entity:GetBonePosition(headBone).z
		end
	end
	if hz < 5 then
		hz = 40
	end
	hz = hz * 0.6

	self.ModelPanel:SetCamPos(Vector(175, 0, hz))
	self.ModelPanel:SetLookAt(Vector(0, 0, hz))

	self.Sequences = {
		'pose_standing_01',
		'pose_standing_02',
		'pose_standing_03',
		'pose_standing_04',
	}

	self:FindSequence()
end

function PANEL:PerformLayout()
	local w, h = self:GetSize()

	self.ModelPanel:SetSize(w, h - 25)
	self.ModelPanel:SetPos(0, 0)

	self.AngleSlider:SetWide(w - 40)
	self.AngleSlider:SetPos(0, h - self.AngleSlider:GetTall())
end

function PANEL:FindSequence()
	if IsValid(self.ModelPanel.Entity) then
		local seqno
		repeat
			seqno = self.ModelPanel.Entity:LookupSequence(self.Sequences[math.random(1, #self.Sequences)])
		until seqno
		self.ModelPanel.Entity:SetSequence(seqno)
	end
end

function PANEL:AddSequence(sequence)
	self.Sequences[#self.Sequences + 1] = sequence
end

function PANEL:SetFOV(fov)
	return self.ModelPanel:SetFOV(fov)
end

function PANEL:SetModel(model)
	return self.ModelPanel:SetModel(model)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(ui.col.Outline)
	surface.DrawLine(20, h - 10, w - 40, h - 10)
	draw.NoTexture()
	surface.DrawPoly({
		{x = 20, y = h - 10},
		{x = 40, y = h - 20},
		{x = 40, y = h}
	})

	surface.DrawPoly({
		{x = w - 40, y = h - 20},
		{x = w - 20, y = h - 10},
		{x = w - 40, y = h}
	})
end

vgui.Register('rp_playerpreview', PANEL, 'Panel')
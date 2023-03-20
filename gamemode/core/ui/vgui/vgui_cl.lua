local GUI = {}
local GM = GM or GAMEMODE

GUI.Theme = 'Black'
GUI.Colors = {}
GUI.Colors['Black'] = {}
GUI.Colors['Black'].Background = Color(0, 0, 0, 175)
GUI.Colors['Black'].NameColor = Color(255, 255, 255)
GUI.Colors['Black'].MoneyColor = Color(255, 255, 255)
GUI.Colors['Black'].CategoryColor = Color(255, 255, 255)
GUI.Colors['Black'].BBColor = Color(0, 0, 0, 50)
GUI.Colors['Black'].BBText = Color(255, 255, 255)
GUI.Colors['Black'].ItemBG = Color(0, 0, 0, 50)
GUI.Colors['Black'].ItemOut = Color(255, 255, 255, 120)
GUI.Colors['Black'].ItemMBG = Color(0, 0, 0, 120)

local PANEL = {}

function PANEL:Init()
    local PanelCategory = self
    PanelCategory.Children = {}
    PanelCategory.IsToggled = false
    PanelCategory:SetTall(35)
    PanelCategory.Button = vgui.Create("DButton", PanelCategory)
    PanelCategory.Button:Dock(TOP)
    PanelCategory.Button:DockMargin(5, 5, 5, 0)
    PanelCategory.Button:SetHeight(35)
    PanelCategory.Button:SetText("")

    PanelCategory.Button.DoClick = function()
        PanelCategory:DoToggle()
    end

    PanelCategory.Button.Paint = function(self, w, h)
        draw.SimpleText(PanelCategory.Title, GetFont(16), 5, 12, GUI.Colors[GUI.Theme].BBText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 50))
end

function PANEL:AddNewChild(element)
    local PanelCategory = self
    if not IsValid(element) then return end
    table.insert(PanelCategory.Children, element)
    PanelCategory.List:PerformLayout()
end

function PANEL:ToggleOpened()
    local PanelCategory = self
    PanelCategory.IsToggled = true
    PanelCategory:SizeTo(PanelCategory:GetWide(), 35 + PanelCategory.List:GetTall() + 15, 0.5, 0.1)
end

function PANEL:ToggleClosed()
    local PanelCategory = self
    PanelCategory.IsToggled = false
    PanelCategory:SizeTo(PanelCategory:GetWide(), 35, 0.5, 0.1)
end

function PANEL:DoToggle()
    local PanelCategory = self

    if PanelCategory.IsToggled then
        PanelCategory:ToggleClosed()
    else
        PanelCategory:ToggleOpened()
    end
end

function PANEL:HeaderTitle(catTitle)
    local PanelCategory = self
    PanelCategory.Title = catTitle
end

vgui.Register("AriviaCategory", PANEL, "DPanel")

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local PANEL = {}

function PANEL:Init()
    self:SetTall(65)
    self.Binder = ui.Create('DButton', self)
    self.Binder:SetText'...'

    self.Binder.DoClick = function(s)
        input.StartKeyTrapping()
        s.Trapping = true
        s:SetText'...'
    end

    self.Binder.Think = function(s)
        if input.IsKeyTrapping() and s.Trapping then
            local key = input.CheckKeyTrapping()

            if key then
                removebind(self.Key)
                s:SetText(input.GetKeyName(key))
                s.Trapping = false
                self.Key = key
                savebind(key, self.Cmd, self.Type)
            end
        end
    end

    self.Setting = ui.Create('DComboBox', self)
    self.Setting:AddChoice('Чат')
    self.Setting:AddChoice('Команда')
    self.Setting:AddChoice('Свой')

    self.Setting.OnSelect = function(s, inx, type)
        self.Type = type
        savebind(self.Key, self.Cmd, self.Type)
    end

    self.Custom = ui.Create('DTextEntry', self)

    self.Custom.OnChange = function(s)
        self.Cmd = s:GetValue()
        savebind(self.Key, self.Cmd, self.Type)
    end

    self.Unbind = ui.Create('DButton', self)
    self.Unbind:SetText''

    self.Unbind.DoClick = function(s)
        removebind(self.Key)
        self:Remove()
    end

    self.Unbind.Paint = function(s, w, h)
        derma.SkinHook('Paint', 'WindowCloseButton', s, w, h)
    end
end

function PANEL:PerformLayout()
    self.Binder:SetPos(5, 5)
    self.Binder:SetSize(55, 55)
    self.Setting:SetPos(65, 5)
    self.Setting:SetSize(self:GetWide() * 0.5, 25)
    self.Custom:SetPos(65, 35)
    self.Custom:SetSize(self:GetWide() - 70, 25)
    self.Unbind:SetSize(25, 25)
    self.Unbind:SetPos(self:GetWide() - 30, 5)
end

function PANEL:SetBind(inf)
    self.Key = inf.Key
    self.Cmd = inf.Cmd
    self.Type = inf.Type
    self.Binder:SetText(input.GetKeyName(self.Key))
    self.Setting:SetText(self.Type)
    self.Custom:SetValue(self.Cmd)
end

vgui.Register('rp_keybinder', PANEL, 'ui_panel')

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local PANEL = {}

function PANEL:Init()

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
	hz = hz * 0.8

	self.ModelPanel:SetCamPos(Vector(150, 0, hz))
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

	self.ModelPanel:SetSize(w, h - 5)
	self.ModelPanel:SetPos(0, 0)

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

end

vgui.Register('rp_modelpreview', PANEL, 'Panel')

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local PANEL = {}

function PANEL:Init()
    self.Settings = ui.Create('ui_settingspanel', self)
    self.Settings.Paint = function(s, w, h) end

    self.Settings:Populate({'Медиа-плейер', 'Чат', 'HUD', 'Другое'})
end

function PANEL:PerformLayout()
    self.Settings:SetPos(0, 0)
    self.Settings:SetSize(self:GetWide() - (self:GetWide() * 0.5) + 1, self:GetTall())
end

vgui.Register('rp_settings', PANEL, 'Panel')

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local PANEL = {}

function PANEL:Init()
	self:SetText('')
	self:SetTall(50)
	self.Model = ui.Create('rp_modelicon', self)

	self.Model.DoClick = function(s)
		s.DoClick(self)
	end
end

function PANEL:Paint(w, h)
	draw.OutlinedBox(0, 0, w, h, self.job.color, ui.col.Outline)

	if self:IsHovered() then
		draw.OutlinedBox(0, 0, w, h, self.job.color, ui.col.Hover)
	end

	draw.SimpleTextOutlined(self.job.name, GetFont(14), 60, h * 0.5, ui.col.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, ui.col.Black)
end

function PANEL:PerformLayout()
	self.Model:SetPos(0, 0)
	self.Model:SetSize(50, 50)
end

function PANEL:OnCursorEntered()
	self.Parent.job = self.job
	self.Parent.ModelKey = cvar.GetValue('TeamModel' .. self.job.name) or 1

	self.Preview:SetModel(self.job.citizen_model and LocalPlayer():GetNetVar('CitizenModel') or istable(self.job.model) and self.job.model[self.Parent.ModelKey] or self.job.model)

	self.Preview:FindSequence()

	if not istable(self.job.ModelInfo) then return end

	if istable(self.job.ModelInfo.BGroups) then
		for k, v in pairs(self.job.ModelInfo.BGroups) do
			if IsValid(self.Preview.ModelPanel.Entity) then
				self.Preview.ModelPanel.Entity:SetBodygroup(k, v)
			end
		end
	end

	if istable(self.job.ModelInfo.Skin) then
		if IsValid(self.Preview.ModelPanel.Entity) then
			self.Preview.ModelPanel.Entity:SetSkin(math.random(1, #self.job.ModelInfo.Skin))
		end
	elseif isnumber(self.job.ModelInfo.Skin) then
		if IsValid(self.Preview.ModelPanel.Entity) then
			self.Preview.ModelPanel.Entity:SetSkin(self.job.ModelInfo.Skin)
		end
	end
end

function PANEL:DoClick()
	if self.Parent.DoClick then
		self.Parent.DoClick(self)
		return
	end
end

function PANEL:SetJob(job)
	self.job = job
	self.job.color = Color(job.color.r, job.color.g, job.color.b, 125)
	self.ModelPath = job.citizen_model and LocalPlayer():GetNetVar('CitizenModel') or istable(job.model) and job.model[1] or job.model
	self.Model:SetModel(self.ModelPath)
end

vgui.Register('rp_jobbutton', PANEL, 'Button')
PANEL = {}

function PANEL:Init()
	self.job = rp.teams[1]
	self.job.color = Color(self.job.color.r, self.job.color.g, self.job.color.b, 125)
	self.ModelKey = cvar.GetValue('TeamModel' .. self.job.name) or 1
	rp.RunCommand('model', self.job.model[self.ModelKey])
	self.JobList = ui.Create('ui_scrollpanel', self)
	self.Info = ui.Create('ui_panel', self)

	self.Info.Paint = function(s, w, h)
		draw.OutlinedBox(0, 0, w, 50, self.job.color, ui.col.Outline)
		draw.SimpleTextOutlined(self.job.name, 'ui.24', w * 0.5, 25, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ui.col.Black)
	end

	self.Model = ui.Create('rp_playerpreview', self)
	self.Model:SetFOV(50)
	self.Model:SetModel(self.job.citizen_model and LocalPlayer():GetNetVar('CitizenModel') or istable(self.job.model) and self.job.model[self.ModelKey] or self.job.model)


	for k, v in pairs({TEAM_CITIZEN, TEAM_UGRS, TEAM_RGRS, TEAM_PPGRS, TEAM_VGRS, TEAM_POVGRS, TEAM_LOA1, TEAM_LOA2, TEAM_CITIZEN3, TEAM_RCT, TEAM_METROPOLIC03E, TEAM_METROPOLICE02, TEAM_METROPOLICE01, TEAM_METROPOLICE04MED, TEAM_METROPOLICE_BRESERK}) do
		local a = rp.teams[v]

		if ((not a.customCheck) or a.customCheck(LocalPlayer())) and (k ~= LocalPlayer():Team()) then
			local btn = ui.Create('rp_jobbutton')
			btn:SetJob(a)
			btn.Parent = self
			btn.Preview = self.Model
			self.JobList:AddItem(btn)
		end
	end
end

function PANEL:PerformLayout()
	self.JobList:SetPos(5, 5)
	self.JobList:SetSize(self:GetWide() * 0.5 - 7.5, self:GetTall() - 10)
	self.JobList:SetSpacing(1)
	self.Info:SetPos(self:GetWide() * 0.5 + 2.5, 5)
	self.Info:SetSize(self:GetWide() * 0.5 - 7.5, self:GetTall() * 0.5)
	self.Model:SetPos(self:GetWide() * 0.5 + 2.5, self:GetTall() * 0.5)
	self.Model:SetSize(self:GetWide() * 0.5 - 7.5, self:GetTall() * 0.5 - 35)
end

vgui.Register('rp_jobslist_disguise', PANEL, 'Panel')


local PANEL = {}

function PANEL:Init()
	self:SetDrawOnTop(true)
	self.DeleteContentsOnClose = false

	self:SetText("")
	self:SetFont(GetFont(8))
	self:SetExpensiveShadow(1, Color(0, 0, 0, 170))
end

function PANEL:UpdateColours()
	return self:SetTextStyleColor(color_white)
end

function PANEL:SetContents(panel, bDelete)
	panel:SetParent(self)

	self.Contents = panel
	self.DeleteContentsOnClose = bDelete or false
	self.Contents:SizeToContents()
	self:InvalidateLayout(true)

	self.Contents:SetVisible(false)
end

function PANEL:PerformLayout()
	if IsValid(self.Contents) then
		self:SetWide(self.Contents:GetWide() + 8)
		self:SetTall(self.Contents:GetTall() + 8)
		self.Contents:SetPos(4, 4)
		self.Contents:SetVisible(true)
	else
		local w, h = self:GetContentSize()
		self:SetSize(w + 10, h + 8)
		self:SetContentAlignment(5)

		if self:GetText() == "" then
			self:SetVisible(false)
		else
			self:SetVisible(true)
		end
	end
end

local Mat = Material("vgui/arrow")
function PANEL:DrawArrow(x, y)
	self.Contents:SetVisible(true)
	surface.SetMaterial(Mat)
	surface.DrawTexturedRect(self.ArrowPosX + x, self.ArrowPosY + y, self.ArrowWide, self.ArrowTall)
end

function PANEL:PositionTooltip()
  if ( !IsValid( self.TargetPanel ) ) then
		self:Remove()
		return
	end

	self:PerformLayout()

	local x, y = input.GetCursorPos()
	local w, h = self:GetSize()

	local lx, ly = self.TargetPanel:LocalToScreen( 0, 0 )

	y = y - 50

	y = math.min( y, ly - h * 1.5 )
	if ( y < 2 ) then y = 2 end

	-- Fixes being able to be drawn off screen
	self:SetPos( math.Clamp( x - w * 0.5, 0, ScrW() - self:GetWide() ), math.Clamp( y, 0, ScrH() - self:GetTall() ))
end

function PANEL:Paint(w, h)
	self:PositionTooltip()
  draw.RoundedBox(8, 0, 0, w, h, Color(10, 10, 10, 200))
	//draw.DrawPanelRoundedRectBlur(self, 0, 0, w, h, Color(10, 10, 10, 200))
end

function PANEL:OpenForPanel(panel)
	self.TargetPanel = panel
	self:PositionTooltip()

	local cooldown = 0.25
	if cooldown > 0 then
		self:SetVisible(false)
		timer.Simple(cooldown, function()
			if not IsValid(self) or not IsValid(panel) then
				return
			end
			self:PositionTooltip()
			self:SetVisible(true)
		end)
	end
end

function PANEL:Close()
	if not self.DeleteContentsOnClose && IsValid(self.Contents) then
		self.Contents:SetVisible(false)
		self.Contents:SetParent(nil)
	end
	self:Remove()
end

derma.DefineControl("MHTooltip", "", PANEL, "DLabel")

local file, Material, Fetch, find = file, Material, http.Fetch, string.find

local errorMat = Material("error", 'smooth') // а чё бы не смуф
local WebImageCache = {}
if !file.IsDir('metahubicon', 'DATA') then
    file.CreateDir('metahubicon')
end
function DownloadMaterial(url, path, callback)
    if WebImageCache[url] then return callback(WebImageCache[url]) end

    local data_path = "data/metahubicon/".. path
    if file.Exists('metahubicon/'..path, "DATA") then
        WebImageCache[url] = Material(data_path, "smooth", "noclamp")
        callback(WebImageCache[url])
    else
        Fetch(url, function(img)
            if img == nil or find(img, "<!DOCTYPE HTML>", 1, true) then return callback(errorMat) end
            
            file.Write('metahubicon/'..path, img)
            WebImageCache[url] = Material(data_path, "smooth", "noclamp")
            callback(WebImageCache[url])
        end, function()
            callback(errorMat)
        end)
    end
end
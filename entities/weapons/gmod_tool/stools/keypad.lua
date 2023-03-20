TOOL.Category = "Основное"
TOOL.Name = "Кейпад"
TOOL.Command = nil
TOOL.ClientConVar['weld'] = '1'
TOOL.ClientConVar['freeze'] = '1'

TOOL.ClientConVar['password'] = ''
TOOL.ClientConVar['secure'] = '0'

TOOL.ClientConVar['repeats_granted'] = '0'
TOOL.ClientConVar['repeats_denied'] = '0'

TOOL.ClientConVar['length_granted'] = '4'
TOOL.ClientConVar['length_denied'] = '0.1'

TOOL.ClientConVar['delay_granted'] = '0'
TOOL.ClientConVar['delay_denied'] = '0'

TOOL.ClientConVar['init_delay_granted'] = '0'
TOOL.ClientConVar['init_delay_denied'] = '0'

TOOL.ClientConVar['key_granted'] = '0'
TOOL.ClientConVar['key_denied'] = '0'

cleanup.Register("keypads")

if(CLIENT) then
	language.Add("tool.keypad.name", "Кейпад")
	language.Add("tool.keypad.0", "Left Click: Create, Right Click: Update")
	language.Add("tool.keypad.desc", "Creates Keypads for secure access")

	language.Add("Undone_Keypad", "Undone Keypad")
	language.Add("Cleanup_keypads", "Keypads")
	language.Add("Cleaned_keypads", "Cleaned up all Keypads")

	language.Add("SBoxLimit_keypads", "You've hit the Keypad limit!")
end

function TOOL:SetupKeypad(ent, pass)
	local data = {
		Password = pass,

		RepeatsGranted = self:GetClientNumber("repeats_granted"),
		RepeatsDenied = self:GetClientNumber("repeats_denied"),

		LengthGranted = math.Clamp(self:GetClientNumber("length_granted"), 4, 10),
		LengthDenied = self:GetClientNumber("length_denied"),

		DelayGranted = math.Clamp(self:GetClientNumber("delay_granted"), 4, 10),
		DelayDenied = self:GetClientNumber("delay_denied"),

		InitDelayGranted = self:GetClientNumber("init_delay_granted"),
		InitDelayDenied = self:GetClientNumber("init_delay_denied"),

		KeyGranted = self:GetClientNumber("key_granted"),
		KeyDenied = self:GetClientNumber("key_denied"),

		Secure = util.tobool(self:GetClientNumber("secure")),

		Owner = self:GetOwner()
	}

	ent:SetData(data)
end

function TOOL:RightClick(tr)
	if(IsValid(tr.Entity) and tr.Entity:GetClass() ~= 'keypad') then return false end

	if(CLIENT) then return true end

	local ply = self:GetOwner()
	local password = tostring(tonumber(ply:GetInfo("keypad_password")))

	local spawn_pos = tr.HitPos
	local trace_ent = tr.Entity

	if(password == nil or (#password > 4) or (string.find(password, "0"))) then
		rp.Notify(ply, NOTIFY_ERROR, 'Неверный пароль!')
		return false
	end

	if(trace_ent:GetClass() == 'keypad' and trace_ent.KeypadData.Owner == ply) then
		self:SetupKeypad(trace_ent, password) -- validated password

		return true
	end
end

function TOOL:LeftClick(tr)
	if(IsValid(tr.Entity) and tr.Entity:GetClass() == "player") then return false end

	if(CLIENT) then return true end

	local ply = self:GetOwner()
	local password = tostring(tonumber(ply:GetInfo("keypad_password")))

	local trace_ent = tr.Entity

	if(password == nil or (#password > 4) or (string.find(password, "0"))) then
		rp.Notify(ply, NOTIFY_ERROR, 'Неверный пароль!')
		return false
	end

	if(not self:GetWeapon():CheckLimit("keypads")) then return false end

	local pl = self:GetOwner()
	local ent = ents.Create('keypad')
	ent:SetPos(tr.HitPos)
	ent:SetAngles(tr.HitNormal:Angle())
	ent:Spawn()
	ent:SetAngles(tr.HitNormal:Angle())
	ent:Activate()
	ent:CPPISetOwner(pl)

	local phys = ent:GetPhysicsObject() -- rely on this being valid

	local freeze = util.tobool(self:GetClientNumber("freeze"))
	local weld = util.tobool(self:GetClientNumber("weld"))

		if freeze or weld then
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
		end

		if weld then
			local weld = constraint.Weld(ent, trace_ent, 0, 0, 0, true, false)
		end

	self:SetupKeypad(ent, password) -- validated password

	undo.Create("Keypad")
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
	undo.Finish()

	ply:AddCount("keypads", ent)
	ply:AddCleanup("keypads", ent)


	return true
end


if(CLIENT) then
	local function ResetSettings(ply)
		ply:ConCommand("keypad_repeats_granted 0")
		ply:ConCommand("keypad_repeats_denied 0")
		ply:ConCommand("keypad_length_granted 4")
		ply:ConCommand("keypad_length_denied 0.1")
		ply:ConCommand("keypad_delay_granted 0")
		ply:ConCommand("keypad_delay_denied 0")
		ply:ConCommand("keypad_init_delay_granted 0")
		ply:ConCommand("keypad_init_delay_denied 0")
	end

	concommand.Add("keypad_reset", ResetSettings)

	function TOOL.BuildCPanel(CPanel)
		local r, l = CPanel:TextEntry("4 Digit Password", "keypad_password")
		r:SetTall(22)

		CPanel:ControlHelp("Allowed Digits: 1-9")

		CPanel:CheckBox("Secure Mode", "keypad_secure")
		CPanel:CheckBox("Weld and Freeze", "keypad_weld")
		CPanel:CheckBox("Freeze", "keypad_freeze")

		local ctrl = vgui.Create("CtrlNumPad", CPanel)
			ctrl:SetConVar1("keypad_key_granted")
			ctrl:SetConVar2("keypad_key_denied")
			ctrl:SetLabel1("Access Granted")
			ctrl:SetLabel2("Access Denied")
		CPanel:AddPanel(ctrl)

		CPanel:Button("Reset Settings", "keypad_reset")

		CPanel:Help("")
		CPanel:Help("Settings when access granted")

		CPanel:NumSlider("Hold Length", "keypad_length_granted", 4, 10, 2)
		CPanel:NumSlider("Initial Delay", "keypad_init_delay_granted", 0, 10, 2)
		CPanel:NumSlider("Multiple Press Delay", "keypad_delay_granted", 0, 10, 2)
		CPanel:NumSlider("Additional Repeats", "keypad_repeats_granted", 0, 5, 0)


		CPanel:Help("")
		CPanel:Help("Settings when access denied")

		CPanel:NumSlider("Hold Length", "keypad_length_denied", 0.1, 10, 2)
		CPanel:NumSlider("Initial Delay", "keypad_init_delay_denied", 0, 10, 2)
		CPanel:NumSlider("Multiple Press Delay", "keypad_delay_denied", 0, 10, 2)
		CPanel:NumSlider("Additional Repeats", "keypad_repeats_denied", 0, 5, 0)
	end
end
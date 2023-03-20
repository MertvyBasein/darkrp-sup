--[[не трож убьет]]local VoteVGUI = {}
local QuestionVGUI = {}
local PanelNum = 0
local LetterWritePanel

local function MsgDoVote(msg)
	if LocalPlayer():IsBanned() then return end

	local chatX, chatY = chat.GetChatBoxPos()
	local chatW, chatH = chat.GetChatBoxSize()
	local x, y = chatX + chatW + 10, ScrH() - 10

	local question = msg:ReadString()
	local voteid = msg:ReadShort()
	local timeleft = msg:ReadFloat()
	local steamid = msg:ReadString()

	if timeleft == 0 then timeleft = 100 end

	if (not IsValid(LocalPlayer())) then return end

	LocalPlayer():EmitSound('Town.d1_town_02_elevbell1', 100, 100)

	local panel = ui.Create('XPContextFrame', function(self)
		self:SetPos(0, ScrH() - 145)
		self:MoveTo(x + PanelNum,  ScrH() - 145, 0.15, 0, 1)
		self:SetTitle('Голосование')
		self:SetSize(210, 140)
		--self:SetSizable(false)
		--self:SetDraggable(false)
		--self:ShowCloseButton(false)
		self.isContext = true
		self.End = CurTime()
	end)

	function panel:Close()
		PanelNum = PanelNum - 142.5
		VoteVGUI[voteid .. 'vote'] = nil

		local num = 5
		for k,v in SortedPairs(VoteVGUI) do
			v:SetPos(num, ScrH() - 145)
			num = num + 142.5
		end

		for k,v in SortedPairs(QuestionVGUI) do
			v:SetPos(num, ScrH() - 145)
			num = num + 302.5
		end
		self:Remove()
	end

	-- function panel:Think()
	-- 	local time = timeleft - (CurTime() - self.End)
	-- 	if (time <= 0) then panel:Close() end
	-- 	if IsValid(self.Title) then
	-- 		print('q')
	-- 		self.Title:Remove()
	-- 	end
	-- 	self:SetTitle('Время: '.. math.ceil(time))
	-- end

	panel:SetKeyboardInputEnabled(false)
	panel:SetMouseInputEnabled(true)
	panel:SetVisible(true)

	for i = 22, string.len(question), 22 do
		if not string.find(string.sub(question, i - 20, i), '\n', 1, true) then
			question = string.sub(question, 1, i) .. '\n'.. string.sub(question, i + 1, string.len(question))
		end
	end

	local label = ui.Create('DLabel', panel)
	label:Dock(TOP)
	label:DockMargin(7, 7, 0, 0)
	label:SetText(question)
	label:SetFont('xpgui_small')
	label:SizeToContents()

	local nextHeight = label:GetTall() > 78 and label:GetTall() - 78 or 0 // make panel taller for divider and buttons
	panel:SetTall(panel:GetTall() + nextHeight)

	local ybutton = ui.Create('XPButton')
	ybutton:SetParent(panel)
	ybutton:SetPos(5, panel:GetTall() - 30)
	ybutton:SetSize(panel:GetWide()/2 -7.5, 25)
	--ybutton:SetCommand('!')
	ybutton:SetText('Да')
	ybutton.DoClick = function()
		LocalPlayer():ConCommand('vote ' .. voteid .. ' yea\n')
		panel:Close()
	end

	local nbutton = ui.Create('XPButton')
	nbutton:SetParent(panel)
	nbutton:SetPos(panel:GetWide()/2 + 2.5, panel:GetTall() - 30)
	nbutton:SetSize(panel:GetWide()/2 -7.5, 25)
	--nbutton:SetCommand('!')
	nbutton:SetText('Нет')
	nbutton.DoClick = function()
		LocalPlayer():ConCommand('vote ' .. voteid .. ' nay\n')
		panel:Close()
	end

	PanelNum = PanelNum + 142.5
	VoteVGUI[voteid .. 'vote'] = panel
end
usermessage.Hook('DoVote', MsgDoVote)

local function KillVoteVGUI(msg)
	local id = msg:ReadShort()

	if VoteVGUI[id .. 'vote'] and VoteVGUI[id .. 'vote']:IsValid() then
		VoteVGUI[id..'vote']:Close()

	end
end
usermessage.Hook('KillVoteVGUI', KillVoteVGUI)

net('DoQuestion', function()
	local color_background = ui.col.Background
	local color_outline = ui.col.Outline

	local bar_color = ui.col.SUP:Copy()
	bar_color.a = 25

	local question = net.ReadString()
	local quesid = net.ReadString()
	local timeleft = net.ReadFloat()

	if timeleft == 0 then timeleft = 100 end

	LocalPlayer():EmitSound('Town.d1_town_02_elevbell1', 100, 100)

	local panel = ui.Create('XPContextFrame', function(self)
		self:SetPos(3 + PanelNum, ScrH() / 2 - 50)
		self:SetSize(300, 140)
		--self:SetSizable(false)
		--self:SetKeyboardInputEnabled(false)
		--self:SetMouseInputEnabled(true)
		self:SetVisible(true)
		--self:ShowCloseButton(false)
		self.End = CurTime()

	end)

    function panel:Close()
        PanelNum = PanelNum - 302.5
        QuestionVGUI[quesid .. 'ques'] = nil
        local num = 0
        for k,v in SortedPairs(VoteVGUI) do
            v:SetPos(num, ScrH() / 2 - 50)
            num = num + 142.5
        end

        for k,v in SortedPairs(QuestionVGUI) do
            v:SetPos(num, ScrH() / 2 - 50)
            num = num + 302.5
        end
        
        self:Remove()
    end

	function panel:PaintOver()
		local time = timeleft - (CurTime() - self.End)
		if (time <= 0) then panel:Close() end
		if IsValid(self.Title) then
			self.Title:Remove()
		end
		self:SetTitle('Время: '.. math.ceil(time))
	end

	local Label = ui.Create('DLabel')
	Label:SetParent(panel)
	Label:SetPos(5, 35)
	Label:SetText(question)
	Label:SetFont('xpgui_small')
	Label:SizeToContents()

    local BtnYes = ui.Create('XPButton')
    BtnYes:SetParent(panel)
    BtnYes:SetPos(105, 100)
    BtnYes:SetSize(40, 20)
    BtnYes:SetText('Да')
    BtnYes:SetFont('xpgui_small')
    BtnYes:SetVisible(true)
    BtnYes.DoClick = function()
        LocalPlayer():ConCommand('ans ' .. quesid .. ' 1\n')
        panel:Close()
    end

    local BtnNo = ui.Create('XPButton')
    BtnNo:SetParent(panel)
    BtnNo:SetPos(155, 100)
    BtnNo:SetSize(40, 20)
    BtnNo:SetText('Нет')
    BtnNo:SetFont('xpgui_small')
    BtnNo:SetVisible(true)
    BtnNo.DoClick = function()
        LocalPlayer():ConCommand('ans ' .. quesid .. ' 2\n')
        panel:Close()
    end

	PanelNum = PanelNum + 302.5
	QuestionVGUI[quesid .. 'ques'] = panel
end)

net('KillQuestionVGUI', function()
	local id = net.ReadString()

	if QuestionVGUI[id .. 'ques'] and QuestionVGUI[id .. 'ques']:IsValid() then
		QuestionVGUI[id .. 'ques']:Close()
	end
end)

local function DoVoteAnswerQuestion(ply, cmd, args)
	if not args[1] then return end

	local vote = 0
	if tonumber(args[1]) == 1 or string.lower(args[1]) == 'yes' or string.lower(args[1]) == 'true' then vote = 1 end

	for k,v in pairs(VoteVGUI) do
		if Valiui_panel(v) then
			local ID = string.sub(k, 1, -5)
			VoteVGUI[k]:Close()
			RunConsoleCommand('vote', ID, vote)
			return
		end
	end

	for k,v in pairs(QuestionVGUI) do
		if Valiui_panel(v) then
			local ID = string.sub(k, 1, -5)
			QuestionVGUI[k]:Close()
			RunConsoleCommand('ans', ID, vote)
			return
		end
	end
end
concommand.Add('rp_vote', DoVoteAnswerQuestion)
rp.orgs = rp.orgs or {}

local fr

net('rp.OrgsMenu', function()
    if IsValid(fr) then fr:Close() end

    local w, h = ScrW() * 0.55, ScrH() * 0.525

    local orgdata   = LocalPlayer():GetOrgData()
    local rank      = orgdata.Rank
    local motd      = orgdata.MoTD
	local perms     = orgdata.Perms

    local orgmembers = {}
	local orgranks = {}
	local orgrankref = {}
	
	 for i = 1, net.ReadUInt(4) do
        local rankname  = net.ReadString()
        local weight    = net.ReadUInt(7)
        local invite    = net.ReadBool()
		local kick		= net.ReadBool()
		local rank		= net.ReadBool()
		local motd		= net.ReadBool()
        orgranks[#orgranks + 1] = {
            Name     = rankname,
			Weight   = weight,
			Invite   = invite,
			Kick     = kick,
			Rank     = rank,
			MoTD     = motd
        }
		orgrankref[rankname] = orgranks[#orgranks]
    end
	table.SortByMember(orgranks, 'Weight')

	for i = 1, net.ReadUInt(8) do
        local steamid   = net.ReadString()
        local name      = net.ReadString()
        local rank      = net.ReadString()
		
		if (!orgrankref[rank]) then
			print("Glitched member: " .. steamid .. " rank " .. rank .. " doesnt exist! Assuming lowest")
			rank = orgranks[#orgranks].Name
		end
		
		local weight = orgrankref[rank].Weight
        orgmembers[#orgmembers + 1] = {
            SteamID 	= steamid,
            Name    	= name,
            Rank    	= rank,
			Weight		= weight
        }
    end
	
	fr = ui.Create('ui_frame', function(self)
		self:SetTitle(LocalPlayer():GetOrg())
		self:SetSize(w, h)
		self:MakePopup()
		self:Center()
		self:SetDraggable(false)
	end)
	
	--------------------------------------------
	-- Left Column: Members
	--------------------------------------------
	fr.colLeft = ui.Create('Panel', function(self)
		self:SetWide(w / 3)
		self:Dock(LEFT)
	end, fr)
	
	fr.lblMem = ui.Create('DLabel', function(self)
		self:SetText('Участники: ' .. #orgmembers)
		self:SizeToContents()
		self:Dock(TOP)
	end, fr.colLeft)
	
	fr.listMem = ui.Create('ui_listview', function(self)
		self:Dock(FILL)
	end, fr.colLeft)
	
	--------------------------------------------
	-- Middle Column: Ranks
	--------------------------------------------
	local a = ui.Create('Panel', function(self)
		self:SetWide(256)
		self:DockMargin(5, 0, 5, 0)
		self:Dock(LEFT)
		self:InvalidateParent(true)
	end, fr)

	local flag = ui.Create('DPanel', function(self)
		self:Dock(TOP)
		self:SetTall(a:GetTall()/2)
	end, a)

	fr.colMid = ui.Create('Panel', function(self)
		self:Dock(FILL)
	end, a)

	fr.lblRanks = ui.Create('DLabel', function(self)
		self:SetText("Ранги")
		self:SizeToContents()
		self:Dock(TOP)
	end, fr.colMid)

	fr.listRank = ui.Create('ui_listview', function(self)
		self:Dock(FILL)
	end, fr.colMid)
	
	--------------------------------------------
	-- Right Column: MOTD, Color
	--------------------------------------------
	fr.colRight = ui.Create('Panel', function(self)
		self:Dock(FILL)
	end, fr)

	fr.lblMoTD = ui.Create('DLabel', function(self)
		self:SetText('Информация')
		self:SizeToContents()
		self:Dock(TOP)
	end, fr.colRight)

	fr.txtMoTD = ui.Create('ui_scrollpanel', function(self)
		self:Dock(FILL)
		self:SetPadding(3)

		self.Paint = function(s, w, h)
			surface.SetDrawColor(200, 200, 200)
			surface.DrawRect(0, 0, w, h)
		end
	end, fr.colRight)
	
	--------------------------------------------
	-- Begin Data Population
	--------------------------------------------
	fr.PopulateMembers = function(tosel)
		table.SortByMember(orgmembers, 'Weight')
		fr.listMem:Reset(true)

		local lastRank = ''
		local cats = {}
		for k, v in ipairs(orgmembers) do
			if (v.Rank != lastRank) then
				cats[#cats+1] = {Name = v.Rank, Members = {}}
				lastRank = v.Rank
			end

			table.insert(cats[#cats].Members, v)
		end

		for k, v in ipairs(cats) do
			fr.listMem:AddSpacer(v.Name)
			table.SortByMember(v.Members, 'Name', true)

			for k, v in ipairs(v.Members) do
				local btn = fr.listMem:AddPlayer(v.Name, v.SteamID)
				btn:SetContentAlignment(4)
				btn:SetTextInset(32, 0)

				btn.Player = v

				if (tosel == v.SteamID) then
					btn:DoClick()
				end
			end
		end
	end
	fr.PopulateMembers()

	fr.ReorderRanks = function()
		local sel = fr.listRank:GetSelected()
		local rank = sel and sel.Rank and sel.Rank.Name or nil

		table.SortByMember(orgranks, 'Weight')

		for k, v in ipairs(orgranks) do
			local k = #orgranks - (k - 1)
			local newWeight = 1 + math.floor(((k - 1) / (#orgranks - 1)) * 99)
			v.Weight = newWeight
		end

		fr.PopulateRanks(rank)
	end
	
	fr.PopulateRanks = function(tosel)
		fr.listRank:Reset(true)

		for k, v in ipairs(orgranks) do
			local btn = fr.listRank:AddRow(v.Name)
			btn.Rank = v
			v.Btn = btn
			v.Number = k

			if (v.Name == tosel) then
				btn:DoClick()
			end
		end

		for k, v in ipairs(fr.listRank:GetChildren()) do
			local x, y = v.x, v.y
			local w, h = v:GetSize()

			v:Dock(NODOCK)
			v:SetPos(x, y)
			v:SetSize(w, h)
		end
	end
	fr.PopulateRanks()

	fr.PopulateMoTD = function()
		fr.txtMoTD:Reset(true)

		local motdRows = string.Wrap('ui.22', motd, w - 30 - fr.colLeft:GetWide() - fr.colMid:GetWide())
		for k, v in pairs(motdRows) do
			local lbl = ui.Create('DLabel', function(self)
				self:SetText(v)
				self:SizeToContents()
				self:SetWide(w - 15 - fr.colLeft:GetWide() - fr.colMid:GetWide())
				self:SetTextColor(rp.col.Black)
				fr.txtMoTD:AddItem(self)
			end)
		end
	end
	fr.PopulateMoTD()
	
	--------------------------------------------
	-- Admin stuff!
	--------------------------------------------
	if (perms.Owner) then
		fr.btnCol = ui.Create('ui_button', function(self)
			self:SetText("Редактировать Цвет")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.overMoTD))
			end
			
			self.DoClick = function(s)
				if (IsValid(fr.colPicker)) then
					local color = fr.colPicker:GetColor()
					if (color != LocalPlayer():GetOrgColor()) then
						RunConsoleCommand('setorgcolor', color.r, color.g, color.b)
					end
						
					fr.colPicker:Remove()
					fr.lblMoTD:SetText('Информация')
					s:SetText('Редактировать Цвет')
				else
					fr.colPicker = ui.Create('DColorMixer', function(col)
						col:SetPos(fr.txtMoTD.x, fr.lblMoTD:GetTall())
						col:SetSize(fr.txtMoTD:GetSize())
						col:SetColor(LocalPlayer():GetOrgColor())
						col:SetAlphaBar(false)
						
						col.OP = col.Paint
						col.Paint = function(s, w, h)
							surface.SetDrawColor(rp.col.Black)
							surface.DrawRect(0, 0, w, h)
							s:OP(w, h)
						end
						
					end, fr.colRight)
					
					fr.lblMoTD:SetText('Выберите новый цвет')
					s:SetText("Сохранить")
				end
			end
		end, fr.colRight)
		
		fr.btnNewRank = ui.Create('ui_button', function(self)
			self:SetText("Новый ранг")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.overRankEdit))
			end
			
			self.DoClick = function(s)
				if (IsValid(fr.overRankNew)) then
					fr.overRankNew:Remove()
					s:SetText("Новый ранг")
				else
					fr.overRankNew = ui.Create('ui_scrollpanel', function(scr)
						scr:SetPos(fr.listRank.x, fr.lblRanks:GetTall())
						scr:SetSize(fr.listRank:GetSize())
						scr.Paint = function(s, w, h)
							surface.SetDrawColor(200, 200, 200)
							surface.DrawRect(0, 0, w, h)
						end
					end, fr.colMid)
					
					local txtName = ui.Create('ui_button', function(txt)
						txt:SetTall(25)
						txt:SetFont('ui.22')
						txt:SetText('Enter Name')
						txt:Dock(TOP)

						txt.DoClick = function(s)
							ui.StringRequest('Название ранга', 'Как бы вы назвали этот ранк?', '', function(resp)
								s:SetText(resp)
							end)
						end

						fr.overRankNew:AddItem(txt)
					end)

					local chkInvite = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Приглашать других игроков")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)

					local chkKick = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Исключать игроков")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)

					local chkRank = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Изменять ранги")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)

					local chkMOTD = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Изменять Информацию")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)
					
					local btnSubmit = ui.Create('ui_button', function(btn)
						btn:SetTall(25)
						btn:SetText("Сохранить")
						btn.TextColor = rp.col.Green
						btn:Dock(TOP)

						btn.DoClick = function(s)
							local name = txtName:GetText()
							local weight = 2
							local invite = chkInvite:GetChecked()
							local kick = chkKick:GetChecked()
							local canrank = chkRank:GetChecked()
							local motd = chkMOTD:GetChecked()
							
							RunConsoleCommand('orgrank', name, tostring(weight), invite and '1' or '0', kick and '1' or '0', canrank and '1' or '0', motd and '1' or '0')
							
							if (#orgranks < 5) then
								orgrankref[name] = orgranks[table.insert(orgranks, {Name = name, Weight = weight, Invite = invite, Kick = kick, Rank = canrank, MoTD = motd})]
							end
							
							fr.btnNewRank:DoClick()
							fr.ReorderRanks()
						end

						fr.overRankNew:AddItem(btn)
					end)

					txtName:DoClick()
					s:SetText("Отмена")
				end
			end
		end, fr.colMid)

		fr.btnEditRank = ui.Create('ui_button', function(self)
			self:SetText("Редактировать ранг")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.overRankNew) or !fr.listRank:GetSelected() or (IsValid(fr.overRankEdit) and fr.overRankEdit:GetAlpha() != 255))
			end
			
			self.DoClick = function(s, ignore)
				if (IsValid(fr.overRankEdit)) then
					if (!ignore) then
						local rank = fr.listRank:GetSelected().Rank

						local invite = fr.overRankEdit.chkInvite:GetChecked()
						local kick = fr.overRankEdit.chkKick:GetChecked()
						local canrank = fr.overRankEdit.chkRank:GetChecked()
						local motd = fr.overRankEdit.chkMOTD:GetChecked()
						
						if (invite != rank.Invite or kick != rank.Kick or canrank != rank.Kick or motd != rank.MoTD) then
							RunConsoleCommand('orgrank', rank.Name, tostring(rank.Weight), invite and '1' or '0', kick and '1' or '0', canrank and '1' or '0', motd and '1' or '0')
							rank.Invite = invite
							rank.Kick = kick
							rank.Rank = canrank
							rank.MoTD = motd
						end
					end
						
					fr.overRankEdit:Remove()
					s:SetText("Редактировать ранг")
					fr.lblRanks:SetText('Ранги')
				else
					local rank = fr.listRank:GetSelected().Rank

					fr.overRankEdit = ui.Create('ui_scrollpanel', function(scr)
						scr:SetPos(fr.listRank.x, fr.listRank.y)
						scr:SetSize(fr.listRank:GetSize())
						scr.Paint = function(s, w, h)
							surface.SetDrawColor(200, 200, 200)
							surface.DrawRect(0, 0, w, h)
						end
						scr.FadeTo = 255
						scr.Think = function(s)
							if (s:GetAlpha() != s.FadeTo) then
								local a = s:GetAlpha()
								local mul = a > s.FadeTo and -1 or 1
								s:SetAlpha(math.Clamp(a + (FrameTime() * mul * 1000), mul == 1 and 0 or s.FadeTo, 255))
							end
						end
					end, fr.colMid)
					
					local btnName = ui.Create('ui_button', function(btn)
						btn:SetText('Переименовывать')
						btn:SetTall(25)
						btn:Dock(TOP)

						btn.DoClick = function(s)
							ui.StringRequest('Переименовывать ранг', 'Что бы вы хотели переименовать ' .. rank.Name .. ' to?', '', function(resp)
								if (!orgrankref[resp]) then
									RunConsoleCommand('orgrank', rank.Name, resp)
									fr.listRank:GetSelected():SetText(resp)
									fr.lblRanks:SetText('Редактирование ' .. resp)

									for k, v in ipairs(orgmembers) do if (v.Rank == rank.Name) then v.Rank = resp end end
									rank.Name = resp
									fr.PopulateMembers()
									fr.PopulateRanks(resp)
								end
							end)
						end

						fr.overRankEdit:AddItem(btn)
					end)
					
					ui.Create('ui_button', function(btn)
						btn:SetText('Установить ниже')
						btn:SetTall(25)
						btn:Dock(TOP)

						btn.DoClick = function(s)
							local m = ui.DermaMenu()

							for k, v in ipairs(orgranks) do
								if (v.Weight == 1 or v.Name == rank.Name) then continue end
								
								m:AddOption(v.Name, function()
									rank.Weight = v.Weight-1
									RunConsoleCommand('orgrank', rank.Name, tostring(v.Weight-1), rank.Invite and '1' or '0', rank.Kick and '1' or '0', rank.Edit and '1' or '0', rank.MoTD and '1' or '0')
									
									fr.ReorderRanks()
								end)
							end

							m:Open()
						end

						fr.overRankEdit:AddItem(btn)
						if (rank.Weight == 1 or rank.Weight == 100) then
							btn:SetMouseInputEnabled(false)
						end
					end)

					fr.overRankEdit.chkInvite = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Приглашать других игроков")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.Invite)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)

					fr.overRankEdit.chkKick = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Исключать игроков")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.Kick)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)

					fr.overRankEdit.chkRank = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Изменять ранги")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.Rank)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)

					fr.overRankEdit.chkMOTD = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Редактировать Информацию")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.MoTD)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)
					
					ui.Create('ui_button', function(btn)
						btn:SetText('Удалить')
						btn:SetTall(25)

						btn.Think = function(s)
							if (s.CoolDown and SysTime() > s.CoolDown + 2) then
								s:SetText("Удалить")
								s.CoolDown = nil;
							end
						end

						btn.DoClick = function(s)
							if (!s.CoolDown) then
								s.CoolDown = SysTime()
								s:SetText("Нажмите снова")
							else
								RunConsoleCommand('orgrankremove', rank.Name)
								fr.listRank:GetSelected():Remove()
								fr.btnEditRank:DoClick(true)

								orgrankref[rank.Name] = nil
								local nextRank
								local rn = rank.Name
								for k, v in ipairs(orgranks) do
									if (v.Name == rank.Name) then
										nextRank = orgranks[k+1]
										table.remove(orgranks, k)
										break
									end
								end
								for k, v in ipairs(orgmembers) do
									if (v.Rank == rn) then
										v.Rank = nextRank.Name
									end
								end
								local sel = fr.listMem:GetSelected()
								fr.PopulateMembers(sel and sel.Player.SteamID or nil)
							end
						end

						btn.TextColor = rp.col.Red

						fr.overRankEdit:AddItem(btn)
						if (rank.Weight == 1 or rank.Weight == 100) then
							btn:SetMouseInputEnabled(false)
						end
					end)

					fr.lblRanks:SetText('Редактирование ' .. rank.Name)
					fr.lblRanks:SizeToContents()
					s:SetText("Назад")
				end
			end
		end, fr.colMid)

	end

	if (perms.MoTD) then
		fr.btnMoTD = ui.Create('ui_button', function(self)
			self:SetText("Редактировать Информацию")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.colPicker))
			end

			self.DoClick = function(s)
				if (IsValid(fr.overMoTD)) then
					local newMoTD = fr.overMoTD:GetValue()
					fr.overMoTD:Remove()

					if (newMoTD != motd) then
						net.Start('rp.SetOrgMoTD')
							net.WriteString(newMoTD)
						net.SendToServer()

						motd = newMoTD
						fr.PopulateMoTD()
					end
					
					s:SetText("Редактировать Информацию")
				else
					fr.overMoTD = ui.Create('DTextEntry', function(txt)
						txt:SetPos(fr.txtMoTD.x, fr.lblMoTD:GetTall())
						txt:SetSize(fr.txtMoTD:GetSize())
						txt:SetMultiline(true)
						txt:SetValue(motd)
						txt:SetFont('ui.22')
						txt:RequestFocus()
					end, fr.colRight)

					s:SetText("Сохранить")
				end
			end
		end, fr.colRight)
	end

	if (perms.Invite) then
		fr.btnInv = ui.Create('ui_button', function(self)
			self:SetText("Пригласить игроков")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.overMem))
			end

			self.DoClick = function(s)
				if (IsValid(fr.overMemInv)) then
					fr.overMemInv:Remove()
					s:SetText("Пригласить игроков")
				else
					fr.overMemInv = ui.Create('ui_playerrequest', function(scr)
						scr:SetPos(fr.listMem.x, fr.lblMem:GetTall())
						scr:SetSize(fr.listMem:GetSize())

						scr:SetPlayers(table.Filter(player.GetAll(), function(v)
							return (not v:GetOrg())
						end))

						scr.OnSelection = function(self, row, pl)
							RunConsoleCommand('orginvite', pl:SteamID64())

							row:Remove()
						end

						scr.Paint = function(scr, w, h)
							surface.SetDrawColor(0, 0, 0)
							surface.DrawRect(0, 0, w, h)
							derma.SkinHook('Paint', 'Frame', self, w, h)
						end
					end, fr.colLeft)

					s:SetText("Назад")
				end
			end
		end, fr.colLeft)
	end

	if (perms.Kick) then
		if (perms.Rank) then
			fr.btnEdit = ui.Create('ui_button', function(self)
				self:SetText("Редактировать игрока")
				self:SetTall(25)
				self:DockMargin(0, 5, 0, 0)
				self:Dock(BOTTOM)

				self.Think = function(s)
					local sel = fr.listMem:GetSelected()

					if (IsValid(fr.overMemInv) or !IsValid(sel) or !sel.Player or sel.Player.SteamID == LocalPlayer():SteamID64() or sel.Player.Weight >= perms.Weight) then
						s:SetDisabled(true)
					else
						s:SetDisabled(false)
					end
				end

				self.DoClick = function(s)
					if (IsValid(fr.overMem)) then
						fr.overMem:Remove()
						s:SetText("Редактировать игрока")
					else
						local sel = fr.listMem:GetSelected()

						fr.overMem = ui.Create('ui_listview', function(scr)
							scr:SetPadding(-1)
							scr:SetPos(fr.listMem.x, fr.lblMem:GetTall())
							scr:SetSize(fr.listMem:GetSize())

							scr.Paint = function(s, w, h)
								surface.SetDrawColor(200, 200, 200)
								surface.DrawRect(0, 0, w, h)
							end

							scr:AddSpacer(sel.Player.Name)

							if (!sel.Player) then return end

							scr.btnKick = ui.Create('ui_button', function(btn)
								btn:SetText("Исключить игрока")
								btn.TextColor = rp.col.Red
								btn:SetTall(25)
								scr:AddItem(btn)

								btn.Think = function(s)
									if (s.CoolDown) then
										if (SysTime() > s.CoolDown + 2) then
											s:SetText("Исключить игрока")
											s.CoolDown = nil
										end
									end
								end

								btn.DoClick = function(s)
									if (!s.CoolDown) then
										s.CoolDown = SysTime()
										s:SetText("Нажмите еще раз, чтобы подтвердить")
									else
										RunConsoleCommand('orgkick', sel.Player.SteamID)
										fr.btnEdit:DoClick()

										sel:Remove()
									end
								end
							end)
							
							scr.btnRank = ui.Create('ui_button', function(btn)
								btn:SetText("Изменить ранг")
								btn:SetTall(25)
								scr:AddItem(btn)

								btn.DoClick = function(s)
									local m = ui.DermaMenu()

									local num = 0
									for k, v in ipairs(orgranks) do
										if (v.Weight < perms.Weight and v.Name != sel.Player.Rank) then
											num = num + 1
											m:AddOption(v.Name, function()
												RunConsoleCommand('orgsetrank', sel.Player.SteamID, v.Name)
												sel.Player.Rank = v.Name
												sel.Player.Weight = v.Weight
												fr.PopulateMembers(sel.Player.SteamID)
												sel = fr.listMem:GetSelected()
											end)
										end
									end

									if (num >= 1) then
										m:Open()
									else
										m:Remove()
									end
								end
							end)		
						end, fr.colLeft)

						s:SetText("Назад")
					end
				end
			end, fr.colLeft)
		else
			fr.btnKick = ui.Create('ui_button', function(self)
				self:SetText("Исключить игрока")
				self:SetTall(25)
				self:DockMargin(0, 5, 0, 0)
				self:Dock(BOTTOM)
				self.TextColor = rp.col.Red

				self.Think = function(s)
					local sel = fr.listMem:GetSelected()

					if (IsValid(fr.overMemInv) or !IsValid(sel) or !sel.Player or sel.Player.SteamID == LocalPlayer():SteamID64() or sel.Player.Weight >= perms.Weight) then
						s:SetDisabled(true)
					else
						s:SetDisabled(false)
					end

					if (s.CoolDown) then
						if (SysTime() > s.CoolDown + 2) then
							s:SetText("Исключить игрока")
							s.CoolDown = nil
						end
					end
				end

				self.DoClick = function(s)
					if (!s.CoolDown) then
						s.CoolDown = SysTime()
						s:SetText("Нажмите еще раз, чтобы подтвердить")
					else
						local sel = fr.listMem:GetSelected()
						RunConsoleCommand('orgkick', sel.Player.SteamID)
						
						sel:Remove()
						s.CoolDown = 0
					end
				end
			end, fr.colLeft)
		end
	end

	--------------------------------------------
	-- Patented quit button
	--------------------------------------------
	fr.btnQuit = ui.Create('ui_button', function(self)
		self:SetText(perms.Owner and 'Распустить' or 'Выйти')
		self:SizeToContents()
		self:SetSize(self:GetWide() + 40, fr.btnClose:GetTall())
		self:SetPos(fr.btnClose.x - self:GetWide() + 1, 0)
		
		self.DoClick = function(s)
			local str = perms.Owner and 'Распустить организацию?' or 'Выйти из организации?'
			local str2 = perms.Owner and 'Вы уверены, что хотите распустить ' .. LocalPlayer():GetOrg() .. '? Напишите YES в поле ниже.' or 'Вы уверены, что хотите выйти ' .. LocalPlayer():GetOrg() .. '? Напишите YES в поле ниже.'
			
			ui.StringRequest(str, str2, '', function(resp)
				local ismatch = (perms.Owner and resp:lower() == 'yes') or (!perms.Owner and resp:lower() == 'yes')

				if (ismatch) then
					fr:Close()
					RunConsoleCommand('quitorg')
				end
			end)
		end
	end, fr)
end)

hook('PopulateF4Tabs', function(frs, fr)
	--frs:Adui_button('Клан', function()
	--	if (LocalPlayer():GetOrg() == nil) then
	--		fr:Close()
	--		ui.StringRequest('Создать Организацию', 'Хотите создать Организацию, стоимость: ' .. rp.FormatMoney(rp.cfg.OrgCost) .. '?\n Напишите название вашей Организации.', '', function(resp)
	--			RunConsoleCommand('createorg', resp)
	--		end)
	--	else
	--		ui.Create'rp_org_panel'
	--	end
	--end):SetIcon('justrp/gui/generic/teamwork.png')	
end)

local PANEL = {}

function PANEL:Init()
	net.Start'rp.OrgsMenus'
	net.SendToServer()

    local orgdata   = LocalPlayer():GetOrgData()
    self.rank      = orgdata.Rank
    self.motd      = orgdata.MoTD
	self.perms     = orgdata.Perms
	self.flag		= orgdata.Flag
	local perms = self.perms
	local motd = self.motd
	local flag_ico = 'https://i.imgur.com/'..self.flag..'.png'

    local orgmembers = {}
	local orgranks = {}
	local orgrankref = {}

	local fr = self

	net('rp.OrgsMenus', function()
		local w, h = self:GetSize()

		for i = 1, net.ReadUInt(4) do
    	    local rankname  = net.ReadString()
    	    local weight    = net.ReadUInt(7)
    	    local invite    = net.ReadBool()
			local kick		= net.ReadBool()
			local rank		= net.ReadBool()
			local motd		= net.ReadBool()
    	    orgranks[#orgranks + 1] = {
    	        Name     = rankname,
				Weight   = weight,
				Invite   = invite,
				Kick     = kick,
				Rank     = rank,
				MoTD     = motd
    	    }
			orgrankref[rankname] = orgranks[#orgranks]
    	end
		table.SortByMember(orgranks, 'Weight')
	
		for i = 1, net.ReadUInt(8) do
    	    local steamid   = net.ReadString()
    	    local name      = net.ReadString()
    	    local rank      = net.ReadString()
			
			if (!orgrankref[rank]) then
				print("Glitched member: " .. steamid .. " rank " .. rank .. " doesnt exist! Assuming lowest")
				rank = orgranks[#orgranks].Name
			end
			
			local weight = orgrankref[rank].Weight
    	    orgmembers[#orgmembers + 1] = {
    	        SteamID 	= steamid,
    	        Name    	= name,
    	        Rank    	= rank,
				Weight		= weight
    	    }
    	end

		fr.colLeft = ui.Create('Panel', function(self)
			self:SetWide(w / 3)
			self:Dock(LEFT)
		end, fr)
		
		fr.lblMem = ui.Create('DLabel', function(self)
			self:SetText('Участники: ' .. #orgmembers)
			self:SizeToContents()
			self:Dock(TOP)
		end, fr.colLeft)
		
		fr.listMem = ui.Create('ui_listview', function(self)
			self:Dock(FILL)
		end, fr.colLeft)

		local a = ui.Create('Panel', function(self)
			self:SetWide(256)
			self:DockMargin(5, 0, 5, 0)
			self:Dock(LEFT)
			self:InvalidateParent(true)
		end, fr)
	
		local flag = ui.Create('Panel', function(self)
			self:Dock(TOP)
			self:SetTall(a:GetTall()/3)
		end, a)
		
	
		local title = ui.Create('DLabel', function(self)
			self:SetText("Флаг")
			self:SizeToContents()
			self:Dock(TOP)
		end, flag)

		local flagg = ui.Create('DButton', function(self)
			self:Dock(FILL)
			self.Paint = function(self,w,h)

				--draw.RoundedBox(0,(w-h)*.5,0,h,h,color_white)
				
				surface.SetMaterial(surface.GetWeb(flag_ico))
				surface.SetDrawColor(255,255,255)
				surface.DrawTexturedRect((w-h)*.5,0,h,h)
			end
			self:SetText''
			self.DoClick = function()
				if (!IGS.CanAfford(ply, 250)) then return rp.Notify(ply, 1, 'Вы не можете себе позволить изменение флага!') end

				ui.StringRequest('Изменение флага', 'Введите ID картинки с Imgur.', '', function(resp)
					net.Start("org.setflag")
					net.WriteString(resp)
					net.SendToServer()
				end)
			end
		end, flag)

		fr.colMid = ui.Create('Panel', function(self)
			self:Dock(FILL)
		end, a)
	
		fr.lblRanks = ui.Create('DLabel', function(self)
			self:SetText("Ранги")
			self:SizeToContents()
			self:Dock(TOP)
		end, fr.colMid)
	
		fr.listRank = ui.Create('ui_listview', function(self)
			self:Dock(FILL)
		end, fr.colMid)
			
		--------------------------------------------
		-- Right Column: MOTD, Color
		--------------------------------------------
		fr.colRight = ui.Create('Panel', function(self)
			self:Dock(FILL)
		end, fr)
	
		fr.lblMoTD = ui.Create('DLabel', function(self)
			self:SetText('Информация')
			self:SizeToContents()
			self:Dock(TOP)
		end, fr.colRight)
	
		fr.txtMoTD = ui.Create('ui_scrollpanel', function(self)
			self:Dock(FILL)
			self:SetPadding(3)
	
			self.Paint = function(s, w, h)
				surface.SetDrawColor(200, 200, 200)
				surface.DrawRect(0, 0, w, h)
			end
		end, fr.colRight)

	fr.PopulateMembers = function(tosel)
		table.SortByMember(orgmembers, 'Weight')
		fr.listMem:Reset(true)

		local lastRank = ''
		local cats = {}
		for k, v in ipairs(orgmembers) do
			if (v.Rank != lastRank) then
				cats[#cats+1] = {Name = v.Rank, Members = {}}
				lastRank = v.Rank
			end

			table.insert(cats[#cats].Members, v)
		end

		for k, v in ipairs(cats) do
			fr.listMem:AddSpacer(v.Name)
			table.SortByMember(v.Members, 'Name', true)

			for k, v in ipairs(v.Members) do
				local btn = fr.listMem:AddPlayer(v.Name, v.SteamID)
				btn:SetContentAlignment(4)
				btn:SetTextInset(32, 0)

				btn.Player = v

				if (tosel == v.SteamID) then
					btn:DoClick()
				end
			end
		end
	end
	fr.PopulateMembers()

	fr.ReorderRanks = function()
		local sel = fr.listRank:GetSelected()
		local rank = sel and sel.Rank and sel.Rank.Name or nil

		table.SortByMember(orgranks, 'Weight')

		for k, v in ipairs(orgranks) do
			local k = #orgranks - (k - 1)
			local newWeight = 1 + math.floor(((k - 1) / (#orgranks - 1)) * 99)
			v.Weight = newWeight
		end

		fr.PopulateRanks(rank)
	end
	
	fr.PopulateRanks = function(tosel)
		fr.listRank:Reset(true)

		for k, v in ipairs(orgranks) do
			local btn = fr.listRank:AddRow(v.Name)
			btn.Rank = v
			v.Btn = btn
			v.Number = k

			if (v.Name == tosel) then
				btn:DoClick()
			end
		end

		for k, v in ipairs(fr.listRank:GetChildren()) do
			local x, y = v.x, v.y
			local w, h = v:GetSize()

			v:Dock(NODOCK)
			v:SetPos(x, y)
			v:SetSize(w, h)
		end
	end
	fr.PopulateRanks()

	fr.PopulateMoTD = function()
		fr.txtMoTD:Reset(true)

		local motdRows = string.Wrap('ui.22', motd, w - 30 - fr.colLeft:GetWide() - fr.colMid:GetWide())
		for k, v in pairs(motdRows) do
			local lbl = ui.Create('DLabel', function(self)
				self:SetText(v)
				self:SizeToContents()
				self:SetWide(w - 15 - fr.colLeft:GetWide() - fr.colMid:GetWide())
				self:SetTextColor(rp.col.Black)
				fr.txtMoTD:AddItem(self)
			end)
		end
	end
	fr.PopulateMoTD()
	
	--------------------------------------------
	-- Admin stuff!
	--------------------------------------------
	if (perms.Owner) then
		fr.btnCol = ui.Create('ui_button', function(self)
			self:SetText("Редактировать Цвет")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.overMoTD))
			end
			
			self.DoClick = function(s)
				if (IsValid(fr.colPicker)) then
					local color = fr.colPicker:GetColor()
					if (color != LocalPlayer():GetOrgColor()) then
						RunConsoleCommand('setorgcolor', color.r, color.g, color.b)
					end
						
					fr.colPicker:Remove()
					fr.lblMoTD:SetText('Информация')
					s:SetText('Редактировать Цвет')
				else
					fr.colPicker = ui.Create('DColorMixer', function(col)
						col:SetPos(fr.txtMoTD.x, fr.lblMoTD:GetTall())
						col:SetSize(fr.txtMoTD:GetSize())
						col:SetColor(LocalPlayer():GetOrgColor())
						col:SetAlphaBar(false)
						
						col.OP = col.Paint
						col.Paint = function(s, w, h)
							surface.SetDrawColor(rp.col.Black)
							surface.DrawRect(0, 0, w, h)
							s:OP(w, h)
						end
						
					end, fr.colRight)
					
					fr.lblMoTD:SetText('Выберите новый цвет')
					s:SetText("Сохранить")
				end
			end
		end, fr.colRight)
		
		fr.btnNewRank = ui.Create('ui_button', function(self)
			self:SetText("Новый ранг")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.overRankEdit))
			end
			
			self.DoClick = function(s)
				if (IsValid(fr.overRankNew)) then
					fr.overRankNew:Remove()
					s:SetText("Новый ранг")
				else
					fr.overRankNew = ui.Create('ui_scrollpanel', function(scr)
						scr:SetPos(fr.listRank.x, fr.lblRanks:GetTall())
						scr:SetSize(fr.listRank:GetSize())
						scr.Paint = function(s, w, h)
							surface.SetDrawColor(200, 200, 200)
							surface.DrawRect(0, 0, w, h)
						end
					end, fr.colMid)
					
					local txtName = ui.Create('ui_button', function(txt)
						txt:SetTall(25)
						txt:SetFont('ui.22')
						txt:SetText('Enter Name')
						txt:Dock(TOP)

						txt.DoClick = function(s)
							ui.StringRequest('Название ранга', 'Как бы вы назвали этот ранк?', '', function(resp)
								s:SetText(resp)
							end)
						end

						fr.overRankNew:AddItem(txt)
					end)

					local chkInvite = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Приглашать других игроков")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)

					local chkKick = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Исключать игроков")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)

					local chkRank = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Изменять ранги")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)

					local chkMOTD = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Изменять Информацию")
						chk:SetTextColor(rp.col.Black)
						chk:Dock(TOP)

						fr.overRankNew:AddItem(chk)
					end)
					
					local btnSubmit = ui.Create('ui_button', function(btn)
						btn:SetTall(25)
						btn:SetText("Сохранить")
						btn.TextColor = rp.col.Green
						btn:Dock(TOP)

						btn.DoClick = function(s)
							local name = txtName:GetText()
							local weight = 2
							local invite = chkInvite:GetChecked()
							local kick = chkKick:GetChecked()
							local canrank = chkRank:GetChecked()
							local motd = chkMOTD:GetChecked()
							
							RunConsoleCommand('orgrank', name, tostring(weight), invite and '1' or '0', kick and '1' or '0', canrank and '1' or '0', motd and '1' or '0')
							
							if (#orgranks < 5) then
								orgrankref[name] = orgranks[table.insert(orgranks, {Name = name, Weight = weight, Invite = invite, Kick = kick, Rank = canrank, MoTD = motd})]
							end
							
							fr.btnNewRank:DoClick()
							fr.ReorderRanks()
						end

						fr.overRankNew:AddItem(btn)
					end)

					txtName:DoClick()
					s:SetText("Отмена")
				end
			end
		end, fr.colMid)

		fr.btnEditRank = ui.Create('ui_button', function(self)
			self:SetText("Редактировать ранг")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.overRankNew) or !fr.listRank:GetSelected() or (IsValid(fr.overRankEdit) and fr.overRankEdit:GetAlpha() != 255))
			end
			
			self.DoClick = function(s, ignore)
				if (IsValid(fr.overRankEdit)) then
					if (!ignore) then
						local rank = fr.listRank:GetSelected().Rank

						local invite = fr.overRankEdit.chkInvite:GetChecked()
						local kick = fr.overRankEdit.chkKick:GetChecked()
						local canrank = fr.overRankEdit.chkRank:GetChecked()
						local motd = fr.overRankEdit.chkMOTD:GetChecked()
						
						if (invite != rank.Invite or kick != rank.Kick or canrank != rank.Kick or motd != rank.MoTD) then
							RunConsoleCommand('orgrank', rank.Name, tostring(rank.Weight), invite and '1' or '0', kick and '1' or '0', canrank and '1' or '0', motd and '1' or '0')
							rank.Invite = invite
							rank.Kick = kick
							rank.Rank = canrank
							rank.MoTD = motd
						end
					end
						
					fr.overRankEdit:Remove()
					s:SetText("Редактировать ранг")
					fr.lblRanks:SetText('Ранги')
				else
					local rank = fr.listRank:GetSelected().Rank

					fr.overRankEdit = ui.Create('ui_scrollpanel', function(scr)
						scr:SetPos(fr.listRank.x, fr.listRank.y)
						scr:SetSize(fr.listRank:GetSize())
						scr.Paint = function(s, w, h)
							surface.SetDrawColor(200, 200, 200)
							surface.DrawRect(0, 0, w, h)
						end
						scr.FadeTo = 255
						scr.Think = function(s)
							if (s:GetAlpha() != s.FadeTo) then
								local a = s:GetAlpha()
								local mul = a > s.FadeTo and -1 or 1
								s:SetAlpha(math.Clamp(a + (FrameTime() * mul * 1000), mul == 1 and 0 or s.FadeTo, 255))
							end
						end
					end, fr.colMid)
					
					local btnName = ui.Create('ui_button', function(btn)
						btn:SetText('Переименовывать')
						btn:SetTall(25)
						btn:Dock(TOP)

						btn.DoClick = function(s)
							ui.StringRequest('Переименовывать ранг', 'Что бы вы хотели переименовать ' .. rank.Name .. ' to?', '', function(resp)
								if (!orgrankref[resp]) then
									RunConsoleCommand('orgrank', rank.Name, resp)
									fr.listRank:GetSelected():SetText(resp)
									fr.lblRanks:SetText('Редактирование ' .. resp)

									for k, v in ipairs(orgmembers) do if (v.Rank == rank.Name) then v.Rank = resp end end
									rank.Name = resp
									fr.PopulateMembers()
									fr.PopulateRanks(resp)
								end
							end)
						end

						fr.overRankEdit:AddItem(btn)
					end)
					
					ui.Create('ui_button', function(btn)
						btn:SetText('Установить ниже')
						btn:SetTall(25)
						btn:Dock(TOP)

						btn.DoClick = function(s)
							local m = ui.DermaMenu()

							for k, v in ipairs(orgranks) do
								if (v.Weight == 1 or v.Name == rank.Name) then continue end
								
								m:AddOption(v.Name, function()
									rank.Weight = v.Weight-1
									RunConsoleCommand('orgrank', rank.Name, tostring(v.Weight-1), rank.Invite and '1' or '0', rank.Kick and '1' or '0', rank.Edit and '1' or '0', rank.MoTD and '1' or '0')
									
									fr.ReorderRanks()
								end)
							end

							m:Open()
						end

						fr.overRankEdit:AddItem(btn)
						if (rank.Weight == 1 or rank.Weight == 100) then
							btn:SetMouseInputEnabled(false)
						end
					end)

					fr.overRankEdit.chkInvite = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Приглашать других игроков")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.Invite)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)

					fr.overRankEdit.chkKick = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Исключать игроков")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.Kick)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)

					fr.overRankEdit.chkRank = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Изменять ранги")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.Rank)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)

					fr.overRankEdit.chkMOTD = ui.Create('DCheckBoxLabel', function(chk)
						chk:SetText("Редактировать Информацию")
						chk:SetTextColor(rp.col.Black)
						chk:SetChecked(rank.MoTD)

						fr.overRankEdit:AddItem(chk)
						if (rank.Weight == 100) then chk:SetMouseInputEnabled(false) end
					end)
					
					ui.Create('ui_button', function(btn)
						btn:SetText('Удалить')
						btn:SetTall(25)

						btn.Think = function(s)
							if (s.CoolDown and SysTime() > s.CoolDown + 2) then
								s:SetText("Удалить")
								s.CoolDown = nil;
							end
						end

						btn.DoClick = function(s)
							if (!s.CoolDown) then
								s.CoolDown = SysTime()
								s:SetText("Нажмите снова")
							else
								RunConsoleCommand('orgrankremove', rank.Name)
								fr.listRank:GetSelected():Remove()
								fr.btnEditRank:DoClick(true)

								orgrankref[rank.Name] = nil
								local nextRank
								local rn = rank.Name
								for k, v in ipairs(orgranks) do
									if (v.Name == rank.Name) then
										nextRank = orgranks[k+1]
										table.remove(orgranks, k)
										break
									end
								end
								for k, v in ipairs(orgmembers) do
									if (v.Rank == rn) then
										v.Rank = nextRank.Name
									end
								end
								local sel = fr.listMem:GetSelected()
								fr.PopulateMembers(sel and sel.Player.SteamID or nil)
							end
						end

						btn.TextColor = rp.col.Red

						fr.overRankEdit:AddItem(btn)
						if (rank.Weight == 1 or rank.Weight == 100) then
							btn:SetMouseInputEnabled(false)
						end
					end)

					fr.lblRanks:SetText('Редактирование ' .. rank.Name)
					fr.lblRanks:SizeToContents()
					s:SetText("Назад")
				end
			end
		end, fr.colMid)

	end

	if (perms.MoTD) then
		fr.btnMoTD = ui.Create('ui_button', function(self)
			self:SetText("Редактировать Информацию")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.colPicker))
			end

			self.DoClick = function(s)
				if (IsValid(fr.overMoTD)) then
					local newMoTD = fr.overMoTD:GetValue()
					fr.overMoTD:Remove()

					if (newMoTD != motd) then
						net.Start('rp.SetOrgMoTD')
							net.WriteString(newMoTD)
						net.SendToServer()

						motd = newMoTD
						fr.PopulateMoTD()
					end
					
					s:SetText("Редактировать Информацию")
				else
					fr.overMoTD = ui.Create('DTextEntry', function(txt)
						txt:SetPos(fr.txtMoTD.x, fr.lblMoTD:GetTall())
						txt:SetSize(fr.txtMoTD:GetSize())
						txt:SetMultiline(true)
						txt:SetValue(motd)
						txt:SetFont('ui.22')
						txt:RequestFocus()
					end, fr.colRight)

					s:SetText("Сохранить")
				end
			end
		end, fr.colRight)
	end

	if (perms.Invite) then
		fr.btnInv = ui.Create('ui_button', function(self)
			self:SetText("Пригласить игроков")
			self:SetTall(25)
			self:DockMargin(0, 5, 0, 0)
			self:Dock(BOTTOM)

			self.Think = function(s)
				s:SetDisabled(IsValid(fr.overMem))
			end

			self.DoClick = function(s)
				if (IsValid(fr.overMemInv)) then
					fr.overMemInv:Remove()
					s:SetText("Пригласить игроков")
				else
					fr.overMemInv = ui.Create('ui_playerrequest', function(scr)
						scr:SetPos(fr.listMem.x, fr.lblMem:GetTall())
						scr:SetSize(fr.listMem:GetSize())

						scr:SetPlayers(table.Filter(player.GetAll(), function(v)
							return (not v:GetOrg())
						end))

						scr.OnSelection = function(self, row, pl)
							RunConsoleCommand('orginvite', pl:SteamID64())

							row:Remove()
						end

						scr.Paint = function(scr, w, h)
							surface.SetDrawColor(0, 0, 0)
							surface.DrawRect(0, 0, w, h)
							derma.SkinHook('Paint', 'Frame', self, w, h)
						end
					end, fr.colLeft)

					s:SetText("Назад")
				end
			end
		end, fr.colLeft)
	end

	if (perms.Kick) then
		if (perms.Rank) then
			fr.btnEdit = ui.Create('ui_button', function(self)
				self:SetText("Редактировать игрока")
				self:SetTall(25)
				self:DockMargin(0, 5, 0, 0)
				self:Dock(BOTTOM)

				self.Think = function(s)
					local sel = fr.listMem:GetSelected()

					if (IsValid(fr.overMemInv) or !IsValid(sel) or !sel.Player or sel.Player.SteamID == LocalPlayer():SteamID64() or sel.Player.Weight >= perms.Weight) then
						s:SetDisabled(true)
					else
						s:SetDisabled(false)
					end
				end

				self.DoClick = function(s)
					if (IsValid(fr.overMem)) then
						fr.overMem:Remove()
						s:SetText("Редактировать игрока")
					else
						local sel = fr.listMem:GetSelected()

						fr.overMem = ui.Create('ui_listview', function(scr)
							scr:SetPadding(-1)
							scr:SetPos(fr.listMem.x, fr.lblMem:GetTall())
							scr:SetSize(fr.listMem:GetSize())

							scr.Paint = function(s, w, h)
								surface.SetDrawColor(200, 200, 200)
								surface.DrawRect(0, 0, w, h)
							end

							scr:AddSpacer(sel.Player.Name)

							if (!sel.Player) then return end

							scr.btnKick = ui.Create('ui_button', function(btn)
								btn:SetText("Исключить игрока")
								btn.TextColor = rp.col.Red
								btn:SetTall(25)
								scr:AddItem(btn)

								btn.Think = function(s)
									if (s.CoolDown) then
										if (SysTime() > s.CoolDown + 2) then
											s:SetText("Исключить игрока")
											s.CoolDown = nil
										end
									end
								end

								btn.DoClick = function(s)
									if (!s.CoolDown) then
										s.CoolDown = SysTime()
										s:SetText("Нажмите еще раз, чтобы подтвердить")
									else
										RunConsoleCommand('orgkick', sel.Player.SteamID)
										fr.btnEdit:DoClick()

										sel:Remove()
									end
								end
							end)
							
							scr.btnRank = ui.Create('ui_button', function(btn)
								btn:SetText("Изменить ранг")
								btn:SetTall(25)
								scr:AddItem(btn)

								btn.DoClick = function(s)
									local m = ui.DermaMenu()

									local num = 0
									for k, v in ipairs(orgranks) do
										if (v.Weight < perms.Weight and v.Name != sel.Player.Rank) then
											num = num + 1
											m:AddOption(v.Name, function()
												RunConsoleCommand('orgsetrank', sel.Player.SteamID, v.Name)
												sel.Player.Rank = v.Name
												sel.Player.Weight = v.Weight
												fr.PopulateMembers(sel.Player.SteamID)
												sel = fr.listMem:GetSelected()
											end)
										end
									end

									if (num >= 1) then
										m:Open()
									else
										m:Remove()
									end
								end
							end)		
						end, fr.colLeft)

						s:SetText("Назад")
					end
				end
			end, fr.colLeft)
		else
			fr.btnKick = ui.Create('ui_button', function(self)
				self:SetText("Исключить игрока")
				self:SetTall(25)
				self:DockMargin(0, 5, 0, 0)
				self:Dock(BOTTOM)
				self.TextColor = rp.col.Red

				self.Think = function(s)
					local sel = fr.listMem:GetSelected()

					if (IsValid(fr.overMemInv) or !IsValid(sel) or !sel.Player or sel.Player.SteamID == LocalPlayer():SteamID64() or sel.Player.Weight >= perms.Weight) then
						s:SetDisabled(true)
					else
						s:SetDisabled(false)
					end

					if (s.CoolDown) then
						if (SysTime() > s.CoolDown + 2) then
							s:SetText("Исключить игрока")
							s.CoolDown = nil
						end
					end
				end

				self.DoClick = function(s)
					if (!s.CoolDown) then
						s.CoolDown = SysTime()
						s:SetText("Нажмите еще раз, чтобы подтвердить")
					else
						local sel = fr.listMem:GetSelected()
						RunConsoleCommand('orgkick', sel.Player.SteamID)
						
						sel:Remove()
						s.CoolDown = 0
					end
				end
			end, fr.colLeft)
		end
	end
	end)
end

function PANEL:AddControls( pnl )
	local perms = self.perms

	pnl.btnQuit = ui.Create('ui_button', function(self)
		self:SetText(perms.Owner and 'Распустить' or 'Выйти')
		self:SizeToContents()
		self:SetSize(self:GetWide() + 40, pnl.btnClose:GetTall())
		self:SetPos(pnl.btnClose.x - self:GetWide() + 1, 0)
		
		self.DoClick = function(s)
			local str = perms.Owner and 'Распустить организацию?' or 'Выйти из организации?'
			local str2 = perms.Owner and 'Вы уверены, что хотите распустить ' .. LocalPlayer():GetOrg() .. '? Напишите YES в поле ниже.' or 'Вы уверены, что хотите выйти ' .. LocalPlayer():GetOrg() .. '? Напишите YES в поле ниже.'
			
			ui.StringRequest(str, str2, '', function(resp)
				local ismatch = (perms.Owner and resp:lower() == 'yes') or (!perms.Owner and resp:lower() == 'yes')

				if (ismatch) then
					pnl:Close()
					RunConsoleCommand('quitorg')
				end
			end)
		end
	end, pnl)

	self.quitt = pnl.btnQuit
end

function PANEL:HideControls(  pnl )
	self.quitt:Remove()
end

vgui.Register('rp_org_panel', PANEL)
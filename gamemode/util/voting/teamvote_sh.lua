if (SERVER) then
	util.AddNetworkString 'rp.TeamVote'
	util.AddNetworkString 'rp.TeamVoteCountdown'
	util.AddNetworkString 'rp.TeamVoteVoted'

	rp.teamVote = {
		Votes = {}
	}

	function rp.teamVote.Create(name, duration, choices, callback)
		local opts = {}
		for k, v in ipairs(choices) do
			if (IsValid(v)) then
				opts[#opts + 1] = v
			end
		end

		if (#opts == 1) then
			callback(opts[1], {[opts[1]] = 1})
			return
		end

		local data = util.Compress(pon.encode(opts))
		local size = #data
		local recipients = table.Filter(player.GetAll(), function(v)
			return !table.HasValue(choices, v)
		end)

		net.Start('rp.TeamVote')
			net.WriteString(name)
			net.WriteUInt(CurTime() + duration, 32)
			net.WriteUInt(size, 16)
			net.WriteData(data, size)
		net.Send(recipients)

		local vote = {
			StartTime = CurTime(),
			Duration = duration,
			Choices = choices,
			Voters = recipients,
			Votes = {},
			Callback = callback
		}

		rp.teamVote.Votes[name] = vote

		hook('Tick', 'rp.TeamVote', rp.teamVote.Tick)
	end

	function rp.teamVote.CountDown(name, duration, callback)
		net.Start('rp.TeamVoteCountdown')
			net.WriteString(name)
			net.WriteFloat(CurTime() + duration)
		net.Broadcast()

		timer.Create('rp.TeamVote.' .. name, duration, 1, callback)
	end
	
	function rp.teamVote.Tick()
		local count = 0

		for k, v in pairs(rp.teamVote.Votes) do
			local shouldFinish = CurTime() > v.StartTime + v.Duration

			if (shouldFinish) then
				local winner
				local winnervotes = 0

				for k, v in pairs(v.Votes) do
					if (IsValid(k) and v > winnervotes) then
						winner = k
						winnervotes = v
					end
				end

				v.Callback(winner, v.Votes)

				rp.teamVote.Votes[k] = nil
				return
			end

			count = count + 1
		end

		if (count == 0) then
			hook.Remove('Tick', 'rp.TeamVote')
			return
		end
	end
	
	net('rp.TeamVote', function(len, pl)
		local votename = net.ReadString()
		local votechoice = player.Find(net.ReadString())

		if (!IsValid(votechoice)) then return end

		local vote = rp.teamVote.Votes[votename]

		if (!vote) then return end

		for k, v in ipairs(vote.Voters) do
			if (IsValid(v) and v == pl) then
				table.remove(vote.Voters, k)

				net.Start 'rp.TeamVoteVoted'
					net.WritePlayer(votechoice)
				net.Broadcast()

				vote.Votes[votechoice] = (vote.Votes[votechoice] or 0) + 1
			end
		end
	end)

	return
end

local cdframes = {}
local votevalues = {}
local totalvotes = 0
local hasvoted = false
local function createTeamVoteWindow(votename, endtime, options)
	if (IsValid(cdframes[votename])) then cdframes[votename]:Remove() end

	options = table.Filter(options, IsValid)

	votevalues = {}
	totalvotes = 0
	hasvoted = false

	local fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Выборы ' .. votename)
		self:SetSize(300, math.min(34 + #options * 30), 159)
		self:SetPos(ScrW() - 300, ScrH() - self:GetTall())

		self.OT = self.Think
		self.Think = function(self)
			self:OT()

			if (SysTime() > endtime and !self.Closing) then
				self.Closing = true
				self:Close()
			end
		end
	end)

	local scr = ui.Create('ui_listview', function(self)
		self:DockMargin(0, 3, 0, 0)
		self:Dock(FILL)
	end, fr)

	for k, v in ipairs(options) do
		votevalues[v] = 0
		local stid = v:SteamID()

		local b = scr:AddPlayer(v)
		b.DoClick = function(self)
			if hasvoted then return end
			hasvoted = true
			chat.AddText(rp.col.White, 'Вы проголосовали за ' .. v:Name() .. '.')

			net.Start('rp.TeamVote')
				net.WriteString(votename)
				net.WriteString(stid)
			net.SendToServer()
		end
		b.PaintOver = function(self, w, h)
			draw.Box(w - 40, 1, 39, h - 2, ui.col.Black)
			draw.SimpleText(((totalvotes == 0) and '0%' or (math.Clamp(math.Round(votevalues[v]/totalvotes * 100, 0), 0, 100) .. '%')), 'ui.20', w - 20, h * .5, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	fr:InvalidateLayout(true)
end

local col = Color()
local cred = Color(240, 0, 0)
local cgreen = Color(50, 200, 50)
local function createTeamVoteCountdown(votename, endtime)
	local fr = ui.Create('ui_frame', function(self)
		self:SetTitle('')
		self:SetSize(300, 59)
		self:SetPos(ScrW() - 300, ScrH() - 59)
	end)

	local pnl = ui.Create('panel', function(self)
		self:DockMargin(0, 3, 0, 0)
		self:Dock(FILL)
		self.EndTime = endtime
		self.StartTime = SysTime()

		self.Paint = function(self, w, h)
			local diff = math.Clamp(self.EndTime - SysTime(), 0, math.huge)
			local prog = math.Clamp((SysTime() - self.StartTime) / (self.EndTime - self.StartTime), 0, 1)

			fr:SetTitle('Выборы Мэра через ' .. math.ceil(diff) .. 'с')

			col:Lerp(prog, cgreen, cred)
			surface.SetDrawColor(col)
			surface.DrawRect(1, 1, (w - 2) - prog * (w - 2), h - 2)

			surface.SetDrawColor(rp.col.Outline)
			surface.DrawOutlinedRect(0, 0, w - prog * w, h)

			if (diff == 0) then
				fr:Close()
				self.Paint = function() end
			end
		end
	end, fr)

	cdframes[votename] = fr
end

net('rp.TeamVoteVoted', function()
	local pl = net.ReadPlayer()
	votevalues[pl] = (votevalues[pl] or 0) + 1
	totalvotes = totalvotes + 1
end)

net('rp.TeamVoteCountdown', function(len)
	local team = net.ReadString()
	local endtime = SysTime() + (net.ReadFloat() - CurTime())

	createTeamVoteCountdown(team, endtime)
end)

net('rp.TeamVote', function(len)
	local team = net.ReadString()
	local endtime = SysTime() + (net.ReadUInt(32) - CurTime())
	local size = net.ReadUInt(16)
	local data = net.ReadData(size)

	local options = pon.decode(util.Decompress(data))
	createTeamVoteWindow(team, endtime, options)
end)
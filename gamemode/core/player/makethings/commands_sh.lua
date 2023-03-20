-----------------------------------------------------------
-- TOGGLE COMMANDS --
-----------------------------------------------------------
function GM:AddTeamCommands(CTeam, max)
	if CLIENT then return end

	if not self:CustomObjFitsMap(CTeam) then return end
	local k = 0
	for num,v in pairs(rp.teams) do
		if v.command == CTeam.command then
			k = num
		end
	end

	if CTeam.vote then
		rp.AddCommand(CTeam.command, function(ply)
			-- Force job if he's the only player

			if (player.GetCount() == 1) then
				rp.Notify(ply, NOTIFY_SUCCESS, 'Вы выиграли голосование так как вы один на сервере.')
				ply:ChangeTeam(k)
				return
			end

			-- Banned from job
			if (!ply:ChangeAllowed(k)) then
				rp.Notify(ply, NOTIFY_ERROR, 'В настоящее время эта работа недоступна для вас.')
				return
			end

			-- Voted too recently
			if (ply:GetTable().LastVoteTime and CurTime() - ply:GetTable().LastVoteTime < 80) then
				rp.Notify(ply, NOTIFY_ERROR, 'Пожалуйста, подождите # секунд чтобы начать голосование.', math.ceil(80 - (CurTime() - ply:GetTable().LastVoteTime)))
				return
			end

			-- Can't vote to become what you already are
			if (ply:Team() == k) then
				rp.Notify(ply, NOTIFY_GENERIC, 'Вы уже на этой работе!')
				return
			end

			-- Max players reached
			local max = CTeam.max
			if (max ~= 0 and ((max % 1 == 0 and team.NumPlayers(k) >= max) or (max % 1 ~= 0 and (team.NumPlayers(k) + 1) / player.GetCount() > max))) then
				rp.Notify(ply, NOTIFY_ERROR, 'Лимит исчерпан.')
				return
			end

			if (CTeam.CurVote) then
				if (!CTeam.CurVote.InProgress) then
					table.insert(CTeam.CurVote.Players, ply)
					rp.Notify(ply, NOTIFY_SUCCESS, 'Вы зарегистрированы на предстоящие выборы!')
				else
					rp.Notify(ply, NOTIFY_ERROR, 'Выборы уже начались. Вы опоздали!')
					return
				end
			else -- Setup a new vote
				CTeam.CurVote = {
					InProgress = false,
					Players = {ply}
				}

				rp.teamVote.CountDown(CTeam.name, 45, function()
					CTeam.CurVote.InProgress = true

					rp.teamVote.Create(CTeam.name, 45, CTeam.CurVote.Players, function(winner, breakdown)
						if IsValid(winner) then
							winner:ChangeTeam(k)
						end

						CTeam.CurVote = nil
					end)
				end)

				rp.Notify(ply, NOTIFY_SUCCESS, 'Вы зарегистрированы на предстоящие выборы!')
			end

			ply:GetTable().LastVoteTime = CurTime()
			return
		end)
	else
		rp.AddCommand(CTeam.command, function(ply)
			ply:ChangeTeam(k)
		end)
	end
end

function GM:AddEntityCommands(tblEnt)
	if CLIENT then return end

	local function buythis(ply)
		if ply:IsArrested() then return end

		if (tblEnt.allowed[ply:Team()] ~= true) then
			rp.Notify(ply, NOTIFY_ERROR, 'Неправильная работа для этого!')
			return
		end

		if tblEnt.customCheck and not tblEnt.customCheck(ply) then
			rp.Notify(ply, NOTIFY_ERROR, 'Вы не допущены к покупке этого предмета.')
			return
		end

		local max = tonumber(tblEnt.max or 3)

		if ply:GetCount(tblEnt.ent) >= tonumber(max) then
			rp.Notify(ply, NOTIFY_ERROR, 'Вы достигли # лимит.', tblEnt.name)
			return
		end

		if not ply:CanAfford(tblEnt.price) then
			rp.Notify(ply, NOTIFY_ERROR, 'Вы не можете позволить себе это!')
			return
		end
		ply:AddMoney(-tblEnt.price, 'Покупка ' .. tblEnt.name)

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local tr = util.TraceLine(trace)
		local item = ents.Create(tblEnt.ent)
		item:SetPos(tr.HitPos)
		item.allowed = tblEnt.allowed
		item.ItemOwner = ply
		item:Spawn()
		item:PhysWake()

		timer.Simple(0, function()
			if item.Setowning_ent then
				item:Setowning_ent(ply)
			end

			if (tblEnt.onSpawn) then tblEnt.onSpawn(item, ply) end
		end)

		ply:_AddCount(tblEnt.ent, item)

		rp.Notify(ply, NOTIFY_SUCCESS, 'Вы купили #/# # за #.', ply:GetCount(tblEnt.ent), max, tblEnt.name, rp.FormatMoney(tblEnt.price))

		hook.Call('PlayerBoughtItem', GAMEMODE, ply, tblEnt.name, tblEnt.price, ply:GetMoney(), item)

		ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_PLACE)

		return
	end
	rp.AddCommand(tblEnt.cmd:gsub('/', ''), buythis)
end

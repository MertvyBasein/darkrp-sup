ENT.Type 		= 'anim'
ENT.Base		= 'base_rp'
ENT.Spawnable	= false
ENT.MediaPlayer = true
ENT.NetworkPlayerUse = true

function ENT:SetupDataTables()
	self:NetworkVar('String', 0, 'URL')
	self:NetworkVar('String', 1, 'Title')
	self:NetworkVar('Int', 0, 'Start')
	self:NetworkVar('Int', 1, 'Time')
	self:NetworkVar('Int', 2, 'Frozen')
	self:NetworkVar('Int', 3, 'Paused')
	self:NetworkVar('Int', 4, 'Looping')
end

function ENT:IsFrozen()
	return (self:GetFrozen() == 1)
end


function ENT:IsPaused()
	return (self:GetPaused() == 1)
end


function ENT:IsLooping()
	return (self:GetLooping() == 1)
end
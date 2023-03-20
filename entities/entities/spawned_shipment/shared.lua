ENT.Type 		= 'anim'
ENT.Base 		= 'base_rp'
ENT.PrintName 	= 'Shipment'
ENT.Category 	= 'RP'
ENT.Spawnable 	= false

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'contents')
	self:NetworkVar('Int', 1, 'count')
	self:NetworkVar('Entity', 1, 'gunModel')
end

rp.inv.Wl['spawned_shipment'] = 'Коробка'
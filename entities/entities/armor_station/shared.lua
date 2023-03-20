ENT.Type 		= 'anim'
ENT.Base 		= 'base_rp'
ENT.PrintName 	= 'Броня Станция'
ENT.Author 		= ''
ENT.Spawnable 	= false
ENT.PressKeyText = 'Чтобы купить броню'

ENT.MinPrice = 1
ENT.MaxPrice = 200

function ENT:SetupDataTables()
	self:NetworkVar('Int',0,'price')
	self:NetworkVar('Entity',1,'owning_ent')
end
AddCSLuaFile()

ENT.Base		= 'media_base'
ENT.PrintName	= 'TV'
ENT.Category 	= 'RP Media'
ENT.Spawnable	= true

ENT.Model 		= 'models/props/cs_office/TV_plasma.mdl'

if (CLIENT) then
	local vec = Vector(6,0,19)
	local ang = Angle(0,90,90)
	function ENT:Draw()
		self:DrawModel()
		cam.Start3D2D(self:LocalToWorld(vec), self:LocalToWorldAngles(ang), 0.065)
			self:DrawScreen(-860 * .5, -256, 860, 512)
		cam.End3D2D()
	end
end
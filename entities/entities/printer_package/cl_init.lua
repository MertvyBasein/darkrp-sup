include('shared.lua')
surface.CreateFont( "DermaAristantow[-1]", {
	font = "Roboto", 
	extended = false,
	size = 196,
	weight = 300,
	blursize = 1,
	scanlines = 0,
	antialias = true,
	outline = true,
} )


local font = "DermaAristantow[-1]"
local size = 0.025
function ENT:Draw()
	self:DrawModel()
	local eye = LocalPlayer():EyeAngles()
	local Pos = self:LocalToWorld( self:OBBCenter() )+Vector( 0, 0, 50 )
	local Ang = Angle( 0, eye.y - 90, 90 )
	if self:GetPos():Distance( LocalPlayer():GetPos() ) > 500 then return end

	cam.Start3D2D(Pos + Vector( 0, 0, math.sin( CurTime() ) * 2 ), Ang, 0.2)
		draw.SimpleTextOutlined("Ящик с принтером","mfire30",0,-20,Color(0,157,255),TEXT_ALIGN_CENTER,0,1.5,Color(0, 0, 0, 255) )
		draw.SimpleTextOutlined("Нажми на 'Е' чтобы открыть!","mfire20",0,25,Color(220,220,220),TEXT_ALIGN_CENTER,0,1,Color(0, 0, 0, 255) )
	cam.End3D2D()
end



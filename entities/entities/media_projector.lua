
 AddCSLuaFile() 
 ENT.Base='media_base' 
 ENT.PrintName='Projector' 
 ENT.Category='RP Media' 
 ENT.Spawnable=true 
 ENT.MediaPlayer=true 
 ENT.Model='models/hunter/plates/plate4x8.mdl' 

 local col = Color(10,10,10)  
 function ENT:Initialize()  
    self:SetMaterial('models/debug/debugwhite') 
    self:SetColor(col) 
    self.BaseClass.Initialize(self) 
end  
    function ENT:CanUse(pl)
        return (pl:Team() == TEAM_KINE)
    end

if (CLIENT) then  

    local vec = Vector(-55,-118.7,1.8) 
    local ags = Angle(0,90,0)  

    function ENT:Draw()  
        self:DrawModel() 
        cam.Start3D2D(self:LocalToWorld(vec),self:LocalToWorldAngles(ags),0.074) 
        self:DrawScreen( - 960, - 540,5140,2565) 
        cam.End3D2D() 
    end 
end
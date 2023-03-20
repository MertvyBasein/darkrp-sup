include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang.y = LocalPlayer():EyeAngles().y - 90

	pos = pos + ang:Up()*3 + ang:Right()*-25

	cam.Start3D2D(pos, ang, 0.04)
		draw.NPCTitle('Охота за головами', 'Цели заказанные шерифом округа', 0, 0, texture.Get('NPCEmployer'))
	cam.End3D2D()
end

--local main
net.Receive('headhunter::menu', function()
	if IsValid(main) then return end
	local tb = net.ReadTable()

	main = vgui.Create('XPFrame')
	main:SetSize(500,350)
	main:Center()
	main:MakePopup()
	main:SetTitle('Охота за головами')

	local hunts = vgui.Create('DIconLayout', main) -- не думаю что цели займут больше чем весь фрейм
	hunts:Dock(FILL)
	hunts:DockMargin(7, 7, 7, 7)
	hunts:SetSpaceX(6)
	hunts:SetSpaceY(6)
	hunts:InvalidateParent(true)
	local w, h = hunts:GetSize()

	for k,v in pairs(tb) do
		if !IsValid(k) then continue end
		local hunt = vgui.Create('EditablePanel', hunts)
		hunt:SetSize(w/4-4, h/2-4)
		hunt.Paint = function(self,w,h)
			draw.RoundedBox(6,0,0,w,h,Color(0,0,0,130))

			self:SetCursor('hand')
		end

		local model = vgui.Create('DModelPanel', hunt)
		model:Dock(TOP)
		model:SetTall(hunt:GetTall()/1.3)
		model:SetModel('models/adi/banditos/male_02.mdl')
    	local eyepos = model.Entity:GetBonePosition(model.Entity:LookupBone("ValveBiped.Bip01_Head1") or 0)
    	model:SetLookAt(eyepos+Vector(-1,0,0))
    	model:SetFOV(17)
    	model:SetMouseInputEnabled(false)

    	model.LayoutEntity = function() return end

    	local n = vgui.Create('EditablePanel', hunt)
    	n:Dock(FILL)
    	n:SetMouseInputEnabled(false)
    	n.Paint = function(self,w,h)
			draw.RoundedBoxEx(6,0,0,w,h,Color(0,0,0,130), false, false, true, true)
			if !IsValid(k) then return end
			draw.SimpleText(k:Name(), 'xpgui_tiny', w/2, 3, LocalPlayer():GetJobColor(),1)
			draw.SimpleText(rp.FormatMoney(v), 'xpgui_tiny2', w/2, 16, Color(0,200,0),1)
		end
	end
end)
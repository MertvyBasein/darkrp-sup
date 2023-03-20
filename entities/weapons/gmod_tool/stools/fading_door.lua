local ent = FindMetaTable("Entity")

function PP_GhostProp(prop)
	if prop:IsVehicle() then return false end
	if prop:IsPlayer() then return false end

	prop:SetCollisionGroup( COLLISION_GROUP_WORLD )
	if not prop.ghosted then
		prop.old_color = prop:GetColor()
	end
	prop:SetColor( Color(0,0,0,200) )
	prop.ghosted = true
	prop:SetRenderMode( RENDERMODE_TRANSALPHA  )
end

function PP_UnGhostProp(ply,prop,printn)
	if prop:IsVehicle() then return false end
	if prop:GetClass() ~= "gmt_instrument_piano" then
		for k, v in pairs(ents.FindInSphere(prop:LocalToWorld(prop:OBBCenter()), prop:BoundingRadius())) do
			if v:IsPlayer() and not v:InVehicle() and not tobool(v:GetObserverMode()) or v:IsVehicle() then
				if prop:NearestPoint(v:NearestPoint(prop:GetPos())):DistToSqr(v:NearestPoint(prop:GetPos())) <= 400 then
					if printn then
				  		rp.Notify(ply, 1, "Ты не можешь заморозить проп рядом с машиной/игроком")
				  	end
				  	PP_GhostProp(prop)
				  	return false
				end
			end
		end
	end

	prop:SetColor( Color(255,255,255) )
	prop:SetRenderMode( RENDERMODE_NORMAL  )
	prop:SetCollisionGroup( COLLISION_GROUP_NONE )
	if prop.old_color then
		prop:SetColor(prop.old_color)
	end
	prop.ghosted = false
end

function ent:Fade()
	self.Faded = true
	self.FadedMaterial = self:GetMaterial()
	self.FadedColor = self:GetColor()
	self.fCollision = self:GetCollisionGroup()

	self:SetMaterial("phoenix_storms/stripes")
	self:SetColor( Color(255,0,0,150) )
	self:SetRenderMode( RENDERMODE_TRANSALPHA  )
	self:DrawShadow(false)
	self:SetNotSolid(true)

	local obj = self:GetPhysicsObject()
	if (IsValid(obj)) then
		obj:EnableMotion(false)
	end
end


function ent:UnFade()
	if (!self:IsValid()) then return end
	self.Faded = nil

	self:SetMaterial(self.FadedMaterial or "")
	self:SetColor(self.FadedColor or Color(255,255,255,255))
	self:DrawShadow(true)

	if timer.Exists("FadingDoorUnFade_"..self:EntIndex()) then timer.Remove("FadingDoorUnFade_"..self:EntIndex()) end

	local obj = self:GetPhysicsObject()
	if (IsValid(obj)) then
		obj:EnableMotion(false)
	end

	local gh = false

	for k, v in pairs(ents.FindInSphere(self:LocalToWorld(self:OBBCenter()), self:BoundingRadius())) do
		if v:IsPlayer() and not v:InVehicle() and not tobool(v:GetObserverMode()) or v:IsVehicle() then
			if self:NearestPoint(v:NearestPoint(self:GetPos())):Distance(v:NearestPoint(self:GetPos())) <= 20 then
			  	gh = true
			end
		end
	end

	if gh then
		PP_GhostProp(self)

		local ind = self:EntIndex()
		timer.Create("FadingDoorAutounghost_".. ind, 3, 0, function()
			if not IsValid(self) then
				timer.Remove("FadingDoorAutounghost_".. ind)
				return
			end

			local can_unghost = true
			for k, v in pairs(ents.FindInSphere(self:LocalToWorld(self:OBBCenter()), self:BoundingRadius())) do
				if v:IsPlayer() and not v:InVehicle() and not tobool(v:GetObserverMode()) or v:IsVehicle() then
					if self:NearestPoint(v:NearestPoint(self:GetPos())):Distance(v:NearestPoint(self:GetPos())) <= 20 then
						can_unghost = false
					end
				end
			end

			if not can_unghost then return end

			PP_UnGhostProp(nil, self, false)
			timer.Remove("FadingDoorAutounghost_".. ind)
		end)
	else
		PP_UnGhostProp(nil, self, false)
	end
	self:SetNotSolid(false)
end


function ent:MakeFadingDoor(pl, key, inversed, toggleactive)
	if self:GetClass() == "ent_textscreen" or self:GetClass() == 'sammyservers_textscreen' then return false end

	local makeundo = true
	if (self.FadingDoor) then
		self:UnFade()
		numpad.Remove(self.NumpadFadeUp)
		numpad.Remove(self.NumpadFadeDown)
		makeundo = false
	end

	// FD Counting temp
	if not self.FadingDoor then
		//if not pl._Counts then
		//	pl._Counts = {}
		//end

		//pl._Counts["fading_doors"] = (pl._Counts["fading_doors"] or 0) + 1

		self:CallOnRemove("RemoveCount_fd", function(ent)
			//if IsValid(pl) and pl._Counts then
			//	pl._Counts["fading_doors"] = pl._Counts["fading_doors"] - 1
			//end

			numpad.Remove(ent.NumpadFadeUp)
			numpad.Remove(ent.NumpadFadeDown)
		end)
	end

	self.FadeKey = key
	self.FadingDoor = true
	self:SetNWBool("IsFadingDoor", true)
	self.FadeCoowners = {}
	self.FadeTeams = {}
	self.FadeInversed = inversed
	self.FadeToggle = toggleactive

	self.NumpadFadeUp = numpad.OnUp(pl, key, "FadeDoor", self, false)
	self.NumpadFadeDown = numpad.OnDown(pl, key, "FadeDoor", self, true)

	if (inversed) then self:Fade() end
	return makeundo
end

-- Utility Functions
local function ValidTrace(tr)
	return ((tr.Entity) and (tr.Entity:IsValid())) and !((tr.Entity:IsPlayer()) or (tr.Entity:IsNPC()) or (tr.Entity:IsVehicle()) or (tr.HitWorld))
end

local function ChangeState(pl, ent, state)
	if !(ent:IsValid()) then return end

	if ent.fd_block and ent.fd_block > CurTime() then
		if IsValid(pl) and state then rp.Notify(pl, 1, "Сразу после взлома Fading Door-a его нельзя включить!") end
		return
	end

	if (ent.FadeToggle) then
		if (state == false) then return end
		if (ent.Faded) then ent:UnFade() else ent:Fade() end
		return
	end

	if ((ent.FadeInversed) and (state == false)) or ((!ent.FadeInversed) and (state == true)) then
		ent:Fade()
	else
		ent:UnFade()
	end
end
if (SERVER) then numpad.Register("FadeDoor", ChangeState) end

TOOL.Category	= "Основное"
TOOL.Name		= "Скрывающиеся дверь"
TOOL.Stage = 1

TOOL.ClientConVar["key"] = "5"
TOOL.ClientConVar["toggle"] = "0"
TOOL.ClientConVar["reversed"] = "0"
TOOL.ClientConVar["length"] = "0"

if (CLIENT) then
	language.Add("Tool.fading_door.name", "Fading Door")
	language.Add("Tool.fading_door.desc", "Создает Fading door на пропах.")
	language.Add("Tool_fading_door_desc", "Создает Fading door на пропах.")
	language.Add("Tool.fading_door.0", "Левый клик - создать Fading Door. Правый клик - настроить доступ к двери")
	language.Add("Undone_fading_door", "Undone Fading Door")

	function TOOL:BuildCPanel()
		self:AddControl("Header",   {Text = "#Tool_fading_door_name", Description = "#Tool_fading_door_desc"})
		self:AddControl("CheckBox", {Label = "Reversed (Starts invisible, becomes solid)", Command = "fading_door_reversed"})
		self:AddControl("CheckBox", {Label = "Toggle Active", Command = "fading_door_toggle"})
		self:AddControl("Numpad",   {Label = "Button", ButtonSize = "22", Command = "fading_door_key"})

		self:AddControl( "Slider", {	Label 	= "Hold Length",
									Type	= "Float",
									Min		= "4",
									Max		= "10",
									Command	= "fading_door_length" } )
	end

	TOOL.LeftClick = ValidTrace
	return
end

function TOOL:LeftClick(tr)
	if ( !self:GetWeapon():CheckLimit( "fading_doors" ) ) then return false end

	if (!ValidTrace(tr)) then return false end
	if !IsValid(tr.Entity) then return false end

	local ent = tr.Entity
	if ent:GetClass() == "ent_textscreen" or ent:GetClass() == 'sammyservers_textscreen' then return false end
	local pl = self:GetOwner()
	if (ent:MakeFadingDoor(pl, self:GetClientNumber("key"), self:GetClientNumber("reversed") == 1, self:GetClientNumber("toggle") == 1)) then
		self.key = self:GetClientNumber("key")
		self.key2 = -1
		undo.Create("fading_door")
			undo.AddFunction(function()
				numpad.Remove(ent.NumpadFadeUp)
				numpad.Remove(ent.NumpadFadeDown)
				if IsValid(ent) then
					ent:UnFade()
					ent.FadingDoor = nil
					ent:SetNWBool("IsFadingDoor", false)
					ent:RemoveCallOnRemove( "RemoveCount_fd" )
				end
				//if pl._Counts and pl._Counts["fading_doors"] then
				//	pl._Counts["fading_doors"] = pl._Counts["fading_doors"] - 1
				//end
			end)
			undo.SetPlayer(pl)
		undo.Finish()
	end
	rp.Notify(pl, 3, "Вы создали Fading Door")
	return true
end

function TOOL:RightClick(tr)
	if (!ValidTrace(tr)) then return false end
	if !IsValid(tr.Entity) then return false end

	local ent = tr.Entity
	if not ent.FadingDoor then return end

	local pl = self:GetOwner()
	net.Start("rp.OpenFadingDoorMenu")
		net.WriteEntity(ent)
	net.Send(pl)
	return true
end

plib.IncludeCL('cl_init.lua')
plib.IncludeSH('shared.lua')
plib.IncludeSV('commands.lua')

function ENT:Initialize()
	self.Destructed = false

	self:SetModel('models/Items/item_item_crate.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self.locked = false
	self.MaxHealth = 100
	
	self:PhysWake()

	self:SetTrigger(true)
end

function ENT:OnTakeDamage(dmg)
	self.MaxHealth = self.MaxHealth - dmg:GetDamage()
	if (self.MaxHealth <= 0) then
		self:Destruct()
	end
end

function ENT:SetContents(s, c)
	self:Setcontents(s)
	self:Setcount(c)
		
	local contents = rp.shipments[s]

	if contents then
		self:SetgunModel(ents.Create('prop_physics'))
		self:GetgunModel():SetModel(contents.model)
		self:GetgunModel():SetPos(self:GetPos())
		self:GetgunModel():Spawn()
		self:GetgunModel():Activate()
		self:GetgunModel():SetSolid(SOLID_NONE)
		self:GetgunModel():SetParent(self)
		self:GetgunModel():DrawShadow(false)
		
		self:GetgunModel():PhysWake()
	end
end






local function GetTeamAllowed(t)
	local a = {}
	for k,v in pairs(rp.cfg.allowedW) do
		if _G[k] != t then
			continue
		end
		if type(v) == 'string' then
			table.Add(a, rp.cfg.weapontablez[v])
		else
			for _, w in pairs(v) do
				table.Add(a, rp.cfg.weapontablez[w])
			end
		end
	end
	return a
end

local function IsTeamAllowed( t, class )
	if table.HasValue(rp.cfg.weapontablez.all, class) then
		local tbl = GetTeamAllowed(t)
		if table.HasValue(tbl, class) then
			return true
		end
		return false
	end
	return true
end

local function NoticeMe( ply, class )
	ply.noticed = ply.noticed or CurTime()
	
	if ply.noticed > CurTime() then return end
	
	ply.noticed = CurTime() + 1
	
	local a = {}
	
	for k,v in pairs(rp.cfg.allowedW) do
		if _G[k] ==  ply:Team() then
			table.Add(a, type(v)=='string' and {v} or v)
			break
		end
	end

	ply:ChatPrint('Вы не можете подобрать ' .. class .. '. Это оружие запрещено для данной профессии')
	ply:ChatPrint('Разрешенное оружие: ' .. (#a == 0 and 'нет разрешенного оружия' or string.Implode(', ', a)))
end


function ENT:Use(pl)
	if pl:IsBanned() or (not hook.Call('PlayerCanPickupWeapon', GAMEMODE,pl)) then
		return
	end

	if (self:Getcount() < 1) then 
		pl:Notify(NOTIFY_ERROR, 'Там нет товаров.') 
		return 
	end

	self:SpawnItem()

end

function ENT:SpawnItem()
	if (not IsValid(self)) then return end

	local count = self:Getcount()

	if (count <= 1) then 
		self:Remove() 
	end

	local contents = self:Getcontents()

	if (not rp.shipments[contents]) then
		self:Remove()
		return
	end

	local weapon = ents.Create('spawned_weapon')

	local weaponAng = self:GetAngles()
	local weaponPos = self:GetAngles():Up() * 40 + weaponAng:Up() * (math.sin(CurTime() * 3) * 8)
	weaponAng:RotateAroundAxis(weaponAng:Up(), (CurTime() * 180) % 360)

	local class = rp.shipments[contents].entity
	local model = rp.shipments[contents].model

	weapon.weaponclass = class
	weapon:SetModel(model)
	weapon.ammoadd = self.ammoadd or (weapons.Get(class) and weapons.Get(class).Primary.DefaultClip)
	weapon.clip1 = self.clip1
	weapon.clip2 = self.clip2
	weapon:SetPos(self:GetPos() + weaponPos)
	weapon:SetAngles(weaponAng)
	weapon:Spawn()

	self:Setcount(count - 1)
	self.locked = false
end


function ENT:Destruct()
	if self.Destructed then return end
	self.Destructed = true
	local vPoint = self:GetPos()
	local contents = self:Getcontents()
	
	if (not rp.shipments[contents]) then
		self:Remove()
		return
	end
	
	local class = rp.shipments[contents].entity
	local model = rp.shipments[contents].model
	
	for i = 1, self:Getcount() do
		local weapon = ents.Create('spawned_weapon')
		weapon:SetModel(model)
		weapon.number = contents
		weapon.weaponclass = class
		weapon:SetPos(Vector(vPoint.x, vPoint.y, vPoint.z + (i*5)))
		weapon:Spawn()
	end
	self:Remove()
end

function ENT:StartTouch(e)
	if self.LastTouch and self.LastTouch >= CurTime() then return end
	self.LastTouch = CurTime() + 1 
	
	if (e:GetClass() ~= 'spawned_weapon') then return end

	local count = self:Getcount()

	if count >= 25 then return end
	
	local contents = self:Getcontents()
	
	if not e.number then return end
	if e.spawnTime and e.spawnTime >= CurTime() then return end
	if e.Shipment then return end
	e.Shipment = true
	
	if count < 1 then
		self:Setcontents(e.number)
		self:Setcount(1)
		
		local Content = rp.shipments[e.number]
		self:GetgunModel():Remove()
		
		self:SetgunModel(ents.Create('prop_physics'))
		self:GetgunModel():SetModel(Content.model)
		self:GetgunModel():SetPos(self:GetPos())
		self:GetgunModel():Spawn()
		self:GetgunModel():Activate()
		self:GetgunModel():SetSolid(SOLID_NONE)
		self:GetgunModel():SetParent(self)
	else
		if rp.shipments[contents].entity ~= e.weaponclass then return end
		self:Setcount(count + 1)
	end
	
	e:Remove()
end
	
function ENT:Touch(ent)
	if (ent:GetClass() ~= 'spawned_shipment') or (self:Getcontents() ~= ent:Getcontents()) or self.locked or ent.locked or self.hasMerged or ent.hasMerged then return end
	
	ent.hasMerged = true
	local selfCount, entCount = self:Getcount(), ent:Getcount()
	local count = selfCount + entCount

	if (count >= 10) then return end

	self:Setcount(count)
	-- Merge ammo information (avoid ammo exploits)
	if self.clip1 or ent.clip1 then -- If neither have a clip, use default clip, otherwise merge the two
		self.clip1 = math.floor(((ent.clip1 or 0) * entCount + (self.clip1 or 0) * selfCount) / count)
	end
	if self.clip2 or ent.clip2 then
		self.clip2 = math.floor(((ent.clip2 or 0) * entCount + (self.clip2 or 0) * selfCount) / count)
	end
	if self.ammoadd or ent.ammoadd then
		self.ammoadd = math.floor(((ent.ammoadd or 0) * entCount + (self.ammoadd or 0) * selfCount) / count)
	end
	ent:Remove()
end
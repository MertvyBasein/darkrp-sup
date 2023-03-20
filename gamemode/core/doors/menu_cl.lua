
-----------------------------------------------------
local adminMenu
local fr
local ent

--
-- Admin Menu
--
local adminOptions = {
	{
		Name = 'Запретить продажу',
		DoClick = function()
			RunConsoleCommand('set_nobuy_door')
		end
	},
	{
		Name = 'Разрешить продажу',
		DoClick = function()
			RunConsoleCommand('set_yesbuy_door')
		end
	},	
	{
		Name = 'Закрыть/Открыть',
		DoClick = function()
			RunConsoleCommand('setlocked')
		end
	},
	{
		Name = 'Дать права профессии',
		DoClick = function()
			local m = ui.DermaMenu()

			for k, v in ipairs(rp.teams) do
				m:AddOption(v.name, function()
					RunConsoleCommand('setteamown', k)
				end)
			end

			m:Open()
		end
	},
	{
		Name = 'Настройка владельца',
		DoClick = function()
			local m = ui.DermaMenu()

			for k, v in pairs(rp.teamDoors) do
				m:AddOption(k, function()
					RunConsoleCommand('setgroupown', k)
				end)
			end

			m:Open()
		end
	}
}

function adminMenu()
	if IsValid(rffr) then
		rffr:Remove()
	end

	rffr = ui.Create('XPFrame', function(self)
		self:SetTitle('Настройки')
		self:Center()
		self:MakePopup()

		self.Think = function(self)
			ent = LocalPlayer():GetEyeTrace().Entity

			if not IsValid(ent) or (ent:GetPos():DistToSqr(LocalPlayer():GetPos()) > 13225) then
				rffr:Remove()
			end
		end
	end)

	local count = -1
	local x, y = rffr:GetDockPos()

	for k, v in ipairs(adminOptions) do
		count = count + 1
		rffr:SetSize(ScrW() * .125, ((count + 1) * 39) + (y + 7))
		rffr:Center()

		ui.Create('XPButton', function(self)
			self:SetPos(x, (count * 39) + y)
			self:SetSize(ScrW() * .125 - 10, 30)
			self:SetText(v.Name)
			self.DoClick = v.DoClick
		end, rffr)
	end
end

concommand.Add('rp_dooradmin', adminMenu)

local doorOptions = {
	{
		Name = 'Продать',
		DoClick = function()
			RunConsoleCommand('selldoor')
			fr:Remove()
		end
	},
	{
		Name = 'Дать ключи',
		Check = function() return (#player.GetAll() > 1) end,
		DoClick = function()
			rp.PlayerRequest(function(pl)
				RunConsoleCommand('addcoowner', pl:SteamID())
			end)
		end
	},
	{
		Name = 'Забрать ключи',
		Check = function() return (ent:DoorGetCoOwners() ~= nil) and (#ent:DoorGetCoOwners() > 0) end,
		DoClick = function()
			rp.PlayerRequest(ent:DoorGetCoOwners(), function(pl)
				RunConsoleCommand('removecoowner', pl:SteamID())
			end)
		end
	},
	{
		Name = 'Надпись',
		DoClick = function()
			Derma_StringRequest('Надпись', 'Напишите текст который будет на двери', '', function(a)
				RunConsoleCommand('settitle', tostring(a))
			end)
		end
	},
	{
		Name = 'Админские',
		Check = function() return LocalPlayer():IsSuperAdmin() end,
		DoClick = function(self)
			adminMenu()
		end
	}
}

local function keysMenu()
	if IsValid(fr) then
		fr:Remove()
	end

	ent = LocalPlayer():GetEyeTrace().Entity

	if IsValid(ent) and ent:IsDoor() and ent:DoorOwnedBy(LocalPlayer()) and (ent:GetPos():DistToSqr(LocalPlayer():GetPos()) < 13225) then
		fr = ui.Create('XPFrame', function(self)
			self:SetTitle('Настройки')
			self:Center()
			self:MakePopup()

			self.Think = function(self)
				ent = LocalPlayer():GetEyeTrace().Entity

				if not IsValid(ent) or (ent:GetPos():DistToSqr(LocalPlayer():GetPos()) > 13225) then
					fr:Remove()
				end
			end
		end)

		local count = -1
		local x, y = fr:GetDockPos()

		for k, v in ipairs(doorOptions) do
			if (v.Check == nil) or (v.Check(ent) == true) then
				count = count + 1
				fr:SetSize(ScrW() * .125, ((count + 1) * 39) + (y + 10))
				fr:Center()

				ui.Create('XPButton', function(self)
					self:SetPos(x, (count * 39) + y)
					self:SetSize(ScrW() * .125 - 10, 30)
					self:SetText(v.Name)
					self.DoClick = function()
						v.DoClick(v)
						fr:Remove()
					end
				end, fr)
			end
		end
	elseif IsValid(ent) and ent:IsDoor() and (ent:GetPos():DistToSqr(LocalPlayer():GetPos()) < 13225) and ent:DoorIsOwnable() then
		RunConsoleCommand('buydoor')
	elseif LocalPlayer():IsSuperAdmin() and IsValid(ent) and ent:IsDoor() and (ent:GetPos():DistToSqr(LocalPlayer():GetPos()) < 13225) and not ent:DoorIsOwnable() then
		adminMenu()
	end
end

net('rp.keysMenu', keysMenu)
GM.ShowTeam = keysMenu


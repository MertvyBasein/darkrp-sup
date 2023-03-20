net('rp.NotifyString', function()
	if (not IsValid(LocalPlayer())) then return end
	notification.AddLegacy(rp.ReadMsg(), net.ReadUInt(2), 4)
end)

net('rp.NotifyTerm', function()
	if (not IsValid(LocalPlayer())) then return end
	notification.AddLegacy(net.ReadTerm(), net.ReadUInt(2), 4)
end)

function rp.Notify(notify_type, msg, ...)
	local replace = {...}
	local count = 0
	msg = msg:gsub('#', function()
		count = count + 1
		local v = replace[count]
		local t = type(v)
		if (t == 'Player') then 
			if (not IsValid(v)) then return 'Unknown' end
			return v:Name()
		elseif (t == 'Entity') then
			if (not IsValid(v)) then return 'Invalid Entity' end
			return (v.PrintName and v.PrintName or v:GetClass())
		end
		return v
	end)
	notification.AddLegacy(msg, notify_type, 4)
end
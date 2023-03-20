function rp.WriteMsg(msg, ...)
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
	net.WriteString(msg)
end

rp.ReadMsg = net.ReadString

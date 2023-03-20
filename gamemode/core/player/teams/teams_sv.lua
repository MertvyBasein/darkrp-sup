--
-- Commands
--
rp.AddCommand('model', function(pl, args, text)
	if args then
		pl:SetVar('Model', string.lower(args))
	end
end)
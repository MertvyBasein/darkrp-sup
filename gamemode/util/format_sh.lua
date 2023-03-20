local string_comma = string.Comma
function rp.FormatMoney(n)
	return  string_comma(n) .. '$'
end
function rp.FormatNumber(n)
	return string_comma(n)
end

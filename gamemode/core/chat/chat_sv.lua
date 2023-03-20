util.AddNetworkString('Chat.ToggleChat')

net.Receive('Chat.ToggleChat', function(len, pl)
	pl:SetNWBool('IsTyping', not pl:GetNWBool('IsTyping'))
end)

local errors = {
	[cmd.ERROR_INVALID_PLAYER]   = 'Игрок # не найден',
	[cmd.ERROR_MISSING_PARAM]    = 'Отстутствует # параметр: #',
	[cmd.ERROR_INVALID_COMMAND]  = 'Неизвестная команда: #',
	[cmd.ERROR_COMMAND_COOLDOWN] = 'Подождите # сек перед повторным вводом #',
	[cmd.ERROR_INVALID_NUMBER]   = 'Некорректный номер: #',
	[cmd.ERROR_INVALID_TIME]     = 'Некорректное время: #'
}
-- Если сможите то доделайте чат плиз
-- а то его так лень делать было
hook('cmd.OnCommandError','MessageCommandError',function(pl,obj,code,params)
	if params[2] == "clothe" then return end
	local msg = 'Неизвестная ошибка.'
	if errors[code] then
		local i = 0
		msg = errors[code]:gsub('#', function()
			i = i + 1
			return params[i]
		end)
	end

	rp.Notify(pl, NOTIFY_ERROR, msg)
end)

function GM:PlayerSay(pl, text, teamonly, dead)
	text = string.Trim(text)

	if not pl:Alive() or pl:IsBanned() or (text == '') or (text == '/') then return '' end

	if teamonly then
		chat.Send('Group', pl, text)
		-- if pl:IsRebels() or pl:IsCP() or pl:IsGSR() then 
		-- 	chat.Send('Me', pl, "сказал что-то по рации")
		-- end
		plogs.PlayerLog(pl, 'Чат', pl:NameID() .. ' сказал в групповой чат: ' .. string.Trim(text), {
			['Name'] 	= pl:Name(),
			['SteamID']	= pl:SteamID()
		})

		return ''
	end

	chat.Send('Local', pl, text)

	plogs.PlayerLog(pl, 'Чат', pl:NameID() .. ' сказал в чат: ' .. string.Trim(text), {
		['Name'] 	= pl:Name(),
		['SteamID']	= pl:SteamID()
	})

	return ''
end

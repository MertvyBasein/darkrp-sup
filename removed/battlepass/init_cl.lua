local _x, _y = 1920, 1080
local cvar_Get = cvar.GetValue

cvar.Register 'BattlePass_HUD'
    :SetDefault(true, true)
    :AddMetadata('Catagory', 'HUD')
    :AddMetadata('Menu', 'Отображение заданий боевого пропуска')
surface.CreateFont('BP.HeaderTasks', { font = 'Rubik SemiBold', extended = true, size = 22, weight = 1 })
surface.CreateFont('BP.Icon', { font = 'Rubik SemiBold', extended = true, size = 50, weight = 1 })
surface.CreateFont('BP.Tasks', { font = 'Rubik', extended = true, size = 20, weight = 1 })
surface.CreateFont('BP.Desc', { font = 'Rubik', extended = true, size = 16, weight = 1 })
surface.CreateFont('BP.Completed', { font = 'Rubik SemiBold', extended = true, size = 15, weight = 1 })

surface.CreateFont('BP.AccuredXP', { font = 'Rubik Light', extended = true, size = 35, weight = 1 })
surface.CreateFont('BP.XP', { font = 'Rubik SemiBold', extended = true, size = 35, weight = 1 })

local w,h = ScrW(),ScrH()
local x, y = w-8


local xp, fraction = nil, 0
net.Receive('bp::challangegot', function()
	xp = net.ReadUInt(8)
end)


hook.Add("HUDPaint","Battlepass.Show",function()
	if not cvar_Get("BattlePass_HUD") then return end
	
	if xp then
		if fraction == 1 then
			fraction = 0
			xp = nil
			return
		end
		fraction = math.Clamp(FrameTime()/2.5 + fraction, 0, 1)
		local w, h = ScrW(), ScrH()
	
		surface.SetFont('BP.AccuredXP')
		local _x, _y = surface.GetTextSize('НАЧИСЛЕНИЕ ОПЫТА')
	
		draw.RoundedBox(0, (w-_x)/2, 30, _x+6, _y, Color(0,0,0, Lerp(fraction,0,200) ))
		draw.SimpleText('НАЧИСЛЕНИЕ ОПЫТА', 'BP.AccuredXP', w/2+3,30, Color(255,255,255, Lerp(fraction,0,200) ), 1)
		
		surface.SetFont('BP.AccuredXP')
		local _x, _y = surface.GetTextSize('+'..xp)
	
		draw.RoundedBox(0, (w-_x)/2, 30+_y+3, _x+6, _y, Color(0,0,0, Lerp(fraction,0,200) ))
		draw.SimpleText('+'..xp, 'BP.AccuredXP', w/2+2,30+_y+4, Color(90,230,90, Lerp(fraction,0,200) ), 1)
	
		/*surface.SetMaterial(Material('vgui/gradient-u'))
		surface.SetDrawColor(255, 255, 255, Lerp(fraction,0,200))
		surface.DrawTexturedRectRotated(0, h-400, ScrW()*3, 600, 135)*/
	end

	local data = LocalPlayer():GetNetVar("BPChallanges")
	if not data then return end
	if table.Count(data) == 0 then return end

	local j = 47

	local activeW, activeH = draw.SimpleText('АКТИВНЫЕ ЗАДАНИЯ -', 'BP.HeaderTasks', w-8, j, Color(240,240,240), 2)
	local y = j+7
	local function addText(str)
		local a, b = draw.SimpleText(str, 'BP.Tasks', w-8-activeW, y+16, Color(245, 206, 66)/*, 2*/)
		local _x, _y = draw.SimpleText("◈ ", 'BP.Icon', w-8-activeW+a+6, y, Color(245, 206, 66)/*, 2*/)
		y = y + 40
		return a, b, w-42-a
	end


	for k,v in pairs(data) do
		local ch = battlepass.Challanges[k]

		local _, _y, q = addText(ch.name)

		local wrap = string.Split(rp.util.textWrap(ch.desc, 'BP.Desc', _), '\n')
		local wrap_y = 0
		local q
		for k,v in pairs(wrap) do
			local _, _y = draw.SimpleText(v, 'BP.Desc', w-8-activeW, y+wrap_y, Color(200,200,200))
			q = _
			wrap_y = wrap_y + _y
		end

		draw.SimpleText("("..v.."/"..ch.require..")", 'BP.Completed', w-8-activeW+q,y+(wrap_y-_y)+4,Color(255,255,255))

		y = y + wrap_y - 10
	end
end)
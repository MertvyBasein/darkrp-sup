rp.col = {
	SUP 		= Color(255,180,0),
	-- цвета саповские вораные
	-- Misc
	Black 		= Color(0,0,0),
	White 		= Color(255,255,255),
	Red 		= Color(245,0,0),
	Orange 		= Color(245,120,0),
	Purple 		= Color(180,50,200),
	Green 		= Color(50,200,50),
	Grey 		= Color(150,150,150),
	Yellow 		= Color(255,255,51),
	Pink 		= Color(245,120,120),
	Blue		= Color(50, 50, 200),
	Indigo		= Color(75, 0, 130),
	Violet		= Color(148, 0, 211),

	-- Chat
	OOC 		= Color(100,255,150),
	
	-- UI 
	Background 		= Color(0,0,0,230),
	Outline 		= Color(190,190,190,200),
	Highlight 		= Color(255,255,255,125),
	Button 			= Color(120,120,120),
	ButtonHovered	= Color(51,128,255),
}

-- Chat Colors
rp.chatcolors = {}
for k, v in pairs(rp.col) do
	local count = #rp.chatcolors + 1
	rp.chatcolors[k] = count
	rp.chatcolors[count] = v
end
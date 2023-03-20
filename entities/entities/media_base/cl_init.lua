include 'shared.lua'

cvar.Register 'media_enable'
	:SetDefault(true)
	:AddMetadata('Catagory', 'Медиа Плеер')
	:AddMetadata('State', 'RPMenu')
	:AddMetadata('Menu', 'Включение & Выключение | Mедиа плеера')
	
cvar.Register 'media_mute_when_unfocused'
	:SetDefault(true)
	:AddMetadata('Catagory', 'Медиа Плеер')
	:AddMetadata('State', 'RPMenu')
	:AddMetadata('Menu', 'Выключить все медиаплееры кроме своего')

cvar.Register 'media_volume'
	:SetDefault(1)
	:AddMetadata('Catagory', 'Медиа Плеер')
	:AddMetadata('State', 'RPMenu')
	:AddMetadata('Menu', 'Громкость МедиаПлеера')
	:AddMetadata('Type', 'number')

cvar.Register 'media_quality'
	:SetDefault('low')
	:AddMetadata('Catagory', 'Медиа Плеер')
	:AddMetadata('State', 'RPMenu')
	:AddMetadata('Menu', 'Качество плеера')

cvar.Register 'media_favs'
	:SetDefault({})
	:AddMetadata('Catagory', 'Медиа Плеер')
	:AddMetadata('State', 'RPMenu')
	:AddMetadata('Menu', 'Отображение плеера')

local favs = cvar.GetValue('media_favs')

local defaultPlaylist = 'Сохраненные видео'
cvar.Register 'media_saved_videos'
	:SetDefault({[defaultPlaylist] = {}}, true)

local mediaservice = medialib.load 'media'
local currentVideoList = defaultPlaylist
function ENT:OnPlay(media)


end


function ENT:GetSoundOrigin()
	return self
end

function ENT:OnRemove()
	local link = self:GetURL()
	if IsValid(self.Media) and (not link or not shouldplay) then
		self.Media:stop()
		self.Media = nil
	end
end


function ENT:Think()
	local link = self:GetURL()
	local lp = LocalPlayer()
	local shouldplay = cvar.GetValue('media_enable') and (lp:EyePos():Distance(self:GetPos()) < 512) and (not self:IsPaused())
	local shouldBeMuted = !(system.HasFocus() or (not cvar.GetValue('media_mute_when_unfocused')))
	local targetVolume = !shouldBeMuted and (cvar.GetValue('media_volume') or 0.75) or 0

	if IsValid(self.Media) and (not link or not shouldplay) then
		self.Media:stop()
		self.Media = nil
	elseif shouldplay and (not IsValid(self.Media) or self.Media:getUrl() ~= link) then
		if IsValid(self.Media) then
			self.Media:stop()
			self.Media = nil
		end
		if (link ~= '') then
			local service = mediaservice.guessService(link)
			if service then
				local mediaclip = service:load(link, {use3D = true, ent3D = self:GetSoundOrigin()})
				self:OnPlay(mediaclip)
				mediaclip:setVolume(cvar.GetValue('media_volume') or 0.75)
				mediaclip:setQuality(cvar.GetValue('media_quality'))
				if (self:GetTime() ~= 0) then
					local progress = (CurTime() - self:GetStart()) % self:GetTime()
					mediaclip:seek(progress)
					mediaclip.LastStart = CurTime() - progress
				else
					mediaclip.LastStart = CurTime()
				end
				mediaclip:play()
				self.Media = mediaclip
			end
		end
	elseif (IsValid(self.Media) and self.Media:getVolume() != targetVolume) then
		self.Media:setVolume(targetVolume)
	elseif (IsValid(self.Media) and shouldplay) then
		if (self:IsLooping()) then
			local inCurrentPlay = (CurTime() - self.Media.LastStart) < self:GetTime()
			if (!inCurrentPlay) then
				local progress = (CurTime() - self:GetStart()) % self:GetTime()
				self.Media:seek(progress)
				self.Media.LastStart = CurTime() - progress
			end
		end
	end
end

local color_bg 		= rp.col.Black
local color_text 	= rp.col.White
local color_texts 	= rp.col.SUP
function ENT:DrawScreen(x, y, w, h)
	if IsValid(self.Media) then
		self.Media:draw(x, y, w, h)
	else
		draw.Box(x, y, w, h, color_bg)
	    draw.SimpleText('Работает на chromium версии garry`s mod', 'ui.40', x + (w * .5),  y + (h * .6), color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end


local fr
local song
local ent
local text
local favs = cvar.GetValue('media_favs')

local function AddRow(p, l, n)
	if (!IsValid(p)) then return end -- menu got closed before the link info loaded
	local media = p:AddRow(n)
	media.DoClick = function(s)
		local m = ui.DermaMenu(self)
		m:AddOption('Play', function()
			if IsValid(ent) then
				cmd.Run('playsong', ent:EntIndex(), song.Link)
				song = nil
			end
		end)
		m:AddOption('Remove', function()
			favs[song.Link] = nil
			song:Remove()
			cvar.SetValue('media_favs', favs)
		end)
		m:Open()

	    song = s
	end
	media.Link = l
	media.Name = n
	return media
end

net.Receive('rp.MediaMenu', function()
    if IsValid(menu) then menu:Close() end

   	ent = net.ReadEntity()

    local w, h = ScrW() * .45, ScrH() * .6    
    local play
    local save
   

    local menu = vgui.Create('XPFrame')
    menu:SetSize(500, 0)
    menu:SetTitle('Плеер')
    menu:MakePopup()
    menu.Paint = function(s,w,h)
        draw.RoundedBox(4,0,0,w,h,Color(10,10,10,200))
    end

    local entry = vgui.Create('XPTextEntry', menu)
    entry:SetSize(0, 25)
    entry:SetPlaceholderText('Вставь прямую ссылку на ютуб или прямую')
    entry:SizeToContents()
    entry:Dock(TOP)

    local play = vgui.Create('XPButton', entry)
    play:SetSize(30, 25)
    play:SetText('►')
    play:Dock(RIGHT)
    play.DoClick = function()
        if IsValid(ent) then
            cmd.Run('playsong', ent:EntIndex(), entry:GetValue() or song.Link)
            song = nil
        end
    end
    play.Think = function(self)
        if (not medialib.load('media').guessService(entry:GetValue())) then
            self:SetDisabled(true)
        else
            self:SetDisabled(false)
        end
    end    

    menu:InvalidateLayout(true)
    menu:SizeToChildren(false, true)
    menu:Center()
end)
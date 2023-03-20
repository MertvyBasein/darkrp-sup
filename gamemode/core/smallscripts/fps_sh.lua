hook.Add("Initialize","NoWidgets",function()

 	hook.Remove("PlayerTick", "TickWidgets")
 
 	if SERVER then
 		if timer.Exists("CheckHookTimes") then
 			timer.Remove("CheckHookTimes")
 		end
 	end
	
 	hook.Remove("PlayerTick","TickWidgets")
	hook.Remove( "Think", "CheckSchedules")
	timer.Destroy("HostnameThink")
	hook.Remove("LoadGModSave", "LoadGModSave")
		
	for k, v in pairs(ents.FindByClass("env_fire")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("trigger_hurt")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("prop_physics")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("prop_ragdoll")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("light")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("spotlight_end")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("beam")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("point_spotlight")) do v:Remove() end
	for k, v in pairs(ents.FindByClass("env_sprite")) do v:Remove() end
	for k,v in pairs(ents.FindByClass("func_tracktrain")) do v:Remove() end
	for k,v in pairs(ents.FindByClass("light_spot")) do v:Remove() end
	for k,v in pairs(ents.FindByClass("point_template")) do v:Remove() end
	
	 if CLIENT then
 		hook.Remove("RenderScreenspaceEffects", "RenderColorModify")
 		hook.Remove("RenderScreenspaceEffects", "RenderBloom")
 		hook.Remove("RenderScreenspaceEffects", "RenderToyTown")
 		hook.Remove("RenderScreenspaceEffects", "RenderTexturize")
 		hook.Remove("RenderScreenspaceEffects", "RenderSunbeams")
 		hook.Remove("RenderScreenspaceEffects", "RenderSobel")
 		hook.Remove("RenderScreenspaceEffects", "RenderSharpen")
 		hook.Remove("RenderScreenspaceEffects", "RenderMaterialOverlay")
 		hook.Remove("RenderScreenspaceEffects", "RenderMotionBlur")
 		hook.Remove("RenderScene", "RenderStereoscopy")
 		hook.Remove("RenderScene", "RenderSuperDoF")
 		hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
 		hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
 		hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
 		hook.Remove("PostRender", "RenderFrameBlend")
 		hook.Remove("PreRender", "PreRenderFrameBlend")
 		hook.Remove("Think", "DOFThink")
 		hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
 		hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
 		hook.Remove("PostDrawEffects", "RenderWidgets")
 		hook.Remove("PostDrawEffects", "RenderHalos")
 	end
	
end)


 if CLIENT then
	 hook.Add("PlayerFinishedLoading","CSS_Check.PlayerIsLoaded",function()
		if IsMounted(240)
			then return 
		else 
			chat.AddText("У вас нету контента CS:Sourse! ...Скачайте его!")
		end 
	end)
	hook.Add("ChatText","hide_joinleave",function(r,r,r,e)
		if e=="joinleave"
			then return true 
		end 
	end)
	local s=CreateClientConVar('rp_viewdist',2500,true)
	hook.Add("OnEntityCreated","ENPC.OnEntityCreated.Jobs",function(e)
		if e~=LocalPlayer() then return end 
		RunConsoleCommand("violence_ablood","1")
		RunConsoleCommand("mat_queue_mode","2")
		RunConsoleCommand("cl_threaded_bone_setup","1")
		RunConsoleCommand("gmod_mcore_test","1")
		RunConsoleCommand("cl_threaded_client_leaf_system","0")
		RunConsoleCommand("r_threaded_client_shadow_manager","1")
		RunConsoleCommand("r_fastzreject","-1")
		RunConsoleCommand("Cl_ejectbrass","0")
		RunConsoleCommand("Muzzleflash_light","0")
		RunConsoleCommand("cl_wpn_sway_interp","0")
		RunConsoleCommand("in_usekeyboardsampletime","0")
	end)
end

if CLIENT then
	hook.Add( "PlayerIsLoaded", "mcorrendesssrring", function()
end)
end

local cmdlist = {
	r_shadowrendertotexture = { 0, GetConVarNumber },
	r_shadowmaxrendered = { 0, GetConVarNumber },
	mat_shadowstate = { 0, GetConVarNumber },
	cl_phys_props_enable = { 0, GetConVarNumber },
	cl_phys_props_max = { 0, GetConVarNumber },
	props_break_max_pieces = { 0, GetConVarNumber },
	r_propsmaxdist = { 0, GetConVarNumber },
	r_drawmodeldecals = { 0, GetConVarNumber },
	r_3dsky  = { 0, GetConVarNumber },
	r_dynamic   = { 0, GetConVarNumber },
	cl_threaded_bone_setup = { 1, GetConVarNumber },
	cl_threaded_client_leaf_system = { 1, GetConVarNumber },
	r_threaded_client_shadow_manager = { 1, GetConVarNumber },
	r_threaded_particles = { 1, GetConVarNumber },
	r_threaded_renderables = { 1, GetConVarNumber },
	studio_queue_mode = { 1, GetConVarNumber },
	mat_queue_mode = { 2, GetConVarNumber },
	gmod_mcore_test = { 1, GetConVarNumber },
}

local detours = {}

for k,v in pairs( cmdlist ) do
	detours[k] = v[2](k)
	RunConsoleCommand(k, v[1])
end

hook.Add( 'ShutDown', 'convarss', function()
	for k,v in pairs(detours) do
		RunConsoleCommand(k,v)
	end
end)

hook.Add("OnAchievementAchieved", "Redmi2", function() return true end)
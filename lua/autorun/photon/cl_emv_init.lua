AddCSLuaFile()

if not CLIENT then return end

include( "cl_emv_meta.lua" )
include( "cl_emv_hud.lua" )
include( "cl_emv_listener.lua" )
include( "cl_emv_net.lua" )
include( "cl_frame_adjust.lua" )
include( "cl_photon_builder.lua" )
include( "cl_photon_menu.lua" )

local should_render = GetConVar( "photon_emerg_enabled" )

local function DrawEMVLights()
	Photon:ClearLightQueue()
	if not should_render:GetBool() then return end
	for k,v in pairs( EMVU:AllVehicles() ) do
		if IsValid( v ) and v.IsEMV and v:IsEMV() and v.Photon_RenderEL then v:Photon_RenderEL() elseif v:IsEMV() then EMVU:MakeEMV(v, v:EMVName()) end
		if IsValid( v ) and v.IsEMV and v:IsEMV() and v.Photon_RenderIllum then v:Photon_RenderIllum() end
	end	
end
hook.Add("PreRender", "EMVU.Scan", DrawEMVLights)

function EMVU:CalculateFrames()
	if not should_render:GetBool() then return end
	for _,ent in pairs( EMVU:AllVehicles() ) do
		if IsValid( ent ) and ent.HasELS and ent:HasELS() and (ent.Photon_Lights and ent:Photon_Lights() or ent.Photon_TrafficAdvisor and ent:Photon_TrafficAdvisor()) then ent:Photon_CalculateELFrames() end
	end
end
timer.Create("EMVU.CalculateFrames", .03, 0, function()
	EMVU:CalculateFrames()
end)

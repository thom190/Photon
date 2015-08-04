AddCSLuaFile()

local should_render = GetConVar( "photon_stand_enabled" )

hook.Add( "Initialize", "Photon.InitStandShouldRender", function() 
	should_render = GetConVar( "photon_stand_enabled" )
end )

PHOTON_REG_ENABLED = true

local PHOTON_REG_ENABLED = PHOTON_REG_ENABLED

local function DrawCarLights()
	if not should_render:GetBool() then return end
	local photonDebug = PHOTON_DEBUG
	for _,ent in pairs( Photon:AllVehicles() ) do
		if IsValid( ent ) then
			if ent:Photon() and ent.Photon_RenderLights then
					ent:Photon_RenderLights( 
						ent:Photon_HeadlightsOn(), 
						ent:Photon_IsRunning(), 
						ent:Photon_IsReversing(), 
						ent:Photon_IsBraking(), 
						ent:Photon_TurningLeft(), 
						ent:Photon_TurningRight(), 
						ent:Photon_Hazards(), 
						photonDebug
					)
				if ent:IsEMV() and ent.Photon_ScanEMVProps then ent:Photon_ScanEMVProps() end
			elseif ent:Photon() and not ent.Photon_RenderLights then
				Photon:SetupCar( ent, ent:Photon() )
			end
		end
	end
end
hook.Add( "PreRender", "Photon.Scan", function()
	DrawCarLights()
end)

function Photon:AdjustFrameTime()
	if FrameTime() >= EMV_FRAME_DUR or FrameTime() < EMV_FRAME_DUR and FrameTime() > EMV_FRAME_CONST then 
		EMV_FRAME_DUR = FrameTime()
	elseif FrameTime() < EMV_FRAME_CONST then
		EMV_FRAME_DUR = EMV_FRAME_CONST
	end
end
hook.Add("PreRender", "Photon.AdjustFrameTime", function()
	Photon:AdjustFrameTime()
end)

local function TurnScan()
	if not should_render:GetBool() then return end
	local ply = LocalPlayer()
	if not ply or not ply:IsValid() or not ply:InVehicle() or not ply:GetVehicle() then return end
	local car = ply:GetVehicle()
	if not IsValid( car ) then return end
	if not car:Photon() then return end
	if ply:KeyDown( IN_MOVERIGHT ) and car:Photon_TurningRight() then 
		car.Lighting.GoingForward = false
		return
	end
	if not ply:KeyDown( IN_FORWARD ) then
		car.Lighting.GoingForward = false
		return
	end
	if car:Photon_TurningLeft() and ply:KeyDown( IN_MOVELEFT ) then
		car.Lighting.GoingForward = false
		return
	end
	
	if car.Lighting.GoingForward and (car:Photon_AdjustedSpeed() > 25) then
		if CurTime() >= car.Lighting.ForwardDuration then
			Photon:CarSignal( "none" )
		end
	else
		car.Lighting.ForwardDuration = CurTime() + 1
		car.Lighting.GoingForward = true
	end

end

hook.Add("Tick", "Photon.TurnScan", function() TurnScan() end)

local function SettingsScan()
	--if istable(VC_Settings_Data) and VC_Settings_Data.VC_Enabled then PHOTON_REG_ENABLED = false return end
	PHOTON_REG_ENABLED = true
end
hook.Add("Tick", "Photon.SettingsScan", function() SettingsScan() end)

local function RemoveCarProps( ent )
	if IsValid( ent ) and ent:IsVehicle() and ent:HasELS() and ent.EMVProps then
		for _,prop in pairs( ent.EMVProps ) do
			prop:Remove()
		end
	end
end
hook.Add("EntityRemoved", "Photon.RemoveCarProps", RemoveCarProps)


---@class (partial) PvpAlerts
local PVP = PVP_Alerts_Main_Table

local chat = PVP.CHAT

local GetFrameTimeSeconds = GetFrameTimeSeconds
local GetFrameTimeMilliseconds = GetFrameTimeMilliseconds
local zo_distance = zo_distance
local Set3DRenderSpaceToCurrentCamera = Set3DRenderSpaceToCurrentCamera
local GetPlayerCameraHeading = GetPlayerCameraHeading
local GetCurrentMapIndex = GetCurrentMapIndex
local GetObjectiveInfo = GetObjectiveInfo
local GetCurrentSubZonePOIIndices = GetCurrentSubZonePOIIndices
local IsInImperialCity = IsInImperialCity
local IsActiveWorldBattleground = IsActiveWorldBattleground
local GetMapPlayerPosition = GetMapPlayerPosition
local GetKeepName = GetKeepName
local GetKeepKeysByIndex = GetKeepKeysByIndex
local GetKeepPinInfo = GetKeepPinInfo
local GetPlayerLocationName = GetPlayerLocationName

local strgsub= zo_strgsub

local ceil = zo_ceil
local max = zo_max
local asin = math.asin
--local acos = zo_cos
local tan = zo_tan
local atan = math.atan
local atan2 = zo_atan2
--local sqrt = zo_sqrt
local cos = zo_cos
local sin = zo_sin
local floor = zo_floor
local abs = zo_abs
local pairs = pairs
local pi = ZO_PI
local ZO_HALF_PI = ZO_HALF_PI

local sort = table.sort
local insert = table.insert
local remove = table.remove
--local concat = table.concat
--local upper = string.upper
--local lower = string.lower
--local format = string.format

local IC_ZONEID = GetZoneIndex(584)

local ICONSIZE = 18
local ICONUASIZE = ICONSIZE + 4
local iconSizeResource = 15
local iconUASizeResource = iconSizeResource + 4
local captureMeterSizeAdjustment = 4
-- local cameraDistance = 10
local playerHeight = 2
local maxDistance = 0.0005
-- local effectiveMaxDistance = 0.85 * maxDistance
-- local effectiveMaxDistanceFar = 1.15 * maxDistance

-- local mydname = GetUnitDisplayName("player")

local BGQUERY_LOCAL = BGQUERY_LOCAL

local PVP_MAPINDEX_CYRODIIL = 14
local PVP_MAPINDEX_IC = 26

local PVP_ICON_HEIGHT_KEEP = 58
local PVP_ICON_HEIGHT_TOWN = 35
local PVP_ICON_HEIGHT_OUTPOST = 55
local PVP_ICON_HEIGHT_BORDER_KEEP = 60
local PVP_ICON_HEIGHT_BORDER_KEEP_INSIDE = 10
local PVP_ICON_HEIGHT_ARTIFACT_KEEP = 62
local PVP_ICON_HEIGHT_ARTIFACT_GATE = 40
local PVP_ICON_HEIGHT_RESOURCE = 35
local PVP_ICON_HEIGHT_IMPERIAL_CITY_DISTRICT = 18
-- local PVP_ICON_HEIGHT_BG_OBJECTIVE = 17
local PVP_ICON_HEIGHT_BG_OBJECTIVE = 13

-- local PVP_DISTANCE_MAX_MULTIPLIER = 4.5
local PVP_DISTANCE_MAX_MULTIPLIER = 7
local PVP_DISTANCE_MAX_MULTIPLIER_IC = 9

-- local PVP_FALLOFF_DISTANCE = 0.03
-- local PVP_FALLOFF_DISTANCE1 = 0.05
local PVP_MAX_DISTANCE = 0.20
local PVP_SKIRMISH_MAX_DISTANCE = PVP_MAX_DISTANCE / 20
--local PVP_MIN_TOOLTIP_POPUP_DISTANCE = PVP_MAX_DISTANCE / 6.4

local PVP_POI_HEIGHT_GRACE_DISTANCE = 0.02
--local PVP_MIN_DISTANCE = 0
local PVP_POI_MIN_DISTANCE = 0.01
local PVP_SKIRMISH_MIN_DISTANCE = PVP_POI_MIN_DISTANCE * 0.75

local PVP_PINTYPE_AYLEIDWELL = PVP:GetGlobal('PVP_PINTYPE_AYLEIDWELL')
local PVP_PINTYPE_DELVE = PVP:GetGlobal('PVP_PINTYPE_DELVE')
local PVP_PINTYPE_GROUP = PVP:GetGlobal('PVP_PINTYPE_GROUP')
local PVP_PINTYPE_IC_ALLIANCE_BASE = PVP:GetGlobal('PVP_PINTYPE_IC_ALLIANCE_BASE')
local PVP_PINTYPE_IC_DOOR = PVP:GetGlobal('PVP_PINTYPE_IC_DOOR')
local PVP_PINTYPE_IC_VAULT = PVP:GetGlobal('PVP_PINTYPE_IC_VAULT')
local PVP_PINTYPE_IC_GRATE = PVP:GetGlobal('PVP_PINTYPE_IC_GRATE')
local PVP_PINTYPE_SEWERS_SIGN = PVP:GetGlobal('PVP_PINTYPE_SEWERS_SIGN')
local PVP_PINTYPE_MILEGATE = PVP:GetGlobal('PVP_PINTYPE_MILEGATE')
local PVP_PINTYPE_BRIDGE = PVP:GetGlobal('PVP_PINTYPE_BRIDGE')
local PVP_PINTYPE_COMPASS = PVP:GetGlobal('PVP_PINTYPE_COMPASS')
local PVP_PINTYPE_TOWNFLAG = PVP:GetGlobal('PVP_PINTYPE_TOWNFLAG')
local PVP_PINTYPE_SHADOWIMAGE = PVP:GetGlobal('PVP_PINTYPE_SHADOWIMAGE')
--local PVP_MONKEY = PVP:GetGlobal('PVP_MONKEY')
--local PVP_BUNNY = PVP:GetGlobal('PVP_BUNNY')

-- local PVP_PINTYPE_SHADOWIMAGE = 9999

local PVP_PINTYPE_POWERUP = PVP:GetGlobal('PVP_PINTYPE_POWERUP')

local PVP_KEEPTYPE_ARTIFACT_KEEP = PVP:GetGlobal('PVP_KEEPTYPE_ARTIFACT_KEEP')
local PVP_KEEPTYPE_BORDER_KEEP = PVP:GetGlobal('PVP_KEEPTYPE_BORDER_KEEP')
local PVP_ALLIANCE_BASE_IC = PVP:GetGlobal('PVP_ALLIANCE_BASE_IC')

local PVP_RALLY_TEXTURE = 'esoui/art/mappins/maprallypoint.dds'
local PVP_WAYPOINT_TEXTURE = 'esoui/art/compass/compass_waypoint.dds'

local PVP_TEXTURES_PATH = PVP:GetGlobal('PVP_TEXTURES_PATH')

-- local rankIcons = {
-- 	[1] = 'esoui/art/tutorial/ava_rankicon64_general.dds',
-- 	[2] = 'esoui/art/tutorial/ava_rankicon64_warlord.dds',
-- 	[3] = 'esoui/art/tutorial/ava_rankicon64_grandwarlord.dds',
-- 	[4] = 'esoui/art/tutorial/ava_rankicon64_overlord.dds',
-- 	[5] = 'esoui/art/tutorial/ava_rankicon64_grandoverlord.dds',
-- }

local icControls = {
	['IC_BASE'] = true,
	['IC_DOOR'] = true,
	['IC_VAULT'] = true,
	['IC_GRATE'] = true,
}

local dynamicControls = {
	['SCROLL'] = true,
	['DAEDRIC_ARTIFACT'] = true,
	['GROUP'] = true,
	['COMPASS'] = true,
}

local connectedKeepsArray = {
	[3] = { 109, 110, 5 },			--warden
	[4] = { 109, 110, 5 },			--rayles
	[5] = { 3, 4, 6, 7 },			--glade
	[6] = { 5, 7, 18, 132 },		--ash
	[7] = { 5, 6, 8, 134 },		 --aw
	[8] = { 109, 110, 7, 9, 107, 108 }, --claw
	[9] = { 10, 13, 8, 134 },		--chal
	[10] = { 11, 12, 9, 13 },		--arrius
	[11] = { 107, 108, 10 },		--king
	[12] = { 107, 108, 10 },		--farra
	[13] = { 10, 9, 14, 133 },		--brk
	[14] = { 107, 108, 13, 15, 105, 106 }, --drake
	[15] = { 16, 17, 14, 133 },	 --alessia
	[16] = { 19, 20, 15, 17 },		--fare
	[17] = { 16, 15, 18, 132 },	 --roe
	[18] = { 105, 106, 109, 110, 17, 6 }, --brindle
	[19] = { 105, 106, 16 },		--bb
	[20] = { 105, 106, 16 },		--bm
	[132] = { 6, 17 },				--nik
	[133] = { 13, 15 },			 --sej
	[134] = { 7, 9 },				--bleaks
	[163] = { 8 },					--Winter's Peak
	[164] = { 18 },				 --Carmala
	[165] = { 14 },				 --Harlun's
}

local adLinks = {
	[1] = { 16, 19 },
	[2] = { 16, 20 },
	[3] = { 17, 18 },
	[4] = { 15, 14 },
}

local dcLinks = {
	[1] = { 5, 3 },
	[2] = { 5, 4 },
	[3] = { 6, 18 },
	[4] = { 7, 8 },
}

local epLinks = {
	[1] = { 10, 11 },
	[2] = { 10, 12 },
	[3] = { 9, 8 },
	[4] = { 13, 14 },
}

local pinTypes = {
	[PVP_PINTYPE_AYLEIDWELL] = 'AYLEID_WELL',
	[PVP_PINTYPE_DELVE] = 'DELVE',
	[PVP_PINTYPE_MILEGATE] = 'MILEGATE',
	[PVP_PINTYPE_BRIDGE] = 'BRIDGE',
	[MAP_PIN_TYPE_PLAYER_WAYPOINT] = 'WAYPOINT',
	[MAP_PIN_TYPE_RALLY_POINT] = 'RALLY',
	[MAP_PIN_TYPE_PING] = 'PING',
	[PVP_PINTYPE_POWERUP] = 'BG_POWERUP',
	[PVP_PINTYPE_SHADOWIMAGE] = 'SHADOW_IMAGE',
	[PVP_PINTYPE_TOWNFLAG] = 'TOWN_FLAG',
	[PVP_PINTYPE_COMPASS] = 'COMPASS',
	[PVP_PINTYPE_IC_ALLIANCE_BASE] = 'IC_BASE',
	[PVP_PINTYPE_IC_DOOR] = 'IC_DOOR',
	[PVP_PINTYPE_IC_VAULT] = 'IC_VAULT',
	[PVP_PINTYPE_IC_GRATE] = 'IC_GRATE',
	[PVP_PINTYPE_SEWERS_SIGN] = 'SEWERS_SIGN'
}

local fixedHeight = {
	['AYLEID_WELL'] = true,
	['DELVE'] = true,
	['IC_BASE'] = true,
	['MILEGATE'] = true,
	['BRIDGE'] = true,
	['BG_BASE'] = true,
	['BG_POWERUP'] = true,
	['SHADOW_IMAGE'] = true,
	['TOWN_FLAG'] = true,
	['COMPASS'] = true,
	['IC_DOOR'] = true,
	['IC_VAULT'] = true,
	['IC_GRATE'] = true,
	['SEWERS_SIGN'] = true,
}

local nonClaimableKeepTypes = {
	[PVP_KEEPTYPE_ARTIFACT_KEEP] = true,
	[PVP_KEEPTYPE_BORDER_KEEP] = true,
	[KEEPTYPE_ARTIFACT_KEEP] = true,
	[KEEPTYPE_ARTIFACT_GATE] = true,
	[KEEPTYPE_BORDER_KEEP] = true,
	[KEEPTYPE_IMPERIAL_CITY_DISTRICT] = true,
}

local function GetNumberOfAnimationPhases()
	return ceil(GetFramerate() / 6) --// yep, just like that //
end

function PVP:GetCaptureTexture(alliance, isCapture, threshold)
	local texture
	if threshold == 100 then
		if alliance == 1 then
			texture = 'esoui/art/ava/avacapturebar_fill_aldmeri.dds'
		elseif alliance == 2 then
			texture = 'esoui/art/ava/avacapturebar_fill_ebonheart.dds'
		elseif alliance == 3 then
			texture = 'esoui/art/ava/avacapturebar_fill_daggerfall.dds'
		end
		return texture
	end

	texture = PVP_TEXTURES_PATH
	if alliance == 1 then
		texture = texture .. 'ad_'
	elseif alliance == 2 then
		texture = texture .. 'ep_'
	elseif alliance == 3 then
		texture = texture .. 'dc_'
	end

	if isCapture then
		texture = texture .. 'capture_'
	else
		texture = texture .. 'contest_'
	end

	texture = texture .. tostring(threshold) .. '.dds'

	return texture
end

local function SetDimensions3DControl(control, iconSize3D, iconUASize3D, BGSize3D)
	local params = control.params
	local keepId = params.keepId
	local flagOffset = (keepId and ({ [KEEPTYPE_OUTPOST] = 4, [KEEPTYPE_TOWN] = 6 })[PVP:KeepIdToKeepType(keepId)]) or 1
	local iconSizeWithOffset = iconSize3D + flagOffset

	if params.type == 'SHADOW_IMAGE' then
		control.icon:Set3DLocalDimensions(iconSize3D / 3, iconSize3D)
		control.bg:Set3DLocalDimensions(iconSize3D / 3 + 1 / 5, iconSize3D + 1 / 5)
	else
		control.icon:Set3DLocalDimensions(iconSize3D, iconSize3D)
		control.bg:Set3DLocalDimensions(BGSize3D, BGSize3D)
	end

	control.scroll:Set3DLocalDimensions(iconSize3D, iconSize3D)
	control.locked:Set3DLocalDimensions(iconSize3D / 2.2, iconSize3D / 2.2)
	control.iconUA:Set3DLocalDimensions(iconUASize3D, iconUASize3D)
	control.ping:Set3DLocalDimensions(iconUASize3D * 2.2, iconUASize3D * 2.2)

	-- Apply the same dimensions to multiple elements
	for _, element in pairs({ control.flags, control.middle, control.apse, control.nave, control.other }) do
		element:Set3DLocalDimensions(iconSizeWithOffset, iconSizeWithOffset)
	end

	local captureSize = iconUASize3D + captureMeterSizeAdjustment
	for _, element in pairs({ control.captureBG, control.captureBar, control.divider }) do
		element:Set3DLocalDimensions(captureSize, captureSize)
	end
end

local function SetupTextureCoords(control)
	local controlType = control.params.type
	local icon = control.icon
	if controlType == 'RALLY' then
		if not control.params.textureState then
			control.params.textureState = 1
			icon:SetTextureCoords(((control.params.textureState - 1) * 64) / 2048, (control.params.textureState * 64) /
				2048, 0, 1)
		end
	elseif controlType == 'PING' then
		icon:SetTextureCoords(0, 0.03125, 0, 1)
	else
		icon:SetTextureCoords(0, 1, 0, 1)
	end

	if (controlType == 'COMPASS' and PVP.SV.useDepthBufferCompass) or controlType == 'SEWERS_SIGN' then
		icon:Set3DRenderSpaceUsesDepthBuffer(true)
	else
		icon:Set3DRenderSpaceUsesDepthBuffer(false)
	end
end

local function ResetControlPings(control)
	if control.params.hasRally then
		PVP.LMP:RemoveMapPing(MAP_PIN_TYPE_RALLY_POINT)
	elseif control.params.hasWaypoint then
		PVP.LMP:RemoveMapPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	end
end

local function IsSkirmishCloseToObjective(condition, objectiveX, objectiveY, scaleAdjustment)
	local isSkirmish
	if condition then
		for i = 1, GetNumKillLocations() do
			local pinType, targetX, targetY = GetKillLocationPinInfo(i)
			if targetX ~= 0 and targetY ~= 0 then
				local distance = zo_distance(objectiveX, objectiveY, targetX, targetY)
				if pinType ~= MAP_PIN_TYPE_INVALID and distance <= scaleAdjustment * PVP_SKIRMISH_MAX_DISTANCE then
					isSkirmish = true
					break
				end
			end
		end
	end
	return isSkirmish
end


local function GetPlayerCameraHeading3D(renew)
	if renew or not (PVP.onUpdateInfo and PVP.onUpdateInfo.GetPlayerCameraHeading) then
		return GetPlayerCameraHeading()
	else
		return PVP.onUpdateInfo.GetPlayerCameraHeading
	end
end

local function GetAdjustedPlayerCameraHeading(renew)
	if renew or not PVP.currentCameraInfo then
		local heading = GetPlayerCameraHeading3D(renew)
		if heading > pi then
			heading = heading - 2 * pi
		end
		return heading
	else
		return PVP.currentCameraInfo.adjustedHeading
	end
end

local function IsPopPhaseValid(currentPhase)
	if not currentPhase or currentPhase < 1 or currentPhase > GetNumberOfAnimationPhases() then
		return false
	else
		return true
	end
end

local function GetPopInMultiplier(targetMultiplier, control)
	local isControlFlipping = control.params.flippingPlaying and control.params.flippingPlaying:IsPlaying()
	local currentPhase = control.params.currentPhase
	if not IsPopPhaseValid(currentPhase) then return targetMultiplier end
	local diff = targetMultiplier - 1
	control.params.currentPhase = control.params.currentPhase + 1
	if diff < 0 then return 1 end

	local multiplierStep = diff / GetNumberOfAnimationPhases()

	return 1 + currentPhase * multiplierStep
end

local function GetPopOutMultiplier(startingMultiplier, control)
	local isControlFlipping = control.params.flippingPlaying and control.params.flippingPlaying:IsPlaying()
	local currentPhase = control.params.currentPhase
	if not IsPopPhaseValid(currentPhase) then return 1 end
	local diff = startingMultiplier - 1
	control.params.currentPhase = control.params.currentPhase - 1
	if diff < 0 then return 1 end

	local multiplierStep = diff / GetNumberOfAnimationPhases()

	return startingMultiplier - (GetNumberOfAnimationPhases() - 1 - currentPhase) * multiplierStep
end

local function GetPOIControlSelectedSizeMultiplier(control, scaleAdjustment, multiplier)
	local sizeAdjustment = control.params.distance / (scaleAdjustment * PVP_MAX_DISTANCE)
	local controlType = control.params.type
	local isWaypoint = controlType == 'WAYPOINT'
	local isPing = controlType == 'PING'
	local isRally = controlType == 'RALLY'
	local isGroup = controlType == 'GROUP'

	if isWaypoint or isPing or isGroup then
		if sizeAdjustment < 0.5 then
			multiplier = multiplier
		else
			if isGroup then
				multiplier = multiplier / 2 / sizeAdjustment
			else
				multiplier = multiplier / 2 / sizeAdjustment
			end
		end
	elseif isRally then
		if sizeAdjustment < 0.25 then
			multiplier = multiplier
		else
			multiplier = multiplier / 4 / sizeAdjustment
		end
	end

	return multiplier
end

local function IsPlayerNearObjective(keepId, isCheck)
	if (not keepId) or keepId == "" then return false end
	local zoneId, subzoneId = GetCurrentSubZonePOIIndices()
	local isBruma = zoneId == 37 and subzoneId == 106
	local zoneName = GetPlayerLocationName()
	local output


	if type(keepId) == "table" then
		keepId = keepId[1]
	end

	if type(keepId) == "number" then
		local keepName = GetKeepName(keepId)
		if keepName == zoneName or keepName == PVP:IsScrollTemple(zoneName) or (isBruma and keepId == 151) then
			output = {}
		end
	elseif type(keepId) == "string" then
		if zoneName == keepId then
			output = {}
		end
	end

	if output then output[1] = keepId end

	if not isCheck and output and type(keepId) == "number" and (GetKeepResourceType(keepId) ~= 0 or GetKeepType(keepId) == KEEPTYPE_KEEP) then
		output[2], output[3], output[4] = PVP:GetNeighbors(keepId)
	end

	return output
end

local function Hide3DControl(control, scaleAdjustment)
	if ZO_WorldMap_IsWorldMapShowing() then
		control:SetHidden(true)
		return true
	end

	local SV = PVP.SV
	local controlParams = control.params
	local controlType = controlParams.type
	local distance = controlParams.distance
	local keepId = controlParams.keepId
	local isCurrent = controlParams.isCurrent
	local name = controlParams.name

	-- Distance checks
	local minIconDistance = scaleAdjustment * SV.min3DIconsDistance
	local maxIconDistance = scaleAdjustment * SV.max3DIconsDistance
	local maxResourceDistance = scaleAdjustment * SV.maxResource3DIconsDistance

	-- Utility controls and keep checks
	local utilityControls = { ['RALLY'] = true, ['WAYPOINT'] = true, ['PING'] = true, ['GROUP'] = true, ['COMPASS'] = true }
	local onScreenKeeps = { [PVP_KEEPTYPE_ARTIFACT_KEEP] = true, [PVP_KEEPTYPE_BORDER_KEEP] = true, [KEEPTYPE_IMPERIAL_CITY_DISTRICT] = true }

	if (controlType ~= "SHADOW_IMAGE" and SV.min3DIconsDistance > 0 and distance < minIconDistance) or
		(keepId and GetKeepResourceType(keepId) ~= 0 and (distance > maxResourceDistance or distance > maxIconDistance)) or
		(not utilityControls[controlType] and distance > maxIconDistance) or
		(icControls[controlType] and not isCurrent) or
		((not SV.showOnScreen and SV.onScreenReplace) and (
			(IsPlayerNearObjective(keepId, true) and not ((controlType == 'TOWN_FLAG') or onScreenKeeps[PVP:KeepIdToKeepType(keepId)])) or
			(IsPlayerNearObjective(name) and (controlType == 'MILEGATE' or controlType == 'BRIDGE'))
		)) then
		control:SetHidden(true)
		return true
	end

	control:SetHidden(false)
	return false
end

local function IsInImperialCityDistrict(renew)
	if renew or not PVP.onUpdateInfo then
		local zoneId, subzoneId = GetCurrentSubZonePOIIndices()
		return zoneId == IC_ZONEID and PVP.icAllianceBases[subzoneId]
	else
		return PVP.onUpdateInfo.IsInImperialCityDistrict
	end
end

function PVP:IsInSewers()
	return IsInImperialCity() and not IsInImperialCityDistrict()
end

local function IsInBorderKeepArea(renew)
	if renew or not PVP.onUpdateInfo then
		local locationName = GetPlayerActiveSubzoneName()
		if not locationName or locationName == '' then return false end

		for k, v in pairs(PVP.borderKeepsIds) do
			local keepName = GetKeepName(k)
			if keepName == locationName or strgsub(locationName, ' Gate', '') == strgsub(keepName, 'Gate', '') then
				return
					k
			end --hax because typo in English client for dc border keep names
		end
		return false
	else
		return PVP.onUpdateInfo.IsInBorderKeepArea
	end
end

local function StartBorderKeep3DAnimation(control)
	local timeline = ANIMATION_MANAGER:CreateTimeline()

	local heading = GetPlayerCameraHeading3D()
	PVP:InsertAnimationType(timeline, ANIMATION_ROTATE3D, control, 10000, 0, ZO_LinearEase, 0, heading, 0, 0,
		2 * pi + heading, 0)
	timeline:SetHandler('OnStop', function()
		if (IsInBorderKeepArea() and PVP.borderKeepsIds[control.params.keepId] and PVP.currentTooltip ~= control) or (not IsInBorderKeepArea() and control == PVP_World3DCrown) then
			timeline:PlayFromStart()
		end
	end)

	timeline:PlayFromStart()
	return timeline
end

local function StartFlipping3DAnimation(control, targetIcon, targetAlliance)
	local timeline = ANIMATION_MANAGER:CreateTimeline()

	local _, heading = control:Get3DRenderSpaceOrientation()

	PVP:InsertAnimationType(timeline, ANIMATION_ROTATE3D, control, 1000, 0, ZO_EaseInQuadratic, 0, heading, 0, 0,
		heading + 3.141, 0)
	PVP:InsertAnimationType(timeline, ANIMATION_ROTATE3D, control, 750, 1000, ZO_EaseOutQuadratic, 0, heading + 3.141, 0,
		0, heading + 6.283, 0)


	timeline:InsertCallback(function()
		local icon = control.icon
		icon:SetTexture(targetIcon)
	end, 0.377 * timeline:GetDuration())


	timeline:SetHandler('OnStop', function()
		control.params.alliance = targetAlliance
	end)

	timeline:PlayFromStart()
	return timeline
end

local function GetCameraInfoOld()
	-- if IsGameCameraSiegeControlled() then
	-- return PVP.currentCameraDistance, false
	-- end

	local camera = PVP_World3DCameraMeasurement
	local cameraTexture = PVP_World3DCameraMeasurementIcon

	Set3DRenderSpaceToCurrentCamera(camera:GetName())

	local x, z, y = camera:Get3DRenderSpaceOrigin()


	local heading = GetPlayerCameraHeading3D()

	local newX, newY

	if not PVP.currentCameraDistance then
		PVP.currentCameraDistance = GetSetting(SETTING_TYPE_CAMERA,
			CAMERA_SETTING_DISTANCE)
	end

	local cameraX = sin(heading) * 1.5 * (PVP.currentCameraDistance == 0 and 10 or PVP.currentCameraDistance)
	local cameraY = cos(heading) * 1.5 * (PVP.currentCameraDistance == 0 and 10 or PVP.currentCameraDistance)

	newX = x - cameraX
	newY = y - cameraY

	camera:Set3DRenderSpaceOrigin(newX, z, newY)

	cameraTexture:Set3DRenderSpaceOrientation(0, 0, 0)

	local facing = cameraTexture:Is3DQuadFacingCamera()

	local angle = 0

	while cameraTexture:Is3DQuadFacingCamera() == facing do
		angle = angle + pi / 200
		cameraTexture:Set3DRenderSpaceOrientation(angle, 0, 0)
	end

	angle = ZO_HALF_PI - angle

	local cameraDistance2d

	if angle >= 0 then
		cameraDistance2d = cos(angle) * PVP.currentCameraDistance
	else
		if -angle < 0.2 then
			cameraDistance2d = cos(-angle) * PVP.currentCameraDistance
		else
			cameraDistance2d = PVP.currentCameraDistance == 0 and 0 or playerHeight / tan(-angle)
		end
	end

	if IsGameCameraSiegeControlled() then
		cameraDistance2d = PVP.currentCameraDistance
	end

	return cameraDistance2d, angle >= 0, angle, x, y, z
end

local function GetCameraInfo()
	local cameraDistance2d, _, angle, x, y, z

	if PVP.currentCameraInfo then
		cameraDistance2d, angle, x, y, z = PVP.currentCameraInfo.cameraDistance, PVP.currentCameraInfo.cameraAngleZ,
			PVP.currentCameraInfo.cameraX, PVP.currentCameraInfo.cameraY, PVP.currentCameraInfo.cameraZ
	else
		cameraDistance2d, _, angle, x, y, z = GetCameraInfoOld()
	end

	if IsGameCameraSiegeControlled() then
		cameraDistance2d = PVP.currentCameraDistance
	end

	return cameraDistance2d, angle >= 0, angle, x, y, z
end

function PVP:SetupShadow(duration)
	local X, Y = GetMapPlayerPosition('player')
	local globalX, globalY = PVP.GPS:LocalToGlobal(GetMapPlayerPosition("player"))
	if not PVP.shadowInfo then PVP.shadowInfo = {} end
	PVP.shadowInfo.X = X
	PVP.shadowInfo.Y = Y
	PVP.shadowInfo.globalX = globalX
	PVP.shadowInfo.globalY = globalY
	local _, angle, Z
	_, _, angle, _, _, Z = GetCameraInfo()
	Z = Z - angle * 7
	PVP.shadowInfo.Z = Z
	-- end
	PVP.shadowInfo.duration = duration
	PVP.shadowInfo.endTime = GetFrameTimeSeconds() + (duration / 1000)
end

function PVP:ResetShadow()
	PVP.shadowInfo = nil
end

local function ReturnClosestBorderKeepId()
	local playerX, playerY = GetMapPlayerPosition('player')
	local minDistance, foundKeepId
	for keepId in pairs(PVP.borderKeepsIds) do
		local _, targetX, targetY = GetKeepPinInfo(keepId, BGQUERY_LOCAL)
		local distance = zo_distance(playerX, playerY, targetX, targetY)
		if not minDistance or distance < minDistance then
			minDistance = distance
			foundKeepId = keepId
		end
	end
	return foundKeepId
end

local function GetCurrentMapScaleTo3D()
	if PVP.testScale then
		return PVP.testScale
	end
	if not IsActiveWorldBattleground() then
		local borderKeepId = IsInBorderKeepArea()
		local currentMapIndex = GetCurrentMapIndex()
		local doesMapMatchLocation = DoesCurrentMapMatchMapForPlayerLocation()
		if borderKeepId then							--// we are in a border keep area //
			if doesMapMatchLocation or not currentMapIndex then --// the map is actually the map of the border keep area //
				return PVP.borderKeepIdToAreaScale[borderKeepId] or 453
			else
				return 10000 --// the map is cyrodiil //
			end
		elseif IsInImperialCityDistrict() then
			if doesMapMatchLocation then
				return 1068
			else
				return 10000
			end
			-- return 1025
		elseif IsInImperialCity() then --sewers
			-- return 353.35
			-- return 2268
			return 3000
		elseif not currentMapIndex then
			return PVP.borderKeepIdToAreaScale[ReturnClosestBorderKeepId()] --// dirty hack //
		else
			return 10000
		end
	else
		local currentBgScale = PVP:GetBgMapScale(GetCurrentBattlegroundId())

		if currentBgScale then
			return currentBgScale
		elseif PVP.testScale then
			return PVP.testScale
		else
			return 300
		end
	end
end

local function GetFormattedDistanceText(control)
	return ' (' .. string.format("%.0f", control.params.distance * GetCurrentMapScaleTo3D()) .. 'm)'
end

local function interpolate(a, b, t)
	return a + (b - a) * t
end

local function ProcessDynamicControlPosition(control)
	local controlParams = control.params
	local controlType = controlParams.type
	local controlX, controlZ, controlY = control:Get3DRenderSpaceOrigin()
	if not controlType then return controlX, controlZ, controlY end

	local currentCameraInfo = PVP.currentCameraInfo
	-- Get the raw height (without bias)
	local rawHeight
	local cameraHeight = currentCameraInfo and currentCameraInfo.cameraZ or (select(6, GetCameraInfo()))
	if not controlParams.height then
		rawHeight = cameraHeight
	else
		rawHeight = controlParams.height
	end

	-- Apply the bias check before smoothing
	local bias = controlParams.isBgFlag and 10 or 15
	rawHeight = max(rawHeight, cameraHeight)

	-- Smooth the raw height first
	local smoothingFactor = 0.01
	local previousSmoothedRaw = controlParams.smoothedHeight or rawHeight
	local newSmoothedRaw = interpolate(previousSmoothedRaw, rawHeight, smoothingFactor)
	if abs(newSmoothedRaw - rawHeight) < 0.01 then
		newSmoothedRaw = rawHeight
	end

	-- Apply the bias after smoothing
	local targetHeight = newSmoothedRaw + bias

	-- Adjust for specific control types
	if controlType == 'COMPASS' and currentCameraInfo and currentCameraInfo.player3dX then
		local camX, camY, camZ = currentCameraInfo.cameraX, currentCameraInfo.cameraY, currentCameraInfo.cameraZ
		local compassOffset = 500
		if controlParams.name == 'WEST' then
			controlX, controlY = camX - compassOffset, camY
		elseif controlParams.name == 'EAST' then
			controlX, controlY = camX + compassOffset, camY
		elseif controlParams.name == 'NORTH' then
			controlX, controlY = camX, camY - compassOffset
		elseif controlParams.name == 'SOUTH' then
			controlX, controlY = camX, camY + compassOffset
		end
		targetHeight = camZ + PVP.SV.compass3dHeight
	end

	if (controlType == 'SCROLL' or controlType == 'DAEDRIC_ARTIFACT') and currentCameraInfo and currentCameraInfo.current3DX then
		local scaleTo3D = GetCurrentMapScaleTo3D()
		controlX = currentCameraInfo.current3DX + (controlParams.X - currentCameraInfo.currentMapX) * scaleTo3D
		controlY = currentCameraInfo.current3DY + (controlParams.Y - currentCameraInfo.currentMapY) * scaleTo3D
	end

	-- Now we use the height with the correct offset
	controlZ = targetHeight

	-- Store the new smoothed raw height and final smoothed height
	controlParams.smoothedHeight = newSmoothedRaw

	-- Set the control's position
	control:Set3DRenderSpaceOrigin(controlX, controlZ, controlY)
	return controlX, controlZ, controlY
end

local function GetControlSizeForAngles(control, multiplier)
	local controlSize

	--// all numeric coefficients were obtained by black magic //

	if control == PVP_World3DCrown then return 165 * 0.55 end
	controlSize = (control.params.dimensions[2] + captureMeterSizeAdjustment) * multiplier

	if control.params.type == 'GROUP' then controlSize = controlSize * 0.75 end
	return controlSize * 0.55
end

local function GetDistanceMultiplier(control, scaleAdjustment)
	local multiplier
	local initial_multiplier = IsInImperialCity() and PVP_DISTANCE_MAX_MULTIPLIER_IC or PVP_DISTANCE_MAX_MULTIPLIER
	local distanceRatio = initial_multiplier * control.params.distance / (scaleAdjustment * PVP_MAX_DISTANCE)

	if distanceRatio > 1 then
		multiplier = distanceRatio
	else
		multiplier = 1
	end

	return multiplier
end

local function GetActivationInfo()
	local camera = PVP_World3DCameraMeasurement
	Set3DRenderSpaceToCurrentCamera(camera:GetName())
	local preToggleX, preToggleY, preToggleZ = camera:Get3DRenderSpaceOrigin()
	ToggleGameCameraFirstPerson()
	Set3DRenderSpaceToCurrentCamera(camera:GetName())
	local toggledX, toggledY, toggledZ = camera:Get3DRenderSpaceOrigin()
	ToggleGameCameraFirstPerson()
	Set3DRenderSpaceToCurrentCamera(camera:GetName())
	local reToggleX, reToggleY, reToggleZ = camera:Get3DRenderSpaceOrigin()


	if preToggleX == toggledX and preToggleY == toggledY and preToggleZ == toggledZ then return false end --// failed to toggle first person camera

	local resultX, resultY, resultZ
	if preToggleX == reToggleX and preToggleY == reToggleY and preToggleZ == reToggleZ then
		resultX, resultY, resultZ = preToggleX, preToggleY, preToggleZ
	else
		resultX, resultY, resultZ = toggledX, toggledY, toggledZ
	end

	return true, resultX, resultY, resultZ
end

local function SetCaptureBarVisibility(control)
	local divider = control.divider
	local captureBG = control.captureBG
	local captureBar = control.captureBar

	if control.params.showCaptureTexture then
		local isControlFlipping = control.params.flippingPlaying and control.params.flippingPlaying:IsPlaying()

		local toHide = (control.params.percentage == 100 and not GetKeepUnderAttack(control.params.keepId, BGQUERY_LOCAL))
		local neutral = control.params.captureAlliance == 0 or control.params.percentage == 0
		local adjustHiding = (control.params.distance > control.params.scaleAdjustment * PVP.SV.max3DCaptureDistance and PVP.currentTooltip ~= control) or
			isControlFlipping

		divider:SetAlpha(1)
		captureBG:SetAlpha(1)
		captureBar:SetAlpha(1)

		divider:SetHidden(toHide or adjustHiding)
		captureBG:SetHidden(toHide or adjustHiding)
		captureBar:SetHidden(toHide or neutral or adjustHiding)
	else
		divider:SetHidden(true)
		captureBG:SetHidden(true)
		captureBar:SetHidden(true)
	end
end

local function ProcessRallyAnimation(control)
	if not control.params.textureState or control.params.textureState > 96 then
		control.params.textureState = 1
	else
		control.params.textureState = control.params.textureState + 1
	end

	local currentState = (control.params.textureState % 3 == 0)

	if currentState then
		if control.params.type == "RALLY" then
			control.icon:SetTextureCoords(((control.params.textureState / 3 - 1) * 64) / 2048,
				(control.params.textureState / 3 * 64) / 2048, 0, 1)
		elseif control.params.hasRally then
			control.ping:SetTextureCoords(((control.params.textureState / 3 - 1) * 64) / 2048,
				(control.params.textureState / 3 * 64) / 2048, 0, 1)
		end
	end
end

local function GetCurrentMapScaleAdjustment(renew)
	if renew or not PVP.onUpdateInfo then
		return 10000 / GetCurrentMapScaleTo3D()
	else
		return PVP.onUpdateInfo.GetCurrentMapScaleAdjustment
	end
end

local function IsCloseToPlayer(control, selfX, selfY, playerX, playerY)
	if control.params.height then return control.params.height end

	local scaleAdjustment = GetCurrentMapScaleAdjustment()
	if not playerX then
		playerX, playerY = GetMapPlayerPosition('player')
	end

	local distance = zo_distance(selfX, selfY, playerX, playerY)
	if distance <= scaleAdjustment * PVP_POI_HEIGHT_GRACE_DISTANCE / 3 then
		return select(6, GetCameraInfo()) -- Use camera height if close
	end
end

local function IsCloseToObjectiveOrPlayer(control, selfX, selfY, playerX, playerY)
	local scaleAdjustment = GetCurrentMapScaleAdjustment()
	local controlType = control.params.type

	if controlType == 'SCROLL' or controlType == 'DAEDRIC_ARTIFACT' or controlType == 'GROUP' then
		if zo_distance(selfX, selfY, playerX, playerY) <= scaleAdjustment * PVP_MAX_DISTANCE * 0.1 then
			return select(6, GetCameraInfo()) -- Use camera height if close
		end
	end

	local adjustedMaxDistance = scaleAdjustment * PVP_POI_HEIGHT_GRACE_DISTANCE
	local minDistance, foundHeight

	local function FindMin(targetX, targetY, possibleHeight)
		local distance = zo_distance(selfX, selfY, targetX, targetY)
		if (not minDistance or distance < minDistance) and distance <= adjustedMaxDistance then
			minDistance = distance
			foundHeight = possibleHeight
		end
		return minDistance, foundHeight
	end

	for i = 1, GetNumKeeps() do
		local keepId = GetKeepKeysByIndex(i)
		local _, targetX, targetY = GetKeepPinInfo(keepId, BGQUERY_LOCAL)
		if PVP.AVAids[keepId] and PVP.AVAids[keepId][1] and PVP.AVAids[keepId][1].height then
			minDistance, foundHeight = FindMin(targetX, targetY, PVP.AVAids[keepId][1].height)
		end
	end

	if scaleAdjustment == 1 then
		for i = 1, #PVP.delvesCoords do
			local targetX, targetY = PVP.delvesCoords[i].x, PVP.delvesCoords[i].y
			minDistance, foundHeight = FindMin(targetX, targetY, PVP.delvesCoords[i].z)
		end

		for i = 1, #PVP.miscCoords do
			local targetX, targetY = PVP.miscCoords[i].x, PVP.miscCoords[i].y
			minDistance, foundHeight = FindMin(targetX, targetY, PVP.miscCoords[i].z)
		end

		for i = 1, #PVP.ayleidWellsCoords do
			local targetX, targetY = PVP.ayleidWellsCoords[i].x, PVP.ayleidWellsCoords[i].y
			minDistance, foundHeight = FindMin(targetX, targetY, PVP.ayleidWellsCoords[i].z)
		end
	end

	if foundHeight then
		return foundHeight
	elseif controlType ~= 'SCROLL' and controlType ~= 'DAEDRIC_ARTIFACT' then
		return IsCloseToPlayer(control, selfX, selfY, playerX, playerY)
	end
end

local function SetShadowImageColor(control)
	if not PVP.shadowInfo then return end
	local icon = control.icon

	local function GetValidRange()
		if PVP.shadowInfo.slotNumber then
			local testSlot = GetSlotBoundId(PVP.shadowInfo.slotNumber)
			if testSlot == 35445 then
				return true
			elseif testSlot == 35441 then
				return false
			end
		end
		return nil


		-- local x, y = PVP.GPS:LocalToGlobal(GetMapPlayerPosition("player"))
		-- local distance = zo_distance(x, y, PVP.shadowInfo.globalX, PVP.shadowInfo.globalY)

		-- if distance>effectiveMaxDistance and distance<effectiveMaxDistanceFar then
		-- return nil
		-- else
		-- return distance <= effectiveMaxDistance
		-- end
	end

	local inRange = GetValidRange()

	if inRange ~= nil then
		if inRange then
			icon:SetColor(0, 1, 0, 1)
		else
			icon:SetColor(1, 0, 0, 1)
		end
	else
		icon:SetColor(0.6, 0.6, 0.6, 1)
	end

	local timeLeft

	if PVP.shadowInfo.endTime then
		timeLeft = zo_ceil(PVP.shadowInfo.endTime - GetFrameTimeSeconds())
	end
end

local function GetShadowImageTexture()
	local ARGONIAN = 'esoui/art/race/silhouette_argonian'
	local HUMAN = 'esoui/art/race/silhouette_human'
	local KHAJIIT = 'esoui/art/race/silhouette_khajiit'
	local texture

	local raceId = GetUnitRaceId('player')
	local gender = GetUnitGender('player')

	if raceId == 6 then
		texture = ARGONIAN
	elseif raceId == 9 then
		texture = KHAJIIT
	else
		texture = HUMAN
	end

	if gender == 1 then
		texture = texture .. "_female.dds"
	else
		texture = texture .. "_male.dds"
	end

	return texture
end

local function GetControlType(control, data, iconType)
	if iconType == "POI" then
		local pinType = data.pinType

		local mappedType = pinTypes[pinType]
		if mappedType then
			return mappedType
		end

		if ZO_MapPin.KILL_LOCATION_PIN_TYPES[pinType] then
			return 'KILL_LOCATION'
		elseif ZO_MapPin.FORWARD_CAMP_PIN_TYPES[pinType] then
			return 'CAMP'
		elseif PVP.elderScrollsPintypes[pinType] or data.isBgFlag then
			return 'SCROLL'
		elseif PVP.daedricArtifactPintypes[pinType] then
			return 'DAEDRIC_ARTIFACT'
		elseif data.isBgBase then
			return 'BG_BASE'
		elseif data.groupTag then
			return 'GROUP'
		end
	end
end

function PVP:IsMiscPassable(keepId)
	local keepType = GetKeepType(keepId)
	if keepType == KEEPTYPE_MILEGATE then
		if GetKeepDirectionalAccess(keepId, BGQUERY_LOCAL) == KEEP_PIECE_DIRECTIONAL_ACCESS_BIDIRECTIONAL then
			return true
		else
			return false
		end
	elseif keepType == KEEPTYPE_BRIDGE then
		if IsKeepPassable(keepId, BGQUERY_LOCAL) then
			return true
		else
			return false
		end
	end
end

local function GetControlTexture(control, data, iconType)
	local controlTypeToTexture = {
		['CAMP'] = 'esoui/art/icons/mapkey/mapkey_forwardcamp.dds',
		['AYLEID_WELL'] = PVP_TEXTURES_PATH .. 'Ayleid_Well_2.dds',
		['DELVE'] = 'esoui/art/icons/mapkey/mapkey_delve.dds',
		['IC_GRATE'] = "/esoui/art/icons/poi/poi_sewer_complete.dds",
		-- ['MILEGATE'] = 'esoui/art/icons/mapkey/mapkey_artifactgate_open.dds',
		['MILEGATE'] = 'EsoUI/Art/MapPins/AvA_milegate_passable.dds',
		['BRIDGE'] = 'EsoUI/Art/MapPins/AvA_bridge_passable.dds',
		['WAYPOINT'] = PVP_WAYPOINT_TEXTURE,
		['RALLY'] = PVP_RALLY_TEXTURE,
		['PING'] = 'esoui/art/mappins/mapping.dds',
		['BG_POWERUP'] = 'esoui/art/icons/heraldrycrests_weapon_axe_02.dds',
		['WEST'] = PVP_TEXTURES_PATH .. 'W.dds',
		['EAST'] = PVP_TEXTURES_PATH .. 'E.dds',
		['NORTH'] = PVP_TEXTURES_PATH .. 'N.dds',
		['SOUTH'] = PVP_TEXTURES_PATH .. 'S.dds',
		['IC_DOOR'] = (data.doorType == 1) and "esoui/art/icons/mapkey/mapkey_artifactgate_open.dds" or
			"esoui/art/icons/mapkey/mapkey_artifactgate_closed.dds",
		['IC_BASE'] = PVP:GetObjectiveIcon(PVP_ALLIANCE_BASE_IC, data.alliance),
		['IC_VAULT'] = select(4, GetPOIMapInfo(IC_ZONEID, data.poiId)),
		['SEWERS_SIGN'] = PVP_TEXTURES_PATH .. 'wrongWay.dds',
		['BG_BASE'] = ZO_GetGamepadBattlegroundTeamIcon(data.pinType),
		-- ['TOWN_FLAG'] = ZO_MapPin.PIN_DATA[40].texture,
		['TOWN_FLAG'] = "EsoUI/Art/MapPins/battlegrounds_capturePoint_pin_neutral.dds",
	}


	local texture
	local controlType = control.params.type

	if iconType == "POI" then
		if controlType == 'KILL_LOCATION' then
			texture = strgsub(ZO_MapPin.PIN_DATA[data.pinType].texture, 'MapPins', 'compass')
		elseif controlType == 'SCROLL' then
			texture = data.isBgFlag and ZO_MapPin.PIN_DATA[data.pinType].texture or
				strgsub(ZO_MapPin.PIN_DATA[data.pinType].texture, 'MapPins', 'compass')
		elseif controlType == 'DAEDRIC_ARTIFACT' then
			texture = ZO_MapPin.PIN_DATA[data.pinType].texture
		elseif controlType == 'GROUP' then
			if control.params.isGroupLeader then
				texture = 'esoui/art/icons/mapkey/mapkey_groupleader.dds'
			else
				if data.unitClass then
					local classID = data.unitClass
					texture = PVP.classIconsLarge[classID]
				else
					texture = 'esoui/art/icons/mapkey/mapkey_groupmember.dds'
				end
			end
		elseif controlType == 'SHADOW_IMAGE' then
			local iconBG = control.bg
			texture = GetShadowImageTexture()
			iconBG:SetTexture(texture)
			iconBG:SetColor(0, 0, 0, 1)
			iconBG:SetHidden(false)
		elseif controlType == 'COMPASS' then
			texture = controlTypeToTexture[data.name]
		elseif controlType == 'MILEGATE' then
			if PVP:IsMiscPassable(data.keepId) then
				texture = "EsoUI/Art/MapPins/AvA_milegate_passable.dds"
			else
				texture = "EsoUI/Art/MapPins/AvA_milegate_center_destroyed.dds"
			end
		elseif controlType == 'BRIDGE' then
			if PVP:IsMiscPassable(data.keepId) then
				texture = "EsoUI/Art/MapPins/AvA_bridge_passable.dds"
			else
				texture = "EsoUI/Art/MapPins/AvA_bridge_not_passable.dds"
			end
		else
			texture = controlTypeToTexture[controlType]
		end
		return texture
	end
end

local function GetControlColor(control, data, iconType)
	local controlColors = {
		['KILL_LOCATION'] = { 1, 1, 1, 1 },
		['AYLEID_WELL'] = { 0.9, 0.9, 0.9, 1 },
		['DELVE'] = { 0, 1, 0, 1 },
		['IC_GRATE'] = { 1, 1, 1, 1 },
		['WAYPOINT'] = { 1, 1, 1, 1 },
		['RALLY'] = { 1, 1, 1, 1 },
		['BG_POWERUP'] = { 1, 0.3, 0.3, 1 },
		['IC_DOOR'] = { 0.5, 0.5, 0.5, 1 },
		['IC_VAULT'] = { 0, 1, 0, 1 },
		['SEWERS_SIGN'] = { 1, 1, 1, 1 },
		['SCROLL'] = { 1, 1, 1, 1 },
		['DAEDRIC_ARTIFACT'] = { 1, 1, 1, 1 },
		['BG_BASE'] = { 1, 1, 1, 1 },
	}

	local colorR, colorG, colorB, alpha
	local controlType = control.params.type

	if controlType == 'GROUP' then
		if data.isUnitDead then
			colorR, colorG, colorB, alpha = 0.4, 0.4, 0.4, 1
		elseif control.params.isGroupLeader then
			colorR, colorG, colorB, alpha = 1, 0, 1, 1
		elseif data.unitSpecColor then
			colorR, colorG, colorB, alpha = data.unitSpecColor:UnpackRGBA()
		else
			colorR, colorG, colorB, alpha = 1, 1, 1, 1
		end
	elseif controlType == 'CAMP' then
		colorR, colorG, colorB, alpha = PVP:GetTrueAllianceColors(PVP.allianceOfPlayer)
	elseif controlType == 'BRIDGE' then
		if PVP:IsMiscPassable(data.keepId) then
			colorR, colorG, colorB, alpha = 0, 1, 0, 1
		else
			colorR, colorG, colorB, alpha = 1, 0, 0, 1
		end
	elseif controlType == 'MILEGATE' then
		if PVP:IsMiscPassable(data.keepId) then
			colorR, colorG, colorB, alpha = 0, 1, 0, 1
		else
			colorR, colorG, colorB, alpha = 1, 0, 0, 1
		end
	elseif controlType == 'PING' then
		local groupNumber = strgsub(data.pingTag, 'group', '')
		if not control.params.pingColor then control.params.pingColor = PVP.pingsColors[tonumber(groupNumber)] end
		colorR, colorG, colorB, alpha = control.params.pingColor[1] / 255, control.params.pingColor[2] / 255, control.params.pingColor[3] / 255, 1
	elseif controlType == 'IC_BASE' then
		colorR, colorG, colorB, alpha = PVP:GetTrueAllianceColors(data.alliance)
	elseif controlType == 'TOWN_FLAG' then
		control.params.alliance = GetCaptureAreaObjectiveOwner(data.keepId, data.objectiveId, BGQUERY_LOCAL)
		colorR, colorG, colorB, alpha = PVP:GetTrueAllianceColors(control.params.alliance)
	elseif controlType == 'COMPASS' then
		if control.params.name == 'NORTH' then
			colorR, colorG, colorB, alpha = unpack(PVP.SV.compass3dColorNorth)
		else
			colorR, colorG, colorB, alpha = unpack(PVP.SV.compass3dColor)
		end
	else
		colorR, colorG, colorB, alpha = unpack(controlColors[controlType])
	end

	if not alpha then alpha = 1 end

	return colorR, colorG, colorB, alpha
end

local function GetControlSize(control, data, iconType)
	local sizeOffsets = {
		['CAMP'] = -10,
		['AYLEID_WELL'] = -8,
		['DELVE'] = -8,
		['IC_GRATE'] = -13,
		['MILEGATE'] = 0,
		['BRIDGE'] = 0,
		['BG_POWERUP'] = -13,
		['IC_DOOR'] = -14,
		['IC_BASE'] = -9,
		['IC_VAULT'] = -12,
		['SEWERS_SIGN'] = -14,
		['BG_BASE'] = -13,
		['SHADOW_IMAGE'] = -12,
	}


	local POISize, POIUASize
	local controlType = control.params.type

	if control.params.isBgFlag then
		POISize, POIUASize = ICONSIZE - 13, ICONUASIZE - 17
	else
		if controlType == 'RALLY' or controlType == 'WAYPOINT' or controlType == 'PING' or controlType == 'GROUP' then
			local sizeAdjustment = control.params.distance / (control.params.scaleAdjustment * PVP_MAX_DISTANCE)
			if controlType == 'WAYPOINT' or controlType == 'PING' or controlType == 'GROUP' then
				local size
				if controlType == 'WAYPOINT' then
					size = ICONSIZE - 6
				elseif controlType == 'PING' then
					size = ICONSIZE - 6
				else
					if control.params.isGroupLeader then
						size = PVP.SV.groupLeaderIconSize
					else
						size = PVP.SV.groupIconSize
					end
				end

				if sizeAdjustment < 0.25 then
					POISize = size
				elseif controlType == 'GROUP' then
					POISize = 2.5 * size * sizeAdjustment
				else
					POISize = 4 * size * sizeAdjustment
				end
			elseif sizeAdjustment < 0.25 then
				POISize = ICONSIZE - 6
			else
				POISize = 4 * (ICONSIZE - 6) * sizeAdjustment
			end
		elseif controlType == 'COMPASS' then
			if control.params.name == "SOUTH" then
				POISize = 0.8 * PVP.SV.compass3dSize
			elseif control.params.name == "EAST" then
				POISize = 0.8 * PVP.SV.compass3dSize
			elseif control.params.name == "NORTH" then
				POISize = 0.94 * PVP.SV.compass3dSize
			else
				POISize = PVP.SV.compass3dSize
			end
		elseif controlType == 'DAEDRIC_ARTIFACT' then
			POISize = ICONSIZE / 2
		elseif sizeOffsets[controlType] then
			POISize = ICONSIZE + sizeOffsets[controlType]
		else
			POISize = ICONSIZE - 6
		end

		if controlType == 'TOWN_FLAG' then
			POIUASize = POISize - 0.5
		else
			POIUASize = POISize * 1.4
		end
	end

	return POISize, POIUASize
end

local function GetControlHeight(control, data, iconType, dynamicZ)
	local heightOffsets = {
		['AYLEID_WELL'] = 15,
		['DELVE'] = 35,
		['IC_GRATE'] = 7,
		['MILEGATE'] = 38,
		['BRIDGE'] = 38,
		['BG_POWERUP'] = 12,
		['IC_DOOR'] = 7,
		['IC_BASE'] = 15,
		['IC_VAULT'] = 7,
		['SEWERS_SIGN'] = 5,
		['BG_BASE'] = 6,
		['SHADOW_IMAGE'] = 1,
		['SCROLL'] = control.params.isBgFlag and 10 or 15,
		['DAEDRIC_ARTIFACT'] = 15,
		['GROUP'] = 10,
		['TOWN_FLAG'] = 15,
	}

	local controlType = control.params.type
	local height = control.params.height


	if height then
		if heightOffsets[controlType] then
			height = height + heightOffsets[controlType]
		else
			height = height + 25
		end
	elseif control.params.isBgFlag then
		height = dynamicZ + 10
	elseif controlType == 'GROUP' then
		height = dynamicZ + 6
	else
		height = dynamicZ + 15
	end

	return height
end

local function ResetWorldTooltip()
	PVP.currentTooltip = nil
	PVP_WorldTooltipLabel:SetText('')
	PVP_WorldTooltipSubLabel:SetText('')
	PVP_WorldTooltipSiegeLabel:SetText('')
	PVP_WorldTooltipCampaignScoreLabel:SetText('')
	PVP_WorldTooltipCampaignPositionInfoLabel:SetText('')
	PVP_WorldTooltipCampaignHoldingsLabel:SetText('')
	PVP_WorldTooltipEmperorInfoLabel:SetText('')
	PVP_WorldTooltipDividerTop:SetHidden(true)
	PVP_WorldTooltipDividerBottom:SetHidden(true)
	PVP_WorldTooltipBackdrop:SetHidden(true)
	PVP_WorldTooltip:SetHidden(true)
end

function PVP:Init3D()
	if self.controls3DPool then return end

	-- specify a parent control if needed (replace GuiRoot with your intended parent)
	local parentControl = GuiRoot
	self.controls3DPool = ZO_ControlPool:New("PVP_World3D", parentControl)

	local function CustomPoolResetBehaviorControl(control)
		if PVP.currentTooltip == control then
			local controlType = control.params.type
			if controlType == 'GROUP' or controlType == 'SCROLL' or controlType == 'DAEDRIC_ARTIFACT' then
				PVP.savedTooltip = PVP.savedTooltip or {}
				PVP.savedTooltip[control.params.name] =
				{
					isGroup = control.params.groupTag,
					isScroll = control.params.artifactAlliance,
					currentPhase = control.params.currentPhase,
				}
			end
			ResetWorldTooltip()
		end

		control:SetHidden(true)
		control.locked:SetHidden(true)
		control.iconUA:SetHidden(true)
		control.bg:SetHidden(true)
		control.captureBG:SetHidden(true)
		control.captureBar:SetHidden(true)
		control.divider:SetHidden(true)
		control.scroll:SetHidden(true)
		control.flags:SetHidden(true)
		control.apse:SetHidden(true)
		control.nave:SetHidden(true)
		control.other:SetHidden(true)
		control.middle:SetHidden(true)

		control:SetHandler("OnUpdate", nil)
		control.icon:SetTextureCoords(0, 1, 0, 1)
		control.ping:SetTextureCoords(0, 1, 0, 1)
		control.icon:Set3DRenderSpaceUsesDepthBuffer(false)

		if control.params.borderKeepAnimationHandler and control.params.borderKeepAnimationHandler:IsPlaying() then
			control.params.borderKeepAnimationHandler:Stop()
		end
		if control.params.flippingPlaying and control.params.flippingPlaying:IsPlaying() then
			control.params.flippingPlaying:Stop()
		end

		ResetControlPings(control)
		control.params = {}
	end

	local function CustomFactoryBehavior(control)
		control:Create3DRenderSpace()
		for i = 1, control:GetNumChildren() do
			control:GetChild(i):Create3DRenderSpace()
		end
		control.params = {}
		control.locked = control:GetNamedChild('Locked')
		control.icon = control:GetNamedChild('Icon')
		control.iconUA = control:GetNamedChild('IconUA')
		control.bg = control:GetNamedChild('BG')
		control.captureBG = control:GetNamedChild('CaptureBG')
		control.captureBar = control:GetNamedChild('CaptureBar')
		control.divider = control:GetNamedChild('Divider')
		control.scroll = control:GetNamedChild('Scroll')
		control.flags = control:GetNamedChild('Flags')
		control.apse = control:GetNamedChild('Apse')
		control.nave = control:GetNamedChild('Nave')
		control.other = control:GetNamedChild('Other')
		control.middle = control:GetNamedChild('Middle')
		control.name = control:GetNamedChild('Name')
		control.siege = control:GetNamedChild('Siege')
		control.ping = control:GetNamedChild('Ping')
		control.neighbors = control:GetNamedChild('Neighbors')
		control.neighbor1 = control.neighbors and control.neighbors:GetNamedChild('Neighbor1')
		control.neighbor2 = control.neighbors and control.neighbors:GetNamedChild('Neighbor2')
		control.neighbor3 = control.neighbors and control.neighbors:GetNamedChild('Neighbor3')
	end

	self.controls3DPool:SetCustomFactoryBehavior(CustomFactoryBehavior)
	self.controls3DPool:SetCustomResetBehavior(CustomPoolResetBehaviorControl)

	-- Set up 3D render spaces for static elements
	PVP_TestWorld:Create3DRenderSpace()
	PVP_TestWorldIcon:Create3DRenderSpace()
	PVP_TestWorldIcon:Set3DLocalDimensions(8, 8)
	PVP_TestWorld:SetHidden(true)

	PVP_World3DCrown:Create3DRenderSpace()
	PVP_World3DCrownIcon:Create3DRenderSpace()
	PVP_World3DCrownIcon:Set3DLocalDimensions(5, 5)
	PVP_World3DCrown:SetHidden(true)
	PVP_World3DCrown.params = {}

	-- PVP_TestWorldCamera:Create3DRenderSpace()
	-- PVP_TestWorldCameraIcon:Create3DRenderSpace()
	-- PVP_TestWorldCameraIcon:Set3DLocalDimensions(10, 10)
	-- PVP_TestWorldCamera:SetHidden(true)

	PVP_World3DCameraMeasurement:Create3DRenderSpace()
	PVP_World3DCameraMeasurementIcon:Create3DRenderSpace()
	PVP_World3DCameraMeasurementIcon:Set3DLocalDimensions(10, 10)
	PVP_World3DCameraMeasurement:SetHidden(false)
	PVP_World3DCameraMeasurementIcon:SetHidden(true)

	CALLBACK_MANAGER:RegisterCallback("On3DWorldOriginChanged", function ()
		local currentCameraInfo = PVP.currentCameraInfo
		if currentCameraInfo.lastDeltaX and currentCameraInfo.lastDeltaY then
			d("ORIGIN CHANGED")
			local objects = PVP.controls3DPool:GetActiveObjects()
			for k, control in pairs(objects) do
				if control and control:GetName() and control.params.type ~= "COMPASS" then
					local scaleTo3D = GetCurrentMapScaleTo3D()
					local newX = currentCameraInfo.current3DX + (control.params.X - currentCameraInfo.currentMapX) * scaleTo3D
					local newY = currentCameraInfo.current3DY + (control.params.Y - currentCameraInfo.currentMapY) * scaleTo3D
					local _, oldZ, _ = control:Get3DRenderSpaceOrigin()
					control:Set3DRenderSpaceOrigin(newX, oldZ, newY)
				end
			end
		end
	end)

	if not PVP.activeScrolls then
		PVP.activeScrolls = {}
	end
	-- d('3d icons initiazlied!')
	-- PVP:Setup3DMeasurements()
end

function PVP:OnWorldMapChangedCallback()
	if not PVP:Should3DSystemBeOn() then return end
	-- if not PVP.wmcCallbackPending then
	-- PVP.wmcCallbackPending = zo_callLater(function() PVP.wmcCallbackPending = nil if DoesCurrentMapMatchMapForPlayerLocation() then d('map changed callback') PVP:UpdateNearbyKeepsAndPOIs(nil, true) end end, 50)
	-- end
	zo_callLater(
		function() if DoesCurrentMapMatchMapForPlayerLocation() then PVP:UpdateNearbyKeepsAndPOIs(nil, true) end end, 50)
end

function PVP:Should3DSystemBeOn()
	local isEnabled = PVP.SV.enabled and PVP.SV.show3DIcons
	local isInIC = IsInImperialCity() and IsInImperialCityDistrict(true)
	local isInValidLocaton = IsInCyrodiil() or isInIC or PVP:IsInSupportedBattleground() or PVP:IsInSewers()

	return isEnabled and isInValidLocaton
end

local function GetCurrentMapCoordsFromKeepId(keepId)
	local scaleAdjustment = GetCurrentMapScaleAdjustment()

	local keepInfoInDB = PVP.AVAids[keepId]

	local _, coordsNewX, coordsNewY, objectiveId

	if keepInfoInDB and keepInfoInDB[1].objectiveId ~= 0 then
		objectiveId = keepInfoInDB[1].objectiveId
		if PVP.midpointKeepIds[keepId] then
			local _, apseX, apseY = GetObjectivePinInfo(keepId, keepInfoInDB[1].objectiveId, BGQUERY_LOCAL)
			local _, naveX, naveY = GetObjectivePinInfo(keepId, keepInfoInDB[2].objectiveId, BGQUERY_LOCAL)
			coordsNewX = (apseX + naveX) / 2
			coordsNewY = (apseY + naveY) / 2
		elseif PVP:KeepIdToKeepType(keepId) == PVP_KEEPTYPE_ARTIFACT_KEEP then
			_, coordsNewX, coordsNewY = GetKeepPinInfo(keepId, BGQUERY_LOCAL)
		else
			_, coordsNewX, coordsNewY = GetObjectivePinInfo(keepId, objectiveId, BGQUERY_LOCAL)
		end
	else
		if PVP.borderKeepsIds[keepId] and keepInfoInDB[1].coords then
			if IsInBorderKeepArea() then
				coordsNewX = (keepInfoInDB[1].coords.insideCorner1.x + keepInfoInDB[1].coords.insideCorner2.x) / 2
				coordsNewY = (keepInfoInDB[1].coords.insideCorner1.y + keepInfoInDB[1].coords.insideCorner2.y) / 2
			else
				coordsNewX = (keepInfoInDB[1].coords.outsideCorner1.x + keepInfoInDB[1].coords.outsideCorner2.x) / 2
				coordsNewY = (keepInfoInDB[1].coords.outsideCorner1.y + keepInfoInDB[1].coords.outsideCorner2.y) / 2
			end
		else
			_, coordsNewX, coordsNewY = GetKeepPinInfo(keepId, BGQUERY_LOCAL)
		end
	end

	return coordsNewX, coordsNewY, objectiveId, keepInfoInDB, scaleAdjustment
end

local function IsNew3DOrigin(newX, newY, newZ)
	local oldX, oldY, oldZ = PVP.currentCameraInfo.cameraX, PVP.currentCameraInfo.cameraY, PVP.currentCameraInfo.cameraZ

	if abs(newX) < 15 and abs(newY) < 15 and (abs(oldX) > 450 or abs(oldY) > 450) then
		return true
	else
		return false
	end
end

local function GetCurrentTrustedCoords()
	local scaleAdjustment = GetCurrentMapScaleAdjustment()
	local _, current3DX, current3DY, currentMapX, currentMapY, success

	if PVP.controls3DPool:GetActiveObjectCount() > 0 then
		local objects = PVP.controls3DPool:GetActiveObjects()
		for k, v in pairs(objects) do
			if v.params.type ~= 'COMPASS' then
				if v.params.scaleAdjustment == scaleAdjustment then
					current3DX, _, current3DY = v:Get3DRenderSpaceOrigin()
					currentMapX, currentMapY = v.params.X, v.params.Y
					success = true
					break
				elseif v.params.keepId then
					currentMapX, currentMapY = GetCurrentMapCoordsFromKeepId(v.params.keepId)
					current3DX, _, current3DY = v:Get3DRenderSpaceOrigin()
					v.params.X, v.params.Y = currentMapX, currentMapY
					v.params.scaleAdjustment = scaleAdjustment
					success = true
					break
				elseif v.params.objectiveId then
					if v.params.type == 'CTF_BASE' then
						_, currentMapX, currentMapY = GetObjectiveSpawnPinInfo(0, v.params.objectiveId, BGQUERY_LOCAL)
					else
						_, currentMapX, currentMapY = GetObjectivePinInfo(0, v.params.objectiveId, BGQUERY_LOCAL)
					end
					current3DX, _, current3DY = v:Get3DRenderSpaceOrigin()
					v.params.X, v.params.Y = currentMapX, currentMapY
					v.params.scaleAdjustment = scaleAdjustment
					success = true
					break
				end
			end
		end
	end
	return current3DX, current3DY, currentMapX, currentMapY, success
end

local function CalculateCameraOffset()
	local control = PVP_World3DCameraMeasurement
	local textureControl = PVP_World3DCameraMeasurementIcon

	Set3DRenderSpaceToCurrentCamera(control:GetName())

	local cameraX, cameraZ, cameraY = control:Get3DRenderSpaceOrigin()

	local heading = GetPlayerCameraHeading3D()

	local measurementCameraX = sin(heading) * 1.5 * (PVP.currentCameraDistance == 0 and 10 or PVP.currentCameraDistance)
	local measurementCameraY = cos(heading) * 1.5 * (PVP.currentCameraDistance == 0 and 10 or PVP.currentCameraDistance)

	control:Set3DRenderSpaceOrigin(cameraX - measurementCameraX, cameraZ, cameraY - measurementCameraY)

	textureControl:Set3DRenderSpaceOrientation(0, 0, 0)

	local initialCameraFacing = textureControl:Is3DQuadFacingCamera()

	local count = 0
	local TARGET_COUNT = 15

	local function TestHalfInterval(startAngle, endAngle)
		local midPoint = startAngle + (endAngle - startAngle) / 2
		count = count + 1

		if count >= TARGET_COUNT then return midPoint end

		textureControl:Set3DRenderSpaceOrientation(midPoint, 0, 0)

		if textureControl:Is3DQuadFacingCamera() == initialCameraFacing then
			return TestHalfInterval(midPoint, endAngle)
		else
			return TestHalfInterval(startAngle, midPoint)
		end
	end

	local cameraAngleZ = ZO_HALF_PI - TestHalfInterval(0, pi)

	return cameraX, cameraY, cameraZ, cameraAngleZ
end

local function CalculatePlayerDistance(cameraX, cameraY, cameraZ, cameraAngleZ)
	local cameraDistance

	if cameraAngleZ >= 0 then
		cameraDistance = cos(cameraAngleZ) * PVP.currentCameraDistance
	else
		if -cameraAngleZ < 0.2 then
			cameraDistance = cos(-cameraAngleZ) * PVP.currentCameraDistance
		else
			cameraDistance = PVP.currentCameraDistance == 0 and 0 or playerHeight / tan(-cameraAngleZ)
		end
	end

	return cameraDistance
end

local function Take3DMeasurements()
	if PVP.suppressTest and (GetFrameTimeMilliseconds() > (PVP.suppressTest.currentTime + 6000)) then
		if PVP.LMP:IsPingSuppressed(MAP_PIN_TYPE_PING, PVP.suppressTest.playerGroupTag) then
			PVP.LMP:UnsuppressPing(
				MAP_PIN_TYPE_PING, PVP.suppressTest.playerGroupTag)
		end
		PVP.suppressTest = nil
	end

	PVP.currentCameraDistance = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)

	PVP.onUpdateInfo = PVP.onUpdateInfo or {}
	PVP.onUpdateInfo.IsInBorderKeepArea = IsInBorderKeepArea(true)
	PVP.onUpdateInfo.GetCurrentMapScaleAdjustment = GetCurrentMapScaleAdjustment(true)
	PVP.onUpdateInfo.IsInImperialCityDistrict = IsInImperialCity() and IsInImperialCityDistrict(true) or false
	PVP.onUpdateInfo.GetPlayerCameraHeading = GetPlayerCameraHeading3D(true)

	local cameraX, cameraY, cameraZ, cameraAngleZ = CalculateCameraOffset()
	local cameraDistance = CalculatePlayerDistance(cameraX, cameraY, cameraZ, cameraAngleZ)

	if PVP.currentCameraInfo then
		if IsNew3DOrigin(cameraX, cameraY, cameraZ) then
			PVP.currentCameraInfo.lastDeltaX = cameraX - PVP.currentCameraInfo.cameraX
			PVP.currentCameraInfo.lastDeltaY = cameraY - PVP.currentCameraInfo.cameraY
			PVP.currentCameraInfo.last3dX = PVP.currentCameraInfo.current3DX
			PVP.currentCameraInfo.last3dY = PVP.currentCameraInfo.current3DY
			PVP.currentCameraInfo.lastMapX = PVP.currentCameraInfo.currentMapX
			PVP.currentCameraInfo.lastMapY = PVP.currentCameraInfo.currentMapY
		end
	end

	local current3DX, current3DY, currentMapX, currentMapY, success = GetCurrentTrustedCoords()
	-- d(success)

	local player3dX, player3dY

	if success then
		local selfX, selfY = GetMapPlayerPosition('player')
		player3dX = current3DX + (selfX - currentMapX) * GetCurrentMapScaleTo3D()
		player3dY = current3DY + (selfY - currentMapY) * GetCurrentMapScaleTo3D()
	end

	PVP.currentCameraInfo = PVP.currentCameraInfo or {}
	PVP.currentCameraInfo = {
		adjustedHeading = GetAdjustedPlayerCameraHeading(true),
		cameraX = cameraX,
		cameraY = cameraY,
		cameraZ = cameraZ,
		cameraAngleZ = cameraAngleZ,
		cameraDistance = cameraDistance,
		timeStamp = GetFrameTimeMilliseconds(),
		lastDeltaX = PVP.currentCameraInfo.lastDeltaX,
		lastDeltaY = PVP.currentCameraInfo.lastDeltaY,
		current3DX = current3DX,
		current3DY = current3DY,
		currentMapX = currentMapX,
		currentMapY = currentMapY,
		player3dX = player3dX,
		player3dY = player3dY
	}

	return cameraDistance, cameraX, cameraY
end

local function OnWorldMapHidden(oldState, newState)
	-- d(newState)
	if newState == SCENE_HIDDEN then
		PVP:UpdateNearbyKeepsAndPOIs()
	end
end

function PVP:Setup3DMeasurements()
	PVP.currentCameraInfo = nil
	WORLD_MAP_SCENE:UnregisterCallback("StateChange", OnWorldMapHidden)
	PVP_World3DCameraMeasurement:SetHandler('OnUpdate', nil)
	if self.SV.enabled and PVP:Should3DSystemBeOn() then
		WORLD_MAP_SCENE:RegisterCallback("StateChange", OnWorldMapHidden)
		Take3DMeasurements()
		PVP_World3DCameraMeasurement:SetHandler("OnUpdate", function() Take3DMeasurements() end)
	end
end

local function GetCurrent3DCameraInfo()
	if PVP.currentCameraInfo then
		return PVP.currentCameraInfo.cameraX, PVP.currentCameraInfo.cameraY, PVP.currentCameraInfo.cameraZ,
			PVP.currentCameraInfo.adjustedHeading, PVP.currentCameraInfo.cameraAngleZ, PVP.currentCameraInfo.cameraDistance,
			PVP.currentCameraInfo.timeStamp
	else
		return false
	end
end

function PVP:KeepIdToKeepType(keepId)
	if not keepId then return end
	local keepType = GetKeepResourceType(keepId)

	if keepType == 0 then
		keepType = GetKeepType(keepId)
		if keepType == KEEPTYPE_ARTIFACT_KEEP then
			keepType = PVP_KEEPTYPE_ARTIFACT_KEEP
		elseif keepType == KEEPTYPE_BORDER_KEEP then
			keepType = PVP_KEEPTYPE_BORDER_KEEP
		end
	end
	return keepType
end

-- function PVP:KeepTypeToInternalType(keepType)
-- if keepType == KEEPTYPE_ARTIFACT_KEEP then
-- keepType = PVP_KEEPTYPE_ARTIFACT_KEEP
-- elseif keepType == KEEPTYPE_BORDER_KEEP then
-- keepType = PVP_KEEPTYPE_BORDER_KEEP
-- end
-- return keepType
-- end

local function KeepIdToHeight(keepId)
	local height
	local keepType = PVP:KeepIdToKeepType(keepId)

	if keepType == KEEPTYPE_KEEP then
		height = PVP_ICON_HEIGHT_KEEP
	elseif keepType == KEEPTYPE_OUTPOST then
		height = PVP_ICON_HEIGHT_OUTPOST
	elseif keepType == KEEPTYPE_TOWN then
		height = PVP_ICON_HEIGHT_TOWN
	elseif keepType == PVP_KEEPTYPE_ARTIFACT_KEEP then
		height = PVP_ICON_HEIGHT_ARTIFACT_KEEP
	elseif keepType == PVP_KEEPTYPE_BORDER_KEEP then
		if IsInBorderKeepArea() == keepId then
			height = PVP_ICON_HEIGHT_BORDER_KEEP_INSIDE
		else
			height = PVP_ICON_HEIGHT_BORDER_KEEP
		end
	elseif keepType == KEEPTYPE_ARTIFACT_GATE then
		height = PVP_ICON_HEIGHT_ARTIFACT_GATE
	elseif keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
		height = PVP_ICON_HEIGHT_IMPERIAL_CITY_DISTRICT
	else
		height = PVP_ICON_HEIGHT_RESOURCE
	end
	return height
end

local function KeepTypeToIconSize(keepType, keepId)
	local isMine = keepType == 3

	local iconSizeX, iconUASizeX

	if keepType == KEEPTYPE_KEEP then
		iconSizeX = ICONSIZE
		iconUASizeX = ICONUASIZE
	elseif keepType == KEEPTYPE_OUTPOST then
		iconSizeX = ICONSIZE
		iconUASizeX = ICONUASIZE
	elseif keepType == KEEPTYPE_TOWN then
		iconSizeX = ICONSIZE
		iconUASizeX = ICONUASIZE + 2
	elseif keepType == PVP_KEEPTYPE_ARTIFACT_KEEP then
		iconSizeX = ICONSIZE
		iconUASizeX = ICONUASIZE
	elseif keepType == PVP_KEEPTYPE_BORDER_KEEP then
		if IsInBorderKeepArea() == keepId then
			iconSizeX = ICONSIZE / 1.9
			iconUASizeX = ICONUASIZE / 1.8
		else
			iconSizeX = ICONSIZE
			iconUASizeX = ICONUASIZE
		end
	elseif keepType == KEEPTYPE_ARTIFACT_GATE then
		iconSizeX = ICONSIZE - 4
		iconUASizeX = ICONUASIZE - 4
	elseif keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
		iconSizeX = iconSizeResource - 6
		iconUASizeX = iconSizeResource - 6
	else
		if isMine then
			iconSizeX = iconSizeResource - 2
		else
			iconSizeX = iconSizeResource
		end
		iconUASizeX = iconUASizeResource
	end
	return iconSizeX, iconUASizeX
end

local function KeepIdToIconSize(keepId, keepIdType)
	local keepType = keepIdType or PVP:KeepIdToKeepType(keepId)

	return KeepTypeToIconSize(keepType, keepId)
end


local function IsScrollInKeepId(keepId, keepIdType)
	local isKeep = keepIdType == KEEPTYPE_KEEP
	local isArtifactKeep = keepIdType == PVP_KEEPTYPE_ARTIFACT_KEEP
	if not (isKeep or isArtifactKeep) then return false end
	for k, v in pairs(PVP.elderScrollsIds) do
		local _, _, scrollState = GetObjectiveInfo(k, v, BGQUERY_LOCAL)
		if isArtifactKeep and scrollState == OBJECTIVE_CONTROL_STATE_FLAG_AT_BASE and keepId == k then
			local mappin = GetObjectivePinInfo(k, v, BGQUERY_LOCAL)
			return true, strgsub(ZO_MapPin.PIN_DATA[mappin].texture, 'MapPins', 'compass')
		end
		if isKeep and scrollState == OBJECTIVE_CONTROL_STATE_FLAG_AT_ENEMY_BASE then
			local keepArtifactStorage = PVP.AVAids[keepId][3]
			if not keepArtifactStorage then return end
			local keepArtifactNodeId = keepArtifactStorage.objectiveId
			if not keepArtifactNodeId or keepArtifactNodeId == 0 then return false end
			local _, keepCapturePointX, keepCapturePointY = GetObjectivePinInfo(keepId, keepArtifactNodeId, BGQUERY_LOCAL)
			local mappin, scrollX, scrollY = GetObjectivePinInfo(k, v, BGQUERY_LOCAL)
			if keepCapturePointX == scrollX and keepCapturePointY == scrollY then
				return true, strgsub(ZO_MapPin.PIN_DATA[mappin].texture, 'MapPins', 'compass')
			end
		end
	end
	return false
end

local function CheckIfLockedAlliance(keepIdA, keepIdB, links)
	for _, v in ipairs(links) do
		if (v[1] == keepIdA and v[2] == keepIdB) or (v[1] == keepIdB and v[2] == keepIdA) then
			return true
		end
	end
end

local function IsAllianceAllowedLink(keepIdA, keepIdB)

	local keepAlliance = GetKeepAlliance(keepIdA, BGQUERY_LOCAL)

	if keepAlliance == 1 and not (CheckIfLockedAlliance(keepIdA, keepIdB, dcLinks) or CheckIfLockedAlliance(keepIdA, keepIdB, epLinks)) then return true end
	if keepAlliance == 2 and not (CheckIfLockedAlliance(keepIdA, keepIdB, adLinks) or CheckIfLockedAlliance(keepIdA, keepIdB, dcLinks)) then return true end
	if keepAlliance == 3 and not (CheckIfLockedAlliance(keepIdA, keepIdB, adLinks) or CheckIfLockedAlliance(keepIdA, keepIdB, epLinks)) then return true end
end

local function CanKeepBeTraveledTo(keepId, keepAlliance)
	if not GetKeepHasResourcesForTravel(keepId, BGQUERY_LOCAL) then return end
	local connectedKeeps = connectedKeepsArray[keepId]
	if connectedKeeps then
		for _, v in ipairs(connectedKeeps) do
			local sameAlliance = GetKeepAlliance(v, BGQUERY_LOCAL) == keepAlliance
			local isBorderKeep = GetKeepType(v) == KEEPTYPE_BORDER_KEEP

			if sameAlliance then
				if isBorderKeep or (IsAllianceAllowedLink(keepId, v) and not GetKeepUnderAttack(v, BGQUERY_LOCAL) and GetKeepHasResourcesForTravel(v, BGQUERY_LOCAL)) then
					return true
				end
			end
		end
	end
end

local function IsKeepLocked(keepId, keepIdType, keepAlliance)
	local isValidKeep = (keepIdType == KEEPTYPE_KEEP) or (keepIdType == KEEPTYPE_OUTPOST)

	if isValidKeep and not CanKeepBeTraveledTo(keepId, keepAlliance) then
		return true
	end
end

local function IsFlagInObjectiveId(objectiveId)
	local flagState = GetObjectiveControlState(0, objectiveId, BGQUERY_LOCAL)
	if flagState == OBJECTIVE_CONTROL_STATE_FLAG_AT_BASE then
		local mappin = GetObjectivePinInfo(0, objectiveId, BGQUERY_LOCAL)
		return true, ZO_MapPin.PIN_DATA[mappin].texture
	end
	return false
end

local function SetupNormalWorldTooltip(altAlign)
	PVP_WorldTooltipBackdrop:SetHidden(true)
	PVP_WorldTooltipDividerTop:SetHidden(true)
	PVP_WorldTooltipDividerBottom:SetHidden(true)

	PVP_WorldTooltip:ClearAnchors()
	PVP_WorldTooltip:SetAnchor(TOPLEFT, GuiRoot, CENTER, 30, -15)
	PVP_WorldTooltipLabel:ClearAnchors()
	PVP_WorldTooltipLabel:SetAnchor(TOPLEFT, PVP_WorldTooltip, TOPLEFT, 0, 0)
	PVP_WorldTooltipLabel:SetFont('$(BOLD_FONT)|$(KB_20)|thick-outline')
	PVP_WorldTooltipSubLabel:ClearAnchors()
	PVP_WorldTooltipSiegeLabel:ClearAnchors()
	if altAlign then
		PVP_WorldTooltipSubLabel:SetAnchor(TOPLEFT, PVP_WorldTooltipLabel, BOTTOMLEFT, 0, 4)
		PVP_WorldTooltipSiegeLabel:SetAnchor(TOPLEFT, PVP_WorldTooltipSubLabel, BOTTOMLEFT, 0, 0)
	else
		PVP_WorldTooltipSubLabel:SetAnchor(TOP, PVP_WorldTooltipLabel, BOTTOM, 0, 2)
		PVP_WorldTooltipSiegeLabel:SetAnchor(TOP, PVP_WorldTooltipSubLabel, BOTTOM, 0, 0)
	end
	PVP_WorldTooltipCampaignScoreLabel:SetText('')
	PVP_WorldTooltipCampaignHoldingsLabel:SetText('')
	PVP_WorldTooltipEmperorInfoLabel:SetText('')
	PVP_WorldTooltipCampaignPositionInfoLabel:SetText('')
end

local function SetControlInitialSize(control)
	local controlIconSize, controlIconUASize, controlBGSize
	if IsActiveWorldBattleground() then
		controlIconSize, controlIconUASize = ICONSIZE - 8, ICONUASIZE - 13
	else
		controlIconSize, controlIconUASize = KeepIdToIconSize(control.params.keepId)
	end
	controlBGSize = controlIconUASize + 2
	SetDimensions3DControl(control, controlIconSize, controlIconUASize, controlBGSize)

	control.params.dimensions = { controlIconSize, controlIconUASize, controlBGSize }
end

local function ControlHasMouseOver(control, multiplier, heading)
	local controlSize = GetControlSizeForAngles(control, multiplier)

	local controlX, controlZ, controlY = ProcessDynamicControlPosition(control)

	if control.params.type == 'COMPASS' then return false end

	-- local controlX, controlZ, controlY = control:Get3DRenderSpaceOrigin()
	local oldOrigin, _, angleZ, cameraX, cameraY, cameraZ = GetCameraInfo()

	if not oldOrigin then return end

	local distance = zo_distance(cameraX, cameraY, controlX, controlY)

	local deltaX = controlX - cameraX
	local deltaY = controlY - cameraY
	local deltaZ = controlZ - cameraZ

	local controlHeading = asin(abs(deltaX) / distance)

	if deltaY > 0 then
		controlHeading = pi - controlHeading
	end

	if deltaX > 0 then
		controlHeading = -controlHeading
	end

	local controlGraceAngle = atan(0.5 * controlSize / distance)

	if heading > controlHeading - controlGraceAngle and heading < controlHeading + controlGraceAngle then
		local lowerBoundZ, higherBoundZ

		lowerBoundZ = atan2((deltaZ - 0.5 * controlSize), distance)
		higherBoundZ = atan2((deltaZ + 0.5 * controlSize), distance)
		local distanceCheck = control.params.distance and PVP.currentTooltip and PVP.currentTooltip.params.distance and
			control.params.distance < PVP.currentTooltip.params.distance


		local validTooltipStatus = not PVP.currentTooltip or PVP.currentTooltip == control or distanceCheck

		if (-angleZ > lowerBoundZ and -angleZ < higherBoundZ) and validTooltipStatus then
			return true
		else
			return false
		end
	end
end

local function GetAllianceColoredString(text, alliance)
	return PVP:Colorize(text, PVP:AllianceToColor(alliance))
end

local function GetUpgradeLevelString(control)
	local upgradeLevelToTexture = {
		-- [0] = "",
		[1] = "esoui/art/tutorial/ava_rankicon_general.dds",
		[2] = "esoui/art/tutorial/ava_rankicon_warlord.dds",
		[3] = "esoui/art/tutorial/ava_rankicon_grandwarlord.dds",
		[4] = "esoui/art/tutorial/ava_rankicon_overlord.dds",
		[5] = "esoui/art/tutorial/ava_rankicon_grandoverlord.dds",
	}

	local upgradeNumber
	local keepId = control.params.keepId
	if keepId then
		if GetKeepResourceType(keepId) ~= 0 then
			upgradeNumber = GetKeepDefensiveLevel(keepId, BGQUERY_LOCAL)
		elseif GetKeepType(keepId) == KEEPTYPE_KEEP then
			local combinedUpgradeLevel = 0
			for i = 1, 3 do
				combinedUpgradeLevel = combinedUpgradeLevel + GetKeepResourceLevel(keepId, 1, i)
			end
			upgradeNumber = tonumber(string.format("%.0f", combinedUpgradeLevel / 3))
		end
	end
	if upgradeNumber and upgradeNumber > 0 then
		return zo_iconFormatInheritColor(upgradeLevelToTexture[upgradeNumber], 32, 32)
	else
		return ""
	end
end


local function GetEmperorInfoString(isWorldCrown)
	local text, accountNameFromDB, unitCharNameFromDB, formattedEmperorName
	local currentCampaignId = PVP.currentCampaignId
	local userDisplayNameType = PVP.SV.userDisplayNameType or PVP.defaults.userDisplayNameType
	local emperorAlliance, emperorRawName, emperorAccName = GetCampaignEmperorInfo(currentCampaignId)
	if emperorAlliance == ALLIANCE_NONE then
		text = PVP:Colorize("No emperor is currently reigning!", 'CCCCCC')
	else
		accountNameFromDB, unitCharNameFromDB = GetPvpDbPlayerInfo(emperorRawName, false)
		if unitCharNameFromDB and (unitCharNameFromDB ~= "") then
			formattedEmperorName = PVP:GetTargetChar(unitCharNameFromDB, 35, 35)
		else
			if userDisplayNameType == "both" then
				formattedEmperorName = PVP:GetEmperorIcon(35, PVP:GetTrueAllianceColorsHex(emperorAlliance)) ..
					GetAllianceColoredString(emperorRawName, emperorAlliance) .. PVP:Colorize(emperorAccName, 'CCCCCC')
			elseif userDisplayNameType == "character" then
				formattedEmperorName = PVP:GetEmperorIcon(35, PVP:GetTrueAllianceColorsHex(emperorAlliance)) ..
					GetAllianceColoredString(emperorRawName, emperorAlliance)
			elseif userDisplayNameType == "user" then
				formattedEmperorName = PVP:GetEmperorIcon(35, PVP:GetTrueAllianceColorsHex(emperorAlliance)) ..
					GetAllianceColoredString(emperorAccName, emperorAlliance)
			end
		end

		if isWorldCrown then
			local reignTime = GetCampaignEmperorReignDuration(currentCampaignId)
			text = PVP:Colorize('Emperor ', 'CCCCCC') ..
				formattedEmperorName .. PVP:Colorize(' reigning for ' .. PVP:SecondsToClock(floor(reignTime)),
					'CCCCCC')
		else
			text = PVP:Colorize('Current Emperor is: ', 'CCCCCC') .. formattedEmperorName
		end
	end
	return text
end

local function GetCampaignInfoString(alliance)
	local currentCampaignId = PVP.currentCampaignId
	local isAssignedCampaign = GetAssignedCampaignId() == currentCampaignId
	local campaignTypeString
	if isAssignedCampaign then
		campaignTypeString = " (Assigned)"
	else
		campaignTypeString = ""
	end
	local currentCampaignName = GetCampaignName(currentCampaignId)
	local text = PVP:Colorize('Welcome to the ', 'CCCCCC') ..
		PVP:Colorize(currentCampaignName, PVP:AllianceToColor(alliance)) ..
		PVP:Colorize(campaignTypeString .. ' campaign!', 'CCCCCC')
	return text
end

local function GetBorderKeepInfoString(keepId, alliance)
	local text = PVP:Colorize("You're at ", 'CCCCCC') ..
		PVP:Colorize(zo_strformat(SI_ALERTTEXT_LOCATION_FORMAT, GetKeepName(keepId)),
			PVP:AllianceToColor(alliance)) .. PVP:Colorize(' border keep!', 'CCCCCC')
	return text
end

local function GetHoldingsInfoString(alliance)
	local allianceToIconName = {
		[1] = 'aldmeri',
		[2] = 'ebonheart',
		[3] = 'daggefall',
	}
	local currentCampaignId = PVP.currentCampaignId
	local numKeeps = GetTotalCampaignHoldings(currentCampaignId, HOLDINGTYPE_KEEP, alliance)
	local numResources = GetTotalCampaignHoldings(currentCampaignId, HOLDINGTYPE_RESOURCE, alliance)
	local numOutposts = GetTotalCampaignHoldings(currentCampaignId, HOLDINGTYPE_OUTPOST, alliance)
	local numScrolls = GetTotalCampaignHoldings(currentCampaignId, HOLDINGTYPE_DEFENSIVE_ARTIFACT, alliance) +
		GetTotalCampaignHoldings(currentCampaignId, HOLDINGTYPE_OFFENSIVE_ARTIFACT, alliance)
	-- local allianceIcon = 'esoui/art/campaign/overview_allianceicon_' .. allianceToIconName[alliance] .. '.dds'
	local keepIcon = 'esoui/art/campaign/overview_keepicon_' .. allianceToIconName[alliance] .. '.dds'
	local outpostIcon = 'esoui/art/campaign/overview_outposticon_' .. allianceToIconName[alliance] .. '.dds'
	local resourceIcon = 'esoui/art/campaign/overview_resourcesicon_' .. allianceToIconName[alliance] .. '.dds'
	local scrollIcon = 'esoui/art/campaign/overview_scrollicon_' .. allianceToIconName[alliance] .. '.dds'
	local text = GetAllianceColoredString(GetAllianceName(alliance), alliance) ..
		PVP:Colorize(' holds: ', 'CCCCCC') ..
		zo_iconFormat(keepIcon, 45, 45) ..
		GetAllianceColoredString(tostring(numKeeps) .. "(18)", alliance) ..
		zo_iconFormat(outpostIcon, 41, 41) ..
		GetAllianceColoredString(tostring(numOutposts) .. "(3)", alliance) ..
		zo_iconFormat(resourceIcon, 38, 38) ..
		GetAllianceColoredString(tostring(numResources) .. "(54)", alliance) ..
		zo_iconFormat(scrollIcon, 44, 44) .. GetAllianceColoredString(numScrolls, alliance)
	return text
end

local function GetScoringInfoString()
	local currentCampaignId = PVP.currentCampaignId
	local function ReturnCampaignScoresInAscendingOrder()
		local scores = {}
		for i = 1, 3 do
			insert(scores, { GetCampaignAllianceScore(currentCampaignId, i), i })
		end

		local function sortingFn(score1, score2)
			return score1[1] > score2[1]
		end

		sort(scores, sortingFn)

		return GetAllianceColoredString(scores[1][1], scores[1][2]),
			GetAllianceColoredString(scores[2][1], scores[2][2]),
			GetAllianceColoredString(scores[3][1], scores[3][2])
	end

	if not GetCampaignAllianceScore(currentCampaignId, BGQUERY_LOCAL) then
		return PVP:Colorize("Campaign Score is not available at the moment!", 'CCCCCC')
	end

	local first, second, third = ReturnCampaignScoresInAscendingOrder()

	local text = PVP:Colorize('Campaign Score is: ', 'CCCCCC') .. first .. ' / ' .. second .. ' / ' .. third
	return text
end

local function GetCampaignPositionInfoString(alliance)
	local currentCampaignId = PVP.currentCampaignId
	local currentRanking, currentAP
	local formattedPlayerName = PVP:GetFormattedName(PVP.playerName)
	for i = 1, GetNumCampaignAllianceLeaderboardEntries(currentCampaignId, alliance) do
		local isPlayer, ranking, charName, alliancePoints = GetCampaignAllianceLeaderboardEntryInfo(
			currentCampaignId, alliance, i)
		if isPlayer and formattedPlayerName == charName then
			currentRanking = ranking
			currentAP = alliancePoints
			break
		end
	end

	local text

	if not currentRanking then
		text = "There're no records about you in this campaign yet!"
	else
		text = PVP:Colorize('You are ', 'CCCCCC') ..
			PVP:Colorize('#' .. currentRanking, PVP:AllianceToColor(alliance)) ..
			PVP:Colorize(' in your alliance with ', 'CCCCCC') ..
			PVP:Colorize(currentAP, PVP:AllianceToColor(alliance)) .. PVP:Colorize(' AP!', 'CCCCCC')
	end
	return text
end

local function ControlOnUpdate(control)
	local params = control.params
	local keepId = params.keepId
	local currentTime = GetFrameTimeMilliseconds()
	if currentTime - params.lastUpdate < 10 then
		return
	end
	params.lastUpdate = currentTime

	local scaleAdjustment = GetCurrentMapScaleAdjustment()
	if Hide3DControl(control, scaleAdjustment) then
		return
	end

	local multiplier = GetDistanceMultiplier(control, scaleAdjustment)
	control.multiplier = multiplier

	local isControlFlipping = params.flippingPlaying and params.flippingPlaying:IsPlaying() or false
	local isBorderAnimPlaying = params.borderKeepAnimationHandler and params.borderKeepAnimationHandler:IsPlaying() or false
	local showBorderKeepInfo = IsInBorderKeepArea() and PVP.borderKeepsIds[keepId]

	if IsInImperialCityDistrict() and PVP.districtKeepIdToSubzoneNumber[keepId] then
		local _, subzoneId = GetCurrentSubZonePOIIndices()
		if PVP.districtKeepIdToSubzoneNumber[keepId] == subzoneId or isControlFlipping or not control.captureBG:IsHidden() then
			control:SetAlpha(1)
		else
			control:SetAlpha(PVP.SV.neighboringDistrictsAlpha)
		end
		if control:GetAlpha() < 0.01 then
			return
		end
	else
		control:SetAlpha(1)
	end

	if params.hasRally then
		ProcessRallyAnimation(control)
	end

	local heading = GetAdjustedPlayerCameraHeading()
	local showTooltip = false

	if ControlHasMouseOver(control, multiplier, heading) then
		local alliance = params.alliance
		control:SetAlpha(1)
		PVP_WorldTooltipLabel:SetColor(PVP:HtmlToColor(PVP:AllianceToColor(alliance)))

		if showBorderKeepInfo then
			PVP_WorldTooltip:ClearAnchors()
			PVP_WorldTooltip:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
			PVP_WorldTooltipLabel:ClearAnchors()
			PVP_WorldTooltipLabel:SetAnchor(TOP, PVP_WorldTooltip, TOP, 0, 0)
			PVP_WorldTooltipLabel:SetText(GetCampaignInfoString(alliance))
			PVP_WorldTooltipLabel:SetFont('$(BOLD_FONT)|$(KB_28)|thick-outline')
			PVP_WorldTooltipSubLabel:SetText(GetBorderKeepInfoString(keepId, alliance))
			PVP_WorldTooltipCampaignScoreLabel:SetText(GetScoringInfoString())
			PVP_WorldTooltipCampaignHoldingsLabel:SetText(GetHoldingsInfoString(alliance))
			PVP_WorldTooltipEmperorInfoLabel:SetText(GetEmperorInfoString())
			PVP_WorldTooltipCampaignPositionInfoLabel:SetText(GetCampaignPositionInfoString(alliance))

			PVP_WorldTooltipBackdrop:SetHidden(false)
			PVP_WorldTooltipDividerTop:SetHidden(false)
			PVP_WorldTooltipDividerBottom:SetHidden(false)
			PVP_WorldTooltipBackdrop:SetCenterColor(PVP:HtmlToColor(PVP:AllianceToColor(alliance, true)))
			PVP_WorldTooltipBackdrop:SetEdgeColor(PVP:HtmlToColor(PVP:AllianceToColor(alliance)))

			local x, y = PVP_WorldTooltip:GetDimensions()
			PVP_WorldTooltipBackdrop:SetDimensions(x + 35, y + 50)
			PVP_WorldTooltipSubLabel:ClearAnchors()
			PVP_WorldTooltipSubLabel:SetAnchor(TOP, PVP_WorldTooltipLabel, BOTTOM, 0, 4)
			PVP_WorldTooltipSiegeLabel:ClearAnchors()
			PVP_WorldTooltipSiegeLabel:SetAnchor(TOP, PVP_WorldTooltipSubLabel, BOTTOM, 0, 0)
		else
			local keepNotClaimable = nonClaimableKeepTypes[GetKeepType(keepId)]
			local guildClaimName = ""
			if not keepNotClaimable then
				guildClaimName = GetClaimedKeepGuildName(keepId, BGQUERY_LOCAL) or ""
				if guildClaimName ~= "" then
					guildClaimName = PVP:Colorize("Guild Owner: ", 'C5C29F') ..
						PVP:Colorize(guildClaimName, PVP:AllianceToColor(alliance))
				else
					guildClaimName = PVP:Colorize("Guild Owner: ", 'C5C29F') ..
						PVP:Colorize("Unclaimed", "808080")
				end
			end

			local siegeCount = ""
			if control.totalSieges > 0 then
				local siegeAD = params.siegesAD > 0 and (" " .. PVP:Colorize(tostring(params.siegesAD), PVP:AllianceToColor(1))) or ""
				local siegeDC = params.siegesDC > 0 and (" " .. PVP:Colorize(tostring(params.siegesDC), PVP:AllianceToColor(3))) or ""
				local siegeEP = params.siegesEP > 0 and (" " .. PVP:Colorize(tostring(params.siegesEP), PVP:AllianceToColor(2))) or ""
				siegeCount = "Siege:" .. siegeAD .. siegeDC .. siegeEP
			end

			if keepNotClaimable then
				PVP_WorldTooltipSubLabel:SetText(siegeCount)
				PVP_WorldTooltipSiegeLabel:SetText("")
			else
				PVP_WorldTooltipSubLabel:SetText(guildClaimName)
				PVP_WorldTooltipSiegeLabel:SetText(siegeCount)
			end

			local distanceText = GetUpgradeLevelString(control) .. GetFormattedDistanceText(control)
			PVP_WorldTooltipLabel:SetText(zo_strformat(SI_ALERTTEXT_LOCATION_FORMAT, GetKeepName(keepId)) .. distanceText)
			SetupNormalWorldTooltip(true)
		end

		if PVP.currentTooltip ~= control then
			params.currentPhase = IsPopPhaseValid(params.currentPhase) and params.currentPhase or 1
		end
		PVP.currentTooltip = control
		showTooltip = true
		SetCaptureBarVisibility(control)
		PVP_WorldTooltip:SetHidden(false)
	end

	if not showTooltip and PVP.currentTooltip == control then
		ResetWorldTooltip()
		SetCaptureBarVisibility(control)
		params.currentPhase = IsPopPhaseValid(params.currentPhase) and params.currentPhase or GetNumberOfAnimationPhases()
	end

	if PVP.currentTooltip == control or isControlFlipping then
		local dims = params.dimensions
		local popMultiplier = GetPopInMultiplier(multiplier, control)
		SetDimensions3DControl(control, dims[1] * popMultiplier, dims[2] * popMultiplier, dims[3] * popMultiplier)
	end

	if showBorderKeepInfo and PVP.currentTooltip ~= control then
		if not isBorderAnimPlaying then
			params.borderKeepAnimationHandler = StartBorderKeep3DAnimation(control)
		end
	else
		if isBorderAnimPlaying then
			params.borderKeepAnimationHandler:Stop()
		end
		if not isControlFlipping then
			control:Set3DRenderSpaceOrientation(0, heading, 0)
		end
	end
end

local function GetBattlegroundNameString(bgAllianceHexColor)
	local text = PVP:Colorize('Welcome to ', 'CCCCCC') ..
		PVP:Colorize(GetPlayerLocationName(), bgAllianceHexColor) .. PVP:Colorize(' battleground!', 'CCCCCC')
	return text
end

local function GetBattlegroundTypeString(battlegroundGameType, bgAllianceHexColor)
	local text = PVP:Colorize('The gametype is ', 'CCCCCC') ..
		PVP:Colorize(PVP:GetBattlegroundTypeText(battlegroundGameType), bgAllianceHexColor) ..
		PVP:Colorize('!', 'CCCCCC')
	return text
end

local function GetBattlegroundAllianceString(alliance, bgAllianceHexColor)
	local text = PVP:Colorize("You're playing on ", 'CCCCCC') ..
		PVP:Colorize(GetBattlegroundTeamName(alliance), bgAllianceHexColor) ..
		PVP:Colorize(' team!', 'CCCCCC')
	return text
end

local function GetBattlegroundDescriptionString(battlegroundDescription)
	local text = PVP:Colorize(battlegroundDescription, 'CCCCCC')
	return text
end

local function GetBattlegroundStateString(battlegroundState)
	local battlegroundStateString
	if battlegroundState == BATTLEGROUND_STATE_PREROUND then
		battlegroundStateString = "Waiting for players..."
	elseif battlegroundState == BATTLEGROUND_STATE_STARTING then
		battlegroundStateString = "The match starts in " ..
			tostring(zo_round(GetCurrentBattlegroundStateTimeRemaining() / 1000))
	elseif battlegroundState == BATTLEGROUND_STATE_RUNNING then
		battlegroundStateString = "The match is running"
	else
		battlegroundStateString = ""
	end

	local text = PVP:Colorize(battlegroundStateString, 'CCCCCC')
	return text
end

local function GetBattlegroundTeamsInfo()
	local countSL, countFD, countPD = 0, 0, 0

	for i = 1, GetNumScoreboardEntries() do
		local alliance = GetScoreboardEntryBattlegroundTeam(i)
		if alliance == BATTLEGROUND_TEAM_FIRE_DRAKES then
			countFD = countFD + 1
		elseif alliance == BATTLEGROUND_TEAM_PIT_DAEMONS then
			countPD = countPD + 1
		elseif alliance == BATTLEGROUND_TEAM_STORM_LORDS then
			countSL = countSL + 1
		end
	end

	local text
	-- FD/SL/PD
	text = PVP:Colorize('The teams currently have: ', 'CCCCCC') ..
		PVP:Colorize(countFD, PVP:BgAllianceToHexColor(BATTLEGROUND_TEAM_FIRE_DRAKES)) ..
		' ' ..
		PVP:Colorize(countSL, PVP:BgAllianceToHexColor(BATTLEGROUND_TEAM_STORM_LORDS)) ..
		' ' .. PVP:Colorize(countPD, PVP:BgAllianceToHexColor(BATTLEGROUND_TEAM_PIT_DAEMONS))
	return text
end

local function GetBattlegroundPositionInfoString(battlegroundGameType, bgAllianceHexColor)

	local battlegroundLeaderboardTypes = {
		[BATTLEGROUND_GAME_TYPE_CAPTURE_THE_FLAG] = BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES,
		[BATTLEGROUND_GAME_TYPE_DEATHMATCH] = BATTLEGROUND_LEADERBOARD_TYPE_DEATHMATCH,
		[BATTLEGROUND_GAME_TYPE_KING_OF_THE_HILL] = BATTLEGROUND_LEADERBOARD_TYPE_LAND_GRAB,
		[BATTLEGROUND_GAME_TYPE_DOMINATION] = BATTLEGROUND_LEADERBOARD_TYPE_LAND_GRAB,
		[BATTLEGROUND_GAME_TYPE_CRAZY_KING] = BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES,
		[BATTLEGROUND_GAME_TYPE_MURDERBALL] = BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES
	}	

	local battlegroundLeaderboardType = battlegroundLeaderboardTypes[battlegroundGameType]

	local position, points

	if battlegroundLeaderboardType then
		position, points = GetBattlegroundLeaderboardLocalPlayerInfo(battlegroundLeaderboardType)
	end

	local text

	if not battlegroundLeaderboardType or position == 0 then
		text = PVP:Colorize("There're no records about you in this leaderboard yet!", 'CCCCCC')
	else
		text = PVP:Colorize('You are ', 'CCCCCC') ..
			PVP:Colorize('#' .. position, bgAllianceHexColor) ..
			PVP:Colorize(' in the leaderboards ', 'CCCCCC') ..
			PVP:Colorize(points, bgAllianceHexColor) .. PVP:Colorize(' points!', 'CCCCCC')
	end
	return text
end

local function PoiOnUpdate(control)
	local controlParams = control.params
	local currentTime = GetFrameTimeMilliseconds()
	-- if controlParams.type == 'COMPASS' or (currentTime - controlParams.lastUpdate) >=5 then
	if (currentTime - controlParams.lastUpdate) >= 10 then
		controlParams.lastUpdate = currentTime
	else
		return
	end
	local scaleAdjustment = GetCurrentMapScaleAdjustment()
	local multiplier = GetDistanceMultiplier(control, scaleAdjustment)
	local showTooltip
	local controlType = controlParams.type
	local name = controlParams.name
	local alliance = controlParams.alliance

	local shouldBgBaseHasEnhancedTooltip = controlType == 'BG_BASE' and alliance == GetUnitBattlegroundTeam('player') and
		GetCurrentBattlegroundState() ~= BATTLEGROUND_STATE_RUNNING

	if controlType == 'RALLY' or controlParams.hasRally then
		ProcessRallyAnimation(control)
	end

	if controlType == 'SHADOW_IMAGE' then
		SetShadowImageColor(control)
	end

	if Hide3DControl(control, scaleAdjustment) then return end

	if icControls[controlType] and not controlParams.isCurrent then
		if PVP.currentTooltip == control then ResetWorldTooltip() end
		return
	end

	local heading = GetAdjustedPlayerCameraHeading()
	if ControlHasMouseOver(control, multiplier, heading) then
		local wasRestored, controllingCharacter, artifactAlliance, artifactOriginalAlliance
		if dynamicControls[controlType] then
			if PVP.savedTooltip and PVP.savedTooltip[name] then
				controlParams.currentPhase = PVP.savedTooltip[name].currentPhase
				PVP.savedTooltip[controlParams.name] = nil
				wasRestored = true
			end
			controllingCharacter = controlParams.controllingCharacter
			artifactAlliance = controlParams.artifactAlliance
			artifactOriginalAlliance = controlParams.artifactOriginalAlliance
		end

		control:SetAlpha(1)

		local mainText

		if shouldBgBaseHasEnhancedTooltip then
			local battlegroundId = GetCurrentBattlegroundId()
			local battlegroundGameType = GetBattlegroundGameType(battlegroundId)
			--local battlegroundName = GetBattlegroundName(battlegroundId)
			local battlegroundDescription = GetBattlegroundDescription(battlegroundId)
			local battlegroundState = GetCurrentBattlegroundState()
			local bgAllianceHexColor = PVP:BgAllianceToHexColor(alliance)

			PVP_WorldTooltipLabel:SetText(GetBattlegroundNameString(bgAllianceHexColor))
			PVP_WorldTooltipSubLabel:SetText(GetBattlegroundTypeString(battlegroundGameType, bgAllianceHexColor))
			PVP_WorldTooltipCampaignScoreLabel:SetText(GetBattlegroundAllianceString(alliance, bgAllianceHexColor))
			PVP_WorldTooltipCampaignHoldingsLabel:SetText(GetBattlegroundTeamsInfo())
			PVP_WorldTooltipEmperorInfoLabel:SetText(GetBattlegroundStateString(battlegroundState))
			PVP_WorldTooltipCampaignPositionInfoLabel:SetText(GetBattlegroundPositionInfoString(battlegroundGameType, bgAllianceHexColor))
		else
			local keepId = controlParams.keepId
			if controlType == 'IC_BASE' then
				mainText = GetAllianceName(alliance) .. ' base'
			elseif controlType == 'IC_DOOR' then
				local prefix
				if controlParams.doorType == 1 then
					prefix = 'To '
				else
					prefix = 'From '
				end
				mainText = PVP:Colorize(prefix, '808080') ..
					PVP:Colorize(name, PVP:AllianceToColor(GetKeepAlliance(controlParams.doorDistrictKeepId, BGQUERY_LOCAL)))
			elseif controlType == 'BG_BASE' then
				mainText = GetBattlegroundTeamName(alliance) .. ' base'
			elseif controlType == 'GROUP' then
				local formattedName = PVP:GetTargetChar(name)
				mainText = formattedName and formattedName or zo_strformat(SI_PLAYER_NAME, name)
			elseif name then
				mainText = name
			else
				mainText = 'Tooltip'
			end

			local distanceText = GetFormattedDistanceText(control)

			if controlType == 'IC_DOOR' then
				distanceText = PVP:Colorize(distanceText, '808080')
			end

			if controlType ~= 'COMPASS' then
				mainText = mainText .. distanceText
			end

			if alliance and not (controlType == 'MILEGATE' or controlType == 'BRIDGE') then
				-- if (controlType == 'MILEGATE' or controlType == 'BRIDGE') then
				-- if alliance ~= ALLIANCE_NONE then
				-- mainText = PVP:Colorize(mainText, PVP:AllianceToColor(GetKeepAlliance(alliance, BGQUERY_LOCAL)))
				-- else
				-- mainText = PVP:Colorize(mainText, '808080')
				-- end
				if controlType == 'BG_BASE' then
					mainText = PVP:Colorize(mainText, PVP:BgAllianceToHexColor(alliance))
				else
					mainText = PVP:Colorize(mainText, PVP:AllianceToColor(alliance))
				end
			elseif controlType == 'MILEGATE' then
				if PVP:IsMiscPassable(keepId) then
					mainText = PVP:Colorize(mainText, '00FF00')
				else
					mainText = PVP:Colorize(mainText, 'FF0000')
				end
			elseif controlType == 'BRIDGE' then
				if PVP:IsMiscPassable(keepId) then
					mainText = PVP:Colorize(mainText, '00FF00')
				else
					mainText = PVP:Colorize(mainText, 'FF0000')
				end
			elseif controlType == 'DELVE' then
				mainText = PVP:Colorize(mainText, '00FF00')
			elseif controlType == 'WAYPOINT' or controlType == 'PING' then
				mainText = PVP:Colorize(mainText, '00FFFF')
			elseif controlType == 'RALLY' then
				mainText = PVP:Colorize(mainText, 'CE9051')
			elseif controlType == 'BG_POWERUP' then
				mainText = PVP:Colorize(mainText, '00E5E5')
			elseif controlType == 'CAMP' then
				mainText = PVP:Colorize(mainText, PVP:AllianceToColor(PVP.allianceOfPlayer))
			elseif controlType == 'SCROLL' then
				if controlParams.isBgFlag then
					if controlParams.artifactAlliance ~= ALLIANCE_NONE then
						mainText = PVP:Colorize(mainText,
							PVP:BgAllianceToHexColor(GetCaptureFlagObjectiveOriginalOwningAlliance(0,
								controlParams.isBgFlag, BGQUERY_LOCAL)))
					else
						mainText = PVP:Colorize(mainText, '808080')
					end
					local carrierName = GetCarryableObjectiveHoldingCharacterInfo(0, controlParams.isBgFlag,
						BGQUERY_LOCAL)
					if carrierName and carrierName ~= "" then
						mainText = mainText ..
							PVP:Colorize(' carried by ', '808080') ..
							PVP:Colorize(zo_strformat(SI_UNIT_NAME, carrierName),
								PVP:BgAllianceToHexColor(artifactAlliance))
					end
				else
					if artifactAlliance ~= ALLIANCE_NONE then
						local carrierToken = PVP:GetTargetChar(controllingCharacter, 35, 35)
						carrierToken = carrierToken and ("\n          " .. carrierToken) or ""
						mainText = PVP:Colorize(mainText, PVP:AllianceToColor(artifactAlliance)) .. carrierToken
					else
						mainText = PVP:Colorize(mainText .. '\n          (Uncontrolled)', '808080')
					end
					if artifactOriginalAlliance ~= ALLIANCE_NONE then
						mainText = PVP:Colorize(
							zo_iconFormatInheritColor(
								PVP:GetObjectiveIcon(PVP_ALLIANCE_BASE_IC, artifactOriginalAlliance), 48, 48),
							PVP:AllianceToColor(artifactOriginalAlliance)) .. mainText
					end
				end
			elseif controlType == 'DAEDRIC_ARTIFACT' then
				if artifactAlliance ~= ALLIANCE_NONE then
					local carrierToken = PVP:GetTargetChar(controllingCharacter, 35, 35)
					carrierToken = carrierToken and ("\n " .. carrierToken) or ""
					mainText = PVP:Colorize(mainText, PVP:AllianceToColor(artifactAlliance)) .. carrierToken
				else
					mainText = "\n" .. PVP:Colorize(mainText, '808080')
				end
		elseif controlType == 'IC_VAULT' then
				mainText = PVP:Colorize(mainText, '00FF00')
			elseif controlType == 'IC_GRATE' then
				mainText = PVP:Colorize(mainText, 'FFFFFF')
			else
				mainText = PVP:Colorize(mainText, 'AAAAAA')
			end
		end

		showTooltip = true

		if PVP.currentTooltip ~= control then
			if wasRestored then
				if controlParams.currentPhase > GetNumberOfAnimationPhases() then
					controlParams.currentPhase = GetNumberOfAnimationPhases()
				end
			else
				controlParams.currentPhase = IsPopPhaseValid(controlParams.currentPhase) and controlParams.currentPhase or 1
			end
		end

		PVP.currentTooltip = control

		if shouldBgBaseHasEnhancedTooltip then
			PVP_WorldTooltipLabel:SetFont('$(BOLD_FONT)|$(KB_28)|thick-outline')
			PVP_WorldTooltip:ClearAnchors()
			PVP_WorldTooltip:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
			PVP_WorldTooltipLabel:ClearAnchors()
			PVP_WorldTooltipLabel:SetAnchor(TOP, PVP_WorldTooltip, TOP, 0, 0)

			PVP_WorldTooltipBackdrop:SetHidden(false)
			PVP_WorldTooltipDividerTop:SetHidden(false)
			PVP_WorldTooltipDividerBottom:SetHidden(false)
			PVP_WorldTooltipBackdrop:SetCenterColor(PVP:HtmlToColor(PVP:BgAllianceToHexColor(alliance),
				true))
			PVP_WorldTooltipBackdrop:SetEdgeColor(PVP:HtmlToColor(PVP:BgAllianceToHexColor(alliance)))

			local x, y = PVP_WorldTooltip:GetDimensions()
			PVP_WorldTooltipBackdrop:SetDimensions(x + 35, y + 50)
			PVP_WorldTooltipSubLabel:ClearAnchors()
			PVP_WorldTooltipSubLabel:SetAnchor(TOP, PVP_WorldTooltipLabel, BOTTOM, 0, 4)
			PVP_WorldTooltipSiegeLabel:ClearAnchors()
			PVP_WorldTooltipSiegeLabel:SetAnchor(TOP, PVP_WorldTooltipSubLabel, BOTTOM, 0, 0)
		else
			PVP_WorldTooltipLabel:SetText(mainText)
			PVP_WorldTooltipLabel:SetColor(0.8, 0.8, 0.8)
			SetupNormalWorldTooltip(false)
			PVP_WorldTooltipSubLabel:SetText('')
			PVP_WorldTooltipSiegeLabel:SetText('')
		end
		PVP_WorldTooltip:SetHidden(false)
	end
	-- end

	if not showTooltip and PVP.currentTooltip == control then
		ResetWorldTooltip()
		controlParams.currentPhase = IsPopPhaseValid(controlParams.currentPhase) and controlParams.currentPhase or GetNumberOfAnimationPhases()
	end

	local adjustedMultiplier = GetPOIControlSelectedSizeMultiplier(control, scaleAdjustment, multiplier)

	local popMultiplier

	if PVP.currentTooltip ~= control then
		popMultiplier = GetPopOutMultiplier(adjustedMultiplier, control)
	else
		popMultiplier = GetPopInMultiplier(adjustedMultiplier, control)
	end

	if controlType == 'BG_BASE' and GetCurrentBattlegroundState() ~= BATTLEGROUND_STATE_RUNNING and PVP.currentTooltip ~= control then
		if not (control.battlegroundTeamSignAnimationHandler and control.battlegroundTeamSignAnimationHandler:IsPlaying()) then
			control.battlegroundTeamSignAnimationHandler = StartBorderKeep3DAnimation(control)
		end
	else
		if (control.battlegroundTeamSignAnimationHandler and control.battlegroundTeamSignAnimationHandler:IsPlaying()) then
			control.battlegroundTeamSignAnimationHandler:Stop()
		end
		if controlType ~= 'SEWERS_SIGN' then
			control:Set3DRenderSpaceOrientation(0, heading, 0)
		else
			control:Set3DRenderSpaceOrientation(0, controlParams.orientation3d and controlParams.orientation3d or 0, 0)
		end
	end

	if controlType ~= 'COMPASS' then
		SetDimensions3DControl(control, controlParams.dimensions[1] * popMultiplier,
			controlParams.dimensions[2] * popMultiplier, controlParams.dimensions[3] * popMultiplier)
	end

	if controlType == 'BG_BASE' and PVP.currentTooltip ~= control and GetCurrentBattlegroundState() == BATTLEGROUND_STATE_RUNNING and GetBattlegroundGameType(GetCurrentBattlegroundId()) ~= BATTLEGROUND_GAME_TYPE_DEATHMATCH and alliance ~= GetUnitBattlegroundTeam('player') then
		control:SetAlpha(0.5)
	elseif controlType == 'GROUP' and not (PVP.SV.allgroup3d or (controlParams.isGroupLeader and PVP.SV.groupleader3d)) then
		local distanceThreshold = 0.1 * scaleAdjustment * PVP_MAX_DISTANCE
		if controlParams.distance < distanceThreshold then
			control:SetAlpha(0)
		elseif controlParams.distance < 1.5 * distanceThreshold then
			local targetAlpha = (controlParams.distance - distanceThreshold) / 0.5 / distanceThreshold
			control:SetAlpha(targetAlpha)
		else
			control:SetAlpha(1)
		end
	else
		control:SetAlpha(1)
	end
end

local function CrownOnUpdate()
	local heading = GetAdjustedPlayerCameraHeading()
	local playerX, playerY = GetMapPlayerPosition('player')
	local distance = zo_distance(playerX, playerY, PVP.icCoords.x, PVP.icCoords.y)
	local alpha
	local crownMaxDistance = 0.2
	local maxAlpha = 0.6

	if distance > (crownMaxDistance - 0.005) then
		alpha = 0
	elseif distance < (crownMaxDistance - 0.02) then
		alpha = maxAlpha
	else
		alpha = -(maxAlpha / 0.015) * (distance - crownMaxDistance + 0.005)
	end

	PVP_World3DCrownIcon:SetAlpha(alpha)

	if ControlHasMouseOver(PVP_World3DCrown, 1, heading) then
		PVP.currentTooltip = PVP_World3DCrown
		PVP.currentTooltip.params.distance = distance
		PVP_WorldTooltip:SetHidden(false)

		local WORLD_CROWN = true
		PVP_WorldTooltipLabel:SetText(GetEmperorInfoString(WORLD_CROWN))
		SetupNormalWorldTooltip(false)
	elseif PVP.currentTooltip == PVP_World3DCrown then
		ResetWorldTooltip()
	end
end

local function GetSiegeIcon(siegesAD, siegesEP, siegesDC)
	local activeSiegesAD = siegesAD > 0 and '_AD' or ''
	local activeSiegesEP = siegesEP > 0 and '_EP' or ''
	local activeSiegesDC = siegesDC > 0 and '_DC' or ''
	return 'PvpAlerts/textures/pin' .. activeSiegesAD .. activeSiegesDC .. activeSiegesEP .. '.dds'
end

local function SetupNew3DMarker(keepId, distance, isActivated, isNewObjective)
	if not keepId or keepId == 0 or keepId == "" then return end
	-- PVP.m1 = GetGameTimeMilliseconds()
	local coordsNewX, coordsNewY, objectiveId, keepInfoInDB, scaleAdjustment = GetCurrentMapCoordsFromKeepId(keepId)

	if coordsNewX == 0 and coordsNewY == 0 then return end

	PVP.currentNearbyKeepIds = PVP.currentNearbyKeepIds or {}

	local control, key

	if not PVP.currentNearbyKeepIds[keepId] then
		control, key = PVP.controls3DPool:AcquireObject()
		control.poolKey = key
	else
		control = PVP.currentNearbyKeepIds[keepId]
	end

	-- local vars for controls
	local lock = control.locked
	local icon = control.icon
	local iconUA = control.iconUA
	local iconBG = control.bg
	local scroll = control.scroll
	local ping = control.ping


	control.params.distance = distance
	control.params.X = coordsNewX
	control.params.Y = coordsNewY
	control.params.scaleAdjustment = scaleAdjustment
	control.params.keepId = keepId

	local keepType = PVP:KeepIdToKeepType(keepId)
	local keepAlliance = GetKeepAlliance(keepId, BGQUERY_LOCAL)
	local isUnderAttack = GetKeepUnderAttack(keepId, BGQUERY_LOCAL)
	
	local iconTexture = PVP:GetObjectiveIcon(keepType, keepAlliance, control.params.keepId)
	icon:SetTexture(iconTexture)
	icon:SetColor(1, 1, 1)

	local isControlFlipping = control.params.flippingPlaying and control.params.flippingPlaying:IsPlaying()
	if not isControlFlipping then
		if control.params.alliance and control.params.alliance ~= keepAlliance then
			control.params.flippingPlaying = StartFlipping3DAnimation(control,
				PVP:GetObjectiveIcon(keepType, keepAlliance, control.params.keepId), keepAlliance)
			control.params.currentPhase = IsPopPhaseValid(control.params.currentPhase) and control.params.currentPhase or
				1
		else
			control.params.alliance = keepAlliance
		end
	end

	local isSkirmish = IsSkirmishCloseToObjective(keepType == KEEPTYPE_ARTIFACT_GATE or
		keepType == PVP_KEEPTYPE_ARTIFACT_KEEP, coordsNewX, coordsNewY,
		scaleAdjustment)
	iconUA:SetTexture('/esoui/art/mappins/ava_attackburst_64.dds')
	local shouldHideUA = not (isUnderAttack or isSkirmish)
	iconUA:SetHidden(shouldHideUA)
	iconUA:SetColor(1, 1, 1)

	local isScroll, scrollTexture = IsScrollInKeepId(keepId, keepType)
	if scrollTexture then
		scroll:SetTexture(scrollTexture)
	else
		scrollTexture = ""
	end
	scroll:SetHidden(not isScroll)

	local shouldHideLock = not IsKeepLocked(keepId, keepType, keepAlliance)
	lock:SetHidden(shouldHideLock)
	lock:SetColor(1, 0, 0)

	local controlHasPing = control.params.hasRally or control.params.hasWaypoint

	if controlHasPing then
		if control.params.hasRally then
			ping:SetTexture(PVP_RALLY_TEXTURE)
		elseif control.params.hasWaypoint then
			ping:SetTexture(PVP_WAYPOINT_TEXTURE)
		end
		ping:SetColor(1, 1, 1)
	end

	ping:SetHidden(not controlHasPing)


	local shouldHideFlags = not (keepType == KEEPTYPE_KEEP or keepType == KEEPTYPE_OUTPOST or keepType == KEEPTYPE_TOWN)
	local naveFlag, apseFlag, otherFlag, naveAlliance, apseAlliance, otherAlliance
	-- PVP.m2 = GetGameTimeMilliseconds()

	if not shouldHideFlags then
		local flags = control.flags
		local apse = control.apse
		local nave = control.nave
		local other = control.other
		local middle = control.middle

		local isTown = keepType == KEEPTYPE_TOWN
		local isKeep = keepType == KEEPTYPE_KEEP
		if isTown then
			flags:SetTexture(PVP_TEXTURES_PATH .. '3barsTemplateLargeFilled.dds')
			middle:SetTexture(PVP_TEXTURES_PATH .. '3barsMiddleLineLarge.dds')
		else
			flags:SetTexture(PVP_TEXTURES_PATH .. '2barsTemplateLargeFilled.dds')
			middle:SetTexture(PVP_TEXTURES_PATH .. '2barsMiddleLineLarge.dds')
		end
		flags:SetColor(PVP:GetTrueAllianceColors(keepAlliance))
		flags:SetHidden(false)
		middle:SetHidden(false)

		local navePercent
		local apsePercent
		local otherPercent
		local naveId, apseId, otherId, naveObjectiveState, apseObjectiveState, otherObjectiveState

		naveId = PVP.AVAids[control.params.keepId][2].objectiveId
		apseId = PVP.AVAids[control.params.keepId][1].objectiveId

		naveObjectiveState = select(3, GetObjectiveInfo(control.params.keepId, naveId, BGQUERY_LOCAL))
		apseObjectiveState = select(3, GetObjectiveInfo(control.params.keepId, apseId, BGQUERY_LOCAL))

		naveAlliance = GetCaptureAreaObjectiveOwner(control.params.keepId, naveId, BGQUERY_LOCAL)
		apseAlliance = GetCaptureAreaObjectiveOwner(control.params.keepId, apseId, BGQUERY_LOCAL)

		if naveAlliance == 0 and not isUnderAttack then
			naveAlliance = keepAlliance
		end
		if apseAlliance == 0 and not isUnderAttack then
			apseAlliance = keepAlliance
		end

		navePercent = PVP:GetCapturePercentFromAlliance(naveObjectiveState, keepAlliance, naveAlliance)
		apsePercent = PVP:GetCapturePercentFromAlliance(apseObjectiveState, keepAlliance, apseAlliance)

		if isTown then
			otherId = PVP.AVAids[control.params.keepId][3].objectiveId
			otherObjectiveState = select(3, GetObjectiveInfo(control.params.keepId, otherId, BGQUERY_LOCAL))
			otherAlliance = GetCaptureAreaObjectiveOwner(control.params.keepId, otherId, BGQUERY_LOCAL)
			if otherAlliance == 0 and not isUnderAttack then
				otherAlliance = keepAlliance
			end
			otherPercent = PVP:GetCapturePercentFromAlliance(otherObjectiveState, keepAlliance, otherAlliance)
		end

		naveFlag = 'flag2Large_'
		apseFlag = isTown and 'flag1Large_' or 'flag3Large_'
		otherFlag = 'flag3Large_'

		if not navePercent or navePercent == 0 then
			nave:SetHidden(true)
			naveFlag = nil
		else
			naveFlag = PVP_TEXTURES_PATH .. naveFlag .. tostring(navePercent) .. '.dds'
			nave:SetTexture(naveFlag)
			nave:SetColor(PVP:GetTrueAllianceColors(naveAlliance))
			nave:SetHidden(false)
		end

		if not apsePercent or apsePercent == 0 then
			apse:SetHidden(true)
			apseFlag = nil
		else
			apseFlag = PVP_TEXTURES_PATH .. apseFlag .. tostring(apsePercent) .. '.dds'
			apse:SetTexture(apseFlag)
			apse:SetColor(PVP:GetTrueAllianceColors(apseAlliance))
			apse:SetHidden(false)
		end

		if not otherPercent or otherPercent == 0 then
			other:SetHidden(true)
			otherFlag = nil
		else
			otherFlag = PVP_TEXTURES_PATH .. otherFlag .. tostring(otherPercent) .. '.dds'
			other:SetTexture(otherFlag)
			other:SetColor(PVP:GetTrueAllianceColors(otherAlliance))
			other:SetHidden(false)
		end
	end

	-- PVP.m3 = GetGameTimeMilliseconds()

	local showCaptureTexture = objectiveId and
		(GetKeepResourceType(control.params.keepId) ~= 0 or GetKeepType(control.params.keepId) == KEEPTYPE_IMPERIAL_CITY_DISTRICT)

	control.params.showCaptureTexture = showCaptureTexture
	local captureTexture = ""

	if showCaptureTexture then
		local isCapture
		local _, _, objectiveState = GetObjectiveInfo(control.params.keepId, objectiveId, BGQUERY_LOCAL)
		local captureAlliance = GetCaptureAreaObjectiveOwner(control.params.keepId, objectiveId, BGQUERY_LOCAL)

		if captureAlliance == 0 and not isUnderAttack then
			captureAlliance = keepAlliance
		end

		local percentage = PVP:GetCapturePercentFromAlliance(objectiveState, GetKeepAlliance(control.params.keepId, BGQUERY_LOCAL),
			captureAlliance)

		if percentage == 40 then
			percentage = 50
		elseif percentage == 51 then
			percentage = 50
		end

		if control.params.percentage then
			if (control.params.captureAlliance == captureAlliance and percentage > control.params.percentage) or control.params.captureAlliance == 0 or control.params.captureAlliance ~= captureAlliance then
				isCapture = true
			elseif control.params.captureAlliance == captureAlliance and percentage == control.params.percentage then
				isCapture = control.params.isCapture
			end
		else
			isCapture = captureAlliance ~= keepAlliance
		end

		control.params.percentage = percentage
		control.params.captureAlliance = captureAlliance
		control.params.isCapture = isCapture

		SetCaptureBarVisibility(control)

		local toHide = (percentage == 100 and not isUnderAttack)
		local neutral = captureAlliance == 0 or percentage == 0

		if not (toHide or neutral) then
			captureTexture = PVP:GetCaptureTexture(captureAlliance, isCapture, percentage)
			local captureBar = control.captureBar
			captureBar:SetTexture(captureTexture)
		end
	end

	--PVP.m4 = GetGameTimeMilliseconds()

	SetCaptureBarVisibility(control)

	local siegeTexture

	local siegesAD = GetNumSieges(control.params.keepId, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
	local siegesEP = GetNumSieges(control.params.keepId, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
	local siegesDC = GetNumSieges(control.params.keepId, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
	local totalSieges = siegesAD + siegesEP + siegesDC

	control.params.siegesAD = siegesAD
	control.params.siegesEP = siegesEP
	control.params.siegesDC = siegesDC
	control.totalSieges = totalSieges

	if totalSieges > 0 then
		siegeTexture = GetSiegeIcon(siegesAD, siegesEP, siegesDC)
		iconBG:SetTexture(siegeTexture)
		iconBG:SetColor(1, 1, 1)
		iconBG:SetHidden(false)
	else
		iconBG:SetHidden(true)
	end


	local showBorderKeepInfo = IsInBorderKeepArea() and PVP.borderKeepsIds[control.params.keepId]
	-- local isBorderKeepAnimationPlaying = control.params.borderKeepAnimationHandler and
	-- 	control.params.borderKeepAnimationHandler:IsPlaying()

	SetControlInitialSize(control)

	Hide3DControl(control, scaleAdjustment)
	local keepName = zo_strformat(SI_ALERTTEXT_LOCATION_FORMAT, GetKeepName(control.params.keepId)) ..
		GetUpgradeLevelString(control)

	if PVP.SV.showOnScreen and not PVP.SV.unlocked then
		local neighbors = IsPlayerNearObjective(control.params.keepId)
		if neighbors then
			PVP:ManageOnScreen(iconTexture, scrollTexture, captureTexture, naveFlag, apseFlag, otherFlag, naveAlliance,
				apseAlliance, otherAlliance, siegeTexture, shouldHideUA, shouldHideLock, not isScroll,
				not (showCaptureTexture and not (control.params.percentage == 100 and not isUnderAttack)),
				shouldHideFlags, totalSieges <= 0, control.params.siegesAD, control.params.siegesDC,
				control.params.siegesEP, keepName, control.params.keepId, PVP_OnScreen)
			PVP_OnScreen.currentKeepId = neighbors
		elseif PVP_OnScreen.currentKeepId and not IsPlayerNearObjective(PVP_OnScreen.currentKeepId) then
			PVP_OnScreen.currentKeepId = nil
			PVP_OnScreen:SetHidden(true)
		end

		if not PVP_OnScreen.currentKeepId then
			PVP_OnScreen:SetHidden(true)
		else
			if PVP_OnScreen.currentKeepId[2] == control.params.keepId then
				PVP:ManageOnScreen(iconTexture, scrollTexture, captureTexture, naveFlag, apseFlag, otherFlag,
					naveAlliance, apseAlliance, otherAlliance, siegeTexture, shouldHideUA, shouldHideLock, not isScroll,
					not (showCaptureTexture and not (control.params.percentage == 100 and not isUnderAttack)),
					shouldHideFlags, totalSieges <= 0, control.params.siegesAD, control.params.siegesDC,
					control.params.siegesEP, keepName, control.params.keepId, PVP_OnScreen.neighbor1)
			elseif PVP_OnScreen.currentKeepId[3] == control.params.keepId then
				PVP:ManageOnScreen(iconTexture, scrollTexture, captureTexture, naveFlag, apseFlag, otherFlag,
					naveAlliance, apseAlliance, otherAlliance, siegeTexture, shouldHideUA, shouldHideLock, not isScroll,
					not (showCaptureTexture and not (control.params.percentage == 100 and not isUnderAttack)),
					shouldHideFlags, totalSieges <= 0, control.params.siegesAD, control.params.siegesDC,
					control.params.siegesEP, keepName, control.params.keepId, PVP_OnScreen.neighbor2)
			elseif PVP_OnScreen.currentKeepId[4] == control.params.keepId then
				PVP:ManageOnScreen(iconTexture, scrollTexture, captureTexture, naveFlag, apseFlag, otherFlag,
					naveAlliance, apseAlliance, otherAlliance, siegeTexture, shouldHideUA, shouldHideLock, not isScroll,
					not (showCaptureTexture and not (control.params.percentage == 100 and not isUnderAttack)),
					shouldHideFlags, totalSieges <= 0, control.params.siegesAD, control.params.siegesDC,
					control.params.siegesEP, keepName, control.params.keepId, PVP_OnScreen.neighbor3)
			end
		end
	end

	local X, Y, Z = coordsNewX, coordsNewY, (keepInfoInDB and keepInfoInDB[1].height or 250)

	Z = Z + KeepIdToHeight(keepId)

	if PVP.midpointKeepIds[keepId] then
		Z = Z + 10
	end

	control.params.newZ = Z

	local playerX, playerY = GetMapPlayerPosition('player')

	local coordX, coordZ, coordY, cameraX, cameraY, allowedToActivate

	-- PVP.m6 = GetGameTimeMilliseconds()

	if isActivated then
		allowedToActivate, coordX, coordZ, coordY = GetActivationInfo()
	end

	if isActivated and allowedToActivate then
		cameraX = 0
		cameraY = 0
		if PVP.isWaitingOnTrustedFirstRun then
			PVP.isWaitingOnTrustedFirstRun = false
		end
	else
		if isActivated then
			PVP.isWaitingOnTrustedFirstRun = true
		end

		local _, realCameraDistance

		realCameraDistance, _, _, coordX, coordY, coordZ = GetCameraInfo()

		if not realCameraDistance then return end

		if isActivated or isNewObjective or PVP.currentCameraDistance == 0 then
			local heading = GetPlayerCameraHeading3D()
			cameraX = sin(heading) * realCameraDistance
			cameraY = cos(heading) * realCameraDistance
		end
	end

	-- PVP.m7 = GetGameTimeMilliseconds()

	local oldX, oldZ, oldY = control:Get3DRenderSpaceOrigin()
	local currentCameraInfo = PVP.currentCameraInfo
	if isNewObjective then
		if currentCameraInfo and currentCameraInfo.current3DX and not isActivated then
			X = currentCameraInfo.current3DX + (X - currentCameraInfo.currentMapX) * GetCurrentMapScaleTo3D()
			Y = currentCameraInfo.current3DY + (Y - currentCameraInfo.currentMapY) * GetCurrentMapScaleTo3D()
		else
			X = coordX - cameraX + (X - playerX) * GetCurrentMapScaleTo3D()
			Y = coordY - cameraY + (Y - playerY) * GetCurrentMapScaleTo3D()
		end
		control:Set3DRenderSpaceOrigin(X, Z, Y)

		control.params.lastUpdate = GetFrameTimeMilliseconds()
		if control:GetHandler() == nil then
			control:SetHandler("OnUpdate", function() ControlOnUpdate(control) end)
		end
	else
		control:Set3DRenderSpaceOrigin(oldX, Z, oldY)
	end

	local currentCampaignId = PVP.currentCampaignId
	local emperorAlliance, emperorRawName, emperorAccName = GetCampaignEmperorInfo(currentCampaignId)
	if emperorAlliance ~= ALLIANCE_NONE then
		PVP_World3DCrownIcon:SetColor(PVP:GetTrueAllianceColors(emperorAlliance))
		if IsInBorderKeepArea() then
			PVP_World3DCrownIcon:Set3DRenderSpaceUsesDepthBuffer(false)
			PVP_World3DCrownIcon:Set3DLocalDimensions(5, 5)
			PVP_World3DCrownIcon:SetAlpha(1)
			PVP_World3DCrown:SetHidden(false)
			if showBorderKeepInfo then
				local x, z, y = control:Get3DRenderSpaceOrigin()
				PVP_World3DCrown:Set3DRenderSpaceOrigin(x, z + 5, y)
				PVP_World3DCrown.params.mainControl = control
			end
			if PVP_World3DCrown:GetHandler() == nil then
				PVP_World3DCrown:SetHandler("OnUpdate", function()
					local heading = GetPlayerCameraHeading3D()
					if PVP_World3DCrown.params.mainControl then
						local _, mainHeading = PVP_World3DCrown.params.mainControl:Get3DRenderSpaceOrientation()
						PVP_World3DCrown:Set3DRenderSpaceOrientation(0, mainHeading, 0)
					else
						PVP_World3DCrown:Set3DRenderSpaceOrientation(0, heading, 0)
					end
				end)
			end
		elseif GetCurrentMapIndex() == PVP_MAPINDEX_CYRODIIL and currentCameraInfo and currentCameraInfo.current3DX and not isActivated then
			PVP_World3DCrownIcon:Set3DRenderSpaceUsesDepthBuffer(true)
			PVP_World3DCrownIcon:Set3DLocalDimensions(165, 165)
			local crownX, crownY
			crownX = currentCameraInfo.current3DX +
				(PVP.icCoords.x - currentCameraInfo.currentMapX) * GetCurrentMapScaleTo3D()
			crownY = currentCameraInfo.current3DY +
				(PVP.icCoords.y - currentCameraInfo.currentMapY) * GetCurrentMapScaleTo3D()
			PVP_World3DCrown:Set3DRenderSpaceOrigin(crownX, PVP.icCoords.z, crownY)
			PVP_World3DCrown:SetHidden(false)
			PVP_World3DCrown.params.mainControl = nil
			if not (PVP_World3DCrown.anim and PVP_World3DCrown.anim:IsPlaying()) then
				PVP_World3DCrown.anim = StartBorderKeep3DAnimation(PVP_World3DCrown)
			end

			if PVP_World3DCrown:GetHandler() == nil then
				PVP_World3DCrown:SetHandler("OnUpdate", function() CrownOnUpdate() end)
			end
		end
	else
		if PVP.currentTooltip == PVP_World3DCrown then
			ResetWorldTooltip()
		end
		PVP_World3DCrown:SetHandler("OnUpdate", nil)
		PVP_World3DCrown.params.mainControl = nil
		PVP_World3DCrown:SetHidden(true)
	end
	-- PVP.m8 = GetGameTimeMilliseconds()
	return control
end

local function SetupNew3DPOIMarker(i, isActivated, isNewObjective)
	local poi = PVP.currentNearbyPOIIds[i]
	local scaleAdjustment = GetCurrentMapScaleAdjustment()

	local control, key
	if not poi.poolKey then
		control, key = PVP.controls3DPool:AcquireObject()
		poi.poolKey = key
	else
		control = poi.control
	end
	if not control then return end

	local params = control.params
	local icon, iconUA = control.icon, control.iconUA
	local iconBG, captureBG = control.bg, control.captureBG
	local captureBar, divider = control.captureBar, control.divider
	local ping = control.ping

	iconBG:SetHidden(true)
	captureBG:SetHidden(true)
	captureBar:SetHidden(true)
	divider:SetHidden(true)

	local ICONTYPE = 'POI'
	params.type	= GetControlType(control, poi, ICONTYPE)
	params.texture = GetControlTexture(control, poi, ICONTYPE)
	params.keepId  = poi.keepId

	icon:SetTexture(params.texture)
	local X, Y, Z = poi.targetX, poi.targetY, poi.targetZ

	local shouldHideUA
	if poi.isBgFlag then
		local auraPinType, auraR, auraG, auraB = GetObjectiveAuraPinInfo(0, poi.isBgFlag, BGQUERY_LOCAL)
		if PVP.auraPinTypes[auraPinType] then
			iconUA:SetTexture(ZO_MapPin.PIN_DATA[auraPinType].texture)
			iconUA:SetColor(auraR, auraG, auraB)
			iconUA:SetHidden(false)
		else
			iconUA:SetHidden(true)
		end
	elseif params.type == 'TOWN_FLAG' then
		local auraPinType, auraR, auraG, auraB = GetObjectiveAuraPinInfo(poi.keepId, poi.objectiveId, BGQUERY_LOCAL)
		if not (auraR == 0 and auraG == 0 and auraB == 0) then
			iconUA:SetTexture("EsoUI/Art/MapPins/battlegrounds_capturePoint_halo.dds")
			iconUA:SetColor(auraR, auraG, auraB)
			iconUA:SetHidden(false)
		else
			iconUA:SetHidden(true)
		end
	else
		if params.type == 'MILEGATE' or params.type == 'BRIDGE' then
			shouldHideUA = not GetKeepUnderAttack(params.keepId, BGQUERY_LOCAL)
		else
			shouldHideUA = not IsSkirmishCloseToObjective(params.type == 'AYLEID_WELL', X, Y, scaleAdjustment)
		end
		iconUA:SetHidden(shouldHideUA)
	end

	local controlHasPing = params.hasRally or params.hasWaypoint
	if controlHasPing then
		if params.hasRally then
			ping:SetTexture(PVP_RALLY_TEXTURE)
		elseif params.hasWaypoint then
			ping:SetTexture(PVP_WAYPOINT_TEXTURE)
		end
		ping:SetColor(1, 1, 1)
	end
	ping:SetHidden(not controlHasPing)

	params.name = poi.name
	params.alliance = poi.alliance
	params.X = X
	params.Y = Y
	params.globalX = poi.globalX
	params.globalY = poi.globalY
	params.scaleAdjustment = scaleAdjustment
	params.orientation3d = poi.orientation3d

	if PVP.SV.showOnScreen and not PVP.SV.unlocked then
		if (params.type == 'MILEGATE' or params.type == 'BRIDGE') and GetPlayerLocationName() == params.name then
			PVP:ManageOnScreen(params.texture, "", "", nil, nil, nil, nil, nil, params.alliance, "",
				shouldHideUA, true, true, true, true, true, nil, nil, nil, params.name, params.keepId, PVP_OnScreen, true)
			PVP_OnScreen.currentKeepId = params.name
		elseif PVP_OnScreen.currentKeepId and not IsPlayerNearObjective(PVP_OnScreen.currentKeepId) then
			PVP_OnScreen.currentKeepId = nil
			PVP_OnScreen:SetHidden(true)
		end
		if not PVP_OnScreen.currentKeepId then
			PVP_OnScreen:SetHidden(true)
		end
	end

	if params.type == 'SHADOW_IMAGE' then
		SetShadowImageColor(control)
	else
		icon:SetColor(GetControlColor(control, poi, ICONTYPE))
	end

	params.distance = poi.distance
	params.doorType = poi.doorType
	params.doorDistrictKeepId = poi.doorDistrictKeepId
	params.controllingCharacter = poi.controllingCharacter
	params.artifactAlliance = poi.controllingAlliance
	params.artifactOriginalAlliance = poi.originalAlliance
	params.isBgFlag = poi.isBgFlag
	params.artifactKeepId = poi.artifactKeepId
	params.artifactObjectiveId = poi.artifactObjectiveId
	params.groupTag = poi.groupTag
	params.isGroupLeader = poi.isGroupLeader
	params.keepId = poi.keepId
	params.objectiveId = poi.objectiveId
	params.x3d = poi.x3d
	params.y3d = poi.y3d

	SetupTextureCoords(control)
	local POISize, POIUASize = GetControlSize(control, poi, ICONTYPE)
	SetDimensions3DControl(control, POISize, POIUASize, POISize)
	params.dimensions = { POISize, POIUASize, POISize }

	if icControls[params.type] then
		params.isCurrent = poi.isCurrent
	end
	Hide3DControl(control, scaleAdjustment)

	local playerX, playerY = GetMapPlayerPosition('player')
	local coordX, coordZ, coordY, cameraX, cameraY, allowedToActivate

	if isActivated then
		allowedToActivate, coordX, coordZ, coordY = GetActivationInfo()
	end

	if isActivated and allowedToActivate then
		cameraX = 0
		cameraY = 0
		if PVP.isWaitingOnTrustedFirstRun then
			PVP.isWaitingOnTrustedFirstRun = false
		end
	else
		if isActivated then
			PVP.isWaitingOnTrustedFirstRun = true
		end
		local _, realCameraDistance
		realCameraDistance, _, _, coordX, coordY, coordZ = GetCameraInfo()
		if not realCameraDistance then return end
		if isActivated or isNewObjective or PVP.currentCameraDistance == 0 then
			local heading = GetPlayerCameraHeading3D()
			cameraX = sin(heading) * realCameraDistance
			cameraY = cos(heading) * realCameraDistance
		end
	end

	if fixedHeight[params.type] then
		params.height = poi.targetZ
	elseif not params.isBgFlag then
		params.height = IsCloseToObjectiveOrPlayer(control, X, Y, playerX, playerY)
	end

	Z = GetControlHeight(control, poi, ICONTYPE, coordZ)
	params.newZ = Z

	if isNewObjective then
		local mapScale3D = GetCurrentMapScaleTo3D()
		if PVP.currentCameraInfo and PVP.currentCameraInfo.current3DX and not isActivated then
			X = PVP.currentCameraInfo.current3DX + (X - PVP.currentCameraInfo.currentMapX) * mapScale3D
			Y = PVP.currentCameraInfo.current3DY + (Y - PVP.currentCameraInfo.currentMapY) * mapScale3D
		else
			X = coordX - cameraX + (X - playerX) * mapScale3D
			Y = coordY - cameraY + (Y - playerY) * mapScale3D
		end
		control:Set3DRenderSpaceOrigin(X, Z, Y)
		params.lastUpdate = GetFrameTimeMilliseconds()
		if not control:GetHandler() then
			control:SetHandler("OnUpdate", function() PoiOnUpdate(control) end)
		end
	elseif params.type ~= "COMPASS" then
		ProcessDynamicControlPosition(control)
	end

	return control
end

local function BGObjectiveOnUpdate(control)
	local scaleAdjustment = GetCurrentMapScaleAdjustment()

	if Hide3DControl(control, scaleAdjustment) then return end
	local showingTooltipStart
	local multiplier = GetDistanceMultiplier(control, scaleAdjustment)
	control.multiplier = multiplier

	control:SetAlpha(1)

	local controlSize = GetControlSizeForAngles(control, multiplier)
	local heading = GetAdjustedPlayerCameraHeading()

	local showTooltip

	local controlX, controlZ, controlY = control:Get3DRenderSpaceOrigin()
	local oldOrigin, _, angleZ, cameraX, cameraY, cameraZ = GetCameraInfo()

	if not oldOrigin then return end

	local distance = zo_distance(cameraX, cameraY, controlX, controlY)

	local deltaX = controlX - cameraX
	local deltaY = controlY - cameraY
	local deltaZ = controlZ - cameraZ

	local controlHeading = asin(abs(deltaX) / distance)

	if deltaY > 0 then
		controlHeading = pi - controlHeading
	end

	if deltaX > 0 then
		controlHeading = -controlHeading
	end

	local diff = controlHeading - heading


	local controlGraceAngle
	controlGraceAngle = atan(0.5 * controlSize / distance)

	local controlParams = control.params
	local controlType = controlParams.type
	local objectiveId = controlParams.objectiveId
	local alliance = controlParams.alliance

	if heading > controlHeading - controlGraceAngle and heading < controlHeading + controlGraceAngle then
		local lowerBoundZ, higherBoundZ

		lowerBoundZ = atan2((deltaZ - 0.5 * controlSize), distance)
		higherBoundZ = atan2((deltaZ + 0.5 * controlSize), distance)

		local validTooltipStatus = not PVP.currentTooltip or PVP.currentTooltip == control or
			controlParams.distance < PVP.currentTooltip.params.distance

		if (-angleZ > lowerBoundZ and -angleZ < higherBoundZ) and validTooltipStatus then
			if controlType == 'CTF_BASE' then
				alliance = GetCaptureFlagObjectiveOriginalOwningAlliance(0,
				objectiveId, BGQUERY_LOCAL)
			else
				alliance = GetCaptureAreaObjectiveOwner(0, objectiveId, BGQUERY_LOCAL)
			end

			-- PVP_WorldTooltipLabel:SetColor(PVP:BgAllianceToHexColor(alliance))
			PVP_WorldTooltipLabel:SetColor(GetBattlegroundTeamColor(alliance):UnpackRGBA())


			local distanceText = GetFormattedDistanceText(control)
			PVP_WorldTooltipLabel:SetText(zo_strformat(SI_ALERTTEXT_LOCATION_FORMAT,
				GetObjectiveInfo(0, objectiveId, BGQUERY_LOCAL)) .. distanceText)

			SetupNormalWorldTooltip(false)


			showingTooltipStart = PVP.currentTooltip ~= control

			if showingTooltipStart then
				controlParams.currentPhase = IsPopPhaseValid(controlParams.currentPhase) and controlParams.currentPhase or 1
			end

			PVP.currentTooltip = control
			showTooltip = true

			PVP_WorldTooltip:SetHidden(false)
		end
	end

	local hidingTooltipStart = not showTooltip and PVP.currentTooltip == control

	if hidingTooltipStart then
		ResetWorldTooltip()
		controlParams.currentPhase = IsPopPhaseValid(controlParams.currentPhase) and controlParams.currentPhase or GetNumberOfAnimationPhases()
	end


	local popMultiplier

	local isControlFlipping --[[ = control.params.flippingPlaying and control.params.flippingPlaying:IsPlaying() ]]
	if PVP.currentTooltip == control or isControlFlipping then
		popMultiplier = GetPopInMultiplier(multiplier, control)
	else
		popMultiplier = GetPopOutMultiplier(multiplier, control)
	end

	local dimensions = controlParams.dimensions
	SetDimensions3DControl(control, dimensions[1] * popMultiplier, dimensions[2] * popMultiplier, dimensions[3] * popMultiplier)

	if not isControlFlipping then
		control:Set3DRenderSpaceOrientation(0, heading, 0)
	end
end

local function SetupNewBattlegroundObjective3DMarker(objectiveId, distance, isActivated, isNewObjective, isCtfBase)
	local pinType, coordsNewX, coordsNewY

	if isCtfBase then
		pinType, coordsNewX, coordsNewY = GetObjectiveSpawnPinInfo(0, objectiveId, BGQUERY_LOCAL)
	else
		pinType, coordsNewX, coordsNewY = GetObjectivePinInfo(0, objectiveId, BGQUERY_LOCAL)
	end
	local pinHeight = PVP.bgObjectives[objectiveId] or 150
	local scaleAdjustment = GetCurrentMapScaleAdjustment()

	local objectiveIcon = ZO_MapPin.PIN_DATA[pinType].texture

	if coordsNewX == 0 and coordsNewY == 0 then
		return
	end

	PVP.currentObjectivesIds = PVP.currentObjectivesIds or {}

	local control, key

	if not PVP.currentObjectivesIds[objectiveId] then
		control, key = PVP.controls3DPool:AcquireObject()
		control.poolKey = key
	else
		control = PVP.currentObjectivesIds[objectiveId]
	end

	if isCtfBase then
		control.params.type = 'CTF_BASE'
	end

	control.params.distance = distance
	control.params.X = coordsNewX
	control.params.Y = coordsNewY
	control.params.scaleAdjustment = scaleAdjustment
	control.params.objectiveId = objectiveId
	-- control.isCtfBase = isCtfBase

	local icon = control.icon
	local iconUA = control.iconUA
	local iconBG = control.bg
	local captureBG = control.captureBG
	local captureBar = control.captureBar
	local divider = control.divider
	local scroll = control.scroll

	local currentControlAlliance = GetCaptureAreaObjectiveOwner(0, control.params.objectiveId, BGQUERY_LOCAL)

	control.params.alliance = currentControlAlliance
	icon:SetTexture(objectiveIcon)

	icon:SetColor(1, 1, 1)


	if isCtfBase then
		local outlinePinType = GetObjectiveReturnPinInfo(0, control.params.objectiveId, BGQUERY_LOCAL)
		local outlineTexture = ZO_MapPin.PIN_DATA[outlinePinType].texture
		iconUA:SetTexture(outlineTexture)
		iconUA:SetColor(1, 1, 1)
		iconUA:SetHidden(false)
	else
		local auraPinType, auraR, auraG, auraB = GetObjectiveAuraPinInfo(0, control.params.objectiveId, BGQUERY_LOCAL)

		local auraTexture

		if PVP.auraPinTypes[auraPinType] then
			auraTexture = ZO_MapPin.PIN_DATA[auraPinType].texture
			iconUA:SetTexture(auraTexture)
			iconUA:SetColor(auraR, auraG, auraB)
			iconUA:SetHidden(false)
		else
			iconUA:SetHidden(true)
		end
	end
	divider:SetHidden(true)
	captureBar:SetHidden(true)
	captureBG:SetHidden(true)
	iconBG:SetHidden(true)

	PVP_World3DCrown:SetHidden(true)

	SetControlInitialSize(control)

	local isFlag, flagTexture = IsFlagInObjectiveId(control.params.objectiveId)

	if flagTexture then
		scroll:SetTexture(flagTexture)
	end

	scroll:SetHidden(not isFlag)

	Hide3DControl(control, scaleAdjustment)

	local X, Y, Z = coordsNewX, coordsNewY, pinHeight

	Z = Z + PVP_ICON_HEIGHT_BG_OBJECTIVE

	local playerX, playerY = GetMapPlayerPosition('player')

	local coordX, coordZ, coordY, cameraX, cameraY, allowedToActivate


	if isActivated then
		allowedToActivate, coordX, coordZ, coordY = GetActivationInfo()
	end

	if isActivated and allowedToActivate then
		cameraX = 0
		cameraY = 0
		if PVP.isWaitingOnTrustedFirstRun then
			PVP.isWaitingOnTrustedFirstRun = false
		end
	else
		if isActivated then
			PVP.isWaitingOnTrustedFirstRun = true
		end

		local _, realCameraDistance

		realCameraDistance, _, _, coordX, coordY, coordZ = GetCameraInfo()

		if not realCameraDistance then return end

		if isActivated or isNewObjective or PVP.currentCameraDistance == 0 then
			local heading = GetPlayerCameraHeading3D()
			cameraX = sin(heading) * realCameraDistance
			cameraY = cos(heading) * realCameraDistance
		end
	end

	local oldX, oldZ, oldY = control:Get3DRenderSpaceOrigin()
	if isNewObjective then
		if PVP.currentCameraInfo and PVP.currentCameraInfo.current3DX and not isActivated then
			X = PVP.currentCameraInfo.current3DX + (X - PVP.currentCameraInfo.currentMapX) * GetCurrentMapScaleTo3D()
			Y = PVP.currentCameraInfo.current3DY + (Y - PVP.currentCameraInfo.currentMapY) * GetCurrentMapScaleTo3D()
		else
			X = coordX - cameraX + (X - playerX) * GetCurrentMapScaleTo3D()
			Y = coordY - cameraY + (Y - playerY) * GetCurrentMapScaleTo3D()
		end
		control:Set3DRenderSpaceOrigin(X, Z, Y)
		if control:GetHandler() == nil then
			control:SetHandler("OnUpdate", function() BGObjectiveOnUpdate(control) end)
		end
	else
		control:Set3DRenderSpaceOrigin(oldX, Z, oldY)
	end

	return control
end

function PVP_SetMapPingOnMouseOver()
	if not PVP.currentTooltip then return end
	local controlType = PVP.currentTooltip.params.type
	-- if PVP.SV.enabled and not PVP.SV.unlocked and PVP.SV.show3DIcons and type ~= 'SCROLL' then
	if PVP.SV.enabled and not PVP.SV.unlocked and PVP.SV.show3DIcons then
		if IsUnitGroupLeader('player') then
			if PVP.currentTooltip.params.hasRally or controlType == 'RALLY' then
				PVP.LMP:RemoveMapPing(MAP_PIN_TYPE_RALLY_POINT)
			else
				PVP.LMP:SetMapPing(MAP_PIN_TYPE_RALLY_POINT, MAP_TYPE_LOCATION_CENTERED, PVP.currentTooltip.params.X,
					PVP.currentTooltip.params.Y)
			end
		else
			d("XXXX PVP_SetMapPingOnMouseOver")
			if PVP.currentTooltip.params.hasWaypoint or controlType == 'WAYPOINT' then
				PVP.LMP:RemoveMapPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
			else
				PVP.LMP:SetMapPing(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, PVP.currentTooltip.params.X,
					PVP.currentTooltip.params.Y)
			end
		end
	end
end

function PVP:FullReset3DIcons()
	self.currentNearbyKeepIds = {}
	self.currentNearbyPOIIds = {}
	self.currentObjectivesIds = {}

	if self.controls3DPool then self.controls3DPool:ReleaseAllObjects() end
	ResetWorldTooltip()
	PVP:Setup3DMeasurements()
end

local function FindNearbyKeeps()
	local scaleAdjustment = GetCurrentMapScaleAdjustment()
	local foundKeeps = {}
	local selfX, selfY = GetMapPlayerPosition('player')
	local inImperialCity = IsInImperialCity()
	local inSewers = inImperialCity and PVP:IsInSewers() -- Only check if in IC

	for i = 1, GetNumKeeps() do
		local keepId = GetKeepKeysByIndex(i)
		local _, targetX, targetY = GetKeepPinInfo(keepId, BGQUERY_LOCAL)

		if not (keepId > 153 and keepId < 163) and targetX ~= 0 and targetY ~= 0 then
			local distance = zo_distance(selfX, selfY, targetX, targetY)
			local isKeep = GetKeepResourceType(keepId) == 0
			local isDistrict = GetKeepType(keepId) == KEEPTYPE_IMPERIAL_CITY_DISTRICT

			if inImperialCity and not inSewers and isDistrict then
				foundKeeps[keepId] = distance
			elseif not isDistrict then
				local maxDisplayDistance = isKeep and PVP.SV.max3DIconsDistance or PVP.SV.maxResource3DIconsDistance
				if distance <= scaleAdjustment * maxDisplayDistance then
					foundKeeps[keepId] = distance
				end
			end
		end
	end

	return next(foundKeeps) and foundKeeps or false
end

-- local guildid
-- local guildtrack = {  }
-- local function GetGuildPlayerPosition(name)
-- 	local mix = GetGuildMemberIndexFromDisplayName(guildid, name)
-- 	if not mix then
-- 		return 0, 0
-- 	end
-- 	local n, note = GetGuildMemberInfo(guildid, mix)
-- 	local tbl = {}
-- 	for token in note:gmatch("[^%s]+") do
-- 		tbl[#tbl + 1] = token
-- 	end
-- 	-- df(">>***** %s/%s %d %f %f", name, n, mix, tonumber(tbl[2]), tonumber(tbl[3]))
-- 	return tonumber(tbl[2]), tonumber(tbl[3])
-- end

-- local last_update = 0
-- local last_x, last_y
-- local UPDATE_TIME = 10
-- local function UpdateGuildPos()
-- 	local now = GetTimeStamp()
-- 	local x, y = GetMapPlayerPosition("player")
-- 	if (now - last_update) > UPDATE_TIME and (last_x ~= x or last_y ~= y) then
-- 		local msg = string.format("POS %f %f", x, y)
-- 		local mix = GetPlayerGuildMemberIndex(guildid)
-- 		chat:Printf("XXX guildid %d gix %d msg %s", guildid, mix, msg)
-- 		SetGuildMemberNote(guildid, mix, msg)
-- 		last_update = now
-- 		last_x = x
-- 		last_y = y
-- 	end
-- end
local adjusted_MAX_DISTANCE
local function POIGroupInsert(foundPOI, groupTag, selfX, selfY, targetX, targetY, name, isGroupLeader, isUnitDead,
							 unitClass, isInCombat, shouldShowGroupLeaderAtAnyDistance, showit)
	-- if groupTag == "group21" or groupTag == "group22" then df("****** HERE %s %s %s %s*******", groupTag, tostring(targetX), tostring(targetY), tostring(showit)) end
	if targetX ~= 0 and targetY ~= 0 and showit then
		local unitSpecColor = PVP:GetUnitSpecColor(name)
		local distance = zo_distance(selfX, selfY, targetX, targetY)
		if distance <= adjusted_MAX_DISTANCE and (PVP.SV.allgroup3d or shouldShowGroupLeaderAtAnyDistance or (distance >= 0.05 * adjusted_MAX_DISTANCE)) then
			-- if distance<=adjusted_MAX_DISTANCE*2 and (distance>=0.1*adjusted_MAX_DISTANCE) then
			insert(foundPOI,
				{
					pinType = PVP_PINTYPE_GROUP,
					targetX = targetX,
					targetY = targetY,
					distance = distance,
					name = name,
					isGroupLeader = isGroupLeader,
					isUnitDead = isUnitDead,
					unitClass = unitClass,
					unitSpecColor = unitSpecColor,
					isInCombat = isInCombat,
					groupTag = groupTag
				})
		end
	end
end

local function FindNearbyPOIs()
	local scaleAdjustment = GetCurrentMapScaleAdjustment()
	local adjusted_POI_MAX_DISTANCE = scaleAdjustment * PVP.SV.max3DIconsPOIDistance
	local currentMapIndex = GetCurrentMapIndex()
	local foundPOI = {}
	local selfX, selfY = GetMapPlayerPosition('player')
	local isActiveWorldBattleground = IsActiveWorldBattleground()

	adjusted_MAX_DISTANCE = scaleAdjustment * PVP_MAX_DISTANCE

	if isActiveWorldBattleground then
		-- local bgId = GetCurrentBattlegroundId()
		local battlegroundId = GetCurrentBattlegroundId()
		local bgBases = PVP:GetBgBaseInfo(battlegroundId)
		-- if PVP.bgTeamBases[bgId] then
		if bgBases then
			for i = 1, 3 do
				-- if PVP.bgTeamBases[bgId][i].x ~= 0 then
				if bgBases[i].x ~= 0 then
					-- local alliance, targetX, targetY, targetZ = PVP.bgTeamBases[bgId][i].alliance, PVP.bgTeamBases[bgId][i].x, PVP.bgTeamBases[bgId][i].y, PVP.bgTeamBases[bgId][i].z
					local alliance, targetX, targetY, targetZ = bgBases[i].alliance, bgBases[i].x, bgBases[i].y,
						bgBases[i].z
					local distance = zo_distance(selfX, selfY, targetX, targetY)
					insert(foundPOI,
						{
							pinType = alliance,
							targetX = targetX,
							targetY = targetY,
							targetZ = targetZ,
							distance = distance,
							alliance = alliance,
							isBgBase = true
						})
				end
			end
		end


		local battlegroundType = GetBattlegroundGameType(battlegroundId)
		local battlegroundState = GetCurrentBattlegroundState()
		local isBgCtf = battlegroundType == BATTLEGROUND_GAME_TYPE_CAPTURE_THE_FLAG
		-- local isBgMurderball = battlegroundType == BATTLEGROUND_GAME_TYPE_MURDERBALL
		local isBgDm = battlegroundType == BATTLEGROUND_GAME_TYPE_DEATHMATCH


		if isBgCtf --[[or isBgMurderball]] then
			for i = 1, GetNumObjectives() do
				local keepId, objectiveId, bgContext = GetObjectiveIdsForIndex(i)
				if keepId == 0 and bgContext == BGQUERY_LOCAL and DoesObjectiveExist(keepId, objectiveId, bgContext) then
					local flagState = GetObjectiveControlState(0, objectiveId, bgContext)
					if flagState ~= OBJECTIVE_CONTROL_STATE_FLAG_AT_BASE then
						local pinType, targetX, targetY = GetObjectivePinInfo(keepId, objectiveId, bgContext)
						if targetX ~= 0 and targetY ~= 0 then
							local distance = zo_distance(selfX, selfY, targetX, targetY)
							local name = GetObjectiveInfo(0, objectiveId, bgContext)
							local holdingAlliance = GetCarryableObjectiveHoldingAllianceInfo(0, objectiveId,
								bgContext)
							insert(foundPOI,
								{
									pinType = pinType,
									targetX = targetX,
									targetY = targetY,
									distance = distance,
									name = name,
									controllingAlliance = holdingAlliance,
									isBgFlag = objectiveId
								})
						end
					end
				end
			end
		end

		if isBgDm and battlegroundState == BATTLEGROUND_STATE_RUNNING then
			-- local powerUps = PVP.bgDamagePowerups[battlegroundId]
			local powerUps = PVP:GetDMPowerups(battlegroundId)
			if powerUps then
				for i = 1, #powerUps do
					local pinType, targetX, targetY, targetZ = PVP_PINTYPE_POWERUP, powerUps[i].x, powerUps[i].y,
						powerUps[i].z
					if targetX ~= 0 and targetY ~= 0 then
						local distance = zo_distance(selfX, selfY, targetX, targetY)
						if distance <= adjusted_POI_MAX_DISTANCE then
							insert(foundPOI,
								{
									pinType = pinType,
									targetX = targetX,
									targetY = targetY,
									targetZ = targetZ,
									distance = distance,
									name = 'Damage PowerUp'
								})
						end
					end
				end
			end
		end
	else
		for i = 1, GetNumKillLocations() do
			local pinType, targetX, targetY = GetKillLocationPinInfo(i)
			if targetX ~= 0 and targetY ~= 0 then
				local distance = zo_distance(selfX, selfY, targetX, targetY)
				if distance <= adjusted_POI_MAX_DISTANCE * 1.5 and pinType ~= MAP_PIN_TYPE_INVALID and distance > scaleAdjustment * PVP_SKIRMISH_MIN_DISTANCE then
					local allianceKills = {}
					for a = 1, ALLIANCE_MAX_VALUE do
						local kills = GetNumKillLocationAllianceKills(i, a)
						allianceKills[a] = kills or 0
					end
					local name = PVP.killLocationPintypeToName[pinType]
					local name_long = (name or "Fight!") ..
						"\nBattle Victories:\n|cEFD13CAD " ..
						(allianceKills[ALLIANCE_ALDMERI_DOMINION] or 0) ..
						"|r, |cFF7161EP " ..
						(allianceKills[ALLIANCE_EBONHEART_PACT] or 0) ..
						"|r, |c80AFFFDC " .. (allianceKills[ALLIANCE_DAGGERFALL_COVENANT] or 0) ..
						"|r"
					insert(foundPOI,
						{ pinType = pinType, targetX = targetX, targetY = targetY, distance = distance, name = name_long })
				end
			end
		end

		local activeScrolls =  PVP.activeScrolls
		for k, v in pairs(PVP.elderScrollsIds) do
			local name, _, scrollState = GetObjectiveInfo(k, v, BGQUERY_LOCAL)
			local originalAlliance
			if not isActiveWorldBattleground then
				originalAlliance = GetArtifactScrollObjectiveOriginalOwningAlliance(k, v, BGQUERY_LOCAL)
			end
			if scrollState ~= OBJECTIVE_CONTROL_STATE_FLAG_AT_BASE and scrollState ~= OBJECTIVE_CONTROL_STATE_FLAG_AT_ENEMY_BASE then --// scrolls in being carried //
				local pinType, targetX, targetY = GetObjectivePinInfo(k, v, BGQUERY_LOCAL)
				if targetX ~= 0 and targetY ~= 0 then
					local distance = zo_distance(selfX, selfY, targetX, targetY)
					-- if distance<=adjusted_MAX_DISTANCE and pinType~=MAP_PIN_TYPE_INVALID and distance>scaleAdjustment*PVP_POI_MIN_DISTANCE*0.75 then
					if distance <= adjusted_MAX_DISTANCE and pinType ~= MAP_PIN_TYPE_INVALID then
						local controllingCharacter = ""
						local controllingAlliance = ALLIANCE_NONE
						if scrollState == OBJECTIVE_CONTROL_STATE_FLAG_HELD then
							local scrollEventInfo = activeScrolls[name] or {}

							if scrollEventInfo.playerName == nil or scrollEventInfo.playerName == "" then
								controllingCharacter = GetCarryableObjectiveHoldingCharacterInfo(k, v, BGQUERY_LOCAL)
								scrollEventInfo.playerName = controllingCharacter
							else
								controllingCharacter = scrollEventInfo.playerName
							end

							if scrollEventInfo.playerAlliance == nil or scrollEventInfo.playerAlliance == ALLIANCE_NONE then
								controllingAlliance = GetCarryableObjectiveHoldingAllianceInfo(k, v, BGQUERY_LOCAL)
								scrollEventInfo.playerAlliance = controllingAlliance
							else
								controllingAlliance = scrollEventInfo.playerAlliance
							end

							scrollEventInfo.controlState = scrollState
							activeScrolls[name] = scrollEventInfo
						end
						insert(foundPOI,
							{
								pinType = pinType,
								targetX = targetX,
								targetY = targetY,
								distance = distance,
								name = name,
								artifactKeepId = k,
								artifactObjectiveId = v,
								controllingCharacter = controllingCharacter,
								controllingAlliance = controllingAlliance,
								originalAlliance = originalAlliance
							})
					end
				end
			end
		end

		local activeObjectiveId = PVP.activeDaedricArtifact
		if activeObjectiveId then
			local name, _, artifactState = GetObjectiveInfo(0, activeObjectiveId, BGQUERY_LOCAL)
			if artifactState ~= OBJECTIVE_CONTROL_STATE_UNKNOWN then
				local pinType, targetX, targetY = GetObjectivePinInfo(0, activeObjectiveId, BGQUERY_LOCAL)
				if targetX ~= 0 and targetY ~= 0 then
					local distance = zo_distance(selfX, selfY, targetX, targetY)
					-- if distance<=adjusted_MAX_DISTANCE and pinType~=MAP_PIN_TYPE_INVALID and distance>scaleAdjustment*PVP_POI_MIN_DISTANCE*0.75 then
					if distance <= adjusted_MAX_DISTANCE and pinType ~= MAP_PIN_TYPE_INVALID then
						local controllingAlliance = GetCarryableObjectiveHoldingAllianceInfo(0, activeObjectiveId, BGQUERY_LOCAL)
						local controllingCharacter  = GetCarryableObjectiveHoldingCharacterInfo(0, activeObjectiveId, BGQUERY_LOCAL)
						if artifactState == OBJECTIVE_CONTROL_STATE_FLAG_HELD and controllingAlliance == ALLIANCE_NONE then
							if controllingCharacter == PVP.playerName then
								controllingAlliance = PVP.allianceOfPlayer
							else
								local playerDbRecord = PVP.SV.playersDB[controllingCharacter]
								controllingAlliance = playerDbRecord and playerDbRecord.alliance or ALLIANCE_NONE
							end
						end
						insert(foundPOI,
							{
								pinType = controllingAlliance and PVP.daedricArtifactAllianceToPinType[controllingAlliance] or PVP.daedricArtifactAllianceToPinType[ALLIANCE_NONE],
								targetX = targetX,
								targetY = targetY,
								distance = distance,
								name = name,
								artifactKeepId = 0,
								artifactObjectiveId = activeObjectiveId,
								controllingCharacter = controllingCharacter,
								controllingAlliance = controllingAlliance,
								originalAlliance = ALLIANCE_NONE
							})
					end
				end
			end
		else
			-- If there isn't an active artifact set by EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED, 
			-- then iterate through the possible IDs so if one was missed it can be updated next cycle
			local candidateArtifacts = PVP.daedricArtifactObjectiveIds
			local numArtifacts = #candidateArtifacts
			for i = 1, numArtifacts do
				local id = candidateArtifacts[i]
				local _, _, artifactState = GetObjectiveInfo(0, id, BGQUERY_LOCAL)
				if artifactState ~= OBJECTIVE_CONTROL_STATE_UNKNOWN then
					PVP.activeDaedricArtifact = id
					break
				end
			end
		end

		if PVP.SV.group3d and IsUnitGrouped('player') then
			local groupSize = GetGroupSize()
			local playerZone = GetUnitZone('player')
			if playerZone ~= "" then
				for i = 1, groupSize do
					local groupTag = GetGroupUnitTagByIndex(i)
					local isGroupLeader = IsUnitGroupLeader(groupTag)
					if GetUnitZone(groupTag) == playerZone then
						local x, y = GetMapPlayerPosition(groupTag)
						POIGroupInsert(foundPOI, groupTag, selfX, selfY, x, y, GetRawUnitName(groupTag),
						isGroupLeader, IsUnitDead(groupTag),
							GetUnitClassId(groupTag), IsUnitInCombat(groupTag), PVP.SV.groupleader3d and isGroupLeader,
							not (PVP.SV.onlyGroupLeader3d and not isGroupLeader))
					end
				end
			end
		end
		-- if PVP.SV.guild3d then
		-- 	UpdateGuildPos()`
		-- 		if n ~= mydname then
		-- 			local x, y = GetGuildPlayerPosition(n)
		-- 			local unitTag = string.format("group%d", 20 + i)
		-- 			POIGroupInsert(foundPOI, unitTag, selfX, selfY, x, y, n, false, false, 0, false, true, true, true)
		-- 		end
		-- 	end
		-- end

		if PVP.shadowInfo then
			local targetX, targetY, targetZ, globalX, globalY = PVP.shadowInfo.X, PVP.shadowInfo.Y, PVP.shadowInfo.Z,
				PVP.shadowInfo.globalX, PVP.shadowInfo.globalY
			if targetX and targetY and targetX ~= 0 and targetY ~= 0 then
				local distance = zo_distance(selfX, selfY, targetX, targetY)
				local name = 'Shadow Image'
				if distance <= adjusted_MAX_DISTANCE then
					insert(foundPOI,
						{
							pinType = PVP_PINTYPE_SHADOWIMAGE,
							targetX = targetX,
							targetY = targetY,
							distance = distance,
							name = name,
							targetZ = targetZ,
							globalX = globalX,
							globalY = globalY
						})
				end
			end
		end

		for i = 1, GetNumForwardCamps(1) do
			local pinType, targetX, targetY, radius = GetForwardCampPinInfo(1, i)

			if targetX ~= 0 and targetY ~= 0 then
				local distance = zo_distance(selfX, selfY, targetX, targetY)
				-- if distance<=PVP_MAX_DISTANCE and distance<=radius and distance>PVP_POI_MIN_DISTANCE/1.8 then
				if distance <= adjusted_MAX_DISTANCE and distance <= radius then
					insert(foundPOI,
						{
							pinType = pinType,
							targetX = targetX,
							targetY = targetY,
							distance = distance,
							name = 'Forward Camp'
						})
				end
			end
		end

		if currentMapIndex == PVP_MAPINDEX_CYRODIIL then
			for i = 1, #PVP.ayleidWellsCoords do
				local pinType, targetX, targetY, targetZ = PVP_PINTYPE_AYLEIDWELL, PVP.ayleidWellsCoords[i].x,
					PVP.ayleidWellsCoords[i].y, PVP.ayleidWellsCoords[i].z

				if targetX ~= 0 and targetY ~= 0 then
					local distance = zo_distance(selfX, selfY, targetX, targetY)
					if distance <= adjusted_POI_MAX_DISTANCE then
						insert(foundPOI,
							{
								pinType = pinType,
								targetX = targetX,
								targetY = targetY,
								targetZ = targetZ,
								distance = distance,
								name = 'Ayleid Well'
							})
					end
				end
			end
		end

		if PVP.SV.showCompass3d and currentMapIndex == PVP_MAPINDEX_CYRODIIL then
			local pinType, targetX, targetY, targetZ

			local distance

			targetZ = PVP.SV.compass3dHeight

			targetX, targetY = selfX - 0.05, selfY
			distance = zo_distance(selfX, selfY, targetX, targetY)

			insert(foundPOI,
				{
					pinType = PVP_PINTYPE_COMPASS,
					targetX = targetX,
					targetY = targetY,
					targetZ = targetZ,
					distance = distance,
					name = 'WEST'
				})

			targetX, targetY = selfX + 0.05, selfY
			distance = zo_distance(selfX, selfY, targetX, targetY)
			insert(foundPOI,
				{
					pinType = PVP_PINTYPE_COMPASS,
					targetX = targetX,
					targetY = targetY,
					targetZ = targetZ,
					distance = distance,
					name = 'EAST'
				})

			targetX, targetY = selfX, selfY - 0.05
			distance = zo_distance(selfX, selfY, targetX, targetY)
			insert(foundPOI,
				{
					pinType = PVP_PINTYPE_COMPASS,
					targetX = targetX,
					targetY = targetY,
					targetZ = targetZ,
					distance = distance,
					name = 'NORTH'
				})

			targetX, targetY = selfX, selfY + 0.05
			distance = zo_distance(selfX, selfY, targetX, targetY)
			insert(foundPOI,
				{
					pinType = PVP_PINTYPE_COMPASS,
					targetX = targetX,
					targetY = targetY,
					targetZ = targetZ,
					distance = distance,
					name = 'SOUTH'
				})
		end



		if currentMapIndex == PVP_MAPINDEX_CYRODIIL then
			local currentKeepId, foundObjectives = PVP:FindAVAIds(GetPlayerLocationName(), true)
			local keepType						= PVP:KeepIdToKeepType(currentKeepId)

			if keepType == KEEPTYPE_TOWN then
				for i = 1, 3 do
					local keepId = foundObjectives[i].keepId
					local objectiveId = foundObjectives[i].objectiveId
					local _, targetX, targetY = GetObjectivePinInfo(keepId, objectiveId, BGQUERY_LOCAL)
					local targetZ

					for j = 1, 3 do
						if PVP.AVAids[keepId][j].objectiveId == objectiveId then
							targetZ = PVP.AVAids[keepId][j].height
							break
						end
					end

					local pinType = PVP_PINTYPE_TOWNFLAG
					local name = foundObjectives[i].objectiveName
					local alliance = GetCaptureAreaObjectiveOwner(keepId, objectiveId, BGQUERY_LOCAL)
					if targetX ~= 0 and targetY ~= 0 then
						local distance = zo_distance(selfX, selfY, targetX, targetY)
						if distance <= adjusted_POI_MAX_DISTANCE then
							insert(foundPOI,
								{
									pinType = pinType,
									targetX = targetX,
									targetY = targetY,
									targetZ = targetZ,
									distance = distance,
									name = name,
									alliance = alliance,
									keepId = keepId,
									objectiveId = objectiveId
								})
						end
					end
				end
			end

			local miscCoords = PVP.miscCoords
			local numMisc = #miscCoords
			for i = 1, numMisc do
				local misc = miscCoords[i]
				local pinType, targetX, targetY, targetZ, name, alliance, keepId = misc.pinType,
					misc.x, misc.y, misc.z, misc.name, misc.alliance, misc.keepId

				if targetX ~= 0 and targetY ~= 0 and (pinType == PVP_PINTYPE_MILEGATE or pinType == PVP_PINTYPE_BRIDGE) then
					local distance = zo_distance(selfX, selfY, targetX, targetY)
					if distance <= adjusted_MAX_DISTANCE then
						insert(foundPOI,
							{
								pinType = pinType,
								targetX = targetX,
								targetY = targetY,
								targetZ = targetZ,
								distance = distance,
								name = name,
								alliance = alliance,
								keepId = keepId
							})
					end
				end
			end

			local delvesCoords = PVP.delvesCoords
			local numDelves = #delvesCoords
			for i = 1, numDelves do
				local delve = delvesCoords[i]
				local pinType, targetX, targetY, targetZ, name = PVP_PINTYPE_DELVE, delve.x,
				delve.y, delve.z, 'Delve: ' .. delve.name

				if targetX ~= 0 and targetY ~= 0 then
					local distance = zo_distance(selfX, selfY, targetX, targetY)
					if distance <= adjusted_POI_MAX_DISTANCE then
						insert(foundPOI,
							{
								pinType = pinType,
								targetX = targetX,
								targetY = targetY,
								targetZ = targetZ,
								distance = distance,
								name = name
							})
					end
				end
			end
		end

		if currentMapIndex == PVP_MAPINDEX_IC and not PVP:IsInSewers() then
			local zoneId, subzoneId = GetCurrentSubZonePOIIndices()
			local icAllianceBases = PVP.icAllianceBases
			if zoneId == IC_ZONEID then	
				if icAllianceBases[subzoneId] then
					for k, v in pairs(icAllianceBases) do
						if k == subzoneId then
							local subZoneBases = icAllianceBases[k]
							for i = 1, 3 do
								local subZoneBase = subZoneBases[i]
								local pinType, targetX, targetY, targetZ, name, alliance = PVP_PINTYPE_IC_ALLIANCE_BASE,
								subZoneBase.x, subZoneBase.y, subZoneBase.z,
									GetPOIInfo(zoneId, k), subZoneBase.alliance
								local distance = zo_distance(selfX, selfY, targetX, targetY)
								local isCurrent = k == subzoneId
								if distance <= adjusted_MAX_DISTANCE then
									insert(foundPOI,
										{
											pinType = pinType,
											targetX = targetX,
											targetY = targetY,
											targetZ = targetZ,
											distance = distance,
											name = name,
											alliance = alliance,
											isCurrent = isCurrent
										})
								end
							end
						end
					end
				end

				local isCurrent = true
				local subzoneDoors = PVP.icDoors[subzoneId]
				if subzoneDoors then
					for k, v in pairs(subzoneDoors) do
						local subzoneDoor = subzoneDoors[k]
						-- local pinType, targetX, targetY, targetZ, name, doorType, angle = PVP_PINTYPE_IC_DOOR, subzoneDoor.x, subzoneDoor.y, subzoneDoor.z, PVP:Colorize(GetKeepName(subzoneDoor.location), PVP:AllianceToColor(GetKeepAlliance(subzoneDoor.location, BGQUERY_LOCAL))), subzoneDoor.type, subzoneDoor.angle
						local pinType, targetX, targetY, targetZ, name, doorType, angle = PVP_PINTYPE_IC_DOOR,
						subzoneDoor.x, subzoneDoor.y, subzoneDoor.z,
						GetKeepName(subzoneDoor.location), subzoneDoor.type, subzoneDoor.angle
						local distance = zo_distance(selfX, selfY, targetX, targetY)
						if distance <= adjusted_MAX_DISTANCE then
							insert(foundPOI,
								{
									pinType = pinType,
									targetX = targetX,
									targetY = targetY,
									targetZ = targetZ,
									distance = distance,
									name = name,
									isCurrent = isCurrent,
									doorType = doorType,
									orientation3d = angle,
									doorDistrictKeepId = subzoneDoor.location
								})
						end
					end
				end

				local zoneVaults = PVP.icVaults[zoneId]
				if zoneVaults then
					for k, v in pairs(zoneVaults) do
						local zoneVault = zoneVaults[k]
						local pinType, targetX, targetY, targetZ, name, poiId = PVP_PINTYPE_IC_VAULT,
						zoneVault.x, zoneVault.y, zoneVault.z,
							GetPOIInfo(341, zoneVault.poiId), zoneVault.poiId
						local distance = zo_distance(selfX, selfY, targetX, targetY)
						if distance <= adjusted_MAX_DISTANCE then
							insert(foundPOI,
								{
									pinType = pinType,
									targetX = targetX,
									targetY = targetY,
									targetZ = targetZ,
									distance = distance,
									name = name,
									isCurrent = isCurrent,
									poiId = poiId
								})
						end
					end
				end

				local zoneGrates = PVP.icGrates[subzoneId]
				if zoneGrates then
					for k, v in pairs(zoneGrates) do
						local zoneGrate = zoneGrates[k]
						local pinType, targetX, targetY, targetZ, name = PVP_PINTYPE_IC_GRATE, zoneGrate.x,
						zoneGrate.y, zoneGrate.z, zoneGrate.name
						local distance = zo_distance(selfX, selfY, targetX, targetY)
						if distance <= adjusted_MAX_DISTANCE then
							insert(foundPOI,
								{
									pinType = pinType,
									targetX = targetX,
									targetY = targetY,
									targetZ = targetZ,
									distance = distance,
									name = name,
									isCurrent = isCurrent
								})
						end
					end
				end
			end
		end

		-- if PVP:IsInSewers() then
		-- for k,v in pairs (PVP.sewers) do
		-- local pinType, targetX, targetY, targetZ, name, angle, x3d, y3d = PVP_PINTYPE_SEWERS_SIGN, v.x, v.y, v.z, v.name, v.angle, v.x3d, v.y3d
		-- local distance = zo_distance(selfX, selfY, targetX, targetY)

		-- if distance<=adjusted_MAX_DISTANCE then
		-- insert(foundPOI, {pinType = pinType, targetX = targetX, targetY = targetY, targetZ = targetZ, distance = distance, name = name, orientation3d = angle, x3d = x3d, y3d = y3d})
		-- end
		-- end
		-- end
	end

	local currentMapPings = PVP.currentMapPings
	local numPings = currentMapPings and #currentMapPings or 0
	if numPings > 0 then
		for i = 1, numPings do
			local currentPing = currentMapPings[i]
			if not currentPing.pingObject then
				if currentPing.pinType == MAP_PIN_TYPE_PLAYER_WAYPOINT then
					currentPing.targetX, currentPing.targetY = PVP.LMP:GetMapPing(
						MAP_PIN_TYPE_PLAYER_WAYPOINT)
				elseif currentPing.pinType == MAP_PIN_TYPE_RALLY_POINT then
					currentPing.targetX, currentPing.targetY = PVP.LMP:GetMapPing(
						MAP_PIN_TYPE_RALLY_POINT)
				elseif currentPing.pinType == MAP_PIN_TYPE_PING then
					currentPing.targetX, currentPing.targetY = PVP.LMP:GetMapPing(
						MAP_PIN_TYPE_PING, currentPing.pingTag)
				end

				if currentPing.targetX ~= 0 and currentPing.targetY ~= 0 then
					local distance = zo_distance(selfX, selfY, currentPing.targetX,
						currentPing.targetY)

					if distance <= adjusted_MAX_DISTANCE * 2 then
						local name
						if currentPing.pinType == MAP_PIN_TYPE_PLAYER_WAYPOINT then
							name = 'My waypoint'
						elseif currentPing.pinType == MAP_PIN_TYPE_RALLY_POINT then
							name = 'Group Rally point'
						elseif currentPing.pinType == MAP_PIN_TYPE_PING then
							if currentPing.pingTag then
								if currentPing.isLocalPlayerOwner then
									name = 'My Ping'
								else
									local unitName = PVP:GetValidName(GetRawUnitName(currentPing.pingTag))
									local formattedName = PVP:GetTargetChar(unitName)
									if not formattedName then
										formattedName = PVP:Colorize(zo_strformat(SI_UNIT_NAME, unitName),
											PVP:AllianceToColor(PVP.allianceOfPlayer))
									end
									name = formattedName .. PVP:Colorize(" ping", '00FFFF')
								end
							else
								name = 'Ping'
							end
						end
						insert(foundPOI,
							{
								pinType = currentPing.pinType,
								pingTag = currentPing.pingTag,
								targetX = currentPing.targetX,
								targetY = currentPing.targetY,
								distance = distance,
								name = name
							})
					end
				end
			end
		end
	end

	if #foundPOI > 0 then return foundPOI else return false end
end

local function FindBgObjectives()
	local battlegroundId = GetCurrentBattlegroundId()
	local battlegroundType = GetBattlegroundGameType(battlegroundId)
	local isBgCtf = battlegroundType == BATTLEGROUND_GAME_TYPE_CAPTURE_THE_FLAG

	-- if battlegroundType == BATTLEGROUND_GAME_TYPE_MURDERBALL then return end
	-- if PVP.arcaneIds[battlegroundId] then return end

	if not PVP:IsInSupportedBattlegroundGametype() then return end


	local foundObjectives = {}
	local selfX, selfY = GetMapPlayerPosition('player')
	for i = 1, GetNumObjectives() do
		local keepId, objectiveId, bgContext = GetObjectiveIdsForIndex(i)
		if keepId == 0 and bgContext == BGQUERY_LOCAL and DoesObjectiveExist(keepId, objectiveId, bgContext) then
			if isBgCtf then
				local pinType, targetX, targetY = GetObjectiveSpawnPinInfo(keepId, objectiveId, bgContext)
				if targetX ~= 0 and targetY ~= 0 then
					local distance = zo_distance(selfX, selfY, targetX, targetY)
					foundObjectives[objectiveId] = { distance = distance, isCtfBase = true }
				end
			else
				local pinType, targetX, targetY = GetObjectivePinInfo(keepId, objectiveId, bgContext)
				if targetX ~= 0 and targetY ~= 0 then
					local distance = zo_distance(selfX, selfY, targetX, targetY)
					foundObjectives[objectiveId] = { distance = distance }
				end
			end
		end
	end

	if next(foundObjectives) ~= nil then return foundObjectives else return false end
end


local function GetCurrentMapScaleFromBgObjectiveId()
	for k, v in pairs(PVP.bgMapScale) do
		if DoesObjectiveExist(0, k, BGQUERY_LOCAL) then
			return v * 55555.555
		end
	end

	return 100
end

function PVP:OnAbilityUsed(eventCode, slotNum)
	if not (GetUnitClassId('player') == 3 and PVP.SV.show3DIcons and PVP.SV.shadowImage3d) then return end
	local isSetup = GetSlotBoundId(slotNum) == 35441
	local isReturn = GetSlotBoundId(slotNum) == 35445
	if isSetup or isReturn then
		if not PVP.shadowInfo then
			PVP.shadowInfo = {}
		end
		PVP.shadowInfo.slotNumber = slotNum
	end

	if isReturn then
		PVP:ResetShadow()
	end
end

function PVP:UpdateNearbyKeepsAndPOIs(isActivated, isZoneChange) --// main function that handles 3d icons allocation. It is called each 250ms from main update loop (additionally on activate and on worldmapchanged) //
	-- PVP.pre3d = GetGameTimeMilliseconds()
	if not PVP:Should3DSystemBeOn() then
		PVP:FullReset3DIcons()
		return
	end

	local isActiveWorldBattleground = IsActiveWorldBattleground()
	if isActivated then -- // makes sure campaign tooltip stays up to date //
		if isActiveWorldBattleground then
			QueryBattlegroundLeaderboardData()
		else
			QueryCampaignSelectionData()
			QueryCampaignLeaderboardData()
		end
	end
	if isActivated and not DoesCurrentMapMatchMapForPlayerLocation() then -- // a precaution, probably not necessary at all //
		PVP.shouldActivate = true
		SetMapToPlayerLocation()
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	end
	if isZoneChange and PVP.shouldActivate then -- // a precaution, probably not necessary at all //
		PVP.shouldActivate = false
		isZoneChange = false
		isActivated = true
	end
	if not PVP:IsWorldMapHidden() then return end				-- // we can't trust map coordinates when the map is open to place 3d icons //

	if PVP.isWaitingOnTrustedFirstRun and GetActivationInfo() then -- // initial 3d-to-map coordinates setup finally happened - reanchor all icons //
		PVP.isWaitingOnTrustedFirstRun = false
		isActivated = true
	end
	if isActivated then
		PVP:FullReset3DIcons()
	end

	local currentNearbyKeepIds = self.currentNearbyKeepIds or {}
	local currentNearbyPOIIds = self.currentNearbyPOIIds or {}
	local currentObjectivesIds = self.currentObjectivesIds or {}
	local controls3DPool = self.controls3DPool

	local foundKeeps, foundPOI, foundBgObjectives
	-- PVP.afterInit3d = GetGameTimeMilliseconds()

	if isActiveWorldBattleground then
		foundBgObjectives = FindBgObjectives()
	else
		foundKeeps = FindNearbyKeeps() -- // returns a list of all keep objects nearby //
	end
	-- PVP.afterKeeps3d = GetGameTimeMilliseconds()
	foundPOI = FindNearbyPOIs() -- // returns a list of all non-keep objects nearby //
	-- PVP.afterPoi3d = GetGameTimeMilliseconds()
	if not foundKeeps and not foundPOI and not foundBgObjectives then
		PVP:FullReset3DIcons()
		return
	end
	if foundKeeps then
		for k, v in pairs(currentNearbyKeepIds) do -- // releases all active objects NOT found on this iteration (i.e. player got out of range) //
			if not foundKeeps[k] then
				controls3DPool:ReleaseObject(v.poolKey)
				currentNearbyKeepIds[k] = nil
			end
		end
		PVP.beforeMarker = GetGameTimeMilliseconds()
		local cc = 0
		for k, v in pairs(foundKeeps) do
			local newMarker = SetupNew3DMarker(k, v, isActivated, not currentNearbyKeepIds[k]) -- // sets up the 3d icons for each relevant keep //
			currentNearbyKeepIds[k] = newMarker
		end
		PVP.cc = cc
		PVP.afterMarker = GetGameTimeMilliseconds()
	else
		for k, v in pairs(currentNearbyKeepIds) do
			controls3DPool:ReleaseObject(v.poolKey)
		end
		currentNearbyKeepIds = {}
	end
	-- PVP.afterKeepsProc3d = GetGameTimeMilliseconds()
	if foundBgObjectives then
		for k, v in pairs(currentObjectivesIds) do -- // releases all active objects NOT found on this iteration (i.e. player got out of range) //
			if not foundBgObjectives[k] then
				controls3DPool:ReleaseObject(v.poolKey)
				currentObjectivesIds[k] = nil
			end
		end

		for k, v in pairs(foundBgObjectives) do
			local newBgControl = SetupNewBattlegroundObjective3DMarker(k, v.distance, isActivated, not currentObjectivesIds[k],
				v.isCtfBase) -- // sets up the 3d icons for each relevant keep //
			currentObjectivesIds[k] = newBgControl
		end
	else
		for k, v in pairs(currentObjectivesIds) do
			controls3DPool:ReleaseObject(v.poolKey)
		end
		currentObjectivesIds = {}
	end

	if foundPOI then
		for i = #currentNearbyPOIIds, 1, -1 do
			local found
			for k = 1, #foundPOI do -- // releases all active objects NOT found on this iteration (i.e. player got out of range) //
				if foundPOI[k].pinType == currentNearbyPOIIds[i].pinType and (foundPOI[k].pinType == PVP_PINTYPE_COMPASS or PVP.killLocationPintypeToName[foundPOI[k].pinType] or
						(foundPOI[k].targetX == currentNearbyPOIIds[i].targetX and
							foundPOI[k].targetY == currentNearbyPOIIds[i].targetY and
							(not foundPOI[k].pingTag or foundPOI[k].pingTag == currentNearbyPOIIds[i].pingTag))) then -- // found the same object - updates its distance from player and the name //
					found = k
					currentNearbyPOIIds[i].name = foundPOI[k].name
					currentNearbyPOIIds[i].distance = foundPOI[k].distance
					break
				end
			end
			if not found then
				controls3DPool:ReleaseObject(currentNearbyPOIIds[i].poolKey)
				remove(currentNearbyPOIIds, i)
			else
				remove(foundPOI, found) -- // removes duplicated object from the new found objects table //
			end
		end
		local oldTableSize = #currentNearbyPOIIds
		for i = 1, #foundPOI do -- // adds non duplicated objects to the currently active poi objects table //
			insert(currentNearbyPOIIds, foundPOI[i])
		end
		PVP.beforePoi = GetGameTimeMilliseconds()
		for i = 1, #currentNearbyPOIIds do
			local isNewObjective = i > oldTableSize
			local newPoiControl = SetupNew3DPOIMarker(i, isActivated, isNewObjective)
			currentNearbyPOIIds[i].control = newPoiControl
		end
		PVP.afterPoi = GetGameTimeMilliseconds()
	else
		for i = 1, #currentNearbyPOIIds do
			controls3DPool:ReleaseObject(currentNearbyPOIIds[i].poolKey)
		end
		currentNearbyPOIIds = {}
	end

	-- PVP.afterPoiProc3d = GetGameTimeMilliseconds()

	self.currentNearbyKeepIds = currentNearbyKeepIds
	self.currentNearbyPOIIds = currentNearbyPOIIds
	self.currentObjectivesIds = currentObjectivesIds
end

local function ControlHasMouseOverAdjusted(control, heading, angleZ, cameraX, cameraY, cameraZ, scaleAdjustment)
	local multiplier = GetDistanceMultiplier(control, scaleAdjustment)
	local controlSize = GetControlSizeForAngles(control, multiplier)
	local controlX, controlZ, controlY = ProcessDynamicControlPosition(control)


	local distance = zo_distance(cameraX, cameraY, controlX, controlY)

	local deltaX = controlX - cameraX
	local deltaY = controlY - cameraY
	local deltaZ = controlZ - cameraZ

	local controlHeading = asin(abs(deltaX) / distance)

	if deltaY > 0 then
		controlHeading = pi - controlHeading
	end

	if deltaX > 0 then
		controlHeading = -controlHeading
	end

	local controlGraceAngle = atan(0.5 * controlSize / distance)

	if control.params.type ~= 'COMPASS' and heading > controlHeading - controlGraceAngle and heading < controlHeading + controlGraceAngle then
		local lowerBoundZ, higherBoundZ

		lowerBoundZ = atan2((deltaZ - 0.5 * controlSize), distance)
		higherBoundZ = atan2((deltaZ + 0.5 * controlSize), distance)
		local distanceCheck = control.params.distance and PVP.currentTooltip and PVP.currentTooltip.params.distance and
			control.params.distance < PVP.currentTooltip.params.distance


		local validTooltipStatus = not PVP.currentTooltip or PVP.currentTooltip == control or distanceCheck

		if (-angleZ > lowerBoundZ and -angleZ < higherBoundZ) and validTooltipStatus then
			return true
		else
			return false
		end
	end
end

function PVP:GetMouseOverControl()
	local heading = GetAdjustedPlayerCameraHeading()
	local oldOrigin, _, angleZ, cameraX, cameraY, cameraZ = GetCameraInfo()
	local scaleAdjustment = GetCurrentMapScaleAdjustment()

	if oldOrigin then
		local objects = PVP.controls3DPool:GetActiveObjects()
		for k, v in pairs(objects) do
			if ControlHasMouseOverAdjusted(v, heading, angleZ, cameraX, cameraY, cameraZ, scaleAdjustment) then
				return v
			end
		end
	end
end

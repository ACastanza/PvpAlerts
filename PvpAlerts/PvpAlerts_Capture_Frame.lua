local PVP = PVP_Alerts_Main_Table

local FLAGTYPE_OTHER = PVP:GetGlobal('FLAGTYPE_OTHER')
local FLAGTYPE_NAVE = PVP:GetGlobal('FLAGTYPE_NAVE')
local FLAGTYPE_APSE = PVP:GetGlobal('FLAGTYPE_APSE')
local PVP_KEEPTYPE_ARTIFACT_KEEP = PVP:GetGlobal('PVP_KEEPTYPE_ARTIFACT_KEEP')
local PVP_KEEPTYPE_BORDER_KEEP = PVP:GetGlobal('PVP_KEEPTYPE_BORDER_KEEP')
local PVP_ALLIANCE_BASE_IC = PVP:GetGlobal('PVP_ALLIANCE_BASE_IC')
local PVP_ICON_MISSING = PVP:GetGlobal('PVP_ICON_MISSING')


function PVP:GetObjectiveIcon(keepType, alliance, keepId)
	if not PVP.objectiveIcons[keepType] then return PVP_ICON_MISSING end

	if keepType == KEEPTYPE_ARTIFACT_GATE then
		if keepId then
			return PVP.objectiveIcons[keepType][GetKeepPinInfo(keepId, 1)]
		else
			local allianceToClosedPinType = {
				[ALLIANCE_ALDMERI_DOMINION] = MAP_PIN_TYPE_ARTIFACT_GATE_CLOSED_ALDMERI_DOMINION,
				[ALLIANCE_DAGGERFALL_COVENANT] = MAP_PIN_TYPE_ARTIFACT_GATE_CLOSED_DAGGERFALL_COVENANT,
				[ALLIANCE_EBONHEART_PACT_COVENANT] = MAP_PIN_TYPE_ARTIFACT_GATE_CLOSED_EBONHEART_PACT,
			}
			return PVP.objectiveIcons[keepType][allianceToClosedPinType[alliance]]
		end
	end
	if keepType == PVP_KEEPTYPE_ARTIFACT_KEEP then return PVP.objectiveIcons[keepType][alliance] end
	if keepType == PVP_KEEPTYPE_BORDER_KEEP then return PVP.objectiveIcons[keepType][alliance] end
	if keepType == PVP_ALLIANCE_BASE_IC then return PVP.objectiveIcons[keepType][alliance] end

	local allianceIdToWord = {
		[ALLIANCE_ALDMERI_DOMINION] = 'aldmeri',
		[ALLIANCE_DAGGERFALL_COVENANT] = 'daggerfall',
		[ALLIANCE_EBONHEART_PACT] = 'ebonheart',
		[ALLIANCE_NONE] = 'neutral',
	}

	local icon = PVP.objectiveIcons[keepType]

	icon = zo_strgsub(icon, 'neutral', allianceIdToWord[alliance])

	return icon
end

local function GetFlagIcon(objectiveType, meter, alliance)
	local flagType, currentKeepFlag

	if objectiveType == KEEPTYPE_RESOURCE then
		flagType = FLAGTYPE_OTHER
		currentKeepFlag = FLAGTYPE_OTHER
	elseif objectiveType == KEEPTYPE_KEEP then
		if meter == 1 then
			flagType = FLAGTYPE_NAVE
			currentKeepFlag = FLAGTYPE_APSE
		elseif meter == 2 then
			flagType = FLAGTYPE_NAVE
		end
	elseif objectiveType == KEEPTYPE_TOWN then
		if meter == 1 then
			flagType = FLAGTYPE_OTHER
			currentKeepFlag = FLAGTYPE_OTHER
		elseif meter == 2 then
			flagType = FLAGTYPE_NAVE
		elseif meter == 3 then
			flagType = FLAGTYPE_NAVE
			currentKeepFlag = FLAGTYPE_APSE
		end
	end

	return PVP:GetObjectiveIcon(flagType, alliance), currentKeepFlag
end

local function UpdateValues(normalControl, meter, percentage, barColorR, barColorG, barColorB, alliance, underAttack)
	local flag

	if objectiveType == KEEPTYPE_KEEP then
		if meter == 1 then
			flag = GetControl(normalControl, 'Flag2')
			currentKeepFlag = FLAGTYPE_APSE
		elseif meter == 2 then
			flag = GetControl(normalControl, 'Flag1')
			-- currentKeepFlag = FLAGTYPE_NAVE
		end
	end

	if not flag then flag = GetControl(normalControl, 'Flag' .. tostring(meter)) end

	local icon = GetControl(flag, 'Icon')
	local iconUA = GetControl(flag, 'IconUnderAttack')
	local control = GetControl(flag, 'Meter')
	local bar = GetControl(control, 'Bar')
	local label = GetControl(control, 'Label')


	iconUA:SetHidden(not (percentage < 100 and underAttack))

	local flagIcon, currentKeepFlag = GetFlagIcon(objectiveType, meter, alliance)
	icon:SetTexture(flagIcon)
	if currentKeepFlag == FLAGTYPE_APSE then
		icon:SetTextureCoords(1, 0, 0, 1)
	else
		icon:SetTextureCoords(0, 1, 0, 1)
	end

	if currentKeepFlag == FLAGTYPE_OTHER then
		icon:SetDimensions(26, 22)
	else
		icon:SetDimensions(26, 26)
	end
	bar:SetDimensions((control:GetWidth() - 1.5) * percentage / 100, control:GetHeight() - 2)
	bar:SetCenterColor(barColorR, barColorG, barColorB)
	label:SetText(tostring(percentage) .. '%')
end

function PVP:UpdateNormalCaptureMeter(keepId)
	local numberObjectives = #PVP.currentObjectiveStatus

	local normalControl = GetControl(PVP_Capture, 'Normal')
	local keepControl = GetControl(PVP_Capture, 'Keep')
	local icControl = GetControl(PVP_Capture, 'ImperialCity')


	normalControl:SetHidden(false)
	keepControl:SetHidden(true)
	icControl:SetHidden(true)

	local normalHeader = GetControl(normalControl, 'Header')
	local normalHeaderIcon = GetControl(normalHeader, 'Icon')
	local normalHeaderIconUnderAttack = GetControl(normalHeader, 'IconUnderAttack')
	local normalHeaderLabel = GetControl(normalHeader, 'Label')
	local normalFlag1 = GetControl(normalControl, 'Flag1')
	local normalFlag2 = GetControl(normalControl, 'Flag2')
	local normalFlag3 = GetControl(normalControl, 'Flag3')


	normalFlag1:SetHidden(not (numberObjectives > 0))
	normalFlag2:SetHidden(not (numberObjectives > 1))
	normalFlag3:SetHidden(not (numberObjectives > 2))


	if numberObjectives > 0 then
		HUD_SCENE:AddFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		HUD_UI_SCENE:AddFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		LOOT_SCENE:AddFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		-- PVP_Capture:SetHidden(false)
	else
		HUD_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		PVP_Capture:SetHidden(true)
	end



	normalHeaderLabel:SetText(zo_strformat(SI_ALERTTEXT_LOCATION_FORMAT, GetKeepName(keepId)))
	normalHeaderLabel:SetColor(PVP:HtmlToColor(PVP:AllianceToColor(GetKeepAlliance(keepId, 1))))

	local keepType = GetKeepResourceType(keepId)
	if keepType == 0 then
		keepType = GetKeepType(keepId)
	end

	normalHeaderIcon:SetTexture(PVP:GetObjectiveIcon(keepType, GetKeepAlliance(keepId, 1)))

	local underAttack = GetKeepUnderAttack(keepId, 1)

	normalHeaderIconUnderAttack:SetHidden(not underAttack)

	local objectiveType

	if numberObjectives == 2 then  --keep/outpost
		objectiveType = KEEPTYPE_KEEP
	elseif numberObjectives == 3 then --town
		objectiveType = KEEPTYPE_TOWN
	elseif numberObjectives == 1 then --resource
		objectiveType = KEEPTYPE_RESOURCE
	end

	local wasCurrent

	for i = 1, numberObjectives do
		if PVP.currentObjectiveStatus[i].meter ~= 10 then
			local barColorR, barColorG, barColorB
			if PVP.currentObjectiveStatus[i].alliance ~= 0 then
				barColorR, barColorG, barColorB = PVP:HtmlToColor(PVP:AllianceToColor(PVP.currentObjectiveStatus[i]
					.alliance))
			else
				barColorR, barColorG, barColorB = 0, 0, 0
			end
			-- if PVP.SV.showNeighbourCaptureFrame and PVP.currentObjectiveStatus[i].isCurrent then
			if PVP.currentObjectiveStatus[i].isCurrent then
				PVP:SetCurrentObjectiveBackdrop(normalControl, objectiveType)
				wasCurrent = true
			end

			UpdateValues(normalControl, PVP.currentObjectiveStatus[i].meter, PVP.currentObjectiveStatus[i].percentage, barColorR,
				barColorG, barColorB, GetKeepAlliance(keepId, 1), GetKeepUnderAttack(keepId, 1))
		end
	end
	-- if PVP.SV.showNeighbourCaptureFrame and not wasCurrent then PVP:SetCurrentObjectiveBackdrop() end
	if not wasCurrent then PVP:SetCurrentObjectiveBackdrop() end
end

local function FlagsProcessing(control, id)
	for i = 1, 3 do
		local flag = GetControl(control, 'Flag' .. tostring(i))
		if i == 1 then
			flag:SetHidden(false)
			local flagIcon = GetControl(flag, 'Icon')
			flagIcon:SetTexture(PVP:GetObjectiveIcon(FLAGTYPE_OTHER, GetKeepAlliance(id, 1)))
			-- flagIcon:SetHidden(true)
		else
			flag:SetHidden(true)
		end
	end
end

local function UpdateKeepCaptureValues(mainControl, percentage, barColorR, barColorG, barColorB, alliance, meter, keepId)
	-- local flag = GetControl(mainControl, 'Icon')

	local control = GetControl(mainControl, 'Meter')
	local bar = GetControl(control, 'Bar')
	local label = GetControl(control, 'Label')

	local iconUA = GetControl(mainControl, 'IconUnderAttack')
	iconUA:SetHidden(not (percentage < 100 and GetKeepUnderAttack(keepId, 1)))
	-- if meter>2 then
	-- flag:SetTexture(PVP:GetObjectiveIcon(FLAGTYPE_OTHER, alliance))
	-- end

	bar:SetDimensions((control:GetWidth() - 1.5) * percentage / 100, control:GetHeight() - 2)
	bar:SetCenterColor(barColorR, barColorG, barColorB)
	label:SetText(tostring(percentage) .. '%')
end

function PVP:UpdateKeepCaptureMeter()
	local numberObjectives = #PVP.currentObjectiveStatus
	local normalControl = GetControl(PVP_Capture, 'Normal')
	local keepControl = GetControl(PVP_Capture, 'Keep')
	local icControl = GetControl(PVP_Capture, 'ImperialCity')

	normalControl:SetHidden(true)
	keepControl:SetHidden(false)
	icControl:SetHidden(true)

	local backdropControl = GetControl(keepControl, 'Backdrop')
	local keepSubcontrol = GetControl(keepControl, 'Keep')
	local keepHeader = GetControl(keepSubcontrol, 'Header')
	local keepHeaderIcon = GetControl(keepHeader, 'Icon')
	local keepHeaderIconUnderAttack = GetControl(keepHeader, 'IconUnderAttack')
	local keepHeaderLabel = GetControl(keepHeader, 'Label')

	local keepFlag1 = GetControl(keepSubcontrol, 'Flag1')
	local keepFlag1Icon = GetControl(keepFlag1, 'Icon')
	local keepFlag2 = GetControl(keepSubcontrol, 'Flag2')
	local keepFlag2Icon = GetControl(keepFlag2, 'Icon')
	local keepFlag3 = GetControl(keepSubcontrol, 'Flag3')

	local lm = GetControl(keepControl, 'Lumbermill')
	local lmHeader = GetControl(lm, 'Header')
	local lmIcon = GetControl(lmHeader, 'Icon')
	local lmIconUA = GetControl(lmHeader, 'IconUnderAttack')
	local lmLabel = GetControl(lmHeader, 'Label')

	local farm = GetControl(keepControl, 'Farm')
	local farmHeader = GetControl(farm, 'Header')
	local farmIcon = GetControl(farmHeader, 'Icon')
	local farmIconUA = GetControl(farmHeader, 'IconUnderAttack')
	local farmLabel = GetControl(farmHeader, 'Label')

	local mine = GetControl(keepControl, 'Mine')
	local mineHeader = GetControl(mine, 'Header')
	local mineIcon = GetControl(mineHeader, 'Icon')
	local mineIconUA = GetControl(mineHeader, 'IconUnderAttack')
	local mineLabel = GetControl(mineHeader, 'Label')

	farmIcon:SetDimensions(38, 38)
	farmIconUA:SetDimensions(50, 50)
	PVP:ReanchorControl(farmIcon, 2, 0)
	lmIcon:SetDimensions(32, 32)
	lmIconUA:SetDimensions(42, 42)
	PVP:ReanchorControl(lmIcon, -1, 0)
	mineIcon:SetDimensions(30, 30)
	mineIconUA:SetDimensions(40, 40)
	PVP:ReanchorControl(mineIcon, -3, -3)

	if numberObjectives > 0 then
		HUD_SCENE:AddFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		HUD_UI_SCENE:AddFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		LOOT_SCENE:AddFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		-- PVP_Capture:SetHidden(false)
	else
		HUD_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		PVP_Capture:SetHidden(true)
	end

	local keepId, lmId, farmId, mineId

	for k, v in pairs(PVP.currentKeepIdArray) do
		if v == KEEPTYPE_KEEP then
			keepId = k
		elseif v == RESOURCETYPE_FOOD then
			farmId = k
		elseif v == RESOURCETYPE_ORE then
			mineId = k
		elseif v == RESOURCETYPE_WOOD then
			lmId = k
		end
	end

	FlagsProcessing(lm, lmId)
	FlagsProcessing(farm, farmId)
	FlagsProcessing(mine, mineId)

	keepFlag1:SetHidden(false)
	keepFlag2:SetHidden(false)
	keepFlag3:SetHidden(true)

	lm:SetHidden(false)
	farm:SetHidden(false)
	mine:SetHidden(false)

	keepHeaderLabel:SetText(zo_strformat(SI_ALERTTEXT_LOCATION_FORMAT, GetKeepName(keepId)))
	lmLabel:SetText(zo_strformat(SI_ALERTTEXT_LOCATION_FORMAT, GetKeepName(lmId)))
	farmLabel:SetText(zo_strformat(SI_ALERTTEXT_LOCATION_FORMAT, GetKeepName(farmId)))
	mineLabel:SetText(zo_strformat(SI_ALERTTEXT_LOCATION_FORMAT, GetKeepName(mineId)))

	keepHeaderLabel:SetColor(PVP:HtmlToColor(PVP:AllianceToColor(GetKeepAlliance(keepId, 1))))

	lmLabel:SetColor(PVP:HtmlToColor(PVP:AllianceToColor(GetKeepAlliance(lmId, 1))))
	farmLabel:SetColor(PVP:HtmlToColor(PVP:AllianceToColor(GetKeepAlliance(farmId, 1))))
	mineLabel:SetColor(PVP:HtmlToColor(PVP:AllianceToColor(GetKeepAlliance(mineId, 1))))

	keepHeaderIcon:SetTexture(PVP:GetObjectiveIcon(GetKeepType(keepId), GetKeepAlliance(keepId, 1)))
	lmIcon:SetTexture(PVP:GetObjectiveIcon(RESOURCETYPE_WOOD, GetKeepAlliance(lmId, 1)))
	farmIcon:SetTexture(PVP:GetObjectiveIcon(RESOURCETYPE_FOOD, GetKeepAlliance(farmId, 1)))
	mineIcon:SetTexture(PVP:GetObjectiveIcon(RESOURCETYPE_ORE, GetKeepAlliance(mineId, 1)))


	keepFlag1Icon:SetTexture(PVP:GetObjectiveIcon(FLAGTYPE_NAVE, GetKeepAlliance(keepId, 1)))
	keepFlag1Icon:SetTextureCoords(0, 1, 0, 1)
	keepFlag2Icon:SetTexture(PVP:GetObjectiveIcon(FLAGTYPE_NAVE, GetKeepAlliance(keepId, 1)))
	keepFlag2Icon:SetTextureCoords(1, 0, 0, 1)

	keepHeaderIconUnderAttack:SetHidden(not GetKeepUnderAttack(keepId, 1))

	lmIconUA:SetHidden(not GetKeepUnderAttack(lmId, 1))
	farmIconUA:SetHidden(not GetKeepUnderAttack(farmId, 1))
	mineIconUA:SetHidden(not GetKeepUnderAttack(mineId, 1))

	local keepFlagToggle, mainControl, wasCurrent, backdropPoint, playerLeft, playerRight, textWidth, labelLeft, controlType, subControlType, worldControlType, objectiveId
	for i = 1, numberObjectives do
		if PVP.currentObjectiveStatus[i].meter ~= 10 then
			local barColorR, barColorG, barColorB
			if PVP.currentObjectiveStatus[i].alliance ~= 0 then
				barColorR, barColorG, barColorB = PVP:HtmlToColor(PVP:AllianceToColor(PVP.currentObjectiveStatus[i]
					.alliance))
			else
				barColorR, barColorG, barColorB = 0, 0, 0
			end

			if PVP.currentObjectiveStatus[i].keepId == keepId then
				if not keepFlagToggle then
					mainControl = keepFlag2
					keepFlagToggle = true
				else
					mainControl = keepFlag1
				end
				backdropPoint = keepSubcontrol
				controlType = KEEPTYPE_KEEP
				subControlType = KEEPTYPE_KEEP
				worldControlType = PVP_World
				objectiveId = keepId
			elseif PVP.currentObjectiveStatus[i].keepId == lmId then
				mainControl = GetControl(lm, 'Flag1')
				backdropPoint = lm
				controlType = KEEPTYPE_RESOURCE
				subControlType = RESOURCETYPE_WOOD
				worldControlType = PVP_WorldLM
				objectiveId = lmId
			elseif PVP.currentObjectiveStatus[i].keepId == farmId then
				mainControl = GetControl(farm, 'Flag1')
				backdropPoint = farm
				controlType = KEEPTYPE_RESOURCE
				subControlType = RESOURCETYPE_FOOD
				worldControlType = PVP_WorldFarm

				objectiveId = farmId
			elseif PVP.currentObjectiveStatus[i].keepId == mineId then
				mainControl = GetControl(mine, 'Flag1')
				backdropPoint = mine
				controlType = KEEPTYPE_RESOURCE
				subControlType = RESOURCETYPE_ORE
				worldControlType = PVP_WorldMine

				objectiveId = mineId
			end
			local isCurrent = PVP.currentObjectiveStatus[i].isCurrent

			if isCurrent then
				PVP:SetCurrentObjectiveBackdrop(backdropPoint, controlType)
				wasCurrent = true
			end

			-- self:Set3DMarker(objectiveId, subControlType, isCurrent, worldControlType)

			UpdateKeepCaptureValues(mainControl, PVP.currentObjectiveStatus[i].percentage, barColorR, barColorG, barColorB,
				PVP.currentObjectiveStatus[i].alliance, PVP.currentObjectiveStatus[i].meter,
				PVP.currentObjectiveStatus[i].keepId)
		end
	end
	if not wasCurrent then PVP:SetCurrentObjectiveBackdrop() end
end

local function UpdateDistrictCaptureValues(icControl, meter, percentage, barColorR, barColorG, barColorB, keepId, isCurrent)
	local district = GetControl(icControl, 'District' .. tostring(meter))
	if isCurrent then
		PVP:SetCurrentObjectiveBackdrop(district, KEEPTYPE_IMPERIAL_CITY_DISTRICT)
	end
	local headerIcon = GetControl(district, 'Icon')
	local headerIconUA = GetControl(district, 'IconUnderAttack')
	local headerLabel = GetControl(district, 'Label')



	local flag = GetControl(district, 'Flag1')
	local icon = GetControl(flag, 'Icon')
	-- local iconUA = GetControl(flag, 'IconUnderAttack')

	-- iconUA:SetHidden(not (percentage<100 and GetKeepUnderAttack(keepId, 1)))

	headerLabel:SetText(zo_strformat(SI_ALERTTEXT_LOCATION_FORMAT, GetKeepName(keepId)))
	headerLabel:SetColor(PVP:HtmlToColor(PVP:AllianceToColor(GetKeepAlliance(keepId, 1))))

	headerIcon:SetTexture(PVP:GetObjectiveIcon(GetKeepType(keepId), GetKeepAlliance(keepId, 1)))

	icon:SetTexture(PVP:GetObjectiveIcon(FLAGTYPE_OTHER, GetKeepAlliance(keepId, 1)))

	headerIconUA:SetHidden(not GetKeepUnderAttack(keepId, 1))

	local control = GetControl(flag, 'Meter')
	local bar = GetControl(control, 'Bar')
	local label = GetControl(control, 'Label')

	bar:SetDimensions((control:GetWidth() - 1.5) * percentage / 100, control:GetHeight() - 2)
	bar:SetCenterColor(barColorR, barColorG, barColorB)
	label:SetText(tostring(percentage) .. '%')
end

function PVP:UpdateDistrictCaptureMeter()
	local numberObjectives = #PVP.currentObjectiveStatus
	local normalControl = GetControl(PVP_Capture, 'Normal')
	local keepControl = GetControl(PVP_Capture, 'Keep')
	local icControl = GetControl(PVP_Capture, 'ImperialCity')

	normalControl:SetHidden(true)
	keepControl:SetHidden(true)
	icControl:SetHidden(false)

	if numberObjectives > 0 then
		HUD_SCENE:AddFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		HUD_UI_SCENE:AddFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		LOOT_SCENE:AddFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		-- PVP_Capture:SetHidden(false)
	else
		HUD_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		PVP_Capture:SetHidden(true)
	end

	local wasCurrent
	for i = 1, numberObjectives do
		if PVP.currentObjectiveStatus[i].meter ~= 10 then
			local barColorR, barColorG, barColorB
			if PVP.currentObjectiveStatus[i].alliance ~= 0 then
				barColorR, barColorG, barColorB = PVP:HtmlToColor(PVP:AllianceToColor(PVP.currentObjectiveStatus[i]
					.alliance))
			else
				barColorR, barColorG, barColorB = 0, 0, 0
			end
			if PVP.currentObjectiveStatus[i].isCurrent then
				wasCurrent = true
			end

			UpdateDistrictCaptureValues(icControl, PVP.currentObjectiveStatus[i].meter, PVP.currentObjectiveStatus[i].percentage, barColorR,
				barColorG, barColorB, PVP.currentObjectiveStatus[i].keepId, PVP.currentObjectiveStatus[i].isCurrent)
		end
	end
	if not wasCurrent then PVP:SetCurrentObjectiveBackdrop() end
end

function PVP:SetCurrentObjectiveBackdrop(currentControl, controlType)
	local backdropControl = PVP_CaptureBackdrop

	if not currentControl then
		backdropControl:SetHidden(true)
		return
	end


	local textWidthGrace = 0
	local rightSideMargin = 20
	local backdropOffsetX = -37
	local backdropOffsetY = -5

	if controlType == KEEPTYPE_TOWN then backdropOffsetY = -12 end
	if controlType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then backdropOffsetY = 3 end
	if controlType == KEEPTYPE_RESOURCE then
		backdropOffsetY = 0
		rightSideMargin = 15
	end

	backdropControl:ClearAnchors()
	backdropControl:SetAnchor(TOPLEFT, currentControl, TOPLEFT, backdropOffsetX, backdropOffsetY)

	local flagControl = GetControl(currentControl, 'Flag1')
	local meterControl = GetControl(flagControl, 'Meter')
	local headerControl

	if controlType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
		headerControl = currentControl
	else
		headerControl = GetControl(currentControl, 'Header')
	end

	local labelControl = GetControl(headerControl, 'Label')
	local sizeY

	if controlType == KEEPTYPE_KEEP then
		sizeY = 76
	elseif controlType == KEEPTYPE_TOWN then
		sizeY = 100 + 2
	elseif controlType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
		sizeY = 49
	else
		sizeY = 59
	end

	local labelComparison = (labelControl:GetLeft() - currentControl:GetLeft()) + labelControl:GetTextWidth() +
		textWidthGrace
	local meterComparison = (meterControl:GetRight() - currentControl:GetLeft())


	local backdropWidth

	if labelComparison > meterComparison then
		backdropWidth = labelComparison
	else
		backdropWidth = meterComparison
	end

	backdropControl:SetDimensions(backdropWidth + rightSideMargin - backdropOffsetX, sizeY)

	backdropControl:SetHidden(false)
end

function PVP:UpdateCaptureMeter(keepId, foundObjectives, infoType)
	if not keepId or keepId == 0 or keepId == {} or not PVP.currentObjectiveStatus then
		HUD_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		PVP_Capture:SetHidden(true)
		return
	end
	for i = 1, #PVP.currentObjectiveStatus do
		if infoType ~= 'zone' and PVP.currentObjectiveStatus[i].objectiveId == foundObjectives.objectiveId and PVP.currentObjectiveStatus[i].keepId == keepId and PVP.currentObjectiveStatus[i].meter ~= 10 then
			if infoType == 'control' then
				PVP.currentObjectiveStatus[i].objectiveState = foundObjectives.objectiveState
				PVP.currentObjectiveStatus[i].objectiveEvent = foundObjectives.objectiveEvent
				PVP.currentObjectiveStatus[i].alliance = PVP:CombineAllianceInfo(foundObjectives.allianceParam1,
					foundObjectives.allianceParam2)
				-- PVP.currentObjectiveStatus[i].alliance = GetCaptureAreaObjectiveOwner(PVP.currentObjectiveStatus[i].keepId, PVP.currentObjectiveStatus[i].objectiveId, BGQUERY_LOCAL)
				if not (PVP.currentObjectiveStatus[i].objectiveState == OBJECTIVE_CONTROL_STATE_AREA_ABOVE_CONTROL_THRESHOLD and PVP.currentObjectiveStatus[i].isCaptureStatus and (GetFrameTimeMilliseconds() - PVP.currentObjectiveStatus[i].isCaptureStatus < 5000)) then
					PVP.currentObjectiveStatus[i].percentage = PVP:GetCapturePercentFromAlliance(
						PVP.currentObjectiveStatus[i].objectiveState,
						GetKeepAlliance(PVP.currentObjectiveStatus[i].keepId, 1), PVP.currentObjectiveStatus[i].alliance)
				end
				PVP.currentObjectiveStatus[i].allianceParam1 = foundObjectives.allianceParam1
				PVP.currentObjectiveStatus[i].allianceParam2 = foundObjectives.allianceParam2
				PVP.currentObjectiveStatus[i].isCaptureStatus = foundObjectives.isCaptureStatus
			elseif infoType == 'capture' then
				PVP.currentObjectiveStatus[i].allianceParam1 = foundObjectives.allianceParam1
				PVP.currentObjectiveStatus[i].allianceParam2 = foundObjectives.allianceParam1
				PVP.currentObjectiveStatus[i].alliance = foundObjectives.allianceParam1
				PVP.currentObjectiveStatus[i].percentage = foundObjectives.capturePoolValue
				PVP.currentObjectiveStatus[i].isCaptureStatus = foundObjectives.isCaptureStatus
			end
		end
	end

	if self.SV.showNeighbourCaptureFrame then
		if #PVP.currentObjectiveStatus == 5 then
			PVP:UpdateKeepCaptureMeter()
		elseif #PVP.currentObjectiveStatus == 1 or #PVP.currentObjectiveStatus == 2 or #PVP.currentObjectiveStatus == 3 then
			PVP:UpdateNormalCaptureMeter(PVP.currentObjectiveStatus[1].keepId)
		elseif #PVP.currentObjectiveStatus == 6 then
			PVP:UpdateDistrictCaptureMeter()
		end
	else
		PVP:UpdateNormalCaptureMeter(keepId)
	end

	-- local foundObjectives = {objectiveName = objectiveName, objectiveId = objectiveId, objectiveState = objectiveControlState, allianceParam1 = objectiveParam1, allianceParam2 = objectiveParam2, objectiveEvent = objectiveControlEvent}

	-- local foundObjectives = {objectiveId = objectiveId, allianceParam1 = owningAlliance, capturePoolValue = capturePoolValue, capturingPlayers = capturingPlayers, contestingPlayers = contestingPlayers}
end

function PVP:GetCapturePercentFromAlliance(objectiveState, objectiveAlliance, captureAlliance)
	local percent
	if objectiveState == OBJECTIVE_CONTROL_STATE_AREA_ABOVE_CONTROL_THRESHOLD then
		if captureAlliance == objectiveAlliance then
			percent = 90
		else
			percent = 51
		end
	elseif objectiveState == OBJECTIVE_CONTROL_STATE_AREA_NO_CONTROL then
		if captureAlliance == 0 then
			percent = 0
		else
			percent = 10
		end
	elseif objectiveState == OBJECTIVE_CONTROL_STATE_AREA_MAX_CONTROL then
		percent = 100
	elseif objectiveState == OBJECTIVE_CONTROL_STATE_AREA_BELOW_CONTROL_THRESHOLD then
		if captureAlliance == objectiveAlliance then
			percent = 40
		else
			percent = 10
		end
	end

	if not percent then
		percent = 99
		-- d('missing percent!')
	end
	return percent
end

function PVP:SetupCurrentObjective(zoneText, keepId, foundObjectives, keepIdToUpdate, updateType)
	PVP.currentKeepIdArray = nil
	PVP.currentObjectiveStatus = nil

	if (zoneText and zoneText ~= "") or keepIdToUpdate then
		if not keepIdToUpdate then
			keepId, foundObjectives = self:FindAVAIds(zoneText)
		end
		-- if (keepId and (self.SV.showNeighbourCaptureFrame or keepId ~= 0)) or keepIdToUpdate then
		if keepId and (self.SV.showNeighbourCaptureFrame or keepId ~= 0) then
			if self.SV.showNeighbourCaptureFrame then
				PVP.currentKeepIdArray = keepId
			end
			PVP.currentObjectiveStatus = foundObjectives
			for i = 1, #PVP.currentObjectiveStatus do
				if not PVP.currentObjectiveStatus[i].isArtifact then
					PVP.currentObjectiveStatus[i].meter = i

					-- PVP.currentObjectiveStatus[i].alliance = PVP:CombineAllianceInfo(PVP.currentObjectiveStatus[i].allianceParam1, PVP.currentObjectiveStatus[i].allianceParam2)

					local captureAlliance = GetCaptureAreaObjectiveOwner(PVP.currentObjectiveStatus[i].keepId,
						PVP.currentObjectiveStatus[i].objectiveId, 1)

					if captureAlliance == 0 and not GetKeepUnderAttack(PVP.currentObjectiveStatus[i].keepId, 1) then
						captureAlliance =
							GetKeepAlliance(PVP.currentObjectiveStatus[i].keepId, 1)
					end


					-- PVP.currentObjectiveStatus[i].alliance = GetCaptureAreaObjectiveLastInfluenceState(PVP.currentObjectiveStatus[i].keepId, PVP.currentObjectiveStatus[i].objectiveId, 1)
					PVP.currentObjectiveStatus[i].alliance = captureAlliance

					if keepIdToUpdate and updateType and PVP.currentObjectiveStatus[i].keepId == keepIdToUpdate then
						if PVP.currentObjectiveStatus[i].objectiveState == OBJECTIVE_CONTROL_STATE_AREA_ABOVE_CONTROL_THRESHOLD then
							PVP.currentObjectiveStatus[i].percentage = 90
						else
							PVP.currentObjectiveStatus[i].percentage = 100
						end
					else
						PVP.currentObjectiveStatus[i].percentage = PVP:GetCapturePercentFromAlliance(
							PVP.currentObjectiveStatus[i].objectiveState,
							GetKeepAlliance(PVP.currentObjectiveStatus[i].keepId, 1),
							PVP.currentObjectiveStatus[i].alliance)
					end
				else
					PVP.currentObjectiveStatus[i].meter = 10
				end
			end
		end
	end
	PVP:UpdateCaptureMeter(keepId, nil, 'zone')
end

function PVP:FindAVAIds(zoneName, forceCurrentId)
	if not zoneName or zoneName == "" then return false end

	local neighbours = not forceCurrentId and self.SV.showNeighbourCaptureFrame

	local zoneId, subzoneId = GetCurrentSubZonePOIIndices()
	local isBruma = zoneId == 37 and subzoneId == 106

	local function FindNeighboursKeepId(zoneName, closestKeepId)
		local neighborsKeepIdToType, numberDistricts = {}, 0
		local foundKeepId
		if not closestKeepId then
			for i = 1, 200 do
				if neighbours and IsInImperialCity() then
					local keepType = GetKeepType(i)
					if keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
						neighborsKeepIdToType[i] = keepType
						numberDistricts = numberDistricts + 1
						if numberDistricts == 6 then
							foundKeepId = 666
							break
						end
					end
				else
					if GetKeepName(i) == zoneName or (isBruma and i == 151) then
						foundKeepId = i
						break
					end
				end
			end

			if not foundKeepId then return false end
		else
			foundKeepId = closestKeepId
		end

		if not neighbours then return foundKeepId end

		if foundKeepId == 666 then
			return neighborsKeepIdToType
		end

		local keepType = GetKeepType(foundKeepId)

		if (keepType ~= KEEPTYPE_KEEP and keepType ~= KEEPTYPE_RESOURCE) then
			neighborsKeepIdToType[foundKeepId] = keepType
			return neighborsKeepIdToType
		end

		if keepType == KEEPTYPE_KEEP then
			neighborsKeepIdToType[foundKeepId] = KEEPTYPE_KEEP
			for i = 1, 3 do
				local resourceId = GetResourceKeepForKeep(foundKeepId, i)
				neighborsKeepIdToType[resourceId] = i
			end
		elseif keepType == KEEPTYPE_RESOURCE then
			local foundResourceKeepId
			for i = 1, 200 do
				local resourceKeepType = GetKeepType(i)

				if resourceKeepType == KEEPTYPE_KEEP then
					for j = 1, 3 do
						if GetResourceKeepForKeep(i, j) == foundKeepId then
							foundResourceKeepId = i
							break
						end
					end
				end
				if foundResourceKeepId then break end
			end

			if not foundResourceKeepId then return false end

			neighborsKeepIdToType[foundResourceKeepId] = KEEPTYPE_KEEP

			for i = 1, 3 do
				local resourceId = GetResourceKeepForKeep(foundResourceKeepId, i)
				neighborsKeepIdToType[resourceId] = i
			end
		end

		return neighborsKeepIdToType
	end


	local neighborsKeepIdToType, targetKeepId, closestKeepId

	if self.SV.showNeighbourCaptureFrame and (zo_strmatch(zoneName, ' Grounds') or zo_strmatch(zoneName, ' grounds')) then
		closestKeepId = PVP:FindNearbyKeepToRespawn(true)
	end


	if neighbours then
		neighborsKeepIdToType = FindNeighboursKeepId(zoneName, closestKeepId)
		if not neighborsKeepIdToType then return false end
	else
		targetKeepId = FindNeighboursKeepId(zoneName)
		if not targetKeepId then return false end
	end

	local foundObjectives = {}

	for i = 1, GetNumAvAObjectives() do
		local keepId, objectiveId, battlegroundContext = GetAvAObjectiveKeysByIndex(i)
		if self:IsValidBattlegroundContext(battlegroundContext) and ((neighbours and neighborsKeepIdToType[keepId]) or (not neighbours and keepId == targetKeepId)) then
			local objectiveName, objectiveType, objectiveState, allianceParam1, allianceParam2 = GetAvAObjectiveInfo(
				keepId, objectiveId, battlegroundContext)
			local isArtifact = (objectiveType ~= 4)

			local isCurrent = zoneName == GetKeepName(keepId) or (isBruma and keepId == 151)


			if not isArtifact then
				table.insert(foundObjectives,
					{
						isCaptureStatus = false,
						isCurrent = isCurrent,
						keepId = keepId,
						objectiveName = objectiveName,
						objectiveId =
							objectiveId,
						objectiveState = objectiveState,
						allianceParam1 = allianceParam1,
						allianceParam2 =
							allianceParam2,
						isArtifact = isArtifact,
						keepType = GetKeepType(keepId),
						resourceType =
							GetKeepResourceType(keepId)
					})
			end
		end
	end


	if #foundObjectives > 0 then
		if neighbours then
			return neighborsKeepIdToType, foundObjectives
		else
			return targetKeepId, foundObjectives
		end
	else
		return false
	end
end

function PVP:ProcessDistrictNamePrompt()
	if not (not PVP.SV.unlocked and PVP.SV.showCaptureFrame and PVP.SV.showNeighbourCaptureFrame and not PVP_Capture:IsHidden() and not PVP_CaptureImperialCity:IsHidden() and IsInImperialCity() and PVP.currentObjectiveStatus and #PVP.currentObjectiveStatus > 0) then return end
	-- d('propmtStarted!')

	local isInDistrict
	for i = 1, #PVP.currentObjectiveStatus do
		if GetPlayerLocationName() == GetKeepName(PVP.currentObjectiveStatus[i].keepId) then
			isInDistrict = true
			break
		end
	end
	-- d('isInDistrict', isInDistrict)
	if not isInDistrict then
		local _, name = GetGameCameraInteractableActionInfo()

		if name and name ~= "" then
			-- d('nameBefore', name)
			for i = 1, #PVP.currentObjectiveStatus do
				local district = GetControl(PVP_CaptureImperialCity, 'District' .. tostring(i))
				local districtLabel = GetControl(district, 'Label')
				if districtLabel:GetText() == zo_strformat(SI_ALERTTEXT_LOCATION_FORMAT, name) then
					-- d('nameAfter', name)
					PVP.currentObjectiveStatus[i].isCurrent = true
				else
					PVP.currentObjectiveStatus[i].isCurrent = false
				end
			end
		else
			for i = 1, #PVP.currentObjectiveStatus do
				PVP.currentObjectiveStatus[i].isCurrent = false
			end
		end
		PVP:UpdateDistrictCaptureMeter()
	end
end

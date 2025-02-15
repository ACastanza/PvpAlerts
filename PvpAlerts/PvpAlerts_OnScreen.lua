---@class (partial) PvpAlerts
local PVP = PVP_Alerts_Main_Table
local PVP_KEEPTYPE_ARTIFACT_KEEP = PVP:GetGlobal('PVP_KEEPTYPE_ARTIFACT_KEEP')

function PVP:SetupOnScreen()
	local control = PVP_OnScreen
	local SV = self.SV
	local unlocked = SV.unlocked

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
	control.neighbor1 = control.neighbors:GetNamedChild('Neighbor1')
	control.neighbor2 = control.neighbors:GetNamedChild('Neighbor2')
	control.neighbor3 = control.neighbors:GetNamedChild('Neighbor3')

	control.locked:SetHidden(true)
	control.icon:SetHidden(not unlocked)
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
	control.ping:SetHidden(true)
	control.neighbors:SetHidden(not unlocked)
	control.neighbor1:SetHidden(false)
	control.neighbor2:SetHidden(false)
	control.neighbor3:SetHidden(false)

	control.neighbor1:GetNamedChild('Icon'):SetTexture("/esoui/art/compass/ava_farm_neutral.dds")
	control.neighbor2:GetNamedChild('Icon'):SetTexture("/esoui/art/compass/ava_mine_neutral.dds")
	control.neighbor3:GetNamedChild('Icon'):SetTexture("/esoui/art/compass/ava_lumbermill_neutral.dds")

	-- control.locked:SetAnchor(CENTER, control, CENTER, -1, 0)
	-- control.icon:SetAnchor(CENTER, control, CENTER, 0, 0)
	-- control.iconUA:SetAnchor(CENTER, control, CENTER, -1, 0)
	-- control.bg:SetAnchor(CENTER, control, CENTER, 0, 0)
	-- control.captureBG:SetAnchor(CENTER, control, CENTER, 0, 0)
	-- control.captureBar:SetAnchor(CENTER, control, CENTER, 0, 0)
	-- control.divider:SetAnchor(CENTER, control, CENTER, 0, 0)
	-- control.scroll:SetAnchor(CENTER, control, CENTER, 0, 0)
	-- control.flags:SetAnchor(CENTER, control, CENTER, 0, 0)
	-- control.apse:SetAnchor(CENTER, control, CENTER, 0, 0)
	-- control.nave:SetAnchor(CENTER, control, CENTER, 0, 0)
	-- control.other:SetAnchor(CENTER, control, CENTER, 0, 0)
	-- control.middle:SetAnchor(CENTER, control, CENTER, 0, 0)


	-- control:SetDrawLayer(0)
	-- control:SetDrawLevel(0)

	-- control.locked:SetColor(1, 0, 0)
	-- control.iconUA:SetColor(1, 1, 1)
	-- control.bg:SetColor(1, 1, 1)

	control:SetMovable(unlocked)
	control:SetMouseEnabled(unlocked)

	if unlocked then
		control.neighbors:ClearAnchors()
		control.neighbors:SetAnchor(TOP, control.siege, BOTTOM, 0, 20)
	end
	local onScreenScale = SV.onScreenScale
	control:SetScale(onScreenScale)
	control.neighbors:SetScale(onScreenScale / 2.5)

	local namesFontSize = 18 + zo_min(zo_ceil((onScreenScale - 0.5) * 8), 8)
	local siegeFontSize = 16 + zo_min(zo_ceil((onScreenScale - 0.5) * 6), 6)

	control.name:SetFont("$(BOLD_FONT)|$(KB_" .. tostring(namesFontSize) .. ")|thick-outline")
	control.siege:SetFont("$(BOLD_FONT)|$(KB_" .. tostring(siegeFontSize) .. ")|thick-outline")

	control:ClearAnchors()
	control:SetAnchor(CENTER, GuiRoot, CENTER, SV.onScreenOffsetX, SV.onScreenOffsetY)

	control.name:SetText(unlocked and "OnScreen Objective Frame" or "")
	control.siege:SetText(unlocked and "Number of Sieges" or "")
	
	if unlocked then PVP_OnScreen.currentKeepId = nil end

	PVP_OnScreenBackdrop:SetHidden(not unlocked)

	control:SetHidden(not (unlocked and SV.showOnScreen))
end

function PVP:ManageOnScreen(iconTexture, scrollTexture, captureTexture, naveFlag, apseFlag, otherFlag, naveAlliance,
							apseAlliance, otherAlliance, siegeTexture, shouldHideUA, shouldHideLock, shouldHideScroll,
							shouldHideCapture, shouldHideFlags, shouldHideSieges, siegesAD, siegesDC, siegesEP, keepName,
							keepId, control, isMisc)
	local isMainControl = control == PVP_OnScreen
	if isMainControl then
		control = PVP_OnScreen
		control.name:SetText(keepName)
		local shouldMoveResources
		if not shouldHideSieges then
			local siegeADText = siegesAD > 0 and (' ' .. self:Colorize(tostring(siegesAD), self:AllianceToColor(1))) or ""
			local siegeDCText = siegesDC > 0 and (' ' .. self:Colorize(tostring(siegesDC), self:AllianceToColor(3))) or ""
			local siegeEPText = siegesEP > 0 and (' ' .. self:Colorize(tostring(siegesEP), self:AllianceToColor(2))) or ""
			control.siege:SetText('Siege:' .. siegeADText .. siegeDCText .. siegeEPText)
		else
			control.siege:SetText('')
			shouldMoveResources = true
		end

		control.neighbors:SetHidden(not (keepId and (GetKeepResourceType(keepId) ~= 0 or GetKeepType(keepId) == KEEPTYPE_KEEP)))
		control.neighbors:ClearAnchors()
		if shouldMoveResources then
			control.neighbors:SetAnchor(TOP, control.siege, BOTTOM, 0, -20)
		else
			control.neighbors:SetAnchor(TOP, control.siege, BOTTOM, 0, 15)
		end
	elseif keepId then
		-- d('control', control)
		-- d('keepId', keepId)
		control.locked = control.locked or control:GetNamedChild('Locked')
		control.icon = control.icon or control:GetNamedChild('Icon')
		control.iconUA = control.iconUA or control:GetNamedChild('IconUA')
		control.bg = control.bg or control:GetNamedChild('BG')
		control.captureBG = control.captureBG or control:GetNamedChild('CaptureBG')
		control.captureBar = control.captureBar or control:GetNamedChild('CaptureBar')
		control.divider = control.divider or control:GetNamedChild('Divider')
		control.scroll = control.scroll or control:GetNamedChild('Scroll')
		control.flags = control.flags or control:GetNamedChild('Flags')
		control.apse = control.apse or control:GetNamedChild('Apse')
		control.nave = control.nave or control:GetNamedChild('Nave')
		control.other = control.other or control:GetNamedChild('Other')
		control.middle = control.middle or control:GetNamedChild('Middle')
		control.name = control.name or control:GetNamedChild('Name')
		control.siege = control.siege or control:GetNamedChild('Siege')
	end

	if keepId then
		if isMisc then
			if self:IsMiscPassable(keepId) then
				control.icon:SetColor(0, 1, 0)
			else
				control.icon:SetColor(1, 0, 0)
			end
		else
			control.icon:SetColor(1, 1, 1)
		end
		if isMainControl then
			if isMisc then
				if self:IsMiscPassable(keepId) then
					control.name:SetColor(0, 1, 0)
				else
					control.name:SetColor(1, 0, 0)
				end
			else
				control.name:SetColor(self:GetTrueAllianceColors(GetKeepAlliance(keepId, 1)))
			end
		end
		if GetKeepResourceType(keepId) ~= 0 then
			if isMainControl and shouldHideCapture then
				control.icon:SetDimensions(100, 100)
				control.iconUA:SetDimensions(110, 110)
			else
				control.icon:SetDimensions(75, 75)
				control.iconUA:SetDimensions(95, 95)
			end
		elseif PVP:KeepIdToKeepType(keepId) == KEEPTYPE_OUTPOST then
			control.icon:SetDimensions(85, 85)
			control.iconUA:SetDimensions(95, 95)
		elseif PVP:KeepIdToKeepType(keepId) == KEEPTYPE_TOWN then
			control.icon:SetDimensions(75, 75)
			control.iconUA:SetDimensions(100, 100)
		elseif PVP:KeepIdToKeepType(keepId) == PVP_KEEPTYPE_ARTIFACT_KEEP then
			control.icon:SetDimensions(85, 85)
			control.iconUA:SetDimensions(100, 100)
		elseif PVP:KeepIdToKeepType(keepId) == KEEPTYPE_ARTIFACT_GATE then
			control.icon:SetDimensions(85, 85)
			control.iconUA:SetDimensions(100, 100)
		elseif PVP:KeepIdToKeepType(keepId) == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
			control.icon:SetDimensions(85, 85)
			control.iconUA:SetDimensions(90, 90)
		else
			control.icon:SetDimensions(100, 100)
			control.iconUA:SetDimensions(110, 110)
		end
	else
		if otherAlliance == ALLIANCE_NONE then
			if isMainControl then control.name:SetColor(0.5, 0.5, 0.5) end
			control.icon:SetColor(0.5, 0.5, 0.5)
		else
			if isMainControl then control.name:SetColor(PVP:GetTrueAllianceColors(GetKeepAlliance(otherAlliance, 1))) end
			control.icon:SetColor(PVP:GetTrueAllianceColors(GetKeepAlliance(otherAlliance, 1)))
		end
		control.icon:SetDimensions(75, 75)
		control.iconUA:SetDimensions(100, 100)
	end

	control.locked:SetHidden(shouldHideLock)
	control.icon:SetHidden(false)
	control.iconUA:SetHidden(shouldHideUA)
	control.bg:SetHidden(shouldHideSieges)
	control.captureBG:SetHidden(shouldHideCapture)
	control.captureBar:SetHidden(shouldHideCapture)
	control.divider:SetHidden(shouldHideCapture)
	control.scroll:SetHidden(shouldHideScroll)
	control.flags:SetHidden(shouldHideFlags)
	control.apse:SetHidden(not apseFlag)
	control.nave:SetHidden(not naveFlag)
	control.other:SetHidden(not otherFlag)
	control.middle:SetHidden(shouldHideFlags)

	control.icon:SetTexture(iconTexture)
	control.scroll:SetTexture(scrollTexture)
	if captureTexture and captureTexture ~= "" then
		control.captureBar:SetTexture(captureTexture)
	end
	control.bg:SetTexture(siegeTexture)

	if not shouldHideFlags then
		control.nave:SetTexture(naveFlag)
		control.apse:SetTexture(apseFlag)
		control.nave:SetColor(PVP:GetTrueAllianceColors(naveAlliance))
		control.apse:SetColor(PVP:GetTrueAllianceColors(apseAlliance))
		if otherFlag then
			control.other:SetColor(PVP:GetTrueAllianceColors(otherAlliance))
			control.other:SetTexture(otherFlag)
			control.flags:SetTexture('PvpAlerts/textures/3barsTemplateLargeFilled.dds')
			control.middle:SetTexture('PvpAlerts/textures/3barsMiddleLineLarge.dds')
		else
			control.flags:SetTexture('PvpAlerts/textures/2barsTemplateLargeFilled.dds')
			control.middle:SetTexture('PvpAlerts/textures/2barsMiddleLineLarge.dds')
		end
	end

	PVP_OnScreen:SetHidden(not (SCENE_MANAGER:GetCurrentScene() == HUD_SCENE or SCENE_MANAGER:GetCurrentScene() == LOOT_SCENE or SCENE_MANAGER:GetCurrentScene() == HUD_UI_SCENE))
end

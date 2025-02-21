---@class (partial) PvpAlerts
local PVP = PVP_Alerts_Main_Table

local PVP_NAME_FONT = PVP:GetGlobal('PVP_NAME_FONT')
local PVP_COUNTER_FONT = PVP:GetGlobal('PVP_COUNTER_FONT')
local PVP_NUMBER_FONT = PVP:GetGlobal('PVP_NUMBER_FONT')
local PVP_LARGE_NUMBER_FONT = PVP:GetGlobal('PVP_LARGE_NUMBER_FONT')

local PVP_DEFAULT_ICON = PVP:GetGlobal('PVP_DEFAULT_ICON')
local PVP_DEFAULT_HEAVY_ATTACK_ICON = PVP:GetGlobal('PVP_DEFAULT_HEAVY_ATTACK_ICON')

function PVP:InitControls()
	if self.noInitControls then
		self.delayedInitControls = true
		return
	end
	if self.delayedInitControls then
		self.delayedInitControls = false
		zo_callLater(function() self:InitControls() end, 250)
		return
	end
	self:SetupOnScreen()
	PVP_Main:ClearAnchors()

	local SV = self.SV
	local unlocked = SV.unlocked

	PVP_Main:SetAnchor(CENTER, GuiRoot, CENTER, SV.offsetX, SV.offsetY)

	PVP_Main:SetScale(1)

	self.mainFrameLabelDimensionX, self.mainFrameLabelDimensionY = PVP_MainLabel:GetDimensions()
	
	-- PVP_MainLabel:SetResizeToFitDescendents(false)
	local controlScale = SV.controlScale
	PVP_Main:SetScale(controlScale)

	PVP_MainBackdrop:ClearAnchors()
	PVP_MainBackdrop:SetAnchor(TOPLEFT, PVP_Main, TOPLEFT, -70*controlScale, -35*controlScale)
	PVP_MainBackdrop:SetAnchor(BOTTOMRIGHT, PVP_Main, BOTTOMRIGHT, 60*controlScale, 35*controlScale)

	PVP_MainBackdrop_Add:ClearAnchors()
	PVP_MainBackdrop_Add:SetAnchor(TOPLEFT, PVP_Main, TOPLEFT, -70*controlScale, -35*controlScale)
	PVP_MainBackdrop_Add:SetAnchor(BOTTOMRIGHT, PVP_Main, BOTTOMRIGHT, 60*controlScale, 35*controlScale)

	PVP_Counter:ClearAnchors()
	PVP_Counter:SetAnchor(CENTER, GuiRoot, CENTER, SV.counterOffsetX, SV.counterOffsetY)
	PVP_Counter:SetScale(1)

	PVP_TUG:ClearAnchors()
	PVP_TUG:SetAnchor(CENTER, GuiRoot, CENTER, SV.tugOffsetX, SV.tugOffsetY)
	PVP_TUG:SetScale(1)

	PVP_KillFeed:SetScale(SV.feedControlScale)
	PVP_KillFeed_Text:SetHorizontalAlignment(SV.feedTextAlign)
	PVP_KillFeed:ClearAnchors()
	PVP_KillFeed:SetAnchor(CENTER, GuiRoot, CENTER, SV.feedOffsetX, SV.feedOffsetY)

	self:ScaleControls(PVP_KillFeed, PVP_KillFeed_Text, 19, SV.feedControlScale)

	PVP_Names:SetScale(SV.namesControlScale)
	PVP_Names:ClearAnchors()
	PVP_Names:SetAnchor(CENTER, GuiRoot, CENTER, SV.namesOffsetX, SV.namesOffsetY)

	self:ScaleControls(PVP_Names, PVP_Names_Text, 18, SV.namesControlScale)

	PVP_KOS:SetScale(SV.KOSControlScale)
	PVP_KOS:ClearAnchors()
	PVP_KOS:SetAnchor(CENTER, GuiRoot, CENTER, SV.KOSOffsetX, SV.KOSOffsetY)

	self:ScaleControls(PVP_KOS, PVP_KOS_Text, 17, SV.KOSControlScale, 400/350)


	PVP_ForwardCamp:ClearAnchors()
	PVP_ForwardCamp:SetAnchor(CENTER, GuiRoot, CENTER, SV.campOffsetX, SV.campOffsetY)
	PVP_ForwardCamp:SetScale(SV.campControlScale)

	PVP_Medals:ClearAnchors()
	PVP_Medals:SetAnchor(CENTER, GuiRoot, CENTER, SV.medalsOffsetX, SV.medalsOffsetY)
	-- PVP_TargetName:SetScale(1)

	PVP_TargetName:ClearAnchors()
	PVP_TargetName:SetAnchor(CENTER, GuiRoot, CENTER, SV.targetOffsetX, SV.targetOffsetY)
	PVP_TargetName:SetScale(SV.targetNameFrameScale)
	PVP_TargetNameLabel:SetFont("$(BOLD_FONT)|30|soft-shadow-thick")

	PVP_TargetNameLabel:SetHorizontalAlignment(SV.targetTextAlign)

	PVP_WorldTooltipLabel:SetFont("$(BOLD_FONT)|$(KB_20)|thick-outline")

	PVP_NewAttacker:ClearAnchors()
	PVP_NewAttacker:SetAnchor(CENTER, GuiRoot, CENTER, SV.newAttackerOffsetX, SV.newAttackerOffsetY)
	PVP_NewAttacker:SetScale(SV.newAttackerFrameScale)
	PVP_NewAttackerNumber:SetScale(1)
	PVP_NewAttackerLabel:SetScale(1)
	PVP_NewAttackerNumber:SetFont("$(BOLD_FONT)|120|soft-shadow-thick")
	PVP_NewAttackerLabel:SetFont("$(BOLD_FONT)|35|soft-shadow-thick")


	PVP_Capture:ClearAnchors()
	PVP_Capture:SetAnchor(CENTER, GuiRoot, CENTER, SV.captureOffsetX, SV.captureOffsetY)

	PVP_Counter_Label:SetFont(PVP_COUNTER_FONT)

	PVP_Counter_CountContainer_CountAD:SetFont(PVP_NUMBER_FONT)
	PVP_Counter_CountContainer_CountDC:SetFont(PVP_NUMBER_FONT)
	PVP_Counter_CountContainer_CountEP:SetFont(PVP_NUMBER_FONT)
	PVP_Counter_CountContainer_SpacerADDC:SetFont(PVP_NUMBER_FONT)
	PVP_Counter_CountContainer_SpacerDCEP:SetFont(PVP_NUMBER_FONT)
	
	-- PVP_Main_Label:SetFont(PVP_NAME_FONT)
	if self.fadeOutIsPlaying and self.fadeOutIsPlaying:IsPlaying() then self.fadeOutIsPlaying:Stop() end

	if unlocked then
		-- self.testNamesProc={}
		-- self:TestFunction()
		if SV.showAttacks then
			self:OnDraw(false, "unlock", "unlocked frame", 0, "", "WARNING MESSAGE", false, false, false, 2500)
		end
		if SV.showCounterFrame then
			PVP_Counter_Label:SetText("Unlocked")
		end

		if self:ShouldShowCampFrame() then
			PVP_ForwardCamp_Icon:SetColor(1,1,1)
		end

		PVP_KillFeed_Text:Clear()
		if SV.showKillFeedFrame then
			PVP_KillFeed_Text:AddMessage("KILL FEED UNLOCKED")
			PVP_KillFeed_Text:AddMessage("Player died from a nasty ability")
			PVP_KillFeed_Text:AddMessage("Another Player died from a nasty ability")
			PVP_KillFeed_Text:AddMessage("Yet Another Player died from a nasty ability")
		end
		PVP_Names_Text:Clear()
		if SV.showNamesFrame then
			PVP_Names_Text:AddMessage("NAMES FRAME UNLOCKED")
			PVP_Names_Text:AddMessage("Some player")
			PVP_Names_Text:AddMessage("Another player")
			PVP_Names_Text:AddMessage("Yet another player")
		end
		PVP_KOS_Text:Clear()
		if SV.showKOSFrame then
			PVP_KOS_Text:AddMessage("KOS FRAME UNLOCKED")
			PVP_KOS_Text:AddMessage("Some KOS player")
			PVP_KOS_Text:AddMessage("Another KOS player")
			PVP_KOS_Text:AddMessage("Yet another KOS player")
		end

		PVP_TargetName:SetAlpha(SV.targetNameFrameAlpha)
		PVP_TargetNameBackdrop:SetHidden(false)

		PVP_NewAttacker:SetAlpha(SV.newAttackerFrameAlpha)
		PVP_NewAttackerBackdrop:SetHidden(false)
		if SV.showTargetNameFrame then
			PVP_TargetNameLabel:SetText("Target Player Name")
		end

		if SV.showNewAttackerFrame then
			PVP_NewAttackerNumber:SetText("10")
			PVP_NewAttackerLabel:SetText("New Attacker Name")
		end

		if SV.showMedalsFrame then
			PVP_Medals:SetAlpha(1)
			PVP_MedalsIcon:SetTexture('/esoui/art/icons/battleground_medal_flagcapture_002.dds')
			PVP_MedalsName:SetText('Expert Relic Runner')
			PVP_MedalsScore:SetText('x2')

		else
			PVP_Medals:SetAlpha(0)
		end


		if SV.showCaptureFrame then
			PVP_Capture:SetHidden(false)
			local showNeighbourCaptureFrame = SV.showNeighbourCaptureFrame
			if IsInImperialCity() then
				PVP_CaptureNormal:SetHidden(true)
				PVP_CaptureKeep:SetHidden(true)
				PVP_CaptureImperialCity:SetHidden(false)

				PVP_CaptureImperialCityDistrict1:SetHidden(false)
				PVP_CaptureImperialCityDistrict2:SetHidden(not showNeighbourCaptureFrame)
				PVP_CaptureImperialCityDistrict3:SetHidden(not showNeighbourCaptureFrame)
				PVP_CaptureImperialCityDistrict4:SetHidden(not showNeighbourCaptureFrame)
				PVP_CaptureImperialCityDistrict5:SetHidden(not showNeighbourCaptureFrame)
				PVP_CaptureImperialCityDistrict6:SetHidden(not showNeighbourCaptureFrame)

			elseif showNeighbourCaptureFrame then
				PVP_CaptureKeep:SetHidden(false)
				PVP_CaptureNormal:SetHidden(true)
				PVP_CaptureImperialCity:SetHidden(true)

				PVP_CaptureKeepKeepFlag1:SetHidden(false)
				PVP_CaptureKeepKeepFlag2:SetHidden(false)
				PVP_CaptureKeepKeepFlag3:SetHidden(true)

				PVP_CaptureKeepFarmFlag1:SetHidden(false)
				PVP_CaptureKeepFarmFlag2:SetHidden(true)
				PVP_CaptureKeepFarmFlag3:SetHidden(true)

				PVP_CaptureKeepLumbermillFlag1:SetHidden(false)
				PVP_CaptureKeepLumbermillFlag2:SetHidden(true)
				PVP_CaptureKeepLumbermillFlag3:SetHidden(true)

				PVP_CaptureKeepMineFlag1:SetHidden(false)
				PVP_CaptureKeepMineFlag2:SetHidden(true)
				PVP_CaptureKeepMineFlag3:SetHidden(true)

			else
				PVP_CaptureNormal:SetHidden(false)
				PVP_CaptureKeep:SetHidden(true)
				PVP_CaptureImperialCity:SetHidden(true)
				PVP_CaptureNormalFlag1:SetHidden(false)
				PVP_CaptureNormalFlag2:SetHidden(false)
				PVP_CaptureNormalFlag3:SetHidden(true)
			end
		end

		PVP_Names_Text:SetLineFade(0, 0)
		PVP_KillFeed_Text:SetLineFade(0, 0)
	else
		PVP_MainLabel:SetText("")
		if IsActiveWorldBattleground() then
			PVP_Counter_Label:SetText("FD/SL/PD")
		else
			PVP_Counter_Label:SetText("AD/DC/EP")
		end

		PVP_KillFeed_Text:Clear()
		PVP_Names_Text:Clear()
		PVP_KOS_Text:Clear()
		PVP_Names_Text:SetLineFade(13, 2)
		PVP_KillFeed_Text:SetLineFade(8, 2)

		PVP_TargetNameLabel:SetText("")
		PVP_TargetName:SetAlpha(0)
		PVP_NewAttackerNumber:SetText("")
		PVP_NewAttackerLabel:SetText("")
		PVP_NewAttacker:SetAlpha(0)
		PVP_Medals:SetAlpha(0)
		PVP_TargetNameBackdrop:SetHidden(true)
		PVP_NewAttackerBackdrop:SetHidden(true)

		PVP_Capture:SetHidden(true)
		PVP_WorldTooltip:SetHidden(true)
	end

	PVP_MainLabel:SetColor(1,1,1)
	PVP_Counter_Label:SetColor(1,1,1)
	PVP_Counter_CountContainer:SetMouseEnabled(false)
	PVP_Counter_CountContainer_CountAD:SetMouseEnabled(true)
	PVP_Counter_CountContainer_CountDC:SetMouseEnabled(true)
	PVP_Counter_CountContainer_CountEP:SetMouseEnabled(true)

	if IsActiveWorldBattleground() then
		PVP_Counter_CountContainer_CountAD:SetColor(GetBattlegroundTeamColor(1):UnpackRGBA())
		PVP_Counter_CountContainer_CountDC:SetColor(GetBattlegroundTeamColor(3):UnpackRGBA())
		PVP_Counter_CountContainer_CountEP:SetColor(GetBattlegroundTeamColor(2):UnpackRGBA())
	else
		PVP_Counter_CountContainer_CountAD:SetColor(0.764,0.666,0.286)
		PVP_Counter_CountContainer_CountDC:SetColor(0.407,0.556,0.694)
		PVP_Counter_CountContainer_CountEP:SetColor(0.87,0.36,0.309)
	end

	PVP_Main:SetMouseEnabled(unlocked)
	PVP_Main:SetMovable(unlocked)
	PVP_Main:SetAlpha(1)

	PVP_Counter:SetMouseEnabled(unlocked)
	PVP_Counter:SetMovable(unlocked)
	PVP_Counter:SetAlpha(1)

	PVP_TUG:SetMouseEnabled(unlocked)
	PVP_TUG:SetMovable(unlocked)
	PVP_TUG:SetAlpha(1)

	PVP_KillFeed:SetMouseEnabled(true)
	PVP_KillFeed_Text:SetMouseEnabled(not unlocked)
	PVP_KillFeed:SetMovable(unlocked)
	PVP_KillFeed_Text:SetLinkEnabled(not unlocked)
	PVP_KillFeed:SetAlpha(1)

	PVP_Names:SetMouseEnabled(true)
	PVP_Names_Text:SetMouseEnabled(not unlocked)
	PVP_Names:SetMovable(unlocked)
	PVP_Names_Text:SetLinkEnabled(not unlocked)
	PVP_Names:SetAlpha(1)

	PVP_KOS:SetMouseEnabled(true)
	PVP_KOS_Text:SetMouseEnabled(not unlocked)
	PVP_KOS:SetMovable(unlocked)
	PVP_KOS_Text:SetLinkEnabled(not unlocked)
	PVP_KOS:SetAlpha(1)

	PVP_ForwardCamp:SetMovable(unlocked)
	PVP_ForwardCamp:SetMouseEnabled(true)
	PVP_ForwardCamp_Icon:SetMouseEnabled(true)
	PVP_ForwardCamp_IconContinuous:SetMouseEnabled(true)
	PVP_ForwardCamp_IconAyleid:SetMouseEnabled(true)
	PVP_ForwardCamp_IconBlessing:SetMouseEnabled(true)

	PVP_TargetName:SetMouseEnabled(unlocked)
	PVP_TargetName:SetMovable(unlocked)

	PVP_NewAttacker:SetMouseEnabled(unlocked)
	PVP_NewAttacker:SetMovable(unlocked)

	PVP_Medals:SetMouseEnabled(unlocked)
	PVP_Medals:SetMovable(unlocked)

	self:SetKOSSliderPosition()

	PVP_WorldTooltipBackdrop:SetEdgeTexture('esoui/art/hud/gamepad/gp_ultimateframe_edge.dds', 16,16)

	PVP_KillFeed_Backdrop:SetHidden(not unlocked)
	PVP_Names_Backdrop:SetHidden(not unlocked)
	PVP_KOS_Backdrop:SetAlpha(0.3)
	PVP_KOS_Backdrop:SetHidden(not unlocked)

	-- PVP_Main:SetHidden(not unlocked)

	PVP_Capture:SetMovable(unlocked)
	PVP_Capture:SetMouseEnabled(unlocked)


	self:Setup3DMeasurements()
	self:UpdateNearbyKeepsAndPOIs(true)
	self:SetSceneVisibility()

	-- PVP.currentCameraDistance = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)

	if not unlocked and SV.enabled and SV.showCaptureFrame then self:SetupCurrentObjective(GetPlayerLocationName()) end
end

function PVP:SetSceneVisibility()
	-- HUD_SCENE:RemoveFragment(PVP_CAMP_SCENE_FRAGMENT)
	-- HUD_UI_SCENE:RemoveFragment(PVP_CAMP_SCENE_FRAGMENT)
	-- LOOT_SCENE:RemoveFragment(PVP_CAMP_SCENE_FRAGMENT)

	if self.SV.enabled and self:IsInPVPZone() and not self.SV.unlocked then
		self:ManageFragments(PVP_COUNTER_SCENE_FRAGMENT)
		self:ManageFragments(PVP_NAMES_SCENE_FRAGMENT)
		self:ManageFragments(PVP_KILLFEED_SCENE_FRAGMENT)
		self:ManageFragments(PVP_KOS_SCENE_FRAGMENT)
		self:ManageFragments(PVP_CAMP_SCENE_FRAGMENT)
		self:ManageFragments(PVP_CAPTURE_SCENE_FRAGMENT)
		self:ManageFragments(PVP_TARGETNAME_SCENE_FRAGMENT)
		self:ManageFragments(PVP_TOOLTIP3D_FRAGMENT)
		self:ManageFragments(PVP_MEDALS_FRAGMENT)
		self:ManageFragments(PVP_ONSCREEN_FRAGMENT)
		self:ManageFragments(PVP_TUG_FRAGMENT)

		-- PVP_Main:SetHidden(not (self.SV.unlocked and self.SV.enabled))
		self:ResetMainFrame()
		-- PVP_Main:SetHidden(true)
		-- PVP_WorldTooltip:SetAlpha(0)
		PVP_WorldTooltip:SetHidden(true)
	else
		HUD_SCENE:RemoveFragment(PVP_KOS_SCENE_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_KOS_SCENE_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_KOS_SCENE_FRAGMENT)

		HUD_SCENE:RemoveFragment(PVP_COUNTER_SCENE_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_COUNTER_SCENE_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_COUNTER_SCENE_FRAGMENT)

		HUD_SCENE:RemoveFragment(PVP_KILLFEED_SCENE_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_KILLFEED_SCENE_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_KILLFEED_SCENE_FRAGMENT)

		HUD_SCENE:RemoveFragment(PVP_NAMES_SCENE_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_NAMES_SCENE_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_NAMES_SCENE_FRAGMENT)

		HUD_SCENE:RemoveFragment(PVP_CAMP_SCENE_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_CAMP_SCENE_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_CAMP_SCENE_FRAGMENT)

		HUD_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_CAPTURE_SCENE_FRAGMENT)

		HUD_SCENE:RemoveFragment(PVP_TARGETNAME_SCENE_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_TARGETNAME_SCENE_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_TARGETNAME_SCENE_FRAGMENT)

		HUD_SCENE:RemoveFragment(PVP_TOOLTIP3D_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_TOOLTIP3D_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_TOOLTIP3D_FRAGMENT)

		HUD_SCENE:RemoveFragment(PVP_MEDALS_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_MEDALS_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_MEDALS_FRAGMENT)

		HUD_SCENE:RemoveFragment(PVP_ONSCREEN_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_ONSCREEN_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_ONSCREEN_FRAGMENT)

		HUD_SCENE:RemoveFragment(PVP_TUG_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PVP_TUG_FRAGMENT)
		LOOT_SCENE:RemoveFragment(PVP_TUG_FRAGMENT)

		local hidingCondition = self.SV.unlocked and self.SV.enabled

		PVP_Main:SetHidden(not (hidingCondition and self.SV.showAttacks))
		PVP_ForwardCamp:SetHidden(not (hidingCondition and self.SV.showCampFrame and not IsActiveWorldBattleground()))
		PVP_Capture:SetHidden(not (hidingCondition and self.SV.showCaptureFrame))
		PVP_Counter:SetHidden(not (hidingCondition and self.SV.showCounterFrame))
		PVP_Names:SetHidden(not (hidingCondition and self.SV.showNamesFrame))
		PVP_KOS:SetHidden(not (hidingCondition and self.SV.showKOSFrame))
		PVP_KillFeed:SetHidden(not (hidingCondition and self.SV.showKillFeedFrame))
		PVP_TargetName:SetHidden(not (hidingCondition and self.SV.showTargetNameFrame))
		PVP_Medals:SetHidden(not (hidingCondition and self.SV.showMedalsFrame))
		PVP_OnScreen:SetHidden(not (hidingCondition and self.SV.showOnScreen))
		PVP_TUG:SetHidden(not (hidingCondition and self.SV.showTug))
		-- PVP_WorldTooltip:SetAlpha(0)
		PVP_WorldTooltip:SetHidden(true)
	end

end

function PVP:ManageFragments(fragment)
	local fragmentCondition, control, isCamp
	if fragment == PVP_COUNTER_SCENE_FRAGMENT then fragmentCondition = self.SV.showCounterFrame control=PVP_Counter
	elseif fragment == PVP_NAMES_SCENE_FRAGMENT then fragmentCondition = self.SV.showNamesFrame control=PVP_Names
	elseif fragment == PVP_KILLFEED_SCENE_FRAGMENT then fragmentCondition = self.SV.showKillFeedFrame control=PVP_KillFeed
	elseif fragment == PVP_KOS_SCENE_FRAGMENT then fragmentCondition = self.SV.showKOSFrame control=PVP_KOS
	elseif fragment == PVP_CAMP_SCENE_FRAGMENT then fragmentCondition = self.SV.showCampFrame and not IsActiveWorldBattleground() control=PVP_ForwardCamp
	elseif fragment == PVP_TARGETNAME_SCENE_FRAGMENT then fragmentCondition = self.SV.showTargetNameFrame control=PVP_TargetName
	elseif fragment == PVP_CAPTURE_SCENE_FRAGMENT then fragmentCondition = self.SV.showCaptureFrame control=PVP_Capture
	elseif fragment == PVP_TOOLTIP3D_FRAGMENT then fragmentCondition = self.SV.show3DIcons control=PVP_WorldTooltip
	elseif fragment == PVP_MEDALS_FRAGMENT then fragmentCondition = self.SV.showMedalsFrame control=PVP_Medals
	elseif fragment == PVP_ONSCREEN_FRAGMENT then fragmentCondition = self.SV.showOnScreen control=PVP_OnScreen
	elseif fragment == PVP_TUG_FRAGMENT then fragmentCondition = self.SV.showTug control=PVP_TUG
	else return
	end

	-- local toShow = (self.SV.unlocked or (fragmentCondition and self:IsInPVPZone()))

	-- if toShow then
	if fragmentCondition then
		HUD_SCENE:AddFragment(fragment)
		HUD_UI_SCENE:AddFragment(fragment)
		LOOT_SCENE:AddFragment(fragment)
	else
		HUD_SCENE:RemoveFragment(fragment)
		HUD_UI_SCENE:RemoveFragment(fragment)
		LOOT_SCENE:RemoveFragment(fragment)
	end

	local function tooltipFragmentCallback (oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWN then
			PVP_WorldTooltip:SetHidden(true)
		end
	end

	if control == PVP_WorldTooltip then
		if fragmentCondition then
			PVP_TOOLTIP3D_FRAGMENT:RegisterCallback("StateChange", tooltipFragmentCallback)
		else
			PVP_TOOLTIP3D_FRAGMENT:UnregisterCallback("StateChange", tooltipFragmentCallback)
		end
	end

	local function onScreenFragmentCallback (oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWN then
			PVP_OnScreen:SetHidden(true)
		end
	end

	if control == PVP_OnScreen then
		if fragmentCondition then
			PVP_ONSCREEN_FRAGMENT:RegisterCallback("StateChange", onScreenFragmentCallback)
		else
			PVP_ONSCREEN_FRAGMENT:UnregisterCallback("StateChange", onScreenFragmentCallback)
		end
	end

	local sceneCondition = SCENE_MANAGER:GetCurrentScene() == GAME_MENU_SCENE

	control:SetHidden(not (fragmentCondition and not sceneCondition))

	local function FrameMenuFix(oldState, newState)
		if newState == SCENE_HIDING or newState == SCENE_HIDDEN then
			control:SetHidden(not (fragmentCondition))
			PVP_Capture:SetHidden(true)
			PVP_OnScreen:SetHidden(true)
			PVP_WorldTooltip:SetHidden(true)
		end

		if newState == SCENE_HIDDEN and self.SV.show3DIcons and self.SV.enabled and not self.SV.unlocked then
			-- d('UPDATE ONACTIVATION FROM OPTIONS!')
			self:UpdateNearbyKeepsAndPOIs(true)
			GAME_MENU_SCENE:UnregisterCallback("StateChange", FrameMenuFix)
		end
	end

	if sceneCondition and self.SV.enabled and self:IsInPVPZone() then
		GAME_MENU_SCENE:RegisterCallback("StateChange", FrameMenuFix)
	end
end

function PVP.EditNoteDialogSetup(dialog, data)
	GetControl(dialog, "DisplayName"):SetText(data.playerName)
	GetControl(dialog, "NoteEdit"):SetText(data.noteString)

	local deleteControl = GetControl(dialog, "Delete")
	if data.noteString then
		deleteControl:SetHidden(false)
	else
		deleteControl:SetHidden(true)
	end
end

function PVP:RegisterCustomDialog()
	local dialogControl = GetControl("PVP_EditNoteDialog")

	ZO_Dialogs_RegisterCustomDialog("PVP_EDIT_NOTE",
		{
			customControl = dialogControl,
			setup = PVP.EditNoteDialogSetup,
			title =
			{
				text = PVP_NOTES_EDIT_NOTE,
			},
			buttons =
			{

				[1] =
				{
					control = GetControl(dialogControl, "Cancel"),
					text = SI_DIALOG_CANCEL,
					keybind = "DIALOG_SECONDARY",
				},

				[2] =
				{
					control = GetControl(dialogControl, "Delete"),
					text = SI_NOTIFICATIONS_DELETE,
					callback = function(dialog)
						local data = dialog.data
						if data.noteString then
							data.changedCallback(data.playerName, nil)
						end
					end,
				},

				[3] =
				{
					control = GetControl(dialogControl, "Save"),
					text = SI_SAVE,
					keybind = "DIALOG_PRIMARY",
					callback = function(dialog)
						local data = dialog.data
						local noteString = GetControl(dialog, "NoteEdit"):GetText()

						if (noteString ~= data.noteString) then
							data.changedCallback(data.playerName, noteString)
						end
					end,
				},
			}
		})
end

function PVP:InitNetworking()
	if PVP.SV.enableNetworking and PVP.addonEnabled then
		if not PVP.networkingEnabled then
			PVP.LMP:RegisterCallback("BeforePingAdded", PVP.OnBeforePingAdded)
			PVP.LMP:RegisterCallback("AfterPingRemoved", PVP.OnAfterPingRemoved)
			PVP.networkingEnabled = true
		end
	elseif PVP.SV.enableNetworking and not PVP.addonEnabled then
		if PVP.networkingEnabled then
			PVP.LMP:UnregisterCallback("BeforePingAdded", PVP.OnBeforePingAdded)
			PVP.LMP:UnregisterCallback("AfterPingRemoved", PVP.OnAfterPingRemoved)
			PVP.networkingEnabled = false
		end
	elseif not PVP.SV.enableNetworking and PVP.addonEnabled then
		if PVP.networkingEnabled then
			PVP.LMP:UnregisterCallback("BeforePingAdded", PVP.OnBeforePingAdded)
			PVP.LMP:UnregisterCallback("AfterPingRemoved", PVP.OnAfterPingRemoved)
			PVP.networkingEnabled = false
		end
	end
end
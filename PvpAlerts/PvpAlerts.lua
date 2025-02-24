-- // the code needs quite a bit of refactoring, which most likely will never happen:( //
---@class (partial) PvpAlerts
local PVP = PVP_Alerts_Main_Table

PVP.version = 1.01 -- // NEVER CHANGE THIS NUMBER FROM 1.01! Otherwise the whole players databse will be lost and you will cry
PVP.textVersion = "3.16.5"
PVP.name = "PvpAlerts"

local sessionTimeEpoch = GetTimeStamp()
local killFeedDuplicateTracker = ZO_RecurrenceTracker:New(2000, 0)
local cachedPlayerNameChanges = {}
local killFeedBuffer = {}
local killingBlows = {}

local LCM = LibChatMessage
local chat = LCM.Create('PvpAlerts', 'PVP')
PVP.CHAT = chat

-- // initialization of global variables for this file //

local GetFrameTimeSeconds = GetFrameTimeSeconds
local GetFrameTimeMilliseconds = GetFrameTimeMilliseconds
local GetGameTimeMilliseconds = GetGameTimeMilliseconds
--local GetGameTimeSeconds = GetGameTimeSeconds
local sort = table.sort
local insert = table.insert
local remove = table.remove
--local concat = table.concat
local upper = string.upper
--local lower = string.lower
local format = string.format

local PVP_NAME_FONT = PVP:GetGlobal('PVP_NAME_FONT')
local PVP_NUMBER_FONT = PVP:GetGlobal('PVP_NUMBER_FONT')

local PVP_ICON_MISSING = PVP:GetGlobal('PVP_ICON_MISSING')
local PVP_KILLING_BLOW = PVP:GetGlobal('PVP_KILLING_BLOW')
local PVP_AP = PVP:GetGlobal('PVP_AP')

local PVP_CONTINUOUS_ATTACK_ID_1 = PVP:GetGlobal('PVP_CONTINUOUS_ATTACK_ID_1')
local PVP_CONTINUOUS_ATTACK_ID_2 = PVP:GetGlobal('PVP_CONTINUOUS_ATTACK_ID_2')
local PVP_AYLEID_WELL_ID = PVP:GetGlobal('PVP_AYLEID_WELL_ID')
local PVP_BLESSING_OF_WAR_ID = PVP:GetGlobal('PVP_BLESSING_OF_WAR_ID')

local PVP_SET_SCALE_FROM_SV = true

local PVP_ID_RETAIN_TIME = PVP:GetGlobal('PVP_ID_RETAIN_TIME')
local PVP_ID_RETAIN_TIME_EFFECT = PVP:GetGlobal('PVP_ID_RETAIN_TIME_EFFECT')

local PVP_BATTLE_INTERVAL = 20000
local PVP_FRAME_DISPLAY_TIME = 1800


local PVP_BRIGHT_AD_COLOR = PVP:GetGlobal('PVP_BRIGHT_AD_COLOR')
local PVP_BRIGHT_EP_COLOR = PVP:GetGlobal('PVP_BRIGHT_EP_COLOR')
local PVP_BRIGHT_DC_COLOR = PVP:GetGlobal('PVP_BRIGHT_DC_COLOR')

local currentCampaignActiveEmperor, currentCampaignActiveEmperorAcc, currentCampaignActiveEmperorAlliance

local localActivePlayerCache = {}

local ccImmunityBuffs = {
	["CC Immunity"] = true,
	["Crowd Control Immunity"] = true,
	["Unstoppable"] = true,
	["Immovable"] = true,
}

local KILLING_BLOW_ACTION_RESULTS = {
	[ACTION_RESULT_KILLING_BLOW] = true,
	[ACTION_RESULT_DIED_XP] = true,
}

local DEAD_ACTION_RESULTS = {
	[ACTION_RESULT_KILLING_BLOW] = true,
	[ACTION_RESULT_TARGET_DEAD] = true,
	[ACTION_RESULT_DIED] = true,
	[ACTION_RESULT_DIED_XP] = true,
	[ACTION_RESULT_REINCARNATING] = true,
	[ACTION_RESULT_RESURRECT] = true,
	[ACTION_RESULT_CASTER_DEAD] = true,
}

local shadowReturnIds = {
	[35451] = true,
	[36290] = true,
	[36295] = true,
	[36300] = true,
}

local shadowSetupIds = {
	[38528] = true,
	[38529] = true,
	[38530] = true,
	[38531] = true,
	[88696] = true,
	[88697] = true,
	[88699] = true,
	[88700] = true,
	[88702] = true,
	[88703] = true,
	[88705] = true,
	[88706] = true,
}

function PVP:RemoveDuplicateNames() -- // a clean-up function for various arrays containing information about players nearby //
	local function ClearId(id)
		PVP.playerSpec[PVP.idToName[id]] = nil
		PVP.miscAbilities[PVP.idToName[id]] = nil
		PVP.playerAlliance[id] = nil
		PVP.idToName[id] = nil
		PVP.totalPlayers[id] = nil
	end
	if next(PVP.idToName) ~= nil then
		local foundNames = {}
		for k, v in pairs(PVP.idToName) do
			if not foundNames[v] then
				foundNames[v] = k
			else
				if PVP.totalPlayers[k] > PVP.totalPlayers[foundNames[v]] then
					ClearId(foundNames[v])
					foundNames[v] = k
				else
					ClearId(k)
				end
			end
		end
	end
end

function PVP:ProcessCachedPlayerNameChanges()
	for k, v in pairs(cachedPlayerNameChanges) do
		self:UpdatePlayerDbAccountName(k, v.newUnitAccName, v.oldUnitAccName)
		cachedPlayerNameChanges[k] = nil
	end
end

function PVP.OnUpdate() -- // main loop of the addon, is called each 250ms //
	local SV = PVP.SV
	if not SV.enabled or not PVP:IsInPVPZone() then return end
	local function sma(period)
		local t = {}
		local function sum(a, ...)
			if a then return a + sum(...) else return 0 end
		end

		local function average(n)
			if #t == period then remove(t, 1) end
			t[#t + 1] = n
			return sum(unpack(t)) / #t, zo_max(unpack(t))
		end

		return average
	end

	local start_main = GetGameTimeMilliseconds()
	if not PVP.addonPerformance then
		PVP.addonPerformance = {}
		PVP.addonPerformance.maxProcessingTime = 0
		-- PVP.addonPerformance.averageCounts = 0
		-- PVP.addonPerformance.averageSum = 0
		-- PVP.addonPerformance.maxMinute = 0
		PVP.addonPerformance.sma = sma(120)
	end

	if not PVP.playerName then PVP.playerName = GetRawUnitName('player') end

	if PVP:IsMalformedName(PVP.playerName) and PVP.bgNames then -- // band-aid attempt to work around zos glitch in bgs //
		if PVP.bgNames[PVP.playerName .. '^Mx'] then PVP.playerName = PVP.playerName .. '^Mx' end
		if PVP.bgNames[PVP.playerName .. '^Fx'] then PVP.playerName = PVP.playerName .. '^Fx' end
	end


	local currentTime = GetFrameTimeMilliseconds()
	if SV.reportSavedInfo and (not PVP.reportTimer or PVP.reportTimer == 0 or (currentTime - PVP.reportTimer) >= 300000) then -- // output of the number of stored accounts/players //
		PVP:RefreshStoredNumbers(currentTime)
	end

	if not PVP.killFeedDelay or (PVP.killFeedDelay > 0 and (currentTime - PVP.killFeedDelay) >= 10000) then -- // kill feed maintenance //
		PVP.killFeedDelay = 0
		PVP_KillFeed_Text:Clear()
		PVP_KillFeed_Ratio:SetHidden(true)
	end

	if not PVP.killFeedRatioDelay or (PVP.killFeedRatioDelay > 0 and (currentTime - PVP.killFeedRatioDelay) >= PVP_BATTLE_INTERVAL) then -- // battle report maintenance //
		if SV.showKillFeedFrame and not IsActiveWorldBattleground() then
			PVP:BattleReport()
		end
		PVP.killFeedRatioDelay = 0
	end
	local start_refresh = GetGameTimeMilliseconds()
	PVP:MainRefresh(currentTime) -- // main loop for pvpalerts.lua functions //
	local end_refresh = GetGameTimeMilliseconds()
	PVP:ProcessDistrictNamePrompt() -- // a tiny feature to check if you mousever a district ladder, while in an ic lobby //
	local start3d = GetGameTimeMilliseconds()
	PVP:UpdateNearbyKeepsAndPOIs() -- // 3d icons main loop //
	local end_all = GetGameTimeMilliseconds()
	if SV.showPerformance then
		chat:Print('----------------------------')
		chat:Printf('Main loop time = %dms', start3d - start_main)
		chat:Printf('Main refresh = %dms', end_refresh - start_refresh)
		chat:Printf('Main Camp = %dms', PVP.endCamp - PVP.endN)
		chat:Printf('Main Counter = %dms', PVP.endCounter - PVP.endCamp)
		chat:Printf('Main Counter Func = %dms', PVP.afterC - PVP.beforeC)
		chat:Printf('Main KOS = %dms', PVP.endKos - PVP.endCounter)
		chat:Printf('3d loop time = %dms', end_all - start3d)

		chat:Printf('New Marker time = %dms', PVP.afterMarker - PVP.beforeMarker)
		if PVP.afterPoi and PVP.beforePoi then
			chat:Printf('New Poi time = %dms', PVP.afterPoi - PVP.beforePoi)
		end
		local c = 0
		for k, v in pairs(PVP.currentNearbyKeepIds) do
			c = c + 1
		end
		chat:Printf('#currentNearbyKeepIds = %dms', c)
		c = 0
		for k, v in pairs(PVP.currentNearbyPOIIds) do
			c = c + 1
		end
		chat:Printf('#currentNearbyPOIIds = %dms', c)
		c = 0
		for k, v in pairs(PVP.currentObjectivesIds) do
			c = c + 1
		end
		chat:Printf('#currentObjectivesIds = %dms', c)
		c = 0
		if PVP.currentMapPings then
			for k, v in pairs(PVP.currentMapPings) do
				c = c + 1
			end
			chat:Printf('#currentMapPings = %dms', c)
		end

		chat:Printf('Cycles = %d', PVP.cc)
		-- chat:Printf('M21 = '..tostring(PVP.m2 - PVP.m1))
		-- chat:Printf('M32 = '..tostring(PVP.m3 - PVP.m2))
		-- chat:Printf('M43 = '..tostring(PVP.m4 - PVP.m3))
		-- chat:Printf('M54 = '..tostring(PVP.m5 - PVP.m4))
		-- chat:Printf('M65 = '..tostring(PVP.m6 - PVP.m5))
		-- chat:Printf('M76 = '..tostring(PVP.m7 - PVP.m6))
		-- chat:Printf('M87 = '..tostring(PVP.m8 - PVP.m7))
		-- chat:Printf('M81 = '..tostring(PVP.m8 - PVP.m1))

		-- chat:Printf('PVP.afterKeeps3d = '..tostring(PVP.afterKeeps3d - PVP.afterInit3d))
		-- chat:Printf('PVP.afterPoi3d = '..tostring(PVP.afterPoi3d - PVP.afterKeeps3d))
		-- chat:Printf('PVP.afterKeepsProc3d = '..tostring(PVP.afterKeepsProc3d - PVP.afterPoi3d))
		-- chat:Printf('PVP.afterPoiProc3d = '..tostring(PVP.afterPoiProc3d - PVP.afterKeepsProc3d))
		if (end_all - start_main) > PVP.addonPerformance.maxProcessingTime then PVP.addonPerformance.maxProcessingTime = (end_all - start_main) end
		-- if (end_all - start_main) > PVP.addonPerformance.maxMinute then PVP.addonPerformance.maxMinute = (end_all - start_main) end
		chat:Printf('Max processing time = %dms', PVP.addonPerformance.maxProcessingTime)
		-- PVP.addonPerformance.averageCounts = PVP.addonPerformance.averageCounts + 1
		-- PVP.addonPerformance.averageSum = PVP.addonPerformance.averageSum + (end_all - start_main)

		-- if PVP.addonPerformance.averageCounts >= 240 then
		-- chat:Printf('Average in last minute processing time = '..tostring(zo_ceil(PVP.addonPerformance.averageSum/PVP.addonPerformance.averageCounts)))
		-- chat:Printf('Max in last minute processing time = '..tostring(PVP.addonPerformance.maxMinute))
		local avg, maxMin = PVP.addonPerformance.sma(end_all - start_main)
		chat:Printf('Last 30 sec average processing time = %dms', zo_ceil(avg))
		chat:Printf('Last 30 sec max processing time = %dms', maxMin)
		-- PVP.addonPerformance.averageCounts = 0
		-- PVP.addonPerformance.maxMinute = 0
		-- end

		if PVP.controls3DPool then
			chat:Printf('3d Objects Count = ', PVP.controls3DPool:GetActiveObjectCount())
			-- if PVP.currentCameraInfo and PVP.currentCameraInfo.performance then
			-- chat:Printf('Measuring time = '..tostring(PVP.currentCameraInfo.performance))
			-- end
		end
		chat:Printf('Performance loss = %.3f%', (end_all - start_main) / 2.5)
		chat:Print('----------------------------')
	end

	if not IsUnitInCombat('player') then PVP:ProcessCachedPlayerNameChanges() end
	-- PVP:TestThisScale()
end

function PVP:UpdateCampaignEmperor(eventCode, campaignId)
	if not campaignId == PVP.currentCampaignId then return end
	local emperorAlliance, emperorRawName, emperorAccName = GetCampaignEmperorInfo(campaignId)
	emperorRawName = tostring(emperorRawName)
	currentCampaignActiveEmperor = self:GetRootNames(emperorRawName)
	currentCampaignActiveEmperorAcc = emperorAccName
	currentCampaignActiveEmperorAlliance = emperorAlliance
end

function PVP:UpdateActiveArtifactInfo(eventCode, artifactName, keepId, playerName, playerAlliance, controlEvent, controlState, campaignId, displayName)
	local currentCampaignId = PVP.currentCampaignId or GetCurrentCampaignId()
	if currentCampaignId ~= campaignId then return end
	if not PVP.activeScrolls then PVP.activeScrolls = {} end
	if controlState ~= OBJECTIVE_CONTROL_STATE_FLAG_AT_BASE and controlState ~= OBJECTIVE_CONTROL_STATE_FLAG_AT_ENEMY_BASE then
		local scrollInfo = {}
		if controlState == OBJECTIVE_CONTROL_STATE_FLAG_HELD then
			scrollInfo = {
				playerName = PVP:GetValidName(playerName),
				playerAlliance = playerAlliance,
				controlEvent = controlEvent,
				controlState = controlState,
			}
		else
			scrollInfo = {
				playerName = "",
				playerAlliance = 0,
				controlEvent = controlEvent,
				controlState = controlState,
			}
		end
		PVP.activeScrolls[artifactName] = scrollInfo
	else
		PVP.activeScrolls[artifactName] = nil
	end
end

function PVP:UpdateActiveDaedricArtifactInfo(eventCode, artifactKeepId, artifactObjectiveId, battlegroundContext,
	controlEvent, controlState, controllingAlliance, lastControllingAlliance,
	holderRawCharacterName, holderDisplayName, lastHolderRawCharacterName,
	lastHolderDisplayName, pinType, artifactId)
	--d("Found artifact:" .. (artifactObjectiveId or ""))
	if controlState ~= OBJECTIVE_CONTROL_STATE_UNKNOWN then
		PVP.activeDaedricArtifact = artifactObjectiveId
	else
		PVP.activeDaedricArtifact = nil
	end
end

local lastcount, lastcountAcc
function PVP:RefreshStoredNumbers(currentTime) -- // output of the number of stored accounts/players //
	self.reportTimer = currentTime

	local count = 0
	local countAcc = 0
	local accountsDB = {}
	local playersDB = self.SV.playersDB
	for k, v in pairs(playersDB) do
		if not accountsDB[v.unitAccName] then
			accountsDB[v.unitAccName] = true
			countAcc = countAcc + 1
		end
		count = count + 1
	end
	if count ~= lastcount or countAcc ~= lastcountAcc then
		local diff, diffAcc
		if lastcount == nil then
			diff = 0
			diffAcc = 0
		else
			diff = count - lastcount
			diffAcc = countAcc - lastcountAcc
		end
		lastcount = count
		lastcountAcc = countAcc
		chat:Print('************************')
		chat:Printf('Stored players: %d (%d)', count, diff)
		chat:Printf('Stored accounts: %d (%d)', countAcc, diffAcc)
		chat:Print('************************')
	end
end

function PVP_test_SV()
	local function Getmean(t)
		local sum = 0
		local count = 0

		for k, v in pairs(t) do
			if type(v) == 'number' then
				sum = sum + v
				count = count + 1
			end
		end

		return (sum / count)
	end

	local function GetMedian(t)
		local temp = {}

		-- deep copy table so that when we sort it, the original is unchanged
		-- also weed out any non numbers
		for k, v in pairs(t) do
			if type(v) == 'number' then
				insert(temp, v)
			end
		end

		sort(temp)

		-- If we have an even number of table elements or odd.
		if zo_mod(#temp, 2) == 0 then
			-- return mean value of middle two elements
			return (temp[#temp / 2] + temp[(#temp / 2) + 1]) / 2
		else
			-- return middle element
			return temp[zo_ceil(#temp / 2)]
		end
	end


	local function GetStd(t)
		local m
		local vm
		local sum = 0
		local count = 0
		local result

		m = Getmean(t)

		for k, v in pairs(t) do
			if type(v) == 'number' then
				vm = v - m
				sum = sum + (vm * vm)
				count = count + 1
			end
		end

		result = zo_sqrt(sum / (count - 1))

		return result
	end



	local playerCountOriginal = 0
	local accountCountOriginal = 0
	local accountCountWithCP = 0
	local playerCountWithCP = 0
	local accountsDB = {}
	local playersDB = PVP.SV.playersDB
	local playersCP = PVP.SV.CP

	for k, v in pairs(playersDB) do
		if not accountsDB[v.unitAccName] then
			accountCountOriginal = accountCountOriginal + 1
			if playersCP[v.unitAccName] then
				accountsDB[v.unitAccName] = {}
				accountsDB[v.unitAccName].CP = playersCP[v.unitAccName]
				accountsDB[v.unitAccName].players = {}
				accountsDB[v.unitAccName].players.k = v

				accountCountWithCP = accountCountWithCP + 1
				playerCountWithCP = playerCountWithCP + 1
			end
		else
			accountsDB[v.unitAccName].players[k] = v
			playerCountWithCP = playerCountWithCP + 1
		end
		playerCountOriginal = playerCountOriginal + 1
	end

	d('***********')
	d('Stored players: ' .. tostring(playerCountOriginal))
	d('Stored accounts: ' .. tostring(accountCountOriginal))
	d('CP players: ' .. tostring(playerCountWithCP))
	d('CP accounts: ' .. tostring(accountCountWithCP))


	local averageCP = 0
	local medianCP = GetMedian(playersCP)
	local stdCP = GetStd(playersCP)
	local aboveCPcap = 0
	local totalWithSpec = 0
	local totalMag = 0
	local totalStam = 0

	local race = {}
	local class = {}
	local classrace = {}
	local totalAD = 0
	local totalDC = 0
	local totalEP = 0

	for k, v in pairs(accountsDB) do
		averageCP = averageCP + v.CP
		if v.CP >= 720 then
			aboveCPcap = aboveCPcap + 1
		end
		for i, j in pairs(v.players) do
			if j.unitSpec then
				totalWithSpec = totalWithSpec + 1
				if j.unitSpec == 'stam' then
					totalStam = totalStam + 1
				elseif j.unitSpec == 'mag' then
					totalMag = totalMag + 1
				end
			end

			-- if v.CP >= 720 and j.unitSpec and j.unitSpec == 'mag' then
			if v.CP >= 720 and j.unitSpec then
				if not race[j.unitRace] then
					race[j.unitRace] = 0
				end

				race[j.unitRace] = race[j.unitRace] + 1

				if not class[j.unitClass] then
					class[j.unitClass] = 0
				end

				class[j.unitClass] = class[j.unitClass] + 1

				if not classrace[j.unitClass] then classrace[j.unitClass] = {} end
				if not classrace[j.unitClass][j.unitRace] then classrace[j.unitClass][j.unitRace] = 0 end
				classrace[j.unitClass][j.unitRace] = classrace[j.unitClass][j.unitRace] + 1


				if j.unitAlliance == 1 then
					totalAD = totalAD + 1
				elseif j.unitAlliance == 2 then
					totalEP = totalEP + 1
				elseif j.unitAlliance == 3 then
					totalDC = totalDC + 1
				end
			end
		end
	end

	local totalOther = totalWithSpec - totalMag - totalStam

	averageCP = averageCP / accountCountWithCP
	d('CP average: ' .. tostring(averageCP))
	d('CP median: ' .. tostring(medianCP))
	d('CP std: ' .. tostring(stdCP))
	d('Above CP cap: ' .. tostring(aboveCPcap))
	d('Below CP cap: ' .. tostring(accountCountWithCP - aboveCPcap))
	d('Percent above CP cap: ' .. tostring(100 * aboveCPcap / accountCountWithCP))
	d('Percent below CP cap: ' .. tostring(100 * (accountCountWithCP - aboveCPcap) / accountCountWithCP))
	d('Total with Spec: ' .. tostring(totalWithSpec))
	d('Total mag: ' .. tostring(totalMag))
	d('Total stam: ' .. tostring(totalStam))
	d('Total other: ' .. tostring(totalOther))
	d('Percent mag: ' .. tostring(100 * totalMag / totalWithSpec))
	d('Percent stam: ' .. tostring(100 * totalStam / totalWithSpec))
	d('Percent other: ' .. tostring(100 * totalOther / totalWithSpec))


	d('Nightblades: ' .. tostring(class[3]))
	d('Templars: ' .. tostring(class[6]))
	d('Wardens: ' .. tostring(class[4]))
	d('Sorcs: ' .. tostring(class[2]))
	d('DKs: ' .. tostring(class[1]))
	d('Necros: ' .. tostring(class[5]))
	d('Arcanists: ' .. tostring(class[117]))
	d('TotalAD: ' .. tostring(totalAD))
	d('TotalDC: ' .. tostring(totalDC))
	d('TotalEP: ' .. tostring(totalEP))

	for k, v in pairs(race) do
		d(GetRaceName(0, k) .. 's: ' .. tostring(v))
	end

	for iClass, v in pairs(classrace) do
		for iRace, numb in pairs(v) do
			d(GetClassName(0, iClass) .. '/' .. GetRaceName(0, iRace) .. ': ' .. tostring(numb))
		end
	end

	d('************')
end

function PVP:CountTotal(currentTime)
	local totalPlayers = self.totalPlayers
	local playerSpec = self.playerSpec
	local miscAbilities = self.miscAbilities
	local playerAlliance = self.playerAlliance
	local idToName = self.idToName
	local playerNames = self.playerNames
	local namesToDisplay = self.namesToDisplay
	local currentlyDead = self.currentlyDead

	for k, v in pairs(totalPlayers) do
		if (currentTime - v) > PVP_ID_RETAIN_TIME_EFFECT then
			totalPlayers[k] = nil
			playerSpec[idToName[k]] = nil
			miscAbilities[idToName[k]] = nil
			playerAlliance[k] = nil
			idToName[k] = nil
		end
	end

	for k, v in pairs(playerNames) do
		if (currentTime - v) >= PVP_ID_RETAIN_TIME then
			playerNames[k] = nil
		end
	end

	local wasRemoved = false
	for i = #namesToDisplay, 1, -1 do
		if (currentTime - namesToDisplay[i].currentTime) >= PVP_ID_RETAIN_TIME then
			remove(namesToDisplay, i)
			wasRemoved = true
		end
	end

	if wasRemoved then
		self:PopulateReticleOverNamesBuffer(nil, currentTime)
	end

	local count = 0
	for _, v in ipairs(namesToDisplay) do
		if not v.isDead and not v.isResurrect then
			count = count + 1
		end
	end

	for k, v in pairs(currentlyDead) do
		currentlyDead[k] = nil
		currentlyDead[k] = nil
		if idToName[k] then
			playerSpec[idToName[k]] = nil
			miscAbilities[idToName[k]] = nil
		end
		playerAlliance[k] = nil
		idToName[k] = nil
		-- if (currentTime-v.currentTime)>PVP_ID_RETAIN_TIME then self.currentlyDead[k]=nil end
	end

	return count
end

function PVP:Clean_PlayerDB()
	local playersDB = self.SV.playersDB
	local KOSList = self.SV.KOSList
	local coolList = self.SV.coolList
	local playersCP = self.SV.CP
	local kosListNames = {}

	for k, v in ipairs(KOSList) do
		kosListNames[v.unitName] = true
		if playersDB[v.unitName] then
			local dbUnitAccName = playersDB[v.unitName].unitAccName
			if dbUnitAccName and dbUnitAccName ~= v.unitAccName then
				KOSList[k].unitAccName = dbUnitAccName
			end
		end
	end

	for k, v in pairs(coolList) do
		if playersDB[k] then
			local dbUnitAccName = playersDB[k].unitAccName
			if dbUnitAccName and dbUnitAccName ~= v then
				coolList[k] = dbUnitAccName
			end
		end
	end

	local unitAccNameCP = {}
	for k, v in pairs(playersDB) do
		if v.unitAvARank == nil and kosListNames[k] == nil and coolList[k] == nil then
			playersDB[k] = nil
		end

		if playersDB[k] ~= nil and v.lastSeen == nil then
			playersDB[k].lastSeen = sessionTimeEpoch
		end

		if playersDB[k] ~= nil and (v.lastSeen <= (sessionTimeEpoch - 31550000)) and kosListNames[k] == nil and coolList[k] == nil then
			playersDB[k] = nil
		elseif (playersDB[k] ~= nil) and playersCP[v.unitAccName] then
			unitAccNameCP[v.unitAccName] = playersCP[v.unitAccName]
		end
	end

	self.SV.CP = unitAccNameCP
end

function PVP:ProcessNpcs(currentTime)
	for k, v in pairs(self.npcExclude) do
		if (currentTime - v) > PVP_ID_RETAIN_TIME_EFFECT then self.npcExclude[k] = nil end
	end
end

function PVP:MainRefresh(currentTime)
	local SV = self.SV
	self.startR = GetGameTimeMilliseconds()
	self:RemoveDuplicateNames()
	self.endD = GetGameTimeMilliseconds()
	local totalCount = self:CountTotal(currentTime)
	self.endC = GetGameTimeMilliseconds()
	self:ProcessNpcs(currentTime)
	self.endN = GetGameTimeMilliseconds()
	if self:ShouldShowCampFrame() then self:ManageCampFrame() end
	self.endCamp = GetGameTimeMilliseconds()
	if self.SV.showCounterFrame or self.SV.showTug then
		self.beforeC = GetGameTimeMilliseconds()
		local numberAD, numberDC, numberEP, tableAD, tableDC, tableEP = self:GetAllianceCountPlayers()
		localActivePlayerCache = { numberAD, numberDC, numberEP, tableAD, tableDC, tableEP }
		self.afterC = GetGameTimeMilliseconds()
		if SV.showCounterFrame then
			local containerControl = PVP_Counter:GetNamedChild('_CountContainer')
			local labelControl = PVP_Counter:GetNamedChild('_Label')
			local bgControl = PVP_Counter:GetNamedChild('_Backdrop')
			local adControl = containerControl:GetNamedChild('_CountAD')
			local dcControl = containerControl:GetNamedChild('_CountDC')
			local epControl = containerControl:GetNamedChild('_CountEP')

			adControl:SetText(tostring(numberAD))
			dcControl:SetText(tostring(numberDC))
			epControl:SetText(tostring(numberEP))

			local targetWidth = containerControl:GetWidth()
			local labelWidth = labelControl:GetWidth()
			bgControl:SetWidth(zo_max(targetWidth, labelWidth) * 1.2)

			if numberAD > 0 then
				self.SetToolTip(adControl, nil, true, unpack(tableAD))
			else
				self.ReleaseToolTip(adControl, self.detailedTooltipCalc == adControl)
			end
			if numberDC > 0 then
				self.SetToolTip(dcControl, nil, true, unpack(tableDC))
			else
				self.ReleaseToolTip(dcControl, self.detailedTooltipCalc == dcControl)
			end
			if numberEP > 0 then
				self.SetToolTip(epControl, nil, true, unpack(tableEP))
			else
				self.ReleaseToolTip(epControl, self.detailedTooltipCalc == epControl)
			end
		end
		if SV.showTug then
			local tug = PVP_TUG
			local tugADcount = PVP_TUG_Frame_ADbar
			local tugADbar = PVP_TUG_Frame_ADbar_BG
			local tugDCcount = PVP_TUG_Frame_DCbar
			local tugDCbar = PVP_TUG_Frame_DCbar_BG
			local tugEPcount = PVP_TUG_Frame_EPbar
			local tugEPbar = PVP_TUG_Frame_EPbar_BG

			local totalNumber = numberAD + numberDC + numberEP
			tugADcount:SetText(numberAD)
			tugDCcount:SetText(numberDC)
			tugEPcount:SetText(numberEP)
			tugADcount:SetHidden(numberAD == 0)
			tugDCcount:SetHidden(numberDC == 0)
			tugEPcount:SetHidden(numberEP == 0)


			-- tug:SetHidden(totalNumber == 0)
			local lowestWidth = 14
			local tugwidth = tug:GetWidth()
			local adwidth = tugwidth * numberAD / totalNumber
			local dcwidth = tugwidth * numberDC / totalNumber
			local epwidth = tugwidth * numberEP / totalNumber
			local widthmargin = 0

			local adlarge, dclarge, eplarge = true, true, true

			if (numberAD > 0) and (adwidth < lowestWidth) then
				adwidth = lowestWidth
				widthmargin = widthmargin + lowestWidth
				tugADcount:SetWidth(adwidth)
				tugADbar:SetWidth(adwidth)
				adlarge = false
			end
			if (numberDC > 0) and (dcwidth < lowestWidth) then
				dcwidth = lowestWidth
				widthmargin = widthmargin + lowestWidth
				tugDCcount:SetWidth(dcwidth)
				tugDCbar:SetWidth(dcwidth)
				dclarge = false
			end
			if (numberEP > 0) and (epwidth < lowestWidth) then
				epwidth = lowestWidth
				widthmargin = widthmargin + lowestWidth
				tugEPcount:SetWidth(epwidth)
				tugEPbar:SetWidth(epwidth)
				eplarge = false
			end

			local reducedTotal = totalNumber

			if adlarge then
				if not dclarge then
					if not eplarge then
						tugADcount:SetWidth(tugwidth - widthmargin)
						tugADbar:SetWidth(tugwidth - widthmargin)
					else
						tugADcount:SetWidth((tugwidth - widthmargin) * numberAD / (numberAD + numberEP))
						tugADbar:SetWidth((tugwidth - widthmargin) * numberAD / (numberAD + numberEP))
						tugEPcount:SetWidth((tugwidth - widthmargin) * numberEP / (numberAD + numberEP))
						tugEPbar:SetWidth((tugwidth - widthmargin) * numberEP / (numberAD + numberEP))
					end
				else
					if not eplarge then
						tugADcount:SetWidth((tugwidth - widthmargin) * numberAD / (numberAD + numberDC))
						tugADbar:SetWidth((tugwidth - widthmargin) * numberAD / (numberAD + numberDC))
						tugDCcount:SetWidth((tugwidth - widthmargin) * numberDC / (numberAD + numberDC))
						tugDCbar:SetWidth((tugwidth - widthmargin) * numberDC / (numberAD + numberDC))
					else
						tugADcount:SetWidth(tugwidth * numberAD / totalNumber)
						tugADbar:SetWidth(tugwidth * numberAD / totalNumber)
						tugDCcount:SetWidth(tugwidth * numberDC / totalNumber)
						tugDCbar:SetWidth(tugwidth * numberDC / totalNumber)
						tugEPcount:SetWidth(tugwidth * numberEP / totalNumber)
						tugEPbar:SetWidth(tugwidth * numberEP / totalNumber)
					end
				end
			else
				if not dclarge then
					if not eplarge then
					else
						tugEPcount:SetWidth(tugwidth - widthmargin)
						tugEPbar:SetWidth(tugwidth - widthmargin)
					end
				else
					if not eplarge then
						tugDCcount:SetWidth(tugwidth - widthmargin)
						tugDCbar:SetWidth(tugwidth - widthmargin)
					else
						tugDCcount:SetWidth((tugwidth - widthmargin) * numberDC / (numberDC + numberEP))
						tugDCbar:SetWidth((tugwidth - widthmargin) * numberDC / (numberDC + numberEP))
						tugEPcount:SetWidth((tugwidth - widthmargin) * numberEP / (numberDC + numberEP))
						tugEPbar:SetWidth((tugwidth - widthmargin) * numberEP / (numberDC + numberEP))
					end
				end
			end


			if (numberAD > 0) and (numberDC > 0) then
				tugADcount:ClearAnchors()
				tugADcount:SetAnchor(LEFT, PVP_TUG_Frame, LEFT, 3, -6)
				tugDCcount:ClearAnchors()
				tugDCcount:SetAnchor(LEFT, tugADcount, RIGHT, 0, 0)
				tugEPcount:ClearAnchors()
				tugEPcount:SetAnchor(LEFT, tugDCcount, RIGHT, 0, 0)
			elseif (numberAD == 0) then
				if (numberDC > 0) then
					tugDCcount:ClearAnchors()
					tugDCcount:SetAnchor(LEFT, PVP_TUG_Frame, LEFT, 3, -6)
					tugEPcount:ClearAnchors()
					tugEPcount:SetAnchor(LEFT, tugDCcount, RIGHT, 0, 0)
				else
					tugEPcount:ClearAnchors()
					tugEPcount:SetAnchor(LEFT, PVP_TUG_Frame, LEFT, 3, -6)
				end
			else
				tugADcount:ClearAnchors()
				tugADcount:SetAnchor(LEFT, PVP_TUG_Frame, LEFT, 3, -6)
				tugEPcount:ClearAnchors()
				tugEPcount:SetAnchor(LEFT, tugADcount, RIGHT, 0, 0)
			end
		end
	end

	self.endCounter = GetGameTimeMilliseconds()
	self.Timer = currentTime

	if SV.showKOSFrame and (SCENE_MANAGER:GetCurrentScene() == HUD_SCENE or SCENE_MANAGER:GetCurrentScene() == LOOT_SCENE) then
		self:RefreshLocalPlayers()
	end
	self.endKos = GetGameTimeMilliseconds()
end

function PVP_ClearTooltip(control)
	PVP_Alerts_Main_Table.detailedTooltipCalc = false
	ClearTooltip(PVP_Tooltip)
	control:SetHandler("OnUpdate", nil)
	control.lastTooltipUpdate = nil
end

local function FillCurrentTooltip(control)
	if not PVP.SV.enabled or not PVP.SV.showCounterFrame or not PVP:IsInPVPZone() then return end

	local numberAD, numberDC, numberEP, tableAD, tableDC, tableEP = unpack(localActivePlayerCache)

	local currentTable, currentNumber

	if control == PVP_Counter_CountContainer_CountAD then
		currentTable = tableAD
		currentNumber = numberAD
	elseif control == PVP_Counter_CountContainer_CountDC then
		currentTable = tableDC
		currentNumber = numberDC
	elseif control == PVP_Counter_CountContainer_CountEP then
		currentTable = tableEP
		currentNumber = numberEP
	else
		return
	end

	ClearTooltip(PVP_Tooltip)
	local side = TOP
	local _, centerY = PVP_Counter:GetCenter()

	if centerY < (GuiRoot:GetHeight() / 2) then side = BOTTOM end

	if currentNumber > 0 then
		PVP.Tooltips_ShowTextTooltip(control, side, nil, true,
			unpack(currentTable))
	else
		PVP_ClearTooltip(control)
	end
end

local function HandleTooltipFilling(control)
	local tooltipTimeDelay = GetFrameTimeMilliseconds()
	control:SetHandler("OnUpdate", function()
		local currentTime = GetFrameTimeMilliseconds()
		if (currentTime - tooltipTimeDelay) >= 50 then
			tooltipTimeDelay = currentTime
			FillCurrentTooltip(control)
		end
	end)
end

function PVP_FillAllianceTooltip(control)
	if not PVP_Alerts_Main_Table.detailedTooltipCalc then
		PVP_Alerts_Main_Table.detailedTooltipCalc = control
		HandleTooltipFilling(control)
	end
end

local function TooltipOnUpdate(control)
	local currentTime = GetFrameTimeMilliseconds()
	if control.timeLeft and (currentTime - control.lastTooltipUpdate) >= 50 then
		InitializeTooltip(PVP_Tooltip)
		local args = control.timeLeft
		PVP_Tooltip:AddLine(args[1], "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		PVP_Tooltip:AddLine(args[2], "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		control.lastTooltipUpdate = currentTime
	end
end

function PVP.SetToolTip(control, maxNameWidth, isCounter, ...)
	local args = { ... }
	control:SetHandler("OnMouseEnter", function(self)
		local side = TOP
		local relativeControl = isCounter and PVP_Counter or PVP_ForwardCamp
		local _, centerY = relativeControl:GetCenter()

		if centerY < (GuiRoot:GetHeight() / 2) then side = BOTTOM end

		PVP.Tooltips_ShowTextTooltip(self, side, maxNameWidth, isCounter, unpack(args))
		if not isCounter then
			control.lastTooltipUpdate = GetFrameTimeMilliseconds()
			control:SetHandler("OnUpdate", function() TooltipOnUpdate(control) end)
		else
			PVP.detailedTooltipCalc = control
			HandleTooltipFilling(control)
		end
	end)
	control:SetHandler("OnMouseExit", function(self)
		PVP.detailedTooltipCalc = false
		ClearTooltip(PVP_Tooltip)
		control:SetHandler("OnUpdate", nil)
		control.lastTooltipUpdate = nil
	end)
end

function PVP.ReleaseToolTip(control, isCurrentTooltip)
	control:SetHandler("OnMouseEnter", nil)
	control:SetHandler("OnMouseExit", nil)
	if not isCurrentTooltip then
		control:SetHandler("OnUpdate", nil)
	end
end

function PVP.Tooltips_ShowTextTooltip(control, side, maxNameWidth, isCounter, ...)
	local OFFSET_DISTANCE = 5
	local OFFSETS_X =
	{
		[TOP] = 0,
		[BOTTOM] = 0,
		[LEFT] = -OFFSET_DISTANCE,
		[RIGHT] = OFFSET_DISTANCE,
	}
	local OFFSETS_Y =
	{
		[TOP] = -OFFSET_DISTANCE,
		[BOTTOM] = OFFSET_DISTANCE,
		[LEFT] = 0,
		[RIGHT] = 0,
	}
	local SIDE_TO_TOOLTIP_SIDE =
	{
		[TOP] = BOTTOM,
		[BOTTOM] = TOP,
		[LEFT] = RIGHT,
		[RIGHT] = LEFT,
	}
	if side == nil then
		InitializeTooltip(PVP_Tooltip)
		ZO_Tooltips_SetupDynamicTooltipAnchors(PVP_Tooltip, control)
	else
		InitializeTooltip(PVP_Tooltip, control, SIDE_TO_TOOLTIP_SIDE[side], OFFSETS_X[side], OFFSETS_Y[side])
	end
	PVP_Tooltip:SetDimensionConstraints(0, 0, maxNameWidth, 0)

	PVP_Tooltip:SetFont("ZoFontWinH5")
	for i = 1, select("#", ...) do
		local line = select(i, ...)
		if isCounter then
			PVP_Tooltip:AddLine(line, "", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
		else
			PVP_Tooltip:AddLine(line, "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
	end
end

function PVP:OnDeactivated(eventId)
	for id, _ in pairs(self.totalPlayers) do
		self.playerSpec[self.idToName[id]] = nil
		self.miscAbilities[self.idToName[id]] = nil
		self.playerAlliance[id] = nil
		self.idToName[id] = nil
		self.totalPlayers[id] = nil
	end
end

function PVP:OnZoneChange(_, zoneName, newZone)
	-- local function ClearId(id)
	-- 	PVP.playerSpec[PVP.idToName[id]]=nil
	-- 	PVP.miscAbilities[PVP.idToName[id]]=nil
	-- 	PVP.playerAlliance[id]=nil
	-- 	PVP.idToName[id]=nil
	-- 	PVP.totalPlayers[id]=nil
	-- end
	-- for k,v in pairs (self.totalPlayers) do
	-- 	ClearId(k)
	-- end

	local zoneText



	zoneText = zoneName == "" and GetPlayerLocationName() or zoneName

	if not self.SV.unlocked and self.SV.showCaptureFrame then self:SetupCurrentObjective(zoneText) end

	self:UpdateNearbyKeepsAndPOIs(nil, true)
	local currentCampaignId = self.currentCampaignId
	if currentCampaignId ~= 0 then
		self:UpdateCampaignEmperor(nil, currentCampaignId)
	end
end

function PVP:OnOwnerOrUnderAttackChanged(zoneText, keepIdToUpdate, updateType)
	if self.SV.unlocked or not self.SV.showCaptureFrame then return end
	local keepId, foundObjectives = self:FindAVAIds(zoneText)
	if keepId and ((self.SV.showNeighbourCaptureFrame and keepId[keepIdToUpdate]) or (not self.SV.showNeighbourCaptureFrame and keepId ~= 0 and keepId == keepIdToUpdate)) then
		self:SetupCurrentObjective(nil, keepId, foundObjectives, keepIdToUpdate, updateType)
	end
end

function PVP:OnControlState(eventCode, keepId, objectiveId, battlegroundContext, objectiveName, objectiveType,
							objectiveControlEvent, objectiveControlState, objectiveParam1, objectiveParam2)
	if self.SV.unlocked or not self.SV.showCaptureFrame or not self:IsValidBattlegroundContext(battlegroundContext) or not keepId or keepId == 0 then return end

	local zoneName = GetPlayerLocationName()
	if not zoneName or zoneName == "" then return end

	local allianceIdToName = {
		[0] = 'None',
		[1] = 'AD',
		[2] = 'EP',
		[3] = 'DC',
	}

	local keepName = GetKeepName(keepId)

	local foundInArray
	if self.SV.showNeighbourCaptureFrame and self.currentKeepIdArray then
		for k, v in pairs(PVP.currentKeepIdArray) do
			if k == keepId then
				foundInArray = true
				break
			end
		end
	end


	if foundInArray or (zoneName == keepName) then
		local isCurrent = zoneName == keepName
		local foundObjectives = {
			isCaptureStatus = false,
			isCurrent = isCurrent,
			keepId = keepId,
			objectiveName = objectiveName,
			objectiveId = objectiveId,
			objectiveState = objectiveControlState,
			allianceParam1 = objectiveParam1,
			allianceParam2 = objectiveParam2,
			objectiveEvent = objectiveControlEvent
		}
		self:UpdateCaptureMeter(keepId, foundObjectives, "control")
	end
end

function PVP:OnCaptureStatus(eventCode, keepId, objectiveId, battlegroundContext, capturePoolValue, capturePoolMax,
							capturingPlayers, contestingPlayers, owningAlliance)
	if self.SV.unlocked or not self.SV.showCaptureFrame or not self:IsValidBattlegroundContext(battlegroundContext) or not keepId or keepId == 0 then return end
	local zoneName = GetPlayerLocationName()
	if not zoneName or zoneName == "" then return end


	local objectiveName = GetObjectiveInfo(keepId, objectiveId, battlegroundContext)

	local foundObjectives = {
		isCaptureStatus = GetFrameTimeMilliseconds(),
		isCurrent = true,
		keepId = keepId,
		objectiveName = objectiveName,
		objectiveId = objectiveId,
		allianceParam1 = owningAlliance,
		capturePoolValue = capturePoolValue,
		capturingPlayers = capturingPlayers,
		contestingPlayers = contestingPlayers
	}

	self:UpdateCaptureMeter(keepId, foundObjectives, "capture")
end

function PVP:IsCurrentlyDead(unitName)
	if not unitName or unitName == "" then return false end
	for k, v in pairs(self.currentlyDead) do
		if v.playerName == unitName then return true end
	end
	return false
end

function PVP:OnEffect(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName,
					 buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
	if not self:IsInPVPZone() then return end
	if unitName == self.playerName then return end
	if IsActiveWorldBattleground() then
		self.bgNames = self.bgNames or {}
		if unitName and unitName ~= '' and not self.bgNames[unitName] then self.bgNames[unitName] = 0 end
	end

	-- d(self.currentlyDead)

	if unitName == "" or self.currentlyDead[unitId] or self:IsCurrentlyDead(unitName) then return end

	local currentTime = GetFrameTimeMilliseconds()

	if self.npcExclude[unitId] then
		self.npcExclude[unitId] = currentTime
		return
	end

	local totalPlayers = self.totalPlayers
	local idToName = self.idToName
	if totalPlayers[unitId] and unitName ~= "" then
		if self:CheckName(unitName) then
			idToName[unitId] = unitName
			totalPlayers[unitId] = currentTime
			local playerDbRecord = self.SV.playersDB[unitName]
			if playerDbRecord then
				self.playerAlliance[unitId] = playerDbRecord.unitAlliance
				self.playerNames[unitName] = currentTime
				if self:StringStart(effectName, "Boon:") then
					playerDbRecord.mundus = zo_strsub(effectName, 11)
				end
				playerDbRecord.unitSpec = self:DetectSpec(nil, abilityId, nil, unitName, true)
			end
		else
			totalPlayers[unitId] = nil
			self.playerAlliance[unitId] = nil
			self.playerSpec[idToName[unitId]] = nil
			self.miscAbilities[idToName[unitId]] = nil
			idToName[unitId] = nil
			self.npcExclude[unitId] = currentTime
		end
	elseif (unitName ~= "") and (totalPlayers[unitId] == nil) and self:CheckName(unitName) then
		totalPlayers[unitId] = currentTime
		idToName[unitId] = unitName
		local playerDbRecord = self.SV.playersDB[unitName]
		if playerDbRecord then
			self.playerAlliance[unitId] = playerDbRecord.unitAlliance
			self.playerNames[unitName] = currentTime
			if self:StringStart(effectName, "Boon:") then
				playerDbRecord.mundus = zo_strsub(effectName, 11)
			end
			playerDbRecord.unitSpec = self:DetectSpec(unitId, abilityId, nil, unitName, true)
		end
	end
end

function PVP:KillFeedRatio_Add(alliance, location)
	if not alliance then return end
	-- if not location == GetPlayerActiveSubzoneName() then return end

	if not self.killFeedRatio then
		self.killFeedRatio = {
			AD = 0,
			DC = 0,
			EP = 0,
			zone = {},
			startTime = GetFrameTimeSeconds(),
			startAP = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER),
			earnedAP = 0
		}
	end

	-- local ratio = self.killFeedRatio
	local AD = self.killFeedRatio.AD
	local DC = self.killFeedRatio.DC
	local EP = self.killFeedRatio.EP
	local zone = self.killFeedRatio.zone

	insert(zone, location)

	if alliance == 1 then
		self.killFeedRatio.AD = self.killFeedRatio.AD + 1
	elseif alliance == 2 then
		self.killFeedRatio.EP = self.killFeedRatio.EP + 1
	elseif alliance == 3 then
		self.killFeedRatio.DC = self.killFeedRatio.DC + 1
	end

	local ADlabel = PVP_KillFeed_Ratio_AD_Label
	local DClabel = PVP_KillFeed_Ratio_DC_Label
	local EPlabel = PVP_KillFeed_Ratio_EP_Label
	local ADframe = PVP_KillFeed_Ratio_AD
	local DCframe = PVP_KillFeed_Ratio_DC
	local EPframe = PVP_KillFeed_Ratio_EP

	local frame = PVP_KillFeed_Ratio

	local frameWidth = frame:GetWidth()

	local unitPixel = frameWidth / (self.killFeedRatio.AD + self.killFeedRatio.DC + self.killFeedRatio.EP)

	ADframe:SetWidth(self.killFeedRatio.AD * unitPixel)
	DCframe:SetWidth(self.killFeedRatio.DC * unitPixel)
	EPframe:SetWidth(self.killFeedRatio.EP * unitPixel)

	if self.killFeedRatio.AD > 0 then ADlabel:SetText(tostring(self.killFeedRatio.AD)) else ADlabel:SetText("") end
	if self.killFeedRatio.DC > 0 then DClabel:SetText(tostring(self.killFeedRatio.DC)) else DClabel:SetText("") end
	if self.killFeedRatio.EP > 0 then EPlabel:SetText(tostring(self.killFeedRatio.EP)) else EPlabel:SetText("") end
end

function PVP:KillFeedRatio_Reset()
	self.killFeedRatio = nil
	PVP_KillFeed_Ratio:SetHidden(true)
end

function PVP:SecondsToClock(seconds)
	local hours, mins, secs
	seconds = tonumber(seconds)

	if seconds <= 0 then
		return "0sec";
	else
		hours = format("%2.f", zo_floor(seconds / 3600));
		mins = format("%2.f", zo_floor(seconds / 60 - (hours * 60)));
		secs = format("%2.f", zo_floor(seconds - hours * 3600 - mins * 60));
		return (tonumber(hours) > 0 and hours .. " hours, " or "") ..
			(((tonumber(mins) > 0 or tonumber(hours) > 0)) and mins .. " min, " or "") .. secs .. " sec"
	end
end

function PVP:BattleReport()
	local data = self.killFeedRatio
	if data and (data.AD + data.DC + data.EP) >= 5 then
		local zone = data.zone
		local uniqueZones, maxZoneName = {}, ""

		for k, v in ipairs(zone) do
			if v ~= "" then
				uniqueZones[v] = uniqueZones[v] and uniqueZones[v] + 1 or 1

				if maxZoneName == "" or uniqueZones[v] > uniqueZones[maxZoneName] then maxZoneName = v end
			end
		end

		local battleTime = self:Colorize(" lasted ", "BBBBBB") ..
			self:Colorize(
				self:SecondsToClock(zo_ceil(GetFrameTimeSeconds() - data.startTime -
					zo_floor(PVP_BATTLE_INTERVAL / 1000))),
				"AF7500") .. self:Colorize(".", "BBBBBB")

		local outputTitle = self:Colorize(
			" *** Battle " .. (maxZoneName == "" and "" or "at " .. self:Colorize(maxZoneName, "AF7500")), "BBBBBB") --..self:Colorize(" ***", "BBBBBB")

		local outputCasualties = " Casualties: " ..
			(data.AD > 0 and (self:Colorize(tostring(data.AD) .. " AD", PVP_BRIGHT_AD_COLOR)) or "")

		outputCasualties = outputCasualties ..
			(data.DC > 0 and (" " .. self:Colorize(tostring(data.DC) .. " DC", PVP_BRIGHT_DC_COLOR)) or "")
		outputCasualties = outputCasualties ..
			(data.EP > 0 and (" " .. self:Colorize(tostring(data.EP) .. " EP", PVP_BRIGHT_EP_COLOR)) or "")
		outputCasualties = self:Colorize(outputCasualties, "BBBBBB")

		local outputAP = self:Colorize(". Earned", "BBBBBB") ..
			self:Colorize(" " .. zo_iconFormat(PVP_AP, 24, 24) .. tostring(data.earnedAP), "00cc00")

		local finalReport = outputTitle .. battleTime .. outputCasualties .. outputAP .. self:Colorize(". ***", "BBBBBB")


		if self.SV.showKillFeedFrame then PVP_KillFeed_Text:AddMessage(finalReport) end

		if self.SV.showKillFeedChat and self.ChatContainer and self.ChatWindow then
			self.ChatContainer:AddMessageToWindow(self.ChatWindow, finalReport)
		end

		if self.SV.showKillFeedInMainChat then
			chat:Print(finalReport)
		end
	end
end

function PVP:UpdateNamesToDisplay(unitName, currentTime, updateOnly, attackType, abilityId, result, unitId, playerDbRecord)
	-- if not (self.SV.showNamesFrame and self.SV.playersDB[unitName]) then return end
	playerDbRecord = playerDbRecord or self.SV.playersDB[unitName]
	if not playerDbRecord then return end

	local isInBG = IsActiveWorldBattleground()
	local isValidBGNameToDisplay = isInBG and self.bgNames and self.bgNames[unitName] and self.bgNames[unitName] ~= 0 and
		self.bgNames[unitName] ~= GetUnitBattlegroundTeam('player')
	local unitAlliance = self.playerAlliance[unitId] or playerDbRecord and playerDbRecord.unitAlliance
	local isValidCyroNameToDisplay = (not isInBG) and (unitAlliance ~= self.allianceOfPlayer)

	local namesToDisplay = self.namesToDisplay
	local numNames = #namesToDisplay
	if isValidBGNameToDisplay or isValidCyroNameToDisplay then
		local found
		for i = 1, numNames do
			if namesToDisplay[i].unitName == unitName then
				found = i
				break
			end
		end
		if found then
			namesToDisplay[found].unitAlliance = unitAlliance
			namesToDisplay[found].currentTime = currentTime

			if updateOnly and self:GetValidName(GetRawUnitName('reticleover')) == unitName then
				if IsUnitDead('reticleover') then
					namesToDisplay[found].isDead = true
				else
					namesToDisplay[found].isResurrect = nil
				end
			end

			if not updateOnly and namesToDisplay[found].isDead then
				namesToDisplay[found].isDead = nil
				if not namesToDisplay[found].isResurrect then
					namesToDisplay[found].isResurrect = currentTime
				end
			end

			if attackType == 'source' then
				namesToDisplay[found].isAttacker = true
			elseif attackType == 'target' then
				namesToDisplay[found].isTarget = true
			end

			local playerToUpdate = namesToDisplay[found]
			local nameToken = self:BuildReticleName(unitName, unitAlliance, false, playerToUpdate.isAttacker,
			playerToUpdate.isTarget, playerToUpdate.isResurrect, currentTime, playerDbRecord, found)
			playerToUpdate.nameToken = nameToken
			if attackType == 'source' then
				remove(namesToDisplay, found)
				insert(namesToDisplay, playerToUpdate)
			end
			self:PopulateReticleOverNamesBuffer(nil, currentTime)
		elseif not updateOnly then
			local isAttacker, isTarget, isResurrect
			if attackType == 'source' then
				isAttacker = true
				if self.SV.playNewAttackerSound and not IsActiveWorldBattleground() then
					self:PlayLoudSound('DUEL_BOUNDARY_WARNING')
					-- d('New attacker!')
					-- d('unitName: '..unitName)
					-- d('abilityId: '..abilityId)
					-- d('abilityName: '..GetAbilityName(abilityId))
				end
				if self.SV.showNamesFrame and self.SV.showNewAttackerFrame then
					self:UpdateNewAttacker(unitName)
				end
			elseif attackType == 'target' then
				isTarget = true
			end
			if abilityId == 0 and result == 2265 and isTarget then
				isResurrect = currentTime
			end

			local nameToken = self:BuildReticleName(unitName, unitAlliance, false, isAttacker,
			isTarget, isResurrect, currentTime, playerDbRecord, found)

			insert(namesToDisplay,
				{
					unitName = unitName,
					unitAlliance = unitAlliance,
					currentTime = currentTime,
					isAttacker = isAttacker,
					isTarget = isTarget,
					isResurrect = isResurrect,
					nameToken = nameToken
				})
		end
	end
end


function PVP:ProcessKillingBlows(result, targetUnitId, targetName, abilityId)
	if KILLING_BLOW_ACTION_RESULTS[result] and ((targetUnitId and targetUnitId ~= 0 and self.totalPlayers[targetUnitId]) or (targetName and targetName ~= "" or targetName == self.playerName)) and GetAbilityName(abilityId) and GetAbilityName(abilityId) ~= "" then
		local targetNameFromId = targetUnitId and self.idToName[targetUnitId] or targetName
		if targetNameFromId then
			local validTargetName = self:GetValidName(targetNameFromId)
			if not validTargetName then return end
			killingBlows[validTargetName] = abilityId
		end
	end
end

function PVP:OnKillingBlow(result, targetUnitId, currentTime, targetName)
	local totalPlayers = self.totalPlayers
	local idToName = self.idToName
	if KILLING_BLOW_ACTION_RESULTS[result] and totalPlayers[targetUnitId] then
		if idToName[targetUnitId] then
			self.currentlyDead[targetUnitId] = { currentTime = currentTime, playerName = idToName[targetUnitId] }
		else
			self.currentlyDead[targetUnitId] = { currentTime = currentTime, playerName = "" }
		end

		local deadName = idToName[targetUnitId] or targetName

		local numNames = #self.namesToDisplay
		if deadName and numNames > 0 then
			for i = 1, numNames do
				if self.namesToDisplay[i].unitName == deadName and not self.namesToDisplay[i].isDead then
					self.namesToDisplay[i].isDead = true
					self.namesToDisplay[i].currentTime = currentTime
					self:UpdateNamesToDisplay(deadName, currentTime, true, 'target', nil, nil, targetUnitId)
					break
				end
			end
		end

		totalPlayers[targetUnitId] = nil
		self.playerSpec[idToName[targetUnitId]] = nil
		self.miscAbilities[idToName[targetUnitId]] = nil
		idToName[targetUnitId] = nil
		self.playerAlliance[targetUnitId] = nil
	end
end

function PVP:ProcessAnonymousEvents(result, sourceName, targetName, targetUnitId, abilityId, currentTime)
	if sourceName == "" and targetName == "" and (not self.npcExclude[targetUnitId]) and (not self.currentlyDead[targetUnitId]) and not DEAD_ACTION_RESULTS[result] then
	local totalPlayers = self.totalPlayers
	local idToName = self.idToName
	if self:IsNPCAbility(abilityId) then
			self.npcExclude[targetUnitId] = currentTime
			if totalPlayers[targetUnitId] then
				totalPlayers[targetUnitId] = nil
				self.playerSpec[idToName[targetUnitId]] = nil
				self.miscAbilities[idToName[targetUnitId]] = nil
				idToName[targetUnitId] = nil
				self.playerAlliance[targetUnitId] = nil
			end
		else
			totalPlayers[targetUnitId] = currentTime
			if idToName[targetUnitId] then
				self:DetectSpec(targetUnitId, abilityId, result, nil, true)
			end
		end
	end
end

function PVP:ProcessSources(result, sourceName, sourceUnitId, abilityId, targetName, currentTime)
	if sourceName ~= "" and sourceName ~= self.playerName and not (self.currentlyDead[sourceUnitId] or self:IsCurrentlyDead(sourceName)) then
		local totalPlayers = self.totalPlayers
		local idToName = self.idToName
		if not self:CheckName(sourceName) then
			self.npcExclude[sourceUnitId] = currentTime
			if totalPlayers[sourceUnitId] then
				totalPlayers[sourceUnitId] = nil
				self.playerSpec[idToName[sourceUnitId]] = nil
				self.miscAbilities[idToName[sourceUnitId]] = nil
				idToName[sourceUnitId] = nil
				self.playerAlliance[sourceUnitId] = nil
			end
		else
			local playerDbRecord = self.SV.playersDB[sourceName]
			if playerDbRecord then
				self.playerAlliance[sourceUnitId] = playerDbRecord.unitAlliance
				idToName[sourceUnitId] = sourceName
				self:DetectSpec(sourceUnitId, abilityId, result, sourceName, false)
				totalPlayers[sourceUnitId] = currentTime
				if targetName == self.playerName then
					if self.SV.showImportant and self.chargeSnareId[abilityId] then
						self.miscAbilities[sourceName] = self.miscAbilities[sourceName] or {}
						self.miscAbilities[sourceName].chargeId = abilityId
					end
					self:UpdateNamesToDisplay(sourceName, currentTime, false, 'source', abilityId, result, sourceUnitId, playerDbRecord)
				end
			end
		end
	end
end

function PVP:ProcessTargets(result, targetName, sourceName, targetUnitId, abilityId, currentTime, hitValue, abilityName)
	if targetName ~= "" and targetName ~= self.playerName and sourceName == self.playerName and not (self.currentlyDead[targetUnitId] or self:IsCurrentlyDead(targetName)) then
		local totalPlayers = self.totalPlayers
		local idToName = self.idToName
		if not self:CheckName(targetName) then
			self.npcExclude[targetUnitId] = currentTime
			if totalPlayers[targetUnitId] then
				totalPlayers[targetUnitId] = nil
				self.playerSpec[idToName[targetUnitId]] = nil
				self.miscAbilities[idToName[targetUnitId]] = nil
				idToName[targetUnitId] = nil
				self.playerAlliance[targetUnitId] = nil
			end
		else
			local playerDbRecord = self.SV.playersDB[targetName]
			if playerDbRecord then
				self.playerAlliance[targetUnitId] = playerDbRecord.unitAlliance
				idToName[targetUnitId] = targetName
				totalPlayers[targetUnitId] = currentTime
				self:UpdateNamesToDisplay(targetName, currentTime, false, 'target', abilityId, result, targetUnitId, playerDbRecord)

				if result == ACTION_RESULT_REFLECTED then
					self.miscAbilities[targetName] = self.miscAbilities[targetName] or {}
					if not self.miscAbilities[targetName].reflects then self.miscAbilities[targetName].reflects = {} end
					self.miscAbilities[targetName].reflects[abilityName] = true
				end
			end
		end
	end
end

function PVP:ProcessPvpBuffs(result, targetName, abilityId)
	if self:ShouldShowCampFrame() and targetName == self.playerName then
		if abilityId == PVP_CONTINUOUS_ATTACK_ID_1 or abilityId == PVP_CONTINUOUS_ATTACK_ID_2 then
			self:StartAnimation(PVP_ForwardCamp_IconContinuous, 'camp')
			if self.SV.playBuffsSound then
				self:PlayLoudSound('JUSTICE_NOW_KOS')
			end
		elseif abilityId == PVP_AYLEID_WELL_ID then
			self:StartAnimation(PVP_ForwardCamp_IconAyleid, 'camp')
			if self.SV.playBuffsSound then
				self:PlayLoudSound('JUSTICE_NOW_KOS')
			end
		elseif abilityId == PVP_BLESSING_OF_WAR_ID then
			self:StartAnimation(PVP_ForwardCamp_IconBlessing, 'camp')
			if self.SV.playBuffsSound then
				self:PlayLoudSound('JUSTICE_NOW_KOS')
			end
		end
	end
end

function PVP:ProcessImportantAttacks(result, abilityName, abilityId, sourceUnitId, sourceName, hitValue, currentTime)
	local SV = self.SV
	if SV.showImportant and (((self.majorImportantAbilities[abilityId] and self.majorImportantAbilities[abilityId][result]) or (self.minorImportantAbilities[abilityId] and self.minorImportantAbilities[abilityId][result])) or
		(result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityName == "Charge Snare" and self.miscAbilities[sourceName] and self.miscAbilities[sourceName].chargeId)) then
		if (not hitValue) or (hitValue <= 200) or (hitValue > 5000) then return end
		local ccImmune = self:IsPlayerCCImmune(currentTime, hitValue)
		if (not ccImmune) then
			local abilityIcon = self.abilityIconSwaps[abilityId] or GetAbilityIcon(abilityId)
			if self.majorImportantAbilities[abilityId] then
				self.majorAttackNotficiationLockout = currentTime + hitValue
				local localAlert = sourceName ~= "AgonyWarning"
				if SV.enableAttackSound then
					local secondaryAlert = SV.secondaryAlert
					self:PlayLoudSound((secondaryAlert and not localAlert) and 'DUEL_START' or 'CONSOLE_GAME_ENTER')
					if secondaryAlert and localAlert and hitValue > 500 then
						zo_callLater(function() self:PlayLoudSound('DUEL_START') end, hitValue - 300)
					end
				end
				FlashHealthWarningStage(1, 150)
				PVP_Main.currentChannel = nil
				self:OnDraw(false, sourceUnitId, abilityName,
					abilityId, abilityIcon, sourceName, true,
					false, false, hitValue)
			elseif self.minorImportantAbilities[abilityId] then
				if currentTime < self.majorAttackNotficiationLockout then return end
				self.minorAttackNotficiationLockout = currentTime + hitValue
				if SV.enableAttackSound then
					self:PlayLoudSound('COLLECTIBLE_ON_COOLDOWN')
				end
				self:OnDraw(false, sourceUnitId, abilityName,
					abilityId, abilityIcon, sourceName, false,
					false, false, hitValue)
				PVP_Main.currentChannel = {
					abilityId = abilityId,
					sourceUnitId = sourceUnitId,
					isHA = false,
					coolDownStartTime = currentTime
				}
			elseif abilityName == "Charge Snare" then
				if currentTime < self.majorAttackNotficiationLockout then return end
				if currentTime < self.minorAttackNotficiationLockout then return end
					abilityIcon = GetAbilityIcon(self.miscAbilities[sourceName].chargeId)
					self:OnDraw(false, sourceUnitId, abilityName,
					abilityId, abilityIcon, sourceName, false,
					false, false, hitValue)
			end
		end

		if self.networkedAbilities[abilityId] and SV.enableNetworking and GetGroupSize() ~= 0 and not (sourceName == "AgonyWarning") then
			PVP:SendWarning()
		end

	end
end

function PVP:ProcessChanneledAttacks(result, isHeavyAttack, isSnipe, abilityId, sourceUnitId, sourceName, hitValue, currentTime)
	if currentTime < self.majorAttackNotficiationLockout or currentTime < self.minorAttackNotficiationLockout then return end
	if result == ACTION_RESULT_BEGIN and (isHeavyAttack or isSnipe or self.ambushId[abilityId]) then
		local abilityIcon = isHeavyAttack and self.heavyAttackId[abilityId] or GetAbilityIcon(abilityId)
		self:OnDraw(isHeavyAttack, sourceUnitId, nil,
			abilityId, abilityIcon, sourceName, false,
			false, false, hitValue)
		PVP_Main.currentChannel = {
			abilityId = abilityId,
			sourceUnitId = sourceUnitId,
			isHA = isHeavyAttack,
			coolDownStartTime = currentTime
		}
	end
end

function PVP:ProcessPiercingMarks(result, abilityName, abilityId, sourceUnitId, sourceName, hitValue, currentTime)
	if not self.SV.showPiercingMark then return end
	if currentTime < self.majorAttackNotficiationLockout or currentTime < self.minorAttackNotficiationLockout then return end
	if result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityName == "Piercing Mark" and not self.piercingDelay then
		self.piercingDelay = true
		local iconAbility = GetAbilityIcon(abilityId)
		PVP_Main.currentChannel = nil
		self:OnDraw(false, sourceUnitId, abilityName, abilityId,
				iconAbility, sourceName, false,
		true, false, hitValue)
		zo_callLater(function() self.piercingDelay = false end, 50)
	end
end

function PVP:ProcessChanneledHits(result, abilityId, sourceUnitId, sourceName, hitValue, currentTime)
	if currentTime < self.majorAttackNotficiationLockout or currentTime < self.minorAttackNotficiationLockout then return end
	if not PVP_Main:IsHidden() and PVP_Main:GetAlpha() > 0 and PVP_Main.currentChannel and PVP_Main.currentChannel.abilityId == abilityId and PVP_Main.currentChannel.sourceUnitId == sourceUnitId and self.hitTypes[result] then
		if not PVP_MainAbilityIconFrameLeftHeavyAttackHighlightIcon.animData:IsPlaying() and not PVP_MainAbilityIconFrameLeftGlow.animData:IsPlaying() then
			self:PlayHighlightAnimation(PVP_Main.currentChannel.isHA, hitValue)
		end
	end
end

function PVP:OnCombat(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName,
	sourceType, targetName, targetType, hitValue, powerType, damageType, combat_log, sourceUnitId,
	targetUnitId, abilityId)
	if not self:IsInPVPZone() then return end
	local currentTime = GetFrameTimeMilliseconds()
	abilityName = abilityName and abilityName ~= "" and abilityName or GetAbilityName(abilityId)

	if IsActiveWorldBattleground() then
		self.bgNames = self.bgNames or {}
		if sourceName and sourceName ~= '' and not self.bgNames[sourceName] then self.bgNames[sourceName] = 0 end
		if targetName and targetName ~= '' and not self.bgNames[targetName] then self.bgNames[targetName] = 0 end
	end
	if ccImmunityBuffs[abilityName] and targetName == self.playerName then
		if (result == ACTION_RESULT_EFFECT_GAINED_DURATION) or (result == ACTION_RESULT_EFFECT_GAINED) then
			local lastEndTime = self.ccImmunity[abilityName]
			if (not lastEndTime) or lastEndTime < currentTime then
				self.ccImmunity[abilityName] = currentTime + hitValue
			end
		elseif targetName == self.playerName and result == ACTION_RESULT_EFFECT_FADED then
			self.ccImmunity[abilityName] = nil
		end
	end

	local SV = self.SV
	-- if GetUnitClassId('player') == 3 and SV.show3DIcons and SV.shadowImage3d and targetType == 1 and shadowReturnIds[abilityId] then
	if GetUnitClassId('player') == 3 and SV.show3DIcons and SV.shadowImage3d then
		if shadowSetupIds[abilityId] and result == 2245 then
			self.shadowTime = hitValue
		end
			if shadowReturnIds[abilityId] then
			if result == 2245 then
				if not self.eventCounter then self.eventCounter = 0 end
				self.eventCounter = self.eventCounter + 1
				self:SetupShadow(self.shadowTime)
			elseif result == 2250 then
				if not self.eventCounter then self.eventCounter = 1 end
				self.eventCounter = self.eventCounter - 1
				if self.eventCounter == 0 then
				self:ResetShadow()
				end
			end
		end
	end

	local isHeavyAttack = SV.showHeavyAttacks and self.heavyAttackId[abilityId]
	local isSnipe = SV.showSnipes and (self.snipeId[abilityId] or self.snipeNames[abilityName])

	if KILLING_BLOW_ACTION_RESULTS[result] then
		self:ProcessKillingBlows(result, targetUnitId, targetName, abilityId)
		self:OnKillingBlow(result, targetUnitId, currentTime, targetName)
	end

	self:ProcessAnonymousEvents(result, sourceName, targetName, targetUnitId, abilityId, currentTime)
	self:ProcessSources(result, sourceName, sourceUnitId, abilityId, targetName, currentTime)
	self:ProcessTargets(result, targetName, sourceName, targetUnitId, abilityId, currentTime, hitValue, abilityName)

	if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
		self:ProcessPvpBuffs(result, targetName, abilityId)
	end

	if self.SV.showAttacks and sourceName ~= self.playerName and ((self.majorImportantAbilities[abilityId] or self.minorImportantAbilities[abilityId]) and (targetName == self.playerName or self.playerAlliance[targetUnitId] == self.allianceOfPlayer or self.playerAlliance[sourceUnitId] ~= self.allianceOfPlayer)) then
		self:ProcessImportantAttacks(result, abilityName, abilityId, sourceUnitId, sourceName, hitValue, currentTime)
		self:ProcessChanneledAttacks(result, isHeavyAttack, isSnipe, abilityId, sourceUnitId, sourceName, hitValue, currentTime)
		self:ProcessPiercingMarks(result, abilityName, abilityId, sourceUnitId, sourceName, hitValue, currentTime)
		self:ProcessChanneledHits(result, abilityId, sourceUnitId, sourceName, hitValue, currentTime)
	end
end

function PVP:UpdateKillfeedPlayer(currentTime, playerValidName, playerDisplayName, unitAlliance, unitAllianceRank)
	if playerValidName == self.playerName or playerDisplayName == "" then return end

	local playersDB = self.SV.playersDB
	local playerDbRecord = playersDB[playerValidName] or {}
	local unitDbAccName = playerDbRecord.unitAccName or playerDisplayName

	playerDbRecord.unitAccName = playerDisplayName
	playerDbRecord.unitAlliance = unitAlliance
	playerDbRecord.unitAvARank = unitAllianceRank
	playersDB[playerValidName] = playerDbRecord
	if playerDisplayName ~= unitDbAccName then
		cachedPlayerNameChanges[playerValidName] = {
			oldUnitAccName = unitDbAccName,
			newUnitAccName = playerDisplayName,
		}
	end
	self.playerNames[playerValidName] = currentTime
end

local function GetSpacedOutString(...)
	local text = ""
	local numArgs = select("#", ...)
	for i = 1, numArgs do
		text = text .. select(i, ...)
		if i ~= numArgs then
			text = text .. " "
		end
	end
	return text
end

function PVP:GetImportantIcon(unitCharName, unitAccName, unitAlliance)
	local KOSOrFriend = self:IsKOSOrFriend(unitCharName, unitAccName or unitCharName and self.SV.playersDB[unitCharName].unitAccName)
	if KOSOrFriend then
		if KOSOrFriend == "KOS" then
			return self:GetKOSIcon(32,
					unitAlliance == self.allianceOfPlayer and "FFFFFF" or nil),
				true
		elseif KOSOrFriend == "friend" then
			return self:GetFriendIcon(24), false
		elseif KOSOrFriend == "cool" then
			return self:GetCoolIcon(24), false
		elseif KOSOrFriend == "groupleader" then
			return self:GetGroupLeaderIcon(32), false
		elseif KOSOrFriend == "group" then
			return self:GetGroupIcon(32), false
		elseif KOSOrFriend == "guild" then
			return self:GetGuildIcon(24,
					unitAlliance == self.allianceOfPlayer and "40BB40" or "BB4040"),
				false
		end
	else
		return ""
	end
end

local function GetFormattedAbilityName(abilityId, color)
	local abilityName, textAbilityIcon
	local formattedAbility = ""
	if abilityId then
		abilityName = PVP:Colorize(GetAbilityName(abilityId), color)
		local abilityIcon = GetAbilityIcon(abilityId)

		if abilityIcon:find(PVP_ICON_MISSING) then
			textAbilityIcon = ""
		else
			textAbilityIcon = zo_iconFormat(abilityIcon, 18, 18)
		end
		formattedAbility = textAbilityIcon .. abilityName
	end
	return formattedAbility
end

function PVP:GetOwnKbString(targetValidName, target, abilityId, targetDisplayName, targetAlliance, targetAllianceRank, targetAllianceColor, killFeedNameType)
	local text
	local messageColor = "40BB40"
	local bracketsToken = self:Colorize("***", messageColor)
	local playerActionKilledToken = self:Colorize("You killed", messageColor)

	local importantToken, isKOS = self:GetImportantIcon(targetValidName, targetDisplayName, targetAlliance)
	local isTargetEmperor = self:IsEmperor(targetValidName, currentCampaignActiveEmperor)
	if isTargetEmperor then
		importantToken = self:GetEmperorIcon(32, targetAllianceColor) .. importantToken
	end
	local targetToken
	local targetNameToken = target

	local prepToken = self:Colorize("with", messageColor)
	local suffixToken = self:Colorize("!", messageColor)
	local kbIconToken = zo_iconFormat(PVP_KILLING_BLOW, 38, 38)

	if killFeedNameType == "both" then
		targetToken = targetNameToken .. self:GetFormattedAccountNameLink(targetDisplayName, "CCCCCC") or
			self:Colorize(targetDisplayName, "CCCCCC")
	elseif killFeedNameType == "character" then
		targetToken = targetNameToken
	elseif killFeedNameType == "user" then
		targetToken = self:GetFormattedClassIcon(targetValidName, nil, targetAllianceColor, nil, nil, nil, nil, nil,
				nil, targetAllianceRank) ..
			self:GetFormattedAccountNameLink(targetDisplayName, targetAllianceColor) or
			self:Colorize(targetDisplayName, targetAllianceColor)
	end

	if abilityId then
		local abilityToken = GetFormattedAbilityName(abilityId, messageColor)
		text = GetSpacedOutString(bracketsToken, playerActionKilledToken,
			importantToken .. targetToken,
			prepToken,
			abilityToken .. suffixToken .. kbIconToken)
	else
		text = GetSpacedOutString(bracketsToken, playerActionKilledToken,
			importantToken .. targetToken .. suffixToken .. kbIconToken)
	end
	return text, isKOS, bracketsToken
end

function PVP:GetKbStringTarget(targetValidName, target, targetDisplayName, targetAlliance, targetAllianceRank, targetAllianceColor, abilityId, sourceValidName, sourceDisplayName, sourceAlliance, sourceAllianceRank, sourceAllianceColor, killLocation, killFeedNameType)
	local text
	local endToken
	local messageColor = "AF7500"

	local killerImportantToken = self:GetImportantIcon(sourceValidName, sourceDisplayName, sourceAlliance)
	local isSourceEmperor = self:IsEmperor(sourceValidName, currentCampaignActiveEmperor)
	if isSourceEmperor then
		killerImportantToken = self:GetEmperorIcon(32, sourceAllianceColor) .. killerImportantToken
	end
	local sourceToken
	local killerNameToken = self:GetFormattedClassNameLink(sourceValidName, sourceAllianceColor, nil, nil, nil, nil,
		nil, nil, nil, sourceAllianceRank)

	local actionToken = self:Colorize("killed", messageColor)

	local targetImportantToken = self:GetImportantIcon(targetValidName, targetDisplayName, targetAlliance)
	local isTargetEmperor = self:IsEmperor(targetValidName, currentCampaignActiveEmperor)
	if isTargetEmperor then
		targetImportantToken = self:GetEmperorIcon(32, targetAllianceColor) .. targetImportantToken
	end
	local targetToken
	local targetNameToken = target
	local withToken = self:Colorize("with", messageColor)

	local suffixToken = self:Colorize("!", messageColor)

	if not killLocation or killLocation == "" then
		endToken = suffixToken
	else
		local locationToken = self:Colorize(" near " .. killLocation, messageColor)
		endToken = locationToken .. suffixToken
	end

	if killFeedNameType == "both" then
		sourceToken = killerNameToken .. self:GetFormattedAccountNameLink(sourceDisplayName, "CCCCCC") or
			self:Colorize(sourceDisplayName, "CCCCCC")
		targetToken = targetNameToken .. self:GetFormattedAccountNameLink(targetDisplayName, "CCCCCC") or
			self:Colorize(targetDisplayName, "CCCCCC")
	elseif killFeedNameType == "character" then
		sourceToken = killerNameToken
		targetToken = targetNameToken
	elseif killFeedNameType == "user" then
		sourceToken = self:GetFormattedClassIcon(sourceValidName, nil, sourceAllianceColor, nil, nil, nil, nil,
				nil, nil, sourceAllianceRank) ..
			self:GetFormattedAccountNameLink(sourceDisplayName, sourceAllianceColor) or
			self:Colorize(sourceDisplayName, sourceAllianceColor)
		targetToken = self:GetFormattedClassIcon(targetValidName, nil, targetAllianceColor, nil, nil, nil, nil, nil,
				nil, targetAllianceRank) ..
			self:GetFormattedAccountNameLink(targetDisplayName, targetAllianceColor) or
			self:Colorize(targetDisplayName, targetAllianceColor)
	end
	if abilityId then
		local abilityToken = GetFormattedAbilityName(abilityId, "CCCCCC")
		text = GetSpacedOutString(killerImportantToken .. sourceToken,
			actionToken,
			targetImportantToken .. targetToken,
			withToken,
			abilityToken .. endToken)
	else
		text = GetSpacedOutString(killerImportantToken .. sourceToken,
			actionToken,
			targetImportantToken .. targetToken ..
			endToken)
	end

	return text
end

function PVP:GetKbStringPlayer(abilityId, sourceValidName, sourceDisplayName, sourceAlliance, sourceAllianceRank, sourceAllianceColor, killFeedNameType)
	local text
	local messageColor = "BB4040"
	local bracketsToken = self:Colorize("***", messageColor)
	local playerActionDiedToken = self:Colorize("You were killed by", messageColor)

	local importantToken = self:GetImportantIcon(sourceValidName, sourceDisplayName, sourceAlliance)
	local isSourceEmperor = self:IsEmperor(sourceValidName, currentCampaignActiveEmperor)
	if isSourceEmperor then
		importantToken = self:GetEmperorIcon(32, sourceAllianceColor) .. importantToken
	end
	local sourceToken
	local killedByNameToken = self:GetFormattedClassNameLink(sourceValidName, sourceAllianceColor, nil, nil, nil, nil,
		nil, nil, nil, sourceAllianceRank)

	local suffixToken = self:Colorize("!", messageColor)
	if killFeedNameType == "both" then
		sourceToken = killedByNameToken .. self:GetFormattedAccountNameLink(sourceDisplayName, "CCCCCC") or
			self:Colorize(sourceDisplayName, "CCCCCC")
	elseif killFeedNameType == "character" then
		sourceToken = killedByNameToken
	elseif killFeedNameType == "user" then
		sourceToken = self:GetFormattedClassIcon(sourceValidName, nil, sourceAllianceColor, nil, nil, nil, nil,
				nil, nil, sourceAllianceRank) ..
			self:GetFormattedAccountNameLink(sourceDisplayName, sourceAllianceColor) or
			self:Colorize(sourceDisplayName, sourceAllianceColor)
	end
	if abilityId then
		local abilityToken = GetFormattedAbilityName(abilityId, "CCCCCC")
		local possessiveToken = self:Colorize("'s'", messageColor)
		text = GetSpacedOutString(playerActionDiedToken,
			importantToken .. sourceToken .. possessiveToken,
			abilityToken .. suffixToken)
	else
		text = GetSpacedOutString(playerActionDiedToken,
			importantToken .. sourceToken .. suffixToken)
	end
	return text, bracketsToken
end

function PVP:ProcessKillfeedEntry(targetValidName, targetDisplayName, targetAlliance, targetRank, targetAllianceColor, sourceValidName, sourceDisplayName, sourceAlliance, sourceRank, sourceAllianceColor, killFeedNameType, killLocation)
	local currentTime = GetFrameTimeMilliseconds()
	local abilityId = killingBlows[targetValidName]
	killingBlows[targetValidName] = nil
	if self.killFeedDelay == 0 then PVP_KillFeed_Text:Clear() end
	if self.killFeedRatioDelay == 0 then self:KillFeedRatio_Reset() end

	self.killFeedDelay = currentTime
	if self.SV.showKillFeedFrame then self.killFeedRatioDelay = currentTime end

	local isOwnKillingBlow = sourceValidName == self.playerName
	local kbOnPlayer = targetValidName == self.playerName

	local outputText
	local endingBrackets = ""

	if kbOnPlayer then
		outputText, endingBrackets = self:GetKbStringPlayer(abilityId, sourceValidName,
			sourceDisplayName, sourceAlliance, sourceRank, sourceAllianceColor, killFeedNameType)
	else
		if self.SV.showKillFeedFrame then self:KillFeedRatio_Add(targetAlliance, killLocation) end
		local target = self:GetFormattedClassNameLink(targetValidName, targetAllianceColor, nil, nil, nil, nil, nil,
			nil, nil, targetRank)
		if isOwnKillingBlow then
			local isKOS
			outputText, isKOS, endingBrackets = self:GetOwnKbString(targetValidName, target, abilityId,
				targetDisplayName, targetAlliance, targetRank, targetAllianceColor, killFeedNameType)
			if self.SV.playKillingBlowSound then
				self:PlayLoudSound('DUEL_WON')
				if isKOS then
					zo_callLater(function()
						self:PlayLoudSound('ACHIEVEMENT_AWARDED')
					end, 3000)
				end
			end
		else
			outputText = self:GetKbStringTarget(targetValidName, target, targetDisplayName,
				targetAlliance, targetRank, targetAllianceColor, abilityId, sourceValidName, sourceDisplayName,
				sourceAlliance, sourceRank, sourceAllianceColor, killLocation, killFeedNameType)
		end
	end

	if self.killingBlowsInfo and targetAlliance and targetAlliance ~= self.allianceOfPlayer then
		outputText = GetSpacedOutString(outputText .. self.killingBlowsInfo.message)
		self.killingBlowsInfo = nil
	end

	outputText = outputText .. " " .. endingBrackets

	if self.SV.showKillFeedFrame then PVP_KillFeed_Text:AddMessage(outputText) end

	if not self.SV.showOnlyOwnKillingBlows or isOwnKillingBlow then
		if self.SV.showKillFeedChat and self.ChatContainer and self.ChatWindow then
			self.ChatContainer:AddMessageToWindow(self.ChatWindow,
				self:Colorize("[" .. GetTimeString() .. "]", "A0A0A0") .. outputText)
		end

		if self.SV.showKillFeedInMainChat then
			chat:Print(outputText)
		end
	end
end

function PVP:OnKillfeed(_, killLocation, sourceDisplayName, sourceCharacterName, sourceAlliance, sourceRank, targetDisplayName, targetCharacterName, targetAlliance, targetRank)
	local currentTime = GetFrameTimeMilliseconds()
	local killFeedNameType = self.SV.killFeedNameType or self.defaults.killFeedNameType
	if killFeedNameType == "link" then
		killFeedNameType = self.SV.userDisplayNameType or self.defaults.userDisplayNameType
	end
	local messageKey = format("%s->->%s", sourceDisplayName, targetDisplayName)
	local numOccurrences = killFeedDuplicateTracker:AddValue(messageKey)
	if numOccurrences > 1 then return end

	local targetValidName = self:GetValidName(targetCharacterName)
	local targetAllianceColor = self:GetTrueAllianceColorsHex(targetAlliance)
	local sourceValidName = self:GetValidName(sourceCharacterName)
	local sourceAllianceColor = self:GetTrueAllianceColorsHex(sourceAlliance)

	self:UpdateKillfeedPlayer(currentTime, targetValidName, targetDisplayName, targetAlliance, targetRank)
	self:UpdateKillfeedPlayer(currentTime, sourceValidName, sourceDisplayName, sourceAlliance, sourceRank)

	insert(killFeedBuffer, {
		targetValidName = targetValidName,
		targetDisplayName = targetDisplayName,
		targetAlliance = targetAlliance,
		targetRank = targetRank,
		targetAllianceColor = targetAllianceColor,
		sourceValidName = sourceValidName,
		sourceDisplayName = sourceDisplayName,
		sourceAlliance = sourceAlliance,
		sourceRank = sourceRank,
		sourceAllianceColor = sourceAllianceColor,
		killFeedNameType = killFeedNameType,
		killLocation = killLocation
	})
end

function PVP:ProcessKillFeedBuffer()
	for i, entry in ipairs(killFeedBuffer) do
		self:ProcessKillfeedEntry(
			entry.targetValidName,
			entry.targetDisplayName,
			entry.targetAlliance,
			entry.targetRank,
			entry.targetAllianceColor,
			entry.sourceValidName,
			entry.sourceDisplayName,
			entry.sourceAlliance,
			entry.sourceRank,
			entry.sourceAllianceColor,
			entry.killFeedNameType,
			entry.killLocation
		)
		killFeedBuffer[i] = nil
	end
	killingBlows = {}
end

function PVP:ResetMainFrame()
	PVP_MainLabel:SetText("")

	PVP_MainAbilityIconFrameLeftGlow.animData:Stop()
	PVP_MainAbilityIconFrameLeftGlow:SetAlpha(0)
	PVP_MainAbilityIconFrameLeftHeavyAttackHighlightIcon.animData:Stop()
	PVP_MainAbilityIconFrameLeftHeavyAttackHighlightIcon:SetAlpha(0)
	PVP_MainAbilityIconFrameLeftCooldown:ResetCooldown()
	-- PVP_MainAbilityIconFrameLeftCooldownMark:ResetCooldown()

	PVP_MainAbilityIconFrameRightGlow.animData:Stop()
	PVP_MainAbilityIconFrameRightGlow:SetAlpha(0)
	PVP_MainAbilityIconFrameRightHeavyAttackHighlightIcon.animData:Stop()
	PVP_MainAbilityIconFrameRightHeavyAttackHighlightIcon:SetAlpha(0)
	PVP_MainAbilityIconFrameRightCooldown:ResetCooldown()
	-- PVP_MainAbilityIconFrameRightCooldownMark:ResetCooldown()


	PVP_MainAbilityIconFrameLeftIcon:SetColor(1, 1, 1, 1)
	PVP_MainAbilityIconFrameRightIcon:SetColor(1, 1, 1, 1)

	PVP_Main.isHA = false

	PVP_MainAbilityIconFrameRight:SetHidden(false)
	if PVP_MainAbilityIconFrameLeftLeadingEdge.animData and PVP_MainAbilityIconFrameLeftLeadingEdge.animData:IsPlaying() then
		PVP_MainAbilityIconFrameLeftLeadingEdge.animData:Stop()
	end
	PVP_Main:SetHidden(true)
end

function PVP:PlayLeadingEdgeAnimation(control, hitValue)
	if control.animData then control.animData:Stop() end

	local timeline = ANIMATION_MANAGER:CreateTimeline()
	local iconControl = control:GetParent():GetNamedChild('Icon')
	local _, offsetY = iconControl:GetDimensions()

	control:ClearAnchors()
	control:SetAnchor(CENTER, iconControl, BOTTOM, 0, 4)

	self:InsertAnimationType(timeline, ANIMATION_TRANSLATE, control, hitValue, 0, ZO_LinearEase, 0, 4, 0, -(offsetY))


	timeline:SetHandler('OnStop', function()
		control:SetHidden(true)
	end)

	control:SetHidden(false)
	timeline:PlayFromStart()
	return timeline
end

function PVP:SetupMainFrame(text, isImportant, texture, isHA)
	self:ResetMainFrame()

	PVP_MainLabel:SetText(text)

	PVP_MainAbilityIconFrameLeftIcon:SetTexture(texture)
	PVP_MainAbilityIconFrameLeftCooldown:SetTexture(texture)


	PVP_MainAbilityIconFrameRightIcon:SetTexture(texture)
	PVP_MainAbilityIconFrameRightCooldown:SetTexture(texture)

	if isHA then
		PVP_MainAbilityIconFrameLeftHeavyAttackHighlightIcon:SetTexture(texture)
		PVP_MainAbilityIconFrameRightHeavyAttackHighlightIcon:SetTexture(texture)
	end

	PVP_MainAbilityIconFrameLeftLeadingEdge:SetHidden(true)
	PVP_MainAbilityIconFrameRight:SetHidden(not isImportant)
	PVP_Main.isHA = isHA
end

local function FadeOut(control)
	control.animData:FadeOut(0, 175, ZO_ALPHA_ANIMATION_OPTION_FORCE_ALPHA)
end

local function StartAnim(control, duration)
	control.animData:PingPong(0, 1, duration, 1)
end

function PVP:PlayHighlightAnimation(isHA, duration)
	local leadingEdgeControl = PVP_MainAbilityIconFrameLeftLeadingEdge
	if leadingEdgeControl.animData and leadingEdgeControl.animData:IsPlaying() then leadingEdgeControl.animData:Stop() end
	duration = duration or 250

	if isHA then
		StartAnim(PVP_MainAbilityIconFrameLeftHeavyAttackHighlightIcon, duration)
		StartAnim(PVP_MainAbilityIconFrameRightHeavyAttackHighlightIcon, duration)
		-- PVP_MainAbilityIconFrameLeftHeavyAttackHighlightIcon.animData:PingPong(0, 1, 250, 1)
		-- PVP_MainAbilityIconFrameRightHeavyAttackHighlightIcon.animData:PingPong(0, 1, 250, 1)
	else
		StartAnim(PVP_MainAbilityIconFrameLeftGlow, duration)
		StartAnim(PVP_MainAbilityIconFrameRightGlow, duration)
		-- PVP_MainAbilityIconFrameLeftGlow.animData:PingPong(0, 1, 250, 1)
		-- PVP_MainAbilityIconFrameRightGlow.animData:PingPong(0, 1, 250, 1)
	end

	local cooldownDuration = PVP_MainAbilityIconFrameLeftCooldown:GetDuration()

	if PVP_Main.currentChannel and PVP_Main.currentChannel.coolDownStartTime and cooldownDuration ~= 0 then
		PVP_Main.currentChannel = nil
	end
end

local function SetAnimData(control)
	control.animData = ZO_AlphaAnimation:New(control)
	control.animData:SetMinMaxAlpha(0, 1)
end

function PVP_SetupHighlightAnimation(control)
	local glowLeft = control:GetNamedChild('AbilityIconFrameLeft'):GetNamedChild('Glow')
	local glowRight = PVP_MainAbilityIconFrameRight:GetNamedChild('Glow')
	local iconHighlightLeft = control:GetNamedChild('AbilityIconFrameLeft'):GetNamedChild('HeavyAttackHighlightIcon')
	local iconHighlightRight = PVP_MainAbilityIconFrameRight:GetNamedChild('HeavyAttackHighlightIcon')

	SetAnimData(glowLeft)
	SetAnimData(glowRight)
	SetAnimData(iconHighlightLeft)
	SetAnimData(iconHighlightRight)
end

function PVP:OnDraw(isHeavyAttack, sourceUnitId, abilityName, abilityId, abilityIcon, sourceName, isImportant, isPiercingMark, isDebuff, hitValue)
	local playerAlliance, nameFromDB, accountNameFromDB, classIcon, nameColor, nameFont, enemyName, formattedName, pureNameWidth, playerDbRecord
	local importantMode = isImportant and not isPiercingMark
	local userDisplayNameType = self.SV.userDisplayNameType or self.defaults.userDisplayNameType
	local heavyAttackSpacer = isHeavyAttack and "" or " "
	local abilityIconSize = isHeavyAttack and 75 or 50
	-- local nameWidth = abilityIconSize
	local nameWidth = 0
	local classIconSize = 45
	-- local abilityIcon = self:GetIcon(abilityIcon, abilityIconSize)..heavyAttackSpacer
	-- local importantIcon = importantMode and " "..abilityIcon or ""
	sourceName = sourceName and sourceName ~= "" and sourceName or sourceUnitId and self.idToName[sourceUnitId]
	if sourceName then
		playerDbRecord = self.SV.playersDB[sourceName]
		accountNameFromDB = playerDbRecord and playerDbRecord.unitAccName
	end
	if sourceUnitId == "unlock" then
		playerAlliance = "BBBBBB"
		classIcon = playerAlliance and
			self:Colorize(zo_iconFormatInheritColor(self.classIcons[3], classIconSize, classIconSize), playerAlliance) or
			heavyAttackSpacer
	elseif not isDebuff then
		playerAlliance = self:IdToAllianceColor(sourceUnitId)
		classIcon = playerAlliance and self:GetFormattedClassIcon(nameFromDB, classIconSize, playerAlliance, nil, nil,
				nil, nil, nil, nil, nil, playerDbRecord or "none") or
			heavyAttackSpacer
	else
		classIcon = ""
	end

	-- enemyName = isDebuff and sourceName or self:GetFormattedName(sourceName)
	enemyName = isDebuff and sourceName or
		(userDisplayNameType == "character" and (self:GetFormattedName(sourceName) or "unknown player") or
			(userDisplayNameType == "user" and (accountNameFromDB or sourceName or "unknown player") or
				(userDisplayNameType == "both" and (self:GetFormattedName(sourceName) .. (accountNameFromDB or "")) or "unknown player")))

	if importantMode then
		nameColor = self.SV.colors.stealthed
		PVP_MainBackdrop:SetHidden(false)
		PVP_MainBackdrop_Add:SetHidden(false)
	else
		PVP_MainBackdrop:SetHidden(true)
		if isPiercingMark then
			PVP_MainBackdrop_Add:SetHidden(false)
			nameColor = self.SV.colors.piercing
		else
			PVP_MainBackdrop_Add:SetHidden(true)
			nameColor = self.SV.colors.normal
		end
	end

	if self.isPlaying then self.isPlaying:Stop() end

	local scale = PVP_MainLabel:GetScale()
	local weirdScale = scale


	local abilityMessages = self.abilityMessages
	if abilityMessages[abilityId] then
		local setName = abilityMessages[abilityId]
		nameWidth = PVP_MainLabel:GetStringWidth(setName)
		PVP_MainLabel:SetWidth(nameWidth / weirdScale)
		formattedName = self:Colorize(setName, "FF0000")
		self:SetupMainFrame(formattedName, importantMode, abilityIcon, isHeavyAttack)
	else
		nameWidth = PVP_MainLabel:GetStringWidth(enemyName) + 60
		PVP_MainLabel:SetWidth(nameWidth / weirdScale)
		formattedName = self:Colorize(enemyName, playerAlliance and playerAlliance or nameColor)
		self:SetupMainFrame(classIcon .. formattedName, importantMode, abilityIcon, isHeavyAttack)
	end

	if hitValue then
		PVP_MainAbilityIconFrameLeftCooldown:StartCooldown(hitValue, hitValue, CD_TYPE_VERTICAL_REVEAL,
			CD_TIME_TYPE_TIME_UNTIL, false)
		if not isHeavyAttack then
			PVP_MainAbilityIconFrameLeftLeadingEdge.animData = PVP:PlayLeadingEdgeAnimation(
				PVP_MainAbilityIconFrameLeftLeadingEdge, hitValue)
		end
		-- PVP_MainAbilityIconFrameLeftCooldownMark:StartCooldown(hitValue, hitValue, CD_TYPE_VERTICAL_REVEAL, CD_TIME_TYPE_TIME_UNTIL, not isHeavyAttack)
	end

	if isImportant then
		self:PlayHighlightAnimation()
	end

	PVP_Main:SetHidden(false)

	if isPiercingMark then
		self.isPlaying = self:StartAnimation(PVP_Main, 'main piercing', hitValue)
	elseif isImportant then
		self.isPlaying = self:StartAnimation(PVP_Main, 'main important', hitValue)
	else
		self.isPlaying = self:StartAnimation(PVP_Main, 'main stealthed', hitValue)
	end
end

function PVP:StartAnimation(control, animationType, hitValue)
	hitValue = hitValue or 1000
	if animationType ~= 'camp' and animationType ~= 'fadeOut' and self.isPlaying then self.isPlaying:Stop() end

	local _, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()
	local scale

	if animationType == 'camp' then
		scale = self.SV.campControlScale
	elseif animationType == 'fadeOut' then
		scale = self.SV.targetNameFrameScale
	elseif animationType == 'medal' then
		scale = 1
	else
		scale = self.SV.controlScale
	end

	control:ClearAnchors()
	control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)

	local timeline = ANIMATION_MANAGER:CreateTimeline()

	if animationType == 'main stealthed' then
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 100, 0, ZO_EaseOutQuadratic, 0, 1)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 100, 0, ZO_EaseOutQuadratic, 1, 1.5, PVP_SET_SCALE_FROM_SV)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 100, 100, ZO_EaseInQuadratic, 1.5, 1, PVP_SET_SCALE_FROM_SV)
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 250, hitValue > PVP_FRAME_DISPLAY_TIME and hitValue or PVP_FRAME_DISPLAY_TIME, ZO_EaseInQuintic, 1, 0, PVP_SET_SCALE_FROM_SV)
	elseif animationType == 'main piercing' then
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 50, 0, ZO_EaseOutQuadratic, 0, 1)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 100, 0, ZO_EaseOutQuadratic, 1, 1.2, PVP_SET_SCALE_FROM_SV)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 250, 350, ZO_EaseInQuadratic, 1.2, 1, PVP_SET_SCALE_FROM_SV)
		local currentAlpha = control:GetAlpha()
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 150, hitValue > 1600 and hitValue or 1600, ZO_EaseOutQuadratic, currentAlpha, 0)
	elseif animationType == 'medal' then
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 250, 0, ZO_EaseInQuadratic, 0, 1)
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 1000, 2000, ZO_EaseOutQuadratic, 1, 0)
	elseif animationType == 'main important' then
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 100, 0, ZO_EaseOutQuadratic, 0, 1)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 100, 0, ZO_EaseOutQuadratic, 1, 1.75, PVP_SET_SCALE_FROM_SV)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 100, 200, ZO_EaseInQuadratic, 1.75, 1, PVP_SET_SCALE_FROM_SV)
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 250, hitValue > 500 and hitValue or 500, ZO_EaseInQuadratic, 1, 0, PVP_SET_SCALE_FROM_SV)
	elseif animationType == 'camp' then
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 100, 0, ZO_EaseOutQuadratic, 0, 1)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 300, 0, ZO_EaseOutQuadratic, 1, 1.6, PVP_SET_SCALE_FROM_SV)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 300, 400, ZO_EaseInQuadratic, 1.6, 1, PVP_SET_SCALE_FROM_SV)
	elseif animationType == 'attackerFrame' then
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 100, 0, ZO_EaseOutQuadratic, 0)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 200, 0, ZO_EaseOutQuadratic, self.SV.newAttackerFrameScale, self.SV.newAttackerFrameScale * 1.6, PVP_SET_SCALE_FROM_SV)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 200, 250, ZO_EaseInQuadratic, self.SV.newAttackerFrameScale * 1.6, self.SV.newAttackerFrameScale, PVP_SET_SCALE_FROM_SV)
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 1500, self.SV.newAttackerFrameDelayBeforeFadeout, ZO_EaseOutQuadratic, nil, 0)
	elseif animationType == 'fadeOut' then
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, self.SV.targetNameFrameFadeoutTime, self.SV.targetNameFrameDelayBeforeFadeout, ZO_EaseOutQuadratic, control:GetAlpha(), 0)
	else
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 50, 0, ZO_EaseOutQuadratic, 0, 1)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 150, 0, ZO_EaseOutQuadratic, 1, 1.4, PVP_SET_SCALE_FROM_SV)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 250, 250, ZO_EaseInQuadratic, 1.4, 1, PVP_SET_SCALE_FROM_SV)
		local currentAlpha = control:GetAlpha()
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 150, hitValue > 1200 and hitValue or 1200, ZO_EaseOutQuadratic, currentAlpha, 0)
	end

	timeline:SetHandler('OnStop', function()
		control:ClearAnchors()
		control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
		control:SetScale(scale)
		if animationType == 'fadeOut' then PVP_TargetNameLabel:SetText("") end
		if animationType == 'attackerFrame' then
			PVP_NewAttackerNumber:SetText("")
			PVP_NewAttackerLabel:SetText("")
		end
		if animationType == 'medal' or animationType == 'main important' or animationType == 'main piercing' or animationType == 'main stealthed' then
			control:SetAlpha(0)
		end
		if self.SV.unlocked then PVP_Main:SetAlpha(1) end
	end)

	timeline:PlayFromStart()
	return timeline
end

local function FindTargetCharInNames(playerName, isTargetFrame, unitAlliance)
	local isDeadOrResurrect
	local statusIcon = ""
	if #PVP.namesToDisplay ~= 0 then
		for _, v in ipairs(PVP.namesToDisplay) do
			if v.unitName == playerName then
				if v.isDead then
					statusIcon = PVP:GetDeathIcon(not isTargetFrame and 40 or nil)
					isDeadOrResurrect = true
				elseif v.isTarget then
					if IsActiveWorldBattleground() then
						statusIcon = PVP:GetAttackerIcon(not isTargetFrame and 55 or nil)
					else
						statusIcon = PVP:GetFightIcon(not isTargetFrame and 35 or nil, nil, unitAlliance)
					end
				elseif v.isAttacker then
					statusIcon = PVP:GetAttackerIcon(not isTargetFrame and 55 or nil)
				end
				break
			end
		end
	end

	return statusIcon, isDeadOrResurrect
end

function PVP:GetTargetChar(playerName, isTargetFrame, forceScale)
	local playerDbRecord = self.SV.playersDB[playerName]
	if not playerDbRecord then return nil end
	local userDisplayNameType = self.SV.userDisplayNameType or self.defaults.userDisplayNameType
	local accountNameFromDB = playerDbRecord.unitAccName or "@name unknown"
	local unitAlliance = playerDbRecord and playerDbRecord.unitAlliance

	local formattedName, classIcons, charName, accountName
	local KOSOrFriend = self:IsKOSOrFriend(playerName, accountNameFromDB)
	local isEmperor = self:IsEmperor(playerName, currentCampaignActiveEmperor)
	local statusIcon, isDeadOrResurrect = FindTargetCharInNames(playerName, isTargetFrame, unitAlliance)

	if self:GetValidName(GetRawUnitName('reticleover')) == playerName and IsUnitDead('reticleover') then
		statusIcon = self:GetDeathIcon(not isTargetFrame and 40 or nil)
		isDeadOrResurrect = true
	end

	local nameColor

	if isTargetFrame and (not forceScale) then
		nameColor = 'FFFFFF'
	else
		if IsActiveWorldBattleground() then
			if self.bgNames and self.bgNames[playerName] and self.bgNames[playerName] ~= 0 then
				nameColor = self:BgAllianceToHexColor(self.bgNames[playerName])
			else
				nameColor = 'FFFFFF'
			end
		else
			nameColor = self:NameToAllianceColor(playerName, isDeadOrResurrect, nil, unitAlliance)
		end
	end

	if isDeadOrResurrect then
		classIcons = self:GetFormattedClassIcon(playerName, nil, nameColor, isDeadOrResurrect, isTargetFrame,
			not isTargetFrame, nil, nil, nil, nil, playerDbRecord or "none")
		charName = self:Colorize(self:GetFormattedCharNameLink(playerName, false), nameColor)
	else
		classIcons = self:GetFormattedClassIcon(playerName, nil, nameColor, nil, true, not isTargetFrame, nil, nil, nil,
			nil, playerDbRecord or "none")
		charName = self:Colorize(self:GetFormattedCharNameLink(playerName, nil), nameColor)
	end

	if userDisplayNameType == "both" then
		accountName = self:GetFormattedAccountNameLink(accountNameFromDB, "CCCCCC")
		formattedName = classIcons .. charName .. "|r" .. accountName
	elseif userDisplayNameType == "character" then
		formattedName = classIcons .. charName
	elseif userDisplayNameType == "user" then
		accountName = self:GetFormattedAccountNameLink(accountNameFromDB, nameColor)
		formattedName = classIcons .. accountName
	end

	if isEmperor then
		formattedName = self:GetEmperorIcon(forceScale or (not isTargetFrame and 45) or nil,
			self:GetTrueAllianceColorsHex(currentCampaignActiveEmperorAlliance)) .. formattedName
	end
	-- if KOSOrFriend then
	if KOSOrFriend == "KOS" then
		formattedName = formattedName .. self:GetKOSIcon(not isTargetFrame and 45 or nil)
	elseif KOSOrFriend == "friend" then
		formattedName = formattedName .. self:GetFriendIcon(not isTargetFrame and 35 or 19)
	elseif KOSOrFriend == "cool" then
		formattedName = formattedName .. self:GetCoolIcon(not isTargetFrame and 35 or 19)
	elseif KOSOrFriend == "groupleader" then
		formattedName = formattedName .. self:GetGroupLeaderIcon(not isTargetFrame and 45 or nil)
	elseif KOSOrFriend == "group" then
		formattedName = formattedName .. self:GetGroupIcon(not isTargetFrame and 45 or nil)
	elseif KOSOrFriend == "guild" then
		formattedName = formattedName .. self:GetGuildIcon(not isTargetFrame and 35 or 19,
			playerDbRecord.unitAlliance == self.allianceOfPlayer and "40BB40" or "BB4040")
	end

	if isTargetFrame then
		formattedName = formattedName .. statusIcon
	elseif isDeadOrResurrect then
		formattedName = formattedName .. " " .. statusIcon
	else
		formattedName = statusIcon .. formattedName .. " " .. statusIcon
	end
	-- d(formattedName)
	return formattedName
end

function PVP:OnMapPing(eventCode, pingEventType, pingType, pingTag, offsetX, offsetY, isLocalPlayerOwner)
	if not self:Should3DSystemBeOn() then return end

	local playerGroupTag = GetGroupUnitTagByIndex(GetGroupIndexByUnitTag("player"))

	self.currentMapPings = self.currentMapPings or {}

	if pingEventType == PING_EVENT_ADDED then
		if self.SV.pingWaypoint and IsUnitGrouped('player') and isLocalPlayerOwner and pingType == MAP_PIN_TYPE_PLAYER_WAYPOINT then
			self.suppressTest = { playerGroupTag = playerGroupTag, currentTime = GetFrameTimeMilliseconds() }
			if not self.LMP:IsPingSuppressed(MAP_PIN_TYPE_PING, self.suppressTest.playerGroupTag) then
				self.LMP:SuppressPing(MAP_PIN_TYPE_PING, self.suppressTest.playerGroupTag)
			end
			self.LMP:SetMapPing(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, offsetX, offsetY)
			self.pingSuppressionStarted = zo_callLater(function() self.pingSuppressionStarted = nil end, 25)
		end
		if not (self.suppressTest and isLocalPlayerOwner and pingType == MAP_PIN_TYPE_PING) then
			local pingObject
			if (pingType == MAP_PIN_TYPE_PLAYER_WAYPOINT or pingType == MAP_PIN_TYPE_RALLY_POINT) and self.currentTooltip then
				pingObject = self.currentTooltip
				if pingType == MAP_PIN_TYPE_PLAYER_WAYPOINT then
					self.currentTooltip.params.hasWaypoint = true
				else
					self.currentTooltip.params.hasRally = true
				end
			end

			insert(self.currentMapPings,
				{
					pinType = pingType,
					pingTag = pingTag,
					targetX = offsetX,
					targetY = offsetY,
					isLocalPlayerOwner = isLocalPlayerOwner,
					pingObject = pingObject
				})
		end
	elseif pingEventType == PING_EVENT_REMOVED then
		if self.suppressTest and not self.pingSuppressionStarted and pingType == MAP_PIN_TYPE_PING and isLocalPlayerOwner then
			if self.LMP:IsPingSuppressed(MAP_PIN_TYPE_PING, self.suppressTest.playerGroupTag) then
				self.LMP:UnsuppressPing(MAP_PIN_TYPE_PING, self.suppressTest.playerGroupTag)
			end
			self.suppressTest = nil
		end

		for k, v in ipairs(self.currentMapPings) do
			if v.pinType == pingType and v.pingTag == pingTag and v.isLocalPlayerOwner == isLocalPlayerOwner then
				if v.pingObject then
					v.pingObject.params.hasWaypoint = nil
					v.pingObject.params.hasRally = nil
				end
				remove(self.currentMapPings, k)
				break
			end
		end
	end
end

local function SetupDeathButtons()
	HUD_SCENE:AddFragment(PVP_DEATH_FRAGMENT)
	HUD_UI_SCENE:AddFragment(PVP_DEATH_FRAGMENT)
	PVP_DEATH_FRAGMENT:Show()

	local color

	if PVP.allianceOfPlayer == 1 then
		color = PVP_BRIGHT_AD_COLOR
	elseif PVP.allianceOfPlayer == 2 then
		color = PVP_BRIGHT_EP_COLOR
	elseif PVP.allianceOfPlayer == 3 then
		color = PVP_BRIGHT_DC_COLOR
	end

	local campIndex = PVP:FindNearbyCampToRespawn(true)

	if campIndex then
		PVP_Death_ButtonsButton1:SetKeybind('PVP_ALERTS_RESPAWN_AT_CAMP')
		PVP_Death_ButtonsButton1NameLabel:SetText('Respawn at ' .. PVP:Colorize('Forward Camp', color))
		PVP_Death_ButtonsButton1:SetCallback(function()
			PVP:RespawnAtNearbyCamp()
		end)
	else
		PVP_Death_ButtonsButton1:SetKeybind(nil)
		PVP_Death_ButtonsButton1NameLabel:SetText('')
		PVP_Death_ButtonsButton1:SetCallback(nil)
	end
	local keepId = PVP:FindNearbyKeepToRespawn()
	if keepId then
		local keepName = GetKeepName(keepId)
		if campIndex then
			PVP_Death_ButtonsButton2:SetKeybind('PVP_ALERTS_RESPAWN_AT_KEEP')
			PVP_Death_ButtonsButton2NameLabel:SetText('Respawn at ' .. PVP:Colorize(keepName, color))
			PVP_Death_ButtonsButton2:SetCallback(function()
				PVP:RespawnAtNearbyKeep()
			end)
		else
			PVP_Death_ButtonsButton1:SetKeybind('PVP_ALERTS_RESPAWN_AT_CAMP')
			PVP_Death_ButtonsButton1NameLabel:SetText('Respawn at ' .. PVP:Colorize(keepName, color))
			PVP_Death_ButtonsButton1:SetCallback(function()
				PVP:RespawnAtNearbyKeep()
			end)
			PVP_Death_ButtonsButton2:SetKeybind(nil)
			PVP_Death_ButtonsButton2NameLabel:SetText('')
			PVP_Death_ButtonsButton2:SetCallback(nil)
		end
	else
		if not campIndex then
			PVP_Death_ButtonsButton1:SetKeybind(nil)
			PVP_Death_ButtonsButton1NameLabel:SetText('')
			PVP_Death_ButtonsButton1:SetCallback(nil)
		end
		PVP_Death_ButtonsButton2:SetKeybind(nil)
		PVP_Death_ButtonsButton2NameLabel:SetText('')
		PVP_Death_ButtonsButton2:SetCallback(nil)
	end
end

function PVP:ProcessKeepTicks(difference, isOffensiveTick, keepId)
	local text
	local currentTime = GetFrameTimeMilliseconds()
	local tickType = isOffensiveTick and " offensive tick" or " defensive tick"

	tickType = self:Colorize(tickType, "F878F8")

	--local keepId = self:FindAVAIds(GetPlayerLocationName(), true)

	if not keepId or keepId == 0 then
		keepId = self:FindAVAIds(GetPlayerLocationName(), true)
		if not keepId or keepId == 0 then
			return
		end
	end

	text = zo_iconFormat(self:GetObjectiveIcon(GetKeepType(keepId), GetKeepAlliance(keepId, 1)), 27, 27) ..
		self:Colorize(GetKeepName(keepId), self:AllianceToColor(GetKeepAlliance(keepId, 1)))

	if not text or text == "" then return end

	text = self:Colorize('+++ You got', "F878F8") .. text .. tickType .. self:Colorize(' for ', "F878F8")

	text = self:Colorize(text, "F878F8") ..
		self:Colorize(zo_iconFormat(PVP_AP, 24, 24) .. tostring(difference), "00cc00") .. self:Colorize(' +++', "F878F8")

	if self.killFeedDelay == 0 then
		PVP_KillFeed_Text:Clear()
	end
	if self.killFeedRatioDelay == 0 then
		self:KillFeedRatio_Reset()
	end
	self.killFeedDelay = currentTime

	if self.SV.showKillFeedFrame then PVP_KillFeed_Text:AddMessage(text) end

	if self.SV.showKillFeedChat and self.ChatContainer and self.ChatWindow then
		self.ChatContainer:AddMessageToWindow(self.ChatWindow, self:Colorize("[" .. GetTimeString() .. "] ", "A0A0A0") ..
			text)
	end

	if self.SV.showKillFeedInMainChat then
		chat:Print(self:Colorize("[" .. GetTimeString() .. "]", "A0A0A0") .. text)
	end

	if self.SV.playBattleReportSound then
		self:PlayLoudSound('BOOK_COLLECTION_COMPLETED')
	end
end

function PVP:OnAlliancePointUpdate(eventCode, alliancePoints, playSound, difference, reason, reasonSupplementaryInfo)
	-- if self.killFeedRatio and reason == CURRENCY_CHANGE_REASON_KILL then
	-- self.killFeedRatio.earnedAP = self.killFeedRatio.earnedAP + difference
	-- end

	-- local isTick = reason == CURRENCY_CHANGE_REASON_KEEP_REWARD and IsInCyrodiil()
	-- local isKB = reason == CURRENCY_CHANGE_REASON_KILL and not IsActiveWorldBattleground()


	-- if not isTick and not isKB then return end

	local currentTime = GetFrameTimeMilliseconds()

	if reason == CURRENCY_CHANGE_REASON_KILL then
		if self.killFeedRatio then
			self.killFeedRatio.earnedAP = self.killFeedRatio.earnedAP + difference
		end
		if not IsActiveWorldBattleground() then
			self.killingBlowsInfo = {
				message = self:Colorize(" " .. zo_iconFormat(PVP_AP, 24, 24) .. tostring(difference), "00cc00"),
				timestamp = currentTime
			}
		end
	elseif IsInCyrodiil() then
		if reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD then
			self:ProcessKeepTicks(difference, true, reasonSupplementaryInfo)
		elseif reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD then
			self:ProcessKeepTicks(difference, false, reasonSupplementaryInfo)
		end
	end

	-- if isTick then
	-- PVP.keepTickPending = difference

	-- zo_callLater(function()
	-- if PVP.keepTickPending then
	-- PVP:ProcessKeepTicks(PVP.keepTickPending, false)
	-- PVP.keepTickPending = nil
	-- end
	-- end, 100)

	-- else

	-- end
end

function PVP:OnMedalAwarded(eventCode, medalId, medalName, medalIcon, medalPoints)
	if not self.SV.showMedalsFrame or self.SV.unlocked then return end
	local alliance = GetUnitBattlegroundTeam('player')

	local medalCount = GetScoreboardEntryNumEarnedMedalsById(GetScoreboardLocalPlayerEntryIndex(), medalId) + 1

	if medalCount > 1 then
		PVP_MedalsScore:SetText('x' .. tostring(medalCount))
	else
		PVP_MedalsScore:SetText('')
	end

	PVP_MedalsIcon:SetTexture(medalIcon)

	PVP_MedalsName:SetText(medalName)
	local x, y = PVP_Medals:GetDimensions()

	PVP_Medals:SetHidden(false)
	if self.medalAnimation and self.medalAnimation:IsPlaying() then self.medalAnimation:Stop() end
	self.medalAnimation = self:StartAnimation(PVP_Medals, 'medal')
	PVP_PlaySparkleAnimation(PVP_Medals)
	PlaySound(SOUNDS.MARKET_CROWN_GEMS_SPENT)
end

function PVP:OnOff()
	local function OnWorldMapChangedCallback()
		PVP:OnWorldMapChangedCallback()
	end

	local function ScoreboardFragmentCallback(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			PVP.bgScoreboard.list:RefreshData()
		end
	end

	local function OnDeathFragmentStateChange(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			local _, _, _, _, _, isAVADeath = GetDeathInfo()
			if isAVADeath then
				SetupDeathButtons()
				PVP_Death_Buttons:SetHandler("OnUpdate", function() SetupDeathButtons() end)
			else
				PVP_Death_ButtonsButton1:SetCallback(nil)
				PVP_Death_ButtonsButton2:SetCallback(nil)
				PVP_Death_Buttons:SetHandler("OnUpdate", nil)
				HUD_SCENE:RemoveFragment(PVP_DEATH_FRAGMENT)
				HUD_UI_SCENE:RemoveFragment(PVP_DEATH_FRAGMENT)
				PVP_DEATH_FRAGMENT:Hide()
			end
		elseif newState == SCENE_FRAGMENT_HIDING then
			PVP_Death_ButtonsButton1:SetCallback(nil)
			PVP_Death_ButtonsButton2:SetCallback(nil)
			PVP_Death_Buttons:SetHandler("OnUpdate", nil)
			HUD_SCENE:RemoveFragment(PVP_DEATH_FRAGMENT)
			HUD_UI_SCENE:RemoveFragment(PVP_DEATH_FRAGMENT)
			PVP_DEATH_FRAGMENT:Hide()
		end
	end

	SLASH_COMMANDS["/who"] = function(name) PVP.Who(self, name, true) end
	SLASH_COMMANDS["/pvpnote"] = function(noteString) PVP.managePlayerNote(self, noteString) end
	--SLASH_COMMANDS["/mmr"] = function(update) PVP.ListMMR(self, flag) end
	if self.SV.enabled and self:IsInPVPZone() then
		if not self.addonEnabled then
			self.addonEnabled = true
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function(...) self:OnCombat(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PVP_KILL_FEED_DEATH, function(...) self:OnKillfeed(...) end)
			EVENT_MANAGER:RegisterForUpdate(self.name .. "_KillFeedBufferUpdate", 250, function() self:ProcessKillFeedBuffer() end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED, function(...) self:OnEffect(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_PLAYER_CHANGED, self.OnTargetChanged)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED, self.OnTargetChanged)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OBJECTIVE_CONTROL_STATE, function(...) self:OnControlState(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CAPTURE_AREA_STATUS, function(...) self:OnCaptureStatus(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_KEEP_ALLIANCE_OWNER_CHANGED,
				function(eventCode, keepId, battlegroundContext, owningAlliance, oldOwningAlliance)
					if PVP:IsValidBattlegroundContext(battlegroundContext) then
						PVP:OnOwnerOrUnderAttackChanged(GetPlayerLocationName(), keepId, true)
					end
				end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_KEEP_UNDER_ATTACK_CHANGED,
				function(eventCode, keepId, battlegroundContext, underAttack)
					if PVP:IsValidBattlegroundContext(battlegroundContext) then
						self:OnOwnerOrUnderAttackChanged(GetPlayerLocationName(), keepId, not underAttack)
					end
				end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ZONE_CHANGED, function(...) self:OnZoneChange(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_DEACTIVATED, function(...) self:OnDeactivated(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAP_PING, function(...) self:OnMapPing(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MEDAL_AWARDED, function(...) self:OnMedalAwarded(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ALLIANCE_POINT_UPDATE, function(...) self:OnAlliancePointUpdate(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_SLOT_ABILITY_USED, function(...) self:OnAbilityUsed(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LEADER_UPDATE, function() PVP:InitControls() end)
			EVENT_MANAGER:RegisterForUpdate(self.name, 250, PVP.OnUpdate)
			DEATH_FRAGMENT:RegisterCallback("StateChange", OnDeathFragmentStateChange)
			PVP_SCOREBOARD_FRAGMENT:RegisterCallback("StateChange", ScoreboardFragmentCallback)
			CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnWorldMapChangedCallback)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CAMPAIGN_EMPEROR_CHANGED, function(...) self:UpdateCampaignEmperor(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ARTIFACT_CONTROL_STATE, function(...) self:UpdateActiveArtifactInfo(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED, function(...) self:UpdateActiveDaedricArtifactInfo(...) end)
			-- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BATTLEGROUND_STATE_CHANGED, function(...) self:OnBattlegroundStateChanged(...) end)
			-- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BATTLEGROUND_MMR_LOSS_REDUCED, function(...) self:OnBattlegroundMMRLossReduced(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_ID_CHANGED, function(...) self:UpdateGuildId(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_SELF_JOINED_GUILD, function(...) self:JoinedNewGuild(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_SELF_LEFT_GUILD, function(...) self:LeftGuild(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_MEMBER_ADDED, function(...) self:GuildMemberJoined(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_MEMBER_REMOVED, function(...) self:GuildMemberLeft(...) end)
			--EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_MEMBER_CHARACTER_UPDATED, function() PVP:PopulateGuildmateDatabase() end)
		end
		self:InitEnabledAddon()
	else
		if self.addonEnabled then
			self.addonEnabled = nil
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PVP_KILL_FEED_DEATH)
			EVENT_MANAGER:UnregisterForUpdate(self.name .. "_KillFeedBufferUpdate")
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_EFFECT_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_RETICLE_TARGET_PLAYER_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ZONE_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_OBJECTIVE_CONTROL_STATE)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_CAPTURE_AREA_STATUS)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_KEEP_ALLIANCE_OWNER_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_KEEP_UNDER_ATTACK_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_MAP_PING)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_MEDAL_AWARDED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ALLIANCE_POINT_UPDATE)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTION_SLOT_ABILITY_USED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_LEADER_UPDATE)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_CAMPAIGN_EMPEROR_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ARTIFACT_CONTROL_STATE)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED)
			-- EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_BATTLEGROUND_STATE_CHANGED)
			-- EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_BATTLEGROUND_MMR_LOSS_REDUCED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_ID_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_SELF_JOINED_GUILD)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_SELF_LEFT_GUILD)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_MEMBER_ADDED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_MEMBER_REMOVED)
			--EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_MEMBER_CHARACTER_UPDATED)
			EVENT_MANAGER:UnregisterForUpdate(self.name)
			DEATH_FRAGMENT:UnregisterCallback("StateChange", OnDeathFragmentStateChange)
			PVP_SCOREBOARD_FRAGMENT:UnregisterCallback("StateChange", ScoreboardFragmentCallback)
			CALLBACK_MANAGER:UnregisterCallback("OnWorldMapChanged", OnWorldMapChangedCallback)
		end
		self.delayedInitControls = true
		self:InitControls()
		self:FullReset3DIcons()
		self:ProcessCachedPlayerNameChanges()
		self:InitNetworking()

		if not (self.SV.enabled and self.SV.unlocked) then
			PVP_TargetName:SetAlpha(0)
			self:ResetMainFrame()
			PVP_Counter:SetHidden(true)
			PVP_Names:SetHidden(true)
			PVP_KOS:SetHidden(true)
			PVP_KillFeed:SetHidden(true)
			PVP_Capture:SetHidden(true)
			PVP_ForwardCamp:SetHidden(true)
			PVP_TUG:SetHidden(true)
		end
	end
end

function PVP:FullReset()
	if self.isPlaying then self.isPlaying:Stop() end
	local currentCampaignId = GetCurrentCampaignId()

	self.bgScoreBoardFirstRunDone = false
	self.piercingDelay = false
	self.bgScoreBoardData = {}
	self.totalPlayers = {}
	self.npcExclude = {}
	self.playerSpec = {}
	self.miscAbilities = {}
	self.playerNames = {}
	self.idToName = {}
	self.playerAlliance = {}
	self.currentlyDead = {}
	self.namesToDisplay = {}

	self.localPlayers = {}
	self.potentialAllies = {}

	self.majorAttackNotficiationLockout = 0
	self.minorAttackNotficiationLockout = 0
	self.friendSoundDelay = 0
	self.kosSoundDelay = 0
	self.reportTimer = 0
	self.killFeedDelay = 0
	self.killFeedRatioDelay = 0
	self.ccImmunity = {}

	if currentCampaignId ~= self.currentCampaignId then
		self.activeScrolls = {}
		self.activeDaedricArtifact = nil
	end
	self.currentCampaignId = currentCampaignId

	self:KillFeedRatio_Reset()
	self:InitControls()

	if self.SV.showKOSFrame then self:RefreshLocalPlayers() end
end

local function FindAlliancePlayerInNames(playerName, unitAlliance)
	local namesToDisplay = PVP.namesToDisplay
	local numNames = #namesToDisplay
	local isResurrect, isDead
	local statusIcon = ""
	if numNames ~= 0 then
		for i = 1, numNames do
			local name = namesToDisplay[i]
			if name.unitName == playerName then
				if name.isResurrect then
					statusIcon = PVP:GetResurrectIcon()
					isResurrect = true
				elseif name.isDead then
					statusIcon = PVP:GetDeathIcon()
					isDead = true
				elseif name.isTarget then
					statusIcon = PVP:GetFightIcon(nil, nil, unitAlliance)
				elseif name.isAttacker then
					statusIcon = PVP:GetAttackerIcon()
				end
				break
			end
		end
	end
	return statusIcon, isResurrect, isDead
end

local function ConvertAlliancePlayerNames()
	local namesToDisplay = PVP.namesToDisplay
	local numNames = #namesToDisplay
	local outputArray = {}
	if numNames ~= 0 then
		for i = 1, numNames do
			local name = namesToDisplay[i]
			outputArray[name.unitName] = {
				isResurrect = name.isResurrect,
				isDead = name.isDead,
				isTarget = name.isTarget,
				isAttacker = name.isAttacker
			}
		end
	end
	return outputArray
end

local function ArrayConversion(inputArray, indexArray, mainArray)
	local outputArray = {}
	local num = #inputArray
	for i = 1, num do
		local newValue = mainArray[indexArray[inputArray[i]]]
		outputArray[i] = newValue
	end
	return outputArray
end

local function SummaryConversion(inputArray, summaryType)
	local num = #inputArray
	local numberInCategory = PVP:Colorize(tostring(num), 'FFFF00')
	local summary
	if summaryType == 'group' then
		summary = ' --- Group (' .. numberInCategory .. ') ---'
	elseif summaryType == 'friends' then
		summary = ' --- Friends (' .. numberInCategory .. ') ---'
	elseif summaryType == 'kos' then
		summary = ' --- KOS (' .. numberInCategory .. ') ---'
	elseif summaryType == 'others' then
		summary = ' --- Others (' .. numberInCategory .. ') ---'
	end

	local outputArray = {}
	outputArray[1] = summary
	for i = 1, num do
		outputArray[i + 1] = inputArray[i]
	end
	return outputArray
end

function PVP:PopulateFromBGScoreboard()
	local numberAD, numberDC, numberEP = 0, 0, 0
	local tableAD, tableDC, tableEP, foundNames = {}, {}, {}, {}
	local tableNameToIndexAD, tableNameToIndexDC, tableNameToIndexEP = {}, {}, {}
	local groupLeaderTable, groupMembersTable, kosTableAD, kosTableDC, kosTableEP, friendsTableAD, friendsTableDC, friendsTableEP, othersTableAD, othersTableDC, othersTableEP =
		{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}

		-- {class = 3, name = "Test^Fx" , kills = 30, deaths = 20, assists = 100, damage = 10000000, healing = 3000000, points = 800, alliance = 3},
	self.scoreboardListData = {}

	self.bgNames = self.bgNames or {}
	self.bgScoreBoardData = self.bgScoreBoardData or {}

	local battlegroundId = GetCurrentBattlegroundId()
	local battlegrounRound = GetCurrentBattlegroundRoundIndex()
	local battlegroundGameType = GetBattlegroundGameType(battlegroundId, battlegrounRound)
	
	local battlegroundLeaderboardTypes = {
		[BATTLEGROUND_GAME_TYPE_CAPTURE_THE_FLAG] = BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES,
		[BATTLEGROUND_GAME_TYPE_DEATHMATCH] = BATTLEGROUND_LEADERBOARD_TYPE_DEATHMATCH,
		[BATTLEGROUND_GAME_TYPE_KING_OF_THE_HILL] = BATTLEGROUND_LEADERBOARD_TYPE_LAND_GRAB,
		[BATTLEGROUND_GAME_TYPE_DOMINATION] = BATTLEGROUND_LEADERBOARD_TYPE_LAND_GRAB,
		[BATTLEGROUND_GAME_TYPE_CRAZY_KING] = BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES,
		[BATTLEGROUND_GAME_TYPE_MURDERBALL] = BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES
	}	

	local battlegroundSpecialsTypes = {
		[BATTLEGROUND_GAME_TYPE_CAPTURE_THE_FLAG] = SCORE_TRACKER_TYPE_FLAG_CAPTURED,
		[BATTLEGROUND_GAME_TYPE_DEATHMATCH] = SCORE_TRACKER_TYPE_KILL_STREAK,
		[BATTLEGROUND_GAME_TYPE_KING_OF_THE_HILL] = SCORE_TRACKER_TYPE_FLAG_CAPTURED,
		[BATTLEGROUND_GAME_TYPE_DOMINATION] = SCORE_TRACKER_TYPE_FLAG_CAPTURED,
		[BATTLEGROUND_GAME_TYPE_CRAZY_KING] = SCORE_TRACKER_TYPE_FLAG_CAPTURED,
		[BATTLEGROUND_GAME_TYPE_MURDERBALL] = SCORE_TRACKER_TYPE_FLAG_CAPTURED
	}

	local battlegroundLeaderboardType = battlegroundLeaderboardTypes[battlegroundGameType]
	local battlegroundSpecialsType = battlegroundSpecialsTypes[battlegroundGameType]

	if GetNumBattlegroundLeaderboardEntries(battlegroundLeaderboardType) == 0 then
		QueryBattlegroundLeaderboardData()
	end

	local currentBgPlayers = {}
	for i = 1, GetNumScoreboardEntries(battlegrounRound) do
		local playerName, accName, bgAlliance = GetScoreboardEntryInfo(i, battlegrounRound)
		local entryClass = GetScoreboardEntryClassId(i, battlegrounRound)
		local entryKills = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_KILL, battlegrounRound)
		local entryDeaths = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_DEATH, battlegrounRound)
		local entryAssists = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_ASSISTS, battlegrounRound)
		local entryDamage = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_DAMAGE_DONE, battlegrounRound)
		local entryHealing = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_HEALING_DONE, battlegrounRound)
		local entryPoints = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_SCORE, battlegrounRound)
		local entrySpecials = GetScoreboardEntryScoreByType(i, battlegroundSpecialsType, battlegrounRound)

		local bgColor = self:BgAllianceToHexColor(bgAlliance)

		local entryRank
		if battlegroundLeaderboardType then
			for j = 1, GetNumBattlegroundLeaderboardEntries(battlegroundLeaderboardType) do
				local rank, displayName, characterName, score = GetBattlegroundLeaderboardEntryInfo(
					battlegroundLeaderboardType, j)
				if '@' .. displayName == accName then
					entryRank = rank
					break
				end
			end
		end

		local medalIdTable = {}

		local medalId = GetNextScoreboardEntryMedalId(i)

		while medalId do
			local medalCount = GetScoreboardEntryNumEarnedMedalsById(i, medalId, battlegrounRound)
			local _, _, _, medalPoints = GetMedalInfo(medalId)
			insert(medalIdTable, { medalId = medalId, medalCount = medalCount, medalPoints = medalPoints })
			-- insert(medalIdTable, {medalId = medalId, medalCount = medalCount})
			medalId = GetNextScoreboardEntryMedalId(i,battlegrounRound, medalId)
		end


		if not entryRank then entryRank = 9999 end

		insert(self.scoreboardListData, {
			class = entryClass,
			name = playerName,
			kills = entryKills,
			deaths = entryDeaths,
			assists = entryAssists,
			damage = entryDamage,
			healing = entryHealing,
			points = entryPoints,
			alliance = bgAlliance,
			rank = entryRank,
			medals = medalIdTable,
			specials = entrySpecials
		})

		local bgAccName = ZO_ShouldPreferUserId() and ZO_GetPrimaryPlayerNameFromUnitTag('player') or
			ZO_GetSecondaryPlayerNameFromUnitTag('player')

		if accName == bgAccName and self:IsMalformedName(self.playerName) then
			self.playerName = playerName
		end

		currentBgPlayers[playerName] = true

		self.bgNames[playerName] = bgAlliance

		local formattedName = self:GetFormattedClassNameLink(playerName, bgColor, nil, nil, nil, nil, entryClass)

		if not self.bgScoreBoardData[playerName] then
			self.bgScoreBoardData[playerName] = formattedName
			if self.bgScoreBoardFirstRunDone and self.SV.showJoinedPlayers then
				chat:Printf('%s joined battleground!', self.bgScoreBoardData[playerName])
			end
		end

		local KOSOrFriend = self:IsKOSOrFriend(playerName, bgAccName)
		if playerName ~= self.playerName then
			local statusIcon, isResurrect, isDead = FindAlliancePlayerInNames(playerName)

			if KOSOrFriend then
				if KOSOrFriend == "KOS" then
					formattedName = formattedName .. self:GetKOSIcon() .. statusIcon
				elseif KOSOrFriend == "friend" then
					formattedName = formattedName .. self:GetFriendIcon(19) .. statusIcon
				elseif KOSOrFriend == "cool" then
					formattedName = formattedName .. self:GetCoolIcon(19) .. statusIcon
				elseif KOSOrFriend == "groupleader" then
					formattedName = formattedName .. self:GetGroupLeaderIcon() .. statusIcon
				elseif KOSOrFriend == "group" then
					formattedName = formattedName .. self:GetGroupIcon() .. statusIcon
				elseif KOSOrFriend == "guild" then
					formattedName = formattedName .. self:GetGuildIcon() .. statusIcon
				end
			else
				formattedName = formattedName .. statusIcon
			end
		else
			formattedName = formattedName .. self:Colorize(' - YOU', 'FFFFFF')
		end

		if bgAlliance == 1 then
			numberAD = numberAD + 1
			insert(tableAD, formattedName)
			tableNameToIndexAD[playerName] = numberAD
			if KOSOrFriend == "groupleader" then
				insert(groupLeaderTable, playerName)
			elseif KOSOrFriend == "group" then
				insert(groupMembersTable, playerName)
			elseif KOSOrFriend == "KOS" then
				insert(kosTableAD, playerName)
			elseif KOSOrFriend == "friend" then
				insert(friendsTableAD, playerName)
			elseif KOSOrFriend == "cool" then
				insert(friendsTableAD, playerName)
			else
				insert(othersTableAD, playerName)
			end
		elseif bgAlliance == 2 then
			numberEP = numberEP + 1
			insert(tableEP, formattedName)
			tableNameToIndexEP[playerName] = numberEP

			if KOSOrFriend == "groupleader" then
				insert(groupLeaderTable, playerName)
			elseif KOSOrFriend == "group" then
				insert(groupMembersTable, playerName)
			elseif KOSOrFriend == "KOS" then
				insert(kosTableEP, playerName)
			elseif KOSOrFriend == "friend" then
				insert(friendsTableEP, playerName)
			elseif KOSOrFriend == "cool" then
				insert(friendsTableEP, playerName)
			else
				insert(othersTableEP, playerName)
			end
		elseif bgAlliance == 3 then
			numberDC = numberDC + 1
			insert(tableDC, formattedName)
			tableNameToIndexDC[playerName] = numberDC

			if KOSOrFriend == "groupleader" then
				insert(groupLeaderTable, playerName)
			elseif KOSOrFriend == "group" then
				insert(groupMembersTable, playerName)
			elseif KOSOrFriend == "KOS" then
				insert(kosTableDC, playerName)
			elseif KOSOrFriend == "friend" then
				insert(friendsTableDC, playerName)
			elseif KOSOrFriend == "cool" then
				insert(friendsTableDC, playerName)
			else
				insert(othersTableDC, playerName)
			end
		end
	end

	for k, v in pairs(self.bgScoreBoardData) do
		if not currentBgPlayers[k] then
			if self.SV.showJoinedPlayers then
				chat:Printf('%s left battleground!', self.bgScoreBoardData[k])
			end
			self.bgScoreBoardData[k] = nil
		end
	end
	self.bgScoreBoardFirstRunDone = true

	if self.bgScoreboard and self.bgScoreboard.list then self.bgScoreboard.list:RefreshData() end

	return numberAD, numberDC, numberEP, tableAD, tableDC, tableEP, tableNameToIndexAD, tableNameToIndexDC, tableNameToIndexEP, groupLeaderTable, groupMembersTable, kosTableAD, kosTableDC, kosTableEP, friendsTableAD, friendsTableDC, friendsTableEP, othersTableAD, othersTableDC, othersTableEP
end

function PVP:GetAllianceCountPlayers()
	local userDisplayNameType = self.SV.userDisplayNameType or self.defaults.userDisplayNameType
	local allianceOfPlayer = self.allianceOfPlayer
	local numberAD, numberDC, numberEP = 0, 0, 0
	local tableAD, tableDC, tableEP, foundNames = {}, {}, {}, {}
	local tableNameToIndexAD, tableNameToIndexDC, tableNameToIndexEP = {}, {}, {}
	local groupLeaderTable, groupMembersTable, kosTableAD, kosTableDC, kosTableEP, friendsTableAD, friendsTableDC, friendsTableEP, othersTableAD, othersTableDC, othersTableEP =
		{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}

	local currentTime = GetFrameTimeMilliseconds()

	-- local countAllianceStart = GetGameTimeMilliseconds()
	local playerAlliance = self.playerAlliance
	local idToName = self.idToName
	local playerNames = self.playerNames
	local playersDb = self.SV.playersDB

	if not IsActiveWorldBattleground() then
		local alliancePlayerNames = ConvertAlliancePlayerNames()
		for k, v in pairs(playerAlliance) do
			local playerName = idToName[k]
			local alliancePlayerNameData = alliancePlayerNames[playerName] or {}
			local playerDbRecord = playersDb[playerName] or {}
			local unitAccName = playerDbRecord.unitAccName
			local unitClass = playerDbRecord.unitClass
			local unitAlliance = playerDbRecord.unitAlliance
			local unitAvARank = playerDbRecord.unitAvARank
			local KOSOrFriend = self:IsKOSOrFriend(playerName, unitAccName)
			local isResurrect = alliancePlayerNameData.isResurrect or false
			local isDead = alliancePlayerNameData.isDead or false
			local isTarget = alliancePlayerNameData.isTarget or false
			local isAttacker = alliancePlayerNameData.isAttacker or false
			local statusIcon = isResurrect and self:GetResurrectIcon() or isDead and self:GetDeathIcon() or isTarget and self:GetFightIcon(nil, nil, unitAlliance) or (isAttacker and self:GetAttackerIcon() or "")

			local allianceColor, classIcons

			if isDead or isResurrect then
				allianceColor = self:GetTimeFadedColor(self:AllianceToColor(unitAlliance, true), k,
					currentTime)
				classIcons = self:GetFormattedClassIcon(playerName, nil, allianceColor, true, nil, k,
					unitClass, k, currentTime, unitAvARank, playerDbRecord or "none")
			else
				allianceColor = self:GetTimeFadedColor(self:AllianceToColor(unitAlliance, false), k,
					currentTime)
				classIcons = self:GetFormattedClassIcon(playerName, nil, allianceColor, false, nil, nil,
					unitClass, k, currentTime, unitAvARank, playerDbRecord or "none")
			end

			local formattedName = classIcons .. (userDisplayNameType == "character" and
				(self:Colorize(self:GetFormattedName(playerName) or "unknown player", allianceColor)) or
				(userDisplayNameType == "user" and self:Colorize(playerDbRecord and unitAccName or self:GetFormattedName(playerName) or "unknown player", allianceColor) or
					(userDisplayNameType == "both" and (self:Colorize(self:GetFormattedName(playerName), allianceColor) .. (unitAccName or "")) or "unknown player")))

			if KOSOrFriend then
				if KOSOrFriend == "KOS" then
					formattedName = formattedName .. self:GetKOSIcon() .. statusIcon
				elseif KOSOrFriend == "friend" then
					formattedName = formattedName .. self:GetFriendIcon(19) .. statusIcon
				elseif KOSOrFriend == "cool" then
					formattedName = formattedName .. self:GetCoolIcon(19) .. statusIcon
				elseif KOSOrFriend == "groupleader" then
					formattedName = formattedName .. self:GetGroupLeaderIcon() .. statusIcon
				elseif KOSOrFriend == "group" then
					formattedName = formattedName .. self:GetGroupIcon() .. statusIcon
				elseif KOSOrFriend == "guild" then
					formattedName = formattedName .. self:GetGuildIcon(19) .. statusIcon
				end
			else
				formattedName = formattedName .. statusIcon
			end

			if v == 1 then
				numberAD = numberAD + 1
				insert(tableAD, formattedName)
				tableNameToIndexAD[playerName] = numberAD
				if KOSOrFriend == "groupleader" then
					insert(groupLeaderTable, playerName)
				elseif KOSOrFriend == "group" then
					insert(groupMembersTable, playerName)
				elseif KOSOrFriend == "KOS" then
					insert(kosTableAD, playerName)
				elseif KOSOrFriend == "friend" then
					insert(friendsTableAD, playerName)
				elseif KOSOrFriend == "cool" then
					insert(friendsTableAD, playerName)
				else
					insert(othersTableAD, playerName)
				end
			elseif v == 2 then
				numberEP = numberEP + 1
				insert(tableEP, formattedName)
				tableNameToIndexEP[playerName] = numberEP

				if KOSOrFriend == "groupleader" then
					insert(groupLeaderTable, playerName)
				elseif KOSOrFriend == "group" then
					insert(groupMembersTable, playerName)
				elseif KOSOrFriend == "KOS" then
					insert(kosTableEP, playerName)
				elseif KOSOrFriend == "friend" then
					insert(friendsTableEP, playerName)
				elseif KOSOrFriend == "cool" then
					insert(friendsTableEP, playerName)
				else
					insert(othersTableEP, playerName)
				end
			elseif v == 3 then
				numberDC = numberDC + 1
				insert(tableDC, formattedName)
				tableNameToIndexDC[playerName] = numberDC

				if KOSOrFriend == "groupleader" then
					insert(groupLeaderTable, playerName)
				elseif KOSOrFriend == "group" then
					insert(groupMembersTable, playerName)
				elseif KOSOrFriend == "KOS" then
					insert(kosTableDC, playerName)
				elseif KOSOrFriend == "friend" then
					insert(friendsTableDC, playerName)
				elseif KOSOrFriend == "cool" then
					insert(friendsTableDC, playerName)
				else
					insert(othersTableDC, playerName)
				end
			end
			foundNames[playerName] = true
		end

		for k, _ in pairs(playerNames) do
			if not foundNames[k] then
				local playerName = k
				local alliancePlayerNameData = alliancePlayerNames[playerName] or {}
				local playerDbRecord = playersDb[playerName] or {}
				local unitAccName = playerDbRecord.unitAccName
				local unitAlliance = playerDbRecord.unitAlliance
				local formattedName
				local KOSOrFriend = self:IsKOSOrFriend(playerName, unitAccName)
				local isResurrect = alliancePlayerNameData.isResurrect or false
				local isDead = alliancePlayerNameData.isDead or false
				local isTarget = alliancePlayerNameData.isTarget or false
				local isAttacker = alliancePlayerNameData.isAttacker or false
				local statusIcon = isResurrect and self:GetResurrectIcon() or isDead and self:GetDeathIcon() or isTarget and self:GetFightIcon(nil, nil, unitAlliance) or (isAttacker and self:GetAttackerIcon() or "")
	
				if (not isDead) and (not isResurrect) then
					if statusIcon == "" then
						statusIcon = self:GetEyeIcon()
					end

					-- if isDead or isResurrect then
					-- formattedName = self:GetFormattedClassNameLink(playerName, self:NameToAllianceColor(playerName, true), false, true)
					-- else
					formattedName = self:GetFormattedClassNameLink(playerName,
						self:NameToAllianceColor(playerName, false, nil, unitAlliance))
					-- end

					if KOSOrFriend then
						if KOSOrFriend == "KOS" then
							formattedName = formattedName .. self:GetKOSIcon() .. statusIcon
						elseif KOSOrFriend == "friend" then
							formattedName = formattedName .. self:GetFriendIcon(19) .. statusIcon
						elseif KOSOrFriend == "cool" then
							formattedName = formattedName .. self:GetCoolIcon(19) .. statusIcon
						elseif KOSOrFriend == "groupleader" then
							formattedName = formattedName .. self:GetGroupLeaderIcon() .. statusIcon
						elseif KOSOrFriend == "group" then
							formattedName = formattedName .. self:GetGroupIcon() .. statusIcon
						elseif KOSOrFriend == "guild" then
							formattedName = formattedName .. self:GetGuildIcon(19) .. statusIcon
						end
					else
						formattedName = formattedName .. statusIcon
					end


					if unitAlliance == 1 then
						numberAD = numberAD + 1
						insert(tableAD, formattedName)
						tableNameToIndexAD[playerName] = numberAD

						if KOSOrFriend == "groupleader" then
							insert(groupLeaderTable, playerName)
						elseif KOSOrFriend == "group" then
							insert(groupMembersTable, playerName)
						elseif KOSOrFriend == "KOS" then
							insert(kosTableAD, playerName)
						elseif KOSOrFriend == "friend" then
							insert(friendsTableAD, playerName)
						elseif KOSOrFriend == "cool" then
							insert(friendsTableAD, playerName)
						else
							insert(othersTableAD, playerName)
						end
					elseif unitAlliance == 2 then
						numberEP = numberEP + 1
						insert(tableEP, formattedName)
						tableNameToIndexEP[playerName] = numberEP
						if KOSOrFriend == "groupleader" then
							insert(groupLeaderTable, playerName)
						elseif KOSOrFriend == "group" then
							insert(groupMembersTable, playerName)
						elseif KOSOrFriend == "KOS" then
							insert(kosTableEP, playerName)
						elseif KOSOrFriend == "friend" then
							insert(friendsTableEP, playerName)
						elseif KOSOrFriend == "cool" then
							insert(friendsTableEP, playerName)
						else
							insert(othersTableEP, playerName)
						end
					elseif unitAlliance == 3 then
						numberDC = numberDC + 1
						insert(tableDC, formattedName)
						tableNameToIndexDC[playerName] = numberDC
						if KOSOrFriend == "groupleader" then
							insert(groupLeaderTable, playerName)
						elseif KOSOrFriend == "group" then
							insert(groupMembersTable, playerName)
						elseif KOSOrFriend == "KOS" then
							insert(kosTableDC, playerName)
						elseif KOSOrFriend == "friend" then
							insert(friendsTableDC, playerName)
						elseif KOSOrFriend == "cool" then
							insert(friendsTableDC, playerName)
						else
							insert(othersTableDC, playerName)
						end
					end
				end
			end
		end
	else
		numberAD, numberDC, numberEP, tableAD, tableDC, tableEP, tableNameToIndexAD, tableNameToIndexDC, 
		tableNameToIndexEP, groupLeaderTable, groupMembersTable, kosTableAD, kosTableDC, kosTableEP, friendsTableAD, 
		friendsTableDC, friendsTableEP, othersTableAD, othersTableDC, othersTableEP = self:PopulateFromBGScoreboard()
	end


	if #groupMembersTable > 1 then sort(groupMembersTable) end
	if #kosTableAD > 1 then sort(kosTableAD) end
	if #kosTableDC > 1 then sort(kosTableDC) end
	if #kosTableEP > 1 then sort(kosTableEP) end
	if #friendsTableAD > 1 then sort(friendsTableAD) end
	if #friendsTableDC > 1 then sort(friendsTableDC) end
	if #friendsTableEP > 1 then sort(friendsTableEP) end

	if #othersTableAD > 1 then sort(othersTableAD) end
	if #othersTableDC > 1 then sort(othersTableDC) end
	if #othersTableEP > 1 then sort(othersTableEP) end

	local onlyOthersAD, onlyOthersDC, onlyOthersEP = true, true, true

	if allianceOfPlayer == 1 then
		groupLeaderTable = ArrayConversion(groupLeaderTable, tableNameToIndexAD, tableAD)
		groupMembersTable = ArrayConversion(groupMembersTable, tableNameToIndexAD, tableAD)

		if #groupLeaderTable ~= 0 or #groupMembersTable ~= 0 then onlyOthersAD = false end
	elseif allianceOfPlayer == 3 then
		groupLeaderTable = ArrayConversion(groupLeaderTable, tableNameToIndexDC, tableDC)
		groupMembersTable = ArrayConversion(groupMembersTable, tableNameToIndexDC, tableDC)

		if #groupLeaderTable ~= 0 or #groupMembersTable ~= 0 then onlyOthersDC = false end
	elseif allianceOfPlayer == 2 then
		groupLeaderTable = ArrayConversion(groupLeaderTable, tableNameToIndexEP, tableEP)
		groupMembersTable = ArrayConversion(groupMembersTable, tableNameToIndexEP, tableEP)

		if #groupLeaderTable ~= 0 or #groupMembersTable ~= 0 then onlyOthersEP = false end
	end


	kosTableAD = ArrayConversion(kosTableAD, tableNameToIndexAD, tableAD)
	kosTableDC = ArrayConversion(kosTableDC, tableNameToIndexDC, tableDC)
	kosTableEP = ArrayConversion(kosTableEP, tableNameToIndexEP, tableEP)
	friendsTableAD = ArrayConversion(friendsTableAD, tableNameToIndexAD, tableAD)
	friendsTableDC = ArrayConversion(friendsTableDC, tableNameToIndexDC, tableDC)
	friendsTableEP = ArrayConversion(friendsTableEP, tableNameToIndexEP, tableEP)
	othersTableAD = ArrayConversion(othersTableAD, tableNameToIndexAD, tableAD)
	othersTableDC = ArrayConversion(othersTableDC, tableNameToIndexDC, tableDC)
	othersTableEP = ArrayConversion(othersTableEP, tableNameToIndexEP, tableEP)

	if #groupLeaderTable ~= 0 then groupMembersTable = PVP:TableConcat(groupLeaderTable, groupMembersTable) end

	if #groupMembersTable ~= 0 then groupMembersTable = SummaryConversion(groupMembersTable, 'group') end

	if #kosTableAD ~= 0 then kosTableAD = SummaryConversion(kosTableAD, 'kos') end
	if #kosTableDC ~= 0 then kosTableDC = SummaryConversion(kosTableDC, 'kos') end
	if #kosTableEP ~= 0 then kosTableEP = SummaryConversion(kosTableEP, 'kos') end

	if #friendsTableAD ~= 0 then friendsTableAD = SummaryConversion(friendsTableAD, 'friends') end
	if #friendsTableDC ~= 0 then friendsTableDC = SummaryConversion(friendsTableDC, 'friends') end
	if #friendsTableEP ~= 0 then friendsTableEP = SummaryConversion(friendsTableEP, 'friends') end

	if #kosTableAD ~= 0 or #friendsTableAD ~= 0 then onlyOthersAD = false end
	if #kosTableDC ~= 0 or #friendsTableDC ~= 0 then onlyOthersDC = false end
	if #kosTableEP ~= 0 or #friendsTableEP ~= 0 then onlyOthersEP = false end


	if #othersTableAD ~= 0 and not onlyOthersAD then othersTableAD = SummaryConversion(othersTableAD, 'others') end
	if #othersTableDC ~= 0 and not onlyOthersDC then othersTableDC = SummaryConversion(othersTableDC, 'others') end
	if #othersTableEP ~= 0 and not onlyOthersEP then othersTableEP = SummaryConversion(othersTableEP, 'others') end


	tableAD, tableDC, tableEP = {}, {}, {}


	tableAD = self:TableConcat(tableAD, friendsTableAD)
	tableAD = self:TableConcat(tableAD, kosTableAD)
	tableAD = self:TableConcat(tableAD, othersTableAD)

	tableDC = self:TableConcat(tableDC, friendsTableDC)
	tableDC = self:TableConcat(tableDC, kosTableDC)
	tableDC = self:TableConcat(tableDC, othersTableDC)

	tableEP = self:TableConcat(tableEP, friendsTableEP)
	tableEP = self:TableConcat(tableEP, kosTableEP)
	tableEP = self:TableConcat(tableEP, othersTableEP)

	if allianceOfPlayer == 1 then
		tableAD = self:TableConcat(groupMembersTable, tableAD)
	elseif allianceOfPlayer == 3 then
		tableDC = self:TableConcat(groupMembersTable, tableDC)
	elseif allianceOfPlayer == 2 then
		tableEP = self:TableConcat(groupMembersTable, tableEP)
	end
	-- d('Damn table time: '..tostring(GetGameTimeMilliseconds() - countAllianceStart)..'ms')
	return numberAD, numberDC, numberEP, tableAD, tableDC, tableEP
end

function PVP:BuildReticleName(unitName, unitAlliance, isDead, isAttacker, isTarget, isResurrect, currentTime, playerDbRecord, found)
	if not self.SV.showNamesFrame or self.SV.unlocked then return "" end
	if not unitName then return "" end
	local userDisplayNameType = self.SV.userDisplayNameType or self.defaults.userDisplayNameType
	if isResurrect and (currentTime - isResurrect) > 15000 then
		isResurrect = nil
	end

	local formattedName = ""
	local KOSOrFriend = self:IsKOSOrFriend(unitName, playerDbRecord)
	if KOSOrFriend then
		if KOSOrFriend == "KOS" then
			formattedName = formattedName .. self:GetKOSIcon()
		elseif KOSOrFriend == "friend" then
			formattedName = formattedName .. self:GetFriendIcon()
		elseif KOSOrFriend == "cool" then
			formattedName = formattedName .. self:GetCoolIcon()
		elseif KOSOrFriend == "groupleader" then
			formattedName = formattedName .. self:GetGroupLeaderIcon()
		elseif KOSOrFriend == "group" then
			formattedName = formattedName .. self:GetGroupIcon()
		elseif KOSOrFriend == "guild" then
			formattedName = formattedName .. self:GetGuildIcon(nil, unitAlliance == self.allianceOfPlayer and "40BB40" or "BB4040")
		end
	end

	local allianceColor = self:NameToAllianceColor(unitName, isDead or isResurrect, nil, unitAlliance)
	local classIcons = self:GetFormattedClassIcon(unitName, nil, allianceColor,isDead or isResurrect,
		nil, nil, nil, nil, currentTime, playerDbRecord.unitAvaRank, playerDbRecord or "none")
	local charName = self:Colorize(self:GetFormattedName(unitName), allianceColor)
	local accountName = self:Colorize(playerDbRecord.unitAccName, userDisplayNameType == "user" and allianceColor or "CCCCCC")
	if userDisplayNameType == "both" then
		formattedName = classIcons .. charName .. accountName .. formattedName
	elseif userDisplayNameType == "character" then
		formattedName = classIcons .. charName .. formattedName
	elseif userDisplayNameType == "user" then
		formattedName = classIcons .. accountName .. formattedName
	end

	local endIcon = ""
	if isDead then
		endIcon = self:GetDeathIcon(nil, 'AAAAAA')
	elseif isResurrect then
		endIcon = self:GetResurrectIcon()
	else
		if IsActiveWorldBattleground() then
			if isAttacker or isTarget then
				endIcon = self:GetAttackerIcon()
			end
		else
			if isAttacker and isTarget then
				endIcon = self:GetFightIcon(nil, nil, unitAlliance)
			elseif isAttacker then
				endIcon = self:GetAttackerIcon()
			elseif isTarget then
				endIcon = self:GetFightIcon(nil, nil, unitAlliance)
			end
		end
	end

	if not found then
		PVP_Names_Text:AddMessage(formattedName .. endIcon)
	end

	return formattedName
end

function PVP:PopulateReticleOverNamesBuffer(forceRefresh, currentTime)
	if not self.SV.showNamesFrame or self.SV.unlocked then return end
	currentTime = currentTime or GetFrameTimeMilliseconds()
	local userDisplayNameType = self.SV.userDisplayNameType or self.defaults.userDisplayNameType
	PVP_Names_Text:Clear()
	local namesToDisplay = self.namesToDisplay
	if #namesToDisplay == 0 then return end

	local playersDb = self.SV.playersDB

	for k, v in ipairs(namesToDisplay) do
		local playerName = v.unitName
		if playerName then
			local unitAlliance = v.unitAlliance
			local nameToken = v.nameToken
			local isDead = v.isDead
			local isAttacker = v.isAttacker
			local isTarget = v.isTarget
			local isResurrect = v.isResurrect

			if isResurrect and (currentTime - isResurrect) > 15000 then
				v.isResurrect = nil
				isResurrect = nil
				--Could insert a call to BuildReticleName here to update the colors if this isn't good enough
			end
			if (not nameToken) or (nameToken == "") or forceRefresh then
				local formattedName = ""
				local playerDbRecord = playersDb[playerName]
				unitAlliance = playerDbRecord and playerDbRecord.unitAlliance

				local KOSOrFriend = self:IsKOSOrFriend(playerName, playerDbRecord)
				if KOSOrFriend then
					if KOSOrFriend == "KOS" then
						formattedName = formattedName .. self:GetKOSIcon()
					elseif KOSOrFriend == "friend" then
						formattedName = formattedName .. self:GetFriendIcon()
					elseif KOSOrFriend == "cool" then
						formattedName = formattedName .. self:GetCoolIcon()
					elseif KOSOrFriend == "groupleader" then
						formattedName = formattedName .. self:GetGroupLeaderIcon()
					elseif KOSOrFriend == "group" then
						formattedName = formattedName .. self:GetGroupIcon()
					elseif KOSOrFriend == "guild" then
						formattedName = formattedName .. self:GetGuildIcon(nil, unitAlliance == self.allianceOfPlayer and "40BB40" or "BB4040")
					end
				end

				local allianceColor = self:NameToAllianceColor(playerName, isDead or isResurrect, nil, unitAlliance)
				local classIcons = self:GetFormattedClassIcon(playerName, nil, allianceColor, isDead or isResurrect,
					nil, nil, nil, nil, currentTime, playerDbRecord.unitAvaRank, playerDbRecord or "none")
				local charName = self:Colorize(self:GetFormattedName(playerName), allianceColor)
				local accountName = self:Colorize(playerDbRecord.unitAccName, userDisplayNameType == "user" and allianceColor or "CCCCCC")
				if userDisplayNameType == "both" then
					formattedName = classIcons .. charName .. accountName .. formattedName
				elseif userDisplayNameType == "character" then
					formattedName = classIcons .. charName .. formattedName
				elseif userDisplayNameType == "user" then
					formattedName = classIcons .. accountName .. formattedName
				end
				v.nameToken = formattedName
				nameToken = formattedName
			end

			local endIcon = ""
			if isDead then
				endIcon = self:GetDeathIcon(nil, 'AAAAAA')
			elseif isResurrect then
				endIcon = self:GetResurrectIcon()
			else
				if IsActiveWorldBattleground() then
					if isAttacker or isTarget then
						endIcon = self:GetAttackerIcon()
					end
				else
					if isAttacker and isTarget then
						endIcon = self:GetFightIcon(nil, nil, unitAlliance)
					elseif isAttacker then
						endIcon = self:GetAttackerIcon()
					elseif isTarget then
						endIcon = self:GetFightIcon(nil, nil, unitAlliance)
					end
				end
			end

			PVP_Names_Text:AddMessage(nameToken .. endIcon)
		end
	end
end

function PVP:GetKillFeed()
	for k, v in ipairs(CHAT_SYSTEM.containers) do
		for i = 1, #v.windows do
			if v:GetTabName(i) == "PVPKillFeed" then
				return v, v.windows[i], i
			end
		end
	end

	local container = CHAT_SYSTEM.primaryContainer
	local window, key = container.windowPool:AcquireObject()
	window.key = key

	container:AddRawWindow(window, "PVPKillFeed")

	local tabIndex = window.tab.index

	container:SetInteractivity(tabIndex, true)
	container:SetLocked(tabIndex, true)
	container:SetTimestampsEnabled(tabIndex, true)

	for category = 1, GetNumChatCategories() do
		container:SetWindowFilterEnabled(tabIndex, category, false)
	end
	return container, window
end

function PVP:InitializeChat()
	if not self.SV.showKillFeedChat then return end
	if ZO_ChatWindowTabTemplate1 then
		self.ChatContainer, self.ChatWindow = self:GetKillFeed()
	else
		zo_callLater(function() PVP:InitializeChat() end, 200)
	end
end

function PVP:ProcessReticleOver(unitName, unitAccName, unitClass, unitAlliance, unitRace, isDead)
	local currentTime = GetFrameTimeMilliseconds()
	local found, foundName

	if isDead and self.playerNames[unitName] then
		self.playerNames[unitName] = nil
		return
	end

	if unitAlliance == self.allianceOfPlayer then
		self:DetectSpecOnReticleOver(unitName)
	end

	for k, v in pairs(self.idToName) do
		if v == unitName then
			found = k
			break
		end
	end

	if found then self.totalPlayers[found] = currentTime end
	self.playerNames[unitName] = currentTime
	self:UpdateNamesToDisplay(unitName, currentTime, true, nil, nil, nil, found)
end

function PVP.OnTargetChanged()
	if PVP.SV.unlocked or not PVP:IsInPVPZone() then return end
	local targetIcon
	if IsUnitPlayer('reticleover') then
		local unitName = PVP:GetValidName(GetRawUnitName('reticleover'))
		local unitAccName = ZO_ShouldPreferUserId() and ZO_GetPrimaryPlayerNameFromUnitTag('reticleover') or
			ZO_GetSecondaryPlayerNameFromUnitTag('reticleover')
		-- local unitAccName=ZO_GetSecondaryPlayerNameFromUnitTag('reticleover')
		local unitClass = GetUnitClassId('reticleover')
		local unitAlliance = GetUnitAlliance('reticleover')
		local unitAllianceRank = GetUnitAvARank('reticleover')
		local unitRace = GetUnitRaceId('reticleover')
		local unitCP = GetUnitChampionPoints('reticleover')

		local unitMundus, unitSpec, unitDbAccName
		if unitName then
			local SV = PVP.SV
			local playersDB = SV.playersDB
			local playerDbRecord = playersDB[unitName]

			if playerDbRecord then
				unitSpec = playerDbRecord.unitSpec
				unitMundus = playerDbRecord.mundus
				unitDbAccName = playerDbRecord.unitAccName
			end

			if unitCP > 0 then
				SV.CP[unitAccName] = unitCP
			end

			if unitDbAccName and (unitDbAccName ~= unitAccName) then
				PVP:UpdatePlayerDbAccountName(unitName, unitAccName, unitDbAccName)
			end

			local updatedPlayerDbRecord = {
				unitAccName = unitAccName,
				unitAlliance = unitAlliance,
				unitClass = unitClass,
				unitRace = unitRace,
				unitSpec = unitSpec,
				mundus = unitMundus,
				unitAvARank = unitAllianceRank,
				lastSeen = sessionTimeEpoch
			}
			playersDB[unitName] = updatedPlayerDbRecord

			if IsActiveWorldBattleground() then
				PVP.bgNames = PVP.bgNames or {}
				PVP.bgNames[unitName] = GetUnitBattlegroundTeam('reticleover')
			end
			if SV.showNewTargetInfo then
				ZO_TargetUnitFramereticleoverName:SetText(PVP:GetTargetChar(unitName, true))
			end

			if SV.showTargetIcon then
				local KOSOrFriend = PVP:IsKOSOrFriend(unitName, updatedPlayerDbRecord)
				local iconSize = 48

				if KOSOrFriend == "KOS" then
					targetIcon = PVP:GetKOSIcon(iconSize * 1.5)
				elseif KOSOrFriend == "friend" then
					targetIcon = PVP:GetFriendIcon(iconSize * 1)
				elseif KOSOrFriend == "cool" then
					targetIcon = PVP:GetCoolIcon(iconSize * 1)
				elseif KOSOrFriend == "groupleader" then
					targetIcon = PVP:GetGroupLeaderIcon(iconSize * 1.3)
				elseif KOSOrFriend == "group" then
					targetIcon = PVP:GetGroupIcon(iconSize * 1.3)
				elseif KOSOrFriend == "guild" then
					targetIcon = PVP:GetGuildIcon(iconSize * 1,
						unitAlliance == PVP.allianceOfPlayer and "40BB40" or "BB4040")
				end
			end

			if (unitCP > 0) and SV.showMaxTargetCP then
				ZO_TargetUnitFramereticleoverChampionIcon:SetDimensions(20, 20)
				ZO_TargetUnitFramereticleoverLevel:SetText(unitCP)
			end

			PVP:ProcessReticleOver(unitName, unitAccName, unitClass, unitAlliance, unitRace, IsUnitDead('reticleover'))

		end
	end

	PVP_TargetIconLabel:SetText(targetIcon)

	if PVP.SV.showTargetNameFrame then PVP:UpdateTargetName() end
end

function PVP:UpdateTargetName()
	local unitName = self:GetValidName(GetRawUnitName('reticleover'))

	if IsUnitPlayer('reticleover') and unitName then
		PVP_TargetNameLabel:SetText(self:GetTargetChar(unitName))
		if self.fadeOutIsPlaying and self.fadeOutIsPlaying:IsPlaying() then self.fadeOutIsPlaying:Stop() end
		PVP_TargetName:SetAlpha(self.SV.targetNameFrameAlpha)
	else
		if self.SV.targetNameFrameFadeoutTime > 0 and (not (self.fadeOutIsPlaying and self.fadeOutIsPlaying:IsPlaying())) and PVP_TargetName:GetAlpha() ~= 0 then
			self.fadeOutIsPlaying = self:StartAnimation(PVP_TargetName, 'fadeOut')
		end
	end
end

function PVP:UpdateNewAttacker(attackerName, test)
	local function CountNonDead()
		local namesToDisplay = self.namesToDisplay
		local count = 0
		if namesToDisplay and #namesToDisplay > 0 then
			for k, v in ipairs(namesToDisplay) do
				if not v.isDead then
					count = count + 1
				end
			end
		end
		return count
	end

	local unitName
	local frame = PVP_NewAttacker

	if test then
		unitName = attackerName
	else
		unitName = self:GetValidName(attackerName)
	end

	if unitName then
		local formattedCharName

		if test then
			formattedCharName = unitName
		else
			formattedCharName = self:GetTargetChar(unitName)
		end

		if not formattedCharName then
			formattedCharName = zo_strformat(SI_UNIT_NAME, attackerName)
		end

		local outputText = upper(formattedCharName)

		local targetNumber = CountNonDead() + 1

		if frame.animation and frame.animation:IsPlaying() then frame.animation:Stop() end

		PVP_NewAttackerNumber:SetText(tostring(targetNumber))
		PVP_NewAttackerLabel:SetText(outputText)

		frame.animation = self:StartAnimation(frame, 'attackerFrame', self.SV.newAttackerFrameAlpha)
	end
end

local function DeathScreenOnLoadFix()
	if DEATH_FRAGMENT.state == 'shown' then
		local _, _, _, _, _, isAVADeath = GetDeathInfo()
		if isAVADeath then
			SetupDeathButtons()
			PVP_Death_Buttons:SetHandler("OnUpdate", function() SetupDeathButtons() end)
		end
	end
end

function PVP:RefreshKOSandCoolAccList()
	local KOSList = self.SV.KOSList
	local KOSAccList = {}
	local numKOS = #KOSList
	for i = 1, numKOS do
		KOSAccList[KOSList[i].unitAccName] = true
	end
	self.KOSAccList = KOSAccList

	local coolList = self.SV.coolList
	local coolAccList = {}
	for k, v in pairs(coolList) do
		coolAccList[v] = true
	end
	self.coolAccList = coolAccList
end

function PVP:InitEnabledAddon()
	if self.addonEnabled then
		EVENT_MANAGER:UnregisterForUpdate(self.name)
		EVENT_MANAGER:RegisterForUpdate(self.name, 250, self.OnUpdate)
		self:Init3D()
		self:InitControls()
		self:InitNetworking()
		self:RegisterCustomDialog()
		self.playerName = GetRawUnitName('player')
		self.allianceOfPlayer = GetUnitAlliance('player')
		self:RefreshKOSandCoolAccList()
		self.guildmates = self:PopulateGuildmateDatabase()
		PVP_KOS_Text:SetHandler("OnLinkMouseUp",
			function(self, _, link, button) return ZO_LinkHandler_OnLinkMouseUp(link, button, self) end)
		PVP_Names_Text:SetHandler("OnLinkMouseUp",
			function(self, _, link, button) return ZO_LinkHandler_OnLinkMouseUp(link, button, self) end)
		PVP_KillFeed_Text:SetHandler("OnLinkMouseUp",
			function(self, _, link, button) return ZO_LinkHandler_OnLinkMouseUp(link, button, self) end)
		self:FullReset()
		-- if not PVP.SV.unlocked and PVP.SV.showCaptureFrame then PVP:SetupCurrentObjective(GetPlayerLocationName()) end
		if not self.deathScreenFixPending then
			self.deathScreenFixPending = zo_callLater(
				function()
					PVP.deathScreenFixPending = false
					DeathScreenOnLoadFix()
				end, 50)
		end
	end
end

function PVP.Activated()
	local function ConvertDatabaseRaceClass()
		if PVP.SV.raceClassConversionDone then return end

		local function ConvertRaceNameToId(raceName)
			if raceName == "" then return false end
			for i = 1, 20 do
				local nameFromId = GetRaceName(0, i)
				if raceName == nameFromId then
					return i
				end
			end
			return false
		end

		local function ConvertClassNameToId(className)
			if className == "" then return false end
			for i = 1, 20 do
				local nameFromId = GetClassName(0, i)
				if className == nameFromId then
					return i
				end
			end
			return false
		end

		local playersDB = PVP.SV.playersDB
		for k, v in pairs(playersDB) do
			if v.unitClass and v.unitClass ~= "" then
				local classId = ConvertClassNameToId(v.unitClass)
				if classId then v.unitClass = classId end
			end
			if v.unitRace and v.unitRace ~= "" then
				local raceId = ConvertRaceNameToId(v.unitRace)
				if raceId then v.unitRace = raceId end
			end
		end
		chat:Print('Race/Class names to Ids conversion done')
		PVP.SV.raceClassConversionDone = true
	end


	local function SyncSpecs()
		if PVP.SV.rememberedSpecs then
			local decisions = {
				["stam"] = true,
				["mag"] = true,
				["hybrid"] = true,
			}
			local counter = 0
			for k, v in pairs(PVP.SV.rememberedSpecs) do
				if v.spec_decision and decisions[v.spec_decision] and PVP.SV.playersDB and PVP.SV.playersDB[k] and not PVP.SV.playersDB[k].unitSpec then
					PVP.SV.playersDB[k].unitSpec = v.spec_decision
					counter = counter + 1
				end
			end
			if counter > 0 then chat:Printf('Processed %d previously recorded player specs!', counter) end
			PVP.SV.rememberedSpecs = nil
		end
	end

	ConvertDatabaseRaceClass()
	SyncSpecs()
	if PVP.SV.delayedStart then
		if not PVP.activatePending then
			PVP.activatePending = zo_callLater(
				function()
					PVP:OnOff()
					PVP.activatePending = nil
				end, 25)
		end
	else
		PVP:OnOff()
	end
end

local function IsAccInDB(accName)
	local KOSList = PVP.SV.KOSList
	for k, v in ipairs(KOSList) do
		if v.unitAccName == accName then return v.unitName end
	end

	local playersDB = PVP.SV.playersDB
	for k, v in pairs(playersDB) do
		if v.unitAccName == accName then return k end
	end
	return false
end

local function IsNameInDB(rawName)
	local playersDB = PVP.SV.playersDB
	if PVP:CheckName(rawName) then
		if playersDB[rawName] then return rawName else return false end
	end
	local maleName = rawName .. "^Mx"
	local femaleName = rawName .. "^Fx"
	if playersDB[maleName] or playersDB[femaleName] then
		if playersDB[maleName] and not playersDB[femaleName] then return maleName end
		if not playersDB[maleName] and playersDB[femaleName] then return femaleName end
		if playersDB[maleName].unitAccName == playersDB[femaleName].unitAccName then
			if zo_random() > 0.5 then
				return
					maleName
			else
				return femaleName
			end
		end
	end
	return false
end

CALLBACK_MANAGER:RegisterCallback(PVP.name .. "_OnAddOnLoaded", function()
	local ShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu
	function CHAT_SYSTEM:ShowPlayerContextMenu(playerName, rawName)
		ShowPlayerContextMenu(self, playerName, rawName)

		if PVP:IsInPVPZone() then
			if IsDecoratedDisplayName(playerName) then
				rawName = IsAccInDB(playerName)
			else
				rawName = IsNameInDB(rawName)
			end

			if rawName then
				if PVP.SV.showKOSFrame then
					local index
					local unitAccName = PVP.SV.playersDB[rawName] and PVP.SV.playersDB[rawName].unitAccName
					local kosList = PVP.SV.KOSList
					local numKOS = #kosList
					for i = 1, numKOS do
						if unitAccName and (unitAccName == kosList[i].unitAccName) then
							index = i
							break
						end
					end
					if index then
						AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_REMOVE_FROM_KOS), function()
							chat:Printf("Removed from KOS: %s%s!", PVP:GetFormattedName(rawName),
								unitAccName)
							remove(PVP.SV.KOSList, index)
							PVP:RefreshKOSandCoolAccList()
							PVP:RefreshLocalPlayers()
							PVP:PopulateReticleOverNamesBuffer(true)
						end)
						local removeCool = PVP:FindAccInCOOL(rawName, unitAccName)
						if removeCool then
							PVP.SV.coolList[removeCool] = nil
							PVP:RefreshKOSandCoolAccList()
							PVP:RefreshLocalPlayers()
							PVP:PopulateReticleOverNamesBuffer(true)
						end

						AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_TO_COOL), function()
							chat:Printf("Removed from KOS: %s%s!", PVP:GetFormattedName(rawName),
								unitAccName)
							remove(PVP.SV.KOSList, index)
							chat:Printf("Added to COOL: %s%s!", PVP:GetFormattedName(rawName),
								unitAccName)
							local addCool = PVP:FindAccInCOOL(rawName, unitAccName)
							if not addCool then PVP.SV.coolList[rawName] = unitAccName end
							PVP:RefreshKOSandCoolAccList()
							PVP:RefreshLocalPlayers()
							PVP:PopulateReticleOverNamesBuffer(true)
						end)
					else
						AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_TO_KOS), function()
							local cool = PVP:FindAccInCOOL(rawName, unitAccName)
							if cool then
								chat:Printf("Removed from COOL: %s%s!",
									PVP:GetFormattedName(rawName),
									unitAccName)
								PVP.SV.coolList[cool] = nil
								PVP:PopulateReticleOverNamesBuffer(true)
							end
							chat:Printf("Added to KOS: %s%s!", PVP:GetFormattedName(rawName),
								unitAccName)
							insert(PVP.SV.KOSList,
								{
									unitName = rawName,
									unitAccName = unitAccName,
								})
								PVP:RefreshKOSandCoolAccList()
								PVP:RefreshLocalPlayers()
								PVP:PopulateReticleOverNamesBuffer(true)
							end)
						local addCool = PVP:FindAccInCOOL(rawName, unitAccName)

						if not addCool then
							AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_TO_COOL), function()
								chat:Printf("Added to COOL: %s%s!",
									PVP:GetFormattedName(rawName),
									unitAccName)
								PVP.SV.coolList[rawName] = unitAccName
								PVP:RefreshKOSandCoolAccList()
								PVP:RefreshLocalPlayers()
								PVP:PopulateReticleOverNamesBuffer(true)
							end)
						else
							AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_REMOVE_FROM_COOL), function()
								chat:Printf("Removed from COOL: %s%s!",
									PVP:GetFormattedName(rawName),
									unitAccName)
								local removeCool = PVP:FindAccInCOOL(rawName, unitAccName)
								if removeCool then
									PVP.SV.coolList[removeCool] = nil
									PVP:RefreshKOSandCoolAccList()
									PVP:RefreshLocalPlayers()
									PVP:PopulateReticleOverNamesBuffer(true)
								end
							end)
						end
					end
					if unitAccName then
						local accNote = PVP.SV.playerNotes[unitAccName]
						if not accNote then
							AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_NOTE), function()
								ZO_Dialogs_ShowDialog("PVP_EDIT_NOTE", {
									playerName = unitAccName,
									noteString = nil,
									changedCallback = function(playerName, noteString)
										if noteString and noteString ~= "" then
											PVP.SV.playerNotes[playerName] = noteString
											chat:Printf("Added note \"%s\" for player %s",
												PVP:Colorize(noteString, "76BCC3"),
												PVP:GetFormattedAccountNameLink(playerName, "FFFFFF"))
										end
									end
								})
							end)
						else
							AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_EDIT_NOTE), function()
								ZO_Dialogs_ShowDialog("PVP_EDIT_NOTE", {
									playerName = unitAccName,
									noteString = accNote,
									changedCallback = function(playerName, noteString)
										if (not noteString) or noteString == "" then
											PVP.SV.playerNotes[playerName] = nil
											chat:Printf("Deleted note \"%s\" for player %s",
												PVP:Colorize(accNote, "76BCC3"),
												PVP:GetFormattedAccountNameLink(playerName, "FFFFFF"))
										elseif noteString ~= accNote then
											PVP.SV.playerNotes[playerName] = noteString
											chat:Printf("Updated note for player %s to \"%s\"",
												PVP:GetFormattedAccountNameLink(playerName, "FFFFFF"),
												PVP:Colorize(noteString, "76BCC3"))
										else
											chat:Printf("Note for player %s was not changed",
												PVP:GetFormattedAccountNameLink(playerName, "FFFFFF"))
										end
									end
								})
							end)
							AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_DELETE_NOTE), function()
								chat:Printf("Deleted note \"%s\" for player %s",
									PVP:Colorize(accNote, "76BCC3"),
									PVP:GetFormattedAccountNameLink(unitAccName, "FFFFFF"))
								PVP.SV.playerNotes[unitAccName] = nil
							end)
						end
					end
				end
			end
		end
		AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_WHO), function() PVP:Who(rawName) end)
		ShowMenu()
	end
end)

function PVP:InitializeSV()
	self.SV = ZO_SavedVars:NewAccountWide("PvpAlertsSettings", self.version, "Settings", self.defaults)
	if self.SV.guild3d == nil then self.SV.guild3d = true end
	if not self.SV.coolList then self.SV.coolList = {} end
	if not self.SV.playerNotes then self.SV.playerNotes = {} end
	if not self.SV.CP then self.SV.CP = {} end
	if not self.SV.MMR then self.SV.MMR = {} end
	if self.SV.enabled then self:InitializeChat() end
end

function PVP.OnLoad(eventCode, addonName)
	if addonName ~= PVP.name then return end
	EVENT_MANAGER:UnregisterForEvent(PVP.name, EVENT_ADD_ON_LOADED, PVP.OnLoad)

	PVP:InitializeSV()
	PVP:Clean_PlayerDB()
	PVP:InitializeAddonMenu()
	PVP:AvAHax()
	PVP_KOS_SCENE_FRAGMENT = ZO_FadeSceneFragment:New(PVP_KOS, nil, 0)
	PVP_COUNTER_SCENE_FRAGMENT = ZO_FadeSceneFragment:New(PVP_Counter, nil, 0)
	PVP_KILLFEED_SCENE_FRAGMENT = ZO_FadeSceneFragment:New(PVP_KillFeed, nil, 0)
	PVP_NAMES_SCENE_FRAGMENT = ZO_FadeSceneFragment:New(PVP_Names, nil, 0)
	PVP_CAMP_SCENE_FRAGMENT = ZO_FadeSceneFragment:New(PVP_ForwardCamp, nil, 0)
	PVP_CAPTURE_SCENE_FRAGMENT = ZO_FadeSceneFragment:New(PVP_Capture, nil, 0)
	PVP_TARGETNAME_SCENE_FRAGMENT = ZO_FadeSceneFragment:New(PVP_TargetName, nil, 0)
	PVP_DEATH_FRAGMENT = ZO_HUDFadeSceneFragment:New(PVP_Death_Buttons)
	PVP_TOOLTIP3D_FRAGMENT = ZO_FadeSceneFragment:New(PVP_WorldTooltip, nil, 0)
	PVP_MEDALS_FRAGMENT = ZO_FadeSceneFragment:New(PVP_Medals, nil, 0)
	PVP_ONSCREEN_FRAGMENT = ZO_FadeSceneFragment:New(PVP_OnScreen, nil, 0)
	PVP_TUG_FRAGMENT = ZO_FadeSceneFragment:New(PVP_TUG, nil, 0)
	ZO_CreateStringId('SI_BINDING_NAME_PVP_ALERTS_SHOW_AD', 'Toggle AD tooltip')
	ZO_CreateStringId('SI_BINDING_NAME_PVP_ALERTS_SHOW_DC', 'Toggle DC tooltip')
	ZO_CreateStringId('SI_BINDING_NAME_PVP_ALERTS_SHOW_EP', 'Toggle EP tooltip')
	ZO_CreateStringId('SI_BINDING_NAME_PVP_ALERTS_SET_WAYPOINT', 'Set waypoint to mouseover 3d icon')
	ZO_CreateStringId('SI_BINDING_NAME_PVP_ALERTS_ADD_KOS_MOUSEOVER', 'Mouseover Add to KOS')
	ZO_CreateStringId('SI_BINDING_NAME_PVP_ALERTS_ADD_COOL_MOUSEOVER', 'Mouseover Add to COOL')
	ZO_CreateStringId('SI_BINDING_NAME_PVP_ALERTS_WHO_IS', 'Mouseover Whois')
	ZO_CreateStringId('SI_BINDING_NAME_PVP_ALERTS_TOGGLE_BG_SCOREBOARD', 'Toggle Scoreboard')
	ZO_CreateStringId("SI_CHAT_PLAYER_CONTEXT_REMOVE_FROM_KOS", "Remove from KOS")
	ZO_CreateStringId("SI_CHAT_PLAYER_CONTEXT_WHO", "Who is this?")
	ZO_CreateStringId("SI_CHAT_PLAYER_CONTEXT_ADD_TO_KOS", "Add to KOS")
	ZO_CreateStringId("SI_CHAT_PLAYER_CONTEXT_REMOVE_FROM_COOL", "Remove from COOL")
	ZO_CreateStringId("SI_CHAT_PLAYER_CONTEXT_ADD_TO_COOL", "Add to COOL")
	ZO_CreateStringId("SI_CHAT_PLAYER_CONTEXT_ADD_NOTE", "Add Note")
	ZO_CreateStringId("SI_CHAT_PLAYER_CONTEXT_EDIT_NOTE", "Edit Note")
	ZO_CreateStringId("SI_CHAT_PLAYER_CONTEXT_DELETE_NOTE", "Delete Note")
	ZO_CreateStringId("PVP_NOTES_EDIT_NOTE", GetString(SI_EDIT_NOTE_DIALOG_TITLE))

	CALLBACK_MANAGER:FireCallbacks(PVP.name .. "_OnAddOnLoaded")
	EVENT_MANAGER:RegisterForEvent(PVP.name, EVENT_PLAYER_ACTIVATED, PVP.Activated)
end

EVENT_MANAGER:RegisterForEvent(PVP.name, EVENT_ADD_ON_LOADED, PVP.OnLoad)

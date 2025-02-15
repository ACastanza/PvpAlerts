---@class (partial) PvpAlerts
local PVP = PVP_Alerts_Main_Table

local PVP_ICON_MISSING = PVP:GetGlobal('PVP_ICON_MISSING')
local PVP_CONTINUOUS_ATTACK_ID_1 = PVP:GetGlobal('PVP_CONTINUOUS_ATTACK_ID_1')
local PVP_CONTINUOUS_ATTACK_ID_2 = PVP:GetGlobal('PVP_CONTINUOUS_ATTACK_ID_2')
local PVP_AYLEID_WELL_ID = PVP:GetGlobal('PVP_AYLEID_WELL_ID')
local PVP_BLESSING_OF_WAR_ID = PVP:GetGlobal('PVP_BLESSING_OF_WAR_ID')
local floor = zo_floor
local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local zo_distance3D = zo_distance3D

function PVP:FindNearbyKeepToRespawn(anyKeep)
	local selfX, selfY = GetMapPlayerPosition('player')
	local foundKeepId, minDistance

	for i = 1, GetNumKeeps() do
		local keepId = GetKeepKeysByIndex(i)
		if anyKeep or (CanRespawnAtKeep(keepId) and not (IsInImperialCity() and GetKeepType(keepId) ~= KEEPTYPE_IMPERIAL_CITY_DISTRICT)) then
			local _, targetX, targetY = GetKeepPinInfo(keepId, 1)
			if targetX ~= 0 and targetY ~= 0 then
				local distance = zo_distance3D(selfX, selfY, 0, targetX, targetY, 0)
				if not minDistance or distance < minDistance then
					foundKeepId, minDistance = keepId, distance
				end
			end
		end
	end

	return foundKeepId or false
end

function PVP:RespawnAtNearbyKeep()
	local keepId = self:FindNearbyKeepToRespawn()
	if keepId then RespawnAtKeep(keepId) end
end

function PVP:RespawnAtNearbyCamp()
	local campIndex = self:FindNearbyCampToRespawn(true)
	if campIndex then RespawnAtForwardCamp(campIndex) end
end

function PVP:ManageCampFrame()
	local function ColorBuffIcon(control, currentRatio)
		if currentRatio == 5 then
			control:SetColor(0.2, 0.2, 0.2)
			control:SetAlpha(0.75)
		elseif currentRatio >= 0.90 then
			control:SetColor(1, 0, 0)
			control:SetAlpha(1)
		elseif currentRatio >= 0.75 then
			control:SetColor(0.9, 0.9, 0)
			control:SetAlpha(1)
		else
			control:SetColor(1, 1, 1)
			control:SetAlpha(1)
		end
	end

	if self.SV.unlocked then
		PVP_ForwardCamp_Icon:SetColor(1, 1, 1)
		PVP_ForwardCamp_IconContinuous:SetColor(1, 1, 1)
		PVP_ForwardCamp_IconAyleid:SetColor(1, 1, 1)
		PVP_ForwardCamp_IconBlessing:SetColor(1, 1, 1)
		PVP_ForwardCamp_IconContinuous:SetAlpha(1)
		PVP_ForwardCamp_IconAyleid:SetAlpha(1)
		PVP_ForwardCamp_IconBlessing:SetAlpha(1)
		return
	end

	local currentTimeSec = GetFrameTimeSeconds()

	local continuous, ayleid, blessing

	-- local debuffs = {}

	-- local buffsStart = GetGameTimeMilliseconds()
	for i = 1, GetNumBuffs('player') do
		local buffName, timeStarted, timeEnding, _, _, _, _, _, _, _, abilityId, _, castByPlayer = GetUnitBuffInfo(
			'player', i)

		local duration = timeEnding - timeStarted
		local timeLeft = timeEnding - currentTimeSec
		local currentRatio = (currentTimeSec - timeStarted) / duration

		if (abilityId == PVP_CONTINUOUS_ATTACK_ID_1) or (abilityId == PVP_CONTINUOUS_ATTACK_ID_2) then
			ColorBuffIcon(PVP_ForwardCamp_IconContinuous, currentRatio)
			continuous = timeLeft
		elseif abilityId == PVP_AYLEID_WELL_ID then
			ColorBuffIcon(PVP_ForwardCamp_IconAyleid, currentRatio)
			ayleid = timeLeft
		elseif abilityId == PVP_BLESSING_OF_WAR_ID then
			ColorBuffIcon(PVP_ForwardCamp_IconBlessing, currentRatio)
			blessing = timeLeft
		end
	end

	local SecondsToClock = self.SecondsToClock

	-- local buffsEnd = GetGameTimeMilliseconds()
	-- d('Buff proc: '..tostring(buffsEnd - buffsStart))

	if continuous then
		local timeString = self:SecondsToClock(floor(continuous))
		PVP_ForwardCamp_IconContinuous.timeLeft = { "Continuous Attack", "Time left: " .. timeString }
		self.SetToolTip(PVP_ForwardCamp_IconContinuous, 200, false, "Continuous Attack", "Time left: " .. timeString)
	else
		PVP_ForwardCamp_IconContinuous.timeLeft = false
		ColorBuffIcon(PVP_ForwardCamp_IconContinuous, 5)
		self.ReleaseToolTip(PVP_ForwardCamp_IconContinuous)
	end

	if ayleid then
		local timeString = self:SecondsToClock(floor(ayleid))
		PVP_ForwardCamp_IconAyleid.timeLeft = { "Ayleid Well", "Time left: " .. timeString }
		self.SetToolTip(PVP_ForwardCamp_IconAyleid, 200, false, "Ayleid Well", "Time left: " .. timeString)
	else
		PVP_ForwardCamp_IconAyleid.timeLeft = false
		ColorBuffIcon(PVP_ForwardCamp_IconAyleid, 5)
		self.ReleaseToolTip(PVP_ForwardCamp_IconAyleid)
	end

	if blessing then
		local timeString = self:SecondsToClock(floor(blessing))
		PVP_ForwardCamp_IconBlessing.timeLeft = { "Blessing of War", "Time left: " .. timeString }
		self.SetToolTip(PVP_ForwardCamp_IconBlessing, 200, false, "Blessing of War", "Time left: " .. timeString)
	else
		PVP_ForwardCamp_IconBlessing.timeLeft = false
		ColorBuffIcon(PVP_ForwardCamp_IconBlessing, 5)
		self.ReleaseToolTip(PVP_ForwardCamp_IconBlessing)
	end
	-- local iconsEnd = GetGameTimeMilliseconds()
	-- d('Icons proc: '..tostring(iconsEnd - buffsEnd))
	local campState = self:FindNearbyCampToRespawn(true)
	-- local campFuncEnd = GetGameTimeMilliseconds()
	-- d('Camp func proc: '..tostring(campFuncEnd - iconsEnd))
	if not self.IsCampActive then
		if campState then
			self:StartAnimation(PVP_ForwardCamp_Icon, 'camp')
			if not self.lastCampTime then self.lastCampTime = currentTimeSec end
			if self.SV.playCampSound and (currentTimeSec - self.lastCampTime >= 5 or self.lastCampTime == currentTimeSec) then
				PlaySound(SOUNDS.ENLIGHTENED_STATE_GAINED)
				self.lastCampTime = currentTimeSec
			end
			self.IsCampActive = true
			self.SetToolTip(PVP_ForwardCamp_Icon, 200, false, "Forward Camp in range!")
		end
	elseif not campState then
		if self.SV.playCampSound and currentTimeSec - self.lastCampTime >= 5 then
			self:PlayLoudSound('JUSTICE_GOLD_REMOVED')
			self.lastCampTime = currentTimeSec
		end
		self.IsCampActive = false
		self.ReleaseToolTip(PVP_ForwardCamp_Icon)
	end
end

function PVP_FindNearestForwardCamp()
	PVP:FindNearbyCampToRespawn()
end

function PVP:FindNearbyCampToRespawn(onUpdate)
	if not self:IsInPVPZone() then return false end

	if GetNumForwardCamps(1) == 0 then
		if not onUpdate then
			d('No camps found!')
		end
		PVP_ForwardCamp_Icon:SetColor(0.1, 0.1, 0.1)
		PVP_ForwardCamp_Icon:SetAlpha(0.5)
		return false
	end
	local campIndex, count, minDistance, isUsable, campRadius = 0, 0, nil, nil, nil
	local selfX, selfY = GetMapPlayerPosition('player')
	for i = 1, GetNumForwardCamps(1) do
		local _, targetX, targetY, radius, usable = GetForwardCampPinInfo(1, i)

		if usable and targetX ~= 0 and targetY ~= 0 then
			local distance = zo_distance3D(selfX, selfY, 0, targetX, targetY, 0)

			if distance / radius < 1 then count = count + 1 end

			if not minDistance then
				minDistance = distance
				campIndex = i
				campRadius = radius
			elseif distance < minDistance then
				minDistance = distance
				campIndex = i
				campRadius = radius
			end
		end
	end

	if minDistance then
		local distanceDelta = minDistance / campRadius

		if distanceDelta < 1 then
			PVP_ForwardCamp_Icon:SetAlpha(1)
			if distanceDelta >= 0.85 then
				PVP_ForwardCamp_Icon:SetColor(1, 0.2, 0.2)
			elseif distanceDelta >= 0.65 then
				PVP_ForwardCamp_Icon:SetColor(0.9, 0.9, 0)
			else
				PVP_ForwardCamp_Icon:SetColor(0, 0.9, 0)
			end

			return campIndex, count
		end
	else
		PVP_ForwardCamp_Icon:SetColor(0.1, 0.1, 0.1)
		PVP_ForwardCamp_Icon:SetAlpha(0.5)
		return false
	end
end

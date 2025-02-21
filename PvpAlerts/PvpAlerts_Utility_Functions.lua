---@class (partial) PvpAlerts
local PVP = PVP_Alerts_Main_Table

PVP.LMP = LibMapPing2
PVP.GPS = LibGPS3

local PVP_DIMMED_AD_COLOR = PVP:GetGlobal('PVP_DIMMED_AD_COLOR')
local PVP_BRIGHT_AD_COLOR = PVP:GetGlobal('PVP_BRIGHT_AD_COLOR')
local PVP_DIMMED_EP_COLOR = PVP:GetGlobal('PVP_DIMMED_EP_COLOR')
local PVP_BRIGHT_EP_COLOR = PVP:GetGlobal('PVP_BRIGHT_EP_COLOR')
local PVP_DIMMED_DC_COLOR = PVP:GetGlobal('PVP_DIMMED_DC_COLOR')
local PVP_BRIGHT_DC_COLOR = PVP:GetGlobal('PVP_BRIGHT_DC_COLOR')

local PVP_STAMINA_COLOR = PVP:GetGlobal('PVP_STAMINA_COLOR')
local PVP_MAGICKA_COLOR = PVP:GetGlobal('PVP_MAGICKA_COLOR')
local PVP_HYBRID_COLOR = PVP:GetGlobal('PVP_HYBRID_COLOR')

local PVP_SPACER_ICON = PVP:GetGlobal('PVP_SPACER_ICON')

local PVP_GUILD_ICON = PVP:GetGlobal('PVP_GUILD_ICON')
local PVP_GROUP_ICON = PVP:GetGlobal('PVP_GROUP_ICON')
local PVP_GROUPLEADER_ICON = PVP:GetGlobal('PVP_GROUPLEADER_ICON')
local PVP_FRIEND_ICON = PVP:GetGlobal('PVP_FRIEND_ICON')
local PVP_COOL_ICON = PVP:GetGlobal('PVP_COOL_ICON')
local PVP_IMPORTANT_ICON = PVP:GetGlobal('PVP_IMPORTANT_ICON')
local PVP_EYE_ICON = PVP:GetGlobal('PVP_EYE_ICON')
local PVP_KILLING_BLOW = PVP:GetGlobal('PVP_KILLING_BLOW')
local PVP_ATTACKER = PVP:GetGlobal('PVP_ATTACKER')
local PVP_EMPEROR = PVP:GetGlobal('PVP_EMPEROR')
local PVP_RESURRECT = PVP:GetGlobal('PVP_RESURRECT')
local PVP_6STAR = PVP:GetGlobal('PVP_6STAR')

local PVP_FIGHT_ADEP = PVP:GetGlobal('PVP_FIGHT_ADEP')
local PVP_FIGHT_ADDC = PVP:GetGlobal('PVP_FIGHT_ADDC')
local PVP_FIGHT_EPAD = PVP:GetGlobal('PVP_FIGHT_EPAD')
local PVP_FIGHT_EPDC = PVP:GetGlobal('PVP_FIGHT_EPDC')
local PVP_FIGHT_DCAD = PVP:GetGlobal('PVP_FIGHT_DCAD')
local PVP_FIGHT_DCEP = PVP:GetGlobal('PVP_FIGHT_DCEP')

local PVP_ID_RETAIN_TIME = PVP:GetGlobal('PVP_ID_RETAIN_TIME')
local PVP_ID_RETAIN_TIME_EFFECT = PVP:GetGlobal('PVP_ID_RETAIN_TIME_EFFECT')

local IsActiveWorldBattleground = IsActiveWorldBattleground
local GetFrameTimeMilliseconds = GetFrameTimeMilliseconds
local zo_distance = zo_distance

local strgsub= zo_strgsub
local strlen = zo_strlen

local sqrt = zo_sqrt
--local sort = table.sort
local insert = table.insert
--local remove = table.remove
local concat = table.concat

--local upper = string.upper
--local lower = string.lower
--local format = string.format

local ccImmunityBuffs = {
	["CC Immunity"] = true,
	["Crowd Control Immunity"] = true,
	["Unstoppable"] = true,
	["Immovable"] = true,
}

local databaseIntegrityCheck = {}

function PVP:RGBtoHEX(rgb)
	local hexadecimal = ''

	for key, value in pairs(rgb) do
		local hex = ''
		-- d("RGB: " .. key .. " " .. value)
		while (value > 0) do
			local index = zo_mod(value, 16) + 1
			value = zo_floor(value / 16)
			hex = zo_strsub('0123456789ABCDEF', index, index) .. hex
		end
		-- d(value .. ' : ' .. hex)
		if (strlen(hex) == 0) then
			hex = '00'
		elseif (strlen(hex) == 1) then
			hex = '0' .. hex
		end
		-- d("hex: " .. hex)

		hexadecimal = hexadecimal .. hex

		-- d("hexadecimal: " .. hexadecimal)
	end

	return hexadecimal
end

function PVP:HSVToRGB(hue, saturation, value)
	if saturation == 0 then
		return value, value, value
	end
	;

	-- Get the hue sector
	local hue_sector = zo_floor(hue / 60)
	local hue_sector_offset = (hue / 60) - hue_sector

	local p = value * (1 - saturation)
	local q = value * (1 - saturation * hue_sector_offset)
	local t = value * (1 - saturation * (1 - hue_sector_offset))

	if hue_sector == 0 then
		return value, t, p
	elseif hue_sector == 1 then
		return q, value, p
	elseif hue_sector == 2 then
		return p, value, t
	elseif hue_sector == 3 then
		return p, q, value
	elseif hue_sector == 4 then
		return t, p, value
	elseif hue_sector == 5 then
		return value, p, q
	end
end

function PVP:RGBToHSV(red, green, blue)
	local hue, saturation, value

	local min_value = zo_min(red, green, blue)
	local max_value = zo_max(red, green, blue)

	value = max_value;

	local value_delta = max_value - min_value
	if max_value ~= 0 then
		saturation = value_delta / max_value
	else
		saturation = 0
		hue = -1
		return hue, saturation, value
	end

	if red == max_value then
		hue = (green - blue) / value_delta;
	elseif green == max_value then
		hue = 2 + (blue - red) / value_delta;
	else
		hue = 4 + (red - green) / value_delta;
	end

	hue = hue * 60;
	if hue < 0 then
		hue = hue + 360;
	end

	return hue, saturation, value
end

function PVP:GetColorBrightnessAdjusted(originalColor, percent)
	-- local red = zo_strsub(originalColor, 1, 2)
	-- local green = zo_strsub(originalColor, 3, 4)
	-- local blue = zo_strsub(originalColor, 5, 6)
	local hue, saturation, value = self:RGBToHSV(self:HtmlToColor(originalColor))
	-- d(hue)
	-- d(saturation)
	-- d(value)
	local red, green, blue = self:HSVToRGB(hue, saturation, value * percent / 100)
	-- d(red)
	-- d(green)
	-- d(blue)
	return PVP:RGBtoHEX({ red * 255, green * 255, blue * 255 })
end

function PVP:GetTimeFadedColor(color, id, currentTime)
	if (not self.detailedTooltipCalc) or (not self.totalPlayers[id]) then return color end

	local timeDelta = currentTime - self.totalPlayers[id]
	if (timeDelta < PVP_ID_RETAIN_TIME) then return color end
	local bottomPercent = 10
	local percent = bottomPercent +
		(100 - bottomPercent) * (PVP_ID_RETAIN_TIME_EFFECT - timeDelta) /
		(PVP_ID_RETAIN_TIME_EFFECT - PVP_ID_RETAIN_TIME)
	if (percent < bottomPercent) then percent = bottomPercent end
	return self:GetColorBrightnessAdjusted(color, percent)
end

function PVP:IsInPVPZone()
	return IsPlayerInAvAWorld() or IsActiveWorldBattleground()
	-- return IsUnitPvPFlagged('player') and GetDuelInfo() ~= 3
end

function PVP:IsValidBattlegroundContext(battlegroundContext)
	return battlegroundContext == 1 or battlegroundContext == 3
end

function PVP:IsScrollTemple(zoneName)
	local startIndex, endIndex = zo_strfind(zoneName, 'Scroll Temple')

	if startIndex then
		zoneName = zo_strsub(zoneName, startIndex, endIndex) ..
			' of' .. zo_strsub(zoneName, endIndex + 1, strlen(zoneName))
	end

	return zoneName
end

function PVP:ReanchorControl(control, newOffsetX, newOffsetY)
	local _, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()

	control:ClearAnchors()
	control:SetAnchor(point, relativeTo, relativePoint, newOffsetX, newOffsetY)
end

function PVP:CombineAllianceInfo(alliance1, alliance2)
	local alliance
	if alliance1 and alliance1 ~= 0 then
		alliance = alliance1
	elseif alliance2 and alliance2 ~= 0 then
		alliance = alliance2
	else
		alliance = 0
	end
	return alliance
end

function PVP:StringStart(String, Start)
	return zo_strsub(String, 1, strlen(Start)) == Start
end

function PVP:StringEnd(String, End)
	return End == '' or zo_strsub(String, -strlen(End)) == End
end

function PVP:Colorize(text, color)
	local combineTable = { "|c", color, tostring(text), "|r" }
	return concat(combineTable)
end

function PVP:HtmlToColor(html, isDark, isBright)
	local r, g, b
	r = tonumber(zo_strsub(html, 1, 2), 16) / 255
	g = tonumber(zo_strsub(html, 3, 4), 16) / 255
	b = tonumber(zo_strsub(html, 5, 6), 16) / 255

	if isDark then
		return 0.5 * r, 0.5 * g, 0.5 * b
	elseif isBright then
		local ratio = 0.9 / zo_max(zo_max(r, g), b)

		if ratio < 1 then ratio = 1 / zo_max(zo_max(r, g), b) end

		return ratio * r, ratio * g, ratio * b
	else
		return r, g, b
	end
end

function PVP:DeaccentString(inputString)
	if (not inputString) or (inputString == "") then return end
	for k, v in pairs(self.accents) do
		inputString = strgsub(inputString, k, v)
	end
	return inputString
end

function PVP:PointIsInsideOfTrapezoid(districtId, pointX, pointY)
	local trap1, trap2, trap3, trap4, trap12, trap23, trap34, trap41, trapArea = PVP.ICtrapeziods[districtId].trap1,
		PVP.ICtrapeziods[districtId].trap2, PVP.ICtrapeziods[districtId].trap3, PVP.ICtrapeziods[districtId].trap4,
		PVP.ICtrapeziods[districtId].trap12, PVP.ICtrapeziods[districtId].trap23, PVP.ICtrapeziods[districtId].trap34,
		PVP.ICtrapeziods[districtId].trap41, PVP.ICtrapeziods[districtId].trapArea
	local pointToTrap1 = zo_distance(pointX, pointY, trap1.x, trap1.y)
	local pointToTrap2 = zo_distance(pointX, pointY, trap2.x, trap2.y)
	local pointToTrap3 = zo_distance(pointX, pointY, trap3.x, trap3.y)
	local pointToTrap4 = zo_distance(pointX, pointY, trap4.x, trap4.y)

	local function triangleArea(side1, side2, side3)
		local p = 0.5 * (side1 + side2 + side3)
		local area = sqrt(p * (p - side1) * (p - side2) * (p - side3))
		return area
	end

	local pointTrapArea = triangleArea(trap12, pointToTrap1, pointToTrap2) +
		triangleArea(trap23, pointToTrap2, pointToTrap3) + triangleArea(trap34, pointToTrap3, pointToTrap4) +
		triangleArea(trap41, pointToTrap4, pointToTrap1)

	local PVP_GRACE_TRAP_AREA = 0.1

	return pointTrapArea <= trapArea
end

function PVP:PlayLoudSound(sound)
	PlaySound(SOUNDS[sound])
	PlaySound(SOUNDS[sound])
end

function PVP:IsWorldMapHidden()
	return WORLD_MAP_SCENE:GetState() == "hidden"
end

function PVP:AllianceToColor(alliance, passive)
	if alliance == 1 then
		if passive then return PVP_DIMMED_AD_COLOR else return PVP_BRIGHT_AD_COLOR end
	elseif alliance == 2 then
		if passive then return PVP_DIMMED_EP_COLOR else return PVP_BRIGHT_EP_COLOR end
	elseif alliance == 3 then
		if passive then return PVP_DIMMED_DC_COLOR else return PVP_BRIGHT_DC_COLOR end
	else
		return 'FFFFFF'
	end
end

function PVP:NameToAllianceColor(unitName, passive, overrideBgColor, unitAlliance)
	if not overrideBgColor and IsActiveWorldBattleground() and PVP.bgNames and PVP.bgNames[unitName] then
		return PVP:BgAllianceToHexColor(PVP.bgNames[unitName])
	end

	if self.SV.playersDB[unitName] and not unitAlliance then
		unitAlliance = self.SV.playersDB[unitName].unitAlliance
	end
	return PVP:AllianceToColor(unitAlliance, passive)
end

function PVP:IdToAllianceColor(unitId, passive)
	local unitName = self.idToName[unitId]
	if IsActiveWorldBattleground() and PVP.bgNames and PVP.bgNames[unitName] then
		return PVP:BgAllianceToHexColor(PVP
			.bgNames[unitName])
	end
	if unitName and self.SV.playersDB[unitName] and self.SV.playersDB[unitName].unitAlliance then
		return self:NameToAllianceColor(unitName, passive)
	else
		return false
	end
end

function PVP:GetUnitAllianceFromDb(unitId)
	local unitName = self.idToName[unitId]
	if unitName and self.SV.playersDB[unitName] and self.SV.playersDB[unitName].unitAlliance then
		return self.SV.playersDB[unitName].unitAlliance
	else
		return false
	end
end

function PVP:GetUnitSpecColor(playerName)
	local specFromDB, color
	local isPlayer = playerName == self.playerName

	if not isPlayer and self.SV.playersDB[playerName] then
		specFromDB = self.SV.playersDB[playerName].unitSpec
	end

	if specFromDB then
		if specFromDB == "stam" then
			color = PVP_STAMINA_COLOR
		elseif specFromDB == "mag" then
			color = PVP_MAGICKA_COLOR
		else
			color = PVP_HYBRID_COLOR
		end
	else
		color = "FFFFFF"
	end

	return ZO_ColorDef:New(color)
end

function PVP:GetFormattedClassIcon(playerName, dimension, allianceColor, isDeadorResurrect, isTargetFrame,
								   isTargetNameFrame, unitClass, id, currentTime, unitAvARank, playerDbRecord)
	local isPlayer = playerName == self.playerName

	playerDbRecord = playerDbRecord or self.SV.playersDB[playerName]

	if ((not playerDbRecord) or (playerDbRecord == "none")) and (not isPlayer) and (not unitClass) then
		return unitAvARank and self:GetFormattedAvaRankIcon(unitAvARank, allianceColor, dimension, playerName) or ""
	end

	if playerDbRecord == "none" then playerDbRecord = nil end

	dimension = isTargetNameFrame and 45 or (dimension or 29)
	local specFromDB = not isPlayer and playerDbRecord and playerDbRecord.unitSpec
	local color =
		(isDeadorResurrect and "808080") or (specFromDB == "stam" and PVP_STAMINA_COLOR) or
		(specFromDB == "mag" and PVP_MAGICKA_COLOR) or
		(specFromDB and PVP_HYBRID_COLOR) or
		"808080"

	unitClass = unitClass or (isPlayer and GetUnitClassId("player")) or (playerDbRecord and playerDbRecord.unitClass)

	local startSpacer, endSpacer = "", ""
	if not isTargetFrame and unitClass then
		if unitClass == 2 then
			dimension = dimension - 3
			startSpacer = zo_iconFormat(PVP_SPACER_ICON, 2, 2)
			endSpacer = startSpacer
		elseif unitClass == 1 then
			dimension = dimension - 2
			startSpacer = zo_iconFormat(PVP_SPACER_ICON, 2, 2)
			endSpacer = zo_iconFormat(PVP_SPACER_ICON, 1, 1)
		elseif unitClass == 6 then
			startSpacer = zo_iconFormat(PVP_SPACER_ICON, 1, 1)
		end
	end

	local mundus = ""
	if playerDbRecord and playerDbRecord.mundus then
		local mundusColor = self.mundusColors[playerDbRecord.mundus] or "FFFFFF"
		local mundusDimension = isTargetNameFrame and 32 or 21
		mundus =
			zo_iconFormatInheritColor(
			"PvpAlerts/textures/" .. playerDbRecord.mundus .. "m.dds",
			mundusDimension,
			mundusDimension
		)
		if id and currentTime then
			mundusColor = self:GetTimeFadedColor(mundusColor, id, currentTime)
		end
		mundus = self:Colorize(mundus, mundusColor)
	end

	local classIcon = unitClass and zo_iconFormatInheritColor(self.classIcons[unitClass], dimension, dimension) or ""
	classIcon = self:Colorize(classIcon, color)

	unitAvARank = unitAvARank or playerDbRecord and playerDbRecord.unitAvARank
	local avaRankIcon = unitAvARank and self:Colorize(
			zo_iconFormatInheritColor(GetAvARankIcon(unitAvARank), dimension, dimension),
			allianceColor
		) or
		""

	if id and currentTime then
		color = self:GetTimeFadedColor(color, id, currentTime)
	end

	return startSpacer .. mundus .. classIcon .. endSpacer .. avaRankIcon
end

function PVP:GetFormattedAvaRankIcon(unitAvARank, allianceColor, dimension, playerName)
	local avaRankIcon
	dimension = dimension or 29
	if unitAvARank then
		avaRankIcon = self:Colorize(zo_iconFormatInheritColor(GetAvARankIcon(unitAvARank), dimension, dimension),
			allianceColor)
	else
		local playerDbRecord = self.SV.playersDB[playerName]
		if playerDbRecord and playerDbRecord.unitAvARank then
		unitAvARank = playerDbRecord.unitAvARank
		avaRankIcon = self:Colorize(zo_iconFormatInheritColor(GetAvARankIcon(unitAvARank), dimension, dimension),
			allianceColor)
		else
			avaRankIcon = ""
		end
	end
	return avaRankIcon
end

function PVP:GetFormattedName(playerName, truncate)
	local formattedName = zo_strformat(SI_UNIT_NAME, playerName)
	if truncate then
		local iconsCutOff

		if truncate == 1 then
			iconsCutOff = 3
		elseif truncate == 2 then
			iconsCutOff = 6
		elseif truncate == 0 then
			iconsCutOff = 0
		end

		local cutOff = 22 - iconsCutOff

		local substringCutOff
		local _, accentedSymbolsIndice = PVP:FindUTFIndice(formattedName)

		if accentedSymbolsIndice == {} then
			substringCutOff = cutOff - 1
		else
			local numberSpecial = 0
			local numAccented = #accentedSymbolsIndice
			for i = 1, numAccented do
				if accentedSymbolsIndice[i] <= (cutOff - 1) then
					numberSpecial = numberSpecial + 1
				end
			end
			substringCutOff = cutOff + numberSpecial - 1
		end


		if strlen(formattedName) >= cutOff then
			formattedName = zo_strsub(formattedName, 1, substringCutOff) .. ".."
		end
	end

	return formattedName
end

function PVP:GetFormattedCharNameLink(playerName, truncate)
	return ZO_LinkHandler_CreateLinkWithoutBrackets(self:GetFormattedName(playerName, truncate), nil, CHARACTER_LINK_TYPE,
		playerName)
end

function PVP:GetFormattedClassNameLink(playerName, allianceColor, truncate, isDeadorResurrect, isTargetFrame,
									   isTargetNameFrame, unitClass, id, currentTime, unitAvARank, playerDbRecord)		   
	return self:GetFormattedClassIcon(playerName, nil, allianceColor, isDeadorResurrect, isTargetFrame, isTargetNameFrame,
			unitClass, id, currentTime, unitAvARank, playerDbRecord) ..
		self:Colorize(self:GetFormattedCharNameLink(playerName, truncate), allianceColor)
end

function PVP:GetFormattedAccountNameLink(accName, color)
	return self:Colorize(ZO_LinkHandler_CreateLinkWithoutBrackets(accName, nil, DISPLAY_NAME_LINK_TYPE, accName), color)
end

function PVP:GetReticleFormattedName(playerName)
	return self:GetFormattedClassIcon(playerName, nil, self:NameToAllianceColor(playerName)) ..
		self:Colorize(self:GetFormattedName(playerName), self:NameToAllianceColor(playerName))
end

function PVP:GetGroupIcon(dimension)
	dimension = dimension or 24
	return self:Colorize(zo_iconFormatInheritColor(PVP_GROUP_ICON, dimension, dimension), "40BB40") --C59B00
end

function PVP:GetGroupLeaderIcon(dimension)
	dimension = dimension or 24
	return self:Colorize(zo_iconFormatInheritColor(PVP_GROUPLEADER_ICON, dimension, dimension), "40BB40") --C59B00
end

function PVP:GetIcon(icon, dimension, color)
	dimension = dimension or 50
	color = color or "FFFFFF"
	return self:Colorize(zo_iconFormatInheritColor(icon, dimension, dimension), color)
end

function PVP:GetFriendIcon(dimension)
	dimension = dimension or 20
	return self:Colorize(zo_iconFormatInheritColor(PVP_FRIEND_ICON, dimension, dimension), "40BB40")
end

function PVP:GetGuildIcon(dimension, color)
	dimension = dimension or 20
	color = color or "FFFFFF"
	return self:Colorize(zo_iconFormatInheritColor(PVP_GUILD_ICON, dimension, dimension), color)
end

function PVP:GetCoolIcon(dimension, dimmed)
	dimension = dimension or 20
	local color
	if dimmed then color = "30AA30" else color = "40BB40" end
	return self:Colorize(zo_iconFormatInheritColor(PVP_COOL_ICON, dimension, dimension), "40BB40")
end

function PVP:GetKOSIcon(dimension, color)
	dimension = dimension or 30
	color = color or "BB4040"
	return self:Colorize(zo_iconFormatInheritColor(PVP_IMPORTANT_ICON, dimension, dimension), color)
end

function PVP:GetEyeIcon(dimension, color)
	dimension = dimension or 20
	color = color or "FFFFFF"
	return self:Colorize(zo_iconFormatInheritColor(PVP_EYE_ICON, dimension, dimension), color)
end

function PVP:GetDeathIcon(dimension, color)
	dimension = dimension or 28
	color = color or "FFFFFF"
	return self:Colorize(zo_iconFormatInheritColor(PVP_KILLING_BLOW, dimension, dimension), color)
end

function PVP:GetAttackerIcon(dimension, color)
	dimension = dimension or 30
	color = color or "FFFFFF"
	return self:Colorize(zo_iconFormatInheritColor(PVP_ATTACKER, dimension, dimension), color)
end

function PVP:GetEmperorIcon(dimension, color)
	dimension = dimension or 20
	color = color or "FFFFFF"
	return self:Colorize(zo_iconFormatInheritColor(PVP_EMPEROR, dimension, dimension), color)
end

-- function PVP:GetTargetIcon(dimension, color)
-- dimension = dimension or 22
-- color = color or "FFFFFF"
-- return self:Colorize(zo_iconFormatInheritColor(PVP_STAMINA, dimension, dimension), color)
-- end

function PVP:GetFightIcon(dimension, color, targetAlliance)
	dimension = dimension or 24
	color = color or "FFFFFF"

	local fightIcons = {
		[ALLIANCE_ALDMERI_DOMINION] = {
			[ALLIANCE_EBONHEART_PACT] = PVP_FIGHT_ADEP,
			[ALLIANCE_DAGGERFALL_COVENANT] = PVP_FIGHT_ADDC
		},
		[ALLIANCE_EBONHEART_PACT] = {
			[ALLIANCE_ALDMERI_DOMINION] = PVP_FIGHT_EPAD,
			[ALLIANCE_DAGGERFALL_COVENANT] = PVP_FIGHT_EPDC
		},
		[ALLIANCE_DAGGERFALL_COVENANT] = {
			[ALLIANCE_ALDMERI_DOMINION] = PVP_FIGHT_DCAD,
			[ALLIANCE_EBONHEART_PACT] = PVP_FIGHT_DCEP
		}
	}

	local icon = fightIcons[self.allianceOfPlayer] and fightIcons[self.allianceOfPlayer][targetAlliance] or ""

	return self:Colorize(zo_iconFormatInheritColor(icon, dimension, dimension), color)
end

function PVP:GetResurrectIcon(dimension, color)
	dimension = dimension or 32
	color = color or "AAAAAA"
	return self:Colorize(zo_iconFormatInheritColor(PVP_RESURRECT, dimension, dimension), color)
end

function PVP:ScaleControls(control, textControl, defaultFontSize, scale, ratioX)
	ratioX = ratioX or 1
	textControl:SetWidth(control:GetWidth() * ratioX)
	textControl:SetHeight(control:GetHeight())

	local fontSize = zo_round(defaultFontSize * scale)
	local font = "$(BOLD_FONT)|$(KB_" .. fontSize .. ")|soft-shadow-thick"
	textControl:SetFont(font)
end

function PVP:FindUTFIndice(name)
	local indice, indiceAccented = {}, {}
	local substring = name
	local before, after, skip
	local count = 0
	for i = 1, strlen(name) - 1 do
		if strlen(substring) == strlen(PVP:DeaccentString(substring)) then break end
		if not skip then
			before = strlen(PVP:DeaccentString(substring))
			substring = zo_strsub(substring, 2, strlen(substring))
			after = strlen(PVP:DeaccentString(substring))
			if after - before == 0 then
				insert(indice, (i - count))
				insert(indiceAccented, i)
				count = count + 1
				skip = true
			end
		else
			substring = zo_strsub(substring, 2, strlen(substring))
			skip = false
		end
	end
	return indice, indiceAccented
end

function PVP:TableConcat(t1, t2)
	if next(t2) == nil then return t1 end
	local numT2 = #t2
	for i = 1, numT2 do
		t1[#t1 + 1] = t2[i]
	end
	return t1
end

function PVP:IsPlayerCCImmune(currentTime, abilityDuration)
	if not abilityDuration then abilityDuration = 1 end
	local ccImmunity = self.ccImmunity
	for abilityName, endTime in pairs(ccImmunity) do
		if ccImmunityBuffs[abilityName] then
			if (currentTime + abilityDuration) < endTime then
				return true
			end
		end
	end
	return false
end

function PVP:InsertAnimationType(animHandler, animType, control, animDuration, animDelay, animEasing, ...)
	if not animHandler then return end

	local animation, startValues, endValues

	if animType == ANIMATION_SCALE then
		animation, startValues, endValues = animHandler:InsertAnimation(ANIMATION_SCALE, control, animDelay), ...
		if select(4, ...) then
			startValues = startValues * self.SV.controlScale
			endValues = endValues * self.SV.controlScale
		end
		animation:SetScaleValues(startValues, endValues)
	elseif animType == ANIMATION_ALPHA then
		animation, startValues, endValues = animHandler:InsertAnimation(ANIMATION_ALPHA, control, animDelay), ...
		animation:SetAlphaValues(startValues, endValues)
	elseif animType == ANIMATION_TRANSLATE then
		animation, startValues, endValues = animHandler:InsertAnimation(ANIMATION_TRANSLATE, control, animDelay), ...
		animation:SetTranslateOffsets(startValues, endValues)
	elseif animType == ANIMATION_ROTATE3D then
		animation, startValues, endValues = animHandler:InsertAnimation(ANIMATION_ROTATE3D, control, animDelay), ...
		animation:SetRotationValues(startValues, endValues)
	elseif animType == ANIMATION_COLOR then
		animation, startValues, endValues = animHandler:InsertAnimation(ANIMATION_COLOR, control, animDelay), ...
		animation:SetRotationValues(startValues, endValues)
	end

	if animation then
		animation:SetDuration(animDuration)
		animation:SetEasingFunction(animEasing)
	end
end

function PVP:ProcessLengths(namesTable, maxLength, addedLength)
	-- local function GetTextWidthInPixels(text)
	-- PVP_Counter_TestWidth:SetFont("ZoFontWinH5")
	-- PVP_Counter_TestWidth:SetText(text)
	-- local width = PVP_Counter_TestWidth:GetTextWidth()
	-- return width
	-- return strlen(text) * 2
	-- end

	-- local maxLength=0
	addedLength = addedLength or 0
	local numNames = #namesTable
	for i = 1, numNames do
		if self:StringEnd(namesTable[i], "+") then
			if addedLength < 35 then addedLength = 35 end
			namesTable[i] = zo_strsub(namesTable[i], 1, (strlen(namesTable[i]) - 1))
		elseif self:StringEnd(namesTable[i], "%") then
			if addedLength < 45 then addedLength = 45 end
			namesTable[i] = zo_strsub(namesTable[i], 1, (strlen(namesTable[i]) - 1))
		elseif self:StringEnd(namesTable[i], "%*") then
			if addedLength < 65 then addedLength = 65 end
			namesTable[i] = zo_strsub(namesTable[i], 1, (strlen(namesTable[i]) - 2))
		elseif self:StringEnd(namesTable[i], "+*") then
			if addedLength < 55 then addedLength = 55 end
			namesTable[i] = zo_strsub(namesTable[i], 1, (strlen(namesTable[i]) - 2))
		elseif self:StringEnd(namesTable[i], "%**") then
			if addedLength < 75 then addedLength = 75 end
			namesTable[i] = zo_strsub(namesTable[i], 1, (strlen(namesTable[i]) - 3))
		elseif self:StringEnd(namesTable[i], "+**") then
			if addedLength < 65 then addedLength = 65 end
			namesTable[i] = zo_strsub(namesTable[i], 1, (strlen(namesTable[i]) - 3))
		elseif self:StringEnd(namesTable[i], "**") then
			if addedLength < 45 then addedLength = 45 end
			namesTable[i] = zo_strsub(namesTable[i], 1, (strlen(namesTable[i]) - 2))
		elseif self:StringEnd(namesTable[i], "*") then
			if addedLength < 40 then addedLength = 40 end
			namesTable[i] = zo_strsub(namesTable[i], 1, (strlen(namesTable[i]) - 1))
		end
	end
	return 6 * maxLength + 90 + addedLength
	-- return 6*maxLength + 70 + addedLength
end

function PVP:ShouldShowCampFrame()
	return self.SV.showCampFrame and not IsActiveWorldBattleground()
end

function PVP:IsNPCAbility(abilityId)
	return self.excludedAbilityIds[abilityId] and true or false
end

function PVP:CheckName(unitName)
	return (self.SV.playersDB[unitName] or self:StringEnd(unitName, "^Mx") or self:StringEnd(unitName, "^Fx")) and true or
		false
end

function PVP:GetTrueAllianceColors(alliance)
	return GetAllianceColor(alliance):UnpackRGB()
end

function PVP:GetTrueAllianceColorsHex(alliance)
	return GetAllianceColor(alliance):ToHex()
end

function PVP:IsMalformedName(name)
	return not (PVP:StringEnd(name, '^Mx') or PVP:StringEnd(name, '^Fx'))
end

function PVP:GetValidName(name)
	if not name or name == '' then return end
	if not self:IsMalformedName(name) then return name end
	-- if not PVP.bgNames then return end

	if IsActiveWorldBattleground() then
		local bgNames = self.bgNames
		if bgNames and bgNames[name .. '^Mx'] then return name .. '^Mx' end
		if bgNames and bgNames[name .. '^Fx'] then return name .. '^Fx' end
	else
		local playersDb = self.SV.playersDB
		if playersDb and playersDb[name .. '^Mx'] then return name .. '^Mx' end
		if playersDb and playersDb[name .. '^Fx'] then return name .. '^Fx' end
	end
end

function PVP:GetRootNames(name)
	if not name or name == '' then return "" end
	local rootName = name:gsub("%s*%^[MF]x%s*$", "")
	return rootName or ""
end

function PVP:UpdatePlayerDbAccountName(unitCharName, unitAccName, oldUnitAccName)
	local nameChangeNote = " (AutoNote: Previous name " .. oldUnitAccName .. ")"

	local isOnList

	local playersCP = PVP.SV.CP
	local oldCP = playersCP[oldUnitAccName]
	local newCP = playersCP[unitAccName]
	if oldCP then
		if not newCP or (newCP == 0) then
			playersCP[unitAccName] = oldCP
			playersCP[oldUnitAccName] = nil
		elseif oldCP > newCP then
			if databaseIntegrityCheck[unitCharName] then return end
			PVP.CHAT:Printf(
				"Possible player name change from %s to %s, seen for character %s, but this requires a CP decrease.",
				self:GetFormattedAccountNameLink(oldUnitAccName, "FFFFFF"),
				self:GetFormattedAccountNameLink(unitAccName, "FFFFFF"),
				self:GetFormattedCharNameLink(unitCharName))
			databaseIntegrityCheck[unitCharName] = true
			return
		end
		playersCP[oldUnitAccName] = nil
	end

	local playersDB = PVP.SV.playersDB
	for k, v in pairs(playersDB) do
		if v.unitAccName == oldUnitAccName then
			playersDB[k].unitAccName = unitAccName
		end
	end

	local KOSList = PVP.SV.KOSList
	for k, v in ipairs(KOSList) do
		if v.unitAccName == oldUnitAccName then
			KOSList[k].unitAccName = unitAccName
			isOnList = true
			PVP.KOSAccList[unitAccName] = true
		end
	end

	local coolList = PVP.SV.coolList
	for k, v in pairs(coolList) do
		if v == oldUnitAccName then
			coolList[k] = unitAccName
			isOnList = true
			PVP.coolAccList[unitAccName] = true
		end
	end

	local guildmates = PVP.guildmates
	if guildmates[oldUnitAccName] then
		guildmates[unitAccName] = guildmates[oldUnitAccName]
		guildmates[oldUnitAccName] = nil
	end

	local playerNotes = PVP.SV.playerNotes
	if playerNotes[oldUnitAccName] then
		local oldNote = playerNotes[oldUnitAccName] or ""
		local currentNote = playerNotes[unitAccName] or ""
		local combinedNote = ((oldNote ~= "" and oldNote) or "")
		combinedNote = combinedNote .. ((currentNote ~= "" and " " .. currentNote) or "")
		combinedNote = combinedNote .. ((nameChangeNote ~= "" and " " .. nameChangeNote) or "")
		playerNotes[unitAccName] = combinedNote
		playerNotes[oldUnitAccName] = nil
	else
		if isOnList then
			playerNotes[unitAccName] = nameChangeNote
		end
	end

	PVP.CHAT:Printf("Name Change! Player %s was previously known as %s",
		self:GetFormattedAccountNameLink(unitAccName, "76BCC3"), self:Colorize(oldUnitAccName, "FFFFFF"))
end

function PVP:BgAllianceToHexColor(bgAlliance)
	return ZO_ColorDef:New(GetBattlegroundTeamColor(bgAlliance)):ToHex()
end

-- 255, 45, 30 alliance 1 color

-- 255, 73, 147 alliance 3 color

function PVP:GetPlayerMarkerBgAllianceHexColor(bgAlliance)
	-- local allianceColor = ZO_ColorDef:New(GetBattlegroundTeamColor(bgAlliance)):ToHex()
	local r, g, b
	if bgAlliance == 1 then
		r = 255 / 255
		g = 60 / 255
		b = 35 / 255
	elseif bgAlliance == 3 then
		r = 255 / 255
		g = 73 / 255
		b = 147 / 255
	elseif bgAlliance == 2 then
		r, g, b = ZO_ColorDef:New(GetBattlegroundTeamColor(bgAlliance)):UnpackRGB()
	end

	return ZO_ColorDef:New(r, g, b, 1):ToHex()
end

function PVP:GetBattlegroundTeamBadgeIcon(alliance)
	local icon
	if alliance == 1 then
		icon = "EsoUI/Art/Stats/battleground_alliance_badge_Fire_Drakes.dds"
	elseif alliance == 2 then
		icon = "EsoUI/Art/Stats/battleground_alliance_badge_Pit_Daemons.dds"
	elseif alliance == 3 then
		icon = "EsoUI/Art/Stats/battleground_alliance_badge_Storm_Lords.dds"
	end
	return icon
end

function PVP:GetBattlegroundTeamBadgeTextFormattedIcon(alliance, dimensionX, dimensionY)
	dimensionX = dimensionX or 32
	dimensionY = dimensionY or 32

	local icon = PVP:GetBattlegroundTeamBadgeIcon(alliance)

	-- return ZO_ColorDef:New(GetBattlegroundTeamColor(alliance)):Colorize(zo_iconFormatInheritColor(icon, dimensionX, dimensionY))
	return zo_iconFormatInheritColor(icon, dimensionX, dimensionY)
end

function PVP:ColorizeToBgTeamColor(alliance, text)
	return ZO_ColorDef:New(GetBattlegroundTeamColor(alliance)):Colorize(text)
end

function PVP:GetBattlegroundTypeText(battlegroundGameType)
	local battlegroundTypeString
	if battlegroundGameType == BATTLEGROUND_GAME_TYPE_CAPTURE_THE_FLAG then
		battlegroundTypeString = "Capture The Flag"
	elseif battlegroundGameType == BATTLEGROUND_GAME_TYPE_DEATHMATCH then
		battlegroundTypeString = "Deathmatch"
	elseif battlegroundGameType == BATTLEGROUND_GAME_TYPE_DOMINATION then
		battlegroundTypeString = "Domination"
	else
		battlegroundTypeString = ""
	end
	return battlegroundTypeString
end

function PVP_Test_Scale(scale)
	PVP.testScale = scale
	PVP:FullReset3DIcons()
	PVP:InitControls()
end

function PVP_GetIDs()
	for i = 1, GetNumObjectives() do
		local keepId, objectiveId, bgContext = GetObjectiveIdsForIndex(i)
		local name = GetObjectiveInfo(keepId, objectiveId, bgContext)
		if keepId == 0 and bgContext == BGQUERY_LOCAL and DoesObjectiveExist(keepId, objectiveId, bgContext) then
			d('objectiveId: ' .. tostring(objectiveId) .. ' name: ' .. tostring(name))
		end
	end
end

function PVP_GetIDCoords()
	for i = 1, GetNumObjectives() do
		local keepId, objectiveId, bgContext = GetObjectiveIdsForIndex(i)
		local name = GetObjectiveInfo(keepId, objectiveId, bgContext)
		if keepId == 0 and bgContext == BGQUERY_LOCAL and DoesObjectiveExist(keepId, objectiveId, bgContext) then
			local pin, X, Y = GetObjectivePinInfo(keepId, objectiveId, bgContext)
			d('objectiveId: ' .. tostring(objectiveId) .. ' name: ' .. tostring(name))
			d('X: ' .. tostring(X) .. ' Y: ' .. tostring(Y))
		end
	end
end

function PVP:IsSupportedBattlegroundId(battlegroundId)
	-- return PVP.ullaraIds[battlegroundId] or PVP.foyadaIds[battlegroundId] or PVP.aldIds[battlegroundId] or PVP.arcaneIds[battlegroundId]
	if PVP.ullaraIds[battlegroundId] or PVP.foyadaIds[battlegroundId] or PVP.aldIds[battlegroundId] then
		return true
	else
		return false
	end
	-- return PVP.ullaraIds[battlegroundId] or PVP.foyadaIds[battlegroundId] or PVP.aldIds[battlegroundId]
end

function PVP:IsInSupportedBattleground()
	return IsActiveWorldBattleground() and PVP:IsSupportedBattlegroundId(GetCurrentBattlegroundId())
end

function PVP:IsInSupportedBattlegroundGametype()
	local supportedGametypes = {
		[BATTLEGROUND_GAME_TYPE_CAPTURE_THE_FLAG] = true,
		[BATTLEGROUND_GAME_TYPE_DEATHMATCH] = true,
		[BATTLEGROUND_GAME_TYPE_DOMINATION] = true,
	}

	local function isSupportedGametype(battlegroundId)
		return supportedGametypes[GetBattlegroundGameType(battlegroundId)]
	end

	return IsActiveWorldBattleground() and isSupportedGametype(GetCurrentBattlegroundId())
end

function PVP:GetBgBaseInfo(battlegroundId)
	if not battlegroundId then return nil end
	if PVP.ullaraIds[battlegroundId] then
		return PVP.bgTeamBasesFull.ul
	elseif PVP.foyadaIds[battlegroundId] then
		return PVP.bgTeamBasesFull.foya
	elseif PVP.aldIds[battlegroundId] then
		return PVP.bgTeamBasesFull.ald
	end
end

function PVP:GetBgMapScale(battlegroundId)
	local ULLARA_SCALE = 294
	local FOYADA_SCALE = 294
	local ALD_SCALE = 316
	local ARCANE_SCALE = 294

	if PVP.ullaraIds[battlegroundId] then
		return ULLARA_SCALE
	elseif PVP.foyadaIds[battlegroundId] then
		return FOYADA_SCALE
	elseif PVP.aldIds[battlegroundId] then
		return ALD_SCALE
	elseif PVP.arcaneIds[battlegroundId] then
		return ARCANE_SCALE
	else
		return nil
	end
end

function PVP:GetDMPowerups(battlegroundId)
	if PVP.ullaraIds[battlegroundId] then
		return PVP.bgDamagePowerups.ullara
	elseif PVP.foyadaIds[battlegroundId] then
		return PVP.bgDamagePowerups.foyada
	elseif PVP.aldIds[battlegroundId] then
		return PVP.bgDamagePowerups.ald
	elseif PVP.arcaneIds[battlegroundId] then
		-- return PVP.bgDamagePowerups.arcane
		return nil
	else
		return nil
	end
end

function PVP:AvAHax()
	local GetAvARankIcon_original = GetAvARankIcon
	GetAvARankIcon = function(rank)
		if rank == 50 and self.SV.show6star then
			return PVP_6STAR
		else
			return GetAvARankIcon_original(rank)
		end
	end

	local GetLargeAvARankIcon_original = GetLargeAvARankIcon
	GetLargeAvARankIcon = function(rank)
		if rank == 50 and self.SV.show6star then
			return PVP_6STAR
		else
			return GetLargeAvARankIcon_original(rank)
		end
	end

	ZO_CampaignAvARank_OnInitialized(ZO_CampaignAvARank)
end

function PVP:GetNeighbors(keepId)
	local neighbors = {}
	local resourceType = GetKeepResourceType(keepId)
	if resourceType ~= 0 then
		local foundResourceKeepId, resourceNumber
		for i = 1, 200 do
			local resourceKeepType = GetKeepType(i)
			if resourceKeepType == KEEPTYPE_KEEP then
				for j = 1, 3 do
					if GetResourceKeepForKeep(i, j) == keepId then
						foundResourceKeepId = i
						resourceNumber = j
						break
					end
				end
			end
			if foundResourceKeepId then break end
		end

		if foundResourceKeepId then
			neighbors[1] = foundResourceKeepId
			local resource1, resource2
			if resourceNumber == 1 then
				resource1 = 2
				resource2 = 3
			elseif resourceNumber == 2 then
				resource1 = 1
				resource2 = 3
			else
				resource1 = 1
				resource2 = 2
			end
			neighbors[2] = GetResourceKeepForKeep(foundResourceKeepId, resource1)
			neighbors[3] = GetResourceKeepForKeep(foundResourceKeepId, resource2)
		end
	elseif GetKeepType(keepId) == KEEPTYPE_KEEP then
		neighbors[1] = GetResourceKeepForKeep(keepId, 1)
		neighbors[2] = GetResourceKeepForKeep(keepId, 2)
		neighbors[3] = GetResourceKeepForKeep(keepId, 3)
	end

	return neighbors[1], neighbors[2], neighbors[3]
end

function PVP:TestThisScale()
	if not PVP:IsInSewers() then return end
	if PVP.testIterator and PVP.testIterator > 10000 then return end
	if not PVP.minDeviation then
		PVP.minDeviation = 1000
		PVP.bestScale = 0
	end
	if not PVP.testIterator then PVP.testIterator = 2500 end
	local i = PVP.testIterator
	d(i)
	PVP.testScale = i
	PVP:InitControls()
	local objects = PVP.controls3DPool:GetActiveObjects()
	for k, v in pairs(objects) do
		local control = v
		if control and control.isSewersSign then
			-- d('control.x3d', control.x3d)
			-- d('control.newZ', control.newZ)
			-- d('control.y3d', control.y3d)
			local controlTrueX, controlTrueZ, controlTrueY = control:Get3DRenderSpaceOrigin()
			local targetX, targetZ, targetY = control.x3d, control.newZ, control.y3d
			local currentDeviation = zo_abs(targetX - controlTrueX) + zo_abs(targetZ - controlTrueZ) +
				zo_abs(targetY - controlTrueY)

			if currentDeviation < PVP.minDeviation then
				PVP.minDeviation = currentDeviation
				PVP.bestScale = i
			end
			d('Current deviation = ' .. tostring(currentDeviation))
			d('X deviation = ' .. tostring(zo_abs(targetX - controlTrueX)))
			d('Y deviation = ' .. tostring(zo_abs(targetY - controlTrueY)))
			d('Z deviation = ' .. tostring(zo_abs(targetZ - controlTrueZ)))
			break
		end
	end


	d('Min Deviation = ' .. tostring(PVP.minDeviation))
	d('Best Scale = ' .. tostring(PVP.bestScale))
	PVP.testIterator = PVP.testIterator + 1
end

function CountNestedElements(t)
	local count = 1
	if type(t) ~= 'table' then return count end

	for k, v in pairs(t) do
		-- if k ~= 'SV' then
		d(k)
		count = count + CountNestedElements(v)
		-- end
	end

	return count

	-- /script d(CountNestedElements(PVP_Alerts_Main_Table.SV))
end

function PVP:GetGuildmateSharedGuilds(displayName, isGuildmate)
	if (not displayName) or (displayName == "") then return "" end
	local guildmateDatabase = self.guildmates
	if not guildmateDatabase then
		guildmateDatabase = self:PopulateGuildmateDatabase()
	end
	if (not isGuildmate) and (isGuildmate ~= nil) or not guildmateDatabase[displayName] then return "" end

	local guildNamesToken = ""
	local firstGuildAllianceColor
	local foundGuilds = 0
	local playerSharedGuilds = guildmateDatabase[displayName]
	for guildId, _ in pairs(playerSharedGuilds) do
		foundGuilds = foundGuilds + 1
		local guildName = GetGuildName(guildId)
		local guildAlliance = GetGuildAlliance(guildId)
		local guildAllianceColor = self:GetTrueAllianceColorsHex(guildAlliance)

		if foundGuilds > 1 then
			guildNamesToken = guildNamesToken .. ", "
		end

		guildNamesToken = guildNamesToken .. self:Colorize(guildName, guildAllianceColor)

		if not firstGuildAllianceColor then
			firstGuildAllianceColor = guildAllianceColor
		end
	end

	return guildNamesToken, firstGuildAllianceColor
end

function PVP:PopulateGuildmateDatabase()
	local guildmateDatabase = {}
	for i = 1, GetNumGuilds() do
		local guildId = GetGuildId(i)
		local numMembers = GetNumGuildMembers(guildId)
		for j = 1, numMembers do
			local displayName, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, j)
			if not guildmateDatabase[displayName] then
				guildmateDatabase[displayName] = {}
			end
			guildmateDatabase[displayName][guildId] = true
		end
	end
	return guildmateDatabase
end

function PVP:UpdateGuildId(eventCode, unitTag, oldGuildId, newGuildId)
	local guildmateDatabase = PVP.guildmates or {}
	for displayName, guilds in pairs(guildmateDatabase) do
		if guilds[oldGuildId] then
			guilds[oldGuildId] = nil
			guilds[newGuildId] = true
		end
		guildmateDatabase[displayName] = guilds
	end
	PVP.guildmates = guildmateDatabase
end

function PVP:JoinedNewGuild(eventCode, guildServerId, characterName, guildId)
	local guildmateDatabase = PVP.guildmates or {}
	for i = 1, GetNumGuildMembers(guildId) do
		local displayName, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, i)
		if not guildmateDatabase[displayName] then
			guildmateDatabase[displayName] = {}
		end
		guildmateDatabase[displayName][guildId] = true
	end
	PVP.guildmates = guildmateDatabase
end

function PVP:LeftGuild(eventCode, guildServerId, characterName, guildId)
	local guildmateDatabase = PVP.guildmates or {}
	for displayName, guilds in pairs(guildmateDatabase) do
		if guilds[guildId] then
			guilds[guildId] = nil
		end
		if not next(guilds) then
			guildmateDatabase[displayName] = nil
		else
			guildmateDatabase[displayName] = guilds
		end
	end
	PVP.guildmates = guildmateDatabase
end

function PVP:GuildMemberJoined(eventCode, guildId, displayName)
	local guildmateDatabase = PVP.guildmates or {}
	if not guildmateDatabase[displayName] then
		guildmateDatabase[displayName] = {}
	end
	guildmateDatabase[displayName][guildId] = true
	PVP.guildmates = guildmateDatabase
end

function PVP:GuildMemberLeft(eventCode, guildId, displayName)
	local guildmateDatabase = PVP.guildmates or {}
	if guildmateDatabase[displayName] then
		if guildmateDatabase[displayName][guildId] then
			guildmateDatabase[displayName][guildId] = nil
		end
		if not next(guildmateDatabase[displayName]) then
			guildmateDatabase[displayName] = nil
		end
	end
	PVP.guildmates = guildmateDatabase
end

--Original code comes from rdkgrouptool via AgonyWarning
function PVP:SendWarning()
	if AgonyWarning then return end
	PVP.GPS:PushCurrentMap()
	SetMapToMapListIndex(23)
	PVP.LMP:SetMapPing(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, PVP:EncodeMessage(10, 10, 10, 10))
	PVP.GPS:PopCurrentMap()
end

function PVP.OnBeforePingAdded(pingType, pingTag, x, y, isPingOwner)
	if (pingType == MAP_PIN_TYPE_PING) then
		PVP.GPS:PushCurrentMap()
		SetMapToMapListIndex(23)
		x, y = PVP.LMP:GetMapPing(pingType, pingTag)
		local b0, b1, b2, b3 = PVP:DecodeMessage(x,y)
		PVP.GPS:PopCurrentMap()
		PVP.LMP:SuppressPing(pingType, pingTag)

		if not PVP.SV.showAttacks then return end
		local pingData = PVP.networkingPingData[b0 .. "_" .. b1 .. "_" .. b2 .. "_" .. b3]
		if pingData then
			PVP:ProcessImportantAttacks(pingData.result, pingData.abilityName, pingData.abilityId, 1234567, pingData.sourceName, pingData.hitValue, GetFrameTimeMilliseconds())
		end
	end
end

function PVP.OnAfterPingRemoved(pingType, pingTag, x, y, isPingOwner)
	if (pingType == MAP_PIN_TYPE_PING) then
		PVP.LMP:UnsuppressPing(pingType, pingTag)
	end
end

--Original code comes from libgroupsocket via AgonyWarning
function PVP:DecodeMessage(x, y)
	x = zo_floor(x / PVP.MapStepSize + 0.5)
	y = zo_floor(y / PVP.MapStepSize + 0.5)
	local b0 = zo_floor(x / 0x100)
	local b1 = x % 0x100
	local b2 = zo_floor(y / 0x100)
	local b3 = y % 0x100
	return b0, b1, b2, b3
end

function PVP:EncodeMessage(b0, b1, b2, b3)
	b0 = b0 or 0
	b1 = b1 or 0
	b2 = b2 or 0
	b3 = b3 or 0
	return (b0 * 0x100 + b1) * PVP.MapStepSize, (b2 * 0x100 + b3) * PVP.MapStepSize
end

function GetPvpDbPlayerInfo(playerName, returnInfoToken, tokenColor)
	local isMalformedName, unitAccName, unitCharName, unitAlliance, unitClass, unitRace, unitSpec, unitAvARank, lastSeen, unitAccNameToken, unitCharNameToken, allianceColor
	isMalformedName = PVP:IsMalformedName(playerName)
	if (not isMalformedName) and PVP.SV.playersDB[playerName] ~= nil then
		local playerDbRecord = PVP.SV.playersDB[playerName]
		unitAccName = playerDbRecord.unitAccName
		unitCharName = playerName
		unitAlliance = playerDbRecord.unitAlliance
		unitClass = playerDbRecord.unitClass
		unitRace = playerDbRecord.unitRace
		unitSpec = playerDbRecord.unitSpec
		unitAvARank = playerDbRecord.unitAvARank
		lastSeen = playerDbRecord.lastSeen

		if returnInfoToken then
			if tokenColor == "alliance" then
				allianceColor = PVP:GetTrueAllianceColors(unitAlliance)
			else
				allianceColor = tokenColor or PVP:NameToAllianceColor(unitCharName)
			end
			if unitAccName then
				unitAccNameToken = PVP:GetFormattedAccountNameLink(unitAccName, allianceColor)
			else
				unitAccNameToken = unitAccName
			end
			unitCharNameToken = PVP:GetFormattedClassNameLink(unitCharName, allianceColor)
			return unitAccNameToken, unitCharNameToken, unitAlliance, unitClass, unitRace, unitSpec, unitAvARank,
				lastSeen
		elseif tokenColor then
			if tokenColor == "alliance" then
				tokenColor = PVP:GetTrueAllianceColors(unitAlliance)
			end
			local unitAccNameColor = PVP:Colorize(unitAccName, tokenColor)
			local unitCharNameColor = PVP:Colorize(unitCharName, tokenColor)
			return unitAccNameColor, unitCharNameColor, unitAlliance, unitClass, unitRace, unitSpec, unitAvARank,
				lastSeen
		else
			return unitAccName, unitCharName, unitAlliance, unitClass, unitRace, unitSpec, unitAvARank, lastSeen
		end
	elseif isMalformedName then
		if PVP.SV.playersDB[playerName .. "^Fx"] ~= nil then
			local playerDbRecord = PVP.SV.playersDB[playerName .. "^Fx"]
			unitAccName = playerDbRecord.unitAccName
			unitCharName = playerName .. "^Fx"
			unitAlliance = playerDbRecord.unitAlliance
			unitClass = playerDbRecord.unitClass
			unitRace = playerDbRecord.unitRace
			unitSpec = playerDbRecord.unitSpec
			unitAvARank = playerDbRecord.unitAvARank
			lastSeen = playerDbRecord.lastSeen
			if returnInfoToken then
				if tokenColor == "alliance" then
					allianceColor = PVP:GetTrueAllianceColors(unitAlliance)
				else
					allianceColor = tokenColor or PVP:NameToAllianceColor(unitCharName)
				end
				if unitAccName then
					unitAccNameToken = PVP:GetFormattedAccountNameLink(unitAccName, allianceColor)
				else
					unitAccNameToken = unitAccName
				end
				unitCharNameToken = PVP:GetFormattedClassNameLink(unitCharName, allianceColor)
				return unitAccNameToken, unitCharNameToken, unitAlliance, unitClass, unitRace, unitSpec, unitAvARank,
					lastSeen
			elseif tokenColor then
				if tokenColor == "alliance" then
					tokenColor = PVP:GetTrueAllianceColors(unitAlliance)
				end
				local unitAccNameColor = PVP:Colorize(unitAccName, tokenColor)
				local unitCharNameColor = PVP:Colorize(unitCharName, tokenColor)
				return unitAccNameColor, unitCharNameColor, unitAlliance, unitClass, unitRace, unitSpec, unitAvARank,
					lastSeen
			else
				return unitAccName, unitCharName, unitAlliance, unitClass, unitRace, unitSpec, unitAvARank, lastSeen
			end
		elseif PVP.SV.playersDB[playerName .. "^Mx"] ~= nil then
			local playerDbRecord = PVP.SV.playersDB[playerName .. "^Mx"]
			unitAccName = playerDbRecord.unitAccName
			unitCharName = playerName .. "^Mx"
			unitAlliance = playerDbRecord.unitAlliance
			unitClass = playerDbRecord.unitClass
			unitRace = playerDbRecord.unitRace
			unitSpec = playerDbRecord.unitSpec
			unitAvARank = playerDbRecord.unitAvARank
			lastSeen = playerDbRecord.lastSeen
			if returnInfoToken then
				if tokenColor == "alliance" then
					allianceColor = PVP:GetTrueAllianceColors(unitAlliance)
				else
					allianceColor = tokenColor or PVP:NameToAllianceColor(unitCharName)
				end
				if unitAccName then
					unitAccNameToken = PVP:GetFormattedAccountNameLink(unitAccName, allianceColor)
				else
					unitAccNameToken = unitAccName
				end
				unitCharNameToken = PVP:GetFormattedClassNameLink(unitCharName, allianceColor)
				return unitAccNameToken, unitCharNameToken, unitAlliance, unitClass, unitRace, unitSpec, unitAvARank,
					lastSeen
			elseif tokenColor then
				if tokenColor == "alliance" then
					tokenColor = PVP:GetTrueAllianceColors(unitAlliance)
				end
				local unitAccNameColor = PVP:Colorize(unitAccName, tokenColor)
				local unitCharNameColor = PVP:Colorize(unitCharName, tokenColor)
				return unitAccNameColor, unitCharNameColor, unitAlliance, unitClass, unitRace, unitSpec, unitAvARank,
					lastSeen
			else
				return unitAccName, unitCharName, unitAlliance, unitClass, unitRace, unitSpec, unitAvARank, lastSeen
			end
		end
	else
		return unitAccName, unitCharName, unitAlliance, unitClass, unitRace, unitSpec, unitAvARank, lastSeen
	end
end

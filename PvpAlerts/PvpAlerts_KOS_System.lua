---@class (partial) PvpAlerts
local PVP = PVP_Alerts_Main_Table

local GetFrameTimeSeconds = GetFrameTimeSeconds
local GetFrameTimeMilliseconds = GetFrameTimeMilliseconds

local sort = table.sort
local insert = table.insert
local remove = table.remove
--local concat = table.concat
--local upper = string.upper
local lower = string.lower
--local format = string.format

function PVP_Who_Mouseover()
	local name

	if not PVP.SV.enabled then return end

	if --[[PVP:IsInPVPZone() and]] DoesUnitExist('reticleover') and IsUnitPlayer('reticleover') then
		name = PVP:GetValidName(GetRawUnitName('reticleover'))
		if name then
			PVP:Who(name)
		end
	end
end

local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function GetKOSIndex(accName, contains)
	local KOSList = PVP.SV.KOSList
	for k, v in ipairs(KOSList) do
		local dbAccName = contains and PVP:DeaccentString(v.unitAccName) or v.unitAccName
		if lower(dbAccName) == accName then return k end
	end
	return 0
end

local function WhoIsAccInDB(accName, contains)
	accName = lower(accName)
	local accKOSIndex = GetKOSIndex(accName, contains)
	local playerNamesForAcc = {}
	local playersDB = PVP.SV.playersDB
	for k, v in pairs(playersDB) do
		local dbAccName = contains and PVP:DeaccentString(v.unitAccName) or v.unitAccName
		if lower(dbAccName) == accName then insert(playerNamesForAcc, k) end
	end

	if #playerNamesForAcc ~= 0 then
		sort(playerNamesForAcc)
		return playerNamesForAcc, accKOSIndex
	else
		return false
	end
end

local function GetListOfNames(name, contains)
	local rawPlayerNames, lowercaseMatch, deaccentedMatch, looseMatch, stringPositionsArray = {}, {}, {}, {}, {}
	local only
	local playersDB = PVP.SV.playersDB

	if playersDB[name .. '^Mx'] then
		insert(rawPlayerNames, name .. '^Mx')
	elseif playersDB[name .. '^Fx'] then
		insert(rawPlayerNames, name .. '^Fx')
	end

	local numRawPlayers = #rawPlayerNames
	if contains and numRawPlayers == 1 then only = true end

	if contains and numRawPlayers == 0 then
		local deaccentName = lower(PVP:DeaccentString(name))

		name = lower(name)

		for k, v in pairs(playersDB) do
			local strippedName = zo_strformat(SI_UNIT_NAME, k)
			local lowerName = lower(strippedName)
			local currentDeaccentedName = lower(PVP:DeaccentString(strippedName))

			if lowerName == name then
				insert(lowercaseMatch, k)
			elseif currentDeaccentedName == deaccentName then
				insert(deaccentedMatch, k)
			elseif zo_strmatch(currentDeaccentedName, deaccentName) then
				local accentBias = zo_strlen(lower(strippedName)) - zo_strlen(currentDeaccentedName)

				if accentBias > 0 then
					local startChar, endChar = zo_strfind(currentDeaccentedName, deaccentName)

					local indice = PVP:FindUTFIndice(lower(strippedName))

					local newStartChar = startChar
					local newEndChar = endChar
					local numIndice = #indice
					for j = 1, numIndice do
						if indice[j] < startChar then
							newStartChar = newStartChar + 1
							newEndChar = newEndChar + 1
						elseif startChar <= indice[j] and endChar >= indice[j] then
							newEndChar = newEndChar + 1
						end
					end

					stringPositionsArray[k] = { startChar = newStartChar, endChar = newEndChar }
				else
					local startChar, endChar = zo_strfind(currentDeaccentedName, deaccentName)
					stringPositionsArray[k] = { startChar = startChar, endChar = endChar }
				end

				insert(looseMatch, k)
			end
		end

		rawPlayerNames = PVP:TableConcat(rawPlayerNames, lowercaseMatch)
		rawPlayerNames = PVP:TableConcat(rawPlayerNames, deaccentedMatch)
	end

	return rawPlayerNames, only, looseMatch, stringPositionsArray
end

local function IsNameInDB(name, contains)
	local playersDB = PVP.SV.playersDB
	local playerNamesInDB
	if PVP:StringEnd(name, "^Mx") or PVP:StringEnd(name, "^Fx") then
		if playersDB[name] then
			return WhoIsAccInDB(playersDB[name].unitAccName, contains)
		else
			return false
		end
	else
		local only, looseMatch, stringPositionsArray
		playerNamesInDB, only, looseMatch, stringPositionsArray = GetListOfNames(name, contains)

		if #playerNamesInDB ~= 0 or #looseMatch ~= 0 then
			if not contains or only then
				return WhoIsAccInDB(playersDB[playerNamesInDB[1]].unitAccName, contains)
			else
				return playerNamesInDB, nil, looseMatch, stringPositionsArray
			end
		else
			return false
		end
	end
end

local function GetCharAccLink(rawName, unitAccName, unitRace)
	return PVP:GetFormattedClassNameLink(rawName, PVP:NameToAllianceColor(rawName, nil, true)) ..
		', ' ..
		GetRaceName(0, unitRace) ..
		', ' ..
		((PVP:StringEnd(rawName, '^Mx') and 'male' or 'female') .. ', ' .. PVP:GetFormattedAccountNameLink(unitAccName, "FFFFFF"))
end

local function GetHighlightedCharAccLink(rawName, startIndex, endIndex)
	local strippedName = zo_strformat(SI_UNIT_NAME, rawName)
	local nameLength = zo_strlen(strippedName)
	local allianceColor = PVP:NameToAllianceColor(rawName, nil, true)
	local playersDB = PVP.SV.playersDB
	local playerDbRecord = playersDB[rawName]
	local unitRace 	= playerDbRecord.unitRace
	local unitAccName = playerDbRecord.unitAccName
	local icon = PVP:GetFormattedClassIcon(rawName, nil, allianceColor, nil, nil, nil, nil,
		nil, nil, nil, playerDbRecord or "none")

	local normalPartBefore, normalPartAfter, highlightPart

	highlightPart = PVP:Colorize(
		ZO_LinkHandler_CreateLinkWithoutBrackets(zo_strsub(strippedName, startIndex, endIndex), nil,
			CHARACTER_LINK_TYPE,
			rawName), 'FF00FF')

	if startIndex == 1 then
		normalPartBefore = ""
		if endIndex >= nameLength then
			normalPartAfter = ""
		else
			normalPartAfter = zo_strsub(strippedName, endIndex + 1, nameLength)
		end
	elseif endIndex >= nameLength then
		normalPartBefore = zo_strsub(strippedName, 1, startIndex - 1)
		normalPartAfter = ""
	else
		normalPartBefore = zo_strsub(strippedName, 1, startIndex - 1)
		normalPartAfter = zo_strsub(strippedName, endIndex + 1, nameLength)
	end

	if normalPartBefore ~= "" then
		normalPartBefore = PVP:Colorize(
			ZO_LinkHandler_CreateLinkWithoutBrackets(normalPartBefore, nil, CHARACTER_LINK_TYPE, rawName),
			allianceColor)
	end

	if normalPartAfter ~= "" then
		normalPartAfter = PVP:Colorize(
			ZO_LinkHandler_CreateLinkWithoutBrackets(normalPartAfter, nil, CHARACTER_LINK_TYPE, rawName),
			allianceColor)
	end

	return icon ..
		normalPartBefore ..
		highlightPart ..
		normalPartAfter ..
		', ' ..
		GetRaceName(0, unitRace) ..
		', ' ..
		((PVP:StringEnd(rawName, '^Mx') and 'male' or 'female') .. ', ' .. PVP:GetFormattedAccountNameLink(unitAccName, "FFFFFF"))
end

local function GetCharLink(rawName)
	local playersDB = PVP.SV.playersDB
	return PVP:GetFormattedClassNameLink(rawName, PVP:NameToAllianceColor(rawName)) ..
		', ' ..
		GetRaceName(0, playersDB[rawName].unitRace) .. ', ' ..
		(PVP:StringEnd(rawName, '^Mx') and 'male' or 'female')
end

function PVP:Who(name, contains)

	local foundPlayerNames, KOSIndex, looseMatch, stringPositionsArray

	if type(name) ~= "string" then
		d('Invalid name provided!')
		return
	end

	if name == "" then
		d('No name provided!')
		return
	end

	if zo_strlen(name) <= 2 then
		d('Name has to be longer than 2 characters!')
		return
	end

	local trimmedName = trim(name)
	local isDecorated = IsDecoratedDisplayName(trimmedName)

	if isDecorated then
		foundPlayerNames, KOSIndex = WhoIsAccInDB(trimmedName, contains)
	else
		foundPlayerNames, KOSIndex, looseMatch, stringPositionsArray = IsNameInDB(trimmedName, contains)
	end

	if (not foundPlayerNames or #foundPlayerNames == 0) and (not looseMatch or #looseMatch == 0) then
		if isDecorated then
			d('No such account in the database!')
		else
			d('No such player in the database!')
		end
		return
	end

	local playersDb = self.SV.playersDB
	local playersCP = self.SV.CP
	local playerNotes = self.SV.playerNotes
	if KOSIndex ~= nil then --single player account information returned
		local currentCP = ""
		local playerDbRecord = playersDb[foundPlayerNames[1]]
		local accName = playerDbRecord.unitAccName
		local sharedGuilds = PVP:GetGuildmateSharedGuilds(accName)
		if playersCP[accName] then currentCP = ' with ' .. PVP:Colorize(playersCP[accName] .. 'cp', 'FFFFFF') .. ',' end
		if isDecorated then
			d('The player ' ..
				PVP:GetFormattedAccountNameLink(accName, "FFFFFF") ..
				currentCP ..
				' has ' ..
				tostring(#foundPlayerNames) .. ' known character' .. (#foundPlayerNames > 1 and 's' or '') .. ':')
		else
			d('Found ' ..
				PVP:GetFormattedAccountNameLink(accName, "FFFFFF") ..
				' account' ..
				currentCP ..
				' for the player ' ..
				PVP:Colorize(zo_strformat(SI_UNIT_NAME, trimmedName), 'FF00FF') ..
				' that has ' .. PVP:Colorize(#foundPlayerNames, 'FFFFFF') .. ' known characters:')
		end
		for i = 1, #foundPlayerNames do
			d(tostring(i) .. '. ' .. GetCharLink(foundPlayerNames[i]))
		end
		if sharedGuilds and sharedGuilds ~= "" then
			d('Shared Guild(s): ' .. sharedGuilds)
		end
		if playerNotes[accName] and playerNotes[accName] ~= "" then
			d('Note: ' .. self:Colorize(playerNotes[accName], "76BCC3"))
		end
	else -- multiple players information returned
		local patternName = zo_strformat(SI_UNIT_NAME, trimmedName)
		local patternLength = zo_strlen(patternName)
		local highlightedName = PVP:Colorize(patternName, 'FF00FF')

		d('Found ' .. tostring(#foundPlayerNames + #looseMatch) .. ' players, similar to ' .. highlightedName .. ':')

		if foundPlayerNames and #foundPlayerNames ~= 0 then
			for i = 1, #foundPlayerNames do
				local currentplayerDbRecord = playersDb[foundPlayerNames[i]]
				local currentAccName = currentplayerDbRecord.unitAccName
				local currentAccCP = ""
				if playersCP[currentAccName] then currentAccCP = ' (' .. playersCP[currentAccName] .. 'cp)' end
				local currentName = foundPlayerNames[i]

				local nameLink = GetCharAccLink(currentName, currentAccName, currentplayerDbRecord.unitRace)

				d(tostring(i) .. '. ' .. nameLink .. currentAccCP)
			end
		end

		if looseMatch and #looseMatch ~= 0 then
			local startFullWord, midFullWord, startPartWord, remainder = {}, {}, {}, {}
			for i = 1, #looseMatch do
				local currentName = looseMatch[i]
				local strippedCurrentName = zo_strformat(SI_UNIT_NAME, currentName)
				local currentNameLength = zo_strlen(strippedCurrentName)
				local first, last = stringPositionsArray[currentName].startChar,
					stringPositionsArray[currentName].endChar
				local startsFullWord = zo_strsub(strippedCurrentName, first - 1, first - 1) == " " or
					zo_strsub(strippedCurrentName, first - 1, first - 1) == "-"
				local endsFullWord = last == currentNameLength or zo_strsub(strippedCurrentName, last + 1, last + 1) ==
					" " or zo_strsub(strippedCurrentName, last + 1, last + 1) == "-"

				if first == 1 then
					if endsFullWord then
						insert(startFullWord, currentName)
					else
						insert(startPartWord, currentName)
					end
				elseif startsFullWord and endsFullWord then
					insert(midFullWord, currentName)
				else
					insert(remainder, currentName)
				end
			end

			if #startFullWord > 1 then sort(startFullWord) end
			if #midFullWord > 1 then sort(midFullWord) end
			if #startPartWord > 1 then sort(startPartWord) end
			if #remainder > 1 then sort(remainder) end

			local looseMatchOutput = {}

			looseMatchOutput = PVP:TableConcat(looseMatchOutput, startFullWord)
			looseMatchOutput = PVP:TableConcat(looseMatchOutput, startPartWord)
			looseMatchOutput = PVP:TableConcat(looseMatchOutput, midFullWord)
			looseMatchOutput = PVP:TableConcat(looseMatchOutput, remainder)

			local indexToHighlight = #startFullWord + #startPartWord + 1

			for i = 1, #looseMatchOutput do
				local currentplayerDbRecord = playersDb[looseMatchOutput[i]]
				local currentAccName = currentplayerDbRecord.unitAccName
				local currentAccCP = ""
				if playersCP[currentAccName] then currentAccCP = ' (' .. playersCP[currentAccName] .. 'cp)' end
				local currentName = looseMatchOutput[i]
				local strippedCurrentName = zo_strformat(SI_UNIT_NAME, currentName)

				local nameLink

				if i >= indexToHighlight and (zo_strlen(zo_strgsub(strippedCurrentName, "%s+", "")) - patternLength) > 2 then
					nameLink = GetHighlightedCharAccLink(currentName, stringPositionsArray[currentName].startChar,
						stringPositionsArray[currentName].endChar)
				else
					nameLink = GetCharAccLink(currentName, currentAccName, currentplayerDbRecord.unitRace)
				end

				d(tostring(i) .. '. ' .. nameLink .. currentAccCP)
			end
		end
	end
end

local function IsAccFriendKOSorCOOL(charAccName)
	if IsFriend(charAccName) then return true end
	local KOSList = PVP.SV.KOSAccList
	if KOSList[charAccName] then return true end

	local coolList = PVP.SV.coolAccList
	if coolList[charAccName] then return true end
	return false
end

local function IsAccMalformedName(charAccName)
	local KOSList = PVP.SV.KOSList
	local numKOS = #KOSList
	for i = 1, numKOS do
		local unitKOSName = KOSList[i].unitName
		if PVP:DeaccentString(unitKOSName) == charAccName then
			return true, unitKOSName
		end
	end
	local coolList = PVP.SV.coolList
	local numCool = #coolList
	for i = 1, numCool do
		local unitCOOLName = coolList[i]
		if PVP:DeaccentString(unitCOOLName) == charAccName then
			return true, unitCOOLName
		end
	end
	return false
end

function PVP:managePlayerNote(noteString)
	local doFunc, charAccName, accNote = noteString:match("([^ ]+) ([^ ]+)%s*(.*)")

	if not doFunc then
		doFunc = noteString
	end

	if doFunc ~= "list" and doFunc ~= "clear" then
		if not charAccName then
			self.CHAT:Printf("No account name provided!")
			return
		end

		if charAccName:sub(1, 1) ~= "@" then
			self.CHAT:Printf("Must use player @name to assign notes!")
			return
		end

		if not IsAccFriendKOSorCOOL(charAccName) then
			local isMalformed, unitDBName = IsAccMalformedName(charAccName)
			if isMalformed then
				self.CHAT:Printf("%s wasn't found in your KOS, COOL. or Friends lists, did you mean \"%s\"?",
					charAccName, self:GetFormattedAccountNameLink(unitDBName, "FFFFFF"))
			else
				self.CHAT:Printf("%s must be added to KOS, COOL, or Friends list for notes to display!",
					self:GetFormattedAccountNameLink(charAccName, "FFFFFF"))
			end
		end
	end

	if doFunc == "add" then
		if not self.SV.playerNotes[charAccName] then
			self.SV.playerNotes[charAccName] = accNote
			self.CHAT:Printf("Note added for %s!", self:GetFormattedAccountNameLink(charAccName, "FFFFFF"))
		else
			local oldAccNote = self.SV.playerNotes[charAccName]
			self.SV.playerNotes[charAccName] = accNote
			self.CHAT:Printf("Note '%s' overwritten for %s!", oldAccNote,
				self:GetFormattedAccountNameLink(charAccName, "FFFFFF"))
		end
	elseif doFunc == "delete" then
		if self.SV.playerNotes[charAccName] then
			self.SV.playerNotes[charAccName] = nil
			self.CHAT:Printf("Note deleted for %s!", self:GetFormattedAccountNameLink(charAccName, "FFFFFF"))
		else
			self.CHAT:Printf("No note exists for %s!", self:GetFormattedAccountNameLink(charAccName, "FFFFFF"))
		end
	elseif doFunc == "show" then
		if self.SV.playerNotes[charAccName] then
			self.CHAT:Printf("Note for %s: %s", self:GetFormattedAccountNameLink(charAccName, "FFFFFF"),
				self:Colorize(self.SV.playerNotes[charAccName], "76BCC3"))
		else
			self.CHAT:Printf("No note exists for %s!", self:GetFormattedAccountNameLink(charAccName, "FFFFFF"))
		end
	elseif doFunc == "list" then
		if next(self.SV.playerNotes) then
			self.CHAT:Printf("Player notes:")
			for k, v in pairs(self.SV.playerNotes) do
				self.CHAT:Printf(self:GetFormattedAccountNameLink(k, "FFFFFF") .. ": " .. self:Colorize(v, "76BCC3"))
			end
		else
			self.CHAT:Printf("No notes found!")
		end
	elseif doFunc == "clear" then
		self.SV.playerNotes = {}
		self.CHAT:Printf("All notes cleared!")
	else
		self.CHAT:Printf("Invalid command! Options are 'add', 'delete', 'show', 'list', or 'clear'.")
	end
end

local function IsAccInKOS(unitAccName)
	local KOSList = PVP.SV.KOSList
	local numKOS = #KOSList
	for i = 1, numKOS do
		if KOSList[i].unitAccName == unitAccName then return KOSList[i].unitName, i end
	end
	return false
end

local function IsKOSAccInDB(unitAccName)
	local nameFromKOS, indexInKOS = IsAccInKOS(unitAccName)
	if nameFromKOS then return nameFromKOS, indexInKOS end

	local playersDB = PVP.SV.playersDB
	local allianceOfPlayer = PVP.allianceOfPlayer
	local foundPlayerNames = {}
	for k, v in pairs(playersDB) do
		if v.unitAccName == unitAccName then insert(foundPlayerNames, k) end
	end
	local numFoundPlayers = #foundPlayerNames
	if numFoundPlayers > 0 then
		if numFoundPlayers == 1 then return foundPlayerNames[1] end
		for i = 1, numFoundPlayers do
			if playersDB[foundPlayerNames[i]].unitAlliance ~= allianceOfPlayer then
				return foundPlayerNames[i]
			end
		end
		return foundPlayerNames[1]
	end
	return false
end

local function CheckNameWithoutSuffixes(rawName)
	local maleName = rawName .. "^Mx"
	local femaleName = rawName .. "^Fx"
	local playersDB = PVP.SV.playersDB
	local allianceOfPlayer = PVP.allianceOfPlayer

	if playersDB[maleName] or playersDB[femaleName] then
		if playersDB[maleName] and not playersDB[femaleName] then return maleName end
		if not playersDB[maleName] and playersDB[femaleName] then return femaleName end
		if playersDB[maleName].unitAccName == playersDB[femaleName].unitAccName then
			if playersDB[maleName].unitAlliance ~= allianceOfPlayer and playersDB[femaleName].unitAlliance == allianceOfPlayer then
				return
					maleName
			end
			if playersDB[maleName].unitAlliance == allianceOfPlayer and playersDB[femaleName].unitAlliance ~= allianceOfPlayer then
				return
					femaleName
			end
			if zo_random() > 0.5 then return maleName else return femaleName end
		end
		return rawName, true
	end

	local foundNames = {}
	for k, _ in pairs(playersDB) do
		if PVP:DeaccentString(maleName) == PVP:DeaccentString(k) or PVP:DeaccentString(femaleName) == PVP:DeaccentString(k) then
			insert(foundNames, k)
		end
	end

	local numFound = #foundNames
	if numFound ~= 0 then
		PVP.CHAT:Printf('Found multiple names. Please use account name to add the desired person:')
		for i = 1, numFound do
			d(tostring(i) ..
				'. ' ..
				PVP:GetFormattedClassNameLink(foundNames[i], PVP:NameToAllianceColor(foundNames[i])) ..
				PVP:GetFormattedAccountNameLink(playersDB[foundNames[i]].unitAccName, "FFFFFF"))
		end
	end

	return false, false, true
end

local function IsNameInDBRecord(unitCharName, playerDbRecord)
	if PVP:CheckName(unitCharName) then
		if playerDbRecord.unitAccName then
			local nameFromKOS, indexInKOS = IsAccInKOS(playerDbRecord.unitAccName)
			if nameFromKOS then return nameFromKOS, indexInKOS end
			return unitCharName
		else
			return false
		end
	end

	local foundRawName, isAmbiguous, isMultiple = CheckNameWithoutSuffixes(unitCharName)

	if isAmbiguous then return foundRawName, false, true end

	if foundRawName then
		local nameFromKOS, indexInKOS = IsAccInKOS(PVP.SV.playersDB[foundRawName].unitAccName)
		if nameFromKOS then return nameFromKOS, indexInKOS end
		return foundRawName
	end

	return false, false, false, isMultiple
end

function PVP:CheckKOSValidity(unitCharName, playerDbRecord)

	local rawName, isInKOS, isAmbiguous, isMultiple

	if IsDecoratedDisplayName(unitCharName) then
		rawName, isInKOS = IsKOSAccInDB(playerDbRecord.unitAccName)
	else
		rawName, isInKOS, isAmbiguous, isMultiple = IsNameInDBRecord(unitCharName, playerDbRecord)
	end

	return rawName, isInKOS, isAmbiguous, isMultiple
end

function PVP_Add_KOS_Mouseover()
	if not PVP.SV.enabled then return end
	if PVP:IsInPVPZone() and DoesUnitExist('reticleover') and IsUnitPlayer('reticleover') then
		local name = PVP:GetValidName(GetRawUnitName('reticleover'))
		if name then
			PVP:AddKOS(name)
		end
	end
end

function PVP_Add_COOL_Mouseover()
	if not PVP.SV.enabled then return end
	if PVP:IsInPVPZone() and DoesUnitExist('reticleover') and IsUnitPlayer('reticleover') then
		local name = PVP:GetValidName(GetRawUnitName('reticleover'))
		if name then
			PVP:AddCOOL(name)
		end
	end
end

function PVP:FindAccInCOOL(unitPlayerName, unitAccName)
	if not unitAccName then return false end

	local coolList = self.SV.coolList
	local found
	for k, v in pairs(coolList) do
		if unitAccName == v then
			found = k
			break
		end
	end
	if found and found ~= unitPlayerName then
		coolList[found] = nil
		coolList[unitPlayerName] = unitAccName
		found = unitPlayerName
	end
	return found
end

function PVP:AddKOS(playerName, isSlashCommand)
	local SV = self.SV
	if not SV.showKOSFrame then self.CHAT:Printf('KOS/COOL system is disabled!') end

	if not playerName or playerName == "" then
		self.CHAT:Printf("Name was not provided!")
		return
	end
	local KOSList = SV.KOSList
	local playersDB = SV.playersDB
	local playerDbRecord = playersDB[playerName] or {}
	playerDbRecord.unitCharName = playerName
	local rawName, isInKOS, isAmbiguous, isMultiple = self:CheckKOSValidity(playerName, playerDbRecord)
	if rawName and (rawName ~= playerName) then
		playerDbRecord = playersDB[rawName] or {}
		playerDbRecord.unitCharName = rawName
	end

	if not rawName then
		if not isMultiple then self.CHAT:Printf("This player is not in the database!") end
		return
	end

	if isAmbiguous then
		self.CHAT:Printf("The name is ambiguous!")
		return
	end

	-- if isInKOS then d('This account is already in KOS as: '..self:GetFormattedName(rawName).."!") return end

	local cool = self:FindAccInCOOL(rawName, playersDB[rawName].unitAccName)
	if cool then
		self.CHAT:Printf("Removed from COOL: %s%s!", self:GetFormattedName(playersDB[cool].unitName),
			playersDB[cool].unitAccName)
		SV.coolList[cool] = nil
		self:PopulateReticleOverNamesBuffer(true)
	end

	if not isInKOS then
		local unitId = 0
		if next(self.idToName) ~= nil and playersDB[rawName] then
			for k, v in pairs(self.idToName) do
				if playersDB[v] and playersDB[v].unitAccName == playersDB[rawName].unitAccName then
					unitId = k
					break
				end
			end
		end
		insert(KOSList,
			{ unitName = rawName, unitAccName = playerDbRecord.unitAccName, unitId = unitId })
			self.CHAT:Printf("Added to KOS: %s%s!", self:GetFormattedName(rawName), playerDbRecord.unitAccName)
	else
		self.CHAT:Printf("Removed from KOS: %s%s!", self:GetFormattedName(KOSList[isInKOS].unitName),
			KOSList[isInKOS].unitAccName)
		remove(KOSList, isInKOS)
	end
	self:RefreshLocalPlayers()
end

function PVP:AddCOOL(playerName, isSlashCommand)
	local SV = self.SV

	if not SV.showKOSFrame then self.CHAT:Printf('KOS/COOL system is disabled!') end

	if not playerName or playerName == "" then
		self.CHAT:Printf("Name was not provided!")
		return
	end

	local KOSList = SV.KOSList
	local coolList = SV.coolList
	local playersDB = SV.playersDB

	local playerDbRecord = playersDB[playerName] or {}
	local rawName, isInKOS, isAmbiguous, isMultiple = self:CheckKOSValidity(playerName, playerDbRecord)
	if rawName and (rawName ~= playerName) then
		playerDbRecord = playersDB[rawName] or {}
	end


	if not rawName then
		if not isMultiple then self.CHAT:Printf("This player is not in the database!") end
		return
	end

	-- if isInKOS then d('This account is already in KOS as: '..self:GetFormattedName(rawName).."!") return end
	if isAmbiguous then
		self.CHAT:Printf("The name is ambiguous!")
		return
	end

	if isInKOS then
		local numKOS = #KOSList
		for i = 1, numKOS do
			if KOSList[i].unitAccName == playerDbRecord.unitAccName then
				self.CHAT:Printf("Removed from KOS: %s%s!", self:GetFormattedName(KOSList[i].unitName),
					KOSList[i].unitAccName)
				remove(KOSList, i)
				break
			end
		end
	end

	local cool = self:FindAccInCOOL(rawName, playersDB[rawName].unitAccName)


	if not cool then
		coolList[rawName] = playerDbRecord.unitAccName
		self.CHAT:Printf("Added to COOL: %s%s!", self:GetFormattedName(rawName), playerDbRecord.unitAccName)
	else
		self.CHAT:Printf("Removed from COOL: %s%s!", self:GetFormattedName(rawName), playerDbRecord.unitAccName)
		SV.coolList[cool] = nil
		-- d(self:GetFormattedName(rawName)..self.SV.playersDB[rawName].unitAccName.." is already COOL!")
	end

	self:RefreshLocalPlayers()
	self:PopulateReticleOverNamesBuffer(true)
end

function PVP:IsKOSOrFriend(playerName, unitAccName)
	local isGrouped = IsUnitGrouped('player')
	if isGrouped and self:GetValidName(GetRawUnitName(GetGroupLeaderUnitTag())) == playerName then return "groupleader" end
	if isGrouped and IsPlayerInGroup(playerName) then return "group" end
	if unitAccName and self.KOSAccList[unitAccName] then return "KOS" end
	if self.SV.showFriends and IsFriend(playerName) then return "friend" end
	if unitAccName and self.coolAccList[unitAccName] then return "cool" end
	if self.SV.showGuildMates and self.guildmates[unitAccName] then return "guild" end

	return false
end

function PVP:IsEmperor(playerName, currentCampaignActiveEmperor)
	if currentCampaignActiveEmperor == "" or currentCampaignActiveEmperor == nil then return false end
	if playerName == "" or playerName == nil then return false end
	playerName = tostring(playerName)
	if playerName == currentCampaignActiveEmperor .. "^Mx" then return true end
	if playerName == currentCampaignActiveEmperor .. "^Fx" then return true end
	return false
end

function PVP:IsAccNameInKOS(unitAccName)
	local KOSList = self.SV.KOSList
	local numKOS = #KOSList
	for i = 1, numKOS do
		if unitAccName == KOSList[i].unitAccName then return true end
	end
	return false
end

local function CheckActive(KOSNamesList, kosActivityList, reportActive)
	if not KOSNamesList or KOSNamesList == {} then
		if kosActivityList then
			return kosActivityList
		else
			return { activeChars = {} }
		end
	end

	local currentTime = GetFrameTimeSeconds()
	if kosActivityList and kosActivityList.measureTime and (currentTime - kosActivityList.measureTime) < 60 then return kosActivityList end
	QueryCampaignLeaderboardData()
	local currentCampaignId = PVP.currentCampaignId

	if not kosActivityList or not kosActivityList.activeChars then
		kosActivityList = { activeChars = {} }
		for k, v in pairs(KOSNamesList) do
			kosActivityList[k] = { chars = {} }
		end
	end

	for k, v in pairs(kosActivityList) do
		if k ~= "activeChars" and not KOSNamesList[k] then kosActivityList[k] = nil end
	end

	kosActivityList.measureTime = currentTime

	for alliance = 1, 3 do
		for i = 1, GetNumCampaignAllianceLeaderboardEntries(currentCampaignId, alliance) do
			local isPlayer, ranking, charName, alliancePoints, _, accName = GetCampaignAllianceLeaderboardEntryInfo(currentCampaignId, alliance, i)

			if KOSNamesList[accName] then
				if not kosActivityList[accName] then
					kosActivityList[accName] = { chars = {} }
				end
				if not kosActivityList[accName].chars[charName] then
					kosActivityList[accName].chars[charName] = { currentTime = currentTime, points = alliancePoints }
				elseif kosActivityList[accName].chars[charName].points < alliancePoints then
					if not kosActivityList.activeChars[accName] then
						if reportActive then
							d("ACTIVE KOS: " .. charName)
						end
						kosActivityList.activeChars[accName] = charName
					end
					kosActivityList[accName].chars[charName] = { currentTime = currentTime, points = alliancePoints }
				end
			end
		end
	end

	for k, v in pairs(kosActivityList.activeChars) do
		if (kosActivityList[k] and kosActivityList[k].chars[v] and kosActivityList[k].chars[v].currentTime and (currentTime - kosActivityList[k].chars[v].currentTime) > 600) or (not kosActivityList[k]) or (not kosActivityList[k].chars[v]) then
			kosActivityList.activeChars[k] = nil
		end
	end
	return kosActivityList
end

local function BuildImportantIcon(unitAccName, isFriend, isCool, isGuildmate, isPlayerGrouped)
	local importantIcon = ""
	if isFriend then importantIcon = importantIcon .. PVP:GetFriendIcon() end
	if isCool then importantIcon = importantIcon .. PVP:GetCoolIcon() end
	if isGuildmate then
		if isPlayerGrouped then
			local guildIcon = PVP:GetGuildIcon(nil, "40BB40")
			importantIcon = importantIcon .. guildIcon
		else
			local guildNames, firstGuildAllianceColor = PVP:GetGuildmateSharedGuilds(unitAccName, isGuildmate)
			local guildIcon = PVP:GetGuildIcon(nil, firstGuildAllianceColor)
			importantIcon = importantIcon .. guildIcon .. guildNames
		end
	end
	return importantIcon
end

local function FormatPlayerNote(playerNote)
	return playerNote and PVP:Colorize("- " .. playerNote, 'C5C29F') or ""
end

local function FormatResurrectIcon(isResurrect)
	return isResurrect and PVP:GetResurrectIcon() or ""
end

local function createIsResurrectList(namesToDisplay)
	local isResurrectList = {}
	if namesToDisplay then
		local numNames = #namesToDisplay
		for j = 1, numNames do
			if namesToDisplay[j].isResurrect then
				isResurrectList[namesToDisplay[j]] = true
			end
		end
	end
	return isResurrectList
end

function PVP:ProcessLocalPlayer(unitId, rawName, dbRec, currentTime, KOSAccList, kosActivityList, coolAccList, guildmates, isResurrectList, playerNotes, showPlayerNotes, showFriends, showGuildMates, allianceOfPlayer, mode)
	local unitAccName = dbRec.unitAccName
	local unitAlliance = dbRec.unitAlliance
	local isKOS = KOSAccList[unitAccName] ~= nil
	local isCool = coolAccList[unitAccName] ~= nil
	local isPlayerGrouped = IsPlayerInGroup(rawName)
	local playerNote = showPlayerNotes and playerNotes[unitAccName] or nil
	local hasPlayerNote = playerNote and (playerNote ~= "")
	local isFriend = showFriends and IsFriend(rawName) or false
	local isGuildmate = showGuildMates and guildmates[unitAccName] or false

	local newLocalPlayer = {
		unitId = unitId,
		unitAccName = unitAccName,
		unitAlliance = unitAlliance,
		isKOS = isKOS,
		isCOOL = isCool
	}

	local isResurrect = isResurrectList[rawName] or false
	local newString = nil
	local isActive = false
	local newPotentialAlly = nil

	if isKOS then
		local isAlly = (unitAlliance == allianceOfPlayer)
		isActive = kosActivityList.activeChars[unitAccName]

		if (mode == 2 and isAlly) or (mode == 3 and not isAlly) or mode == 1 then
			if unitId ~= 0 then
				local kosIcon = self:GetKOSIcon(nil, isAlly and "FFFFFF" or nil) or ""
				local resurrectIcon = FormatResurrectIcon(isResurrect)
				local importantIcon = BuildImportantIcon(unitAccName, isFriend, isCool, isGuildmate, isPlayerGrouped)
				local playerNoteToken = hasPlayerNote and FormatPlayerNote(playerNote) or ""
				PVP_KOS_Text:AddMessage(
					self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName), nil, isResurrect,
					nil, nil, nil, unitId, currentTime, nil, dbRec or "none") ..
					self:GetFormattedAccountNameLink(unitAccName, isAlly and "FFFFFF" or "BB4040") ..
					kosIcon .. resurrectIcon .. importantIcon .. playerNoteToken
				)
			end
		end

		if mode == 4 then
			local guildNames, firstGuildAllianceColor, guildIcon
			if isGuildmate then
				guildNames, firstGuildAllianceColor = self:GetGuildmateSharedGuilds(unitAccName, isGuildmate)
				guildIcon = self:GetGuildIcon(nil, firstGuildAllianceColor)
			else
				guildIcon = ""
				guildNames = ""
			end

			if isActive then
				newString = self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName), isResurrect, nil,
				nil, nil, nil, unitId, currentTime, nil, dbRec or "none") ..
					self:GetFormattedAccountNameLink(unitAccName, isAlly and "FFFFFF" or "BB4040") .. " ACTIVE"
			else
				newString = self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName, true), nil, true,
				nil, nil, nil, unitId, currentTime, nil, dbRec or "none") ..
					self:GetFormattedAccountNameLink(unitAccName, "3F3F3F") .. guildIcon .. guildNames .. FormatPlayerNote(playerNote)
			end
		end
	end

	if (not isKOS) and (hasPlayerNote or ((not isPlayerGrouped) and (isCool or isFriend or isGuildmate))) then
		newPotentialAlly = {
			currentTime = currentTime,
			unitAccName = unitAccName,
			unitAlliance = dbRec.unitAlliance,
			isPlayerGrouped = isPlayerGrouped,
			isFriend = isFriend,
			isGuildmate = isGuildmate,
			isCool = isCool,
			playerNote = hasPlayerNote and playerNote or nil,
			isResurrect = isResurrect
		}
		local isAlly = (unitAlliance == allianceOfPlayer)
		local validAlliance = (mode == 1) or (mode == 2 and isAlly) or (mode == 3 and not isAlly)
		if validAlliance and not isKOS then
			local resurrectIcon = FormatResurrectIcon(isResurrect)
			local importantIcon = BuildImportantIcon(unitAccName, isFriend, isCool, isGuildmate, isPlayerGrouped)
			local playerNoteToken = hasPlayerNote and FormatPlayerNote(playerNote) or ""

			PVP_KOS_Text:AddMessage(
				self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName), isResurrect, nil,
				nil, nil, nil, unitId, currentTime, nil, dbRec or "none") ..
				self:GetFormattedAccountNameLink(unitAccName, "40BB40") ..
				resurrectIcon .. importantIcon .. playerNoteToken
			)
		end
	end

	return newLocalPlayer, newString, isActive, newPotentialAlly
end

function PVP:RefreshLocalPlayers()
	local SV = self.SV
	if SV.unlocked then return end

	local KOSList = SV.KOSList
	local coolList = SV.coolList
	local playersDB = SV.playersDB
	local allianceOfPlayer = self.allianceOfPlayer

	if SV.showTargetNameFrame then self:UpdateTargetName() end
	local mode = SV.KOSmode
	PVP_KOS_Text:Clear()

	local KOSAccList = self.KOSAccList
	local coolAccList = self.coolAccList
	local guildmates = self.guildmates

	local currentTime = GetFrameTimeMilliseconds()

	if not self.lastActiveCheckedTime or ((currentTime - self.lastActiveCheckedTime) >= 300000) then
		self.lastActiveCheckedTime = currentTime
		self.kosActivityList = CheckActive(KOSAccList, self.kosActivityList, SV.outputNewKos)
	end
	local kosActivityList = self.kosActivityList


	local localPlayers = {}
	local potentialAllies = {}
	local idToName = self.idToName
	local playerNames = self.playerNames
	local namesToDisplay = self.namesToDisplay
	local playerNotes = SV.playerNotes
	local showPlayerNotes = SV.showPlayerNotes
	local showFriends = SV.showFriends
	local showGuildMates = SV.showGuildMates

	local activeStringsArray = {}
	local inactiveStringsArray = {}

	local isResurrectList = createIsResurrectList(namesToDisplay)

	for unitId, rawName in pairs(idToName) do
		local dbRec = playersDB[rawName]
		if dbRec then
			local newLocalPlayer, newString, isActive, newPotentialAlly = self:ProcessLocalPlayer(unitId, rawName, dbRec, currentTime, KOSAccList, kosActivityList, coolAccList, guildmates, isResurrectList, playerNotes, showPlayerNotes, showFriends, showGuildMates, allianceOfPlayer, mode)
			localPlayers[rawName] = newLocalPlayer
			if newString then
				if isActive then
					insert(activeStringsArray, newString)
				else
					insert(inactiveStringsArray, newString)
				end
			end
			if newPotentialAlly then
				potentialAllies[rawName] = newPotentialAlly
			end
		end
	end

	for rawName, _ in pairs(playerNames) do
		if not localPlayers[rawName] then
			local dbRec = playersDB[rawName]
			if dbRec then
				local newLocalPlayer, newString, isActive, newPotentialAlly = self:ProcessLocalPlayer(1234567890, rawName, dbRec, currentTime, KOSAccList, kosActivityList, coolAccList, guildmates, isResurrectList, playerNotes, showPlayerNotes, showFriends, showGuildMates, allianceOfPlayer, mode)
				localPlayers[rawName] = newLocalPlayer
				if newString then
					if isActive then
						insert(activeStringsArray, newString)
					else
						insert(inactiveStringsArray, newString)
					end
				end
				if newPotentialAlly then
					potentialAllies[rawName] = newPotentialAlly
				end
			end
		end
	end

	if mode == 4 then
		for _, v in ipairs(KOSList) do
			if not localPlayers[v.unitName] then
				local dbRec = playersDB[v.unitName]
				if dbRec then
					local isAlly = (dbRec.unitAlliance == allianceOfPlayer)
					local isActive = KOSAccList[dbRec.unitAccName] and kosActivityList.activeChars[dbRec.unitAccName]
					local isResurrect, guildNames, firstGuildAllianceColor, guildIcon
					local isGuildmate = guildmates[dbRec.unitAccName]

					if isGuildmate then
						guildNames, firstGuildAllianceColor = self:GetGuildmateSharedGuilds(dbRec.unitAccName, isGuildmate)
						guildIcon = self:GetGuildIcon(nil, firstGuildAllianceColor)
					else
						guildIcon = ""
						guildNames = ""
					end

					if isActive then
						local activeMessage = self:GetFormattedClassNameLink(v.unitName, self:NameToAllianceColor(v.unitName), nil, nil,
						nil, nil, nil, nil, currentTime, nil, dbRec or "none") ..
							self:GetFormattedAccountNameLink(dbRec.unitAccName, isAlly and "FFFFFF" or "BB4040") .. " ACTIVE"
						insert(activeStringsArray, activeMessage)
					else
						local inactiveMessage = self:GetFormattedClassNameLink(v.unitName, self:NameToAllianceColor(v.unitName, true), nil, true,
						nil, nil, nil, nil, currentTime, nil, dbRec or "none") ..
							self:GetFormattedAccountNameLink(dbRec.unitAccName, "3F3F3F") .. guildIcon .. guildNames .. FormatPlayerNote(playerNotes[dbRec.unitAccName])
						insert(inactiveStringsArray, inactiveMessage)
					end
				end
			end
		end

		for rawName, accName in pairs(coolList) do
			if not localPlayers[rawName] then
				local dbRec = playersDB[rawName]
				if dbRec then
					local message = self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName), nil, nil,
					nil, nil, nil, nil, currentTime, nil, dbRec or "none") ..
						self:Colorize(accName, "3F3F3F") ..
						self:GetCoolIcon(nil, true) .. FormatPlayerNote(playerNotes[accName])
					insert(inactiveStringsArray, message)
				end
			end
		end

		for _, v in ipairs(activeStringsArray) do
			PVP_KOS_Text:AddMessage(v)
		end
		for _, v in ipairs(inactiveStringsArray) do
			PVP_KOS_Text:AddMessage(v)
		end
	end

	self.localPlayers = localPlayers
	self.potentialAllies = potentialAllies
end

function PVP:SetKOSSliderPosition()
	local mode = PVP.SV.KOSmode
	local control = PVP_KOS_ControlFrame
	local button = PVP_KOS_ControlFrame_Button
	local controlWidth = control:GetWidth() - 10
	local selfWidth = button:GetWidth()
	local effectiveWidth = controlWidth - selfWidth

	local offset1 = zo_round(-effectiveWidth / 2)
	local offset2 = zo_round(-effectiveWidth / 6)
	local offset3 = zo_round(effectiveWidth / 6)
	local offset4 = zo_round(effectiveWidth / 2)

	local _, point, relativeTo, relativePoint, offsetX, offsetY = button:GetAnchor()

	if mode == 1 then
		offsetX = offset1
		button:SetText("All")
	elseif mode == 2 then
		offsetX = offset2
		button:SetText("Allies")
	elseif mode == 3 then
		offsetX = offset3
		button:SetText("Enemies")
	elseif mode == 4 then
		offsetX = offset4
		button:SetText("Setup")
	end

	button:ClearAnchors()
	button:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
end

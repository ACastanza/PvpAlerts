local PVP = PVP_Alerts_Main_Table

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

function PVP:Who(name, contains)
	local function trim(s)
		return (s:gsub("^%s*(.-)%s*$", "%1"))
	end

	local function GetKOSIndex(accName)
		for k, v in ipairs(PVP.SV.KOSList) do
			local dbAccName = contains and PVP:DeaccentString(v.unitAccName) or v.unitAccName
			if string.lower(dbAccName) == accName then return k end
		end
		return 0
	end

	local function IsAccInDB(accName, contains)
		accName = string.lower(accName)
		local accKOSIndex = GetKOSIndex(accName)
		local playerNamesForAcc = {}
		for k, v in pairs(PVP.SV.playersDB) do
			local dbAccName = contains and PVP:DeaccentString(v.unitAccName) or v.unitAccName
			if string.lower(dbAccName) == accName then table.insert(playerNamesForAcc, k) end
		end

		if #playerNamesForAcc ~= 0 then
			table.sort(playerNamesForAcc)
			return playerNamesForAcc, accKOSIndex
		else
			return false
		end
	end

	local function GetListOfNames(name, contains)
		local rawPlayerNames, lowercaseMatch, deaccentedMatch, looseMatch, stringPositionsArray = {}, {}, {}, {}, {}
		local only

		if PVP.SV.playersDB[name .. '^Mx'] then
			table.insert(rawPlayerNames, name .. '^Mx')
		elseif PVP.SV.playersDB[name .. '^Fx'] then
			table.insert(rawPlayerNames, name .. '^Fx')
		end

		if contains and #rawPlayerNames == 1 then only = true end


		if contains and #rawPlayerNames == 0 then
			local deaccentName = string.lower(PVP:DeaccentString(name))

			name = string.lower(name)

			for k, v in pairs(PVP.SV.playersDB) do
				local strippedName = zo_strformat(SI_UNIT_NAME, k)
				local currentDeaccentedName = string.lower(PVP:DeaccentString(strippedName))
				local lowerName = string.lower(lowerName)

				if lowerName == name then
					table.insert(lowercaseMatch, k)
				elseif currentDeaccentedName == deaccentName then
					table.insert(deaccentedMatch, k)
				elseif string.match(currentDeaccentedName, deaccentName) then
					local accentBias = string.len(string.lower(strippedName)) - string.len(currentDeaccentedName)

					if accentBias > 0 then
						local startChar, endChar = string.find(currentDeaccentedName, deaccentName)

						local indice = PVP:FindUTFIndice(string.lower(strippedName))


						local newStartChar = startChar
						local newEndChar = endChar

						for j = 1, #indice do
							if indice[j] < startChar then
								newStartChar = newStartChar + 1
								newEndChar = newEndChar + 1
							elseif startChar <= indice[j] and endChar >= indice[j] then
								newEndChar = newEndChar + 1
							end
						end

						stringPositionsArray[k] = { startChar = newStartChar, endChar = newEndChar }
					else
						local startChar, endChar = string.find(currentDeaccentedName, deaccentName)
						stringPositionsArray[k] = { startChar = startChar, endChar = endChar }
					end


					table.insert(looseMatch, k)
				end
			end

			rawPlayerNames = PVP:TableConcat(rawPlayerNames, lowercaseMatch)
			rawPlayerNames = PVP:TableConcat(rawPlayerNames, deaccentedMatch)
		end

		return rawPlayerNames, only, looseMatch, stringPositionsArray
	end

	local function IsNameInDB(name, contains)
		local playerNamesInDB
		if self:StringEnd(name, "^Mx") or self:StringEnd(name, "^Fx") then
			if PVP.SV.playersDB[name] then
				return IsAccInDB(PVP.SV.playersDB[name].unitAccName)
			else
				return false
			end
		else
			local only, looseMatch, stringPositionsArray
			playerNamesInDB, only, looseMatch, stringPositionsArray = GetListOfNames(name, contains)

			if #playerNamesInDB ~= 0 or #looseMatch ~= 0 then
				if not contains or only then
					return IsAccInDB(PVP.SV.playersDB[playerNamesInDB[1]].unitAccName)
				else
					return playerNamesInDB, nil, looseMatch, stringPositionsArray
				end
			else
				return false
			end
		end
	end

	local function GetCharAccLink(rawName)
		return PVP:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName, nil, true)) ..
			', ' ..
			GetRaceName(0, PVP.SV.playersDB[rawName].unitRace) ..
			', ' ..
			((PVP:StringEnd(rawName, '^Mx') and 'male' or 'female') .. ', ' .. PVP:GetFormattedAccountNameLink(PVP.SV.playersDB[rawName].unitAccName, "FFFFFF"))
	end

	local function GetHighlightedCharAccLink(rawName, startIndex, endIndex)
		local strippedName  = zo_strformat(SI_UNIT_NAME, rawName)
		local nameLength    = string.len(strippedName)
		local allianceColor = self:NameToAllianceColor(rawName, nil, true)
		local icon          = self:GetFormattedClassIcon(rawName, nil, allianceColor)

		local normalPartBefore, normalPartAfter, highlightPart

		highlightPart       = self:Colorize(
			ZO_LinkHandler_CreateLinkWithoutBrackets(string.sub(strippedName, startIndex, endIndex), nil,
				CHARACTER_LINK_TYPE,
				rawName), 'FF00FF')

		if startIndex == 1 then
			normalPartBefore = ""
			if endIndex >= nameLength then
				normalPartAfter = ""
			else
				normalPartAfter = string.sub(strippedName, endIndex + 1, nameLength)
			end
		elseif endIndex >= nameLength then
			normalPartBefore = string.sub(strippedName, 1, startIndex - 1)
			normalPartAfter = ""
		else
			normalPartBefore = string.sub(strippedName, 1, startIndex - 1)
			normalPartAfter = string.sub(strippedName, endIndex + 1, nameLength)
		end

		if normalPartBefore ~= "" then
			normalPartBefore = self:Colorize(
				ZO_LinkHandler_CreateLinkWithoutBrackets(normalPartBefore, nil, CHARACTER_LINK_TYPE, rawName),
				allianceColor)
		end

		if normalPartAfter ~= "" then
			normalPartAfter = self:Colorize(
				ZO_LinkHandler_CreateLinkWithoutBrackets(normalPartAfter, nil, CHARACTER_LINK_TYPE, rawName),
				allianceColor)
		end

		return icon ..
			normalPartBefore ..
			highlightPart ..
			normalPartAfter ..
			', ' ..
			GetRaceName(0, PVP.SV.playersDB[rawName].unitRace) ..
			', ' ..
			((PVP:StringEnd(rawName, '^Mx') and 'male' or 'female') .. ', ' .. PVP:GetFormattedAccountNameLink(PVP.SV.playersDB[rawName].unitAccName, "FFFFFF"))
	end


	local function GetCharLink(rawName)
		return PVP:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName)) ..
			', ' ..
			GetRaceName(0, PVP.SV.playersDB[rawName].unitRace) .. ', ' ..
			(PVP:StringEnd(rawName, '^Mx') and 'male' or 'female')
	end

	local foundPlayerNames, KOSIndex, looseMatch, stringPositionsArray

	if type(name) ~= "string" then
		d('Invalid name provided!')
		return
	end

	if name == "" then
		d('No name provided!')
		return
	end


	if string.len(name) <= 2 then
		d('Name has to be longer than 2 characters!')
		return
	end

	local trimmedName = trim(name)
	local isDecorated = IsDecoratedDisplayName(trimmedName)

	if isDecorated then
		foundPlayerNames, KOSIndex = IsAccInDB(trimmedName, contains)
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

	if KOSIndex ~= nil then --single player account information returned
		local currentCP = ""
		local accName = PVP.SV.playersDB[foundPlayerNames[1]].unitAccName
		if self.SV.CP[accName] then currentCP = ' with ' .. PVP:Colorize(self.SV.CP[accName] .. 'cp', 'FFFFFF') .. ',' end
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
	else -- multiple players information returned
		local patternName = zo_strformat(SI_UNIT_NAME, trimmedName)
		local patternLength = string.len(patternName)
		local highlightedName = PVP:Colorize(patternName, 'FF00FF')

		d('Found ' .. tostring(#foundPlayerNames + #looseMatch) .. ' players, similar to ' .. highlightedName .. ':')

		for i = 1, #foundPlayerNames do
			local currentAccName = PVP.SV.playersDB[foundPlayerNames[i]].unitAccName
			local currentAccCP = ""
			if self.SV.CP[currentAccName] then currentAccCP = ' (' .. self.SV.CP[currentAccName] .. 'cp)' end
			local currentName = foundPlayerNames[i]

			local nameLink = GetCharAccLink(currentName)

			d(tostring(i) .. '. ' .. nameLink .. currentAccCP)
		end

		if #looseMatch ~= 0 then
			local startFullWord, midFullWord, startPartWord, remainder = {}, {}, {}, {}
			for i = 1, #looseMatch do
				local currentName = looseMatch[i]
				local strippedCurrentName = zo_strformat(SI_UNIT_NAME, currentName)
				local currentNameLength = string.len(strippedCurrentName)
				local first, last = stringPositionsArray[currentName].startChar,
					stringPositionsArray[currentName].endChar
				local startsFullWord = string.sub(strippedCurrentName, first - 1, first - 1) == " " or
					string.sub(strippedCurrentName, first - 1, first - 1) == "-"
				local endsFullWord = last == currentNameLength or string.sub(strippedCurrentName, last + 1, last + 1) ==
					" " or string.sub(strippedCurrentName, last + 1, last + 1) == "-"

				if first == 1 then
					if endsFullWord then
						table.insert(startFullWord, currentName)
					else
						table.insert(startPartWord, currentName)
					end
				elseif startsFullWord and endsFullWord then
					table.insert(midFullWord, currentName)
				else
					table.insert(remainder, currentName)
				end
			end

			if #startFullWord > 1 then table.sort(startFullWord) end
			if #midFullWord > 1 then table.sort(midFullWord) end
			if #startPartWord > 1 then table.sort(startPartWord) end
			if #remainder > 1 then table.sort(remainder) end

			local looseMatchOutput = {}

			looseMatchOutput = PVP:TableConcat(looseMatchOutput, startFullWord)
			looseMatchOutput = PVP:TableConcat(looseMatchOutput, startPartWord)
			looseMatchOutput = PVP:TableConcat(looseMatchOutput, midFullWord)
			looseMatchOutput = PVP:TableConcat(looseMatchOutput, remainder)

			local indexToHighlight = #startFullWord + #startPartWord + 1

			for i = 1, #looseMatchOutput do
				local currentAccName = PVP.SV.playersDB[looseMatchOutput[i]].unitAccName
				local currentAccCP = ""
				if self.SV.CP[currentAccName] then currentAccCP = ' (' .. self.SV.CP[currentAccName] .. 'cp)' end
				local currentName = looseMatchOutput[i]
				local strippedCurrentName = zo_strformat(SI_UNIT_NAME, currentName)

				local nameLink

				if i >= indexToHighlight and (string.len(string.gsub(strippedCurrentName, "%s+", "")) - patternLength) > 2 then
					nameLink = GetHighlightedCharAccLink(currentName, stringPositionsArray[currentName].startChar,
						stringPositionsArray[currentName].endChar)
				else
					nameLink = GetCharAccLink(currentName)
				end

				d(tostring(i) .. '. ' .. nameLink .. currentAccCP)
			end
		end
	end
end

function PVP:managePlayerNote(noteString)
	local doFunc, charAccName, accNote = noteString:match("([^ ]+) ([^ ]+)%s*(.*)")

	if not doFunc then
        doFunc = noteString
    end
	
	local function IsAccFriendKOSorCOOL(charAccName)
		if IsFriend(charAccName) then return true end
        for i = 1, #PVP.SV.KOSList do
            if PVP.SV.KOSList[i].unitAccName == charAccName then
                return true
            end
        end
        for i = 1, #PVP.SV.coolList do
			if PVP.SV.coolList[i] == charAccName then return true end
        end
        return false
    end
	
    local function IsAccMalformedName(charAccName)
        for i = 1, #PVP.SV.KOSList do
			local unitKOSName = PVP.SV.KOSList[i].unitName
            if PVP:DeaccentString(unitKOSName) == charAccName then
				return true, unitKOSName
            end
        end
        for i = 1, #PVP.SV.coolList do
			local unitCOOLName = PVP.SV.coolList[i]
            if PVP:DeaccentString(unitCOOLName) == charAccName then
                return true, unitCOOLName
            end
        end
        return false
    end
	
    if doFunc ~= "list" and doFunc ~= "clear" then
        if not charAccName then
            d("No account name provided!")
            return
        end

        if charAccName:sub(1, 1) ~= "@" then
            d("Must use player @name to assign notes!")
            return
        end

        if not IsAccFriendKOSorCOOL(charAccName) then
            local isMalformed, unitDBName = IsAccMalformedName(charAccName)
            if isMalformed then
                d(charAccName ..
                    " wasn't found in your KOS, COOL. or Friends lists, did you mean '" .. unitDBName .. "'?")
            else
                d(self:GetFormattedAccountNameLink(charAccName, "FFFFFF") ..
                    " must be added to KOS, COOL, or Friends list for notes to display!")
            end
        end
    end
	
    if doFunc == "add" then
        if not self.SV.playerNotes[charAccName] then
            self.SV.playerNotes[charAccName] = accNote
            d("Note added for " .. self:GetFormattedAccountNameLink(charAccName, "FFFFFF") .. "!")
        else
			local oldAccNote = self.SV.playerNotes[charAccName]
			self.SV.playerNotes[charAccName] = accNote
            d("Note '".. oldAccNote .. "' overwritten for " .. self:GetFormattedAccountNameLink(charAccName, "FFFFFF") .. "!")
        end
    elseif doFunc == "remove" then
        if self.SV.playerNotes[charAccName] then
            self.SV.playerNotes[charAccName] = nil
            d("Note removed for " .. self:GetFormattedAccountNameLink(charAccName, "FFFFFF") .. "!")
        else
            d("No note exists for " .. self:GetFormattedAccountNameLink(charAccName, "FFFFFF") .. "!")
        end
    elseif doFunc == "show" then
        if self.SV.playerNotes[charAccName] then
            d("Note for " ..
                self:GetFormattedAccountNameLink(charAccName, "FFFFFF") .. ": " .. self.SV.playerNotes[charAccName])
        else
            d("No note exists for " .. self:GetFormattedAccountNameLink(charAccName, "FFFFFF") .. "!")
        end
    elseif doFunc == "list" then
        if next(self.SV.playerNotes) then
            d("Player notes:")
            for k, v in pairs(self.SV.playerNotes) do
                d(self:GetFormattedAccountNameLink(k, "FFFFFF") .. ": " .. v)
            end
        else
            d("No notes found!")
        end
	elseif doFunc == "clear" then
		self.SV.playerNotes = {}
		d("All notes cleared!")
    else
        d("Invalid command! Options are 'add', 'remove', 'show', 'list', or 'clear'.")
    end
end

function PVP:CheckKOSValidity(playerName)
	local function IsAccInKOS(accName)
		for i = 1, #PVP.SV.KOSList do
			if PVP.SV.KOSList[i].unitAccName == accName then return PVP.SV.KOSList[i].unitName, i end
		end
		return false
	end

	local function IsAccInDB(accName)
		local nameFromKOS, indexInKOS = IsAccInKOS(accName)
		if nameFromKOS then return nameFromKOS, indexInKOS end

		local foundPlayerNames = {}
		for k, v in pairs(PVP.SV.playersDB) do
			if v.unitAccName == accName then table.insert(foundPlayerNames, k) end
		end

		if #foundPlayerNames > 0 then
			if #foundPlayerNames == 1 then return foundPlayerNames[1] end
			for i = 1, #foundPlayerNames do
				if self.SV.playersDB[foundPlayerNames[i]].unitAlliance ~= self.allianceOfPlayer then
					return
						foundPlayerNames[i]
				end
			end
			return foundPlayerNames[1]
		end
		return false
	end

	local function CheckNameWithoutSuffixes(rawName)
		local maleName = rawName .. "^Mx"
		local femaleName = rawName .. "^Fx"

		if PVP.SV.playersDB[maleName] or PVP.SV.playersDB[femaleName] then
			if self.SV.playersDB[maleName] and not self.SV.playersDB[femaleName] then return maleName end
			if not self.SV.playersDB[maleName] and self.SV.playersDB[femaleName] then return femaleName end
			if self.SV.playersDB[maleName].unitAccName == self.SV.playersDB[femaleName].unitAccName then
				if self.SV.playersDB[maleName].unitAlliance ~= self.allianceOfPlayer and self.SV.playersDB[femaleName].unitAlliance == self.allianceOfPlayer then
					return
						maleName
				end
				if self.SV.playersDB[maleName].unitAlliance == self.allianceOfPlayer and self.SV.playersDB[femaleName].unitAlliance ~= self.allianceOfPlayer then
					return
						femaleName
				end
				if math.random() > 0.5 then return maleName else return femaleName end
			end
			return rawName, true
		end

		local foundNames = {}
		for k, _ in pairs(PVP.SV.playersDB) do
			if PVP:DeaccentString(maleName) == PVP:DeaccentString(k) or PVP:DeaccentString(femaleName) == PVP:DeaccentString(k) then
				table.insert(foundNames, k)
			end
		end

		if #foundNames ~= 0 then
			d('Found multiple names. Please use account name to add the desired person:')
			for i = 1, #foundNames do
				d(tostring(i) ..
					'. ' ..
					self:GetFormattedClassNameLink(foundNames[i], self:NameToAllianceColor(foundNames[i])) ..
					self:GetFormattedAccountNameLink(PVP.SV.playersDB[foundNames[i]].unitAccName, "FFFFFF"))
			end
		end

		return false, false, true
	end

	local function IsNameInDB(rawName)
		if PVP:CheckName(rawName) then
			if PVP.SV.playersDB[rawName] then
				local nameFromKOS, indexInKOS = IsAccInKOS(PVP.SV.playersDB[rawName].unitAccName)
				if nameFromKOS then return nameFromKOS, indexInKOS end
				return rawName
			else
				return false
			end
		end

		local foundRawName, isAmbiguous, isMultiple = CheckNameWithoutSuffixes(rawName)

		if isAmbiguous then return foundRawName, false, true end

		if foundRawName then
			local nameFromKOS, indexInKOS = IsAccInKOS(PVP.SV.playersDB[foundRawName].unitAccName)
			if nameFromKOS then return nameFromKOS, indexInKOS end
			return foundRawName
		end

		return false, false, false, isMultiple
	end

	local rawName, isInKOS, isAmbiguous, isMultiple

	if IsDecoratedDisplayName(playerName) then
		rawName, isInKOS = IsAccInDB(playerName)
	else
		rawName, isInKOS, isAmbiguous, isMultiple = IsNameInDB(playerName)
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

function PVP:FindInCOOL(playerName)
	if not self.SV.playersDB[playerName] then return false end
	local found
	for k, v in pairs(self.SV.coolList) do
		if self.SV.playersDB[playerName].unitAccName == v then
			found = k
			break
		end
	end
	if found and found ~= playerName then
		self.SV.coolList[found] = nil
		self.SV.coolList[playerName] = self.SV.playersDB[playerName].unitAccName
		found = playerName
	end
	return found
end

function PVP:AddKOS(playerName, isSlashCommand)
	if not self.SV.showKOSFrame then d('KOS/COOL system is disabled!') end

	if not playerName or playerName == "" then
		d("Name was not provided!")
		return
	end

	local rawName, isInKOS, isAmbiguous, isMultiple = self:CheckKOSValidity(playerName)

	if not rawName then
		if not isMultiple then d("This player is not in the database!") end
		return
	end

	if isAmbiguous then
		d("The name is ambiguous!")
		return
	end

	-- if isInKOS then d('This account is already in KOS as: '..self:GetFormattedName(rawName).."!") return end

	local cool = self:FindInCOOL(rawName)
	if cool then
		d("Removed from COOL: " ..
			self:GetFormattedName(self.SV.playersDB[cool].unitName) .. self.SV.playersDB[cool].unitAccName .. "!")
		self.SV.coolList[cool] = nil
		self:PopulateReticleOverNamesBuffer()
	end

	if not isInKOS then
		local unitId = 0
		if next(self.idToName) ~= nil and self.SV.playersDB[rawName] then
			for k, v in pairs(self.idToName) do
				if self.SV.playersDB[v] and self.SV.playersDB[v].unitAccName == self.SV.playersDB[rawName].unitAccName then
					unitId = k
					break
				end
			end
		end
		table.insert(self.SV.KOSList,
			{ unitName = rawName, unitAccName = self.SV.playersDB[rawName].unitAccName, unitId = unitId })
		d("Added to KOS: " .. self:GetFormattedName(rawName) .. self.SV.playersDB[rawName].unitAccName .. "!")
	else
		d("Removed from KOS: " .. self:GetFormattedName(rawName) .. self.SV.playersDB[rawName].unitAccName .. "!")
		table.remove(self.SV.KOSList, isInKOS)
	end
	self:PopulateKOSBuffer()
end

function PVP:AddCOOL(playerName, isSlashCommand)
	if not self.SV.showKOSFrame then d('KOS/COOL system is disabled!') end

	if not playerName or playerName == "" then
		d("Name was not provided!")
		return
	end

	local rawName, isInKOS, isAmbiguous, isMultiple = self:CheckKOSValidity(playerName)

	if not rawName then
		if not isMultiple then d("This player is not in the database!") end
		return
	end

	-- if isInKOS then d('This account is already in KOS as: '..self:GetFormattedName(rawName).."!") return end
	if isAmbiguous then
		d("The name is ambiguous!")
		return
	end

	if isInKOS then
		for i = 1, #self.SV.KOSList do
			if self.SV.KOSList[i].unitAccName == self.SV.playersDB[rawName].unitAccName then
				d("Removed from KOS: " ..
					self:GetFormattedName(self.SV.KOSList[i].unitName) .. self.SV.KOSList[i].unitAccName .. "!")
				table.remove(self.SV.KOSList, i)
				break
			end
		end
	end

	local cool = self:FindInCOOL(rawName)


	if not cool then
		self.SV.coolList[rawName] = self.SV.playersDB[rawName].unitAccName
		d("Added to COOL: " .. self:GetFormattedName(rawName) .. self.SV.playersDB[rawName].unitAccName .. "!")
	else
		d("Removed from COOL: " ..
			PVP:GetFormattedName(PVP.SV.playersDB[rawName].unitName) .. PVP.SV.playersDB[rawName].unitAccName .. "!")
		PVP.SV.coolList[cool] = nil
		-- d(self:GetFormattedName(rawName)..self.SV.playersDB[rawName].unitAccName.." is already COOL!")
	end

	self:PopulateKOSBuffer()
	self:PopulateReticleOverNamesBuffer()
end

function PVP:FindCOOLPlayer(unitName, unitAccName)
	local unitId = 0
	local newName = unitName
	if next(self.idToName) ~= nil then
		for k, v in pairs(self.idToName) do
            if self.SV.playersDB[v] and self.SV.playersDB[v].unitAccName == unitAccName then
				local hasPlayerNote = (self.SV.playerNotes[unitAccName] ~= nil)
                if v ~= unitName then
                    self.SV.coolList[v] = unitAccName
                    self.SV.coolList[unitName] = nil
                    newName = v
                end
				if (not IsPlayerInGroup(v)) or hasPlayerNote then
					unitId = k
				end
				break
			end
		end
	end

	if unitId == 0 and next(self.playerNames) ~= nil then
		for k, _ in pairs(self.playerNames) do
            if self.SV.playersDB[k].unitAccName == unitAccName then
				local hasPlayerNote = (self.SV.playerNotes[unitAccName] ~= nil)
                if k ~= unitName then
                    self.SV.coolList[k] = unitAccName
                    self.SV.coolList[unitName] = nil
                    newName = k
                end
                if (not IsPlayerInGroup(k)) or hasPlayerNote then
                    unitId = 1234567890
                end
				break
			end
		end
	end
	return unitId, newName
end

function PVP:FindKOSPlayer(index)
	local currentTime = GetFrameTimeMilliseconds()
	local unitId = 0
	if next(self.idToName) ~= nil then
		for k, v in pairs(self.idToName) do
            if self.SV.playersDB[v] and self.SV.playersDB[v].unitAccName == self.SV.KOSList[index].unitAccName then
				local hasPlayerNote = (self.SV.playerNotes[self.SV.KOSList[index].unitAccName] ~= nil)
				if v ~= self.SV.KOSList[index].unitName then self.SV.KOSList[index].unitName = v end
				if hasPlayerNote or not IsPlayerInGroup(v) then unitId = k end
				break
			end
		end
	end

	if unitId == 0 and next(self.playerNames) ~= nil then
		for k, _ in pairs(self.playerNames) do
            if self.SV.playersDB[k].unitAccName == self.SV.KOSList[index].unitAccName then
				local hasPlayerNote = (self.SV.playerNotes[self.SV.KOSList[index].unitAccName] ~= nil)
				if k ~= self.SV.KOSList[index].unitName then self.SV.KOSList[index].unitName = k end
				if hasPlayerNote or not IsPlayerInGroup(k) then unitId = 1234567890 end
				break
			end
		end
	end

	local isInNames = self.playerNames[self.SV.KOSList[index].unitName]

	if self.SV.KOSList[index].unitId == 0 and unitId ~= 0 and self.SV.playKOSSound and (isInNames or self.playerAlliance[unitId]) then
		if (isInNames and self.SV.playersDB[self.SV.KOSList[index].unitName].unitAlliance == self.allianceOfPlayer) or self.playerAlliance[unitId] == self.allianceOfPlayer or (IsActiveWorldBattleground() and PVP.bgNames and PVP.bgNames[self.SV.KOSList[index].unitName] and PVP.bgNames[self.SV.KOSList[index].unitName] == GetUnitBattlegroundAlliance('player')) then
			-- d('KOS failed here')
			if PVP.SV.KOSmode == 2 then
				if currentTime - self.kosSoundDelay > 2000 then
					PlaySound(SOUNDS.CROWN_CRATES_CARD_FLIPPING)
				end
				PlaySound(SOUNDS.CROWN_CRATES_CARD_FLIPPING)
				self.kosSoundDelay = currentTime
			end
		elseif PVP.SV.KOSmode ~= 2 then
			if currentTime - self.kosSoundDelay > 2000 then
				PlaySound(SOUNDS.JUSTICE_STATE_CHANGED)
			end
			PlaySound(SOUNDS.JUSTICE_STATE_CHANGED)
			self.kosSoundDelay = currentTime
		end
	end
	self.SV.KOSList[index].unitId = unitId
	return unitId
end

function PVP:IsKOSOrFriend(playerName)
	if not self.SV.playersDB[playerName] then return false end
	-- if GetRawUnitName(GetGroupLeaderUnitTag())==playerName then return "groupleader" end
	if PVP:GetValidName(GetRawUnitName(GetGroupLeaderUnitTag())) == playerName then return "groupleader" end
	if IsPlayerInGroup(playerName) then return "group" end
	if self:IsNameInKOS(playerName) then return "KOS" end
	if IsFriend(playerName) then return "friend" end

	if self:FindInCOOL(playerName) then return "cool" end

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

function PVP:IsNameInKOS(playerName)
	local dbRecord, accName
	dbRecord = self.SV.playersDB[playerName]
	if not dbRecord then return false else accName = dbRecord.unitAccName end

	for i = 1, #self.SV.KOSList do
		if accName == self.SV.KOSList[i].unitAccName then return true end
	end
	return false
end

function PVP:PopulateKOSBuffer()
	local function CheckActive()
		if not self.KOSNamesList or self.KOSNamesList == {} then return end
		local currentTime = GetFrameTimeSeconds()
		if PVP.kosActivityList and PVP.kosActivityList.measureTime and (currentTime - PVP.kosActivityList.measureTime) < 60 then return end
		QueryCampaignLeaderboardData()
		local currentCampaignId = GetCurrentCampaignId()
		
		if not PVP.kosActivityList then
			PVP.kosActivityList = {}
			PVP.kosActivityList.activeChars = {}
			for k, v in pairs(self.KOSNamesList) do
				PVP.kosActivityList[k] = {}
				PVP.kosActivityList[k].chars = {}
			end
		end

		for k, v in pairs(self.kosActivityList) do
			if k ~= "activeChars" then
				if not self.KOSNamesList[k] then self.kosActivityList[k] = nil end
			end
		end

		PVP.kosActivityList.measureTime = currentTime

		for alliance = 1, 3 do
			for i = 1, GetNumCampaignAllianceLeaderboardEntries(currentCampaignId, alliance) do
				local isPlayer, ranking, charName, alliancePoints, _, accName = GetCampaignAllianceLeaderboardEntryInfo(
					currentCampaignId, alliance, i)

				if self.KOSNamesList[accName] then
					if not PVP.kosActivityList[accName] then
						PVP.kosActivityList[accName] = {}
						PVP.kosActivityList[accName].chars = {}
					end
					if not PVP.kosActivityList[accName].chars[charName] then
						PVP.kosActivityList[accName].chars[charName] = {
							currentTime = currentTime,
							points = alliancePoints
						}
					else
						if PVP.kosActivityList[accName].chars[charName].points < alliancePoints then
							if not PVP.kosActivityList.activeChars[accName] then
								if self.SV.outputNewKos then
									d("ACTIVE KOS: " .. charName)
								end
								PVP.kosActivityList.activeChars[accName] = charName
							end
							PVP.kosActivityList[accName].chars[charName] = {
								currentTime = currentTime,
								points = alliancePoints
							}
						end
					end
				end
			end
		end

		for k, v in pairs(PVP.kosActivityList.activeChars) do
			if (PVP.kosActivityList[k] and PVP.kosActivityList[k].chars[v] and PVP.kosActivityList[k].chars[v].currentTime and (currentTime - PVP.kosActivityList[k].chars[v].currentTime) > 600) or (not PVP.kosActivityList[k]) or (not PVP.kosActivityList[k].chars[v]) then
				PVP.kosActivityList.activeChars[k] = nil
			end
		end
	end


	if self.SV.unlocked then return end
	if self.SV.showTargetNameFrame then self:UpdateTargetName() end
	local mode = self.SV.KOSmode
	PVP_KOS_Text:Clear()

	self.KOSNamesList = {}
	for i = 1, #self.SV.KOSList do
		self.KOSNamesList[self.SV.KOSList[i].unitAccName] = true
	end

	local currentTime = GetFrameTimeMilliseconds()

	if not PVP.lastActiveCheckedTime or ((currentTime - PVP.lastActiveCheckedTime) >= 5000) then
		PVP.lastActiveCheckedTime = currentTime
		CheckActive()
	end

	self:FindFriends()

	if next(self.friends) ~= nil and (mode == 1 or mode == 2) then
        for rawName, v in pairs(self.friends) do
			local playerNote
            local accName = self.SV.playersDB[rawName].unitAccName
			playerNote = self.SV.playerNotes[accName]
			if playerNote then playerNote = PVP:Colorize("- " .. playerNote, 'C5C29F') else playerNote = "" end
			if not self.KOSNamesList[accName] then
				local friendIcon, resurrectIcon
				if v.isFriend then
					friendIcon = self:GetFriendIcon()
				else
					friendIcon = self:GetCoolIcon()
				end
				if v.isResurrect then
					resurrectIcon = self:GetResurrectIcon()
				else
					resurrectIcon = ""
				end
				PVP_KOS_Text:AddMessage(self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName)) ..
					self:GetFormattedAccountNameLink(accName, "40BB40") .. friendIcon .. resurrectIcon .. playerNote)
				self.KOSNamesList[accName] = true
			end
		end
	end

	local activeStringsArray = {}
	for i = 1, #self.SV.KOSList do
		local unitId = self:FindKOSPlayer(i)
		local rawName = self.SV.KOSList[i].unitName
		local accName = self.SV.KOSList[i].unitAccName
		local ally = self.SV.playersDB[rawName].unitAlliance == self.allianceOfPlayer
		local isResurrect, playerNote
        local isActive = PVP.kosActivityList.activeChars[accName]
		playerNote = self.SV.playerNotes[accName]
        if playerNote then playerNote = PVP:Colorize("- " .. playerNote, 'C5C29F') else playerNote = "" end
		
		if unitId ~= 0 then
			for j = 1, #self.namesToDisplay do
				if self.namesToDisplay[j] == rawName and self.namesToDisplay[j].isResurrect then
					isResurrect = true
				end
			end
		end

		-- if (mode==2 and ally) or (mode==3 and not ally) or mode==4 or mode==1 then
		if (mode == 2 and ally) or (mode == 3 and not ally) or mode == 1 then
			if unitId ~= 0 then
				local resurrectIcon
				if isResurrect then
					resurrectIcon = self:GetResurrectIcon()
				else
					resurrectIcon = ""
				end
				if ally then
					PVP_KOS_Text:AddMessage(self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName)) ..
						self:GetFormattedAccountNameLink(accName, "FFFFFF") .. self:GetKOSIcon(nil, "FFFFFF") ..
						resurrectIcon .. playerNote)
				else
					PVP_KOS_Text:AddMessage(self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName)) ..
						self:GetFormattedAccountNameLink(accName, "BB4040") ..
						self:GetKOSIcon() .. resurrectIcon .. playerNote)
				end
			end
		end

		if mode == 4 then
			if isActive then
				if ally then
					-- PVP_KOS_Text:AddMessage(self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName))..self:GetFormattedAccountNameLink(accName, "FFFFFF").." ACTIVE")
					table.insert(activeStringsArray,
						self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName)) ..
						self:GetFormattedAccountNameLink(accName, "FFFFFF") .. " ACTIVE")
				else
					-- PVP_KOS_Text:AddMessage(self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName))..self:GetFormattedAccountNameLink(accName, "BB4040").." ACTIVE")
					table.insert(activeStringsArray,
						self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName)) ..
						self:GetFormattedAccountNameLink(accName, "BB4040") .. " ACTIVE")
				end
			else
				PVP_KOS_Text:AddMessage(self:GetFormattedClassNameLink(rawName, self:NameToAllianceColor(rawName, true),
					nil, true) .. self:GetFormattedAccountNameLink(accName, "3F3F3F") .. playerNote)
			end
		end
	end

	if mode == 4 then
		for k, v in pairs(self.SV.coolList) do
            local unitId, newName = self:FindCOOLPlayer(k, v)
			local playerNote
			playerNote = self.SV.playerNotes[v]
			if playerNote then playerNote = PVP:Colorize("- " .. playerNote, 'C5C29F') else playerNote = "" end
			if unitId ~= 0 then
				PVP_KOS_Text:AddMessage(self:GetFormattedClassNameLink(newName, self:NameToAllianceColor(newName)) ..
					self:Colorize(v, "40BB40") .. self:GetCoolIcon() .. playerNote)
			else
				PVP_KOS_Text:AddMessage(self:GetFormattedClassNameLink(newName, self:NameToAllianceColor(newName, true),
					nil, true) ..
				self:GetFormattedAccountNameLink(v, "3F3F3F") .. self:GetCoolIcon(nil, true) .. playerNote)
			end
		end

		for k, v in ipairs(activeStringsArray) do
			PVP_KOS_Text:AddMessage(v)
		end
	end
end

function PVP:FindFriends()
	local currentTime = GetFrameTimeMilliseconds()
	local foundNames = {}
	if next(self.idToName) ~= nil then
		for k, v in pairs(self.idToName) do
            local cool = self:FindInCOOL(v)
			local hasPlayerNote = (self.SV.playerNotes[PVP.SV.playersDB[v].unitAccName] ~= nil)
			if self.SV.playersDB[v] and hasPlayerNote or (not IsPlayerInGroup(v)) and (IsFriend(v) or cool) then
				if not self.friends[v] and self.SV.playKOSSound and PVP.SV.KOSmode ~= 3 then
					if currentTime - self.friendSoundDelay > 2000 then
						PlaySound(SOUNDS.CROWN_CRATES_CARD_FLIPPING)
					end
					PlaySound(SOUNDS.CROWN_CRATES_CARD_FLIPPING)
					self.friendSoundDelay = currentTime
				end
				if IsFriend(v) then
					self.friends[v] = { currentTime = currentTime, isFriend = true, isResurrect = false }
				else
					self.friends[v] = { currentTime = currentTime, isFriend = false, isResurrect = false }
				end
				foundNames[v] = true
			end
		end
	end

	if next(self.playerNames) ~= nil then
		for k, _ in pairs(self.playerNames) do
			if not foundNames[k] then
                local cool = self:FindInCOOL(k)
				local hasPlayerNote = (self.SV.playerNotes[PVP.SV.playersDB[k].unitAccName] ~= nil)
				if hasPlayerNote or (not IsPlayerInGroup(k)) and (IsFriend(k) or cool) then
					if not self.friends[k] and self.SV.playKOSSound and PVP.SV.KOSmode ~= 3 then
						if currentTime - self.friendSoundDelay > 2000 then
							PlaySound(SOUNDS.CROWN_CRATES_CARD_FLIPPING)
						end
						PlaySound(SOUNDS.CROWN_CRATES_CARD_FLIPPING)
						self.friendSoundDelay = currentTime
					end
					if IsFriend(k) then
						self.friends[k] = { currentTime = currentTime, isFriend = true, isResurrect = false }
					else
						self.friends[k] = { currentTime = currentTime, isFriend = false, isResurrect = false }
					end
				end
			end
		end
	end

	for i = 1, #self.namesToDisplay do
		if self.friends[self.namesToDisplay[i]] and self.namesToDisplay[i].isResurrect then
			self.friends[self.namesToDisplay[i]].isResurrect = true
		end
	end


	for k, v in pairs(self.friends) do
		if v.currentTime ~= currentTime then self.friends[k] = nil end
	end
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

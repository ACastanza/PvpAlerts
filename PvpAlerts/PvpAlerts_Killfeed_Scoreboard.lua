---@class (partial) PvpAlerts
local PVP = PVP_Alerts_Main_Table

--local GetFrameTimeSeconds = GetFrameTimeSeconds
--local GetFrameTimeMilliseconds = GetFrameTimeMilliseconds
local GetGameTimeMilliseconds = GetGameTimeMilliseconds
--local GetGameTimeSeconds = GetGameTimeSeconds
local sort = table.sort
local insert = table.insert
--local remove = table.remove
--local concat = table.concat
--local upper = string.upper
--local lower = string.lower
local format = string.format
local sub = string.sub

-- local textColorBright = ZO_ColorDef:New({ r = 1, g = 1, b = 0, a = 1 })
-- local PLAYER_HIGHLIGHT_KILLFEED_COLOR = ZO_ColorDef:New({ r = 0.75, g = 0.75, b = 0, a = 1 })

local KillfeedScoreboardList = ZO_SortFilterList:Subclass()

-- local PVP_GOLD_COLOR = ZO_ColorDef:New({ r = 0.8, g = 0.8, b = 0, a = 1 })
-- local PVP_SILVER_COLOR = ZO_ColorDef:New({ r = 0.75, g = 0.75, b = 0.75, a = 1 })
-- local PVP_BRONZE_COLOR = ZO_ColorDef:New({ r = 0.847, g = 0.6, b = 0.357, a = 1 })

-- local PVP_PLAYER_COLOR_GREEN = ZO_ColorDef:New({ r = 0, g = 1, b = 0, a = 1 })
-- local PVP_PLAYER_COLOR_YELLOW = ZO_ColorDef:New({ r = 1, g = 1, b = 0, a = 1 })
-- local PVP_PLAYER_COLOR_RED = ZO_ColorDef:New({ r = 1, g = 0, b = 0, a = 1 })

-- Cache for alliance colors to reduce API calls
local allianceColorCache = {}

local function GetCachedAllianceColor(alliance)
    if not allianceColorCache[alliance] then
        allianceColorCache[alliance] = PVP:GetTrueAllianceColorsHex(alliance)
    end
    return allianceColorCache[alliance]
end

local function FormatPlayerDisplayName(characterName, displayName)
    local userDisplayNameType = (PVP.SV and PVP.SV.userDisplayNameType) or (PVP.defaults and PVP.defaults.userDisplayNameType) or "character"
    
    if userDisplayNameType == "user" then
        if displayName and displayName ~= "" then
            return zo_strformat(SI_UNIT_NAME, displayName)
        else
            return zo_strformat(SI_UNIT_NAME, characterName)
        end
    elseif userDisplayNameType == "both" then
        return zo_strformat(SI_UNIT_NAME, characterName) .. (displayName or "")
    else
        return zo_strformat(SI_UNIT_NAME, characterName)
    end
end

function PVP:IsGroupMember(characterName)
	if not characterName or characterName == "" then
		return false
	end
	
    local killfeedScoreboard = self.killfeedScoreboard
    if not killfeedScoreboard.historicalGroupMembers then
        killfeedScoreboard.historicalGroupMembers = {}
    end
    return killfeedScoreboard.historicalGroupMembers[characterName] or false
end

function PVP:UpdateHistoricalGroupMembers()
    local killfeedScoreboard = self.killfeedScoreboard
    if not killfeedScoreboard.historicalGroupMembers then
        killfeedScoreboard.historicalGroupMembers = {}
    end

	for i = 1, GetGroupSize() do
		local unitTag = GetGroupUnitTagByIndex(i)
		if unitTag then
			local displayName = GetUnitDisplayName(unitTag)
			if displayName and displayName ~= "" then
                killfeedScoreboard.historicalGroupMembers[displayName] = true
			end
		end
	end
end

function PVP:GetAvailableGuilds()
	local guilds = {}
	for i = 1, GetNumGuilds() do
		local guildId = GetGuildId(i)
		local guildName = GetGuildName(guildId)
		insert(guilds, { id = guildId, name = guildName })
	end
	return guilds
end

function PVP:IsGuildmateInSelected(displayName)
    local killfeedScoreboard = self.killfeedScoreboard
    if not killfeedScoreboard or not killfeedScoreboard.selectedGuilds then
		return false
	end
	
    local guildmates = self.guildmates
	if not guildmates or not guildmates[displayName] then
		return false
	end
	-- Check if player is in any of the selected guilds
	for guildId, _ in pairs(guildmates[displayName]) do
        if killfeedScoreboard.selectedGuilds[guildId] then
			return true
		end
	end
	
	return false
end

function PVP:GetPlayerRecentEvents(playerName)
    local killfeedScoreboard = self.killfeedScoreboard
    if not killfeedScoreboard.playerStats or not killfeedScoreboard.playerStats[playerName] then
        return {}
    end
    
    local allEvents = killfeedScoreboard.playerStats[playerName].events or {}
    local events = {}
    
    for _, event in ipairs(allEvents) do
        local isKill = (event.source == playerName)
        
        insert(events, {
            type = isKill and "kill" or "death",
            opponent = isKill and event.target or event.source,
            opponentDisplayName = isKill and event.targetDisplayName or event.sourceDisplayName,
            opponentAlliance = isKill and event.targetAlliance or event.sourceAlliance,
            opponentClass = isKill and event.targetClass or event.sourceClass,
            timestamp = event.timestamp
        })
    end
    
    sort(events, function(a, b) return a.timestamp > b.timestamp end)
    
    return events
end

function PVP:CalculatePlayerAggregateStats(playerName, applyFilters)
    local killfeedScoreboard = self.killfeedScoreboard
    if not killfeedScoreboard.playerStats or not killfeedScoreboard.playerStats[playerName] then
        return nil
    end
    
    local stats = killfeedScoreboard.playerStats[playerName]
    local events = stats.events or {}
    
    local killsByAlliance = {
        [ALLIANCE_ALDMERI_DOMINION] = 0,
        [ALLIANCE_DAGGERFALL_COVENANT] = 0,
        [ALLIANCE_EBONHEART_PACT] = 0
    }
    local deathsByAlliance = {
        [ALLIANCE_ALDMERI_DOMINION] = 0,
        [ALLIANCE_DAGGERFALL_COVENANT] = 0,
        [ALLIANCE_EBONHEART_PACT] = 0
    }
    
    local kills = 0
    local deaths = 0
    
    local playerInGroup = false
    local playerInGuild = false
    if applyFilters and (killfeedScoreboard.filterGroupOnly or killfeedScoreboard.filterGuildOnly) then
        if killfeedScoreboard.filterGroupOnly and stats.displayName then
            playerInGroup = self:IsGroupMember(stats.displayName)
        end
        if killfeedScoreboard.filterGuildOnly and stats.displayName then
            playerInGuild = self:IsGuildmateInSelected(stats.displayName)
        end
    end
    
    if applyFilters and (killfeedScoreboard.filterGroupOnly or killfeedScoreboard.filterGuildOnly) then
        for _, event in ipairs(events) do
            local isKill = (event.source == playerName)
            local opponent = isKill and event.target or event.source
            local opponentDisplayName = isKill and event.targetDisplayName or event.sourceDisplayName
            local opponentAlliance = isKill and event.targetAlliance or event.sourceAlliance

            local isOpponentAllianceDisabled = opponentAlliance and killfeedScoreboard.disabledAlliances[opponentAlliance]
            
            if not killfeedScoreboard.disabledPlayers[opponent] and not isOpponentAllianceDisabled then
                local countThisEvent = false
                if playerInGroup or playerInGuild then
                    countThisEvent = true
                end
                if not countThisEvent and opponentDisplayName then
                    if killfeedScoreboard.filterGroupOnly and self:IsGroupMember(opponentDisplayName) then
                        countThisEvent = true
                    end
                    if killfeedScoreboard.filterGuildOnly and self:IsGuildmateInSelected(opponentDisplayName) then
                        countThisEvent = true
                    end
                end
                
                if countThisEvent then
                    if isKill then
                        kills = kills + 1
                        if opponentAlliance then
                            killsByAlliance[opponentAlliance] = killsByAlliance[opponentAlliance] + 1
                        end
                    else
                        deaths = deaths + 1
                        if opponentAlliance then
                            deathsByAlliance[opponentAlliance] = deathsByAlliance[opponentAlliance] + 1
                        end
                    end
                end
            end
        end
    else
        for _, event in ipairs(events) do
            local isKill = (event.source == playerName)
            local opponent = isKill and event.target or event.source
            local opponentAlliance = isKill and event.targetAlliance or event.sourceAlliance
            
            local isOpponentAllianceDisabled = opponentAlliance and killfeedScoreboard.disabledAlliances[opponentAlliance]

            if not killfeedScoreboard.disabledPlayers[opponent] and not isOpponentAllianceDisabled then
                if isKill then
                    kills = kills + 1
                    if opponentAlliance then
                        killsByAlliance[opponentAlliance] = killsByAlliance[opponentAlliance] + 1
                    end
                else
                    deaths = deaths + 1
                    if opponentAlliance then
                        deathsByAlliance[opponentAlliance] = deathsByAlliance[opponentAlliance] + 1
                    end
                end
            end
        end
    end
    
    return {
        kills = kills,
        deaths = deaths,
        killsByAlliance = killsByAlliance,
        deathsByAlliance = deathsByAlliance
    }
end

function PVP_ShowPlayerDetails(playerName)
	if not PVP.killfeedScoreboard.playerStats or not PVP.killfeedScoreboard.playerStats[playerName] then return end
	
	PVP.killfeedScoreboard.currentDetailsPlayerName = playerName
	
	local playerStats = PVP.killfeedScoreboard.playerStats[playerName]
	local aggregates = PVP:CalculatePlayerAggregateStats(playerName, true)
	
	if not aggregates then return end
	
	local classID = playerStats.class or 0
	local classIcon = ""
	if classID > 0 and PVP.classIcons then
		classIcon = PVP.classIcons[classID] or ""
	end
	
	local formattedPlayerName = FormatPlayerDisplayName(playerName, playerStats.displayName)
	
	local nameText
	if classIcon ~= "" then
		nameText = zo_iconFormatInheritColor(classIcon, 28, 28) .. " " .. formattedPlayerName
	else
		nameText = formattedPlayerName
	end
	
	local allianceHex = GetCachedAllianceColor(playerStats.alliance or ALLIANCE_NONE)
	nameText = PVP:Colorize(nameText, allianceHex)
	
	PVP_KillfeedPlayerDetailsPlayerName:SetText(nameText)
	PVP_KillfeedPlayerDetailsPlayerName:SetMouseEnabled(true)
	PVP_KillfeedPlayerDetailsPlayerName:SetHandler("OnMouseUp", function(self, button, upInside)
		if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
			if CHAT_SYSTEM and CHAT_SYSTEM.ShowPlayerContextMenu then
				CHAT_SYSTEM:ShowPlayerContextMenu(playerStats.displayName, playerName)
			end
		end
	end)
	
	local kdRatio = aggregates.deaths > 0 and (aggregates.kills / aggregates.deaths) or aggregates.kills
	local statsText = format("Kills: %s | Deaths: %s | K/D: %s",
		PVP:Colorize(tostring(aggregates.kills), "00FF00"),
		PVP:Colorize(tostring(aggregates.deaths), "FF0000"),
		PVP:Colorize(format("%.2f", kdRatio), "FFFF00")
	)
	
	local adHex = GetCachedAllianceColor(ALLIANCE_ALDMERI_DOMINION)
	local dcHex = GetCachedAllianceColor(ALLIANCE_DAGGERFALL_COVENANT)
	local epHex = GetCachedAllianceColor(ALLIANCE_EBONHEART_PACT)
	
	statsText = statsText .. "\n" .. format("vs |c%sAD|r: %d/%d  |  vs |c%sDC|r: %d/%d  |  vs |c%sEP|r: %d/%d",
		adHex, aggregates.killsByAlliance[ALLIANCE_ALDMERI_DOMINION] or 0, aggregates.deathsByAlliance[ALLIANCE_ALDMERI_DOMINION] or 0,
		dcHex, aggregates.killsByAlliance[ALLIANCE_DAGGERFALL_COVENANT] or 0, aggregates.deathsByAlliance[ALLIANCE_DAGGERFALL_COVENANT] or 0,
		epHex, aggregates.killsByAlliance[ALLIANCE_EBONHEART_PACT] or 0, aggregates.deathsByAlliance[ALLIANCE_EBONHEART_PACT] or 0
	)
	
	PVP_KillfeedPlayerDetailsStats:SetText(statsText)
	
	local events = PVP:GetPlayerRecentEvents(playerName)
	
	if not PVP.killfeedScoreboard.eventsList then
		local eventListControl = PVP_KillfeedPlayerDetailsEventList
		if eventListControl then
            PVP.killfeedScoreboard.eventsList = eventListControl
            ZO_ScrollList_AddDataType(PVP.killfeedScoreboard.eventsList, 1, "PVP_KillfeedPlayerDetailsEventRow", 32,
                function(control, data)
                    control:SetText(data.text)
                    control.eventData = data
                    control:SetMouseEnabled(true)
                    
                    control:SetHandler("OnMouseUp", function(self, button, upInside)
                        if upInside and button == MOUSE_BUTTON_INDEX_RIGHT and self.eventData and self.eventData.opponentName and self.eventData.opponentDisplayName then
                            if CHAT_SYSTEM and CHAT_SYSTEM.ShowPlayerContextMenu then
                                CHAT_SYSTEM:ShowPlayerContextMenu(self.eventData.opponentDisplayName, self.eventData.opponentName)
                            end
                        end
                    end)
                end)
		end
	end
	
	if PVP.killfeedScoreboard.eventsList then
		local scrollData = ZO_ScrollList_GetDataList(PVP.killfeedScoreboard.eventsList)
		ZO_ScrollList_Clear(PVP.killfeedScoreboard.eventsList)
		
        local subjectMatchesFilter = false
        if PVP.killfeedScoreboard.filterGroupOnly or PVP.killfeedScoreboard.filterGuildOnly then
            if PVP.killfeedScoreboard.filterGroupOnly and PVP:IsGroupMember(playerStats.displayName) then
                subjectMatchesFilter = true
            elseif PVP.killfeedScoreboard.filterGuildOnly and PVP:IsGuildmateInSelected(playerStats.displayName) then
                subjectMatchesFilter = true
            end
        end

		for _, event in ipairs(events) do
			local timestamp = event.timestamp
			local timeStr = ZO_FormatTime(zo_floor((GetGameTimeMilliseconds() - timestamp) / 1000), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)
			
			local formattedOpponentName = FormatPlayerDisplayName(event.opponent, event.opponentDisplayName)
			
            local isOpponentDisabled = PVP.killfeedScoreboard.disabledPlayers[event.opponent] or false
            local isOpponentAllianceDisabled = PVP.killfeedScoreboard.disabledAlliances[event.opponentAlliance] or false
            local isOpponentFilteredOut = false
            
            if PVP.killfeedScoreboard.filterGroupOnly or PVP.killfeedScoreboard.filterGuildOnly then
                if not subjectMatchesFilter then
                    local matchesFilter = false
                    local opponentDisplayName = event.opponentDisplayName
                    
                    if PVP.killfeedScoreboard.filterGroupOnly and PVP:IsGroupMember(opponentDisplayName) then
                        matchesFilter = true
                    elseif PVP.killfeedScoreboard.filterGuildOnly and PVP:IsGuildmateInSelected(opponentDisplayName) then
                        matchesFilter = true
                    end
                    
                    if not matchesFilter then isOpponentFilteredOut = true end
                else
                    isOpponentFilteredOut = false
                end
            end
            
            local isDimmed = isOpponentDisabled or isOpponentAllianceDisabled or isOpponentFilteredOut

			local opponentAllianceHex = PVP:AllianceToColor(event.opponentAlliance or ALLIANCE_NONE, isDimmed)
			local opponentName = PVP:Colorize(formattedOpponentName, opponentAllianceHex)
			
			local eventText
			if event.type == "kill" then
				eventText = format("[%s] %s killed %s", timeStr, PVP:Colorize("KILL", "00FF00"), opponentName)
			else
				eventText = format("[%s] %s by %s", timeStr, PVP:Colorize("DEATH", "FF0000"), opponentName)
			end
			
			insert(scrollData, ZO_ScrollList_CreateDataEntry(1, { 
				text = eventText,
				opponentName = event.opponent,
				opponentDisplayName = event.opponentDisplayName
			}))
		end
		
		if #scrollData == 0 then
			insert(scrollData, ZO_ScrollList_CreateDataEntry(1, { text = "No events recorded" }))
		end
		
		ZO_ScrollList_Commit(PVP.killfeedScoreboard.eventsList)
	end
	
	PVP_KillfeedPlayerDetails:SetHidden(false)
	PVP_KillfeedPlayerDetails:BringWindowToTop()
end

function PVP:RefreshPlayerDetailsIfOpen()
    local killfeedScoreboard = self.killfeedScoreboard
    if killfeedScoreboard.currentDetailsPlayerName and 
	   PVP_KillfeedPlayerDetails and 
	   not PVP_KillfeedPlayerDetails:IsHidden() then
        PVP_ShowPlayerDetails(killfeedScoreboard.currentDetailsPlayerName)
	end
end

function PVP:RefreshKillfeedScoreboards()
    local killfeedScoreboard = self.killfeedScoreboard
    if not killfeedScoreboard or not killfeedScoreboard.lists then return end
    
    if not killfeedScoreboard.playerStats then
        killfeedScoreboard.playerStats = {}
    end
    
    self:UpdateHistoricalGroupMembers()

    local totalPlayers = 0
    local disabledPlayers = 0
    
    local allianceStats = {}
    local alliancePlayers = {}
    for i = 1, 3 do
        allianceStats[i] = { 
            alliance = i, 
            totalKills = 0, 
            totalDeaths = 0,
            totalPlayers = 0,
            enabledPlayers = 0,
            killsByAlliance = {
                [ALLIANCE_ALDMERI_DOMINION] = 0,
                [ALLIANCE_DAGGERFALL_COVENANT] = 0,
                [ALLIANCE_EBONHEART_PACT] = 0
            },
            deathsByAlliance = {
                [ALLIANCE_ALDMERI_DOMINION] = 0,
                [ALLIANCE_DAGGERFALL_COVENANT] = 0,
                [ALLIANCE_EBONHEART_PACT] = 0
            }
        }
        alliancePlayers[i] = {}
    end
    
    for playerName, stats in pairs(killfeedScoreboard.playerStats) do
        local alliance = stats.alliance
        
        local passesDirectFilter = false
        if not killfeedScoreboard.filterGroupOnly and not killfeedScoreboard.filterGuildOnly then
            passesDirectFilter = true
        else
            if killfeedScoreboard.filterGroupOnly and self:IsGroupMember(stats.displayName) then
                passesDirectFilter = true
            elseif killfeedScoreboard.filterGuildOnly and self:IsGuildmateInSelected(stats.displayName) then
                passesDirectFilter = true
            end
        end

        local isPlayerDisabled = killfeedScoreboard.disabledPlayers[playerName] or false
        local isAllianceDisabled = (alliance and killfeedScoreboard.disabledAlliances[alliance]) or false
        local isDisabled = isPlayerDisabled or isAllianceDisabled
        
        local applyFilters = true 
        local aggregates = self:CalculatePlayerAggregateStats(playerName, applyFilters)
        local includePlayer = false
        
        if passesDirectFilter then
             includePlayer = true
        elseif aggregates and (aggregates.kills + aggregates.deaths > 0) then
             includePlayer = true
        end

        if includePlayer then
            if isDisabled then
                disabledPlayers = disabledPlayers + 1
                if alliance and allianceStats[alliance] then
                    allianceStats[alliance].totalPlayers = allianceStats[alliance].totalPlayers + 1
                end
            else
                totalPlayers = totalPlayers + 1
                if alliance and allianceStats[alliance] then
                    allianceStats[alliance].totalPlayers = allianceStats[alliance].totalPlayers + 1
                    allianceStats[alliance].enabledPlayers = allianceStats[alliance].enabledPlayers + 1
                end
            end
            
            if alliance and alliancePlayers[alliance] then
                if aggregates then
                    local kills = aggregates.kills
                    local deaths = aggregates.deaths
                    
                    insert(alliancePlayers[alliance], {
                        name = playerName,
                        sortName = FormatPlayerDisplayName(playerName, stats.displayName),
                        displayName = stats.displayName,
                        kills = kills,
                        deaths = deaths,
                        killsByAlliance = aggregates.killsByAlliance,
                        deathsByAlliance = aggregates.deathsByAlliance,
                        alliance = alliance,
                        rank = stats.rank or 9999,
                        class = stats.class or 0,
                        lastSeen = stats.lastSeen or 0,
                        kd = (deaths > 0) and (kills / deaths) or kills,
                    })
                    
                    if not isDisabled then
                        allianceStats[alliance].totalKills = allianceStats[alliance].totalKills + kills
                        allianceStats[alliance].totalDeaths = allianceStats[alliance].totalDeaths + deaths
                        
                        if aggregates.killsByAlliance then
                            for kAlliance, count in pairs(aggregates.killsByAlliance) do
                                allianceStats[alliance].killsByAlliance[kAlliance] = (allianceStats[alliance].killsByAlliance[kAlliance] or 0) + count
                            end
                        end
                        if aggregates.deathsByAlliance then
                            for kAlliance, count in pairs(aggregates.deathsByAlliance) do
                                allianceStats[alliance].deathsByAlliance[kAlliance] = (allianceStats[alliance].deathsByAlliance[kAlliance] or 0) + count
                            end
                        end
                    end
                end
            end
        end
    end
    
    local totalPlayersText = "Players: " .. tostring(totalPlayers)
    if disabledPlayers > 0 then
        totalPlayersText = totalPlayersText .. " (" .. tostring(disabledPlayers) .. " disabled)"
    end
    if PVP_KillfeedScoreboardPlayers then
        PVP_KillfeedScoreboardPlayers:SetText(totalPlayersText)
    end
    
    if PVP_KillfeedScoreboardInfo then
        PVP_KillfeedScoreboardInfo:SetText("Killfeed Scoreboard - " .. GetPlayerLocationName())
    end
    
    sort(allianceStats, function(a, b)
        local kdA = a.totalDeaths > 0 and (a.totalKills / a.totalDeaths) or a.totalKills
        local kdB = b.totalDeaths > 0 and (b.totalKills / b.totalDeaths) or b.totalKills
        return kdA > kdB
    end)
    
    for i = 1, 3 do
        local statsData = allianceStats[i]
        local alliance = statsData.alliance
        local players = alliancePlayers[alliance]
        
        sort(players, function(a, b)
            return a.kd > b.kd
        end)
        
        killfeedScoreboard.lists[i].masterList = players
        
        local allianceName = GetAllianceName(alliance)
        local icon = GetAllianceBannerIcon(alliance)
        
        local isAllianceDisabled = killfeedScoreboard.disabledAlliances[alliance] or false
        local colorHex = self:AllianceToColor(alliance, isAllianceDisabled)
        
        local totalKills = statsData.totalKills
        local totalDeaths = statsData.totalDeaths
        local kd = (totalDeaths > 0) and (totalKills / totalDeaths) or totalKills
        local kdText = format("%.2f", kd)
        local headerNameText = zo_iconFormatInheritColor(icon, 28, 28) .. "  " .. allianceName .. "  (K/D " .. kdText .. ")"
        
        if isAllianceDisabled then
             headerNameText = headerNameText .. " (Disabled)"
        end
        
        local enabledCount = statsData.enabledPlayers or 0
        local totalCount = statsData.totalPlayers or 0
        local playerCountText
        if totalCount > enabledCount then
            playerCountText = enabledCount .. "/" .. totalCount
        else
            playerCountText = tostring(enabledCount)
        end
        
        local headerStatsText = "Kills: " .. tostring(totalKills) .. " | Deaths: " .. tostring(totalDeaths) .. " (Players: " .. playerCountText .. ")"
        
        local headerControl = PVP_KillfeedScoreboard:GetNamedChild("List" .. i .. "AllianceHeader")
        if headerControl then
            headerControl.allianceId = alliance
            headerControl.statsData = statsData
            headerControl:SetText(self:Colorize(headerNameText, colorHex))
        end
        local subHeaderControl = PVP_KillfeedScoreboard:GetNamedChild("List" .. i .. "AllianceSubHeader")
        if subHeaderControl then
            subHeaderControl:SetText(self:Colorize(headerStatsText, colorHex))
        end
        
        killfeedScoreboard.lists[i]:RefreshData()
    end
end

function PVP_InitKillfeedScoreboard()
    PVP.killfeedScoreboard = {}

    if not PVP.killfeedScoreboard.lists then
        if not PVP_KillfeedScoreboard then
            return
        end
        
        PVP.killfeedScoreboard.lists = {}
        for i = 1, 3 do
            local control = PVP_KillfeedScoreboard:GetNamedChild("List" .. i)
            if not control then
                return
            end
            PVP.killfeedScoreboard.lists[i] = KillfeedScoreboardList:New(control)
            
            local header = control:GetNamedChild("AllianceHeader")
            if header then
                header:SetMouseEnabled(true)
                header:SetHandler("OnMouseUp", function(self, button, upInside)
                    if upInside and button == MOUSE_BUTTON_INDEX_LEFT and self.allianceId then
                        local allianceId = self.allianceId
                        if PVP.killfeedScoreboard.disabledAlliances[allianceId] then
                            PVP.killfeedScoreboard.disabledAlliances[allianceId] = nil
                        else
                            PVP.killfeedScoreboard.disabledAlliances[allianceId] = true
                        end
                        PVP:RefreshKillfeedScoreboards()
                        PVP:RefreshPlayerDetailsIfOpen()
                    end
                end)
                
                header:SetHandler("OnMouseEnter", function(self)
                    if not self.allianceId then return end
                    InitializeTooltip(InformationTooltip, self, TOP, 0, 0)
                    local isDisabled = PVP.killfeedScoreboard.disabledAlliances[self.allianceId]
                    local actionText = isDisabled and "Click to Enable Alliance" or "Click to Disable Alliance"
                    InformationTooltip:AddLine(actionText, "", 1, 1, 1)

                    if self.statsData then
                        ZO_Tooltip_AddDivider(InformationTooltip)
                        
                        local adHex = GetCachedAllianceColor(ALLIANCE_ALDMERI_DOMINION)
                        local dcHex = GetCachedAllianceColor(ALLIANCE_DAGGERFALL_COVENANT)
                        local epHex = GetCachedAllianceColor(ALLIANCE_EBONHEART_PACT)
                        
                        local killsLine = ""
                        if self.allianceId ~= ALLIANCE_ALDMERI_DOMINION then
                             killsLine = killsLine .. "|c" .. adHex .. "AD|r: " .. (self.statsData.killsByAlliance[ALLIANCE_ALDMERI_DOMINION] or 0) .. "  |  "
                        end
                        if self.allianceId ~= ALLIANCE_DAGGERFALL_COVENANT then
                             killsLine = killsLine .. "|c" .. dcHex .. "DC|r: " .. (self.statsData.killsByAlliance[ALLIANCE_DAGGERFALL_COVENANT] or 0) .. "  |  "
                        end
                        if self.allianceId ~= ALLIANCE_EBONHEART_PACT then
                             killsLine = killsLine .. "|c" .. epHex .. "EP|r: " .. (self.statsData.killsByAlliance[ALLIANCE_EBONHEART_PACT] or 0)
                        end
                         
                        local deathsLine = ""
                        if self.allianceId ~= ALLIANCE_ALDMERI_DOMINION then
                             deathsLine = deathsLine .. "|c" .. adHex .. "AD|r: " .. (self.statsData.deathsByAlliance[ALLIANCE_ALDMERI_DOMINION] or 0) .. "  |  "
                        end
                        if self.allianceId ~= ALLIANCE_DAGGERFALL_COVENANT then
                             deathsLine = deathsLine .. "|c" .. dcHex .. "DC|r: " .. (self.statsData.deathsByAlliance[ALLIANCE_DAGGERFALL_COVENANT] or 0) .. "  |  "
                        end
                        if self.allianceId ~= ALLIANCE_EBONHEART_PACT then
                             deathsLine = deathsLine .. "|c" .. epHex .. "EP|r: " .. (self.statsData.deathsByAlliance[ALLIANCE_EBONHEART_PACT] or 0)
                        end
                        
                        if sub(killsLine, -5) == "  |  " then killsLine = sub(killsLine, 1, -6) end
                        if sub(deathsLine, -5) == "  |  " then deathsLine = sub(deathsLine, 1, -6) end
                                          
                        InformationTooltip:AddLine("Kills by Alliance:", "ZoFontWinH4", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
                        InformationTooltip:AddLine(killsLine, "ZoFontWinH4", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)

                        InformationTooltip:AddLine("Deaths by Alliance:", "ZoFontWinH4", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
                        InformationTooltip:AddLine(deathsLine, "ZoFontWinH4", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
                    end
                end)
                
                header:SetHandler("OnMouseExit", function(self)
                    ClearTooltip(InformationTooltip)
                end)
            end
        end
        PVP.killfeedScoreboard.playerStats = {}
        PVP.killfeedScoreboard.isLogging = false
        PVP.killfeedScoreboard.historicalGroupMembers = {}
        PVP.killfeedScoreboard.disabledPlayers = {}
        PVP.killfeedScoreboard.disabledAlliances = {}
        PVP.killfeedScoreboard.filterGroupOnly = false
        PVP.killfeedScoreboard.filterGuildOnly = false
        PVP.killfeedScoreboard.selectedGuilds = {}
        PVP.killfeedScoreboard.currentDetailsPlayerName = nil

        for i = 1, GetNumGuilds() do
            local guildId = GetGuildId(i)
            PVP.killfeedScoreboard.selectedGuilds[guildId] = true
        end
        
        PVP.killfeedScoreboard.guildComboBox = nil
        
        PVP.killfeedScoreboard.scene = ZO_Scene:New("PVPKillfeedScoreboardScene", SCENE_MANAGER)
        PVP_KILLFEED_SCOREBOARD_FRAGMENT = ZO_FadeSceneFragment:New(PVP_KillfeedScoreboard, nil, 0)
        PVP.killfeedScoreboard.scene:AddFragment(PVP_KILLFEED_SCOREBOARD_FRAGMENT)
        PVP.killfeedScoreboard.scene:AddFragment(UNIT_FRAMES_FRAGMENT)
        PVP.killfeedScoreboard.scene:AddFragment(UI_COMBAT_OVERLAY_FRAGMENT)
        PVP.killfeedScoreboard.scene:AddFragment(MOUSE_UI_MODE_FRAGMENT)
        
        PVP.killfeedScoreboard.scene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWING then
                PVP:RefreshKillfeedScoreboards()
            elseif newState == SCENE_HIDDEN then
                if PVP_KillfeedPlayerDetails then
                    PVP_KillfeedPlayerDetails:SetHidden(true)
                    PVP.killfeedScoreboard.currentDetailsPlayerName = nil
                end
            end
        end)
        
        PVP:RefreshKillfeedScoreboards()
        
        local guildFilterButton = PVP_KillfeedScoreboard:GetNamedChild("GuildFilterButton")
        local groupFilterButton = PVP_KillfeedScoreboard:GetNamedChild("GroupFilterButton")
        
        if guildFilterButton then
            guildFilterButton:SetAlpha(0.5)
        end
        
        if groupFilterButton then
            groupFilterButton:SetAlpha(0.5)
        end
        
        if PVP_KillfeedPlayerDetails then
            PVP_KillfeedPlayerDetails:SetHandler("OnKeyDown", function(control, key)
                if key == KEY_ESCAPE then
                    control:SetHidden(true)
                    PVP.killfeedScoreboard.currentDetailsPlayerName = nil
                    return true
                end
                return false
            end)
        end
    end
end

function PVP:KillfeedScoreboardToggle(isKeyDown)
    local killfeedScoreboard = self.killfeedScoreboard
    if not killfeedScoreboard.lists then
		PVP_InitKillfeedScoreboard()
	end
	
	if not PVP_KillfeedScoreboard then
		d("[PvpAlerts] PVP_KillfeedScoreboard control not found!")
		return
	end
	
    if self.SV.killfeedScoreboardToggle then
		if isKeyDown then
			if PVP_KillfeedScoreboard:IsControlHidden() then
				SCENE_MANAGER:Show("PVPKillfeedScoreboardScene")
                self:RefreshKillfeedScoreboards()
			else
				SCENE_MANAGER:Hide("PVPKillfeedScoreboardScene")
			end
		end
	else
		if isKeyDown then
			SCENE_MANAGER:Show("PVPKillfeedScoreboardScene")
            self:RefreshKillfeedScoreboards()
		else
			SCENE_MANAGER:Hide("PVPKillfeedScoreboardScene")
		end
	end
end

function PVP:ToggleGroupMemberFilter()
    local killfeedScoreboard = self.killfeedScoreboard
    killfeedScoreboard.filterGroupOnly = not killfeedScoreboard.filterGroupOnly
    self:RefreshKillfeedScoreboards()
    self:RefreshPlayerDetailsIfOpen()
    return killfeedScoreboard.filterGroupOnly
end

function PVP:ToggleGuildMemberFilter()
    local killfeedScoreboard = self.killfeedScoreboard
    killfeedScoreboard.filterGuildOnly = not killfeedScoreboard.filterGuildOnly
    self:RefreshKillfeedScoreboards()
    self:RefreshPlayerDetailsIfOpen()
    return killfeedScoreboard.filterGuildOnly
end

function PVP:ToggleGuildInFilter(guildId)
    local killfeedScoreboard = self.killfeedScoreboard
    if not killfeedScoreboard.selectedGuilds then
        killfeedScoreboard.selectedGuilds = {}
	end
	
    if killfeedScoreboard.selectedGuilds[guildId] then
        killfeedScoreboard.selectedGuilds[guildId] = nil
	else
        killfeedScoreboard.selectedGuilds[guildId] = true
	end
	
    self:RefreshKillfeedScoreboards()
    self:RefreshPlayerDetailsIfOpen()
    return killfeedScoreboard.selectedGuilds[guildId] or false
end

function PVP:IsGuildSelected(guildId)
    local killfeedScoreboard = self.killfeedScoreboard
    return killfeedScoreboard.selectedGuilds and killfeedScoreboard.selectedGuilds[guildId] or false
end

function KillfeedScoreboardList:New(control)
	local list = ZO_SortFilterList.New(self, control)
	list.frame = control:GetParent()
	list.control = control
	list:Setup()
	return list
end

function KillfeedScoreboardList:Setup()
    ZO_ScrollList_AddDataType(self.list, 70, "PVP_KillfeedScoreboardRow", 28,
        function(control, data) self:SetupPlayerRow(control, data) end)
    ZO_ScrollList_AddDataType(self.list, 71, "PVP_KillfeedScoreboardSectionHeader", 32,
        function(control, data) self:SetupAllianceHeader(control, data) end)
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
    self:SetAlternateRowBackgrounds(false)

    self.masterList = {}
    
    local sortKeys = {
        ["name"] = { caseInsensitive = true },
        ["sortName"] = { caseInsensitive = true },
        ["kd"] = { tiebreaker = "sortName" },
        ["kills"] = { tiebreaker = "sortName" },
        ["deaths"] = { tiebreaker = "sortName" },
    }
    
    self.sortHeaderGroup:SelectHeaderByKey("kd")
    self.currentSortKey = "kd"
    self.currentSortOrder = ZO_SORT_ORDER_DOWN
    
	self.sortFunction = function(listEntry1, listEntry2)
		local key = self.currentSortKey
		if key == "name" then
			key = "sortName"
		end
		return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, key, sortKeys, self.currentSortOrder)
	end
end

function KillfeedScoreboardList:BuildMasterList()
end

function KillfeedScoreboardList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	if self.masterList and #self.masterList > 0 then
		for i = 1, #self.masterList do
			insert(scrollData, ZO_ScrollList_CreateDataEntry(70, self.masterList[i]))
		end
	end
end

function KillfeedScoreboardList:SortScrollList()
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
		local scrollData = ZO_ScrollList_GetDataList(self.list)
		sort(scrollData, self.sortFunction)
	end

	self:RefreshVisible()
end

function KillfeedScoreboardList:SetupAllianceHeader(control, data)
	local alliance = data.alliance
	local allianceName = GetAllianceName(alliance)
	local icon = GetAllianceBannerIcon(alliance)
    local colorHex = GetCachedAllianceColor(alliance)
    local totalKills = data.totalKills or 0
    local totalDeaths = data.totalDeaths or 0
    local kd = (totalDeaths > 0) and (totalKills / totalDeaths) or totalKills
    local kdText = format("%.2f", kd)
    
    local enabledPlayers = data.enabledPlayers or 0
    local totalPlayers = data.totalPlayers or 0
    local playerCountText
    if totalPlayers > enabledPlayers then
        playerCountText = enabledPlayers .. "/" .. totalPlayers
    else
        playerCountText = tostring(enabledPlayers)
    end
    
    local titleText = zo_iconFormatInheritColor(icon, 28, 28) .. "  " .. allianceName .. "  (" .. playerCountText .. " players, K/D " .. kdText .. ")\n" ..
        tostring(totalKills) .. " | " .. tostring(totalDeaths) .. " | " .. kdText
	control:GetNamedChild("Title"):SetText(PVP:Colorize(titleText, colorHex))
end

function KillfeedScoreboardList:SetupPlayerRow(control, data)
    local isPlayer = data.name == (PVP.playerName or GetRawUnitName('player'))

    control.data = data
    control.listParent = self

    local classID = data.class
    local classIcon = ""
    if classID and classID > 0 and PVP.classIcons then
        classIcon = PVP.classIcons[classID] or ""
    end

    local formattedDisplayName = FormatPlayerDisplayName(data.name, data.displayName)

    local isPlayerDisabled = PVP.killfeedScoreboard.disabledPlayers[data.name] or false
    local isAllianceDisabled = PVP.killfeedScoreboard.disabledAlliances[data.alliance] or false
    local isDisabled = isPlayerDisabled or isAllianceDisabled

    local nameText
    if classIcon ~= "" then
        nameText = zo_iconFormatInheritColor(classIcon, 28, 28) .. formattedDisplayName
    else
        nameText = formattedDisplayName
    end

    local allianceHex = PVP:AllianceToColor(data.alliance or ALLIANCE_NONE, isDisabled)
    nameText = PVP:Colorize(nameText, allianceHex)
    control:GetNamedChild("Name"):SetText(nameText)

    local killsText = PVP:Colorize(tostring(data.kills), "00FF00")
    control:GetNamedChild("Kills"):SetText(killsText)

    local deathsText = PVP:Colorize(tostring(data.deaths), "FF0000")
    control:GetNamedChild("Deaths"):SetText(deathsText)

    local kdRatio = data.deaths > 0 and (data.kills / data.deaths) or data.kills
    local kdText = PVP:Colorize(format("%.2f", kdRatio), "FFFF00")
    control:GetNamedChild("KD"):SetText(kdText)

    ZO_SortFilterList.SetupRow(self, control, data)
end

function PVP_KillfeedScoreboardRow_OnMouseEnter(control)
	if control.listParent then
		control.listParent:Row_OnMouseEnter(control)
	end
	
	InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
	
	local isDisabled = PVP.killfeedScoreboard.disabledPlayers[control.data.name] or false
	local toggleText = isDisabled and "Left-click to Enable | Right-click for Details" or "Left-click to Disable | Right-click for Details"
	InformationTooltip:AddLine(toggleText, "ZoFontWinH5", 0.7, 0.7, 0.7, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	ZO_Tooltip_AddDivider(InformationTooltip)
	
	
	local classID = control.data.class
	local classIcon = ""
	if classID and classID > 0 and PVP.classIcons then
		classIcon = PVP.classIcons[classID] or ""
	end
	
    local formattedTooltipName = FormatPlayerDisplayName(control.data.name, control.data.displayName)

    local formattedName
    if classIcon ~= "" then
        formattedName = zo_iconFormatInheritColor(classIcon, 28, 28) .. formattedTooltipName
    else
        formattedName = formattedTooltipName
    end
	
	InformationTooltip:AddLine(formattedName, "ZoFontWinH2", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	
	if classID and classID > 0 then
		local formattedClass = GetClassName(0, classID)
		InformationTooltip:AddLine(formattedClass, "ZoFontWinH4", 0.772, 0.760, 0.619, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	end
	
	ZO_Tooltip_AddDivider(InformationTooltip)
	
	local kdRatio = control.data.deaths > 0 and (control.data.kills / control.data.deaths) or control.data.kills
	
	InformationTooltip:AddLine(
		"Overall: " .. control.data.kills .. " Kills | " .. control.data.deaths .. " Deaths | K/D: " .. format("%.2f", kdRatio),
		"ZoFontWinH4", 1, 1, 0.5, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER
	)
	if control.data.killsByAlliance then
		local adKills = control.data.killsByAlliance[ALLIANCE_ALDMERI_DOMINION] or 0
		local dcKills = control.data.killsByAlliance[ALLIANCE_DAGGERFALL_COVENANT] or 0
		local epKills = control.data.killsByAlliance[ALLIANCE_EBONHEART_PACT] or 0
		
		local adHex = GetCachedAllianceColor(ALLIANCE_ALDMERI_DOMINION)
		local dcHex = GetCachedAllianceColor(ALLIANCE_DAGGERFALL_COVENANT)
		local epHex = GetCachedAllianceColor(ALLIANCE_EBONHEART_PACT)
		
		local killsLine = ""
		if control.data.alliance ~= ALLIANCE_ALDMERI_DOMINION then
             killsLine = killsLine .. "|c" .. adHex .. "AD|r: " .. adKills .. "  |  "
        end
		if control.data.alliance ~= ALLIANCE_DAGGERFALL_COVENANT then
             killsLine = killsLine .. "|c" .. dcHex .. "DC|r: " .. dcKills .. "  |  "
        end
		if control.data.alliance ~= ALLIANCE_EBONHEART_PACT then
             killsLine = killsLine .. "|c" .. epHex .. "EP|r: " .. epKills
        end
        if sub(killsLine, -5) == "  |  " then killsLine = sub(killsLine, 1, -6) end
		
		InformationTooltip:AddLine(
			"Kills by Alliance:",
			"ZoFontWinH4", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT
		)
		InformationTooltip:AddLine(
			killsLine,
			"ZoFontWinH4", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT
		)
	end
	
	if control.data.deathsByAlliance then
		local adDeaths = control.data.deathsByAlliance[ALLIANCE_ALDMERI_DOMINION] or 0
		local dcDeaths = control.data.deathsByAlliance[ALLIANCE_DAGGERFALL_COVENANT] or 0
		local epDeaths = control.data.deathsByAlliance[ALLIANCE_EBONHEART_PACT] or 0
		
		local adHex = GetCachedAllianceColor(ALLIANCE_ALDMERI_DOMINION)
		local dcHex = GetCachedAllianceColor(ALLIANCE_DAGGERFALL_COVENANT)
		local epHex = GetCachedAllianceColor(ALLIANCE_EBONHEART_PACT)
		
		local deathsLine = ""
		if control.data.alliance ~= ALLIANCE_ALDMERI_DOMINION then
             deathsLine = deathsLine .. "|c" .. adHex .. "AD|r: " .. adDeaths .. "  |  "
        end
		if control.data.alliance ~= ALLIANCE_DAGGERFALL_COVENANT then
             deathsLine = deathsLine .. "|c" .. dcHex .. "DC|r: " .. dcDeaths .. "  |  "
        end
		if control.data.alliance ~= ALLIANCE_EBONHEART_PACT then
             deathsLine = deathsLine .. "|c" .. epHex .. "EP|r: " .. epDeaths
        end
        if sub(deathsLine, -5) == "  |  " then deathsLine = sub(deathsLine, 1, -6) end
		
		InformationTooltip:AddLine(
			"Deaths by Alliance:",
			"ZoFontWinH4", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT
		)
		InformationTooltip:AddLine(
			deathsLine,
			"ZoFontWinH4", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT
		)
	end
end

function PVP_KillfeedScoreboardRow_OnMouseExit(control)
	if control.listParent then
		control.listParent:Row_OnMouseExit(control)
	end
	ClearTooltip(InformationTooltip)
end

function PVP_KillfeedScoreboardRow_OnMouseUp(control, button, upInside)
	if not upInside or not control.data then return end
	
	if button == MOUSE_BUTTON_INDEX_LEFT then
		local playerName = control.data.name
		if PVP.killfeedScoreboard.disabledPlayers[playerName] then
			PVP.killfeedScoreboard.disabledPlayers[playerName] = nil
		else
			PVP.killfeedScoreboard.disabledPlayers[playerName] = true
		end
		PVP:RefreshKillfeedScoreboards()
		PVP:RefreshPlayerDetailsIfOpen()
	elseif button == MOUSE_BUTTON_INDEX_RIGHT then
		PVP_ShowPlayerDetails(control.data.name)
	end
end

function PVP:AddKillfeedScoreboardKill(sourceCharacterName, sourceAlliance, targetCharacterName, targetAlliance, sourceDisplayName, targetDisplayName)
    local killfeedScoreboard = self.killfeedScoreboard
    if not killfeedScoreboard.playerStats then
        killfeedScoreboard.playerStats = {}
    end
    local playerStats = killfeedScoreboard.playerStats

    local playersDB = self.SV.playersDB
    local sourceClass = 0
    local targetClass = 0
    if playersDB then
        if playersDB[sourceCharacterName] and playersDB[sourceCharacterName].unitClass then
            sourceClass = playersDB[sourceCharacterName].unitClass
        end
        if playersDB[targetCharacterName] and playersDB[targetCharacterName].unitClass then
            targetClass = playersDB[targetCharacterName].unitClass
        end
    end

    if not playerStats[sourceCharacterName] then
        playerStats[sourceCharacterName] = {
            events = {},
            alliance = sourceAlliance,
            name = sourceCharacterName,
            displayName = sourceDisplayName,
            class = sourceClass,
            lastSeen = GetGameTimeMilliseconds(),
        }
    else
        if sourceClass ~= 0 then
            playerStats[sourceCharacterName].class = sourceClass
        end
        if not playerStats[sourceCharacterName].events then
            playerStats[sourceCharacterName].events = {}
        end
    end

    if not playerStats[targetCharacterName] then
        playerStats[targetCharacterName] = {
            events = {},
            alliance = targetAlliance,
            name = targetCharacterName,
            displayName = targetDisplayName,
            class = targetClass,
            lastSeen = GetGameTimeMilliseconds(),
        }
    else
        if targetClass ~= 0 then
            playerStats[targetCharacterName].class = targetClass
        end
        if not playerStats[targetCharacterName].events then
            playerStats[targetCharacterName].events = {}
        end
    end

    local timestamp = GetGameTimeMilliseconds()

    local event = {
        source = sourceCharacterName,
        sourceDisplayName = sourceDisplayName,
        sourceAlliance = sourceAlliance,
        sourceClass = sourceClass,
        target = targetCharacterName,
        targetDisplayName = targetDisplayName,
        targetAlliance = targetAlliance,
        targetClass = targetClass,
        timestamp = timestamp
    }
    
    insert(playerStats[sourceCharacterName].events, event)
    insert(playerStats[targetCharacterName].events, event)

    playerStats[sourceCharacterName].lastSeen = timestamp
    playerStats[targetCharacterName].lastSeen = timestamp
    playerStats[sourceCharacterName].displayName = sourceDisplayName
    playerStats[targetCharacterName].displayName = targetDisplayName
end

function PVP:ClearKillfeedScoreboard()
    local killfeedScoreboard = self.killfeedScoreboard
	local numPlayers = 0
    if killfeedScoreboard.playerStats then
        for _ in pairs(killfeedScoreboard.playerStats) do
			numPlayers = numPlayers + 1
		end
	end
	
    killfeedScoreboard.playerStats = {}
    if killfeedScoreboard.historicalGroupMembers then
        for k in pairs(killfeedScoreboard.historicalGroupMembers) do
            killfeedScoreboard.historicalGroupMembers[k] = nil
    	end
    else
        killfeedScoreboard.historicalGroupMembers = {}
    end
    killfeedScoreboard.disabledPlayers = {}
    self:RefreshKillfeedScoreboards()
	
	if numPlayers > 0 then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Killfeed Scoreboard cleared (" .. numPlayers .. " players removed)")
	end
end

function PVP_KillfeedScoreboard_OnClear()
	PVP:ClearKillfeedScoreboard()
end

function PVP_KillfeedScoreboardStartButton_OnMouseEnter(button)
	InitializeTooltip(InformationTooltip, button, BOTTOM, 0, 0)
	local isLogging = PVP.killfeedScoreboard.isLogging
	local tooltipText = isLogging and "Stop Logging" or "Start Logging"
	InformationTooltip:AddLine(tooltipText, "", 1, 1, 1)
end

function PVP_KillfeedScoreboard_OnToggleLogging()
	PVP.killfeedScoreboard.isLogging = not PVP.killfeedScoreboard.isLogging
	
	if PVP.killfeedScoreboard.isLogging then
		PVP:UpdateHistoricalGroupMembers()
	end
	
	local button = PVP_KillfeedScoreboard:GetNamedChild("StartButton")
	if button then
		if PVP.killfeedScoreboard.isLogging then
			button:SetNormalTexture("EsoUI/Art/Buttons/decline_up.dds")
			button:SetPressedTexture("EsoUI/Art/Buttons/decline_down.dds")
			button:SetMouseOverTexture("EsoUI/Art/Buttons/decline_over.dds")
		else
			button:SetNormalTexture("EsoUI/Art/Buttons/accept_up.dds")
			button:SetPressedTexture("EsoUI/Art/Buttons/accept_down.dds")
			button:SetMouseOverTexture("EsoUI/Art/Buttons/accept_over.dds")
		end
	end
	
	local status = PVP.killfeedScoreboard.isLogging and "Logging Started" or "Logging Stopped"
	ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Killfeed Scoreboard: " .. status)
end

function PVP_KillfeedScoreboard_OnToggleGroupFilter()
	local isActive = PVP:ToggleGroupMemberFilter()
	local button = PVP_KillfeedScoreboard:GetNamedChild("GroupFilterButton")
	
    if button then
        if isActive then
            button:SetAlpha(1.0)
        else
            button:SetAlpha(0.5)
        end
    end
	
	local status = isActive and "Group Filter Enabled" or "Group Filter Disabled"
	ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Killfeed Scoreboard: " .. status)
end

function PVP_KillfeedScoreboard_OnToggleGuildFilter()
	local isActive = PVP:ToggleGuildMemberFilter()
	local button = PVP_KillfeedScoreboard:GetNamedChild("GuildFilterButton")
	
    if button then
        if isActive then
            button:SetAlpha(1.0)
        else
            button:SetAlpha(0.5)
        end
    end
	
	local status = isActive and "Guild Filter Enabled" or "Guild Filter Disabled"
	ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Killfeed Scoreboard: " .. status)
end

function PVP_KillfeedScoreboard_GuildFilterButton_OnMouseUp(button, mouseButton)
	if mouseButton == 2 then
		PVP_KillfeedScoreboard_ShowGuildSelectComboBox(button)
	end
end

function PVP_KillfeedScoreboard_ShowGuildSelectComboBox(anchorButton)
    local guilds = PVP:GetAvailableGuilds()
    if not guilds or #guilds == 0 then
        d("[PvpAlerts] No guilds available")
        return
    end
    ClearMenu()
    for _, guildInfo in ipairs(guilds) do
        local isSelected = PVP:IsGuildSelected(guildInfo.id)
        
        local displayName = isSelected and ("+ " .. guildInfo.name) or ("  " .. guildInfo.name)
        
        AddCustomMenuItem(
            displayName,
            function()
                PVP:ToggleGuildInFilter(guildInfo.id)
                PVP:RefreshKillfeedScoreboards()
            end
        )
    end
    ShowMenu(anchorButton)
end

function PVP_KillfeedScoreboard_OnRefresh()
	PVP.killfeedScoreboard.disabledPlayers = {}
	PVP:RefreshKillfeedScoreboards()
end
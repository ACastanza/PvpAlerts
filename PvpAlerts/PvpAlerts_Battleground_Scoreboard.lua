---@class (partial) PvpAlerts
local PVP = PVP_Alerts_Main_Table


local textColorBright = ZO_ColorDef:New(1, 1, 0, 1)
local PLAYER_HIGHLIGHT_SCOREBOARD_COLOR = ZO_ColorDef:New(0.75, 0.75, 0, 1)
local ScoreboardList = ZO_SortFilterList:Subclass()
local specialsIcon

local PVP_SPECIALS_ICON_DOM = "EsoUI/Art/MapPins/battlegrounds_multiCapturePoint_D_pin_neutral.dds"
local PVP_SPECIALS_ICON_DM = "esoui/art/deathrecap/deathrecap_killingblow_icon.dds"
local PVP_SPECIALS_ICON_CTF = "esoui/art/compass/ava_flagcarrier_neutral.dds"

local BATTLEGROUND_TEAM_TO_BG_TEXTURE = {
	[BATTLEGROUND_TEAM_FIRE_DRAKES] = "EsoUI/Art/Battlegrounds/battlegrounds_scoreboardBG_orange.dds",
	[BATTLEGROUND_TEAM_PIT_DAEMONS] = "EsoUI/Art/Battlegrounds/battlegrounds_scoreboardBG_green.dds",
	[BATTLEGROUND_TEAM_STORM_LORDS] = "EsoUI/Art/Battlegrounds/battlegrounds_scoreboardBG_purple.dds",
}

local PVP_GOLD_COLOR = ZO_ColorDef:New("CCCC00")
local PVP_SILVER_COLOR = ZO_ColorDef:New("C0C0C0")
local PVP_BRONZE_COLOR = ZO_ColorDef:New("d7995b")

local PVP_PLAYER_COLOR_GREEEN = ZO_ColorDef:New(0, 1, 0, 1)
local PVP_PLAYER_COLOR_YELLOW = ZO_ColorDef:New(1, 1, 0, 1)
local PVP_PLAYER_COLOR_RED = ZO_ColorDef:New(1, 0, 0, 1)

local PVP_MEDAL_TOOLTIP_NAME_COLOR = ZO_ColorDef:New('AAAA00')
local PVP_MEDAL_TOOLTIP_POINTS_COLOR = ZO_ColorDef:New('A0A0A0')

PVP.bgScoreboard = {}

function PVP_InitScoreboard()
	PVP.bgScoreboard.list = ScoreboardList:New(PVP_ScoreboardList1)
end

function PVP:ScoreboardToggle(isKeyDown)
	if not IsActiveWorldBattleground() then
		ClearTooltip(PVPScoreboardTooltip)
		PVPScoreboardTooltip:SetHidden(true)
		SCENE_MANAGER:Hide("PVPScoreboardScene")
		return
	end

	if not PVP.bgScoreboard.list then
		PVP.bgScoreboard.list = ScoreboardList:New(PVP_ScoreboardList1)
	end

	if PVP.SV.bgToggle then
		if isKeyDown then
			if (PVP_Scoreboard:IsControlHidden()) then
				SCENE_MANAGER:Show("PVPScoreboardScene")
				PVP.bgScoreboard.list:RefreshData()
			else
				PVP.bgScoreboard.list.medalsPool:ReleaseAllObjects()
				ClearTooltip(PVPScoreboardTooltip)
				PVPScoreboardTooltip:SetHidden(true)
				SCENE_MANAGER:Hide("PVPScoreboardScene")
			end
		end
	else
		if isKeyDown then
			SCENE_MANAGER:Show("PVPScoreboardScene")
			PVP.bgScoreboard.list:RefreshData()
		else
			PVP.bgScoreboard.list.medalsPool:ReleaseAllObjects()
			ClearTooltip(PVPScoreboardTooltip)
			PVPScoreboardTooltip:SetHidden(true)
			SCENE_MANAGER:Hide("PVPScoreboardScene")
		end
	end
end

local function MedalsPoolCustomFactory(control)
	control:SetHidden(false)
end

local function PlayerMedalsPoolCustomFactory(control)
	local score = control:GetNamedChild('Score')
	local icon = control:GetNamedChild('Icon')
	icon:SetDimensions(75, 75)
	control:SetHidden(false)
end

local function MedalsPoolCustomReset(control)
	control:SetHidden(true)
end

function ScoreboardList:New(control)
	local list = ZO_SortFilterList.New(self, control)
	list.frame = control:GetParent()

	list.medalsPool = ZO_ControlPool:New("PVP_Scoreboard_Tooltip_Medal_Template")
	list.playerMedalsPool = ZO_ControlPool:New("PVP_Medals_OnScreen_Template")

	list.medalsPool:SetCustomFactoryBehavior(MedalsPoolCustomFactory)
	list.medalsPool:SetCustomResetBehavior(MedalsPoolCustomReset)
	list.playerMedalsPool:SetCustomFactoryBehavior(PlayerMedalsPoolCustomFactory)
	list.playerMedalsPool:SetCustomResetBehavior(MedalsPoolCustomReset)
	list:Setup()
	return list
end

function ScoreboardList:Setup()
	ZO_ScrollList_AddDataType(self.list, 69, "PVP_ScoreboardRow", 28,
		function(control, data) self:SetupPlayerRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(false)

	self.masterList = {}

	local sortKeys = {
		["name"] = { caseInsensitive = true },
		["points"] = { caseInsensitive = true, tiebreaker = "name" },
		["rank"] = { caseInsensitive = true, tiebreaker = "points" },
		["kills"] = { caseInsensitive = true, tiebreaker = "points" },
		["deaths"] = { caseInsensitive = true, tiebreaker = "points" },
		["assists"] = { caseInsensitive = true, tiebreaker = "points" },
		["damage"] = { caseInsensitive = true, tiebreaker = "points" },
		["healing"] = { caseInsensitive = true, tiebreaker = "points" },
		-- ["medals"] = { caseInsensitive = true, tiebreaker = "points" },
		["specials"] = { caseInsensitive = true, tiebreaker = "points" },
	}

	-- self.currentSortKey = "name"
	self.currentSortKey = "points"
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey)
	self.sortFunction = function(listEntry1, listEntry2)
		if self.currentSortKey == "name" then
			if listEntry1.data.alliance == listEntry2.data.alliance then
				if self.currentSortOrder == ZO_SORT_ORDER_UP then
					return listEntry1.data.name < listEntry2.data.name
				else
					return listEntry1.data.name > listEntry2.data.name
				end
			else
				if self.currentSortOrder == ZO_SORT_ORDER_UP then
					return listEntry1.data.alliance < listEntry2.data.alliance
				else
					return listEntry1.data.alliance > listEntry2.data.alliance
				end
			end
		else
			return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys,
				self.currentSortOrder)
		end
	end

	PVP.bgScoreboard.scene = ZO_Scene:New("PVPScoreboardScene", SCENE_MANAGER);
	PVP_SCOREBOARD_FRAGMENT = ZO_FadeSceneFragment:New(PVP_Scoreboard, nil, 0)
	PVP.bgScoreboard.scene:AddFragment(PVP_SCOREBOARD_FRAGMENT)

	PVP.bgScoreboard.scene:AddFragment(UNIT_FRAMES_FRAGMENT)
	PVP.bgScoreboard.scene:AddFragment(UI_COMBAT_OVERLAY_FRAGMENT)
	PVP.bgScoreboard.scene:AddFragment(MOUSE_UI_MODE_FRAGMENT)
	PVP.bgScoreboard.scene:AddFragment(BATTLEGROUND_SCOREBOARD_ACTION_LAYER_FRAGMENT)
	self:RefreshData()
end

PVP.sampleSBdata = {
	{
		class = 1,
		name = "Miat Did Nothing Wrong^Mx",
		kills = 5,
		deaths = 2,
		assists = 3,
		damage = 10000,
		healing = 2000,
		points = 350,
		alliance = 1,
		rank = 20,
		specials = 3,
		medals = {
			{ medalId = 1,  medalCount = 2 },
			{ medalId = 2,  medalCount = 5 },
			{ medalId = 3,  medalCount = 2 },
			{ medalId = 4,  medalCount = 1 },
			{ medalId = 5,  medalCount = 3 },
			{ medalId = 6,  medalCount = 1 },
			{ medalId = 7,  medalCount = 4 },
			{ medalId = 8,  medalCount = 1 },
			{ medalId = 9,  medalCount = 1 },
			{ medalId = 10, medalCount = 1 },
		}
	},
	{
		class = 2,
		name = "Miat Did Something Wrong^Fx",
		kills = 3,
		deaths = 2,
		assists = 10,
		damage = 3200,
		healing = 1000,
		points = 900,
		alliance = 1,
		rank = 238,
		specials = 0,
		medals = {
			{ medalId = 10, medalCount = 2 },
			{ medalId = 12, medalCount = 5 },
			{ medalId = 13, medalCount = 2 },
			{ medalId = 14, medalCount = 1 },
			{ medalId = 15, medalCount = 3 },
			{ medalId = 16, medalCount = 1 },
			{ medalId = 7,  medalCount = 4 },
			{ medalId = 8,  medalCount = 1 },
		}
	},
	{
		class = 3,
		name = "Miat Did Nothing^Fx",
		kills = 18,
		deaths = 20,
		assists = 100,
		damage = 10000000,
		healing = 2000000,
		points = 800,
		alliance = 1,
		rank = 9999,
		specials = 0,
		medals = {
			{ medalId = 10, medalCount = 2 },
			{ medalId = 12, medalCount = 5 },
			{ medalId = 13, medalCount = 2 },
			{ medalId = 7,  medalCount = 1 },
			{ medalId = 18, medalCount = 1 },
		}
	},
	{
		class = 2,
		name = "Miat-For-Cookies^Fx",
		kills = 30,
		deaths = 20,
		assists = 100,
		damage = 10000000,
		healing = 3000000,
		points = 700,
		alliance = 1,
		rank = 9999,
		specials = 1,
		medals = {
			{ medalId = 10, medalCount = 2 },
			{ medalId = 7,  medalCount = 1 },
			{ medalId = 18, medalCount = 1 },
		}
	},
	{
		class = 3,
		name = "Cookies Rebellion^Fx",
		kills = 30,
		deaths = 20,
		assists = 100,
		damage = 10000000,
		healing = 3000000,
		points = 600,
		alliance = 2,
		rank = 9999,
		specials = 0,
		medals = {
			{ medalId = 12, medalCount = 2 },
			{ medalId = 13, medalCount = 1 },
			{ medalId = 14, medalCount = 3 },
			{ medalId = 15, medalCount = 5 },
			{ medalId = 16, medalCount = 1 },
		}
	},
	{
		class = 2,
		name = "Testing Cookies^Fx",
		kills = 80,
		deaths = 200,
		assists = 100,
		damage = 10000000,
		healing = 300000,
		points = 310,
		alliance = 2,
		rank = 1,
		specials = 0,
		medals = {
			{ medalId = 9,  medalCount = 8 },
			{ medalId = 10, medalCount = 1 },
			{ medalId = 11, medalCount = 3 },
			{ medalId = 12, medalCount = 2 },
			{ medalId = 13, medalCount = 1 },

		}
	},
	{
		class = 1,
		name = "Khajiits Against Humanity^Fx",
		kills = 30,
		deaths = 20,
		assists = 100,
		damage = 10000000,
		healing = 3000000,
		points = 500,
		alliance = 2,
		rank = 4,
		specials = 0,
		medals = {
			{ medalId = 2, medalCount = 5 },
			{ medalId = 3, medalCount = 2 },
			{ medalId = 4, medalCount = 1 },
			{ medalId = 5, medalCount = 3 },
			{ medalId = 6, medalCount = 1 },
			{ medalId = 7, medalCount = 4 },
		}
	},
	{
		class = 1,
		name = "Bob^Mx",
		kills = 30,
		deaths = 20,
		assists = 100,
		damage = 10000000,
		healing = 3000000,
		points = 400,
		alliance = 2,
		rank = 7,
		specials = 0,
		medals = {
			{ medalId = 4, medalCount = 1 },
		}
	},
	{
		class = 2,
		name = "Not-Bob^Fx",
		kills = 30,
		deaths = 20,
		assists = 100,
		damage = 10000000,
		healing = 3000000,
		points = 300,
		alliance = 3,
		rank = 55,
		specials = 0,
		medals = {
			{ medalId = 4, medalCount = 10 },
			{ medalId = 5, medalCount = 3 },
		}
	},
	{
		class = 1,
		name = "Definitely-Not-Bob^Fx",
		kills = 30,
		deaths = 20,
		assists = 100,
		damage = 10000000,
		healing = 3000000,
		points = 200,
		alliance = 3,
		rank = 9999,
		specials = 0,
		medals = {
			{ medalId = 18, medalCount = 3 },
			{ medalId = 19, medalCount = 1 },
		}
	},
	{
		class = 3,
		name = "Cookies For Bob^Fx",
		kills = 30,
		deaths = 20,
		assists = 100,
		damage = 10000000,
		healing = 3000000,
		points = 1100,
		alliance = 3,
		rank = 9999,
		specials = 0,
		medals = {
			{ medalId = 1,  medalCount = 2 },
			{ medalId = 2,  medalCount = 5 },
			{ medalId = 3,  medalCount = 2 },
			{ medalId = 4,  medalCount = 1 },
			{ medalId = 5,  medalCount = 3 },
			{ medalId = 6,  medalCount = 1 },
			{ medalId = 7,  medalCount = 4 },
			{ medalId = 8,  medalCount = 1 },
			{ medalId = 9,  medalCount = 1 },
			{ medalId = 10, medalCount = 1 },
			{ medalId = 11, medalCount = 1 },
			{ medalId = 12, medalCount = 1 },
			{ medalId = 13, medalCount = 1 },
			{ medalId = 14, medalCount = 1 },
			{ medalId = 15, medalCount = 1 },
			{ medalId = 16, medalCount = 1 },
			{ medalId = 17, medalCount = 1 },
			{ medalId = 18, medalCount = 1 },
			{ medalId = 19, medalCount = 1 },
			{ medalId = 20, medalCount = 1 },
		}
	},
	{
		class = 3,
		name = "Bobception^Fx",
		kills = 30,
		deaths = 20,
		assists = 100,
		damage = 10000000,
		healing = 3000000,
		points = 1200,
		alliance = 3,
		rank = 9999,
		specials = 0,
		medals = {
			{ medalId = 4,  medalCount = 1 },
			{ medalId = 5,  medalCount = 3 },
			{ medalId = 6,  medalCount = 1 },
			{ medalId = 7,  medalCount = 4 },
			{ medalId = 8,  medalCount = 1 },
			{ medalId = 9,  medalCount = 1 },
			{ medalId = 10, medalCount = 1 },
			{ medalId = 11, medalCount = 1 },
			{ medalId = 12, medalCount = 1 },
			{ medalId = 13, medalCount = 1 },
			{ medalId = 14, medalCount = 1 },
			{ medalId = 15, medalCount = 1 },
			{ medalId = 16, medalCount = 1 },
			{ medalId = 17, medalCount = 1 },
			{ medalId = 18, medalCount = 1 },
		}
	},
}



function ScoreboardList:BuildMasterList()
	self.masterList = {}
	local function sortDamageFn(entry1, entry2)
		return entry1.damage > entry2.damage
	end

	local function sortHealingFn(entry1, entry2)
		return entry1.healing > entry2.healing
	end

	local function sortAssistFn(entry1, entry2)
		return entry1.assists > entry2.assists
	end

	local function sortKillsFn(entry1, entry2)
		return entry1.kills > entry2.kills
	end

	local function sortDeathsFn(entry1, entry2)
		return entry1.deaths < entry2.deaths
	end

	local function sortPointsFn(entry1, entry2)
		return entry1.points > entry2.points
	end

	local function FindPlayerRank(scoreboardTable, sortingFunction, sortingType, onlyTopThree)
		local rank
		local uniqueTable = {}
		local uniqueCount = 0

		table.sort(scoreboardTable, sortingFunction)

		for i = 1, #scoreboardTable do
			local currentSortingParameter = scoreboardTable[i][sortingType]
			if not uniqueTable[currentSortingParameter] then
				uniqueTable[currentSortingParameter] = true
				uniqueCount = uniqueCount + 1
			end

			if scoreboardTable[i].name == (PVP.playerName or GetRawUnitName('player')) then
				if currentSortingParameter ~= 0 then
					rank = uniqueCount
				end
				break
			end
		end

		if onlyTopThree then
			if rank and rank <= 3 then
				return rank
			else
				return nil
			end
		else
			return rank
		end
	end

	local function FindPlayerTopRanks(scoreboardTable, onlyTopThree)
		local damageRank, healingRank, assistsRank, killsRank, deathsRank, pointsRank

		damageRank = FindPlayerRank(scoreboardTable, sortDamageFn, "damage", onlyTopThree)
		healingRank = FindPlayerRank(scoreboardTable, sortHealingFn, "healing", onlyTopThree)
		assistsRank = FindPlayerRank(scoreboardTable, sortAssistFn, "assists", onlyTopThree)
		killsRank = FindPlayerRank(scoreboardTable, sortKillsFn, "kills", onlyTopThree)
		deathsRank = FindPlayerRank(scoreboardTable, sortDeathsFn, "deaths", onlyTopThree)
		pointsRank = FindPlayerRank(scoreboardTable, sortPointsFn, "points", onlyTopThree)

		return damageRank, healingRank, assistsRank, killsRank, deathsRank, pointsRank
	end

	local function ProcessScoreboard(scoreboardTable)
		local allianceCount1, allianceCount2, allianceCount3 = 0, 0, 0

		for i = 1, #scoreboardTable do
			local entry = scoreboardTable[i]
			table.insert(self.masterList, PVP:CreateEntryFromRaw(entry))
			if entry.alliance == 1 then
				allianceCount1 = allianceCount1 + 1
			elseif entry.alliance == 2 then
				allianceCount2 = allianceCount2 + 1
			elseif entry.alliance == 3 then
				allianceCount3 = allianceCount3 + 1
			end
		end

		PVP.bgScoreboard.allianceCounts = { allianceCount1, allianceCount2, allianceCount3 }

		local damageRank, healingRank, assistsRank, killsRank, deathsRank, pointsRank = FindPlayerTopRanks(
			scoreboardTable, true)
		PVP.bgScoreboard.playerCurrentRank = {
			damage = damageRank,
			healing = healingRank,
			assists = assistsRank,
			kills = killsRank,
			deaths = deathsRank,
			points = pointsRank
		}
	end


	if PVP.scoreboardListData then
		ProcessScoreboard(PVP.scoreboardListData)
	else
		ProcessScoreboard(PVP.sampleSBdata)
	end
end

function ScoreboardList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	local bgState = GetCurrentBattlegroundState()
	local isPregame = bgState == BATTLEGROUND_STATE_PREROUND
	local isPostGame = bgState == BATTLEGROUND_STATE_POSTROUND
	local postGameMVP

	local function GetTeamScoreInfo(alliance, score, position, isPlayer)

		local control = PVP_ScoreboardScore:GetNamedChild('Team' .. tostring(position))
		local formattedScore, formattedName

		if isPlayer then
			formattedScore = PVP:ColorizeToBgTeamColor(alliance, score)
		else
			formattedScore = ZO_NORMAL_TEXT:Colorize(score)
		end


		formattedName = GetColoredBattlegroundTeamName(alliance)

		control:GetNamedChild("Score"):SetText(formattedScore)
		control:GetNamedChild("Name"):SetText(formattedName:upper())

		control:GetNamedChild("BG"):SetTexture(BATTLEGROUND_TEAM_TO_BG_TEXTURE[alliance])
	end

	local function GenerateMVPText(postGameMVP, specialsIcon)
		local formattedIcon = zo_iconFormatInheritColor('esoui/art/tutorial/ava_rankicon64_grandoverlord.dds', 40, 40)
		formattedIcon = PLAYER_HIGHLIGHT_SCOREBOARD_COLOR:Colorize(formattedIcon)

		local classID = postGameMVP.class

		local formattedName = zo_iconFormatInheritColor(PVP.classIcons[classID], 28, 28) ..
			zo_strformat(SI_UNIT_NAME, postGameMVP.name)
		formattedName = PVP:ColorizeToBgTeamColor(postGameMVP.alliance, formattedName)


		local formattedKills
		if postGameMVP.kills > 0 then
			formattedKills = PLAYER_HIGHLIGHT_SCOREBOARD_COLOR:Colorize(postGameMVP.kills) .. " kills"
		else
			formattedKills = ""
		end

		local formattedAssists
		if postGameMVP.assists > 0 then
			formattedAssists = PLAYER_HIGHLIGHT_SCOREBOARD_COLOR:Colorize(postGameMVP.assists) .. " assists"
		else
			formattedAssists = ""
		end

		local formattedSpecials
		if postGameMVP.specials > 0 then
			local specialsName = ""
			if specialsIcon == PVP_SPECIALS_ICON_CTF then
				specialsName = " flag captures"
				postGameMVP.specials = postGameMVP.specials / 100
			elseif specialsIcon == PVP_SPECIALS_ICON_DM then
				specialsName = " kill streak"
			elseif specialsIcon == PVP_SPECIALS_ICON_DOM then
				specialsName = " nodes captures"
			end

			formattedSpecials = PLAYER_HIGHLIGHT_SCOREBOARD_COLOR:Colorize(postGameMVP.specials)

			formattedSpecials = formattedSpecials .. specialsName .. "!"
		else
			formattedSpecials = ""
		end

		local withSeparator
		if postGameMVP.kills == 0 and postGameMVP.assists == 0 and postGameMVP.specials == 0 then
			withSeparator = "!"
		else
			withSeparator = " with "
		end

		if postGameMVP.kills ~= 0 then
			if postGameMVP.assists ~= 0 then
				if postGameMVP.specials ~= 0 then
					formattedKills = formattedKills .. ", "
					formattedAssists = formattedAssists .. " and "
				else
					formattedKills = formattedKills .. " and "
					formattedAssists = formattedAssists .. "!"
				end
			else
				if postGameMVP.specials ~= 0 then
					formattedKills = formattedKills .. " and "
				else
					formattedKills = formattedKills .. "!"
				end
			end
		else
			if postGameMVP.assists ~= 0 then
				if postGameMVP.specials ~= 0 then
					formattedAssists = formattedAssists .. " and "
				else
					formattedAssists = formattedAssists .. "!"
				end
			end
		end

		return formattedIcon ..
			" MATCH MVP: " ..
			formattedName ..
			withSeparator .. formattedKills .. formattedAssists .. formattedSpecials .. ' ' .. formattedIcon
	end

	for i = 1, #self.masterList do
		local data = self.masterList[i]

		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(69, data))

		if isPostGame or not IsActiveWorldBattleground() then
			if not postGameMVP then
				postGameMVP = data
			elseif postGameMVP.points < data.points then
				postGameMVP = data
			elseif postGameMVP.points == data.points then
				if postGameMVP.kills + postGameMVP.assists < data.kills + data.assists then
					postGameMVP = data
				end
			end
		end
	end

	if PVP.bgScoreboard.allianceCounts then
		local totalPlayers = PVP.bgScoreboard.allianceCounts[1] + PVP.bgScoreboard.allianceCounts[2] +
			PVP.bgScoreboard.allianceCounts[3]
		local totalPlayersText = "Players - " .. tostring(totalPlayers)
		local alliance1Text = PVP:ColorizeToBgTeamColor(1,
			PVP:GetBattlegroundTeamBadgeTextFormattedIcon(1) .. "" .. tostring(PVP.bgScoreboard.allianceCounts[1]))
		local alliance2Text = PVP:ColorizeToBgTeamColor(2,
			PVP:GetBattlegroundTeamBadgeTextFormattedIcon(2) .. "" .. tostring(PVP.bgScoreboard.allianceCounts[2]))
		local alliance3Text = PVP:ColorizeToBgTeamColor(3,
			PVP:GetBattlegroundTeamBadgeTextFormattedIcon(3) .. "" .. tostring(PVP.bgScoreboard.allianceCounts[3]))
		PVP_ScoreboardPlayers:SetText(totalPlayersText .. " : " ..
			alliance1Text .. "	 " .. alliance2Text .. "  " .. alliance3Text)
	else
		PVP_ScoreboardPlayers:SetText("TOTAL PLAYERS - 15 : |c794993" ..
			PVP:GetBattlegroundTeamBadgeTextFormattedIcon(3) ..
			" - 4|r  |CC1572D" ..
			PVP:GetBattlegroundTeamBadgeTextFormattedIcon(1) ..
			" - 4|R	|c589726" .. PVP:GetBattlegroundTeamBadgeTextFormattedIcon(2) .. " - 4|r")
	end

	local team1Control = PVP_ScoreboardScoreTeam1
	local team2Control = PVP_ScoreboardScoreTeam2
	local team3Control = PVP_ScoreboardScoreTeam3

	if PVP.scoreboardListData and IsActiveWorldBattleground() then
		local battlegroundId = GetCurrentBattlegroundId()
		local battlegroundGameType = GetBattlegroundGameType(battlegroundId)

		local playerAlliance = GetUnitBattlegroundTeam('player')


		local specialsControl1 = PVP_ScoreboardList1HeadersSpecialsName

		if battlegroundGameType == BATTLEGROUND_GAME_TYPE_CAPTURE_THE_FLAG then
			specialsControl1:SetText("FLAGS")
			-- specialsControl2:SetText("FLAGS")
			specialsIcon = PVP_SPECIALS_ICON_CTF
		elseif battlegroundGameType == BATTLEGROUND_GAME_TYPE_DEATHMATCH then
			specialsControl1:SetText("STREAK")
			-- specialsControl2:SetText("STREAK")
			specialsIcon = PVP_SPECIALS_ICON_DM
		elseif battlegroundGameType == BATTLEGROUND_GAME_TYPE_DOMINATION then
			specialsControl1:SetText("NODES")
			-- specialsControl2:SetText("NODES")
			specialsIcon = PVP_SPECIALS_ICON_DOM
		end

		PVP_ScoreboardInfo:SetText(GetPlayerLocationName() .. " - " .. PVP:GetBattlegroundTypeText(battlegroundGameType))

		local function ReturnBattlegroundScoresInAscendingOrder(battlegroundId)
			local scores = {}
			local nTeams = GetBattlegroundNumTeams(battlegroundId)
			for i = 1, nTeams do
				table.insert(scores, { GetCurrentBattlegroundScore(GetCurrentBattlegroundRoundIndex(), i), i })
			end

			local function sortingFn(score1, score2)
				return score1[1] > score2[1]
			end

			table.sort(scores, sortingFn)

			for i = 1, nTeams do
				local color

				color = ZO_ColorDef:New(GetBattlegroundTeamColor(scores[i][2]))

				scores[i][3] = tostring(scores[i][1])
			end


			return scores, scores[1][2]
		end

		local teamScores, winningTeamAlliance = ReturnBattlegroundScoresInAscendingOrder(battlegroundId)
		-- local timeLeft = tostring(zo_round(GetCurrentBattlegroundStateTimeRemaining()/1000))
		local battlegroundRemainingTime = GetCurrentBattlegroundStateTimeRemaining()
		local timeLeft = tostring(ZO_FormatTimeMilliseconds(battlegroundRemainingTime, TIME_FORMAT_STYLE_COLONS,
			TIME_FORMAT_PRECISION_SECONDS))



		if bgState == BATTLEGROUND_STATE_RUNNING then
			-- self.frame:GetNamedChild("Title"):SetText("MATCH IS RUNNING! TIME LEFT: "..timeLeft)
			self.frame:GetNamedChild("State"):SetText("MATCH IS RUNNING!")
		elseif bgState == BATTLEGROUND_STATE_PREROUND then
			self.frame:GetNamedChild("State"):SetText("WAITING FOR PLAYERS...")
		elseif bgState == BATTLEGROUND_STATE_STARTING then
			self.frame:GetNamedChild("State"):SetText("MATCH IS STARTING!")
		elseif isPostGame then
			local hasRounds = DoesBattlegroundHaveRounds(battlegroundId)
			local winningTeamName

			winningTeamName = GetBattlegroundTeamName(winningTeamAlliance):upper()

			local winnerTitleString

			winnerTitleString = PVP:ColorizeToBgTeamColor(winningTeamAlliance,
					PVP:GetBattlegroundTeamBadgeTextFormattedIcon(winningTeamAlliance, 48, 48)) ..
                    GetColoredBattlegroundTeamName(winningTeamAlliance)

			if hasRounds then
				self.frame:GetNamedChild("Title"):SetText(winnerTitleString .. " have won the round!")
				self.frame:GetNamedChild("State"):SetText("Round Ended!")
			else
				self.frame:GetNamedChild("Title"):SetText(winnerTitleString .. " have won!")
				self.frame:GetNamedChild("State"):SetText("MATCH ENDED!")
			end
			if playerAlliance == winningTeamAlliance then
				self.frame:GetNamedChild("Title"):GetNamedChild("Backdrop1"):SetTexture(
					"EsoUI/Art/Battlegrounds/battlegrounds_scoreboardBG_green.dds")
				self.frame:GetNamedChild("Title"):GetNamedChild("Backdrop2"):SetTexture(
					"EsoUI/Art/Battlegrounds/battlegrounds_scoreboardBG_green.dds")
				self.frame:GetNamedChild("Title"):GetNamedChild("Backdrop1"):SetColor(0, 1, 0)
				self.frame:GetNamedChild("Title"):GetNamedChild("Backdrop2"):SetColor(0, 1, 0)
			else
				self.frame:GetNamedChild("Title"):GetNamedChild("Backdrop1"):SetTexture(
					"EsoUI/Art/Battlegrounds/battlegrounds_scoreboardBG_orange.dds")
				self.frame:GetNamedChild("Title"):GetNamedChild("Backdrop2"):SetTexture(
					"EsoUI/Art/Battlegrounds/battlegrounds_scoreboardBG_orange.dds")
				self.frame:GetNamedChild("Title"):GetNamedChild("Backdrop1"):SetColor(1, 0, 0)
				self.frame:GetNamedChild("Title"):GetNamedChild("Backdrop2"):SetColor(1, 0, 0)
			end

			if postGameMVP and postGameMVP.name then
				local mvpText = GenerateMVPText(postGameMVP, specialsIcon)
				self.frame:GetNamedChild("MVP"):SetText(mvpText)
				if not (postGameMVP.name == (PVP.playerName or GetRawUnitName('player'))) then
					self.frame:GetNamedChild("MVP").nameLink = PVP:GetFormattedCharNameLink(postGameMVP.name)
				end
			end
		end

		self.frame:GetNamedChild("Title"):SetHidden(bgState ~= BATTLEGROUND_STATE_POSTROUND)
		self.frame:GetNamedChild("MVP"):SetHidden(bgState ~= BATTLEGROUND_STATE_POSTROUND)

		self.frame:GetNamedChild("TimerContainer"):GetNamedChild("Label"):SetText(timeLeft)

		local newControl
		local teamControls = { team1Control, team2Control, team3Control }
		for i = 1, GetBattlegroundNumTeams(battlegroundId) do
			GetTeamScoreInfo(teamScores[i][2], teamScores[i][1], 1, playerAlliance == teamScores[1][2])
			if playerAlliance == teamScores[i][2] then
				newControl = teamControls[i]
			end
		end


		PVP_ScoreboardPlayerIcon:ClearAnchors()
		PVP_ScoreboardPlayerIcon:SetAnchor(BOTTOM, newControl, TOP, 0, 7)
	else
		self.frame:GetNamedChild("Title"):SetText(PVP:ColorizeToBgTeamColor(3,
			PVP:GetBattlegroundTeamBadgeTextFormattedIcon(3, 48, 48) .. "STORM LORDS") .. " HAVE WON!")

		GetTeamScoreInfo(3, 500, 1)
		GetTeamScoreInfo(1, 45, 2, true)
		GetTeamScoreInfo(2, 8, 3)

		specialsIcon = PVP_SPECIALS_ICON_CTF
		if postGameMVP and postGameMVP.name then
			local mvpText = GenerateMVPText(postGameMVP, specialsIcon)
			self.frame:GetNamedChild("MVP"):SetText(mvpText)
			if not (postGameMVP.name == (PVP.playerName or GetRawUnitName('player'))) then
				self.frame:GetNamedChild("MVP").nameLink = PVP:GetFormattedCharNameLink(postGameMVP.name)
			end
		end
	end
end

function ScoreboardList:SortScrollList()
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
		local scrollData = ZO_ScrollList_GetDataList(self.list)
		table.sort(scrollData, self.sortFunction)
	end

	self:RefreshVisible()
end

function ScoreboardList:SetupPlayerRow(control, data)
	local _
	local isPlayer = data.name == (PVP.playerName or GetRawUnitName('player'))
	local bg1 = ZO_ColorDef:New(GetBattlegroundTeamColor(1))
	local bg2 = ZO_ColorDef:New(GetBattlegroundTeamColor(2))
	local bg3 = ZO_ColorDef:New(GetBattlegroundTeamColor(3))

	control.data = data

	local function GetPlayerRankIcon(rank, isPoints)
		if not rank or rank == 0 then return "" end


		if rank == 1 then
			-- return PVP:Colorize(zo_iconFormatInheritColor("esoui/art/tutorial/ava_rankicon64_general.dds", 30, 30), "CCCC00")
			return PVP_GOLD_COLOR:Colorize(zo_iconFormatInheritColor("esoui/art/tutorial/ava_rankicon64_general.dds", 30,
				30))
		elseif rank == 2 then
			return PVP_SILVER_COLOR:Colorize(zo_iconFormatInheritColor("esoui/art/tutorial/ava_rankicon64_general.dds",
				30, 30))
		elseif rank == 3 then
			return PVP_BRONZE_COLOR:Colorize(zo_iconFormatInheritColor("esoui/art/tutorial/ava_rankicon64_general.dds",
				30, 30))
		end
	end

	local classID = data.class

	control:GetNamedChild("Name"):SetText(zo_iconFormatInheritColor(PVP.classIcons[classID], 28, 28) ..
		zo_strformat(SI_UNIT_NAME, data.name))


	if data.name and not isPlayer then
		control.nameLink = PVP:GetFormattedCharNameLink(data.name)
	end

	if data.rank ~= 9999 then
		control:GetNamedChild("Rank"):SetText(data.rank)
	else
		control:GetNamedChild("Rank"):SetText("~")
	end


	local kills, deaths, assists, damage, healing, points = "", "", "", "", "", ""

	if isPlayer and PVP.bgScoreboard.playerCurrentRank and (not IsActiveWorldBattleground() or GetCurrentBattlegroundState() == BATTLEGROUND_STATE_POSTROUND) then
		kills = GetPlayerRankIcon(PVP.bgScoreboard.playerCurrentRank.kills)
		-- deaths = GetPlayerRankIcon(PVP.bgScoreboard.playerCurrentRank.deaths)
		assists = GetPlayerRankIcon(PVP.bgScoreboard.playerCurrentRank.assists)
		damage = GetPlayerRankIcon(PVP.bgScoreboard.playerCurrentRank.damage)
		healing = GetPlayerRankIcon(PVP.bgScoreboard.playerCurrentRank.healing)
		points = GetPlayerRankIcon(PVP.bgScoreboard.playerCurrentRank.points, true)
	end

	control:GetNamedChild("Kills"):SetText(kills .. tostring(data.kills))


	control:GetNamedChild("Deaths"):SetText(deaths .. tostring(data.deaths))


	control:GetNamedChild("Assists"):SetText(assists .. tostring(data.assists))


	control:GetNamedChild("Damage"):SetText(damage .. tostring(data.damage))


	control:GetNamedChild("Healing"):SetText(healing .. tostring(data.healing))


	control:GetNamedChild("Points"):SetText(points .. tostring(data.points))

	local numMedals = #data.medals
	local medalsText = ""

	local function sortTotalMedalPointsFn(entry1, entry2)
		if not entry1.medalPoints then
			_, _, _, entry1.medalPoints = GetMedalInfo(entry1.medalId)
		end

		if not entry2.medalPoints then
			_, _, _, entry2.medalPoints = GetMedalInfo(entry2.medalId)
		end

		return (entry1.medalCount * entry1.medalPoints) > (entry2.medalCount * entry2.medalPoints)
	end

	table.sort(data.medals, sortTotalMedalPointsFn)

	-- if isPlayer then PVP.bgScoreboard.list.playerMedalsPool:ReleaseAllObjects() end
	if isPlayer then self.playerMedalsPool:ReleaseAllObjects() end

	if numMedals > 0 then
		for i = 1, numMedals do
			local medalName, medalTexture, medalDescription, medalPoints = GetMedalInfo(data.medals[i].medalId)
			medalsText = medalsText .. zo_iconFormat(medalTexture, 20, 20)
			if isPlayer then
				local numActive = self.playerMedalsPool:GetActiveObjectCount()
				local medalControl = self.playerMedalsPool:AcquireObject()
				medalControl:GetNamedChild('Icon'):SetTexture(medalTexture)
				medalControl:GetNamedChild('Name'):SetText('')

				medalControl:ClearAnchors()

				if numActive == 1 then
					medalControl:SetAnchor(LEFT, PVP_ScoreboardPlayerMedals, LEFT, 0, 0)
					medalControl:SetParent(PVP_ScoreboardPlayerMedals)
				elseif numActive == 11 then
					medalControl:SetAnchor(LEFT, PVP_ScoreboardPlayerMedalsBottom, LEFT, 0, 0)
					medalControl:SetParent(PVP_ScoreboardPlayerMedalsBottom)
				else
					if numActive > 11 then
						medalControl:SetParent(PVP_ScoreboardPlayerMedalsBottom)
					else
						medalControl:SetParent(PVP_ScoreboardPlayerMedals)
					end
					if self.lastActiveMedal and self.lastActiveMedal ~= medalControl then
						medalControl:SetAnchor(LEFT, self.lastActiveMedal, RIGHT, 25, 0)
					else
						medalControl:SetAnchor(LEFT, medalControl:GetParent(), LEFT, (numActive - 1) * 25, 0)
					end
				end
				-- control:GetNamedChild('Icon'):SetDesaturation(1)
				if data.medals[i].medalCount > 1 then
					medalControl:GetNamedChild('Score'):SetText("x" .. data.medals[i].medalCount)
				else
					medalControl:GetNamedChild('Score'):SetText("")
				end

				medalControl.medalId = data.medals[i].medalId
				medalControl.medalCount = data.medals[i].medalCount
				self.lastActiveMedal = medalControl
			end
		end
	end

	if isPlayer then
		PVP_ScoreboardPlayerMedals:ClearAnchors()
		PVP_ScoreboardPlayerMedals:SetAnchor(BOTTOM, PVP_Scoreboard, BOTTOM, 0, 85)
		PVP_ScoreboardPlayerMedalsBottom:ClearAnchors()
		PVP_ScoreboardPlayerMedalsBottom:SetAnchor(TOP, PVP_ScoreboardPlayerMedals, BOTTOM, 0, 20)
	end

	local currentBg

	if data.alliance == 1 then
		control:GetNamedChild("BG"):SetTexture(
			"EsoUI/Art/Battlegrounds/battlegrounds_scoreboard_highlightStrip_orange.dds")
		currentBg = bg1
	elseif data.alliance == 2 then
		control:GetNamedChild("BG"):SetTexture(
			"EsoUI/Art/Battlegrounds/battlegrounds_scoreboard_highlightStrip_green.dds")
		currentBg = bg2
	elseif data.alliance == 3 then
		control:GetNamedChild("BG"):SetTexture(
			"EsoUI/Art/Battlegrounds/battlegrounds_scoreboard_highlightStrip_purple.dds")
		currentBg = bg3
	end

	control:GetNamedChild("Name"):SetColor(PVP:HtmlToColor(currentBg:ToHex(), nil, true))

	if data.specials and data.specials > 0 then
		local output

		if specialsIcon == PVP_SPECIALS_ICON_CTF and data.specials >= 100 then
			output = zo_round(data.specials / 100)
		elseif specialsIcon == PVP_SPECIALS_ICON_DM then
			output = zo_round(data.specials / 2)
		else
			output = data.specials
		end
		local brightColor = ZO_ColorDef:New(PVP:HtmlToColor(currentBg:ToHex(), nil, true))
		control:GetNamedChild("Specials"):SetText(brightColor:Colorize(zo_iconFormatInheritColor(specialsIcon, 34, 34)) ..
			output)
		-- local normalColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
		-- control:GetNamedChild("Specials"):SetText(normalColor:Colorize(zo_iconFormatInheritColor(specialsIcon, 32, 32))..output)
	else
		control:GetNamedChild("Specials"):SetText("")
	end


	if isPlayer then
		control:GetNamedChild("Name"):SetColor(textColorBright:UnpackRGBA())
		control:GetNamedChild("Rank"):SetColor(textColorBright:UnpackRGBA())
		control:GetNamedChild("Kills"):SetColor(textColorBright:UnpackRGBA())
		control:GetNamedChild("Deaths"):SetColor(textColorBright:UnpackRGBA())
		control:GetNamedChild("Assists"):SetColor(textColorBright:UnpackRGBA())
		control:GetNamedChild("Damage"):SetColor(textColorBright:UnpackRGBA())
		control:GetNamedChild("Healing"):SetColor(textColorBright:UnpackRGBA())
		control:GetNamedChild("Specials"):SetColor(textColorBright:UnpackRGBA())
		control:GetNamedChild("Points"):SetColor(textColorBright:UnpackRGBA())
	else
		control:GetNamedChild("Rank"):SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
			INTERFACE_TEXT_COLOR_NORMAL))
		control:GetNamedChild("Kills"):SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
			INTERFACE_TEXT_COLOR_NORMAL))
		control:GetNamedChild("Deaths"):SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
			INTERFACE_TEXT_COLOR_NORMAL))
		control:GetNamedChild("Assists"):SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
			INTERFACE_TEXT_COLOR_NORMAL))
		control:GetNamedChild("Damage"):SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
			INTERFACE_TEXT_COLOR_NORMAL))
		control:GetNamedChild("Healing"):SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
			INTERFACE_TEXT_COLOR_NORMAL))
		control:GetNamedChild("Specials"):SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
			INTERFACE_TEXT_COLOR_NORMAL))
		control:GetNamedChild("Points"):SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
			INTERFACE_TEXT_COLOR_NORMAL))
	end

	ZO_SortFilterList.SetupRow(self, control, data);
end

function PVP_ScoreboardRow_OnMouseEnter(control)
	PVP.bgScoreboard.list:Row_OnMouseEnter(control)
	-- InitializeTooltip(PVPScoreboardTooltip, PVP_Scoreboard, TOPLEFT, -100, -50, TOPRIGHT)
	InitializeTooltip(PVPScoreboardTooltip, PVP_Scoreboard, BOTTOMLEFT, -100, -72, BOTTOMRIGHT)

	local teamColor = ZO_ColorDef:New(PVP:HtmlToColor(
		ZO_ColorDef:New(GetBattlegroundTeamColor(control.data.alliance)):ToHex(), nil, true))

	PVPScoreboardTooltipBG:SetEdgeColor(teamColor:UnpackRGBA())
	PVPScoreboardTooltipIcon:SetTexture(PVP:GetBattlegroundTeamBadgeIcon(control.data.alliance))
	PVPScoreboardTooltipIcon:SetColor(teamColor:UnpackRGBA())
	PVPScoreboardTooltip:AddVerticalPadding(30)

	local classID = control.data.class

	local formattedName = zo_iconFormatInheritColor(PVP.classIcons[classID], 35, 35) ..
		zo_strformat(SI_UNIT_NAME, control.data.name)
	formattedName = teamColor:Colorize(formattedName)
	formattedName = ZO_NORMAL_TEXT:Colorize("Player: ") .. formattedName
	PVPScoreboardTooltip:AddLine(formattedName, "ZoFontWinH2", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT,
		true)

	local formattedClass = GetClassName(0, classID)

	-- formattedClass = ZO_NORMAL_TEXT:Colorize("Class: "..formattedClass)

	local formattedRace
	if PVP.SV.playersDB[control.data.name] then
		formattedRace = GetRaceName(0, PVP.SV.playersDB[control.data.name].unitRace)
		-- formattedRace = ZO_NORMAL_TEXT:Colorize("Race: "..formattedRace)
	end

	local formattedClassRace = formattedClass

	if formattedRace then
		formattedClassRace = formattedRace .. ' ' .. formattedClassRace
	end

	formattedClassRace = ZO_NORMAL_TEXT:Colorize(formattedClassRace)

	-- PVPScoreboardTooltip:AddLine(formattedClass, "ZoFontWinH2", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	PVPScoreboardTooltip:AddLine(formattedClassRace, "ZoFontWinH2", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT,
		true)

	-- if formattedRace then
	-- PVPScoreboardTooltip:AddLine(formattedRace, "ZoFontWinH2", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	-- end
	-- PVPScoreboardTooltip:AddVerticalPadding(10)
	ZO_Tooltip_AddDivider(PVPScoreboardTooltip)
	PVPScoreboardTooltip:AddLine(
		ZO_NORMAL_TEXT:Colorize("Total points: ") .. PVP_MEDAL_TOOLTIP_NAME_COLOR:Colorize(control.data.points),
		"ZoFontWinH2", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	ZO_Tooltip_AddDivider(PVPScoreboardTooltip)
	local numMedalsToDisplay = #control.data.medals < 5 and #control.data.medals or 5
	PVPScoreboardTooltip:AddLine(ZO_NORMAL_TEXT:Colorize("Top Medals: "), "ZoFontWinH2", 1, 1, 1, LEFT,
		MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	PVP.bgScoreboard.list.medalsPool:ReleaseAllObjects()
	for i = 1, numMedalsToDisplay do
		local medalControl = PVP.bgScoreboard.list.medalsPool:AcquireObject()
		local medalId = control.data.medals[i].medalId
		local name, textureName, description, points = GetMedalInfo(medalId)
		local totalPoints = control.data.medals[i].medalCount * points
		medalControl:GetNamedChild('Icon'):SetTexture(textureName)
		medalControl:GetNamedChild('Name'):SetText(name)

		if control.data.medals[i].medalCount > 1 then
			medalControl:GetNamedChild('Score'):SetText("x" .. control.data.medals[i].medalCount)
		else
			medalControl:GetNamedChild('Score'):SetText("")
		end
		medalControl:GetNamedChild('Description'):SetText(tostring(totalPoints) ..
			' points' .. ' (' .. tostring(control.data.medals[i].medalCount) .. 'x' .. tostring(points) .. ')')
		PVPScoreboardTooltip:AddControl(medalControl)
		medalControl:SetAnchor(LEFT)
	end
end

function PVP_ScoreboardRow_OnMouseExit(control)
	PVP.bgScoreboard.list:Row_OnMouseExit(control)
	PVP.bgScoreboard.list.medalsPool:ReleaseAllObjects()
	ClearTooltip(PVPScoreboardTooltip)
	PVPScoreboardTooltip:SetHidden(true)
end

function PVP_ScoreboardName_OnMouseUp(button, control)
	if control.nameLink then
		ZO_LinkHandler_OnLinkMouseUp(control.nameLink, button, control)
	end
end

function PVP_Medal_OnMouseEnter(control)
	if not IsActiveWorldBattleground() then return end
	local name, medalTexture, description, points = GetMedalInfo(control.medalId)


	local totalPoints = control.medalCount * points

	InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
	InformationTooltip:AddLine(name, "ZoFontWinH2", 0.667, 0.667, 0, LEFT, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER)
	ZO_Tooltip_AddDivider(InformationTooltip)
	if description ~= "" then
		InformationTooltip:AddLine(description, "ZoFontWinH4", 0.772, 0.760, 0.619, LEFT, MODIFY_TEXT_TYPE_NONE,
			TEXT_ALIGN_CENTER, true)
		ZO_Tooltip_AddDivider(InformationTooltip)
	end
	InformationTooltip:AddLine(
		tostring(totalPoints) .. ' points' .. ' (' .. tostring(control.medalCount) .. 'x' .. tostring(points) .. ')',
		"ZoFontWinH4", 0.627, 0.627, 0.627, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER)
end

function PVP_Medal_OnMouseExit(control)
	ClearTooltip(InformationTooltip)
end

function PVP_ScoreboardButton_OnClicked(control)
	LeaveBattleground()
end

function PVP_CreateSparkleAnimation(control)
	local sparkle = control:GetNamedChild("Sparkle")
	local sparkleCCW = sparkle:GetNamedChild("CCW")

	local animData =
	{
		sparkle = sparkle,
		sparkleTimeLine = ANIMATION_MANAGER:CreateTimelineFromVirtual("SparkleStarburstAnim", sparkle),
	}

	local ccwAnim = animData.sparkleTimeLine:GetAnimation(2)
	ccwAnim:SetAnimatedControl(sparkleCCW)

	animData.sparkleTimeLine:SetHandler("OnStop", function() animData.sparkle:SetHidden(true) end)

	sparkle.animData = animData
end

function PVP_PlaySparkleAnimation(control)
	local animData = control:GetNamedChild("Sparkle").animData

	animData.sparkleTimeLine:PlayFromStart()
	animData.sparkle:SetHidden(false)
end

function PVP:CreateEntryFromRaw(rawEntry)
	return ({
		type = 1,
		class = rawEntry.class,
		rank = rawEntry.rank,
		name = rawEntry.name,
		kills = rawEntry.kills,
		deaths = rawEntry.deaths,
		assists = rawEntry.assists,
		damage = rawEntry.damage,
		healing = rawEntry.healing,
		medals = rawEntry.medals,
		points = rawEntry.points,
		alliance = rawEntry.alliance,
		specials = rawEntry.specials,
	});
end

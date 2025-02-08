---@class (partial) PvpAlerts
PVP_Alerts_Main_Table = {}
---@class (partial) PvpAlerts
local PVP = PVP_Alerts_Main_Table

---@enum (value) PvpAlerts_globalConstants
local Constants = {
	-- ['PVP_BRIGHT_AD_COLOR']="EFD13C",
	['PVP_BRIGHT_AD_COLOR'] = "C2AA49",
	-- ['PVP_BRIGHT_EP_COLOR']="FF7161",
	['PVP_BRIGHT_EP_COLOR'] = "DE5B4E",
	-- ['PVP_BRIGHT_DC_COLOR']="80AFFF",
	['PVP_BRIGHT_DC_COLOR'] = "4F81BD",

	['PVP_DIMMED_AD_COLOR'] = "7B714A",
	['PVP_DIMMED_EP_COLOR'] = "85514D",
	['PVP_DIMMED_DC_COLOR'] = "566674",

	['PVP_STAMINA_COLOR'] = "00CC00",
	['PVP_MAGICKA_COLOR'] = "AAAAFF",
	['PVP_HYBRID_COLOR'] = "FF4444",
	['PVP_SPACER_ICON'] = "esoui/art/mappins/ui-worldmapplayercamerapip.dds",

	['PVP_GROUP_ICON'] = "esoui/art/icons/mapkey/mapkey_groupmember.dds",
	['PVP_GROUPLEADER_ICON'] = "esoui/art/icons/mapkey/mapkey_groupleader.dds",
	['PVP_IMPORTANT_ICON'] = "esoui/art/tutorial/ava_rankicon_general.dds",
	['PVP_FRIEND_ICON'] = "esoui/art/tutorial/gamepad/gp_overview_friends.dds",
	['PVP_GUILD_ICON'] = "esoui/art/tutorial/gamepad/gp_overview_guild.dds",
	['PVP_DEATH_ICON'] = "esoui/art/treeicons/tutorial_idexicon_death_up.dds",
	['PVP_KILLING_BLOW'] = "esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds",
	['PVP_STEALTH_ICON'] = "esoui/art/tutorial/stealth-seen.dds",
	['PVP_EYE_ICON'] = "esoui/art/tutorial/poi_areaofinterest_complete.dds",
	['PVP_COOL_ICON'] = "esoui/art/cadwell/check.dds",

	['PVP_ICON_MISSING'] = "icon_missing",

	['PVP_FIGHT'] = "esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_swords.dds",

	['PVP_FIGHT_ADEP'] = "/esoui/art/mappins/ava_aldmerivebonheart.dds",
	['PVP_FIGHT_ADDC'] = "/esoui/art/mappins/ava_aldmerivdaggerfall.dds",

	['PVP_FIGHT_DCAD'] = "/esoui/art/mappins/ava_daggerfallvaldmeri.dds",
	['PVP_FIGHT_DCEP'] = "/esoui/art/mappins/ava_daggerfallvebonheart.dds",

	['PVP_FIGHT_EPAD'] = "/esoui/art/mappins/ava_ebonheartvaldmeri.dds",
	['PVP_FIGHT_EPDC'] = "/esoui/art/mappins/ava_ebonheartvdaggerfall.dds",

	['PVP_ATTACKER'] = "/esoui/art/compass/ava_returnpoint_ebonheart.dds",

	['PVP_RESURRECT'] = "/esoui/art/compass/ava_flagcarrier_neutral.dds",

	['PVP_6STAR'] = "PvpAlerts/textures/6star1.dds",
	['PVP_EMPEROR'] = "/esoui/art/campaign/overview_indexicon_emperor_up.dds",

	['PVP_AP'] = "esoui/art/currency/alliancepoints_32.dds",

	['PVP_NAME_FONT'] = "$(BOLD_FONT)|29|thick-outline",
	['PVP_NAME_STEALTH_FONT'] = "$(BOLD_FONT)|27|thick-outline",
	['PVP_COUNTER_FONT'] = "$(BOLD_FONT)|20|thick-outline",
	['PVP_NUMBER_FONT'] = "$(BOLD_FONT)|34|thick-outline",
	['PVP_LARGE_NUMBER_FONT'] = "$(BOLD_FONT)|38|thick-outline",

	['PVP_DEFAULT_ICON'] = "esoui/art/icons/ability_nightblade_008.dds",
	['PVP_DEFAULT_HEAVY_ATTACK_ICON'] = "PvpAlerts/textures/staff_3.dds",

	['PVP_CONTINUOUS_ATTACK_ID_1'] = 39249,
	['PVP_CONTINUOUS_ATTACK_ID_2'] = 45617,
	-- ['PVP_AYLEID_WELL_ID'] = 21263,
	['PVP_AYLEID_WELL_ID'] = 100862,
	['PVP_BLESSING_OF_WAR_ID'] = 66282,
	['PVP_KEEPTYPE_ARTIFACT_KEEP'] = 10,
	['PVP_KEEPTYPE_BORDER_KEEP'] = 11,

	['PVP_ALLIANCE_BASE_IC'] = 66,

	['PVP_PINTYPE_AYLEIDWELL'] = 6661,
	['PVP_PINTYPE_DELVE'] = 6662,
	['PVP_PINTYPE_GROUP'] = 6663,
	['PVP_PINTYPE_IC_ALLIANCE_BASE'] = 6664,
	['PVP_PINTYPE_IC_DOOR'] = 6665,
	['PVP_PINTYPE_IC_VAULT'] = 6666,
	['PVP_PINTYPE_IC_GRATE'] = 6667,
	['PVP_PINTYPE_MILEGATE'] = 6668,
	['PVP_PINTYPE_POWERUP'] = 6669,
	['PVP_PINTYPE_COMPASS'] = 6670,
	['PVP_PINTYPE_TOWNFLAG'] = 6671,
	['PVP_PINTYPE_SEWERS_SIGN'] = 6672,
	['PVP_PINTYPE_SHADOWIMAGE'] = 6673,
	['PVP_PINTYPE_BRIDGE'] = 6674,

	['PVP_TEXTURES_PATH'] = "PvpAlerts/textures/",

	['FLAGTYPE_OTHER'] = 1001,
	['FLAGTYPE_NAVE'] = 1002,
	['FLAGTYPE_APSE'] = 1003,

	['PVP_ID_RETAIN_TIME'] = 20000,
	-- ['PVP_ID_RETAIN_TIME'] = 20000,
	['PVP_ID_RETAIN_TIME_EFFECT'] = 100000,
}

PVP.globalConstants = Constants

--- Retrieves a constant from the global constants table.
--- Utilizing generics to capture the type so that callers can receive their expected type.
--- @generic T : PvpAlerts_globalConstants
--- @param globalName T The key whose value is being retrieved.
--- @return T
function PVP:GetGlobal(globalName)
	return self.globalConstants[globalName]
end

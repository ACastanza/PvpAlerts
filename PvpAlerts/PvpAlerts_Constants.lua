---@class (partial) PvpAlerts
local PVP = PVP_Alerts_Main_Table

local texturePath = PVP:GetGlobal('PVP_TEXTURES_PATH')
local PVP_NIGHTBLADE_ICON = "esoui/art/icons/class/class_nightblade.dds"
local PVP_TEMPLAR_ICON = "esoui/art/icons/class/class_templar.dds"
local PVP_SORCERER_ICON = "esoui/art/icons/class/class_sorcerer.dds"
local PVP_DRAGONKNIGHT_ICON = "esoui/art/icons/class/class_dragonknight.dds"
local PVP_WARDEN_ICON = "esoui/art/icons/class/class_warden.dds"
local PVP_NECRO_ICON = "esoui/art/icons/class/class_necromancer.dds"
local PVP_ARCANIST_ICON = "esoui/art/icons/class/class_arcanist.dds"

local PVP_NIGHTBLADE_ICON_LARGE = "esoui/art/icons/class/gamepad/gp_class_nightblade.dds"
local PVP_TEMPLAR_ICON_LARGE = "esoui/art/icons/class/gamepad/gp_class_templar.dds"
local PVP_SORCERER_ICON_LARGE = "esoui/art/icons/class/gamepad/gp_class_sorcerer.dds"
local PVP_DRAGONKNIGHT_ICON_LARGE = "esoui/art/icons/class/gamepad/gp_class_dragonknight.dds"
local PVP_WARDEN_ICON_LARGE = "esoui/art/icons/class/gamepad/gp_class_warden.dds"
local PVP_NECRO_ICON_LARGE = "esoui/art/icons/class/gamepad/gp_class_necromancer.dds"
local PVP_ARCANIST_ICON_LARGE = "esoui/art/icons/class/gamepad/gp_class_arcanist.dds"

local PVP_BOW_HA_ICON = texturePath .. "bow_3.dds"
local PVP_DW_HA_ICON = texturePath .. "dw_3.dds"
local PVP_2H_HA_ICON = texturePath .. "2h_3.dds"
local PVP_SB_HA_ICON = texturePath .. "snb_3.dds"
local PVP_FLAME_HA_ICON = texturePath .. "staff_3.dds"
local PVP_FROST_HA_ICON = texturePath .. "staff_3.dds"

local PVP_PINTYPE_MILEGATE = PVP:GetGlobal('PVP_PINTYPE_MILEGATE')
local PVP_PINTYPE_BRIDGE = PVP:GetGlobal('PVP_PINTYPE_BRIDGE')
local FLAGTYPE_OTHER = PVP:GetGlobal('FLAGTYPE_OTHER')
local FLAGTYPE_NAVE = PVP:GetGlobal('FLAGTYPE_NAVE')
local FLAGTYPE_APSE = PVP:GetGlobal('FLAGTYPE_APSE')
local PVP_KEEPTYPE_ARTIFACT_KEEP = PVP:GetGlobal('PVP_KEEPTYPE_ARTIFACT_KEEP')
local PVP_KEEPTYPE_BORDER_KEEP = PVP:GetGlobal('PVP_KEEPTYPE_BORDER_KEEP')
local PVP_ALLIANCE_BASE_IC = PVP:GetGlobal('PVP_ALLIANCE_BASE_IC')

PVP.accountWideDefaults = {
	accountWide = true
}

PVP.defaults = {
	enabled = true,
	unlocked = true,
	controlScale = 1.0,
	counterControlScale = 1.0,
	feedControlScale = 1.0,
	namesControlScale = 1.0,
	KOSControlScale = 1.0,
	campControlScale = 1.0,
	targetNameFrameScale = 1.0,
	feedTextAlign = TEXT_ALIGN_CENTER,
	targetTextAlign = TEXT_ALIGN_CENTER,
	playKOSSound = true,
	playKillingBlowSound = true,
	playNewAttackerSound = true,
	playBattleReportSound = true,
	playCampSound = true,
	playBuffsSound = true,
	-- stealthOnly=false,

	showAttacks = true,
	showImportant = true,
	enableAttackSound = true,
	showHeavyAttacks = true,
	showPiercingMark = false,
	showSnipes = true,
	enableNetworking = true,
	-- showNumberStealthed=true,

	showKOSFrame = true,
	showPlayerNotes = true,
	showFriends = true,
	showGuildMates = true,
	showCounterFrame = true,
	showCampFrame = true,
	showCaptureFrame = true,
	showNeighbourCaptureFrame = true,
	showKillFeedFrame = true,
	showKillFeedChat = true,
	showKillFeedInMainChat = false,
	userDisplayNameType = "character",
	killFeedNameType = "link",
	showOnlyOwnKillingBlows = false,
	showNamesFrame = true,
	showTargetNameFrame = true,
	showNewAttackerFrame = true,
	showMedalsFrame = true,
	show3DIcons = true,
	showTug = false,
	group3d = false,
	groupleader3d = true,
	showOnScreen = true,
	onScreenReplace = true,
	allgroup3d = false,
	onlyGroupLeader3d = false,
	outputNewKos = true,
	groupLeaderIconSize = 9,
	groupIconSize = 10,
	shadowImage3d = true,
	delayedStart = true,
	showTargetIcon = true,
	targetNameFrameAlpha = 0.9,
	newAttackerFrameAlpha = 0.9,
	newAttackerFrameScale = 1,
	targetNameFrameFadeoutTime = 1500,
	newAttackerFrameDelayBeforeFadeout = 1500,
	targetNameFrameDelayBeforeFadeout = 250,
	-- cameraDistance = 10,
	min3DIconsDistance = 0,
	max3DIconsDistance = 0.20,
	maxResource3DIconsDistance = 0.065,
	max3DIconsPOIDistance = 0.075,
	max3DCaptureDistance = 0.075,
	neighboringDistrictsAlpha = 0.5,
	showCompass3d = true,
	compass3dHeight = 225,
	compass3dSize = 100,
	-- compass3dOpacity = 0.5,
	compass3dColor = { 0, 0, 0.5, 0.5 },
	compass3dColorNorth = { 0.5, 0, 0, 0.5 },
	useDepthBufferCompass = true,

	pingWaypoint = true,
	showNewTargetInfo = true,
	showMaxTargetCP = true,
	showJoinedPlayers = true,
	showPerformance = false,

	bgToggle = false,
	show6star = true,
	offsetX = 0,
	offsetY = -100,
	counterOffsetX = 400,
	counterOffsetY = 400,
	tugOffsetX = 0,
	tugOffsetY = 0,
	feedOffsetX = 0,
	feedOffsetY = 550,
	campOffsetX = 350,
	campOffsetY = 350,
	newAttackerOffsetX = 0,
	newAttackerOffsetY = 0,
	targetOffsetX = 0,
	targetOffsetY = 0,
	medalsOffsetX = 0,
	medalsOffsetY = 350,
	captureOffsetX = 200,
	captureOffsetY = 200,
	namesOffsetX = 350,
	namesOffsetY = 350,
	KOSOffsetX = -300,
	KOSOffsetY = -300,
	onScreenOffsetX = 0,
	onScreenOffsetY = -300,
	onScreenScale = 1,
	KOSmode = 4,

	showHybridJustification = false,
	reportSavedInfo = false,

	colors = {
		normal = "EEEE00",
		stealthed = "AB0100",
		piercing = "FFAA00",
	},
	playersDB = {},
	KOSList = {},
}

PVP.accents = {
	["à"] = "a",
	["á"] = "a",
	["â"] = "a",
	["ã"] = "a",
	["ä"] = "a",
	["å"] = "a",
	["ą"] = "a",

	["ß"] = "b",

	["ĥ"] = "h",

	["ç"] = "c",
	["æ"] = "ae",

	["è"] = "e",
	["é"] = "e",
	["ê"] = "e",
	["ë"] = "e",
	["ę"] = "e",

	["ì"] = "i",
	["í"] = "i",
	["î"] = "i",
	["ï"] = "i",
	["ı"] = "i",
	["į"] = "i",

	["ł"] = "l",

	["ñ"] = "n",

	--["ð"] = "d",

	["þ"] = "p",

	["ò"] = "o",
	["ó"] = "o",
	["ô"] = "o",
	["õ"] = "o",
	["ö"] = "o",
	["ō"] = "o",
	["ð"] = "o",
	["ø"] = "o",
	["ǫ"] = "o",

	["ẅ"] = "w",

	["ş"] = "s",
	["š"] = "s",

	["ù"] = "u",
	["ú"] = "u",
	["û"] = "u",
	["ü"] = "u",
	["ų"] = "u",

	["ý"] = "y",
	["ÿ"] = "y",
	["ŷ"] = "y",


	["À"] = "A",
	["Á"] = "A",
	["Â"] = "A",
	["Ã"] = "A",
	["Ä"] = "A",
	["Å"] = "A",
	["Ą"] = "A",

	["ẞ"] = "B",

	["Ĥ"] = "H",

	["Ç"] = "C",
	["Æ"] = "Ae",

	["È"] = "E",
	["É"] = "E",
	["Ê"] = "E",
	["Ë"] = "E",
	["Ę"] = "E",

	["Ì"] = "I",
	["Í"] = "I",
	["Î"] = "I",
	["Ï"] = "I",
	["Į"] = "I",

	["Ł"] = "L",

	["Ñ"] = "N",

	["Ð"] = "D",
	["Š"] = "S",
	["Ş"] = "S",

	["Þ"] = "P",

	["Ò"] = "O",
	["Ó"] = "O",
	["Ô"] = "O",
	["Õ"] = "O",
	["Ö"] = "O",
	["Ø"] = "O",
	["Ǫ"] = "O",

	["Ẅ"] = "W",

	["Ù"] = "U",
	["Ú"] = "U",
	["Û"] = "U",
	["Ü"] = "U",
	["Ų"] = "U",

	["Ý"] = "Y",
	["Ÿ"] = "Y",
	["Ŷ"] = "Y",

}

PVP.classIcons = {
	PVP_DRAGONKNIGHT_ICON,
	PVP_SORCERER_ICON,
	PVP_NIGHTBLADE_ICON,
	PVP_WARDEN_ICON,
	PVP_NECRO_ICON,
	PVP_TEMPLAR_ICON,
	[117] = PVP_ARCANIST_ICON,
}

PVP.classIconsLarge = {
	PVP_DRAGONKNIGHT_ICON_LARGE,
	PVP_SORCERER_ICON_LARGE,
	PVP_NIGHTBLADE_ICON_LARGE,
	PVP_WARDEN_ICON_LARGE,
	PVP_NECRO_ICON_LARGE,
	PVP_TEMPLAR_ICON_LARGE,
	[117] = PVP_ARCANIST_ICON_LARGE,
}

PVP.mundusColors = {
	["Warrior"] = "00FF00",
	["Tower"] = "00FF00",
	["Serpent"] = "00FF00",

	["Atronach"] = "2080FF",
	["Mage"] = "2080FF",
	["Apprentice"] = "2080FF",
	-- ["Apprentice"] = "426CA0",

	["Ritual"] = "FF0000",
	["Lord"] = "FF0000",
	["Lady"] = "FF0000",

	["Lover"] = "FF00FF",
	["Thief"] = "FF00FF",
	["Shadow"] = "FF00FF",

	["Steed"] = "999999",
}

PVP.snipeNames = {
	["Lethal Arrow"] = true,
	["Focused Aim"] = true,
	["Snipe"] = true,
	["Dark Flare"] = true,
	["Solar Flare"] = true,
	["Assassin's Will"] = true,
	["Assassin's Scourge"] = true,
	["Crystal Fragments"] = true,
	["Crystal Blast"] = true,
	["Crystal Shard"] = true,
	["Uppercut"] = true,
	["Wrecking Blow"] = true,
	["Dizzying Swing"] = true,

	["Crushing Swipe"] = true,

	["Fatecarver"] = true,
	["Exhausting Fatecarver"] = true,
	["Pragmatic Fatecarver"] = true,
}

PVP.snipeId = {
	[38685] = 1, --Lethal Arrow Active
	[40893] = 2, --Lethal Arrow Active
	[40895] = 3, --Lethal Arrow Active
	[40897] = 4, --Lethal Arrow Active

	[38687] = 1, --Focused Aim Active
	[40899] = 2, --Focused Aim Active
	[40903] = 3, --Focused Aim Active
	[40907] = 4, --Focused Aim Active


	[28882] = 1, --Snipe Active
	[40890] = 2, --Snipe Active
	[40891] = 3, --Snipe Active
	[40892] = 4, --Snipe Active


	[22110] = 1, --Dark Flare Active
	[24129] = 2, --Dark Flare Active
	[24139] = 3, --Dark Flare Active
	[24147] = 4, --Dark Flare Active


	[22057] = 1, --Solar Flare Active
	[24080] = 2, --Solar Flare Active
	[24101] = 3, --Solar Flare Active
	[24110] = 4, --Solar Flare Active

	[61930] = 1, --Assassin's Will Active
	[62132] = 2, --Assassin's Will Active
	[62135] = 3, --Assassin's Will Active
	[62138] = 4, --Assassin's Will Active

	[61932] = 1, --Assassin's Scourge Active
	[62126] = 2, --Assassin's Scourge Active
	[62128] = 3, --Assassin's Scourge Active
	[62130] = 4, --Assassin's Scourge Active

	[46324] = 1, --Crystal Fragments Active
	[47565] = 2, --Crystal Fragments Active
	[47567] = 3, --Crystal Fragments Active
	[47569] = 4, --Crystal Fragments Active

	[46331] = 1, --Crystal Blast Active
	[47554] = 2, --Crystal Blast Active
	[47557] = 3, --Crystal Blast Active
	[47560] = 4, --Crystal Blast Active

	[43714] = 1, --Crystal Shard Active
	[47548] = 2, --Crystal Shard Active
	[47550] = 3, --Crystal Shard Active
	[47552] = 4, --Crystal Shard Active

	[28279] = 1, --Uppercut Active
	[39962] = 2, --Uppercut Active
	[39965] = 3, --Uppercut Active
	[39968] = 4, --Uppercut Active


	[38807] = 1, --Wrecking Blow Active
	[40000] = 2, --Wrecking Blow Active
	[40004] = 3, --Wrecking Blow Active
	[40008] = 4, --Wrecking Blow Active

	[38814] = 1, --Dizzying Swing Active
	[39976] = 2, --Dizzying Swing Active
	[39980] = 3, --Dizzying Swing Active
	[39984] = 4, --Dizzying Swing Active


	[89128] = 1, --Crushing Swipe
	[89220] = 2, --Crushing Swipe

	[185808] = -1, -- Fatecarver
	[185805] = 1, -- Fatecarver
	[20185805] = 2, -- Fatecarver
	[30185805] = 3, -- Fatecarver
	[40185805] = 4, -- Fatecarver

	[183123] = -1, -- Exhausting Fatecarver
	[183122] = 1, -- Exhausting Fatecarver
	[20183122] = 2, -- Exhausting Fatecarver
	[30183122] = 3, -- Exhausting Fatecarver
	[40183122] = 4, -- Exhausting Fatecarver

	[186370] = -1, -- Pragmatic Fatecarver
	[186366] = 1, -- Pragmatic Fatecarver
	[20186366] = 2, -- Pragmatic Fatecarver
	[30186366] = 3, -- Pragmatic Fatecarver
	[40186366] = 4, -- Pragmatic Fatecarver

}

PVP.ambushId = {
	[25493] = 1, --Lotus Fan Active
	[35874] = 2, --Lotus Fan Active
	[35878] = 3, --Lotus Fan Active
	[35882] = 4, --Lotus Fan Active

	[25484] = 1, --Ambush Active
	[35886] = 2, --Ambush Active
	[35892] = 3, --Ambush Active
	[35898] = 4, --Ambush Active

	[18342] = 1, --Teleport Strike Active
	[35864] = 2, --Teleport Strike Active
	[35868] = 3, --Teleport Strike Active
	[35871] = 4, --Teleport Strike Active
}


PVP.excludedAbilityIds = {
	[46858] = true,
	[36304] = true,
	[43754] = true,
	[20542] = true,
	[38433] = true,
	[46270] = true,
	[22469] = true,
	[64674] = true,
	[5605] = true,
	[5044] = true,
	[8077] = true,
	[5614] = true,
	--NEW NEEDS MORE TESTING
	[46272] = true,
	[31373] = true,
	[64303] = true, --drinking mead
	[55041] = true, --webdrop
	[10298] = true, --boss
	[15954] = true, --boss
	[31367] = true, --daedric synergy
	[68511] = true, --anchor summon
	[31115] = true, --anchor summon
	[26017] = true, --feast slow
	[51941] = true, --cleave stance
	[44635] = true, --daedric souls average
	[53273] = true, --portal spawn
	[4114] = true, --howl
}

PVP.staminaAbilitiesSmall = {
	["Dawnbreaker of Smiting"] = true,
}

PVP.magickaAbilitiesSmall = {
	["Fossilize"] = true,
	["Defensive Rune"] = true,
	["Toppling Charge"] = true,
	["Concealed Weapon"] = true,
	-- ["Petrify"] = true,
}

PVP.staminaAbilities = {
	---nightblade

	["Incapacitating Strike"] = true,
	["Ambush"] = true,
	["Killer's Blade"] = true,
	["Relentless Focus"] = true,
	["Power Extraction"] = true,
	["Assassin's Scourge"] = true,
	["Surprise Attack"] = true,

	---sorcerer-----

	["Bound Armaments"] = true,
	["Hurricane"] = true,
	["Critical Surge"] = true,

	----dk-----

	["Venomous Claw"] = true,
	["Noxious Breath"] = true,
	["Corrosive Armor"] = true,
	["Take Flight"] = true,

	-----templar----

	["Biting Jabs"] = true,
	["Binding Javelin"] = true,
	["Power of the Light"] = true,
	["Crescent Sweep"] = true,


	-----warden----

	["Cutting Dive"] = true,
	["Subterranian Assault"] = true,
	["Soothing Spores"] = true,

	----AVA----

	["Resolving Vigor"] = true,
	["Echoing Vigor"] = true,
	["Vigor"] = true,


	["Rearming Trap"] = true,
	["Trap Beast"] = true,
	["Lightweight Beast Trap"] = true,
	["Silver Bolts"] = true,
	["Silver Shards"] = true,
	["Silver Leash"] = true,
	["Flawless Dawnbreaker"] = true,

	["Spiked Bone Shield"] = true,


	["Pounce"] = true,
	["Brutal Pounce"] = true,
	["Feral Pounce"] = true,
	["Roar"] = true,
	["Ferocious Roar"] = true,
	["Rousing Roar"] = true,
	["Piercing Howl"] = true,
	["Howl of Despair"] = true,
	["Howl of Agony"] = true,
	["Infectious Claws"] = true,
	["Claws of Anguish"] = true,
	["Claws of Life"] = true,

	["Trapping Webs"] = true,
	["Shadow Silk"] = true,
	["Tangling Webs"] = true,

	["Tremorscale"] = true,
	["Viper"] = true,



	["Heavy Attack (2H)"] = true,
	["Heavy Attack (Bow)"] = true,

}

PVP.staminaAbilitiesSmallID = {
	[40158] = true, --Dawnbreaker of Smiting
}

PVP.magickaAbilitiesSmallID = {
	[32685] = true, --Fossilize
	[24574] = true, --Defensive Rune
	[15540] = true, --Toppling Charge
	[25267] = true, --Concealed Weapon
}

PVP.staminaAbilitiesID = {
	[36508] = true, --Incapacitating Strike
	[25484] = true, --Ambush
	[34843] = true, --Killer's Blade
	[61927] = true, --Relentless Focus
	[36901] = true, --Power Extraction
	[61932] = true, --Assassin's Scourge
	[25260] = true, --Surprise Attack


	---sorcerer-----

	[24165] = true, --Bound Armaments
	[23231] = true, --Hurricane
	[23678] = true, --Critical Surge

	----dk-----

	[20668] = true, --Venomous Claw
	[20944] = true, --Noxious Breath
	[17878] = true, --Corrosive Armor
	[32719] = true, --Take Flight

	-----templar----

	[26792] = true, --Biting Jabs
	[26804] = true, --Binding Javelin
	[21763] = true, --Power of the Light
	[22139] = true, --Crescent Sweep

	----AVA----

	[61507] = true, --Resolving Vigor
	[61505] = true, --Echoing Vigor
	[63236] = true, --Vigor


	[40382] = true, --Rearming Trap
	[35750] = true, --Trap Beast
	[40372] = true, --Lightweight Beast Trap
	[35721] = true, --Silver Bolts
	[40300] = true, --Silver Shards
	[40336] = true, --Silver Leash
	[40161] = true, --Flawless Dawnbreaker
	[35713] = true, --Dawnbreaker

	[42138] = true, --Spiked Bone Shield


	[32632] = true, --Pounce
	[39105] = true, --Brutal Pounce
	[39104] = true, --Feral Pounce
	[32633] = true, --Roar
	[39113] = true, --Ferocious Roar
	[39114] = true, --Rousing Roar
	[58405] = true, --Piercing Howl
	[58742] = true, --Howl of Despair
	[58798] = true, --Howl of Agony
	[58855] = true, --Infectious Claws
	[58864] = true, --Claws of Anguish
	[58879] = true, --Claws of Life

	["Trapping Webs"] = true,
	["Shadow Silk"] = true,
	["Tangling Webs"] = true,

	["Tremorscale"] = true,
	["Viper"] = true,

	["Heavy Attack (2H)"] = true,
	["Heavy Attack (Bow)"] = true,

}

PVP.selfStamAbilities = {
	["Shuffle"] = true,
	["Elude"] = true,

	["Boon: The Serpent"] = true,
	["Boon: The Warrior"] = true,
}

PVP.selfMagAbilities = {
	["Channeled Focus"] = true,
	["Boon: The Mage"] = true,
	["Boon: The Atronach"] = true,
}

PVP.selfBigStamAbilities = {
	["Relentless Focus"] = true,
	["Bound Armaments"] = true,
	["Critical Surge"] = true,
	["Rally"] = true,
	["Momentum"] = true,
	["Hurricane"] = true,
	["Hawk Eye"] = true,
	["Increase Max Health & Stamina"] = true,
	["Increase Max Health & Health"] = true,

	["Bull Netch"] = true,
	["Green Lotus"] = true,


	["Boon: The Serpent"] = true,
	["Boon: The Warrior"] = true,
	["Boon: The Tower"] = true,
}

PVP.selfBigMagAbilities = {
	["Bound Aegis"] = true,
	["Hardened Ward"] = true,
	["Empowered Ward"] = true,
	["Power Surge"] = true,
	["Harness Magicka"] = true,
	["Dampen Magic"] = true,
	["Merciless Resolve"] = true,
	["Summon Twilight Tormentor"] = true,
	["Summon Twilight Matriarch"] = true,
	["Crystal Fragments Proc"] = true,
	["Boundless Storm"] = true,
	["Flames of Oblivion"] = true,
	["Sea of Flames"] = true,
	["Inferno"] = true,
	["Increase Max Health & Magicka"] = true,
	["Witchmother's Potent Brew"] = true,

	["Blue Betty"] = true,
	["Lotus Blossom"] = true,

	["Boon: The Atronach"] = true,
	["Boon: The Mage"] = true,
	["Boon: The Apprentice"] = true,
}

PVP.magickaAbilities = {
	----nightblade----

	-- ["Impale"] = true,
	["Lotus Fan"] = true,
	["Merciless Resolve"] = true,
	["Twisting Path"] = true,
	["Path of Darkness"] = true,
	["Refreshing Path"] = true,
	["Funnel Health"] = true,
	["Swallow Soul"] = true,
	["Strife"] = true,
	["Crippling Grasp"] = true,
	["Debilitate"] = true,
	["Cripple"] = true,
	["Sap Essence"] = true,
	["Prolonged Suffering"] = true,
	["Malefic Wreath"] = true,
	["Agony"] = true,




	----sorcerer----

	["Dark Conversion"] = true,
	["Unstable Clannfear"] = true,
	["Volatile Familiar"] = true,
	["Daedric Curse"] = true,
	["Haunting Curse"] = true,
	["Daedric Prey"] = true,
	["Bound Aegis"] = true,
	["Conjured Ward"] = true,
	["Hardened Ward"] = true,
	["Empowered Ward"] = true,
	["Crystal Shard"] = true,
	["Crystal Fragments"] = true,
	["Crystal Blast"] = true,
	["Mage's Wrath"] = true,
	["Endless Fury"] = true,
	["Mage's Fury"] = true,
	["Liquid Lightning"] = true,
	["Lightning Flood"] = true,
	["Power Surge"] = true,
	["Rune Cage"] = true,
	["Rune Prison"] = true,
	["Boundless Storm"] = true,



	-----dk-----

	["Engulfing Flames"] = true,
	["Lava Whip"] = true,
	["Molten Whip"] = true,
	["Flame Lash"] = true,
	["Cauterize"] = true,
	["Burning Talons"] = true,
	["Choking Talons"] = true,
	["Inhale"] = true,
	["Deep Breath"] = true,
	["Draw Essence"] = true,
	["Ash Cloud"] = true,
	["Cinder Storm"] = true,
	["Eruption"] = true,
	["Ferocious Leap"] = true,
	["Burning Embers"] = true,

	["Shattering Rocks"] = true,


	----templar----

	["Puncturing Sweep"] = true,
	["Empowering Sweep"] = true,
	["Aurora Javelin"] = true,
	["Luminous Shards"] = true,
	["Spear Shards"] = true,
	["Blazing Spear"] = true,
	["Explosive Charge"] = true,
	["Focused Charge"] = true,

	["Sun Fire"] = true,
	["Vampire's Bane"] = true,
	["Reflective Light"] = true,

	["Dark Flare"] = true,
	["Solar Barrage"] = true,
	["Purifying Light"] = true,
	["Blazing Shield"] = true,
	["Radiant Ward"] = true,
	["Nova"] = true,
	["Solar Prison"] = true,
	["Solar Disturbance"] = true,


	["Radiant Glory"] = true,
	["Radiant Oppresion"] = true,
	["Rushed Ceremony"] = true,
	["Honor the Dead"] = true,
	["Breath of Life"] = true,
	["Ritual of Rebirth"] = true,
	["Lingering Ritual"] = true,
	["Healing Ritual"] = true,
	["Hasty Prayer"] = true,

	["Radiant Aura"] = true,

	["Rite of Passage"] = true,
	["Remembrance"] = true,
	["Practiced Incantation"] = true,

	["Eclipse"] = true,
	["Total Dark"] = true,
	["Unstable Core"] = true,

	-- warden

	["Screaming Cliff Racer"] = true,
	["Deep Fissure"] = true,
	["Fetcher Infection"] = true,
	["Growing Swarm"] = true,
	["Enchanted Growth"] = true,
	["Budding Seeds"] = true,
	["Winter's Revenge"] = true,
	["Northern Storm"] = true,



	["Meteor"] = true,
	["Shooting Star"] = true,
	["Ice Comet"] = true,

	["Bat Swarm"] = true,
	["Devouring Swarm"] = true,
	["Clouding Swarm"] = true,

	["Accelerating Drain"] = true,
	["Invigorating Drain"] = true,
	["Drain Essence"] = true,

	["Baleful Mist"] = true,

	["Soul Strike"] = true,
	["Shatter Soul"] = true,
	["Soul Assault"] = true,

	["Soul Trap"] = true,
	["Soul Spitting Trap"] = true,
	["Consuming Trap"] = true,


	----AVA----

	["Proximity Detonation"] = true,
	["Entrophy"] = true,
	["Degeneration"] = true,
	["Structured Entropy"] = true,
	["Inevitable Detonation"] = true,
	["Volcanic Rune"] = true,
	["Scalding Rune"] = true,
	["Necrotic Orb"] = true,
	["Mystic Orb"] = true,
	["Energy Orb"] = true,


	["Heavy Attack (Flame)"] = true,
	["Heavy Attack (Frost)"] = true,
	["Heavy Attack (Shock)"] = true,
	["Heavy Attack (Restoration)"] = true,

}

PVP.staminaSkillLines = {
	["Two Handed"] = true,
	["One Handed and Shield"] = true,
	["Dual Wield"] = true,
	["Bow"] = true,
}

PVP.magickaSkillLines = {
	["Destruction Staff"] = true,
	["Restoration Staff"] = true,
}

PVP.majorImportantAbilities = {
	[160184] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Rush Of Agony
}

PVP.minorImportantAbilities = {
	-- [20492] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true},  -- Fiery Grip
	-- [20493] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true},  -- Fiery Grip (From DBG)
	-- [20494] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true},  -- Fiery Grip (From DBG)
	-- [20496] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true},  -- Unrelenting Grip
	-- [32717] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Ferocious Leap (From DBG)
	-- [32721] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Ferocious Leap (From DBG)
	-- [40336] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true},  -- Silver Leash
	-- [62001] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true},  -- Unrelenting Grip (From DBG)
	-- [62004] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true},  -- Unrelenting Grip (From DBG)
	-- [118928] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Dragon Leap
	-- [118936] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Take Flight
	-- [118938] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Ferocious Leap
	-- [160317] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Dark Convergence
	-- [163227] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Meteor (Called)
	-- [163236] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Shooting Star (Called)
	-- [183267] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Rune of the Colorless Pool
	-- [185918] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Rune of Eldrich Horror
	-- [163238] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Ice Comet (Called)
	-- [185841] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Rune of Displacement
	-- [185921] =  {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Rune of Uncanny Adoration
	-- [187526] =  {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Rune of Displacement (From DBG)
	-- --[191083] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Rune of Displacement (From DBG) Synergy??
	-- [217228] = {[ACTION_RESULT_BEGIN] = true, [ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Repelling Explosion
	-- [217235] = {[ACTION_RESULT_BEGIN] = true, [ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Repelling Explosion (From DBG)
	-- [217784] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true},  -- Leashing Soul
	-- [216814] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Leashing Soul (From DBG)
	-- [216815] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Leashing Soul (From DBG)
	-- [216854] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Leashing Soul (From DBG)
	-- [217466] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Leashing Burst (From DBG)
	-- [217979] = {[ACTION_RESULT_EFFECT_GAINED] = true, [ACTION_RESULT_EFFECT_GAINED_DURATION] = true}, -- Leashing Burst
}

PVP.abilityIdIgnoreList = {
}

PVP.abilityMessages = {
	[160184] = "BLOCK - RUSH PULL - BLOCK",

	-- [20492] = "BLOCK - DK CHAIN",
	-- [20493] = "BLOCK - Fiery Grip (From DBG)",
	-- [20494] = "BLOCK - Fiery Grip (From DBG)",
	-- [20496] = "BLOCK - DK CHAIN",
	-- [32717] = "BLOCK - LEAP",
	-- [32721] = "BLOCK - LEAP",
	-- [40336] = "BLOCK - LEASH",
	-- [62001] = "BLOCK - DK CHAIN",
	-- [62004] = "BLOCK - DK CHAIN",
	-- [118928] = "BLOCK - LEAP",
	-- [118936] = "BLOCK - LEAP",
	-- [118938] = "BLOCK - LEAP",
	-- [160317] = "MOVE - DARK CON",
	-- [163227] = "BLOCK - METEOR",
	-- [163236] = "BLOCK - METEOR",
	-- [163238] = "BLOCK - METEOR",
	-- [183267] = "BLOCK - ARC FEAR",
	-- [185918] = "BLOCK - ARC FEAR",
	-- [185841] = "BLOCK - DISPLACEMENT",
	-- [187526] = "BLOCK - DISPLACEMENT",
	-- --[191083] = "BLOCK - DISPLACEMENT",
	-- [185921] = "BLOCK - CHARM",
	-- [217228] = "BLOCK - KNOCKBACK",
	-- [217235] = "BLOCK - KNOCKBACK",
	-- [216814] = "BLOCK - SOUL CHAIN",
	-- [216815] = "BLOCK - SOUL CHAIN",
	-- [216854] = "BLOCK - SOUL CHAIN",
	-- [217784] = "BLOCK - SOUL CHAIN",
	-- [217466] = "BLOCK - SOUL PULL",
	-- [217979] = "BLOCK - SOUL PULL",
}

PVP.abilityIconSwaps = {
	[160184] = "/esoui/art/icons/ability_mage_023.dds",
	-- [163227] = GetAbilityIcon(16536), -- Meteor (Called)
	-- [163236] = GetAbilityIcon(40493), -- Shooting Star (Called)
	-- [163238] = GetAbilityIcon(40489), -- Ice Comet (Called)
	-- [185841] = GetAbilityIcon(201293), -- Rune of Displacement
	-- [191083] = GetAbilityIcon(201293), -- Rune of Displacement
}

PVP.networkedAbilities = {
	[160184] = true, -- Rush Of Agony
}

PVP.networkingPingData = {
	["10_10_10_10"] = {
		["result"] = ACTION_RESULT_EFFECT_GAINED,
		["abilityName"]= "When you deal direct damage with a Blink, Charge, Leap, Teleport, or Pull",
		["abilityId"] = 160184,
		["sourceUnitId"] = 123456,
		["sourceName"] = "AgonyWarning",
		["hitValue"] = 800,
	}
}

PVP.heavyAttackNames = {
	["Heavy Attack (2H)"] = PVP_2H_HA_ICON,
	["Heavy Attack (Bow)"] = PVP_BOW_HA_ICON,
	["Heavy Attack (Dual Wield)"] = PVP_DW_HA_ICON,
	["Heavy Attack (1H)"] = PVP_SB_HA_ICON,
	["Heavy Attack (Flame)"] = PVP_FLAME_HA_ICON,
	["Heavy Attack (Frost)"] = PVP_FROST_HA_ICON,
}

PVP.heavyAttackId = {
	[16041] = PVP_2H_HA_ICON,
	[16691] = PVP_BOW_HA_ICON,
	[16420] = PVP_DW_HA_ICON,
	[15279] = PVP_SB_HA_ICON,
	[15383] = PVP_FLAME_HA_ICON,
	[16261] = PVP_FROST_HA_ICON,
}

PVP.hitTypes = {
	[ACTION_RESULT_BLOCKED] = true,
	[ACTION_RESULT_ABSORBED] = true,
	[ACTION_RESULT_BLOCKED_DAMAGE] = true,
	[ACTION_RESULT_CRITICAL_DAMAGE] = true,
	[ACTION_RESULT_DAMAGE] = true,
	[ACTION_RESULT_DAMAGE_SHIELDED] = true,
	[ACTION_RESULT_IMMUNE] = true,
	[ACTION_RESULT_MISS] = true,
	[ACTION_RESULT_PARTIAL_RESIST] = true,
	[ACTION_RESULT_REFLECTED] = true,
	[ACTION_RESULT_RESIST] = true,
	[ACTION_RESULT_WRECKING_DAMAGE] = true,

	[ACTION_RESULT_DODGED] = true,
	[ACTION_RESULT_DISORIENTED] = true,
	[ACTION_RESULT_EFFECT_GAINED] = true,
	[ACTION_RESULT_EFFECT_GAINED_DURATION] = true,
	[ACTION_RESULT_FEARED] = true,
	[ACTION_RESULT_STUNNED] = true,
	[ACTION_RESULT_OFFBALANCE] = true,
}

-- PVP.heavyAttackIdFrame={
-- [16041] = PVP_2H_HA_ICON,
-- [16691] = PVP_BOW_HA_ICON,
-- [16420] = PVP_DW_HA_ICON,
-- [15279] = PVP_SB_HA_ICON,
-- [15383] = PVP_FLAME_HA_ICON,
-- [16261] = PVP_FROST_HA_ICON,
-- [18396] = PVP_SHOCK_HA_ICON,
-- [16212] = PVP_RESTO_HA_ICON,
-- }

-- PVP.heavyIconColors={
-- [16041] = PVP_2H_HA_COLOR,
-- [16691] = PVP_BOW_HA_COLOR,
-- [16420] = PVP_DW_HA_COLOR,
-- [15279] = PVP_SB_HA_COLOR,
-- [15383] = PVP_FLAME_HA_COLOR,
-- [16261] = PVP_FROST_HA_COLOR,
-- [18396] = PVP_SHOCK_HA_COLOR,
-- [16212] = PVP_RESTO_HA_COLOR,
-- }

PVP.chargeSnare = {
	["Toppling Charge"] = true,
	["Invasion"] = true,
	["Shielded Assault"] = true,
	["Shield Charge"] = true,
}

PVP.chargeSnareId = {
	[15540] = true, --Toppling Charge Active
	[23864] = true, --Toppling Charge Active
	[23869] = true, --Toppling Charge Active
	[23870] = true, --Toppling Charge Active

	[38405] = true, --Invasion Active
	[41530] = true, --Invasion Active
	[41534] = true, --Invasion Active
	[41538] = true, --Invasion Active

	[38401] = true, --Shielded Assault Active
	[41518] = true, --Shielded Assault Active
	[41522] = true, --Shielded Assault Active
	[41526] = true, --Shielded Assault Active

	[28719] = true, --Shield Charge Active
	[41506] = true, --Shield Charge Active
	[41509] = true, --Shield Charge Active
	[41512] = true, --Shield Charge Active
}

PVP.AVAids = {
	[16] = { -- Castle Faregyl

		[1] = { -- Castle Faregyl Apse
			objectiveId = 60,
			height = 209.88,
		},
		[2] = { -- Castle Faregyl Nave
			objectiveId = 61,
			height = 209.88,
		},
		[3] = { -- Castle Faregyl Artifact Storage
			objectiveId = 155,
			height = 209.88,
		},
	},

	[45] = { -- Castle Faregyl Mine

		[1] = { -- Faregyl Mine Flag
			objectiveId = 64,
			height = 215.31,
			parentKeepId = 16,
		},
	},

	[43] = { -- Castle Faregyl Farm

		[1] = { -- Faregyl Farm Flag
			objectiveId = 62,
			height = 224.19,
			parentKeepId = 16,
		},
	},

	[44] = { -- Castle Faregyl Lumbermill

		[1] = { -- Faregyl Lumbermill Flag
			objectiveId = 63,
			height = 235.64,
			parentKeepId = 16,
		},
	},

	---------------------------------------------------------

	[15] = { -- Castle Alessia

		[1] = { -- Castle Alessia Apse
			objectiveId = 167,
			height = 164.71,
		},
		[2] = { -- Castle Alessia Nave
			objectiveId = 168,
			height = 164.71,
		},
		[3] = { -- Castle Alessia Artifact Storage
			objectiveId = 154,
			height = 164.71,
		},
	},

	[79] = { -- Castle Alessia Mine

		[1] = { -- Alessia Mine Flag
			objectiveId = 198,
			height = 160.28,
			parentKeepId = 15,
		},
	},

	[81] = { -- Castle Alessia Farm

		[1] = { -- Alessia Farm Flag
			objectiveId = 197,
			height = 200.91,
			parentKeepId = 15,
		},
	},

	[80] = { -- Castle Alessia Lumbermill

		[1] = { -- Alessia Lumbermill Flag
			objectiveId = 196,
			height = 141.73,
			parentKeepId = 15,
		},
	},

	------------------------------------------------------------------------


	[19] = { -- Castle Black Boot

		[1] = { -- Castle Black Boot Apse
			objectiveId = 49,
			height = 186.76,
		},
		[2] = { -- Castle Black Boot Nave
			objectiveId = 48,
			height = 186.76,
		},
		[3] = { -- Castle Black Boot Artifact Storage
			objectiveId = 158,
			height = 186.76,
		},
	},

	[35] = { -- Castle Black Boot Mine

		[1] = { -- Black Boot Mine Flag
			objectiveId = 46,
			height = 178.82,
			parentKeepId = 19,
		},
	},

	[36] = { -- Castle Black Boot Farm

		[1] = { -- Black Boot Farm Flag
			objectiveId = 47,
			height = 183.12,
			parentKeepId = 19,
		},
	},

	[34] = { -- Castle Black Boot Lumbermill

		[1] = { -- Black Boot Lumbermill Flag
			objectiveId = 45,
			height = 154.38,
			parentKeepId = 19,
		},
	},

	------------------------------------------------------------------------

	[20] = { -- Castle Bloodmayne

		[1] = { -- Castle Bloodmayne Apse
			objectiveId = 40,
			height = 159.57,
		},
		[2] = { -- Castle Bloodmayne Nave
			objectiveId = 41,
			height = 159.57,
		},
		[3] = { -- Castle Bloodmayne Artifact Storage
			objectiveId = 159,
			height = 159.57,
		},
	},

	[23] = { -- Castle Bloodmayne Mine

		[1] = { -- Bloodmayne Mine Flag
			objectiveId = 80,
			height = 167.00,
			parentKeepId = 20,
		},
	},

	[22] = { -- Castle Bloodmayne Farm

		[1] = { -- Bloodmayne Farm Flag
			objectiveId = 42,
			height = 206.28,
			parentKeepId = 20,
		},
	},

	[24] = { -- Castle Bloodmayne Lumbermill

		[1] = { -- Bloodmayne Lumbermill Flag
			objectiveId = 79,
			height = 179.00,
			parentKeepId = 20,
		},
	},

	------------------------------------------------------------------------

	[17] = { -- Castle Roebeck

		[1] = { -- Castle Roebeck Apse
			objectiveId = 165,
			height = 255.21,
		},
		[2] = { -- Castle Roebeck Nave
			objectiveId = 166,
			height = 255.21,
		},
		[3] = { -- Castle Roebeck Artifact Storage
			objectiveId = 156,
			height = 255.21,
		},
	},

	[82] = { -- Castle Roebeck Mine

		[1] = { -- Roebeck Mine Flag
			objectiveId = 183,
			height = 256.99,
			parentKeepId = 17,
		},
	},

	[84] = { -- Castle Roebeck Farm

		[1] = { -- Roebeck Farm Flag
			objectiveId = 181,
			height = 230.59,
			parentKeepId = 17,
		},
	},

	[83] = { -- Castle Roebeck Lumbermill

		[1] = { -- Roebeck Lumbermill Flag
			objectiveId = 182,
			height = 254.99,
			parentKeepId = 17,
		},
	},

	------------------------------------------------------------------------

	[18] = { -- Castle Brindle

		[1] = { -- Castle Brindle Apse
			objectiveId = 163,
			height = 260.70,
		},
		[2] = { -- Castle Brindle Nave
			objectiveId = 164,
			height = 260.70,
		},
		[3] = { -- Castle Brindle Artifact Storage
			objectiveId = 157,
			height = 260.70,
		},
	},

	[85] = { -- Castle Brindle Mine

		[1] = { -- Brindle Mine Flag
			objectiveId = 162,
			height = 259.26,
			parentKeepId = 18,
		},
	},

	[87] = { -- Castle Brindle Farm

		[1] = { -- Brindle Farm Flag
			objectiveId = 105,
			height = 207.83,
			parentKeepId = 18,
		},
	},

	[86] = { -- Castle Brindle Lumbermill

		[1] = { -- Brindle Lumbermill Flag
			objectiveId = 161,
			height = 258.02,
			parentKeepId = 18,
		},
	},

	------------------------------------------------------------------------

	[14] = { -- Drakelowe Keep

		[1] = { -- Drakelowe Keep Apse
			objectiveId = 171,
			height = 179.78,
		},
		[2] = { -- Drakelowe Keep Nave
			objectiveId = 172,
			height = 179.78,
		},
		[3] = { -- Drakelowe Keep Artifact Storage
			objectiveId = 153,
			height = 179.78,
		},
	},

	[76] = { -- Drakelowe Keep Mine

		[1] = { -- Drakelowe Mine Flag
			objectiveId = 202,
			height = 156.10,
			parentKeepId = 14,
		},
	},

	[78] = { -- Drakelowe Keep Farm

		[1] = { -- Drakelowe Farm Flag
			objectiveId = 204,
			height = 224.00,
			parentKeepId = 14,
		},
	},

	[77] = { -- Drakelowe Keep Lumbermill

		[1] = { -- Drakelowe Lumbermill Flag
			objectiveId = 203,
			height = 185.09,
			parentKeepId = 14,
		},
	},

	------------------------------------------------------------------------

	[11] = { -- Kingscrest Keep

		[1] = { -- Kingscrest Keep Apse
			objectiveId = 77,
			height = 360.57,
		},
		[2] = { -- Kingscrest Keep Nave
			objectiveId = 78,
			height = 357.40,
		},
		[3] = { -- Kingscrest Keep Artifact Storage
			objectiveId = 150,
			height = 362.24,
		},
	},

	[54] = { -- Kingscrest Keep Mine

		[1] = { -- Kingscrest Mine Flag
			objectiveId = 83,
			height = 381.07,
			parentKeepId = 11,
		},
	},

	[52] = { -- Kingscrest Keep Farm

		[1] = { -- Kingscrest Farm Flag
			objectiveId = 81,
			height = 350.43,
			parentKeepId = 11,
		},
	},

	[53] = { -- Kingscrest Keep Lumbermill

		[1] = { -- Kingscrest Lumbermill Flag
			objectiveId = 82,
			height = 380.03,
			parentKeepId = 11,
		},
	},

	------------------------------------------------------------------------

	[12] = { -- Farragut Keep

		[1] = { -- Farragut Keep Apse
			objectiveId = 51,
			height = 373.33,
		},
		[2] = { -- Farragut Keep Nave
			objectiveId = 50,
			height = 370.16,
		},
		[3] = { -- Farragut Keep Artifact Storage
			objectiveId = 151,
			height = 375.00,
		},
	},

	[38] = { -- Farragut Keep Mine

		[1] = { -- Farragut Mine Flag
			objectiveId = 53,
			height = 370.02,
			parentKeepId = 12,
		},
	},

	[39] = { -- Farragut Keep Farm

		[1] = { -- Farragut Farm Flag
			objectiveId = 54,
			height = 358.59,
			parentKeepId = 12,
		},
	},

	[37] = { -- Farragut Keep Lumbermill

		[1] = { -- Farragut Lumbermill Flag
			objectiveId = 52,
			height = 363.78,
			parentKeepId = 12,
		},
	},

	------------------------------------------------------------------------

	[13] = { -- Blue Road Keep

		[1] = { -- Blue Road Keep Apse
			objectiveId = 176,
			height = 263.51,
		},
		[2] = { -- Blue Road Keep Nave
			objectiveId = 175,
			height = 263.51,
		},
		[3] = { -- Blue Road Keep Artifact Storage
			objectiveId = 152,
			height = 263.51,
		},
	},

	[73] = { -- Blue Road Keep Mine

		[1] = { -- Blue Road Mine Flag
			objectiveId = 184,
			height = 262.11,
			parentKeepId = 13,
		},
	},

	[75] = { -- Blue Road Keep Farm

		[1] = { -- Blue Road Farm Flag
			objectiveId = 186,
			height = 202.98,
			parentKeepId = 13,
		},
	},

	[74] = { -- Blue Road Keep Lumbermill

		[1] = { -- Blue Road Lumbermill Flag
			objectiveId = 185,
			height = 267.12,
			parentKeepId = 13,
		},
	},

	------------------------------------------------------------------------

	[6] = { -- Fort Ash

		[1] = { -- Fort Ash Apse
			objectiveId = 177,
			height = 263.51,
		},
		[2] = { -- Fort Ash Nave
			objectiveId = 178,
			height = 263.51,
		},
		[3] = { -- Fort Ash Artifact Storage
			objectiveId = 145,
			height = 263.51,
		},
	},

	[63] = { -- Fort Ash Mine

		[1] = { -- Fort Ash Mine Flag
			objectiveId = 194,
			height = 259.52,
			parentKeepId = 6,
		},
	},

	[61] = { -- Fort Ash Farm

		[1] = { -- Fort Ash Farm Flag
			objectiveId = 193,
			height = 247.45,
			parentKeepId = 6,
		},
	},

	[62] = { -- Fort Ash Lumbermill

		[1] = { -- Fort Ash Lumbermill Flag
			objectiveId = 195,
			height = 219.17,
			parentKeepId = 6,
		},
	},

	------------------------------------------------------------------------

	[10] = { -- Arrius Keep

		[1] = { -- Arrius Keep Apse
			objectiveId = 65,
			height = 316.96,
		},
		[2] = { -- Arrius Keep Nave
			objectiveId = 66,
			height = 313.79,
		},
		[3] = { -- Arrius Keep Artifact Storage
			objectiveId = 149,
			height = 318.63,
		},
	},

	[48] = { -- Arrius Keep Mine

		[1] = { -- Arrius Keep Mine Flag
			objectiveId = 69,
			height = 335.09,
			parentKeepId = 10,
		},
	},

	[46] = { -- Arrius Keep Farm

		[1] = { -- Arrius Keep Farm Flag
			objectiveId = 67,
			height = 340.01,
			parentKeepId = 10,
		},
	},

	[47] = { -- Arrius Keep Lumbermill

		[1] = { -- Arrius Keep Lumbermill Flag
			objectiveId = 68,
			height = 306.04,
			parentKeepId = 10,
		},
	},

	------------------------------------------------------------------------

	[9] = { -- Chalman Keep

		[1] = { -- Chalman Keep Apse
			objectiveId = 179,
			height = 235.54,
		},
		[2] = { -- Chalman Keep Nave
			objectiveId = 180,
			height = 233.58,
		},
		[3] = { -- Chalman Keep Artifact Storage
			objectiveId = 148,
			height = 236.47,
		},
	},

	[70] = { -- Chalman Keep Mine

		[1] = { -- Chalman Keep Mine Flag
			objectiveId = 190,
			height = 248.62,
			parentKeepId = 9,
		},
	},

	[72] = { -- Chalman Keep Farm

		[1] = { -- Chalman Keep Farm Flag
			objectiveId = 192,
			height = 283.29,
			parentKeepId = 9,
		},
	},

	[71] = { -- Chalman Keep Lumbermill

		[1] = { -- Chalman Keep Lumbermill Flag
			objectiveId = 191,
			height = 210.76,
			parentKeepId = 9,
		},
	},

	------------------------------------------------------------------------

	[7] = { -- Fort Aleswell

		[1] = { -- Fort Aleswell Apse
			objectiveId = 173,
			height = 214.29,
		},
		[2] = { -- Fort Aleswell Nave
			objectiveId = 174,
			height = 212.33,
		},
		[3] = { -- Fort Aleswell Artifact Storage
			objectiveId = 146,
			height = 215.30,
		},
	},

	[64] = { -- Fort Aleswell Mine

		[1] = { -- Fort Aleswell Mine Flag
			objectiveId = 189,
			height = 241.10,
			parentKeepId = 7,
		},
	},

	[66] = { -- Fort Aleswell Farm

		[1] = { -- Fort Aleswell Farm Flag
			objectiveId = 187,
			height = 229.53,
			parentKeepId = 7,
		},
	},

	[65] = { -- Fort Aleswell Lumbermill

		[1] = { -- Fort Aleswell Lumbermill Flag
			objectiveId = 188,
			height = 211.05,
			parentKeepId = 7,
		},
	},

	------------------------------------------------------------------------

	[4] = { -- Fort Rayles

		[1] = { -- Fort Rayles Apse
			objectiveId = 75,
			height = 316.51,
		},
		[2] = { -- Fort Rayles Nave
			objectiveId = 76,
			height = 313.34,
		},
		[3] = { -- Fort Rayles Artifact Storage
			objectiveId = 143,
			height = 318.18,
		},
	},

	[57] = { -- Fort Rayles Mine

		[1] = { -- Fort Rayles Mine Flag
			objectiveId = 86,
			height = 347.58,
			parentKeepId = 4,
		},
	},

	[55] = { -- Fort Rayles Farm

		[1] = { -- Fort Rayles Farm Flag
			objectiveId = 84,
			height = 308.25,
			parentKeepId = 4,
		},
	},

	[56] = { -- Fort Rayles Lumbermill

		[1] = { -- Fort Rayles Lumbermill Flag
			objectiveId = 85,
			height = 308.12,
			parentKeepId = 4,
		},
	},

	------------------------------------------------------------------------

	[3] = { -- Fort Warden

		[1] = { -- Fort Warden Apse
			objectiveId = 56,
			height = 362.01,
		},
		[2] = { -- Fort Warden Nave
			objectiveId = 55,
			height = 358.84,
		},
		[3] = { -- Fort Warden Artifact Storage
			objectiveId = 142,
			height = 363.68,
		},
	},

	[42] = { -- Fort Warden Mine

		[1] = { -- Fort Warden Mine Flag
			objectiveId = 59,
			height = 375.77,
			parentKeepId = 3,
		},
	},

	[40] = { -- Fort Warden Farm

		[1] = { -- Fort Warden Farm Flag
			objectiveId = 57,
			height = 384.36,
			parentKeepId = 3,
		},
	},

	[41] = { -- Fort Warden Lumbermill

		[1] = { -- Fort Warden Lumbermill Flag
			objectiveId = 58,
			height = 368.02,
			parentKeepId = 3,
		},
	},

	------------------------------------------------------------------------

	[8] = { -- Fort Dragonclaw

		[1] = { -- Fort Dragonclaw Apse
			objectiveId = 169,
			height = 414.02,
		},
		[2] = { -- Fort Dragonclaw Nave
			objectiveId = 170,
			height = 412.14,
		},
		[3] = { -- Fort Dragonclaw Artifact Storage
			objectiveId = 147,
			height = 415.03,
		},
	},

	[67] = { -- Fort Dragonclaw Mine

		[1] = { -- Fort Dragonclaw Mine Flag
			objectiveId = 199,
			height = 392.74,
			parentKeepId = 8,
		},
	},

	[69] = { -- Fort Dragonclaw Farm

		[1] = { -- Fort Dragonclaw Farm Flag
			objectiveId = 201,
			height = 402.99,
			parentKeepId = 8,
		},
	},

	[68] = { -- Fort Dragonclaw Lumbermill

		[1] = { -- Fort Dragonclaw Lumbermill Flag
			objectiveId = 200,
			height = 422.65,
			parentKeepId = 8,
		},
	},

	------------------------------------------------------------------------

	[5] = { -- Fort Glademist

		[1] = { -- Fort Glademist Apse
			objectiveId = 70,
			height = 319.50,
		},
		[2] = { -- Fort Glademist Nave
			objectiveId = 71,
			height = 316.33,
		},
		[3] = { -- Fort Glademist Artifact Storage
			objectiveId = 144,
			height = 321.17,
		},
	},

	[51] = { -- Fort Glademist Mine

		[1] = { -- Fort Glademist Mine Flag
			objectiveId = 74,
			height = 352.04,
			parentKeepId = 5,
		},
	},

	[49] = { -- Fort Glademist Farm

		[1] = { -- Fort Glademist Farm Flag
			objectiveId = 72,
			height = 306.94,
			parentKeepId = 5,
		},
	},

	[50] = { -- Fort Glademist Lumbermill

		[1] = { -- Fort Glademist Lumbermill Flag
			objectiveId = 73,
			height = 307.71,
			parentKeepId = 5,
		},
	},


	------------------------------------------------------------------------

	[133] = { -- Sejanus Outpost

		[1] = { -- Sejanus Outpost Tower
			objectiveId = 214,
			height = 223.71,
		},
		[2] = { -- Sejanus Outpost Courtyard
			objectiveId = 215,
			height = 223.71,
		},
	},

	------------------------------------------------------------------------

	[132] = { -- Nikel Outpost

		[1] = { -- Nikel Outpost Tower
			objectiveId = 216,
			height = 258.01,
		},
		[2] = { -- Nikel Outpost Courtyard
			objectiveId = 217,
			height = 258.01,
		},
	},

	------------------------------------------------------------------------

	[134] = { -- Bleaker's Outpost

		[1] = { -- Bleaker's Outpost Tower
			objectiveId = 218,
			height = 249.53,
		},
		[2] = { -- Bleaker's Outpost Courtyard
			objectiveId = 219,
			height = 247.57,
		},
	},

	------------------------------------------------------------------------

	[164] = { -- Carmala Outpost

		[1] = { -- Carmala Outpost Tower
			objectiveId = 433,
			height = 240.15,
		},
		[2] = { -- Carmala Outpost Courtyard
			objectiveId = 434,
			height = 238.19,
		},
	},

	------------------------------------------------------------------------

	[163] = { -- Winter's Peak Outpost

		[1] = { -- Winter's Peak Outpost Tower
			objectiveId = 431,
			height = 426.03,
		},
		[2] = { -- Winter's Peak Outpost Courtyard
			objectiveId = 432,
			height = 424.07,
		},
	},

	------------------------------------------------------------------------

	[165] = { -- Harlun's Outpost

		[1] = { -- Harlun's Outpost Tower
			objectiveId = 435,
			height = 308.33,
		},
		[2] = { -- Harlun's Outpost Courtyard
			objectiveId = 436,
			height = 306.36,
		},
	},

	------------------------------------------------------------------------

	[149] = { -- Vlastarus

		[1] = { -- Vlastarus Central Flag
			objectiveId = 294,
			height = 230.75,
		},
		[2] = { -- Vlastarus Merchant Flag
			objectiveId = 303,
			height = 238.42,
		},
		[3] = { -- Vlastarus Outlier Flag
			objectiveId = 304,
			height = 232.93,
		},
	},

	------------------------------------------------------------------------

	[152] = { -- Cropsford

		[1] = { -- Cropsford Central Flag
			objectiveId = 300,
			height = 222.39,
		},
		[2] = { -- Cropsford Merchant Flag
			objectiveId = 301,
			height = 207.28,
		},
		[3] = { -- Cropsford Outlier Flag
			objectiveId = 302,
			height = 219.32,
		},
	},

	------------------------------------------------------------------------

	[151] = { -- Bruma

		[1] = { -- Bruma Central Flag
			objectiveId = 296,
			height = 331.56,
		},
		[2] = { -- Bruma Merchant Flag
			objectiveId = 299,
			height = 336.48,
		},
		[3] = { -- Bruma Outlier Flag
			objectiveId = 297,
			height = 337.24,
		},
	},

	------------------------------------------------------------------------

	[119] = { -- Scroll Temple of Mnem

		[1] = { -- Elder Scroll of Mnem
			objectiveId = 137,
			height = 223.77,
		},
	},

	------------------------------------------------------------------------

	[118] = { -- Scroll Temple of Altadoon

		[1] = { -- Elder Scroll of Altadoon
			objectiveId = 136,
			height = 258.53,
		},
	},

	------------------------------------------------------------------------

	[123] = { -- Scroll Temple of Alma Ruma

		[1] = { -- Elder Scroll of Alma Ruma
			objectiveId = 141,
			height = 375.05,
		},
	},

	------------------------------------------------------------------------

	[122] = { -- Scroll Temple of Ni-Mohk

		[1] = { -- Elder Scroll of Ni-Mohk
			objectiveId = 140,
			height = 375.02,
		},
	},

	------------------------------------------------------------------------

	[121] = { -- Scroll Temple of Chim

		[1] = { -- Elder Scroll of Chim
			objectiveId = 139,
			height = 412.14,
		},
	},

	------------------------------------------------------------------------

	[120] = { -- Scroll Temple of Ghartok

		[1] = { -- Elder Scroll of Ghartok
			objectiveId = 138,
			height = 409.12,
		},
	},

	------------------------------------------------------------------------

	[125] = { -- Gate of Mnem

		[1] = {
			objectiveId = 0,
			height = 139.52,
		},
	},

	------------------------------------------------------------------------

	[124] = { -- Gate of Altadoon

		[1] = {
			objectiveId = 0,
			height = 171.31,
		},
	},

	------------------------------------------------------------------------

	[126] = { -- Gate of Ghartok

		[1] = {
			objectiveId = 0,
			height = 379.19,
		},
	},

	------------------------------------------------------------------------

	[127] = { -- Gate of Chim

		[1] = {
			objectiveId = 0,
			height = 397.10,
		},
	},

	------------------------------------------------------------------------

	[128] = { -- Gate of Ni-Mohk

		[1] = {
			objectiveId = 0,
			height = 323.30,
		},
	},

	------------------------------------------------------------------------

	[129] = { -- Gate of Alma Ruma

		[1] = {
			objectiveId = 0,
			height = 359.104,
		},
	},

	------------------------------------------------------------------------

	[105] = { -- Western Elsweyr Gate

		[1] = {
			objectiveId = 0,
			height = 257.51,
			coords = {
				insideCorner1 = {
					x = 0.461968511343,
					y = 0.54347509145737,
				},
				insideCorner2 = {
					x = 0.45691725611687,
					y = 0.53950273990631,
				},
				outsideCorner1 = {
					x = 0.38421556353569,
					y = 0.89181333780289,
				},
				outsideCorner2 = {
					x = 0.38398665189743,
					y = 0.89163333177567,
				},
			},
		},
	},

	------------------------------------------------------------------------

	[106] = { -- Eastern Elsweyr Gate

		[1] = {
			objectiveId = 0,
			height = 251.722,
			coords = {
				insideCorner1 = {
					x = 0.43370285630226,
					y = 0.39417254924774,
				},
				insideCorner2 = {
					x = 0.42899861931801,
					y = 0.39391729235649,
				},
				outsideCorner1 = {
					x = 0.6035777926445,
					y = 0.8824177980423,
				},
				outsideCorner2 = {
					x = 0.60329109430313,
					y = 0.88240224123001,
				},
			},
		},
	},



	------------------------------------------------------------------------

	[107] = { -- Southern Morrowind Gate

		[1] = {
			objectiveId = 0,
			height = 411.73,
			coords = {
				insideCorner1 = {
					x = 0.53014594316483,
					y = 0.47470769286156,
				},
				insideCorner2 = {
					x = 0.52724635601044,
					y = 0.47757571935654,
				},
				outsideCorner1 = {
					x = 0.92780888080597,
					y = 0.30632221698761,
				},
				outsideCorner2 = {
					x = 0.92760443687439,
					y = 0.30652445554733,
				},
			},
		},
	},


	------------------------------------------------------------------------

	[108] = { -- Northern Morrowind Gate

		[1] = {
			objectiveId = 0,
			height = 424.27,
			coords = {
				insideCorner1 = {
					x = 0.48236629366875,
					y = 0.5524914264679,
				},
				insideCorner2 = {
					x = 0.48526585102081,
					y = 0.55539095401764,
				},
				outsideCorner1 = {
					x = 0.837526679039,
					y = 0.11551778018475,
				},
				outsideCorner2 = {
					x = 0.83773112297058,
					y = 0.11572222411633,
				},
			},
		},
	},

	------------------------------------------------------------------------

	[109] = { -- Southern Highrock Gate

		[1] = {
			objectiveId = 0,
			height = 388.72,
			coords = {
				insideCorner1 = {
					x = 0.65259683132172,
					y = 0.4966089725944,
				},
				insideCorner2 = {
					x = 0.65558630228043,
					y = 0.4916116297245,
				},
				outsideCorner1 = {
					x = 0.068831108510494,
					y = 0.28527998924255,
				},
				outsideCorner2 = {
					x = 0.068980000913143,
					y = 0.28503111004829,
				},
			},
		},
	},

	------------------------------------------------------------------------

	[110] = { -- Northern Highrock Gate

		[1] = {
			objectiveId = 0,
			height = 353.94,
			coords = {
				insideCorner1 = {
					x = 0.53899747133255,
					y = 0.64700305461884,
				},
				insideCorner2 = {
					x = 0.53450405597687,
					y = 0.6440349817276,
				},
				outsideCorner1 = {
					x = 0.15952444076538,
					y = 0.10226000100374,
				},
				outsideCorner2 = {
					x = 0.15928222239017,
					y = 0.10209999978542,
				},
			},
		},
	},

	------------------------------------------------------------------------

	[141] = { -- Nobles District

		[1] = { -- Nobles District Flag
			objectiveId = 291,
			height = 310.48,
		},
	},

	------------------------------------------------------------------------

	[142] = { -- Memorial District

		[1] = { -- Memorial District Flag
			objectiveId = 289,
			height = 310,
		},
	},

	------------------------------------------------------------------------

	[143] = { -- Arboretum

		[1] = { -- Arboretum District Flag
			objectiveId = 290,
			height = 310.62,
		},
	},

	------------------------------------------------------------------------

	[146] = { -- Arena District

		[1] = { -- Arena District Flag
			objectiveId = 288,
			height = 310.49,
		},
	},

	------------------------------------------------------------------------

	[147] = { -- Temple District

		[1] = { -- Temple District Flag
			objectiveId = 292,
			height = 310,
		},
	},

	------------------------------------------------------------------------

	[148] = { -- Elven Gardens District

		[1] = { -- Elven Gardens District Flag
			objectiveId = 293,
			height = 310,
		},
	},

	------------------------------------------------------------------------

}

PVP.bgObjectives = {
	-- ulara
	[316] = 159.00, -- ulara waterfall
	[317] = 159.83, -- ulara altar
	[315] = 171.49, -- ulara cenral
	[318] = 159.26, -- ulara mushroom

	[340] = 165.79, -- ullara SL relic spawn
	[341] = 165.28, -- ullara PD relic spawn
	[342] = 165.06, -- ullara FD relic spawn

	-- foyada
	[308] = 116.32, -- foyada pit flag
	[309] = 117.02, -- foyada fire storm
	[306] = 120.53, -- foyada cenral
	[310] = 116.53, -- foyada storm pit

	[335] = 123.71, -- foyada SL relic spawn
	[336] = 123.39, -- foyada PD relic spawn
	[334] = 123.91, -- foyada FD relic spawn

	-- ald carac
	[321] = 159.24, -- ald carac Centurion
	[319] = 155.77, -- engine
	[320] = 159.91, -- forge
	[314] = 155.16, -- central

	[337] = 161.00, -- ald carac SL relic spawn
	[338] = 161.00, -- ald carac PD relic spawn approx
	[339] = 161.00, -- ald carac FD relic spawn approx

}

PVP.ullaraIds = {
	[43] = true,
	[46] = true,
	[49] = true,
	[72] = true,
	[85] = true,
	[88] = true,
	[91] = true,
	[113] = true,
	[117] = true,
	[121] = true,
}

PVP.foyadaIds = {
	[41] = true,
	[44] = true,
	[47] = true,
	[69] = true,
	[70] = true,
	[83] = true,
	[86] = true,
	[111] = true,
	[115] = true,
	[119] = true,
}

PVP.aldIds = {
	[42] = true,
	[45] = true,
	[48] = true,
	[76] = true,
	[77] = true,
	[84] = true,
	[87] = true,
	[112] = true,
	[116] = true,
	[120] = true,
}

PVP.arcaneIds = {
	[40] = true,
	[93] = true,
	[81] = true,
	[105] = true,
	[107] = true,
	[108] = true,
	[109] = true,
	[110] = true,
	[118] = true,
	[122] = true,
}

PVP.bgDamagePowerups = {
	-- [42] = { -- arc DM
	ald = { -- ald DM
		{ x = 0.426172, y = 0.757604, z = 162.20 },
		{ x = 0.426489, y = 0.242078, z = 159.25 },
		{ x = 0.862167, y = 0.492712, z = 162.20 },
		{ x = 0.579847, y = 0.488910, z = 155.16 },
	},

	-- [41] = { -- foyada DM
	foyada = { -- foyada DM
		{ x = 0.626567, y = 0.681125, z = 116.90 },
		{ x = 0.34496,  y = 0.49915,  z = 116.07 },
		{ x = 0.63842,  y = 0.35276,  z = 116.22 },
		{ x = 0.530667, y = 0.503219, z = 120.52 },
	},

	ullara = { -- ullara DM
		{ x = 0.397900, y = 0.728109, z = 159.84 },
		{ x = 0.541144, y = 0.490289, z = 177.52 },
		{ x = 0.405350, y = 0.270187, z = 159.26 },
		{ x = 0.795462, y = 0.506884, z = 159.13 },
	},
}


PVP.bgTeamBases = {
	[77] = { -- arc DOM
		{ x = 0.243979, y = 0.497148, z = 169.91, alliance = BATTLEGROUND_TEAM_FIRE_DRAKES },
		{ x = 0.748098, y = 0.208174, z = 170.03, alliance = BATTLEGROUND_TEAM_PIT_DAEMONS },
		{ x = 0.739860, y = 0.772813, z = 169.90, alliance = BATTLEGROUND_TEAM_STORM_LORDS },
	},

	[42] = { -- arc DM
		{ x = 0.243979, y = 0.497148, z = 169.91, alliance = BATTLEGROUND_TEAM_FIRE_DRAKES },
		{ x = 0.748098, y = 0.208174, z = 170.03, alliance = BATTLEGROUND_TEAM_PIT_DAEMONS },
		{ x = 0.739860, y = 0.772813, z = 169.90, alliance = BATTLEGROUND_TEAM_STORM_LORDS },
	},

	[84] = { -- arc CTF
		{ x = 0.243979, y = 0.497148, z = 169.91, alliance = BATTLEGROUND_TEAM_FIRE_DRAKES },
		{ x = 0.748098, y = 0.208174, z = 170.03, alliance = BATTLEGROUND_TEAM_PIT_DAEMONS },
		{ x = 0.739860, y = 0.772813, z = 169.90, alliance = BATTLEGROUND_TEAM_STORM_LORDS },
	},

	[70] = { -- foyada DON
		{ x = 0.259573, y = 0.572009, z = 132.64, alliance = BATTLEGROUND_TEAM_FIRE_DRAKES },
		{ x = 0.679091, y = 0.756353, z = 133.19, alliance = BATTLEGROUND_TEAM_PIT_DAEMONS },
		{ x = 0.691968, y = 0.281260, z = 132.59, alliance = BATTLEGROUND_TEAM_STORM_LORDS },
	},

	[41] = { -- foyada DM
		{ x = 0.259573, y = 0.572009, z = 132.64, alliance = BATTLEGROUND_TEAM_FIRE_DRAKES },
		{ x = 0.679091, y = 0.756353, z = 133.19, alliance = BATTLEGROUND_TEAM_PIT_DAEMONS },
		{ x = 0.691968, y = 0.281260, z = 132.59, alliance = BATTLEGROUND_TEAM_STORM_LORDS },
	},

	[83] = { -- foyada CTF
		{ x = 0.259573, y = 0.572009, z = 132.64, alliance = BATTLEGROUND_TEAM_FIRE_DRAKES },
		{ x = 0.679091, y = 0.756353, z = 133.19, alliance = BATTLEGROUND_TEAM_PIT_DAEMONS },
		{ x = 0.691968, y = 0.281260, z = 132.59, alliance = BATTLEGROUND_TEAM_STORM_LORDS },
	},

	[72] = { -- ularra DOM
		{ x = 0.216728, y = 0.496081, z = 176.42, alliance = BATTLEGROUND_TEAM_FIRE_DRAKES },
		{ x = 0.700304, y = 0.213287, z = 176.54, alliance = BATTLEGROUND_TEAM_PIT_DAEMONS },
		{ x = 0.695902, y = 0.773083, z = 176.03, alliance = BATTLEGROUND_TEAM_STORM_LORDS },
	},

	[43] = { -- ularra DM
		{ x = 0.216728, y = 0.496081, z = 176.42, alliance = BATTLEGROUND_TEAM_FIRE_DRAKES },
		{ x = 0.700304, y = 0.213287, z = 176.54, alliance = BATTLEGROUND_TEAM_PIT_DAEMONS },
		{ x = 0.695902, y = 0.773083, z = 176.03, alliance = BATTLEGROUND_TEAM_STORM_LORDS },
	},

	[85] = { -- ularra CTF
		{ x = 0.216728, y = 0.496081, z = 176.42, alliance = BATTLEGROUND_TEAM_FIRE_DRAKES },
		{ x = 0.700304, y = 0.213287, z = 176.54, alliance = BATTLEGROUND_TEAM_PIT_DAEMONS },
		{ x = 0.695902, y = 0.773083, z = 176.03, alliance = BATTLEGROUND_TEAM_STORM_LORDS },
	},
}

PVP.bgTeamBasesFull = {
	ald = { -- ald DOM
		{ x = 0.243979, y = 0.497148, z = 169.91, alliance = BATTLEGROUND_TEAM_FIRE_DRAKES },
		{ x = 0.748098, y = 0.208174, z = 170.03, alliance = BATTLEGROUND_TEAM_PIT_DAEMONS },
		{ x = 0.739860, y = 0.772813, z = 169.90, alliance = BATTLEGROUND_TEAM_STORM_LORDS },
	},

	foya = { -- foyada DON
		{ x = 0.259573, y = 0.572009, z = 132.64, alliance = BATTLEGROUND_TEAM_FIRE_DRAKES },
		{ x = 0.679091, y = 0.756353, z = 133.19, alliance = BATTLEGROUND_TEAM_PIT_DAEMONS },
		{ x = 0.691968, y = 0.281260, z = 132.59, alliance = BATTLEGROUND_TEAM_STORM_LORDS },
	},

	ul = { -- ularra DOM
		{ x = 0.216728, y = 0.496081, z = 176.42, alliance = BATTLEGROUND_TEAM_FIRE_DRAKES },
		{ x = 0.700304, y = 0.213287, z = 176.54, alliance = BATTLEGROUND_TEAM_PIT_DAEMONS },
		{ x = 0.695902, y = 0.773083, z = 176.03, alliance = BATTLEGROUND_TEAM_STORM_LORDS },
	},
}

PVP.auraPinTypes = {
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_NEUTRAL] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_A_NEUTRAL] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_A_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_A_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_A_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_B_NEUTRAL] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_B_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_B_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_B_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_C_NEUTRAL] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_C_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_C_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_C_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_D_NEUTRAL] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_D_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_D_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_D_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_NEUTRAL] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_A_NEUTRAL] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_A_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_A_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_A_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_B_NEUTRAL] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_B_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_B_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_B_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_C_NEUTRAL] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_C_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_C_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_C_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_D_NEUTRAL] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_D_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_D_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_D_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_FLAG_NEUTRAL] = true,
	-- [MAP_PIN_TYPE_BGPIN_FLAG_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_FLAG_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_FLAG_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_FLAG_SPAWN_NEUTRAL] = true,
	-- [MAP_PIN_TYPE_BGPIN_FLAG_SPAWN_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_FLAG_SPAWN_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_FLAG_SPAWN_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_FLAG_RETURN_FIRE_DRAKES] = true,
	-- [MAP_PIN_TYPE_BGPIN_FLAG_RETURN_PIT_DAEMONS] = true,
	-- [MAP_PIN_TYPE_BGPIN_FLAG_RETURN_STORM_LORDS] = true,
	-- [MAP_PIN_TYPE_BGPIN_MURDERBALL_SPAWN_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_MURDERBALL_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_MURDERBALL_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_MURDERBALL_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_MURDERBALL_STORM_LORDS] = true,
	[MAP_PIN_TYPE_AVA_CAPTURE_AREA_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_NEUTRAL_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_FIRE_DRAKES_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_PIT_DAEMONS_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_STORM_LORDS_AURA] = true
}

PVP.bgMapScale = {
	[308] = 0.00118025, -- foyada
	[316] = 0.001175, -- ulara
	[320] = 0.0012625, -- ald carac

}

-- /script for i = 1, GetNumAvAObjectives() do local keepId, objectiveId, battlegroundContext = GetAvAObjectiveKeysByIndex(i) local name = GetKeepName(keepId) if name == 'Arrius Keep' then d(name, GetAvAObjectiveInfo(keepId,  objectiveId, 1),keepId, objectiveId) end end

-- PVP.mapIndexTo3DScale = {
-- [14] = 10000,  -- Cyrodiil 0.179999550
-- [26] = 949.64,  -- Imperial City 1067 ic = 0.0170935(949.64)	 0.00636025 (353.35) (full sewers and base), cyro gates - 0.01096775 (609.3735)
-- }

PVP.borderKeepIdToAreaScale = {
	[110] = 539, -- Northern Highrock Gate
	[109] = 498, -- Southern Highrock Gate
	[105] = 453, -- Western Elsweyr Gate
	[106] = 609, -- Eastern Elsweyr Gate
	[107] = 705, -- Southern Morrowind Gate 0.0126
	[108] = 705, -- Northern Morrowind Gate
}

PVP.borderKeepsIds = {
	[105] = true, -- Western Elsweyr Gate
	[106] = true, -- Eastern Elsweyr Gate
	[107] = true, -- Southern Morrowind Gate
	[108] = true, -- Northern Morrowind Gate
	[109] = true, -- Southern Highrock Gate
	[110] = true, -- Northern Highrock Gate
}

PVP.elderScrollsIds = {
	[118] = 136, -- Elder Scroll of Altadoon
	[119] = 137, -- Elder Scroll of Mnem
	[120] = 138, -- Elder Scroll of Ghartok
	[121] = 139, -- Elder Scroll of Chim
	[122] = 140, -- Elder Scroll of Ni-Mohk
	[123] = 141, -- Elder Scroll of Alma Ruma
}

PVP.elderScrollsPintypes = {
	[MAP_PIN_TYPE_ARTIFACT_ALDMERI_OFFENSIVE] = true, -- Altadoon
	[MAP_PIN_TYPE_ARTIFACT_ALDMERI_DEFENSIVE] = true, -- Mnem
	[MAP_PIN_TYPE_ARTIFACT_EBONHEART_OFFENSIVE] = true, -- Ghartok
	[MAP_PIN_TYPE_ARTIFACT_EBONHEART_DEFENSIVE] = true, -- Chim
	[MAP_PIN_TYPE_ARTIFACT_DAGGERFALL_OFFENSIVE] = true, -- Ni-Mohk
	[MAP_PIN_TYPE_ARTIFACT_DAGGERFALL_DEFENSIVE] = true, -- Alma Ruma
}

-- Complete? List of possible IDs
PVP.daedricArtifactObjectiveIds = {
	439, 440, 441, 442, 443, 444, 445, 446, 447,
	448, 449, 450, 451, 452, 453, 454, 455, 456,
	457, 458, 459, 460, 461, 462
}

-- Confirmed IDs and their corresponding alliance/location
PVP.daedricArtifactSpawnAlliance = {
	[439] = ALLIANCE_ALDMERI_DOMINION, --Eastern Elsweyr Gate
	[446] = ALLIANCE_ALDMERI_DOMINION, -- Beriel's Lament, East of Bloodmayne
	[447] = ALLIANCE_EBONHEART_PACT, -- Northern Morrowind Gate
	[455] = ALLIANCE_DAGGERFALL_COVENANT, --Southern Highrock Gate
	[456] = ALLIANCE_DAGGERFALL_COVENANT, -- Amber Woodland, South of Fort Warden
}

PVP.daedricArtifactPintypes = {
	[MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_NEUTRAL] = true,
	[MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_ALDMERI] = true,
	[MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_EBONHEART] = true,
	[MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_DAGGERFALL] = true,
}

PVP.daedricArtifactAllianceToPinType = {
	[ALLIANCE_NONE] = MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_NEUTRAL,
	[ALLIANCE_ALDMERI_DOMINION] = MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_ALDMERI,
	[ALLIANCE_EBONHEART_PACT] = MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_EBONHEART,
	[ALLIANCE_DAGGERFALL_COVENANT] = MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_DAGGERFALL,
}

PVP.districtKeepIdToSubzoneNumber = {
	[141] = 29, -- Nobles
	[142] = 28, -- Memorial
	[143] = 25, -- Aboretum
	[146] = 26, -- Arena
	[147] = 30, -- Temple
	[148] = 27, -- Elven Gardens
}

PVP.icAllianceBases = {
	[29] = {
		{ x = 0.29688304662704, y = 0.53833013772964, z = 318.37, alliance = ALLIANCE_ALDMERI_DOMINION }, --Nobles AD
		{ x = 0.35189777612686, y = 0.71287500858307, z = 318.37, alliance = ALLIANCE_EBONHEART_PACT }, --Nobles EP
		{ x = 0.27476951479912, y = 0.76019096374512, z = 318.37, alliance = ALLIANCE_DAGGERFALL_COVENANT }, --Nobles DC
	},

	[28] = {
		{ x = 0.56690222024918, y = 0.19403754174709, z = 318.28, alliance = ALLIANCE_ALDMERI_DOMINION }, --Memorial AD
		{ x = 0.40852716565132, y = 0.23505873978138, z = 318.28, alliance = ALLIANCE_EBONHEART_PACT }, --Memorial EP
		{ x = 0.54188704490662, y = 0.29721066355705, z = 318.28, alliance = ALLIANCE_DAGGERFALL_COVENANT }, --Memorial DC
	},

	[25] = {
		{ x = 0.84852808713913, y = 0.60808724164963, z = 321.45, alliance = ALLIANCE_ALDMERI_DOMINION }, --Aboretum AD
		{ x = 0.86488509178162, y = 0.53390741348267, z = 321.45, alliance = ALLIANCE_EBONHEART_PACT }, --Aboretum EP
		{ x = 0.79854446649551, y = 0.71916973590851, z = 321.45, alliance = ALLIANCE_DAGGERFALL_COVENANT }, --Aboretum DC
	},

	[26] = {
		{ x = 0.64620679616928, y = 0.31478446722031, z = 320.59, alliance = ALLIANCE_ALDMERI_DOMINION }, --Arena AD
		{ x = 0.85056394338608, y = 0.45338606834412, z = 320.59, alliance = ALLIANCE_EBONHEART_PACT }, --Arena EP
		{ x = 0.73601818084717, y = 0.47287872433662, z = 320.59, alliance = ALLIANCE_DAGGERFALL_COVENANT }, --Arena DC
	},

	[30] = {
		{ x = 0.63827395439148, y = 0.80923855304718, z = 325.51, alliance = ALLIANCE_ALDMERI_DOMINION }, --Temple AD
		{ x = 0.55000704526901, y = 0.72186082601547, z = 325.51, alliance = ALLIANCE_EBONHEART_PACT }, --Temple EP
		{ x = 0.38119530677795, y = 0.78682076931000, z = 325.51, alliance = ALLIANCE_DAGGERFALL_COVENANT }, --Temple DC
	},

	[27] = {
		{ x = 0.34522861242294, y = 0.36383208632469, z = 319.70, alliance = ALLIANCE_ALDMERI_DOMINION }, --Elven Garden AD
		{ x = 0.30879393219948, y = 0.45453268289566, z = 319.70, alliance = ALLIANCE_EBONHEART_PACT }, --Elven Garden EP
		{ x = 0.31448027491570, y = 0.28834185004234, z = 319.70, alliance = ALLIANCE_DAGGERFALL_COVENANT }, --Elven Garden DC
	},
}

PVP.icDoors = {
	[29] = { --Nobles
		{ x = 0.38386297, y = 0.68715775, z = 314.83, location = 147, type = 2 },
		{ x = 0.32358309, y = 0.79430896, z = 315.03, location = 147, type = 2 },
		{ x = 0.39329341, y = 0.66911590, z = 310.13, location = 147, type = 1 },

		{ x = 0.36172601, y = 0.73922401, z = 309.83, location = 147, type = 1 },
		{ x = 0.31766274, y = 0.80299061, z = 310.13, location = 147, type = 1 },

		{ x = 0.14988066, y = 0.51649737, z = 310.06, location = 148, type = 1 },

		{ x = 0.29189872, y = 0.51506996, z = 314.68, location = 148, type = 2 },

		{ x = 0.30212476, y = 0.51530396, z = 310.14, location = 148, type = 1 },
		{ x = 0.22661112, y = 0.50912624, z = 309.90, location = 148, type = 1 },

		{ x = 0.17063696, y = 0.51584219, z = 314.68, location = 148, type = 2 },
	},

	[28] = { --Memorial
		{ x = 0.33453455, y = 0.21425563, z = 314.61, location = 148, type = 2 },
		{ x = 0.39600786, y = 0.32077503, z = 314.72, location = 148, type = 2 },
		{ x = 0.32944566, y = 0.20536340, z = 309.94, location = 148, type = 1 },

		{ x = 0.40630412, y = 0.33809146, z = 310.10, location = 148, type = 1 },
		{ x = 0.36200684, y = 0.27544811, z = 309.75, location = 148, type = 1 },


		{ x = 0.66211915, y = 0.20643983, z = 309.67, location = 146, type = 1 },
		{ x = 0.65205693, y = 0.22445827, z = 314.61, location = 146, type = 2 },

		{ x = 0.62870311, y = 0.27575233, z = 309.94, location = 146, type = 1 },
		{ x = 0.58550566, y = 0.33806803, z = 309.85, location = 146, type = 1 },

		{ x = 0.59079420, y = 0.32938644, z = 314.25, location = 146, type = 2 },
	},

	[25] = { --Aboretum
		{ x = 0.69019985, y = 0.51663780, z = 310.49, location = 146, type = 1, angle = ZO_PI * 21 / 64 },
		{ x = 0.76671969, y = 0.50919640, z = 309.84, location = 146, type = 1, angle = ZO_PI * 21 / 64 },
		{ x = 0.67379605, y = 0.79480004, z = 312.68, location = 147, type = 1, angle = ZO_PI * 21 / 64 },
		{ x = 0.63417887, y = 0.74053448, z = 309.90, location = 147, type = 1, angle = ZO_PI * 21 / 64 },

		{ x = 0.60658961, y = 0.68100339, z = 315.26, location = 147, type = 2, angle = ZO_PI * 21 / 64 },

		{ x = 0.82346612, y = 0.51460194, z = 314.95, location = 146, type = 2, angle = ZO_PI * 21 / 64 },

		{ x = 0.83359855, y = 0.51516354, z = 313.88, location = 146, type = 1, angle = ZO_PI * 21 / 64 },
		{ x = 0.71062856, y = 0.51574856, z = 315.30, location = 146, type = 2, angle = ZO_PI * 21 / 64 },

		{ x = 0.66258716, y = 0.77708613, z = 316.10, location = 147, type = 2, angle = ZO_PI * 21 / 64 },
		{ x = 0.60169887, y = 0.67204099, z = 310.70, location = 147, type = 1, angle = ZO_PI * 21 / 64 },
	},

	[26] = { --Arena
		{ x = 0.66193193, y = 0.23807740, z = 314.88, location = 142, type = 2, angle = ZO_PI * 21 / 64 },
		{ x = 0.61115270, y = 0.32650816, z = 314.76, location = 142, type = 2, angle = ZO_PI * 21 / 64 },
		{ x = 0.66700989, y = 0.22909158, z = 311.96, location = 142, type = 1, angle = ZO_PI * 21 / 64 },
		{ x = 0.60132449, y = 0.34431600, z = 310.26, location = 142, type = 1, angle = ZO_PI * 21 / 64 },
		{ x = 0.63352364, y = 0.27460569, z = 309.83, location = 142, type = 1, angle = ZO_PI * 21 / 64 },

		{ x = 0.84412878, y = 0.49836194, z = 310.25, location = 143, type = 1, angle = ZO_PI * 21 / 64 },

		{ x = 0.70218092, y = 0.49913418, z = 314.69, location = 143, type = 2, angle = ZO_PI * 21 / 64 },

		{ x = 0.69181448, y = 0.49899378, z = 310.25, location = 143, type = 1, angle = ZO_PI * 21 / 64 },

		{ x = 0.76723450, y = 0.50507789, z = 309.90, location = 143, type = 1, angle = ZO_PI * 21 / 64 },



		{ x = 0.82381707, y = 0.49857255, z = 314.77, location = 143, type = 2, angle = ZO_PI * 21 / 64 },
	},

	[30] = { --Temple
		{ x = 0.66474002, y = 0.79341977, z = 314.59, location = 143, type = 2 },
		{ x = 0.58779895, y = 0.67286002, z = 310.16, location = 143, type = 1 },
		{ x = 0.63481068, y = 0.73358452, z = 309.82, location = 143, type = 1 },

		{ x = 0.33781063, y = 0.81576728, z = 310.19, location = 141, type = 1 },

		{ x = 0.36788037, y = 0.74476999, z = 309.90, location = 141, type = 1 },
		{ x = 0.40873777, y = 0.68088638, z = 310.17, location = 141, type = 1 },
		{ x = 0.40380024, y = 0.69001263, z = 314.77, location = 141, type = 2 },

		{ x = 0.66894134, y = 0.80268639, z = 310.16, location = 143, type = 1 },

		{ x = 0.59921842, y = 0.68984884, z = 314.73, location = 143, type = 2 },

		{ x = 0.34733468, y = 0.79756164, z = 314.75, location = 141, type = 2 },
	},

	[27] = { --Elven
		{ x = 0.16043432, y = 0.50109982, z = 314.46, location = 141, type = 2 },
		{ x = 0.28338092, y = 0.50124025, z = 314.75, location = 141, type = 2 },
		{ x = 0.15018486, y = 0.50058501, z = 310.48, location = 141, type = 1 },
		{ x = 0.22719614, y = 0.50737118, z = 309.84, location = 141, type = 1 },
		{ x = 0.30362239, y = 0.50107640, z = 310.29, location = 141, type = 1 },

		{ x = 0.31756913, y = 0.21350680, z = 310.01, location = 142, type = 1 },
		{ x = 0.32838022, y = 0.23138484, z = 314.51, location = 142, type = 2 },

		{ x = 0.36149200, y = 0.27692234, z = 309.91, location = 142, type = 1 },
		{ x = 0.39308279, y = 0.34583702, z = 309.92, location = 142, type = 1 },

		{ x = 0.38828566, y = 0.33673420, z = 314.75, location = 142, type = 2 },
	},
}

PVP.icVaults = {
	[29] = { --Nobles
		{ x = 0.20545701, y = 0.72253942, z = 310.69, poiId = 32 },
	},

	[28] = { --Memorial
		{ x = 0.52651286, y = 0.14985725, z = 309.27, poiId = 34 },
	},

	[25] = { --Aboretum
		{ x = 0.71273458, y = 0.79288154, z = 312.84, poiId = 36 },
	},

	[26] = { --Arena
		{ x = 0.81127440, y = 0.32491692, z = 307.55, poiId = 35 },
	},

	[30] = { --Temple
		{ x = 0.63317263, y = 0.83774042, z = 309.29, poiId = 37 },
	},

	[27] = { --Elven
		{ x = 0.27381008, y = 0.23014461, z = 309.55, poiId = 33 },
	},
}

PVP.icGrates = {
	[29] = { --Nobles
		{ x = 0.15615200, y = 0.63319605, z = 310.28, name = "To Lambent Passage" },
	},

	[28] = { --Memorial
		{ x = 0.60446012, y = 0.16380399, z = 308.11, name = "To Harena Hypogeum" },
	},

	[25] = { --Aboretum
		{ x = 0.85278901, y = 0.57275235, z = 312.90, name = "To Irrigation Tunnels" },
	},

	[26] = { --Arena
		{ x = 0.79515141, y = 0.30315440, z = 308.03, name = "To Harena Hypogeum" },
	},

	[30] = { --Temple
		{ x = 0.46733281, y = 0.86603170, z = 308.06, name = "To Irrigation Tunnels" },
	},

	[27] = { --Elven
		{ x = 0.13612112, y = 0.47999250, z = 309.19, name = "To Lambent Passage" },
	},
}

PVP.delvesCoords = {

	{ x = 0.67226, y = 0.59793, z = 208.98, name = 'Cracked Wood Cave' },
	{ x = 0.72170, y = 0.69504, z = 111.33, name = 'Newt Cave' },
	{ x = 0.53730, y = 0.81005, z = 115.28, name = 'Bloodmane Cave' },
	{ x = 0.45461, y = 0.72516, z = 189.43, name = 'Pothole Caverns' },
	{ x = 0.36197, y = 0.69811, z = 257.57, name = 'Nisin Cave' },
	{ x = 0.31646, y = 0.56291, z = 223.56, name = 'Haynote Cave' },
	{ x = 0.28873, y = 0.48721, z = 262.09, name = 'Breakneck Cave' },
	{ x = 0.20635, y = 0.50749, z = 258.06, name = 'Serpent Hollow Cave' },
	{ x = 0.15506, y = 0.24113, z = 450.72, name = 'Lipsand Tarn' },
	{ x = 0.36090, y = 0.22184, z = 336.45, name = 'Underpall Cave' },
	{ x = 0.35449, y = 0.14113, z = 402.34, name = 'Echo Cave' },
	{ x = 0.42162, y = 0.15316, z = 359.58, name = 'Capstone Cave' },
	{ x = 0.50270, y = 0.21536, z = 319.53, name = 'Toadstool Hollow' },
	{ x = 0.58314, y = 0.19519, z = 359.30, name = 'Red Ruby Cave' },
	{ x = 0.75884, y = 0.34677, z = 309.13, name = 'Quickwater Cave' },
	{ x = 0.80618, y = 0.25049, z = 389.05, name = 'Kingscrest Cavern' },
	{ x = 0.71032, y = 0.49034, z = 206.61, name = 'Muck Valley Cavern' },
	{ x = 0.80716, y = 0.46103, z = 258.69, name = 'Vahtacen' },
}

PVP.miscCoords = {
	{ -- Niben River Bridge
		x = 0.61220,
		y = 0.64072,
		z = 132.91,
		name = 'Niben River Bridge',
		pinType = PVP_PINTYPE_BRIDGE,
		alliance = ALLIANCE_NONE,
		keepId = 156
	},
	{ -- Kingscrest Milegate
		x = 0.66992,
		y = 0.13765,
		z = 385.14,
		name = 'Kingscrest Milegate',
		pinType = PVP_PINTYPE_MILEGATE,
		alliance = ALLIANCE_NONE,
		keepId = 160
	},
	{ -- Bay Bridge
		x = 0.66469,
		y = 0.71974,
		z = 121.52,
		name = 'Bay Bridge',
		pinType = PVP_PINTYPE_BRIDGE,
		alliance = ALLIANCE_NONE,
		keepId = 157
	},
	{ -- Chorrol Milegate
		x = 0.16387,
		y = 0.41751,
		z = 257.76,
		name = 'Chorrol Milegate',
		pinType = PVP_PINTYPE_MILEGATE,
		alliance = ALLIANCE_NONE,
		keepId = 159
	},
	{ -- Horunn Milegate
		x = 0.61824,
		y = 0.21514,
		z = 321.10,
		name = 'Horunn Milegate',
		pinType = PVP_PINTYPE_MILEGATE,
		alliance = ALLIANCE_NONE,
		keepId = 161
	},
	{ -- Priory Milegate
		x = 0.24247,
		y = 0.41867,
		z = 241.42,
		name = 'Priory Milegate',
		pinType = PVP_PINTYPE_MILEGATE,
		alliance = ALLIANCE_NONE,
		keepId = 158
	},
	{ -- Chalman Milegate
		x = 0.54010,
		y = 0.29418,
		z = 254.83,
		name = 'Chalman Milegate',
		pinType = PVP_PINTYPE_MILEGATE,
		alliance = 9,
		keepId = 162
	},
	{ -- Ash Milegate
		x = 0.35996,
		y = 0.46201,
		z = 248.67,
		name = 'Ash Milegate',
		pinType = PVP_PINTYPE_MILEGATE,
		alliance = 6,
		keepId = 155
	},
	{ -- Alessia Bridge
		x = 0.58858,
		y = 0.53298,
		z = 141.97,
		name = 'Alessia Bridge',
		pinType = PVP_PINTYPE_BRIDGE,
		alliance = 15,
		keepId = 154
	},
	{ -- Cheydinhal
		x = 0.78137,
		y = 0.38986,
		z = 312.47, 
		name = 'Cheydinhal',
		pinType = 'town'
	},
}

PVP.icCoords = {
	x = 0.496,
	y = 0.429,
	z = 800,
	name = 'Crown',
}

PVP.ayleidWellsCoords = {

	{ x = 0.36087, y = 0.36112, z = 154.49 },
	{ x = 0.46138, y = 0.23957, z = 262.23 },
	{ x = 0.43849, y = 0.21113, z = 313.75 },
	{ x = 0.18537, y = 0.40744, z = 272.57 },
	{ x = 0.38327, y = 0.53015, z = 248.24 },
	{ x = 0.26134, y = 0.67056, z = 294.75 },
	{ x = 0.33254, y = 0.72857, z = 237.63 },
	{ x = 0.39217, y = 0.69155, z = 222.15 },
	{ x = 0.46606, y = 0.76441, z = 163.39 },
	{ x = 0.50522, y = 0.76108, z = 202.23 },
	{ x = 0.62154, y = 0.79278, z = 128.56 },
	{ x = 0.62518, y = 0.50758, z = 201.05 },
	{ x = 0.62801, y = 0.44472, z = 195.16 },
	{ x = 0.70646, y = 0.58114, z = 233.89 },
	{ x = 0.63834, y = 0.65077, z = 123.80 },
	{ x = 0.65840, y = 0.69458, z = 136.87 },

}

-- Original array where on an AD character
-- An AD vs. DC fight erroneously said EP vs. DC
-- and an AD vs. EP fight erroneously AD vs. DC
PVP.killLocationPintypeToName = {
	[MAP_PIN_TYPE_TRI_BATTLE_SMALL] = "|cEFD13C3-|r|c80AFFFway|r |cFF7161fight!|r",
	[MAP_PIN_TYPE_TRI_BATTLE_MEDIUM] = "|cEFD13C3-|r|c80AFFFway|r |cFF7161fight!|r",
	[MAP_PIN_TYPE_TRI_BATTLE_LARGE] = "|cEFD13C3-|r|c80AFFFway|r |cFF7161fight!|r",

	[MAP_PIN_TYPE_ALDMERI_VS_EBONHEART_SMALL] = "|cEFD13CAD|r vs |cFF7161EP|r fight!",
	[MAP_PIN_TYPE_ALDMERI_VS_EBONHEART_MEDIUM] = "|cEFD13CAD|r vs |cFF7161EP|r fight!",
	[MAP_PIN_TYPE_ALDMERI_VS_EBONHEART_LARGE] = "|cEFD13CAD|r vs |cFF7161EP|r fight!",

	[MAP_PIN_TYPE_ALDMERI_VS_DAGGERFALL_SMALL] = "|cEFD13CAD|r vs |c80AFFFDC|r fight!",
	[MAP_PIN_TYPE_ALDMERI_VS_DAGGERFALL_MEDIUM] = "|cEFD13CAD|r vs |c80AFFFDC|r fight!",
	[MAP_PIN_TYPE_ALDMERI_VS_DAGGERFALL_LARGE] = "|cEFD13CAD|r vs |c80AFFFDC|r fight!",

	[MAP_PIN_TYPE_EBONHEART_VS_DAGGERFALL_SMALL] = "|cFF7161EP|r vs |c80AFFFDC|r fight!",
	[MAP_PIN_TYPE_EBONHEART_VS_DAGGERFALL_MEDIUM] = "|cFF7161EP|r vs |c80AFFFDC|r fight!",
	[MAP_PIN_TYPE_EBONHEART_VS_DAGGERFALL_LARGE] = "|cFF7161EP|r vs |c80AFFFDC|r fight!",
}

PVP.pingsColors = {
	{ 255, 82,  72 },
	{ 217, 88,  0 },
	{ 1,   188, 106 },
	{ 2,   129, 204 },
	{ 0,   159, 140 },
	{ 255, 149, 157 },
	{ 1,   213, 243 },

	{ 137, 59,  33 },
	{ 1,   115, 236 },
	{ 117, 221, 81 },
	{ 164, 33,  171 },

	{ 221, 99,  232 },
	{ 132, 163, 0 },
	{ 250, 133, 255 },
	{ 172, 144, 0 },

	{ 255, 159, 26 },



	{ 255, 61,  169 },
	{ 121, 70,  21 },
	{ 210, 188, 251 },

	{ 112, 62,  136 },
	{ 219, 149, 137 },
	{ 164, 16,  57 },

	{ 140, 49,  94 },
	{ 130, 70,  59 },
}

PVP.midpointKeepIds = {
	[3] = true, -- Warden
	[4] = true, -- Rayles
	[5] = true, -- Glademist

	[10] = true, -- Arrius
	[11] = true, -- Kingscrest
	[12] = true, -- Farragut

	[16] = true, -- Faregyl
	[19] = true, -- Black Boot
	[20] = true, -- Bloodmayne
}

PVP.sewers = {
	-- {x = 0.84993708, y = 0.71968555, z = 128.99, name = 'To Cyro'}, -- AD base to cyro
	-- {x = 0.84987419, y = 0.71968555, z = 129.08, name = 'To Sewers', angle = 6.247179}, -- AD base to sewers
	{
		x = 0.84987419843674,
		y = 0.71955972909927,
		z = 129.0823059082,
		name = 'To Sewers',
		x3d = -1.1537978649139,
		y3d = -14.28395652771
	}, -- AD base to sewers
}

PVP.objectiveIcons = {
	[KEEPTYPE_KEEP] = "/esoui/art/compass/ava_largekeep_neutral.dds",
	[KEEPTYPE_OUTPOST] = "/esoui/art/compass/ava_outpost_neutral.dds",
	[KEEPTYPE_TOWN] = "/esoui/art/compass/ava_town_neutral.dds",
	[KEEPTYPE_IMPERIAL_CITY_DISTRICT] = "/esoui/art/compass/ava_imperialdistrict_neutral.dds",

	[RESOURCETYPE_FOOD] = "/esoui/art/compass/ava_farm_neutral.dds",
	[RESOURCETYPE_ORE] = "/esoui/art/compass/ava_mine_neutral.dds",
	[RESOURCETYPE_WOOD] = "/esoui/art/compass/ava_lumbermill_neutral.dds",

	[KEEPTYPE_ARTIFACT_GATE] = {
		[MAP_PIN_TYPE_ARTIFACT_GATE_CLOSED_ALDMERI_DOMINION] = "/esoui/art/compass/ava_artifactgate_aldmeri_closed.dds",
		[MAP_PIN_TYPE_ARTIFACT_GATE_CLOSED_DAGGERFALL_COVENANT] = "/esoui/art/compass/ava_artifactgate_daggerfall_closed.dds",
		[MAP_PIN_TYPE_ARTIFACT_GATE_CLOSED_EBONHEART_PACT] = "/esoui/art/compass/ava_artifactgate_ebonheart_closed.dds",
		[MAP_PIN_TYPE_ARTIFACT_GATE_OPEN_ALDMERI_DOMINION] = "/esoui/art/compass/ava_artifactgate_aldmeri_open.dds",
		[MAP_PIN_TYPE_ARTIFACT_GATE_OPEN_DAGGERFALL_COVENANT] = "/esoui/art/compass/ava_artifactgate_daggerfall_open.dds",
		[MAP_PIN_TYPE_ARTIFACT_GATE_OPEN_EBONHEART_PACT] = "/esoui/art/compass/ava_artifactgate_ebonheart_open.dds",
	},

	[PVP_KEEPTYPE_ARTIFACT_KEEP] = {
		[ALLIANCE_ALDMERI_DOMINION] = "/esoui/art/compass/ava_artifacttemple_aldmeri.dds",
		[ALLIANCE_DAGGERFALL_COVENANT] = "/esoui/art/compass/ava_artifacttemple_daggerfall.dds",
		[ALLIANCE_EBONHEART_PACT] = "/esoui/art/compass/ava_artifacttemple_ebonheart.dds",
	},

	[PVP_KEEPTYPE_BORDER_KEEP] = {
		[ALLIANCE_ALDMERI_DOMINION] = "/esoui/art/compass/ava_borderkeep_pin_aldmeri.dds",
		[ALLIANCE_DAGGERFALL_COVENANT] = "/esoui/art/compass/ava_borderkeep_pin_daggerfall.dds",
		[ALLIANCE_EBONHEART_PACT] = "/esoui/art/compass/ava_borderkeep_pin_ebonheart.dds",
	},

	-- [PVP_KEEPTYPE_BORDER_KEEP] =		{
	-- [ALLIANCE_ALDMERI_DOMINION]	=	"esoui/art/guild/banner_aldmeri.dds",
	-- [ALLIANCE_DAGGERFALL_COVENANT]	=	"esoui/art/guild/banner_daggerfall.dds",
	-- [ALLIANCE_EBONHEART_PACT]		=	"esoui/art/guild/banner_ebonheart.dds",
	-- },

	[FLAGTYPE_OTHER] = "/esoui/art/compass/ava_flagneutral.dds",
	[FLAGTYPE_NAVE] = "/esoui/art/compass/ava_flagcarrier_neutral.dds",
	[FLAGTYPE_APSE] = "/esoui/art/compass/ava_flagbase_neutral.dds",

	[PVP_ALLIANCE_BASE_IC] = {
		[ALLIANCE_ALDMERI_DOMINION] = "/esoui/art/campaign/overview_allianceicon_aldmeri.dds",
		[ALLIANCE_DAGGERFALL_COVENANT] = "/esoui/art/campaign/overview_allianceicon_daggefall.dds",
		[ALLIANCE_EBONHEART_PACT] = "/esoui/art/campaign/overview_allianceicon_ebonheart.dds",
	},
}

PVP.MapStepSize = 1.4285034012573e-005
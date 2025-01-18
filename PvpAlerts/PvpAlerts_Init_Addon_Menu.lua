local PVP = PVP_Alerts_Main_Table

local LAM2 = LibAddonMenu2

function PVP:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Miat's Pvp Alerts",
		displayName = "Miat's Pvp Alerts",
		author = "Dorrino",
		version = self.textVersion,
		slashCommand = "/pvpmenu",
		registerForRefresh = true,
		registerForDefaults = false,
		resetFunc = function()
			self.SV.offsetX = 0
			self.SV.offsetY = 0
			self.SV.counterOffsetX = 0
			self.SV.counterOffsetY = 0
			self.SV.tugOffsetX = 0
			self.SV.tugOffsetY = 0
			self.SV.feedOffsetX = 0
			self.SV.feedOffsetY = 0
			self.SV.userDisplayNameType = self.defaults.userDisplayNameType
			self.SV.killFeedNameType = self.defaults.killFeedNameType
			self.SV.showPlayerNotes = self.defaults.showPlayerNotes
			self.SV.showFriends = self.defaults.showFriends
			self.SV.showGuildMates = self.defaults.showGuildMates
			self.SV.namesOffsetX = 0
			self.SV.namesOffsetY = 0
			self.SV.KOSOffsetX = 0
			self.SV.KOSOffsetY = 0
			self.SV.captureOffsetX = 0
			self.SV.captureOffsetY = 0
			self.SV.targetNameX = 0
			self.SV.targetNameY = 0
			self.SV.newAttackerOffsetX = 0
			self.SV.newAttackerOffsetY = 0
			self.SV.medalsOffsetX = 0
			self.SV.medalsOffsetY = 0


			self:FullReset()
			self:InitControls()
		end
	}

	local optionsPanel = LAM2:RegisterAddonPanel("Pvp_Alerts", panelData)

	SLASH_COMMANDS["/pvpa"] = SLASH_COMMANDS["/pvpmenu"]

	local this = self
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
		if panel == optionsPanel then
			this.noInitControls = true
			this.delayedInitControls = false
		end
	end)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
		if panel == optionsPanel then
			this.noInitControls = false
			if this.delayedInitControls then
				PVP:InitControls()
			end
		end
	end)

	local optionsData = {
		{
			type = "header",
			name = "Frames positions LOCK/UNLOCK",
		},
		{
			type = "checkbox",
			name = "Turn OFF when satisfied with frame position",
			tooltip =
			"ON - frame can me moved on the screen by left clicking and dragging, OFF - frame is locked in place and can not be moved",
			default = self.defaults.unlocked,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.unlocked end,
			setFunc = function(newValue)
				self.SV.unlocked = newValue
				self:InitControls()
			end,
		},
		{
			type = "header",
			name = "Addon main features",
		},
		{
			type = "checkbox",
			name = "ADDON ENABLED",
			tooltip = "ON - enabled, OFF - disabled",
			default = self.defaults.enabled,
			getFunc = function() return self.SV.enabled end,
			setFunc = function(newValue)
				self.SV.enabled = newValue
				self:InitControls()
				self:OnOff()
			end,
		},
		{
			type = "checkbox",
			name = "Enable attacks notifications",
			tooltip = "ON - notify on incoming attacks, OFF - do not notify on incoming attacks",
			default = self.defaults.showAttacks,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showAttacks end,
			setFunc = function(newValue)
				self.SV.showAttacks = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Enable players counter feature",
			tooltip = "ON - enables the counter, OFF - disables the counter",
			default = self.defaults.showCounterFrame,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showCounterFrame end,
			setFunc = function(newValue)
				self.SV.showCounterFrame = newValue
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Enable players counter tug bar",
			tooltip = "ON - enables the tug bar, OFF - disables the tug bar",
			default = self.defaults.showTug,
			disabled = function() return not self.SV.enabled or not self.SV.showCounterFrame end,
			getFunc = function() return self.SV.showTug end,
			setFunc = function(newValue)
				self.SV.showTug = newValue
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Enable Kill Feed feature",
			tooltip = "ON - enables Kill Feed, OFF - hides Kill Feed",
			default = self.defaults.showKillFeedFrame,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showKillFeedFrame end,
			setFunc = function(newValue)
				self.SV.showKillFeedFrame = newValue
				if not newValue then self:KillFeedRatio_Reset() end
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Enable Attackers Names Frame",
			tooltip = "ON - enables Attackers Names Frame, OFF - disables Attackers Names Frame",
			default = self.defaults.showNamesFrame,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showNamesFrame end,
			setFunc = function(newValue)
				self.SV.showNamesFrame = newValue
				if not newValue then
					self.namesToDisplay = {}
					PVP_Names_Text:Clear()
				end
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Enable New Attacker Notification",
			tooltip = "ON - enables New Attacker Notification, OFF - disables New Attacker Notification",
			default = self.defaults.showNewAttackerFrame,
			-- disabled = function() return not self.SV.enabled or not self.SV.showNamesFrame end,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showNewAttackerFrame end,
			setFunc = function(newValue)
				self.SV.showNewAttackerFrame = newValue
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Enable KOS/COOL system",
			tooltip =
			"ON - enables the full system (window, ability to add/remove KOS/COOL players, sounds), OFF - disables the KOS/COOL system",
			default = self.defaults.showKOSFrame,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showKOSFrame end,
			setFunc = function(newValue)
				self.SV.showKOSFrame = newValue
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Enable Forward Camp and pvp buffs tracker",
			tooltip = "ON - enables Forward Camp Frame, OFF - disables Forward Camp Frame",
			default = self.defaults.showCampFrame,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showCampFrame end,
			setFunc = function(newValue)
				self.SV.showCampFrame = newValue
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Enable Objective Capture Frame",
			tooltip = "ON - enables Objective Capture Frame, OFF - disables Objective Capture Frame",
			default = self.defaults.showCaptureFrame,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showCaptureFrame end,
			setFunc = function(newValue)
				self.SV.showCaptureFrame = newValue
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Enable Target Name Frame",
			tooltip = "ON - enables Target Name Frame, OFF - disables Target Name Frame",
			default = self.defaults.showTargetNameFrame,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showTargetNameFrame end,
			setFunc = function(newValue)
				self.SV.showTargetNameFrame = newValue
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Enable Target Icon",
			tooltip = "ON - enables Target Type Icon at the crosshair, OFF - disables Target Type Icon",
			default = self.defaults.showTargetIcon,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showTargetIcon end,
			setFunc = function(newValue)
				self.SV.showTargetIcon = newValue
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Enable 3D icons system",
			tooltip = "ON - enables 3D icons system, OFF - disables 3D icons system",
			default = self.defaults.show3DIcons,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.show3DIcons end,
			setFunc = function(newValue)
				self.SV.show3DIcons = newValue
				self:FullReset3DIcons()
				self:InitControls()
			end
		},
		{
			type = "dropdown",
			name = "User Display Name Type Preference:",
			tooltip = 'Default is "Character"',
			default = self.defaults.userDisplayNameType,
			choices = { "Character@User", "Character", "@User" },
			getFunc = function()
				if self.SV.userDisplayNameType == "both" then
					return "Character@User"
				elseif self.SV.userDisplayNameType == "character" then
					return "Character"
				elseif self.SV.userDisplayNameType == "user" then
					return "@User"
				end
			end,
			setFunc = function(newValue)
				if newValue == "Character@User" then
					self.SV.userDisplayNameType = "both"
				elseif newValue == "Character" then
					self.SV.userDisplayNameType = "character"
				elseif newValue == "@User" then
					self.SV.userDisplayNameType = "user"
				end
			end,
		},
		{
			type = "header",
			name = "Attacks notification options",
		},
		{
			type = "slider",
			name = "Set attacks icon and text scale (%)",
			tooltip = "Icon and text scale goes from 50% to 150% of original scale",
			default = tonumber(string.format("%.0f", 100 * self.defaults.controlScale)),
			disabled = function() return not self.SV.enabled or not self.SV.showAttacks end,
			min = 50,
			max = 150,
			step = 1,
			getFunc = function() return tonumber(string.format("%.0f", 100 * self.SV.controlScale)) end,
			setFunc = function(newValue)
				self.SV.controlScale = newValue / 100
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Show important projectiles notification",
			tooltip = "ON - notify about important projectiles, OFF - do not notify about important projectiles",
			default = self.defaults.showImportant,
			disabled = function() return not self.SV.enabled or not self.SV.showAttacks end,
			getFunc = function() return self.SV.showImportant end,
			setFunc = function(newValue)
				self.SV.showImportant = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Show channaled abilities notification",
			tooltip =
			"ON - notify about hard-hitting channeled abilities, OFF - do not notify about hard-hitting channeled abilities",
			default = self.defaults.showSnipes,
			disabled = function() return not self.SV.enabled or not self.SV.showAttacks end,
			getFunc = function() return self.SV.showSnipes end,
			setFunc = function(newValue)
				self.SV.showSnipes = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Show heavy attacks notification",
			tooltip = "ON - notify about heavy attacks, OFF - do not notify about heavy attacks",
			default = self.defaults.showHeavyAttacks,
			disabled = function() return not self.SV.enabled or not self.SV.showAttacks end,
			getFunc = function() return self.SV.showHeavyAttacks end,
			setFunc = function(newValue)
				self.SV.showHeavyAttacks = newValue
				self:InitControls()
			end,
		},
		{
			type = "header",
			name = "Kill Feed options",
		},
		{
			type = "slider",
			name = "Set Kill Feed scale (%)",
			tooltip = "Kill Feed scale scale goes from 50% to 150% of original scale",
			default = tonumber(string.format("%.0f", 100 * self.defaults.feedControlScale)),
			disabled = function() return not self.SV.enabled or not self.SV.showKillFeedFrame end,
			min = 50,
			max = 150,
			step = 1,
			getFunc = function() return tonumber(string.format("%.0f", 100 * self.SV.feedControlScale)) end,
			setFunc = function(newValue)
				self.SV.feedControlScale = newValue / 100
				self:InitControls()
			end,
		},
		{
			type = "dropdown",
			name = "Choose Kill Feed Text Alignment:",
			tooltip = 'Default is "Center"',
			choices = { "Center", "Left", "Right" },
			getFunc = function()
				if self.SV.feedTextAlign == TEXT_ALIGN_CENTER then
					return "Center"
				elseif self.SV.feedTextAlign == TEXT_ALIGN_LEFT then
					return "Left"
				elseif self.SV.feedTextAlign == TEXT_ALIGN_RIGHT then
					return "Right"
				end
			end,
			setFunc = function(newValue)
				if newValue == "Center" then
					self.SV.feedTextAlign = TEXT_ALIGN_CENTER
				elseif newValue == "Left" then
					self.SV.feedTextAlign = TEXT_ALIGN_LEFT
				elseif newValue == "Right" then
					self.SV.feedTextAlign = TEXT_ALIGN_RIGHT
				end
				self:InitControls()
			end,
			default = "Center",
			disabled = function() return not self.SV.enabled or not self.SV.showKillFeedFrame end,
		},
		{
			type = "dropdown",
			name = "Kill Feed Name Type Preference:",
			tooltip = 'Default (Link) uses the value of "User Display Name Type Preference"',
			default = self.defaults.killFeedNameType,
			choices = { "Link", "Character@User", "Character", "@User" },
			getFunc = function()
				if self.SV.killFeedNameType == "link" then
					return "Link"
				elseif self.SV.killFeedNameType == "both" then
					return "Character@User"
				elseif self.SV.killFeedNameType == "character" then
					return "Character"
				elseif self.SV.killFeedNameType == "user" then
					return "@User"
				end
			end,
			setFunc = function(newValue)
				if newValue == "Link" then
					self.SV.killFeedNameType = "link"
				elseif newValue == "Character@User" then
					self.SV.killFeedNameType = "both"
				elseif newValue == "Character" then
					self.SV.killFeedNameType = "character"
				elseif newValue == "@User" then
					self.SV.killFeedNameType = "user"
				end
			end,
		},
		{
			type = "checkbox",
			name = "Enable Kill Feed chat tab",
			tooltip = "ON - enables kill feed chat tab, OFF - removes kill feed chat tab",
			default = self.defaults.showKillFeedChat,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showKillFeedChat end,
			setFunc = function(newValue)
				self.SV.showKillFeedChat = newValue
				if newValue then
					self:InitializeChat()
				else
					local _, _, windowIndex = PVP:GetKillFeed()
					CHAT_SYSTEM.primaryContainer:RemoveWindow(windowIndex)
				end
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Show Kill Feed in general chat tab",
			tooltip = "ON - enables kill feed in general chat tab, OFF - disables kill feed in general chat tab",
			default = self.defaults.showKillFeedInMainChat,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showKillFeedInMainChat end,
			setFunc = function(newValue)
				self.SV.showKillFeedInMainChat = newValue
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Show Kill Feed only for killing blows",
			tooltip = "ON - shows only own killing blows, OFF - shows all kills",
			default = self.defaults.showOnlyOwnKillingBlows,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showOnlyOwnKillingBlows end,
			setFunc = function(newValue)
				self.SV.showOnlyOwnKillingBlows = newValue
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Play AP ticks sound",
			tooltip = "ON - play sound, OFF - do not play sound",
			default = self.defaults.playBattleReportSound,
			disabled = function() return not self.SV.enabled or not self.SV.showKillFeedFrame end,
			getFunc = function() return self.SV.playBattleReportSound end,
			setFunc = function(newValue)
				self.SV.playBattleReportSound = newValue
				self:InitControls()
			end,
		},
		{
			type = "header",
			name = "Attackers Names Frame options",
		},

		{
			type = "slider",
			name = "Set Attackers Names Frame scale (%)",
			tooltip = "Attackers Names Frame scale goes from 50% to 150% of original scale",
			default = tonumber(string.format("%.0f", 100 * self.defaults.namesControlScale)),
			disabled = function() return not self.SV.enabled or not self.SV.showNamesFrame end,
			min = 50,
			max = 150,
			step = 1,
			getFunc = function() return tonumber(string.format("%.0f", 100 * self.SV.namesControlScale)) end,
			setFunc = function(newValue)
				self.SV.namesControlScale = newValue / 100
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Play new attacker sound",
			tooltip = "ON - play sound, OFF - do not play sound",
			default = self.defaults.playNewAttackerSound,
			disabled = function() return not self.SV.enabled or not self.SV.showNamesFrame end,
			getFunc = function() return self.SV.playNewAttackerSound end,
			setFunc = function(newValue)
				self.SV.playNewAttackerSound = newValue
				self:InitControls()
			end,
		},
		{
			type = "slider",
			name = "Set New Attacker Frame scale (%)",
			tooltip = "New Attacker Frame scale goes from 50% to 150% of original scale",
			default = tonumber(string.format("%.0f", 100 * self.defaults.newAttackerFrameScale)),
			-- disabled = function() return not self.SV.enabled or not self.SV.showNamesFrame or not self.SV.showNewAttackerFrame end,
			disabled = function() return not self.SV.enabled or not self.SV.showNewAttackerFrame end,
			min = 50,
			max = 150,
			step = 1,
			getFunc = function() return tonumber(string.format("%.0f", 100 * self.SV.newAttackerFrameScale)) end,
			setFunc = function(newValue)
				self.SV.newAttackerFrameScale = newValue / 100
				self:InitControls()
			end,
		},
		{
			type = "slider",
			name = "Set New Attacker Frame Alpha (%)",
			tooltip = "New Attacker Frame alpha goes from 1% to 100%",
			default = tonumber(string.format("%.0f", 100 * self.defaults.newAttackerFrameAlpha)),
			-- disabled = function() return not self.SV.enabled or not self.SV.showNamesFrame or not self.SV.showNewAttackerFrame end,
			disabled = function() return not self.SV.enabled or not self.SV.showNewAttackerFrame end,
			min = 1,
			max = 100,
			step = 1,
			getFunc = function() return tonumber(string.format("%.0f", 100 * self.SV.newAttackerFrameAlpha)) end,
			setFunc = function(newValue)
				self.SV.newAttackerFrameAlpha = newValue / 100
				self:InitControls()
			end,
		},
		{
			type = "slider",
			name = "Set New Attacker Frame delay before fadeout (ms)",
			tooltip = "New Attacker Frame fadeout time goes from 0 to 2000ms (2 sec). Default value is 1500ms.",
			default = self.defaults.newAttackerFrameDelayBeforeFadeout,
			disabled = function() return not self.SV.enabled or not self.SV.showTargetNameFrame end,
			min = 0,
			max = 2000,
			step = 1,
			getFunc = function() return self.SV.newAttackerFrameDelayBeforeFadeout end,
			setFunc = function(newValue)
				self.SV.newAttackerFrameDelayBeforeFadeout = newValue
				self:InitControls()
			end,
		},
		{
			type = "header",
			name = "KOS Frame options",
		},
		{
			type = "checkbox",
			name = "Show Friends in KOS/COOL Frame",
			tooltip = "ON - show friends, OFF - do not show friends",
			default = self.defaults.showFriends,
			disabled = function() return not self.SV.enabled or not self.SV.showKOSFrame end,
			getFunc = function() return self.SV.showFriends end,
			setFunc = function(newValue)
				self.SV.showFriends = newValue
			end,
		},
		{
			type = "checkbox",
			name = "Show Guildmates in KOS/COOL Frame",
			tooltip = "ON - show guildmates, OFF - do not show guildmates",
			default = self.defaults.showGuildMates,
			disabled = function() return not self.SV.enabled or not self.SV.showKOSFrame end,
			getFunc = function() return self.SV.showGuildMates end,
			setFunc = function(newValue)
				self.SV.showGuildMates = newValue
			end,
		},
		{
			type = "checkbox",
			name = "Show Player Notes in KOS/COOL Frame",
			tooltip = "ON - show player notes, OFF - do not show player notes",
			default = self.defaults.showPlayerNotes,
			disabled = function() return not self.SV.enabled or not self.SV.showKOSFrame end,
			getFunc = function() return self.SV.showPlayerNotes end,
			setFunc = function(newValue)
				self.SV.showPlayerNotes = newValue
			end,
		},
		{
			type = "slider",
			name = "Set KOS Frame scale (%)",
			tooltip = "KOS Frame scale goes from 50% to 150% of original scale",
			default = tonumber(string.format("%.0f", 100 * self.defaults.KOSControlScale)),
			disabled = function() return not self.SV.enabled or not self.SV.showKOSFrame end,
			min = 50,
			max = 150,
			step = 1,
			getFunc = function() return tonumber(string.format("%.0f", 100 * self.SV.KOSControlScale)) end,
			setFunc = function(newValue)
				self.SV.KOSControlScale = newValue / 100
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Play sound on friends/COOL/KOS targets detection",
			tooltip = "ON - play sound, OFF - do not play sound",
			default = self.defaults.playKOSSound,
			disabled = function() return not self.SV.enabled or not self.SV.showKOSFrame end,
			getFunc = function() return self.SV.playKOSSound end,
			setFunc = function(newValue)
				self.SV.playKOSSound = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Output new active KOS to the chat",
			tooltip = "ON - output to chat, OFF - do not output to chat",
			default = self.defaults.outputNewKos,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.outputNewKos end,
			setFunc = function(newValue)
				self.SV.outputNewKos = newValue
				self:InitControls()
			end,
		},
		{
			type = "header",
			name = "Forward Camp Frame options",
		},
		{
			type = "checkbox",
			name = "Play camp sounds",
			tooltip = "ON - play camp sounds, OFF - do not play camp sounds",
			default = self.defaults.playCampSound,
			disabled = function() return not self.SV.enabled or not self.SV.showCampFrame end,
			getFunc = function() return self.SV.playCampSound end,
			setFunc = function(newValue)
				self.SV.playCampSound = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Play PVP buffs sounds",
			tooltip = "ON - play a sound on gaining PVP buffs, OFF - do not play PVP buffs sounds",
			default = self.defaults.playBuffsSound,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.playBuffsSound end,
			setFunc = function(newValue)
				self.SV.playBuffsSound = newValue
				self:InitControls()
			end,
		},
		{
			type = "header",
			name = "Objective Capture Frame options",
		},
		{
			type = "checkbox",
			name = "Enable Neighbouring Capture Frame",
			tooltip = "ON - enables Neighbouring Capture Frame, OFF - disables Neighbouring Capture Frame",
			default = self.defaults.showNeighbourCaptureFrame,
			disabled = function() return not self.SV.enabled or not self.SV.showCaptureFrame end,
			getFunc = function() return self.SV.showNeighbourCaptureFrame end,
			setFunc = function(newValue)
				self.SV.showNeighbourCaptureFrame = newValue
				self:InitControls()
			end
		},
		{
			type = "header",
			name = "Target Name Frame options",
		},

		{
			type = "slider",
			name = "Set Target Name Frame scale (%)",
			tooltip = "Target Name Frame scale goes from 50% to 150% of original scale",
			default = tonumber(string.format("%.0f", 100 * self.defaults.targetNameFrameScale)),
			disabled = function() return not self.SV.enabled or not self.SV.showTargetNameFrame end,
			min = 50,
			max = 150,
			step = 1,
			getFunc = function() return tonumber(string.format("%.0f", 100 * self.SV.targetNameFrameScale)) end,
			setFunc = function(newValue)
				self.SV.targetNameFrameScale = newValue / 100
				self:InitControls()
			end,
		},
		{
			type = "dropdown",
			name = "Choose Target Name Text Alignment:",
			tooltip = 'Default is "Center"',
			choices = { "Center", "Left", "Right" },
			getFunc = function()
				if self.SV.targetTextAlign == TEXT_ALIGN_CENTER then
					return "Center"
				elseif self.SV.targetTextAlign == TEXT_ALIGN_LEFT then
					return "Left"
				elseif self.SV.targetTextAlign == TEXT_ALIGN_RIGHT then
					return "Right"
				end
			end,
			setFunc = function(newValue)
				if newValue == "Center" then
					self.SV.targetTextAlign = TEXT_ALIGN_CENTER
				elseif newValue == "Left" then
					self.SV.targetTextAlign = TEXT_ALIGN_LEFT
				elseif newValue == "Right" then
					self.SV.targetTextAlign = TEXT_ALIGN_RIGHT
				end
				self:InitControls()
			end,
			default = "Center",
			disabled = function() return not self.SV.enabled or not self.SV.showTargetNameFrame end,
		},
		{
			type = "slider",
			name = "Set Target Name Frame Alpha (%)",
			tooltip = "Target Name Frame alpha goes from 1% to 100%",
			default = tonumber(string.format("%.0f", 100 * self.defaults.targetNameFrameAlpha)),
			disabled = function() return not self.SV.enabled or not self.SV.showTargetNameFrame end,
			min = 1,
			max = 100,
			step = 1,
			getFunc = function() return tonumber(string.format("%.0f", 100 * self.SV.targetNameFrameAlpha)) end,
			setFunc = function(newValue)
				self.SV.targetNameFrameAlpha = newValue / 100
				self:InitControls()
			end,
		},
		{
			type = "slider",
			name = "Set Target Name Frame fadeout time (ms)",
			tooltip =
			"Target Name Frame fadeout time goes from 0 (fadeout disabled) to 5000ms (5 sec). Default value is 1500ms (1.5 sec).",
			default = self.defaults.targetNameFrameFadeoutTime,
			disabled = function() return not self.SV.enabled or not self.SV.showTargetNameFrame end,
			min = 0,
			max = 5000,
			step = 1,
			getFunc = function() return self.SV.targetNameFrameFadeoutTime end,
			setFunc = function(newValue)
				self.SV.targetNameFrameFadeoutTime = newValue
				self:InitControls()
			end,
		},
		{
			type = "slider",
			name = "Set Target Name Frame delay before fadeout (ms)",
			tooltip = "Target Name Frame fadeout time goes from 0 to 2000ms (2 sec). Default value is 250ms.",
			default = self.defaults.targetNameFrameDelayBeforeFadeout,
			disabled = function() return not self.SV.enabled or not self.SV.showTargetNameFrame end,
			min = 0,
			max = 2000,
			step = 1,
			getFunc = function() return self.SV.targetNameFrameDelayBeforeFadeout end,
			setFunc = function(newValue)
				self.SV.targetNameFrameDelayBeforeFadeout = newValue
				self:InitControls()
			end,
		},
		{
			type = "header",
			name = "3D Icons options",
		},
		{
			type = "checkbox",
			name = "Show on screen info for close objective",
			tooltip =
			"ON - shows on screen info from for objective, OFF - doesn't show on screen info from for objective",
			default = self.defaults.showOnScreen,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons end,
			getFunc = function() return self.SV.showOnScreen end,
			setFunc = function(newValue)
				self.SV.showOnScreen = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Replace 3d icon with on screen info",
			tooltip =
			"ON - icon of the objective will be hidden, while having on screen info, OFF - both on screen info and 3d icon will be present",
			default = self.defaults.onScreenReplace,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons or not self.SV.showOnScreen end,
			getFunc = function() return self.SV.onScreenReplace end,
			setFunc = function(newValue)
				self.SV.onScreenReplace = newValue
				self:InitControls()
			end,
		},
		{
			type = "slider",
			name = "Set on screen info scale (%)",
			tooltip = "Icon and text scale goes from 50% to 150% of original scale",
			default = tonumber(string.format("%.0f", 100 * self.defaults.onScreenScale)),
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons or not self.SV.showOnScreen end,
			min = 50,
			max = 150,
			step = 1,
			getFunc = function() return tonumber(string.format("%.0f", 100 * self.SV.onScreenScale)) end,
			setFunc = function(newValue)
				self.SV.onScreenScale = newValue / 100
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Show group members icons",
			tooltip = "ON - shows 3d icons for group members, OFF - disables 3d icons for group members",
			default = self.defaults.group3d,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons end,
			getFunc = function() return self.SV.group3d end,
			setFunc = function(newValue)
				self.SV.group3d = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Show only group leader icon",
			tooltip = "ON - shows 3d icons only for the group leader, OFF - shows 3d icons for all group members",
			default = self.defaults.onlyGroupLeader3d,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons end,
			getFunc = function() return self.SV.onlyGroupLeader3d end,
			setFunc = function(newValue)
				self.SV.onlyGroupLeader3d = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Show group leader 3d icon at any distance",
			tooltip =
			"ON - shows group leader 3d icon at any distance, OFF - hides group leader 3d icon when close to player",
			default = self.defaults.groupleader3d,
			disabled = function()
				return not self.SV.enabled or not self.SV.show3DIcons or not self.SV.group3d or
					self.SV.allgroup3d
			end,
			getFunc = function() return self.SV.groupleader3d end,
			setFunc = function(newValue)
				self.SV.groupleader3d = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Show ALL group 3d icons at any distance (not recommended)",
			tooltip = "ON - shows ALL group 3d icons at any distance, OFF - hides group 3d icons when close to player",
			default = self.defaults.allgroup3d,
			disabled = function()
				return not self.SV.enabled or not self.SV.show3DIcons or not self.SV.group3d or
					self.SV.onlyGroupLeader3d
			end,
			getFunc = function() return self.SV.allgroup3d end,
			setFunc = function(newValue)
				self.SV.allgroup3d = newValue
				self:InitControls()
			end,
		},
		{
			type = "slider",
			name = "Size of group leader 3d icons",
			tooltip = "Default size is 9",
			default = self.defaults.groupLeaderIconSize,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons or not self.SV.group3d end,
			min = 1,
			max = 15,
			step = 1,
			getFunc = function() return self.SV.groupLeaderIconSize end,
			setFunc = function(newValue) self.SV.groupLeaderIconSize = newValue end,
		},
		{
			type = "slider",
			name = "Size of group members 3d icons",
			tooltip = "Default size is 10",
			default = self.defaults.groupIconSize,
			disabled = function()
				return not self.SV.enabled or not self.SV.show3DIcons or not self.SV.group3d or
					self.SV.onlyGroupLeader3d
			end,
			min = 1,
			max = 15,
			step = 1,
			getFunc = function() return self.SV.groupIconSize end,
			setFunc = function(newValue) self.SV.groupIconSize = newValue end,
		},
		{
			type = "checkbox",
			name = "Show shadow image 3d icon (nightblade)",
			tooltip = "ON - shows shadow image 3d icon (nightblade), OFF - disables shadow image 3d icon (nightblade)",
			default = self.defaults.shadowImage3d,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons or GetUnitClassId('player') ~= 3 end,
			getFunc = function() return self.SV.shadowImage3d end,
			setFunc = function(newValue)
				self.SV.shadowImage3d = newValue
				if not newValue then self.shadowInfo = nil end
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Set map ping at the location of map waypoint",
			tooltip =
			"ON - when you put a waypoint marker on the map the addon puts ping icon on top of it, OFF - disables setting ping on waypoint marker",
			default = self.defaults.pingWaypoint,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons end,
			getFunc = function() return self.SV.pingWaypoint end,
			setFunc = function(newValue)
				self.SV.pingWaypoint = newValue
				self:InitControls()
			end,
		},
		{
			type = "slider",
			name = "Minimum distance to hide 3D icons (m)",
			tooltip = "Minimum distance goes from 0m (default, the icons are always visible) to 200m",
			default = self.defaults.min3DIconsDistance,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons end,
			min = 0,
			max = 200,
			step = 1,
			getFunc = function() return self.SV.min3DIconsDistance * 10000 end,
			-- setFunc = function(newValue) self.SV.min3DIconsDistance = newValue/10000 self:FullReset3DIcons() self:InitControls() end,
			setFunc = function(newValue) self.SV.min3DIconsDistance = newValue / 10000 end,
		},
		{
			type = "slider",
			name = "Maximum distance to show ALL 3D icons (m)",
			tooltip =
			"Maximum distance goes from 2000m (default, approximately the distance between 2 keeps) down to 250m",
			default = self.defaults.max3DIconsDistance,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons end,
			min = 250,
			max = 2000,
			step = 1,
			getFunc = function() return self.SV.max3DIconsDistance * 10000 end,
			-- setFunc = function(newValue) self.SV.max3DIconsDistance = newValue/10000 self:FullReset3DIcons() self:InitControls() end,
			setFunc = function(newValue) self.SV.max3DIconsDistance = newValue / 10000 end,
		},
		{
			type = "slider",
			name = "Maximum distance to show resources 3D icons (m)",
			tooltip = "Maximum distance goes from 2000m (default is 650m) down to 250m",
			default = self.defaults.maxResource3DIconsDistance,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons end,
			min = 250,
			max = 2000,
			step = 1,
			getFunc = function() return self.SV.maxResource3DIconsDistance * 10000 end,
			-- setFunc = function(newValue) self.SV.max3DIconsDistance = newValue/10000 self:FullReset3DIcons() self:InitControls() end,
			setFunc = function(newValue) self.SV.maxResource3DIconsDistance = newValue / 10000 end,
		},
		{
			type = "slider",
			name = "Maximum distance to show POI icons (m)",
			tooltip =
			"Maximum distance to show POI icons (fights, delves, wells, etc). It goes from 250m to 1000m (dafault value - 750m)",
			default = self.defaults.max3DIconsPOIDistance,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons end,
			min = 250,
			max = 1000,
			step = 1,
			getFunc = function() return self.SV.max3DIconsPOIDistance * 10000 end,
			-- setFunc = function(newValue) self.SV.max3DIconsPOIDistance = newValue/10000 self:FullReset3DIcons() self:InitControls() end,
			setFunc = function(newValue) self.SV.max3DIconsPOIDistance = newValue / 10000 end,
		},
		{
			type = "slider",
			name = "Maximum distance to show capture border on the icons (m)",
			tooltip = "Maximum distance to show capture border. It goes from 250m to 1000m (dafault value - 750m)",
			default = self.defaults.max3DCaptureDistance,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons end,
			min = 250,
			max = 1000,
			step = 1,
			getFunc = function() return self.SV.max3DCaptureDistance * 10000 end,
			-- setFunc = function(newValue) self.SV.max3DCaptureDistance = newValue/10000 self:FullReset3DIcons() self:InitControls() end,
			setFunc = function(newValue) self.SV.max3DCaptureDistance = newValue / 10000 end,
		},
		{
			type = "slider",
			name = "Set opacity of IC neighbouring districts (%)",
			tooltip =
			"Sets opacity for the district icons outside of your current district. Opacity goes from 0% (invisible) to 100% (fully visible)",
			default = tonumber(string.format("%.0f", 100 * self.defaults.neighboringDistrictsAlpha)),
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons end,
			min = 0,
			max = 100,
			step = 1,
			getFunc = function() return tonumber(string.format("%.0f", 100 * self.SV.neighboringDistrictsAlpha)) end,
			setFunc = function(newValue)
				self.SV.neighboringDistrictsAlpha = newValue / 100
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Show 3d compass letters",
			tooltip = "ON - shows 3d compass letters, OFF - disables 3d compass letters",
			default = self.defaults.showCompass3d,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons end,
			getFunc = function() return self.SV.showCompass3d end,
			setFunc = function(newValue)
				self.SV.showCompass3d = newValue
				self:InitControls()
			end,
		},
		{
			type = "slider",
			name = "Height of compass letters",
			tooltip = "Set height of compass letters above the player (default 225)",
			default = self.defaults.compass3dHeight,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons or not self.SV.showCompass3d end,
			min = 0,
			max = 500,
			step = 1,
			getFunc = function() return self.SV.compass3dHeight end,
			setFunc = function(newValue)
				self.SV.compass3dHeight = newValue
				self:InitControls()
			end,
		},
		{
			type = "slider",
			name = "Size of compass letters",
			tooltip = "Set size of compass letters (default 100)",
			default = self.defaults.compass3dSize,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons or not self.SV.showCompass3d end,
			min = 50,
			max = 300,
			step = 1,
			getFunc = function() return self.SV.compass3dSize end,
			setFunc = function(newValue)
				self.SV.compass3dSize = newValue
				self:InitControls()
			end,
		},
		{
			type = "colorpicker",
			name = "Pick color for compass 3d letters",
			tooltip = "Pick color for compass 3d letters",
			default = ZO_ColorDef:New(unpack(self.defaults.compass3dColor)),
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons or not self.SV.showCompass3d end,
			getFunc = function() return unpack(self.SV.compass3dColor) end,
			setFunc = function(r, g, b, a)
				self.SV.compass3dColor = { r, g, b, a }
			end
		},
		{
			type = "colorpicker",
			name = "Pick color for North compass 3d letter",
			tooltip = "Pick color for North compass 3d letter",
			default = ZO_ColorDef:New(unpack(self.defaults.compass3dColorNorth)),
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons or not self.SV.showCompass3d end,
			getFunc = function() return unpack(self.SV.compass3dColorNorth) end,
			setFunc = function(r, g, b, a)
				self.SV.compass3dColorNorth = { r, g, b, a }
			end
		},
		{
			type = "checkbox",
			name = "Use Depth Buffer for compass",
			tooltip = "ON - shows 3d compass letters, OFF - disables 3d compass letters",
			default = self.defaults.useDepthBufferCompass,
			disabled = function() return not self.SV.enabled or not self.SV.show3DIcons or not self.SV.showCompass3d end,
			getFunc = function() return self.SV.useDepthBufferCompass end,
			setFunc = function(newValue)
				self.SV.useDepthBufferCompass = newValue
				self:InitControls()
			end
		},

		{
			type = "header",
			name = "Misc options",
		},
		{
			type = "checkbox",
			name = "Play killing blow sounds",
			tooltip = "ON - play sound, OFF - do not play sound",
			default = self.defaults.playKillingBlowSound,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.playKillingBlowSound end,
			setFunc = function(newValue)
				self.SV.playKillingBlowSound = newValue
				self:InitControls()
			end
		},
		{
			type = "checkbox",
			name = "Show modified target name in default target frame",
			tooltip = "ON - Show modified target name, OFF - do not show modified target name",
			default = self.defaults.showNewTargetInfo,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showNewTargetInfo end,
			setFunc = function(newValue)
				self.SV.showNewTargetInfo = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Show max target CP in default target frame",
			tooltip = "ON - Show max target CP, OFF - do not show max target CP",
			default = self.defaults.showMaxTargetCP,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showMaxTargetCP end,
			setFunc = function(newValue)
				self.SV.showMaxTargetCP = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Output abilities list for detected hybrid specs",
			tooltip = "ON - Output the list, OFF - do not output the list",
			default = self.defaults.showHybridJustification,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showHybridJustification end,
			setFunc = function(newValue)
				self.SV.showHybridJustification = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Report numbers of saved characters/accounts",
			tooltip = "ON - Keep reporting, OFF - Stop reporting",
			default = self.defaults.reportSavedInfo,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.reportSavedInfo end,
			setFunc = function(newValue)
				self.SV.reportSavedInfo = newValue
				if newValue then PVP:RefreshStoredNumbers(GetFrameTimeMilliseconds()) else PVP.reportTimer = 0 end
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Show medals frame in battlegrounds",
			tooltip = "ON - show medals frame, OFF - do not show medals frame",
			default = self.defaults.showMedalsFrame,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showMedalsFrame end,
			setFunc = function(newValue)
				self.SV.showMedalsFrame = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Scoreboard button toggle",
			tooltip =
			"ON - the button works as a toggle, OFF - shows scoreboard on button press and hides on button release",
			default = self.defaults.bgToggle,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.bgToggle end,
			setFunc = function(newValue)
				self.SV.bgToggle = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Show joined/left players in battelgrounds",
			tooltip = "ON - show players messages in chat, OFF - don't show players messages in chat",
			default = self.defaults.showJoinedPlayers,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showJoinedPlayers end,
			setFunc = function(newValue)
				self.SV.showJoinedPlayers = newValue
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Replace rank 50 icon with a 6 star icon",
			tooltip =
			"ON - replaces the default rank 50 icon (5 stars) with a new 6 stars icon, OFF - reverts to 5 star icon for rank 50",
			default = self.defaults.show6star,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.show6star end,
			setFunc = function(newValue)
				self.SV.show6star = newValue
				ZO_CampaignAvARank_OnInitialized(ZO_CampaignAvARank)
				-- CAMPAIGN_AVA_RANK = CampaignAvARank:New(ZO_CampaignAvARank)
				self:InitControls()
			end,
		},
		{
			type = "checkbox",
			name = "Show performance stats in chat",
			tooltip = "ON - show addon performance stats in chat, OFF - stop showing performance stats in chat",
			default = self.defaults.showPerformance,
			disabled = function() return not self.SV.enabled end,
			getFunc = function() return self.SV.showPerformance end,
			setFunc = function(newValue)
				self.SV.showPerformance = newValue
				self:InitControls()
			end,
		}
	}
	LAM2:RegisterOptionControls("Pvp_Alerts", optionsData)
end

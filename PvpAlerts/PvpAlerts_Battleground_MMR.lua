local PVP = PVP_Alerts_Main_Table

local activities =
{
    --[LFG_ACTIVITY_ARENA] = "Arena",
    -- [LFG_ACTIVITY_AVA] = "AvA",
    --[LFG_ACTIVITY_BATTLE_GROUND_CHAMPION] = "CP Battlegrounds",
    [LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION] = "Battlegrounds",
    --[LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL] = "U50 Battlegrounds",
    --[LFG_ACTIVITY_DUNGEON] = "Dungeon",
    --[LFG_ACTIVITY_ENDLESS_DUNGEON] = "Infinite Archive",
    --[LFG_ACTIVITY_EXPLORATION] = "Exploration",
    --[LFG_ACTIVITY_HOME_SHOW] = "Home Tours",
    --[LFG_ACTIVITY_INVALID] = "Invalid",
    --[LFG_ACTIVITY_MASTER_DUNGEON] = "Master Dungeon",
    --[LFG_ACTIVITY_TRIAL] = "Trial",
    --[LFG_ACTIVITY_TRIBUTE_CASUAL] = "Casual ToT",
    --[LFG_ACTIVITY_TRIBUTE_COMPETITIVE] = "Ranked ToT",
};

--[[
* EVENT_BATTLEGROUND_STATE_CHANGED (*[BattlegroundState|#BattlegroundState]* _previousState_, *[BattlegroundState|#BattlegroundState]* _currentState_)
h5. BattlegroundState
* BATTLEGROUND_STATE_FINISHED
* BATTLEGROUND_STATE_NONE
* BATTLEGROUND_STATE_POSTROUND
* BATTLEGROUND_STATE_PREROUND
* BATTLEGROUND_STATE_RUNNING
* BATTLEGROUND_STATE_STARTING

 ]]

function PVP:OnBattlegroundStateChanged(eventCode, previousState, currentState)
    if not PVP.SV.mmr then PVP.SV.mmr = {} end
    if not PVP.SV.mmr[PVP.playerName] then PVP.SV.mmr[PVP.playerName] = {} end
    local activityId = GetCurrentLFGActivityId()
    local activityType = GetActivityType(activityId)
    local lastMMR = PVP.SV.mmr[PVP.playerName] and PVP.SV.mmr[PVP.playerName][activityType] or 0
    if (currentState == BATTLEGROUND_STATE_STARTING and previousState == BATTLEGROUND_STATE_NONE) or (previousState == BATTLEGROUND_STATE_STARTING) then
        local currentMMR = GetPlayerMMRByType(activityType) or 0
        PVP.SV.mmr[PVP.playerName][activityType] = currentMMR
        local mmrDecay = lastMMR - currentMMR
        if DoesCurrentBattlegroundImpactMMR() then
            if currentMMR == lastMMR or (lastMMR == 0) then
                PVP.CHAT:Printf("Your MMR starting this battleground is: %s.", currentMMR)
            else
                PVP.CHAT:Printf("Your MMR has decayed by %s (from %s to %s) since your last ranked battlegound.",
                    mmrDecay, lastMMR, currentMMR)
            end
        else
            if currentMMR == lastMMR or (lastMMR == 0) then
                PVP.CHAT:Printf("This Battleground has no MMR Impact. Your MMR starting this battleground is: %s.",
                    currentMMR)
            else
                PVP.CHAT:Printf(
                    "This Battleground has no MMR Impact. Your MMR has decayed by %s (from %s to %s) since your last ranked battlegound.",
                    mmrDecay, lastMMR, currentMMR)
            end
        end
    elseif (currentState == BATTLEGROUND_STATE_FINISHED) then
        if DoesCurrentBattlegroundImpactMMR() then
            local currentMMR = GetPlayerMMRByType(activityType)
            PVP.SV.mmr[PVP.playerName][activityType] = currentMMR
            PVP.CHAT:Printf("Your MMR finishing this battleground is: %s", currentMMR)
        end
    end;
end;

--[[
* EVENT_BATTLEGROUND_MMR_LOSS_REDUCED (*[BattlegroundMMRBonusType|#BattlegroundMMRBonusType]* _reductionReason_)

h5. BattlegroundMMRBonusType
* BG_MMR_BONUS_ALL
* BG_MMR_BONUS_JOIN_IN_PROGRESS
* BG_MMR_BONUS_LFM_REQUESTED
]]

function PVP:OnBattlegroundMMRLossReduced(eventCode, reductionReason)
    if not DoesCurrentBattlegroundImpactMMR() then return end
    if (reductionReason == BG_MMR_BONUS_JOIN_IN_PROGRESS) then
        PVP.CHAT:Printf("MMR Impact of this battleground is reduced due to joining a match in progress")
    elseif (reductionReason == BG_MMR_BONUS_LFM_REQUESTED) then
        PVP.CHAT:Printf("MMR Impact of this battleground has been reduced due to a request for replacement players")
    elseif (reductionReason == BG_MMR_BONUS_ALL) then
        PVP.CHAT:Printf("This battleground will currently have full MMR impact")
    end
end

-- Helper function to display MMR stats for a character
local function DisplayMMR(character, isCurrentPlayer)
    PVP.CHAT:Printf("Character: %s", PVP:GetFormattedName(character))
    for activityType, activityName in pairs(activities) do
        local currentMMR = isCurrentPlayer and (GetPlayerMMRByType(activityType) or 0) or
            (PVP.SV.mmr[character][activityType] or 0)
        local lastMMR = PVP.SV.mmr[character][activityType] or 0
        local mmrDecay = lastMMR - currentMMR

        if isCurrentPlayer and mmrDecay ~= 0 then
            PVP.CHAT:Printf("Your MMR for %s has decayed by %s (from %s to %s).", activityName, mmrDecay, lastMMR,
                currentMMR)
        else
            PVP.CHAT:Printf("%s MMR: %s", activityName, currentMMR)
        end

        -- Update saved MMR if flag is set
        if update and isCurrentPlayer then
            PVP.SV.mmr[character][activityType] = currentMMR
        end
    end
end

function PVP:ListMMR(flag)
    local player = PVP.playerName or GetRawUnitName('player')
    if not PVP.SV.mmr then PVP.SV.mmr = {} end
    if not PVP.SV.mmr[player] then PVP.SV.mmr[player] = {} end

    local update = flag == "update" or flag == "updateall"
    local showAll = flag == "all" or flag == "updateall"

    -- Display MMR for the current character
    DisplayMMR(player, true)

    -- Display MMR for all characters if "all" or "updateall" flag is set
    if showAll then
        for character, _ in pairs(PVP.SV.mmr) do
            if character ~= player then
                DisplayMMR(character, false)
            end
        end
    end
end

--[[
* GetCurrentBattlegroundState()
** _Returns:_ *[BattlegroundState|#BattlegroundState]* _result_

* DoesCurrentBattlegroundImpactMMR()
** _Returns:_ *bool* _impactsMMR_

* DoesActivitySetHaveMMR(*integer* _activitySetId_)
** _Returns:_ *bool* _hasMMR_

* GetCurrentLFGActivityId()
** _Returns:_ *integer* _activityId_

* GetActivityType(*integer* _activityId_)
** _Returns:_ *[LFGActivity|#LFGActivity]* _activity_

* GetPlayerMMRByType(*[LFGActivity|#LFGActivity]* _activity_)
** _Returns:_ *integer* _mmrRating_
]]

local PVP = PVP_Alerts_Main_Table

function PVP:DetectSpec(unitId, abilityId, result, sourceName, isBuff, damageBuff)
	local unitName = sourceName or self.idToName[unitId]

	if not unitName or unitName == "" or PVP:IsMalformedName(unitName) then return end

	self.playerSpec[unitName] = self.playerSpec[unitName] or { spec_counterStam = 0, spec_counterMag = 0 }

	if self.playerSpec[unitName].spec_decision then return self.playerSpec[unitName].spec_decision end

	local spec = self.playerSpec[unitName]
	local counterStam, counterMag = spec.spec_counterStam, spec.spec_counterMag

	local function CountSpec()
		local total = counterStam + counterMag
		if total < 3 then return false end
		if total >= 4 then return true end
		if total == 3 then
			if counterStam == 3 or counterMag == 3 then
				return true
			else
				return false
			end
		end
	end

	if CountSpec() then
		return self:MakeSpecDecision(unitName)
	end

	local abilityName

	abilityName = damageBuff and damageBuff or GetAbilityName(abilityId)

	local function SetSpecAbility(decision)
		if decision then
			spec[abilityName] = true
			if decision == "stam" then counterStam = counterStam + 1 end
			if decision == "mag" then counterMag = counterMag + 1 end
			if decision == "stamBig" then counterStam = counterStam + 3 end
			if decision == "magBig" then counterMag = counterMag + 3 end
		end
	end

	local isReflected = self.miscAbilities[sourceName] and self.miscAbilities[sourceName].reflects and
		self.miscAbilities[sourceName].reflects[abilityName]

	if isReflected and spec[abilityName] then spec[abilityName] = nil end

	if not spec[abilityName] and not isReflected then
		local decision
		if isBuff then
			if damageBuff then
				if damageBuff == "Major Brutality" then
					decision = "stam"
				else
					decision = "mag"
				end
			else
				decision = self:GetSelfSpecAbilities(abilityName)
			end
		else
			decision = self:DetectAbilitySpec(abilityName)
		end

		SetSpecAbility(decision)

		spec.spec_counterStam = counterStam
		spec.spec_counterMag = counterMag
		self.playerSpec[unitName] = spec

		if CountSpec() then
			return self:MakeSpecDecision(unitName)
		end
	end
end

function PVP:MakeSpecDecision(unitName)
	local decision, threshold

	local counterStam, counterMag = self.playerSpec[unitName].spec_counterStam, self.playerSpec[unitName]
		.spec_counterMag

	if counterStam + counterMag >= 7 then
		threshold = 2
	else
		threshold = 1
	end

	if counterMag <= threshold then
		decision = "stam"
	elseif counterStam <= threshold then
		decision = "mag"
	else
		decision = "hybrid"
	end

	if self.SV.showHybridJustification and decision == "hybrid" then
		d('Hybrid spec for ' .. unitName)
		for k, v in pairs(self.playerSpec[unitName]) do
			if k ~= "spec_counterStam" and k ~= "spec_counterMag" then
				d(k)
			end
		end
		d('end of abilities list')
	end

	self.playerSpec[unitName] = { spec_decision = decision }
	return decision
end

function PVP:DetectAbilitySpec(abilityName)
	if self:IsStaminaAbility(abilityName) == 'small' then
		return "stam"
	elseif self:IsStaminaAbility(abilityName) == 'big' then
		return "stamBig"
	end
	if self:IsMagickaAbility(abilityName) == 'small' then
		return "mag"
	elseif self:IsMagickaAbility(abilityName) == 'big' then
		return "magBig"
	end
	return nil
end

function PVP:IsStaminaAbility(abilityName)
	if self.staminaAbilities[abilityName] then return 'big' end
	if self.staminaAbilitiesSmall[abilityName] then return 'small' end

	for i = 1, GetNumSkillLines(SKILL_TYPE_WEAPON) do
		if self.staminaSkillLines[GetSkillLineInfo(SKILL_TYPE_WEAPON, i)] then
			for j = 1, GetNumSkillAbilities(SKILL_TYPE_WEAPON, i) do
				if GetSkillAbilityInfo(SKILL_TYPE_WEAPON, i, j) == abilityName then return 'big' end
			end
		end
	end

	return false
end

function PVP:IsMagickaAbility(abilityName)
	if self.magickaAbilities[abilityName] then return 'big' end
	if self.magickaAbilitiesSmall[abilityName] then return 'small' end

	for i = 1, GetNumSkillLines(SKILL_TYPE_WEAPON) do
		if self.magickaSkillLines[GetSkillLineInfo(SKILL_TYPE_WEAPON, i)] then
			for j = 1, GetNumSkillAbilities(SKILL_TYPE_WEAPON, i) do
				if GetSkillAbilityInfo(SKILL_TYPE_WEAPON, i, j) == abilityName then return 'big' end
			end
		end
	end

	return false
end

function PVP:GetSelfSpecAbilities(abilityName)
	if self.selfBigStamAbilities[abilityName] then return "stamBig" end
	if self.selfBigMagAbilities[abilityName] then return "magBig" end
	if self.selfStamAbilities[abilityName] then return "stam" end
	if self.selfMagAbilities[abilityName] then return "mag" end
	return nil
end

function PVP:SelfGetSpec(abilityId)
	local abilityName = GetAbilityName(abilityId)

	if self.selfStamAbilities[abilityName] then
		d("(SS)Stam: " .. abilityName)
		return 1
	end
	if self.selfMagAbilities[abilityName] then
		d("(SS)Mag: " .. abilityName)
		return 2
	end
	return 0
end

function PVP:DetectSpecOnReticleOver(unitName)
	local selfBuffs = {}

	self.playerSpec[unitName] = self.playerSpec[unitName] or { spec_counterStam = 0, spec_counterMag = 0 }

	for i = 1, GetNumBuffs('reticleover') do
		local buffName, _, _, _, _, _, _, _, _, _, abilityId, _, castByPlayer = GetUnitBuffInfo('reticleover', i)
		selfBuffs[buffName] = true
		self:DetectSpec(nil, abilityId, nil, unitName, true)
	end

	if self.playerSpec[unitName].spec_decision then return end

	if not selfBuffs["Igneous Weapons"] and not selfBuffs["Major Sorcery"] and not selfBuffs["Rally"] and not selfBuffs["Forward Momentum"] and selfBuffs["Major Brutality"] then
		self:DetectSpec(nil, nil, nil, unitName, true, "Major Brutality")
		return
	end

	if not selfBuffs["Molten Armaments"] and not selfBuffs["Igneous Weapons"] and not selfBuffs["Critical Surge"] and not selfBuffs["Power Surge"] and not selfBuffs["Major Brutality"] and selfBuffs["Major Sorcery"] then
		self:DetectSpec(nil, nil, nil, unitName, true, "Major Sorcery")
		return
	end
end

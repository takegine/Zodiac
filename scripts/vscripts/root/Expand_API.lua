----------------------------------------------------------------
-- "Custom" modifier value fetching
----------------------------------------------------------------
-- Spell lifesteal
function CDOTA_BaseNPC:GetSpellLifesteal()
    local lifesteal = 0
    for _, parent_modifier in pairs(self:FindAllModifiers()) do
        if parent_modifier.GetModifierSpellLifesteal then
            lifesteal = lifesteal + parent_modifier:GetModifierSpellLifesteal()
        end
    end
    return lifesteal
end

-- Autoattack lifesteal
function CDOTA_BaseNPC:GetLifesteal()
    local lifesteal = 0
    for _, parent_modifier in pairs(self:FindAllModifiers()) do
        if parent_modifier.GetModifierLifesteal then
            lifesteal = lifesteal + parent_modifier:GetModifierLifesteal()
        end
    end
    return lifesteal
end

-- Health regeneration % amplification
function CDOTA_BaseNPC:GetHealthRegenAmp()
    local regen_increase = 0
    for _, parent_modifier in pairs(self:FindAllModifiers()) do
        if parent_modifier.GetModifierHealthRegenAmp then
            regen_increase = regen_increase + parent_modifier:GetModifierHealthRegenAmp()
        end
    end
    return regen_increase
end

-- Spell power
function CDOTA_BaseNPC:GetSpellPower()

    -- If this is not a hero, do nothing
    if not self:IsHero() then
        return 0
    end

    -- Adjust base spell power based on current intelligence
    local spell_power = self:GetIntellect() / 14

    -- Mega Treads increase spell power from intelligence by 30%
    if self:HasModifier("modifier_imba_mega_treads_stat_multiplier_02") then
        spell_power = self:GetIntellect() * 0.093
    end

    -- Fetch spell power from modifiers
    for _, parent_modifier in pairs(self:FindAllModifiers()) do
        if parent_modifier.GetModifierSpellAmplify_Percentage then
            spell_power = spell_power + parent_modifier:GetModifierSpellAmplify_Percentage()
        end
    end

    -- Return current spell power
    return spell_power
end

-- Cooldown reduction
function CDOTA_BaseNPC:GetCooldownReduction()

    -- If this is not a hero, do nothing
    if not self:IsRealHero() then
        return 0
    end

    -- Fetch cooldown reduction from modifiers
    local cooldown_reduction = 0
    local nonstacking_reduction = 0
    local stacking_reduction = 0
    for _, parent_modifier in pairs(self:FindAllModifiers()) do

        -- Nonstacking reduction
        if parent_modifier.GetCustomCooldownReduction then
            nonstacking_reduction = math.max(nonstacking_reduction, parent_modifier:GetCustomCooldownReduction())
        end

        -- Stacking reduction
        if parent_modifier.GetCustomCooldownReductionStacking then
            stacking_reduction = 100 - (100 - stacking_reduction) * (100 - parent_modifier:GetCustomCooldownReductionStacking()) * 0.01
        end
    end

    -- Calculate actual cooldown reduction
    cooldown_reduction = 100 - (100 - nonstacking_reduction) * (100 - stacking_reduction) * 0.01

    -- Return current cooldown reduction
    return cooldown_reduction
end

-- Calculate physical damage post reduction
function CDOTA_BaseNPC:GetPhysicalArmorReduction()
    local armornpc = self:GetPhysicalArmorValue(false)
    local armor_reduction = 1 - (0.06 * armornpc) / (1 + (0.06 * math.abs(armornpc)))
    armor_reduction = 100 - (armor_reduction * 100)
    return armor_reduction
end

-- Physical damage block
function CDOTA_BaseNPC:GetDamageBlock()

    -- Fetch damage block from custom modifiers
    local damage_block = 0
    local unique_damage_block = 0
    for _, parent_modifier in pairs(self:FindAllModifiers()) do

        -- Vanguard-based damage block does not stack
        if parent_modifier.GetCustomDamageBlockUnique then
            unique_damage_block = math.max(unique_damage_block, parent_modifier:GetCustomDamageBlockUnique())
        end

        -- Stack all other sources of damage block
        if parent_modifier.GetCustomDamageBlock then
            damage_block = damage_block + parent_modifier:GetCustomDamageBlock()
        end
    end

    -- Calculate total damage block
    damage_block = damage_block + unique_damage_block

    -- Ranged attackers only benefit from part of the damage block
    if self:IsRangedAttacker() then
        return 0.6 * damage_block
    else
        return damage_block
    end
end
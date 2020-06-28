
modifier_item_relic_status = class({})
--------------------------------------------------------------------------------

function modifier_item_relic_status:IsHidden() 
	return false
end

--------------------------------------------------------------------------------

function modifier_item_relic_status:IsPurgable()
	return false
end

function modifier_item_relic_status:GetTexture ()
    return "custom/relic_status"
end

----------------------------------------

function modifier_item_relic_status:OnCreated( kv )
    self.needupwawe = true
    if self:GetAbility() ~= nil then
        self.bonus_damage_for_wawe = self:GetAbility():GetSpecialValueFor( "bonus_all_stats_for_wawe" )
    end
	if IsServer() then
        self:OnWaweChange(_G.GAME_ROUND)
    end
end

----------------------------------------

function modifier_item_relic_status:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}

	return funcs
end

----------------------------------------

function modifier_item_relic_status:OnWaweChange( wawe )
	if IsServer() then
        self.wave = wawe
        local damag = 0
        if self:GetCaster().lvl_item_relic_status ~= nil then
            if self:GetCaster().lvl_item_relic_status >= 20 then
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * 20)
            else
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_status)
            end
            if damag ~= self:GetStackCount() then
                self:SetStackCount(damag)
            end
        else
            self:GetCaster().lvl_item_relic_status = 1
        end
    end
end

function modifier_item_relic_status:GetModifierBonusStats_Strength( params )
	if IsServer() then
        local damag = 0
        if self:GetCaster().lvl_item_relic_status ~= nil then
            if self:GetCaster().lvl_item_relic_status >= 20 then
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * 20)
            else
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_status)
            end
            if damag ~= self:GetStackCount() then
                self:SetStackCount(damag)
            end
        else
            self:GetCaster().lvl_item_relic_status = 1
        end
    end
    return self:GetStackCount()
end

function modifier_item_relic_status:GetModifierBonusStats_Agility( params )
	if IsServer() then
        local damag = 0
        if self:GetCaster().lvl_item_relic_status ~= nil then
            if self:GetCaster().lvl_item_relic_status >= 20 then
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * 20)
            else
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_status)
            end
            if damag ~= self:GetStackCount() then
                self:SetStackCount(damag)
            end
        else
            self:GetCaster().lvl_item_relic_status = 1
        end
    end
    return self:GetStackCount()
end

function modifier_item_relic_status:GetModifierBonusStats_Intellect( params )
	if IsServer() then
        local damag = 0
        if self:GetCaster().lvl_item_relic_status ~= nil then
            if self:GetCaster().lvl_item_relic_status >= 20 then
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * 20)
            else
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_status)
            end
            if damag ~= self:GetStackCount() then
                self:SetStackCount(damag)
            end
        else
            self:GetCaster().lvl_item_relic_status = 1
        end
    end
    return self:GetStackCount()
end
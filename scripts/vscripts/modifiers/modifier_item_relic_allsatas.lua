
modifier_item_relic_allsatas = class({})
--------------------------------------------------------------------------------

function modifier_item_relic_allsatas:IsHidden() 
	return false
end

--------------------------------------------------------------------------------

function modifier_item_relic_allsatas:IsPurgable()
	return false
end

function modifier_item_relic_allsatas:GetTexture ()
    return "custom/relic_allsatas"
end

----------------------------------------

function modifier_item_relic_allsatas:OnCreated( kv )
    self.needupwawe = true
    if self:GetAbility() ~= nil then
        self.bonus_damage_for_wawe = self:GetAbility():GetSpecialValueFor( "bonus_all_stats_for_wawe" )
    end
	if IsServer() then
        self:OnWaweChange(_G.GAME_ROUND)
    end
end

----------------------------------------

function modifier_item_relic_allsatas:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}

	return funcs
end

----------------------------------------

function modifier_item_relic_allsatas:OnWaweChange( wawe )
	if IsServer() then
        self.wave = wawe
        local damag = 0
        if self:GetCaster().lvl_item_relic_allsatas ~= nil then
            if self:GetCaster().lvl_item_relic_allsatas >= 20 then
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * 20)
            else
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_allsatas)
            end
            if damag ~= self:GetStackCount() then
                self:SetStackCount(damag)
            end
        else
            self:GetCaster().lvl_item_relic_allsatas = 1
        end
    end
end

function modifier_item_relic_allsatas:GetModifierBonusStats_Strength( params )
	if IsServer() then
        local damag = 0
        if self:GetCaster().lvl_item_relic_allsatas ~= nil then
            if self:GetCaster().lvl_item_relic_allsatas >= 20 then
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * 20)
            else
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_allsatas)
            end
            if damag ~= self:GetStackCount() then
                self:SetStackCount(damag)
            end
        else
            self:GetCaster().lvl_item_relic_allsatas = 1
        end
    end
    return self:GetStackCount()
end

function modifier_item_relic_allsatas:GetModifierBonusStats_Agility( params )
	if IsServer() then
        local damag = 0
        if self:GetCaster().lvl_item_relic_allsatas ~= nil then
            if self:GetCaster().lvl_item_relic_allsatas >= 20 then
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * 20)
            else
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_allsatas)
            end
            if damag ~= self:GetStackCount() then
                self:SetStackCount(damag)
            end
        else
            self:GetCaster().lvl_item_relic_allsatas = 1
        end
    end
    return self:GetStackCount()
end

function modifier_item_relic_allsatas:GetModifierBonusStats_Intellect( params )
	if IsServer() then
        local damag = 0
        if self:GetCaster().lvl_item_relic_allsatas ~= nil then
            if self:GetCaster().lvl_item_relic_allsatas >= 20 then
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * 20)
            else
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_allsatas)
            end
            if damag ~= self:GetStackCount() then
                self:SetStackCount(damag)
            end
        else
            self:GetCaster().lvl_item_relic_allsatas = 1
        end
    end
    return self:GetStackCount()
end
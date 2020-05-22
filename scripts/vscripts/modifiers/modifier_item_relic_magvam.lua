modifier_item_relic_magvam = class({})
--------------------------------------------------------------------------------

function modifier_item_relic_magvam:IsHidden()      return false end
function modifier_item_relic_magvam:IsPurgable()    return false end
function modifier_item_relic_magvam:GetTexture()    return "custom/relic_magvam" end

----------------------------------------

function modifier_item_relic_magvam:OnCreated( kv )
    self.needupwawe = true
    if self:GetAbility() ~= nil then
        self.bonus_damage_for_wawe = self:GetAbility():GetSpecialValueFor( "bonus_mana_cst_for_wawe" )
    end
	if IsServer() then self:OnWaweChange(_G.GAME_ROUND) 
    end
end

function modifier_item_relic_magvam:OnWaweChange( wawe )
    if not IsServer() then return end
    
    self.wave = wawe
    local damag = 0
    if self:GetCaster().lvl_item_relic_magvam ~= nil then
        if self:GetCaster().lvl_item_relic_magvam >= 20 then
            damag = math.floor(self.bonus_damage_for_wawe * self.wave * 20)
        else
            damag = math.floor(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_magvam)
        end
        if damag ~= self:GetStackCount() then
            self:SetStackCount(damag)
        end
    else
        self:GetCaster().lvl_item_relic_magvam = 1
    end
end
----------------------------------------

function modifier_item_relic_magvam:DeclareFunctions() return { MODIFIER_EVENT_ON_ABILITY_EXECUTED } end 

----------------------------------------
function modifier_item_relic_magvam:GetModifierSpellLifesteal( params )
    if not IsServer() then return self:GetStackCount() end

    local damag = 0
    if self:GetCaster().lvl_item_relic_magvam ~= nil then
        if self:GetCaster().lvl_item_relic_magvam >= 20 then
            damag = math.floor(self.bonus_damage_for_wawe * self.wave * 20)
        else
            damag = math.floor(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_magvam)
        end
        if damag ~= self:GetStackCount() then
            self:SetStackCount(damag)
        end
    else
        self:GetCaster().lvl_item_relic_magvam = 1
    end
    return self:GetStackCount()
end

function modifier_item_relic_magvam:OnAbilityExecuted( params )
    if not IsServer() or params.unit ~= self:GetCaster() then return 0 end
    
    if not params.ability:IsItem() and not params.ability:IsToggle() then
        for i=0, 6 do
            local abil = self:GetCaster():GetAbilityByIndex(i)
            local coold = abil:GetCooldownTimeRemaining()
            if coold > 0 then
                if coold - 1 > 0 then
                    abil:EndCooldown()
                    abil:StartCooldown(coold-1)
                else
                    abil:EndCooldown()
                end
            end
        end
    end

end
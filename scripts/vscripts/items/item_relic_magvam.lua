item_relic_magvam = class({})

function item_relic_magvam:GetIntrinsicModifierName()
	return "modifier_item_relic_magvam"
end


--------------------------------------------------------------------------------
LinkLuaModifier( "modifier_item_relic_magvam", "items/item_relic_magvam", LUA_MODIFIER_MOTION_NONE )
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
	if  not IsServer() then return end
    self.wave = wawe

    local level = self:GetCaster().lvl_item_relic_damage or 1
    local count = math.ceil(self.bonus_damage_for_wawe * self.wave * Clamp(level, 1, 20)  )
    self:SetStackCount(count)
end
----------------------------------------

function modifier_item_relic_magvam:DeclareFunctions() return { MODIFIER_EVENT_ON_ABILITY_EXECUTED } end

----------------------------------------
function modifier_item_relic_magvam:GetModifierSpellLifesteal( params )
    return self:GetStackCount()
end

function modifier_item_relic_magvam:OnAbilityExecuted( params )
    if  IsServer()
    and not params.unit == self:GetCaster()
    and not params.ability:IsItem()
    and not params.ability:IsToggle()
	then
		for i=0, 6 do
            local abil = self:GetCaster():GetAbilityByIndex(i)
            local cool = abil:GetCooldownTimeRemaining()
            abil:EndCooldown()
            abil:StartCooldown( Clamp(cool-1, 0, cool-1) )
        end
	end
	return 0
end
item_relic_magdam = class({})


function item_relic_magdam:GetIntrinsicModifierName()
	return "modifier_item_relic_magdam"
end

--------------------------------------------------------------------------------
LinkLuaModifier( "modifier_item_relic_magdam", "items/item_relic_magdam", LUA_MODIFIER_MOTION_NONE )
modifier_item_relic_magdam = class({})
--------------------------------------------------------------------------------

function modifier_item_relic_magdam:IsHidden() return false end
function modifier_item_relic_magdam:IsPurgable() return false end
function modifier_item_relic_magdam:GetTexture () return "custom/relic_magdam" end

--------------------------------------------------------------------------------

function modifier_item_relic_magdam:OnCreated( kv )
    self.needupwawe = true
    if self:GetAbility() ~= nil then
        self.bonus_damage_for_wawe = self:GetAbility():GetSpecialValueFor( "bonus_spell_amp_for_wawe" )
    end
	if IsServer() then
        self:OnWaweChange(_G.GAME_ROUND)
    end
end

function modifier_item_relic_magdam:OnWaweChange( wawe )
	if  not IsServer() then return end
    self.wave = wawe

    local level = self:GetCaster().lvl_item_relic_damage or 1
    local count = math.ceil(self.bonus_damage_for_wawe * self.wave * Clamp(level, 1, 20)  )
    self:SetStackCount(count)
end
----------------------------------------

function modifier_item_relic_magdam:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end

----------------------------------------
function modifier_item_relic_magdam:GetModifierSpellAmplify_Percentage( params )
    return self:GetStackCount()
end
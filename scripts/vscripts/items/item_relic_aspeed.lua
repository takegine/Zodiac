item_relic_aspeed = class({})


function item_relic_aspeed:GetIntrinsicModifierName()
	return "modifier_item_relic_aspeed"
end

--------------------------------------------------------------------------------
LinkLuaModifier( "modifier_item_relic_aspeed", "items/item_relic_aspeed", LUA_MODIFIER_MOTION_NONE )
modifier_item_relic_aspeed = class({})
--------------------------------------------------------------------------------

function modifier_item_relic_aspeed:IsHidden() return false end
function modifier_item_relic_aspeed:IsPurgable() return false end
function modifier_item_relic_aspeed:GetTexture () return "custom/relic_attackspeed" end

----------------------------------------

function modifier_item_relic_aspeed:OnCreated( kv )
    self.needupwawe = true
    if self:GetAbility() ~= nil then
        self.bonus_damage_for_wawe = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed_for_wawe" )
    end
	if IsServer() then
        self:OnWaweChange(_G.GAME_ROUND)
    end
end

function modifier_item_relic_aspeed:OnWaweChange( wawe )
	if  not IsServer() then return end
    self.wave = wawe

    local level = self:GetCaster().lvl_item_relic_damage or 1
    local count = math.ceil(self.bonus_damage_for_wawe * self.wave * Clamp(level, 1, 20)  )
    self:SetStackCount(count)
end
----------------------------------------

function modifier_item_relic_aspeed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

----------------------------------------

function modifier_item_relic_aspeed:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetStackCount()
end
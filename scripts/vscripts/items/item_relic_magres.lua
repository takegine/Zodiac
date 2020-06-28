item_relic_magres = class({})

function item_relic_magres:GetIntrinsicModifierName()
	return "modifier_item_relic_magres"
end

--------------------------------------------------------------------------------
LinkLuaModifier( "modifier_item_relic_magres", "items/item_relic_magres", LUA_MODIFIER_MOTION_NONE )
modifier_item_relic_magres = class({})
--------------------------------------------------------------------------------

function modifier_item_relic_magres:IsHidden()  return false end
function modifier_item_relic_magres:IsPurgable() return false end
function modifier_item_relic_magres:GetTexture () return "custom/relic_magres" end

----------------------------------------

function modifier_item_relic_magres:OnCreated( kv )
    self.needupwawe = true
    if self:GetAbility() ~= nil then
        self.bonus_damage_for_wawe = self:GetAbility():GetSpecialValueFor( "bonus_mag_res_for_wawe" )
    end
	if IsServer() then
        self:OnWaweChange(_G.GAME_ROUND)
    end
end

function modifier_item_relic_magres:OnWaweChange( wawe )
	if  not IsServer() then return end
    self.wave = wawe

    local level = self:GetCaster().lvl_item_relic_damage or 1
    local count = math.ceil(self.bonus_damage_for_wawe * self.wave * Clamp(level, 1, 20)  )
    self:SetStackCount(count)
end
----------------------------------------

function modifier_item_relic_magres:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

----------------------------------------

function modifier_item_relic_magres:GetModifierMagicalResistanceBonus( params )
    return self:GetStackCount()
end
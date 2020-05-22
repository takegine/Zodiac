item_relic_damage = class({})
LinkLuaModifier( "modifier_item_relic_damage", "modifiers/modifier_item_relic_damage", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------

function item_relic_damage:GetIntrinsicModifierName()
	return "modifier_item_relic_damage"
end
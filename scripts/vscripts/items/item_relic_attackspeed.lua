item_relic_attackspeed = class({})
LinkLuaModifier( "modifier_item_relic_attackspeed", "modifiers/modifier_item_relic_attackspeed", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------

function item_relic_attackspeed:GetIntrinsicModifierName()
	return "modifier_item_relic_attackspeed"
end
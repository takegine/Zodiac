item_relic_allsatas = class({})
LinkLuaModifier( "modifier_item_relic_allsatas", "modifiers/modifier_item_relic_allsatas", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------

function item_relic_allsatas:OnSpellStart()
	if IsServer() then
		EmitSoundOn( "DOTA_Item.GhostScepter.Activate", self:GetCaster() )

		local kv =
		{
			duration = -1,
			extra_spell_damage_percent = self:GetSpecialValueFor( "extra_spell_damage_percent" ),
		}
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ghost_state", kv )
	end
end

--------------------------------------------------------------------------------

function item_relic_allsatas:OnChannelFinish( bInterrupted )
	if IsServer() then
		self:GetCaster():RemoveModifierByName( "modifier_ghost_state" )
	end
end

function item_relic_allsatas:GetIntrinsicModifierName()
	return "modifier_item_relic_allsatas"
end
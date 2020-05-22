item_finalbook = class({})
LinkLuaModifier( "mod_proved", "modifiers/mod_proved", LUA_MODIFIER_MOTION_NONE )

function item_finalbook:OnSpellStart()
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

function item_finalbook:OnChannelFinish( bInterrupted )
	if IsServer() then
		self:GetCaster():RemoveModifierByName( "modifier_ghost_state" )
	end
end
--------------------------------------------------------------------------------

function item_finalbook:GetIntrinsicModifierName()
	return "mod_proved"
end
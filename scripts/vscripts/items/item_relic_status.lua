item_relic_status = class({})

--------------------------------------------------------------------------------

function item_relic_status:OnSpellStart()
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

function item_relic_status:OnChannelFinish( bInterrupted )
	if IsServer() then
		self:GetCaster():RemoveModifierByName( "modifier_ghost_state" )
	end
end

function item_relic_status:GetIntrinsicModifierName()
	return "modifier_item_relic_status"
end


------------------------------------------------------------------------

LinkLuaModifier( "modifier_item_relic_status", "items/item_relic_status", LUA_MODIFIER_MOTION_NONE )
modifier_item_relic_status = modifier_item_relic_status or class({})
--------------------------------------------------------------------------------

function modifier_item_relic_status:IsHidden()      return false end
function modifier_item_relic_status:IsPurgable()	return false end
function modifier_item_relic_status:GetTexture ()   return "custom/relic_status" end

----------------------------------------

function modifier_item_relic_status:OnCreated( kv )
    self.needupwawe = true

    if  self:GetAbility() then
        self.bonus_damage_for_wawe = self:GetAbility():GetSpecialValueFor( "bonus_all_stats_for_wawe" )
    end

	if  IsServer() then
        self:OnWaweChange(_G.GAME_ROUND)
    end
end

----------------------------------------

function modifier_item_relic_status:OnWaweChange( wawe )
	if  not IsServer() then return end
    self.wave = wawe

    local level = self:GetCaster().lvl_item_relic_damage or 1
    local count = math.ceil(self.bonus_damage_for_wawe * self.wave * Clamp(level, 1, 20)  )
    self:SetStackCount(count)
end

----------------------------------------

function modifier_item_relic_status:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}

	return funcs
end

function modifier_item_relic_status:GetModifierBonusStats_Strength( ... )
    return self:GetStackCount()
end

function modifier_item_relic_status:GetModifierBonusStats_Agility( ... )
    return self:GetStackCount()
end

function modifier_item_relic_status:GetModifierBonusStats_Intellect( ... )
    return self:GetStackCount()
end
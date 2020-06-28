item_relic_damage = item_relic_damage or class({})

--------------------------------------------------------------------------------

function item_relic_damage:GetIntrinsicModifierName()
	return "modifier_item_relic_damage"
end


--------------------------------------------------------------------------------

LinkLuaModifier( "modifier_item_relic_damage", "items/item_relic_damage", LUA_MODIFIER_MOTION_NONE )
modifier_item_relic_damage = modifier_item_relic_damage or class({})
--------------------------------------------------------------------------------
col_ud = 0

function modifier_item_relic_damage:IsHidden()      return false end
function modifier_item_relic_damage:IsPurgable()	return false end
function modifier_item_relic_damage:GetTexture ()   return "custom/relic_damage" end

----------------------------------------

function modifier_item_relic_damage:OnCreated( kv )
    self.needupwawe = true

    if  self:GetAbility() then
        self.bonus_damage_for_wawe = self:GetAbility():GetSpecialValueFor( "bonus_damage_for_wawe" )
    end

	if  IsServer() then
        self:OnWaweChange(_G.GAME_ROUND)
    end
end

----------------------------------------

function modifier_item_relic_damage:OnWaweChange( wawe )
	if  not IsServer() then return end
    self.wave = wawe

    local level = self:GetCaster().lvl_item_relic_damage or 1
    local count = math.ceil(self.bonus_damage_for_wawe * self.wave * Clamp(level, 1, 20)  )
    self:SetStackCount(count)
end

function modifier_item_relic_damage:DeclareFunctions()
	local funcs =
	{
        MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}

	return funcs
end

----------------------------------------
function modifier_item_relic_damage:GetModifierPreAttack_BonusDamage( params )
    return self:GetStackCount()
end

function modifier_item_relic_damage:OnAttackLanded( params )--每打三下有一个额外伤害
    if not  IsServer() or self:GetCaster() ~= params.attacker then return end

    col_ud = col_ud + 1
    if col_ud >= 3 then
        local unts = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, 9999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
        if #unts > 0 then
            local victim = unts[math.random(1,#unts)]
            local caster = self:GetCaster()
            local lightningBolt = ParticleManager:CreateParticle("particles/econ/events/ti9/maelstorm_ti9.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl( lightningBolt, 0, caster:GetAbsOrigin()+ Vector(0,0, caster:GetBoundingMaxs().z) )
            ParticleManager:SetParticleControl( lightningBolt, 1, victim:GetAbsOrigin()+ Vector(0,0, victim:GetBoundingMaxs().z) )
            local damageTable = {
                victim      = victim,
                attacker    = caster,
                damage      = caster:GetAttackDamage() * 1.5,
                damage_type = DAMAGE_TYPE_MAGICAL,
            }
            ApplyDamage(damageTable)--释放1.5倍伤害
        end
        col_ud = 0
    end

end
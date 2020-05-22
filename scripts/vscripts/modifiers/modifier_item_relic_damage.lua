
modifier_item_relic_damage = class({})
--------------------------------------------------------------------------------
col_ud = 0
function modifier_item_relic_damage:IsHidden()      return false end

--------------------------------------------------------------------------------

function modifier_item_relic_damage:IsPurgable()	return false end

function modifier_item_relic_damage:GetTexture ()   return "custom/relic_damage" end

----------------------------------------

function modifier_item_relic_damage:OnCreated( kv )
    self.needupwawe = true
    if  self:GetAbility() ~= nil then
        self.bonus_damage_for_wawe = self:GetAbility():GetSpecialValueFor( "bonus_damage_for_wawe" )
    end
	if  IsServer() then
        self:OnWaweChange(_G.GAME_ROUND)
    end
end

----------------------------------------

function modifier_item_relic_damage:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}

	return funcs
end

----------------------------------------

function modifier_item_relic_damage:OnWaweChange( wawe )--在轮数变化的时候被调用
	if  IsServer() then
        self.wave = wawe
        local damag = 0
        if  self:GetCaster().lvl_item_relic_damage ~= nil then
            if  self:GetCaster().lvl_item_relic_damage >= 20 then
                damag = math.ceil(self.bonus_damage_for_wawe * self.wave * 20)
            else
                damag = math.ceil(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_damage)
            end
            if  damag ~= self:GetStackCount() then
                self:SetStackCount(damag)
            end
        else
            self:GetCaster().lvl_item_relic_damage = 1
        end
    end
end

function modifier_item_relic_damage:GetModifierPreAttack_BonusDamage( params )
	if IsServer() then
        local damag = 0
        if  self:GetCaster().lvl_item_relic_damage ~= nil then
            if  self:GetCaster().lvl_item_relic_damage >= 20 then
                damag = math.ceil(self.bonus_damage_for_wawe * self.wave * 20)
            else
                damag = math.ceil(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_damage)
            end
            if  damag ~= self:GetStackCount() then
                self:SetStackCount(damag)
            end
        else
            self:GetCaster().lvl_item_relic_damage = 1
        end
    end
    return self:GetStackCount()
end

function modifier_item_relic_damage:OnAttackLanded( params )--每打三下有一个额外伤害
	if IsServer() then
        if self:GetCaster() == params.attacker then
            col_ud = col_ud + 1
            if col_ud >= 3 then
                local unts = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, 9999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
                if #unts > 0 then
                    local rand = math.random(1,#unts)
                    local lightningBolt = ParticleManager:CreateParticle("particles/econ/events/ti9/maelstorm_ti9.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
                    ParticleManager:SetParticleControl(lightningBolt,0,Vector(self:GetCaster():GetAbsOrigin().x,self:GetCaster():GetAbsOrigin().y,self:GetCaster():GetAbsOrigin().z + self:GetCaster():GetBoundingMaxs().z ))   
                    ParticleManager:SetParticleControl(lightningBolt,1,Vector(unts[rand]:GetAbsOrigin().x,unts[rand]:GetAbsOrigin().y,unts[rand]:GetAbsOrigin().z + unts[rand]:GetBoundingMaxs().z ))
                    local damageTable = {
                        victim      = unts[rand],
                        attacker    = self:GetCaster(),
                        damage      = self:GetCaster():GetAttackDamage() * 1.5,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                    }
                    --ApplyDamage(damageTable)--释放1.5倍伤害
                end
                col_ud = 0
            end
        end
    end
end
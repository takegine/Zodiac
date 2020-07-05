
modifier_ability_life_steal = modifier_ability_life_steal or class({})

function modifier_ability_life_steal:IsHidden()         return false end
function modifier_ability_life_steal:IsPurgable()	    return false end
function modifier_ability_life_steal:RemoveOnDeath()    return true  end
function modifier_ability_life_steal:GetAttributes()    return   MODIFIER_ATTRIBUTE_MULTIPLE    end
function modifier_ability_life_steal:DeclareFunctions()	return { MODIFIER_EVENT_ON_TAKEDAMAGE } end

function modifier_ability_life_steal:OnCreated( params )
    if IsServer() and not self:GetAbility() then 
        self:Destroy()
        return
    end

    local parent  = self:GetParent()
    local pfxName = "particles/items3_fx/octarine_core_lifesteal.vpcf"
    local pfx_heal= ParticleManager:CreateParticle( pfxName, PATTACH_ABSORIGIN_FOLLOW, parent)
                    ParticleManager:SetParticleControl( pfx, 0, parent:GetAbsOrigin())

    self.lifesteal_pfx = pfx
    self.lifesteal     = params.lifesteal or 0
end

--- Enum DamageCategory_t
-- DOTA_DAMAGE_CATEGORY_ATTACK = 1
-- DOTA_DAMAGE_CATEGORY_SPELL  = 0

function modifier_ability_life_steal:OnTakeDamage( keys )
    local parent = self:GetParent()

    -- 删选无关触发
    if keys.attacker ~= parent 
    or keys.unit:IsBuilding() 
    or keys.unit:IsOther() 
    or keys.inflictor 
    or keys.damage_category ~= DOTA_DAMAGE_CATEGORY_SPELL 
    or parent:FindAllModifiersByName(self:GetName())[1] ~= self 
    or bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL 
    then return 
    end

    -- 释放粒子特效
    ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)

    -- 触发声音事件
    parent:EmitSound("Hero_Zuus.StaticField")
    
    -- 在攻击幻象时，治疗不受幻象改变的传入伤害值的影响。
    -- 这是非常粗略的，因为imba作者称其不知道有任何接口方法可以直接获取给玩家对幻象单位的 造成/输出 伤害，
    -- 或者在您击中幻象单位时给您“显示的”伤害，这些幻像显示出的数字就像您在攻击非幻象单位。
    -- 这里用到了一个拓展的API是imba独有的：GetReductionFromArmor

    -- if keys.unit:IsIllusion() then
    --     if keys.damage_type == DAMAGE_TYPE_PHYSICAL 
    --         and keys.unit.GetPhysicalArmorValue 
    --         and GetReductionFromArmor 
    --         then keys.damage = keys.original_damage * (1 - GetReductionFromArmor(keys.unit:GetPhysicalArmorValue(false)))

    --     elseif keys.damage_type == DAMAGE_TYPE_MAGICAL 
    --         and keys.unit.GetMagicalArmorValue 
    --         then keys.damage = keys.original_damage * (1 - GetReductionFromArmor(keys.unit:GetMagicalArmorValue()))

    --     elseif keys.damage_type == DAMAGE_TYPE_PURE 
    --         then keys.damage = keys.original_damage
    --     end
    -- end

    local backheal = math.max( keys.damage, 0) * self.lifesteal / 100
    parent:Heal(backheal, parent)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, backheal, nil)

end

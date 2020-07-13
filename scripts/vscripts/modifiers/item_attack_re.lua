function Attack( event )
	local target = event.target
	local caster = event.caster
	local ability	= event.ability
    if not caster:IsIllusion() then
        if caster.att_target then
            if not  caster.att_target:IsNull() 
            and     caster.att_target:IsAlive() then
                    caster.att_target:RemoveModifierByName("modifier_item_void_fire_damage")
            end
        end
        ability:ApplyDataDrivenModifier( caster, target, "modifier_item_void_fire_damage", {} )
        caster.att_target = target
    end
end

-- Keeps track of the targets health
function OnTakeDamage( event )
    --DeepPrintTable(event)
	local damage = event.Damage * event.Perc / 100
	local caster = event.caster
	local ability= event.ability
    
    if caster:IsIllusion()
    or caster:GetAttackCapability() ~= 1
    or not caster.att_target
    or caster.att_target == caster
    or damage <= 1 
    then return
    end
    local pfxName  = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( pfxName, PATTACH_ABSORIGIN, caster.att_target )
	ParticleManager:SetParticleControlEnt( nFXIndex, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin(), true )
	local damageTable = {
        victim      = caster.att_target,
        attacker    = caster,
        damage      = damage,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL, --Optional.
        ability     = ability --Optional.
    }
    ApplyDamage(damageTable)
end
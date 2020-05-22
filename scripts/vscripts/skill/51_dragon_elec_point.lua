function Cast( event )
	local caster	= event.caster
	local ability	= event.ability
	local center	= Entities:FindByName( nil, "boss_center"):GetAbsOrigin()
    
    local vPos = center + RandomVector( RandomInt( 50, 2500 ) )
    -- Spawn a new spirit
    local newSpirit = CreateUnitByName( "npc_dota_wisp_spirit", vPos, false, caster, caster, caster:GetTeam() )
    newSpirit.pfx = ParticleManager:CreateParticle("particles/dragon/electro_orb.vpcf", PATTACH_ABSORIGIN, newSpirit)
    -- Apply the spirit modifier
    ability:ApplyDataDrivenModifier( newSpirit, newSpirit, event.spirit_modifier, {} )

    --particles/dragon/electro_orb.vpcf
end

function Triggered( event )
	local caster = event.caster
	local ability = event.ability
    local target = event.target
    
    local lightningBolt = ParticleManager:CreateParticle("particles/econ/items/zeus/zeus_ti8_immortal_arms/zeus_ti8_immortal_arc.vpcf", PATTACH_WORLDORIGIN, ability:GetCaster())
    ParticleManager:SetParticleControl(lightningBolt,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))   
    ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
    local damageTable = {
        victim = target,
        attacker = ability:GetCaster(),
        damage = 100,
        damage_type = DAMAGE_TYPE_MAGICAL,
    }
    ApplyDamage(damageTable)

    ParticleManager:DestroyParticle( caster.pfx, false )
    caster:ForceKill(false)
    -- Kill this unit immediately.
end
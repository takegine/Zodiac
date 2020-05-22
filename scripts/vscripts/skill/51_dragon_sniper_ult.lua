--[[
	Author: Ractidous
	Date: 09.02.2015.
	Cast spirits.
]]
function Cast( event )
	
	local caster	= event.caster
	local ability	= event.ability
	local target	= event.target
	local center	= Entities:FindByName( nil, "boss_center"):GetAbsOrigin()

	ability.spirits_numSpirits = 0		-- Use this rather than "#spirits_spiritsSpawned"
    
	if ability.spirits_spiritsSpawned == nil then
        ability.spirits_spiritsSpawned = {}
        for i=1, 8 do
            -- Spawn a new spirit
            local newSpirit = CreateUnitByName( "npc_dota_wisp_spirit", center, false, caster, caster, caster:GetTeam() )

            -- Update the state
            local spiritIndex = ability.spirits_numSpirits + 1
            newSpirit.spirit_index = spiritIndex
            ability.spirits_numSpirits = spiritIndex
            ability.spirits_spiritsSpawned[spiritIndex] = newSpirit

            -- Apply the spirit modifier
            ability:ApplyDataDrivenModifier( caster, newSpirit, event.spirit_modifier, {} )

        --for k,v in pairs( ability.spirits_spiritsSpawned ) do

            -- Rotate
            local rotationAngle = 0 - 45 * ( i - 1 )
            local relPos = Vector( 0, 3000, 0 )
            relPos = RotatePosition( Vector(0,0,0), QAngle( 0, -rotationAngle, 0 ), relPos )

            local absPos = GetGroundPosition( relPos + center, newSpirit )

            newSpirit:SetAbsOrigin( absPos )

        --end
        end
    end
    target:AddNewModifier( caster, ability, "modifier_sniper_assassinate", { duration = 6 } )

    for i=1, 8 do
        Timers:CreateTimer(1.8+0.3*i, function()
            local info = 
            {
                EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf";
                Target = target,
                Source = ability.spirits_spiritsSpawned[i],
                Ability = ability,
                iMoveSpeed = 2000
            }

            ProjectileManager:CreateTrackingProjectile( info )
            EmitSoundOn( "Ability.Assassinate", ability.spirits_spiritsSpawned[i] )
            EmitSoundOn( "Hero_Sniper.AssassinateProjectile", ability.spirits_spiritsSpawned[i] )
        end)
    end
end

-- Author: 西索酱
-- Date: 03.07.2020.
-- 开始这个技能

spirit_speed = 0
col_spirits  = 0
max_sp = 3 + 4 * _G.hardmode

spirit_list  = {}

function CastSpirits( event )
    print("CastSpirits")
    local caster  = event.caster
    local ability = event.ability

    ability.start = GameRules:GetGameTime()
    caster.radius = event.default_radius

end


-- Author: 西索酱
-- Date: 03.07.2020.
-- 更新精灵护卫

wtfparams = true
function ThinkSpirits( event )
    local caster	= event.caster
    local ability	= event.ability
    local spirit_mod= event.spirit_modifier
    local casterOrigin	= caster:GetAbsOrigin()

    --------------------------------------------------------------------------------
    -- Validate the number of spirits summoned
    
    --小精灵不足数就创建小精灵
    if #spirit_list < max_sp then
        -- 创建新的小精灵
        local newSpirit = CreateUnitByName( "npc_dota_custom_creep_05_3", casterOrigin, false, caster, caster, caster:GetTeam() )

        -- 创建粒子
        newSpirit.pfx = ParticleManager:CreateParticle( event.spirit_particle_name, PATTACH_ABSORIGIN_FOLLOW, newSpirit )

        table.insert(spirit_list, newSpirit)
        ability:ApplyDataDrivenModifier( caster, newSpirit, spirit_mod, {} )
        
        col_spirits = col_spirits + 1
    end
    --------------------------------------------------------------------------------
    -- 更新精灵圈的半径
    --
    local currentRadius	= caster.radius + ( wtfparams and - 3 or 3) 

    -- Clamp(currentRadius , event.min_range , event.max_range)
    if wtfparams and currentRadius < event.min_range then
        wtfparams = false
	elseif currentRadius > event.max_range then
		wtfparams = true
    end

    caster.radius = currentRadius
    --------------------------------------------------------------------------------
    -- 更新精灵护卫 的坐标
    --
    
    if col_spirits == max_sp then
        spirit_speed = spirit_speed < 50 and spirit_speed + 0.3 or 200
    end

    local currentRotationAngle = (GameRules:GetGameTime() - ability.start) * spirit_speed

    for k,v in pairs( spirit_list ) do

        -- Rotate
        local rotationAngle = currentRotationAngle - (360 / max_sp) * ( k - 1 )
        local relPos = RotatePosition( Vector(0,0,0), QAngle( 0, -rotationAngle, 0 ), Vector( 0,  currentRadius, 0 ) )

        v:SetAbsOrigin( GetGroundPosition( relPos + casterOrigin, v ) )

        -- Update particle
        ParticleManager:SetParticleControl( v.pfx, 1, Vector( currentRadius, 0, 0 ) )

    end

    if col_spirits == max_sp and numSpiritsAlive == 0 then
        -- All spirits have been exploded.
        caster:RemoveModifierByName( event.caster_modifier )
    end

end


-- Author: 西索酱
-- Date: 03.07.2020.
-- 清空精灵护卫

function EndSpirits( event )
    print("EndSpirits")
    local caster	= event.caster
    local ability	= event.ability

        for k,v in pairs( spirit_list ) do
            print("EndSpirits",k,v)
            v:RemoveModifierByName(  event.spirit_modifier )
        end

    StopSoundEvent( event.sound_name, event.caster )
end


-- Author: 西索酱
-- Date: 03.07.2020.
-- 检测与英雄碰撞的修改器。

function OnCreatedSpirit( event )
    
    print("OnCreatedSpirit")
    local spirit = event.target
    local ability = event.ability

    -- Set the spirit to caster
    Timers:CreateTimer(0.01, function()
        ability:ApplyDataDrivenModifier( spirit, spirit, event.additionalModifier, {} )
    end)
    
end


-- Author: 西索酱
-- Date: 03.07.2020.
-- 摧毁这个精力护卫

function OnDestroySpirit( event )
    
    print("OnDestroySpirit")
    
    local spirit	= event.target
    local ability	= event.ability
    
    ParticleManager:DestroyParticle( spirit.pfx, false )

    -- Create vision
    ability:CreateVisibilityNode( spirit:GetAbsOrigin(), event.vision_radius, event.vision_duration )

    -- Kill
    -- spirit:SetTeam(2)
    spirit:ForceKill( true )

end


-- Author: 西索酱
-- Date: 03.07.2020.
-- 撞到敌方英雄就爆炸

function ExplodeSpirit( event )
    print("ExplodeSpirit")
    local spirit	= event.caster

    if not spirit.spirit_isExploded then

        spirit.spirit_isExploded = true
        -- Remove from the list of spirits
        
        for k,v in pairs( spirit_list ) do
            if v==spirit then
                table.remove(spirit_list,k)
                v:RemoveModifierByName(  event.spirit_modifier )
                break
            end
        end

        -- Fire the hit sound
        StartSoundEvent( event.explosion_sound, spirit )
        --spirit:RemoveSelf()--
    end
end


    -- Author: 西索酱
    -- Date: 29.01.2015.
    -- Stop a sound.

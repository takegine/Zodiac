--[[
	Author: Ractidous
	Date: 27.01.2015.
	Create the particle effect and projectiles.
]]
function FireMacropyre( event )
	local caster		= event.caster
	local ability		= event.ability

	local pathLength	= event.cast_range  * math.pow(1.3, _G.hardmode-1)
	local pathRadius	= event.path_radius 
	local duration		= event.duration * math.pow(1.3, _G.hardmode-1)

	local startPos = caster:GetAbsOrigin()
	local endPos = startPos + caster:GetForwardVector() * pathLength

    --把三个值写入技能，方便其他地方调用
	ability.macropyre_startPos	 = startPos
	ability.macropyre_endPos 	 = endPos
	ability.macropyre_expireTime = GameRules:GetGameTime() + duration

	-- 为技能的实体添加粒子特效
	local particleName = "particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, endPos )
	ParticleManager:SetParticleControl( pfx, 2, Vector( duration, 0, 0 ) )
	ParticleManager:SetParticleControl( pfx, 3, startPos )

	-- 创建技能的投射物
	pathRadius = math.max( pathRadius, 64 )
	local projectileRadius = pathRadius * math.sqrt(2)				--投射物半径？
	local numProjectiles = math.floor( pathLength / (pathRadius*2) )--投射物的数量为 长度除以直径 
	local stepLength = pathLength /  numProjectiles 				--某长度，实值为直径的浮点数

	local dummyModifierName = "modifier_macropyre_destroy_tree_datadriven"

	for i=0, numProjectiles do
		local projectilePos = startPos + caster:GetForwardVector() * i * stepLength --位置

		ProjectileManager:CreateLinearProjectile( {
			Ability				= ability,
		--	EffectName			= "",
			vSpawnOrigin		= projectilePos,	--始发地点
			fDistance			= 64,
			fStartRadius		= projectileRadius,	--起始半径
			fEndRadius			= projectileRadius,	--结束半径
			Source				= caster,			--创建者
			bHasFrontalCone		= false,			--有椎体
			bReplaceExisting	= false,			--替代现有(投射器?)
			iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,						--目标队伍--ability:GetAbilityTargetTeam()
			iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,						--目标标记
			iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,   --目标类型--ability:GetAbilityTargetType()
			fExpireTime			= ability.macropyre_expireTime,--持续时间
			bDeleteOnHit		= false,					--碰撞后后消失
			vVelocity			= Vector( 0, 0, 0 ),		-- Don't move!
			bProvidesVision		= false,					--提供视野
		--	iVisionRadius		= 0,						--提供视野半径
		--	iVisionTeamNumber	= caster:GetTeamNumber(),	--提供视野
		--[[EffectName			: string	
			Ability?			: CDOTABaseAbility
			Source?				: CDOTA_BaseNPC
			vSpawnOrigin?		: Vector
			vVelocity?			: Vector
			vAcceleration?		: Vector					--加速度，含方向
			fMaxSpeed?			: float						--最大速度
			fDistance?			: float
			fStartRadius?		: float
			fEndRadius?			: float
			fExpireTime?		: float
			iUnitTargetTeam?	: DOTA_UNIT_TARGET_TEAM
			iUnitTargetFlags?	: DOTA_UNIT_TARGET_FLAGS
			iUnitTargetType?	: DOTA_UNIT_TARGET_TYPE
			bIgnoreSource?		: bool
			bHasFrontalCone?	: bool
			bDrawsOnMinimap?	: bool
			bVisibleToEnemies?	: bool
			bProvidesVision?	: bool
			iVisionRadius?		: uInt
			iVisionTeamNumber?	: DOTATeam_t
			ExtraData?: Record<string, string | number | boolean>]]
		} )

		-- 投射物会摧毁树木 Create dummy to destroy trees
		if i~=0 and GridNav:IsNearbyTree( projectilePos, pathRadius, true ) then
			local dummy = CreateUnitByName( "npc_dota_thinker", projectilePos, false, caster, caster, caster:GetTeamNumber() )
			ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
		end
	end
end

--[[
	Author: Ractidous
	Data: 27.01.2015.
	Apply a dummy modifier that periodcally checks whether the target is within the macropyre's path.
]]
function ApplyDummyModifier( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local modifierName = event.modifier_name

	local duration = ability.macropyre_expireTime - GameRules:GetGameTime()

	ability:ApplyDataDrivenModifier( target, target, modifierName, { duration = duration } )
end

--[[
	Author: Ractidous
	Date: 27.01.2015.
	Check whether the target is within the path, and apply damage if neccesary.
]]
function CheckMacropyre( event )
	local caster		= event.caster
	local target		= event.target
	local ability		= event.ability
	local pathRadius	= event.path_radius 
	local damage		= event.damage * math.pow(1.3, _G.hardmode-1)

	local burn_interval		= event.burn_interval

	local targetPos = target:GetAbsOrigin()
	targetPos.z = 0
    if ability ~= nil then
	local distance = DistancePointSegment( targetPos, ability.macropyre_startPos, ability.macropyre_endPos )--目标位置，技能起始点，技能结束点
	if distance < pathRadius then
		--print("Apply damage " .. damage .. " * " .. burn_interval)
		ApplyDamage( {
			ability = ability,
			attacker = caster,
			victim = target,
			damage = damage * burn_interval,
			damage_type = ability:GetAbilityDamageType(),
		} )
	end
    end
end

--[[
	Author: Ractidous
	Date: 27.01.2015.
	Distance between a point and a segment.
]]
function DistancePointSegment( p, v, w )
	local l = w - v
	local l2 = l:Dot( l )
	t = ( p - v ):Dot( w - v ) / l2
	if t < 0.0 then
		return ( v - p ):Length2D()
	elseif t > 1.0 then
		return ( w - p ):Length2D()
	else
		local proj = v + t * l
		return ( proj - p ):Length2D()
	end
end
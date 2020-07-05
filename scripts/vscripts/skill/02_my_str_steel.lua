

function OnAttack( event )
    local caster  = event.caster
    local target  = event.target
    local ability = event.ability
    
    local modif   = target:FindModifierByName("modifier_decrease_strength")

    if not modif then

        target:AddNewModifier(target, ability, "modifier_decrease_strength", {duration = 30})
        modif:IncrementStackCount()
    else
        modif:SetDuration(30,true)
    end
    
    for i =1,_G.hardmode do
        modif:IncrementStackCount() 
    end
    print("round 02 ,the modifier count equal the level of hardmode："..modif:GetStackCount().."now hardmode is:".._G.hardmode)
end

LinkLuaModifier("modifier_decrease_strength","skill/02_my_str_steel", LUA_MODIFIER_MOTION_NONE)
modifier_decrease_strength = class ({})

function modifier_decrease_strength:GetTexture ()
    return "undying_decay"
end

function modifier_decrease_strength:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}
 
	return funcs
end

function modifier_decrease_strength:IsDebuff()
	return true
end

function modifier_decrease_strength:GetModifierBonusStats_Strength( params )
	return -self:GetStackCount()
end
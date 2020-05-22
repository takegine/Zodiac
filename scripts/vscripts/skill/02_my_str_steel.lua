LinkLuaModifier("my_str_debuff","modifiers/02_my_str_debuff", LUA_MODIFIER_MOTION_NONE)

function OnAttack( event )
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    
    if target:FindModifierByName("my_str_debuff") == nil then
        target:AddNewModifier(target,ability,"my_str_debuff",{duration = 30})
        local modif = target:FindModifierByName("my_str_debuff")
        modif:IncrementStackCount()
        for i =1,_G.hardmode do modif:IncrementStackCount() end
        print("round 02 ,the modifier count equal the level of hardmode："..modif:GetStackCount().."now hardmode is:".._G.hardmode)
   
    else
        local modif = target:FindModifierByName("my_str_debuff")
        modif:SetDuration(30,true)
        for i =1,_G.hardmode do modif:IncrementStackCount() end
    	print("round 02 ,the modifier count equal the level of hardmode："..modif:GetStackCount(),"now hardmode is:".._G.hardmode)
      
    end
    
end
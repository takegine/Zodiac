--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called whenever one of Slark's autoattack lands.  If it hit an enemy hero, it steals attribute points from them 
	and leaves a counter on their modifier HUD.
	Additional parameters: keys.StatLoss
================================================================================================================= ]]
function modifier_slark_essence_shift_datadriven_on_attack_landed(keys)
	if keys.target:IsHero() and keys.target:IsOpposingTeam(keys.caster:GetTeam()) then
		--For the affected enemy, increment their visible counter modifier's stack count.
		local previous_stack_count = 0
		local debuff = nil
		if keys.target:HasModifier("modifier_slark_essence_shift_datadriven_debuff_counter") then
			debuff = keys.target:FindModifierByName("modifier_slark_essence_shift_datadriven_debuff_counter")
			previous_stack_count = debuff:GetStackCount()
		else
			debuff = keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_slark_essence_shift_datadriven_debuff_counter", nil)
		end
		debuff:SetDuration(30,true)
		debuff:SetStackCount(previous_stack_count + 1)	
		
		--Apply a stat debuff to the target StatLoss number of times.  Attributes bottom out at 0, so we do not need to worry about
		--applying more debuffs than attribute points the target currently has.  This is the way the stock Essence Shift works.
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_slark_essence_shift_datadriven_debuff", nil)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called whenever an Essence Shift debuff on an opponent expires.  Decrements their debuff counter by one.
================================================================================================================= ]]
function modifier_slark_essence_shift_datadriven_debuff_on_destroy(keys)
	if keys.target:HasModifier("modifier_slark_essence_shift_datadriven_debuff_counter") then
		local debuff = keys.target:FindModifierByName("modifier_slark_essence_shift_datadriven_debuff_counter")
		local previous_stack_count = debuff:GetStackCount()
		if previous_stack_count > 1 then
			debuff:SetStackCount(previous_stack_count - 1)
		else
			keys.target:RemoveModifierByName("modifier_slark_essence_shift_datadriven_debuff_counter")
		end
	end
end
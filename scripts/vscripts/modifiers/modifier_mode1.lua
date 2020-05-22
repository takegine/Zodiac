modifier_easy_mode = class({})

function modifier_easy_mode:IsHidden() return false end 		--死亡掉落
function modifier_easy_mode:IsPurgable() return false end 		--不可驱散
function modifier_easy_mode:IsPurgeException() return false end --不可强驱散
function modifier_easy_mode:RemoveOnDeath() return false end 	--死亡掉落

function modifier_easy_mode:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,--增加受到的伤害，值在回调GetModifierIncomingDamage_Percentage()
	}

	return funcs
end

function modifier_easy_mode:GetModifierIncomingDamage_Percentage() return -15 end
function OnCreatedDebuff( event )--round1
    event.target:SetModelScale(0.5)
end

function OnDestroyDebuff( event )--round1
    local target = event.target
    target:SetModelScale(0.9)
    target:SetBaseDamageMin(21+_G.hardmode*5)
    target:SetBaseDamageMax(19+_G.hardmode*8)
    
end

function my_death_puls( event )--round3
    event.target:SetModelScale(event.target:GetModelScale() + 0.2)
end

function OnCreated(event)--round9
    if event.caster:GetHealth() < event.caster:GetMaxHealth() then
        ExecuteOrderFromTable({
            UnitIndex = event.caster:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
            AbilityIndex = event.ability:entindex(),
            Queue = false,
        })
    end
end

function DestroyAura(event)--round13
    target = event.target
    print(target)
	JumpAbility = target:FindAbilityByName( "my_lone_druid_true_form_datadriven" )
    
    if JumpAbility ~= nil and target:IsAlive() then
    ExecuteOrderFromTable({
		UnitIndex = target:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = JumpAbility:entindex(),
		Queue = false,
	})
    end
end

function OnTakeDamage(event)--round15
    local target = event.caster
    target:SetAcquisitionRange(9999)
end

function Triggered (event)--round20---phoenix_supernova_datadriven
    caster = event.caster
    
    if caster:GetHealth() < 3 then
        caster:SetHealth(50000)
        local novaAbility = caster:FindAbilityByName( "phoenix_supernova_datadriven" )
        novaAbility:StartCooldown(9999)
        caster:RemoveModifierByName("nova_trigger")
    end
end
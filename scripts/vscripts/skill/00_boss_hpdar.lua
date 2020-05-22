function OnCreated(event)
    Timers:CreateTimer(0.1, function()

	--print("kkkkkkkkksss..1。。")
        local caster = event.target
        if caster ~= nil then
            if not caster:IsIllusion() then
                CustomGameEventManager:Send_ServerToAllClients( "createhp", {name="hp_bar",text = "#HPBar", svalue = caster:GetHealth(),evalue=caster:GetMaxHealth()})
                CustomGameEventManager:Send_ServerToAllClients( "refreshhpdata", {name="hp_bar",text = "#HPBar", svalue = caster:GetHealth(),evalue=caster:GetMaxHealth()})
            end
        end
    end)
end

function OnDestroy(event)
    local caster = event.target
    if caster ~= nil then
        if not caster:IsIllusion() then
            CustomGameEventManager:Send_ServerToAllClients( "removehppui", {name="hp_bar"})
        end
    end
end

function OnIntervalThink(event)
	--print("kkkkkkkkksss..2。。")
    local caster = event.target
    if caster ~= nil then
        if not caster:IsIllusion() then
            CustomGameEventManager:Send_ServerToAllClients( "refreshhpdata", {name="hp_bar",text = "#HPBar", svalue = caster:GetHealth(),evalue=caster:GetMaxHealth()})
            
        end
    end
end
--------------------------------上面的是BOSS血条---下面是真视-----------------------------------------------------------------------


function OnIntervalThink2( event )--my_gem_datadriven
    event.target:RemoveModifierByName("modifier_phantom_assassin_blur_active")
end
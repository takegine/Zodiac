function OnCreated(event)
        local caster = event.target
        if caster and not caster:IsIllusion() then
            sentmes = {
                name   = "hp_bar",
                text   = "#HPBar", 
                svalue = caster:GetHealth(),
                evalue = caster:GetMaxHealth()
            }
            CustomGameEventManager:Send_ServerToAllClients( "createhp", sentmes )
            CustomGameEventManager:Send_ServerToAllClients( "refreshhpdata", sentmes )
        end
end

function OnDestroy(event)
    local caster = event.target
    if  caster and not caster:IsIllusion() then
        CustomGameEventManager:Send_ServerToAllClients( "removehppui", {name="hp_bar"})
    end
end

function OnIntervalThink(event)
    local caster = event.target
    if caster and not caster:IsIllusion() then
        sentmes = {
            name   = "hp_bar",
            text   = "#HPBar", 
            svalue = caster:GetHealth(),
            evalue = caster:GetMaxHealth()
        }
        CustomGameEventManager:Send_ServerToAllClients( "refreshhpdata", sentmes)
    end
end
--------------------------------上面的是BOSS血条---下面是真视-----------------------------------------------------------------------


function OnIntervalThink2( event )--my_gem_datadriven
    event.target:RemoveModifierByName("modifier_phantom_assassin_blur_active")
end
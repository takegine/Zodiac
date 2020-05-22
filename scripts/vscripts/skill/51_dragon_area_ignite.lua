dragon_area_ignite = class ({})
LinkLuaModifier( "modifier_dragon_area_ignite_thinker", "modifiers/modifier_dragon_area_ignite_thinker", LUA_MODIFIER_MOTION_NONE )

----------------------------------------------------------------------------------------

function dragon_area_ignite:OnSpellStart()
    if IsServer() then
        self.hThinker = {}
        --print(self:GetCursorPosition())
        for i=1,50 do
            table.insert(self.hThinker, CreateModifierThinker( self:GetCaster(), self, "modifier_dragon_area_ignite_thinker", { duration = -1 }, Vector(3180-i*125,-8185,256), self:GetCaster():GetTeamNumber(), false ))
            local hBuff = self.hThinker[i]:FindModifierByName( "modifier_dragon_area_ignite_thinker" )
            
            Timers:CreateTimer(i*0.05, function()
                hBuff:OnIntervalThink()
            end)
        end

        local info = 
        {
            Ability = self,
                EffectName = "particles/dragon/spectre_ti7_crimson_spectral_dagger_2.vpcf",
                vSpawnOrigin = self.hThinker[1]:GetAbsOrigin()+Vector(1000,0,0),
                fDistance = 7500,
                fStartRadius = 200,
                fEndRadius = 200,
                Source = self.hThinker[1],
                --bHasFrontalCone = false,
                --bReplaceExisting = false,
                --fExpireTime = GameRules:GetGameTime() + 10.0,
            --bDeleteOnHit = false,
            vVelocity = Vector(-2500,0,0)
        }
        ProjectileManager:CreateLinearProjectile(info)
    end
end

----------------------------------------------------------------------------------------
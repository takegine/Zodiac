function CheckToPickGold(keys)
    local target = keys.target
	if not target:IsRealHero() then return end

    table.foreach(Entities:FindAllByClassnameWithin("dota_item_drop", target:GetAbsOrigin(), 175),
        function(_, drop_item)
            local containedItem = drop_item:GetContainedItem() --其中的禁用物品
            if containedItem and containedItem:GetName()=="item_25gold"
            and GameRules:GetGameTime() - drop_item:GetCreationTime() > 0.5 then
                print("pick up a gold，time:",GameRules:GetGameTime() - drop_item:GetCreationTime())
                GivenGold()
                UTIL_Remove( containedItem)
                UTIL_Remove( drop_item )
            end
        end)
end

function CheckToPickAllGold(keys)
	local caster = keys.caster
    table.foreach(Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetAbsOrigin(), 9999),
        function(_, drop_item)
	    local containedItem = drop_item:GetContainedItem()
        if containedItem
        and containedItem:GetName()=="item_25gold"
        and GameRules:GetGameTime() - drop_item:GetCreationTime() > 10
        and drop_item:GetOrigin().z > caster:GetAbsOrigin().z then
            GivenGold()
            UTIL_Remove( containedItem)
            UTIL_Remove( drop_item )
        end

	end)
end

function CheckElements(keys)
	local caster = keys.caster
    table.foreach(Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetAbsOrigin(), 9999),
        function(_, drop_item)
            local containedItem = drop_item:GetContainedItem()
            if containedItem
            and GameRules:GetGameTime() - drop_item:GetCreationTime() > 5 then

                local partlist = {}
                partlist.item_water  ={2,"particles/econ/events/ti7/maelstorm_ti7.vpcf"}
                partlist.item_void   ={4,"particles/econ/events/ti9/maelstorm_ti9.vpcf"}
                partlist.item_fire   ={6,"particles/econ/events/ti6/maelstorm_ti6.vpcf"}
                partlist.item_light  ={7,"particles/units/heroes/hero_lion/lion_spell_finger_of_death_orig.vpcf"}
                partlist.item_air    ={8,"particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf"}
                partlist.item_ice    ={9,"particles/units/heroes/hero_techies/techies_stasis_trap_beams.vpcf"}
                partlist.item_energy ={10,"particles/econ/events/ti8/maelstorm_ti8.vpcf"}

                partlist.item_life   ={1,"particles/econ/events/battlecup/battle_cup_summer2016_destroy.vpcf"}
                partlist.item_shadow ={3,"particles/units/heroes/hero_grimstroke/grimstroke_phantom_return.vpcf"}
                partlist.item_earth  ={5,"particles/units/heroes/hero_grimstroke/grimstroke_phantom_ambient.vpcf"}

                local t = partlist[containedItem:GetName()]
                if t then

                    local nFXIndex = ParticleManager:CreateParticle( t[2], PATTACH_ABSORIGIN, drop_item )
                    ParticleManager:SetParticleControl( nFXIndex, 0, drop_item:GetAbsOrigin() )
                    ParticleManager:SetParticleControl( nFXIndex, 1, containedItem:GetPurchaser():GetAbsOrigin() )
                    ParticleManager:SetParticleControlEnt( nFXIndex, 1, containedItem:GetPurchaser(), PATTACH_POINT_FOLLOW, "attach_hitloc", containedItem:GetPurchaser():GetOrigin(), true )
                    ParticleManager:ReleaseParticleIndex( nFXIndex )

                    local id = containedItem:GetPurchaser():GetPlayerID()
                    local myTable = CustomNetTables:GetTableValue("Elements_Tabel",tostring(id))
                    myTable[tostring(t[1])] = myTable[tostring(t[1])] + 1
                    CustomNetTables:SetTableValue("Elements_Tabel",tostring(id),myTable)
                    UTIL_Remove( containedItem)
                    UTIL_Remove( drop_item )
                end
            end
	    end)
end


function GivenGold()

    local plc  = PlayerResource:GetPlayerCount()
    local gold = 280 / (plc + 2)
    for id = 0, plc-1 do
        if  PlayerResource:IsValidPlayer( id )
        and PlayerResource:HasSelectedHero( id ) then
            local hero = PlayerResource:GetSelectedHeroEntity( id )
            SendOverheadEventMessage( hero, OVERHEAD_ALERT_GOLD, hero, gold, nil )
            PlayerResource:ModifyGold( id, gold, true, DOTA_ModifyGold_Unspecified )
        end
    end
end
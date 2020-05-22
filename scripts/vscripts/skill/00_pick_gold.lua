function CheckToPickGold(keys)--捡钱
    local target	= keys.target--建一个本地变量，值为参数中的target
	if target:IsRealHero() then --如果是玩家操作的英雄，非幻象
		local drop_items=Entities:FindAllByClassnameWithin("dota_item_drop",target:GetAbsOrigin(),175)--建一个本地实体，值为英雄175的半径内，符合"dota_item_drop"中类名
		for _, drop_item in pairs(drop_items) do     -- 遍历刚刚建的实体中的drop_item
	    local containedItem = drop_item:GetContainedItem() --local其中的禁用物品
	        if containedItem and containedItem:GetName()=="item_25gold" then --如果有禁用物品，且名为"item_25gold"
                if GameRules:GetGameTime() - drop_item:GetCreationTime() > 0.5 then --且出现时间在开局0.5以后
                    print("pick up a gold",GameRules:GetGameTime() - drop_item:GetCreationTime())
                    local plc = PlayerResource:GetPlayerCount()--获得没有缺少的玩家数，这个是5人游戏，如果只有3个人开图，那么这个值就是2
    	            local value= 280 / (plc + 2) --算出每人分多少钱
             	    for nPlayerID = 0, plc-1 do --遍历所有玩家
    				    if PlayerResource:IsValidPlayer( nPlayerID ) and PlayerResource:HasSelectedHero( nPlayerID ) then --如果是有效玩家且选了英雄
    						local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID ) --标记出获得玩家所选英雄的实体
                            SendOverheadEventMessage( hero, OVERHEAD_ALERT_GOLD, hero, value, nil ) --在这个英雄实体的头上显示分到手的钱的数目
                            PlayerResource:ModifyGold(nPlayerID,value,true,DOTA_ModifyGold_Unspecified)--把钱给该玩家
    				    end
    			    end
    			    UTIL_Remove(containedItem) --删除本地变量，优化内存             
    	            UTIL_Remove( drop_item )
                end
	        end
	    end
	end
end

function CheckToPickAllGold(keys)--没捡起来的钱自动捡起来
	local caster	= keys.caster --未知
    local drop_items= Entities:FindAllByClassnameWithin("dota_item_drop",caster:GetAbsOrigin(),99999)--全地图的中符合"dota_item_drop"中类名实体
	for _, drop_item in pairs(drop_items) do     
	    local containedItem = drop_item:GetContainedItem()
	    if containedItem then
            if containedItem:GetName()=="item_25gold" then
                if GameRules:GetGameTime() - drop_item:GetCreationTime() > 10 then
                    if drop_item:GetOrigin().z > caster:GetAbsOrigin().z then
                        local plc = PlayerResource:GetPlayerCount()
                        local value= (280 / (plc + 2))
                        for nPlayerID = 0, plc-1 do
                            if PlayerResource:IsValidPlayer( nPlayerID ) and PlayerResource:HasSelectedHero( nPlayerID ) then
                                local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
                                SendOverheadEventMessage( hero, OVERHEAD_ALERT_GOLD, hero, value, nil )
                                PlayerResource:ModifyGold(nPlayerID,value,true,DOTA_ModifyGold_Unspecified)
                                
                            end
                        end
                        UTIL_Remove(containedItem)
                        UTIL_Remove( drop_item )
                    end
                end
            end
	    end
	end
end

function CheckElements(keys)
	local caster	= keys.caster
    local drop_items=Entities:FindAllByClassnameWithin("dota_item_drop",caster:GetAbsOrigin(),99999)
	for _, drop_item in pairs(drop_items) do     
	    local containedItem = drop_item:GetContainedItem()
	    if containedItem then
            if GameRules:GetGameTime() - drop_item:GetCreationTime() > 5 then
                local est = false
                local elid = 0
                local allelements = { --本地变量，一个包含全部元素球的表
                    "item_life","item_water","item_shadow",
                    
                    "item_void",

                    "item_earth",
                    "item_fire",
                    
                    
                    "item_light","item_air","item_ice",
                    "item_energy"
                }
                for y=1, #allelements do --遍历本地元素球的表
                    if containedItem:GetName()==allelements[y] then --如果掉在地上的禁用物品的名字与表中相同
                        est = true
                        elid = y
                        break--结束循环，保证est和elid对应的是重名物品
                    end
                end
                if est then--如果存在est
                    local partlist = {--本地变量，一个包含全部元素球的粒子特效文件地址的表，就是掉落元素球的时候飞过来的动画
                    "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                    "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                    "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                    "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                    "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                    "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                    "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                    "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                    "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                    "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                    
                    }
                    
                    local nFXIndex = ParticleManager:CreateParticle( partlist[elid], PATTACH_ABSORIGIN, drop_item )--给掉落的物品加载对应的粒子特效
                    --ParticleManager:SetParticleControl( nFXIndex, 0, drop_item:GetAbsOrigin() )
                    --ParticleManager:SetParticleControl( nFXIndex, 1, containedItem:GetPurchaser():GetAbsOrigin() )

                    --未知
                    ParticleManager:SetParticleControlEnt( nFXIndex, 1, containedItem:GetPurchaser(), PATTACH_POINT_FOLLOW, "attach_hitloc", containedItem:GetPurchaser():GetOrigin(), true )
                    ParticleManager:ReleaseParticleIndex( nFXIndex )
                    
                    local id = containedItem:GetPurchaser():GetPlayerID()--得到获取该元素球的玩家ID
                    local myTable = CustomNetTables:GetTableValue("Elements_Tabel",tostring(id))--获得玩家的元素面板的表单
                    myTable[tostring(elid)] = myTable[tostring(elid)] + 1--把该元素球的库存+1
                    CustomNetTables:SetTableValue("Elements_Tabel",tostring(id),myTable)--设置该玩家的元素面板的表单，既更新数据
                    UTIL_Remove(containedItem)
                    UTIL_Remove( drop_item )
                end
            end
	    end
	end
end
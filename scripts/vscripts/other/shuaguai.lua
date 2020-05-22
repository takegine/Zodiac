function ShuaGuai2( ... )

	--basenpc:RespawnUnit()	复活该单位。


	local wave = nil--关卡数归零
	local sweepnum = nil--场上怪物数量归零


	
	local ShuaGuai_entity = Entities:FindByName(nil,"sweepbirth")

	for wave = 0,4 do --建立5个关卡

		--循环0-2，创建3个怪物1
		for i=0,2 do
			local ShuaGuai = CreateUnitByName("npc_dota_hero_axe",ShuaGuai_entity:GetOrigin(),false,nil,nil,DOTA_TEAM_BADGUYS)
			ShuaGuai:AddNewModifier(nil, nil, "modifier_phased", {duration=0.1})
			sweepnum += 1
		end

		--循环0-5，创建6个怪物2
		for i=0,5 do    FindClearSpaceForUnit(handle a, Vector b, bool c)
			local ShuaGuai = CreateUnitByName("npc_dota_hero_sven",ShuaGuai_entity:GetOrigin(),false,nil,nil,DOTA_TEAM_BADGUYS)
			ShuaGuai:AddNewModifier(nil, nil, "modifier_phased", {duration=0.1})
			sweepnum += 1
		end


			--监听单位死亡，这个要放到intogame中
			ListenToGameEvent("entity_killed", Dynamic_Wrap(EarthlyBranches, "OnEntityKilled"), self)
			function EarthlyBranches:OnEntityKilled( keys )
        				print("OnEntityKilled")

        				local killed = EntIndexToHScript(keys.entindex_killed)--把一个实体的整数索引转化为表达该实体脚本实例的HScript
        				if killed:IsControllableByAnyPlayer() == true then
        					sweepnum -= 1
        					if sweepnum == 0 then
        						--如果场上怪物都死完了，检测是否有死亡玩家，如果有复活他。然后运行等待时间函数。
								--如果没有英雄或者墓碑在安全区，时间函数等于零。
								for i =0,4 do
									-- 获取这个玩家，返回的类型是CDOTAPlayer
									local deadplayer = PlayerResource:GetPlayer(i)
									if deadplayer:IsAlive() = false then
										deadplayer:RespawnUnit()
									end
								end
								
								--创建等待时间
								for time = 0,59 do --等待一分钟
									

								end

							end
        				elseif killed:IsRealHero() == true then
        					CreateItemOnPositionSync(killed:GetAbsOrigin(),killed:AddItemByName("item_blade_mail")) --死亡掉落一个刃甲（重生墓碑需要放在这里)
        				end

        			DeepPrintTable(keys)    --详细打印传递进来的表
			

			end
			

			if   
			 bool IsAlive()--判断是否活着
			 RespawnUnit()	--立刻复活该单位。
			end

	end
end

function DeadMan()--设置死亡掉落物品墓碑，对墓碑持续施法复活队友
    --BaseNPC_Hero.SetRespawnPosition(Vector a)--设置复活地点
    --BaseNPC_Hero.RespawnHero(bool buyback, bool IsActuallyBeingSpawnedForTheFirstTime, bool RespawnPenalty)
end
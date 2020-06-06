--使Zodiac 为全局可用，Zodiac可自己改
print ( '[Zodiac] be loadding' )

Zodiac = Zodiac or class({})

-- 此函数初始化游戏模式，并在任何人加载到游戏之前调用
-- 可用于预先初始化以后需要的任何值/表
function Zodiac:new()
    print("print InitGameMode is loaded.")
    
    
    --GameRules:GetGameModeEntity():SetCustomGameForceHero(SET_FORCE_HERO)强制所有人选一个英雄，并且跳过英雄选择的阶段

    CustomGameEventManager:RegisterListener("player_get_mode",Dynamic_Wrap(Zodiac, 'NanDuXuanZe'))--玩家点击难度，传回数据，如果没有选，缺省值为Mode1
    CustomGameEventManager:RegisterListener("player_get_ready",Dynamic_Wrap(Zodiac, 'moshixuanze'))--玩家点击难度并确定，在此判断并确定本局难度

    ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(Zodiac, 'OnNonPlayerUsedAbility'), self)--函数给大牛和凤凰的技能加魔免效果，用了修饰器，事件：当非玩家实体使用技能时


    self.vUserIds  = {}
    self.vSteamIds = {}
    self.vBots     = {}
    self.vBroadcasters = {}
    _G.DedicatedServerKey = GetDedicatedServerKeyV2("2")
    
end

--[[
    获取每队玩家数
    比较得到玩家数最大的队伍，相同的向下对齐
    MAX为本轮难度
    设置所有玩家到队伍1
]]

function Zodiac:NanDuXuanZe(data)
    --玩家点击难度选项会经过此反馈给其他玩家，反馈还没有做好
    --data.PlayerID玩家序号0.4
    --data，，他所点选的难度，
    
    CustomGameEventManager:Send_ServerToAllClients( "nandu_xuanze", {["1"]=data.PlayerID,["2"]=data.keys})--把数据传给所有客户端
    GameMode:NeedSteamIds(data)
end
    
local modecount = {Mode1=0,Mode2=0,Mode3=0,Mode4=0}
function Zodiac:moshixuanze( data )
--玩家选择难度点击确定后，这里会汇总然后找出投票最多的难度，并确定
    for i =0,PlayerResource:GetPlayerCount()-1 do
        if i == data.PlayerID then
            modecount[data.value] = modecount[data.value] + 1
        end
    end	
    print("----------------------vsplayer-----------------------------------")
    DeepPrintTable(modecount)

    local maxkey = next(modecount)     --令key等于表的最后一个键，既mode4
    local maxval = modecount[maxkey]   --key键对应的值

    for k, v in pairs(modecount) do    --遍历四个模式
        if  modecount[k] > maxval then --如果当前循环到的模式投票人数大于前一个模式投票人数
            maxkey, maxval = k, v      --那么替换最大投票选项
        end                            --如果有两个选项人数相同会选择较轻松的难度
    end
    print("#modecount:"..#modecount)
    
    for i = 1,4 do                            --循环难度
        if maxkey == "Mode"..i then           --判断投票最多的难度
            _G.hardmode = i                                                         --难度系数，涉及怪物伤害，血量，变身时机及修饰器层数等
            print("mode=".._G.hardmode.."......".."DropTable="..i.."......" )       --打印确认
            break
        end
    end
end
-------------------------------------------------------------游戏主线--------------------------------------------------------------------------------------
function Zodiac:OnGameRulesStateChange( keys ) 
    local newState = GameRules:State_Get() --获取当前游戏阶段
    --DeepPrintTable(keys)    --详细打印传递进来的表
    print ("print  OnGameRulesStateChange is running."..newState)

    if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then    
        --print("Player begin select hero")  --玩家处于选择英雄界面

        CustomUI:DynamicHud_Create(-1,"psd","file://{resources}/layout/custom_game/uiscreen.xml",nil)--创建选择难度面板

    elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then  --玩家处于选择选完的准备界面
        
        local unit = CreateUnitByName( "npc_dota_gold_spirit", Entities:FindByName( nil, "sweepbirth"):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS )

        for i=0, PlayerResource:GetPlayerCount()-1 do
            if PlayerResource:HasSelectedHero(i) == false then
                PlayerResource:GetPlayer(i):MakeRandomHeroSelection()
            end
        end

    elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
            Zodiac:ShuaGuai(CreateName)--正常刷怪
    end
end

LinkLuaModifier( "modifier_easy_mode", "modifiers/modifier_mode1", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_imba_generic_talents_handler", "modifiers/modifier_mode3", LUA_MODIFIER_MOTION_NONE )
-- 有NPC被创建，包括玩家
function Zodiac:OnNPCSpawned(keys)
    --DeepPrintTable(keys)
    local npc = EntIndexToHScript(keys.entindex)
    print("[BAREBONES] NPC Spawned",npc:GetUnitName())
    if  npc:IsRealHero() and npc.bFirstSpawned == nil then --是玩家操作的英雄 且 该单位首次创建
        npc.bFirstSpawned = true
        npc.immortalbuffs = {}
        npc:AddExperience(100,1,false,false)
        npc:AddNewModifier(npc, nil, "modifier_imba_generic_talents_handler", {})
        
        local id = npc:GetPlayerID()
        _G.bonuses[1][id] = 0
        _G.bonuses[2][id] = 0
        _G.bonuses[3][id] = 0
        _G.bonuses[4][id] = 0
        _G.bonuses[5][id] = 0
        _G.bonuses[6][id] = 0
        _G.bonuses[7][id] = 0
        npc.sealcolor = 1
        npc.rsp = 0
        local info = {}
        info.PlayerID = id
        Timers:CreateTimer(1, function()
            RelicStone:LoadRelics(info)
        end)

        value = {}
        local bbbbbb = {1,2,3,4,5,6,7,8,9,10}
        for i =1,10 do
            local elindoor = RandomInt( 1, #bbbbbb )--在bbbbbb按个数随机一个序号
            if     _G.hardmode == 3 then
                value[bbbbbb[elindoor]] = 0
            elseif _G.hardmode == 2 and i > 6 then 
                value[bbbbbb[elindoor]] = 0         --这个序号在bbbbbb里面指向的值作为value的key,指向为1，也就是该KEY对应的球有1个   
            else
                value[bbbbbb[elindoor]] = 1         --这个序号在bbbbbb里面指向的值作为value的key,指向为1，也就是该KEY对应的球有1个
            end
            table.remove(bbbbbb, elindoor)          --在bbbbbb里面移掉刚刚的数字
        end
        CustomNetTables:SetTableValue("Elements_Tabel",tostring(id),value)
        --DeepPrintTable(value)
        print("/////////////////////////////////////////////////////////////////////////////////////////////")

        --添加一个轻松游戏的修饰器
        if _G.hardmode == 1 then
            npc:AddNewModifier(npc, nil, "modifier_easy_mode", {})
        end

        --hRequest:Login(id)

        --[[给资助的人一个宠物
        if _G.patreons[tostring(PlayerResource:GetSteamID(id))] ~= nil then
            if _G.patreons[tostring(PlayerResource:GetSteamID(id))] > 3 then
                info.hero = npc
                Pets.CreatePet( info )
            end
        end]]
    end
end

-- 当玩家完全连接并且准备加载
function Zodiac:OnConnectFull(keys)
    print("function Zodiac:OnConnectFull()is working.")
    --DeepPrintTable(keys)
    XP_PER_LEVEL_TABLE = {}--初始化经验表单，会在难度选择函数中更新
    for i=1,MAX_LEVEL do
        XP_PER_LEVEL_TABLE[i] = i * 100--升级按经验总量来算，这里就是每级都是100点经验
    end
    
    -- 建立游戏模式的参数
    mode = mode or GameRules:GetGameModeEntity()

    mode:DisableHudFlip( true )--?禁用hub翻转，即小地图放在右边
    mode:SetLoseGoldOnDeath( false )--死亡损失金钱
    mode:SetAnnouncerDisabled(true)--禁用播音员
    mode:SetCustomHeroMaxLevel(MAX_LEVEL)--设定最高等级
    mode:SetHudCombatEventsDisabled(true)--猜测：不显示左侧的战斗事件
    mode:SetBuybackEnabled(BUYBACK_ENABLED)--设定玩家不能买活
    mode:SetSelectionGoldPenaltyEnabled( false )--启用/禁用不选英雄的金币惩罚
    mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )--屏蔽金币的声音
    mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
    mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
    mode:SetFogOfWarDisabled( DISABLE_FOG_OF_WAR_ENTIRELY)--取消战争迷雾
    mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )
    mode:SetTopBarTeamValuesOverride( USE_CUSTOM_TOP_BAR_VALUES )--自定义顶部数据栏
    mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )--经验值表单
    mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )--禁用装备推荐
    mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )--自定义买活金额
    mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )--自定义买活CD
    
    mode:SetItemAddedToInventoryFilter( Dynamic_Wrap( self.game, "ItemAddedToInventoryFilter" ), self )--设置一个过滤器，用来控制物品被放入物品栏时的行为。
  --mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )--取消塔防御
  --mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
  --mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )--修改视野高度
        
    mode:SetHUDVisible(1,true)   --设置HUD元素，1元素可见

    local entIndex = keys.index+1                  -- 正在进入的用户 玩家实体
    local ply      = EntIndexToHScript(entIndex)

    local playerID = ply:GetPlayerID()             -- 正在进入的用户 玩家ID

    self.game.vUserIds[keys.userid] = ply               -- 使用此用户ID更新用户ID表

    self.game.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply  -- 更新Steam ID表

    -- If the player is a broadcaster flag it in the Broadcasters table
    if PlayerResource:IsBroadcaster(playerID) then -- 
        self.game.vBroadcasters[keys.userid] = 1
        return
    end
end

function Zodiac:ItemAddedToInventoryFilter( filterTable )--控制物品被放入物品栏时的行为
    if filterTable["item_entindex_const"] == nil                  --获得的物品
    or filterTable["inventory_parent_entindex_const"] == nil then --库存拥有者
        return true
    end

    local hItem = EntIndexToHScript( filterTable["item_entindex_const"] )
    local hInventoryParent = EntIndexToHScript( filterTable["inventory_parent_entindex_const"] )
    
    if  hItem ~= nil and hInventoryParent ~= nil 
    and hItem:GetAbilityName() ~= "item_tombstone" 
    and hInventoryParent:IsRealHero() then
        local rlcs = {
            item_relic_damage = 1,
            item_relic_armor = 1,
            item_relic_magres = 1,
            item_relic_attackspeed = 1,
            item_relic_allsatas = 1,
            item_relic_magvam = 1,
            item_relic_magdam = 1,
            item_book = 1,
            item_redemption_ticket = 1,
            item_proved = 2,
            item_finalbook = 3,
            item_op_staff = 4,
            item_shadow_cuirass = 4,
            item_ice_staff = 4
        }
        if rlcs[hItem:GetAbilityName()] == nil then --当获得的装备不在上表中
            local est2 = false                      --是否是元素装备
            for _, v in pairs(notforall) do
                if v == hItem:GetAbilityName() then --当获得的装备在上表中
                    est2 = true
                end
            end
            if  est2 == false then
                hItem:SetPurchaser( hInventoryParent )--既不是元素装备也不是遗物，那么设置他为购买者
            else
                if  hItem:GetPurchaser() ~= hInventoryParent then--不是自己的元素装备不能拾起，下一帧掉落
                    Timers:CreateTimer(0.01,function()
                        hInventoryParent:DropItemAtPositionImmediate( hItem, hInventoryParent:GetAbsOrigin() )
                    end)
                end
            end
        else
            if hItem:GetPurchaser() ~= hInventoryParent then --不是自己的元素装备不能拾起，下一帧掉落
                Timers:CreateTimer(0.01,function()
                    hInventoryParent:DropItemAtPositionImmediate( hItem, hInventoryParent:GetAbsOrigin() )
                end)
            else
                for i=0, 9, 1 do
                    local current_item = hInventoryParent:GetItemInSlot(i)
                    if current_item ~= nil then
                        if rlcs[current_item:GetAbilityName()] ~= nil then
                            if rlcs[hItem:GetAbilityName()] > rlcs[current_item:GetAbilityName()] then
                                    hInventoryParent:RemoveItem(current_item)

                            elseif rlcs[hItem:GetAbilityName()] < rlcs[current_item:GetAbilityName()] then
                                Timers:CreateTimer(0.01,function()
                                    hInventoryParent:RemoveItem(hItem)
                                    end)

                            elseif hItem:GetAbilityName() == current_item:GetAbilityName() then
                                Timers:CreateTimer(0.01,function()
                                    hInventoryParent:RemoveItem(hItem)
                                    end)
                            end
                        end
                    end
                end
            end
        end
    end
    return true
end

function Zodiac:OnEntityKilled( keys )
    print("OnEntityKilled")
        --DeepPrintTable(keys)    --详细打印传递进来的表
    local killedUnit = EntIndexToHScript( keys.entindex_killed )--取得死者实体

    --print( killedUnit:IsControllableByAnyPlayer() )--判断死者是否受玩家操控

--玩家死了掉墓碑,及失败
    if killedUnit and killedUnit:IsHero() then
        local newItem = CreateItem( "item_tombstone", killedUnit, killedUnit )--创建一个属于死亡玩家的墓碑实体
        newItem:SetPurchaseTime( 0 )										 --设置墓碑实体立即可以购买
        newItem:SetPurchaser( killedUnit )									 --设置墓碑实体为死者购买
        local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )--同步生成表中的单个实体
        tombstone:SetContainedItem( newItem )								 --禁用墓碑实体
        tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )	 --设置墓碑的颠簸,偏航,摇晃，
        FindClearSpaceForUnit( tombstone, killedUnit:GetAbsOrigin(), true )	--在死者附近空地上创建这个墓碑
        tombstone:SetModelScale(RandomFloat( 2, 3 ))
    --设置失败
        local test2 = Entities:FindAllByName("item_tombstone")--按照名字实体一个表单，包含了所有符合这个名字条件的实体，
        if  #test2 == PlayerResource:GetPlayerCount() then
            GameMode:TheGameEndding( DOTA_TEAM_BADGUYS )
        end
    end

--设置胜利
    if killedUnit:GetUnitName() == "npc_dota_custom_creep_50_1" then --如果死亡的单位是50关的怪
        GameMode:TheGameEndding( DOTA_TEAM_GOODGUYS )
    end

--结束本轮，发经验
    if killedUnit:GetTeam() == 3 and killedUnit:GetName() == "npc_dota_creature" then--如果死的单位是3队的创建类单位
        if not killedUnit:IsIllusion() then                     --当死者不是幻象
            local getxp = killedUnit:GetBaseDayTimeVisionRange()--获得死者白天的标准视野范围
            if  getxp > 0 then
                local heroes = GameMode:GetAllRealHeroes()      --获得全部在游戏中的英雄的名单
                for i=1, #heroes do                             --给这些英雄发经验
                    heroes[i]:AddExperience((getxp / #heroes)*(1-(0.05*(5 - #heroes))),false,false)--发经验值
                end
            end
        end
        if  killedUnit:IsCreature() then --如果死的单位是怪物
            RollDrops(killedUnit)       --调用随机掉落
        end

        --[[--读取下一轮的方案3：获取在场活着的实体,判断个数 BOSS关卡有问题
        local units =  FindUnitsInRadius(3, Entities:FindByName(nil,"sweepbirth"):GetOrigin(), nil, FIND_UNITS_EVERYWHERE,DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                       DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,FIND_ANY_ORDER, false)
        if  #units == 0 then            --参数为下一关可以进的时候，调用下一关
            Zodiac:ShuaGuai() --读取下一轮
        elseif #units == 1 then
            Timers:CreateTimer(0.1, function()
                if  units[1]:GetName()=="npc_dota_creature" then
                    return 1
                elseif units[1]:IsAlive() ~= true then
                    Zodiac:ShuaGuai() --读取下一轮
                    return nil
                else
                    return 1
                end
            end)
        end]]

        --读取下一轮的方案2：删实体，然后判断剩余没删的个数
        killedUnit:Destroy()--删除这个死者的在内存的实体
        local nextwave = true                                    --下一关默认开启，每次有死亡单位刷新
        local units = Entities:FindAllByName("npc_dota_creature")--按照名字实体一个表单，包含了所有符合这个名字条件的实体，
        --print("skkkkkssss.."..#units)                            --打印实体数量，检查
        if units ~= nil and #units ~= 0 then					 --如果创建物表单 非空，且个体数非零（个数如果为零意味没有实体，这个判断应该多余了）
            for b=1,#units do 									 --从1开始遍历整个表单
                if  units[b]:GetTeam() == 3 and units[b]:IsAlive() == true then --如果这个表单中属于三队的还有活着的
                    nextwave = false                             --下一关就不能开始
                end
            end
        end
        if nextwave == true then Zodiac:ShuaGuai(CreateName) end --参数为下一关可以进的时候，调用下一关

        --[[--读取下一轮的方案1：我优化的原方案，每个死亡做一个计时循环，直到表中单位都死了，进入下一轮
        local nextwave = true
        Timers:CreateTimer(0.1, function()                              --0.1秒后执行该函数
            local units = Entities:FindAllByName("npc_dota_creature")   --获取所有创建的怪
            if units ~= nil and #units ~= 0 then                        --至少还存在一个怪，units非空非零
                for b=1,#units do                                       --判断表中是不是都死了，有活着的就继续循环
                    if  units[b]:GetTeam() == 3 and units[b]:IsAlive() == true then
                        nextwave = false
                        return 0.1
                    end
                end
            else
                nextwave = true
            end
            if nextwave == true then Zodiac:ShuaGuai() end --参数为下一关可以进的时候，调用下一关
        end)]]
    end
end

cheats = false
readytable={}
function Zodiac:ShuaGuai(CreateName)
    local point = Entities:FindByName( nil, "sweepbirth"):GetAbsOrigin()--获取TestGuai这个实体出生
    --local waypoint = Entities:FindByName( nil, "way1")

    if CreateName then
        --创建单位
        local TestGuai = CreateUnitByName(CreateName,point,false,nil,nil,DOTA_TEAM_NEUTRALS)
        --添加相位移动的modifier，持续时间0.1秒
        --当相位移动的modifier消失，系统会自动计算碰撞，这样就避免了卡位
        TestGuai:AddNewModifier(nil, nil, "modifier_phased", {duration=0.1})--或者上一句第三个参数填true

    else 
        local return_time = 60 + _G.GAME_ROUND -- 关卡之间的时间
        local time_ = 1
        
        if GameRules:IsCheatMode() then cheats = true end --检测是否作弊，

    --更新全部状态
        local heroes = GameMode:GetAllRealHeroes()
        --DeepPrintTable(heroes)
        for i=1, #heroes do
                if heroes[i].damage_schetchik then
                    if  heroes[i].oldwd then
                        heroes[i].nowwd = math.ceil(heroes[i].damage_schetchik - heroes[i].oldwd)
                        heroes[i].oldwd = math.ceil(heroes[i].damage_schetchik)
                    else
                        heroes[i].nowwd = math.ceil(heroes[i].damage_schetchik)
                        heroes[i].oldwd = math.ceil(heroes[i].damage_schetchik)
                    end
                else
                    heroes[i].oldwd = 0
                    heroes[i].nowwd = 0
                end
            
            if  heroes[i]:IsAlive() == false then					--复活死了的玩家
                heroes[i]:RespawnUnit()								--我替换了复活代码，如果没有复活就换回下面的
                --heroes[i]:SetRespawnPosition(heroes[i]:GetOrigin())
                --heroes[i]:RespawnHero( false, false )
            end
            heroes[i]:SetHealth(heroes[i]:GetMaxHealth())			--满血
            heroes[i]:SetMana(heroes[i]:GetMaxMana())				--满篮
            for y=0, 9, 1 do
                local current_item = heroes[i]:GetItemInSlot(y)    --获得英雄物品栏
                if    current_item ~= nil and current_item:GetName() == "item_bottle" then --充满魔瓶
                      current_item:SetCurrentCharges(4)
                end
            end
        end
    --展示本轮伤害数据统计
        local maxdh  = nil 			          	--本轮最大伤害的英雄
        local maxdmg = -1 			           	--本轮最大伤害值
        local dlist  = {}			        	--本轮伤害清单
        local myneedheroes = GameMode:GetAllRealHeroes()
        for i=1, #myneedheroes do                     --按英雄人数遍历，为了排序
            maxdh = nil
            maxdmg = -1
            for n=1, #myneedheroes do                 --按人数遍历，为了找出剩余的最大伤害
                if myneedheroes[n] ~= nil and myneedheroes[n].nowwd > maxdmg then--如果有该英雄且伤害大于最大伤害
                    maxdmg = myneedheroes[n].nowwd	    --更新本次n循环最大伤害
                    maxdh  = n 					--更新本次n循环最大伤害的英雄
                end
            end
            --table.insert(dlist,heroes[maxdh])	--在本轮伤害清单插入一个标签，标记最大伤害英雄
            dlist["hero"..i]=myneedheroes[maxdh]:GetName()
            dlist["damage"..i]=myneedheroes[maxdh].nowwd
            myneedheroes[maxdh] = nil 			--在表单里删掉这一轮的最大伤害，下一轮的最大伤害就是次一级的
        end
        DeepPrintTable(dlist)
        CustomGameEventManager:Send_ServerToAllClients( "Open_DamageTop", dlist)--把数据传给所有客户端
        

        --在投票板上显示几个玩家的头像
        local heronametab = {}
        for i = 1,10 do
            if i <= #heroes then
                    heronametab["hero"..i]=heroes[i]:GetName() --有玩家就给名字，到时候就有头像
            else heronametab["hero"..i]=""                  --没玩家就给空白免得有个空格
            end
        end
        CustomGameEventManager:Send_ServerToAllClients( "Display_RoundVote",heronametab)



    --调用任务系统，创建任务：准备时间
        
        QuestSystem:CreateQuest("PrepTime","#QuestPanel",1,return_time,nil,_G.GAME_ROUND + 1)

        Timers:CreateTimer(1, function()
            local gogame = 0 --默认为不可以进入下一关
            for i=0,#heroes do
                local InBox = Entities:FindByName(nil,"neutral_camp"):IsTouching(heroes[i])
                if InBox then gogame=gogame+1 end
                print(".."..i.."..".."false"..tostring(InBox))
                --CustomGameEventManager:Send_ServerToAllClients("changevote",{hero=heroes[i]:GetName(),bool=tostring(InBox)})

                print(".."..i.."..".."false")
            end


            if time_ <= return_time and gogame ~= PlayerResource:GetPlayerCount() then    --如果计数time_小于等于游戏之间的时间(60)，且不是所有玩家都在灰色区域
                QuestSystem:RefreshQuest("PrepTime",time_,return_time,_G.GAME_ROUND + 1)
                time_ = time_ + 1           --那么刷新任务，且计数值加1
                print("//------------------time_--"..time_)
                return 1 		         	--返回值1，也就是1秒钟后重启这个function()
            else                            --如果计数time_大于游戏之间的时间
                print("bbbbbbbb")          	--打印了这句
            
                QuestSystem:DelQuest("PrepTime")--那么删除任务，
                
                CustomGameEventManager:Send_ServerToAllClients( "Close_DamageTop", {})  --关闭伤害示数面板
                CustomGameEventManager:Send_ServerToAllClients( "Close_RoundVote", {})  --关闭投票面板
                
                _G.GAME_ROUND = _G.GAME_ROUND + 1										--轮数+1
                
                CustomNetTables:SetTableValue("Hero_Stats","wave",{_G.GAME_ROUND})	    --在网络表格中更新轮数
                
                EmitGlobalSound("Tutorial.Quest.complete_01")							--奏战歌
                print("..................round:".._G.GAME_ROUND..".....................")

            --出怪，我的方案,
                for i=1,3 do 															--每一关的三类怪，循环来确定
                    local unitname="npc_dota_custom_creep_".._G.GAME_ROUND.."_"..i      --通关组合的方式得到怪物名字的字符串
                    local unitnum =tonumber(ROUND_UNITS[unitname][tostring(_G.hardmode)]) or 0
                   
                    if ROUND_UNITS[unitname] then                                       --判断这个怪物是否在文件npc_units_custom中已创建
                        for k=1,unitnum do
                            local unit = CreateUnitByName( unitname, point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS )
                            --unit:SetInitialGoalEntity( waypoint )						--设置该怪物的初始路径点。我没有创建这个路径点
                            --[[ for i = 1,2* (_G.hardmode - 1) do
                                local enemyitem={} --另外写一个物品表单来调用
                                    local num = math.random(#enemyitem[_G.GAME_ROUND])  --随机个数表示这个物品
                                
                                unit:AddItemByName(enemyitem[_G.GAME_ROUND][num])--按照随机数给该物品

                                --根据难度怪物会获得装备，件数为2* (_G.hardmode - 1)  有个装备列表，怪物随机获得其中装备
                            end]]
                            if ADDED_ITEM[unitname] then
                                table.foreach(ADDED_ITEM[unitname],function(item,hard)  if _G.hardmode > hard then unit:AddItemByName(item) end end)
                            end
                            if ADDED_ABLE[unitname] then
                                table.foreach(ADDED_ABLE[unitname],function(_,able)  unit:AddAbility(able) end)
                            end
                            --[[
                            if _G.hardmode > 1 then				         				--如果不是普通模式，给下列关卡的怪物加装备
                                if _G.GAME_ROUND ==  4 then unit:AddItemByName("item_fire_earth_water") end
                                if _G.GAME_ROUND == 11 then unit:AddItemByName("item_ice_fire_earth") end 
                                if _G.GAME_ROUND == 14 then unit:AddItemByName("item_earth_shadow_life_2") end
                                if _G.GAME_ROUND == 15 then unit:AddItemByName("item_fire_core") unit:AddItemByName("item_imba_ultimate_scepter_synth") end
                                if _G.GAME_ROUND == 16 then unit:AddItemByName("item_butterfly") end
                                if unitname == "npc_dota_custom_creep_17_2" then unit:AddItemByName("item_energy_fire_void") end
                                if _G.GAME_ROUND == 19 then unit:AddItemByName("item_hammer_of_god") end
                                if _G.GAME_ROUND == 20 then unit:AddItemByName("item_fire_radiance") end
                                if _G.GAME_ROUND == 21 then unit:AddItemByName("item_echo_sabre") end
                                if _G.GAME_ROUND == 22 then unit:AddItemByName("item_earth_s_and_y") end
                                if _G.GAME_ROUND == 25 then unit:AddItemByName("item_energy_core") end
                            end]]
                        end
                    end
                end
                
            --local heroes = GameMode:GetAllRealHeroes()--前面写了，我删掉看看能不能跑
            --刷新英雄身上的修饰器
                for i=1, #heroes do  		--遍历每个英雄,判断玩家是否在线(2在线)
                    print("refresh all modifiers on hero")
                    if PlayerResource:GetConnectionState(heroes[i]:GetPlayerOwnerID()) == 2 then
                        local modifs = heroes[i]:FindAllModifiers() --获取该英雄所有修饰器buff
                        for b=1, #modifs do
                            if modifs[b]:GetAbility() ~= nil then 	--如果buff中有技能
                                if  modifs[b].needupwawe then		--且该修饰器needupwawe为真
                                    modifs[b]:OnWaweChange(_G.GAME_ROUND)--根据本轮轮数改变修饰器
                                end
                            end
                        end
                    end
                end
            end
        end)--计时器结束
    
    end
end

function Zodiac:OnPlayerLevelUp(keys)
    print ('[GameMode] OnPlayerLevelUp')
    --DeepPrintTable(keys)
    local hero = EntIndexToHScript(keys.hero_entindex)--把该英雄实体的整数索引转化为脚本

    if keys.level >= 30 then
        hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)--给英雄加一点可分配的技能点
    end
end

--allelements = { "item_jia","item_yi","item_bing","item_ding","item_wu","item_ji","item_geng","item_xin","item_ren","item_kui"}
allelements = { "item_life","item_water","item_shadow","item_void","item_earth","item_fire","item_light","item_air","item_ice","item_energy"}
needdropel  = {} --需要掉落的球
function RollDrops(unit)
    local DropInfo = DropTable[unit:GetUnitName()]          --获取死者掉落表单
    if DropInfo then
        for item_name,ItemTable in pairs(DropInfo) do 		--遍历掉落物品
            local introll = ItemTable.roll or 100 			--爆率
            local intmuch = ItemTable.much or 1 		    --个数
            --local item_name = ItemTable.Item 				--掉落物品名字
            print("RollDrops",unit:GetUnitName(),introll,intmuch,item_name)
            for i=1,intmuch do 							    --按掉落个数循环
                if item_name == "item_25gold" then 			--掉落钱袋
                    if RollPercentage(introll) then                          --随机生成1-100内的数，小于等于给定数(爆率)则返回true
                        local item = CreateItem(item_name, nil, nil)            --实体一个掉落物
                        item:SetPurchaseTime(0)                                 --购买时间归零
                        CreateItemOnPositionSync( unit:GetAbsOrigin() , item )  --掉落在死者处
                        item:LaunchLoot(false, 200, 0.75, unit:GetAbsOrigin() + RandomVector(RandomFloat(150,200)) )--按照150/200之前随机一个浮点数，然后随机向量把这个装备弹射出去，防止物品卡位
                    end

                elseif item_name == "item_elbol" then       --掉落 元素球
                    if #needdropel == 0 then                         --需要掉落的球
                        table.foreach(allelements,function(_,v) table.insert(needdropel,v) end)
                        --for y=1,#allelements do
                        --    table.insert(needdropel, allelements[y]) --插入值在“需要掉落的球”的表单中，这个表单在难度选择中
                        --end
                    end
                    local rand = RandomInt( 1, #needdropel )         --按需要掉落的球中随机一个
                    local newb = needdropel[rand]                    --把掉落品改为
                    table.remove(needdropel,rand)                    --在“需要掉落的球”表单中删掉刚刚掉落的球
                            
                    for z=0, PlayerResource:GetPlayerCount()-1 do
                        local myTable = CustomNetTables:GetTableValue("Elements_Tabel",tostring(z))--从网络表单获取元素球个数
                        table.foreach(allelements,function(y,v)
                        --for y=1, #allelements do
                            --if allelements[y] == item_name then
                            if v==newb then
                                local partlist = {                       --掉落元素时的粒子特效
                                        "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                                        "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8_arc.vpcf",
                                        "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8_arc_b.vpcf",
                                        "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                                        "particles/econ/items/lion/lion_ti8/lion_spell_finger_ti8.vpcf",
                                        "particles/units/heroes/hero_undying/undying_fg_portrait_mouthgas.vpcf",
                                        "particles/units/heroes/hero_zeus/zeus_return_king_of_gods_head_style1_ambient.vpcf",
                                        "particles/units/heroes/hero_tinker/laser_cutter_sparks_c.vpcf",
                                        "particles/units/heroes/hero_techies/techies_stasis_trap_beams.vpcf",
                                        "particles/econ/courier/courier_snail/courier_snail_ambient_flying.vpcf"
                                }
                                        
                                local nFXIndex = ParticleManager:CreateParticle( partlist[y], PATTACH_OVERHEAD_FOLLOW, unit )--特效--原参数2 PATTACH_ABSORIGIN
                                --ParticleManager:SetParticleControl( nFXIndex, 0, drop_item:GetAbsOrigin() )
                                --ParticleManager:SetParticleControl( nFXIndex, 1, containedItem:GetPurchaser():GetAbsOrigin() )
                                ParticleManager:SetParticleControlEnt( nFXIndex, 1, PlayerResource:GetSelectedHeroEntity(z), PATTACH_POINT_FOLLOW, "attach_hitloc", PlayerResource:GetSelectedHeroEntity(z):GetOrigin(), true )
                                --SetParticleControlEnt(particle: ParticleID, controlPoint: int, unit: CDOTA_BaseNPC, particleAttach: ParticleAttachment_t, attachment: string, offset: Vector, lockOrientation: bool)
                                --设置CP点参数
                                ParticleManager:ReleaseParticleIndex( nFXIndex )--释放特效
                                            
                                myTable[tostring(y)] = myTable[tostring(y)] + 1
                                CustomNetTables:SetTableValue("Elements_Tabel",tostring(z),myTable) --上传元素球余额到网络表单中
                                --break
                            end
                        end)
                    end
                elseif ItemTable.sins then 			--掉落relic
                    
                    if RollPercentage(introll*PlayerResource:GetPlayerCount()) then  --随机生成1-100内的数，小于等于给定数（玩家数）则返回true
                        local item = CreateItem(item_name, nil, nil)				--创建该掉落实体
                        print("vooo",item_name)
                              item:SetPurchaseTime(0)								--购买时间为0
                        CreateItemOnPositionSync( unit:GetAbsOrigin(), item )		--实现物品掉落
                        --在死亡地点增加一个 根据100/125随机一个浮点数产生的随机向量，把掉落物装备发射出去，防止装备相位卡住
                        item:LaunchLoot(false, 200, 0.75, unit:GetAbsOrigin()+RandomVector(RandomFloat(110,140)))
                        item.bIsRelic = true 										--不知道干嘛的
                        local PlayerIDs = {}
                        print( "Zodiac:OnRelicSpawned - New Relic " .. item:GetAbilityName() .. " created." )
                            
                        for _,Hero in pairs ( GameMode:GetAllRealHeroes() ) do 		--遍历在场英雄，所有value
                            if Hero ~= nil  										--如果英雄非空，
                            and Hero:IsRealHero() 									--不是幻想和召唤物，
                            and Hero:HasOwnerAbandoned() == false 					--没有被持有者遗弃(false)，玩家没有掉线(2)
                            and PlayerResource:GetConnectionState(Hero:GetPlayerID()) == 2 then
                                print( "Zodiac:OnRelicSpawned - PlayerID " .. Hero:GetPlayerID() .. " does not own item, adding to grant list." )
                                table.insert( PlayerIDs, Hero:GetPlayerID() ) 		--在PlayerIDs表单中加入这个玩家
                            end
                        end

                        --抽一个玩家作为得到掉落的人
                        local WinningPlayerID = -1
                        if #PlayerIDs == 1 then 										--当PlayerIDs表单中只有一个键值对
                            WinningPlayerID = PlayerIDs[1] 								--取值，为玩家ID
                        else
                            WinningPlayerID = PlayerIDs[ RandomInt( 1, #PlayerIDs ) ]	--不是只有一个玩家的时候，取值 随机一个玩家
                            print( "Zodiac:OnRelicSpawned - " .. #PlayerIDs .. " players have not yet found an artifact, winner is player ID " .. WinningPlayerID )
                        end

                        if WinningPlayerID == -1 or WinningPlayerID == nil then 		--当值为初始值-1或空时，打印无玩家
                            print( "Zodiac:OnRelicSpawned - ERROR - WinningPlayerID is invalid." )
                            return
                        end
                        
                        local WinningHero = PlayerResource:GetSelectedHeroEntity( WinningPlayerID ) --实体化胜利的玩家
                        local WinningSteamID = PlayerResource:GetSteamID( WinningPlayerID )			--取值 steamID

                        print( "Zodiac:OnRelicSpawned - Relic " .. item:GetAbilityName() .. " has been bound to " .. WinningPlayerID )
                        item:SetPurchaser( WinningHero ) 											--设置物品的购买者
                        
                        if  item_name == "item_relic_damage" then
                            if	WinningHero.lvl_item_relic_damage ~= nil then WinningHero.lvl_item_relic_damage = WinningHero.lvl_item_relic_damage + 1
                                else                                        WinningHero.lvl_item_relic_damage = 1
                            end
                        elseif  item_name == "item_relic_armor" then
                            if  WinningHero.lvl_item_relic_armor ~= nil then WinningHero.lvl_item_relic_armor = WinningHero.lvl_item_relic_armor + 1
                                else                                        WinningHero.lvl_item_relic_armor = 1
                            end
                        elseif  item_name == "item_relic_magres" then
                            if  WinningHero.lvl_item_relic_magres ~= nil then WinningHero.lvl_item_relic_magres = WinningHero.lvl_item_relic_magres + 1
                                else                                        WinningHero.lvl_item_relic_magres = 1
                            end
                        elseif  item_name == "item_relic_attackspeed" then
                            if  WinningHero.lvl_item_relic_attackspeed ~= nil then WinningHero.lvl_item_relic_attackspeed = WinningHero.lvl_item_relic_attackspeed + 1
                                else                                        WinningHero.lvl_item_relic_attackspeed = 1
                            end
                        elseif  item_name == "item_relic_allsatas" then
                            if  WinningHero.lvl_item_relic_allsatas ~= nil then WinningHero.lvl_item_relic_allsatas = WinningHero.lvl_item_relic_allsatas + 1
                                else                                        WinningHero.lvl_item_relic_allsatas = 1
                            end
                        elseif  item_name == "item_relic_magvam" then
                            if  WinningHero.lvl_item_relic_magvam ~= nil then WinningHero.lvl_item_relic_magvam = WinningHero.lvl_item_relic_magvam + 1
                                else                                        WinningHero.lvl_item_relic_magvam = 1
                            end
                        elseif  item_name == "item_relic_magdam" then
                            if  WinningHero.lvl_item_relic_magdam ~= nil then WinningHero.lvl_item_relic_magdam = WinningHero.lvl_item_relic_magdam + 1
                                else                                        WinningHero.lvl_item_relic_magdam = 1
                            end
                        end
                        
                        EmitSoundOn( "sounds/misc/soundboard/absolutely_perfect.vsnd", WinningHero )
                        --[[
                        local otv = ""
                        local req = CreateHTTPRequestScriptVM( "POST", Zodiac.gjfll2 .. "/lol21.php")
                        req:SetHTTPRequestGetOrPostParameter("id", tostring(WinningSteamID))
                        req:SetHTTPRequestGetOrPostParameter("name", item_name)
                        req:SetHTTPRequestGetOrPostParameter("v", _G.DedicatedServerKey)
                        req:Send(function(result)
                            otv = result.Body
                        end)
                        ]]
                    end

                elseif item_name == "RS" then  ------掉落relic stone 宝石的------
                    
                    if RollPercentage(introll*PlayerResource:GetPlayerCount()) then --随机一个100以内的数，如果小于爆率X玩家缺省数
                        local PlayerIDs = {}
                        local Heroes = GameMode:GetAllRealHeroes()
                        for _,Hero in pairs ( Heroes ) do
                            if Hero ~= nil and Hero:IsRealHero() and Hero:HasOwnerAbandoned() == false and PlayerResource:GetConnectionState(Hero:GetPlayerID()) == 2 then
                                table.insert( PlayerIDs, Hero:GetPlayerID() )
                            end
                        end

                        local WinningPlayerID = -1
                        if #PlayerIDs == 1 then
                            WinningPlayerID = PlayerIDs[1]
                        else
                            WinningPlayerID = PlayerIDs[ RandomInt( 1, #PlayerIDs ) ]
                        end
                        if WinningPlayerID == -1 or WinningPlayerID == nil then
                            print( "Zodiac:OnRelicSpawned - ERROR - WinningPlayerID is invalid." )
                            return
                        end
                        
                        local WinningHero = PlayerResource:GetSelectedHeroEntity( WinningPlayerID )
                        local WinningSteamID = PlayerResource:GetSteamID( WinningPlayerID )
                        local ininvid = ""
                        if WinningHero.rsinv ~= nil then
                            if #WinningHero.rsinv > 99 then
                                ininvid = tostring(#WinningHero.rsinv)
                            elseif #WinningHero.rsinv > 9 then
                                ininvid = "0"..tostring(#WinningHero.rsinv)
                            elseif #WinningHero.rsinv > -1 then
                                ininvid = "00"..tostring(#WinningHero.rsinv)
                            end
                        else
                            ininvid = "001"
                        end

                        local rares = ItemTable.level

                        local rsid = nil   --初始化一个宝石的序列号
                        if rares == 0 then     rsid =            "1"..RandomInt(0,9)..RandomInt(1,4)..RandomInt(1,7).."0000"..ininvid
                            if   WinningHero.rsinv ~= nil then table.insert(WinningHero.rsinv,rsid)
                            else WinningHero.rsinv = {rsid}
                            end
                        elseif rares == 1 then rsid = RandomInt(1,2)..RandomInt(0,9)..RandomInt(1,4)..RandomInt(1,7).."0000"..ininvid
                            if   WinningHero.rsinv ~= nil then table.insert(WinningHero.rsinv,rsid)
                            else WinningHero.rsinv = {rsid}
                            end
                        elseif rares == 2 then rsid =            "2"..RandomInt(0,9)..RandomInt(1,4)..RandomInt(1,7).."0000"..ininvid
                            if WinningHero.rsinv ~= nil then table.insert(WinningHero.rsinv,rsid)
                            else WinningHero.rsinv = {rsid}
                            end
                        elseif rares == 3 then
                            local rrr = RandomInt(1,3)
                            local secstat = 0
                            if rrr == 3 then
                                secstat = RandomInt(1,7)
                            end
                                                    rsid = rrr..RandomInt(0,9)..RandomInt(1,4)..RandomInt(1,7)..secstat.."000"..ininvid
                            if   WinningHero.rsinv ~= nil then table.insert(WinningHero.rsinv,rsid)
                            else WinningHero.rsinv = {rsid}
                            end
                        elseif rares == 4 then
                            local rrr = RandomInt(2,3)
                            local secstat = 0
                            if rrr == 3 then secstat = RandomInt(1,7) end
                                                    rsid = rrr..RandomInt(0,9)..RandomInt(1,4)..RandomInt(1,7)..secstat.."000"..ininvid
                            if   WinningHero.rsinv ~= nil then table.insert(WinningHero.rsinv,rsid)
                            else WinningHero.rsinv = {rsid}
                            end
                        elseif rares == 5 then
                                            rsid = "3"..RandomInt(0,9)..RandomInt(1,4)..RandomInt(1,7)..RandomInt(1,7).."000"..ininvid
                            if   WinningHero.rsinv ~= nil then table.insert(WinningHero.rsinv,rsid)
                            else WinningHero.rsinv = {rsid}
                            end
                        elseif rares == 6 then
                        elseif rares == 7 then
                        elseif rares == 8 then
                        elseif rares == 9 then
                            local stat1 = RandomInt(1,7)
                            local stat2 = RandomInt(1,6)
                            if stat2 >= stat1 then  stat2 = stat2 + 1  end
                                rsid = "4"..RandomInt(0,9)..RandomInt(1,4)..stat1..stat2.."0"..RandomInt(1,5)..RandomInt(0,2)..ininvid
                            if   WinningHero.rsinv ~= nil then table.insert(WinningHero.rsinv,rsid)
                            else WinningHero.rsinv = {rsid}
                            end
                        end

                        if rsid ~= nil then
                            CustomGameEventManager:Send_ServerToAllClients( "AddRSUI", {rsid = rsid,hero = WinningHero:GetName()})
                            --[[
                            local otv = ""
                            local req = CreateHTTPRequestScriptVM( "POST", Zodiac.gjfll2 .. "/relicstones1.php")
                            req:SetHTTPRequestGetOrPostParameter("id", tostring(WinningSteamID))
                            req:SetHTTPRequestGetOrPostParameter("rsid", rsid)
                            req:SetHTTPRequestGetOrPostParameter("v", _G.DedicatedServerKey)
                            req:Send(function(result)
                                otv = result.Body
                            end)
                            ]]
                        end
                    end

                end
            end
        end
    end
end

-------------------------------------------------------------游戏补充--------------------------------------------------------------------------------------

-- 非玩家实体使用了技能 A non-player entity (necro-book, chen creep, etc) used an ability
function Zodiac:OnNonPlayerUsedAbility(keys)
    print('[BAREBONES] OnNonPlayerUsedAbility')
    --DeepPrintTable(keys)

    local abilityname=  keys.abilityname
    
    if  abilityname == "elder_titan_echo_stomp" then
        local caster = EntIndexToHScript(keys.caster_entindex)
        local bkb_abil = caster:FindAbilityByName( "my_bkb" )
        
        bkb_abil:ApplyDataDrivenModifier( caster, caster, "my_black_king_bar", {duration = 1.8} )

    elseif abilityname == "phoenix_sun_ray_datadriven" then
        local caster = EntIndexToHScript(keys.caster_entindex)
        local bkb_abil = caster:FindAbilityByName( "my_bkb" )
        
        bkb_abil:ApplyDataDrivenModifier( caster, caster, "my_black_king_bar", {duration = 6.1} )
    end
end
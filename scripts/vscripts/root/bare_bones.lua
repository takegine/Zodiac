
print ( '[GameMode] be loadding' )
GameMode = GameMode or class({})

function GameMode:InitGameMode()
    GameRules:SetCustomGameSetupAutoLaunchDelay(30)--将自动启动延迟从默认值（30秒）更改为0秒
    GameRules:SetHeroSelectPenaltyTime(0)--设置没有选择英雄的惩罚时间
    GameRules:SetStrategyTime( 0 )--设置玩家在选择英雄和进入展示阶段之间的时间。
    GameRules:SetShowcaseTime(0)--设置玩家在策略阶段和进入赛前阶段之间的时间
    --GameRules:ForceGameStart(true)--将游戏状态转换为DOTA_GAMERULES_STATE_GAME_IN_PROGRESS
    GameRules:SetPreGameTime(0)--设置选择英雄与开始游戏之间的倒数时间
    GameRules:SetStartingGold(450)--出门金币
    GameRules:SetHeroSelectionTime(HERO_SELECTION_TIME)--设置选择英雄的时间
    GameRules:SetUseUniversalShopMode(true)--商店范围内可以购买全部商品，不再限制家里还是边路还是秘密商店
    GameRules:SetHeroRespawnEnabled( false )-- 设定英雄不能重生
	GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
	GameRules:SetPostGameTime( POST_GAME_TIME )--结束记分板展示时长
	GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )--英雄复选
    GameRules:EnableCustomGameSetupAutoLaunch(true)--启用 (true)或禁用 (false) 自定义游戏的自动设置。
    GameRules:LockCustomGameSetupTeamAssignment(false)--锁定(true)或解锁(false)队伍分配.。如果队伍分配被锁定，玩家将不再能修改队伍
    GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)--死亡后自己不扣钱
    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 0 )
    GameRules:SetCustomGameTeamMaxPlayers( 6, 5 )
    GameRules:SetCustomGameTeamMaxPlayers( 7, 5 )
    GameRules:SetCustomGameTeamMaxPlayers( 8, 5 )
    GameRules:SetCustomGameTeamMaxPlayers( 9, 5 )
    SendToServerConsole("dota_max_physical_items_purchase_limit 9999") --购物个数上线改为9999个
    --[[
        GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(true)--信使
    ListenToGameEvent("entity_killed", 		Dynamic_Wrap(Zodiac, "OnEntityKilledHero"), self)--同一事件名可以有不同的函数，但是基本没这个必要
    ListenToGameEvent("entity_hurt", 		Dynamic_Wrap(Zodiac, "OnEntityHurt"), self)--监听单位受到伤害事件

    ListenToGameEvent("player_disconnect",  Dynamic_Wrap(Zodiac, "OnPlayerDisconnect"), self)--监听玩家断开连接的事件
    ListenToGameEvent("dota_item_purchased",Dynamic_Wrap(Zodiac, "OnDotaItemPurchased"), self)--监听物品被购买的事件
    ListenToGameEvent("player_chat", 		Dynamic_Wrap(Zodiac, "PlayerChat"), self)--监听玩家聊天事件
    ]]
    
    if GetMapName()=="rectangle" then require("root/rectangle") end
    self.game=Zodiac()
    self.game:new()

    GameRules:GetGameModeEntity():SetThink( "OnThink", self, 2 )--加一个计时器，输出游戏失败
    ListenToGameEvent("entity_hurt",                 Dynamic_Wrap(self.game, "entity_hurt"), self.game)
    ListenToGameEvent("npc_spawned",                Dynamic_Wrap(self.game, "OnNPCSpawned"), self.game)--监听单位重生或者创建事件
    ListenToGameEvent("entity_killed",		       Dynamic_Wrap(self.game,"OnEntityKilled"), self.game)--单位被击杀
    ListenToGameEvent('player_connect_full',       Dynamic_Wrap(self.game, 'OnConnectFull'), self.game)--所有玩家连入后加载玩家信息，加载游戏模式，
    ListenToGameEvent('dota_player_gained_level',Dynamic_Wrap(self.game, 'OnPlayerLevelUp'), self.game)--玩家升级
    ListenToGameEvent("game_rules_state_change",Dynamic_Wrap(self.game,"OnGameRulesStateChange"), self.game) --游戏阶段改变

    
    CustomGameEventManager:RegisterListener("UpdateProfiles", Dynamic_Wrap(self, 'UpdateProfiles'))--刷新玩家历史记录数据
    CustomGameEventManager:RegisterListener("Updatenandu", Dynamic_Wrap(self, 'NeedSteamIds'))--刷新玩家历史记录数据

    
    Convars:RegisterCommand( "getfullrelic", Dynamic_Wrap(self, 'GetFullRelic'),         " 1", 0 )--注册一个控制台指令，给自己全部遗物
    Convars:RegisterCommand( "getrelicstones", Dynamic_Wrap(self, 'GetRelicStones'),     " 1", 0 )--注册一个控制台指令，给自己RS石头
    
end

function GameMode:OnThink()
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then return nil end
       return 1
   end

function GameMode:UpdateProfiles(data)--更新玩家历史游戏记录
    --RelicStone:Levels(data)

    GameMode:NeedSteamIds(data)--得到steamID


    local pplc = PlayerResource:GetPlayerCount()
    for i=0,pplc-1 do
        --CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(data.PlayerID), "MyProfileInfo", MyProfileArray[i])--只传给发来请求的玩家
        CustomGameEventManager:Send_ServerToAllClients( "MyProfileInfo", MyProfileArray[i])--传给所有玩家
    end
end

function GameMode:NeedSteamIds(data)--获取STEAMID发给客户端
    local result = {}
    
    for i=0,PlayerResource:GetPlayerCount()-1 do
        result[i] = {}
        table.insert(result[i],PlayerResource:GetSteamID(i))
        if PlayerResource:HasSelectedHero(i) then
            table.insert(result[i],PlayerResource:GetSelectedHeroName(i))
        end
      --result[i]={ PlayerResource:GetSteamID(i), PlayerResource:GetSelectedHeroName(i) }
    end
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(data.PlayerID), "SteamIds", result)
end

--[[function GameMode:_CheckForDefeat()--游戏失败
    if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        return
    end

    local bAllPlayersDead = true
    for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetTeam( i ) == DOTA_TEAM_GOODGUYS and PlayerResource:HasSelectedHero( i ) then
            local hero = PlayerResource:GetSelectedHeroEntity( i )
            if hero and hero:IsAlive() then  bAllPlayersDead = false  end
        end
    end

    if bAllPlayersDead then
        local plc = PlayerResource:GetPlayerCount()
        for i=0,plc-1 do
            local sch = PlayerResource:GetSelectedHeroEntity(i).damage_schetchik
            if sch == nil then  sch = 0  end
            local tbl = {
                tdmg = PlayerResource:GetCreepDamageTaken(i,true),
                heal = PlayerResource:GetHealing(i),
                last = PlayerResource:GetLastHits(i),
                ddmg = math.ceil(sch)
            }
            CustomNetTables:SetTableValue("Hero_Stats",tostring(i),tbl)
        end
        GameMode:_Stats(nil)
        GameRules:MakeTeamLose( DOTA_TEAM_GOODGUYS )
        return
    end
end]]

function GameMode:TheGameEndding(WinTeamInt)
    --GameMode:_Stats("1")  --给后端发送游戏数据,胜利发1，失败
    for i=0,PlayerResource:GetPlayerCount()-1 do    --按实际玩家数循环
        local sch = PlayerResource:GetSelectedHeroEntity(i).damage_schetchik--获得该玩家的伤害计数器
        if sch == nil then sch = 0 end --如果没有就令其为0，防止bug
        
        local tbl = {--整合以下数据为表单，便于调用
            tdmg = PlayerResource:GetCreepDamageTaken(i,true),--获取该玩家受到的来自野怪的伤害
            heal = PlayerResource:GetHealing(i),              --获取该玩家治疗量
            last = PlayerResource:GetLastHits(i),             --获取最后一击的伤害
            ddmg = math.ceil(sch)							  --sch向上取整数
        }
        CustomNetTables:SetTableValue("Hero_Stats",tostring(i),tbl) --建立名为"Hero_Stats"的数组，i为keys,值为表单tbl
    end
    Timers:CreateTimer(0.1, function()--在0.1秒后执行
        GameRules:SetGameWinner(WinTeamInt)--令天辉军团胜利
    end)
end
-------------------------------------------------------------控制台调用--------------------------------------------------------------------------------------

function GameMode:GetFullRelic(strid)
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer and tostring(PlayerResource:GetSteamID(cmdPlayer:GetPlayerID())) == "76561198087419846" then
        if strid ~= nil then
            local id = tonumber(strid)
            local hero = PlayerResource:GetSelectedHeroEntity(id)
            hero.lvl_item_relic_damage = 20
            hero.lvl_item_relic_armor = 20
            hero.lvl_item_relic_magres = 20
            hero.lvl_item_relic_attackspeed = 20
            hero.lvl_item_relic_allsatas = 20
            hero.lvl_item_relic_magvam = 20
            hero.lvl_item_relic_magdam = 20
            hero.lvl_item_book = 1
            hero.rsinv = ""
            hero.rsp = 0
            hero.rsslots = ""
            hero.rssaves = ""
            
            local relicboolarr = {
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true
            }
            hero.seal = true
            hero.actseal = true
            hero.relicboolarr = relicboolarr
            local data = {}
            data.PlayerID = id
            Zodiac:Levels(data)
        end
    end
end

function GameMode:GetRelicStones(rs)
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer and tostring(PlayerResource:GetSteamID(cmdPlayer:GetPlayerID())) == "76561198087419846" then
        if rs ~= nil then
            CustomGameEventManager:Send_ServerToAllClients( "AddRSUI", {rsid = rs,hero = PlayerResource:GetSelectedHeroName(cmdPlayer:GetPlayerID())})
        else
            CustomGameEventManager:Send_ServerToAllClients( "AddRSUI", {rsid = "40143044164",hero = PlayerResource:GetSelectedHeroName(cmdPlayer:GetPlayerID())})
        end
    end
end

-----------------------------------------------以下单独作用给指定玩家，与全局游戏无关-----------------------------------------------------------
function GameMode:CheckWearables(unit) 		 --给自己特权的装备检查
    if tostring(PlayerResource:GetSteamID(unit:GetPlayerID())) == "76561198087419846" then
        if unit:GetName() == "npc_dota_hero_juggernaut" then
            GameMode:RemoveAllWearables(unit)
            GameMode:AttachWearable(unit,"models/items/juggernaut/armor_for_the_favorite_arms/armor_for_the_favorite_arms.vmdl","particles/econ/items/juggernaut/armor_of_the_favorite/juggernaut_favorite_shoulder_ambient.vpcf")
            GameMode:AttachWearable(unit,"models/items/juggernaut/armor_for_the_favorite_back/armor_for_the_favorite_back.vmdl","particles/econ/items/juggernaut/armor_of_the_favorite/juggernaut_favorite_shoulder_ambient.vpcf")
            GameMode:AttachWearable(unit,"models/items/juggernaut/armor_for_the_favorite_head/armor_for_the_favorite_head.vmdl","particles/econ/items/juggernaut/armor_of_the_favorite/juggernaut_favorite_eyes.vpcf")
            GameMode:AttachWearable(unit,"models/items/juggernaut/armor_for_the_favorite_legs/armor_for_the_favorite_legs.vmdl","particles/econ/items/juggernaut/armor_of_the_favorite/juggernaut_favorite_body_ambient.vpcf")
            GameMode:AttachWearable(unit,"models/items/juggernaut/armor_for_the_favorite_weapon/armor_for_the_favorite_weapon.vmdl","particles/econ/items/juggernaut/armor_of_the_favorite/juggernaut_favorite_weapon.vpcf")
        end
        if unit:GetName() == "npc_dota_hero_dazzle" then
            GameMode:RemoveAllWearables(unit)
            GameMode:AttachWearable(unit,"models/items/dazzle/darkclaw_acolyte_back/darkclaw_acolyte_back.vmdl","particles/econ/items/dazzle/dazzle_darkclaw/dazzle_darkclaw_ambient_head.vpcf")
            GameMode:AttachWearable(unit,"models/items/dazzle/darkclaw_acolyte_misc/darkclaw_acolyte_misc.vmdl",nil)
            GameMode:AttachWearable(unit,"models/items/dazzle/darkclaw_acolyte_legs/darkclaw_acolyte_legs.vmdl",nil)
            GameMode:AttachWearable(unit,"models/items/dazzle/darkclaw_acolyte_arms/darkclaw_acolyte_arms.vmdl",nil)
            GameMode:AttachWearable(unit,"models/items/dazzle/darkclaw_acolyte_weapon/darkclaw_acolyte_weapon.vmdl","particles/econ/items/dazzle/dazzle_darkclaw/dazzle_darkclaw_ambient.vpcf")
        end
    end
end

function GameMode:RemoveAllWearables(hero)
    local wearables = {} 				-- 删除本地数组声明
    local cur = hero:FirstMoveChild()	-- hero () 获取对象的子对象上的第一个指针

    while cur ~= nil do 				-- 只要我们当前的指针不是nil（void / null指针）
        cur = cur:NextMovePeer() 		-- 选择以下指向我们对象的子对象的指针
        if cur ~= nil and cur:GetClassname() ~= "" and cur:GetClassname() == "dota_item_wearable" then
            -- 检查当前指针是否不为空，类名称是否为空，以及该类是否为“ dota_item_wearable”类，即放置在化妆品上
            table.insert(wearables, cur)-- 将当前项目添加到表中以进行删除（我们从上方检查了当前对象的类）
        end
    end
    
    for i = 1, #wearables do			-- 删除输入数组中要删除的所有内容的实际循环
        UTIL_Remove(wearables[i]) 		-- 删除对象
    end
end

function GameMode:AttachWearable(unit, modelPath,part)
    local wearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model = modelPath, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})

    wearable:FollowEntity(unit, true)
    
    if part ~= nil then
        local mask1_particle = ParticleManager:CreateParticle( part, PATTACH_ABSORIGIN_FOLLOW, wearable )
        ParticleManager:SetParticleControlEnt( mask1_particle, 0, wearable, PATTACH_POINT_FOLLOW, "attach_part" , unit:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( mask1_particle, 1, wearable, PATTACH_POINT_FOLLOW, "attach_part" , unit:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( mask1_particle, 2, wearable, PATTACH_POINT_FOLLOW, "attach_part" , unit:GetOrigin(), true )
    end
    
    unit.wearables = unit.wearables or {}
    table.insert(unit.wearables, wearable)

    return wearable
end

function GameMode:RemoveWearables(unit)
    if not unit.wearables or #unit.wearables == 0 then --该单位有饰品或者饰品数不为零的话，结束该函数
        return
    end

    for _, part in pairs(unit.wearables) do				--该单位饰品非空非零则移除饰品
        part:RemoveSelf()
    end

    unit.wearables = {}									--清空列表
end

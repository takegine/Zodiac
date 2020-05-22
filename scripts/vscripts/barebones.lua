
print ( '[GameMode] be running' )
if  GameMode== nil then GameMode = class({}) end

function GameMode:InitGameMode()
    GameRules:SetPreGameTime(5)--设置选择英雄与开始游戏之间的倒数时间
    GameRules:SetStartingGold(450)--出门金币
    GameRules:SetStrategyTime( 0 )--设置玩家在选择英雄和进入展示阶段之间的时间。
    GameRules:SetHeroSelectionTime(HERO_SELECTION_TIME)--设置选择英雄的时间
    GameRules:SetHeroSelectPenaltyTime(0)--设置没有选择英雄的惩罚时间
    GameRules:SetUseUniversalShopMode(true)--商店范围内可以购买全部商品，不再限制家里还是边路还是秘密商店
    GameRules:SetHeroRespawnEnabled( false )-- 设定英雄不能重生
    GameRules:SetCustomGameSetupAutoLaunchDelay(0)--将自动启动延迟从默认值（30秒）更改为0秒
    GameRules:EnableCustomGameSetupAutoLaunch(true)--启用 (true)或禁用 (false) 自定义游戏的自动设置。
    GameRules:LockCustomGameSetupTeamAssignment(true)--锁定(true)或解锁(false)队伍分配.。如果队伍分配被锁定，玩家将不再能修改队伍
    GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)--死亡后自己不扣钱
    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )--天灾最多0个人
    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 9 )--近卫最多9个人
    SendToServerConsole("dota_max_physical_items_purchase_limit 9999") --购物个数上线改为9999个
    --[[
        GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(true)--信使
    ListenToGameEvent("entity_killed", 		Dynamic_Wrap(Zodiac, "OnEntityKilledHero"), self)--同一事件名可以有不同的函数，但是基本没这个必要
    ListenToGameEvent("entity_hurt", 		Dynamic_Wrap(Zodiac, "OnEntityHurt"), self)--监听单位受到伤害事件

    ListenToGameEvent("player_disconnect",  Dynamic_Wrap(Zodiac, "OnPlayerDisconnect"), self)--监听玩家断开连接的事件
    ListenToGameEvent("dota_item_purchased",Dynamic_Wrap(Zodiac, "OnDotaItemPurchased"), self)--监听物品被购买的事件
    ListenToGameEvent("player_chat", 		Dynamic_Wrap(Zodiac, "PlayerChat"), self)--监听玩家聊天事件
    ]]
    self.game=Zodiac()
    self.game:new()

    GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter( Dynamic_Wrap( self.game, "ItemAddedToInventoryFilter" ), self )--设置一个过滤器，用来控制物品被放入物品栏时的行为。
    GameRules:GetGameModeEntity():SetThink( "OnThink", self.game, 2 )--加一个计时器，输出游戏失败
    ListenToGameEvent("npc_spawned",                Dynamic_Wrap(self.game, "OnNPCSpawned"), self)--监听单位重生或者创建事件
    ListenToGameEvent("entity_killed",		       Dynamic_Wrap(self.game,"OnEntityKilled"), self)--单位被击杀
    ListenToGameEvent('player_connect_full',       Dynamic_Wrap(self.game, 'OnConnectFull'), self)--所有玩家连入后加载玩家信息，加载游戏模式，
    ListenToGameEvent('dota_player_gained_level',Dynamic_Wrap(self.game, 'OnPlayerLevelUp'), self)--玩家升级
    ListenToGameEvent("game_rules_state_change",Dynamic_Wrap(self.game,"OnGameRulesStateChange"), self) --游戏阶段改变

    
    CustomGameEventManager:RegisterListener("UpdateProfiles", Dynamic_Wrap(self, 'UpdateProfiles'))--刷新玩家历史记录数据
    CustomGameEventManager:RegisterListener("Updatenandu", Dynamic_Wrap(self, 'NeedSteamIds'))--刷新玩家历史记录数据
end

function GameMode:UpdateProfiles(data)--更新玩家历史游戏记录
    RelicStone:Levels(data)

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
        local arr={}
        table.insert(arr,PlayerResource:GetSteamID(i))
        if PlayerResource:HasSelectedHero(i) then
            table.insert(arr,PlayerResource:GetSelectedHeroName(i))
        end
        result[i] = arr;
    end
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(data.PlayerID), "SteamIds", result)
end



function GameMode:_Stats(iswin)
    local plc = PlayerResource:GetPlayerCount() 		--玩家数
    if not GameRules:IsCheatMode()  					--非作弊模式
        and _G.GAME_ROUND ~= 0 							--游戏已经开始。轮数不为0
        and cheats == false 							--作弊状态为假
        and GameRules:GetDOTATime(false,false) > 35 	--返回Dota游戏内的时间，不包含 赛前时间PregameTime 和 负时间NegativeTime
        and plc > 0 then 								--玩家数大于0
        local req = CreateHTTPRequestScriptVM( "POST", GameMode.gjfll2 .. "/data.php")--创建一个通讯到数据服务器
        req:SetHTTPRequestGetOrPostParameter("v", _G.DedicatedServerKey)--专用服务器密钥
        if iswin ~= nil then 							--判断是否通关
            req:SetHTTPRequestGetOrPostParameter("test", "-1" .. iswin)
        else
            req:SetHTTPRequestGetOrPostParameter("test", tostring(_G.GAME_ROUND))
        end 											--把玩家数和通关时间发给服务器
        req:SetHTTPRequestGetOrPostParameter("players", tostring(plc))
        req:SetHTTPRequestGetOrPostParameter("time", tostring(math.floor(GameRules:GetDOTATime(false,false))))

        if _G.hardmode > 1 then 	       				--判断游戏难度，把通关难度发给服务器
            req:SetHTTPRequestGetOrPostParameter("hardmode", "true")
        else
            req:SetHTTPRequestGetOrPostParameter("hardmode", "false")
        end
        for i=0,plc-1 do 										--遍历所有玩家
            if PlayerResource:GetConnectionState(i) == 2 then 	--在线的玩家，把通关记录发给服务器
                req:SetHTTPRequestGetOrPostParameter("hero" .. i+1,tostring(PlayerResource:GetSelectedHeroID(i)))
                req:SetHTTPRequestGetOrPostParameter("id" .. i+1, tostring(PlayerResource:GetSteamID(i)))
            end
        end
        req:Send(function(result)
            print(result.Body)
        end)
    end
end

-- 多处调用该函数，获取全部玩家操作的英雄单位，返回清单
function GameMode:GetAllRealHeroes()
    local rheroes = {}
    local heroes = HeroList:GetAllHeroes()
    
    for i=1,#heroes do
        if heroes[i]:IsRealHero() then
            table.insert(rheroes,heroes[i])
        end
    end
    return rheroes
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

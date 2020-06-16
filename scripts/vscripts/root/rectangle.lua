--使Zodiac 为全局可用，Zodiac可自己改
print ( '[Zodiac] be loadding' )

Zodiac = Zodiac or class({})

-- 此函数初始化游戏模式，并在任何人加载到游戏之前调用
-- 可用于预先初始化以后需要的任何值/表
function Zodiac:new()
    print("print InitGameMode is loaded.")

    CustomGameEventManager:RegisterListener("Buy_Element",    Dynamic_Wrap(self, 'Buy_Element'))
    ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(self, 'OnNonPlayerUsedAbility'), self)
    _G.hardmode=1

    -- self.vUserIds  = {}
    -- self.vSteamIds = {}
    -- self.vBots     = {}
    -- self.vBroadcasters = {}
    -- _G.DedicatedServerKey = GetDedicatedServerKeyV2("2")
    
    cheats = GameRules:IsCheatMode()
end

function Zodiac:OnConnectFull(keys)
    print("function Zodiac:OnConnectFull()is working.")
    --DeepPrintTable(keys)
    require('root/GameMode')
    
    mode:SetItemAddedToInventoryFilter( Dynamic_Wrap( self, "ItemAddedToInventoryFilter" ), self )--设置一个过滤器，用来控制物品被放入物品栏时的行为。
    local ply      = EntIndexToHScript(keys.index+1)-- 正在进入的用户 玩家实体

    local playerID = ply:GetPlayerID()             -- 正在进入的用户 玩家ID

    -- self.game.vUserIds[keys.userid] = ply               -- 使用此用户ID更新用户ID表

    -- self.game.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply  -- 更新Steam ID表

    -- -- If the player is a broadcaster flag it in the Broadcasters table
    -- if PlayerResource:IsBroadcaster(playerID) then -- 
    --     self.game.vBroadcasters[keys.userid] = 1
    --     return
    -- end

    
    print("/////////////////////////////////////////////////////////////////////////////////////////////")
    local getboll = 0
    if _G.hardmode== 2 then getboll = 4 end
    if _G.hardmode== 3 then getboll = 0 end
    
    local value = {}
    while not (#need_drop_el==getboll) do
        roll_no = RandomInt( 1, #need_drop_el )
        print(roll_no)
        value[need_drop_el[roll_no]]=1
        table.remove(need_drop_el, roll_no)
    end
    for i=1,#need_drop_el do value[need_drop_el[i]]=0 end
    Zodiac.firstbolltable=value
    
    --DeepPrintTable(value)
end

function Zodiac:OnGameRulesStateChange( keys ) 
    local newState = GameRules:State_Get() 
    print ("print  OnGameRulesStateChange is running."..newState)

    if     newState == DOTA_GAMERULES_STATE_HERO_SELECTION then

    elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then  --玩家处于选择选完的准备界面
        
        local unit = CreateUnitByName( "npc_dota_gold_spirit", Vector(0,0,0), true, nil, nil, DOTA_TEAM_GOODGUYS )
        
        for i=0, PlayerResource:GetPlayerCount()-1 do
            if not PlayerResource:HasSelectedHero(i) then PlayerResource:GetPlayer(i):MakeRandomHeroSelection() end
        end

    elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        Zodiac:Continue()
    end
end

function Zodiac:Continue()
    
    local return_time = 60 + _G.GAME_ROUND -- 关卡之间的时间
    local time_ = 1
    
    cheats = GameRules:IsCheatMode()

    local heroes = GameMode:GetAllRealHeroes()
    
    table.foreach(heroes,function(k,h)
        if h.damage_schetchik then
            if  h.oldwd then
                h.nowwd = math.ceil(h.damage_schetchik - h.oldwd)
                h.oldwd = math.ceil(h.damage_schetchik)
            else
                h.nowwd = math.ceil(h.damage_schetchik)
                h.oldwd = math.ceil(h.damage_schetchik)
            end
        else
            h.oldwd = 0
            h.nowwd = 0
        end
        
        if not h:IsAlive() then h:RespawnUnit() end
        h:SetHealth(h:GetMaxHealth())
        h:SetMana(h:GetMaxMana())
        local bottle = h:FindItemInInventory("item_bottle")
        if bottle then bottle:SetCurrentCharges(math.ceil(2+_G.GAME_ROUND/5)) end
    end)
    
    local dlist  = {}
    local myneedheroes = GameMode:GetAllRealHeroes()
    for i= #myneedheroes,1,-1 do
        local maxdh = nil
        local maxdmg = -1
        for n=1, #myneedheroes do
            if myneedheroes[n] and myneedheroes[n].nowwd > maxdmg then
                maxdmg = myneedheroes[n].nowwd
                maxdh  = n
            end
        end
        
        dlist["hero"..i]=myneedheroes[maxdh]:GetName()
        dlist["damage"..i]=myneedheroes[maxdh].nowwd
        table.remove(myneedheroes,maxdh)
    end
    CustomGameEventManager:Send_ServerToAllClients( "Open_DamageTop", dlist)
    
    local heronametab = {}
    for i = 1,10 do
        if i <= #heroes then heronametab["hero"..i]=heroes[i]:GetName()
        else heronametab["hero"..i]=""
        end
    end
    CustomGameEventManager:Send_ServerToAllClients( "Display_RoundVote",heronametab)
    
    QuestSystem:CreateQuest("PrepTime","#QuestPanel",1,return_time,nil,_G.GAME_ROUND + 1)

    Timer(function()
        local gogame = 0
        for i=0,#heroes do
            local InBox = Entities:FindByName(nil,"neutral_camp"):IsTouching(heroes[i])
            if InBox then gogame=gogame+1 end
            print(".."..i.."..".."false",tostring(InBox))
            --CustomGameEventManager:Send_ServerToAllClients("changevote",{hero=heroes[i]:GetName(),bool=tostring(InBox)})
    
            print(".."..i.."..".."false")
        end
    
        if time_ <= return_time and gogame ~= PlayerResource:GetPlayerCount() then
            QuestSystem:RefreshQuest("PrepTime",time_,return_time,_G.GAME_ROUND + 1)
            print("countdown wait time_: ",time_)
            time_ = time_ + 1
            return 1 
        else
    
            _G.GAME_ROUND = _G.GAME_ROUND + 1
            QuestSystem:DelQuest("PrepTime")
            CustomNetTables:SetTableValue("Hero_Stats","wave",{_G.GAME_ROUND})
            CustomGameEventManager:Send_ServerToAllClients( "Close_DamageTop", {})
            CustomGameEventManager:Send_ServerToAllClients( "Close_RoundVote", {})
            EmitGlobalSound("Tutorial.Quest.complete_01")
    
            print("..................round:",_G.GAME_ROUND,".....................")
            
            for i=1,3 do
                local unitname = "npc_dota_custom_creep_".._G.GAME_ROUND.."_"..i
                if ROUND_UNITS[unitname] then
                    local unitnum  = tonumber(ROUND_UNITS[unitname][tostring(_G.hardmode)]) or 0
                    local point    = Entities:FindByName( nil, "sweepbirth"):GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) )
                    for k=1,unitnum do
                        CreateUnitByName( unitname, point, true, nil, nil, DOTA_TEAM_BADGUYS ).enemy=true
                    end
                end
            end
            
            print("refresh all modifiers on hero")
            for i=1, #heroes do
                if PlayerResource:GetConnectionState(heroes[i]:GetPlayerOwnerID()) == 2 then
                    table.foreach( heroes[i]:FindAllModifiers(),function(_,b) if b:GetAbility() and b.needupwawe then b:OnWaweChange(_G.GAME_ROUND) end end)
                end
            end
        end
    end)
end

function Zodiac:OnNPCSpawned(keys)
    
    local npc = EntIndexToHScript(keys.entindex)
    print("[Zodiac] NPC Spawned ",npc:GetUnitName())


    if npc.bFirstSpawned then return end
        
    npc.bFirstSpawned = true
    if  npc:IsRealHero() then
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
        --Timers:CreateTimer(1, function() RelicStone:LoadRelics(info) end)

        if _G.hardmode == 1 then npc:AddNewModifier(npc, nil, "modifier_easy_mode", {}) end
    
        CustomNetTables:SetTableValue("Elements_Tabel",tostring(id), Zodiac.firstbolltable)
        --hRequest:Login(id)

        --[[给资助的人一个宠物
        if _G.patreons[tostring(PlayerResource:GetSteamID(id))] ~= nil then
            if _G.patreons[tostring(PlayerResource:GetSteamID(id))] > 3 then
                info.hero = npc
                Pets.CreatePet( info )
            end
        end]]
    else
        local unitname = npc:GetUnitName()
        --[[ for i = 1,2* (_G.hardmode - 1) do
            local enemyitem={} --另外写一个物品表单来调用
                local num = math.random(#enemyitem[_G.GAME_ROUND])  --随机个数表示这个物品
            
            unit:AddItemByName(enemyitem[_G.GAME_ROUND][num])--按照随机数给该物品

            --根据难度怪物会获得装备，件数为2* (_G.hardmode - 1)  有个装备列表，怪物随机获得其中装备
        end]]
        if ADDED_ITEM[unitname] then
            table.foreach(ADDED_ITEM[unitname],function(item,hard)  if _G.hardmode > hard then npc:AddItemByName(item) end end)
        end
        if ADDED_ABLE[unitname] then
            table.foreach(ADDED_ABLE[unitname],function(_,able)  npc:AddAbility(able):SetLevel(1) end)
        end
    end
end

function Zodiac:OnEntityKilled( keys )
    print("OnEntityKilled")
        --DeepPrintTable(keys)    --详细打印传递进来的表
    local killedUnit = EntIndexToHScript( keys.entindex_killed )--取得死者实体
    
    if killedUnit and killedUnit:IsHero() then
        local newItem = CreateItem( "item_tombstone", killedUnit, killedUnit )
              newItem:SetPurchaseTime( 0 )
              newItem:SetPurchaser( killedUnit )
        local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
              tombstone:SetContainedItem( newItem )
              tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
              tombstone:SetModelScale(RandomFloat( 2, 3 ))
        FindClearSpaceForUnit( tombstone, killedUnit:GetAbsOrigin(), true )

        local test2 = Entities:FindAllByName("item_tombstone")
        if  #test2 == PlayerResource:GetPlayerCount() then GameMode:TheGameEndding( DOTA_TEAM_BADGUYS ) end
    end
    
    if killedUnit:GetUnitName() == "npc_dota_custom_creep_50_1" then GameMode:TheGameEndding( DOTA_TEAM_GOODGUYS ) end

    if killedUnit:GetTeam() == 3 and killedUnit:GetName() == "npc_dota_creature" then
        if not killedUnit:IsIllusion() then
            local getxp  = killedUnit:GetBaseDayTimeVisionRange()
            local heroes = GameMode:GetAllRealHeroes()
            if  getxp > 0 then
                table.foreach(heroes,function(_,h) 
                    h:AddExperience(getxp / #heroes*(0.75+0.05*#heroes),
                    false,false) 
                end )
            end
        end
        if  killedUnit:IsCreature() then RollDrops(killedUnit) end
        
        killedUnit:Destroy()
        local units = Entities:FindAllByName("npc_dota_creature")
        if units then
            for b=#units,1,-1 do
                if units[b]:GetTeam() ~= 3 
                or not units[b]:IsAlive()
                then table.remove(units,b) end
            end
        end
        
        print("Remaining enemy count: ",#units)
        if not units or #units == 0 then Zodiac:Continue() end
    end
end

function RollDrops(unit)
    local DropInfo = DropTable[unit:GetUnitName()]
    if not DropInfo then return end

    table.foreach(DropInfo,function( item_name, ItemTable)
        local introll = ItemTable.roll or 100
        local intmuch = ItemTable.much or 1
        print("RollDrops", unit:GetUnitName(), introll, intmuch, item_name)
        for i=1,intmuch do
            if     item_name == "item_25gold" then
                if RollPercentage(introll) then
                    local item = CreateItem(item_name, nil, nil)
                    item:SetPurchaseTime(0)
                    CreateItemOnPositionSync( unit:GetAbsOrigin() , item )
                    item:LaunchLoot(false, 200, 0.75, unit:GetAbsOrigin() + RandomVector(RandomFloat(150,200)) )
                end

            elseif item_name == "item_elbol" then
                if #need_drop_el == 0 then 
                    for g=1,10 do need_drop_el[g]=g end 
                end
                local roll_no = RandomInt( 1, #need_drop_el )
                for z=0, PlayerResource:GetPlayerCount()-1 do
                    local myTable  = CustomNetTables:GetTableValue("Elements_Tabel",tostring(z))
                    -- local nFXIndex = ParticleManager:CreateParticle( partlist[need_drop_el[roll_no]], PATTACH_OVERHEAD_FOLLOW, unit )--特效--原参数2 PATTACH_ABSORIGIN
                    -- --ParticleManager:SetParticleControl( nFXIndex, 0, drop_item:GetAbsOrigin() )
                    -- --ParticleManager:SetParticleControl( nFXIndex, 1, containedItem:GetPurchaser():GetAbsOrigin() )
                    -- ParticleManager:SetParticleControlEnt( nFXIndex, 1, PlayerResource:GetSelectedHeroEntity(z), PATTACH_POINT_FOLLOW, "attach_hitloc", PlayerResource:GetSelectedHeroEntity(z):GetOrigin(), true )
                    -- --SetParticleControlEnt(particle: ParticleID, controlPoint: int, unit: CDOTA_BaseNPC, particleAttach: ParticleAttachment_t, attachment: string, offset: Vector, lockOrientation: bool)
                    -- --设置CP点参数
                    -- ParticleManager:ReleaseParticleIndex( nFXIndex )--释放特效
                    myTable[tostring(need_drop_el[roll_no])] = myTable[tostring(need_drop_el[roll_no])] + 1
                    CustomNetTables:SetTableValue("Elements_Tabel",tostring(z),myTable)
                end
                table.remove(need_drop_el,roll_no) 

            elseif ItemTable.sins then
                if RollPercentage(introll*PlayerResource:GetPlayerCount()) then
                    local item = CreateItem(item_name, nil, nil)
                            item:SetPurchaseTime(0)
                            item.bIsRelic = true
                    CreateItemOnPositionSync( unit:GetAbsOrigin(), item )
                    item:LaunchLoot(false, 200, 0.75, unit:GetAbsOrigin()+RandomVector(RandomFloat(110,140)))

                    local PlayerIDs = {}                            
                    table.foreach( GameMode:GetAllRealHeroes() ,function(_,h)
                        if not h:HasOwnerAbandoned() and PlayerResource:GetConnectionState(h:GetPlayerID()) == 2 then
                            table.insert( PlayerIDs, Hero:GetPlayerID() )
                        end
                    end)

                    --抽一个玩家作为得到掉落的人
                    local WinningPlayerID = nil
                    WinningPlayerID = PlayerIDs[ RandomInt( 1, #PlayerIDs ) ]

                    if not WinningPlayerID then return end
                    
                    local WinningHero = PlayerResource:GetSelectedHeroEntity( WinningPlayerID )
                    item:SetPurchaser( WinningHero )
                    if not WinningHero["lvl_"..item_name] then 
                            WinningHero["lvl_"..item_name] = 1
                    else   WinningHero["lvl_"..item_name] = WinningHero["lvl_"..item_name] + 1
                    end
                    
                    EmitSoundOn( "sounds/misc/soundboard/absolutely_perfect.vsnd", WinningHero )
                    --[[
                    local otv = ""
                    local req = CreateHTTPRequestScriptVM( "POST", Zodiac.gjfll2 .. "/lol21.php")
                    req:SetHTTPRequestGetOrPostParameter("id", tostring(PlayerResource:GetSteamID( WinningPlayerID )))
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
    end)
end

-------------------------------------------------------------游戏补充--------------------------------------------------------------------------------------

-- 非玩家实体使用了技能 A non-player entity (necro-book, chen creep, etc) used an ability
function Zodiac:OnNonPlayerUsedAbility(keys)
    
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

function Zodiac:OnPlayerLevelUp(keys)
    local hero = EntIndexToHScript(keys.hero_entindex)
    if keys.level >= 30 then hero:SetAbilityPoints(hero:GetAbilityPoints() + 1) end
end

function Zodiac:ItemAddedToInventoryFilter( filterTable )
    if filterTable["item_entindex_const"] == nil 
    or filterTable["inventory_parent_entindex_const"] == nil then
        return true
    end

    local hItem = EntIndexToHScript( filterTable["item_entindex_const"] )
    local parent = EntIndexToHScript( filterTable["inventory_parent_entindex_const"] )

    if not hItem or not parent or hItem:GetAbilityName() == "item_tombstone" or not parent:IsRealHero() then return true end

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
    
    if  hItem:GetPurchaser() ~= parent then
            Timer(0.01,function() parent:DropItemAtPositionImmediate( hItem, hItem:GetPurchaser():GetAbsOrigin()+RandomVector(20) ) end)
    elseif rlcs[hItem:GetAbilityName()] then 
        for i=0, 9, 1 do
            local current_item = parent:GetItemInSlot(i)
            if current_item and rlcs[current_item:GetAbilityName()] then
                if hItem:GetAbilityName() == current_item:GetAbilityName() then local reitem = hItem
                elseif rlcs[hItem:GetAbilityName()] < rlcs[current_item:GetAbilityName()] then local reitem = hItem
                elseif rlcs[hItem:GetAbilityName()] > rlcs[current_item:GetAbilityName()] then local reitem = current_item 
                end
                if reitem then parent:RemoveItem(reitem) end
            end
        end
    --elseif notforall[itemA] then hItem:SetPurchaser( parent )
    end
    return true
end

function Zodiac:Buy_Element(event)
    
    local myTable = CustomNetTables:GetTableValue("Elements_Tabel",tostring(event.PlayerID))
    if myTable[tostring(event.num)] <= 0 then return end
    
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)

    for i=0,15 do
        if  not hero:GetItemInSlot(i) then
            myTable[tostring(event.num)] =  myTable[tostring(event.num)] - 1
            CustomNetTables:SetTableValue("Elements_Tabel",tostring(event.PlayerID),myTable)
            local itemname = all_elements[event.num]  
            local item = CreateItem(itemname, hero, hero)
                  item:SetPurchaseTime(0)
                  item:SetPurchaser( hero )
            EmitSoundOn( "General.Buy", hero )
            hero:AddItem(item)

            break
        end
    end   
end
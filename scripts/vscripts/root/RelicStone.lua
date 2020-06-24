
print ( '[RelicStone] be loadding' )
RelicStone = RelicStone or {}

function RelicStone:listenList()
    CustomGameEventManager:RegisterListener("Buy_Relic",      Dynamic_Wrap(RelicStone, 'Buy_Relic'))--购买relic
    CustomGameEventManager:RegisterListener("SniatRS",        Dynamic_Wrap(RelicStone, 'SniatRS'))--跳转了两个函数，和relicStone相关，功用未知
    CustomGameEventManager:RegisterListener("EqipRS",         Dynamic_Wrap(RelicStone, 'EqipRS'))--跳转了两个函数，和relicStone相关，功用未知
    CustomGameEventManager:RegisterListener("SetDefaultPart", Dynamic_Wrap(RelicStone, 'SetDefaultPart'))--猜测是分解粉末的按钮，存数据和CD
    CustomGameEventManager:RegisterListener("RefreshRelics",  Dynamic_Wrap(RelicStone, 'LoadRelics'))
    CustomGameEventManager:RegisterListener("Levels",         Dynamic_Wrap(RelicStone, 'Levels'))
end

function RelicStone:Buy_Relic(event) 
    print("function RelicStone:Buy_Relic()is working.")
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    if event.num == 0 then                  --如果他按了全买就是0，否则就是一个个买
        local item_list = {                 --一个relic清单
            "item_relic_damage",
            "item_relic_armor",
            "item_relic_magres",
            "item_relic_attackspeed",
            "item_relic_allsatas",
            "item_relic_magvam",
            "item_relic_magdam",
            "item_book"
        }
        if hero.relicboolarr ~= nil then  --
            for i=1,#item_list do         --按relic清单数遍历
            for x=0,15 do                --按库存空格数遍历
                if hero:GetItemInSlot(x) == nil and hero.relicboolarr[i] == true then
                --以下标值 x 获取物品栏中的物品。如果库存有空位置 且 英雄可以拥有该装备
                    local itemname =  item_list[i]
                    if    itemname == "item_book" and hero.actseal == true then
                          itemname =  "item_redemption_ticket"  --如果玩家已经激活seal，那么卷轴升级成为激活的卷轴
                    end
                    local item = CreateItem(itemname, hero, hero)
                    item:SetPurchaseTime(0)  --购买时间为0
                    item:SetPurchaser( hero )--购买者是该英雄
                    item.bIsRelic = true     --是relic
                    hero:AddItem(item)       --把物品加到该英雄的库存
                    hero.relicboolarr[i] = false
                    break                    --中断库存空格数的遍历
                end
            end
            end
        end
    else                          --他一个个买relic
        for x=0,15 do             --按库存空格数遍历
            if hero:GetItemInSlot(x) == nil and hero.relicboolarr[event.num] == true then
            --以下标值 x 获取物品栏中的物品。如果库存有空位置 且 英雄可以拥有该装备
                local itemname =  event.item
                if    itemname == "item_book" and hero.actseal == true then
                      itemname =  "item_redemption_ticket"  --如果玩家已经激活seal，那么卷轴升级成为激活的卷轴
                end
                local item = CreateItem(itemname, hero, hero)
                item:SetPurchaseTime(0)  --购买时间为0
                item:SetPurchaser( hero )--购买者是该英雄
                item.bIsRelic = true     --是relic
                EmitSoundOn( "General.Buy", hero )
                hero:AddItem(item)       --把物品加到该英雄的库存
                hero.relicboolarr[event.num] = false
                break                    --中断库存空格数的遍历
            end
        end
    end
end

function RelicStone:SniatRS(event)
    print("function RelicStone:SniatRS()is working.")
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    hero.rsslots[event.slotid] = ""
    local data = {}
    data.PlayerID = event.PlayerID
    RelicStone:UpdateRS(event.PlayerID)
    RelicStone:Levels(data)
end

function RelicStone:EqipRS(event)
    print("function RelicStone:EqipRS()is working.")
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    local eqiped = false
    for i=1,8 do
        if hero.rsslots[i] == event.rsid then
            eqiped = true
            break
        end
    end
    if eqiped == false then
        local find = false
        if hero.seal == true then
            for i=1,4 do
                if hero.rsslots[i] == "" then
                    hero.rsslots[i] = event.rsid
                    find = true
                    break
                end
            end
            if find == false then
                if hero.actseal == true then
                    for i=5,8 do
                        if hero.rsslots[i] == "" then
                            hero.rsslots[i] = event.rsid
                            --print(hero.rsslots[i])
                            find = true
                            break
                        end
                    end
                end
            end
        end
        --if find == true then
        --    RelicStone:Levels(event)
        --end
    end
    RelicStone:UpdateRS(event.PlayerID)
    RelicStone:Levels(event)
end

function RelicStone:SetDefaultPart(event)
    print("function RelicStone:SetDefaultPart()is working.")
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if  player.parttimerok == nil  then player.parttimerok = true end --值为空的时候，令其真
    if  player.parttimerok == true then player.parttimerok = false    --值为真的时候，令其假，等带30秒令其真，并发送回玩家
        Timers:CreateTimer(30, function()                             --设置30秒的CD
            player.parttimerok = true
            CustomGameEventManager:Send_ServerToPlayer( player, "DefaultButtonReady", {})
        end)
        local req = CreateHTTPRequestScriptVM( "POST", RelicStone.gjfll2 .. "/data.php") --创建一个到存储服务器的请求
        req:SetHTTPRequestGetOrPostParameter("inid", tostring(PlayerResource:GetSteamID(event.PlayerID)))
        req:SetHTTPRequestGetOrPostParameter("part", "defaults")
        req:SetHTTPRequestGetOrPostParameter( "reson", tostring(event.part) )
        req:SetHTTPRequestGetOrPostParameter("v", _G.DedicatedServerKey)
        req:Send(function(result)
            print(result.Body)
        end)
    end
end

function RelicStone:Levels(data)
    local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    local lvl_item_relic_damage = 0
    local lvl_item_relic_armor = 0
    local lvl_item_relic_magres = 0
    local lvl_item_relic_attackspeed = 0
    local lvl_item_relic_allsatas = 0
    local lvl_item_relic_magvam = 0
    local lvl_item_relic_magdam = 0
    local lvl_item_book = 0
    if hero then
        if hero.lvl_item_relic_damage ~= nil then
            lvl_item_relic_damage = hero.lvl_item_relic_damage
        end
        if hero.lvl_item_relic_armor ~= nil then
            lvl_item_relic_armor = hero.lvl_item_relic_armor
        end
        if hero.lvl_item_relic_magres ~= nil then
            lvl_item_relic_magres = hero.lvl_item_relic_magres
        end
        if hero.lvl_item_relic_attackspeed ~= nil then
            lvl_item_relic_attackspeed = hero.lvl_item_relic_attackspeed
        end
        if hero.lvl_item_relic_allsatas ~= nil then
            lvl_item_relic_allsatas = hero.lvl_item_relic_allsatas
        end
        if hero.lvl_item_relic_magvam ~= nil then
            lvl_item_relic_magvam = hero.lvl_item_relic_magvam
        end
        if hero.lvl_item_relic_magdam ~= nil then
            lvl_item_relic_magdam = hero.lvl_item_relic_magdam
        end
        if hero.lvl_item_relic_magdam ~= nil then
            lvl_item_book = hero.lvl_item_book
        end
        local myvalue = {
            data.PlayerID,
            lvl_item_relic_damage,
            lvl_item_relic_armor,
            lvl_item_relic_magres,
            lvl_item_relic_attackspeed,
            lvl_item_relic_allsatas,
            lvl_item_relic_magvam,
            lvl_item_relic_magdam,
            lvl_item_book,
            hero.rsinv,
            hero.rsp,
            hero.rsslots,
            hero.rssaves,
            hero.sealcolor,
            hero.sealcolors
        }
        CustomGameEventManager:Send_ServerToAllClients( "My_lvl", myvalue)
    end
    CustomGameEventManager:Send_ServerToAllClients( "My_lvl", myvalue)
end

function RelicStone:LoadRelics(info)
    local i = info.PlayerID
    if not PlayerResource:IsValidPlayerID(i) then return end    --如果不是玩家操作的就结束函数
    local  selectheroo = PlayerResource:GetSelectedHeroEntity(i)--选好的英雄实体
    if not selectheroo then return end                          --没英雄也结束
    if  selectheroo.needrefresh == nil then
        selectheroo.needrefresh = true                          --需要刷新，初始化为真
    end
    if selectheroo.needrefresh then
        local loaded = false
        print("Start Load")
        selectheroo.needrefresh = false                         --改为不需要初始化
        -- print("Steam" .. i .. " " .. tostring(PlayerResource:GetSteamID(i)))
        -- print(string.sub(tostring(PlayerResource:GetSteamID(i)),-1))
        local req = CreateHTTPRequestScriptVM( "POST", RelicStone.gjfll2 .. "/lol21.php")    --创建一个获取数据的函数
        req:SetHTTPRequestGetOrPostParameter("id",tostring(PlayerResource:GetSteamID(i)))--发送玩家ID
        req:SetHTTPRequestGetOrPostParameter("v", _G.DedicatedServerKey)                 --发送秘钥
        req:Send(function(result)
            local otv = result.Body
            print(otv)                          --打印反馈值
            if otv ~= "" then
                if otv ~= "none" then
                    local locstr = ""
                    local arrstr = {}
                    --print(i .. " = " .. otv)
                    for n=1, string.len(otv) do
                        if string.char(string.byte(otv, n)) ~= nil then
                            if string.char(string.byte(otv, n)) == " " then
                                table.insert(arrstr, locstr)
                                locstr = ""
                            else
                                locstr = locstr .. string.char(string.byte(otv, n))
                            end
                        end
                    end
                    if locstr ~= "" then
                        table.insert(arrstr, locstr)
                        locstr = ""
                    end
                    if arrstr[#arrstr] == "allok" then
                        loaded = true
                        arrstr[#arrstr] = nil
                        local value = arrstr

                        local seal = true
                        local actseal = true
                        local relicboolarr = {
                            false,
                            false,
                            false,
                            false,
                            false,
                            false,
                            false,
                            false
                        }
                        --####################################
                        if tonumber(value[1]) > 0 then
                            selectheroo.lvl_item_relic_damage = tonumber(value[1])
                            relicboolarr[1] = true
                            if tonumber(value[1]) < 20 then
                                actseal = false
                            end
                        else
                            seal = false
                            actseal = false
                            value[1] = nil
                        end
                        if tonumber(value[2]) > 0 then
                            selectheroo.lvl_item_relic_armor = tonumber(value[2])
                            relicboolarr[2] = true
                            if tonumber(value[2]) < 20 then
                                actseal = false
                            end
                        else
                            seal = false
                            actseal = false
                            value[2] = nil
                        end
                        if tonumber(value[3]) > 0 then
                            selectheroo.lvl_item_relic_magres = tonumber(value[3])
                            relicboolarr[3] = true
                            if tonumber(value[3]) < 20 then
                                actseal = false
                            end
                        else
                            seal = false
                            actseal = false
                            value[3] = nil
                        end
                        if tonumber(value[4]) > 0 then
                            selectheroo.lvl_item_relic_attackspeed = tonumber(value[4])
                            relicboolarr[4] = true
                            if tonumber(value[4]) < 20 then
                                actseal = false
                            end
                        else
                            seal = false
                            actseal = false
                            value[4] = nil
                        end
                        if tonumber(value[5]) > 0 then
                            selectheroo.lvl_item_relic_allsatas = tonumber(value[5])
                            relicboolarr[5] = true
                            if tonumber(value[5]) < 20 then
                                actseal = false
                            end
                        else
                            seal = false
                            actseal = false
                            value[5] = nil
                        end
                        if tonumber(value[6]) > 0 then
                            selectheroo.lvl_item_relic_magvam = tonumber(value[6])
                            relicboolarr[6] = true
                            if tonumber(value[6]) < 20 then
                                actseal = false
                            end
                        else
                            seal = false
                            actseal = false
                            value[6] = nil
                        end
                        if tonumber(value[7]) > 0 then
                            selectheroo.lvl_item_relic_magdam = tonumber(value[7])
                            relicboolarr[7] = true
                            if tonumber(value[7]) < 20 then
                                actseal = false
                            end
                        else
                            seal = false
                            actseal = false
                            value[7] = nil
                        end
                        if tonumber(value[8]) > 0 then
                            selectheroo.lvl_item_book = tonumber(value[8])
                            relicboolarr[8] = true
                        else
                            seal = false
                            actseal = false
                            value[8] = nil
                        end
                        --####################################
                        selectheroo.seal = seal
                        selectheroo.actseal = actseal
                        selectheroo.relicboolarr = relicboolarr
                        selectheroo.sealcolors = {}
                        local arrstr2 = {}
                        for n=1, string.len(value[18]) do
                            if string.char(string.byte(value[18], n)) ~= nil then
                                if string.char(string.byte(value[18], n)) == "|" then
                                    table.insert(arrstr2, locstr)
                                    locstr = ""
                                else
                                    locstr = locstr .. string.char(string.byte(value[18], n))
                                end
                            end
                        end
                        if locstr ~= "" then
                            table.insert(arrstr2, locstr)
                            locstr = ""
                        end
                        selectheroo.rsinv = arrstr2
                        selectheroo.rsp = tonumber(value[9])
                        selectheroo.rsslots = {"","","","","","","",""}
                        selectheroo.rssaves = {value[10],value[11],value[12],value[13],value[14],value[15],value[16],value[17]}
                        local data = {}
                        data.PlayerID = i
                        data.num = 1
                        RelicStone:LoadSet(data)
                        if selectheroo.rsslots[1] ~= "" then
                            selectheroo.sealcolor = tonumber(string.sub(selectheroo.rsslots[1], 2, 2))+2
                        else
                            selectheroo.sealcolor = 1
                        end
                        if _G.patreons[tostring(PlayerResource:GetSteamID(i))] ~= nil then
                            if _G.patreons[tostring(PlayerResource:GetSteamID(i))] > 2 then
                                selectheroo.sealcolor = 12
                            end
                        end
                        RelicStone:Levels(data)
                    end
                else
                    loaded = true
                    local selectheroo = PlayerResource:GetSelectedHeroEntity(i)
                    selectheroo.nullrelics = true
                end
            end
        end)
        
        Timers:CreateTimer(10, function()
            if  loaded == false then            --如果没加载
                selectheroo.needrefresh = true  --改为需要刷新，并给玩家发送消息
                CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(i), "NeedRefresh", {})
            end
        end)
    end
end

function RelicStone:UpgradeRS(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    for i=1,#hero.rsinv do
        if hero.rsinv[i] == event.rs then
            local rares = string.sub(event.rs, 1, 1)
            local qual = string.sub(event.rs, 8, 8)
            if qual ~= "5" and rares == "4" then
                local cost = 0
                if     qual == "0" then cost = 40
                elseif qual == "1" then cost = 80
                elseif qual == "2" then cost = 160
                elseif qual == "3" then cost = 320
                elseif qual == "4" then cost = 640
                end
                if hero.rsp >= cost then
                    hero.rsinv[i] = string.sub(event.rs, 1, 7) .. tonumber(qual)+1 .. string.sub(event.rs, 9)
                    hero.rsp = hero.rsp - cost
                    -- local req = CreateHTTPRequestScriptVM( "POST", GameMode.gjfll2 .. "/relicstones1.php")
                    -- req:SetHTTPRequestGetOrPostParameter("id", tostring(PlayerResource:GetSteamID(event.PlayerID)))
                    -- req:SetHTTPRequestGetOrPostParameter("uprsid", event.rs)
                    -- req:SetHTTPRequestGetOrPostParameter("v", _G.DedicatedServerKey)
                    -- req:Send(function(result) print(result.Body) end)
                end
            end
            RelicStone:Levels(event)
            break
        end
    end
end

function RelicStone:SetColor(event)--设置颜色
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    if event.colorid ~= 1 then
        for i=1,#hero.sealcolors do
            if hero.sealcolors[i] == event.colorid then
                hero.sealcolor = event.colorid
                break
            end
        end
    else
        hero.sealcolor = event.colorid
    end
    --print(hero.sealcolor)
end

function RelicStone:UpdateRS(id)--刷新石头
    local hero = PlayerResource:GetSelectedHeroEntity(id)
    _G.bonuses[1][id] = 0
    _G.bonuses[2][id] = 0
    _G.bonuses[3][id] = 0
    _G.bonuses[4][id] = 0
    _G.bonuses[5][id] = 0
    _G.bonuses[6][id] = 0
    _G.bonuses[7][id] = 0
    local colors = {}
    --print("StartLoad")
    for i=1,8 do
        if hero.immortalbuffs[i] ~= nil then
            hero:RemoveModifierByName(hero.immortalbuffs[i])
            hero.immortalbuffs[i] = nil
        end
        if hero.rsslots[i] ~= "" then
            table.insert(colors,tonumber(string.sub(hero.rsslots[i], 2, 2))+2)
            local lclarr = {
                {0.005,0.0015,0.001,0.0025,0.0015,0.0015,0.0025},
                {0.01,0.0025,0.0015,0.005,0.0025,0.0025,0.005},
                {0.01,0.0025,0.0015,0.005,0.0025,0.0025,0.005},
                {
                    {0.01,0.0025,0.0015,0.005,0.0025,0.0025,0.005},
                    {0.012,0.003,0.0018,0.006,0.003,0.003,0.006},
                    {0.014,0.0035,0.0021,0.007,0.0035,0.0035,0.007},
                    {0.016,0.004,0.0024,0.008,0.004,0.004,0.008},
                    {0.018,0.0045,0.0027,0.009,0.0045,0.0045,0.009},
                    {0.02,0.005,0.003,0.01,0.005,0.005,0.01}
                }
            }
            if string.sub(hero.rsslots[i], 4, 4) ~= "0" then
                local relicid = tonumber(string.sub(hero.rsslots[i], 4, 4))
                if relicid ~= 0 then
                    if string.sub(hero.rsslots[i], 1, 1) == "4" then
                        _G.bonuses[relicid][id] = _G.bonuses[relicid][id] + lclarr[tonumber(string.sub(hero.rsslots[i], 1, 1))][tonumber(string.sub(hero.rsslots[i], 8, 8))+1][relicid]
                    else
                        _G.bonuses[relicid][id] = _G.bonuses[relicid][id] + lclarr[tonumber(string.sub(hero.rsslots[i], 1, 1))][relicid]
                    end
                end
            end
            if string.sub(hero.rsslots[i], 5, 5) ~= "0" then
                local relicid = tonumber(string.sub(hero.rsslots[i], 5, 5))
                if relicid ~= 0 then
                    if string.sub(hero.rsslots[i], 1, 1) == "4" then
                        _G.bonuses[relicid][id] = _G.bonuses[relicid][id] + lclarr[tonumber(string.sub(hero.rsslots[i], 1, 1))][tonumber(string.sub(hero.rsslots[i], 8, 8))+1][relicid]
                    else
                        _G.bonuses[relicid][id] = _G.bonuses[relicid][id] + lclarr[tonumber(string.sub(hero.rsslots[i], 1, 1))][relicid]
                    end
                end
            end
            if string.sub(hero.rsslots[i], 6, 7) ~= "00" then
                --print("immortal_mod_" .. string.sub(hero.rsslots[i], 6, 7))
                hero:AddNewModifier(hero, nil, "immortal_mod_" .. string.sub(hero.rsslots[i], 6, 7), {})
                hero.immortalbuffs[i] = "immortal_mod_" .. string.sub(hero.rsslots[i], 6, 7)
            end
        end
    end
    local estcolor = false
    for i=1,#colors do
        if colors[i] == hero.sealcolor then
            estcolor = true
        end
    end
    if estcolor == false then
        hero.sealcolor = 1
    end
    if _G.patreons[tostring(PlayerResource:GetSteamID(id))] ~= nil then
        if _G.patreons[tostring(PlayerResource:GetSteamID(id))] > 2 then
            table.insert(colors,12)
        end
    end
    hero.sealcolors = colors
    local modifs = hero:FindAllModifiers()
    for b=1, #modifs do
        if modifs[b]:GetAbility() ~= nil then
            if modifs[b].needupwawe then
                modifs[b]:OnWaweChange(_G.GAME_ROUND)--改变遗物上面的轮数
            end
        end
    end
end

puretimerok = true
function RelicStone:PureRS(event)--粉碎石头
    if  puretimerok == true then
        puretimerok = false
        Timers:CreateTimer(30, function()
            puretimerok = true
            CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(event.PlayerID), "PureButtonReady", {})
        end)
        local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
        local inslot = false
        local newlist = {}
        local rspure = 0
        for k,v in pairs(event.rs) do
            for i=1,8 do
                if hero.rsslots[i] == v then
                    inslot = true
                    break
                end
            end
            
            if inslot == false then
                for i=1,#hero.rsinv do
                    if hero.rsinv[i] == v then
                        table.remove(hero.rsinv,i)
                        table.insert(newlist,v)
                        local fchr = string.sub(v, 1, 1)
                        if fchr == "1" then rspure = rspure + 1
                        elseif fchr == "2" then rspure = rspure + 3
                        elseif fchr == "3" then rspure = rspure + 15
                        elseif fchr == "4" then rspure = rspure + 60
                        end
                        break
                    end
                end
            end
        end
        hero.rsp = hero.rsp + rspure
        if #newlist > 0 then
            local rstr = ""
            for i=1,#newlist do
                if rstr == "" then
                    rstr = rstr .. newlist[i]
                else
                    rstr = rstr .. "|" .. newlist[i]
                end
            end
            --print(rstr)
            local   req = CreateHTTPRequestScriptVM( "POST", GameMode.gjfll2 .. "/relicstones1.php")
                    req:SetHTTPRequestGetOrPostParameter("id", tostring(PlayerResource:GetSteamID(event.PlayerID)))
                    req:SetHTTPRequestGetOrPostParameter("rsids", rstr)
                    req:SetHTTPRequestGetOrPostParameter("v", _G.DedicatedServerKey)
                    req:Send(function(result) print(result.Body) end)
        end
        RelicStone:UpdateRS(event.PlayerID)
        RelicStone:Levels(event)
    end
end

function RelicStone:SaveSet(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    if hero.sevesettimerok == nil then hero.sevesettimerok = true end
    if hero.sevesettimerok == true then
        hero.sevesettimerok = false
        Timers:CreateTimer(30, function()
            hero.sevesettimerok = true
            CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(event.PlayerID), "ReadySetButton", {})
        end)
        local rstr = ""
        for i=1,8 do
            if i ~= 8 then
                rstr = rstr .. hero.rsslots[i] .. "|"
            else
                rstr = rstr .. hero.rsslots[i]
            end
        end
        hero.rssaves[tonumber(event.num)] = rstr
        local req = CreateHTTPRequestScriptVM( "POST", GameMode.gjfll2 .. "/relicstones1.php")
        req:SetHTTPRequestGetOrPostParameter("id", tostring(PlayerResource:GetSteamID(event.PlayerID)))
        req:SetHTTPRequestGetOrPostParameter("v", _G.DedicatedServerKey)
        req:SetHTTPRequestGetOrPostParameter("savenum", tostring(event.num))
        req:SetHTTPRequestGetOrPostParameter("slots", rstr)
        req:Send(function(result)
            print(result.Body)
        end)
        RelicStone:UpdateRS(event.PlayerID)
        RelicStone:Levels(event)
    end
end

function RelicStone:LoadSet(event)--加载设置
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    local thisslots = {}
    hero.rsslots = {"","","","","","","",""}
    for token in string.gmatch(hero.rssaves[tonumber(event.num)].."|", "([^|]*)|") do
        local moshnoadd = true
        local estininv = false
        for i=1,#hero.rsinv do
            if hero.rsinv[i] == token then
                estininv = true
                break
            end
        end
        for i=1,8 do
            if hero.rsslots[i] == token then
                moshnoadd = false
                break
            end
        end
        if moshnoadd == true and estininv == true then
            table.insert(thisslots,token)
        else
            table.insert(thisslots,"")
        end
    end
    if #thisslots == 8 then
        hero.rsslots = thisslots
    end
    RelicStone:UpdateRS(event.PlayerID)
    RelicStone:Levels(event)
end

function GameMode:_Stats(iswin)
    local plc = PlayerResource:GetPlayerCount() 		--玩家数
    if  not GameRules:IsCheatMode()  					--非作弊模式
    and _G.GAME_ROUND ~= 0 						    	--游戏已经开始。轮数不为0
    and cheats == false 						    	--作弊状态为假
    and GameRules:GetDOTATime(false,false) > 35     	--返回Dota游戏内的时间，不包含 赛前时间PregameTime 和 负时间NegativeTime
    and plc > 0 then 							    	--玩家数大于0
        local req = CreateHTTPRequestScriptVM( "POST", GameMode.gjfll2 .. "/data.php")--创建一个通讯到数据服务器
        
        req:SetHTTPRequestGetOrPostParameter("v", _G.DedicatedServerKey)--专用服务器密钥

        if iswin ~= nil then 							--判断是否通关
            req:SetHTTPRequestGetOrPostParameter("test", "-1" .. iswin)
        else
            req:SetHTTPRequestGetOrPostParameter("test", tostring(_G.GAME_ROUND))
        end 	
        										--把玩家数和通关时间发给服务器
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

        req:Send(function(result) print(result.Body) end)
    end
end


-- local req = CreateHTTPRequestScriptVM( "POST", gjfll2 .. "/data.php") 
-- req:SetHTTPRequestGetOrPostParameter( "inid" , tostring(PlayerResource:GetSteamID(event.PlayerID)))
-- req:SetHTTPRequestGetOrPostParameter( "part" , "defaults")
-- req:SetHTTPRequestGetOrPostParameter( "reson", tostring(event.part) )
-- req:SetHTTPRequestGetOrPostParameter( "v"    , GetDedicatedServerKeyV2("2"))
-- req:Send(function(result)
--     print(result.Body)
-- end)

-- -----------------------------------------------------------------------------------------

-- local req = CreateHTTPRequestScriptVM( "POST", gjfll2 .. "/data.php") 
-- req:SetHTTPRequestHeaderValue("Content-Type", "application/json")

-- local encoded = {}
-- encoded.inid  = tostring(PlayerResource:GetSteamID(playerID))
-- encoded.part  = 'defaults'
-- encoded.reson = tostring(event.part) 
-- encoded.v     = GetDedicatedServerKeyV2("2")

-- req:SetHTTPRequestRawPostBody("application/json", json.encode( encoded ) )
-- req:Send(function(result)
--     print(result.Body)
-- end)



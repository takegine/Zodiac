print ( '[ValueTable] be running' )

-- GameRules 的变量（Variables）在此改变dota默认值，将在后面调用
ENABLE_HERO_RESPAWN = false              -- 允许英雄重生：英雄应该在计时器上自动重生还是保持死亡直到手动重生Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = true               -- 全商店模式：主商店应包含秘密商店物品还是常规物品Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = false        -- 英雄复选 Should we let people select the same hero as each other

HERO_SELECTION_TIME = 30.0              -- 给多长时间选英雄How long should we let people select their hero?
PRE_GAME_TIME = 10.0                    -- 选完英雄到游戏开始的倒数时间有多长How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- 游戏结束的记分板展示多久How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 30.0                 -- 树木重生的周期How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 0                       -- 玩家工资多少 How much gold should players get per tick?
GOLD_TICK_TIME = 999999.0               -- 发工资的频率 How long should we wait in seconds between gold ticks?


CAMERA_DISTANCE_OVERRIDE = 1134.0       -- 视角高度，1134是默认值 How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1                   -- 英雄图标尺寸What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- 野怪图标尺寸What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- 神符图标尺寸What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                   -- 刷新神符的时间间隔 秒 How long in seconds should we wait between rune spawns?

USE_STANDARD_HERO_GOLD_BOUNTY = false   -- 使用标准的赏金规则 Should we give gold for hero kills the same as in Dota, or allow those values to be changed?


SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION= false -- 我们应该为塔启用后门保护吗？ Should we enable backdoor protection for our towers?

END_GAME_ON_KILLS = false               -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

MAX_LEVEL = 200                         -- 设置英雄满级 What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

PlaysTopList    = {}
WinsTopList     = {}
HardWinsTopList = {}
MyProfileArray  = {}

_G.hardmode    = 1	    	--默认游戏难度为简单
_G.GAME_ROUND  = 0 		--初始化回合数
_G.defaultpart = {}
_G.bonuses = 
    {
        [1]  = {},
        [2]  = {},
        [3]  = {},
        [4]  = {},
        [5]  = {},
        [6]  = {},
        [7]  = {}
    }

DropTable   = LoadKeyValues("scripts/kv/item_drops.kv") --怪物掉落的机率文件
ROUND_UNITS = LoadKeyValues("scripts/kv/round_units.kv")--出怪数量表单
ADDED_ITEM  = LoadKeyValues("scripts/kv/item_added.kv") --敌方附加装备
ADDED_ABLE  = LoadKeyValues("scripts/kv/able_added.kv") --敌方添加技能

LinkLuaModifier( "modifier_easy_mode", "modifiers/modifier_mode1", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_imba_generic_talents_handler", "modifiers/modifier_mode3", LUA_MODIFIER_MOTION_NONE )

--allelements = { "item_jia","item_yi","item_bing","item_ding","item_wu","item_ji","item_geng","item_xin","item_ren","item_kui"}
--all_elements = { "item_life","item_water","item_shadow","item_void","item_earth","item_fire","item_light","item_air","item_ice","item_energy"}
need_drop_el = {1,2,3,4,5,6,7,8,9,10}
partlist = { 
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

notforall = {
    item_ice = true,
    item_fire = true,
    item_water = true,
    item_energy = true,
    item_earth = true,
    item_life = true,
    item_void = true,
    item_air = true,
    item_light = true,
    item_shadow = true,
    item_ice_essence = true,
    item_fire_essence = true,
    item_water_essence = true,
    item_energy_essence = true,
    item_earth_essence = true,
    item_life_essence = true,
    item_void_essence = true,
    item_air_essence = true,
    item_light_essence = true,
    item_shadow_essence = true,
    item_ice_dummy = true,
    item_fire_dummy = true,
    item_water_dummy = true,
    item_energy_dummy = true,
    item_earth_dummy = true,
    item_life_dummy = true,
    item_void_dummy = true,
    item_air_dummy = true,
    item_light_dummy = true,
    item_shadow_dummy = true,
    item_upgraded_mjollnir = true,
    item_upgraded_heart = true,
    item_upgraded_greater_crit = true,
    item_upgraded_satanic = true,
    item_upgraded_pipe = true,
    item_upgraded_desolator = true,
    item_upgraded_diffusal_blade = true,
    item_upgraded_sange_and_yasha = true,
    item_upgraded_butterfly = true,
    item_upgraded_monkey_king_bar = true,
    item_light_fire_earth = true,
    item_light_life_ice = true,
    item_air_earth_shadow = true,
    item_air_life_void = true,
    item_air_fire_life = true,
    item_energy_fire_void = true,
    item_energy_shadow_water = true,
    item_energy_earth_water = true,
    item_energy_void_ice = true,
    item_energy_light_air = true,
    item_energy_life_fire = true,
    item_fire_earth_water = true,
    item_water_life_shadow = true,
    item_light_water_void = true,
    item_ice_air_water = true,
    item_light_life_earth = true,
    item_shadow_light_ice = true,
    item_ice_shadow_air = true,
    item_void_fire_shadow = true,
    item_void_ice_earth = true,
    item_air_void_water = true,
    item_air_fire_light = true,
    item_air_earth_energy = true,
    item_void_shadow_water = true,
    item_water_ice_fire = true,
    item_void_light_life = true,
    item_earth_shadow_life = true,
    item_shadow_energy_light = true,
    item_ice_fire_earth = true,
    item_ice_life_energy = true,
    item_light_fire_earth_2 = true,
    item_light_life_ice_2 = true,
    item_air_earth_shadow_2 = true,
    item_air_life_void_2 = true,
    item_air_fire_life_2 = true,
    item_energy_fire_void_2 = true,
    item_energy_shadow_water_2 = true,
    item_energy_earth_water_2 = true,
    item_energy_void_ice_2 = true,
    item_energy_light_air_2 = true,
    item_energy_life_fire_2 = true,
    item_fire_earth_water_2 = true,
    item_water_life_shadow_2 = true,
    item_light_water_void_2 = true,
    item_ice_air_water_2 = true,
    item_light_life_earth_2 = true,
    item_shadow_light_ice_2 = true,
    item_ice_shadow_air_2 = true,
    item_void_fire_shadow_2 = true,
    item_void_ice_earth_2 = true,
    item_air_void_water_2 = true,
    item_air_fire_light_2 = true,
    item_air_earth_energy_2 = true,
    item_void_shadow_water_2 = true,
    item_water_ice_fire_2 = true,
    item_void_light_life_2 = true,
    item_earth_shadow_life_2 = true,
    item_shadow_energy_light_2 = true,
    item_ice_fire_earth_2 = true,
    item_ice_life_energy_2 = true,
    item_light_fire_earth_3 = true,
    item_light_life_ice_3 = true,
    item_air_earth_shadow_3 = true,
    item_air_life_void_3 = true,
    item_air_fire_life_3 = true,
    item_energy_fire_void_3 = true,
    item_energy_shadow_water_3 = true,
    item_energy_earth_water_3 = true,
    item_energy_void_ice_3 = true,
    item_energy_light_air_3 = true,
    item_energy_life_fire_3 = true,
    item_fire_earth_water_3 = true,
    item_water_life_shadow_3 = true,
    item_light_water_void_3 = true,
    item_ice_air_water_3 = true,
    item_light_life_earth_3 = true,
    item_shadow_light_ice_3 = true,
    item_ice_shadow_air_3 = true,
    item_void_fire_shadow_3 = true,
    item_void_ice_earth_3 = true,
    item_air_void_water_3 = true,
    item_air_fire_light_3 = true,
    item_air_earth_energy_3 = true,
    item_void_shadow_water_3 = true,
    item_water_ice_fire_3 = true,
    item_void_light_life_3 = true,
    item_earth_shadow_life_3 = true,
    item_shadow_energy_light_3 = true,
    item_ice_fire_earth_3 = true,
    item_ice_life_energy_3 = true,
    item_power_dagon = true,
    item_fire_radiance = true,
    item_life_greaves = true,
    item_fire_desol = true,
    item_water_butterfly = true,
    item_shivas_shield = true,
    item_energy_sphere = true,
    item_water_blades = true,
    item_energy_core = true,
    item_power_satanic = true,
    item_heart_of_light = true,
    item_earth_cuirass = true,
    item_dragon_staff = true,
    item_earth_s_and_y = true,
    item_ice_pipe = true,
    item_fire_core = true,
    item_solar_crest_of_void = true,
    item_talisman_of_atos = true,
    item_urn_of_life = true,
    item_skadi_bow = true,
    item_monkey_king_bow = true,
    item_mystery_cyclone = true,
    item_kingsbane = true,
    item_energy_veil = true,
    item_vampire_robe = true,
    item_mana_blade = true,
    item_ice_aluneth = true,
    item_my_crit = true,
    item_cuirass_of_life = true,
    item_hammer_of_god = true
}

print ( '[hRequest] be loadding' )
hRequest = hRequest or {}

function hRequest:Login(playerID) 
    local req = CreateHTTPRequestScriptVM("POST", "https://14769.playfabapi.com/Client/LoginWithCustomID")
    req:SetHTTPRequestHeaderValue("Content-Type", "application/json")

    local encoded = {}
    encoded.CustomId      = tostring(PlayerResource:GetSteamID(playerID))
    encoded.CreateAccount = true
    encoded.TitleId       = 14769

    req:SetHTTPRequestRawPostBody("application/json",json.encode(encoded))
    
    req:Send(function(res)
        --print("[STATS] Received", res.Body)
        local resbody   = json.decode(res.Body)
        local data      =resbody.data
        local ticket    =data.SessionTicket
        local playfab_id=data.PlayFabId
        --PlayerData[playerID]={}--init player data
        --PlayerData[playerID][0]=ticket  --store session ticket
        print(playfab_id,ticket)
        self:getplayerdata(ticket)
    end)
end

function hRequest:getplayerdata(session_ticket, keys)
    local req = CreateHTTPRequestScriptVM("POST", "https://14769.playfabapi.com/Client/GetUserData")
    req:SetHTTPRequestHeaderValue("Content-Type", "application/json")
    req:SetHTTPRequestHeaderValue("X-Authentication", session_ticket)

    local encoded = {}
    encoded.Keys  = {"Gold","TimeSaved"}
    req:SetHTTPRequestRawPostBody("application/json",json.encode(encoded))
                
    req:Send(function(res)
        print("[STATS] Received", res.Body)
        local resbody = json.decode(res.Body)
        local data=resbody["data"]
        local datadata=data["Data"]
        local gold=datadata["Gold"]

        if gold==nil then                        --First time player
                self:updateplayerdata(session_ticket,0)
        else
                print("current gold is")
                local goldnum=tonumber(gold["Value"])
                --PlayerData[0][1]=goldnum
        end
    end)
end

function hRequest:updateplayerdata(session_ticket, goldnum)
    --login
    print(goldnum)

    local req = CreateHTTPRequestScriptVM("POST", "https://14769.playfabapi.com/Client/UpdateUserData")
          req:SetHTTPRequestHeaderValue("Content-Type", "application/json")
          req:SetHTTPRequestHeaderValue("X-Authentication", session_ticket)

    local encoded   = {}
    encoded.Data    = {}
    encoded.Data.Gold   = tostring(goldnum)
    encoded.Data.isPayed= true
    encoded.Permission  = "Public"
        
    req:SetHTTPRequestRawPostBody("application/json",json.encode(encoded))
                
    req:Send(function(res)
        print("[STATS] Received", res.Body)
        local resbody = json.decode(res.Body)
        local data    =resbody["data"]
        local dataversion=data["DataVersion"]
        print(dataversion)
    end)
end


--[[

[STATS] Received	
{
    "code":200,
    "status":"OK",
    "data":
    {
        "SessionTicket":"72C027DC81A14AEA--84DD21FD2ED670EE-14769-8D803D5761EB80A-+selbfvC1/yY79CNtmQpuF5+P/H5yvwGEjm8LgKBpnQ=",
        "PlayFabId":"72C027DC81A14AEA",
        "NewlyCreated":true,
        "SettingsForUser":
        {
            "NeedsAttribution":false,
            "GatherDeviceInfo":true,
            "GatherFocusInfo":true
            },
        "EntityToken":
        {
            "EntityToken":"Mnx7ImkiOiIyMDIwLTA1LTI5VDEzOjM3OjQxLjc1NjcyNDJaIiwiaWRwIjoiQ3VzdG9tIiwiZSI6IjIwMjAtMDUtMzBUMTM6Mzc6NDEuNzU2NzI0MloiLCJoIjoiNUJEODY4NUQ4OEVFNTk2OCIsInMiOiJwZlFzRmN2UFVmeVdPSHZaV1BNb2psTExWUDdUQnRkK0NBUldYZzRobno4PSIsImVjIjoidGl0bGVfcGxheWVyX2FjY291bnQhREM5ODAzNEZFMkQ3MDY1Ni8xNDc2OS83MkMwMjdEQzgxQTE0QUVBLzNGODdFMDVBMUFDQUJGMkEvIiwiZWkiOiIzRjg3RTA1QTFBQ0FCRjJBIiwiZXQiOiJ0aXRsZV9wbGF5ZXJfYWNjb3VudCJ9",
            "TokenExpiration":"2020-05-30T13:37:41.756Z",
            "Entity":
            {
                "Id":"3F87E05A1ACABF2A",
                "Type":"title_player_account",
                "TypeString":"title_player_account"
            }
        },
        "TreatmentAssignment":{"Variants":[],"Variables":[]}}}
72C027DC81A14AEA--84DD21FD2ED670EE-14769-8D803D5761EB80A-+selbfvC1/yY79CNtmQpuF5+P/H5yvwGEjm8LgKBpnQ=
]]
_G.patreons = {}
function hRequest:Patreons()
    print("Load Patreons")
        local patreonreq = CreateHTTPRequestScriptVM( "GET", "https://pastebin.com/raw/Njy7mF0F")
        patreonreq:Send(function(result)
            print_r(result.Body)
            print("..................")
            for token in string.gmatch(result.Body, "([^|]*)|") do
                print(token)
                local id = ""
                local lvl = ""
                id, lvl = token:match("([^,]+),([^,]+)")
                _G.patreons[id] = tonumber(lvl)
            end
            --print("Patreons Loaded")
            --print_r(_G.patreons)
            local pplc = PlayerResource:GetPlayerCount()
            for i=0,pplc-1 do
                local parts = CustomNetTables:GetTableValue("Particles_Tabel",tostring(i))
                --print(parts)
                
                parts = parts or {}
                --patreon particles
                parts["11"] = "nill"
                parts["12"] = "nill"
                parts["13"] = "nill"
                parts["14"] = "nill"
                parts["15"] = "nill"
                local plvl = _G.patreons[tostring(PlayerResource:GetSteamID(i))]
                if plvl ~= nil then
                    if plvl >= 1 then parts["11"] = "normal" end
                    if plvl >= 2 then parts["12"] = "normal" end
                    if plvl >= 3 then parts["13"] = "normal" end
                    if plvl >= 4 then parts["14"] = "normal" end
                    if plvl >= 5 then parts["15"] = "normal" end
                end
                DeepPrintTable(parts)
                CustomNetTables:SetTableValue("Particles_Tabel",tostring(i),parts)
                
            end
        end)
    end
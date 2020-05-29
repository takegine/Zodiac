print ( '[ValueTable] be running' )
--如果要测试哪个怪就写哪个怪
CreateName = nil--"npc_dota_custom_creep_5_1"

-- GameRules 的变量（Variables）在此改变dota默认值，将在后面调用
ENABLE_HERO_RESPAWN = false              -- 允许英雄重生：英雄应该在计时器上自动重生还是保持死亡直到手动重生Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = true               -- 全商店模式：主商店应包含秘密商店物品还是常规物品Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = false        -- 允许选择重复的英雄Should we let people select the same hero as each other

HERO_SELECTION_TIME = 30.0              -- 给多长时间选英雄How long should we let people select their hero?
PRE_GAME_TIME = 10.0                    -- 选完英雄到游戏开始的倒数时间有多长How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- 游戏结束的记分板展示多久How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 30.0                 -- 树木重生的周期How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 0                       -- 玩家工资多少 How much gold should players get per tick?
GOLD_TICK_TIME = 999999.0               -- 发工资的频率 How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = false     -- 禁用装备推荐 Should we disable the recommened builds for heroes (Note: this is not working currently I believe)
CAMERA_DISTANCE_OVERRIDE = 1134.0       -- 视角高度，1134是默认值 How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1                   -- 英雄图标尺寸What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- 野怪图标尺寸What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- 神符图标尺寸What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                   -- 刷新神符的时间间隔 秒 How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- 使用自定义买活金额 Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- 使用自定义买活冷却 Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- 允许买活吗 Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = true      -- 禁用双方的战争迷雾 Should we disable fog of war entirely for both teams?
USE_STANDARD_HERO_GOLD_BOUNTY = false   -- 使用标准的赏金规则 Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- 使用自定义顶部数据，否则使用默认的团队击杀数 Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- 顶部数据栏（我猜是显示玩家KDA和补兵） Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION= false -- 我们应该为塔启用后门保护吗？ Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = true        -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false               -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 200                         -- 设置英雄满级 What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

PlaysTopList    = {}
WinsTopList     = {}
HardWinsTopList = {}
MyProfileArray  = {}
_G.bonuses     = {}
_G.bonuses[1]  = {}
_G.bonuses[2]  = {}
_G.bonuses[3]  = {}
_G.bonuses[4]  = {}
_G.bonuses[5]  = {}
_G.bonuses[6]  = {}
_G.bonuses[7]  = {}
_G.defaultpart = {}


_G.hardmode = 1	    	--默认游戏难度为简单
_G.GAME_ROUND = 0 		--初始化回合数


notforall = {
    "item_ice",
    "item_fire",
    "item_water",
    "item_energy",
    "item_earth",
    "item_life",
    "item_void",
    "item_air",
    "item_light",
    "item_shadow",
    "item_ice_essence",
    "item_fire_essence",
    "item_water_essence",
    "item_energy_essence",
    "item_earth_essence",
    "item_life_essence",
    "item_void_essence",
    "item_air_essence",
    "item_light_essence",
    "item_shadow_essence",
    "item_ice_dummy",
    "item_fire_dummy",
    "item_water_dummy",
    "item_energy_dummy",
    "item_earth_dummy",
    "item_life_dummy",
    "item_void_dummy",
    "item_air_dummy",
    "item_light_dummy",
    "item_shadow_dummy",
    "item_upgraded_mjollnir",
    "item_upgraded_heart",
    "item_upgraded_greater_crit",
    "item_upgraded_satanic",
    "item_upgraded_pipe",
    "item_upgraded_desolator",
    "item_upgraded_diffusal_blade",
    "item_upgraded_sange_and_yasha",
    "item_upgraded_butterfly",
    "item_upgraded_monkey_king_bar",
    "item_light_fire_earth",
    "item_light_life_ice",
    "item_air_earth_shadow",
    "item_air_life_void",
    "item_air_fire_life",
    "item_energy_fire_void",
    "item_energy_shadow_water",
    "item_energy_earth_water",
    "item_energy_void_ice",
    "item_energy_light_air",
    "item_energy_life_fire",
    "item_fire_earth_water",
    "item_water_life_shadow",
    "item_light_water_void",
    "item_ice_air_water",
    "item_light_life_earth",
    "item_shadow_light_ice",
    "item_ice_shadow_air",
    "item_void_fire_shadow",
    "item_void_ice_earth",
    "item_air_void_water",
    "item_air_fire_light",
    "item_air_earth_energy",
    "item_void_shadow_water",
    "item_water_ice_fire",
    "item_void_light_life",
    "item_earth_shadow_life",
    "item_shadow_energy_light",
    "item_ice_fire_earth",
    "item_ice_life_energy",
    "item_light_fire_earth_2",
    "item_light_life_ice_2",
    "item_air_earth_shadow_2",
    "item_air_life_void_2",
    "item_air_fire_life_2",
    "item_energy_fire_void_2",
    "item_energy_shadow_water_2",
    "item_energy_earth_water_2",
    "item_energy_void_ice_2",
    "item_energy_light_air_2",
    "item_energy_life_fire_2",
    "item_fire_earth_water_2",
    "item_water_life_shadow_2",
    "item_light_water_void_2",
    "item_ice_air_water_2",
    "item_light_life_earth_2",
    "item_shadow_light_ice_2",
    "item_ice_shadow_air_2",
    "item_void_fire_shadow_2",
    "item_void_ice_earth_2",
    "item_air_void_water_2",
    "item_air_fire_light_2",
    "item_air_earth_energy_2",
    "item_void_shadow_water_2",
    "item_water_ice_fire_2",
    "item_void_light_life_2",
    "item_earth_shadow_life_2",
    "item_shadow_energy_light_2",
    "item_ice_fire_earth_2",
    "item_ice_life_energy_2",
    "item_light_fire_earth_3",
    "item_light_life_ice_3",
    "item_air_earth_shadow_3",
    "item_air_life_void_3",
    "item_air_fire_life_3",
    "item_energy_fire_void_3",
    "item_energy_shadow_water_3",
    "item_energy_earth_water_3",
    "item_energy_void_ice_3",
    "item_energy_light_air_3",
    "item_energy_life_fire_3",
    "item_fire_earth_water_3",
    "item_water_life_shadow_3",
    "item_light_water_void_3",
    "item_ice_air_water_3",
    "item_light_life_earth_3",
    "item_shadow_light_ice_3",
    "item_ice_shadow_air_3",
    "item_void_fire_shadow_3",
    "item_void_ice_earth_3",
    "item_air_void_water_3",
    "item_air_fire_light_3",
    "item_air_earth_energy_3",
    "item_void_shadow_water_3",
    "item_water_ice_fire_3",
    "item_void_light_life_3",
    "item_earth_shadow_life_3",
    "item_shadow_energy_light_3",
    "item_ice_fire_earth_3",
    "item_ice_life_energy_3",
    "item_power_dagon",
    "item_fire_radiance",
    "item_life_greaves",
    "item_fire_desol",
    "item_water_butterfly",
    "item_shivas_shield",
    "item_energy_sphere",
    "item_water_blades",
    "item_energy_core",
    "item_power_satanic",
    "item_heart_of_light",
    "item_earth_cuirass",
    "item_dragon_staff",
    "item_earth_s_and_y",
    "item_ice_pipe",
    "item_fire_core",
    "item_solar_crest_of_void",
    "item_talisman_of_atos",
    "item_urn_of_life",
    "item_skadi_bow",
    "item_monkey_king_bow",
    "item_mystery_cyclone",
    "item_kingsbane",
    "item_energy_veil",
    "item_vampire_robe",
    "item_mana_blade",
    "item_ice_aluneth",
    "item_my_crit",
    "item_cuirass_of_life",
    "item_hammer_of_god"
}
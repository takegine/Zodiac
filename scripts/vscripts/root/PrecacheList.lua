-- 修改1：引入文件

print ( '[root] be running' )
require("root/questsystem")  --任务列表，倒计时
require("root/Zodiac")			--主体程序
require("root/timers")       --计时器
require("root/round_units")   --每轮出怪数
require("code")   --密钥
require("root/VauleTable")
require("root/bare_bones")
require("root/RelicStone")
require("root/Expand_API")
require("root/ToolsFromX")


function Precache(context)--用于模型，特效，音效的预载入

	PrecacheModel("models/heroes/earthshaker/totem.vmdl_c", context)--小牛的图腾

	local precacheList = LoadKeyValues('scripts/npc/npc_units_custom.txt')
	for unit, info in pairs(precacheList) do
		                           PrecacheUnitByNameSync(unit, context)
        if type(info) == table then
            if info["Model"]  then PrecacheModel(info["Model"], context)                end
            if info["Effect"] then PrecacheResource("particle",info["Effect"], context) end
        end
	end
    
	local precacheList = LoadKeyValues('scripts/npc/npc_items_custom.txt')
	for item, info in pairs(precacheList) do
		                           PrecacheItemByNameSync(item, context)
        if type(info) == table then
            if info["Model"]  then PrecacheModel(info["Model"], context)                end
            if info["Effect"] then PrecacheResource("particle",info["Effect"], context) end
        end
	end

    PrecacheResource("particle_folder", "particles/units/heroes/hero_faceless_void", context)
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context )
end
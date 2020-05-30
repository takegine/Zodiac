-- config_mob_spawn.lua 内容
return {
    -- 刷怪开始时间（秒）
    spawn_start_time = 10,
    -- 波次配置
    waves = {
        -- 每一个{}都是一波兵
        {
            -- 怪物单位名称
            name = "npc_dota_creature_gnoll_assassin",
            
            -- 本波个数
            num = 5,
            
            -- 怪物等级
            level = 1,
            
            -- 刷怪点的名字，这里直接用了路径起始点
            location = "path_mob_default",
            
            -- 怪物寻路的路径起始点
            path = "path_mob_default"
        }
    }
}
--这是第一个被运行的文件
require("PrecacheList")

-- 激活时创建游戏模式
function Activate()
	print("print Activate is loaded.")
    GameRules.CAddonGameMode = GameMode()
    GameRules.CAddonGameMode:InitGameMode()
end


-- addon_game_mode.lua 内容

-- 从模板生成
--使CAddonTemplateGameMode 为全局可用，CAddonTemplateGameMode可自己改
if CAddonTemplateGameMode == nil then
	_G.CAddonTemplateGameMode = class({})
end

-- 修改1：引入文件
require("mob_spawner")--刷怪文件，待设计
require("ItemDrop")--物品掉落机制，代设计
require("listener_uievent")--UI面板监听


function Precache(context)
	--[[
		预缓存我们知道将使用的东西。 可能的文件类型包括（但不限于）：
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- 激活时创建游戏模式
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

--初始化游戏，可以写监听时间
function CAddonTemplateGameMode:InitGameMode()
	print("Template addon is loaded.")
	GameRules:GetGameModeEntity():SetThink("OnThink", self, "GlobalThink", 2)

	
	-- 修改2：把备战时间调短
	GameRules:SetHeroSelectionTime(20)--设置选择英雄的时间
	GameRules:SetPreGameTime(15)--设置选择英雄与开始游戏之间的时间

	GameRules:LockCustomGameSetupTeamAssignment(true)--锁定(true)或解锁(false)队伍分配.。如果队伍分配被锁定，玩家将不再能修改队伍。
	GameRules:SetCustomGameSetupTimeout(0)--设置(赛前)阶段的超时。 0 = 立即开始, -1 = 永远 (直到FinishCustomGameSetup 被调用)
	GameRules:FinishCustomGameSetup(0)--提示自定义游戏的设置阶段已经完成，并应用到游戏中。
	GameRules:ResetToHeroSelection()--在进入选队的时候调用重新进入选英雄也是可以跳过选队，但是同上无法选择英雄

	GameRules:GetPlayerCustomGameAccountRecord(int int_1)--(Preview/Unreleased)	获取玩家在本次会话开始时的自定义游戏帐户记录
	void SetCustomGameAccountRecordSaveFunction(handle handle_1, handle handle_2)--(Preview/Unreleased)	向句柄设置一个回调来保存玩家的账户信息。 (回调传递了玩家的ID，并应该返回一个简单的table)。
	
	-- 修改3：创建并启动刷怪器
	self.mob_spawner = MobSpawner()--需要require("mob_spawner")
	self.mob_spawner:Start()--需要require("mob_spawner")


    self:_RegisterCustomGameEventListeners()--使用UI面板监听的lua

--监听游戏进度
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CAddonTemplateGameMode,"OnGameRulesStateChange"), self)

--英雄重生时所有技能等级为1的事件
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(CAddonTemplateGameMode,'OnPlayerConnectFull'), self)--需要require("listener_uievent")

	ListenToGameEvent("npc_spawned", Dynamic_Wrap(EarthlyBranches,"OnNpcSpawned"), self)--监视NPC建立，既游戏开始，需要require("listener_uievent")

--监听UI事件,这是新的事件管理器
    CustomGameEventManager:RegisterListener( "ui_open", OnUIOpen() )

end

function CAddonTemplateGameMode:OnGameRulesStateChange( keys )
        local state = GameRules:State_Get()

        if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
                print("Player begin select team") --玩家处于选择队伍

        elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then    
        		print("Player begin select hero")  --玩家处于选择英雄界面

        elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
                print("Player are show case")  --玩家处于游戏准备状态,购物

        elseif newState == DOTA_GAMERULES_WAIT_FOR_MAP_TO_LOAD then
                print("map is loadding")  --地图加载

        elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
                print("Player in befor game")  --进游戏直到倒数结束

        elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
                print("Player game begin")  --玩家开始游戏
--调用UIbutton 按钮
            	CustomUI:DynamicHud_Create(-1,"UIbutton1","file://{resources}/layout/custom_game/uimian.xml",nil)

        elseif newState == DOTA_GAMERULES_STATE_POST_GAME then
                print("Player are show case")  --游戏结束
        end
end

function OnUIOpen( index,keys )
         --index 是事件的index值
         --keys 是一个table，固定包含一个触发的PlayerID，其余的是传递过来的数据
         CustomUI:DynamicHud_Create(keys.PlayerID,"UIMain","file://{resources}/layout/custom_game/uimain.xml",nil)
end
-- 明确游戏阶段，think是个客观参考
function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		-- print("Template addon script is running.")
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function CAddonTemplateGameMode:OnGameRulesStateChange( keys )
        local state = GameRules:State_Get()

        if state == DOTA_GAMERULES_STATE_PRE_GAME then
--调用UIbutton 按钮
            CustomUI:DynamicHud_Create(-1,"UIbutton1","file://{resources}/layout/custom_game/uimian.xml",nil)
        end
end

function OnUIOpen( index,keys )
         --index 是事件的index值
         --keys 是一个table，固定包含一个触发的PlayerID，其余的是传递过来的数据
         CustomUI:DynamicHud_Create(keys.PlayerID,"UIMain","file://{resources}/layout/custom_game/uimain.xml",nil)
end
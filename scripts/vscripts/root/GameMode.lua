XP_PER_LEVEL_TABLE = {}--初始化经验表单，会在难度选择函数中更新
    for i=1,MAX_LEVEL do
        XP_PER_LEVEL_TABLE[i] = i * 100--升级按经验总量来算，这里就是每级都是100点经验
    end
    
    -- 建立游戏模式的参数
    mode = mode or GameRules:GetGameModeEntity()

    mode:DisableHudFlip( true )--?禁用hub翻转，即小地图放在右边
    mode:SetLoseGoldOnDeath( false )--死亡损失金钱
    mode:SetAnnouncerDisabled(true)--禁用播音员
    mode:SetCustomHeroMaxLevel(MAX_LEVEL)--设定最高等级
    mode:SetHudCombatEventsDisabled(true)--猜测：不显示左侧的战斗事件
    mode:SetBuybackEnabled(BUYBACK_ENABLED)--设定玩家不能买活
    mode:SetSelectionGoldPenaltyEnabled( false )--启用/禁用不选英雄的金币惩罚
    mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )--屏蔽金币的声音
    mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
    mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
    mode:SetFogOfWarDisabled( DISABLE_FOG_OF_WAR_ENTIRELY)--取消战争迷雾
    mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )
    mode:SetTopBarTeamValuesOverride( USE_CUSTOM_TOP_BAR_VALUES )--自定义顶部数据栏
    mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )--经验值表单
    mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )--禁用装备推荐
    mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )--自定义买活金额
    mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )--自定义买活CD
    
        
  mode:SetHUDVisible(1,true)
  mode:SetHUDVisible(4,false)
  mode:SetHUDVisible(9, false)

        
    
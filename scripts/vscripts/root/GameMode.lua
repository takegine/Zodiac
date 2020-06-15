XP_PER_LEVEL_TABLE = {}--初始化经验表单，会在难度选择函数中更新
    for i=1,MAX_LEVEL do
        XP_PER_LEVEL_TABLE[i] = i * 100--升级按经验总量来算，这里就是每级都是100点经验
    end
    
    -- 建立游戏模式的参数
    mode = mode or GameRules:GetGameModeEntity()

    mode:DisableHudFlip( true )
    mode:SetLoseGoldOnDeath( false )
    mode:SetAnnouncerDisabled(true)
    mode:SetCustomHeroMaxLevel(MAX_LEVEL)
    mode:SetHudCombatEventsDisabled(true)
    mode:SetBuybackEnabled(false)
    mode:SetSelectionGoldPenaltyEnabled( false )
    mode:SetGoldSoundDisabled( false )
    mode:SetTopBarTeamValuesVisible( true )
    mode:SetUseCustomHeroLevels ( true )
    mode:SetFogOfWarDisabled( true)
    mode:SetRemoveIllusionsOnDeath( true )
    mode:SetTopBarTeamValuesOverride( true )
    mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
    mode:SetRecommendedItemsDisabled( true )--禁用装备推荐
    mode:SetCustomBuybackCostEnabled( true )
    mode:SetCustomBuybackCooldownEnabled( true )
    mode:SetSendToStashEnabled( false )
        
  mode:SetHUDVisible(1,true)
  mode:SetHUDVisible(4,false)
  mode:SetHUDVisible(9, false)

        
    
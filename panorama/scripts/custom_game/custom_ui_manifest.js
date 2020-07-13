GameUI.CustomUIConfig().Creator = [ ];
GameUI.CustomUIConfig().ActiveDevelopers = [  ];
GameUI.CustomUIConfig().InactiveDevelopers = [  ];

GameUI.CustomUIConfig().multiteam_top_scoreboard =
{
    reorder_team_scores: true,
    LeftInjectXMLFile: "file://{resources}/layout/custom_game/legion_round_left.xml",
};

GameUI.CustomUIConfig().team_colors = {}//设置队伍颜色
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = "#ff5252";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = "#ff793f";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = "#33d9b2";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = "#34ace0";

GameUI.CustomUIConfig().team_icons = {}
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = "s2r://panorama/images/custom_game/quest_1_01.png";
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = "s2r://panorama/images/custom_game/quest_2_01.png";
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = "s2r://panorama/images/custom_game/quest_3_01.png";
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = "s2r://panorama/images/custom_game/quest_4_01.png";

GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES,false);//HUD顶部的英雄与队伍。
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP,false);//小地图
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY,true);//快速购买,关闭会导致持有金币示数为0
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS,false);//建议购买的面板

GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME,true);//.................结束比赛比分板
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL,true);//............正中间下方英雄动作界面
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY,true);//...........时钟
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_GOLD,true);//..........显示金币
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP,true);//!--........//右下角商店面板
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL,true);//!--.........物品栏+中立物品栏
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS,true);//!--.......//物品栏
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_MENU_BUTTONS,true);//!--......//左上角HUD菜单按钮
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD,true);//!--.....//左侧得分板
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER,true);//!--.....//快递控制--信使
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT,true);//.....//雕文
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_TEAMS,true);//--..//英雄选择天辉与夜魇队伍
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_CLOCK,true);//--....英雄选择时钟.
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_GAME_NAME,true);//英雄选择游戏模式名称显示


var rootUI = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("HUDElements");
    rootUI.FindChildTraverse("minimap_container").FindChildTraverse("GlyphScanContainer").style.visibility = "collapse";//NoGlyphAndRadar

var reShop = rootUI.FindChildTraverse("lower_hud").FindChildTraverse("shop_launcher_block");
    reShop.FindChildTraverse("shop_launcher_bg").style.visibility = "collapse";
    reShop.FindChildTraverse("quickbuy").FindChildTraverse("ShopCourierControls").FindChildTraverse("courier").style.visibility = "collapse";//信使功能
    reShop.FindChildTraverse("quickbuy").FindChildTraverse("ShopCourierControls").FindChildTraverse("ShopButton").FindChildTraverse("BuybackHeader").style.visibility = "collapse";//鼠标悬浮的买活信息
    reShop.FindChildTraverse("quickbuy").FindChildTraverse("ShopCourierControls").FindChildTraverse("ShopButton").style.width="128px";//金币按钮宽度
    reShop.FindChildTraverse("quickbuy").FindChildTraverse("QuickBuyRows").style.visibility = "collapse";//快捷购买
    reShop.FindChildTraverse("quickbuy").FindChildTraverse("ShopCourierControls").style.marginLeft = "64px";//金币按钮位移
    reShop.FindChildTraverse("stash").style.visibility = "collapse";


var newUI  = rootUI.FindChildTraverse("lower_hud").FindChildTraverse("center_with_stats").FindChildTraverse("center_block");
    //newUI.FindChildTraverse("StatBranch" ).style.visibility = "collapse";//天赋树？
    //newUI.FindChildTraverse("right_flare").style.visibility = "collapse";//隐藏 物品栏右边 Panel
    //newUI.FindChildTraverse("inventory_tpscroll_container").style.visibility = "collapse";//No TP Scroll UI 
    //newUI.FindChildTraverse("inventory_neutral_slot_container").style.visibility = "collapse";//No Neutral Item Slot
    //newUI.FindChildTraverse("inventory").style.width="500px";
    //newUI.FindChildTraverse("inventory").style.marginRight="-200px";
    //newUI.FindChildTraverse("inventory").FindChildTraverse("inventory_items").style.marginLeft="1px";
    //newUI.FindChildTraverse("inventory").FindChildTraverse("inventory_items").FindChildTraverse("inventory_backpack_list").style.visibility = "collapse";//隐藏备用物品栏
    //newUI.FindChildTraverse("inventory").FindChildTraverse("inventory_items").FindChildTraverse("InventoryContainer").FindChildTraverse("InventoryBG").style.visibility = "collapse";//好像隐藏不掉
    //newUI.FindChildTraverse("inventory").FindChildTraverse("inventory_items").FindChildTraverse("InventoryContainer").FindChildTraverse("HUDSkinInventoryBG").style.visibility = "collapse";
    $.Msg("SSSSS",DotaDefaultUIElement_t);
    GameUI.CustomUIConfig().dotaUi = newUI;


var NoKDA  = rootUI.FindChildTraverse("stackable_side_panels");
    NoKDA.FindChildTraverse("quickstats").style.visibility = "collapse";
    NoKDA.FindChildTraverse("PlusStatus").style.visibility = "collapse";

//newUI.FindChildTraverse("AbilitiesAndStatBranch").FindChildTraverse("StatBranch").BCreateChildren("<Panel id='herocountry' style='width:62px;height:62px;' class='ShowStatBranch'><Label id='herocountrytext' text='' style='font-size:60px;' class='ShowStatBranch'/></Panel>");
//GameEvents.Subscribe( "playergetcountry", upcountry)


GameEvents.Subscribe( "CameraRotateHorizontal", (data) => {
    GameUI.SetCameraYaw(data["angle"])
})
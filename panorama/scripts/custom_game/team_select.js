"use strict";

// Global list of panels representing each of the teams
var g_TeamPanels = [];

// Global list of panels representing each of the players (1 per-player). These are reparented
// to the appropriate team panel to indicate which team the player is on.
var g_PlayerPanels = [];

var g_TEAM_SPECATOR = 1;

var min_wait_time = Game.GetAllPlayerIDs().length == 1 ? 0 : 20;

var startTime = Game.GetGameTime();

//--------------------------------------------------------------------------------------------------
// Handeler for when the unssigned players panel is clicked that causes the player to be reassigned
// to the unssigned players team
//--------------------------------------------------------------------------------------------------
function OnLeaveTeamPressed() {
    Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_NOTEAM);
}


//--------------------------------------------------------------------------------------------------
// Handler for when the Lock and Start button is pressed
//--------------------------------------------------------------------------------------------------
function OnLockAndStartPressed() {
    // Don't allow a forced start if there are unassigned players
    if (Game.GetUnassignedPlayerIDs().length > 0)
        return;

    if (Game.GetGameTime() - startTime < min_wait_time)
        return;

    // Lock the team selection so that no more team changes can be made
    Game.SetTeamSelectionLocked(true);

    // Disable the auto start count down
    Game.SetAutoLaunchEnabled(false);

    // Set the remaining time before the game starts
    Game.SetRemainingSetupTime(15);
}


//--------------------------------------------------------------------------------------------------
// Handler for when the Cancel and Unlock button is pressed
//--------------------------------------------------------------------------------------------------
function OnCancelAndUnlockPressed() {
    // Unlock the team selection, allowing the players to change teams again
    Game.SetTeamSelectionLocked(false);

    // Stop the countdown timer
    Game.SetRemainingSetupTime(-1);
}


//--------------------------------------------------------------------------------------------------
// Handler for the auto assign button being pressed
//--------------------------------------------------------------------------------------------------
function OnAutoAssignPressed() {
    // Assign all of the currently unassigned players to a team, trying
    // to keep any players that are in a party on the same team.
    Game.AutoAssignPlayersToTeams();
}


//--------------------------------------------------------------------------------------------------
// Handler for the shuffle player teams button being pressed
//--------------------------------------------------------------------------------------------------
function OnShufflePlayersPressed() {
    // Shuffle the team assignments of any players which are assigned to a team,
    // this will not assign any players to a team which are currently unassigned.
    // This will also not attempt to keep players in a party on the same team.
    Game.ShufflePlayerTeamAssignments();
}


//--------------------------------------------------------------------------------------------------
// Find the player panel for the specified player in the global list or create the panel if there
// is not already one in the global list. Make the new or existing panel a child panel of the
// specified parent panel
//--------------------------------------------------------------------------------------------------
function FindOrCreatePanelForPlayer(playerId, parent) {
    // Search the list of player player panels for one witht the specified player id
    for (var i = 0; i < g_PlayerPanels.length; ++i) {
        var playerPanel = g_PlayerPanels[i];

        if (playerPanel.GetAttributeInt("player_id", -1) == playerId) {
            playerPanel.SetParent(parent);
            return playerPanel;
        }
    }

    // Create a new player panel for the specified player id if an existing one was not found
    var newPlayerPanel = $.CreatePanel("Panel", parent, "player_root" + playerId);
        newPlayerPanel.SetAttributeInt("player_id", playerId);
        newPlayerPanel.AddClass("player_root");

        //newPlayerPanel.BLoadLayout("file://{resources}/layout/custom_game/team_select_player.xml", false, false);

        newPlayerPanel.BLoadLayoutSnippet('PlayerSnip');
        newPlayerPanel.FindChildInLayoutFile("PlayerLeaveTeamButton").SetPanelEvent('onactivate',function() { Game.PlayerJoinTeam(6); }  ) ;
        OnPlayerDetailsChanged(newPlayerPanel);

    // Add the panel to the global list of player planels so that we will find it next time
    g_PlayerPanels.push(newPlayerPanel);

    return newPlayerPanel;
}

function OnPlayerDetailsChanged(newPlayerPanel) {

    var playerId = newPlayerPanel.GetAttributeInt("player_id", -1);
    
    var playerInfo = Game.GetPlayerInfo(playerId);
    if (playerInfo) {
        $("#PlayerName").text = playerInfo.player_name;
        $("#PlayerAvatar").steamid = playerInfo.player_steamid;

        newPlayerPanel.SetHasClass("player_is_local", playerInfo.player_is_local);
        newPlayerPanel.SetHasClass("player_has_host_privileges", playerInfo.player_has_host_privileges);
    }
}

//--------------------------------------------------------------------------------------------------
// Find player slot n in the specified team panel
//--------------------------------------------------------------------------------------------------
function FindPlayerSlotInTeamPanel(teamPanel, playerSlot) {
    var playerListNode = teamPanel.FindChildInLayoutFile("PlayerList");
    if (playerListNode == null)
        return null;

    var nNumChildren = playerListNode.GetChildCount();
    for (var i = 0; i < nNumChildren; ++i) {
        var panel = playerListNode.GetChild(i);
        if (panel.GetAttributeInt("player_slot", -1) == playerSlot) {
            return panel;
        }
    }

    return null;
}


//--------------------------------------------------------------------------------------------------
// Update the specified team panel ensuring that it has all of the players currently assigned to its
// team and the the remaining slots are marked as empty
//--------------------------------------------------------------------------------------------------
function UpdateTeamPanel(teamPanel) {
    // Get the id of team this panel is displaying
    var teamId = teamPanel.GetAttributeInt("team_id", -1);
    if (teamId <= 0)
        return;

    // Add all of the players currently assigned to the team
    var teamPlayers = Game.GetPlayerIDsOnTeam(teamId);
    for (var i = 0; i < teamPlayers.length; ++i) {
        var playerSlot = FindPlayerSlotInTeamPanel(teamPanel, i);
        playerSlot.RemoveAndDeleteChildren();
        FindOrCreatePanelForPlayer(teamPlayers[i], playerSlot);
    }

    // Fill in the remaining player slots with the empty slot indicator
    var teamDetails = Game.GetTeamDetails(teamId);
    var nNumPlayerSlots = teamDetails.team_max_players;
    for (var i = teamPlayers.length; i < nNumPlayerSlots; ++i) {
        var playerSlot = FindPlayerSlotInTeamPanel(teamPanel, i);
        if (playerSlot.GetChildCount() == 0) {
            var empty_slot = $.CreatePanel("Panel", playerSlot, "");
                empty_slot.AddClass("player_root");
                empty_slot.BLoadLayout("file://{resources}/layout/custom_game/team_select_empty_slot.xml", false, false);
        }
    }

    // Change the display state of the panel to indicate the team is full
    teamPanel.SetHasClass("team_is_full", (teamPlayers.length === teamDetails.team_max_players));

    // If the local player is on this team change team panel to indicate this
    var localPlayerInfo = Game.GetLocalPlayerInfo()
    if (localPlayerInfo) {
        var localPlayerIsOnTeam = (localPlayerInfo.player_team_id === teamId);
        teamPanel.SetHasClass("local_player_on_this_team", localPlayerIsOnTeam);
    }
}


//--------------------------------------------------------------------------------------------------
// Update the unassigned players list and all of the team panels whenever a change is made to the
// player team assignments
//--------------------------------------------------------------------------------------------------
function OnTeamPlayerListChanged() {
    var unassignedPlayersContainerNode = $("#UnassignedPlayersContainer");
    if (unassignedPlayersContainerNode === null)
        return;

    // Move all existing player panels back to the unassigned player list
    for (var i = 0; i < g_PlayerPanels.length; ++i) {
        var playerPanel = g_PlayerPanels[i];
        playerPanel.SetParent(unassignedPlayersContainerNode);
    }

    // Make sure all of the unassigned player have a player panel
    // and that panel is a child of the unassigned player panel.
    var unassignedPlayers = Game.GetUnassignedPlayerIDs();
    for (var i = 0; i < unassignedPlayers.length; ++i) {
        var playerId = unassignedPlayers[i];
        FindOrCreatePanelForPlayer(playerId, unassignedPlayersContainerNode);
    }

    // Update all of the team panels moving the player panels for the
    // players assigned to each team to the corresponding team panel.
    for (var i = 0; i < g_TeamPanels.length; ++i) {
        UpdateTeamPanel(g_TeamPanels[i])
    }

    // Set the class on the panel to indicate if there are any unassigned players
    $("#GameAndPlayersRoot").SetHasClass("unassigned_players", unassignedPlayers.length != 0);
    $("#GameAndPlayersRoot").SetHasClass("no_unassigned_players", unassignedPlayers.length == 0);
}


//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
function OnPlayerSelectedTeam(nPlayerId, nTeamId, bSuccess) {
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo)
        return;

    // Check to see if the event is for the local player
    if (playerInfo.player_id === nPlayerId) {
        // Play a sound to indicate success or failure
        if (bSuccess) {
            Game.EmitSound("ui_team_select_pick_team");
        } else {
            Game.EmitSound("ui_team_select_pick_team_failed");
        }
    }
}


//--------------------------------------------------------------------------------------------------
// Check to see if the local player has host privileges and set the 'player_has_host_privileges' on
// the root panel if so, this allows buttons to only be displayed for the host.
//--------------------------------------------------------------------------------------------------
function CheckForHostPrivileges() {
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo)
        return;

    // Set the "player_has_host_privileges" class on the panel, this can be used
    // to have some sub-panels on display or be enabled for the host player.
    $.GetContextPanel().SetHasClass("player_has_host_privileges", playerInfo.player_has_host_privileges);
}


//--------------------------------------------------------------------------------------------------
// Update the state for the transition timer periodically
//--------------------------------------------------------------------------------------------------
function UpdateTimer()
{
    var gameTime = Game.GetGameTime();
    var transitionTime = Game.GetStateTransitionTime();

    CheckForHostPrivileges();

    var mapInfo = Game.GetMapInfo();
    $( "#MapInfo" ).SetDialogVariable( "map_name", mapInfo.map_display_name );

    if ( transitionTime >= 0 )
    {
        $( "#StartGameCountdownTimer" ).SetDialogVariableInt( "countdown_timer_seconds", Math.max( 0, Math.floor( transitionTime - gameTime ) ) );
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_active", true );
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_inactive", false );
    }
    else
    {
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_active", false );
        $( "#StartGameCountdownTimer" ).SetHasClass( "countdown_inactive", true );
    }

    var autoLaunch = Game.GetAutoLaunchEnabled();
    $( "#StartGameCountdownTimer" ).SetHasClass( "auto_start", autoLaunch );
    $( "#StartGameCountdownTimer" ).SetHasClass( "forced_start", ( autoLaunch == false ) );

    // Allow the ui to update its state based on team selection being locked or unlocked
    $.GetContextPanel().SetHasClass( "teams_locked", Game.GetTeamSelectionLocked() );
    $.GetContextPanel().SetHasClass( "teams_unlocked", Game.GetTeamSelectionLocked() == false );

    $.Schedule( 0.1, UpdateTimer );
}

function CreateTeam(teamId) {
    
    var teamNode = $.CreatePanel("Panel", $("#TeamsListRoot"), "team_" + teamId);
        teamNode.BLoadLayoutSnippet('TeamSnip');
        teamNode.AddClass("team_" + teamId);
        teamNode.SetPanelEvent('onactivate',function() { Game.PlayerJoinTeam(teamId); }  ) ;
        teamNode.SetAttributeInt("team_id", teamId);
    var teamDetails = Game.GetTeamDetails(teamId);

    // 将团队徽标添加到面板
    var logo_xml = GameUI.CustomUIConfig().team_logo_xml;
    if (logo_xml) {
        var teamLogoPanel = teamNode.FindChildInLayoutFile("TeamLogo");
            teamLogoPanel.SetAttributeInt("team_id", teamId);
            teamLogoPanel.BLoadLayout(logo_xml, false, false);
    }

    // 设定团队名称
    var teamDetails = Game.GetTeamDetails(teamId);
    teamNode.FindChildInLayoutFile("TeamNameLabel").text = $.Localize(teamDetails.team_name);

    // 获取玩家列表并添加玩家位置，以便有多达team_max_player位置
    var playerListNode = teamNode.FindChildInLayoutFile("PlayerList");

    var numPlayerSlots = teamDetails.team_max_players;
    for (var i = 0; i < numPlayerSlots; ++i) {
        // Add the slot itself
        var slot = $.CreatePanel("Panel", playerListNode, "");
            slot.AddClass("player_slot");
            slot.SetAttributeInt("player_slot", i);
    }

    if (GameUI.CustomUIConfig().team_colors) {
        var teamColor = GameUI.CustomUIConfig().team_colors[teamId].replace(";", "");

        teamNode.FindChildInLayoutFile("TeamBackgroundGradient").style.backgroundColor = 'gradient( linear, 0% 0%, 70% 100%, from( ' + teamColor + '77 ), color-stop(0.75, #00000077), to( #00000077) );';
        teamNode.FindChildInLayoutFile("TeamBackgroundGradientHighlight").style.backgroundColor = 'gradient( linear, 0% 0%, 80% 100%, from( ' + teamColor + 'AA ), color-stop(0.9, #00000088), to( #00000088 ) );';
        // var gradientText = 'gradient( linear, -800% -1600%, 90% 100%, from( ' + teamColor + ' ), to( #00000088 ) );';
        teamNode.FindChildInLayoutFile("TeamNameLabel").style.color = teamColor + ';';
        
    }

    //将团队面板添加到全局列表中，以便我们稍后可以轻松进行更新
    g_TeamPanels.push(teamNode); 
}


//--------------------------------------------------------------------------------------------------
// Entry point called when the team select panel is created
//--------------------------------------------------------------------------------------------------
(function () {
    var bShowSpectatorTeam = false;
    var bAutoAssignTeams = true;


    // 获取任何自定义配置
    if (GameUI.CustomUIConfig().team_select) {
        var cfg = GameUI.CustomUIConfig().team_select;
        if (cfg.bShowSpectatorTeam !== undefined) {
                bShowSpectatorTeam = cfg.bShowSpectatorTeam;
        }
        if (cfg.bAutoAssignTeams !== undefined) {
                bAutoAssignTeams = cfg.bAutoAssignTeams;
        }
    }

    // 默认情况下阻止聊天窗口聚焦
    $("#TeamSelectContainer").SetAcceptsFocus(true); 

    // 为每个团队构建面板
    var allTeamIDs = Game.GetAllTeamIDs();
    if  (bShowSpectatorTeam) { allTeamIDs.unshift(g_TEAM_SPECATOR); }
    for (var teamId of allTeamIDs) { CreateTeam(teamId) }

    // 自动将玩家分配到团队
    if (bAutoAssignTeams) { Game.AutoAssignPlayersToTeams(); }

    // 对玩家队伍分配进行初步更新
    OnTeamPlayerListChanged();

    // 开始更新计时器，此功能将安排自己定期调用
    UpdateTimer();

    // 监听当玩家分配队伍
    $.RegisterForUnhandledEvent("DOTAGame_TeamPlayerListChanged", OnTeamPlayerListChanged);

    // 监听玩家选择队伍
    $.RegisterForUnhandledEvent("DOTAGame_PlayerSelectedCustomTeam", OnPlayerSelectedTeam);
    
    //监听玩家更改队伍
    $.RegisterForUnhandledEvent("DOTAGame_PlayerDetailsChanged", OnPlayerDetailsChanged);
})();

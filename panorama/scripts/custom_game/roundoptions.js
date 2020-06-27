//显示投票板
GameEvents.Subscribe("Display_RoundVote", (info) => {
    var bool = false;
    $("#RoundOptions").visible = !bool;
    $("#RoundOptions").SetHasClass("OnPanelClass", !bool);
    $("#RoundOptions").SetHasClass("OffPanelClass", bool);

    for (var i = 1; i <= 5; i++)
        if (info[i] != "") {
            $("#hero" + i).heroname = info[i];
            $("#hero" + i).AddClass("selectred");
        }
})

//关闭投票板
GameEvents.Subscribe("Close_RoundVote", () => {
    var bool = true;
    $.Schedule(1, () => {
        $("#RoundOptions").visible = !bool
    });
    $("#RoundOptions").SetHasClass("OnPanelClass", !bool);
    $("#RoundOptions").SetHasClass("OffPanelClass", bool);
})

//更新投票
GameEvents.Subscribe("changevote", (info) => {
    var hero = info.hero;
    if (info.id == Game.GetLocalPlayerID()) {
        $("#confirmation").text = info.bool ? "#ready" : "#voteyestext";
    }
    for (var i = 1; i <= 5; i++)
        if (hero == "npc_dota_hero_" + $("#hero" + i).heroname) {
            $("#hero" + i).SetHasClass("selectred", !info.bool)
            $("#hero" + i).SetHasClass("selectgreen", info.bool)
        }
})

$("#RoundOptions").visible = false;
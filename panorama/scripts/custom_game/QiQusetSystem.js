function RefreshQuestData(data){
    var TargetPanleId=data.name
    var TargetPanleSvalue=data.svalue
    var TargetPanleEvalue=data.evalue
var TargetPanleText=$.Localize(data.text)+"("+TargetPanleSvalue+"/"+TargetPanleEvalue+")"
    var QuestPanle=$('#QuestExample').FindChild(TargetPanleId)
    var ValuePercent=parseInt(parseInt(TargetPanleSvalue)/parseInt(TargetPanleEvalue)*100)
    if(QuestPanle!=null){
        SliderPanle=QuestPanle.GetChild(0);
        SliderPanle.GetChild(0).style.width=ValuePercent.toString()+"%"
        SliderPanle.GetChild(1).style.width=(100-ValuePercent).toString()+"%"
        QuestPanle.GetChild(1).GetChild(0).text=TargetPanleText
    }
}
function CreatQuest(data) {
        $.Msg("CreateQuest")
        NewPanel = $.CreatePanel('Panel', $('#QuestExample'),data.name);
        NewPanel.BLoadLayoutSnippet("QuestLine");
        NewPanel.AddClass("Panle_MarginStyle")
        $.Msg(data)
}
// CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(i), "refreshquestdata", {name=QuestSystem.InfoTable[1],text = QuestSystem.InfoTable[2], svalue = QuestSystem.InfoTable[3],evalue=QuestSystem.InfoTable[4])
function RemoveQuestPUI(data){
    var RemovePanle=$('#QuestExample').FindChild(data.name)
    RemovePanle.deleted = true;
    RemovePanle.DeleteAsync(0);

}
GameEvents.Subscribe( "createquest", CreatQuest);
GameEvents.Subscribe( "refreshquestdata", RefreshQuestData);
GameEvents.Subscribe( "removequestpui", RemoveQuestPUI);
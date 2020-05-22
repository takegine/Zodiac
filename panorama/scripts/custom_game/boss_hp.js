function RefreshHPData(data){

    var panleId=data.name
    var panleSvalue=data.svalue
    var panleEvalue=data.evalue
    var remark=data.remark
    
    var questPanle=$('#QuestPanel').FindChild(panleId)
    var valuePercent=parseInt(panleSvalue)/parseInt(panleEvalue)*100;
    if(questPanle!=null){
        sliderPanle=questPanle.GetChild(0);
        sliderPanle.GetChild(0).style.width=valuePercent.toString()+"%"
        sliderPanle.GetChild(1).style.width=(100-valuePercent).toString()+"%"
        questPanle.GetChild(1).GetChild(0).text=panleText
         if (remark!=null)
         {
             questPanle.GetChild(1).GetChild(0).SetDialogVariableInt( "remark", remark);
         }
         if (panleSvalue!=null)
         {
             questPanle.GetChild(1).GetChild(0).SetDialogVariableInt( "panleSvalue", panleSvalue);
         }
         if (panleEvalue!=null)
         {
             questPanle.GetChild(1).GetChild(0).SetDialogVariableInt( "panleEvalue", panleEvalue);
         }
         if (panleEvalue!=null)
         {
             if (panleSvalue!=null)
            {
                questPanle.GetChild(1).GetChild(0).SetDialogVariableInt( "Eva-Sva", panleEvalue - panleSvalue);
            }
         }
        var panleText=$.Localize(data.text,questPanle.GetChild(1).GetChild(0))
        questPanle.GetChild(1).GetChild(0).text=panleText
    }
}

function CreatHP(data) {
        newPanel = $.CreatePanel('Panel', $('#QuestPanel'),data.name);
        newPanel.BLoadLayoutSnippet("QuestLine");
        newPanel.AddClass("Panle_MarginStyle")
}

function RemoveHPPUI(data){
    $.Msg(data.name+"data name")
    var RemovePanle=$('#QuestPanel').FindChild(data.name)
    RemovePanle.deleted = true;
    RemovePanle.DeleteAsync(0);
}

(function(){ 
    GameEvents.Subscribe( "createhp", CreatHP);
    GameEvents.Subscribe( "refreshhpdata", RefreshHPData);
    GameEvents.Subscribe( "removehppui", RemoveHPPUI);
})();
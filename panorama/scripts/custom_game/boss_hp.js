(function(){ 

    GameEvents.Subscribe( "createhp", (data) => {
        newPanel = $.CreatePanel('Panel', $('#QuestPanel'),data.name);
        newPanel.BLoadLayoutSnippet("QuestLine");
        newPanel.AddClass("Panle_MarginStyle")
    });

    GameEvents.Subscribe( "removehppui", (data) => {
        $.Msg(data.name+"data name")
        var RemovePanle=$('#QuestPanel').FindChild(data.name)
        RemovePanle.deleted = true;
        RemovePanle.DeleteAsync(0);
    });

    GameEvents.Subscribe( "refreshhpdata", (data) => {

        var panleId    = data.name
        var panleSvalue= data.svalue
        var panleEvalue= data.evalue
        var text       = data.text
        
        var questPanle = $('#QuestPanel').FindChild( panleId )
        var HpPercent  = parseInt(panleSvalue) / parseInt(panleEvalue) *100;
        
        if( questPanle )
            sliderPanle = questPanle.GetChild(0);
            sliderPanle.GetChild(0).style.width = HpPercent.toString()+"%";
            sliderPanle.GetChild(1).style.width = (100-HpPercent).toString()+"%";
    
            changepanle = questPanle.GetChild(1).GetChild(0);
            changepanle.SetDialogVariableInt( "panleSvalue", panleSvalue);
            changepanle.SetDialogVariableInt( "panleEvalue", panleEvalue);
            changepanle.text = $.Localize( text , changepanle)
        
    });
})();
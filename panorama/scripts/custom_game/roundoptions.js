

function UpdateVote(info)
{
    
    if( info.bool == true){
        if ("npc_dota_hero_" + $("#hero1").heroname == info.hero||$("#hero1").BHasClass("selectred"))    { $("#hero1").RemoveClass("selectred"); $("#hero1").AddClass("selectgreen");	  }
        if ("npc_dota_hero_" + $("#hero2").heroname == info.hero||$("#hero2").BHasClass("selectred"))    { $("#hero2").RemoveClass("selectred"); $("#hero2").AddClass("selectgreen");     }
        if ("npc_dota_hero_" + $("#hero3").heroname == info.hero||$("#hero3").BHasClass("selectred"))    { $("#hero3").RemoveClass("selectred"); $("#hero3").AddClass("selectgreen");     }
        if ("npc_dota_hero_" + $("#hero4").heroname == info.hero||$("#hero4").BHasClass("selectred"))    { $("#hero4").RemoveClass("selectred"); $("#hero4").AddClass("selectgreen");     }
        if ("npc_dota_hero_" + $("#hero5").heroname == info.hero||$("#hero5").BHasClass("selectred"))    { $("#hero5").RemoveClass("selectred"); $("#hero5").AddClass("selectgreen");     }

        $("#confirmation").text = "#voteyestext";
        }
    else{
        if ("npc_dota_hero_" + $("#hero1").heroname == info.hero||$("#hero1").BHasClass("selectgreen"))    { $("#hero1").RemoveClass("selectgreen"); $("#hero1").AddClass("selectred");     }
        if ("npc_dota_hero_" + $("#hero2").heroname == info.hero||$("#hero2").BHasClass("selectgreen"))    { $("#hero2").RemoveClass("selectgreen"); $("#hero2").AddClass("selectred");     }
        if ("npc_dota_hero_" + $("#hero3").heroname == info.hero||$("#hero3").BHasClass("selectgreen"))    { $("#hero3").RemoveClass("selectgreen"); $("#hero3").AddClass("selectred");     }
        if ("npc_dota_hero_" + $("#hero4").heroname == info.hero||$("#hero4").BHasClass("selectgreen"))    { $("#hero4").RemoveClass("selectgreen"); $("#hero4").AddClass("selectred");     }
        if ("npc_dota_hero_" + $("#hero5").heroname == info.hero||$("#hero5").BHasClass("selectgreen"))    { $("#hero5").RemoveClass("selectgreen"); $("#hero5").AddClass("selectred");     }

        $("#confirmation").text = "#ready";
        }
}

function open(info)
{
    if ($("#RoundOptions").visible == false)    {        $("#RoundOptions").visible = true;    }

    if (info.hero1 != "")    {   $("#hero1").heroname = info.hero1;        $("#hero1").AddClass("selectred");    }
    if (info.hero2 != "")    {   $("#hero2").heroname = info.hero2;        $("#hero2").AddClass("selectred");    }
    if (info.hero3 != "")    {   $("#hero3").heroname = info.hero3;        $("#hero3").AddClass("selectred");    }
    if (info.hero4 != "")    {   $("#hero4").heroname = info.hero4;        $("#hero4").AddClass("selectred");    }
    if (info.hero5 != "")    {   $("#hero5").heroname = info.hero5;        $("#hero5").AddClass("selectred");    }
}

function close(){	$("#RoundOptions").visible = false;  }


(function()
{
    GameEvents.Subscribe( "Display_RoundVote", open)//显示投票板
    GameEvents.Subscribe( "Close_RoundVote", close)//关闭投票板
    
    GameEvents.Subscribe( "changevote", UpdateVote)//显示投票板
    
    $("#RoundOptions").visible = false;

})();
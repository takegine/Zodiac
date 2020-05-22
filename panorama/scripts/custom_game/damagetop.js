function open(info)
{
    $.Msg(info);
    
    if (info.hero1 != null && info.damage1 != 0)
    {
        $("#DamageTop").visible = true;
        $("#topp").visible = true;
        $("#hero1").visible = true;
        $("#ihero1").heroname = info.hero1;
        $("#DamageH1").text = info.damage1;
    }
    else
    {
        $("#hero1").visible = false;
        $("#topp").visible = false;
        $("#DamageTop").visible = false;
    }
    
    if (info.hero2 != null)
    {
        $("#hero2").visible = true;
        $("#ihero2").heroname = info.hero2;
        $("#DamageH2").text = info.damage2;
    }
    else
    {
        $("#hero2").visible = false;
    }
    
    if (info.hero3 != null)
    {
        $("#hero3").visible = true;
        $("#ihero3").heroname = info.hero3;
        $("#DamageH3").text = info.damage3;
    }
    else
    {
        $("#hero3").visible = false;
    }
    
    if (info.hero4 != null)
    {
        $("#hero4").visible = true;
        $("#ihero4").heroname = info.hero4;
        $("#DamageH4").text = info.damage4;
    }
    else
    {
        $("#hero4").visible = false;
    }
    
    if (info.hero5 != null)
    {
        $("#hero5").visible = true;
        $("#ihero5").heroname = info.hero5;
        $("#DamageH5").text = info.damage5;
    }
    else
    {
        $("#hero5").visible = false;
    }
}

function close()
{
	$("#DamageTop").visible = false;
}

(function()
{
    GameEvents.Subscribe( "Open_DamageTop", open)
    GameEvents.Subscribe( "Close_DamageTop", close)
    
    $("#DamageTop").visible = false;
})();
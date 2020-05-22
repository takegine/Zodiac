var lll = false;
var inventory = null;
var slots = null;
var saves = null;
var filter = 0;     //筛选表头 颜色默认为没有
var filter2 = 0;    //筛选表头 类型默认为没有
var nowselected = 0; //默认选中0面板
var purestones = [];
var upgradestone = "";
var color = 1;

function Yes()//桌面按钮 显示/隐藏总结面
{
    purestones = [];
    if (lll == true)
    {

        $("#AllRelicPanel").RemoveClass("CreatePanelClass");
        $("#AllRelicPanel").AddClass("OffPanelClass");
        lll = false;
    }
    else
    {
        if ($("#AllRelicPanel").visible == false)
        {
            $("#AllRelicPanel").visible = true;
        }
        $("#AllRelicPanel").RemoveClass("OffPanelClass");
        $("#AllRelicPanel").AddClass("CreatePanelClass");
        lll = true;
        GameEvents.SendCustomGameEventToServer( "Levels", { id: Players.GetLocalPlayer()} );
    }
}


function Buy(id)//购买遗物
{
    //$.Msg( "Buy ", $("#myitem1").itemname);
    if (id == 0) //0就是购买全部，1-8就是具体装备，把参数传给服务器
    {  GameEvents.SendCustomGameEventToServer( "Buy_Relic", { id: Players.GetLocalPlayer(),num:id} );    }
    else
    {  GameEvents.SendCustomGameEventToServer( "Buy_Relic", { item: $("#lvlmyitem"+id).itemname,id: Players.GetLocalPlayer(),num:id} );    }
}


function ClickItemOnSlot(slotnum)
{
    GameEvents.SendCustomGameEventToServer( "SniatRS", { id: Players.GetLocalPlayer(),slotid:slotnum} );
}

function ClickItemOnInv(rsid)
{
    if (nowselected == 0)
    {
        GameEvents.SendCustomGameEventToServer( "EqipRS", { id: Players.GetLocalPlayer(),rsid:rsid.toString()} );
    }
    else if (nowselected == 1)
    {
        for (var i = 1; i <= 8; i++)
        {
            if (slots[i] == rsid)
            {
                return;
            }
        }
        var est = false;
        var ind = -1;
        for (var i = 0; i < purestones.length; i++)
        {
            if (purestones[i] == rsid.toString())
            {
                est = true;
                ind = i;
                break;
            }
        }
        if (est == true)
        {
            purestones.splice(ind, 1);
        }
        else
        {
            purestones.splice(purestones.Length, 0, rsid.toString());
        }
        RefreshInventory(false);//刷新石头面板
        UpdtPureDust();
    }
    else if (nowselected == 2)
    {
        for (var i = 1; i <= 8; i++)
        {
            if (slots[i] == rsid)
            {
                return;
            }
        }
        upgradestone = rsid.toString();
        UpdtUpgrade();
    }
}

function UpgradeButton()
{
    if ($("#UpgradeButton").BHasClass("PureButtonact"))
    {
        $("#forupgradepartpanel").RemoveAndDeleteChildren();
        if (upgradestone.charAt(7) != '5' && upgradestone.charAt(0) == '4')
        {
            var dust = 0;//粉末数归零
            var qual = upgradestone.charAt(7);
            switch(qual) {//升星需要的粉末数
                case '0':                dust = 40;                break
                case '1':                dust = 80;                break            
                case '2':                dust = 160;                break            
                case '3':                dust = 320;                break            
                case '4':                dust = 640;                break
            }

            if (Number($("#dustlabeltxt").text) >= dust)//如果粉末数大于需求数
            {
                GameEvents.SendCustomGameEventToServer( "UpgradeRS", { id: Players.GetLocalPlayer(),rs:upgradestone} );
                qual = Number(qual)+1;
                //$("#dustlabeltxt").text = Number($("#dustlabeltxt").text) - dust;
                upgradestone = upgradestone.substring(0,7) + qual.toString() + upgradestone.substring(8);
                UpdtUpgrade();
                $("#forupgradepartpanel").BCreateChildren("<DOTAScenePanel id='testtt' hittest='false' particleonly='true' style='margin-top:0px; margin-left:114px; height:350px;width:350px;' map='cameras' camera='partcamera3' />");
            }
        }
    }
}

function UpdtUpgrade()
{
    $("#forupitem").RemoveAndDeleteChildren();
    $("#upgradebuttontext").text = $.Localize("#noupgrade");
    $("#UpgradeButton").RemoveClass("PureButtonact");
    $("#UpgradeButton").AddClass("PureButtondis");
    if (upgradestone != "")
    {
        switch(upgradestone.charAt(0)) {
            case '1':
            rares = "shards";            myclass = "common";            break
        
            case '2':
            rares = "stones";            myclass = "rare";            break
        
            case '3':
            rares = "crystals";            myclass = "mythical";            break
        
            case '4':
            rares = "clusters";            myclass = "immortal";            break
        }
        switch(upgradestone.charAt(1)) {
            case '0':    elem = "ice";       break
            case '1':    elem = "fire";            break
            case '2':    elem = "water";            break
            case '3':    elem = "energy";            break
            case '4':    elem = "earth";            break
            case '5':    elem = "life";            break
            case '6':    elem = "void";            break
            case '7':    elem = "air";            break
            case '8':    elem = "light";            break
            case '9':    elem = "shadow";            break
        }
        var boolestlivslote = "0";
        var estlivslote = "itemborder";
        for (var i = 1; i <= 8;i++)
        {
            if (upgradestone == slots[i])
            {
                boolestlivslote = "t";
                estlivslote = "selecteditemborder";
                break;
            }
        }
        $("#forupitem").BCreateChildren("<Panel hittest='false' id='upitem"+upgradestone+"' class='"+estlivslote+"' style='margin-top:0px; margin-left:0px;' onmouseover='UIShowCustomLayoutParametersTooltip(RSTooltip,file://{resources}/layout/custom_game/rs_tooltips.xml,num="+upgradestone+boolestlivslote+")' onmouseout='UIHideCustomLayoutTooltip(RSTooltip)'/>");
        $("#upitem"+upgradestone).BCreateChildren("<Image src='file://{images}/custom_game/relic_items/"+rares+"/"+elem+"/"+upgradestone.charAt(2)+".png' style='height:60px;width:80px;' onactivate='ClickItemOnInv("+upgradestone+")'/>");
        $("#upitem"+upgradestone).BCreateChildren("<Panel hittest='false' class='"+myclass+"' style='height:60px;width:5px; margin-left:80px;'/>");

        if (upgradestone.charAt(0) == '4')
        {
            if (upgradestone.charAt(7) != '5')
            {
                var dust = 0;
                switch(upgradestone.charAt(7)) {//升星需要的粉末数量
                    case '0':                    dust = 40;                    break
                    case '1':                    dust = 80;                    break                
                    case '2':                    dust = 160;                    break                
                    case '3':                    dust = 320;                    break                
                    case '4':                    dust = 640;                    break
                }
                $("#upgradebuttontext").text = $.Localize("#upgradeof") + dust;
                $("#UpgradeButton").RemoveClass("PureButtondis");
                $("#UpgradeButton").AddClass("PureButtonact");
            }
            else
            {
                $("#upgradebuttontext").text = $.Localize("#noupgrade");
                $("#UpgradeButton").RemoveClass("PureButtonact");
                $("#UpgradeButton").AddClass("PureButtondis");
            }
        }
        else
        {
            $("#upgradebuttontext").text = $.Localize("#noupgrade");
            $("#UpgradeButton").RemoveClass("PureButtonact");
            $("#UpgradeButton").AddClass("PureButtondis");
        }
    }
}

function UpdtPureDust()//更新纯粹粉末的数据
{
    var dust = 0;
    for (var i = 0; i < purestones.length; i++)
    {
        switch(purestones[i].charAt(0)) {//粉碎四个等级的石头所增加粉末
            case '1':            dust += 1;            break          
            case '2':            dust += 3;            break          
            case '3':            dust += 15;            break          
            case '4':            dust += 60;            break
        }
    }
    $("#puredustlabel").text = dust;//粉末余额
    //$("#puredustlabel").BCreateChildren("<DOTAScenePanel id='testtt"+dust+"' hittest='false' particleonly='true' style='height:100px;width:100px;' map='cameras' camera='partcamera2' />");
}

function PureButton()
{
    if ($("#PureButton").BHasClass("PureButtonact"))
    {
        if (purestones.length != 0)
        {
            GameEvents.SendCustomGameEventToServer( "PureRS", { id: Players.GetLocalPlayer(),rs:purestones} );
            purestones = []
            UpdtPureDust()
            $("#PureButton").RemoveClass("PureButtonact");
            $("#PureButton").AddClass("PureButtondis");
        }
    }
}

function UpdtLvl(info)
{
    if (info[1] == Players.GetLocalPlayer())
    {
        var actsealt = true;
        var sealt = true;
        for (var i = 2; i <= 8;i++)
        {
            if (info[i] > 0)
            {
                $("#lvlmyitem"+(i-1)).RemoveClass("riimg");
                $("#lvlmyitem"+(i-1)).AddClass("riimg2");
                if (info[i] >= 20)
                {
                    $("#lvlmyitemtext"+(i-1)).text = 20;//设置拥有遗物等级，最高显示20个
                }
                else
                {
                    $("#lvlmyitemtext"+(i-1)).text = info[i];//设置拥有遗物等级，实际等级
                    actsealt = false;
                }
            }
            else
            {
                sealt = false;
            }
        }
        if (info[9] > 0)
        {
            $("#lvlmyitem8").RemoveClass("riimg");
            $("#lvlmyitem8").AddClass("riimg2");
        }
        else
        {
            actsealt = false;
            sealt = false;
        }
        if (actsealt == true)
        {
            $("#relicitem").itemname = "item_seal_act";
            $("#mysealcampart").visible = true;      
            $("#locks1").visible = false;
            $("#locks2").visible = false;
        }
        else if (sealt == true)
        {
            $("#relicitem").itemname = "item_seal_1";
            $("#mysealcampart").visible = true;
            $("#locks1").visible = false;
        }
        inventory = info[10];
        $("#dustlabeltxt").text = info[11];   
        slots = info[12];
        saves = info[13];
        RefreshInventory(true)//刷新石头面板
        SetColors(info[15],info[14]);
        UpdtPureDust();
    }
}

function SetColors(estcolors,newcolor)
{
    for (var i = 2; i <= 12;i++)
    {
        if ($("#ColorButton"+i).BHasClass("noselectedfilter"))
        $("#ColorButton"+i).RemoveClass("noselectedfilter");
        if ($("#ColorButton"+i).BHasClass("selectedfilter"))
        $("#ColorButton"+i).RemoveClass("selectedfilter");
        $("#ColorButton"+i).AddClass("nocolor");
        //$("#ColorButton"+i).visible = false;
    }
    for (var i = 2; i <= 12;i++)
    {
        for(var prop in estcolors)
        {
            if (estcolors[prop] == i)
            {
                $("#ColorButton"+i).RemoveClass("nocolor");
                $("#ColorButton"+i).AddClass("noselectedfilter");
                //$("#ColorButton"+i).visible = true;
                break;
            }
        }
    }
    if (color != newcolor)
    {
        if (!$("#ColorButton"+color).BHasClass("nocolor"))
        {
            if ($("#ColorButton"+color).BHasClass("selectedfilter"))
            $("#ColorButton"+color).RemoveClass("selectedfilter");
            $("#ColorButton"+color).AddClass("noselectedfilter");
        }
        color = newcolor;
        if ($("#ColorButton"+newcolor).BHasClass("noselectedfilter"))
        $("#ColorButton"+newcolor).RemoveClass("noselectedfilter");
        $("#ColorButton"+newcolor).AddClass("selectedfilter");
    }
    else
    {
        if ($("#ColorButton"+newcolor).BHasClass("noselectedfilter"))
        $("#ColorButton"+newcolor).RemoveClass("noselectedfilter");
        $("#ColorButton"+newcolor).AddClass("selectedfilter");
    }
    $.Msg(color);
}

function RefreshInventory(upslots)//筛选石头
{
    $("#rsinv").RemoveAndDeleteChildren();
    var numininv = 0;
    for(var prop in inventory)
    {
        if (inventory[prop] != "0")
        {
            if (filter == 0)//如果没有按颜色筛选石头
            {
                if (filter2 == 0)//如果没有按类型筛选石头
                {
                    MiniFunc(prop,prop)
                }
                else//按类型筛选
                {
                    if (inventory[prop].charAt(3) == filter2.toString() || inventory[prop].charAt(4) == filter2.toString())
                    {
                        numininv++;
                        MiniFunc(numininv,prop)
                    }
                }
            }
            else//按颜色筛选
            {
                if (filter2 == 0)//没按类型筛选
                {
                    if (inventory[prop].charAt(0) == filter.toString())
                    {
                        numininv++;
                        MiniFunc(numininv,prop)
                    }
                }
                else//按类型筛选
                {
                    if (inventory[prop].charAt(0) == filter.toString())
                    {
                        if (inventory[prop].charAt(3) == filter2.toString() || inventory[prop].charAt(4) == filter2.toString())
                        {
                            numininv++;
                            MiniFunc(numininv,prop)
                        }
                    }
                }
            }
        }
    }//for循环结束
    if (saves != null)
    {
        $("#savespanelitems").RemoveAndDeleteChildren();
        for (var i = 1; i <= 8;i++)
        {
            if (saves[i.toString()] != "" && saves[i.toString()] != null)
            {
                var locarr = saves[i.toString()].split('|');
                for (var y = 0; y < 8;y++)
                {
                    if (locarr[y] != "")
                    {
                        var mtop = 30+90*(i-1)+35*Math.floor(y/4);
                        var mleft = 20+50*y-200*Math.floor(y/4);
                        switch(locarr[y].charAt(0)) {
                            case '1':
                            rares = "shards";
                            myclass = "common";
                            break
                        
                            case '2':
                            rares = "stones";
                            myclass = "rare";
                            break
                        
                            case '3':
                            rares = "crystals";
                            myclass = "mythical";
                            break
                        
                            case '4':
                            rares = "clusters";
                            myclass = "immortal";
                            break
                        }
                        switch(locarr[y].charAt(1)) {
                            case '0':                            elem = "ice";                            break                        
                            case '1':                            elem = "fire";                            break                        
                            case '2':                            elem = "water";                            break                        
                            case '3':                            elem = "energy";                            break                        
                            case '4':                            elem = "earth";                            break                        
                            case '5':                            elem = "life";                            break                        
                            case '6':                            elem = "void";                            break                                     
                            case '7':                            elem = "air";                            break 
                            case '8':                            elem = "light";                            break                        
                            case '9':                            elem = "shadow";                            break
                        }
                        var boolestlivslote = "0";
                        var estlivslote = "itemborder";
                        //for (var i = 1; i <= 8;i++)
                        //{
                        //    if (locarr[y] == slots[i])
                        //    {
                        //        boolestlivslote = "1";
                        //        estlivslote = "selecteditemborder";
                        //        break;
                        //    }
                        //}
                        var estbool = false;
                        for(var prop in inventory)
                        {
                            if (inventory[prop] == locarr[y])
                            {
                                estbool = true;
                                break;
                            }
                        }
                        if (estbool == false)
                        {
                            estlivslote = "selectedfditemborder";
                        }
                        $("#savespanelitems").BCreateChildren("<Panel hittest='false' id='save"+i+"sitem"+locarr[y]+"' class='"+estlivslote+"' style='margin-top:"+mtop+"px; margin-left:"+mleft+"px;' onmouseover='UIShowCustomLayoutParametersTooltip(RSTooltip,file://{resources}/layout/custom_game/rs_tooltips.xml,num="+locarr[y]+boolestlivslote+")' onmouseout='UIHideCustomLayoutTooltip(RSTooltip)'/>");
                        $("#save"+i+"sitem"+locarr[y]).BCreateChildren("<Image src='file://{images}/custom_game/relic_items/"+rares+"/"+elem+"/"+locarr[y].charAt(2)+".png' style='height:30px;width:40px;'/>");
                        $("#save"+i+"sitem"+locarr[y]).BCreateChildren("<Panel hittest='false' class='"+myclass+"' style='height:30px;width:3px; margin-left:40px;'/>");
                    }
                }
            }
        }
    }
    if (upslots == true)
    {
        $("#imgslots").RemoveAndDeleteChildren();
        for (var i = 1; i <= 8;i++)
        {
            $("#slot"+i+"anim1").visible = false;
            $("#slot"+i+"anim2").visible = false;
            var elems = new Array("ice","fire","water","energy","earth","life","void","air","light","shadow");
            for (var y = 0; y <= 9;y++)
            {
                if ($("#slot"+i+"anim1").BHasClass(elems[y]+"1"))
                    $("#slot"+i+"anim1").RemoveClass(elems[y]+"1");
                if ($("#slot"+i+"anim2").BHasClass(elems[y]+"2"))
                    $("#slot"+i+"anim2").RemoveClass(elems[y]+"2");
            }
        }
        for(var prop in slots)
        {
            //$.Msg(slots[prop]);
            if (slots[prop] != "0" && slots[prop] != "")
            {
                var coords = [];
                coords[1] = [35, 249];
                coords[2] = [234, 459];
                coords[3] = [432, 249];
                coords[4] = [234, 39];
                coords[5] = [83, 412];
                coords[6] = [384, 412];
                coords[7] = [384, 87];
                coords[8] = [83, 87];
                switch(slots[prop].charAt(0)) {
                    case '1':                    rares = "shards";                    break                  
                    case '2':                    rares = "stones";                    break                  
                    case '3':                    rares = "crystals";                    break                  
                    case '4':                    rares = "clusters";                    break
                }
                switch(slots[prop].charAt(1)) {
                    case '0':                    elem = "ice";                    break                  
                    case '1':                    elem = "fire";                    break                  
                    case '2':                    elem = "water";                    break
                    case '3':                    elem = "energy";                    break                  
                    case '4':                    elem = "earth";                    break                  
                    case '5':                    elem = "life";                    break                  
                    case '6':                    elem = "void";                    break                  
                    case '7':                    elem = "air";                    break                  
                    case '8':                    elem = "light";                    break                  
                    case '9':                    elem = "shadow";                    break
                }
                $("#slot"+prop+"anim1").visible = true;
                $("#slot"+prop+"anim2").visible = true;
                $("#slot"+prop+"anim1").AddClass(elem+"1");
                $("#slot"+prop+"anim2").AddClass(elem+"2");
                $("#imgslots").BCreateChildren("<Image id='imgslot"+prop+"' class='inslotitem' src='file://{images}/custom_game/relic_items/"+rares+"/"+elem+"/"+slots[prop].charAt(2)+".png' style='height:39px;width:52px; margin-top:"+coords[prop][0]+"px; margin-left:"+coords[prop][1]+"px;' onmouseover='UIShowCustomLayoutParametersTooltip(RSTooltip,file://{resources}/layout/custom_game/rs_tooltips.xml,num="+slots[prop]+")' onmouseout='UIHideCustomLayoutTooltip(RSTooltip)' onactivate='ClickItemOnSlot("+prop+")'/>");
            }
        }
    }
}

function MiniFunc(numininv,prop)
{  
    var mtop = 5 + 70*Math.floor((numininv-1)/3);
    var mleft = 5 + 95*(numininv-1)-285*Math.floor((numininv-1)/3);
    switch(inventory[prop].charAt(0)) {
        case '1':
        rares = "shards";
        myclass = "common";
        break
    
        case '2':
        rares = "stones";
        myclass = "rare";
        break
    
        case '3':
        rares = "crystals";
        myclass = "mythical";
        break
    
        case '4':
        rares = "clusters";
        myclass = "immortal";
        break
    }
    switch(inventory[prop].charAt(1)) {
        case '0':
        elem = "ice";
        break
    
        case '1':
        elem = "fire";
        break
    
        case '2':
        elem = "water";
        break
    
        case '3':
        elem = "energy";
        break
    
        case '4':
        elem = "earth";
        break
    
        case '5':
        elem = "life";
        break
    
        case '6':
        elem = "void";
        break
    
        case '7':
        elem = "air";
        break
    
        case '8':
        elem = "light";
        break
    
        case '9':
        elem = "shadow";
        break
    }
    var boolestlivslote = "0";
    var estlivslote = "itemborder";
    for (var i = 1; i <= 8;i++)
    {
        if (inventory[prop] == slots[i])
        {
            boolestlivslote = "t";
            estlivslote = "selecteditemborder";
            break;
        }
    }
    for (var i = 0; i < purestones.length; i++)
    {
        if (purestones[i] == inventory[prop].toString())
        {
            estlivslote = "selectedfditemborder";
            break;
        }
    }
    $("#rsinv").BCreateChildren("<Panel hittest='false' id='item"+inventory[prop]+"' class='"+estlivslote+"' style='margin-top:"+mtop+"px; margin-left:"+mleft+"px;' onmouseover='UIShowCustomLayoutParametersTooltip(RSTooltip,file://{resources}/layout/custom_game/rs_tooltips.xml,num="+inventory[prop]+boolestlivslote+")' onmouseout='UIHideCustomLayoutTooltip(RSTooltip)'/>");
    $("#item"+inventory[prop]).BCreateChildren("<Image src='file://{images}/custom_game/relic_items/"+rares+"/"+elem+"/"+inventory[prop].charAt(2)+".png' style='height:60px;width:80px;' onactivate='ClickItemOnInv("+inventory[prop]+")'/>");
    $("#item"+inventory[prop]).BCreateChildren("<Panel hittest='false' class='"+myclass+"' style='height:60px;width:5px; margin-left:80px;'/>");
}

function NeedRefresh(info)
{
    $("#RButton").visible = true;//显示刷新按钮
}

function SetFilter(filterid)
{
    if (filterid == filter)
    {
        filter = 0;
        $("#FilterButton"+filterid).RemoveClass("selectedfilter");
        $("#FilterButton"+filterid).AddClass("noselectedfilter");
    }
    else
    {
        if (filter != 0)
        {
            $("#FilterButton"+filter).RemoveClass("selectedfilter");
            $("#FilterButton"+filter).AddClass("noselectedfilter");
        }
        filter = filterid;
        $("#FilterButton"+filterid).RemoveClass("noselectedfilter");
        $("#FilterButton"+filterid).AddClass("selectedfilter");
        if (nowselected == 1)
        {
            if (GameUI.IsShiftDown())
            {
                $.Msg("test");
                purestones = [];
                for(var prop in inventory)
                {
                    if (inventory[prop] != "0")
                    {
                        if (inventory[prop].charAt(0) == filter.toString())
                        {
                            var moshno = true;
                            for (var i = 1; i <= 8; i++)
                            {
                                if (slots[i] == inventory[prop])
                                {
                                    moshno = false;
                                    break;
                                }
                            }
                            if (moshno)
                            {
                                purestones.splice(purestones.Length, 0, inventory[prop]);
                            }
                        }
                    }
                }
            }
        }
    }
    RefreshInventory(false);
    UpdtPureDust();
}

function SetFilter2(filter2id)
{
    if (filter2id == filter2)
    {
        filter2 = 0;
        $("#FilterButton2"+filter2id).RemoveClass("selectedfilter");
        $("#FilterButton2"+filter2id).AddClass("noselectedfilter");
    }
    else
    {
        if (filter2 != 0)
        {
            $("#FilterButton2"+filter2).RemoveClass("selectedfilter");
            $("#FilterButton2"+filter2).AddClass("noselectedfilter");
        }
        filter2 = filter2id;
        $("#FilterButton2"+filter2id).RemoveClass("noselectedfilter");
        $("#FilterButton2"+filter2id).AddClass("selectedfilter");
    }
    RefreshInventory(false)
}

function RefreshR()
{
	//$.Msg( "test" );
    $("#RButton").visible = false;//隐藏刷新按钮
    GameEvents.SendCustomGameEventToServer( "RefreshRelics", { id: Players.GetLocalPlayer()} );
}

function SelectPl(num)//点击上面三个选择面板的按钮触发，num是面板序号
{
    purestones = [];
    upgradestone = "";
    UpdtUpgrade();
    UpdtPureDust();
    RefreshInventory(false);//刷新石头面板
    nowselected = num;
    UpdateSelection();
}

function UpdateSelection()//根据显示的面板改变显示内容
{
	$("#spba0").visible = false;   //隐藏面板0图标
    $("#spba1").visible = false;   //隐藏面板1图标
    $("#spba2").visible = false;   //隐藏面板2图标
    $("#spba"+nowselected).visible = true;   //显示被选中的面板图标
    if (nowselected == 0)
    {
        $("#rsfilter").visible = true;//石头筛选列表表头
        $("#rsinv").visible = true;
        $("#osnova").visible = true;
        $("#puredust").visible = false;
        $("#dustlabel").visible = false;
        $("#saves").visible = true;
        $("#upgradepanel").visible = false;
        if ($("#saves").BHasClass("savesact"))
        {
            $("#saves").RemoveClass("savesact");
            $("#saves").AddClass("savesdis");
            //$("#rsfilter").visible = true;
            //$("#rsinv").visible = true;
        }
        $("#SavesButtonimg").AddClass("imgoff");
    }
    else if (nowselected == 1)
    {
        $("#osnova").visible = false;
        $("#rsfilter").visible = true;
        $("#rsinv").visible = true;
        $("#puredust").visible = true;
        $("#dustlabel").visible = true;
        $("#saves").visible = false;
        $("#upgradepanel").visible = false;
        if ($("#saves").BHasClass("savesact"))
        {
            $("#saves").RemoveClass("savesact");
            $("#saves").AddClass("savesdis");
            //$("#rsfilter").visible = true;
            //$("#rsinv").visible = true;
        }
        $("#SavesButtonimg").AddClass("imgoff");
    }
    else if (nowselected == 2)
    {
        $("#osnova").visible = false;
        $("#rsfilter").visible = true;
        $("#rsinv").visible = true;
        $("#puredust").visible = false;
        $("#dustlabel").visible = true;
        $("#saves").visible = false;
        $("#upgradepanel").visible = true;
        if ($("#saves").BHasClass("savesact"))
        {
            $("#saves").RemoveClass("savesact");
            $("#saves").AddClass("savesdis");
            //$("#rsfilter").visible = true;
            //$("#rsinv").visible = true;
        }
        $("#SavesButtonimg").AddClass("imgoff");
    }
}

function PureButtonReady()
{
    $("#PureButton").RemoveClass("PureButtondis");
    $("#PureButton").AddClass("PureButtonact");
}

function SavesButton()
{
    if ($("#saves").BHasClass("savesdis"))
    {
        $("#saves").RemoveClass("savesdis");
        $("#saves").AddClass("savesact");
        $("#rsfilter").visible = false;
        $("#rsinv").visible = false;
        $("#SavesButtonimg").RemoveClass("imgoff");
    }
    else
    {
        $("#saves").RemoveClass("savesact");
        $("#saves").AddClass("savesdis");
        $("#rsfilter").visible = true;
        $("#rsinv").visible = true;
        $("#SavesButtonimg").AddClass("imgoff");
    }
}

function SaveSet(num)
{
    if ($("#saves").BHasClass("savesact"))
    {
        $("#SaveButton1").RemoveClass("SaveButtons");
        $("#SaveButton2").RemoveClass("SaveButtons");
        $("#SaveButton3").RemoveClass("SaveButtons");
        $("#SaveButton4").RemoveClass("SaveButtons");
        $("#SaveButton5").RemoveClass("SaveButtons");
        $("#SaveButton6").RemoveClass("SaveButtons");
        $("#SaveButton7").RemoveClass("SaveButtons");
        $("#SaveButton8").RemoveClass("SaveButtons");
        $("#SaveButton1").AddClass("SaveButtonsdis");
        $("#SaveButton2").AddClass("SaveButtonsdis");
        $("#SaveButton3").AddClass("SaveButtonsdis");
        $("#SaveButton4").AddClass("SaveButtonsdis");
        $("#SaveButton5").AddClass("SaveButtonsdis");
        $("#SaveButton6").AddClass("SaveButtonsdis");
        $("#SaveButton7").AddClass("SaveButtonsdis");
        $("#SaveButton8").AddClass("SaveButtonsdis");
        GameEvents.SendCustomGameEventToServer( "SaveSet", { id: Players.GetLocalPlayer(), num:num} );
    }
}

function LoadSet(num)
{
    if ($("#saves").BHasClass("savesact"))
    {
        GameEvents.SendCustomGameEventToServer( "LoadSet", { id: Players.GetLocalPlayer(), num:num} );
    }
}

function ReadySetButton()
{
    $("#SaveButton1").RemoveClass("SaveButtonsdis");
    $("#SaveButton2").RemoveClass("SaveButtonsdis");
    $("#SaveButton3").RemoveClass("SaveButtonsdis");
    $("#SaveButton4").RemoveClass("SaveButtonsdis");
    $("#SaveButton5").RemoveClass("SaveButtonsdis");
    $("#SaveButton6").RemoveClass("SaveButtonsdis");
    $("#SaveButton7").RemoveClass("SaveButtonsdis");
    $("#SaveButton8").RemoveClass("SaveButtonsdis");
    $("#SaveButton1").AddClass("SaveButtons");
    $("#SaveButton2").AddClass("SaveButtons");
    $("#SaveButton3").AddClass("SaveButtons");
    $("#SaveButton4").AddClass("SaveButtons");
    $("#SaveButton5").AddClass("SaveButtons");
    $("#SaveButton6").AddClass("SaveButtons");
    $("#SaveButton7").AddClass("SaveButtons");
    $("#SaveButton8").AddClass("SaveButtons");
}

function SetColor(colorid)
{
    if (!$("#ColorButton"+colorid).BHasClass("nocolor"))
    if (colorid != color)
    {
        $("#ColorButton"+color).RemoveClass("selectedfilter");
        $("#ColorButton"+color).AddClass("noselectedfilter");
        color = colorid;
        $("#ColorButton"+colorid).RemoveClass("noselectedfilter");
        $("#ColorButton"+colorid).AddClass("selectedfilter");
        GameEvents.SendCustomGameEventToServer( "SetColor", { id: Players.GetLocalPlayer(), colorid:colorid} );
    }
}

(function()
{
    GameEvents.Subscribe( "My_lvl", UpdtLvl);                   //监听事件
    GameEvents.Subscribe( "NeedRefresh", NeedRefresh);          //监听事件
    GameEvents.Subscribe( "PureButtonReady", PureButtonReady);  //监听事件
    GameEvents.Subscribe( "ReadySetButton", ReadySetButton);    //监听事件
    $("#AllRelicPanel").visible = false;                        //主面板隐藏
	$("#RButton").visible = false;                              //隐藏刷新按钮
	$("#spba0").visible = false;                                //隐藏面板0的提亮图标
    $("#spba1").visible = false;                                //隐藏面板1的提亮图标
    $("#mysealcampart").visible = false;
    UpdateSelection()
})();
var crafts = [
    [4,8,2],
    [8,1,4],
    [9,5,6],
    [10,3,2],
    [6,8,7],
    [6,5,2],
    [7,2,4],
    [10,1,6],
    [8,5,3],
    [6,8,1],
    [9,8,2],
    [2,5,10],
    [3,4,2],
    [7,3,10],
    [10,6,4],
    [3,7,9],
    [9,1,10],
    [9,3,8],
    [7,1,5],
    [9,6,2],
    [4,7,1],
    [5,3,1],
    [6,5,7],
    [7,1,9],
    [5,8,10],
    [4,6,3],
    [2,1,3],
    [4,9,5],
    [10,7,8],
    [10,4,9]

];

var elems = ["item_life","item_water","item_shadow","item_void","item_earth","item_fire","item_light","item_air","item_ice","item_energy"];

var items = [
    "item_air_void_water",
    "item_air_life_void",
    "item_ice_fire_earth",
    "item_energy_shadow_water",
    "item_air_fire_light",
    "item_fire_earth_water",
    "item_light_water_void",
    "item_energy_life_fire",
    "item_air_earth_shadow",
    "item_air_fire_life",
    "item_ice_air_water",
    "item_energy_earth_water",
    "item_void_shadow_water",
    "item_shadow_energy_light",
    "item_energy_fire_void",
    "item_shadow_light_ice",
    "item_ice_life_energy",
    "item_ice_shadow_air",
    "item_light_life_earth",
    "item_water_ice_fire",
    "item_void_light_life",
    "item_earth_shadow_life",
    "item_light_fire_earth",
    "item_light_life_ice",
    "item_air_earth_energy",
    "item_void_fire_shadow",
    "item_water_life_shadow",
    "item_void_ice_earth",
    "item_energy_light_air",
    "item_energy_void_ice"
    ];


function Yes()
{
    //$.Msg();
    if  ( $("#ShopInfo").visible == true){   $("#ShopInfo").visible = false;         }
    else{ $("#ShopInfo").visible = true;
            if ($("#ShopInfo").BHasClass("ShopInfoAnim"))
                {
                 $("#ShopInfo").RemoveClass("ShopInfoAnim");
                 $("#ShopInfo").AddClass("ShopInfoAnim");    }

        //GameEvents.SendCustomGameEventToServer( "Levels", { id: Players.GetLocalPlayer()} );
        }
    $("#readytext").RemoveClass("ElementShopText");//移除闪烁特效
    $("#ElementShop").RemoveClass("ElementShopText");//移除闪烁特效
}

function Buy(myint)
{
    //$.Msg( "Buy ", $("#myitem1").itemname);
    GameEvents.SendCustomGameEventToServer( "Buy_Element", { id: Players.GetLocalPlayer(),num:myint} );
}

var x3mode = false;
function ToggleX3mode()
{
    if (  x3mode == true)
        { x3mode = false
        $("#ToggleX3mode").RemoveClass("selectedfilter");
        }
    else{ x3mode = true
        $("#ToggleX3mode").AddClass("selectedfilter");
        }
    UpdateShop( "Elements_Tabel", Players.GetLocalPlayer(), CustomNetTables.GetTableValue( "Elements_Tabel", Players.GetLocalPlayer() ) );
}

function UpdateShop( table_name, key, data )
{
    var ID = Players.GetLocalPlayer();
	//$.Msg( ID, ": ", "Table ", table_name, " changed: '", key, "' = ", data );
    if (ID == key)
    {
        //更新顶部剩余个数
        for (var i = 1; i <= 10;i++)
            { $("#btntop"+(i-1)).RemoveClass("offcraft");
            if (data[i] == 0) {  $("#btntop"+(i-1)).AddClass("offcraft");  }
            if (data[i] != null) {  $("#lvlmyitemtext"+i).text = "x "+data[i];  }        }

        for (var y = 1; y <= 30;y++)
            {
            $("#craft"+y).RemoveClass("offcraft");//移除灰色
            for (var i = 0; i <= 2;i++)
            {
                if (x3mode == true) {//打开X3状态下，余量小于3就会添加灰色
                    if (data[crafts[y-1][i]] < 3)
                    {
                        $("#craft"+y).AddClass("offcraft");
                        break;
                    }
                }
                else{//不是X3状态下，余量等于0就会添加灰色
                    if (data[crafts[y-1][i]] == 0)
                    {
                        $("#craft"+y).AddClass("offcraft");
                        break;
                    }

                }
            }
        }
    }
}

(function()//立即执行的函数
{
    CustomNetTables.SubscribeNetTableListener( "Elements_Tabel", UpdateShop );

    $("#ShopInfo").visible = false;
    for (var i = 1; i <= 30;i++)
    {
        var mtop = 10+50*(i-1)-500*Math.floor((i-1)/10);//与顶部距离。
        var mleft = 15+300*Math.floor((i-1)/10);
        $("#ShopInfo").BCreateChildren("<Panel hittest='false' id='craft"+i+"'/>");//创建一个子面板
        $("#craft"+i).BCreateChildren("<DOTAItemImage class='shopitem' itemname='"+elems[crafts[i-1][0]-1]+"' style='margin-top:"+mtop+"px; margin-left:"+mleft+"px;' onactivate='Buy("+crafts[i-1][0]+")'/>");
        $("#craft"+i).BCreateChildren("<DOTAItemImage class='shopitem' itemname='"+elems[crafts[i-1][1]-1]+"' style='margin-top:"+mtop+"px; margin-left:"+(mleft+62)+"px;' onactivate='Buy("+crafts[i-1][1]+")'/>");
        $("#craft"+i).BCreateChildren("<DOTAItemImage class='shopitem' itemname='"+elems[crafts[i-1][2]-1]+"' style='margin-top:"+mtop+"px; margin-left:"+(mleft+124)+"px;' onactivate='Buy("+crafts[i-1][2]+")'/>");
        $("#craft"+i).BCreateChildren("<Label text='→' style='font-size:32px; color:#fff;margin-top:"+(mtop-7)+"px; margin-left:"+(mleft+186)+"px;'/>");
        $("#craft"+i).BCreateChildren("<DOTAItemImage class='shopitem' itemname='"+items[i-1]+"' style='margin-top:"+mtop+"px; margin-left:"+(mleft+220)+"px;'/>");
    }
    UpdateShop( "Elements_Tabel", Players.GetLocalPlayer(), CustomNetTables.GetTableValue( "Elements_Tabel", Players.GetLocalPlayer() ) )
})();
/**点击关闭难度选择面板**/
function onBtnClick(){
	var value="Mode1"
	for(var i=1;i<5;i++){/**循环1-4，把没有隐藏的难度说明都隐藏**/
		if ($( "#ModeInfo" + i ).style["visibility"]=="visible" )
		{
			value="Mode"+i
			break
		}
	}
   $("#psd").visible = false;
   $("#UIstartmain").visible = false;

	//$("#psd").ToggleClass("Hidden")
	GameEvents.SendCustomGameEventToServer( "player_get_ready", {value} );/**把选项传回服务器**/
}

/**点击难度显示相应难度说明**/
function OpenInfo( keys ){/**传回的参数当作难度编号**/
	$.Msg("input keys=" + keys );
	for(var i=1;i<5;i++){/**循环1-4，把没有隐藏的难度说明都隐藏**/
		if ($( "#ModeInfo" + i ).style["visibility"]!="collapse" )
		{
			$( "#ModeInfo" + i ).style["visibility"]="collapse"
		}
	}
	$( "#ModeInfo" + keys ).style["visibility"]="visible"/**显示被选择的难度说明**/


	
	GameEvents.SendCustomGameEventToServer( "player_get_mode", {keys} );/**把选择的难度发给服务器**/
}

function OnSteamIds(myids)
{
    // $.Msg("xxxxx.."+i+".."+myids[i]["2"]);
    for (i=0;i<3;i++){for (j in myids)
   		{
        if ($("#ava"+i+j) != null)    {   $("#ava"+i+j).steamid = myids[j]["1"];  }//如果有这个板子，就给他设置对应的steamid
    	}
    }
}

function voted(data){

	var ids=data["1"];//玩家ID
	var keys=data["2"]-1;//在OpenInfo中传给服务器的难度
	$.Msg("kkkkk who pointed the selected"+ids);
	$.Msg("kkkkk which is his selected"+keys);
	for (i=0;i<3;i ++){
	//	if($("#spl"+i).GetChildCount() != 0 ){
	//		$("#cds"+ids). RemoveAndDeleteChildren();
	$("#ava"+i+ids).visible = false;
	//	}
	}
	$("#ava"+keys+ids).visible = true;
	//$("#spl"+keys).RemoveAndDeleteChildren("#ava"+ids);
	//$("#spl"+keys).BCreateChildren("<Panel id='cds"+ids+"' />");
	//$("#cds"+ids).BCreateChildren("<DOTAAvatarImage id='ava"+ids+"' steamid=' ' style='height:30px;width:30px;border-radius: 100%;   border: 1px solid #eeeeee;'/>");
	//$("#ava"+ids).SetParent()=$("#spl"+keys);

}

(function()	{
	GameEvents.Subscribe( "nandu_xuanze", voted)//监听别人选了什么难度选项
    GameEvents.Subscribe( "SteamIds", OnSteamIds);//监听NeedsteamID的回调
 	//$("#mode0").checked()=true;
    //GameEvents.SendCustomGameEventToServer( "Updatenandu", {id:Players.GetLocalPlayer()} );
    for (i=0;i<3;i++){for (j=0;j<10;j++){
    	$("#spl"+i).BCreateChildren("<DOTAAvatarImage id='ava"+i+j+"' steamid=' ' class='userhead'/>");
    	$("#ava"+i+j).visible = false;
    	}
    }
   //$("#psd").visible = false;
   //$("#UIstartmain").visible = true;

})();
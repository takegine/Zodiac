"use strict";

function GetRandomInt( min, max )
{
	return Math.floor( Math.random() * ( max - min + 1 ) ) + min;
}

var ShowAbilityTooltip = ( function( ability )
{
	return function()
	{
		$.DispatchEvent( "DOTAShowAbilityTooltip", ability, ability.abilityname );
	}
});

var HideAbilityTooltip = ( function( ability )
{
	return function()
	{
		$.DispatchEvent( "DOTAHideAbilityTooltip", ability );
	}
});


function ShowItemTooltip (itemImage) {
    $.DispatchEvent("DOTAShowAbilityTooltip",itemImage,itemImage.itemname)
}

function HideItemTooltip (itemImage) {
     $.DispatchEvent("DOTAHideAbilityTooltip",itemImage);
}

function FormatSeconds(value) {  //将秒数转为时分秒
    var theTime = parseInt(value);// 秒
    var theTime1 = 0;// 分
    var theTime2 = 0;// 小时
    if(theTime > 60) {
        theTime1 = parseInt(theTime/60);
        theTime = parseInt(theTime%60);
            if(theTime1 > 60) {
            theTime2 = parseInt(theTime1/60);
            theTime1 = parseInt(theTime1%60);
            }
    }
        var result = ""+parseInt(theTime)+"\"";
        if(theTime1 > 0) {
           result = ""+parseInt(theTime1)+"\'"+result;
        }
        if(theTime2 > 0) {
          result = ""+parseInt(theTime2)+":"+result;
        }
    return result;
}

function ConvertToSteamid64(steamid32)  //32位转64位
{
    var steamid64 = '765' + (parseInt(steamid32) + 61197960265728).toString();
    return steamid64;
}

function ConvertToSteamId32(steamid64) {   //64位转32位
    return steamid64.substr(3) - 61197960265728;
}
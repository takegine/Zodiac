

function OpenProfile(){
	$.Msg("OpenProfile")
	var parentPanel = $.GetContextPanel(); // 当前XML上下文的根面板
	var newChildPanel = $.CreatePanel( "Panel", parentPanel, "#profile" );
	newChildPanel.BLoadLayout( "file://{resources}/layout/custom_game/profile.xml", false, false );
  }



function OpenNewPanel( str ){
	$.Msg("print..." + "#PMenu" + str)
	if ($( "#PMenu" + str ).style["visibility"]!="visible" )
		{
			$( "#PMenu" + str ).style["visibility"]="visible"
		}
	
	else if ($( "#PMenu" + str ).style["visibility"]=="visible" )
		{
			$( "#PMenu" + str ).style["visibility"]="collapse"
		}
}
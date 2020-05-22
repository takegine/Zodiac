function EarthlyBranches:OnPlayerConnectFull(keys){
	print("all player connect")
}

function EarthlyBranches:OnEntitykilled(event){--单位死亡

	local killedUnit = EntIndexToHScript(event.entindex_killed)
	RollDorps(killedUnit)--随机掉落
}

function EarthlyBranches:OnNpcSpawned(event){--单位新生
	
	local killedUnit = EntIndexToHScript(event.entindex)
	--叠加if条件，保证只有开局响应一次。
	if Unit.Inited == nil then
		UnitAbilityLevelset(unit)
		local teamid = Unit:getTeam()
		if teamid == 3 then
			local playerid = unit.GetPlayerID()
			--CameraRotateHorizontal(playerid,180)--转动摄像头180°
			CustomUI:DynamicHud_Create(-1,"UIbutton1","file://{resources}/layout/custom_game/uimian.xml",nil)
			print ("调转相机响应")
		end

		Unit.Inited = ture
	end
end

}

function EarthlyBranches:_RegisterCustomGameEventListeners(){
	CustomUI:DynamicHud_Create(-1,"UIbutton1","file://{resources}/layout/custom_game/uimian.xml",nil)
}--无效
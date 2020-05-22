
tablebb={}
function EndTouchAll( data )
	print ("PlayerVoted...EndTouchAll.")
	if data.IsPlayer then
		table.insert(tablebb,data.GetHealth)
		table.insert(tablebb,1)
	end
	DeepPrintTable(tablebb)

print( "-------------------------------------------------------------" )

end

function OnTrigger( data )
	print ("PlayerVoted...OnTrigger.")
	if data.IsPlayer then
		table.insert(tablebb,data.GetHealth)
		table.insert(tablebb,1)
	end
	DeepPrintTable(tablebb)
print( "-------------------------------------------------------------" )

end

function OnStartTouch( data )
	print ("PlayerVoted..OnStartTouch..")
	if data.IsPlayer then
		table.insert(tablebb,data.GetHealth)
		table.insert(tablebb,1)
	end
	DeepPrintTable(tablebb)
print( "-------------------------------------------------------------" )

end

function OnTouching( data )
	print ("PlayerVoted..OnTouching..")
	if data.IsPlayer then
		table.insert(tablebb,data.GetHealth)
		table.insert(tablebb,1)
	end
	DeepPrintTable(tablebb)

print( "-------------------------------------------------------------" )

end

function OnNotTouching( data )
	print ("PlayerVoted..OnNotTouching..")
	if data.IsPlayer then
		table.insert(tablebb,data.GetHealth)
		table.insert(tablebb,1)
	end
	DeepPrintTable(tablebb)
print( "-------------------------------------------------------------" )

end

function PlayerReady( data )
	print ("PlayerVoted..PlayerReady..")
	if data.IsPlayer then
		table.insert(tablebb,data.GetHealth)
		table.insert(tablebb,1)
	end
	DeepPrintTable(tablebb)
print( "-------------------------------------------------------------" )

end

function NotReady( data )
	print ("PlayerVoted..NotReady..")
	if data.IsPlayer then
		table.insert(tablebb,data.GetHealth)
		table.insert(tablebb,1)
	end
	DeepPrintTable(tablebb)
print( "-------------------------------------------------------------" )

end

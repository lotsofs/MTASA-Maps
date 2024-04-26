
------------------
-- Main
--------------------
function start(newstate,oldstate) --function to update the race states
	if (newstate == "GridCountdown") then --when the race countdown starts, load all the obstacles
		createPath()
		local finish = getElementByID("finish")
		local x,y,z = getElementPosition(finish)
		local col1 = createColCircle(570.5,-2432.2,16)
		addEventHandler("onColShapeHit",col1,preventFinish)
	end
end
addEvent ( "onRaceStateChanging", true )
addEventHandler ( "onRaceStateChanging", getRootElement(), start )

function skin ( thePlayer, seat, jacked )
    setElementModel(thePlayer,1)
end
addEventHandler ( "onVehicleEnter", getRootElement(), skin )

------------------------
-- Obstacle 2: fallthrough tiles
------------------------
function createPath()
	local options = {-1,1}
	local path = {{},{},{},{},{},{},{},{},{},{}}
	local a=1
	local b=math.random(1,10) 
	path[a][b] = true
	
	repeat
		if math.random() < 0.5 then
			a=a+options[math.random(1,2)]
		else
			b=b+options[math.random(1,2)]
		end
		if (b>10) or (b<1) or (a<1) or (path[a][b]) then --conditions to reset
			if not attempts then attempts = 0 end
			attempts = attempts+1
			createPath()
			return
		else
			path[a][b]=true
		end
	until (a==10)
	--outputChatBox(attempts)
	
	
	-- -- create the physical tiles
	-- -- x direction = +9
	-- -- y direction = -9
	local tiles = {{},{},{},{},{},{},{},{},{},{}}
	local x,y,z = 550,-2540,133.3 --starting position of (1,1)
	for i=1,10 do
		for j=1,10 do
			local x,y,z = x+(j-1)*9,y+(i-1)*9,z
			tiles[i][j]= createObject(3095,x,y,z) --create tiles & neon squares
			local neon = createObject(9126,x,y,z-1.19,90,0,0)
			setObjectScale(neon,0.5)
			
			if not path[i][j] then
				setElementCollisionsEnabled(tiles[i][j],false) --disable collisions on tiles that are not on the correct path
			end
		end
	end
	triggerClientEvent("drawTiles",getResourceRootElement(),path,tiles) --send the path and the tiles to clientside
end


function preventFinish(theElement)
	if getElementType(theElement) == "vehicle" then
		if (getElementModel(theElement)==462) then
			local x,y,z = getElementPosition(theElement)
			if z < 133 then
				blowVehicle(theElement)
			end
		else
			blowVehicle(theElement)
		end
	end
end


function modelChange(oldModel, newModel)
    if ( getElementType(source) == "vehicle" ) then -- Make sure the element is a vehicle
		local player = getVehicleOccupant(source)
		if player then
			if newModel == 539 then
				triggerClientEvent(player,"floatPath",player)
			else
				triggerClientEvent(player,"restorePath",player)
			end
		end
    end
end
addEventHandler("onElementModelChange", root, modelChange) -- Bind the event to every element

function player_Spawn ( posX, posY, posZ, spawnRotation, theTeam, theSkin, theInterior, theDimension )
	triggerClientEvent(source,"restorePath",source)
end
addEventHandler ( "onPlayerSpawn", getRootElement(), player_Spawn )


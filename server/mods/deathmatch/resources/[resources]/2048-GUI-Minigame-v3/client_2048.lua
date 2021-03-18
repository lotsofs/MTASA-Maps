-- 2048 in MTA by Ali Digitali
-- the original game can be found at: http://gabrielecirulli.github.io/2048/
-- anyone reading this has permission to copy parts of this script

--------------------
--	GUI FUNCTIONS --
--------------------

GUIEditor = {
    button = {},
    window = {},
    label = {},
    edit = {},
	staticimage = {}
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
		-- main window
		GUIEditor.window[1] = guiCreateWindow(373, 136, 510, 600, "2048", false)
        guiWindowSetSizable(GUIEditor.window[1], false)
        guiWindowSetMovable (GUIEditor.window[1], true )
        guiSetAlpha(GUIEditor.window[1], 0.90)
		
		-- buttons
		newGameButton = guiCreateButton(14, 535, 100, 25, "New Game", false, GUIEditor.window[1])
        guiSetProperty(newGameButton, "NormalTextColour", "FFAAAAAA")
		
		closeButton = guiCreateButton(14, 565, 100, 25, "Close", false, GUIEditor.window[1])
		
		-- labels
		controlLabel = guiCreateLabel(145, 535, 300, 50, "Controls:", false, GUIEditor.window[1])
		controlLabel2= guiCreateLabel(145, 555, 300, 50, "Arrow keys, OR", false, GUIEditor.window[1])
		controlLabel3= guiCreateLabel(145, 570, 300, 50, "WASD", false, GUIEditor.window[1])

		scoreLabel = guiCreateLabel(260, 535, 1000, 50, "Score: 0", false, GUIEditor.window[1])
		tipLabel = guiCreateLabel(260, 555, 300, 50, "Tip: use '/bind [key] down 2048' to bind", false, GUIEditor.window[1])
		tipLabel2= guiCreateLabel(260, 570, 300, 50, "opening and closing this window to a key!", false, GUIEditor.window[1])
		
		gameState = guiCreateLabel(100, 250, 400, 200, "", false, GUIEditor.window[1])
		guiSetProperty(gameState,"AlwaysOnTop","true")
		guiSetFont(gameState,"sa-gothic")
		
        -- background image
		background = guiCreateStaticImage(5, 25, 500, 500, "images/background.png", false, GUIEditor.window[1])    
		
		-- create a grid with empty squares
		gridImage = {{},{},{},{}} -- one grid that contains all the images of the numbers
		grid = {[0]={},[1]={},[2]={},[3]={},[4]={},[5]={}} -- and a grid that contains actual numbers for calculations
		
		-- load the images onto the grid
		for i=1,4 do
			for j=1,4 do
				grid[i][j] = 0
			end
		end
		
		-- button events
		addEventHandler("onClientGUIClick", newGameButton, newGame, false)
		addEventHandler("onClientGUIClick", closeButton, closeWindow, false)
		
		-- start a new game
		newGame()
	
		-- hide the window
		guiSetVisible(GUIEditor.window[1], false)
		
		-- bind the keys for moving the tiles
		allowMoves = true
		bindKey("arrow_u","down",inputHandler,0,-1) --up
		bindKey("arrow_d","down",inputHandler,0,1)	--down
		bindKey("arrow_l","down",inputHandler,-1,0)	--left
		bindKey("arrow_r","down",inputHandler,1,0) 	--right

		bindKey("w","down",inputHandler,0,-1) --up
		bindKey("s","down",inputHandler,0,1)	--down
		bindKey("a","down",inputHandler,-1,0)	--left
		bindKey("d","down",inputHandler,1,0) 	--right
		
    end
)

-- close the gui window
function closeWindow()
	setElementData(localPlayer,"2048_active",false,true)
	guiSetVisible(GUIEditor.window[1], false)
	showCursor(false)
end

-- open/close the gui window
function showPollGuiHandler()
	if (guiGetVisible(GUIEditor.window[1])) then -- if the window is visible
		closeWindow() --close
	else
		guiSetVisible(GUIEditor.window[1], true) --else show the window
		setElementData(localPlayer,"2048_active",true,true)
		showCursor(true)
	end
end
addCommandHandler ("2048", showPollGuiHandler )

-------------------------
--	Gameplay Functions --
-------------------------

function updateGrid(action,i,j,tileNumber,iOld,jOld) -- update the grid on index i,j with tileNumber
	if (isElement(gridImage[i][j])) then
		guiSetAlpha(gridImage[i][j],1)
	end
	if tileNumber then
		grid[i][j]= tileNumber -- update the mathematical grid
	end
	
	local xoffset = 14 + 119*(j-1)
	local yoffset = 16 + 121*(i-1)
		
	if (action == "new") then
		gridImage[i][j] = guiCreateStaticImage(xoffset, yoffset, 107, 107, "images/"..tostring(tileNumber)..".png", false, background)
		
		-- make the new tile fade in
		local alpha = 0
		guiSetProperty(gridImage[i][j],"Alpha",alpha)
		setTimer(function()
			alpha = alpha+0.25
			if isElement(gridImage[i][j]) then
				guiSetAlpha(gridImage[i][j],alpha)
			end
		end,50,4)
	
		return
	end
	
	local xoffsetOld = 14 + 119*(jOld-1)
	local yoffsetOld = 16 + 121*(iOld-1)
	
	
	if (action == "move") then
		grid[iOld][jOld] = 0 -- remove the old tile
		
		-- create a new image at the old tile, but have it indexed at the new tile
		gridImage[i][j] = gridImage[iOld][jOld]
		
		-- move the tile to the new position
		guiAddInterpolateEffect(gridImage[i][j],xoffsetOld, yoffsetOld,xoffset, yoffset, 100)
		return
	end
	
	if (action == "merge") then
		local newValue = grid[i][j]+grid[iOld][jOld]
		
		if (newValue == 2048) then -- if you merge into 2048 you win
			guiLabelSetColor(gameState,0,255,0)
			guiSetText(gameState,"You Win!")
			triggerServerEvent ( "on2048win", localPlayer) 
		elseif (newValue > 2048) then -- do not merge to tiles over 2048, because there are no images of those values and it will show white.
			return false
		end
			
		if (newValue > maxTile) then
			maxTile = newValue
			setElementData(localPlayer,"2048_max",maxTile,true)
		end


		-- updating mathematical grid:
		grid[iOld][jOld] = 0 
		grid[i][j] = newValue
		
		-- animations:
		guiAddInterpolateEffect(gridImage[iOld][jOld],xoffsetOld, yoffsetOld,xoffset, yoffset, 100)

		local newGridImage = gridImage[i][j]
		local oldGridImage = gridImage[iOld][jOld]
		setTimer(function()
			destroyElement(oldGridImage)
			guiStaticImageLoadImage(gridImage[i][j],"images/"..tostring(newValue)..".png")
		end,100,1)
		
		g_score = g_score + newValue
		guiSetProperty(scoreLabel,"Text","Score: "..g_score)
		setElementData(localPlayer,"2048_score",g_score,true)
	
		return true
	end	
end

function clearGrid() -- clears the grid
	for i=1,4 do
		for j=1,4 do
			grid[i][j] = 0
			if isElement(gridImage[i][j]) then
				destroyElement(gridImage[i][j])
			end
		end
	end
end

function newGame() -- clear the grid and place random tiles on the board
	clearGrid()
	g_score = 0
	setElementData(localPlayer,"2048_score",0,true)
	maxTile = 2
	setElementData(localPlayer,"2048_max",2,true)
	guiSetProperty(scoreLabel, "Text","Score: 0")
	guiSetText(gameState,"")
	for a=1,2 do
		addRandomTile()
	end
end

-- returns all the indices of empty tiles in table form
function getEmptyTiles()
	local emptyTiles = {}
	for i=1,4 do
		for j=1,4 do
			if (grid[i][j] == 0) then
				table.insert(emptyTiles,{i,j})
			end
		end
	end
	if not emptyTiles then
		return false
	else
		return emptyTiles
	end
end

-- returns the indices of a random tile that is free,how many tiles are still empty, if there are no free tiles returns false
function getRandomFreeTile()
	local emptyTiles = getEmptyTiles()
	if not emptyTiles then
		return false
	end
	
	local randomTile = emptyTiles[math.random(#emptyTiles)]
	return randomTile[1],randomTile[2],#emptyTiles
end

function addRandomTile()
	local i,j,emptyTilesLeft = getRandomFreeTile()
	local newTileValue 
	
	if (math.random() < 0.9) then
		newTileValue = 2
	else
		newTileValue = 4
	end
	
	updateGrid("new",i,j,newTileValue)
	
	if emptyTilesLeft < 2 then 	-- if the grid had one or less open tiles it has now become full
		-- if one of these returns true it means that there are available moves
		local checkUp = moveTiles(0,-1,true)
		local checkDown = moveTiles(0,1,true)
		local checkLeft = moveTiles(-1,0,true)
		local checkRight = moveTiles(1,0,true)
		
		if not (checkUp or checkDown or checkLeft or checkRight) then -- if none return true you cannot make any moves and the game is over
			guiLabelSetColor(gameState,255,0,0)
			guiSetText(gameState,"Game Over!")
		end
	end
end

function inputHandler(key,keystate,x,y)
	if (guiGetVisible(GUIEditor.window[1])) and (allowMoves) then -- only move tiles if the window is visible
		moveTiles(x,y)
	end
end

function moveTiles(x,y,checkMoves) 
	
	if not checkMoves then -- if checkmoves is given and true, this function checks if a move is possible without acutally making a move
		checkmoves = false
	end
	
	local hasGridMoved = false
	
	if (y==0) then -- left of right movement
		for i=1,4 do-- check the rows first
			for j=(2.5-0.5*x)+x,(2.5-0.5*x)-x,-x do-- move along the coloms, starting at the edge. If you move left, start on the left side, if you move right start on the right side
				if (grid[i][j]~= 0) then  -- check to see if the grid is occupied
					local b = j
					repeat
						b = b+x
					until (grid[i][b] ~= 0)
					
					if (grid[i][b]==grid[i][j]) then -- if the tile on the found blockage is the same
						if checkMoves then
							return true -- return true for checking moves because this tile can be merged
						end
						hasGridMoved = updateGrid("merge",i,b,false,i,j)
					elseif not((b-x)==j) then -- else if the tile is not itself move it
						if checkMoves then
							return true
						end
						updateGrid("move",i,b-x,grid[i][j],i,j) -- move the tile to the found position
						hasGridMoved = true
					end
				end
			end
		end
		
	elseif (x==0) then -- up or down
		for j=1,4 do-- coloms
			for i=(2.5-0.5*y)+y,(2.5-0.5*y)-y,-y do -- rows
				if (grid[i][j]~= 0) then  -- check to see if the grid is occupied
					local a = i
					repeat
						a = a+y
					until (grid[a][j] ~= 0)
					
					if (grid[a][j]==grid[i][j]) then
						if checkMoves then
							return true
						end
						hasGridMoved = updateGrid("merge",a,j,false,i,j)
					elseif not ((a-y)==i) then -- set a space to zero if it has moved
						if checkMoves then
							return true
						end
						updateGrid("move",a-y,j,grid[i][j],i,j)
						hasGridMoved = true
					end
				end
			end
		end
	end
	if checkmoves then
		return false
	end
	
	if hasGridMoved then -- add a random tile if a move has been made
		addRandomTile()
		allowMoves = false
		setTimer(function()
			allowMoves = true
		end,100,1)
		
		-- -- Debug
		-- outputChatBox("Grid Moved and is now: ")
		-- for i=1,4 do
			-- outputChatBox(grid[i][1].." "..grid[i][2].." "..grid[i][3].." "..grid[i][4])
		-- end
	end
end

-------------
-- Animations
-------------

local active_gui_elements = {}
function isGUIElementActive( window )
	if not window then
		return false
	end
	if active_gui_elements[window] then
		return true
	end
	return false
end

function isGUIElement( element )
	if isElement( element ) then
		if getElementType( element ):find( "gui-" ) then
			return true
		end
	end
	return false
end

function interpolate( gui_element )
	if not isGUIElementActive( gui_element ) then
		return false
	end
	
	local tick = getTickCount( )
	local timePassed = tick - active_gui_elements[gui_element].startTime
	local difference = active_gui_elements[gui_element].endTime - active_gui_elements[gui_element].startTime
	local progress = timePassed / difference
	
	local x, y = interpolateBetween(
		active_gui_elements[gui_element].startPosition[1], active_gui_elements[gui_element].startPosition[2], 0,
		active_gui_elements[gui_element].endPosition[1], active_gui_elements[gui_element].endPosition[2], 0,
		progress, active_gui_elements[gui_element].easingTypes[1] )
	
	if (isElement(gui_element)) then
		guiSetPosition( gui_element, x, y, false )
	end
		
	if tick >= active_gui_elements[gui_element].endTime then
		removeEventHandler( "onClientRender", root, active_gui_elements[gui_element].func )
		active_gui_elements[gui_element] = nil
		return true
	end
	return false
end

function guiAddInterpolateEffect( gui_element, startX, startY, endX, endY, progressTime)
	coordinates = 
	{
		startX, startY, startW, startH, endX, endY, endW, endH
	}	
	active_gui_elements[gui_element] = {}
	active_gui_elements[gui_element].startTime = getTickCount( )
	active_gui_elements[gui_element].endTime = active_gui_elements[gui_element].startTime + ( progressTime)
	active_gui_elements[gui_element].startPosition = {startX, startY}
	active_gui_elements[gui_element].endPosition   = {endX, endY}
	active_gui_elements[gui_element].easingTypes = {"InOutQuad",""}
	
	active_gui_elements[gui_element].func = function( )
		interpolate( gui_element )
	end
	addEventHandler( "onClientRender", root, active_gui_elements[gui_element].func )
	return true
end
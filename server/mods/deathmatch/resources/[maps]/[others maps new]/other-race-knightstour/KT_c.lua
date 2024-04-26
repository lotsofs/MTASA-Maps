

----------------
-- Obstacle 2: fallout tiles
----------------
--setDevelopmentMode(true)
function drawTilesHandler(path,tiles)
	
	-- ---------
	-- --Displaying Path
	-- ---------
	-- local display = getElementByID("display") --display tower
	-- local d_x,d_y,d_z = getElementPosition(display)
	-- local xoffset = 3.5 --offsets of the tower to the corner of the black display area
	-- local yoffset = 6
	-- local zoffset = 7.3
	
	-- -- position offsets
	-- ywidth = yoffset*2/5 --globally defined because its needed in the dxdraw functions
	-- local zwidth = zoffset*2/5
	-- local ystart = d_y + 2*ywidth
	-- local zstart = d_z - 2.5*zwidth
	
	----------
	--Active Pathing
	----------
	g_tiles = tiles
	g_path = path
	render = {}
	colRects = {}
	activeCol = {}
	local a = 1
	local x,y,z = getElementPosition(tiles[1][1]) -- starting posistion for colshape (1,1)
	for i=1,10 do --loop through all the tiles
		for j=1,10 do

			--put all of the coordinates for the drawn squares of the path display in a table
			-- render[a]={path[i][j],d_x-xoffset,ystart-(j-1)*ywidth,zstart+0.1+(i-1)*zwidth,d_x-xoffset,ystart-(j-1)*ywidth,zstart-0.1+i*zwidth}
			-- a=a+1
			
			-- create collision recrangles to keep track of player movement
			local xCol,yCol = (x-4.5)+(j-1)*9,(y-4.5)+(i-1)*9
			local col = createColRectangle(xCol,yCol,9,9)
			
			-- create the start and end coordinates of the squares drawn when hitting a colshpape (squares when driving)
			colRects[col]={path[i][j],xCol+2,yCol+4.5,z+0.59,xCol+7,yCol+4.5,z+0.59}
		end
	end
	addEventHandler("onClientRender",root,drawSquares) --draw the squares every frame
end
addEvent("drawTiles",true)
addEventHandler("drawTiles",getResourceRootElement(),drawTilesHandler)


local red = dxCreateTexture("red.png")
local green = dxCreateTexture("green.png")
function drawSquares() --draw the display squares and active path squares
	-- display
	-- for i=1,100 do
		-- local color,startX,startY,startZ,endX,endY,endZ = unpack(render[i])
		-- if color then
			-- dxDrawMaterialLine3D(startX,startY,startZ,endX,endY,endZ,green,ywidth-0.2,tocolor(0,255,0,255),startX+1,startY,startZ)
		-- else
			-- dxDrawMaterialLine3D(startX,startY,startZ,endX,endY,endZ,red,ywidth-0.2,tocolor(255,255,255,255),startX+1,startY,startZ)
		-- end
	-- end

	-- active path
	for index,theCol in pairs (activeCol) do
		local color,startX,startY,startZ,endX,endY,endZ = unpack(theCol)
		if color then
			dxDrawMaterialLine3D(startX,startY,startZ,endX,endY,endZ,green,6,tocolor(0,255,0,255),startX,startY,startZ-1)
		else
			dxDrawMaterialLine3D(startX,startY,startZ,endX,endY,endZ,red,6,tocolor(255,255,255,255),startX,startY,startZ-1)
		end
	end
end

-- add a square to the active path display when the coresponding colshape is hit
function onClientColShapeHit(theElement)
	if (getElementType(theElement) == "vehicle") then  -- Checks whether the entering element is the local player
		local ped = getVehicleOccupant(theElement)
		if ped then
			if (getElementType(ped) == "player") and (getElementModel(theElement)==462) then
				local x,y,z = getElementPosition(theElement)
				if (z>133) and (z<140) then
					if colRects[source] then --if the collshape that is hit coresponds to a tile
						table.insert(activeCol,colRects[source])
						destroyElement(source)
					end
				end
			end
		end
    end
end
addEventHandler("onClientColShapeHit",getRootElement(),onClientColShapeHit)


-- function fly ()
	-- local veh = getPedOccupiedVehicle(localPlayer)
	-- if veh then
		-- if getElementModel(veh)== 539 then
			-- local x,y,z = getElementPosition(veh)
			-- setElementPosition(veh,x,y,135)
			-- local _,_,rotz = getElementRotation(veh)
			-- setElementRotation(veh,0,0,rotz)
		-- end
	-- end
-- end
-- addEventHandler ( "onClientPreRender", root, fly )

function restorePath()
	if g_tiles then
		for i=1,10 do
			for j=1,10 do
				if not g_path[i][j] then
					setElementCollisionsEnabled(g_tiles[i][j],false) --disable collisions on tiles that are not on the correct path
				end
			end
		end
	end
end
addEvent("restorePath",true)
addEventHandler("restorePath",root,restorePath)

function floatPath()
	if g_tiles then
		for i=1,10 do
			for j=1,10 do
				setElementCollisionsEnabled(g_tiles[i][j],true) --disable collisions on tiles that are not on the correct path
			end
		end
	end
end
addEvent("floatPath",true)
addEventHandler("floatPath",root,floatPath)
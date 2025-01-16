---
-- Main client file with drawing and calculating.
--
-- @author	driver2
-- @copyright	2009-2010 driver2
--
-- Recent changes:
-- 2010-02-09: Made GUI-key a setting in defaultSettings.lua, added help to radio buttons, replaced "infocenter" with "gamecenter"
-- 2018-02/03: Added optional zoom, added some commands, filter colorcodes from names, some GUI and layout improvements, fixed checkpoint loading/order, updated help, some cleanup
-- 2020-03: Hide when poll is showing

-------------------------
-- Initialize Settings --
-------------------------

local gamecenterResource = false
settingsObject = Settings:new(defaultSettings,"settings.xml")

local function s(setting,settingType)
	return settingsObject:get(setting,settingType)
end

----------------
-- Info Texts --
----------------

local zoomUnavailableInfo = InfoText:new()
zoomUnavailableInfo.displayTime = 4*1000
local zoomOffInfo = InfoText:new()
zoomOffInfo.displayTime = 3*1000
local keyInfo = InfoText:new()
local zoomSectionInfo = InfoText:new()

---------------
-- Variables --
---------------

local screenWidth,screenHeight = guiGetScreenSize()
local x = nil
local y = nil
local h = nil
local readyToDraw = false
local mapLoaded = false
local screenFadedOut = false
local showingPoll = false
local updateIntervall = 1000
-- The distance the zoomed-in section covers (taken from the settings, or map length if shorter)
local g_zoomDistance = 500
-- The height of the zoomed-in section, in pixels (depending on setting)
local g_zoomHeight = 200
-- Whether the zoom is currently enabled (depending on the settings and the map length)
local g_zoomEnabled = true

local g_CheckpointDistance = {}
local g_CheckpointDistanceSum = {}
local g_players = nil
local g_distanceT = 0
local g_distanceB = 0
local g_TotalDistance = 0
local g_recordedDistances = {}
local g_recordedDistancesForReplay = {}
local g_times = {}

-- The maximum name width in pixels of all players
local g_maxNameWidth = 0

---------------
-- Constants --
---------------

local c_fonts = {"default","default-bold","clear","arial","sans","pricedown","bankgothic","diploma","beckett"}

-- The gap between bar sections (zoom)
local c_gap = 6
-- How much the zoomed-in section has to be zoomed for the zoom to be enabled
local c_minZoomFactor = 1.5

------------
-- Events --
------------

function initiate()
	-- setAllowOnce() first, so it already works when loading map and preparing to draw
	zoomSectionInfo:setAllowOnce()
	keyInfo:setAllowOnce()

	settingsObject:loadFromXml()
	mapStarted()
	sendMessageToServer("loaded")
end
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),initiate)

function mapStarted()
	-- Start under the assumption that no checkpoints are found,
	-- so not ready to draw (also the new data hasn't been loaded
	-- yet)
	readyToDraw = false
	mapLoaded = false
	if loadMap() then
		-- If data was successfully loaded, prepare drawing
		mapLoaded = true
		calculateCheckpointDistance()
		zoomUnavailableInfo:setAllowOnce()
		prepareDraw()
	end
	g_times = {}
	g_delay = {}
	-- TODO: load distances for map
	g_recordedDistancesForReplay = g_recordedDistances
	g_recordedDistances = {}
	g_replayCount = 0
end
addEventHandler("onClientMapStarting",getRootElement(),mapStarted)

-------------------------------
-- Load and prepare map data --
-------------------------------

function loadMap()
	--local res = call(getResourceFromName("mapmanager"),"getRunningGamemodeMap")
	-- Get the data or empty tables, if none of these elements exist
	g_Spawnpoints = getAll("spawnpoint")
	g_Checkpoints = sortCheckpoints(getAll("checkpoint"))
	
	if #g_Spawnpoints > 0 and #g_Checkpoints > 0 then
		return true
	end
	return false
end

function getAll(name)
	local result = {}
	for i,element in ipairs(getElementsByType(name)) do
		result[i] = {}
		result[i].id = getElementID(element)
		result[i].nextid = getElementData(element, "nextid")
		local position = {
					tonumber(getElementData(element,"posX")),
					tonumber(getElementData(element,"posY")),
					tonumber(getElementData(element,"posZ"))
				}
		result[i].position = position
	end
	return result
end

--[[
-- Start with the first checkpoint, then find the first "nextid" for each one. This has
-- to be done since the order of the checkpoints in the file may not be as they are
-- actually connected.
--
-- Checkpoints (except for the first) that aren't referred to by "nextid" are ignored.
--
-- Modifies the argument table.
--
-- @param   table  cps: List of checkpoints, ordered as received from MTA
-- @return  table       Properly ordered list of checkpoints
-- ]]
function sortCheckpoints(cps)
	-- sort checkpoints
	local chains = {}		-- a chain is a list of checkpoints that immediately follow each other
	local prevchainnum, chainnum, nextchainnum
	for i,checkpoint in ipairs(cps) do
		-- any chain we can place this checkpoint after?
		chainnum = table.find(chains, '[last]', 'nextid', checkpoint.id)
		if chainnum then
			table.insert(chains[chainnum], checkpoint)
			if checkpoint.nextid then
				nextchainnum = table.find(chains, 1, 'id', checkpoint.nextid)
				if nextchainnum then
					table.merge(chains[chainnum], chains[nextchainnum])
					table.remove(chains, nextchainnum)
				end
			end
		elseif checkpoint.nextid then
			-- any chain we can place it before?
			chainnum = table.find(chains, 1, 'id', checkpoint.nextid)
			if chainnum then
				table.insert(chains[chainnum], 1, checkpoint)
				prevchainnum = table.find(chains, '[last]', 'nextid', checkpoint.id)
				if prevchainnum then
					table.merge(chains[prevchainnum], chains[chainnum])
					table.remove(chains, chainnum)
				end
			else
				-- new chain
				table.insert(chains, { checkpoint })
			end
		else
			table.insert(chains, { checkpoint })
		end
	end
	return chains[1] or {}
end

--[[
-- Calculate and store race distances based on checkpoint coordinates (as well as one spawnpoint),
-- for later use on calculating player distance progress.
--
-- g_CheckpointDistance: The distance between the previous and the next (index) checkpoint
-- g_CheckpointDistanceSum: The total race distance to the checkpoint (index)
-- g_TotalDistance: The total race distance from start to finish
--
-- ]]
function calculateCheckpointDistance()
	local total = 0
	local cps = {}
	local cpsSum = {}
	-- Simply use the first found spawnpoint
	local pos = g_Spawnpoints[1].position
	local prevX, prevY, prevZ = pos[1],pos[2],pos[3]
	for k,v in ipairs(g_Checkpoints) do
		local pos = v.position
		if prevX ~= nil then
			local distance = getDistanceBetweenPoints3D(pos[1],pos[2],pos[3],prevX,prevY,prevZ)
			total = total + distance
			cps[k] = distance
			cpsSum[k] = total
		end
		prevX = pos[1]
		prevY = pos[2]
		prevZ = pos[3]
	end
	g_CheckpointDistance = cps
	g_CheckpointDistanceSum = cpsSum
	g_TotalDistance = total
end


-----------
-- Times --
-----------

-- SHOULD BE DONE: maybe reset data if player rejoins? maybe check if he already passed that checkpoint


--[[
-- Adds the given time for the player at that checkpoint to the table,
-- as well as displays it, if there is a time at the same checkpoint
-- to compare it with.
--
-- @param   player   player:     The player element
-- @param   int      checkpoint: The checkpoint number
-- @param   int      time:       The number of milliseconds
-- @return  boolean              false if parameters are invalid
-- ]]
function addTime(player,checkpoint,time)
	if player == nil then
		return false
	end
	if g_times[player] == nil  then
		g_times[player] = {}
	end
	g_times[player][checkpoint] = time
	
	if player == getLocalPlayer() then
		-- For players who passed the checkpoint you hit before you	
		for k,v in ipairs(getElementsByType("player")) do
			local prevTime = getTime(v,checkpoint)
			--var_dump("prevTime",prevTime)
			if prevTime then
				local diff = time - prevTime
				g_delay[v] = {diff,getTickCount()}
			end
		end
	else
		-- For players who hit a checkpoint you already passed
		local prevTime = getTime(getLocalPlayer(),checkpoint)
		if prevTime then
			local diff = -(time - prevTime)
			g_delay[player] = {diff,getTickCount()}
		end
	end
end

--[[
-- Gets the time of a player for a certain checkpoint, if it exists
-- and the player has already reached it (as far as race is concerned)
--
-- @param   player   player:     The player element
-- @param   int      checkpoint: The checkpoint number
-- @return  mixed                The number of milliseconds passed for this player
--                               at this checkpoint, or false if it doesn't exist
-- ]]
function getTime(player,checkpoint)
	-- Check if the desired time exists
	if g_times[player] ~= nil and g_times[player][checkpoint] ~= nil then
		-- Check if player has already reached that checkpoint. This prevents
		-- two scenarios from causing wrong times to appear:
		-- 1. When a player is set back to a previous checkpoint when he dies twice
		-- 2. When a player rejoins and the player element remains the same (with the times still being saved
		--    at the other clients)
		local playerHeadingForCp = getElementData(player,"race.checkpoint")
		if type(playerHeadingForCp) == "number" and playerHeadingForCp > checkpoint then
			return g_times[player][checkpoint]
		end
	end
	return false
end

--[[
-- Calculates minutes and seconds from milliseconds
-- and formats the output in the form xx:xx.xx
--
-- Also supports negative numbers, to which it will add a minus-sign (-)
-- before the output, a plus-sign (+) otherwise.
--
-- @param   int     milliseconds: The number of milliseconds you wish to format
-- @return  string                The formated string or an empty string if no parameter was specified
-- ]]
function formatTime(milliseconds)
	if milliseconds == nil then
		return ""
	end
	local prefix = "+"
	if milliseconds < 0 then
		prefix = "-"
		milliseconds = -(milliseconds)
	end
	local minutes = math.floor(milliseconds / 1000 / 60)
	local milliseconds = milliseconds % (1000 * 60)
	local seconds = math.floor(milliseconds / 1000)
	local milliseconds = milliseconds % 1000

	return string.format(prefix.."%i:%02i.%03i",minutes,seconds,milliseconds)
end

-------------------
-- Communication --
-------------------

function serverMessage(message,parameter)
	if message == "update" then
		addTime(parameter[1],parameter[2],parameter[3])
	end
	if message == "times" then
		g_times = parameter
	end
end
addEvent("onClientRaceProgressServerMessage",true)
addEventHandler("onClientRaceProgressServerMessage",getRootElement(),serverMessage)

function sendMessageToServer(message,parameter)
	triggerServerEvent("onRaceProgressClientMessage",getRootElement(),message,parameter)
end

----------------------------
-- Update player position --
----------------------------

function update()
	-- If not checkpoints are present on the current map,
	-- we don't need to do anything.
	if not mapLoaded or not s("enabled") then
		return
	end
	-- Start with an empty table, this way players
	-- won't have to be removed, but simply not added
	local players = {}
	g_localPlayerDistance = nil
	
	-- Go through all current players
	for _,player in ipairs(getElementsByType("player")) do
		if not getElementData(player,"race.finished") then
			local headingForCp = getElementData(player,"race.checkpoint")
			local distanceToCp = distanceFromPlayerToCheckpoint(player,headingForCp)
			if distanceToCp ~= false then
				local playerName = stripColors(getPlayerName(player))
				local distance = calculateDistance(headingForCp,distanceToCp)
				-- Add with numeric index to make shuffling possible
				table.insert(players,{playerName,distance,player})
				
				-- Save Local Player info separately
				if player == getLocalPlayer() then
					g_localPlayerName = playerName
					g_localPlayerDistance = distance
				end
			end
		end
	end

	-- Test players
	--table.insert(players,{"Start",0})
	--table.insert(players,{"Start2",10})
	--table.insert(players,{"a",700})
	--table.insert(players,{"b",1100})	
	--table.insert(players,{"c",1100})
	--table.insert(players,{"d",1100})
	--table.insert(players,{"e",1100})
	--table.insert(players,{"f",1100})
	--table.insert(players,{"g",1100})
	--table.insert(players,{"norby890",32})
	--table.insert(players,{"AdnanKananda",110})
	--table.insert(players,{"Player234",500})
	--table.insert(players,{"Kray-Z",1050})
	--table.insert(players,{"SneakyViper",1100})
	--table.insert(players,{"100", 100})
	--table.insert(players,{"600", 600})
	--table.insert(players,{"1000", 1000})
	--table.insert(players,{"1500", 1500})
	--if g_localPlayerDistance ~= nil then
	--	for i=-10,10,1 do
	--		local d = g_localPlayerDistance + i*73
	--		table.insert(players,{tostring(d), d})
	--	end
	--end

	calculateBarDistances()
	if g_zoomEnabled then
		-- Sort players into the three sections
		local playersT = {}
		local playersM = {}
		local playersB = {}
		for _,values in pairs(players) do
			local dist = values[2]
			if dist > g_distanceT then
				table.insert(playersT, values)
			elseif dist < g_distanceB then
				table.insert(playersB, values)
			else
				table.insert(playersM, values)
			end
		end
		sortPlayers(playersT)
		sortPlayers(playersM)
		sortPlayers(playersB)
		g_players = {playersT, playersM, playersB}
	else
		-- Just put all players into the middle section
		sortPlayers(players)
		g_players = {nil, players, nil}
	end
	
	checkKeyInfo()
end
setTimer(update,updateIntervall,0)

--[[
-- Sort the players, if enabled.
-- ]]
function sortPlayers(players)
	if s("sortMode") == "length" then
		table.sort(players,function(w1,w2) if w1[1]:len() > w2[1]:len() then return true end end)
	elseif s("sortMode") == "shuffle" then
		shuffle(players)
	elseif s("sortMode") == "rank" then
		table.sort(players,function(w1,w2) if w1[2] < w2[2] then return true end end)
	end

	-- Prefer players directly in front and behind you if enabled
	if s("preferNear") and g_localPlayerDistance ~= nil then
		local prevNick = nil
		local playerBefore = nil
		local playerAfter = nil
		local playerBeforeKey = 0
		local playerAfterKey = 0
		for key,table in pairs(players) do
			--outputChatBox(tostring(g_localPlayerDistance))
			if table[2] > g_localPlayerDistance then
				if playerBefore == nil or table[2] < playerBefore[2] then
					playerBefore = table
					playerBeforeKey = key
				end
			end
			if table[2] < g_localPlayerDistance then
				if playerAfter == nil or table[2] > playerAfter[2] then
					playerAfter = table
					playerAfterKey = key
				end
			end
		end
		if playerAfterKey ~= 0 then
			table.insert(players,table.remove(players,playerAfterKey))
			-- Correct the index if needed (because the indices may have shifted,
			-- which would cause the playerBeforeKey not to be correct anymore)
			if playerBeforeKey > 0 then
				playerBeforeKey = playerBeforeKey - 1
			end
		end
		if playerBeforeKey ~= 0 then
			table.insert(players,table.remove(players,playerBeforeKey))
		end
	end
end


-- see: http://en.wikipedia.org/wiki/Fisher-Yates_shuffle


function shuffle(t)
  local n = #t
 
  while n > 2 do
    -- n is now the last pertinent index
    local k = math.random(n) -- 1 <= k <= n
    -- Quick swap
    t[n], t[k] = t[k], t[n]
    n = n - 1
  end
 
  return t
end

--[[
-- Calculate the distance from the given player position to the
-- checkpoint at the given index.
--
-- @param   player  player: The player object
-- @param   number  index:  The checkpoint index
-- @return  number          The distance of the player to the checkpoint
-- ]]
function distanceFromPlayerToCheckpoint(player, index)
	-- TODO: check if the index exists
	local checkpoint = g_Checkpoints[index]
	if checkpoint == nil then
		return false
	end
	local x, y, z = getElementPosition(player)
	return getDistanceBetweenPoints3D(x, y, z, unpack(checkpoint.position))
end

--[[
-- Calculate the total race distance progress, taking into account the current
-- checkpoint and the distance to it.
--
-- @param   number  headingForCp: The index of the checkpoint
-- @param   number  distanceToCp: The distance to the checkpoint
-- @return  number                The total distance, or false if invalid checkpoint
-- ]]
function calculateDistance(headingForCp,distanceToCp)
	local sum = g_CheckpointDistanceSum[headingForCp]
	if sum == nil then
		return false
	end
	local checkpointDistance = g_CheckpointDistance[headingForCp]
	if distanceToCp > checkpointDistance then
		distanceToCp = checkpointDistance
	end
	return sum - distanceToCp
end

--[[
-- Calculate the distances the progress bar sections cover,
-- depending on the current zoom and player progress.
-- ]]
function calculateBarDistances()
	if g_zoomEnabled then
		local z = g_zoomDistance / 2
		local d = g_localPlayerDistance
		if g_localPlayerDistance == nil then
			d = g_TotalDistance
		end
		local distanceB = d - z
		local distanceT = d + z
		if distanceB < 0 then
			distanceT = distanceT - distanceB
			distanceB = 0
		end
		if distanceT > g_TotalDistance then
			distanceB = distanceB - (distanceT - g_TotalDistance)
			distanceT = g_TotalDistance
		end
		if distanceB < 0 then
			distanceB = 0
		end
		g_distanceB = math.ceil(distanceB)
		g_distanceT = math.ceil(distanceT)
	else
		g_distanceB = 0
		g_distanceT = g_TotalDistance
	end
end

-------------
-- Drawing --
-------------

--[[
-- Sets stuff needed for drawing that only changes when the map changes or
-- when settings change. Thus, this is only called if necessary, not on
-- every frame.
-- ]]
function prepareDraw()
	-- Map needs to be loaded, a lot depends on it
	if not mapLoaded then
		return
	end

	-- Variables that stay the same (until settings are changed)
	font = s("fontType")
	fontScale = s("fontSize")
	fontHeight = dxGetFontHeight(s("fontSize"),s("fontType"))
	local widthToTheRight = 20
	if s("drawDistance") then
		widthToTheRight = widthToTheRight + dxGetTextWidth("00.00",fontScale,font) + 20
	end
	if s("drawDelay") then
		widthToTheRight = widthToTheRight + dxGetTextWidth("00:00.00",fontScale,font) + 20
	end

	-- Colors
	s_backgroundColor = getColor("background")
	s_background2Color = getColor("background2")
	s_fontColor = getColor("font")
	s_font2Color = getColor("font2")
	s_barColor = getColor("bar")
	s_progressColor = getColor("progress")

	-- Position and height
	x = math.floor(s("left") * screenWidth) - widthToTheRight
	y = math.floor(s("top") * screenHeight)
	g_height = math.floor(s("size") * screenHeight)
	g_fullPixelPerMeter = g_height / g_TotalDistance
	
	-- Zoom Dimensions
	g_zoomDistance = math.min(s("zoomDistance"), g_TotalDistance)
	g_zoomHeight = math.floor(s("zoomHeight") * g_height)
	if g_zoomHeight > g_height - c_gap*2 - 10 then
		g_zoomHeight = g_height - c_gap*2 - 10
	end

	-- Zoom PPM
	local normalHeight = g_height - g_zoomHeight - c_gap*2
	local normalDistance = g_TotalDistance - g_zoomDistance
	g_normalPixelPerMeter = normalHeight / normalDistance
	g_zoomPixelPerMeter = g_zoomHeight / g_zoomDistance
	
	-- Decide whether zoom should be enabled
	g_zoomFactor = math.floor(g_zoomPixelPerMeter / g_normalPixelPerMeter * 100) / 100
	g_zoomAvailable = g_zoomFactor >= c_minZoomFactor
	g_zoomEnabled = s("zoomEnabled") and g_zoomAvailable

	-- Info Displays
	if not g_zoomAvailable and s("zoomEnabled") then
		zoomUnavailableInfo:showIfAllowed()
	end
	if g_zoomEnabled then
		zoomSectionInfo:showIfAllowed()
	end
	checkKeyInfo()

	updateZoomInfo()

	update()

	-- Ready preparing, can start drawing if necessary
	readyToDraw = true
end

--[[
-- Update the zoom info shown in the GUI.
-- ]]
function updateZoomInfo()
	if zoomInfo == nil then
		return
	end
	local factorText = g_zoomFactor.."x normal resolution with current settings and map length."
	if g_zoomEnabled then
		guiSetText(zoomInfo, "Zoom is currently enabled, and has "..factorText)
	elseif g_zoomAvailable then
		guiSetText(zoomInfo, "Zoom is currently disabled, and would have "..factorText)
	else
		guiSetText(zoomInfo, "Zoom is currently automatically disabled, because it would only have "..factorText)
	end
end

--[[
-- Shows the zoomed-in section.
-- ]]
zoomSectionInfo.drawFunction = function(fade)
	if not g_zoomEnabled then
		return
	end
	local top = y + g_normalPixelPerMeter * (g_TotalDistance - g_distanceT) + c_gap
	local bottom = top + g_zoomHeight
	local gap = math.max(g_maxNameWidth + 50, 30)
	local left = x - gap
	local right = x - (gap - 10)

	dxDrawLine(left, top,   left, bottom, getColor("font", fade))
	dxDrawLine(left, top,   right, top, getColor("font", fade))
	dxDrawLine(left, bottom,   right, bottom, getColor("font", fade))
	drawText("Zoomed-in section (always "..s("zoomDistance").."m)", left - 10, top + g_zoomHeight / 2, getColor("font", fade), getColor("background", fade), true)
end

zoomUnavailableInfo.drawFunction = function(fade)
	drawText("Zoom unavailable (short map)", x, y - fontHeight - 3, getColor("font", fade), getColor("background", fade), true)
end

zoomOffInfo.drawFunction = function(fade)
	drawText("Zoom off", x, y - fontHeight - 3, getColor("font", fade), getColor("background", fade), true)
end

--[[
-- This actually draws all the stuff on the screen.
--
-- If Zoom enabled, calculates the size and position of the bar sections.
-- ]]
function draw()
	-- Check if drawing is enabled
	if not readyToDraw or not s("enabled") or screenFadedOut or showingPoll or g_players == nil then
		return
	end

	-- Draw Info Texts (will only actually draw if currently shown)
	zoomUnavailableInfo:draw()
	zoomOffInfo:draw()
	keyInfo:draw()
	zoomSectionInfo:draw()

	g_maxNameWidth = 0

	-- Player Info for Top/Middle/Bottom bar
	local playersT = g_players[1]
	local playersM = g_players[2]
	local playersB = g_players[3]
	
	if g_zoomEnabled then
		local ppm = g_normalPixelPerMeter
		-- Top Bar
		if g_distanceT < g_TotalDistance then
			local height = ppm * (g_TotalDistance - g_distanceT)
			drawBar(y, height, ppm, g_distanceT, playersT, "top")
		end
		-- Bottom Bar
		if g_distanceB > 0 then
			local height = ppm * g_distanceB
			drawBar(y + (g_height - height), height, ppm, 0, playersB, "bottom")
		end
		-- Middle Bar
		drawBar(y + ppm * (g_TotalDistance - g_distanceT) + c_gap, g_zoomHeight, g_zoomHeight / g_zoomDistance, g_distanceB, playersM, "middle")
	else
		-- Main Bar / No Zoom
		drawBar(y, g_height, g_fullPixelPerMeter, 0, playersM, "middle")
	end

	-- Draw the total distance (if enabled)
	if s("drawDistance") then
		local backgroundColor = s_backgroundColor
		local fontColor = s_fontColor
		local totalDistanceOutput = g_TotalDistance
		if s("mode") == "miles" then
			totalDistanceOutput = totalDistanceOutput / 1.609344
		end
		drawText(string.format("%.2f",totalDistanceOutput/1000).." "..s("mode"),x + 18,y - fontHeight / 2,fontColor,backgroundColor)
	end
end

--[[
-- This actually draws all the stuff on the screen.
-- ]]
function drawBar(y, h, pixelPerMeter, distanceOffset, players, barType)

	-- Initialize Variables needed
	local backgroundColor = s_backgroundColor
	local fontColor = s_fontColor
	local color = s_fontColor

	-- Dertemine local Players distance
	local localPlayerDistance = g_localPlayerDistance
	local localPlayerLevel = nil
	if localPlayerDistance ~= nil then
		-- TODO: to round or not to round
		localPlayerLevel = math.floor(y + h - (localPlayerDistance - distanceOffset)*pixelPerMeter) - 1
	else
		localPlayerDistance = g_TotalDistance
	end

	-----------------------
	-- Draw Progress Bar --
	-----------------------
	local outlineColor = tocolor(0,0,0,200)
	local outlineColor2 = tocolor(0,0,0,120)
	local w = 4
	if barType == "middle" and g_zoomEnabled and s("zoomWider") then
		w = 5
	end

	-- Left border
	dxDrawLine(x-w-1, y-1, x-w-1, y+h-1, outlineColor)
	dxDrawLine(x-w-2, y-1, x-w-2, y+h-1, outlineColor)
	-- Right border
	dxDrawLine(x+w, y-1, x+w, y+h-1, outlineColor)
	dxDrawLine(x+w+1, y-1, x+w+1, y+h-1, outlineColor)
	
	-- Top border
	dxDrawLine(x-w-1, y-1,   x+w, y-1,   outlineColor)
	dxDrawLine(x-w-1, y-2,   x+w, y-2,   outlineColor2)
	-- Bottom border
	dxDrawLine(x-w-1, h+y-1, x+w, h+y-1, outlineColor)
	dxDrawLine(x-w-1, h+y,   x+w, h+y,   outlineColor2)
	
	-- Background
	dxDrawRectangle(x-w,y,w*2,h,s_barColor)
	
	-- Current local player progress
	if localPlayerLevel ~= nil and barType == "middle" then
		dxDrawRectangle(x-w,localPlayerLevel,w*2,y + h- localPlayerLevel - 1,s_progressColor)
	end

	-- Always draw full progress for bottom bar
	if barType == "bottom" and localPlayerDistance ~= g_TotalDistance then
		dxDrawRectangle(x-w,y,w*2,h,s_progressColor)
	end
	
	----------------------------------------------
	-- Draw all players except the Local Player --
	----------------------------------------------
	local showLocalPlayer = true
	for pos,value in pairs(players) do
		local playerName = value[1]
		local playerDistance = value[2] - distanceOffset
		local actualPlayerDistance = value[2]
		local playerElement = value[3]
		local delay = nil
		local delayPassed = nil
		if g_delay[playerElement] ~= nil then
			delay = g_delay[playerElement][1]
			delayPassed = getTickCount() - g_delay[playerElement][2]
		end
		if playerElement ~= getLocalPlayer() then
			local level = math.floor(y + h - playerDistance*pixelPerMeter) - 1
			local distance = 0
			if localPlayerLevel ~= nil then
				if math.abs(localPlayerLevel - level) < 10 then
					showLocalPlayer = false;
				end
			end
			distance = actualPlayerDistance - localPlayerDistance
			
			-- prepare actual output
			if s("mode") == "miles" then
				distance = distance / 1.609344
			end
			if distance > 0 then
				distance = string.format("+%.2f",distance/1000)
			else
				distance = string.format("%.2f",distance/1000)
			end
			local textWidth = dxGetTextWidth(playerName,fontScale,font)
			if textWidth > g_maxNameWidth then
				g_maxNameWidth = textWidth
			end
			dxDrawRectangle(	x - 10,			level,		20,	2,	color)
			drawText(playerName,	x - textWidth - 20,	level - fontHeight / 2,fontColor,backgroundColor)
			local indent = 20
			if s("drawDistance") then
				drawText(distance,x+ indent, level - fontHeight / 2,fontColor,backgroundColor)
				indent = indent + dxGetTextWidth(distance,fontScale,font) + 20
			end
			if s("drawDelay") and delay ~= nil then
				local stayTime = 8000
				local fadeOutTime = 4000
				if delayPassed < fadeOutTime + stayTime or isGuiVisible() then
					local fade = 1
					if delayPassed > stayTime and not isGuiVisible() then
						fade = (fadeOutTime - delayPassed + stayTime) / fadeOutTime
					end
					drawText(formatTime(delay),x+indent,level-fontHeight/2,getColor("fontDelay",fade),getColor("backgroundDelay",fade))	
				end
			end
		end
	end

	-----------------------
	-- Draw Local Player --
	-----------------------
	-- Draw only if player hasn't finished
	if localPlayerDistance == g_TotalDistance or barType ~= "middle" then
		return
	end
	local fontColor = s_font2Color
	local backgroundColor = s_background2Color
	-- Local player indiciator is a bit wider
	dxDrawRectangle(x - 12,localPlayerLevel,24,2,fontColor)
	if showLocalPlayer then
		local textWidth = dxGetTextWidth(g_localPlayerName,fontScale,font)
		if textWidth > g_maxNameWidth then
			g_maxNameWidth = textWidth
		end
		local leftX = x - textWidth - 20
		local topY = localPlayerLevel - fontHeight / 2
		
		drawText(g_localPlayerName,leftX,topY,fontColor,backgroundColor)
		if s("mode") == "miles" then
			localPlayerDistance = localPlayerDistance / 1.609344
		end
		if s("drawDistance") then
			drawText(string.format("%.2f",localPlayerDistance/1000),x + 20,localPlayerLevel - fontHeight / 2,fontColor,backgroundColor)
		end
	end
end
addEventHandler("onClientRender",getRootElement(),draw)

--[[
-- Retrieves the given color from the settings and returns
-- it as hex color value.
--
-- @param   string   name: The name of the color (e.g. "font")
-- @param   float    fade (optional): This number is multiplied with the alpha
-- 			part of the color, to fade the element the color
-- 			is used with
-- @return  color   A color created with tocolor()
-- ]]
function getColor(name,fade)
	if fade == nil then
		fade = 1
	end
	return tocolor(s(name.."ColorRed"),s(name.."ColorGreen"),s(name.."ColorBlue"),s(name.."ColorAlpha") * fade)
end

--[[
-- Draws text with a background
--
-- @param   string   text: The actual text to be drawn
-- @param   int      x: The upper left corner of the start of the text
-- @param   int      y: The upper left corner of the start of the text
-- @param   color    color: The font color
-- @param   color    backgroundColor: The color used for the background
-- ]]
function drawText(text,x,y,color,backgroundColor,left)
	local font = s("fontType")
	local fontScale = s("fontSize")

	local textWidth = math.floor(dxGetTextWidth(text,fontScale,font))
	local fontHeight = math.floor(dxGetFontHeight(fontScale,font))
	if left then
		x = x - textWidth
	end

	x = math.floor(x + 0.5)
	y = math.floor(y + 0.5)
	
	local cornerSize = math.floor(fontHeight / 2.5)

	--  TODO: if the font size is made bigger, the borders increase as well,
	--  but the calculation for the space is fixed
	if s("roundCorners") then
		dxDrawRectangle(x,y, textWidth, fontHeight, backgroundColor)

		dxDrawRectangle(x - cornerSize,y + cornerSize, cornerSize, fontHeight - cornerSize*2,backgroundColor)
		dxDrawRectangle(x + textWidth,y + cornerSize, cornerSize, fontHeight - cornerSize*2,backgroundColor)

		dxDrawImage(x - cornerSize, y, cornerSize, cornerSize, "corner.png",0,0,0,backgroundColor)
		dxDrawImage(x - cornerSize, y + fontHeight - cornerSize, cornerSize, cornerSize, "corner.png",270,0,0,backgroundColor)
		dxDrawImage(x + textWidth, y + fontHeight - cornerSize, cornerSize, cornerSize, "corner.png",180,0,0,backgroundColor)
		dxDrawImage(x + textWidth, y, cornerSize, cornerSize, "corner.png",90,0,0,backgroundColor)

		--[[
		dxDrawImage(x - cornerSize - 1, y-1, cornerSize, cornerSize, "corner2.png",0,0,0,tocolor(0,0,0,255))
		dxDrawImage(x - cornerSize, y + fontHeight - cornerSize, cornerSize, cornerSize, "corner2.png",270,0,0,tocolor(0,0,0,255))
		dxDrawImage(x + textWidth, y + fontHeight - cornerSize, cornerSize, cornerSize, "corner2.png",180,0,0,tocolor(0,0,0,255))
		dxDrawImage(x + textWidth, y, cornerSize, cornerSize, "corner2.png",90,0,0,tocolor(0,0,0,255))

		dxDrawLine(x,y-1,x+textWidth,y-1,tocolor(0,0,0,255))
		dxDrawLine(x,y+fontHeight,x+textWidth,y+fontHeight,tocolor(0,0,0,255))
		dxDrawLine(x,y-2,x+textWidth,y-2,tocolor(0,0,0,255))
		dxDrawLine(x,y+fontHeight+1,x+textWidth,y+fontHeight+1,tocolor(0,0,0,255))

		dxDrawLine(x - cornerSize-1,y+cornerSize,x-cornerSize-1,y+fontHeight-cornerSize,tocolor(0,0,0,255))
		dxDrawLine(x + textWidth+cornerSize,y+cornerSize,x+textWidth+cornerSize,y+fontHeight-cornerSize,tocolor(0,0,0,255))
		]]
	else
		dxDrawRectangle(x - cornerSize,y,textWidth + cornerSize*2,fontHeight,backgroundColor)
		--[[
		dxDrawLine(x - cornerSize / 2,y-1,x+textWidth + cornerSize/2,y-1,tocolor(0,0,0,255))
		dxDrawLine(x - cornerSize / 2 - 1,y-1,x-cornerSize/2 - 1,y+fontHeight,tocolor(0,0,0,255))
		dxDrawLine(x - cornerSize / 2,y+fontHeight,x+textWidth + cornerSize/2,y+fontHeight,tocolor(0,0,0,255))
		dxDrawLine(x+textWidth+cornerSize/2,y-1,x+textWidth+cornerSize/2,y+fontHeight,tocolor(0,0,0,255))
		]]
	end
	dxDrawText(text,x,y,x,y,color,fontScale,font)
	--dxDrawText(tostring(y),0,0,0)
end

addEventHandler("onClientScreenFadedOut",getRootElement(),function() screenFadedOut = true end)
addEventHandler("onClientScreenFadedIn",getRootElement(),function() screenFadedOut = false end)

addEvent("doShowPoll", true)
addEvent("doStopPoll", true)
addEventHandler("doShowPoll", getRootElement(), function() showingPoll = true end)
addEventHandler("doStopPoll", getRootElement(), function() showingPoll = false end)

------------------
-- Settings Gui --
------------------

local gui = {}
local radioButtons = {}

--[[
-- This will determine if the settings gui is currently visible.
--
-- @return   boolean   true if the gui exists and is visible, false otherwise
-- ]]
function isGuiVisible()
	if not isElement(gui.window) then
		return false
	end
	return guiGetVisible(gui.window)
end

local function handleEdit(element)
	if element == gui.helpMemo then
		return
	end

	for k,v in pairs(gui) do
		local _,_,radioName = string.find(k,"radio_(%w+)_%d+")
		if element == v and (settingsObject.settings.default[k] ~= nil or settingsObject.settings.default[radioName] ~= nil) then
			--outputChatBox(tostring(getElementType(element)))
			if type(settingsObject.settings.main[k]) == "boolean" then
				settingsObject:set(k,guiCheckBoxGetSelected(element))
			elseif getElementType(element) == "gui-radiobutton" then
				if guiRadioButtonGetSelected(element) then
					local data = radioButtons[radioName]
					local _,_,key = string.find(k,"radio_%w+_(%d+)")
					settingsObject:set(radioName,data[tonumber(key)].value)
				end
			else
				settingsObject:set(k,guiGetText(element))
			end
		end
	end
	if element ~= gui.zoomInfo then
		prepareDraw()
	end
end

local function handleClick()

	handleEdit(source)

	if source == gui.buttonSave then
		settingsObject:saveToXml()
	end
	if source == gui.buttonClose then
		closeGui()
	end
end

local function addColor(color,name,top,help)
	local label = guiCreateLabel(24,top,140,20,name..":",false,gui.tabStyles)
	local defaultButton = {}
	gui[color.."Red"] = guiCreateEdit(160,top,50,20,tostring(s(color.."Red")),false,gui.tabStyles)
	table.insert(defaultButton,{mode="set",edit=gui[color.."Red"],value=s(color.."Red","default")})
	gui[color.."Green"] = guiCreateEdit(215,top,50,20,tostring(s(color.."Green")),false,gui.tabStyles)
	table.insert(defaultButton,{mode="set",edit=gui[color.."Green"],value=s(color.."Green","default")})
	gui[color.."Blue"] = guiCreateEdit(270,top,50,20,tostring(s(color.."Blue")),false,gui.tabStyles)
	table.insert(defaultButton,{mode="set",edit=gui[color.."Blue"],value=s(color.."Blue","default")})
	gui[color.."Alpha"] = guiCreateEdit(325,top,50,20,tostring(s(color.."Alpha")),false,gui.tabStyles)
	table.insert(defaultButton,{mode="set",edit=gui[color.."Alpha"],value=s(color.."Alpha","default")})
	addEditButton(390,top,50,20,"default",false,gui.tabStyles,unpack(defaultButton))
	if help ~= nil then
		addHelp(help,label,gui[color.."Red"],gui[color.."Green"],gui[color.."Blue"],gui[color.."Alpha"])
	end
end


--[[
-- This will add one or (usually) several radio-buttons, that can be used
-- to change a single setting.
--
-- @param   int     x: The x position of the buttons
-- @param   int     y: The y position of the first button (others will be placed below)
-- @param   string  name: The name of the radio-button-group with which it will be identified
-- 				and is also the name of the setting these radio-buttons represent
-- @param   table   data: A table of the options to be added, numeric indices, possible elements:
-- 				text: The text of the radio button
-- 				value: The value to be set if the radio button is activated
-- ]]
local function addRadioButtons(x,y,name,data,selected)
	local pos = y
	for k,v in pairs(data) do
		local radio = guiCreateRadioButton(x,pos,200,20,v.text,false,gui.tabGeneral)
		if v.help ~= nil then
			addHelp(v.help,radio)
		end
		gui["radio_"..name.."_"..k] = radio
		if selected == v.value then
			guiRadioButtonSetSelected(radio,true)
		end
		pos = pos + 20
	end
	radioButtons[name] = data
end

--[[
-- Creates all the settings gui elements and either adds them to a window
-- if the "gamecenter" resource is not running or adds them to the "gamecenter" gui.
--
-- If the gui already exists, calling this function will have no effect.
-- ]]
function createGui()
	-- Check if GUI already exists
	if gui.window ~= nil then
		return
	end

	-- Check if "gamecenter" is running and if so, get a srcollpane to add the elements to,
	-- otherwise create a window.
	gamecenterResource = getResourceFromName("gamecenter")

	if gamecenterResource then
		gui.window = call(gamecenterResource,"addWindow","Settings","Race Progress",500,560)
	else
		gui.window = guiCreateWindow ( 320, 240, 500, 560, "Race Progress Bar settings", false )
	end
	
	-- Create the actual elements
	
	-- TABS
	gui.tabs = guiCreateTabPanel(0,24,500,400,false,gui.window)
	gui.tabGeneral = guiCreateTab("General",gui.tabs)
	addHelp("General settings for the progress display.",gui.tabGeneral)
	gui.tabStyles = guiCreateTab("Styles",gui.tabs)
	addHelp("Styling settings.",gui.tabStyles)
	gui.tabZoom = guiCreateTab("Zoom", gui.tabs)
	gui.tabHelp = guiCreateTab("Help", gui.tabs)

	-----------------
	-- TAB GENERAL --
	-----------------
	gui.enabled = guiCreateCheckBox(24,20,100,20,"Enable",s("enabled"),false,gui.tabGeneral)
	addHelp("Show or hide the Progress Bar.",gui.enabled)
	gui.drawDistance = guiCreateCheckBox(180,20,100,20,"Show distance",s("drawDistance"),false,gui.tabGeneral)
	addHelp("If enabled, shows the distances to other players, the total race distance and your own travelled distance on the right-hand side.",gui.drawDistance)
	gui.drawDelay = guiCreateCheckBox(290,20,110,20,"Show time delay",s("drawDelay"),false,gui.tabGeneral)
	addHelp("If enabled, shows the time difference to other players (at checkpoints) on the right-hand side.",gui.drawDelay)

	gui.size = guiCreateEdit(100,50,80,20,tostring(s("size")),false,gui.tabGeneral)
	addHelp("The size (height) of the progress display (relative to screen resolution).",gui.size,
		guiCreateLabel(24,50,70,20,"Size:",false,gui.tabGeneral))
	addEditButton(190,50,60,20,"smaller",false,gui.tabGeneral,{mode="add",edit=gui.size,add=-0.01})
	addEditButton(260,50,60,20,"bigger",false,gui.tabGeneral,{mode="add",edit=gui.size,add=0.01})
	addEditButton(330,50,60,20,"default",false,gui.tabGeneral,{mode="set",edit=gui.size,value=s("size","default")})

	gui.fontSize = guiCreateEdit(100,80,80,20,tostring(s("fontSize")),false,gui.tabGeneral)
	addHelp("The size of the text.",gui.fontSize,
		guiCreateLabel(24,80,80,20,"Font size:",false,gui.tabGeneral))
	addEditButton(190,80,60,20,"smaller",false,gui.tabGeneral,{mode="add",edit=gui.fontSize,add=-0.1})
	addEditButton(260,80,60,20,"bigger",false,gui.tabGeneral,{mode="add",edit=gui.fontSize,add=0.1})
	addEditButton(330,80,60,20,"default",false,gui.tabGeneral,{mode="set",edit=gui.fontSize,value=s("fontSize","default")})

	gui.fontType = guiCreateEdit(100,110,80,20,tostring(s("fontType")),false,gui.tabGeneral)
	addHelp("The font type of the text.",gui.fontType,
		guiCreateLabel(24,110,80,20,"Font type:",false,gui.tabGeneral))
	addEditButton(190,110,60,20,"<--",false,gui.tabGeneral,{mode="cyclebackwards",edit=gui.fontType,values=c_fonts})
	addEditButton(260,110,60,20,"-->",false,gui.tabGeneral,{mode="cycle",edit=gui.fontType,values=c_fonts})
	addEditButton(330,110,60,20,"default",false,gui.tabGeneral,{mode="set",edit=gui.fontType,value=s("fontType","default")})

	guiCreateLabel(24, 140, 60, 20, "Position:", false, gui.tabGeneral )

	gui.top = guiCreateEdit( 140, 140, 60, 20, tostring(s("top")), false, gui.tabGeneral )
	addHelp("The relative position of the upper left corner of the progress display, from the top border of the screen.",gui.top,
		guiCreateLabel(100, 140, 40, 20, "Top:", false, gui.tabGeneral ))

	addEditButton(258, 140, 40, 20, "up", false, gui.tabGeneral, {mode="add",edit=gui.top,add=-0.01})
	addEditButton(258, 166, 40, 20, "down", false, gui.tabGeneral, {mode="add",edit=gui.top,add=0.01})
	
	gui.left = guiCreateEdit( 140, 166, 60, 20, tostring(s("left")), false, gui.tabGeneral )
	addHelp("The relative position of the upper left corner of the progress display, from the left border of the screen.",gui.left,
		guiCreateLabel(100, 166, 40, 20, "Left:", false, gui.tabGeneral))
	addEditButton(210, 166, 40, 20, "left", false, gui.tabGeneral, {mode="add",edit=gui.left,add=-0.01})
	addEditButton( 306, 166, 40, 20, "right", false, gui.tabGeneral, {mode="add",edit=gui.left,add=0.01})
	
	addEditButton(360, 166, 50, 20, "default", false, gui.tabGeneral,
		{mode="set",edit=gui.top,value=s("top","default")},
		{mode="set",edit=gui.left,value=s("left","default")}
	)

	guiCreateLabel(24,200,60,20,"Mode:",false,gui.tabGeneral)
	gui.mode = guiCreateEdit( 100, 200,80,20,tostring(s("mode")),false,gui.tabGeneral)
	local button1 = addEditButton(190,200,80,20,"toggle Mode",false,gui.tabGeneral,{mode="cycle",edit=gui.mode,values={"km","miles"}})
	addHelp("Changes the display of the distances between kilometres or miles.",gui.mode,button1)

	gui.preferNear = guiCreateCheckBox(24,300,280,20,"Prefer players behind or in front of you",s("preferNear"),false,gui.tabGeneral)
	addHelp("Draws players directly before or in front of you on top of the other players, so you know who you race against. If you have this enabled, the shuffle or sorting functions have no effect for those players affected by this setting.",gui.preferNear)

	addRadioButtons(24,234,"sortMode",{
		{text="Sort playernames by length",value="length",help="This affects how playernames that are close to eachother overlap. If this option is selected, shorter playernames will be drawn ontop."},
		{text="Shuffle playernames",value="shuffle",help="This affects how playernames that are close to eachother overlap. If this option is selected, the order in which the playernames are drawn changes randomly."},
		{text="Sort playernames by rank",value="rank",help="This affects how playernames that are close to eachother overlap. If this option is selected, playernames of players who have a higher rank are preferred and drawn ontop."}
	},s("sortMode"))

	----------------
	-- TAB STYLES --
	----------------
	
	guiCreateLabel(165,40,40,20,"Red",false,gui.tabStyles)
	guiCreateLabel(220,40,40,20,"Green",false,gui.tabStyles)
	guiCreateLabel(275,40,40,20,"Blue",false,gui.tabStyles)
	guiCreateLabel(325,40,40,20,"Alpha",false,gui.tabStyles)

	addColor("barColor","Bar Color",60,"Background color of the progress bar.")
	addColor("progressColor","Progress",84,"Color of the bar the fills the background depending on your progress.")
	addColor("fontColor","Font",108,"The color of the text, except your own name and distance.")
	addColor("font2Color","Font (yours)",132,"The color of your own name and distance.")
	addColor("backgroundColor","Background",156,"The background color of the text, except your own name and distance.")
	addColor("background2Color","Background (yours)",180,"The background color of your own name and distance.")
	addColor("fontDelayColor","Font (delay)",204,"The font color of the delay times.")
	addColor("backgroundDelayColor","Background (delay)",228,"The background color of the delay times.")
	
	gui.roundCorners = guiCreateCheckBox(24,260,140,20,"Round corners",s("roundCorners"),false,gui.tabStyles)
	addHelp("Use round corners for the background of the text.",gui.roundCorners)

	--------------
	-- TAB ZOOM --
	--------------
	
	gui.zoomEnabled = guiCreateCheckBox(24,20,100,20,"Enable Zoom",s("zoomEnabled"),false,gui.tabZoom)
	addHelp("Adds a zoomed-in section in the progress bar centered on the player.",gui.zoomEnabled)

	gui.zoomHeight = guiCreateEdit(100,50,80,20,tostring(s("zoomHeight")),false,gui.tabZoom)
	addEditButton(190,50,60,20,"smaller",false,gui.tabZoom,{mode="add",edit=gui.zoomHeight,add=-0.01})
	addEditButton(260,50,60,20,"bigger",false,gui.tabZoom,{mode="add",edit=gui.zoomHeight,add=0.01})
	addEditButton(330,50,60,20,"default",false,gui.tabZoom,{mode="set",edit=gui.zoomHeight,value=s("zoomHeight","default")})
	addHelp("The height of the zoomed-in section (relative to Progress Bar height).", gui.zoomHeight,
		guiCreateLabel(24,50,70,20,"Height:",false,gui.tabZoom))

	gui.zoomDistance = guiCreateEdit(100,80,80,20,tostring(s("zoomDistance")),false,gui.tabZoom)
	addEditButton(190,80,60,20,"smaller",false,gui.tabZoom,{mode="add",edit=gui.zoomDistance,add=-10})
	addEditButton(260,80,60,20,"bigger",false,gui.tabZoom,{mode="add",edit=gui.zoomDistance,add=10})
	addEditButton(330,80,60,20,"default",false,gui.tabZoom,{mode="set",edit=gui.zoomDistance,value=s("zoomDistance","default")})
	addHelp("The distance in meters that is covered by the zoomed-in section of the Progress Bar.",
		gui.zoomDistance, guiCreateLabel(24,80,70,20,"Distance:",false,gui.tabZoom))

	gui.zoomWider = guiCreateCheckBox(24,110,180,20,"Zoomed-in section wider",s("zoomWider"),false,gui.tabZoom)
	addHelp("Draws the zoomed-in section with slightly more width.",gui.zoomWider)

	gui.zoomInfo = guiCreateMemo(24,160,440,80,"",false,gui.tabZoom)
	guiMemoSetReadOnly(gui.zoomInfo, true)
	zoomInfo = gui.zoomInfo

	--------------
	-- TAB HELP --
	--------------
	
	local helpText = xmlNodeGetValue(getResourceConfig("help.xml"))
	gui.helpTextMemo = guiCreateMemo(.05, .05, .9, .9, helpText, true, gui.tabHelp)
	guiMemoSetReadOnly(gui.helpTextMemo, true)

	--------------------
	-- ALWAYS VISIBLE --
	--------------------
	gui.helpMemo = guiCreateMemo(0,440,500,80, "[Move over GUI to get help]", false, gui.window)
	guiHelpMemo = gui.helpMemo

	gui.buttonSave = guiCreateButton( 0, 530, 260, 20, "Save Settings To File", false, gui.window )
	addHelp("Saves current settings to file, so that they persist when you reconnect.",gui.buttonSave)
	gui.buttonClose = guiCreateButton( 280, 530, 235, 20, "Close", false, gui.window )

	-- Events and "gamecenter" stuff
	if gamecenterResource then
		guiSetEnabled(gui.buttonClose,false)
	else
		guiSetVisible(gui.window,false)
	end
	addEventHandler("onClientGUIClick",gui.window,handleClick)
	addEventHandler("onClientGUIChanged",gui.window,handleEdit)
	addEventHandler("onClientMouseEnter",gui.window,handleHelp)
end

--[[
-- As soon as the "gamecenter" resource is started, this will create the GUI
-- if it wasn't already (if it is created, it will also be added to the gamecenter gui).
-- ]]
addEventHandler("onClientResourceStart",getRootElement(),
	function(resource)
		if getResourceName(resource) == "gamecenter" then
			-- Create the GUI as soon as the gamecenter-resource starts (if it hasn't been created yet)
			createGui()
			--recreateGui()
		elseif resource == getThisResource() then
			if getResourceFromName("gamecenter") then
				createGui()
			end
		end
	end
)

-- TODO: check if this can somehow work
addEventHandler("onClientResourceStop",getRootElement(),
	function(resource)
		if getResourceName(resource) == "gamecenter" then
			--recreateGui()
		end
	end
)

--[[
-- Destroys all GUI elements of the settings GUI and creates them again.
-- TODO: not working nor used
-- ]]
function recreateGui()
	for k,v in pairs(gui) do
		if isElement(v) then
			outputConsole(getElementType(v).." "..guiGetText(v))
			destroyElement(v)
		end
	end
	gui = {}
	createGui()
end

--[[
-- Opens the GUI, as well as creates it first (if necessary). Will call
-- gamecenter to open the appropriate window if it is running.
-- ]]
function openGui()
	-- Create the GUI as soon as someone tries to open it (if it hasn't been created yet)
	createGui()
	checkKeyInfo(true) -- Also changes title
	
	if gamecenterResource then
		exports.gamecenter:open("Settings","Race Progress")
	else
		guiSetVisible(gui.window,true)
		showCursor(true)
	end
	zoomSectionInfo:setShowAlways(true)
end

--[[
-- Either hides the window or asks gamecenter to close its gui, if it is running.
-- ]]
function closeGui()
	if gamecenterResource then
		exports.gamecenter:close()
	else
		guiSetVisible(gui.window,false)
		showCursor(false)
	end
	zoomSectionInfo:setShowAlways(false)
end

--------------
-- Commands --
--------------

--[[
-- Shows the gui if it is hidden and vice versa.
-- ]]
function toggleGui()
	if gui.window ~= nil and guiGetVisible(gui.window) then
		closeGui()
	else
		openGui()
	end
end
addCommandHandler("progress",toggleGui)

function toggleBooleanSetting(element, name)
	settingsObject:set(name, not s(name))
	if element ~= nil then
		guiCheckBoxSetSelected(element, s(name))
	end
	prepareDraw()
end

function toggleEnabled()
	toggleBooleanSetting(gui.enabled, "enabled")
end
addCommandHandler("progress_toggle", toggleEnabled)

function toggleZoomEnabled()
	toggleBooleanSetting(gui.zoomEnabled, "zoomEnabled")
	if readyToDraw and not g_zoomAvailable then
		zoomUnavailableInfo:reset()
		zoomOffInfo:reset()
		if s("zoomEnabled") then
			zoomUnavailableInfo:show()
		else
			zoomOffInfo:show()
		end
	end
	if s("zoomEnabled") and not g_zoomAvailable and readyToDraw then
		zoomUnavailableInfo:show()
	end
end
addCommandHandler("progress_toggleZoom", toggleZoomEnabled)

function toggleDebugEnabled()
	settingsObject:set("debug", not s("debug"))
	outputChatBox("[Progress] Debug "..(s("debug") and "enabled" or "disabled"))
end
addCommandHandler("progress_toggleDebug", toggleDebugEnabled)

------------------
-- Key Handling --
------------------

local keyDown = 0
local longPress = 300
local keyTimer = nil

--[[
-- Called when a key is pressed/released and checks how long it was pressed
-- as well as starts a timer that will open the gui if necessary.
--
-- @param   string   key: The key that was pressed
-- @param   string   keyState: The state of the key ("up", "down")
-- ]]
function keyHandler(key,keyState)
	if keyState == "down" then
		keyDown = getTickCount()
		keyTimer = setTimer(keyTimerHandler,longPress,1)
	else
		-- Key was released, kill timer if it is running
		-- to prevent the GUI from opening
		if isTimer(keyTimer) then
			killTimer(keyTimer)
		end
		-- Calculate the time passed, and if the timer wasn't yet executed,
		-- toggle the progress bar
		local timePassed = getTickCount() - keyDown
		keyDown = 0
		if timePassed < longPress then
			toggleEnabled()
		end
	end
end
function keyTimerHandler()
	toggleGui()
end
bindKey(toggleSettingsGuiKey,"both",keyHandler)

function checkKeyInfo(force)
	if not keyInfo:isAllowed() and not force then
		return
	end
	local key = getKeyBoundToFunction(keyHandler)
	if type(key) == "string" then
		toggleSettingsGuiKey = key
		keyInfo:showIfAllowed()
		if gui.window ~= nil then
			guiSetText(gui.window, "Race Progress Bar settings (hold "..toggleSettingsGuiKey.." to toggle)")
		end
	elseif gui.window ~= nil then
		guiSetText(gui.window, "Race Progress Bar settings")
	end
end

keyInfo.drawFunction = function(fade)
	drawText(toggleSettingsGuiKey.." (press/hold)", x, y + g_height + 5, getColor("font", fade), getColor("background", fade), true)
end

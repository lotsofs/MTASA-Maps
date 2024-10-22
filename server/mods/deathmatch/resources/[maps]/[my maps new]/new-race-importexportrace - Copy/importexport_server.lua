CHECKPOINT = {}
CHECKPOINTS = getElementsByType("checkpoint")

REQUIRED_CHECKPOINTS = -1
POLL_ACTIVE = false

MARKER_START = getElementByID("_MARKER_GAME_START")

CUTSCENE_LENGTH_IN_SECONDS = 29

CHOSEN_CARS = {}
SHUFFLED_INDICES_PER_PLAYER = {}
PLAYER_PROGRESS = {}

PLAYERS_WHO_JOINED_DURING_CUTSCENE = {}

LEFT_PLAYERS_PROGRESS = {}
LEFT_PLAYERS_SHUFFLED_CARS = {}

DATABASE = dbConnect("sqlite", ":/mapImportExportRace.db")
	
------------------------------------------------------ Start of race ------------------------------------------------------

function selectCars()
	local cars = getElementsByType("exportable")
	-- Select cars for every player
	if (#CHOSEN_CARS == 0) then
		if (REQUIRED_CHECKPOINTS == #cars) then
			CHOSEN_CARS = cars
		else
			for i = #cars, #cars - REQUIRED_CHECKPOINTS + 1, -1 do
				randomIndex = math.random(1,i)
				table.insert(CHOSEN_CARS, cars[randomIndex])
				table.remove(cars, randomIndex)
			end
		end
	end
	-- Shuffle the cars for each player
	for i, v in pairs(getElementsByType("player")) do
		shuffleCarsPerPlayer(v)
		-- if (not PLAYERS_WHO_JOINED_DURING_CUTSCENE[v]) then
		-- 	local intsTable = {}
		-- 	SHUFFLED_INDICES_PER_PLAYER[v] = {}
		-- 	for j = #CHOSEN_CARS, 1, -1 do
		-- 		table.insert(intsTable, j)
		-- 	end
		-- 	for j = #intsTable, 1, -1 do
		-- 		randomIndex = math.random(1,j)
		-- 		table.insert(SHUFFLED_INDICES_PER_PLAYER[v], intsTable[randomIndex])
		-- 		table.remove(intsTable, randomIndex)
		-- 	end
	
		-- 	-- setPlayerScriptDebugLevel(v, 3)
		-- 	colorGenerator(v)
		-- 	PLAYER_PROGRESS[v] = 1
		-- 	teleportToNext(1, v)
		-- end
	end
end

function shuffleCarsPerPlayer(whose)
	if (#CHOSEN_CARS == 0) then
		-- Race hasn't started yet
		return
	end
	local sipp = SHUFFLED_INDICES_PER_PLAYER[whose]
	if (sipp ~= nil and #sipp > 0) then
		-- This player is not new
		return
	end
	
	local serial = getPlayerSerial(whose)
	if (LEFT_PLAYERS_PROGRESS[serial]) then
		PLAYER_PROGRESS[whose] = LEFT_PLAYERS_PROGRESS[serial]
		--LEFT_PLAYERS_PROGRESS[serial] = nil
		SHUFFLED_INDICES_PER_PLAYER[whose] = LEFT_PLAYERS_SHUFFLED_CARS[serial]
		teleportToNext(PLAYER_PROGRESS[whose], whose)
		
		triggerClientEvent(whose, "updateTarget", whose, PLAYER_PROGRESS[whose])
	else	
		local intsTable = {}
		SHUFFLED_INDICES_PER_PLAYER[whose] = {}
		for i = #CHOSEN_CARS, 1, -1 do
			table.insert(intsTable, i)
		end
		for i = #intsTable, 1, -1 do
			randomIndex = math.random(1,i)
			table.insert(SHUFFLED_INDICES_PER_PLAYER[whose], intsTable[randomIndex])
			table.remove(intsTable, randomIndex)
		end
		PLAYER_PROGRESS[whose] = 1
		teleportToNext(1, whose)
		triggerClientEvent(whose, "postCutsceneGameStart", whose)
	end
	-- triggerClientEvent ( whose, "gridCountdownStarted", resourceRoot )
	-- setPlayerScriptDebugLevel(whose, 3)
	colorGenerator(whose)
end

-- function newJoineeMarkerHit(markerHit, matchingDimension, dumpVariable)
-- 	if (markerHit ~= MARKER_START and marketHit ~= nil) then
-- 		return
-- 	end
-- 	if (getElementType(source) ~= "player") then
-- 		return
-- 	end

-- 	-- if (#CHOSEN_CARS == 0) then
-- 	-- 	-- Race hasn't started yet
-- 	-- 	return
-- 	-- end
-- 	local sipp = SHUFFLED_INDICES_PER_PLAYER[source]
-- 	if (sipp ~= nil and #sipp > 0) then
-- 		-- This player is not new
-- 		-- shuffleCarsPerPlayer(source)
-- 		return
-- 	end

-- 	triggerClientEvent ( source, "gridCountdownStarted", resourceRoot )
-- 	setTimer(function(whom)
-- 		shuffleCarsPerPlayer(whom)
-- 	end, (CUTSCENE_LENGTH_IN_SECONDS+0.5)*1000, 1, source)
-- end
-- addEventHandler("onPlayerMarkerHit", root, newJoineeMarkerHit)

function teleportToNext(progress, player)
	-- get our destination
	element = CHOSEN_CARS[SHUFFLED_INDICES_PER_PLAYER[player][progress]]
	x = getElementData(element, "posX")
	y = getElementData(element, "posY")
	z = getElementData(element, "posZ")
	rX = getElementData(element, "rotX")
	rY = getElementData(element, "rotY")
	rZ = getElementData(element, "rotZ")
	model = getElementData(element, "model")
	model = tonumber(model)
	-- go there
	local vehicle = getPedOccupiedVehicle(player)
	if (not vehicle) then
		return
	end
	setElementModel(vehicle, model)

	-- setElementFrozen(vehicle, true)
	setElementPosition(vehicle, x, y, z)
	setElementAngularVelocity(vehicle, 0, 0, 0)
	setElementVelocity(vehicle, 0, 0, 0)
	setElementRotation(vehicle, rX, rY, rZ)
	fixVehicle(vehicle)
	setCameraTarget ( player, player )
end

function updateProgress(target)
	progress = target + 1

	if (getElementData(client, "race.finished")) then
		return
	end

	if (progress > REQUIRED_CHECKPOINTS) then
		PLAYER_PROGRESS[client] = #getElementsByType("checkpoint")
		triggerClientEvent(client, "finishRace", client)
	else
		if (progress == REQUIRED_CHECKPOINTS) then
			iprint("HELLO? BROTHER? ")
			triggerClientEvent(client, "lastCar", resourceRoot)
		end
		PLAYER_PROGRESS[client] = progress
		teleportToNext(progress, client)
		triggerClientEvent(client, "updateTarget", client, progress)
		iprint("2", progress, REQUIRED_CHECKPOINTS)
	end
end
addEvent("updateProgress", true)
addEventHandler("updateProgress", resourceRoot, updateProgress)

function playerRespawn(theVehicle, seat, jacked)
	-- do nothing if game hasnt started yet
	if (REQUIRED_CHECKPOINTS == -1) then
		return
	end
	local sipp = SHUFFLED_INDICES_PER_PLAYER[source]
	if (sipp == nil or #sipp == 0) then
		-- This player is new
		return
	end
	colorGenerator(source)
	teleportToNext(PLAYER_PROGRESS[source], source)
end
addEventHandler("onPlayerVehicleEnter", root, playerRespawn)

function raceStateChanged(newState, oldState)
	if (newState == "GridCountdown") then
		killTimer(FUN_TIMER)
		
		for i, v in pairs(getElementsByType("player")) do
			enableControlsInCountdown(getPedOccupiedVehicle(v), v)
		end

		triggerClientEvent ( root, "gridCountdownStarted", resourceRoot )
		startRacePoll()
	elseif (newState == "Running") then
		startGame()
	end
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, raceStateChanged)

function startRacePoll()
	exports.votemanager:stopPoll {}
	POLL_ACTIVE = true
	poll = exports.votemanager:startPoll {
		--start settings (dictionary part)
		title="Choose the map length:",
		percentage=100,
		timeout=11,
		allowchange=true,

		--start options (array part)
		[1]={"A Basic Race (1)", "pollFinished" , resourceRoot, 1},		
		[2]={"Shortened (5)", "pollFinished" , resourceRoot, 5},		
		[3]={"Full Experience (30)", "pollFinished", resourceRoot, 30},
		[4]={"DEBUG MODE (2)", "pollFinished" , resourceRoot, 2},		
	}
	if not poll then
		applyPollResult(1)
	end
end

function applyPollResult(pollResult)
	REQUIRED_CHECKPOINTS = pollResult

	-- Do some trickery with the map name & the race scoreboard manager so that separate top times are tracked per map length
	local customMapName = getMapName()
	if (pollResult == 1) then
		customMapName = customMapName .. " (A Basic Race)"
	elseif (pollResult == 5) then
		customMapName = customMapName .. " (Shortened)"
	elseif (pollResult == 30) then
		customMapName = customMapName .. " (Full Experience)"
	else
		customMapName = customMapName .. " (DEBUG MODE)"
	end
	setMapName ( customMapName )
	
	-- THe default top times manager does not respond to the above. So send it an event so it does
	local timesManager = getResourceRootElement( getResourceFromName("race_toptimes"))
	local raceResRoot = getResourceRootElement( getResourceFromName( "race" ) )
	local raceInfo = raceResRoot and getElementData( raceResRoot, "info" )
	
	local stuff = {}
	stuff.modename = raceInfo.mapInfo.modename
	stuff.name = customMapName
	stuff.statsKey = nil

	if raceInfo and timesManager then
		triggerEvent("onMapStarting", timesManager, stuff, stuff, stuff)
	end
end
addEvent("pollFinished", true)
addEventHandler("pollFinished", resourceRoot, applyPollResult)

function startGame()
	POLL_ACTIVE = false
	selectCars()
	exports.scoreboard:addScoreboardColumn("Vehicle")
	exports.scoreboard:addScoreboardColumn("Money")
end

function colorGenerator(player)
	colors = {}
	for i = 1, 4, 1 do
		-- since MTA wants colors in RGB, we won't bother calculating hue. Instead, we pretend S & V are both 100% to calculate a RGB values and apply SV on them later.
		-- When both S and V are 100%, the color in RGB will always have one component of 255, one of 0, and one in between.
		components = {}
		components[1] = 255
		components[2] = 0
		components[3] = math.random(0, 255)
		saturation = math.random(99, 100) / 100
		value = math.random(99, 100) / 100

		-- this block of code determines which RGB component will be min, which max, and which the other by shuffling them.
		indices = {1, 2, 3}
		shuffledIndices = {}
		for i = #indices, 1, -1 do
			random = math.random(1,i)
			shuffledIndices[i] = indices[random]
			table.remove(indices, random)
		end

		-- now we take the min/maxed RGB components and do the saturation & value calculations on them based on the shuffled indices
		for j,w in pairs(shuffledIndices) do
			c = components[w]		
			c = c + ((255 - c) * (1 - saturation)) 
			c = c * value			
			c = c - (c % 1)			
			colors[j + (i - 1) * 3] = c	
		end
	end
	-- apply our 4 generated colors the vehicle
	vehicle = getPedOccupiedVehicle(player)
	setVehicleColor(vehicle, colors[1], colors[2], colors[3], colors[4], colors[5], colors[6], colors[7], colors[8], colors[9], colors[10], colors[11], colors[12])
end

---------------------------------
---------------------------------

function cleanup(stoppedResource)
	exports.scoreboard:removeScoreboardColumn("Vehicle")
	exports.scoreboard:removeScoreboardColumn("Money")
end
addEventHandler( "onResourceStop", resourceRoot, cleanup)

function LoadGameFromDatabase(playerSource, commandName)
	if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(playerSource)), aclGetGroup ("Admin")) then
		LOADED_GAME_FROM_DB = true
		outputChatBox ( "Loading game from Database", root, 255, 0, 0, true )
		if (DATABASE) then
			for i, v in pairs(getElementsByType("player")) do
				-- read the database	
				local s = getPlayerSerial(v)
				dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS progressTable (serial TEXT, progress INTEGER, indices TEXT)")
				query = dbQuery(DATABASE, "SELECT * FROM progressTable WHERE serial=? LIMIT 1", s)
				results = dbPoll(query, -1)
				if (results[1]["progress"]) then
					LEFT_PLAYERS_PROGRESS[s] = results[1]["progress"]
					LEFT_PLAYERS_SHUFFLED_CARS[s] = fromJSON(results[1]["indices"])
				end
			end
		end
	end
end
addCommandHandler("ie_loadGame", LoadGameFromDatabase )

function autoSave()
	if (#CHOSEN_CARS == 0 or RACE_FINISHED) then
		-- Race hasn't started yet or has ended
		return
	end
	if (DATABASE) then
		for i, v in pairs(getElementsByType("player")) do
			local s = getPlayerSerial(v)
			dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS progressTable (serial TEXT, progress INTEGER, indices TEXT)")
			if (SHUFFLED_INDICES_PER_PLAYER[v]) then
				local json = toJSON(SHUFFLED_INDICES_PER_PLAYER[v])
				if (results and #results > 0) then
					dbExec(DATABASE, "UPDATE progressTable SET progress = ?, indices = ? WHERE serial = ?", PLAYER_PROGRESS[v], json, s)
				else
					dbExec(DATABASE, "INSERT INTO progressTable(serial, progress, indices) VALUES (?,?,?)", getPlayerSerial(v), PLAYER_PROGRESS[v], json)
				end
			end
		end	
	end
end
setTimer(autoSave, 60000, 0) -- autosave every 1 minutes

function playerLeaving(quitType)
	if (#CHOSEN_CARS == 0) then
		-- Race hasn't started yet
		return
	end
	if (getElementData(source, "race.finished")) then
		return
	end
	if (PLAYER_PROGRESS[source] == nil or PLAYER_PROGRESS[source] < 2) then
		return
	end
	local serial = getPlayerSerial(source)
	LEFT_PLAYERS_PROGRESS[serial] = PLAYER_PROGRESS[source]
	LEFT_PLAYERS_SHUFFLED_CARS[serial] = SHUFFLED_INDICES_PER_PLAYER[source]
end
addEventHandler( "onPlayerQuit", root, playerLeaving)

function playerJoining(loadedResource)
	if (loadedResource ~= resource) then
		return
	end
	didWeStartYet = 0
	if (#CHOSEN_CARS > 0) then
		didWeStartYet = 2
	end
	if (POLL_ACTIVE == true) then
		didWeStartYet = 1
		PLAYERS_WHO_JOINED_DURING_CUTSCENE[source] = true
	end
	triggerClientEvent(source, "didWeStartYet", source, didWeStartYet)
end
addEventHandler("onPlayerResourceStart", root, playerJoining)

--- I/E Race specific
function enableControlsInCountdown(car, driver)
	-- setElementData(car, "race.collideothers", 0)
	setElementFrozen(car, false)
	setElementCollisionsEnabled(car, true)
	-- toggleAllControls(driver, false, true, false)
end

function playerEnteredVehicle(theVehicle, seat, jacked)
	local m = getElementModel(theVehicle)
	if (m == 522 or m == 438 or m == 420) then
		enableControlsInCountdown(theVehicle, source)
	end
end
addEventHandler("onPlayerVehicleEnter", root, enableControlsInCountdown)

function makePeopleDrive() 
	for i, v in pairs(getElementsByType("player")) do
		w = getPedOccupiedVehicle(v)
		if (w) then
			enableControlsInCountdown(w, v)
		end
	end
end
FUN_TIMER = setTimer(makePeopleDrive, 1000, 0)





















-- -- TODO:
-- -- DONE - a script that teleports players to a car at the start
-- -- DONE - a script that detects the player inside the marker
-- -- DONE - a script that teleports players to a new car
-- -- DONE (unintentiallo) - a script that sets the respawn point for players
-- -- DONE (maybe) - a script that detects the player being inside a tanker and moving the marker for it
-- -- DONE - move stuff server side for security
-- -- DONE - repair car on teleport
-- -- DONE - intermediate checkpoints
-- -- DONE - fix coordinates for sanchez etc
-- -- DONE - spamming suicide = skip checkpoints
-- -- DONE - colorful cars
-- -- DONE - crane
-- -- DONE - blip
-- -- DONE - voting at start for length
-- -- DONE - leaderboard for 30 minute
-- -- DONE - make leaderboard disappear after a while, and reappear upon the end, and maybe upon the press of a button
-- -- DONE - add players to the leaderboard when they finish
-- -- DONE - taxi driver
-- -- DONE - make tanker be craned
-- -- DONE - magnet raised by 2Z then lowered by 4Z
-- -- DONE - check if player drove their truck off the ship or died somehow on the ship
-- -- DONE - shuffle is not called on laptop
-- -- DONE - use the new crane technology to attach the player to it when they finish
-- -- people entering --> line 208 in server, attempt to perform arithmetic on a nil value
-- -- DONE - outputchatbox

-- MARKER = getElementByID("_MARKER_EXPORT_PARK")
-- MARKER_TANKER = getElementByID("_MARKER_EXPORT_TANKER")

-- SHUFFLED_CARS = {}
-- PLAYER_PROGRESS = {}
-- TELEPORTING = {}
-- CHECKPOINT = {}
-- CHECKPOINTS = getElementsByType("checkpoint")

-- REQUIRED_CHECKPOINTS = -1
-- TIMER_POLL = nil

-- PRE_SHUFFLED_CARS = {}

-- DATABASE = dbConnect("sqlite", ":/importExportRaceTopTimes.db")
	
-- ------------------------------------------------------ Start of race ------------------------------------------------------

-- function shuffleCarsAll()
-- 	-- do nothing if game hasnt started yet
-- 	if (REQUIRED_CHECKPOINTS == -1) then
-- 		return
-- 	end
-- 	cars = getElementsByType("exportable")
-- 	for i, v in pairs(getElementsByType("player")) do
-- 		if (not SHUFFLED_CARS[v]) then
-- 			if (REQUIRED_CHECKPOINTS == #cars) then
-- 				PRE_SHUFFLED_CARS = cars
-- 			else
-- 				if (#PRE_SHUFFLED_CARS == 0) then
-- 					for i = #cars, #cars - REQUIRED_CHECKPOINTS + 1, -1 do
-- 						randomIndex = math.random(1,i)
-- 						table.insert(PRE_SHUFFLED_CARS, cars[randomIndex])
-- 						table.remove(cars, randomIndex)
-- 					end
-- 				end
-- 			end
-- 			colorGenerator(v)
-- 			triggerClientEvent(v, "shuffle", resourceRoot, PRE_SHUFFLED_CARS)
-- 		else
-- 			colorGenerator(v)
-- 			teleportToNext(v)
-- 		end
-- 	end
-- end

-- function inStarterCarFailsafe()
-- 	for i,v in pairs(getElementsByType("player")) do
-- 		vehicle = getPedOccupiedVehicle(v)
-- 		model = getElementModel(vehicle)
-- 		if (model == 522 or model == 420 or model == 438) then
-- 			-- do nothing if game hasnt started yet
-- 			if (REQUIRED_CHECKPOINTS == -1) then
-- 				return
-- 			end
-- 			cars = getElementsByType("exportable")
-- 			if (not SHUFFLED_CARS[v]) then
-- 				if (REQUIRED_CHECKPOINTS == #cars) then
-- 					PRE_SHUFFLED_CARS = cars
-- 				else
-- 					if (#PRE_SHUFFLED_CARS == 0) then
-- 						for i = #cars, #cars - REQUIRED_CHECKPOINTS + 1, -1 do
-- 							randomIndex = math.random(1,i)
-- 							table.insert(PRE_SHUFFLED_CARS, cars[randomIndex])
-- 							table.remove(cars, randomIndex)
-- 						end
-- 					end
-- 				end
-- 				colorGenerator(v)
-- 				triggerClientEvent(v, "shuffle", resourceRoot, PRE_SHUFFLED_CARS)
-- 			else
-- 				colorGenerator(v)
-- 				teleportToNext(v)
-- 			end			
-- 		end
-- 	end
-- end
-- setTimer(inStarterCarFailsafe, 10000, 0)

-- function shuffleCarsOnePlayer(theVehicle, seat, jacked)
-- 	-- do nothing if game hasnt started yet
-- 	if (REQUIRED_CHECKPOINTS == -1) then
-- 		return
-- 	end
-- 	cars = getElementsByType("exportable")
-- 	if (not SHUFFLED_CARS[source]) then
-- 		if (REQUIRED_CHECKPOINTS == #cars) then
-- 			PRE_SHUFFLED_CARS = cars
-- 		else
-- 			if (#PRE_SHUFFLED_CARS == 0) then
-- 				for i = #cars, #cars - REQUIRED_CHECKPOINTS + 1, -1 do
-- 					randomIndex = math.random(1,i)
-- 					table.insert(PRE_SHUFFLED_CARS, cars[randomIndex])
-- 					table.remove(cars, randomIndex)
-- 				end
-- 			end
-- 		end
-- 		colorGenerator(source)
-- 		triggerClientEvent(source, "shuffle", resourceRoot, PRE_SHUFFLED_CARS)
-- 	else
-- 		colorGenerator(source)
-- 		teleportToNext(source)
-- 	end
-- end
-- addEventHandler("onPlayerVehicleEnter", root, shuffleCarsOnePlayer)

-- function nrgFailsafe(newState, oldState)
-- 	if (newState ~= "GridCountdown") then
-- 		return
-- 	end
-- 	-- poll thing, half of which I dont understand what it means
-- 	poll = exports.votemanager:startPoll {
-- 	   --start settings (dictionary part)
-- 	   title="Choose the map length:",
-- 	   percentage=75,
-- 	   timeout=11,
-- 	   allowchange=true,

-- 	   --start options (array part)
-- 	   [1]={"Shortened (5)", "pollFinished" , resourceRoot, 5},		
-- 	   [2]={"Full Experience (30)",  "pollFinished", resourceRoot, 30},
-- 	}
-- 	if not poll then
-- 		startGame(30)
-- 	end
-- 	TIMER_POLL = setTimer(startGame, 20000, 1, 30)

-- 	-- -- This might become obsolete
-- 	-- for i, v in pairs(getElementsByType("player")) do
-- 		-- if (getPedOccupiedVehicle(v) == 522) then
-- 			-- killTimer(timerPoll)
-- 			-- shuffleCars()
-- 		-- end
-- 	-- end
-- end
-- addEvent("onRaceStateChanging", true)
-- addEventHandler("onRaceStateChanging", root, nrgFailsafe)

-- function startGame(count)
-- 	killTimer(TIMER_POLL)
-- 	REQUIRED_CHECKPOINTS = count
-- 	shuffleCarsAll()
-- end
-- addEvent("pollFinished", true)
-- addEventHandler("pollFinished", resourceRoot, startGame)

-- function receiveShuffledCars(shuffledCars)
-- 	SHUFFLED_CARS[client] = shuffledCars
-- 	PLAYER_PROGRESS[client] = 1
-- 	teleportToNext(client)
-- 	colorGenerator(client)
-- end

-- function colorGenerator(player)
-- 	colors = {}
-- 	for i = 1, 4, 1 do
-- 		-- since MTA wants colors in RGB, we won't bother calculating hue. Instead, we pretend S & V are both 100% to calculate a RGB values and apply SV on them later.
-- 		-- When both S and V are 100%, the color in RGB will always have one component of 255, one of 0, and one in between.
-- 		components = {}
-- 		components[1] = 255
-- 		components[2] = 0
-- 		components[3] = math.random(0, 255)
-- 		saturation = math.random(99, 100) / 100
-- 		value = math.random(99, 100) / 100

-- 		-- this block of code determines which RGB component will be min, which max, and which the other by shuffling them.
-- 		indices = {1, 2, 3}
-- 		shuffledIndices = {}
-- 		for i = #indices, 1, -1 do
-- 			random = math.random(1,i)
-- 			shuffledIndices[i] = indices[random]
-- 			table.remove(indices, random)
-- 		end

-- 		-- now we take the min/maxed RGB components and do the saturation & value calculations on them based on the shuffled indices
-- 		for j,w in pairs(shuffledIndices) do
-- 			c = components[w]		
-- 			c = c + ((255 - c) * (1 - saturation)) 
-- 			c = c * value			
-- 			c = c - (c % 1)			
-- 			colors[j + (i - 1) * 3] = c	
-- 		end
-- 	end
-- 	-- apply our 4 generated colors the vehicle
-- 	vehicle = getPedOccupiedVehicle(player)
-- 	setVehicleColor(vehicle, colors[1], colors[2], colors[3], colors[4], colors[5], colors[6], colors[7], colors[8], colors[9], colors[10], colors[11], colors[12])
-- end

-- function teleportToNext(player)
-- 	-- get our destination
-- 	element = SHUFFLED_CARS[player][PLAYER_PROGRESS[player]]
-- 	x = getElementData(element, "posX")
-- 	y = getElementData(element, "posY")
-- 	z = getElementData(element, "posZ")
-- 	rX = getElementData(element, "rotX")
-- 	rY = getElementData(element, "rotY")
-- 	rZ = getElementData(element, "rotZ")
-- 	model = getElementData(element, "model")
-- 	-- go there
-- 	vehicle = getPedOccupiedVehicle(player)
-- 	setElementModel(vehicle, model)
-- 	setElementPosition(vehicle, x, y, z)
-- 	setElementRotation(vehicle, rX, rY, rZ)
-- 	fixVehicle(vehicle)
-- 	TELEPORTING[player] = false
-- end

-- addEvent("shuffleDone", true)
-- addEventHandler("shuffleDone", resourceRoot, receiveShuffledCars)

-- ------------------------------------------------------ Player progress ------------------------------------------------------

-- function playerStoppedInMarker()
-- 	for i,v in ipairs(getElementsByType("player")) do	
-- 		vehicle = getPedOccupiedVehicle(v)
-- 		if (vehicle) then
-- 			x, y, z = getElementVelocity(vehicle)
-- 			shittyVelocity = x*x + y*y + z*z
-- 			if (shittyVelocity < 0.001 and isElementWithinMarker(vehicle, MARKER) and not TELEPORTING[v]) then
-- 				TELEPORTING[v] = true
-- 				PLAYER_PROGRESS[v] = PLAYER_PROGRESS[v] + 1
-- 				teleportToCheckpoints(v)
-- 			end
-- 			if (getElementModel(vehicle) == 514 and shittyVelocity < 0.001 and isElementWithinMarker(vehicle, MARKER_TANKER)) then
-- 				triggerClientEvent(v, "moveCrane", resourceRoot)
-- 				--TELEPORTING[v] = true
-- 				--PLAYER_PROGRESS[v] = PLAYER_PROGRESS[v] + 1
-- 				--teleportToCheckpoints(v)
-- 			end
-- 		end
-- 	end
-- end
-- setTimer(playerStoppedInMarker, 1, 0)

-- function teleportToCheckpoints(player)
-- 	vehicle = getPedOccupiedVehicle(player)
-- 	for i = 1, PLAYER_PROGRESS[player] - 1, 1 do
-- 		x,y,z = getElementPosition(CHECKPOINTS[i])
-- 		setElementPosition(vehicle, x, y, z)
-- 	end
-- end

-- function grabCheckpoint(checkpoint, time_)
-- 	if (checkpoint < PLAYER_PROGRESS[source] - 1 and checkpoint < REQUIRED_CHECKPOINTS) then
-- 		--TELEPORTING[source] = false
-- 		teleportToCheckpoints(source)
-- 	elseif (checkpoint == REQUIRED_CHECKPOINTS) then
-- 		PLAYER_PROGRESS[source] = #getElementsByType("checkpoint") + 1
-- 		teleportToCheckpoints(source)
-- 	elseif (checkpoint < REQUIRED_CHECKPOINTS) then
-- 		teleportToNext(source)
-- 	end
-- 	if (checkpoint == REQUIRED_CHECKPOINTS - 1) then
-- 		triggerClientEvent(source, "lastCar", resourceRoot)
-- 	end
-- end
-- addEventHandler("onPlayerReachCheckpoint", getRootElement(), grabCheckpoint)

-- function finish(rank, _time)
-- 	triggerClientEvent(source, "teleportToCraneForFinish", resourceRoot)
-- 	name = getPlayerName(source)
-- 	if (REQUIRED_CHECKPOINTS == #getElementsByType("checkpoint")) then
-- 		if (DATABASE) then
-- 			dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS scoresTable (playername TEXT, score integer)")
-- 			query = dbQuery(DATABASE, "SELECT * FROM scoresTable WHERE playername = ?", name)
-- 			results = dbPoll(query, -1)		

-- 			if (results and #results > 0) then
-- 				if (_time < results[1]["score"]) then
-- 					dbExec(DATABASE, "UPDATE scoresTable SET score = ? WHERE playername = ?", _time, name)
-- 				end
-- 			else
-- 				dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", name, _time)
-- 			end
-- 			query2 = dbQuery(DATABASE, "SELECT * FROM scoresTable ORDER BY score ASC LIMIT 10")		
-- 			results = dbPoll(query2, -1)
-- 			triggerClientEvent(root, "setScoreBoard", resourceRoot, results)
-- 		else
-- 			outputChatBox("ERROR: Scores database fault", 255, 127, 0)
-- 		end	
-- 	end
-- end
-- addEventHandler("onPlayerFinish", getRootElement(), finish)


--     -- <exportable id="vehicle (Admiral) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="445" plate="EDA6OYQ" dimension="0" color="93,27,32,93,27,32,0,0,0,0,0,0" posX="-2268.8" posY="750.70001" posZ="49.3" rotX="0" rotY="0" rotZ="180"></exportable>
--     -- <exportable id="vehicle (Banshee) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="429" plate="PYPM 2TQ" dimension="0" posX="-2273.2" posY="-130.8" posZ="35.4" rotX="0" rotY="0" rotZ="270.4" color="70,89,122,70,89,122,0,0,0,0,0,0"></exportable>
--     -- <exportable id="vehicle (BF Injection) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="424" plate="7X4JGP6" dimension="0" color="132,4,16,42,119,161,0,0,0,0,0,0" posX="-2917.3999" posY="-616.70001" posZ="4" rotX="0" rotY="0" rotZ="55.5"></exportable>
--     -- <exportable id="vehicle (Blade) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="536" plate="330V OTV" dimension="0" posX="-2009.3" posY="-55.1" posZ="35" rotX="0" rotY="0" rotZ="180" color="93,126,141,245,245,245,0,0,0,0,0,0"></exportable>
--     -- <exportable id="vehicle (Blista Compact) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="496" plate="A8RF DS2" dimension="0" posX="-1674.6" posY="-563.29999" posZ="11.6" rotX="356" rotY="0" rotZ="310" color="94,112,114,214,218,214,0,0,0,0,0,0"></exportable>
--     -- <exportable id="vehicle (Buffalo) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="402" plate="MP6H4UT" dimension="0" color="105,30,59,105,30,59,0,0,0,0,0,0" posX="-1673.9399" posY="439.01999" posZ="7.01" rotX="0" rotY="0" rotZ="136"></exportable>
--     -- <exportable id="vehicle (Camper) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="483" plate="3SNFGXR" dimension="0" color="245,245,245,95,39,43,245,245,245,0,0,0" posX="-2461.2" posY="-5.6" posZ="28.1" rotX="0" rotY="0" rotZ="270"></exportable>
--     -- <exportable id="vehicle (Cheetah) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="415" plate="JB1ZVSV" dimension="0" color="59,78,120,245,245,245,0,0,0,0,0,0" posX="-2618.2" posY="155.60001" posZ="4" rotX="0" rotY="0" rotZ="270"></exportable>
--     -- <exportable id="vehicle (Comet) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="480" plate="89BI6NB" dimension="0" color="157,152,114,157,152,114,0,0,0,0,0,0" posX="-2751.79" posY="-281.5" posZ="6.81" rotX="0" rotY="0" rotZ="0"></exportable>
--     -- <exportable id="vehicle (Euros) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="587" plate="CLYN PGE" dimension="0" posX="2207.4299" posY="1286.13" posZ="10.57" rotX="0" rotY="0" rotZ="180" color="32,32,44,245,245,245,0,0,0,0,0,0"></exportable>
--     -- <exportable id="vehicle (FCR-900) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="521" plate="5BV4 NVD" dimension="0" posX="-2025.9" posY="123.1" posZ="28.8" rotX="0" rotY="0" rotZ="182" color="63,62,69,163,173,198,0,0,0,0,0,0"></exportable>
--     -- <exportable id="vehicle (Feltzer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="533" plate="X8HFL14" dimension="0" color="96,26,35,245,245,245,0,0,0,0,0,0" posX="-1752.6" posY="954.40002" posZ="24.5" rotX="0" rotY="0" rotZ="74"></exportable>
--     -- <exportable id="vehicle (Freeway) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="463" plate="6H3EX3F" dimension="0" color="14,49,109,14,49,109,0,0,0,0,0,0" posX="-2590.3999" posY="73.2" posZ="4.1" rotX="0" rotY="0" rotZ="42"></exportable>
--     -- <exportable id="vehicle (Huntley) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="579" plate="BVLS KVN" dimension="0" posX="-2068.6899" posY="-83.75" posZ="35.1" rotX="0" rotY="0" rotZ="0" color="124,28,42,124,28,42,0,0,0,0,0,0"></exportable>
--     -- <exportable id="vehicle (Infernus) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="411" plate="6UWMFK3" dimension="0" color="114,42,63,245,245,245,0,0,0,0,0,0" posX="-2665.4399" posY="990.77002" posZ="64.45" rotX="0" rotY="0" rotZ="51"></exportable>
--     -- <exportable id="vehicle (Journey) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="508" plate="H33Y L3X" dimension="0" posX="-1623.6" posY="-1616.3" posZ="36.7" rotX="0" rotY="0" rotZ="114" color="245,245,245,245,245,245,0,0,0,0,0,0"></exportable>
--     -- <exportable id="vehicle (Mesa) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="500" plate="1RXF KDD" dimension="0" posX="-2406.25" posY="-2180.8401" posZ="33.39" rotX="0" rotY="0" rotZ="180" color="115,46,62,105,88,83,0,0,0,0,0,0"></exportable>
--     -- <exportable id="vehicle (Patriot) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="470" plate="E91BXCK" dimension="0" color="95,10,21,0,0,0,0,0,0,0,0,0" posX="-1006.41" posY="-628.27002" posZ="32" rotX="0" rotY="0" rotZ="270"></exportable>
--     -- <exportable id="vehicle (Rancher) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="489" plate="XC9GMLD" dimension="0" color="164,160,150,171,146,118,0,0,0,0,0,0" posX="-2030.1" posY="122.8" posZ="29.4" rotX="0" rotY="0" rotZ="175.997"></exportable>
--     -- <exportable id="vehicle (Remington) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="534" plate="JIUQEZ8" dimension="0" color="45,58,53,45,58,53,0,0,0,0,0,0" posX="-2449.5" posY="-122" posZ="26" rotX="0" rotY="0" rotZ="288"></exportable>
--     -- <exportable id="vehicle (Sabre) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="475" plate="ZZIC Y3H" dimension="0" posX="-1898.4" posY="-92.5" posZ="21.2" rotX="15.996" rotY="0" rotZ="38.507" color="94,112,114,109,122,136,0,0,0,0,0,0"></exportable>
--     -- <exportable id="vehicle (Sanchez) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="468" plate="QIW851E" dimension="0" color="215,142,16,215,142,16,0,0,0,0,0,0" posX="-2486.0459" posY="59.2" posZ="25.6" rotX="0" rotY="0" rotZ="180"></exportable>
--     -- <exportable id="vehicle (Sentinel) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="405" plate="855NJW7" dimension="0" color="37,37,39,245,245,245,0,0,0,0,0,0" posX="-2694.7" posY="825.09998" posZ="50" rotX="0" rotY="0" rotZ="358"></exportable>
--     -- <exportable id="vehicle (Slamvan) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="535" plate="3ZCFAIR" dimension="0" color="61,74,104,245,245,245,0,0,0,0,0,0" posX="-2024.1" posY="123.4" posZ="29" rotX="0" rotY="0" rotZ="358"></exportable>
--     -- <exportable id="vehicle (Stafford) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="580" plate="AXX4 B0E" dimension="0" posX="-2430.22" posY="320.84" posZ="34.97" rotX="0" rotY="0" rotZ="245" color="109,108,110,109,108,110,0,0,0,0,0,0"></exportable>
--     -- <exportable id="vehicle (Stallion) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="439" plate="FHYWBO2" dimension="0" color="189,190,198,115,14,26,0,0,0,0,0,0" posX="-1796.9" posY="-130.39999" posZ="5.7" rotX="0" rotY="0" rotZ="0"></exportable>
--     -- <exportable id="vehicle (Stretch) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="409" plate="2ZBIGX4" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="-1922.1899" posY="288.34" posZ="40.84" rotX="0" rotY="0" rotZ="180"></exportable>
--     -- <exportable id="vehicle (Super GT) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="506" plate="NUFY BMH" dimension="0" posX="-2093.8999" posY="-83.7" posZ="35.2" rotX="0" rotY="0" rotZ="359.1" color="77,98,104,77,98,104,0,0,0,0,0,0"></exportable>
--     -- <exportable id="vehicle (Tanker) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="514" plate="6TCRKYH" dimension="0" color="61,74,104,245,245,245,0,0,0,0,0,0" posX="-1747.6" posY="-1166.3" posZ="55.7" rotX="0" rotY="0" rotZ="206"></exportable>
--     -- <exportable id="vehicle (ZR-350) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="477" plate="G6OQ ID2" dimension="0" posX="-2007.9" posY="364.79999" posZ="34.9" rotX="0" rotY="0" rotZ="180" color="109,108,110,245,245,245,0,0,0,0,0,0"></exportable>

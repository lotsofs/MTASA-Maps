-- TODO:
-- Runway indicators on map
-- Go through rpoblematic spawns and replace the ground where needed (eg. the underground popo garages)
-- Hide boat icon if not in boat
-- Move transparency code client side
-- Add pedestrians as spectators as some sort of endurance reward. Make them no collision. Maybe other decorations as well.
-- Add points mechanic for damage
-- None of this crap about it into a LEFT PLAYERS table, just index with player serials everywhere
-- Crane one really likes to make 350 degree turns, but doesn't affect the actual deliveries. Only visual.
-- Add options for no planes, boats, etc
-- you could inform the client of the required_cp_count and do the collectCP *before* communicating with the server
-- nth: Output to text
-- blank box for newcomers (leaderboard)

-- Test: Tropic bridge behavior
-- Test: Heli blade collisions (others and yours)
-- Flying a plane kamikaze into the marker can trigger a succesful delivery. Don't
-- Find bug that causes deliveries upon random death far away



-- DONE - a script that teleports players to a car at the start
-- DONE - a script that detects the player inside the marker
-- DONE - a script that teleports players to a new car
-- DONE (unintentiallo) - a script that sets the respawn point for players
-- DONE (maybe) - a script that detects the player being inside a tanker and moving the marker for it
-- DONE - move stuff server side for security
-- DONE - repair car on teleport
-- DONE - intermediate checkpoints
-- DONE - fix coordinates for sanchez etc
-- DONE - spamming suicide = skip checkpoints
-- DONE - colorful cars
-- DONE - crane
-- DONE - blip
-- DONE - voting at start for length
-- DONE - leaderboard for 30 minute
-- DONE - make leaderboard disappear after a while, and reappear upon the end, and maybe upon the press of a button
-- DONE - add players to the leaderboard when they finish
-- DONE - taxi driver
-- DONE - make tanker be craned
-- DONE - magnet raised by 2Z then lowered by 4Z
-- DONE - check if player drove their truck off the ship or died somehow on the ship
-- DONE - shuffle is not called on laptop
-- DONE - use the new crane technology to attach the player to it when they finish
-- DONE - people entering --> line 208 in server, attempt to perform arithmetic on a nil value
-- DONE - outputchatbox


-- DONE - Allow tanks to fire without damaging other players
-- DONE - Bicycles were unable to hop. Fix
-- DONE - Make the cranes work
-- DONE - Tweak cranes if needed
-- DONE - Make work for players joining midway through
-- DONE - Boat Detector: Could probably shave the eastern edge of the boat hitbox further west since you'll only be approaching with a Reefer from that direction. West and southern border are fine.
-- DONE - Repair boats maybe
-- DONE - Protection when landing big planes such as AT-400
-- DONE - Can bicycles cheese the non-collision fence? Fix
-- DONE - There's a failsafe for new players joining (is it needed?). But this triggers by them being in a 'wrong' vehicle. However, there are no wrong vehicles. Workaround.
-- DONE - Map loading upon teleporting. If I can't find a way to preload map regions, I think I'll just have to do a freeze before move, or do the hold the line thing.
-- DONE - Base on the vehicle how high the hook goes. Some dont need to go high. Others do.
-- DONE - Trains
-- DONE - Cranes still seem to bug out sometimes particularly with trains/trailers that spawn inside the area. Fixed by KYS, but not ideal
-- DONE - Test: One of the trains does not spawn in range ( the one across from handin marker)
-- DONE - Some tall light poles can have visual collisions on the crane. Maybe lower them or delete them or sth.
-- DONE - Spectate ghost thing. Do an additional failsafe for if someone respawns in the air above the marker and stays there.
-- DONE - (Cant fix, MTA limitation) Heli blades disable for otherr players but not self
-- DONE - SpeedyFolf parked in the marker but it didnae work?
-- DONE - Progress save system
-- DONE - On reosurce end/wgeb fuinishing a race, restore all control (vehicle fire/secondary fire)
-- DONE - Spawn area
-- DONE - Tropic Doesn't fit under the bridge
-- DONE - Cranes do not seem to get reset properly upon delivering a vehicle with them
-- DONE - Boats get delivered before dropping to the ground
-- DONE - Reset cranes on death
-- DONE - Trains and trailers: Instant hook pls
-- DONE - Train in corner that was bad before clips through the wall behind it
-- DONE - Joining messes up the disabled guns in hunter etc -- Probably because of cheat over/underflow. Needs more investigating
-- DONE - Janky launch spawns. Need to freeze probably.
-- DONE - !!! Dying on the cranes fucks them up
-- DONE - Reset PRogress broke chief
-- DONE - Tutorial cutscene
-- DONE - Upon laoding, do players instantly get CPd?
-- DONE - Finale outro cutscene. Lots of errors currently and youre just floating.
-- DONE - Add a noob friendlier option for planes that's really slow. Perhaps using cranes.
-- DONE - Test the fucking planes!
-- DONE - Coach & look over other vehicles again
-- DONE - Farm & Ladder trailer bounces a lot and then dies or doesnt hit the marker, Yes this is actually important
-- DONE - Cheat Spectate
-- DONE - Test the 212 CP proper
-- DONE - meta..
-- DONE - Dont forget to remove the cheats, debug levels, and iprsints when publishuing this thing
-- DONE - Move pizzaboy
-- DONE - Add small planes to the boat list
-- DONE - Add some disco lights or something when last vehicle is being delivered?
-- DONE - There's an error in line 245 (if CUR > new + 1), but the bug report is not very good.
-- DONE - Saved progress persists between map sessions?

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

VEHICLES_WITH_GUNS = {
	[425] = true, -- hunter
	[430] = true, -- predator
	[447] = true, -- seaspar
	[464] = true, -- rcbaron
	[476] = true  -- rustler
} -- do not delete

-- BOATS = {
-- 	[430] = true, -- predator
-- 	[446] = true, -- squalo
-- 	[452] = true, -- speeder
-- 	[453] = true, -- reefer
-- 	[454] = true, -- tropic
-- 	[472] = true, -- coastg
-- 	[473] = true, -- dinghy
-- 	[484] = true, -- marquis
-- 	[493] = true, -- jetmax
-- 	[595] = true, -- launch
	
-- 	[435] = true, -- artict1
-- 	[450] = true, -- artict2
-- 	[584] = true, -- petrotr
-- 	[591] = true, -- artict3
-- 	[608] = true, -- tugstair
-- 	[610] = true, -- farmtr1
	
-- 	[449] = true, -- tram
-- 	[537] = true, -- freight
-- 	[538] = true, -- streak
-- 	[569] = true, -- freiflat
-- 	[570] = true, -- streakc
-- 	[590] = true  -- freibox
-- }

TRAINS = {
	[449] = true, -- tram
	[537] = true, -- freight
	[538] = true, -- streak
	[569] = true, -- freiflat
	[570] = true, -- streakc
	[590] = true  -- freibox
} -- do not delete

DATABASE = dbConnect("sqlite", ":/mapSuperFleischbergAutos.db")
	
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

function newJoineeMarkerHit(markerHit, matchingDimension, dumpVariable)
	if (markerHit ~= MARKER_START and marketHit ~= nil) then
		return
	end
	if (getElementType(source) ~= "player") then
		return
	end

	-- if (#CHOSEN_CARS == 0) then
	-- 	-- Race hasn't started yet
	-- 	return
	-- end
	local sipp = SHUFFLED_INDICES_PER_PLAYER[source]
	if (sipp ~= nil and #sipp > 0) then
		-- This player is not new
		-- shuffleCarsPerPlayer(source)
		return
	end

	triggerClientEvent ( source, "gridCountdownStarted", resourceRoot )
	setTimer(function(whom)
		shuffleCarsPerPlayer(whom)
	end, (CUTSCENE_LENGTH_IN_SECONDS+0.5)*1000, 1, source)
end
addEventHandler("onPlayerMarkerHit", root, newJoineeMarkerHit)

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
	if (TRAINS[model]) then
		setTrainDerailed(vehicle, true)
	end

	if (VEHICLES_WITH_GUNS[model]) then
		toggleControl(player, 'vehicle_secondary_fire', false)
		if (model == 430) then -- predator
			toggleControl(player, 'vehicle_fire', false)
		end
	else
		toggleControl(player, 'vehicle_fire', true)
		toggleControl(player, 'vehicle_secondary_fire', true)
	end

	-- setElementFrozen(vehicle, true)
	setMovementControls(player, false)
	setElementPosition(vehicle, x, y, z)
	setElementAngularVelocity(vehicle, 0, 0, 0)
	setElementVelocity(vehicle, 0, 0, 0)
	setElementRotation(vehicle, rX, rY, rZ)
	fixVehicle(vehicle)
	setElementAlpha ( vehicle, 0 ) 
	setCameraTarget ( player, player )

	if (progress == 1 and model == 581) then
		iprint("BF START. DEBUG PLS ", getPlayerName(player))
		setTimer( function(vehiclee, xx, yy, zz, rrX, rrY, rrZ)
			-- setElementFrozen(vehicle, true)
			setElementPosition(vehiclee, xx, yy, zz)
			setElementAngularVelocity(vehiclee, 0, 0, 0)
			setElementVelocity(vehiclee, 0, 0, 0)
			setElementRotation(vehiclee, rrX, rrY, rrZ)
			fixVehicle(vehiclee)
		end, 1500, 1, vehicle, x, y, z, rX, rY, rZ)
	end

	setTimer( function(vehicle)
		if (not isElement(vehicle)) then
			return
		end
		setElementAlpha(vehicle, math.min(255, getElementAlpha(vehicle) + 17))
	end, 100, 16, vehicle)

	setTimer ( function(player)
		if (not isElement(player)) then
			-- player left
			return
		end
		setElementAlpha ( vehicle, 255 ) 
		setMovementControls(player, true)
		triggerClientEvent(player, "playGoSound", resourceRoot)
	end, 2000, 1, player)
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
		PLAYER_PROGRESS[client] = progress
		teleportToNext(progress, client)
		triggerClientEvent(client, "updateTarget", client, progress)
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
	if (newState ~= "GridCountdown") then
		return
	end
	triggerClientEvent ( root, "gridCountdownStarted", resourceRoot )
	startRacePoll()
	setTimer(startGame, (CUTSCENE_LENGTH_IN_SECONDS+0.5)*1000, 1)

	-- -- This might become obsolete
	-- for i, v in pairs(getElementsByType("player")) do
		-- if (getPedOccupiedVehicle(v) == 522) then
			-- killTimer(timerPoll)
			-- shuffleCars()
		-- end
	-- end
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, raceStateChanged)

function startRacePoll()
	exports.votemanager:stopPoll {}
	POLL_ACTIVE = true
	-- poll thing, half of which I dont understand what it means
	poll = exports.votemanager:startPoll {
		--start settings (dictionary part)
		title="Choose the map length:",
		percentage=100,
		timeout=CUTSCENE_LENGTH_IN_SECONDS,
		allowchange=true,

		--start options (array part)
		[1]={"A Basic Race (1)", "pollFinished" , resourceRoot, 1},		
		[2]={"Double It Up (2)", "pollFinished" , resourceRoot, 2},		
		[3]={"Post SSA Instadeliveries (3)", "pollFinished" , resourceRoot, 3},		
		[4]={"Tetrad (4)", "pollFinished" , resourceRoot, 4},		
		[5]={"Bite Sized Chunk (5)", "pollFinished" , resourceRoot, 5},		
		--[6]={"One List (10)", "pollFinished" , resourceRoot, 10},			
		--[7]={"Classic (30)", "pollFinished" , resourceRoot, 30},			
		--[8]={"Extended (100)", "pollFinished", resourceRoot, 100},
		--[9]={"Full Experience (212)", "pollFinished", resourceRoot, 212},
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
	elseif (pollResult == 2) then
		customMapName = customMapName .. " (Double It Up)"
	elseif (pollResult == 3) then
		customMapName = customMapName .. " (Post SSA Instadeliveries)"
	elseif (pollResult == 4) then
		customMapName = customMapName .. " (Tetrad)"
	elseif (pollResult == 5) then
		customMapName = customMapName .. " (Bite Sized Chunk)"
	elseif (pollResult == 10) then
		customMapName = customMapName .. " (One List)"
	elseif (pollResult == 30) then
		customMapName = customMapName .. " (Classic)"
	elseif (pollResult == 100) then
		customMapName = customMapName .. " (Extended)"
	elseif (pollResult == 212) then
		customMapName = customMapName .. " (Full Experience)"
	end
	setMapName ( customMapName )
	
	-- THe default top times manager does not respond to the above. So send it an event so it does
	-- It appears that the leguaan server has their own thing for this, idk what. Strip this out for them
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

function setMovementControls(player, enabled)
	toggleControl(player, 'vehicle_left', enabled)
	toggleControl(player, 'vehicle_right', enabled)
	toggleControl(player, 'steer_forward', enabled)
	toggleControl(player, 'steer_back', enabled)
	toggleControl(player, 'brake_reverse', enabled)
	toggleControl(player, 'accelerate', enabled)
	toggleControl(player, 'special_control_up', enabled)
	toggleControl(player, 'special_control_down', enabled)
end

---------------------------------
---------------------------------

function cleanup(stoppedResource)
	for i, v in ipairs(getElementsByType("player")) do
		toggleControl(v, 'vehicle_fire', true)
		toggleControl(v, 'vehicle_secondary_fire', true)
		toggleControl(v, 'vehicle_left', true)
		toggleControl(v, 'vehicle_right', true)
		toggleControl(v, 'steer_forward', true)
		toggleControl(v, 'steer_back', true)
		toggleControl(v, 'brake_reverse', true)
		toggleControl(v, 'accelerate', true)
		toggleControl(v, 'special_control_up', true)
		toggleControl(v, 'special_control_down', true)
	end
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
	-- iprint("[FleischBerg Autos] Autosaving")
	if (DATABASE) then
		for i, v in pairs(getElementsByType("player")) do
			s = getPlayerSerial(v)
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


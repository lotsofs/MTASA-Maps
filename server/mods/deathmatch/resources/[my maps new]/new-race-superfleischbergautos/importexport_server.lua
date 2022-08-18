-- TODO:
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
	[476] = true,
	[447] = true,
	[430] = true,
	[464] = true,
	[425] = true
} -- do not delete

BOATS = {
	[472] = true,
	[473] = true,
	[493] = true,
	[595] = true,
	[484] = true,
	[430] = true,
	[453] = true,
	[452] = true,
	[446] = true,
	[454] = true,
	
	[610] = true,
	[584] = true,
	[608] = true,
	[435] = true,
	[450] = true,
	[591] = true,
	
	[590] = true,
	[538] = true,
	[570] = true,
	[569] = true,
	[537] = true,
	[449] = true
}

TRAINS = {
	[590] = true,
	[538] = true,
	[570] = true,
	[569] = true,
	[537] = true,
	[449] = true
} -- do not delete

DATABASE = dbConnect("sqlite", ":/mapSuperFleischbergAutos.db")
	
------------------------------------------------------ Start of race ------------------------------------------------------

function shuffleCarsAll()
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
		shuffleCarsOne(v)
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

function shuffleCarsOne(whose)
	if (#CHOSEN_CARS == 0) then
		-- Race hasn't started yet
		return
	end
	if (sipp ~= nil and #sipp > 0) then
		-- This player is not new
		return
	end
	
	local serial = getPlayerSerial(whose)
	if (LEFT_PLAYERS_PROGRESS[serial]) then
		PLAYER_PROGRESS[whose] = LEFT_PLAYERS_PROGRESS[serial]
		LEFT_PLAYERS_PROGRESS[serial] = nil
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
	end
	-- triggerClientEvent ( whose, "configureCrane", resourceRoot )
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
		-- shuffleCarsOne(source)
		return
	end

	triggerClientEvent ( source, "configureCrane", resourceRoot )
	setTimer(function(whom)
		shuffleCarsOne(whom)
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
	disableMovementControls(player, true)
	setElementPosition(vehicle, x, y, z)
	setElementAngularVelocity(vehicle, 0, 0, 0)
	setElementVelocity(vehicle, 0, 0, 0)
	setElementRotation(vehicle, rX, rY, rZ)
	fixVehicle(vehicle)
	setElementAlpha ( vehicle, 0 ) 
	setCameraTarget ( player, player )

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
		disableMovementControls(player, false)
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

function startRacePoll(newState, oldState)
	if (newState ~= "GridCountdown") then
		return
	end
	triggerClientEvent ( root, "configureCrane", resourceRoot )
	
	POLL_ACTIVE = true
	-- poll thing, half of which I dont understand what it means
	poll = exports.votemanager:startPoll {
	--start settings (dictionary part)
	title="Choose the map length:",
	percentage=100,
	timeout=CUTSCENE_LENGTH_IN_SECONDS,
	allowchange=true,

	--start options (array part)
	[1]={"Bite Sized Chunk (5)", "pollFinished" , resourceRoot, 5},		
	[2]={"One List (10)", "pollFinished" , resourceRoot, 10},			
	[3]={"Classic (30)", "pollFinished" , resourceRoot, 30},			
	[4]={"Full Experience (212)", "pollFinished", resourceRoot, 212},
	}
	if not poll then
		applyPollResult(20)
	end
	
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
addEventHandler("onRaceStateChanging", root, startRacePoll)

function applyPollResult(pollResult)
	REQUIRED_CHECKPOINTS = pollResult
end
addEvent("pollFinished", true)
addEventHandler("pollFinished", resourceRoot, applyPollResult)

function startGame()
	POLL_ACTIVE = false
	shuffleCarsAll()
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

function disableMovementControls(player, yes)
	yes = not yes
	toggleControl(player, 'vehicle_left', yes)
	toggleControl(player, 'vehicle_right', yes)
	toggleControl(player, 'steer_forward', yes)
	toggleControl(player, 'steer_back', yes)
	toggleControl(player, 'brake_reverse', yes)
	toggleControl(player, 'accelerate', yes)
	toggleControl(player, 'special_control_up', yes)
	toggleControl(player, 'special_control_down', yes)
end

------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------

function cheatResetProgress(playerSource, commandName)
	outputChatBox ( "Resetting Progress", playerSource, 255, 127, 127, true )
	SHUFFLED_INDICES_PER_PLAYER[playerSource] = {}
	PLAYER_PROGRESS[playerSource] = 1
	shuffleCarsOne(playerSource)
	triggerClientEvent(playerSource, "updateTarget", playerSource, PLAYER_PROGRESS[playerSource])
end
addCommandHandler("resetprogress", cheatResetProgress)

-- function cheatSkipVehicle(playerSource, commandName)
-- 	progress = PLAYER_PROGRESS[playerSource] + 1
-- 	if (progress > REQUIRED_CHECKPOINTS) then
-- 		return
-- 	end
-- 	PLAYER_PROGRESS[playerSource] = progress
	
-- 	teleportToNext(progress, playerSource)
-- 	triggerClientEvent(playerSource, "updateTarget", playerSource, progress)
-- end
-- addCommandHandler("cheatnext", cheatSkipVehicle)

function cheatSkipForPlayer(playerSource, commandName, name)
	if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(playerSource)), aclGetGroup ("Admin")) then
		local playa = getPlayerFromName ( name )
		if (not playa) then
			iprint("[FleischBerg Autos] no such player")
			return
		end

		progress = PLAYER_PROGRESS[playa] + 1
		if (progress > REQUIRED_CHECKPOINTS) then
			return
		end
		PLAYER_PROGRESS[playa] = progress
		
		teleportToNext(progress, playa)
		triggerClientEvent(playa, "updateTarget", playa, progress)
	end
end
addCommandHandler("ie_cheatSkipForPlayer", cheatSkipForPlayer )

-- function cheatFlipVehicle(playerSource, commandName)
-- 	vehicle = getPedOccupiedVehicle(playerSource)
-- 	setElementRotation(vehicle, 0, 180, 0)
-- end
-- addCommandHandler("cheatflip", cheatFlipVehicle)

-- function cheatPrevVehicle(playerSource, commandName)
-- 	progress = PLAYER_PROGRESS[playerSource] - 1
-- 	if (progress == 0) then
-- 		return
-- 	end
-- 	PLAYER_PROGRESS[playerSource] = progress
	
-- 	teleportToNext(progress, playerSource)
-- 	triggerClientEvent(playerSource, "updateTarget", playerSource, progress)
-- end
-- addCommandHandler("cheatprev", cheatPrevVehicle)

-- function cheatTeleportVehicle(playerSource, commandName)
-- 	vehicle = getPedOccupiedVehicle(playerSource)
-- 	setElementPosition(vehicle, 0, 0, 20)
-- end
-- addCommandHandler("cheattp", cheatTeleportVehicle)

-- function cheatTeleportVehicleOp(playerSource, commandName)
-- 	vehicle = getPedOccupiedVehicle(playerSource)
-- 	setElementPosition(vehicle, 5, -241, 20)
-- end
-- addCommandHandler("cheattpop", cheatTeleportVehicleOp)

-- function cheatTeleportBoat(playerSource, commandName)
-- 	vehicle = getPedOccupiedVehicle(playerSource)
-- 	setElementPosition(vehicle, -219, -604, 20)
-- end
-- addCommandHandler("cheattpboat", cheatTeleportBoat)

---------------------------------
---------------------------------
---------------------------------
---------------------------------
---------------------------------
---------------------------------
---------------------------------
---------------------------------

function finish(rank, _time)
	name = getPlayerName(source)
	RACE_FINISHED = true
	if (DATABASE) then
		dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS progressTable (serial TEXT, progress INTEGER, indices TEXT)")
		local s = getPlayerSerial(source)
		local query = dbQuery(DATABASE, "SELECT * FROM progressTable WHERE serial=? LIMIT 1", s)
		local results = dbPoll(query, -1)
		if (results and #results > 0) then
			dbExec(DATABASE, "DELETE FROM progressTable WHERE serial=?", s)
		end
		if (REQUIRED_CHECKPOINTS == #getElementsByType("checkpoint")) then
			dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS scoresTable (playername TEXT, score integer)")
			query = dbQuery(DATABASE, "SELECT * FROM scoresTable WHERE playername = ?", name)
			results = dbPoll(query, -1)		
			if (LOADED_GAME_FROM_DB) then
				return
			end
			if (results and #results > 0) then
				if (_time < results[1]["score"]) then
					dbExec(DATABASE, "UPDATE scoresTable SET score = ? WHERE playername = ?", _time, name)
				end
			else
				dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", name, _time)
			end
			query2 = dbQuery(DATABASE, "SELECT * FROM scoresTable ORDER BY score ASC LIMIT 10")		
			results = dbPoll(query2, -1)
			triggerClientEvent(root, "setScoreBoard", resourceRoot, results)
		else
			outputChatBox("ERROR: Scores database fault", 255, 127, 0)
		end	
	end
end
addEventHandler("onPlayerFinish", getRootElement(), finish)


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
			local json = toJSON(SHUFFLED_INDICES_PER_PLAYER[v])
			if (results and #results > 0) then
				dbExec(DATABASE, "UPDATE progressTable SET progress = ?, indices = ? WHERE serial = ?", PLAYER_PROGRESS[v], json, s)
			else
				dbExec(DATABASE, "INSERT INTO progressTable(serial, progress, indices) VALUES (?,?,?)", getPlayerSerial(v), PLAYER_PROGRESS[v], json)
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

-- database stuff
-- --------------

function showScores(newState, oldState)
	if (newState == "Running") then
		-- triggerClientEvent(root, "setScoreBoard", resourceRoot, results)
		triggerClientEvent(root, "showScoreBoard", resourceRoot, true, 31000)
		return
	elseif (newState == "GridCountdown") then
		if (DATABASE) then
			-- read the database
			dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS scoresTable (playername TEXT, score integer)")
			query = dbQuery(DATABASE, "SELECT * FROM scoresTable ORDER BY score ASC LIMIT 10")
			results = dbPoll(query, -1)
			triggerClientEvent(root, "setScoreBoard", resourceRoot, results)
			triggerClientEvent(root, "showScoreBoard", resourceRoot, true, nil)
		else
			outputChatBox("ERROR: Scores database fault", 255, 127, 0)
		end
	elseif (newState == "TimesUp" or newState == "EveryoneFinished" or newState == "PostFinish" or newState == "SomeoneWon") then
		triggerClientEvent(root, "showScoreBoard", resourceRoot, true, nil)
	end
end
addEventHandler("onRaceStateChanging", root, showScores)
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
-- people entering --> line 208 in server, attempt to perform arithmetic on a nil value
-- DONE - outputchatbox


-- DONE - Allow tanks to fire without damaging other players
-- DONE - Bicycles were unable to hop. Fix
-- DONE - Make the cranes work
-- Tweak cranes if needed
-- Make work for players joining midway through
-- DONE - Boat Detector: Could probably shave the eastern edge of the boat hitbox further west since you'll only be approaching with a Reefer from that direction. West and southern border are fine.
-- DONE - Repair boats maybe
-- DONE - Protection when landing big planes such as AT-400
-- DONE - Can bicycles cheese the non-collision fence? Fix
-- Tutorial cutscene & more polls
-- There's a failsafe for new players joining (is it needed?). But this triggers by them being in a 'wrong' vehicle. However, there are no wrong vehicles. Workaround.
-- Map loading upon teleporting. If I can't find a way to preload map regions, I think I'll just have to do a freeze before move, or do the hold the line thing.
-- Add options for no planes, boats, etc
-- Janky launch spawns. Need to freeze probably.
-- Base on the vehicle how high the hook goes. Some dont need to go high. Others do.
-- DONE - Trains
-- Runway indicators on map?
-- Coach
-- Cranes still seem to bug out sometimes particularly with trains/trailers that spawn inside the area. Fixed by KYS, but not ideal
-- Test: One of the trains does not spawn in range ( the one across from handin marker)
-- Some tall light poles can have visual collisions on the crane. Maybe lower them or delete them or sth.
-- Finale outro cutscene. Lots of errors currently and youre just floating.
-- DONE - Spectate ghost thing. Do an additional failsafe for if someone respawns in the air above the marker and stays there.
-- Ladder trailer bounces a lot and then dies or doesnt hit the marker
-- DONE (Cant fix, MTA limitation) - Heli blades disable for otherr players but not self
-- SpeedyFolf parked in the marker but it didnae work?
-- Progress save system
-- DONE - On reosurce end/wgeb fuinishing a race, restore all control (vehicle fire/secondary fire)
-- Spawn area
-- DONE - Tropic Doesn't fit under the bridge
-- Add pedestrians as spectators as some sort of endurance reward. Make them no collision. Maybe other decorations as well.
-- Add a noob friendlier option for planes that's really slow. Perhaps using cranes.
-- nth: Output to text
-- Cranes do not seem to get reset properly upon delivering a vehicle with them
-- DONE - Boats get delivered before dropping to the ground
-- DONE - Reset cranes on death
-- Trains and trailers: Instant hook pls

CHECKPOINT = {}
CHECKPOINTS = getElementsByType("checkpoint")

REQUIRED_CHECKPOINTS = -1
TIMER_POLL = nil

CHOSEN_CARS = {}
SHUFFLED_INDICES_PER_PLAYER = {}
PLAYER_PROGRESS = {}

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

DATABASE = dbConnect("sqlite", ":/fleischbergAutosTopTimes.db")
	
------------------------------------------------------ Start of race ------------------------------------------------------

function shuffleCarsAll()
	local cars = getElementsByType("exportable")
	if (REQUIRED_CHECKPOINTS == #cars) then
		CHOSEN_CARS = cars
	else
		for i = #cars, #cars - REQUIRED_CHECKPOINTS + 1, -1 do
			randomIndex = math.random(1,i)
			table.insert(CHOSEN_CARS, cars[randomIndex])
			table.remove(cars, randomIndex)
		end
	end
	for i, v in pairs(getElementsByType("player")) do
		local intsTable = {}
		SHUFFLED_INDICES_PER_PLAYER[v] = {}
		for i = #CHOSEN_CARS, 1, -1 do
			table.insert(intsTable, i)
		end
		for i = #intsTable, 1, -1 do
			randomIndex = math.random(1,i)
			table.insert(SHUFFLED_INDICES_PER_PLAYER[v], intsTable[randomIndex])
			table.remove(intsTable, randomIndex)
		end

		setPlayerScriptDebugLevel(v, 3)
		colorGenerator(v)
		PLAYER_PROGRESS[v] = 1
		teleportToNext(1, v)
	end
end

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

	setElementPosition(vehicle, x, y, z)
	setElementRotation(vehicle, rX, rY, rZ)
	fixVehicle(vehicle)
end

function updateProgress(target)
	progress = target + 1

	if (getElementData(client, "race.finished")) then
		iprint("iprint")
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

-- function inStarterCarFailsafe()
-- 	for i,v in pairs(getElementsByType("player")) do
-- 		vehicle = getPedOccupiedVehicle(v)
-- 		model = getElementModel(vehicle)
-- 		-- if (model == 522 or model == 420 or model == 438) then
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
-- 			-- else
-- 				-- colorGenerator(v)
-- 				-- teleportToNext(v)
-- 			end			
-- 		-- end
-- 	end
-- end
-- setTimer(inStarterCarFailsafe, 10000, 0)

function playerRespawn(theVehicle, seat, jacked)
	-- do nothing if game hasnt started yet
	if (REQUIRED_CHECKPOINTS == -1) then
		return
	end
	colorGenerator(source)
	teleportToNext(PLAYER_PROGRESS[source], source)
end
addEventHandler("onPlayerVehicleEnter", root, playerRespawn)

function nrgFailsafe(newState, oldState)
	if (newState ~= "GridCountdown") then
		return
	end
	triggerClientEvent ( root, "configureCrane", resourceRoot )
	-- poll thing, half of which I dont understand what it means
	poll = exports.votemanager:startPoll {
	   --start settings (dictionary part)
	   title="Choose the map length:",
	   percentage=75,
	   timeout=11,
	   allowchange=true,

	   --start options (array part)
	   [1]={"Bite Sized Chunk (5)", "pollFinished" , resourceRoot, 5},		
	   [2]={"One List (10)", "pollFinished" , resourceRoot, 10},			
	   [3]={"Classic (30)", "pollFinished" , resourceRoot, 30},			
	   [4]={"Full Experience (212)", "pollFinished", resourceRoot, 212},
	}
	if not poll then
		startGame(30)
	end
	TIMER_POLL = setTimer(startGame, 20000, 1, 30)

	-- -- This might become obsolete
	-- for i, v in pairs(getElementsByType("player")) do
		-- if (getPedOccupiedVehicle(v) == 522) then
			-- killTimer(timerPoll)
			-- shuffleCars()
		-- end
	-- end
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, nrgFailsafe)

function startGame(pollResult)
	killTimer(TIMER_POLL)
	REQUIRED_CHECKPOINTS = pollResult
	shuffleCarsAll()
end
addEvent("pollFinished", true)
addEventHandler("pollFinished", resourceRoot, startGame)

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
-- 	model = tonumber(model)
-- 	-- go there
-- 	local vehicle = getPedOccupiedVehicle(player)
-- 	setElementModel(vehicle, model)
-- 	if (TRAINS[model]) then
-- 		setTrainDerailed(vehicle, true)
-- 	end

-- 	if (VEHICLES_WITH_GUNS[model]) then
-- 		toggleControl(player, 'vehicle_secondary_fire', false)
-- 		if (model == 430) then -- predator
-- 			toggleControl(player, 'vehicle_fire', false)
-- 		end
-- 	else
-- 		toggleControl(player, 'vehicle_fire', true)
-- 		toggleControl(player, 'vehicle_secondary_fire', true)
-- 	end

-- 	setElementPosition(vehicle, x, y, z)
-- 	setElementRotation(vehicle, rX, rY, rZ)
-- 	fixVehicle(vehicle)
-- 	PLAYER_TRAIN_IN_MARKER[player] = false
-- 	TELEPORTING[player] = false
-- 	triggerClientEvent(player, "makeCranesAvailable", resourceRoot)
-- end

-- addEvent("shuffleDone", true)
-- addEventHandler("shuffleDone", resourceRoot, receiveShuffledCars)

------------------------------------------------------ Player progress ------------------------------------------------------

-- function playerStoppedInMarker()
-- 	for i,v in ipairs(getElementsByType("player")) do	
-- 		local x, y, z = getElementPosition(v)
-- 		if (z > 1000) then
-- 			return
-- 		end
-- 		local vehicle = getPedOccupiedVehicle(v)
-- 		if (vehicle) then
-- 			x, y, z = getElementVelocity(vehicle)
-- 			shittyVelocity = x*x + y*y + z*z
-- 			-- vehicle handin location
-- 			if (TRAINS[getElementModel(vehicle)] and not PLAYER_TRAIN_IN_MARKER[v] and isElementWithinMarker(vehicle, MARKER_EXPORT)) then
-- 				PLAYER_TRAIN_IN_MARKER[v] = true
-- 				setTimer(function()
-- 					TELEPORTING[v] = true
-- 					PLAYER_PROGRESS[v] = PLAYER_PROGRESS[v] + 1
-- 					teleportToCheckpoints(v)
-- 				end, 1000, 1)
-- 			elseif (not PLAYER_TRAIN_IN_MARKER[v] and shittyVelocity < 0.001 and isElementWithinMarker(vehicle, MARKER_EXPORT)) then
-- 				TELEPORTING[v] = true
-- 				PLAYER_PROGRESS[v] = PLAYER_PROGRESS[v] + 1
-- 				teleportToCheckpoints(v)
-- 			end
-- 			-- boat marker
-- 			if (BOATS[getElementModel(vehicle)] and shittyVelocity < 0.001 and isElementWithinColShape(vehicle, REACH_CRANE2)) then
-- 				triggerClientEvent(v, "craneGrab", resourceRoot, 2)
-- 			elseif (BOATS[getElementModel(vehicle)] and shittyVelocity < 0.001 and isElementWithinColShape(vehicle, REACH_CRANE1)) then
-- 				triggerClientEvent(v, "craneGrab", resourceRoot, 1)
-- 			end
-- 		end
-- 	end
-- end
-- setTimer(playerStoppedInMarker, 1, 0)

function cheatData(playerSource, commandName)
	v = getPlayerFromName("SpeedyFolf")
	local vehicle = getPedOccupiedVehicle(v)
	iprint(v, TRAINS[getElementModel(vehicle)], PLAYER_TRAIN_IN_MARKER[v], isElementWithinMarker(vehicle, MARKER_EXPORT), TELEPORTING[v], PLAYER_PROGRESS[v])
end
addCommandHandler("cheatdata", cheatData)

function cheatSkipVehicle(playerSource, commandName)
	progress = PLAYER_PROGRESS[playerSource] + 1

	PLAYER_PROGRESS[playerSource] = progress
	
	teleportToNext(progress, playerSource)
	triggerClientEvent(playerSource, "updateTarget", playerSource, progress)
end
addCommandHandler("cheatnext", cheatSkipVehicle)

function cheatFlipVehicle(playerSource, commandName)
	vehicle = getPedOccupiedVehicle(playerSource)
	setElementRotation(vehicle, 0, 180, 0)
end
addCommandHandler("cheatflip", cheatFlipVehicle)

function cheatPrevVehicle(playerSource, commandName)
	progress = PLAYER_PROGRESS[playerSource] - 1

	PLAYER_PROGRESS[playerSource] = progress
	
	teleportToNext(progress, playerSource)
	triggerClientEvent(playerSource, "updateTarget", playerSource, progress)
end
addCommandHandler("cheatprev", cheatPrevVehicle)

function cheatTeleportVehicle(playerSource, commandName)
	vehicle = getPedOccupiedVehicle(playerSource)
	setElementPosition(vehicle, 0, 0, 20)
end
addCommandHandler("cheattp", cheatTeleportVehicle)

function cheatTeleportBoat(playerSource, commandName)
	vehicle = getPedOccupiedVehicle(playerSource)
	setElementPosition(vehicle, -219, -604, 20)
end
addCommandHandler("cheattpboat", cheatTeleportBoat)


function finish(rank, _time)
	name = getPlayerName(source)
	if (REQUIRED_CHECKPOINTS == #getElementsByType("checkpoint")) then
		if (DATABASE) then
			dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS scoresTable (playername TEXT, score integer)")
			query = dbQuery(DATABASE, "SELECT * FROM scoresTable WHERE playername = ?", name)
			results = dbPoll(query, -1)		

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
	toggleControl(player, 'vehicle_fire', true)
	toggleControl(player, 'vehicle_secondary_fire', true)
end
addEventHandler( "onResourceStop", resourceRoot, cleanup)

-- database stuff
-- --------------

function showScores(newState, oldState)
	if (newState == "Running") then
		triggerClientEvent(root, "showScoreBoard", resourceRoot, true, 5000)
		return
	elseif (newState == "GridCountdown") then
		if (DATABASE) then
			-- read the database
			dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS scoresTable (playername TEXT, score integer)")
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "iguana", 87645)
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "zerogott", 23)
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "jivel", 1011)
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "thedamngod", 45302)
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "kavakcz", 999)
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "uber_dragon", 4)
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "wayno717", 171)
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
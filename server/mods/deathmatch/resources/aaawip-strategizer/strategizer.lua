SELECTED_CARS = {}
SELECTED_TRACK_INDICES = {}

BLIPS = {}
CHECKPOINT_MARKERS = {}

PLAYER_SELECTIONS = {}
PLAYER_FAILSAFETIMERS = {}
PLAYER_FAILSAFETIMERCOUNTERS = {}

COLORS = {
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
	{math.random(0, 255), math.random(0, 255), math.random(0, 255)},
}

FINISHES = getElementsByType("finish")
TRACKS = getElementsByType("track")
STARTS = getElementsByType("start")

RACE_CPS = getElementsByType("checkpoint")
COL_SHAPES = {}

STAGES = 10
MAP_STAGE = "pregrid" --0 = before grid countdown. 1 = setup. 2 = race

----------------------------- Start of the race ---------------------------

addEventHandler("onResourceStop", resourceRoot,
	function(resource)
		for i, player in pairs(getElementsByType("player")) do
			setElementData(player, "strategizer.progress", 0)
			setElementData(player, "strategizer.state", "none") 
			setElementData(player, "strategizer.failsafetimer", "0") 
			-- none, setup, setupend, racestart, racing, fadeout, fadein, finished
		end
	end
)

function startGame()
	MAP_STAGE = "setup"
	shuffleTracksAll()
	shuffleCarsAll()
	for i, player in pairs(getElementsByType("player")) do
		setElementData(player, "strategizer.progress", 0)
		setElementData(player, "strategizer.state", "setup")
		triggerClientEvent(player, "onCarSelectionFinished", resourceRoot, SELECTED_CARS, SELECTED_TRACK_INDICES, COLORS)
	end
	displayTracks()
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, 
	function(newState, oldState)
		if (newState == "GridCountdown") then
			startGame()
		end
	end
)

function shuffleTracksAll()
	TRACKS = getElementsByType("track")
	local indices = {}
	for i = 1, #TRACKS, 1 do
		indices[i] = i
	end

	local shuffledIndices = {}
	for i = #indices, 1, -1 do
		randomIndex = math.random(1,i)
		shuffledIndices[i] = indices[randomIndex]
		table.remove(indices, randomIndex)
	end
	for i = 1, STAGES, 1 do
		SELECTED_TRACK_INDICES[i] = shuffledIndices[i]
	end

	-- -- temporary code to disable shuffling
	-- STARTAT = 235
	-- for i = STARTAT, STAGES + STARTAT - 1, 1 do
	-- 	j = i - STARTAT + 1
	-- 	if i <= #indices then
	-- 		SELECTED_TRACK_INDICES[j] = indices[i]
	-- 	else
	-- 		SELECTED_TRACK_INDICES[j] = indices[i - #indices]
	-- 	end
	-- end
end

function shuffleCarsAll()
	local suitableCars = { 413, 418, 440, 459, 482, 483, 508, 582,
		414, 422, 428, 456, 478, 499, 543, 554, 600, 609,
		403, 406, 408, 443, 455, 486, 514, 515, 524, 525, 530, 552, 573, 574, 578,
		407, 416, 427, 432, 433, 490, 528, 544, 596, 597, 598, 599, 601,
		402, 411, 415, 429, 451, 477, 480, 506, 541, 555, 558, 559, 560, 562, 565, 587, 602, 603,
		401, 410, 436, 474, 491, 496, 517, 526, 527, 533, 545, 549, 439, 475, 542,
		412, 419, 518, 534, 535, 536, 567, 575, 576,
		405, 409, 420, 421, 426, 438, 445, 466, 467, 492, 507, 516, 529, 540, 546, 547, 550, 551, 566, 580, 585,
		400, 404, 442, 458, 470, 479, 489, 495, 500, 561, 579, 589,
		423, 424, 431, 434, 437, 444, 457, 485, 494, 502, 503, 504, 531, 532, 539, 556, 557, 568, 571, 572, 583, 588,
		441, 564, 
		448, 461, 462, 463, 468, 471, 521, 522, 523, 581, 586,
		509, 481, 510,
		605, 604, 594
	}
	local shuffledCars = {}
	for i = #suitableCars, 1, -1 do
		randomIndex = math.random(1,i)
		shuffledCars[i] = suitableCars[randomIndex]
		table.remove(suitableCars, randomIndex)
	end
	for i = 1, STAGES, 1 do
		SELECTED_CARS[i] = shuffledCars[i]
	end
end

function displayTracks()
	for i, v in pairs(SELECTED_TRACK_INDICES) do
		local r, g, b = unpack(COLORS[i])
		
		-- display the checkpoint markers and put a blip on them
		local x, y, z = getElementPosition(FINISHES[v])
		local size = getElementData(FINISHES[v], "size") or 6

		table.insert(CHECKPOINT_MARKERS, createMarker(x, y, z, "checkpoint", 6, r, g, b))
		table.insert(BLIPS, createBlip(x, y, z, 0, 8, r, g, b, 255, 0, 1000))

		-- place the lighthouse beacons
		x, y, z = getElementPosition(TRACKS[v])
		object = createObject(6295, x, y + 0.175, z - 1)
		setObjectScale(object, 0.1)
		setElementCollisionsEnabled(object, false)
		createMarker(x, y, z + 1.1, "corona", 1.5, r, g, b) -- glow

		-- put a blip on the spawn (start position) of the track
		x, y, z = getElementPosition(STARTS[v])
		table.insert(BLIPS, createBlip(x, y, z, 0, 4, r, g, b, 255, 0, 1000))
	end
end

----------------------------- Misc (TODO: Different file?) ---------------------------

addEvent("onClientCarChange", true)
addEventHandler("onClientCarChange", root, 
	function (model, r, g, b, r2, g2, b2)
		local vehicle = getPedOccupiedVehicle(client)
		setElementModel(vehicle, model)
		setVehicleColor(vehicle, r, g, b, r2, g2, b2)
	end
)

function getPosAndRotData(element)
	local x = getElementData(element, "posX")
	local y = getElementData(element, "posY")
	local z = getElementData(element, "posZ")
	local rX = getElementData(element, "rotX")
	local rY = getElementData(element, "rotY")
	local rZ = getElementData(element, "rotZ")
	return x, y, z, rX, rY, rZ
end

----------------------------- Setup To Race Transition ---------------------------

function finishSetup()
	MAP_STAGE = "race"
	-- get rid of ALL The blips on the minimap
	for i, blip in pairs(BLIPS) do
		destroyElement(blip)
	end

	-- place an (invisible) hitbox on each checkpoint, and make all the markers invisible
	for i, check in pairs(CHECKPOINT_MARKERS) do
		local r, g, b = getMarkerColor(check)
		setMarkerColor(check, r, g, b ,0)
		setMarkerType(check, "cylinder")
		local x, y, z = getElementPosition(check)
		size = getMarkerSize(check)
		table.insert(COL_SHAPES, createColCircle(x, y, size + 2))
	end
	
	-- tell every player that setup has ended, make them compile a list and send it back to us.
	-- This will be received in receiveClientCarList(), which will teleport players to the start after 2 seconds
	for i, player in pairs(getElementsByType("player")) do
		setElementData(player, "strategizer.state", "setupend")
		triggerClientEvent(player, "onSetupFinished", resourceRoot)
	end

	-- after 4 seconds, unfreeze every player (they'll have teleported by then)
	setTimer ( function()
		for i, player in pairs(getElementsByType("player")) do
			vehicle = getPedOccupiedVehicle(player)
			setElementData(player, "strategizer.state", "racestart")
			setElementCollisionsEnabled(vehicle, true)
			setElementFrozen(vehicle, false)
		end
	end, 4000, 1)
	-- after 6 seconds, start the race for everyone
	setTimer ( function()
		for i, player in pairs(getElementsByType("player")) do
			setElementData(player, "strategizer.state", "racing")
			toggleAllControls(player, true)
			triggerClientEvent(player, "playGoSound", resourceRoot)
		end
	end, 6000, 1)
end
bindKey(getElementsByType("player")[1], "H", "down", finishSetup)

function receiveClientCarList(cars)
	-- received car list
	PLAYER_SELECTIONS[client] = cars
	--  set progress
	setElementData(client, "strategizer.progress", 1)
	-- disable movement, and fade to black
	toggleAllControls(client, false, true, false)
	triggerClientEvent(client, "checkpointFade", resourceRoot)
	-- after 2 seconds, teleport player to start and fade back in
	setTimer ( function(player)
		triggerClientEvent(player, "fadeIn", resourceRoot)
		setElementFrozen(getPedOccupiedVehicle(player), true)
		teleportPlayerToStart(player)
	end, 2000, 1, client)
end
addEvent("transferCarList", true)
addEventHandler("transferCarList", root, receiveClientCarList)

----------------------------- Player Race Teleportation ---------------------------


function teleportPlayerToStart(player)
	local model = PLAYER_SELECTIONS[player][1]
	local track = SELECTED_TRACK_INDICES[1]
	teleportPlayerToTrack(player, track, model)
	enableNextCheckpoint(player, 1)
end

function teleportPlayerToNextTrack(player)
	local playerProgress = getElementData(player, "strategizer.progress")
	local nextTrack = SELECTED_TRACK_INDICES[playerProgress]
	local model = PLAYER_SELECTIONS[player][playerProgress]
	teleportPlayerToTrack(player, nextTrack, model)
end

function teleportPlayerToTrack(player, trackNo, carModel)
	local destination = STARTS[trackNo]
	local x, y, z, rX, rY, rZ = getPosAndRotData(destination)
	local vehicle = getPedOccupiedVehicle(player)
	setElementModel(vehicle, carModel)
	setElementPosition(vehicle, x, y, z)
	setElementRotation(vehicle, rX, rY, rZ)
	fixVehicle(vehicle)
end

function teleportToFinish(player)
	local vehicle = getPedOccupiedVehicle(player)
	setElementPosition(vehicle, 613, -2377, 9)
end

function respawnDuringRace(theVehicle, seat, jacked)
	-- do nothing at the start of the map
	if (MAP_STAGE == "pregrid") then
		return
	end
	
	-- if the player just joined
	if (getElementData(source, "strategizer.state") == false) then
		-- give them all the information that was generated at the start of the map
		setElementData(source, "strategizer.state", "setup")
		triggerClientEvent(source, "onCarSelectionFinished", resourceRoot, SELECTED_CARS, SELECTED_TRACK_INDICES, COLORS)
		-- if the race is already ongoing, put them in
		if (MAP_STAGE == "race") then
			setElementData(source, "strategizer.state", "racing")
			triggerClientEvent(source, "onSetupFinished", resourceRoot)
		end
		return
	end	


	-- ??????????
	if (MAP_STAGE == "setup") then
		triggerClientEvent(source, "respawn", resourceRoot)
		return
	end
	
	-- if the player has already finished
	local progress = getElementData(source, "strategizer.progress")
	if (progress > STAGES) then
		return
	end

	local playerState = getElementData(source, "strategizer.state")
	-- player died after grabbing CP but before being teleported to the next track
	if (playerState == "fadeout") then
		-- the race respawn reenables player's control, so disable it again
		toggleAllControls(source, false, true, false)
		-- When race mode unfreezes the player after respawn, they also give them controls back. Disable it once more
		setTimer ( function(player)
			toggleAllControls(player, false, true, false)
		end, 2000, 1, source)
		iprint(source)
		iprint("respawning during fadeout")
		teleportPlayerToNextTrack(source)
	else
		teleportPlayerToNextTrack(source)
	end
end
addEventHandler("onPlayerVehicleEnter", root, respawnDuringRace)

----------------------------- CLEAN UP EVERYTHING BELOW ---------------------------

function checkpointHit(player, matchingDimension)
	-- figure out which checkpoint it is we just hit
	for i, v in pairs(COL_SHAPES) do
		if v == source then
			if (source == COL_SHAPES[10]) then
				outputChatBox("TODO: Do something else when you finish the race than just transitioning")
			end
			if i == getElementData(player, "strategizer.progress") then
				-- start the transition for the player
				transitionPlayer(player)
				return
			end
		end
	end
end
addEventHandler("onColShapeHit", resourceRoot, 
	function(player, matchingDimension) 
		-- only check players
		if (getElementType(player) ~= "player") then
			return
		end
		-- spectators are really high in the sky
		local x, y, z = getElementPosition(player)
		if (z > 10000) then
			return
		end
		checkpointHit(player)
	end
)

function transitionPlayer(player)
	-- transition player out
	setElementData(player, "strategizer.state", "fadeout")
	toggleAllControls(player, false, true, false)
	triggerClientEvent(player, "checkpointFade", resourceRoot)
	
	setTimer ( function(player)
		local progress = getElementData(player, "strategizer.progress")
		-- I dont want to do all this on the server, but race conditions :)
		local vehicle = getPedOccupiedVehicle(player)
		local matrix = getElementMatrix(vehicle)
		local velocity = getElementVelocity(vehicle)
		local angularVelocity = getElementAngularVelocity(vehicle)
		-- Store these values on the client side so they can get a cool cinematic at the end
		-- triggerClientEvent(player, "onCheckpointTransition", matrix, velocity, angularVelocity)
		triggerClientEvent(player, "dumpSpeed", resourceRoot, progress)
		-- freeze the player
		setElementVelocity(vehicle, 0 ,0,0)
		setElementAngularVelocity(vehicle, 0, 0 ,0)
		setElementFrozen(getPedOccupiedVehicle(player), true)
		cpNo = getElementData(player, "race.checkpoint")
		for i = cpNo, progress do
			teleportPlayerToRaceCp(player, i)
		end
		-- setElementData(player, "strategizer.progress", i + 1)
	end, 2000, 1, player)
	-- failsafe in case the player dies at an unfortuante moment in the transition
	local progress = getElementData(player, "strategizer.progress")
	PLAYER_FAILSAFETIMERCOUNTERS[player] = 0
	PLAYER_FAILSAFETIMERS[player] = setTimer ( function(player, oldProgress)
		PLAYER_FAILSAFETIMERCOUNTERS[player] = PLAYER_FAILSAFETIMERCOUNTERS[player] + 1
		-- dont do anything before 5 half seconds have passed
		if (PLAYER_FAILSAFETIMERCOUNTERS[player] < 5) then
			return
		end
		-- if the player is still in fadeout (probably, otherwise this timer would've been killed already)
		if getElementData(player, "strategizer.state") == "fadeout" then
			local progress = getElementData(player, "strategizer.progress")
			-- spam chat :)
			local name = getPlayerName(player)
			outputChatBox(name .. " has encountered a big fat error! Arguments: " .. progress .. " " .. oldProgress .. " " .. PLAYER_FAILSAFETIMERCOUNTERS[player], root, 227, 20, 32)
			-- do the teleport again
			cpNo = getElementData(player, "race.checkpoint")
			for i = cpNo, progress do
				teleportPlayerToRaceCp(player, i)
			end
		end
	end, 500, 0, player, progress)
end

function teleportPlayerToRaceCp(player, cp)
	local vehicle = getPedOccupiedVehicle(player)
	local x,y,z = getElementPosition(RACE_CPS[cp])
	setElementPosition(vehicle,x,y,z)
end

function freePlayerControls(player)
	toggleAllControls(player, true)
	setElementCollisionsEnabled(getPedOccupiedVehicle(player), true)
	setElementFrozen(getPedOccupiedVehicle(player), false)
end

addEventHandler("onPlayerReachCheckpoint", root, 
	function(checkpoint, time_)
		-- ignore CPs the player already got
		if (checkpoint == getElementData(source, "strategizer.progress")) then
			-- Kill failsafe timers
			-- PLAYER_FAILSAFETIMERCOUNTERS[player] = 0
			killTimer(PLAYER_FAILSAFETIMERS[source])
			-- Increment player progress
			progress = getElementData(source, "strategizer.progress")
			progress = progress + 1
			setElementData(source, "strategizer.progress", progress)
			-- Ensure the player can't move
			toggleAllControls(source, false, true, false)
			-- Ensure the player's car's physics are preserved
			setElementFrozen(getPedOccupiedVehicle(source), false)
			setElementCollisionsEnabled(getPedOccupiedVehicle(source), true)
			-- Teleport player to next track
			teleportPlayerToNextTrack(source)
			enableNextCheckpoint(source, checkpoint + 1)	-- shouldnt be needed later TODO:
			-- Tell the client to fade back in
			triggerClientEvent(source, "fadeIn", resourceRoot)
			setElementData(source, "strategizer.state", "fadein")
			-- After two seconds, the player can go again!
			setTimer ( function(player)
				setElementData(player, "strategizer.state", "racing")
				freePlayerControls(player)
				triggerClientEvent(player, "playGoSound", resourceRoot)
			end, 2000, 1, source)
		end
	end
)


function finish(rank, _time)
	-- toggleAllControls(source, true)
	triggerClientEvent(source, "fadeIn", resourceRoot)
	setElementCollisionsEnabled(getPedOccupiedVehicle(source), true)
	setElementFrozen(getPedOccupiedVehicle(source), false)
	setElementData(source, "strategizer.state", "finished")
	teleportToFinish(source)
	triggerClientEvent(source, "spectacularFinish", resourceRoot)
end
addEventHandler("onPlayerFinish", getRootElement(), finish)

-- ??????? honestly what the fuck? Just fetch all this information client side (it should already have it) 
-- rather than passing it along for the bazillionth time. Just do the triggerclientevent thing without all the junk
function enableNextCheckpoint(player, progress)
	-- progress = getElementData(player, "strategizer.progress")
	local destination = CHECKPOINT_MARKERS[progress]
	local x, y, z = getElementPosition(destination)
	local size = getMarkerSize(destination)
	local r, g, b = getMarkerColor(destination)

	triggerClientEvent(player, "makeCheckpointVisible", resourceRoot, x,y,z,size,r,g,b)
end
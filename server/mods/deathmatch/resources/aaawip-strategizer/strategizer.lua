selectedCars = {}
selectedTracks = {}

blips = {}
checkpoints = {}

playerProgress = {}
playerSelections = {}

colors = {
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

finishes = {}
tracks = {}
starts = {}

raceCps = getElementsByType("checkpoint")
colShapes = {}

STAGES = 10

----------------------------- Start of the race ---------------------------

function startGame(newState, oldState)
	if (newState ~= "GridCountdown") then
		return
	end
	shuffleTracksAll()
	shuffleCarsAll()
	for i, v in pairs(getElementsByType("player")) do
		triggerClientEvent(v, "onCarSelectionFinished", resourceRoot, selectedCars, selectedTracks, colors)
	end
	finishes = getElementsByType("finish")
	tracks = getElementsByType("track")
	starts = getElementsByType("start")
	displayTracks()
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, startGame)

function shuffleTracksAll()
	tracks = getElementsByType("track")
	-- outputChatBox("tracks length: " .. #tracks)
	indices = {}
	for i = 1, #tracks, 1 do
		indices[i] = i
	end

	shuffledIndices = {}
	for i = #indices, 1, -1 do
		randomIndex = math.random(1,i)
		shuffledIndices[i] = indices[randomIndex]
		table.remove(indices, randomIndex)
	end
	for i = 1, STAGES, 1 do
		selectedTracks[i] = shuffledIndices[i]
	end


	--- temporary code to disable shuffling
	-- STARTAT = 78
	-- for i = STARTAT, STAGES + STARTAT - 1, 1 do
	-- 	j = i - STARTAT + 1
	-- 	if i <= #indices then
	-- 		selectedTracks[j] = indices[i]
	-- 	else
	-- 		selectedTracks[j] = indices[i - #indices]
	-- 	end
	-- end
end

function shuffleCarsAll()
	suitableCars = { 413, 418, 440, 459, 482, 483, 508, 582,
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
		509, 481, 510
	}
	-- outputChatBox("cars length: " .. #suitableCars)
	shuffledCars = {}
	for i = #suitableCars, 1, -1 do
		randomIndex = math.random(1,i)
		shuffledCars[i] = suitableCars[randomIndex]
		table.remove(suitableCars, randomIndex)
	end
	for i = 1, STAGES, 1 do
		selectedCars[i] = shuffledCars[i]
	end
end

function displayTracks()
	for i, v in pairs(selectedTracks) do
		x, y, z = getElementPosition(finishes[v])
		size = getElementData(finishes[v], "size") or 6
		table.insert(checkpoints, createMarker(x, y, z, "checkpoint", 6, colors[i][1], colors[i][2], colors[i][3]))
		table.insert(blips, createBlip(x, y, z, 0, 8, colors[i][1], colors[i][2], colors[i][3], 255, 0, 1000))
		table.insert(blips, createBlip(620.5, -2371.4, 3, 31, 1, colors[i][1], colors[i][2], colors[i][3], 255, 0))

		x, y, z = getElementPosition(tracks[v])
		object = createObject(6295, x, y + 0.175, z - 1)
		setObjectScale(object, 0.1)
		setElementCollisionsEnabled(object, false)
		createMarker(x, y, z + 1.1, "corona", 1.5, colors[i][1], colors[i][2], colors[i][3])

		x, y, z = getElementPosition(starts[v])
		table.insert(blips, createBlip(x, y, z, 0, 2, colors[i][1], colors[i][2], colors[i][3], 255, 0, 1000))
	end
end

function changeCar(model, r, g, b, r2, g2, b2)
	vehicle = getPedOccupiedVehicle(client)
	setElementModel(vehicle, model)
	setVehicleColor(vehicle, r, g, b, r2, g2, b2)
end
addEvent("changeCar", true)
addEventHandler("changeCar", root, changeCar)

----------------------------- Post Setup ---------------------------

function finishSetup()
	for i, v in pairs(blips) do
		destroyElement(v)
	end
	for i, v in pairs(checkpoints) do
		r, g, b = getMarkerColor(v)
		setMarkerColor(v, r, g, b ,0)
		setMarkerType(v, "cylinder")
		x, y, z = getElementPosition(v)
		size = getMarkerSize(v)
		table.insert(colShapes, createColCircle(x, y, size + 2))
		-- destroyElement(v)
	end
	for i, v in pairs(getElementsByType("player")) do
		triggerClientEvent(v, "onSetupFinished", resourceRoot)
	end
end

function transferCarList(cars)
	playerSelections[client] = cars
	playerProgress[client] = 1
	teleportToNext(client)
end
addEvent("transferCarList", true)
addEventHandler("transferCarList", root, transferCarList)


function teleportToNext(player)
	-- get our destination
	destination = starts[selectedTracks[playerProgress[player]]]
	x = getElementData(destination, "posX")
	y = getElementData(destination, "posY")
	z = getElementData(destination, "posZ")
	rX = getElementData(destination, "rotX")
	rY = getElementData(destination, "rotY")
	rZ = getElementData(destination, "rotZ")
	-- get the vehicle for our destination
	model = playerSelections[player][playerProgress[player]]
	-- go there
	vehicle = getPedOccupiedVehicle(player)
	setElementModel(vehicle, model)
	setElementPosition(vehicle, x, y, z)
	setElementRotation(vehicle, rX, rY, rZ)
	fixVehicle(vehicle)
	enableNextCheckpoint(player)
end

function enableNextCheckpoint(player)
	-- get our destination
	progress = playerProgress[player]
	destination = checkpoints[progress]
	x, y, z = getElementPosition(destination)
	size = getMarkerSize(destination)
	r, g, b = getMarkerColor(destination)
	triggerClientEvent(player, "makeCheckpointVisible", resourceRoot, x,y,z,size,r,g,b)
end

bindKey(getElementsByType("player")[1], "H", "down", finishSetup)


----------------------------- Hitting a marker ---------------------------


function teleportToRaceCp(player)
	vehicle = getPedOccupiedVehicle(player)
	for i = 1, playerProgress[player] - 1, 1 do
		x,y,z = getElementPosition(raceCps[i])
		setElementPosition(vehicle, x, y, z)
	end
end

function checkpointHit(player, matchingDimension)
	if (getElementType(player) ~= "player") then
		return
	end
	for i, v in pairs(colShapes) do
		if v == source then
			if i == playerProgress[player] then
				toggleAllControls(player, false, true, false)
				triggerClientEvent(player, "checkpointFade", resourceRoot)
				setTimer ( function(player)
					playerProgress[player] = playerProgress[player] + 1
					setElementFrozen(getPedOccupiedVehicle(player), true)
					teleportToRaceCp(player)
				end, 2000, 1, player)
			end
		end
	end
end
addEventHandler("onColShapeHit", resourceRoot, checkpointHit)

function grabCheckpoint(checkpoint, time_)
	if (checkpoint < playerProgress[source] - 1) then
		teleportToRaceCp(source)
	elseif (checkpoint < STAGES) then
		teleportToNext(source)
		triggerClientEvent(source, "fadeIn", resourceRoot)
		setElementFrozen(getPedOccupiedVehicle(source), false)
		setTimer ( function(player)
			toggleAllControls(player, true)
			triggerClientEvent(player, "playGoSound", resourceRoot)
		end, 2000, 1, source)
	end
end
addEventHandler("onPlayerReachCheckpoint", getRootElement(), grabCheckpoint)
selectedCars = {}
selectedIndices = {}

playerProgress = {}
playerCurrentCar = {}
playerCurrentTrack = {}
STAGES = 10

----------------------------- Start of the race ---------------------------

function startGame(newState, oldState)
	if (newState ~= "GridCountdown") then
		return
	end
	shuffleTracksAll()
	shuffleCarsAll()
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, startGame)

function shuffleTracksAll()
	tracks = getElementsByType("track")
	outputChatBox("tracks length: " .. #tracks)
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
		selectedIndices[i] = shuffledIndices[i]
	end
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
	outputChatBox("cars length: " .. #suitableCars)
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

function nextCar()
	changeCar(client, 1)
end

function prevCar()
	changeCar(client, -1)
end

function nextTrack()
	changeTrack(client, 1)
end

function prevTrack()
	changeTrack(client, -1)
end

function changeCar(player, next)
	if playerCurrentCar[player] then
		local index = playerCurrentCar[player] 
		playerCurrentCar[player] = playerCurrentCar[player] + next
	else
		playerCurrentCar[player] = next
	end
	if playerCurrentCar[player] < 1 then
		playerCurrentCar[player] = playerCurrentCar[player] + STAGES
	elseif playerCurrentCar[player] > STAGES then
		playerCurrentCar[player] = playerCurrentCar[player] - STAGES
	end

	vehicle = getPedOccupiedVehicle(player)
	model = selectedCars[playerCurrentCar[player]]
	setElementModel(vehicle, model)
	fixVehicle(vehicle)
	x, y, z = getElementPosition(vehicle)
	setElementPosition(vehicle, x, y, z + 0.5)
end

function changeTrack(player, next)
	if playerCurrentTrack[player] then
		local index = playerCurrentTrack[player]
		playerCurrentTrack[player] = playerCurrentTrack[player] + next
	else
		playerCurrentTrack[player] = next
	end
	if playerCurrentTrack[player] < 1 then
		playerCurrentTrack[player] = playerCurrentTrack[player] + STAGES
	elseif playerCurrentTrack[player] > STAGES then
		playerCurrentTrack[player] = playerCurrentTrack[player] - STAGES
	end

	local vehicle = getPedOccupiedVehicle(player)
	fixVehicle(vehicle)
	
	starts = getElementsByType("start")
	x, y, z = getElementPosition(starts[selectedIndices[playerCurrentTrack[player]]])
	u, v, w = getElementRotation(starts[selectedIndices[playerCurrentTrack[player]]])
	setElementFrozen(vehicle, true)
	setElementPosition(vehicle, x, y, z)
	setElementRotation(vehicle, u, v, w)
	setElementVelocity(vehicle, 0,0,0 + 0.5)
	setTimer( function()
		setElementFrozen(vehicle, false)
	end, 100, 1)
end

addEvent("nextCar", true)
addEventHandler("nextCar", resourceRoot, nextCar)
addEvent("prevCar", true)
addEventHandler("prevCar", resourceRoot, prevCar)
addEvent("nextTrack", true)
addEventHandler("nextTrack", resourceRoot, nextTrack)
addEvent("prevTrack", true)
addEventHandler("prevTrack", resourceRoot, prevTrack)
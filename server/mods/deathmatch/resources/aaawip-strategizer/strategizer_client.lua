spawners = getElementsByType("vehicleSpawner")
starts = getElementsByType("start")
tracks = getElementsByType("track")

selectedCars = {}
currentCar = 0
spawnedCars = {}

assignedCarColors = {}
carBlips = {}

selectedTracks = {}
currentTrack = 0

colors = {}

currentCp = nil
currentBlip = nil

isSetup = false

function onSetupFinished()
	sortedCars = {}
	for i, tr in pairs(selectedTracks) do
		x1, y1, z1 = getElementPosition(tracks[tr])
		distanceOld = 99999
		chosenIndex = 0
		for j, ca in pairs(spawnedCars) do
			x2, y2, z2 = getElementPosition(ca)
			distanceNew = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
			if (distanceNew < distanceOld) then
				chosenIndex = j
				distanceOld = distanceNew
			end
		end
		table.insert(sortedCars, getElementModel(spawnedCars[chosenIndex]))
		destroyElement(spawnedCars[chosenIndex])
		table.remove(spawnedCars, chosenIndex)
	end
	isSetup = false
	for i, v in pairs(carBlips) do
		destroyElement(v)
	end
	triggerServerEvent("transferCarList", resourceRoot, sortedCars)
end

addEvent("onSetupFinished", true)
addEventHandler("onSetupFinished", resourceRoot, onSetupFinished)


function makeCheckpointVisible(x,y,z,size,r,g,b)
	outputChatBox(x)
	currentCp = createMarker(x, y, z, "checkpoint", size, r, g, b)
	currentBlip = createBlip(x,y,z,0,4,r,g,b)
end

addEvent("makeCheckpointVisible", true)
addEventHandler("makeCheckpointVisible", resourceRoot, makeCheckpointVisible)


function fadeIn()
	fadeCamera(true, 2)
end
addEvent("fadeIn", true)
addEventHandler("fadeIn", resourceRoot, fadeIn)

function playGoSound()
	playSoundFrontEnd(45)
end
addEvent("playGoSound", true)
addEventHandler("playGoSound", resourceRoot, playGoSound)


function checkpointFade()
	playSoundFrontEnd(43)
	fadeCamera(false, 2)
	destroyElement(currentCp)
	destroyElement(currentBlip)
end
addEvent("checkpointFade", true)
addEventHandler("checkpointFade", resourceRoot, checkpointFade)


------------------------------------------ setup stage ------------------------------

function onCarSelectionFinished(cars, tracks, col)
	selectedCars = cars
	selectedTracks = tracks
	colors = col
	for i, veh in pairs(spawners) do
		if (i <= #cars) then
			x,y,z = getElementPosition(veh)
			u = getElementData(veh, "rotX")
			v = getElementData(veh, "rotY")
			w = getElementData(veh, "rotZ")
			model = cars[i]
			spawnedCars[i] = createVehicle(model, x, y, z, u, v, w)
			setVehicleColor(spawnedCars[i], 255, 255, 255, 0, 0, 0)
			carBlips[i] = createBlipAttachedTo(spawnedCars[i],0,5,255,255,255,255,64, 1000)
		end
	end
	changeCar(0)
	isSetup = true
end

addEvent("onCarSelectionFinished", true)
addEventHandler("onCarSelectionFinished", resourceRoot, onCarSelectionFinished)

function changeCar(next)
	currentCar = currentCar + next

	if currentCar < 1 then
		currentCar = currentCar + #selectedCars
	elseif currentCar > #selectedCars then
		currentCar = currentCar - #selectedCars
	end

	vehicle = getPedOccupiedVehicle(localPlayer)
	model = selectedCars[currentCar]
	setElementModel(vehicle, model)
	fixVehicle(vehicle)
	x, y, z = getElementPosition(vehicle)
	setElementPosition(vehicle, x, y, z + 0.5)
	trackColor = assignedCarColors[currentCar]
	
	if (trackColor) then
		setVehicleColor(vehicle, colors[trackColor][1], colors[trackColor][2] , colors[trackColor][3], colors[trackColor][1] / 2, colors[trackColor][2] / 2, colors[trackColor][3] / 2)
	else
		setVehicleColor(vehicle, 255, 255, 255, 0, 0, 0)
	end
	triggerServerEvent("changeCar", resourceRoot, model)
end

function changeTrack(next)
	currentTrack = currentTrack + next
	
	if currentTrack < 1 then
		currentTrack = currentTrack + #selectedTracks
	elseif currentTrack > #selectedTracks then
		currentTrack = currentTrack - #selectedTracks
	end

	local vehicle = getPedOccupiedVehicle(localPlayer)
	fixVehicle(vehicle)
	
	x, y, z = getElementPosition(starts[selectedTracks[currentTrack]])
	u = getElementData(starts[selectedTracks[currentTrack]], "rotX")
	v = getElementData(starts[selectedTracks[currentTrack]], "rotY")
	w = getElementData(starts[selectedTracks[currentTrack]], "rotZ")
	setElementFrozen(vehicle, true)
	setElementPosition(vehicle, x, y, z)
	setElementRotation(vehicle, u, v, w)
	setElementVelocity(vehicle, 0,0,0 + 0.5)
	setTimer( function(vehicle)
		setElementFrozen(vehicle, false)
	end, 100, 1, vehicle)
end

function assignCar(keyName, keyState)
	if (isSetup == true and getPedOccupiedVehicle(localPlayer)) then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		x,y,z = getElementPosition(vehicle)
		u,v,w = getElementRotation(vehicle)
		setElementPosition(spawnedCars[currentCar], x,y,z)
		setElementRotation(spawnedCars[currentCar], u,v,w)
		
		distanceOld = 99999
		chosenIndex = 0
		for i, v in pairs(selectedTracks) do
			track = tracks[v]
			x2,y2,z2 = getElementPosition(track)
			distanceNew = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			if (distanceNew < distanceOld) then
				chosenIndex = i
				distanceOld = distanceNew
			end
		end
		setVehicleColor(vehicle, colors[chosenIndex][1], colors[chosenIndex][2], colors[chosenIndex][3], colors[chosenIndex][1] / 2, colors[chosenIndex][2] / 2, colors[chosenIndex][3] / 2)
		setVehicleColor(spawnedCars[currentCar], colors[chosenIndex][1], colors[chosenIndex][2], colors[chosenIndex][3], colors[chosenIndex][1] / 2, colors[chosenIndex][2] / 2, colors[chosenIndex][3] / 2)
		setBlipColor(carBlips[currentCar], colors[chosenIndex][1], colors[chosenIndex][2], colors[chosenIndex][3], 255)
		assignedCarColors[currentCar] = chosenIndex
	end
end

for keyName, state in pairs(getBoundKeys("sub_mission")) do
	bindKey(keyName, "down", assignCar)
end

function nextCar(keyName, keyState)
	if (isSetup == true and getPedOccupiedVehicle(localPlayer)) then
		changeCar(1)
	end
end

function prevCar(keyName, keyState)
	if (isSetup == true and getPedOccupiedVehicle(localPlayer)) then
		changeCar(-1)
	end
end

function nextTrack(keyName, keyState)
	if (isSetup == true and getPedOccupiedVehicle(localPlayer)) then
		changeTrack(1)
	end
end

function prevTrack(keyName, keyState)
	if (isSetup == true and getPedOccupiedVehicle(localPlayer)) then
		changeTrack(-1)
	end
end

for keyName, state in pairs(getBoundKeys("special_control_up")) do
	bindKey(keyName, "down", nextTrack)
end

for keyName, state in pairs(getBoundKeys("special_control_down")) do
	bindKey(keyName, "down", prevTrack)
end

for keyName, state in pairs(getBoundKeys("special_control_left")) do
	bindKey(keyName, "down", prevCar)
end

for keyName, state in pairs(getBoundKeys("special_control_right")) do
	bindKey(keyName, "down", nextCar)
end




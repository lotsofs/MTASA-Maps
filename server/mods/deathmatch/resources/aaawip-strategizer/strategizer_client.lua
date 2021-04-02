spawners = getElementsByType("vehicleSpawner")
starts = getElementsByType("start")
finishes = getElementsByType("finish")
tracks = getElementsByType("track")

selectedCars = {}
currentCar = 0
spawnedCars = {}
sortedCars = {}
sortedCarsDistance = {}
unassignedCars = {}

assignedCarColors = {}
carBlips = {}

selectedTracks = {}
selectedTrackNames = {}
currentTrack = 0

colors = {}

currentCp = nil
currentBlip = nil

isSetup = false

radarArea = createRadarArea(150, -2850, 700, 700, 115, 138, 173, 64)

function calculateCarAssignment(sortUnassigned) 
	unassignedCars = {}
	sortedCars = {}
	for i, car in pairs(selectedCars) do
		local x1, y1, z1 = getElementPosition(spawnedCars[i])
		local distanceOld = 99999
		chosenIndex = 0
		if (isInsideRadarArea(radarArea, x1, y1) == false) then
			for j, tr in pairs(selectedTracks) do
				x2, y2, z2 = getElementPosition(tracks[tr])
				distanceNew = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
				if (distanceNew < distanceOld) then
					chosenIndex = j
					distanceOld = distanceNew
				end
			end
			if (sortedCars[chosenIndex] ~= nil) then
				if (sortedCarsDistance[chosenIndex] > distanceOld) then
					table.insert(unassignedCars, sortedCars[chosenIndex])
					sortedCars[chosenIndex] = car
					sortedCarsDistance[chosenIndex] = distanceOld
				else
					table.insert(unassignedCars, car)
				end
			else
				sortedCars[chosenIndex] = car
				sortedCarsDistance[chosenIndex] = distanceOld
			end
		else
			table.insert(unassignedCars, car)
		end
	end
	if (sortUnassigned == false or sortUnassigned == nil) then
		return
	end
	j = 1
	for i = 1, 10 do
		if (sortedCars[i] == nil) then
			sortedCars[i] = unassignedCars[j]
			j = j + 1
		end
	end
end

function onSetupFinished()
	calculateCarAssignment(true)
	for i, sc in pairs(spawnedCars) do
		destroyElement(sc)
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
	if (currentCp) then 
		destroyElement(currentCp) 
		currentCp = nil
	end
	if (currentBlip) then 
		destroyElement(currentBlip) 
		currentBlip = nil
	end
	currentCp = createMarker(x, y, z, "checkpoint", size, r, g, b)
	currentBlip = createBlip(x,y,z,0,4,r,g,b)
end

addEvent("makeCheckpointVisible", true)
addEventHandler("makeCheckpointVisible", resourceRoot, makeCheckpointVisible)


velocities = {}
rotations = {}
angularVelocities = {}
function dumpSpeed(index)
	vehicle = getPedOccupiedVehicle(localPlayer)
	angularVelocities[index] = {getElementAngularVelocity(vehicle)}
	velocities[index] = {getElementVelocity(vehicle)}
	rotations[index] = {getElementRotation(vehicle)}
end
addEvent("dumpSpeed", true)
addEventHandler("dumpSpeed", resourceRoot, dumpSpeed)

function spectacularFinish()
	createMarker(613, -2377, 9, "corona", size, 255, 255, 255, 127)
	for i = 1, 9 do
		setTimer(function(index)
			vehicle = createVehicle(sortedCars[index], 613, -2377, 9, unpack(rotations[index]))
			setElementAngularVelocity(vehicle, unpack(angularVelocities[index]))
			setElementVelocity(vehicle, unpack(velocities[index]))
		end, 2000 - (200 * i), 1, i)			
	end
	vehicle = getPedOccupiedVehicle(localPlayer)
	setElementAngularVelocity(vehicle, unpack(angularVelocities[10]))
	setElementVelocity(vehicle, unpack(velocities[10]))
end
addEvent("spectacularFinish", true)
addEventHandler("spectacularFinish", resourceRoot, spectacularFinish)

-- function respawnCleanup()
-- 	destroyElement(currentCp)
-- 	destroyElement(currentBlip)
-- end
-- addEvent("respawnCleanup", true)
-- addEventHandler("respawnCleanup", resourceRoot, respawnCleanup)

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
	if (currentCp) then 
		destroyElement(currentCp) 
		currentCp = nil
	end
	if (currentBlip) then 
		destroyElement(currentBlip) 
		currentBlip = nil
	end
	currentCp = nil
	currentBlip = nil
end
addEvent("checkpointFade", true)
addEventHandler("checkpointFade", resourceRoot, checkpointFade)


------------------------------------------ setup stage ------------------------------

function onCarSelectionFinished(c, t, col)
	selectedCars = c
	selectedTracks = t
	for i, track in pairs(selectedTracks) do
		local name = getElementData(tracks[track], "name")
		if (name == nil or name == "" or name == " ") then
			name = getElementID(selectedTracks[track])
		end
		local x1, y1, z1 = getElementPosition(starts[track])
		local x2, y2, z2 = getElementPosition(finishes[track])
		local distance = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
		selectedTrackNames[i] = "(" .. math.floor(distance) .. " M) " .. name
	end
	colors = col
	for i, veh in pairs(spawners) do
		if (i <= #c) then
			x,y,z = getElementPosition(veh)
			u = getElementData(veh, "rotX")
			v = getElementData(veh, "rotY")
			w = getElementData(veh, "rotZ")
			model = selectedCars[i]
			spawnedCars[i] = createVehicle(model, x, y, z, u, v, w)
			setVehicleColor(spawnedCars[i], 255, 255, 255, 0, 0, 0)
			carBlips[i] = createBlipAttachedTo(spawnedCars[i],0,6,255,255,255,255,64, 1000)
		end
	end
	changeCar(0)
	isSetup = true
	calculateCarAssignment()
end

addEvent("onCarSelectionFinished", true)
addEventHandler("onCarSelectionFinished", resourceRoot, onCarSelectionFinished)


function respawn()
	changeCar(0)
end
addEvent("respawn", true)
addEventHandler("respawn", resourceRoot, respawn)

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
		r = colors[trackColor][1]
		g = colors[trackColor][2]
		b = colors[trackColor][3]
		r2 = r/2
		g2 = g/2
		b2 = b/2
	else
		r = 255
		g = 255
		b = 255
		r2 = 0
		g2 = 0
		b2 = 0
	end
	setVehicleColor(vehicle, r, g, b, r2, g2, b2)
	triggerServerEvent("onClientCarChange", resourceRoot, model, r, g, b, r2, g2, b2)
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
		
		if (isInsideRadarArea(radarArea, x, y)) then
			r = 255
			g = 255
			b = 255
			r2 = 0
			g2 = 0
			b2 = 0
		else
			r = colors[chosenIndex][1]
			g = colors[chosenIndex][2]
			b = colors[chosenIndex][3]
			r2 = r/2
			g2 = g/2
			b2 = b/2
		end

		setVehicleColor(vehicle, r, g, b, r2, g2, b2)
		setVehicleColor(spawnedCars[currentCar], r, g, b, r2, g2, b2)
		setBlipColor(carBlips[currentCar], r, g, b, 255)
		assignedCarColors[currentCar] = chosenIndex
		triggerServerEvent("onClientCarChange", resourceRoot, getElementModel(vehicle), r, g, b, r2, g2, b2)
		calculateCarAssignment()
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
	bindKey(keyName, "down", prevTrack)
end

for keyName, state in pairs(getBoundKeys("special_control_down")) do
	bindKey(keyName, "down", nextTrack)
end

for keyName, state in pairs(getBoundKeys("special_control_left")) do
	bindKey(keyName, "down", prevCar)
end

for keyName, state in pairs(getBoundKeys("special_control_right")) do
	bindKey(keyName, "down", nextCar)
end




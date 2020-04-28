-- on player finish

BIG_CARS = { [514] = true, [406] = true, [431] = true, [532] = true, [476] = true, [495] = true,[486] = true, [515] = true, [444] = true }
DODOS = {}
CHECKPOINTS = getElementsByType("checkpoint")
DRIVERS = {}

function onRaceStateChanging(newState, oldState)
	if (newState == "GridCountdown") then
		triggerClientEvent(root, "receiveDodos", resourceRoot, DODOS)
		at400 = getElementByID("AT400")
		at400p = getElementByID("AT400Parent")
		attachElements(at400, at400p)
		x,y,z = getElementPosition(at400p)
		moveObject(at400p, 6000, x, y-500, z)
		setTimer(function()
			moveObject(at400p, 24000, x, y-2500, z+200, 90, 0, 0)
		end, 6000, 1)
		for i,v in pairs(getElementsByType("vehicle")) do
			-- setVehicleDamageProof(v, false)
			-- setVehicleEngineState(v, true)
			setElementData(v, "race.collideothers", 0)
			setElementFrozen(v, false)
			setElementCollisionsEnabled(v, true)
			player = getVehicleOccupant(v)
			if (player) then
				setElementData(player, "airpain3.dodosDestroyed", 0)
				toggleAllControls(player, false, true, false)
				x2,y2,z2 = getElementPosition(v)
				distance = y - y2
				distance = distance * 10
				distance = distance + 200
				if (x2 < 1470 or x2 > 1485) then
					distance = distance + 150
				end
				
				left = math.random()
				left = left * 0.7
				left = left + 0.3
				if (x2 < x) then
					left = left * -1
				end
				forward = math.random()
				forward = forward + 0.5
				forward = forward * -1
				
				up = math.random()
				up = up * 0.5
				
				angularX = math.random() - 0.5
				angularY = math.random() - 0.5
				angularZ = math.random() - 0.5
				angularX = angularX / 10
				angularY = angularY / 10
				angularZ = angularZ / 10
				

				
				model = getVehicleModel(v)
				if (BIG_CARS[model] ~= true and (x2 < 1470 or x2 > 1485) and math.random() < 0.85) then
					left = 0
					forward = 0
					up = 0
					angularX = 0
					angularY = 0
					angularZ = 0
				end
				setElementData(v, "airpain3.left", left)
				setElementData(v, "airpain3.forward", forward)
				setElementData(v, "airpain3.up", up)
				
				setTimer(function()
					setElementVelocity(v, getElementData(v,"airpain3.left"), getElementData(v,"airpain3.forward"), getElementData(v,"airpain3.up"))
					setElementAngularVelocity(v, (math.random() - 0.5)/10 , (math.random() - 0.5)/10, (math.random() - 0.5)/10)
				end, distance, 1)
			end
			--setElementVelocity(v, 0.3, 0.9, 0.6)		
		end
	elseif (newState == "Running") then
		triggerClientEvent(root, "spawnFirstDodos", resourceRoot)
		handling = getModelHandling(429)
		for i, v in pairs(getElementsByType("vehicle")) do
			if (getVehicleOccupant(v)) then
				setVehicleDamageProof(v, true)			
				--setVehicleHandling(v, "mass", handling.mass)
				setVehicleHandling(v, "dragCoeff", handling.dragCoeff)
				setVehicleHandling(v, "engineAcceleration", handling.engineAcceleration)
				setVehicleHandling(v, "engineInertia", handling.engineInertia)
				setVehicleHandling(v, "maxVelocity", handling.maxVelocity)
			end
		end
		setTimer(function()
			triggerClientEvent(root, "markDodosOnMap", resourceRoot)
		end, 240000, 1)
		--triggerClientEvent(root, "setOpponentCollisions", resourceRoot)
	end	
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, onRaceStateChanging)

function onMapStarting()
	dodos = getElementsByType("dodo")
	for i = #dodos, 1, -1 do
		newI = math.random(1, i)
		table.insert(DODOS, dodos[newI])
		table.remove(dodos, newI)
	end

	drivers = getElementsByType("driver")
	for i = #drivers, 1, -1 do
		newI = math.random(1, i)
		table.insert(DRIVERS, drivers[newI])
		table.remove(drivers, newI)
	end
	players = getElementsByType("player")
	if (#players <= #DRIVERS) then
		for i = 1, #players, 1 do
			setElementData(players[i], "airpain3.driver", DRIVERS[i])
		end
	else
		for i = 1, #players, 1 do
			if (i > #DRIVERS) then
				setElementData(players[i], "airpain3.driver", DRIVERS[i - #DRIVERS])
			else
				setElementData(players[i], "airpain3.driver", DRIVERS[i])
			end
		end
	end

	handling = getModelHandling(429)
	for i, v in pairs(getElementsByType("vehicle")) do
		if (getVehicleOccupant) then
			setVehicleDamageProof(v, true)			
			--setVehicleHandling(v, "mass", handling.mass)
			setVehicleHandling(v, "dragCoeff", handling.dragCoeff)
			setVehicleHandling(v, "engineAcceleration", handling.engineAcceleration)
			setVehicleHandling(v, "engineInertia", handling.engineInertia)
			setVehicleHandling(v, "maxVelocity", handling.maxVelocity)
		end
	end
end
addEventHandler("onMapStarting", root, onMapStarting)

function onVehicleEnter(thePlayer, seat, jacked)
	if (not getElementType(thePlayer) == "player") then
		return
	end
	setTimer(function()
		driver = getElementData(thePlayer, "airpain3.driver")
		vehicle = getPedOccupiedVehicle(thePlayer)
		model = getElementData(driver, "model")
		paintjob = getElementData(driver, "paintjob")
		color = getElementData(driver, "color")
		colors = {}
		for col in string.gmatch(color, '([^,]+)') do
			table.insert(colors, col)
		end
		setElementModel(vehicle, model)
		setVehiclePaintjob(vehicle, paintjob)
		setVehicleColor(vehicle, colors[1], colors[2], colors[3], colors[4], colors[5], colors[6], colors[7], colors[8], colors[9], colors[10], colors[11], colors[12])
		
		setVehicleDamageProof(vehicle, true)			
		--setVehicleHandling(vehicle, "mass", handling.mass)
		setVehicleHandling(vehicle, "dragCoeff", handling.dragCoeff)
		setVehicleHandling(vehicle, "engineAcceleration", handling.engineAcceleration)
		setVehicleHandling(vehicle, "engineInertia", handling.engineInertia)
		setVehicleHandling(vehicle, "maxVelocity", handling.maxVelocity)
	end, 2000, 1)
end
addEventHandler("onVehicleEnter", root, onVehicleEnter)

function onPlayerJoin()
	setElementData(source, "airpain3.driver", DRIVERS[math.random(#DRIVERS)])
	triggerClientEvent(source, "receiveDodos", resourceRoot, DODOS)
	triggerClientEvent(source, "spawnFirstDodos", resourceRoot)
	joinedPlayer = source
end
addEventHandler("onPlayerJoin", root, onPlayerJoin)

function playerDestroyedDodo()
	dodosDestroyed = getElementData(client, "airpain3.dodosDestroyed")
	car = getPedOccupiedVehicle(client)
	xO,yO,zO = getElementPosition(car)
	qO,rO,sO = getElementVelocity(car)
	if (not dodosDestroyed) then
		x,y,z = getElementPosition(CHECKPOINTS[1])
		setElementPosition(car, x,y,z)
		setElementPosition(car, xO, yO, zO)
		setElementVelocity(car, qO, rO, sO)
		dodosDestroyed = 1
		setElementData(client, "airpain3.dodosDestroyed", dodosDestroyed)
	else
		dodosDestroyed = dodosDestroyed + 1
		setElementData(client, "airpain3.dodosDestroyed", dodosDestroyed)
		for i = 1, dodosDestroyed, 1 do
			x,y,z = getElementPosition(CHECKPOINTS[i])
			setElementPosition(car, x, y, z)
		end
		setElementPosition(car, xO, yO, zO)
		setElementVelocity(car, qO, rO, sO)
	end
	if (dodosDestroyed == 8) then
		triggerClientEvent(client, "spawnSecondDodos", resourceRoot)
	elseif (dodosDestroyed == 18) then
		triggerClientEvent(client, "spawnThirdDodos", resourceRoot)
	end
end
addEvent("playerDestroyedDodo", true)
addEventHandler("playerDestroyedDodo", resourceRoot, playerDestroyedDodo)
function setHeliBladesCollidable(vehicle)
	setHeliBladeCollisionsEnabled(vehicle, false)
end
addEvent("setHeliBladesCollidable", true)
addEventHandler("setHeliBladesCollidable", resourceRoot, setHeliBladesCollidable)

function setHeliBladesCollidableAll()
	for i, v in pairs(getElementsByType("vehicle")) do
		setHeliBladeCollisionsEnabled(v, false)
	end
end
addEvent("setHeliBladesCollidableAll", true)
addEventHandler("setHeliBladesCollidableAll", resourceRoot, setHeliBladesCollidableAll)

function crashAT()
	atSpawn = getElementByID("_AT_400")
	x = getElementData(atSpawn, "posX")
	y = getElementData(atSpawn, "posY")
	z = getElementData(atSpawn, "posZ")
	u = getElementData(atSpawn, "rotX")
	v = getElementData(atSpawn, "rotY")
	w = getElementData(atSpawn, "rotZ")
	t = getElementData(atSpawn, "model")
	
	pedTemplate = getElementByID("_PILOT")
	pedModel = getElementData(pedTemplate, "model")

	atVehicle = createVehicle(t, x, y, z, u, v, w)
	ped = createPed(pedModel, x, y, z + 10)
	warpPedIntoVehicle(ped, atVehicle)
	setPedControlState(ped, "accelerate", true)
	setPedControlState(ped, "vehicle_left", true)
	setElementHealth(atVehicle, 249)
	setTimer(blowVehicle, 20000, 3, atVehicle, true)
end
addEvent("crashAT", true)
addEventHandler("crashAT", resourceRoot, crashAT)

function crashHydras()
	hydraSpawn1 = getElementByID("_HYDRA_01")
	hydraSpawn2 = getElementByID("_HYDRA_02")
	hydraSpawn3 = getElementByID("_HYDRA_03")
	
	x1 = getElementData(hydraSpawn1, "posX")
	y1 = getElementData(hydraSpawn1, "posY")
	z1 = getElementData(hydraSpawn1, "posZ")
	u1 = getElementData(hydraSpawn1, "rotX")
	v1 = getElementData(hydraSpawn1, "rotY")
	w1 = getElementData(hydraSpawn1, "rotZ")
	t1 = getElementData(hydraSpawn1, "model")
	
	x2 = getElementData(hydraSpawn2, "posX")
	y2 = getElementData(hydraSpawn2, "posY")
	z2 = getElementData(hydraSpawn2, "posZ")
	u2 = getElementData(hydraSpawn2, "rotX")
	v2 = getElementData(hydraSpawn2, "rotY")
	w2 = getElementData(hydraSpawn2, "rotZ")
	t2 = getElementData(hydraSpawn2, "model")
	
	x3 = getElementData(hydraSpawn3, "posX")
	y3 = getElementData(hydraSpawn3, "posY")
	z3 = getElementData(hydraSpawn3, "posZ")
	u3 = getElementData(hydraSpawn3, "rotX")
	v3 = getElementData(hydraSpawn3, "rotY")
	w3 = getElementData(hydraSpawn3, "rotZ")
	t3 = getElementData(hydraSpawn3, "model")
	
	pedTemplate1 = getElementByID("_SOLDIER_1")
	pedModel1 = getElementData(pedTemplate1, "model")
	pedTemplate2 = getElementByID("_SOLDIER_2")
	pedModel2 = getElementData(pedTemplate2, "model")
	pedTemplate3 = getElementByID("_SOLDIER_3")
	pedModel3 = getElementData(pedTemplate3, "model")

	hydra1Vehicle = createVehicle(t1, x1, y1, z1, u1, v1, w1)
	ped1 = createPed(pedModel1, x1, y1, z1 + 10)
	warpPedIntoVehicle(ped1, hydra1Vehicle)
	setPedControlState(ped1, "accelerate", true)
	setPedControlState(ped1, "vehicle_left", true)
	setPedControlState(ped1, "special_control_up", true)
	setElementHealth(hydra1Vehicle, 251)
	setVehicleLandingGearDown(hydra1Vehicle, false)
	setTimer(blowVehicle, 15000, 3, hydra1Vehicle, true)
	
	hydra2Vehicle = createVehicle(t2, x2, y2, z2, u2, v2, w2)
	ped2 = createPed(pedModel2, x2, y2, z2 + 10)
	warpPedIntoVehicle(ped2, hydra2Vehicle)
	setPedControlState(ped2, "accelerate", true)
	setPedControlState(ped2, "vehicle_right", true)
	setPedControlState(ped2, "special_control_up", true)
	setElementHealth(hydra2Vehicle, 251)
	setVehicleLandingGearDown(hydra2Vehicle, false)
	setTimer(blowVehicle, 17000, 3, hydra2Vehicle, true)
	
	hydra3Vehicle = createVehicle(t3, x3, y3, z3, u3, v3, w3)
	ped3 = createPed(pedModel3, x3, y3, z3 + 10)
	warpPedIntoVehicle(ped3, hydra3Vehicle)
	setPedControlState(ped3, "accelerate", true)
	--setPedControlState(ped3, "vehicle_left", true)
	setPedControlState(ped3, "special_control_up", true)
	setElementHealth(hydra3Vehicle, 251)
	setVehicleLandingGearDown(hydra3Vehicle, false)
	setTimer(blowVehicle, 14000, 3, hydra3Vehicle, true)
end
addEvent("crashHydras", true)
addEventHandler("crashHydras", resourceRoot, crashHydras)

COLLAPSED = false
function crashTower()
	if (COLLAPSED) then
		return
	end
	COLLAPSED = true
	explosions = {}
	x = {}
	y = {}
	z = {}
	for i = 1, 12, 1 do
		explosions[i] = getElementByID("_EXPLOSION_" .. i)
		x[i] = getElementData(explosions[i], "posX")
		y[i] = getElementData(explosions[i], "posY")
		z[i] = getElementData(explosions[i], "posZ")
		setTimer(createExplosion, 3000 + i * 50, 1, x[i], y[i], z[i], 2)
		setTimer(createExplosion, 4000 + i * 50, 1, x[i], y[i], z[i], 2)
		setTimer(createExplosion, 5000 + i * 50, 1, x[i], y[i], z[i], 2)
	end
	tower = getElementByID("_COLLAPSING_TOWER")
	towerDown = getElementByID("_COLLAPSED_TOWER")
	rubble = getElementByID("_RUBBLE_PILE_DOWN")
	rubbleUp = getElementByID("_RUBBLE_PILE_UP")
	tX, tY, tZ = getElementPosition(towerDown)
	tU1, tV1, tW1 = getElementRotation(tower)
	tU2, tV2, tW2 = getElementRotation(towerDown)
	tU3 = tU2 - tU1
	tV3 = tV2 - tV1
	tW3 = tW2 - tW1
	rX, rY, rZ = getElementPosition(rubbleUp)
	setTimer(moveObject, 5000, 1, tower, 5000, tX, tY, tZ, tU3, tV3, tW3, "InQuad")
	setTimer(moveObject, 5000, 1, rubble, 5000, rX, rY, rZ, 0, 0, 0, "InQuad")
end
addEvent("crashTower", true)
addEventHandler("crashTower", resourceRoot, crashTower)


function crashHelicopter()
	heliSpawn = getElementByID("_POLICE_MAVERICK")
	x = getElementData(heliSpawn, "posX")
	y = getElementData(heliSpawn, "posY")
	z = getElementData(heliSpawn, "posZ")
	u = getElementData(heliSpawn, "rotX")
	v = getElementData(heliSpawn, "rotY")
	w = getElementData(heliSpawn, "rotZ")
	t = getElementData(heliSpawn, "model")
	
	pedTemplate = getElementByID("_COP")
	pedModel = getElementData(pedTemplate, "model")

	heliSpawn = createVehicle(t, x, y, z, u, v, w)
	ped = createPed(pedModel, x, y, z + 10)
	warpPedIntoVehicle(ped, heliSpawn)
	setPedControlState(ped, "brake_reverse", true)
	--setPedControlState(ped, "vehicle_left", true)
	setElementHealth(heliSpawn, 249)
	setHelicopterRotorSpeed(heliSpawn, 0.2)
	setTimer(blowVehicle, 60000, 3, heliSpawn, true)
end
addEvent("crashHelicopter", true)
addEventHandler("crashHelicopter", resourceRoot, crashHelicopter)
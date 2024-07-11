
STARTING_AREA = createColCircle(500,-2500,50)
END_MARKER_C = getElementByID("MARKER_CP")

START_X = 0
START_Y = 0
START_Z = 0
START_R = 0

TICK_RATE = 1000/30
MARKER_MOVE_ANGLE = 0
MARKER_MOVE_SPEED = TICK_RATE / 1000 * 12

RACE_ONGOING = false
RACE_DURATION = 0
RACE_STUCK = false

RANDOM_VEHICLE = 414
HEIGHT_OFFSET = 0

function teleportPlayers()
	local stuck = true
	RACE_DURATION = RACE_DURATION + 1
	for i, p in pairs(getElementsByType("player")) do
		local v = getPedOccupiedVehicle(p)
		if (v and isElementWithinColShape(v, STARTING_AREA)) then
			if (START_Z > 0) then
				setElementModel(v, RANDOM_VEHICLE)
				setElementPosition(v, START_X, START_Y, START_Z + HEIGHT_OFFSET)
				setElementRotation(v, 0, 0, START_R)
				if (RACE_ONGOING) then
					triggerClientEvent(root, "onRaceHasBegun", resourceRoot)
				end
			end
		end
		-- Hack for bad spawn
		if (not isPedDead(p) and v and RACE_ONGOING and RACE_DURATION > 7 and not isElementWithinColShape(v, STARTING_AREA)) then
			local xc, yx, zc = getElementPosition(v)
			local dist = getDistanceBetweenPoints3D(xc, yx, zc, START_X, START_Y, START_Z + HEIGHT_OFFSET)
			if (RACE_STUCK and dist <= 5) then
				setElementPosition(v, START_X, START_Y, -105)
			end
			if (dist > 5) then
				stuck = false
			end
		else
			stuck = false
		end
	end
	RACE_STUCK = stuck
end
setTimer(teleportPlayers, 1000, 0)

function raceStateChanged(newState, oldState)
	if (newState == "Running") then
		triggerClientEvent(root, "onRaceHasBegun", resourceRoot)
		RACE_ONGOING = true
		RACE_DURATION = 0
	elseif (newState == "GridCountdown") then
		setTimer(moveMarker, TICK_RATE, 0)
	end
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, raceStateChanged)

function moveMarker()
	oldX,oldY,_ = getElementPosition(END_MARKER_C)
	
	if (math.abs(oldX) > 3000) then
		MARKER_MOVE_ANGLE = 3.14159 - MARKER_MOVE_ANGLE
	end
	if (math.abs(oldY) > 3000) then
		MARKER_MOVE_ANGLE = -1 * MARKER_MOVE_ANGLE
	end

	local change = math.random(1,2)
	if change == 2 then
		change = -1
	end
	change = change * 0.0174533
	MARKER_MOVE_ANGLE = MARKER_MOVE_ANGLE + change
	local theta = MARKER_MOVE_ANGLE
	local r = MARKER_MOVE_SPEED
	newX = r * math.cos(theta)
	newY = r * math.sin(theta)
	setElementPosition(END_MARKER_C,oldX+newX,oldY+newY,500)
end

function startMap()
	local mules = getElementsByType("vehicle", resourceRoot)
	local selectedMule = math.random(1,#mules)
	for i,m in ipairs(mules) do
		if (i == selectedMule) then
			START_X, START_Y, START_Z = getElementPosition(m)
			_, _, START_R = getElementRotation(m)
		end
		destroyElement(m)
	end
	setElementPosition(END_MARKER_C, START_X, START_Y, 500)
	MARKER_MOVE_ANGLE = math.random(0, 359)
	MARKER_MOVE_ANGLE = MARKER_MOVE_ANGLE * 0.0174533

	RANDOM_VEHICLE, HEIGHT_OFFSET = selectVehicle()
end
addEventHandler("onMapStarting", root, startMap)




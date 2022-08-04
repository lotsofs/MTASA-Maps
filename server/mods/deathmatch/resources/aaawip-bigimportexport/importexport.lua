local RACE_RESOURCE = getResourceDynamicElementRoot(getResourceFromName("race"))

MARKER_EXPORT = getElementByID("_MARKER_EXPORT_PARK")
MARKER_BOAT = getElementByID("_MARKER_EXPORT_BOAT")

BOAT_DETECTOR = createColCuboid(-476, -966, -5, 929, 839, 15)
REACH_CRANE1 = createColCircle(72.4, -339.4, 89)
REACH_CRANE2 = createColCircle(-61.9, -286.4, 89)
GODMODE_REGION_BOAT = createColCircle(-12.5, -342.0, 15)
GODMODE_REGION_PLANE = createColRectangle(-61, -233, 30, 29)
CRANE1_STATE = "init"
CRANE2_STATE = "init"

CRANE_HOOK_VERTICAL_SPEED = 131
CRANE_HOOK_HORIZONTAL_SPEED = 181
CRANE_TURN_SPEED = 220
CRANE_TURN_ODDS = 50
HOOK_BOAT_HEIGHT_OFFSET = 6

SHUFFLED_CARS = {}
PLAYER_CURRENT_TARGET = 1
-- LAST_CAR = false


VEHICLE_WEAPONS = {
	[38] = true, --hunter minigun
	[37] = true, --havent a clue, somethign with the hydra
	[51] = true, --hunter missiles, tank
	[31] = true, --rustler, seasparrow, rc baron
	[28] = true --predator
}

BIG_PLANES = {
	[577] = true,
	[553] = true,
	[592] = true
}

VEHICLES_WITH_GUNS = {
	[476] = true,
	[447] = true,
	[430] = true,
	[464] = true,
	[425] = true
}

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

TRAILERS = {
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
}

function playerStoppedInMarker()
	local x, y, z = getElementPosition(localPlayer)
	if (z > 1000) then
		-- When spectating, do nothing
		return
	end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (not vehicle) then
		return
	end
	x, y, z = getElementVelocity(vehicle)
	shittyVelocity = x*x + y*y + z*z
	if (shittyVelocity > 0.001) then
		return
	end

	-- Check if the player is stopped by any of the cranes. Check crane 2 first because 1 doesnt need to do anything if 2 can handle it.
	if (BOATS[getElementModel(vehicle)] and isElementWithinColShape(vehicle, REACH_CRANE2)) then
		craneGrab(2)
	elseif (BOATS[getElementModel(vehicle)] and isElementWithinColShape(vehicle, REACH_CRANE1)) then
		craneGrab(1)
	end

	if (not isElementWithinMarker(vehicle, MARKER_EXPORT)) then
		return
	end

	if (getElementAttachedTo(vehicle) ~= false) then
		return
	end

	collectCheckpoints(PLAYER_CURRENT_TARGET)

	triggerServerEvent("updateProgress", resourceRoot, PLAYER_CURRENT_TARGET)
end
setTimer(playerStoppedInMarker, 1, 0)

function collectCheckpoints(target)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    local checkpoint = getElementData(localPlayer, "race.checkpoint")
    for i=checkpoint, target do
        local colshapes = getElementsByType("colshape", RACE_RESOURCE)
        triggerEvent("onClientColShapeHit",
            colshapes[#colshapes], vehicle, true)
    end
end

function updateTarget(new)
	PLAYER_CURRENT_TARGET = new
	CRANE1_STATE = "available"
	CRANE2_STATE = "available"
end
addEvent("updateTarget", true)
addEventHandler("updateTarget", localPlayer, updateTarget)

---- Prevent players from harming one another
---- Prevent players from harming one another
---- Prevent players from harming one another
---- Prevent players from harming one another
---- Prevent players from harming one another

function handleVehicleExplosions(x, y, z, theType)
	-- 2 = hunter
	-- 3 = hydra heat seek
	-- 10 = tank
	if (theType == 2 or theType == 3 or theType == 10) then
		-- u, v, w = getElementPosition(localPlayer)
		-- if (getDistanceBetweenPoints3D ( x, y, z, u, v, w ) < 120) then
		-- 	playSFX("genrl", 45, 3, false)
		-- end
		-- playSFX("genrl", 45, 1, false)
		if (source ~= localPlayer) then
			-- createEffect("explosion_medium", x,y,z, 270, 0, 0, 0, true)
			createExplosion(x,y,z,1)
			cancelEvent()
		end
		-- createExplosion(x, y, z, theType, true, -1.0, true)
	end
end
addEventHandler("onClientExplosion", root, handleVehicleExplosions)

function handleVehicleDamage(attacker, weapon, loss, x, y, z, tire)
	if (VEHICLE_WEAPONS[weapon] and attacker ~= localPlayer) then
		cancelEvent()
	end
end
addEventHandler("onClientVehicleDamage", root, handleVehicleDamage)

-- New Crane Stuff
-- New Crane Stuff
-- New Crane Stuff
-- New Crane Stuff

-- Initialize all the crane stuff
function configureCrane()
	crane = {}
	crane["base1"] = getElementByID("_CRANE1_POLE")
	crane["base2"] = getElementByID("_CRANE2_POLE")
	crane["bar1"] = getElementByID("_CRANE1_BAR")
	crane["bar2"] = getElementByID("_CRANE2_BAR")
	crane["hook1"] = getElementByID("_CRANE1_HOOK")
	crane["hook2"] = getElementByID("_CRANE2_HOOK")
	crane["rope1"] = getElementByID("_CRANE1_ROPE")
	crane["rope2"] = getElementByID("_CRANE2_ROPE")

	-- Make the cranes visibile from afar by spawning a LowLOD version (TODO: someone pls tell me what model to use)
	lowLOD3 = createObject(1391, -61.9, -286.4, 51.7, 0, 0, 0, true)
	lowLOD4 = createObject(1391, 72.4, -339.4, 26.9, 0, 0, 0, true)
	setObjectScale ( lowLOD3, 1.5)
	setObjectScale ( lowLOD4, 1.5)
	local a, b, c = getElementPosition(crane["bar1"])
	local a2, b2, c2 = getElementPosition(crane["bar2"])
	lowLOD1 = createObject(1394, a, b, c, 0, 0, 0, true)
	lowLOD2 = createObject(1394, a2, b2, c2, 0, 0, 0, true)
	setObjectScale ( lowLOD1, 1.5)
	setObjectScale ( lowLOD2, 1.5)
	attachElements ( lowLOD1, crane["bar1"], 0, 0, 0 )
	attachElements ( lowLOD2, crane["bar2"], 0, 0, 0 )

	-- attach crane 1
	local barX, barY, barZ = getElementPosition(crane["bar1"])
	local ropeX, ropeY, ropeZ = getElementPosition(crane["rope1"])
	local hookX, hookY, hookZ = getElementPosition(crane["hook1"])
	attachElements ( crane["hook1"], crane["rope1"], hookX-ropeX, hookY-ropeY, hookZ-ropeZ )
	attachElements ( crane["rope1"], crane["bar1"], ropeX-barX, ropeY-barY, ropeZ-barZ )
	
	-- attach crane 2
	local barX, barY, barZ = getElementPosition(crane["bar2"])
	local ropeX, ropeY, ropeZ = getElementPosition(crane["rope2"])
	local hookX, hookY, hookZ = getElementPosition(crane["hook2"])
	attachElements ( crane["hook2"], crane["rope2"], hookX-ropeX, hookY-ropeY, hookZ-ropeZ )
	attachElements ( crane["rope2"], crane["bar2"], ropeX-barX, ropeY-barY, ropeZ-barZ )
	
	-- done
	CRANE1_STATE = "available"
	CRANE2_STATE = "available"

	setTimer(craneTimerTick, 100, 0)

	createBlip(99.4, -414.6, 0, 9)
end
addEvent("configureCrane", true)
addEventHandler("configureCrane", resourceRoot, configureCrane)

function craneOneBoatGrab()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	local x1,y1,z1 = getElementPosition(crane["bar1"])
	local x2,y2,z2 = getElementPosition(vehicle)
	local u1,v1,w1 = getElementRotation(crane["hook1"])
	local u2,v2,w2 = getElementRotation(vehicle)
	if (CRANE1_STATE == "boat 0") then
		-- move bar above boat
		CRANE1_STATE = "boat 1"
		local r = findRotation(x1,y1,x2,y2)
		local d
		if (TRAILERS[getElementModel(vehicle)]) then
			d = 0
		end
		local duration = rotateCraneTo(1, r, d, 0.25)
		setTimer(function()
			CRANE1_STATE = "boat 2"
		end, duration, 1)
	elseif (CRANE1_STATE == "boat 2") then
		-- move hook into boat
		CRANE1_STATE = "boat 3"
		local d = getDistanceBetweenPoints2D ( x1,y1,x2,y2 )
		local duration = moveHook(1, z2 + HOOK_BOAT_HEIGHT_OFFSET, math.min(d,89), 0.5)
		setTimer(function()
			CRANE1_STATE = "boat 4"
		end, duration, 1)
	elseif (CRANE1_STATE == "boat 4") then
		-- raise hook up with boat
		CRANE1_STATE = "boat 5"
		local x3,y3,z3 = getElementPosition(crane["hook1"])
		local d = getDistanceBetweenPoints2D ( x3,y3,x2,y2 )
		-- if (d > 90) then
		-- 	CRANE1_STATE = "waiting for boat"
		-- 	return
		-- end
		if (d > 1) then
			CRANE1_STATE = "boat 0"
			return
		end
		if (getElementHealth(vehicle) >= 250) then
			attachElements(vehicle, crane["rope1"], 0, 0, -HOOK_BOAT_HEIGHT_OFFSET, u2-u1, v2-v1, w2-w1)
		end
		rotateCraneTo(2, 218, nil, 0.5) -- rotate crane 2 into position
		local duration = moveHook(1, math.random(35,41), -1)
		setTimer(function()
			CRANE1_STATE = "boat 6"
		end, duration, 1)
	elseif (CRANE1_STATE == "boat 6") then
		-- rotate crane with boat
		CRANE1_STATE = "boat 7"
		local duration = rotateCraneTo(1, 94, nil, 0.5)
		setTimer(function()
			CRANE1_STATE = "boat 8"
		end, duration, 1)
	elseif (CRANE1_STATE == "boat 8") then
		-- move hook into range of other crane if not there yet
		CRANE1_STATE = "boat 9"
		local d = getDistanceBetweenPoints2D ( x1,y1,x2,y2 )
		if (d < 70) then
			local duration = moveHook(1, -1, math.random(70,89))
			setTimer(function()
				CRANE1_STATE = "boat 10"
			end, duration, 1)
		else
			CRANE1_STATE = "boat 10"
		end
	elseif (CRANE1_STATE == "boat 10") then
		-- drop boat
		CRANE1_STATE = "boat 11"
		detachElements(vehicle)
		setTimer(function()
			CRANE1_STATE = "boat 12"
		end, 500, 1)
	elseif (CRANE1_STATE == "boat 12") then
		-- move crane out of the way
		CRANE1_STATE = "boat 13"
		local duration = rotateCraneTo(1, math.random(135, 405))
	end
end

function craneTwoBoatGrab()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	x1,y1,z1 = getElementPosition(crane["bar2"])
	x2,y2,z2 = getElementPosition(vehicle)
	u1,v1,w1 = getElementRotation(crane["hook2"])
	u2,v2,w2 = getElementRotation(vehicle)
	if (CRANE2_STATE == "boat 0") then
		-- move bar above boat
		CRANE2_STATE = "boat 1"
		local r = findRotation(x1,y1,x2,y2)
		local d
		if (TRAILERS[getElementModel(vehicle)]) then
			d = 0
		end
		local duration = rotateCraneTo(2, r, d, 0.2)
		setTimer(function()
			CRANE2_STATE = "boat 2"
		end, duration, 1)
	elseif (CRANE2_STATE == "boat 2") then
		-- move hook into boat
		CRANE2_STATE = "boat 3"
		local d = getDistanceBetweenPoints2D ( x1,y1,x2,y2 )
		local duration = moveHook(2, z2 + HOOK_BOAT_HEIGHT_OFFSET, math.min(d,95), 0.5)
		setTimer(function()
			CRANE2_STATE = "boat 4"
		end, duration, 1)
	elseif (CRANE2_STATE == "boat 4") then
		-- raise hook up with boat
		CRANE2_STATE = "boat 5"
		local x3,y3,z3 = getElementPosition(crane["hook2"])
		local d = getDistanceBetweenPoints2D ( x3,y3,x2,y2 )
		if (d > 1) then
			CRANE2_STATE = "boat 0"
			return
		end
		if (getElementHealth(vehicle) >= 250) then
			attachElements(vehicle, crane["rope2"], 0, 0, -HOOK_BOAT_HEIGHT_OFFSET, u2-u1, v2-v1, w2-w1)
		end
		local duration = moveHook(2, 68, -1)
		setTimer(function()
			CRANE2_STATE = "boat 6"
		end, duration, 1)
	elseif (CRANE2_STATE == "boat 6") then
		-- rotate crane with boat
		CRANE2_STATE = "boat 7"
		local duration = rotateCraneTo(2, 350, nil, 0.3)
		setTimer(function()
			CRANE2_STATE = "boat 8"
		end, duration, 1)
	elseif (CRANE2_STATE == "boat 8") then
		-- move hook above marker
		CRANE2_STATE = "boat 9"
		local d = getDistanceBetweenPoints2D ( x1,y1,x2,y2 )
		if (d > 0) then
			local duration = moveHook(2, -1, 65.5)
			setTimer(function()
				CRANE2_STATE = "boat 10"
			end, duration, 1)
		else
			CRANE2_STATE = "boat 10"
		end
	elseif (CRANE2_STATE == "boat 10") then
		-- drop boat
		CRANE2_STATE = "boat 11"
		if (TRAINS[getElementModel(vehicle)]) then
			local duration = moveHook(2, 12.8, -1)
			setTimer(function()
				CRANE2_STATE = "boat 12"
			end, duration, 1)
		else
			detachElements(vehicle)
			setTimer(function()
				CRANE2_STATE = "boat 99"
			end, 500, 1)
		end	
	elseif (CRANE2_STATE == "boat 12") then
		CRANE2_STATE = "boat 99"
		detachElements(vehicle)
		local duration = moveHook(2, math.random(20,41), -1)
	end
end

function checkVehicleHealthOnCrane()
	local veh = getPedOccupiedVehicle(localPlayer)
	if (veh and getElementAttachedTo(veh) ~= false and getElementHealth(veh) < 250) then
		setElementHealth(veh, 251)
	end
end
setTimer(checkVehicleHealthOnCrane, 100, 0)

function setCraneBoatState(craneID, state)
	if (craneID == 1) then
		if (CRANE1_STATE:find("^boat") ~= nil) then
			CRANE1_STATE = state
		end
	elseif (craneID == 2) then
		if (CRANE2_STATE:find("^boat") ~= nil) then
			CRANE2_STATE = state
		end
	end
end

function craneTimerTick()
	
	if (CRANE1_STATE:find("^boat") ~= nil) then
		craneOneBoatGrab()
		return
	end
	if (CRANE2_STATE:find("^boat") ~= nil) then
		craneTwoBoatGrab()
		return
	end
	
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (not vehicle) then
		return
	end
	local vehicleModel = getElementModel(vehicle)
	if (BOATS[vehicleModel]) then
		if (CRANE1_STATE == "available") then
			CRANE1_STATE = "waiting for boat"
		end
		if (CRANE2_STATE == "available") then
			CRANE2_STATE = "waiting for boat"
		end
		return
	end

	local r = math.random(1,CRANE_TURN_ODDS)
	if (r > 1) then
		return
	end
	if (CRANE1_STATE == "available") then
		-- Crane 1 has free movement
		CRANE1_STATE = "rotating for fun"
		r = math.random(-270,270)
		rotateCraneRelative(1, r)
	elseif (CRANE2_STATE == "available") then
		-- Crane 2 is constrained between 36 - 376
		CRANE2_STATE = "rotating for fun"
		r = math.random(36,376)
		rotateCraneTo(2, r)
	end
end

function rotateCraneTo(craneID, wDest, time, speedMultiplier)
	local bar
	if (craneID == 1) then
		bar = crane["bar1"]
	elseif (craneID == 2) then
		bar = crane["bar2"]
	else
		return
	end
	local x,y,z = getElementPosition(bar)
	local u,v,w = getElementRotation(bar)

	if (craneID == 2 and w <= 16) then
		wDest = wDest - 360
	elseif (craneID == 1 and wDest + 360 - w < 180) then
		wDest = wDest + 360
	end

	wDiff = wDest - w
	local duration
	if (time == nil or time < 0) then
		duration = math.abs(wDiff * CRANE_TURN_SPEED)
	else
		duration = time
	end
	if (speedMultiplier ~= nil) then
		duration = duration * speedMultiplier
	end
	moveObject(bar, duration, x, y, z, 0, 0, wDiff, "InOutQuad")
	setTimer(makeCraneAvailable, duration, 1, craneID)
	return duration
	-- local duration = math.abs(wDiff * CRANE_TURN_SPEED)
	-- moveObject(bar, duration, x, y, z, 0, 0, wDiff, "InOutQuad")
	-- setTimer(makeCraneAvailable, duration, 1, craneID)
end

function rotateCraneRelative(craneID, wDiff)
	local bar
	if (craneID == 1) then
		bar = crane["bar1"]
	elseif (craneID == 2) then
		bar = crane["bar2"]
	else
		return
	end
	local x,y,z = getElementPosition(bar)
	local u,v,w = getElementRotation(bar)
	local duration = math.abs(wDiff * CRANE_TURN_SPEED)
	moveObject(bar, duration, x, y, z, 0, 0, wDiff, "InOutQuad")
	setTimer(makeCraneAvailable, duration, 1, craneID)
end

function makeCraneAvailable(craneID)
	if (craneID == 1) then
		if (CRANE1_STATE == "rotating for fun" or force == true) then
			CRANE1_STATE = "available"
		end
	elseif (craneID == 2) then
		if (CRANE2_STATE == "rotating for fun" or force == true) then
			CRANE2_STATE = "available"
		end
	end
end

-- attach the hook to the bar after moving it
function attachHook(craneID)
	if (craneID == 1) then
		local barX, barY, barZ = getElementPosition(crane["bar1"])
		local barU, barV, barW = getElementRotation(crane["rope1"])
		local ropeX, ropeY, ropeZ = getElementPosition(crane["rope1"])
		local ropeU, ropeV, ropeW = getElementRotation(crane["rope1"])
		attachElements ( crane["rope1"], crane["bar1"], 0, getDistanceBetweenPoints2D (barX,barY,ropeX,ropeY), ropeZ-barZ )
	elseif (craneID == 2) then
		local barX, barY, barZ = getElementPosition(crane["bar2"])
		local ropeX, ropeY, ropeZ = getElementPosition(crane["rope2"])
		local ropeU, ropeV, ropeW = getElementRotation(crane["rope2"])
		attachElements ( crane["rope2"], crane["bar2"], 0, getDistanceBetweenPoints2D (barX,barY,ropeX,ropeY), ropeZ-barZ )
	end
end

-- raise or lower the hook
function moveHook(craneID, destinationZ, destinationD, speedMultiplier)
	-- max values for crane 1: Z = 41, D = 89
	-- max values for crane 2: Z = 70.6, D = 89
	-- min D = 5ish
	
	local rope
	local base
	if (craneID == 1) then
		rope = crane["rope1"]
		base = crane["bar1"]
	elseif (craneID == 2) then
		rope = crane["rope2"]
		base = crane["bar2"]
	else
		return
	end
	detachElements(rope)
	u,v,w = getElementRotation(base)
	setElementRotation(rope,u,v,w)

	xBase, yBase, zBase = getElementPosition(base)
	xHook, yHook, zHook = getElementPosition(rope)
	aBar = findRotation( xBase, yBase, xHook, yHook ) 
	dHook = getDistanceBetweenPoints2D ( xBase, yBase, xHook, yHook )
	if (destinationD < 0) then
		destinationD = dHook
	end
	xNew, yNew = getPointFromDistanceRotation(xBase, yBase, destinationD, aBar)
	if (destinationZ < 0) then
		destinationZ = zHook
	end

	local zDiff = math.abs(zHook - destinationZ)
	local zDuration = zDiff * CRANE_HOOK_VERTICAL_SPEED
	local dDiff = math.abs(dHook - destinationD)
	local dDuration = dDiff * CRANE_HOOK_HORIZONTAL_SPEED
	
	local duration = math.max(dDuration, zDuration)
	if (speedMultiplier ~= nil) then
		duration = duration * speedMultiplier
	end

	moveObject(rope, duration, xNew, yNew, destinationZ, 0, 0, 0, "InOutQuad")
	setTimer(attachHook, duration, 1, craneID)
	return duration
end

function craneGrab(craneID)
	if (craneID == 1) then
		if (CRANE1_STATE:find("^boat") ~= nil) then
			return
		end
		if (CRANE1_STATE == "waiting for boat" or CRANE1_STATE == "rotating for fun") then
			CRANE1_STATE = "boat 0"
		end
	end
	if (craneID == 2) then
		if (CRANE2_STATE:find("^boat") ~= nil) then
			return
		end
		if (CRANE2_STATE == "waiting for boat" or CRANE2_STATE == "rotating for fun") then
			CRANE2_STATE = "boat 0"
		end
	end
end

function craneDetectBoat(element, matchingDimension)
	-- TODO: and not in spawn area
	if (element ~= localPlayer) then
		return
	end
	local vehicle = getElementModel(getPedOccupiedVehicle(localPlayer))
	if (not vehicle or not BOATS[vehicle]) then
		return
	end
	if (CRANE1_STATE ~= "waiting for boat") then
		CRANE1_STATE = "waiting for boat"
		iprint("Crane wasn't ready yet")
	end
	rotateCraneTo(1, 200, 20000)
end
addEventHandler("onClientColShapeHit", BOAT_DETECTOR, craneDetectBoat)

--- Other Stuff
--- Other Stuff
--- Other Stuff
--- Other Stuff
--- Other Stuff
--- Other Stuff
--- Other Stuff
--- Other Stuff

function enableGodMode(element, matchingDimension)
	if (getElementType(element) ~= "vehicle") then
		return
	end
	if (source == GODMODE_REGION_BOAT) then
		if (BOATS[getElementModel(element)]) then
			setVehicleDamageProof(element, true)
		end
	elseif (source == GODMODE_REGION_PLANE) then
		if (BIG_PLANES[getElementModel(element)]) then
			iprint(getElementModel(element))
			setVehicleDamageProof(element, true)
		end
	end

end
addEventHandler("onClientColShapeHit", GODMODE_REGION_BOAT, enableGodMode)
addEventHandler("onClientColShapeHit", GODMODE_REGION_PLANE, enableGodMode)

function disableGodMode(element, matchingDimension)
	if (getElementType(element) ~= "vehicle") then
		return
	end
	setVehicleDamageProof(element, false)
end
addEventHandler("onClientColShapeLeave", GODMODE_REGION_BOAT, disableGodMode)
addEventHandler("onClientColShapeLeave", GODMODE_REGION_PLANE, disableGodMode)

-- Helper functions
-- Helper functions
-- Helper functions
-- Helper functions
-- Helper functions
-- Helper functions
-- Helper functions
-- Helper functions

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x-dx, y+dy;
end

---- Scoreboard stuff
---- Scoreboard stuff
---- Scoreboard stuff
---- Scoreboard stuff
---- Scoreboard stuff
---- Scoreboard stuff
---- Scoreboard stuff
---- Scoreboard stuff
---- Scoreboard stuff

TEXT = ""
SHOW = false

function setScoreBoard(scores)
	text = "Top times for the Full Experience:\n_______________________________________\n"
	for i, v in pairs(scores) do
		time_ = v["score"]
	
		milliseconds = time_ % 1000
		seconds = ((time_ - milliseconds) % 60000) / 1000
		minutes = (time_ - milliseconds - (seconds * 1000)) / 60000

		zeroSeconds = ""
		zeroMinutes = ""
		zeroMilliseconds = ""
		if (seconds < 10) then
			zeroSeconds = "0"
		end
		if (minutes < 10) then
			zeroMinutes = "0"
		end
		if (milliseconds < 10) then
			zeroMilliseconds = "00"
		elseif (milliseconds < 100) then
			zeroMilliseconds = "0"
		end
		timeText = zeroMinutes .. minutes .. ":" .. zeroSeconds .. seconds .. "." .. zeroMilliseconds .. milliseconds
		
		zeroPos = ""
		if (i < 10) then
			zeroPos = "0"
		end
		text = text .. zeroPos .. i .. ".   " .. timeText .. "    " .. v["playername"] .. "\n"
	end
	if (#scores < 10) then
		for i = #scores + 1, 10, 1 do
			zeroPos = ""
			if (i < 10) then
				zeroPos = "0"
			end
			text = text .. zeroPos .. i .. ".   -- Empty --\n"
		end
	end
	TEXT = text
end
addEvent("setScoreBoard", true)
addEventHandler("setScoreBoard", root, setScoreBoard)

function showScoreBoardCmd()
	showScoreBoard(true, 15000)
end

function showScoreBoard(enabled, duration)
	SHOW = enabled
	if (duration) then
		setTimer(function()
			SHOW = false
		end, duration, 1)
	end
end
addEvent("showScoreBoard", true)
addEventHandler("showScoreBoard", root, showScoreBoard)
addCommandHandler("showtimes", showScoreBoardCmd)

function drawScoreBoard()
	if (SHOW) then
		local width,height = guiGetScreenSize()
		boxX = width * 0.275
		boxY = height * 0.015
		boxWidth = width * 0.18
		boxHeight = (boxWidth * 0.6875)
		dxDrawRectangle(boxX, boxY, boxWidth, boxHeight, tocolor(5, 33, 51, 127))
		dxDrawText(TEXT, width*0.28, height*0.025, width*0.8, height*0.9, tocolor(230, 245, 255, 255), width / 1600, "default-bold", "left", "top", false, true, false, false)
	end
end
addEventHandler("onClientRender", root, drawScoreBoard)


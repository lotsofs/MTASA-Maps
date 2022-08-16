local RACE_RESOURCE = getResourceDynamicElementRoot(getResourceFromName("race"))

MARKER_EXPORT = getElementByID("_MARKER_EXPORT_PARK")
MARKER_BOAT = getElementByID("_MARKER_EXPORT_BOAT")

BLOCKING_BRIDGE = getElementByID("_NON_COLLIDE_BRIDGE")

BRIDGE_DETECTOR = createColCircle(37, -530, 22)
BOAT_DETECTOR = createColCuboid(-476, -966, -5, 929, 839, 15)
REACH_CRANE1 = createColCircle(72.4, -339.4, 89)
REACH_CRANE2 = createColCircle(-61.9, -286.4, 89)
GODMODE_REGION_BOAT = createColCircle(-12.5, -342.0, 15)
GODMODE_REGION_PLANE = createColCuboid(-61, -233, 0, 30, 29, 25)
SPAWN_AREA = createColCuboid(20, -329, 1, 91, 34, 23)

CRANE1_STATE = "init"
CRANE2_STATE = "init"

CRANE_HOOK_VERTICAL_SPEED = 131
CRANE_HOOK_HORIZONTAL_SPEED = 181
CRANE_TURN_SPEED = 220
CRANE_TURN_ODDS = 50
HOOK_BOAT_HEIGHT_OFFSET = 6
LOW_DAMAGE_DIVISOR = 2

LOW_DAMAGE = false
CAR_DELIVERING = false

SCREENWIDTH, SCREENHEIGHT = guiGetScreenSize()
TUTORIAL_BLURB = "<blurb>"

SHUFFLED_CARS = {}
PLAYER_CURRENT_TARGET = 1
-- LAST_CAR = false

RACE_STARTED_ALREADY = 0


VEHICLE_WEAPONS = {
	[38] = true, --hunter minigun
	[37] = true, --heat seeking missiles I think
	[51] = true, --hunter missiles, tank
	[31] = true, --rustler, seasparrow, rc baron
	[28] = true --predator
}

HELICOPTERS = {
	[548] = true,
	[425] = true,
	[417] = true,
	[487] = true,
	[488] = true,
	[497] = true,
	[563] = true,
	[447] = true,
	[469] = true,

	[460] = true,
	[511] = true,
	[519] = true,

	[577] = true,
	[553] = true,
	[592] = true	
}

MEDIUM_PLANES = {
	[460] = true,
	[511] = true,
	[519] = true,

	[577] = true,
	[553] = true,
	[592] = true
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

HELICOPTERS = {
	[548] = true,
	[425] = true,
	[417] = true,
	[487] = true,
	[488] = true,
	[497] = true,
	[563] = true,
	[447] = true,
	[469] = true,
	[465] = true,
	[501] = true
}

BOATS = {
	[460] = {41, 70},
	[511] = {41, 70},
	[519] = {41, 70},

	[577] = {41, 70},
	[553] = {41, 70},
	[592] = {41, 70},

	[472] = {41, 41},
	[473] = {41, 42},
	[493] = {42, 43},
	[595] = {42, 44},
	[484] = {42, 45},
	[430] = {41, 46},
	[453] = {42, 47},
	[452] = {41, 43},
	[446] = {42, 44},
	[454] = {42, 45},

	[610] = {0, 16}, 
	[591] = {25, 29},
	[608] = {18, 26},
	[435] = {42, 42},
	[450] = {45, 45},
	[584] = {42, 42},
	[611] = {0, 18},

	[590] = {0, 46},
	[538] = {0, 66},
	[570] = {0, 22},
	[569] = {0, 30},
	[537] = {0, 41},
	[449] = {0, 42} 
}

TRAILERS = {
	[610] = true,
	[584] = true,
	[608] = true,
	[435] = true,
	[450] = true,
	[591] = true,
	[611] = true,
	
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
	if (CAR_DELIVERING) then
		return
	end
	local x, y, z = getElementPosition(localPlayer)
	if (z > 21) then
		-- When spectating or on the crane still, do nothing
		return
	end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (not vehicle) then
		return
	end
	x, y, z = getElementVelocity(vehicle)
	shittyVelocity = x*x + y*y + z*z
	if (shittyVelocity > 0.0001) then
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
	CAR_DELIVERING = true
	triggerServerEvent("updateProgress", resourceRoot, PLAYER_CURRENT_TARGET)
end
setTimer(playerStoppedInMarker, 1, 0)

function collectCheckpoints(target)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    local checkpoint = getElementData(localPlayer, "race.checkpoint")
    for i=checkpoint, target do
		local colshapes = getElementsByType("colshape", RACE_RESOURCE)
		if (#colshapes == 0) then
			break
		end
		triggerEvent("onClientColShapeHit",
            colshapes[#colshapes], vehicle, true)
    end
end

function finishRace(new)
	collectCheckpoints(#getElementsByType("checkpoint"))
end
addEvent("finishRace", true)
addEventHandler("finishRace", localPlayer, finishRace)

function updateTarget(new)
	CAR_DELIVERING = false
	collectCheckpoints(PLAYER_CURRENT_TARGET)
	PLAYER_CURRENT_TARGET = new
	CRANE1_STATE = "available"
	CRANE2_STATE = "available"
	setElementCollisionsEnabled(BLOCKING_BRIDGE, true)
end
addEvent("updateTarget", true)
addEventHandler("updateTarget", localPlayer, updateTarget)

---- Prevent players from harming one another or themselves in certain cases
---- Prevent players from harming one another or themselves in certain cases
---- Prevent players from harming one another or themselves in certain cases
---- Prevent players from harming one another or themselves in certain cases
---- Prevent players from harming one another or themselves in certain cases

function enableGodMode(element, matchingDimension)
	if (getElementType(element) ~= "vehicle") then
		return
	end
	if (source == GODMODE_REGION_BOAT) then
		if (BOATS[getElementModel(element)]) then
			LOW_DAMAGE = true
			-- setVehicleDamageProof(element, true)
		end
	elseif (source == GODMODE_REGION_PLANE) then
		if (HELICOPTERS[getElementModel(element)]) then
			LOW_DAMAGE = true
			-- setVehicleDamageProof(element, true)
		end
	end

end
addEventHandler("onClientColShapeHit", GODMODE_REGION_BOAT, enableGodMode)
addEventHandler("onClientColShapeHit", GODMODE_REGION_PLANE, enableGodMode)

function disableGodMode(element, matchingDimension)
	if (getElementType(element) ~= "vehicle") then
		return
	end
	LOW_DAMAGE = false
	-- setVehicleDamageProof(element, false)
end
addEventHandler("onClientColShapeLeave", GODMODE_REGION_BOAT, disableGodMode)
addEventHandler("onClientColShapeLeave", GODMODE_REGION_PLANE, disableGodMode)

function bigPlaneDelivery()
	veh = getPedOccupiedVehicle(localPlayer)
	if (not veh) then
		return
	end
	if (veh ~= getPedOccupiedVehicle(localPlayer)) then
		return
	end
	if (not BIG_PLANES[getElementModel(veh)]) then
		return
	end
	if (not isElementWithinColShape(veh, GODMODE_REGION_PLANE)) then
		return
	end
	x, y, z = getElementVelocity(veh)
	shittyVelocity = x*x + y*y + z*z
	if (shittyVelocity > 0.0001) then
		return
	end
	-- collectCheckpoints(PLAYER_CURRENT_TARGET)
	triggerServerEvent("updateProgress", resourceRoot, PLAYER_CURRENT_TARGET)
end
setTimer(bigPlaneDelivery, 100, 0)

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
	-- if (HELICOPTERS[getElementModel(source)] and attacker ~= nil) then
	-- 	setHeliBladeCollisionsEnabled ( source, false )
	-- 	cancelEvent()
	-- end
	if (VEHICLE_WEAPONS[weapon] and attacker ~= localPlayer) then
		cancelEvent()
	elseif (LOW_DAMAGE) then
		setElementHealth(source, getElementHealth(source) - (loss / LOW_DAMAGE_DIVISOR))
		cancelEvent()
	end
		-- 	x, y, z = getElementPosition(source)
		-- 	if (getElementHealth(source) > 250) then
		-- 		return
		-- 	end

		-- 	if (source ~= getPedOccupiedVehicle(localPlayer)) then
		-- 		return
		-- 	end
		-- 	if (not BIG_PLANES[getElementModel(source)]) then
		-- 		return
		-- 	end
		-- 	if (not isElementWithinColShape(source, GODMODE_REGION_PLANE)) then
		-- 		return
		-- 	end
		-- 	setElementHealth(source, 1000)
		-- 	cancelEvent()
		-- 	-- deliver vehicle anyway if it's a big plane inside the godmode region plane and it's ours:
		-- 	collectCheckpoints(PLAYER_CURRENT_TARGET)
		-- 	triggerServerEvent("updateProgress", resourceRoot, PLAYER_CURRENT_TARGET)
end
addEventHandler("onClientVehicleDamage", root, handleVehicleDamage)

-- New Crane Stuff
-- New Crane Stuff
-- New Crane Stuff
-- New Crane Stuff

function resetCranes(killer, weapon, bodypart)
	veh = getPedOccupiedVehicle(source)
	if (veh) then
		detachElements(veh)
	end
	CRANE1_STATE = "available"
	CRANE2_STATE = "available"
	setElementCollisionsEnabled(BLOCKING_BRIDGE, true)
end
addEventHandler("onClientPlayerWasted", localPlayer, resetCranes)

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
end

function preRace()
	configureCrane()
	if (RACE_STARTED_ALREADY > 0) then
		return
	end
	setTimer(function()
		if (RACE_STARTED_ALREADY > 0) then
			return
		end
		setCameraMatrix (  -213.5, -453.5, 63.5, -118.0, -353.8, 0.5)
	end, 1000, 1)
end
addEventHandler("onClientMapStarting", localPlayer, preRace)

function didWeStartYet(yes)
	RACE_STARTED_ALREADY = yes
	setCameraTarget ( localPlayer )
end
addEvent("didWeStartYet", true)
addEventHandler("didWeStartYet", localPlayer, didWeStartYet)

function introCutscene()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (vehicle) then
		setElementPosition(vehicle, 135.9, -309.1, 9.2)
	end
	setCameraMatrix ( -213.5, -453.5, 63.5, -118.0, -353.8, 0.5)
	setTimer(function()
		setCameraMatrix ( -4.6, -99.4, 38.0, -55.0, -233.0, 26.0)
		-- SHOW_TUTORIAL = true
	end, 6000, 1)
	setTimer(function()
		TUTORIAL_BLURB = "Deliver all the vehicles to the FleischBerg© factory!"
		SHOW_TUTORIAL = true
	end, 7000, 1)
	setTimer(function()
		setCameraMatrix ( -27.7, -209.6, 10.9, -50.2, -222.3, 6.4)
		SHOW_TUTORIAL = false
	end, 11000, 1)
	setTimer(function()
		TUTORIAL_BLURB = "Vehicles can be delivered by parking them in this marker."
		SHOW_TUTORIAL = true
	end, 11500, 1)
	setTimer(function()
		setCameraMatrix ( 150.0, -392.0, 55.0, -39.0, -293.0, 32.0)
		SHOW_TUTORIAL = false
	end, 16000, 1)
	setTimer(function()
		TUTORIAL_BLURB = "These cranes will assist you with boats, trains, large planes, and trailers."
		SHOW_TUTORIAL = true
	end, 16500, 1)
	setTimer(function()
		setCameraMatrix ( 170.5, -432.8, 18.0, 100.3, -399.5, 6.8)
		SHOW_TUTORIAL = false
	end, 22000, 1)
	setTimer(function()
		TUTORIAL_BLURB = "Simply park these vehicles anywhere within the cranes' range, such as inside this blue marker."
		SHOW_TUTORIAL = true
	end, 22500, 1)
	setTimer(function()
		SHOW_TUTORIAL = false
	end, 28000, 1)
	setTimer(function()
		if (getCameraTarget(localPlayer) ~= localPlayer) then
			setCameraTarget ( localPlayer )
		end
	end, 32000, 1)
end

-- Initialize all the crane stuff
function gameStart()
	introCutscene()

	createBlip(99.4, -414.6, 0, 9) -- Boat blip

	-- Heli blades are scoffed in ghost mode and MTA does not support any way to fix them decently.
	-- However I can at least disable heliblade collisions of other players so they don't knock you out of the way
	-- You can still knock yourself out of the way by hitting other players with your blades though, despite them being ghost
	local allVehicles = getElementsByType("vehicle")
	local myVehicle = getPedOccupiedVehicle(localPlayer)
	for i, v in ipairs(allVehicles) do
		if (v ~= myVehicle) then
			setHeliBladeCollisionsEnabled ( v, false )
		end
	end
end
addEvent("configureCrane", true)
addEventHandler("configureCrane", resourceRoot, gameStart)

function craneOneBoatGrab()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	local x1,y1,z1 = getElementPosition(crane["bar1"])
	local x2,y2,z2 = getElementPosition(vehicle)
	local u1,v1,w1 = getElementRotation(crane["hook1"])
	local u2,v2,w2 = getElementRotation(vehicle)
	if (CRANE1_STATE == "boat 0") then
		-- move bar above boat
		setCraneBoatState(1, "boat 1")
		local r = findRotation(x1,y1,x2,y2)
		local d
		if (TRAILERS[getElementModel(vehicle)]) then
			d = 0
		end
		local duration = rotateCraneTo(1, r, d, 0.25)
		setTimer(function()
			setCraneBoatState(1, "boat 2")
		end, duration, 1)
	elseif (CRANE1_STATE == "boat 2") then
		-- move hook into boat
		setCraneBoatState(1, "boat 3")
		local d = getDistanceBetweenPoints2D ( x1,y1,x2,y2 )
		t = nil
		if (TRAILERS[getElementModel(vehicle)]) then
			t = 3000
		end
		local duration = moveHook(1, z2 + HOOK_BOAT_HEIGHT_OFFSET, math.min(d,89), 0.5, t)
		setTimer(function()
			setCraneBoatState(1, "boat 4")
		end, duration, 1)
	elseif (CRANE1_STATE == "boat 4") then
		-- raise hook up with boat
		setCraneBoatState(1, "boat 5")
		local x3,y3,z3 = getElementPosition(crane["hook1"])
		local d = getDistanceBetweenPoints2D ( x3,y3,x2,y2 )
		-- if (d > 90) then
		-- 	setCraneBoatState(1, "waiting for boat"
		-- 	return
		-- end
		if (d > 1) then
			setCraneBoatState(1, "boat 0")
			return
		end
		if (getElementHealth(vehicle) >= 250) then
			attachElements(vehicle, crane["rope1"], 0, 0, -HOOK_BOAT_HEIGHT_OFFSET, u2-u1, v2-v1, w2-w1)
		end
		rotateCraneTo(2, 218, nil, 0.5) -- rotate crane 2 into position
		local duration = moveHook(1, BOATS[getElementModel(vehicle)][1], -1) -- formerly 35 - 41
		setTimer(function()
			setCraneBoatState(1, "boat 6")
		end, duration, 1)
	elseif (CRANE1_STATE == "boat 6") then
		-- rotate crane with boat
		setCraneBoatState(1, "boat 7")
		local duration = rotateCraneTo(1, 94, nil, 0.5)
		setTimer(function()
			setCraneBoatState(1, "boat 8")
		end, duration, 1)
	elseif (CRANE1_STATE == "boat 8") then
		-- move hook into range of other crane if not there yet
		setCraneBoatState(1, "boat 9")
		local d = getDistanceBetweenPoints2D ( x1,y1,x2,y2 )
		if (d < 70) then
			local duration = moveHook(1, -1, 83) -- former math.random(70,89)
			setTimer(function()
				setCraneBoatState(1, "boat 10")
			end, duration, 1)
		else
			setCraneBoatState(1, "boat 10")
		end
	elseif (CRANE1_STATE == "boat 10") then
		-- drop boat
		setCraneBoatState(1, "boat 11")
		detachElements(vehicle)
		setTimer(function()
			setCraneBoatState(1, "boat 12")
		end, 500, 1)
	elseif (CRANE1_STATE == "boat 12") then
		-- move crane out of the way
		setCraneBoatState(1, "boat 13")
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
		setCraneBoatState(2, "boat 1")
		local r = findRotation(x1,y1,x2,y2)
		local d = 3000
		if (TRAILERS[getElementModel(vehicle)]) then
			d = 0
		end
		local duration = rotateCraneTo(2, r, d)
		setTimer(function()
			setCraneBoatState(2, "boat 2")
		end, duration, 1)
	elseif (CRANE2_STATE == "boat 2") then
		-- move hook into boat
		setCraneBoatState(2, "boat 3")
		local d = getDistanceBetweenPoints2D ( x1,y1,x2,y2 )
		t = nil
		if (TRAILERS[getElementModel(vehicle)]) then
			t = 3000
		end
		local duration = moveHook(2, z2 + HOOK_BOAT_HEIGHT_OFFSET, math.min(d,95), 0.5, t)
		setTimer(function()
			setCraneBoatState(2, "boat 4")
		end, duration, 1)
	elseif (CRANE2_STATE == "boat 4") then
		-- raise hook up with boat
		setCraneBoatState(2, "boat 5")
		local x3,y3,z3 = getElementPosition(crane["hook2"])
		local d = getDistanceBetweenPoints2D ( x3,y3,x2,y2 )
		if (d > 1) then
			setCraneBoatState(2, "boat 0")
			return
		end
		if (getElementHealth(vehicle) >= 250) then
			attachElements(vehicle, crane["rope2"], 0, 0, -HOOK_BOAT_HEIGHT_OFFSET, u2-u1, v2-v1, w2-w1)
		end
		local duration = moveHook(2, BOATS[getElementModel(vehicle)][2], -1)
		setTimer(function()
			setCraneBoatState(2, "boat 6")
		end, duration, 1)
	elseif (CRANE2_STATE == "boat 6") then
		-- rotate crane with boat
		setCraneBoatState(2, "boat 7")
		local duration = rotateCraneTo(2, 350, nil, 0.3)
		setTimer(function()
			setCraneBoatState(2, "boat 8")
		end, duration, 1)
	elseif (CRANE2_STATE == "boat 8") then
		-- move hook above marker
		setCraneBoatState(2, "boat 9")
		local d = getDistanceBetweenPoints2D ( x1,y1,x2,y2 )
		if (d > 0) then
			local duration = moveHook(2, -1, 65.5)
			setTimer(function()
				setCraneBoatState(2, "boat 10")
			end, duration, 1)
		else
			setCraneBoatState(2, "boat 10")
		end
	elseif (CRANE2_STATE == "boat 10") then
		-- drop boat
		setCraneBoatState(2, "boat 11")
		if (TRAINS[getElementModel(vehicle)]) then
			local duration = moveHook(2, 12.8, -1)
			setTimer(function()
				setCraneBoatState(2, "boat 12")
			end, duration, 1)
		else
			detachElements(vehicle)
			setTimer(function()
				setCraneBoatState(2, "boat 99")
			end, 500, 1)
		end	
	elseif (CRANE2_STATE == "boat 12") then
		setCraneBoatState(2, "boat 99")
		detachElements(vehicle)
		local duration = moveHook(2, math.random(20,41), -1)
	end
end

function repairVehicleOnCrane()
	local veh = getPedOccupiedVehicle(localPlayer)
	if (veh and getElementAttachedTo(veh) ~= false and getElementHealth(veh) < 250) then
		setElementHealth(veh, 251)
	end
end
setTimer(repairVehicleOnCrane, 100, 0)

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
function moveHook(craneID, destinationZ, destinationD, speedMultiplier, time)
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
	if (time ~= nil) then
		duration = time
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

function craneDetectApproachingBoat(element, matchingDimension)
	-- TODO: and not in spawn area
	
	if (element ~= localPlayer) then
		return
	end
	local vehicle = getPedOccupiedVehicle(localPlayer)

	-- local f1,f2,f3,f5,f6,f7,f8,f9 = getCameraMatrix()
	-- setCameraMatrix(-1587, 702, -4)
	-- -- setCameraMatrix(f1,f2,f3,f5,f6,f7,f8,f9)
	-- setCameraTarget(localPlayer)
	-- setTimer(function(vehicle)
	-- 	setElementPosition(vehicle, -1587, 702, -4)
	-- end, 10000, 1, vehicle)	

	if (not vehicle) then
		return
	end
	vehicle = getElementModel(vehicle)
	if (not vehicle or not BOATS[vehicle]) then
		return
	end
	if (CRANE1_STATE ~= "waiting for boat") then
		CRANE1_STATE = "waiting for boat"
		iprint("Crane wasn't ready yet")
	end
	rotateCraneTo(1, 200, 20000)
end
addEventHandler("onClientColShapeHit", BOAT_DETECTOR, craneDetectApproachingBoat)

function bridgeTropicCollisionDisable(element, matchingDimension)
	if (element ~= localPlayer) then
		return
	end
	local vehicle = getElementModel(getPedOccupiedVehicle(localPlayer))
	if (not vehicle or vehicle ~= 454) then -- tropic
		return
	end
	setElementCollisionsEnabled(BLOCKING_BRIDGE, false)
end
addEventHandler("onClientColShapeHit", BRIDGE_DETECTOR, bridgeTropicCollisionDisable)
--- Other Stuff
--- Other Stuff
--- Other Stuff
--- Other Stuff
--- Other Stuff
--- Other Stuff
--- Other Stuff
--- Other Stuff

function playGoSound()
	playSoundFrontEnd(43)
end
addEvent("playGoSound", true)
addEventHandler("playGoSound", resourceRoot, playGoSound)

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

---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff
---- Scoreboard and UI stuff

TEXT = ""
SHOW_SCOREBOARD = false

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
	SHOW_SCOREBOARD = enabled
	if (duration) then
		setTimer(function()
			SHOW_SCOREBOARD = false
		end, duration, 1)
	end
end
addEvent("showScoreBoard", true)
addEventHandler("showScoreBoard", root, showScoreBoard)
addCommandHandler("showtimes", showScoreBoardCmd)

function drawScoreBoard()
	if (SHOW_SCOREBOARD) then
		local width,height = guiGetScreenSize()
		boxX = width * 0.275
		boxY = height * 0.015
		boxWidth = width * 0.18
		boxHeight = (boxWidth * 0.6875)
		dxDrawRectangle(boxX, boxY, boxWidth, boxHeight, tocolor(5, 33, 51, 127))
		dxDrawText(TEXT, width*0.28, height*0.025, width*0.8, height*0.9, tocolor(230, 245, 255, 255), width / 1600, "default-bold", "left", "top", false, true, false, false)
	end
	if (SHOW_TUTORIAL) then
		drawBorderedText(TUTORIAL_BLURB, 2, SCREENWIDTH*0.20, SCREENHEIGHT*0.35, SCREENWIDTH*0.8, SCREENHEIGHT, tocolor(255, 255, 255, 255), 3, "default-bold", "center", "top", false, true, true, false)
	end
end
addEventHandler("onClientRender", root, drawScoreBoard)

function drawBorderedText(text, borderSize, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
	-- width = width * screenWidth
	-- height = height * screenHeight
	-- width2 = width2 * screenWidth
	-- height2 = height2 * screenHeight
	-- size = screenWidth * size * 0.0005
	-- borderSize = size

	dxDrawText(text2, width+borderSize, height, width2+borderSize, height2, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width, height+borderSize, width2, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width, height-borderSize, width2, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height, width2-borderSize, height2, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width+borderSize, height+borderSize, width2+borderSize, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height-borderSize, width2-borderSize, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width+borderSize, height-borderSize, width2+borderSize, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height+borderSize, width2-borderSize, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
end
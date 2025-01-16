local RACE_RESOURCE = getResourceDynamicElementRoot(getResourceFromName("race"))
HALT_DELIVERY_TIMER_MS = 0
MARKER_EXPORT = getElementByID("_MARKER_EXPORT_PARK")
MARKER_TANKER = getElementByID("_MARKER_EXPORT_TANKER")
PLAYER_CURRENT_TARGET = 1
RACE_STARTED_ALREADY = 0
CUSTOM_TIMER = 11

function deliverVehicle() 
	if (HALT_DELIVERY_TIMER_MS > 0) then return end
	HALT_DELIVERY_TIMER_MS = 2000
	local score = getElementData(localPlayer, "Money")
	if (not score) then
		score = 0
	end
	veh = getPedOccupiedVehicle(localPlayer)
	monetary = getVehicleHandling(veh)["monetary"]
	damage = getElementHealth(veh) / 1000
	reward = monetary * damage
	reward = math.floor(reward)
	score = score + reward
	setElementData(localPlayer, "Money", score, true)
	triggerServerEvent("updateProgress", resourceRoot, PLAYER_CURRENT_TARGET)
end

function checkDelivery(deltaTime)
	if (HALT_DELIVERY_TIMER_MS > 0) then
		-- When delivering a car or respawning, we want to pause deliveries to avoid fake deliveries
		-- This is put on a timer. We're not using timer class because it is clunky to use when
		-- the timer needs to be reset midway through (eg someone spams enter to commit sudoku repeatedly)
		HALT_DELIVERY_TIMER_MS = HALT_DELIVERY_TIMER_MS - deltaTime
		return
	end

	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (not vehicle) then
		-- Unsure when this happens. Maybe in spectate mode. Either way, do nothing
		return
	end

	if (isElementFrozen(vehicle)) then
		-- Upon respawning, our vehicle is frozen temporarily. Do not check for progress in this state.
		return
	end

	if (getElementAttachedTo(vehicle) ~= false) then
		-- We are attached to a crane, do nothing
		return
	end

	local x,y,z = getElementPosition(localPlayer)
	if (z > 1000 or getElementData(localPlayer, "state") == "spectating") then
		-- When spectating the position is set to 30k. 1000 is the maxc flight limit. Do nothing
		return
	end

	local vehicleModel = getElementModel(vehicle)
	if (vehicleModel == 522 or vehicleModel == 438 or vehicleModel == 420) then
		-- Ignore pre-start race vehicles
		return
	end

	local vx,vy,vz = getElementVelocity(vehicle)
	local shittyVelocity = vx*vx+vy*vy+vz*vz
	local targetVelocity = 0.0001

	if (shittyVelocity > targetVelocity) then
		-- We are not actually stopped
		return
	end

	if (isElementWithinMarker(vehicle, MARKER_TANKER)) then
		-- We are a tanker in the tanker marker
 		moveCrane()
	elseif (isElementWithinMarker(vehicle, MARKER_EXPORT)) then
		-- We are in the export marker. All conditions met. Deliver
		outputConsole("Delivering vehicle as normal: " .. vehicleModel)
		deliverVehicle()
		return
	end

	-- -- Check if the player is stopped by any of the cranes. Check crane 2 first because 1 doesnt need to do anything if 2 can handle it.
	-- if (BOATS[getElementModel(vehicle)] and isElementWithinColShape(vehicle, REACH_CRANE2)) then
	-- 	craneGrab(2)
	-- elseif (BOATS[getElementModel(vehicle)] and isElementWithinColShape(vehicle, REACH_CRANE1)) then
	-- 	craneGrab(1)
	-- end
end
addEventHandler("onClientPreRender", root, checkDelivery)

function updateTarget(new)
	CAR_DELIVERING = false
	-- Autoload
	if (new > PLAYER_CURRENT_TARGET + 1) then
		PLAYER_CURRENT_TARGET = new - 1
		MID_PLAY_BLURB = "Your saved progress has been restored. Use /ie_resetprogress to undo."
		SHOW_MID_PLAY_TUTORIAL = true
		setTimer(function()
			SHOW_MID_PLAY_TUTORIAL = false
		end, 7000, 1)
	end
	-- Reset progress?
	if (new < PLAYER_CURRENT_TARGET) then
		PLAYER_CURRENT_TARGET = new - 1
	end
	-- Normal behavior
	collectCheckpoints(PLAYER_CURRENT_TARGET)
	PLAYER_CURRENT_TARGET = new
	resetDeliveryArea()
end
addEvent("updateTarget", true)
addEventHandler("updateTarget", localPlayer, updateTarget)

function resetDeliveryArea()
	HALT_DELIVERY_TIMER_MS = 5000
	veh = getPedOccupiedVehicle(localPlayer)
	if (veh) then
		detachElements(veh)
		setHeliBladeCollisionsEnabled ( veh, false )
	end

	local vehicleId = getElementModel(veh)
	local carName = VEHICLE_NAMES[vehicleId]
	CAR_BLURB = carName
	setElementData(localPlayer, "Vehicle", carName, true)
	SHOW_CAR = true
	setTimer(function()
		SHOW_CAR = false
	end, 6500, 1)

	makeMarkerVisible(vehicleId == 514)
end

--- More
--- More
--- More
--- More

function playerDead(killer, weapon, bodypart)
	resetDeliveryArea()
end
addEventHandler("onClientPlayerWasted", localPlayer, playerDead)

function didWeStartYet(yes)
	RACE_STARTED_ALREADY = yes
end
addEvent("didWeStartYet", true)
addEventHandler("didWeStartYet", localPlayer, didWeStartYet)

function postCutsceneGameStart()
	resetDeliveryArea()
end
addEvent("postCutsceneGameStart", true)
addEventHandler("postCutsceneGameStart", localPlayer, postCutsceneGameStart)

-- Initialize all the crane stuff
function preCutsceneGameStart()
	--SHOW_TUTORIAL = true
	TUTORIAL_BLURB = CUSTOM_TIMER
	setTimer(function()
		CUSTOM_TIMER = CUSTOM_TIMER - 1
		TUTORIAL_BLURB = CUSTOM_TIMER
		iprint(CUSTOM_TIMER)
	end, 1000, 8)
	setTimer(function()
		SHOW_TUTORIAL = false
	end, 8000, 1)
	-- resetDeliveryArea()
	local x, y, z = getElementPosition(MARKER_EXPORT)
	createBlip(x, y, z, 0) -- Blip
	setElementData(localPlayer, "Money", 0, true)
end
addEvent("gridCountdownStarted", true)
addEventHandler("gridCountdownStarted", resourceRoot, preCutsceneGameStart)

function pollEnded()
	if (CUSTOM_TIMER > 3) then
		SHOW_TUTORIAL = true
	end
end
addEvent("pollEnded", true)
addEventHandler("pollEnded", resourceRoot, pollEnded)

function repairVehicleOnCrane()
	local veh = getPedOccupiedVehicle(localPlayer)
	if (veh and getElementAttachedTo(veh) ~= false and getElementHealth(veh) < 250) then
		setElementHealth(veh, 251)
	end
end
setTimer(repairVehicleOnCrane, 100, 0)



--- Stadium music Disabler

addEventHandler("onClientResourceStart", getRootElement(), function()	
	setInteriorSoundsEnabled(false)
end )

addEventHandler("onClientResourceStop", getRootElement(), function()
	setInteriorSoundsEnabled(true)
end )

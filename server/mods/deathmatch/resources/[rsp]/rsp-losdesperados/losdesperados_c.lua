MISSION_ID = "losdesperados"
MISSION_NAME = "Los Desperados"

------------------
-- Boiler Plate --
------------------

ONMISSION_CURRENT = false

-- This resource just started, do a check if the mission is started by/for us
function resourceStarted()
	if (ONMISSION_CURRENT) then
		return
	end
	local currentMission = getElementData(localPlayer, "rsp-onmission")
	if (currentMission == MISSION_ID) then
		iprint("Loaded and started mission ", currentMission)
		initMission()
	end
end
addEventHandler("onClientResourceStart", resourceRoot, resourceStarted)

-- The resource was already running, but we started a mission. Check if it's this one.
function evaluateStartedMission(mission)
	if (ONMISSION_CURRENT) then
		return
	end
	if (mission ~= MISSION_ID) then 
		return 
	end
	iprint("Started already loaded mission ", mission)
	initMission()
end
addEventHandler("onClientMissionStarted", root, evaluateStartedMission)

function initMission()
	ONMISSION_CURRENT = true
	startMission()
end

function passMission()
	triggerEvent("onClientMissionPassed", localPlayer, MISSION_ID)
end

---------------
-- Waypoints --
---------------

WAYPOINTS = getElementsByType("waypoint")
NEXTWAYPOINT = nil
NEXTBLIP = nil
PROGRESS = 1

function startMission()
	ONMISSION_CURRENT = true
	createWaypoint(1)
end

-- Marker hit. The event is already bound to a specific marker, so we only need to check who hit it
function markerHit(hitPlayer, matchingDimension)
	if (hitPlayer ~= localPlayer) then return end
	progressMission()
end

-- Progress missions (marker hit, target killed, destination reached, etc)
function progressMission()
	PROGRESS = PROGRESS + 1
	removeEventHandler("onClientMarkerHit", NEXTWAYPOINT, markerHit)
	destroyElement(NEXTWAYPOINT)
	destroyElement(NEXTBLIP)
	if (PROGRESS > #WAYPOINTS) then
		passMission()
		return
	end
	createWaypoint(PROGRESS)
end

-- Create the next waypoint (checkpoint)
function createWaypoint(index)
	local w = WAYPOINTS[index]
	local x = getElementData(w, "posX")
	local y = getElementData(w, "posY")
	local z = getElementData(w, "posZ") - 1
	local col = getElementData(w, "color")
	local r,g,b,a = getColorFromString(col)
	local size = getElementData(w, "size")
	local markerType = getElementData(w, "type")
	local markerId = "marker_" .. getElementID(w)
	NEXTWAYPOINT = createMarker(x, y, z, markerType, size, r, g, b, a, resourceRoot)
	NEXTBLIP = createBlip(x, y, z, 0, 2, r, g, b, a)
	addEventHandler("onClientMarkerHit", NEXTWAYPOINT, markerHit)
end

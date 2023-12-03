CRANE_STATE = {
    [1] = "init",
    [2] = "init",
    [3] = "init"
}

CRANE_BASE = {}
CRANE_BAR = {}
CRANE_HOOK = {}
CRANE_ROPE = {}
CRANE_LOWLOD_A = {}
CRANE_LOWLOD_B = {}

CRANE_ROTATING = {}
CRANE_HOOKING = {}

CRANE_HOOK_VERTICAL_SPEED = 131
CRANE_HOOK_HORIZONTAL_SPEED = 181
CRANE_TURN_SPEED = 220
CRANE_TURN_ODDS = 50
HOOK_BOAT_HEIGHT_OFFSET = 6

REACH_CRANE1 = createColCircle(72.4, -339.4, 89)
REACH_CRANE2 = createColCircle(-61.9, -286.4, 89)

function initCranes()
    craneInit(1)
    craneInit(2)
    craneInit(3)
end

function craneInit(craneID)
    if (craneID == 3) then
        return
    end
    
    if (CRANE_STATE[craneID] ~= "init") then
        return
    end

    iprint("_CRANE" .. craneID .. "_POLE");
    CRANE_BASE[craneID] = getElementByID("_CRANE" .. craneID .. "_POLE")
    CRANE_BAR[craneID] = getElementByID("_CRANE" .. craneID .. "_BAR")
    CRANE_HOOK[craneID] = getElementByID("_CRANE" .. craneID .. "_HOOK")
    CRANE_ROPE[craneID] = getElementByID("_CRANE" .. craneID .. "_ROPE")

    -- Make the cranes visibile from afar by spawning a LowLOD version (TODO: someone pls tell me what model to use)
    local pX, pY, pZ = getElementPosition(CRANE_BASE[craneID])
    CRANE_LOWLOD_A[craneID] = createObject(1391, pX, pY, pZ, 0, 0, 0, true)
    setObjectScale ( CRANE_LOWLOD_A[craneID], 1.5)

    local bX, bY, bZ = getElementPosition(CRANE_BAR[craneID])
    CRANE_LOWLOD_B[craneID] = createObject(1394, bX, bY, bZ, 0, 0, 0, true)
    setObjectScale ( CRANE_LOWLOD_B[craneID], 1.5)

    attachElements ( CRANE_LOWLOD_B[craneID], CRANE_BAR[craneID], 0, 0, 0)
    
	-- assemble crane
    local rX, rY, rZ = getElementPosition(CRANE_ROPE[craneID])
    local hX, hY, hZ = getElementPosition(CRANE_HOOK[craneID])
	local barX, barY, barZ = getElementPosition(CRANE_BAR[craneID])
	local ropeX, ropeY, ropeZ = getElementPosition(CRANE_ROPE[craneID])
	local hookX, hookY, hookZ = getElementPosition(CRANE_HOOK[craneID])
	attachElements ( CRANE_HOOK[craneID], CRANE_ROPE[craneID], hX-rX, hY-rY, hZ-rZ )
	attachElements ( CRANE_ROPE[craneID], CRANE_BAR[craneID], rX-bX, rY-bY, rZ-bZ )
	
	-- done
    CRANE_STATE[craneID] = "available"

    CRANE_ROTATING[craneID] = false
    CRANE_HOOKING[craneID] = false

	setTimer(craneTimerTick, 100, 0, craneID)
end

function craneTimerTick(craneID)
    iprint(craneID, CRANE_STATE[craneID])
    if (CRANE_ROTATING[craneID] == true or CRANE_HOOKING[craneID] == true) then
        -- The crane is currently busy rotating. Wait...
        return
    end

    if (craneID == 1 or craneID == 2) then
        -- Check if the player is in a boat. If they are, we will halt 
        -- recreative crane movement and keep it idle until we arrive
        local vehicle = getPedOccupiedVehicle(localPlayer)
        if (not vehicle) then
            return
        end
        local vehicleModel = getElementModel(vehicle)
        if (BOATS[vehicleModel]) then
            if (CRANE_STATE[craneID] == "available") then
                CRANE_STATE[craneID] = "waiting for boat"
            end
        end
    end
    
    -- Rotate the crane for fun as it is not doing anything else
    local r = math.random(1,CRANE_TURN_ODDS)
	if (r > 1) then
		return
	end
    if (CRANE_STATE[craneID] == "available") then
		-- CRANE_STATE[craneID] = "rotating for fun"
		if (craneID == 1 or craneID == 3) then
            r = math.random(-270,270)
		    rotateCraneRelative(craneID, r)        
        else
            r = math.random(36,376)
            rotateCraneTo(craneID, r)           
        end
    end

	-- if (CRANE1_STATE:find("^boat") ~= nil) then
	-- 	craneOneBoatGrab()
	-- 	return
	-- end
end

function rotateCraneRelative(craneID, wDiff)
	local x,y,z = getElementPosition(CRANE_BAR[craneID])
	local u,v,w = getElementRotation(CRANE_BAR[craneID])
	local duration = math.abs(wDiff * CRANE_TURN_SPEED)

    CRANE_ROTATING[craneID] = true
	moveObject(CRANE_BAR[craneID], duration, x, y, z, 0, 0, wDiff, "InOutQuad")
	setTimer(finalizeCraneRotation, duration, 1, craneID)
    return duration
end

function rotateCraneTo(craneID, wDest, time, speedMultiplier)
	local x,y,z = getElementPosition(CRANE_BAR[craneID])
	local u,v,w = getElementRotation(CRANE_BAR[craneID])   
    
    if (craneID == 2 and w <= 16) then
		wDest = wDest - 360
	elseif (craneID ~= 2 and wDest + 360 - w < 180) then
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

    CRANE_ROTATING[craneID] = true
	moveObject(bar, duration, x, y, z, 0, 0, wDiff, "InOutQuad")
	setTimer(finalizeCraneRotation, duration, 1, craneID)
	return duration

end

function finalizeCraneRotation(craneID)
    CRANE_ROTATING[craneID] = false
end












function makeCraneAvailableOld(craneID, force)
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

function rotateCraneToOld(craneID, wDest, time, speedMultiplier)
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

function rotateCraneRelativeOld(craneID, wDiff)
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


function craneTimerTickOld(craneID)
	
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


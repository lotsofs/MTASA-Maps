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
CRANE_TIMER = {}
CRANE_SLEEPTIMER = {}

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
    -- craneInit(3)
end

function craneInit(craneID)
    if (CRANE_STATE[craneID] ~= "init") then
        return
    end

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
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if (not vehicle) then
        return
    end
    if (getElementAttachedTo(vehicle) ~= false and getElementData(localPlayer, "state") == "spectating") then
        detachElements(vehicle)
    end
    
    if (CRANE_ROTATING[craneID] == true or CRANE_HOOKING[craneID] == true) then
        -- The crane is currently busy rotating. Wait...
        return
    end

    local vehicleModel = getElementModel(vehicle)

    if (CRANE_STATE[craneID] == "sleeping") then
        if (CRANE_SLEEPTIMER[craneID] <= 0) then
            if (craneID == 1) then
                -- Rotate crane out of the way
                rotateCraneTo(1, math.random(135, 405))
                CRANE_STATE[1] = "available"
            elseif (craneID == 2) then
                -- Make crane 2 available again in case something went wrong
                CRANE_STATE[2] = "available"
            end
        end
        CRANE_SLEEPTIMER[craneID] = CRANE_SLEEPTIMER[craneID] - 1

    elseif (CRANE_STATE[craneID] == "assist") then
        if (getElementAttachedTo(vehicle) ~= false) then
            local desiredZ = BOATS[vehicleModel][craneID]
            local rX,rY,rZ = getElementPosition(CRANE_ROPE[craneID])
            local bU,bV,bW = getElementRotation(CRANE_BAR[craneID])
            local bX, bY, bZ = getElementPosition(CRANE_BASE[craneID])
            local vX,vY,vZ = getElementPosition(vehicle)
            local vehicleDistanceFromBase = getDistanceBetweenPoints2D(bX,bY,vX,vY)
            local hookHeightDeviation = math.abs(rZ-desiredZ)
            local rotDestination
            if (craneID == 1) then
                rotDestination = 94
            elseif (craneID == 2) then
                rotDestination = 350
            end
            local barDirectionDeviation = math.abs(bW-rotDestination)
            if (hookHeightDeviation > 0.1 and barDirectionDeviation > 0.1) then
                -- Move the hook up to the required height
                moveHook(craneID, desiredZ, -1)
            elseif (barDirectionDeviation > 0.1) then
                -- Rotate the crane to its destination
                rotateCraneTo(craneID, rotDestination, nil, 0.5)
            elseif (craneID == 1 and vehicleDistanceFromBase < 70) then
                -- Move the hook forward or backwards before the drop
                moveHook(craneID,-1,83)
            elseif (craneID == 2 and math.abs(vehicleDistanceFromBase-65.5) > 1) then
                moveHook(craneID,-1,65.5)
            elseif (craneID == 1 and MEDIUM_PLANES[vehicleModel] and rZ-14 > 0) then
                -- Lower big planes down safely so they don't get blown up when put down
                moveHook(craneID, 13.5, -1)
            elseif (craneID == 2 and TRAINS[vehicleModel] and rZ-13 > 0) then
                -- Lower trains down into the marker since they have no proper physics
                moveHook(craneID, 12.8, -1)
            else
		        detachElements(vehicle)
                if (craneID == 2) then
                    moveHook(craneID, math.random(20,41), -1)
                end
                CRANE_SLEEPTIMER[craneID] = 5
                CRANE_STATE[craneID] = "sleeping"
            end
        else
            local vX,vY,vZ = getElementPosition(vehicle)
            local hX,hY,hZ = getElementPosition(CRANE_HOOK[craneID])
            local hookDistance = getDistanceBetweenPoints2D(hX,hY,vX,vY)
            -- Check if the hook is near the car
            if (hookDistance < 0.5 and getElementHealth(vehicle) >= 250) then
                local hU,hV,hW = getElementRotation(CRANE_HOOK[craneID])
                local vU,vV,vW = getElementRotation(vehicle)
                attachElements(vehicle, CRANE_ROPE[craneID], 0, 0, -HOOK_BOAT_HEIGHT_OFFSET, vU-hU, vV-hV, vW-hW)
                if (craneID == 1) then
                    local craneTwoMoveIntoPositionSpeed = 1
                    if (TRAILERS[vehicleModel]) then
                        craneTwoMoveIntoPositionSpeed = 0.5
                    end
		            rotateCraneTo(2, 218, nil, 1) -- rotate crane 2 into position upon being grabbed by crane 1
                end
                return
            end
    
            local bX,bY,zY = getElementPosition(CRANE_BAR[craneID])
            local bU,bV,bW = getElementRotation(CRANE_BAR[craneID])
            local vehicleAngleFromCrane = findRotation(bX,bY,vX,vY)
            local craneAngleFromVehicle = math.abs(vehicleAngleFromCrane - bW) % 360
            -- Check if the crane is pointing at us
            if (craneAngleFromVehicle < 0.1 or craneAngleFromVehicle > 359.9) then
                -- The crane is pointing at us. Move hook in.
                local vD = getDistanceBetweenPoints2D(bX,bY,vX,vY)
                local t = -1
                if (TRAILERS[vehicleModel]) then
                    t = 3000
                end
                moveHook(craneID, vZ + HOOK_BOAT_HEIGHT_OFFSET, math.min(vD,89), 0.5, t)
            else
                -- The crane is not pointing at us, move the bar over the boat
                local t = -1
                if (TRAILERS[vehicleModel]) then
                    t = 0
                end
                rotateCraneTo(craneID, vehicleAngleFromCrane, t, 0.25)
            end
        end

    elseif (CRANE_STATE[craneID] == "available") then
        -- Check if the player is in a boat. If they are, we will halt 
        -- recreative crane movement and keep it idle until we arrive
        if (BOATS[vehicleModel]) then
            CRANE_STATE[craneID] = "waiting for boat"
        else
            -- Rotate the crane for fun as it is not doing anything else
            local r = math.random(1,CRANE_TURN_ODDS)
            if (r < 2) then
                if (craneID ~= 2) then
                    r = math.random(-270,270)
                    rotateCraneRelative(craneID, r)        
                else
                    r = math.random(36,376)
                    rotateCraneTo(craneID, r)           
                end
            end
        end
    end
end

function rotateCraneRelative(craneID, wDiff)
	local x,y,z = getElementPosition(CRANE_BAR[craneID])
	local u,v,w = getElementRotation(CRANE_BAR[craneID])
	local duration = math.abs(wDiff * CRANE_TURN_SPEED)

    CRANE_ROTATING[craneID] = true
	moveObject(CRANE_BAR[craneID], duration, x, y, z, 0, 0, wDiff, "InOutQuad")
	if (duration > 0) then
        CRANE_TIMER[craneID] = setTimer(finalizeCraneRotation, duration, 1, craneID)
    else
        finalizeCraneRotation(craneID)
    end
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
	moveObject(CRANE_BAR[craneID], duration, x, y, z, 0, 0, wDiff, "InOutQuad")
	if (duration > 0) then
        CRANE_TIMER[craneID] = setTimer(finalizeCraneRotation, duration, 1, craneID)
    else
        finalizeCraneRotation(craneID)
    end
	return duration

end

function finalizeCraneRotation(craneID)
    CRANE_ROTATING[craneID] = false
    CRANE_TIMER[craneID] = false
end

-- raise or lower the hook
function moveHook(craneID, destinationZ, destinationD, speedMultiplier, time)
	-- max values for crane 1: Z = 41, D = 89
	-- max values for crane 2: Z = 70.6, D = 89
	-- min D = 5ish
    -- D = horizontal distance of the rope from the base
	
	local rope = CRANE_ROPE[craneID]
	local base = CRANE_BAR[craneID]

    detachElements(rope)
	local u,v,w = getElementRotation(base)
	setElementRotation(rope,u,v,w)

	local xBase, yBase, zBase = getElementPosition(base)
	local xHook, yHook, zHook = getElementPosition(rope)
	local aBar = findRotation( xBase, yBase, xHook, yHook ) 
	local dHook = getDistanceBetweenPoints2D ( xBase, yBase, xHook, yHook )
	if (destinationD < 0) then
		destinationD = dHook
	end
	local xNew, yNew = getPointFromDistanceRotation(xBase, yBase, destinationD, aBar)
	if (destinationZ < 0) then
		destinationZ = zHook
	end

	local duration
    if (time ~= nil and time >= 0) then
        duration = time
    else
        local zDiff = math.abs(zHook - destinationZ)
        local zDuration = zDiff * CRANE_HOOK_VERTICAL_SPEED
        local dDiff = math.abs(dHook - destinationD)
        local dDuration = dDiff * CRANE_HOOK_HORIZONTAL_SPEED
        
        duration = math.max(dDuration, zDuration)
        if (speedMultiplier ~= nil) then
            duration = duration * speedMultiplier
        end
    end

	CRANE_HOOKING[craneID] = true
    moveObject(rope, duration, xNew, yNew, destinationZ, 0, 0, 0, "InOutQuad")
	if (duration > 0) then
        CRANE_TIMER[craneID] = setTimer(finalizeCraneHookment, duration, 1, craneID)
    else
        finalizeCraneHookment(craneID)
    end
	return duration
end

-- attach the hook to the bar after moving it
function attachHook(craneID)
    local barX, barY, barZ = getElementPosition(CRANE_BAR[craneID])
    local ropeX, ropeY, ropeZ = getElementPosition(CRANE_ROPE[craneID])
    local ropeU, ropeV, ropeW = getElementRotation(CRANE_ROPE[craneID])
    attachElements ( CRANE_ROPE[craneID], CRANE_BAR[craneID], 0, getDistanceBetweenPoints2D (barX,barY,ropeX,ropeY), ropeZ-barZ )
end

function finalizeCraneHookment(craneID)
    attachHook(craneID)
    CRANE_HOOKING[craneID] = false
    CRANE_TIMER[craneID] = false
end


function craneDetectApproachingBoat(element, matchingDimension)
	-- TODO: and not in spawn area
	
	if (element ~= localPlayer) then
		return
	end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (not vehicle) then
		return
	end
    
	vehicle = getElementModel(vehicle)
	if (not vehicle or not BOATS[vehicle]) then
		return
	end
	if (CRANE_STATE[1] == "available") then
		--iprint("Crane wasn't ready yet")
	end
	if (CRANE_STATE[1] == "available" or CRANE_STATE[1] == "waiting for boat") then
        rotateCraneTo(1, 200, 20000)
    end
end
addEventHandler("onClientColShapeHit", BOAT_DETECTOR, craneDetectApproachingBoat)

function abortCraneMovement(craneID)
    if (CRANE_ROTATING[craneID]) then
        --iprint("Crane was ill-prepared", craneID)
        stopObject(CRANE_BAR[craneID])
        CRANE_ROTATING[craneID] = false
        if (CRANE_TIMER[craneID]) then
            killTimer(CRANE_TIMER[craneID])
        end
        CRANE_TIMER[craneID] = false
    end
end

function craneGrab(craneID)
	if (CRANE_STATE[craneID] == "available") then
        --iprint("Crane was not aware this would happen", craneID)
        abortCraneMovement(craneID)
    end
    if (CRANE_STATE[craneID] == "waiting for boat") then
        abortCraneMovement(craneID)
    end
    CRANE_STATE[craneID] = "assist"
end
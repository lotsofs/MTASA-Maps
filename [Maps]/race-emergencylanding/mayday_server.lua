MARKER = getElementByID("_MARKER")
TELEPORTING = {}
RACE_STARTED = false

function disableHealth(player)
	vehicle = getPedOccupiedVehicle(player)
	setElementHealth(vehicle, 251)
	setElementHealth(vehicle, 249)
end

function setLowHealth(player)
	vehicle = getPedOccupiedVehicle(player)
	setElementHealth(vehicle, 251)
end 

function onRaceStateChanging(newState, oldState)
	if (newState == "GridCountdown") then
		triggerClientEvent(root, "setHeliBladesCollidableAll", resourceRoot)
		setCloudsEnabled(true)
	end
	if (newState == "Running") then
		setCloudsEnabled(true)
		triggerClientEvent(root, "setHeliBladesCollidableAll", resourceRoot)
		RACE_STARTED = true
		for i, v in pairs(getElementsByType("player")) do
			disableHealth(v)
		end
	end
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, onRaceStateChanging)

function onPlayerReachCheckpoint(checkpoint, time_)
	-- set health
	if (checkpoint < #getElementsByType("checkpoint") - 1) then
		disableHealth(source)
	else
		setLowHealth(source)
	end	
	
	-- trigger events
	if (checkpoint == 2) then
		triggerClientEvent(source, "crashAT", resourceRoot)
	elseif (checkpoint == 3) then
		triggerClientEvent(source, "crashHydras", resourceRoot)
	elseif (checkpoint == 4) then
		triggerClientEvent(source, "crashTower", resourceRoot)
	elseif (checkpoint == 5) then
		triggerClientEvent(source, "crashHelicopter", resourceRoot)
	end	
end
addEventHandler("onPlayerReachCheckpoint", root, onPlayerReachCheckpoint)

function getDistanceToLandingPad(vehicle)
	x1, y1, z1 = getElementPosition(MARKER)
	x2, y2, z2 = getElementPosition(vehicle)
	return getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
end

function onVehicleEnter(thePlayer, seat, jacked)
	if (not RACE_STARTED) then
		return
	end
	if (getElementType(thePlayer) == "player") then
		triggerClientEvent(root, "setHeliBladesCollidable", resourceRoot, source)
		if (getDistanceToLandingPad(source) < 100) then
			setTimer(setLowHealth, 2100, 1, thePlayer)
		else
			setTimer(disableHealth, 2100, 1, thePlayer)
		end
	end
end
addEventHandler("onVehicleEnter", root, onVehicleEnter)

function playerStoppedInMarker()
	for i,v in ipairs(getElementsByType("player")) do	
		vehicle = getPedOccupiedVehicle(v)
		if (vehicle) then
			velocity = getDistanceBetweenPoints3D(0,0,0,getElementVelocity(vehicle))
			if (velocity < 0.001 and getDistanceToLandingPad(vehicle) < 30 and not TELEPORTING[v]) then
				TELEPORTING[v] = true
				x1,y1,z1 = getElementPosition(vehicle)
				checkpoints = getElementsByType("checkpoint")
				x2,y2,z2 = getElementPosition(checkpoints[#checkpoints])
				setElementPosition(vehicle,x2,y2,z2)
				setElementPosition(vehicle,x1,y1,z1)
			end
		end
	end
end
setTimer(playerStoppedInMarker, 1, 0)





-- setTimer(function()
	-- for i, v in pairs(getElementsByType("player")) do
		-- vehicle = getPedOccupiedVehicle(v)
		-- --outputChatBox(getElementHealth(vehicle))
	-- end
-- end, 1, 0)

-- car = nil
-- sir = nil

-- function aaa()
	-- -- asdf = getModelHandling(476)
	-- -- for i, v in pairs(asdf) do
		-- -- setModelHandling(476, i, v)
	-- -- end
	-- -- for k,_ in pairs(getModelHandling(476)) do
		-- -- setModelHandling(476, k, nil)
	-- -- end
	-- vehicle = getPedOccupiedVehicle(localPlayer)
	-- x,y,z = getElementPosition(vehicle)
	-- if (car) then
		-- destroyElement(car)
	-- end
	-- sir = createPed(120,x+10,y,z)
	-- car = createVehicle(476,x+12, y, z)
	-- warpPedIntoVehicle(sir, car)
	-- attachElements(car,vehicle,0,0,1,10,0,0)
	-- setElementAlpha(localPlayer, 0)
	-- setTimer(function(vehicle)
		-- setElementAlpha(vehicle, 0)
	-- end, 1000, 10, vehicle)
	-- setPedControlState(sir, "accelerate", true)
-- end
-- addCommandHandler("a", aaa)
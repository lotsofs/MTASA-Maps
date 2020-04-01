	-- todo: Play "HEY THATS THE DA. HES A GOOD TIPPER" sound
	-- todo: rest of the map
MARKER = getElementByID("marker_undergroundGarageParkingSpot")
MARKER_REPAIR = getElementByID("marker_garageRepair")
CHECKPOINT2 = getElementByID("checkpoint2cutscene")
CHECKPOINT3 = getElementByID("checkpoint3cutscene")
CHECKPOINT6 = getElementByID("checkpoint6final")

function onMapStarting(mapInfo, mapOptions, gameOptions)
	setElementAlpha(MARKER, 0)
	setElementAlpha(MARKER_REPAIR, 0)
end
addEventHandler("onMapStarting", root, onMapStarting)

-- race progress
-- -------------
-- -------------

function onPlayerReachCheckpoint(checkpoint, time_)
	name = getPlayerName(source)
	if (checkpoint == 1) then
		-- player arrives at hotel
		-- move player away
		vehicle = getPedOccupiedVehicle(source)
		setElementFrozen(vehicle, true)
		toggleAllControls(source, false, true, false)
			-- <location id="tempPlayerHideHotel" interior="0" dimension="0" posX="-1734.2" posY="981.29999" posZ="83" rotX="0" rotY="0" rotZ="180"></location>
		setElementPosition(vehicle, -1734.2, 981.29999, 83)
		-- play cutscene
		triggerClientEvent(source, "playDACutscene", resourceRoot)
		setTimer(function(vehicle, player)
			x,y,z = getElementPosition(vehicle)
			if (z < 80) then
				return
			end
				--  <vehicle id="Place_Car_Here_Hotel colors 4 4 0 0" sirens="false" paintjob="3" interior="0" alpha="255" model="551" plate="9IA8P8R" dimension="0" 
				--  color="88,88,83,245,245,245,0,0,0,0,0,0" posX="-1757.8" posY="953.70001" posZ="25" rotX="0" rotY="0" rotZ="90"></vehicle>
			-- teleport player into DA car in parking spot
			setElementFrozen(vehicle, false)
			toggleAllControls(player, true)
			setElementPosition(vehicle, getElementPosition(CHECKPOINT2))
			setElementPosition(vehicle, getElementPosition(CHECKPOINT3))
			setElementPosition(vehicle, -1757.8, 953.7, 25)
			setElementModel(vehicle, 551)
			setVehicleColor(vehicle, 4, 4, 4, 4)
			fixVehicle(vehicle)
			setElementRotation(vehicle, 0, 0, 90)
		end, 6000, 1, vehicle, source)
	elseif (checkpoint == 4) then
		-- player arrives at garage
		vehicle = getPedOccupiedVehicle(source)
			-- <vehicle id="Vehicle_ParkMeritHereAfterRepair" sirens="false" paintjob="3" interior="0" alpha="255" model="551" plate="CZ95Z56" 
			-- dimension="0" color="54,65,85,245,245,245,0,0,0,0,0,0" posX="-2031.5" posY="178.60001" posZ="28.7" rotX="0" rotY="0" rotZ="270"></vehicle>
		-- replace vehicle
		setElementPosition(vehicle, -2031.5, 178.6, 28.7)
		setElementRotation(vehicle, 0, 0, 270)
		setElementVelocity(vehicle, 0, 0, 0)
		setElementAngularVelocity(vehicle, 0, 0, 0)
		fixVehicle(vehicle)
		-- move DA
		triggerClientEvent(source, "prepareHotelGarage", resourceRoot)
	elseif (checkpoint == 5) then
		triggerClientEvent(source, "promptPlayerParkInMarker", resourceRoot)
	end
end
addEventHandler("onPlayerReachCheckpoint", root, onPlayerReachCheckpoint)

function playerStoppedInMarker()
	-- player is in the marker at the parking spot inside the garage
	for i,v in ipairs(getElementsByType("player")) do	
		currentCheckpoint = getElementData(v, "checkpoint")
		if (currentCheckpoint == "5/6") then
			vehicle = getPedOccupiedVehicle(v)
			if (vehicle and isElementWithinMarker(vehicle, MARKER)) then
				health = getElementHealth(vehicle)
				if (health == 1000) then
					velocity = getDistanceBetweenPoints3D(0,0,0,getElementVelocity(vehicle))
					if (velocity < 0.001) then
						x,y,z = getElementPosition(vehicle)
						setElementPosition(vehicle, getElementPosition(CHECKPOINT6))
						setElementPosition(vehicle, x,y,z)
					end
				end
			end
		end
	end
end
setTimer(playerStoppedInMarker, 1, 0)


-- damage stuff
-- ------------
-- ------------

function onVehicleDamage(loss)
	-- vehicle damaged
	player = getVehicleOccupant(source)
	if (not getElementType(player) == "player") then
		return
	end
	currentCheckpoint = getElementData(player, "checkpoint")
	if (currentCheckpoint == "4/6" or currentCheckpoint == "5/6") then
		-- merit is damaged on the way back to the hotel, prompt for repair
		triggerClientEvent(player, "promptVehicleRepair", resourceRoot, true)
	end
end
addEventHandler("onVehicleDamage", root, onVehicleDamage)

function onPlayerWasted()
	triggerClientEvent(source, "promptVehicleRepair", resourceRoot, false)
end
addEventHandler("onPlayerWasted", root, onPlayerWasted)

function onPlayerRepairMarkerHit(hitElement, matchingDimension)
	if (getElementType(hitElement) ~= "player") then
		return
	end
	currentCheckpoint = getElementData(hitElement, "checkpoint")
	if (currentCheckpoint ~= "4/6" and currentCheckpoint ~= "5/6") then
		return
	end
	vehicle = getPedOccupiedVehicle(hitElement)
	health = getElementHealth(vehicle)
	if (health < 1000) then
		fixVehicle(vehicle)
		setElementPosition(vehicle, -2031.5, 178.6, 28.7)
		setElementRotation(vehicle, 0, 0, 270)
		setElementVelocity(vehicle, 0, 0, 0)
		setElementAngularVelocity(vehicle, 0, 0, 0)
		triggerClientEvent(hitElement, "promptVehicleRepair", resourceRoot, false)	
	end
end
addEventHandler("onMarkerHit", MARKER_REPAIR, onPlayerRepairMarkerHit)

function onPlayerPickUpRacePickup(pickupID, pickupType, vehicleModel)
	if (pickupType ~= "repair") then
		return
	end
	if (currentCheckpoint ~= "4/6" and currentCheckpoint ~= "5/6") then
		return
	end
	triggerClientEvent(player, "promptVehicleRepair", resourceRoot, false)	
end
addEvent("onPlayerPickUpRacePickup", true)
addEventHandler("onPlayerPickUpRacePickup", root, onPlayerPickUpRacePickup)

function processRespawn(vehicle)
	player = getVehicleOccupant(vehicle)
	if (not player) then
		return
	end
	checkpoint = getElementData(player, "checkpoint")
	if (checkpoint == "0/6" or checkpoint == false) then
		return
	elseif (checkpoint == "1/6" or checkpoint == "2/6" or checkpoint == "3/6") then
		-- player respawned at the hotel
		setElementPosition(vehicle, getElementPosition(CHECKPOINT2))
		setElementPosition(vehicle, getElementPosition(CHECKPOINT3))
		setElementModel(vehicle, 551)
		setVehicleColor(vehicle, 4, 4, 4, 4)
		setElementRotation(vehicle, 0, 0, 90)
		setElementPosition(vehicle, -1757.8, 953.7, 25)	
		setElementVelocity(vehicle, 0, 0, 0)
		setElementAngularVelocity(vehicle, 0, 0, 0)
	elseif (checkpoint == "4/6") then
		-- player respawned at the garage
			--setElementPosition(vehicle, -2031.5, 178.6, 28.7)
			--setElementRotation(vehicle, 0, 0, 270)
		setVehicleColor(vehicle, 4, 4, 4, 4)
		setElementRotation(vehicle, 0, 0, 90)
		setElementVelocity(vehicle, 0, 0, 0)
		setElementAngularVelocity(vehicle, 0, 0, 0)
		setElementPosition(vehicle, -1757.8, 953.7, 25)	
		setElementHealth(vehicle, 400)
	elseif (checkpoint == "5/6") then
		setVehicleColor(vehicle, 4, 4, 4, 4)
		setElementHealth(vehicle, 400)
	end
end

function onVehicleEnter(thePlayer, seat, jacked)
	name = getPlayerName(thePlayer)
	setTimer(processRespawn, 2000, 1, source)
	-- player is respawning
end
addEventHandler("onVehicleEnter", root, onVehicleEnter)


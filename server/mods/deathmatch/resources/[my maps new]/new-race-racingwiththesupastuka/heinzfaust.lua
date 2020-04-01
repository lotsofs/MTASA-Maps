supastukas = {}
heinzFausts = {}

function AttachTheSupastuka(player)
	vehicle = getPedOccupiedVehicle(player)
	-- create heinz
	if (heinzFausts[player]) then
		destroyElement(heinzFausts[player])
	end
	heinzFausts[player] = createPed(234,0,0,0)
	-- create the supastuka
	if (supastukas[player]) then
		destroyElement(supastukas[player])
	end
	supastukas[player] = createVehicle(476,0,0,0)
	-- combine
	warpPedIntoVehicle(heinzFausts[player], supastukas[player])
	attachElements(supastukas[player],vehicle,0,0,1,13,0,0)
end

function hideWindsor(player)
	vehicle = getPedOccupiedVehicle(player)
	if (vehicle) then
		setElementAlpha(vehicle, 0)
	end
	setElementAlpha(player, 0)
end

function onVehicleEnter(thePlayer, seat, jacked)
	if (getElementType(thePlayer) ~= "player") then
		return
	end
	AttachTheSupastuka(thePlayer)
	hideWindsor(thePlayer)
	setTimer(hideWindsor, 1, 1, thePlayer)
	setTimer(hideWindsor, 2000, 1, thePlayer)
end
addEventHandler("onVehicleEnter", root, onVehicleEnter)
addEvent("onRaceStateChanging", true)

function onRaceStateChanging(newState, oldState)
	for i, v in pairs(getElementsByType("player")) do
		hideWindsor(v)
	end
end
addEventHandler("onRaceStateChanging", root, onRaceStateChanging)

function onPlayerPickUpRacePickup(pickupID, pickupType, vehicleModel)
	if (pickupType == "repair") then
		fixVehicle(supastukas[source])
	end
end
addEventHandler("onPlayerPickUpRacePickup", root, onPlayerPickUpRacePickup)
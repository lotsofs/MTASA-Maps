addEvent("callTriggerOnClient", true)
addEventHandler("callTriggerOnClient", resourceRoot, function(theTrigger, arg1, arg2, arg3)
	if (theTrigger == "Exit Vehicle") then
		setPedExitVehicle(localPlayer)
	elseif (theTrigger == "Fall Off Bike") then
		triggerSetFallOffBike(arg1)
	elseif (theTrigger == "Vehicle Blip") then
		setVehicleBlip(arg2 or g_Vehicle, arg1)
		setVehicleMarker(arg2 or g_Vehicle, arg1)
	end
end)

function triggerSetFallOffBike(arg)
	local state
	if (arg == "keep") then
		return
	elseif (arg == "true") then
		state = true
	elseif (arg == "toggle") then
		state = not canPedBeKnockedOffBike(localPlayer)
	else
		state = false
	end
	setPedCanBeKnockedOffBike(localPlayer, state)
end
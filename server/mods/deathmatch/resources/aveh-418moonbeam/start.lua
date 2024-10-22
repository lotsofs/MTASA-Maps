function onRaceStateChanging(newState, oldState)
	if (newState == "GridCountdown") then
		for i,v in pairs(getElementsByType("player")) do
			toggleAllControls(v, false, true, false)
			vehicle = getPedOccupiedVehicle(v)
			if (vehicle) then
				-- setElementData(v, "race.collideothers", 0)
				setElementFrozen(vehicle, false)
				setElementCollisionsEnabled(vehicle, true)
			end
		end
	end	
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, onRaceStateChanging)
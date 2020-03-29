function onRaceStateChanging(newState, oldState)
	if (newState == "GridCountdown") then
		for i,v in pairs(getElementsByType("vehicle")) do
			-- setVehicleDamageProof(v, false)
			-- setVehicleEngineState(v, true)
			setElementData(v, "race.collideothers", 1)
			setElementFrozen(v, false)
			setElementCollisionsEnabled(v, true)
			toggleAllControls(getVehicleOccupant(v), false, true, false)
			setElementVelocity(v, 0.3, 0.9, 0.6)
			
			-- if (getVehicleOccupant(v)) then
				-- x,y,z = getElementPosition(v)
				-- shad = createObject(7017, x, y - 100, z)
				-- moveObject(shad, 5000, x, y + 100, z)
			-- end
		
		end
	end
	
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, onRaceStateChanging)
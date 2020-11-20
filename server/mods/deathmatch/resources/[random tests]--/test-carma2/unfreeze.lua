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


function oof()
	outputChatBox("ASD")
	for i,v in pairs(getElementsByType("vehicle")) do
		asdf = getModelHandling(429)
		for k,g in pairs(asdf) do
			setVehicleHandling(v, k, g)
		end
	end
end
addCommandHandler("oof", oof)
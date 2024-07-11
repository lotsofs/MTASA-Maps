function onRaceStateChanging(newState, oldState)
	iprint(newState)
	if (newState == "PreGridCountdown") then

	elseif (newState == "GridCountdown") then
		bah = getElementsByType("spawnpoint")
		x, y, z = getElementPosition(bah[#bah])
		for i,v in pairs(getElementsByType("player")) do
			car = getPedOccupiedVehicle(v)
			if (car) then
				--setElementPosition(car, x, y, z)
				setElementFrozen(car, false)
				setElementCollisionsEnabled(car, true)
				setElementVelocity(car, -92, 87, 12)
				setElementAngularVelocity(car, (math.random() - 0.5)/10 , (math.random() - 0.5)/10, (math.random() - 0.5)/10)
			end
		end
	elseif (newState == "Running") then

	elseif (newState == "SomeoneWon") then

	end	
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, onRaceStateChanging)
function freezeVehicles()
	for i, v in pairs(getElementsByType("vehicle")) do
		if (not getVehicleOccupant(v)) then
			setElementFrozen(v, true)
		end
	end
end
addEventHandler("onMapStarting", root, freezeVehicles) 
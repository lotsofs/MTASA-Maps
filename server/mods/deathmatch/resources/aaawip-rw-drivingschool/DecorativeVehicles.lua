function freezeVehicles()
	for i, v in pairs(getElementsByType("vehicle")) do
		if (not getVehicleOccupant(v)) then
			setElementFrozen(v, true)
			outputChatBox("froze a " .. getElementModel(v))
		end
	end
end
addEventHandler("onMapStarting", root, freezeVehicles) 
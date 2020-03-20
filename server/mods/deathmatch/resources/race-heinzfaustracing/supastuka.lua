function setInvisible()
	for i, v in pairs(getElementsByType("player")) do
		vehicle = getPedOccupiedVehicle(v)
		if (vehicle and getElementModel(vehicle) == 555) then
			setElementAlpha(vehicle, 0)
			setElementAlpha(v, 0)
		end
	end
end
setTimer(setInvisible, 1000, 0)
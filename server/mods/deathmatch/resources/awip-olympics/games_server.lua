-- DRAG_SPAWN = {[x] = 2069.3, [y] = 1670, [z] = 13.61475}	--getElementByID("SPAWN_DRAG") --posX="2069.3" posY="1670" posZ="13.61475"
dragFinish = getElementByID("FINISH_DRAG") --posX="2069.3" posY="870" posZ="15.1"

function startDrag(vehicleModel, distance, nitro, airResistance)
	for (i, player) in getElementsByType("player") do
		toggleMovementControls(player, false)
		toggleVehicleWeaponControls(player, false)

		local vehicle = getPedOccupiedVehicle(player)
		setElementVelocity(vehicle, 0, 0, 0)
		setElementAngularVelocity(vehicle, 0, 0, 0)
		setElementModel(vehicleModel)
		setElementPosition(vehicle, 2069.3, 1670, 13.61475)
		setElementRotation(vehicle, 0, 0, 180)
		if (VEHICLE_DATA[vehicleModel].tunable) then
			if (nitro) then
				addVehicleUpgrade(vehicle, 1010)
			else
				removeVehicleUpgrade(vehicle, 1010)
			end
		end
	end

	setElementPosition(dragFinish, 2069.3, 1670 - distance, 15.1)
	setWorldSpecialPropertyEnabled("extraairresistance", airResistance)
end
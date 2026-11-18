function toggleVehicleWeaponControls(player, enabled)
	local vehicle = getPedOccupiedVehicle(player)
	local model = getElementModel(vehicle)
	if ( VEHICLE_DATA[model].weapons ) then
		toggleControl(player, 'vehicle_fire', enabled)
		toggleControl(player, 'vehicle_secondary_fire', enabled)
	else
		-- enable shooting in every other case (most notably firetruck), but also just in case.
		toggleControl(player, 'vehicle_fire', true)
		toggleControl(player, 'vehicle_secondary_fire', true)
	end
end

function toggleMovementControls(player, enabled)
	toggleControl(player, 'vehicle_left', enabled)
	toggleControl(player, 'vehicle_right', enabled)
	toggleControl(player, 'steer_forward', enabled)
	toggleControl(player, 'steer_back', enabled)
	toggleControl(player, 'brake_reverse', enabled)
	toggleControl(player, 'accelerate', enabled)
	toggleControl(player, 'special_control_up', enabled)
	toggleControl(player, 'special_control_down', enabled)
	toggleControl(player, 'vehicle_look_left', enabled)
	toggleControl(player, 'vehicle_look_right', enabled)
end

function cleanup()
	for i, player in getElementsByType("player") do
		toggleMovementControls(player, true)
		toggleVehicleWeaponControls(player, true)
	end
	setWorldSpecialPropertyEnabled("extraairresistance", true)
end


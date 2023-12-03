CAMERA_ANGLE = 0
function cheatSpectate(playerSource, commandName)
	setElementFrozen(getPedOccupiedVehicle(localPlayer), true)
	if (CAMERA_ANGLE == 0) then
		setCameraMatrix (-213.5, -453.5, 63.5, -118.0, -353.8, 0.5)
		CAMERA_ANGLE = 1
	elseif (CAMERA_ANGLE == 1) then
		setCameraMatrix ( -4.6, -99.4, 38.0, -55.0, -233.0, 26.0)
		CAMERA_ANGLE = 2
	elseif (CAMERA_ANGLE == 2) then
		setCameraMatrix ( 150.0, -392.0, 55.0, -39.0, -293.0, 32.0)
		CAMERA_ANGLE = 3
	elseif (CAMERA_ANGLE == 3) then
		setCameraMatrix ( -27.7, -209.6, 10.9, -50.2, -222.3, 6.4)
		CAMERA_ANGLE = 4
	elseif (CAMERA_ANGLE == 4) then
		setCameraMatrix ( 170.5, -432.8, 18.0, 100.3, -399.5, 6.8)
		CAMERA_ANGLE = 5
	elseif (CAMERA_ANGLE == 5) then
		CAMERA_ANGLE = 0
		setElementFrozen(getPedOccupiedVehicle(localPlayer), false)
		setElementHealth(localPlayer, 0)
		setCameraTarget ( localPlayer )
	end
end
addCommandHandler("ie_spectate", cheatSpectate)
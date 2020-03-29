function playDACutscene()
	-- show the DA driving to the carport
		--  <vehicle id="Cutscene_Car" sirens="false" paintjob="3" interior="0" alpha="255" model="551" plate="M0BOP47" dimension="0" color="88,88,83,245,245,245,0,0,0,0,0,0" 
		--	posX="-1696" posY="918.20001" posZ="24.6" rotX="0" rotY="0" rotZ="60"></vehicle>
	car = createVehicle(551, -1696, 918.2, 24.6, 0, 0, 60)
	setVehicleColor(car, 4, 4, 4, 4)
		--  <ped id="DA" dimension="0" model="240" interior="0" rotZ="0.003" frozen="false" alpha="255" posX="-1732.4" posY="986.29999" posZ="83" rotX="0" rotY="0"></ped>
	ped = createPed(240, -1696, 919.2, 24.6)
	warpPedIntoVehicle(ped, car)
	setPedControlState(ped, "accelerate", true)
	setCameraMatrix(-1759.9, 962.8, 26.0, -1755.5, 943.5, 25)
	setTimer(function()
		setPedControlState(ped, "accelerate", false)
		setPedControlState(ped, "handbrake", true)
	end, 3050, 1)
	setTimer(function()
		-- remove DA from vehicle, remove vehicle, place DA next to vehicle, have him walk away
		setPedControlState(ped, "handbrake", false)
		removePedFromVehicle(ped)
		destroyElement(car)
		setCameraTarget(localPlayer)
		x, y, z = getElementPosition(ped)
		setElementPosition(ped, x, y-1, z)
		setElementRotation(ped, 0, 0, 90, "default", true)
		setPedControlState(ped, "walk", true)
		setPedControlState(ped, "forwards", true)
	end, 6000, 1)
end
addEvent("playDACutscene", true)
addEventHandler("playDACutscene", resourceRoot, playDACutscene)






-- function cutscene(newState, oldState)
	-- if (newState == "GridCountdown") then
		-- for i, v in pairs(getElementsByType("player")) do
			-- setCameraMatrix(v, CAMERA_POSITION_X, CAMERA_POSITION_Y, CAMERA_POSITION_Z, CAMERA_TARGET_X, CAMERA_TARGET_Y, CAMERA_TARGET_Z)
			-- setTimer(setCameraTarget, 5000, 1, v, v)
		-- end
	-- elseif (newState == "Running") then
		-- for i, v in pairs(getElementsByType("player")) do
			-- setCameraTarget(v, v)
		-- end
	-- end
-- end
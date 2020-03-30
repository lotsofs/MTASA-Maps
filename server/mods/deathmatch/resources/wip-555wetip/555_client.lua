DA = nil
BLIP = nil
BLIP2 = nil
TEXT = nil
TIMER = nil

function playDACutscene()
	-- show the DA driving to the carport
		--  <vehicle id="Cutscene_Car" sirens="false" paintjob="3" interior="0" alpha="255" model="551" plate="M0BOP47" dimension="0" color="88,88,83,245,245,245,0,0,0,0,0,0" 
		--	posX="-1696" posY="918.20001" posZ="24.6" rotX="0" rotY="0" rotZ="60"></vehicle>
	car = createVehicle(551, -1696, 918.2, 24.6, 0, 0, 60)
	setVehicleColor(car, 4, 4, 4, 4)
		--  <ped id="DA" dimension="0" model="240" interior="0" rotZ="0.003" frozen="false" alpha="255" posX="-1732.4" posY="986.29999" posZ="83" rotX="0" rotY="0"></ped>
	ped = createPed(240, -1696, 919.2, 24.6)
	DA = ped
	warpPedIntoVehicle(ped, car)
	setPedControlState(ped, "accelerate", true)
	setCameraMatrix(-1759.9, 962.8, 26.0, -1755.5, 943.5, 25)
	setTimer(function()
		setPedControlState(ped, "accelerate", false)
		setPedControlState(ped, "handbrake", true)
		playSound("tipper.wav")
	end, 3050, 1)
	setTimer(function()
		playerX, playerY, playerZ = getElementPosition(localPlayer)
		if (playerY < 500) then
			destroyElement(ped)
			destroyElement(car)
			return
		end
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

function prepareHotelGarage()
	if (DA) then
		setPedControlState(DA, "forwards", false)
		setPedControlState(DA, "walk", false)
			-- <ped id="putDAHere" dimension="0" model="240" interior="0" rotZ="0" alpha="255" 
			-- posX="-1755.3" posY="947" posZ="24.9" rotX="0" rotY="0"></ped>
		setElementPosition(DA, -1755.3, 947, 24.9)
		setElementRotation(DA, 0, 0, 0, "default", true)
	end
	marker = getElementByID("marker_undergroundGarageParkingSpot")
	setElementAlpha(marker, 255)
	TEXT = "The drugs are planted. \nTake the car to the valet's #FE0000car park."
	TIMER = setTimer(function()
		TEXT = "Keep the car spotless or the D.A. will notice."
		TIMER = setTimer(function()
			TEXT = nil
			TIMER = nil
		end, 5000, 1)
	end, 5000, 1)
end
addEvent("prepareHotelGarage", true)
addEventHandler("prepareHotelGarage", resourceRoot, prepareHotelGarage)

function promptVehicleRepair(enabled)
	if (TIMER) then
		killTimer(TIMER)
		TIMER = nil
	end
	marker = getElementByID("marker_undergroundGarageParkingSpot")
	marker2 = getElementByID("marker_garageRepair")
	if (enabled) then
		setElementAlpha(marker, 0)
		setElementAlpha(marker2, 255)
		if (BLIP) then
			destroyElement(BLIP)
			BLIP = nil
		end
		BLIP = createBlip(-1904.3, 286.89999, 41.6, 63)
		if (BLIP2) then
			destroyElement(BLIP2)
			BLIP2 = nil
		end
		BLIP2 = createBlip(-2033.626, 178.85645, 27.8359, 0, 2, 0, 255, 0)
		-- prompt player to repair their vehicle
		TEXT = "The car's noticeably damaged. \nTake it back to #00FE00the Garage#FFFFFF to get it fixed up."
	else
		setElementAlpha(marker, 255)
		setElementAlpha(marker2, 0)
		if (BLIP) then
			destroyElement(BLIP)
			BLIP = nil
		end
		if (BLIP2) then
			destroyElement(BLIP2)
			BLIP2 = nil
		end
		TEXT = nil
	end
end
addEvent("promptVehicleRepair", true)
addEventHandler("promptVehicleRepair", resourceRoot, promptVehicleRepair)

function promptPlayerParkInMarker()
	if (TEXT) then
		return
	end
	TEXT = "Park the car in the marked #FE0000parking space."
	TIMER = setTimer(function()
		TEXT = nil
		TIMER = nil
	end, 5000, 1)
end
addEvent("promptPlayerParkInMarker", true)
addEventHandler("promptPlayerParkInMarker", resourceRoot, promptPlayerParkInMarker)

function drawText()
	if (not TEXT) then
		return
	end
	local width,height = guiGetScreenSize()
	drawBorderedText(TEXT, 2, width*0.2, height*0.7, width*0.8, height*0.9, tocolor(255, 255, 255, 255), 3, "default", "center", "top", false, true, false, true)
end

function drawBorderedText(text, borderSize, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
	dxDrawText(text2, width+borderSize, height, width2+borderSize, height2, tocolor(0, 0, 0, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width, height+borderSize, width2, height2+borderSize, tocolor(0, 0, 0, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width, height-borderSize, width2, height2-borderSize, tocolor(0, 0, 0, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height, width2-borderSize, height2, tocolor(0, 0, 0, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width+borderSize, height+borderSize, width2+borderSize, height2+borderSize, tocolor(0, 0, 0, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height-borderSize, width2-borderSize, height2-borderSize, tocolor(0, 0, 0, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width+borderSize, height-borderSize, width2+borderSize, height2-borderSize, tocolor(0, 0, 0, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height+borderSize, width2-borderSize, height2+borderSize, tocolor(0, 0, 0, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
end

addEventHandler("onClientRender", root, drawText)
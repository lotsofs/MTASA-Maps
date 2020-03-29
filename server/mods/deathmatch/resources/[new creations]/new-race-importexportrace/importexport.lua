MARKER_TANKER = getElementByID("_MARKER_EXPORT_TANKER")
CRANE_STATE = "unavailable"
TANKER_DETECTOR = createColCuboid(-1740, -29, 0, 284, 238, 12)
ENDCAR_DETECTOR	= createColCuboid(-1644, -17, 16, 200, 200, 20)
LAST_CAR = false

function shuffleCars(cars)
	shuffledCars = {}
	for i = #cars, 1, -1 do
		randomIndex = math.random(1,i)
		shuffledCars[i] = cars[randomIndex]
		table.remove(cars, randomIndex)
	end
	triggerServerEvent("shuffleDone", resourceRoot, shuffledCars)
end

function makeMarkerVisible(oldModel, newModel)
	if (getVehicleOccupant(source) ~= localPlayer) then
		return
	end
	if (newModel == 514) then
		setMarkerColor(MARKER_TANKER, 255, 3, 3, 0)
	else
		setMarkerColor(MARKER_TANKER, 255, 3, 3, 0)
	end
end
addEventHandler("onClientElementModelChange", root, makeMarkerVisible)

addEvent("shuffle", true)
addEventHandler("shuffle", resourceRoot, shuffleCars)

function craneDetectTanker(element, matchingDimension)
	if (element ~= localPlayer) then
		return
	end
	vehicle = getPedOccupiedVehicle(element)
	if (not vehicle or getElementModel(vehicle) ~= 514) then
		if (LAST_CAR and CRANE_STATE == "unavailable" and vehicle and getElementModel(vehicle) ~= 522) then
			moveCraneIntoEndPositionNoTanker()
		end
		return
	end
	if (CRANE_STATE == "unavailable") then
		prepareCrane()
	elseif (CRANE_STATE == "finished") then
		resetCrane()
	end
end
addEventHandler("onClientColShapeHit", TANKER_DETECTOR, craneDetectTanker)

function prepareCrane()
	CRANE_STATE = "lowering"
	magnet = getElementByID("_CRANE_MAGNET")
	x,y,z = getElementPosition(magnet)
	moveObject(magnet, 3000, x, y, z - 4, 0, 0, 0, "InOutQuad")
	setTimer(function()
		CRANE_STATE = "available"
	end, 3000, 1)
end

function craneDetectFinalCar(theElement, matchingDimension)
	if (theElement ~= localPlayer) then
		return
	end
	if (CRANE_STATE == "finished" and LAST_CAR) then
		CRANE_STATE = "endgame"
		crane = {}
		crane["base"] = getElementByID("_CRANE_BASE")
		crane["head"] = getElementByID("_CRANE_HEAD")
		crane["arm"] = getElementByID("_CRANE_ARM")
		crane["magnet"] = getElementByID("_CRANE_MAGNET")
		x,y,z = getElementPosition(crane["magnet"])
		x1,y1,z1 = getElementPosition(crane["arm"])
		x2,y2,z2 = getElementPosition(crane["head"])
		wait = 1
		if (getElementModel(getPedOccupiedVehicle(localPlayer)) ~= 514) then
			wait = 4000
		end
		setTimer(function()
			moveObject(crane["magnet"], 3000, x - 0.5, y - 11.5, z - 2, 0, 0, 0, "InOutQuad")
			moveObject(crane["arm"], 3000, x1, y1, z1, -10, 0, -7, "InOutQuad")
			moveObject(crane["head"], 3000, x2, y2, z2, 0, 0, -7, "InOutQuad")
		end, wait, 1)
	end
end
addEventHandler("onClientColShapeHit", ENDCAR_DETECTOR, craneDetectFinalCar)

function lastCar()
	LAST_CAR = true
end
addEvent("lastCar", true)
addEventHandler("lastCar", resourceRoot, lastCar)

function resetCrane()
	CRANE_STATE = "resetting"
	crane = {}
	crane["base"] = getElementByID("_CRANE_BASE")
	crane["head"] = getElementByID("_CRANE_HEAD")
	crane["arm"] = getElementByID("_CRANE_ARM")
	crane["magnet"] = getElementByID("_CRANE_MAGNET")
	
	wait = 0
	if (LAST_CAR) then
		x,y,z = getElementPosition(crane["magnet"])
		x1,y1,z1 = getElementPosition(crane["arm"])
		x2,y2,z2 = getElementPosition(crane["head"])		
		moveObject(crane["magnet"], 3000, x + 0.5, y + 11.5, z + 2, 0, 0, 0, "InOutQuad")
		moveObject(crane["arm"], 3000, x1, y1, z1, -10, 0, 7, "InOutQuad")
		moveObject(crane["head"], 3000, x2, y2, z2, 0, 0, 7, "InOutQuad")
		wait = 3000
	end
	
	-- rotate the crane back
	x,y,z = getElementPosition(crane["magnet"])
	x1,y1,z1 = getElementPosition(crane["arm"])
	x2,y2,z2 = getElementPosition(crane["head"])
	moveObject(crane["magnet"], 3000 + wait, x - 16.6, y + 5.1, z, 0, 0, 0, "InOutQuad")
	moveObject(crane["arm"], 3000 + wait, x1, y1, z1, 30, 0, -43, "InOutQuad")
	moveObject(crane["head"], 3000 + wait, x2, y2, z2, 0, 0, -43, "InOutQuad")
	-- move the crane back
	setTimer(function()
		for i,v in pairs(crane) do
			x,y,z = getElementPosition(v)
			moveObject(v, 5000 + wait, x - 24.5, y - 24.5, z, 0, 0, 0, "InOutQuad")
		end
	end, 3000, 1)
	-- lower the magnet
	setTimer(function()
		x,y,z = getElementPosition(crane["magnet"])
		moveObject(crane["magnet"], 2000 + wait, x, y, z - 15.5, 0, 0, 0, "InOutQuad")
	end, 8000, 1)
	-- make available
	setTimer(function()
		CRANE_STATE = "available"
	end, 10000, 1)
end

function moveCraneIntoEndPositionNoTanker()
	CRANE_STATE = "endgame"
	crane = {}
	crane["base"] = getElementByID("_CRANE_BASE")
	crane["head"] = getElementByID("_CRANE_HEAD")
	crane["arm"] = getElementByID("_CRANE_ARM")
	crane["magnet"] = getElementByID("_CRANE_MAGNET")
	
	-- move the whole crane by -24.5
	for i,v in pairs(crane) do
		x,y,z = getElementPosition(v)
		moveObject(v, 5000, x + 24.5, y + 24.5, z, 0, 0, 0, "InOutQuad")
	end
	
	-- raise the magnet
	setTimer(function()
		x,y,z = getElementPosition(crane["magnet"])
		moveObject(crane["magnet"], 2000, x, y, z + 9.5, 0, 0, 0, "InOutQuad")
	end, 5000, 1)

	-- rotate stuff (The complicated step) 
	setTimer(function()
		x,y,z = getElementPosition(crane["magnet"])
		x1,y1,z1 = getElementPosition(crane["arm"])
		x2,y2,z2 = getElementPosition(crane["head"])
		moveObject(crane["magnet"], 3000, x + 16.1, y - 16.6, z, 0, 0, 0, "InOutQuad")
		moveObject(crane["arm"], 3000, x1, y1, z1, -30, 0, 36, "InOutQuad")
		moveObject(crane["head"], 3000, x2, y2, z2, 0, 0, 36, "InOutQuad")
	end, 10000, 1)
end

function moveCrane()
	-- get the crane
	if (CRANE_STATE ~= "available") then
		return
	end
	CRANE_STATE = "transporting"
	crane = {}
	crane["base"] = getElementByID("_CRANE_BASE")
	crane["head"] = getElementByID("_CRANE_HEAD")
	crane["arm"] = getElementByID("_CRANE_ARM")
	crane["magnet"] = getElementByID("_CRANE_MAGNET")
	
	-- move the whole crane by -24.5
	for i,v in pairs(crane) do
		x,y,z = getElementPosition(v)
		moveObject(v, 5000, x + 24.5, y + 24.5, z, 0, 0, 0, "InOutQuad")
	end
	
	-- raise the magnet
	setTimer(function()
		x,y,z = getElementPosition(crane["magnet"])
		moveObject(crane["magnet"], 2000, x, y, z + 15.5, 0, 0, 0, "InOutQuad")
	end, 5000, 1)
	
	-- rotate stuff (The complicated step) 
	setTimer(function()
		x,y,z = getElementPosition(crane["magnet"])
		x1,y1,z1 = getElementPosition(crane["arm"])
		x2,y2,z2 = getElementPosition(crane["head"])
		moveObject(crane["magnet"], 3000, x + 16.6, y - 5.1, z, 0, 0, 0, "InOutQuad")
		moveObject(crane["arm"], 3000, x1, y1, z1, -30, 0, 43, "InOutQuad")
		moveObject(crane["head"], 3000, x2, y2, z2, 0, 0, 43, "InOutQuad")
	end, 7000, 1)
	
	vehicle = getPedOccupiedVehicle(localPlayer)
	setElementFrozen(vehicle, true)
	--setCameraClip(false)
	magnetTimer = setTimer(function()
		x,y,z = getElementPosition(crane["magnet"])
		setElementPosition(vehicle, x, y, z - 2.6)
	end, 1, 0)
	setTimer(function()
		setElementFrozen(vehicle, false)
		killTimer(magnetTimer)
		CRANE_STATE = "finished"
		craneDetectFinalCar(localPlayer, nil)
	end, 10000, 1)
	setTimer(function()
		--setCameraClip(true)
	end, 11000, 1)
end
addEvent("moveCrane", true)
addEventHandler("moveCrane", resourceRoot, moveCrane)

function teleportToCraneForFinish()
	vehicle = getPedOccupiedVehicle(localPlayer)
	magnet = getElementByID("_CRANE_MAGNET")
	x,y,z = getElementPosition(magnet)
	setElementFrozen(vehicle, true)
	vehicle = getPedOccupiedVehicle(localPlayer)
	a,b,c,d,e,f = getElementBoundingBox(vehicle)
	aa,bb,cc,dd,ee,ff = getElementBoundingBox(magnet)
	setElementPosition(vehicle, x, y, z - f + aa + 1)
end
addEvent("teleportToCraneForFinish", true)
addEventHandler("teleportToCraneForFinish", resourceRoot, teleportToCraneForFinish)

-- function disableCameraClip()
	-- setCameraClip(true)
-- end
-- addEventHandler( "onClientResourceStop", resourceRoot, disableCameraClip)

TEXT = ""
SHOW = false

function setScoreBoard(scores)
	text = "Top times for the Full Experience:\n_______________________________________\n"
	for i, v in pairs(scores) do
		time_ = v["score"]
	
		milliseconds = time_ % 1000
		seconds = ((time_ - milliseconds) % 60000) / 1000
		minutes = (time_ - milliseconds - (seconds * 1000)) / 60000

		zeroSeconds = ""
		zeroMinutes = ""
		zeroMilliseconds = ""
		if (seconds < 10) then
			zeroSeconds = "0"
		end
		if (minutes < 10) then
			zeroMinutes = "0"
		end
		if (milliseconds < 10) then
			zeroMilliseconds = "00"
		elseif (milliseconds < 100) then
			zeroMilliseconds = "0"
		end
		timeText = zeroMinutes .. minutes .. ":" .. zeroSeconds .. seconds .. "." .. zeroMilliseconds .. milliseconds
		
		zeroPos = ""
		if (i < 10) then
			zeroPos = "0"
		end
		text = text .. zeroPos .. i .. ".   " .. timeText .. "    " .. v["playername"] .. "\n"
	end
	if (#scores < 10) then
		for i = #scores + 1, 10, 1 do
			zeroPos = ""
			if (i < 10) then
				zeroPos = "0"
			end
			text = text .. zeroPos .. i .. ".   -- Empty --\n"
		end
	end
	TEXT = text
end
addEvent("setScoreBoard", true)
addEventHandler("setScoreBoard", root, setScoreBoard)

function showScoreBoardCmd()
	showScoreBoard(true, 15000)
end

function showScoreBoard(enabled, duration)
	SHOW = enabled
	if (duration) then
		setTimer(function()
			SHOW = false
		end, duration, 1)
	end
end
addEvent("showScoreBoard", true)
addEventHandler("showScoreBoard", root, showScoreBoard)
addCommandHandler("showScoreBoard", showScoreBoardCmd)

function drawScoreBoard()
	if (SHOW) then
		local width,height = guiGetScreenSize()
		boxX = width * 0.275
		boxY = height * 0.015
		boxWidth = width * 0.18
		boxHeight = (boxWidth * 0.6875)
		dxDrawRectangle(boxX, boxY, boxWidth, boxHeight, tocolor(5, 33, 51, 127))
		dxDrawText(TEXT, width*0.28, height*0.025, width*0.8, height*0.9, tocolor(230, 245, 255, 255), width / 1600, "default-bold", "left", "top", false, true, false, false)
	end
end
addEventHandler("onClientRender", root, drawScoreBoard)




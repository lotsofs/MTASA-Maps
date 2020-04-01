-- function setPlaneStreamable()
    -- plane = getElementByID("AT400")
    -- setElementStreamable ( plane, false )
	-- outputChatBox(getElementModel(plane))
-- end
-- addEventHandler ( "onClientResourceStart", resourceRoot, setPlaneStreamable )
DODOS = {}
MARK = false
TEXT = nil

-- function setOpponentCollisions()
	-- -- for i, v in pairs(getElementsByType("player")) do
		-- -- outputChatBox("HEY")
		-- -- veh = getPedOccupiedVehicle(v)
		-- -- setElementData(veh, "race.collideothers", 0)
	-- -- end
-- end
-- addEvent("setOpponentCollisions", true)
-- addEventHandler("setOpponentCollisions", resourceRoot, setOpponentCollisions)

function onClientVehicleDamage(theAttacker, theWeapon, loss, damagePosX, damagePosY, damagePosZ, tireID)
	if (theWeapon == 31 and getElementModel(source) == 593 and not isVehicleBlown(source) and theAttacker == getPedOccupiedVehicle(localPlayer)) then
		setElementFrozen(source, false)
		setVehicleDamageProof(source, false)
		x,y,z = getElementPosition(source)
		createExplosion(x,y,z,2)
		blowVehicle(source)
		triggerServerEvent("playerDestroyedDodo", resourceRoot)
		for i, v in pairs(getAttachedElements(source)) do
			if (getElementType(v) == "blip") then
				destroyElement(v)
			end
		end
		setTimer(function()
			for i, v in pairs(getElementsByType("vehicle")) do
				if (getElementModel(v) == 593 and isVehicleBlown(v)) then
					destroyElement(v)
				end
			end
		end, 10000, 1)
	end
end
addEventHandler("onClientVehicleDamage", root, onClientVehicleDamage)

function onClientVehicleCollision(theHitElement, force, bodyPart, collisionX, collisionY, collisionZ, normalX, normalY, normalZ, hitElementForce, model)
	if (theHitElement and source == getPedOccupiedVehicle(localPlayer) and getElementType(theHitElement) == "vehicle" and getElementModel(theHitElement) == 593 and not isVehicleBlown(theHitElement)) then
		setElementFrozen(theHitElement, false)
		setVehicleDamageProof(theHitElement, false)
		x,y,z = getElementPosition(theHitElement)
		createExplosion(x,y,z,2)
		blowVehicle(theHitElement)
		triggerServerEvent("playerDestroyedDodo", resourceRoot)
		for i, v in pairs(getAttachedElements(theHitElement)) do
			if (getElementType(v) == "blip") then
				destroyElement(v)
			end
		end
		setTimer(function()
			for i, v in pairs(getElementsByType("vehicle")) do
				if (getElementModel(v) == 593 and isVehicleBlown(v)) then
					destroyElement(v)
				end
			end
		end, 10000, 1)
	end
end
addEventHandler ( "onClientVehicleCollision", root, onClientVehicleCollision )

function spawnFirstDodos()
	for i = 1, 10, 1 do
		rotX = getElementData(DODOS[i], "rotX")
		rotY = getElementData(DODOS[i], "rotY")
		rotZ = getElementData(DODOS[i], "rotZ")
		x, y, z = getElementPosition(DODOS[i])
		dodo = createVehicle(593, x,y,z, rotX, rotY, rotZ)
		setElementData(dodo, "race.collideothers", 1, false)
		setElementFrozen(dodo, true)
	end
	setText("Destroy 30 Dodos parked around the airport!")
	setTimer(function()
		setText("Destroy 30 Dodos parked around the airport!")
	end, 10000, 2)
end
addEvent("spawnFirstDodos", true)
addEventHandler("spawnFirstDodos", resourceRoot, spawnFirstDodos)

function spawnSecondDodos()
	for i = 11, 20, 1 do
		rotX = getElementData(DODOS[i], "rotX")
		rotY = getElementData(DODOS[i], "rotY")
		rotZ = getElementData(DODOS[i], "rotZ")
		x, y, z = getElementPosition(DODOS[i])
		dodo = createVehicle(593, x,y,z, rotX, rotY, rotZ)
		setElementData(dodo, "race.collideothers", 1)
		setElementFrozen(dodo, true)
		setText("More Dodos have spawned.")
	end
	if (MARK) then
		markDodosOnMap()
	end
end
addEvent("spawnSecondDodos", true)
addEventHandler("spawnSecondDodos", resourceRoot, spawnSecondDodos)

function spawnThirdDodos()
	for i = 21, 30, 1 do
		rotX = getElementData(DODOS[i], "rotX")
		rotY = getElementData(DODOS[i], "rotY")
		rotZ = getElementData(DODOS[i], "rotZ")
		x, y, z = getElementPosition(DODOS[i])
		dodo = createVehicle(593, x,y,z, rotX, rotY, rotZ)
		setElementData(dodo, "race.collideothers", 1)
		setElementFrozen(dodo, true)
		setText("More Dodos have spawned.")
	end
	if (MARK) then
		markDodosOnMap()
	end
end
addEvent("spawnThirdDodos", true)
addEventHandler("spawnThirdDodos", resourceRoot, spawnThirdDodos)

function markDodosOnMap()
	if (not MARK) then
		MARK = true	
		setText("Remaining Dodos have been revealed on the map.")
	end
	for i, v in pairs(getElementsByType("vehicle")) do
		if (getVehicleModel(v) == 593 and not isVehicleBlown(v)) then
			createBlipAttachedTo(v, 0, 1, 255, 255, 0, 255)
		end
	end
end
addEvent("markDodosOnMap", true)
addEventHandler("markDodosOnMap", resourceRoot, markDodosOnMap)

function receiveDodos(dodos)
	DODOS = dodos
	setText("Destroy 30 Dodos parked around the airport!")
end
addEvent("receiveDodos", true)
addEventHandler("receiveDodos", resourceRoot, receiveDodos)









function setText(text)
	TEXT = text
	setTimer(function()
		TEXT = nil
	end, 10000, 1)
end

function drawText()
	if (not TEXT) then
		return
	end
	local width,height = guiGetScreenSize()
	drawBorderedText(TEXT, 2, width*0.2, height*0.7, width*0.8, height*0.9, tocolor(255, 255, 255, 255), 3, "default", "center", "top", false, true, false, true)
end
addEventHandler("onClientRender", root, drawText)

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

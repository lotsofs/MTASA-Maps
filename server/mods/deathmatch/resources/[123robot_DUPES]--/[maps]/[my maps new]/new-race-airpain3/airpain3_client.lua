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

function onClientExplosion(x, y, z, theType)
	if(theType == 19) then
		createExplosion(x,y,z,10)
		cancelEvent()	
	end
end
addEventHandler("onClientExplosion", root, onClientExplosion)

function destroyDodo(dodo)
	setElementFrozen(dodo, false)
	setVehicleDamageProof(dodo, false)
	x,y,z = getElementPosition(dodo)
	createExplosion(x,y,z,10)
	blowVehicle(dodo)
	setVehicleHandling(dodo, "mass", 0)
	
	for i, v in pairs(getAttachedElements(dodo)) do
		if (getElementType(v) == "blip") then
			destroyElement(v)
		end
	end
	setTimer(
		function(deadDodo)
			destroyElement(deadDodo)
		end
	, 10000, 1, dodo)
end

function gainProgression()
	local dodosDestroyed = getElementData(localPlayer, "airpain3.dodosDestroyed") or 0
	dodosDestroyed = dodosDestroyed + 1
	if (dodosDestroyed == 8) then
		spawnSecondDodos()
	elseif (dodosDestroyed == 18) then
		spawnThirdDodos()
	end
	setElementData(localPlayer, "airpain3.dodosDestroyed", dodosDestroyed)
	
	local vehicle = getPedOccupiedVehicle(localPlayer)
    local checkpoint = getElementData(localPlayer, "race.checkpoint")
    for i=checkpoint, dodosDestroyed do
		local colshapes = getElementsByType("colshape", getResourceDynamicElementRoot(getResourceFromName("race")))
		if (#colshapes == 0) then
			break
		end
		triggerEvent("onClientColShapeHit",
            colshapes[#colshapes], vehicle, true)
    end
end

function onClientVehicleDamage(theAttacker, theWeapon, loss, damagePosX, damagePosY, damagePosZ, tireID)
	if (theWeapon == 31 and getElementModel(source) == 593 and not isVehicleBlown(source) and theAttacker == getPedOccupiedVehicle(localPlayer)) then
		destroyDodo(source)
		gainProgression()
	end
end
addEventHandler("onClientVehicleDamage", root, onClientVehicleDamage)

function onClientVehicleCollision(theHitElement, force, bodyPart, collisionX, collisionY, collisionZ, normalX, normalY, normalZ, hitElementForce, model)
	if (theHitElement and source == getPedOccupiedVehicle(localPlayer) and getElementType(theHitElement) == "vehicle" and getElementModel(theHitElement) == 593 and not isVehicleBlown(theHitElement)) then
		destroyDodo(theHitElement)
		gainProgression()
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

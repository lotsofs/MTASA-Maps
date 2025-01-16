g_IVArrows = {}
g_IVBlips = {}

addEvent("onEnterAlternativeVehicle", true)
addEventHandler("onEnterAlternativeVehicle", resourceRoot, function()
	setTimer(setPedEnterVehicle, 1, 1, localPlayer, source)
end)

addEventHandler( "onClientElementStreamIn", root,
	function ( )
		if (getElementType( source ) == "vehicle" and getElementData(source, "raceiv.interactable")) or (getElementData(source, "raceiv.owner") and getVehicleController(source)) then
			triggerServerEvent("onClientStreamInVehicle", resourceRoot, source)
		end
	end
);

function getMostColorfulColor(r1,g1,b1,r2,g2,b2,r3,g3,b3,r4,g4,b4)
	local brightestCol = 1
	local biggestDiff = math.max(r1, g1, b1) - math.min(r1, g1, b1)
	local currentDiff = math.max(r2, g2, b2) - math.min(r2, g2, b2)
	if (currentDiff >= biggestDiff) then
		brightestCol = 2
		biggestDiff = currentDiff
	end
	currentDiff = math.max(r3, g3, b3) - math.min(r3, g3, b3)
	if (currentDiff >= biggestDiff) then
		brightestCol = 3
		biggestDiff = currentDiff
	end
	currentDiff = math.max(r4, g4, b4) - math.min(r4, g4, b4)
	if (currentDiff >= biggestDiff) then
		brightestCol = 4
	end
	if brightestCol == 1 then return r1,g1,b1
	elseif brightestCol == 2 then return r2,g2,b2
	elseif brightestCol == 3 then return r3,g3,b3
	else return r4,g4,b4 end
end

function setVehicleBlip(theVehicle, enabled)
	if (not theVehicle) then return end
	if enabled == "toggle" then
		if g_IVBlips[theVehicle] then enabled = false
		else enabled = true end
	end
	if (not enabled and g_IVBlips[theVehicle]) then
		destroyElement(g_IVBlips[theVehicle])
		g_IVBlips[theVehicle] = nil
	elseif (enabled and not g_IVBlips[theVehicle]) then
		local r,g,b = getMostColorfulColor(getVehicleColor(theVehicle, true))
		local x,y,z = getElementPosition(theVehicle)
		g_IVBlips[theVehicle] = createBlipAttachedTo(theVehicle, 0, 3, r, g, b, 255)
	end
end

function setVehicleMarker(theVehicle, enabled)
	if (not theVehicle) then return end
	if enabled == "toggle" then
		if g_IVArrows[theVehicle] then enabled = false
		else enabled = true end
	end
	if (not enabled and g_IVArrows[theVehicle]) then
		destroyElement(g_IVArrows[theVehicle])
		g_IVArrows[theVehicle] = nil
	elseif (enabled and not g_IVArrows[theVehicle]) then
		local r,g,b = getMostColorfulColor(getVehicleColor(theVehicle, true))
		local x,y,z = getElementPosition(theVehicle)
		g_IVArrows[theVehicle] = createMarker(x, y, z + 4, "arrow", 2, r, g, b, 255)
		setElementInterior(g_IVArrows[theVehicle], getElementInterior(theVehicle))
	end
end

-- addEvent("markVehicle", true)
-- addEventHandler("markVehicle", resourceRoot, function(thePlayer, enabled, ignoreCleanup)
-- 	ignoreNextCleanup = ignoreCleanup -- Because end-of-race cleanup gets called at the start of a race as well for some reason so this would immediately get erased again
-- 	markVehicle(thePlayer, enabled)
-- end)

addEventHandler("onClientVehicleExit", resourceRoot, function(thePlayer, seat)
	if (thePlayer ~= localPlayer) then return end
	if getElementData(source, "raceiv.owner") ~= localPlayer then return end

	setVehicleMarker(source, true)
	updateVehicleWeapons()
	if (source == g_Vehicle or not g_Vehicle) then
		setVehicleBlip(source, true)
	end
end)

addEventHandler("onClientVehicleEnter", resourceRoot, function(thePlayer, seat)
	if (thePlayer == localPlayer) then
		if g_IVArrows[source] then
			destroyElement(g_IVArrows[source])
			g_IVArrows[source] = nil
		end
		if g_IVBlips[source] then
			destroyElement(g_IVBlips[source])
			g_IVBlips[source] = nil
		end
	end
	if (getElementData(source, "raceiv.collisions") == "upon entered") then
		setElementData(source, "raceiv.collide", true)
		setElementData(source, "raceiv.collisions", nil)
	end
	updateVehicleWeapons()
end)

addEventHandler("onClientVehicleStartEnter", resourceRoot, function(thePlayer, seat, door)
	if (thePlayer == localPlayer) then
		if (source == g_Vehicle) then
			setElementPosition(source, getElementPosition(source))
		end
		if (getElementData(source, "raceiv.collisions") == "upon start enter") then
			setElementData(source, "raceiv.collide", true)
			setElementData(source, "raceiv.collisions", nil)
		end
	end
end)


setTimer(function()
	for i, v in pairs(g_IVArrows) do
		if (not isElement(i)) then
			destroyElement(v)
			g_IVArrows[i] = nil
		else
			-- Attaching the object to the car causes the camera to malfunction upon entering the vehicle. So we do it like this.
			local x,y,z = getElementPosition(i)
			setElementPosition(v, x, y, z + 4)
		end
	end
end, 15, 0)

addEventHandler("onClientMapStopping", resourceRoot, function(preRace)
	if (preRace) then
		-- This gets called at the start of a map too. Ignore it.
		return
	end
	for i, v in pairs(g_IVArrows) do
		destroyElement(v)
	end
	for i, v in pairs(g_IVBlips) do
		destroyElement(v)
	end
	g_IVArrows = { }
	g_IVBlips = { }
end)
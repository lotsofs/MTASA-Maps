g_IVArrows = {}
g_IVBlips = {}

addEvent("onEnterAlternativeVehicle", true)
addEventHandler("onEnterAlternativeVehicle", resourceRoot, function()
	setTimer(setPedEnterVehicle, 1, 1, localPlayer, source)
end)

addEventHandler( "onClientElementStreamIn", root,
    function ( )
        if (getElementType( source ) == "vehicle" and getElementData(source, "raceiv.interactable")) or (getElementData(source, "raceiv.owner") and getVehicleOccupant(source, 0)) then
            triggerServerEvent("onClientStreamInVehicle", resourceRoot, source)
        end
    end
);

function markVehicle(thePlayer, seat)
	if (thePlayer == localPlayer) then
		if getElementData(source, "raceiv.owner") ~= localPlayer then
            return
        end
        local _,_,_,_,_,_,_,_,_,r,g,b = getVehicleColor(source, true)
        local x,y,z = getElementPosition(source)
        g_IVArrows[source] = createMarker(x, y, z + 4, "arrow", 2, r, g, b, 255)
        if (source == g_Vehicle or not g_Vehicle) then
            g_IVBlips[source] = createBlipAttachedTo(source, 0, 3, r, g, b, 255)
        end
    end
end

addEvent("markVehicle", true)
addEventHandler("markVehicle", resourceRoot, function(thePlayer, seat)
	ignoreNextCleanup = true
	markVehicle(thePlayer, seat)
end)
addEventHandler("onClientVehicleExit", resourceRoot, function(thePlayer, seat)
	markVehicle(thePlayer, seat)
	updateVehicleWeapons()
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
	updateVehicleWeapons()
end)

addEventHandler("onClientVehicleStartEnter", resourceRoot, function(thePlayer, seat, door)
    if (thePlayer == localPlayer) then
        if (source == g_Vehicle) then
            setElementPosition(source, getElementPosition(source))
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

addEventHandler("onClientMapStopping", resourceRoot, function()
	if (ignoreNextCleanup) then
		-- This gets called at the start of a map too. Ignore it.
		ignoreNextCleanup = false
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
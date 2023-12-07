BRIDGE_DETECTOR = createColCircle(37, -530, 22)
BLOCKING_BRIDGE = getElementByID("_NON_COLLIDE_BRIDGE")

function bridgeTropicCollisionDisable(element, matchingDimension)
	if (element ~= localPlayer) then
		return
	end
	local vehicle = getElementModel(getPedOccupiedVehicle(localPlayer))
	if (not vehicle or vehicle ~= 454) then -- tropic
		return
	end
	setElementCollisionsEnabled(BLOCKING_BRIDGE, false)
end
addEventHandler("onClientColShapeHit", BRIDGE_DETECTOR, bridgeTropicCollisionDisable)
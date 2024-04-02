function plrJump()
	local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
	if isVehicleOnGround(theVehicle) and not isPlayerDead(getLocalPlayer()) then
		local vx,vy,vz = getElementVelocity(theVehicle)
		setElementVelocity(theVehicle,vx,vy,0.25)
	end
end

for keyName, state in pairs(getBoundKeys("horn")) do
	bindKey(keyName, "down", plrJump)
end

for keyName, state in pairs(getBoundKeys("vehicle_secondary_fire")) do
	bindKey(keyName, "down", plrJump)
end
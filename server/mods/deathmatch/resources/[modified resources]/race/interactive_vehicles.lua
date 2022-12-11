g_IVSpawners = {}
g_IVSpawns = {}
g_IVDespawnTimers = {}
g_IVRespawnTimers = {}

function processInteractiveVehicles(intVehs)
	g_IVSpawners = intVehs
	for i, v in ipairs(g_IVSpawners) do
		if (v.spawnimmediately == 'true') then
			spawnInteractiveVehicle(v)
		end
	end
end

function destroyInteractiveVehicles()
	for i, t in pairs(g_IVDespawnTimers) do
		if (t and isTimer(t)) then
			killTimer(t)
		end
	end
	for i, t in pairs(g_IVRespawnTimers) do
		if (t and isTimer(t)) then
			killTimer(t)
		end
	end
	for v, d in pairs(g_IVSpawns) do
		destroyElement(v)
	end
	g_IVSpawners = {}
	g_IVSpawns = {}
	g_IVDespawnTimers = {}
	g_IVRespawnTimers = {}
end

function findInteractiveVehicle(id)
	for i, v in ipairs(g_IVSpawners) do
		if (v.id == id) then
			return v
		end
	end
end

function spawnInteractiveVehicle(stats)
	local x, y, z = unpack(stats.position)
	local rx, ry, rz = unpack(stats.rotation)
	local veh = createVehicle(stats.model, x, y, z, rx, ry, rz)
	if (stats.plate) then setVehiclePlateText(veh, stats.plate) end
	if (stats.paintjob and stats.paintjob ~= "false" and stats.paintjob ~= "nil") then setVehiclePaintjob(veh, tonumber(stats.paintjob)) end
	setVehicleSirensOn(veh, stats.sirens == 'true')
	setVehicleLocked(veh, stats.locked == 'true')
	setElementHealth(veh, stats.health or 1000)
	setElementInterior(veh, stats.interior)
	if (stats.cantenter == 'true') then
		setElementData(veh, "raceiv.blocked", true)
	end
	if (stats.upgrades) then
		if (type(stats.upgrades) == "table") then
			for _, u in ipairs(stats.upgrades) do
				addVehicleUpgrade(veh, u)
			end
		elseif (type(stats.upgrades) == "number") then
			addVehicleUpgrade(veh, stats.upgrades)
		end
	end
	-- Set colors. There has to be a better way of doing this
	local col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12 = getVehicleColor(veh, true)
	if (stats.colora) then
		col1, col2, col3 = unpack(stats.colora)
	end
	if (stats.colorb) then
		col4, col5, col6 = unpack(stats.colorb)
	end
	if (stats.colorc) then
		col7, col8, col9 = unpack(stats.colorc)
	end
	if (stats.colord) then
		col10, col11, col12 = unpack(stats.colord)
	end
	setVehicleColor(veh, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12)

	setElementData(veh, "raceiv.taken", false)
	setElementData(veh, "raceiv.interactable", true)

	setElementData(veh, "raceiv.collisions", stats.collisions)
	setElementData(veh, "raceiv.collide", stats.collisions == "always")
	-- setElementData(veh, "raceiv.unclaimedcollidewithvehicles", stats.unclaimedcollidewithvehicles == 'true')
	-- setElementData(veh, "raceiv.unclaimedcollidewithplayers", stats.unclaimedcollidewithplayers == 'true')
	-- setElementData(veh, "raceiv.claimedcollisions", stats.claimedcollisions == 'true')

	g_IVSpawns[veh] = stats
	return veh
end

function despawnInteractiveVehicle(theVehicle)
	g_IVSpawns[theVehicle] = nil
	destroyElement(theVehicle)
end

function markInteractiveVehicleForDespawn(theVehicle)
	local data = g_IVSpawns[theVehicle]
	if (not data) then
		return
	end
	local despawnTime = data.despawntime
	if (despawnTime >= 0) then
		local despawnTimer = g_IVDespawnTimers[theVehicle]
		if (despawnTimer) then
			killTimer(despawnTimer)
			g_IVDespawnTimers[theVehicle] = nil
		end
		g_IVDespawnTimers[theVehicle] = setTimer(despawnInteractiveVehicle, despawnTime, 1, theVehicle)
	end
end

setTimer(function()
	for p, v in pairs(g_Vehicles) do
		if (not getVehicleController(v)) then
			setElementPosition(v, getElementPosition(v))
			setElementRotation(v, getElementRotation(v))
			setElementVelocity(v, getElementVelocity(v))
			setElementAngularVelocity(v, getElementAngularVelocity(v))
		end
	end
end, 5000, 0)

setTimer(function()
	for vehicle, data in pairs(g_IVSpawns) do
		if (not isElement(vehicle)) then
			-- vehicle has been forcefully destroyed
			g_IVSpawns[vehicle] = nil
			return
		end
		local x1, y1, z1 = unpack(data.position)
		local x2, y2, z2 = getElementPosition(vehicle)
		local distance = getDistanceBetweenPoints3D (x1, y1, z1, x2, y2, z2)
		if (distance > data.maxmovedistance or isVehicleBlown(vehicle)) then
			if (not getElementData(vehicle, "raceiv.taken")) then
				-- Car is pushed too far outside of its spawn area or destroyed.
				local respawnTime = data.respawntime
				if (respawnTime >= 0) then
					table.insert(g_IVRespawnTimers, setTimer(spawnInteractiveVehicle, respawnTime, 1, data))
				end
				setElementData(vehicle, "raceiv.taken", true)
			end
		end
		if (distance > data.maxmovedistance and getElementData(vehicle, "raceiv.collisions") == "upon drive away") then
			setElementData(vehicle, "raceiv.collide", true)
			setElementData(vehicle, "raceiv.collisions", nil)
		end
		if (not getVehicleController(vehicle)) then
			if (getElementData(vehicle, "raceiv.taken")) then
				-- Driver died or left the game without calling OnVehicleExit.
				local despawnTimer = g_IVDespawnTimers[vehicle]
				if (not despawnTimer) then
					markInteractiveVehicleForDespawn(vehicle)
				end
			end
		end
	end
end, 15, 0)

addEventHandler("onPlayerVehicleExit", root, function(theVehicle, seat, jacked)
	markInteractiveVehicleForDespawn(theVehicle)
	if (g_Vehicles[source] == theVehicle) then
		setVehicleDamageProof(theVehicle, true)
	end
end)

addEventHandler("onPlayerVehicleEnter", root, function(theVehicle, seat, jacked)
	local despawnTimer = g_IVDespawnTimers[theVehicle]
	if (despawnTimer) then
		killTimer(despawnTimer)
		g_IVDespawnTimers[theVehicle] = nil
	end
	if (g_Vehicles[source] == theVehicle) then
		setVehicleDamageProof(theVehicle, false)
	else
		setElementFrozen(theVehicle, false)
	end
end)

function findFreeVehicle(player)
	local lastMinDis = 10
	local nearestVeh = false
	local px,py,pz = getElementPosition(player)
	for _,v in pairs(getElementsWithinRange(px,py,pz,10,"vehicle")) do
		local owner = getElementData(v, "raceiv.owner")
		local interactable = getElementData(v, "raceiv.interactable")
		local blocked = getElementData(v, "raceiv.blocked")
		if (not blocked and (not owner or owner == player) and not isVehicleBlown(v) and (interactable or g_Vehicles[player] == v)) then
			local vx,vy,vz = getElementPosition(v)
			local dis = getDistanceBetweenPoints3D(px,py,pz,vx,vy,vz)
			if dis < lastMinDis then
				lastMinDis = dis
				nearestVeh = v
			end
		end
	end
	return nearestVeh
end

addEventHandler("onVehicleStartEnter", root, function(player, seat, jacked)
	if (getElementType(player) ~= "player") then
		return
	end
	if seat ~= 0 then
		cancelEvent()
		return
	end

	if (getElementData(source, "raceiv.blocked")) then
		cancelEvent()
		local alternative = findFreeVehicle(player)
		if (alternative) then triggerClientEvent(player, "onEnterAlternativeVehicle", alternative) end
		return
	end

	-- Prevent stealing main race vehicles
	for p, v in pairs(g_Vehicles) do
		if (p ~= player) then
			if (v == source) then
				cancelEvent()
				local alternative = findFreeVehicle(player)
				if (alternative) then triggerClientEvent(player, "onEnterAlternativeVehicle", alternative) end
				return
			end
		end
	end
	-- Ignore vehicles not created by race
	if (not getElementData(source, "raceiv.interactable") and g_Vehicles[player] ~= source) then
		cancelEvent()
		local alternative = findFreeVehicle(player)
		if (alternative) then triggerClientEvent(player, "onEnterAlternativeVehicle", alternative) end
		return
	end
	
	-- If this vehicle is claimed by another player
	local owner = getElementData(source, "raceiv.owner")
	if (owner and owner ~= player) then
		cancelEvent()
		local alternative = findFreeVehicle(player)
		if (alternative) then triggerClientEvent(player, "onEnterAlternativeVehicle", alternative) end
		return
	end

	-- Spawn a new vehicle as someone starts entering so that other players can also take a car
	local data = g_IVSpawns[source]
	if (not data) then
		return
	end
	if (data.shared ~= "true" and not getElementData(source, "raceiv.owner")) then
		setElementData(source, "raceiv.owner", player)
	end
	if (getElementData(source, "raceiv.taken")) then
		return
	end
	setElementData(source, "raceiv.taken", true)
	local respawnTime = data.respawntime
	if (respawnTime >= 0) then
		table.insert(g_IVRespawnTimers, setTimer(spawnInteractiveVehicle, respawnTime, 1, data))
	end
	
end)

addEvent("onClientStreamInVehicle", true)
addEventHandler("onClientStreamInVehicle", resourceRoot, function(theVehicle)
	if (getVehicleController(theVehicle)) then
		return
	end
	setElementPosition(theVehicle, getElementPosition(theVehicle))
	setElementRotation(theVehicle, getElementRotation(theVehicle))
	setElementVelocity(theVehicle, getElementVelocity(theVehicle))
	setElementAngularVelocity(theVehicle, getElementAngularVelocity(theVehicle))
end)

addEventHandler("onElementStopSync", resourceRoot, function()
	if (getElementType(source) == "vehicle" and getElementData(source, "raceiv.interactable")) or g_Vehicles[source] then
		setElementFrozen(source, true)
		setElementPosition(source, getElementPosition(source))
		setElementRotation(source, getElementRotation(source))
		setElementVelocity(source, getElementVelocity(source))
		setElementAngularVelocity(source, getElementAngularVelocity(source))
	end
end)

addEventHandler("onElementStartSync", resourceRoot, function()
	if (getElementType(source) == "vehicle" and getElementData(source, "raceiv.interactable")) or g_Vehicles[source] then
		if (getVehicleController(source)) then
			return
		end
		setElementFrozen(source, false)
		setElementPosition(source, getElementPosition(source))
		setElementRotation(source, getElementRotation(source))
		setElementVelocity(source, getElementVelocity(source))
		setElementAngularVelocity(source, getElementAngularVelocity(source))
	end
end)

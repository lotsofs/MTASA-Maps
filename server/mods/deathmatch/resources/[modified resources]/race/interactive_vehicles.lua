g_IVSpawners = {}
g_IVSpawns = {}
g_IVDespawnTimers = {}

function processInteractiveVehicles(intVehs)
	g_IVSpawners = intVehs
	for i, v in ipairs(g_IVSpawners) do
		spawnInteractiveVehicle(v)
	end
end

function spawnInteractiveVehicle(stats)
	local x, y, z = unpack(stats.position)
	local rx, ry, rz = unpack(stats.rotation)
	local veh = createVehicle(stats.model, x, y, z, rx, ry, rz)
	if (stats.plate) then setVehiclePlateText(veh, stats.plate) end
	if (stats.paintjob and stats.paintjob ~= "false" and stats.paintjob ~= "nil") then setVehiclePaintjob(veh, tonumber(stats.paintjob)) end
	setVehicleSirensOn(veh, stats.sirens == 'true')
	if (stats.upgrades and type(stats.upgrades) == "table") then
		for _, u in ipairs(stats.upgrades) do
			addVehicleUpgrade(veh, u)
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

	setElementData(veh, "raceiv.unclaimedcollidewithvehicles", stats.unclaimedcollidewithvehicles == 'true')
	setElementData(veh, "raceiv.unclaimedcollidewithplayers", stats.unclaimedcollidewithplayers == 'true')
	setElementData(veh, "raceiv.claimedcollisions", stats.claimedcollisions == 'true')

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
	for vehicle, data in pairs(g_IVSpawns) do
		local x1, y1, z1 = unpack(data.position)
		local x2, y2, z2 = getElementPosition(vehicle)
		local distance = getDistanceBetweenPoints3D (x1, y1, z1, x2, y2, z2)
		if ((distance > data.maxmovedistance or isVehicleBlown(vehicle)) and not getElementData(vehicle, "raceiv.taken")) then
			-- Car is pushed too far outside of its spawn area or destroyed.
			local respawnTime = data.respawntime
			if (respawnTime >= 0) then
				setTimer(spawnInteractiveVehicle, respawnTime, 1, data)
			end
			setElementData(vehicle, "raceiv.taken", true)
		end
		local occupants = getVehicleOccupants(vehicle)
		if (not occupants[0] and #occupants == 0) then
			if (getElementData(vehicle, "raceiv.taken")) then
				-- Driver died or left the game without calling OnVehicleExit.
				local despawnTimer = g_IVDespawnTimers[vehicle]
				if (not despawnTimer) then
					markInteractiveVehicleForDespawn(vehicle)
				end
			end
		end
	end
end, 500, 0)

addEventHandler("onPlayerVehicleExit", root, function(theVehicle, seat, jacked)
	markInteractiveVehicleForDespawn(theVehicle)
end)

addEventHandler("onPlayerVehicleEnter", root, function(theVehicle, seat, jacked)
	local despawnTimer = g_IVDespawnTimers[theVehicle]
	if (despawnTimer) then
		killTimer(despawnTimer)
		g_IVDespawnTimers[theVehicle] = nil
	end
end)

function findFreeVehicle(player) 
	local lastMinDis = 10
	local nearestVeh = false
	local px,py,pz = getElementPosition(player)
	for _,v in pairs(getElementsWithinRange(px,py,pz,10,"vehicle")) do
		local owner = getElementData(v, "raceiv.owner")
		if ((not owner or owner == player) and not isVehicleBlown(v)) then
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
		setTimer(spawnInteractiveVehicle, respawnTime, 1, data)
	end
	
end)

addEvent("onClientStreamInVehicle", true)
addEventHandler("onClientStreamInVehicle", resourceRoot, function(theVehicle)
	setElementPosition(theVehicle, getElementPosition(theVehicle))
end)

addEventHandler("onElementStopSync", resourceRoot, function()
	if (getElementType(source) == "vehicle" and getElementData(source, "raceiv.interactable")) then
		setElementFrozen(source, true)
	end
end)

addEventHandler("onElementStartSync", resourceRoot, function()
	if (getElementType(source) == "vehicle" and getElementData(source, "raceiv.interactable")) then
		setElementFrozen(source, false)
	end
end)

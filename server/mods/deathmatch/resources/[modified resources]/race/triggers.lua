g_Triggers = {}
g_VehicleTriggers = {}
g_FootTriggers = {}

function processTriggers(map)
	g_Triggers = {}
	g_VehicleTriggers = {}
	g_FootTriggers = {}
	g_Triggers = map:getAll('trigger')
	g_VehicleTriggers = map:getAll('trigger_vehicle')
	g_FootTriggers = map:getAll('trigger_foot')
end

-- function destroyTriggers()
-- 	g_Triggers = {}
-- end


function distanceFromPlayerToFootSpawnpoint(player, spawnpoint)
    if player then
	    local x, y, z = getElementPosition(player)
	    return getDistanceBetweenPoints3D(x, y, z, unpack(spawnpoint.position))
    end
    return 0
end

function getSpaceAroundFootSpawnpoint(ignore,spawnpoint)
    local space = 100000
    for i,player in ipairs(g_Players) do
		if player ~= ignore then
			space = math.min(space, distanceFromPlayerToFootSpawnpoint(player, spawnpoint))
		end
    end
    return space
end

function hasSpaceFootAroundSpawnpoint(ignore,spawnpoint, requiredSpace)
    for i,player in ipairs(g_Players) do
		if player ~= ignore then
			if distanceFromPlayerToFootSpawnpoint(player, spawnpoint) < requiredSpace then
				return false
			end
        end
    end
    return true
end

local g_DoubleUpPos = 0
function pickFreeFootSpawnpoint(prefix, ignore)
    local options = {}
	for i, v in pairs(g_OnfootSpawnpoints) do
		if (prefix and string.sub(v.id, 1, #prefix) == prefix) then
			table.insert(options, v)
		end
	end
	if #options == 0 then return nil end
	-- Use the spawnpoints from #1 to #numplayers as a pool to use
    local numToScan = math.min(getPlayerCount(), #options)
    -- Starting at a random place in the pool...
    local scanPos = math.random(1,numToScan)
    -- ...loop through looking for a free spot
    for i=1,numToScan do
        local idx = (i + scanPos) % numToScan + 1
        if hasSpaceFootAroundSpawnpoint(ignore,options[idx], 1) then
			return options[idx]
        end
    end
    -- If one can't be found, find the spot which has the most space
    local bestSpace = 0
    local bestMatch = 1
    for i=1,numToScan do
        local idx = (i + scanPos) % numToScan + 1
        local space = getSpaceAroundFootSpawnpoint(ignore,options[idx])
        if space > bestSpace then
            bestSpace = space
            bestMatch = idx
        end
    end
	-- If bestSpace is too small, assume all spawnpoints are taken, and start to double up
	if bestSpace < 0.1 then
		g_DoubleUpPos = ( g_DoubleUpPos + 1 ) % #options
		bestMatch = g_DoubleUpPos + 1
	end
    return options[bestMatch]
end

function callTrigger(theTrigger, player)
	local trig
	for i, v in pairs(g_Triggers) do
		if (v.id == theTrigger) then
			trig = v
			break
		end
	end
	if (not trig) then
		return
	end
	if (trig.vehicletrigger) then
		callVehicleTrigger(trig.vehicletrigger, player)
	end
	if (trig.foottrigger) then
		callFootTrigger(trig.foottrigger, player)
	end

	if (trig.actiona == "None") then
		-- Do nothing. Putting this here simply so I can move things around easily without having to worry about changing between if and elseif if I end up changing first one.
	elseif (trig.actiona == "Can Fall Off Bike (Bool)") then
		action_SetFallOffBike(player, trig.arga)
	elseif (trig.actiona == "Exit Vehicle ()") then
		action_ExitVehicle(player)
	elseif (trig.actiona == "Vehicle Marker Visibility (Bool)") then
		action_VehicleBlip(player, trig.arga)
	elseif (trig.actiona == "Warp to Vehicle ()") then
		action_VehicleWarp(player)	
	end
	if (trig.nexttrigger ~= theTrigger) then
		callTrigger(trig.nexttrigger, player)
	end
end

function callFootTrigger(theTrigger, player)
	local fTrig
	for i, f in pairs(g_FootTriggers) do
		if (f.id == theTrigger) then
			fTrig = f
			break
		end
	end		
	
	if (fTrig.forceoutofvehicle == 'true') then
		removePedFromVehicle(player)
	end

	local templates = {}
	local template
	if (fTrig.multitemplate) then
		template = pickFreeFootSpawnpoint(fTrig.multitemplate, player)
	end
	for i, f in ipairs(g_OnfootSpawnpoints) do
		if (f.id == fTrig.template) then
			template = f
		end
	end
	if (not template) then return end
	if (fTrig.teleport == 'true') then
		setElementPosition(player, unpack(template.position))
		setElementInterior(player, template.interior or 0)
		if (fTrig.tpretainrotation ~= 'true') then
			local x, y, z = unpack(template.rotation)
			setElementRotation(player, x, y, z, "default", true)
		end
		if (fTrig.tpretainvelocity ~= 'true') then
			setElementVelocity(player, 0, 0, 0)
		end
	end
	if (fTrig.sethealth == 'true') then
		setElementHealth(player, template.health)
	end


	if (fTrig.changeskin == 'true') then
		setElementModel(player, template.skin)
	end

	if (template.jetpack == 'give') then
		setPedWearingJetpack(player, true)
	elseif (template.jetpack == 'remove') then
		setPedWearingJetpack(player, false)
	elseif (template.jetpack == 'toggle') then
		setPedWearingJetpack(player, not isPedWearingJetpack(player))
	end


end

function callVehicleTrigger(theTrigger, player)
	local vTrig
	for i, v in pairs(g_VehicleTriggers) do
		if (v.id == theTrigger) then
			vTrig = v
			break
		end
	end		

	if (not vTrig.template) then return end
	
	local template = findInteractiveVehicle(vTrig.template)

    if (vTrig.vehicletoaffect == "main" or not g_MapOptions.allowonfoot) then
		performVehicleTrigger(vTrig, g_Vehicles[player], player, template)
	elseif (vTrig.vehicletoaffect == "current") then
		local vehicle = getPedOccupiedVehicle(player)
		if (vehicle) then
			performVehicleTrigger(vTrig, vehicle, player, template)
		end
	elseif (vTrig.vehicletoaffect == "duplicate") then
		vehicle = spawnInteractiveVehicle(template)
		setElementData(vehicle, "raceiv.taken", true)
		setElementData(vehicle, "raceiv.owner", player)
		performVehicleTrigger(vTrig, vehicle, player, template, true)
	elseif (vTrig.vehicletoaffect == "new") then
		if (getPedOccupiedVehicle(player) or vTrig.change == 'true') then
			-- dont spawn vehicle if we need to change but there's nothing to change.
			local vehicle = spawnInteractiveVehicle(template)
			setElementData(vehicle, "raceiv.taken", true)
			setElementData(vehicle, "raceiv.owner", player)
			performVehicleTrigger(vTrig, vehicle, player, template, true)
		end
	end
end

function performVehicleTrigger(trigger, vehicle, player, template, new)
	if (not new and trigger.change == 'true') then
		-- turn our vehicle into a different one
		setElementModel(vehicle, template.model)
		if (template.plate) then setVehiclePlateText(vehicle, template.plate) end
		if (template.paintjob and template.paintjob ~= "false" and template.paintjob ~= "nil") then setVehiclePaintjob(vehicle, tonumber(template.paintjob)) end
		setVehicleSirensOn(vehicle, template.sirens == 'true')
		setVehicleLocked(vehicle, template.locked == 'true')
		setElementInterior(player, template.interior)
		setElementInterior(vehicle, template.interior)
		if (template.upgrades) then
			if (type(template.upgrades) == "table") then
				for _, u in ipairs(template.upgrades) do
					addVehicleUpgrade(vehicle, u)
				end
			elseif (type(template.upgrades) == "number") then
				addVehicleUpgrade(vehicle, template.upgrades)
			end
		end
		local col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12 = getVehicleColor(vehicle, true) 
		if (template.colora) then 
			col1, col2, col3 = unpack(template.colora)
		end
		if (template.colorb) then 
			col4, col5, col6 = unpack(template.colorb)
		end
		if (template.colorc) then 
			col7, col8, col9 = unpack(template.colorc)
		end
		if (template.colord) then 
			col10, col11, col12 = unpack(template.colord)
		end
		setVehicleColor(vehicle, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12)
	elseif (new and trigger.change ~= 'true') then
		-- spawned a new vehicle, but it needs to be the same as our current
		local oldVeh = getPedOccupiedVehicle(player)
		if (trigger.vehicletoaffect == "duplicate") then
			oldVeh = g_Vehicles[player]
		end
		if (oldVeh) then
			setElementModel(vehicle, getElementModel(oldVeh))
			setVehiclePlateText(vehicle, getVehiclePlateText(oldVeh))
			setVehicleSirensOn(vehicle, getVehicleSirensOn(oldVeh))
			setVehicleLocked(vehicle, isVehicleLocked(oldVeh))
			setElementHealth(vehicle, getElementHealth(oldVeh))
			setElementInterior(vehicle, getElementInterior(oldVeh))
			for _, u in pairs(getVehicleUpgrades(oldVeh)) do
				addVehicleUpgrade(vehicle, u)
			end
			setVehicleColor(vehicle, getVehicleColor(oldVeh, true))
		end
	end

	if (not new and trigger.teleport == 'true') then
		-- keep current car, and tp. So move it.
		local x, y, z = unpack(template.position)
		setElementPosition(vehicle, x, y, z)
		setElementInterior(player, template.interior)
		setElementInterior(vehicle, template.interior)
		if (trigger.tpretainrotation ~= 'true') then
			local rx, ry, rz = unpack(template.rotation)
			setElementRotation(vehicle, rx, ry, rz)
		end
		iprint(getElementVelocity(vehicle))
		if (trigger.tpretainvelocity ~= 'true') then
			setElementVelocity(vehicle, 0, 0, 0)
			setElementAngularVelocity(vehicle, 0, 0, 0)
		else
			setElementVelocity(vehicle, getElementVelocity(vehicle))
			setElementAngularVelocity(vehicle, getElementAngularVelocity(vehicle))
		end
	elseif (new and trigger.teleport == 'true') then
		-- yes tp, but new car so just leave our old vehicle where it is. update rot and vel if needed though.
		local oldVeh = getPedOccupiedVehicle(player)
		if (oldVeh) then
			if (trigger.tpretainrotation == 'true') then
				setElementRotation(vehicle, getElementRotation(oldVeh))
			end
			if (trigger.tpretainvelocity == 'true') then
				setElementVelocity(vehicle, getElementVelocity(oldVeh))
				setElementAngularVelocity(vehicle, getElementAngularVelocity(oldVeh))
			end
		end
	elseif (new and trigger.teleport ~= 'true') then
		-- new car, no tp. Move the new car to us.
		local oldVeh = getPedOccupiedVehicle(player)
		if (trigger.vehicletoaffect == "duplicate") then
			oldVeh = g_Vehicles[player]
		end
		if (not oldVeh) then
			oldVeh = player
		end
		setElementPosition(vehicle, getElementPosition(oldVeh))
		setElementInterior(vehicle, getElementInterior(oldVeh))
		if (trigger.tpretainrotation == 'true') then
			setElementRotation(vehicle, getElementRotation(oldVeh))
		end
		if (trigger.tpretainvelocity == 'true') then
			setElementVelocity(vehicle, getElementVelocity(oldVeh))
			if (oldVeh ~= player) then
				setElementAngularVelocity(vehicle, getElementAngularVelocity(oldVeh))
			end
		end	
	end

	if (trigger.sethealth == 'true') then
		setElementHealth(vehicle, template.health)
	end

	if (trigger.vehicletoaffect == "new") then
		-- put us inside the new car. 
		setElementData(vehicle, "raceiv.blocked", false)
		warpPedIntoVehicle(player, vehicle)
		if (template.cantenter == 'true') then
			setElementData(vehicle, "raceiv.blocked", true)
		end
	end
end

function action_SetFallOffBike(player, arg)
	triggerClientEvent(player, "callTriggerOnClient", player, "Fall Off Bike", arg)
end

function action_ExitVehicle(player, arg)
	triggerClientEvent(player, "callTriggerOnClient", player, "Exit Vehicle")
end

function action_VehicleBlip(player, arg)
	local state
	if (arg == "true") then
		state = true
	elseif (arg == "toggle") then
		state = "toggle"
	else
		state = false
	end
	triggerClientEvent(player, "callTriggerOnClient", player, "Vehicle Blip", state, g_Vehicles[player])
end

function action_VehicleWarp(player, arg)
	if (getPedOccupiedVehicle(player) ~= g_Vehicles[player]) then
		warpPedIntoVehicle(player, g_Vehicles[player])
	end
end
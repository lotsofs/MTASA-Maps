--
-- override_client.lua
--

-------------------------------------------------------
--
-- OverrideClient
--
-- Apply element vars for alpha and collideness
--
--------------------------------------------------------
OverrideClient = {}
OverrideClient.method = "fast"
OverrideClient.debug = false

addEventHandler('onClientElementStreamIn', root,
	function()
		if getElementType( source ) == "vehicle" or getElementType( source ) == "player" then
			OverrideClient.updateVars( source )
		end
	end
)

addEventHandler('onClientElementDataChange', root,
	function(dataName)
		if dataName == "race.collideothers" or dataName == "race.collideworld" or dataName == "race.alpha" or string.sub(dataName, 1, 7) == "raceiv." then
			OverrideClient.updateVars( source )
		end
	end
)

addEventHandler('onClientVehicleExit', root,
	function(thePlayer, seat)
		OverrideClient.updateVars( source )
		OverrideClient.updateVars( thePlayer )
	end
)

addEventHandler('onClientVehicleStartEnter', root,
	function(player, seat, door)
		OverrideClient.updateVars( source )
	end
)

addEventHandler('onClientVehicleEnter', root,
	function(player, seat, door)
		OverrideClient.updateVars( source )
	end
)

addEventHandler('onClientMapStarting', root,
	function(mapInfo)
		for i, v in pairs(getElementsByType("vehicle")) do
			OverrideClient.updateVars( v )
		end
	end
)

function OverrideClient.updateVars( element )
	-- Alpha
	local alpha = getElementData ( element, "race.alpha" )
	if alpha then
		setElementAlpha ( element, alpha )
	end
	if OverrideClient.method ~= "fast" then return end
	if not isVersion102Compatible() then
		if g_Vehicle then
			-- 1.0 and 1.0.1
			-- Collide others
			local collideothers = isCollideOthers ( g_Vehicle )
			for _,other in ipairs( getElementsByType( "vehicle" ) ) do
				if other ~= g_Vehicle then
					local docollide = collideothers and isCollideOthers ( other )
					setElementCollisionsEnabled ( other, docollide )
					setHeliBladeCollisionsEnabled ( other, g_GameOptions.helibladecollisionsdisabled )
				end
			end
			-- Collide world
			local collideworld = isCollideWorld ( g_Vehicle )
			setElementCollisionsEnabled ( g_Vehicle, collideworld )
		end
	else
		local i = getElementData(element, "raceiv.interactable")
		-- 1.0.2
		-- Collide others
		local collideothers = isCollideOthers ( element )
		local otherVehicles = getElementsByType( "vehicle" )
		if (not i) then
			for _,other in ipairs( otherVehicles ) do
				local docollide = collideothers and isCollideOthers ( other )
				setElementCollidableWith ( element, other, docollide )
				setHeliBladeCollisionsEnabled ( other, g_GameOptions.helibladecollisionsdisabled )
			end
		end
		-- Collide world
		local collideworld = isCollideWorld ( element )
		setElementCollisionsEnabled ( element, collideworld )
		-- Handle interactive cars, primarily for foot races, though the cars can be used for normal races as well
		if (alpha == 120) then
			return
		end -- Don't do anything if respawn effect (120 alpha)
		local otherPlayers = getElementsByType( "player" )
		local ghostModeOff = false
		local allowOnFoot = false
		if (g_MapOptions) then
			ghostModeOff = not g_MapOptions.ghostmode or false
			allowOnFoot = g_MapOptions.allowonfoot or false
		end

		if (i) then
			-- All interactable vehicles need to have their stuff set.
			local c = getElementData(element, "raceiv.collide")
			local t = getElementData(element, "raceiv.taken")
			local o = getElementData(element, "raceiv.owner")
			local vo = getVehicleController(element)
			if getElementData(element, "raceiv.blocked") then o = nil end
			if (vo and o ~= vo) then o = vo end

			if (not c) then -- This car has no cols
				setElementAlpha(element, 180)
				-- Set collisions
				for _,other in ipairs( otherPlayers ) do
					setElementCollidableWith( element, other, false )
				end
				for _,other in ipairs( otherVehicles ) do
					setElementCollidableWith( element, other, false )
				end
			elseif (o) then -- This car has cols and an owner
				setElementAlpha (element, o == localPlayer and 255 or ghostModeOff and 255 or 180)
				for _,other in ipairs( otherPlayers ) do
					setElementCollidableWith( element, other, other == o or ghostModeOff )
				end
				for _,other in ipairs( otherVehicles ) do
					local c2 = getElementData(other, "raceiv.collide")
					local t2 = getElementData(other, "raceiv.taken")
					local o2 = getElementData(other, "raceiv.owner")
					local i2 = getElementData(other, "raceiv.interactable")
					local vo2 = getVehicleController(other)
					if getElementData(other, "raceiv.blocked") then o2 = nil end
					if (vo2 and o2 ~= vo2) then o2 = vo2 end
					if (not i2) then
						setElementCollidableWith( element, other, o2 == o or isCollideOthers ( other ))
					elseif (not c2) then
						setElementCollidableWith( element, other, false )
					elseif (o2) then
						setElementCollidableWith( element, other, o2 == o or ghostModeOff )
					elseif (t2) then
						setElementCollidableWith( element, other, ghostModeOff )
					else
						setElementCollidableWith( element, other, true )
					end
				end
			elseif (t) then -- This car is claimed, but has no owner
				setElementAlpha(element, ghostModeOff and 255 or 180)
				-- Set collisions
				for _,other in ipairs( otherPlayers ) do
					setElementCollidableWith( element, other, ghostModeOff )
				end
				for _,other in ipairs( otherVehicles ) do
					local c2 = getElementData(other, "raceiv.collide")
					setElementCollidableWith( element, other, c2 and ghostModeOff )
				end
			else -- This car is parked and not claimed
				setElementAlpha(element, 255)
				-- Set collisions
				for _,other in ipairs( otherPlayers ) do
					setElementCollidableWith( element, other, true )
				end
				for _,other in ipairs( otherVehicles ) do
					local c2 = getElementData(other, "raceiv.collide")
					setElementCollidableWith( element, other, c2 )
				end
			end
		elseif (getElementData(element, "raceiv.owner")) then
			-- This is the main starter vehicle and it needs to be interacted with as well
			local o = getElementData(element, "raceiv.owner")
			if (allowOnFoot) then setElementAlpha (element, o == localPlayer and 255 or ghostModeOff and 255 or 180) end
			for _,other in ipairs( otherPlayers ) do
				setElementCollidableWith( element, other, other == o or ghostModeOff )
			end	
			for _,other in ipairs( otherVehicles ) do
				local c2 = getElementData(other, "raceiv.collide")
				local t2 = getElementData(other, "raceiv.taken")
				local o2 = getElementData(other, "raceiv.owner")
				local i2 = getElementData(other, "raceiv.interactable")
				local vo2 = getVehicleController(other)
				if getElementData(other, "raceiv.blocked") then o2 = nil end
				if (vo2 and o2 ~= vo2) then o2 = vo2 end
				if (not i2) then
					setElementCollidableWith( element, other, o2 == o or isCollideOthers ( other ))
				elseif (not c2) then
					setElementCollidableWith( element, other, false )
				elseif (o2) then
					setElementCollidableWith( element, other, o2 == o or ghostModeOff )
				elseif (t2) then
					setElementCollidableWith( element, other, ghostModeOff )
				else
					setElementCollidableWith( element, other, true )
				end
			end
		elseif (getElementType(element) == "player") then
			-- This is the main starter vehicle and it needs to be interacted with as well
			local o = element
			if (allowOnFoot) then setElementAlpha (element, o == localPlayer and 255 or ghostModeOff and 255 or 180) end
			for _,other in ipairs( otherPlayers ) do
				if (other ~= o) then
					setElementCollidableWith( element, other, ghostModeOff )
				end
			end	
			for _,other in ipairs( otherVehicles ) do
				local c2 = getElementData(other, "raceiv.collide")
				local t2 = getElementData(other, "raceiv.taken")
				local o2 = getElementData(other, "raceiv.owner")
				local i2 = getElementData(other, "raceiv.interactable")
				local vo2 = getVehicleController(other)
				if getElementData(other, "raceiv.blocked") then o2 = nil end
				if (vo2 and o2 ~= vo2) then o2 = vo2 end
				if (not i2) then
					setElementCollidableWith( element, other, isCollideOthers ( other ))
				elseif (not c2) then
					setElementCollidableWith( element, other, false )
				elseif (o2) then
					setElementCollidableWith( element, other, o2 == o or ghostModeOff )
				elseif (t2) then
					setElementCollidableWith( element, other, ghostModeOff )
				else
					setElementCollidableWith( element, other, true )
				end
			end
		end
		-- End LotsOfS
	end

end

function isCollideOthers ( element )
	return ( getElementData ( element, 'race.collideothers' ) or 0 ) ~= 0
end

function isCollideWorld ( element )
	return ( getElementData ( element, 'race.collideworld' ) or 1 ) ~= 0
end

--
-- Emergency backup method - Works, but is slower and doesn't look as nice
--
addEventHandler('onClientPreRender', root,
	function()
		if OverrideClient.method ~= "slow" then return end
		if g_Vehicle then
			-- Collide others
			local collideothers = isCollideOthers ( g_Vehicle )
			for _,vehicle in ipairs( getElementsByType( "vehicle" ) ) do
				if vehicle ~= g_Vehicle then
					local docollide = collideothers and isCollideOthers ( vehicle )
					setElementCollisionsEnabled ( vehicle, docollide )
					setHeliBladeCollisionsEnabled ( vehicle, g_GameOptions.helibladecollisionsdisabled )
				end
			end
			-- Collide world
			local collideworld = isCollideWorld ( g_Vehicle )
			setElementCollisionsEnabled ( g_Vehicle, collideworld )
		end
	end
)

-----------------------------------------------
-- Debug output
if OverrideClient.debug then
	addEventHandler('onClientRender', root,
		function()
			local sx = { 30, 200, 280, 360, 420, 500 }
			local sy = 200
			dxDrawText ( "name", sx[1], sy )
			dxDrawText ( "collisions", sx[2], sy )
			dxDrawText ( "colwith#", sx[3], sy )
			dxDrawText ( "col-othrs", sx[4], sy )
			dxDrawText ( "col-wrld", sx[5], sy )
			sy = sy + 25
			for _,vehicle in ipairs(getElementsByType("vehicle")) do
				local count = not isElementCollidableWith and "n/a" or 0
				for _,vehicle2 in ipairs(getElementsByType("vehicle")) do
					if vehicle ~= vehicle2 then
						if isElementCollidableWith and isElementCollidableWith( vehicle, vehicle2 ) then
							count = count + 1
						end
					end
				end
				local player = getVehicleController(vehicle)
				local collisions = not isVehicleCollisionsEnabled and "n/a" or isVehicleCollisionsEnabled(vehicle)
				local collideothers = getElementData ( vehicle, "race.collideothers" )
				local collideworld = getElementData ( vehicle, "race.collideworld" )
				dxDrawText ( getElementDesc(vehicle), sx[1], sy )
				dxDrawText ( tostring(collisions), sx[2], sy )
				dxDrawText ( tostring(count), sx[3], sy )
				dxDrawText ( tostring(collideothers), sx[4], sy )
				dxDrawText ( tostring(collideworld), sx[5], sy )
				sy = sy + 20
			end
		end
	)
end

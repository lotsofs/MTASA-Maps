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

addEventHandler('onClientElementStreamIn', g_Root,
	function()
		if getElementType( source ) == "vehicle" or getElementType( source ) == "player" then
			OverrideClient.updateVars( source )
		end
	end
)

addEventHandler('onClientElementDataChange', g_Root,
	function(dataName)
		if dataName == "race.collideothers" or dataName == "race.collideworld" or dataName == "race.alpha" or string.sub(dataName, 1, 7) == "raceiv." then
			OverrideClient.updateVars( source )
		end
	end
)

addEventHandler('onClientVehicleExit', g_Root, 
	function(thePlayer, seat)
		OverrideClient.updateVars( source )
		OverrideClient.updateVars( thePlayer )
	end
)

addEventHandler('onClientVehicleStartEnter', g_Root, 
	function(player, seat, door)
		OverrideClient.updateVars( source )
	end
)

addEventHandler('onClientMapStarting', g_Root,
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
				end
			end
			-- Collide world
			local collideworld = isCollideWorld ( g_Vehicle )
			setElementCollisionsEnabled ( g_Vehicle, collideworld )
		end
	else
		-- 1.0.2
		-- Collide others
		local collideothers = isCollideOthers ( element )
		local otherVehicles = getElementsByType( "vehicle" )
		for _,other in ipairs( otherVehicles ) do
			local docollide = collideothers and isCollideOthers ( other )
			setElementCollidableWith ( element, other, docollide )
		end
		-- Collide world
		local collideworld = isCollideWorld ( element )
		setElementCollisionsEnabled ( element, collideworld )
		-- LotsOfS: Code to handle interactive cars, primarily for foot races, though the cars can be used for normal races as well
		if (alpha == 120) then 
			return 
		end -- Ignore if respawn effect
		-- First off, we need to handle the players too, not just their vehicles
		local otherPlayers = getElementsByType( "player" )
		local ghostModeOff = false
		local allowOnFoot = false
		if (g_MapOptions) then
			ghostModeOff = not g_MapOptions.ghostmode or false
			allowOnFoot = g_MapOptions.allowonfoot or false
		end

		if (getElementData(element, "raceiv.interactable")) then
			local ugv = getElementData(element, "raceiv.unclaimedcollidewithvehicles")
			local ugp = getElementData(element, "raceiv.unclaimedcollidewithplayers")
			local cg = getElementData(element, "raceiv.claimedcollisions")
			local t = getElementData(element, "raceiv.taken")
			local o = getElementData(element, "raceiv.owner")
			if getElementData(element, "raceiv.blocked") then o = nil end
			local vo = getVehicleController(element)
			if (t and (o or vo)) then
				-- someone's car
				if (vo and o ~= vo) then
					o = vo
				end
				if (o == g_Me) then
					if (cg) then
						setElementAlpha (element, 255)
					else
						setElementAlpha (element, 180)
					end
				else
					setElementAlpha (element, (cg and ghostModeOff) and 255 or 180)
				end
				for _,other in ipairs( otherPlayers ) do
					if (other == o) then
						setElementCollidableWith ( element, other, cg )	
					else
						setElementCollidableWith ( element, other, ghostModeOff )	
					end
				end
				for _,other in ipairs( otherVehicles ) do
					local ugv2 = getElementData(other, "raceiv.unclaimedcollidewithvehicles")
					local cg2 = getElementData(other, "raceiv.claimedcollisions")
					local t2 = getElementData(other, "raceiv.taken")
					local o2 = getElementData(other, "raceiv.owner")
					if getElementData(other, "raceiv.blocked") then o2 = nil end
					local vo2 = getVehicleController(other)
					if ((t2 and o2 == o) or (not t2 and o2 == o)) then
						-- enable collisions with their own vehicles
						setElementCollidableWith(element, other, cg and cg2)
					elseif (t2) then
						-- enable cols with other players based on ghost mode setting
						setElementCollidableWith ( element, other, cg2 and ghostModeOff )	
					elseif (not t2 and getElementData(other, "raceiv.interactable")) then
						-- disable cols with parked cars
						setElementCollidableWith ( element, other, ugv2 )
					else	
						-- non interactive vehicles
						setElementCollidableWith ( element, other, isCollideOthers ( other ) )	
					end
				end
			elseif (t and not o) then
				-- a car pushed out of its spawn area or shared car
				setElementAlpha (element, ghostModeOff and 255 or 180)
				for _,other in ipairs( otherPlayers ) do
					setElementCollidableWith ( element, other, ghostModeOff )	
				end
				for _,other in ipairs( otherVehicles ) do
					local ugv2 = getElementData(other, "raceiv.unclaimedcollidewithvehicles")
					local cg2 = getElementData(other, "raceiv.claimedcollisions")
					local t2 = getElementData(other, "raceiv.taken")
					local o2 = getElementData(other, "raceiv.owner")
					if getElementData(other, "raceiv.blocked") then o2 = nil end
					local vo2 = getVehicleController(other)
					if (t2) then
						-- enable cols with other players based on ghost mode setting
						setElementCollidableWith ( element, other, cg2 and ghostModeOff )	
					elseif (not t2 and getElementData(other, "raceiv.interactable")) then
						-- disable cols with parked cars
						setElementCollidableWith ( element, other, ugv2 )
					else	
						-- non interactive vehicles
						setElementCollidableWith ( element, other, isCollideOthers ( other ) )	
					end
				end
			elseif (not t) then
				-- parked cars
				if (ugv) then
					setElementAlpha (element, 255)
				else
					setElementAlpha (element, 180)
				end
				for _,other in ipairs( otherPlayers ) do
					setElementCollidableWith ( element, other, ugp )	
				end
				for _,other in ipairs( otherVehicles ) do
					setElementCollidableWith ( element, other, ugv )	
				end
			end
		elseif (getElementData(element, "raceiv.owner")) then
			-- This is the main starter vehicle and it needs to be interacted with as well
			local o = getElementData(element, "raceiv.owner")
			if (allowOnFoot) then
				if (o == g_Me) then
					setElementAlpha (element, 255)
				end
			end
			for _,other in ipairs( otherPlayers ) do
				if (other == o) then
					setElementCollidableWith ( element, other, true )	
				else
					setElementCollidableWith ( element, other, ghostModeOff )	
				end
			end
			for _,other in ipairs( otherVehicles ) do
				local ugv2 = getElementData(other, "raceiv.unclaimedcollidewithvehicles")
				local cg2 = getElementData(other, "raceiv.claimedcollisions")
				local t2 = getElementData(other, "raceiv.taken")
				local o2 = getElementData(other, "raceiv.owner")
				if getElementData(other, "raceiv.blocked") then o2 = nil end
				local vo2 = getVehicleController(other)
				if ((t2 and o2 == o) or (not t2 and o2 == o)) then
					-- enable collisions with their own vehicles
					setElementCollidableWith(element, other, cg2)
				elseif (t2) then
					-- enable cols with other players based on ghost mode setting
					setElementCollidableWith ( element, other, cg2 and ghostModeOff )	
				elseif (not t2 and getElementData(other, "raceiv.interactable")) then
					-- disable cols with parked cars
					setElementCollidableWith ( element, other, ugv2 )
				else	
					-- non interactive vehicles
					setElementCollidableWith ( element, other, isCollideOthers ( other ) )	
				end
			end
		elseif (getElementType(element) == "player") then
			-- Lastly, take care of players themselves
			local o = element
			if (allowOnFoot) then
				if (o == g_Me) then
					setElementAlpha (element, 255)
				end
			end
			for _,other in ipairs( otherPlayers ) do
				if (other ~= o) then
					setElementCollidableWith ( element, other, ghostModeOff )	
				end
			end
			for _,other in ipairs( otherVehicles ) do
				local ugp2 = getElementData(other, "raceiv.unclaimedcollidewithplayers")
				local cg2 = getElementData(other, "raceiv.claimedcollisions")
				local t2 = getElementData(other, "raceiv.taken")
				local o2 = getElementData(other, "raceiv.owner")
				if getElementData(other, "raceiv.blocked") then o2 = nil end
				local vo2 = getVehicleController(other)
				if ((t2 and o2 == o) or (not t2 and o2 == o)) then
					-- enable collisions with their own vehicles
					setElementCollidableWith(element, other, cg2)
				elseif (t2) then
					-- enable cols with other players based on ghost mode setting
					setElementCollidableWith ( element, other, cg2 and ghostModeOff )	
				elseif (not t2 and getElementData(other, "raceiv.interactable")) then
					-- disable cols with parked cars
					setElementCollidableWith ( element, other, ugp2 )
				else	
					-- non interactive vehicles
					setElementCollidableWith ( element, other, isCollideOthers ( other ) )	
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
addEventHandler('onClientPreRender', g_Root,
	function()
		if OverrideClient.method ~= "slow" then return end
		if g_Vehicle then
			-- Collide others
			local collideothers = isCollideOthers ( g_Vehicle )
			for _,vehicle in ipairs( getElementsByType( "vehicle" ) ) do
				if vehicle ~= g_Vehicle then
					local docollide = collideothers and isCollideOthers ( vehicle )
					setElementCollisionsEnabled ( vehicle, docollide )
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
	addEventHandler('onClientRender', g_Root,
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

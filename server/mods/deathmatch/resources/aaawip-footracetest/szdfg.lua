-- function preRace(loadedResource)
-- 	if (loadedResource ~= resource) then
-- 		return
-- 	end
--     iprint(source)
-- 	setTimer(function(who)
--         removePedFromVehicle(who)
--         setElementPosition(who, 2241.7, 1061.7, 33.5)
--         setElementRotation(who, 0, 0, 68)
--         setCameraTarget(who, who)
--     end, 1000, 1, source)
--     -- <ped id="ped (1)" dimension="0" model="0" interior="0" rotZ="68.003" alpha="255" posX="2241.7" posY="1061.7" posZ="33.5" rotX="0" rotY="0"></ped>

--     -- configureCrane()
-- 	-- if (RACE_STARTED_ALREADY > 0) then
-- 	-- 	return
-- 	-- end
-- 	-- setTimer(function()
-- 	-- 	if (RACE_STARTED_ALREADY > 0) then
-- 	-- 		return
-- 	-- 	end
-- 	-- 	setCameraMatrix (  -213.5, -453.5, 63.5, -118.0, -353.8, 0.5)
-- 	-- end, 1000, 1)
-- end
-- addEventHandler("onPlayerResourceStart", root, preRace)


-- local RACE_RESOURCE = getResourceDynamicElementRoot(getResourceFromName("race"))

function a()
	iprint(":)")
    local p = getPlayerFromName("S.")
    -- local v = getPedOccupiedVehicle(p)
    -- removePedFromVehicle(p)
    x, y, z = getElementPosition(p)
    local u = createPickup(x, y, z, 0, 100, 1)
    -- local u = createPed(7, x, y, -30)
    -- warpPedIntoVehicle(u, v, 0)
end
addCommandHandler("aa", a)

-- function b()
--     iprint("ASDF")
-- end
-- addEventHandler("warppeds", root, b)
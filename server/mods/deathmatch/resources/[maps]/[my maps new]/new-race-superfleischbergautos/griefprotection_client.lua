function handleVehicleExplosions(x, y, z, theType)
	-- 2 = hunter
	-- 3 = hydra heat seek
	-- 10 = tank
	if (theType == 2 or theType == 3 or theType == 10) then
		-- u, v, w = getElementPosition(localPlayer)
		-- if (getDistanceBetweenPoints3D ( x, y, z, u, v, w ) < 120) then
		-- 	playSFX("genrl", 45, 3, false)
		-- end
		-- playSFX("genrl", 45, 1, false)
		if (source ~= localPlayer) then
			-- createEffect("explosion_medium", x,y,z, 270, 0, 0, 0, true)
			createExplosion(x,y,z,1)
			cancelEvent()
		end
		-- createExplosion(x, y, z, theType, true, -1.0, true)
	end
end
addEventHandler("onClientExplosion", root, handleVehicleExplosions)
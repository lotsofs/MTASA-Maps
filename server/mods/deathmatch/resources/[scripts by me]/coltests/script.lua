iprint("fyuc")
setDevelopmentMode(true)

addCommandHandler("devmode",
    function()
		
		
		iprint("fyuc")
        setDevelopmentMode(true)
    end
)


-- vehicleMatrix is the column-major 4x4 matrix, a 3x3 rotation with translation in the fourth column. (Basically homogeneous but not using all features.)
-- desiredDirection is a 2-vector {x, y}. Something like {x, y, z} is tolerated but gets z ignored.
-- The matrix has its heading changed in place and is returned.
function makeVehicleFaceHeading(vehicleMatrix, desiredDirection)
    local parallel = desiredDirection[1] * vehicleMatrix[2][1] + desiredDirection[2] * vehicleMatrix[2][2]
    local perpendicular = desiredDirection[1] * vehicleMatrix[2][2] - desiredDirection[2] * vehicleMatrix[2][1]
    local lengthSquared = parallel * parallel + perpendicular * perpendicular
    if lengthSquared > 0 then -- When facing straight up or down, there is no sense of heading. Don't do anything in that case.
        local length = math.sqrt(lengthSquared)
        parallel = parallel / length
        perpendicular = perpendicular / length
        for i = 1, 3 do -- Only do 3 to rotate around the vehicle's origin, not the world's origin.
            vehicleMatrix[i][1], vehicleMatrix[i][2] =
                parallel * vehicleMatrix[i][1] + perpendicular * vehicleMatrix[i][2],
                parallel * vehicleMatrix[i][2] - perpendicular * vehicleMatrix[i][1]
        end
    end
    return vehicleMatrix
end


addEventHandler("onClientVehicleDamage", root,
	function(theAttacker, theWeapon, loss, damagePosX, damagePosY, damagePosZ, tireID)
		vehiclePosX, vehiclePosY, vehiclePosZ = getElementPosition(source)
		vehicleVelocityX, vehicleVelocityY, vehicleVelocityZ = getElementVelocity(source)
		-- We need to use matrices to figure out where forward is. Then we can do an angular calculation on where the damage was taken
		-- Something like the below commented stuff but with the correct values.
		-- If we're using matrices anyway, at that point could probably just calculate our rotation compared to the impact force's direction directly.
		-- That would also involve some positional calcs. Car A tboning car B will have the same angles as car B tboning car A.
		-- So yeah
		local q = createObject(1240,damagePosX,damagePosY,damagePosZ)
		setElementCollisionsEnabled(q, false)
		iprint("AH")
		
	end
)

addEventHandler("onClientVehicleCollision", root,
	function()
	end
)

-- addEventHandler("onClientVehicleCollision", root,
-- 	function(collider, damageImpulseMag, bodyPart, x, y, z, nx, ny, nz, hitElementForce, model)
-- 		iprint(source, bodyPart)
-- 		if (true) then
-- 			return
-- 		end
-- 		occupant = getVehicleOccupant(source)
-- 		if (occupant ~= localPlayer) then
-- 			-- iprint("Not me", source)
-- 			return
-- 		end
-- 		-- iprint("I", source)
-- 		cx, cy, cz = getElementPosition(collider) -- Their pos
-- 		vx, vy, vz = getElementVelocity(source) -- Velocity
-- 		px, py, pz = getElementRotation(source) -- Position = point P
-- 		fx = px + vx -- Future position (pos + vel) = point F
-- 		fy = py + vy
-- 		fz = pz + vz
-- 		--point C = cx,cy,cz (collision point)
-- 		-- ==> triangle PCF
-- 		-- calculate side lengths:
-- 		lPF = getDistanceBetweenPoints3D(px,py,pz,fx,fy,fz) -- Triangle side lengths
-- 		lCF = getDistanceBetweenPoints3D(cx,cy,cz,fx,fy,fz)
-- 		lPC = getDistanceBetweenPoints3D(px,py,pz,cx,cy,cz)
-- 		-- https://en.wikipedia.org/wiki/Law_of_cosines
-- 		-- We want to calculate the angle the attack came from. Thus the angle of corner P
-- 		--
-- 		--                   adjacentA² + adjacentB² - opposite²
-- 		-- corner = arccos( ------------------------------------- )
-- 		--                        2 * adjacentA * adjacentB
-- 		--
-- 		--                   lPF² + lPC² - lCF²
-- 		-- P = arccos( ------------------------------------ )
-- 		--                       2 * lPF * lPC
-- 		--
-- 		local numerator = lPF*lPF + lPC*lPC - lCF*lCF
-- 		local denominator = 2*lPC*lPF
-- 		local cosineP = numerator/denominator
-- 		local pa = math.acos(cosineP)
-- 		pa = math.deg(pa)
-- 		iprint(pa)



-- 	end
-- )
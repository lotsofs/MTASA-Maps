function getVehicleSpeed()
    local target = localPlayer    
    if getElementData(localPlayer, 'race.spectating') then
        target = getVehicleOccupant(getCameraTarget(localPlayer), 0)
    end    
    local vehicle = getPedOccupiedVehicle(target)  
    if (vehicle) then
        local vx, vy, vz = getElementVelocity(vehicle)
        
        if (vx) and (vy)and (vz) then
            return math.sqrt(vx^2 + vy^2 + vz^2) * 180 -- km/h
        else
            return 0
        end
    else
        return 0
    end
end


function getVehicleSpeedString() 
    local speedString = math.floor(getVehicleSpeed() + 0.5)
    return string.format("%03d", speedString)
end
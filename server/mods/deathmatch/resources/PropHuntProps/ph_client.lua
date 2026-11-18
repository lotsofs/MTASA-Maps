
local screenWidth, screenHeight = guiGetScreenSize ( ) -- Get the screen resolution (width and height)

local progress = 0

function check_proximity ()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then 
        return
    end
    
    local x, y, z = getElementPosition ( veh )
    x2,y2,z2 = getPositionFromElementOffset(veh,0,2,0)

    -- only process world map in line of sight, hit is guaranteed a world model
    local hit, hx, hy, hz, hitElement, _, _, _, material, _, _, worldModelID = processLineOfSight (x,y,z,x2,y2,z2,
                    true, -- world map items
                    false, -- vehicles
                    false, -- players
                    true, -- objects, must be set true to detect dynamic objects
                    false, -- dummies
                    false, -- see through stuff
                    false, -- ignore some objects for camera
                    false, -- shoot through stuff
                    nil,   -- ignored element
                    true,  -- include world model info, this is required to get the model ID
                    false, -- car tyres
                    true) -- material info

    color = tocolor(255,0,0)
    if hit then
        if models[worldModelID] then
            -- Extra check to never detect in starting area. 
            -- Technically not needed because demo objects are not collidable and thus invisible to process line of sight.
            -- But we never know what delicious bugs future versions might bring
            if not (hy > -108 and hy < -52 and hx < 108 and hx > 52) then  
                if not found[worldModelID] then -- trigger server event once
                    found[worldModelID] = true
                    progress = progress + 1
                    collectCheckpoints(progress)
                    triggerServerEvent("onServerSendMessage", localPlayer, worldModelID, hx, hy, hz)
                    addEventHandler("onClientRender", root, showMessage)
                    setTimer(function()
                        removeEventHandler("onClientRender", root, showMessage)
                    end, 2000, 1)
                end
                color = tocolor(0,255,0)
            end
        end
    
        --dxDrawText ( worldModelID, screenWidth/2, screenHeight/2, screenWidth, screenHeight, tocolor ( 0, 255, 0, 255 ), 1.02, "pricedown" )
        --dxDrawText ( material, screenWidth/2+20, screenHeight/2, screenWidth, screenHeight, tocolor ( 0, 255, 0, 255 ), 1.02, "pricedown" )

    end
    dxDrawLine3D(x,y,z,x2,y2,z2,color)

end
addEventHandler ( "onClientRender", root, check_proximity )


function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end


function soundAirHorn()
    playSFX("script", 6, 1, false) -- airhorn sound
end
addEvent ( "soundAirHorn", true )
addEventHandler ("soundAirHorn", getRootElement(), soundAirHorn )


models = {}
found = {}
function receivePropData(prop_data)
    print('Client received prop_data, the next number should be 5: ', #prop_data)
    for i, prop in ipairs(prop_data) do
        models[prop['model']] = true
    end
end
addEvent ( "receivePropData", true )
addEventHandler ("receivePropData", getRootElement(), receivePropData )


function collectCheckpoints(target)
    local checkpoint = getElementData(localPlayer, "race.checkpoint")
    if not checkpoint then 
        return
    end
    if (checkpoint > target) then 
        return 
    end
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if (isElementFrozen(vehicle)) then 
        return 
    end
    for i=checkpoint, target do
        local raceresource = getResourceFromName("race")
        local racedynamics = getResourceDynamicElementRoot(raceresource)
        local colshapes = getElementsByType("colshape", racedynamics)
        if (#colshapes == 0) then
            break
        end
        triggerEvent("onClientColShapeHit", colshapes[#colshapes], vehicle)
    end
end


function checkVehicles(theVehicle)  -- when you respawn collect checkpoints again
    collectCheckpoints(progress)
end
addEventHandler("onClientPlayerVehicleEnter", localPlayer, checkVehicles)


function showMessage()
    dxDrawText ( "Prop Collected!", screenWidth/2, screenHeight/2, screenWidth, screenHeight, tocolor ( 0, 255, 0, 255 ), 1.02, "pricedown" )
end

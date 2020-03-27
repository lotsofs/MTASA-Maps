-- THIS RESOURCE WAS WRITTEN BY VALLY SPECIALLY FOR MRL COMMUNITY

-- INIT
local fuel = 100
c_rate = 0.025 --fuel consume rate
r_rate = 1 --fuel refill rate
v_property = 0 --vehicle default handling property
property_m = 0.03 --handling property multiplier
property = "engineAcceleration" --vehicle handling property to change
current_property = 0 --vehicle current changable property value. used for debug
refill_stations_coords = {} --refill stations coords
refill_stations_coords[1] = {2371.42,-1744.83,12.5}

refill_stations = {} --refill stations

-- CALL SERVER FUNCTION
function callServerFunction(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do
            if (type(value) == "number") then arg[key] = tostring(value) end
        end
    end
    triggerServerEvent("onClientCallsServerFunction", resourceRoot , funcname, unpack(arg))
end

-- FUNCTIONS
function stopEngine()
    if getVehicleEngineState(getPedOccupiedVehicle(localPlayer)) then
        callServerFunction("setVehicleEngineState", getPedOccupiedVehicle(localPlayer), false)
    end
end

function fuelConsume()
    if isPedInVehicle(localPlayer) and getVehicleEngineState(getPedOccupiedVehicle(localPlayer)) then
        if fuel > c_rate then
            fuel = fuel - c_rate
        elseif fuel <= c_rate or fuel <= 0 then
            stopEngine()
        end
        setElementData(getPedOccupiedVehicle(localPlayer), "fuel", fuel)
    end
end

function createRefillStations()
    for i,coords in ipairs(refill_stations_coords) do
        local x = coords[1]
        local y = coords[2]
        local z = coords[3]
        refill_stations[i] = createMarker(x,y,z,"cylinder",3,255,255,255,50)
        createBlip(x,y,z,27)
    end
end

function fuelRefill()
    if not isPedInVehicle(localPlayer) then return end
    for i,marker in ipairs(refill_stations) do
        local p_veh = getPedOccupiedVehicle(localPlayer)
        if isElementWithinMarker(p_veh, marker) and fuel < 100 then
            fuel = fuel + r_rate
        end
    end
end

function updateHandling()
    if not isElement(getPedOccupiedVehicle(localPlayer)) then return end
    local new_property = v_property + 1.3 - fuel*property_m
    if new_property > 100 then
        new_property = 100
    end
    current_property = new_property
    callServerFunction("setVehicleHandling", getPedOccupiedVehicle(localPlayer), property, new_property)
end

createRefillStations()

--GUI
function quater()
    fuel = 25
    setElementData(getPedOccupiedVehicle(localPlayer), "fuel", fuel)
end

function half()
    fuel = 50
    setElementData(getPedOccupiedVehicle(localPlayer), "fuel", fuel)
end

function three_quater()
    fuel = 75
    setElementData(getPedOccupiedVehicle(localPlayer), "fuel", fuel)
end

function full()
    fuel = 100
    setElementData(getPedOccupiedVehicle(localPlayer), "fuel", fuel)
end

local window

function createWindow()
    local x,y = guiGetScreenSize()
    showCursor(true, true)
    window = guiCreateWindow(x-210, y/2-100, 200, 160, "Initial fuel", false)
    quater_button = guiCreateButton(10, 30, 180, 20, "1/4 of fuel tank", false, window)
    addEventHandler("onClientGUIClick", quater_button, quater)
    half_button = guiCreateButton(10, 60, 180, 20, "1/2 of fuel tank", false, window)
    addEventHandler("onClientGUIClick", half_button, half)
    three_quater_button = guiCreateButton(10, 90, 180, 20, "3/4 of fuel tank", false, window)
    addEventHandler("onClientGUIClick", three_quater_button, three_quater)
    full_button = guiCreateButton(10, 120, 180, 20, "full fuel tank", false, window)
    addEventHandler("onClientGUIClick", full_button, full)
    setTimer(
        function()
            guiSetVisible(window, false)
            showCursor(false)
        end
        , 20000, 1)
end

-- TIMERS
setTimer(fuelConsume, 100, 0)
setTimer(fuelRefill, 100, 0)
setTimer(updateHandling, 1000, 0)

-- EVENTS
addEventHandler("onClientPlayerVehicleEnter", getRootElement(),
    function(theVehicle, seat)
        if seat == 0 and source == localPlayer then
            local d_property = getElementData(theVehicle, "def_property")
            if not d_property then
                local handlingTable = getVehicleHandling(theVehicle)
                v_property = handlingTable[property]
                setElementData(theVehicle, "def_property", v_property)
            else
                v_property = d_property
            end
            createWindow()
        end
    end
)

--[[addCommandHandler("engine",
    function()
        if not isPedInVehicle(localPlayer) then return end
        local state = getVehicleEngineState(getPedOccupiedVehicle(localPlayer))
        callServerFunction("setVehicleEngineState", getPedOccupiedVehicle(localPlayer), not state)
    end
)
]]
addEventHandler("onClientResourceStart", getRootElement(),
    function(resource)
        if resource == getThisResource() then
            if isPedInVehicle(localPlayer) then
                triggerEvent("onClientPlayerVehicleEnter", localPlayer, getPedOccupiedVehicle(localPlayer), 0)
            end
        end
    end
)

addEvent("onStartBla", true)
addEventHandler("onStartBla", getRootElement(),
    function()
        guiSetVisible(window, false)
        showCursor(false)
    end
)

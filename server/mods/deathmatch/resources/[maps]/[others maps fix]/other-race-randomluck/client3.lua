gMe=getLocalPlayer()
local marker = createMarker(6584.44921875, -3785, 5, "corona", 10, 0, 0, 0, 0)

function weather(hitPlayer)
    if hitPlayer~=gMe then return end
    vehicle=getPedOccupiedVehicle(hitPlayer)
        if source == marker then
            setWeather (0)
            setTime (23, 0)
        end
    end
addEventHandler("onClientMarkerHit",getResourceRootElement(getThisResource()),weather)
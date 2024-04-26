addEvent("onClientMissionStarted", true)

function gainProgression(mission)
	local progress = getElementData(source, "rsp-completion")
	progress = progress + 1
	setElementData(source, "rsp-completion", progress)
	
	local vehicle = getPedOccupiedVehicle(localPlayer)
    local checkpoint = getElementData(localPlayer, "race.checkpoint")
    for i=checkpoint, progress do
		local colshapes = getElementsByType("colshape", getResourceDynamicElementRoot(getResourceFromName("race")))
		if (#colshapes == 0) then
			break
		end
		triggerEvent("onClientColShapeHit",
            colshapes[#colshapes], vehicle, true)
    end
end
addEvent("onClientMissionPassed", true)
addEventHandler("onClientMissionPassed", root, gainProgression)
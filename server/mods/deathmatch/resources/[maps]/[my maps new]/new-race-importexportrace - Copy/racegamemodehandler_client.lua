function collectCheckpoints(target)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    local checkpoint = getElementData(localPlayer, "race.checkpoint")
    for i=checkpoint, target do
		local colshapes = getElementsByType("colshape", RACE_RESOURCE)
		if (#colshapes == 0) then
			break
		end
		triggerEvent("onClientColShapeHit",
            colshapes[#colshapes], vehicle, true)
    end
end

function finishRace(new)
	teleportToCraneForFinish()
	collectCheckpoints(#getElementsByType("checkpoint"))
end
addEvent("finishRace", true)
addEventHandler("finishRace", localPlayer, finishRace)
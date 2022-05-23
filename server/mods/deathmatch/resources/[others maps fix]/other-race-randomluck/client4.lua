marker1 = createMarker (6584.390625,-4044.0283203125,35.54,"corona",5,0,0,0,0)


function jump(hitPlayer, matchingDimension)
	if(hitPlayer ~= getLocalPlayer() or not matchingDimension) then return end
	
	if(source == marker1)then
		local ve = getPedOccupiedVehicle(hitPlayer)
		setElementVelocity(ve, 0, 0, 0.75)
	end
end
addEventHandler("onClientMarkerHit", getRootElement(), jump)

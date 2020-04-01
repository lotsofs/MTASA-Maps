addEvent('onRaceStateChanging')
addEventHandler('onRaceStateChanging', root, function (new)
	if (new ~= 'GridCountdown') then
		return
	end
	
	for i, blip in ipairs(getElementsByType('blip')) do
		setBlipColor(blip, 0, 0, 0, 0)
	end
	
	for j, player in ipairs(getElementsByType('player')) do
		if (player.vehicle.model == 480) then
			setPlayerWantedLevel(player, 2)
		end
		
		setVehicleDamageProof(player.vehicle, true)
	end
	
	triggerClientEvent('onClientScreenFadedOut', root)
end)

addEventHandler('onVehicleDamage', root, function (loss)
	if (loss < (1000 - 249)) then
		setElementHealth(source, 1000)
	end
end)

addEventHandler('onVehicleExplode', root, function ()
	if (source.model == 480) then
		outputChatBox("We can't prosecute the dead! You're working the beat until I have regained confidence in your abilities.")
	end
end)

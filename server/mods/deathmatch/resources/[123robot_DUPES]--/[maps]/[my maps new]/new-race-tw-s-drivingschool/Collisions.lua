function onClientElementDataChange(theKey, oldValue, newValue)
	if (theKey == "race.collideothers") then
		evaluateTeamCollisions(source, oldValue, newValue)
	end
end

function evaluateTeamCollisions(vehicle, oldValue, newValue)
	-- check if a car has its collisions set by the race gamemode and whether it is being set to yes collisions.
	if (newValue == 0) then
		return
	end
	-- check if the car has an occupant
	if (not getVehicleOccupant(vehicle)) then
		return
	end
	-- compare occupant team to player's team
	team1 = getPlayerTeam(getVehicleOccupant(vehicle))
	team2 = getPlayerTeam(localPlayer)

	-- if not, set collisions to false isntead of true
	if (team1 ~= team2) then
		setElementData(vehicle, "race.collideothers", 0, false)
	end
end
addEventHandler("onClientElementDataChange", root, onClientElementDataChange)


function resetCollisions(player)
	if (player == localPlayer) then
		for i, v in pairs(getElementsByType("player")) do
			vehicle = getPedOccupiedVehicle(v)
			setElementData(vehicle, "race.collideothers", 1, false)
		end
	else
		vehicle = getPedOccupiedVehicle(player)
		if (not vehicle) then
			return
		end
		setElementData(vehicle, "race.collideothers", 1, false)
	end
end
addEvent("resetCollisions", true)
addEventHandler("resetCollisions", getRootElement(), resetCollisions)
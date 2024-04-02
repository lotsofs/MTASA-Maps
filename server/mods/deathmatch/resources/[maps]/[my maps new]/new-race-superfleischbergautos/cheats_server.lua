------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------

function cheatResetProgress(playerSource, commandName)
	outputChatBox ( "Resetting Progress", playerSource, 255, 127, 127, true )
	SHUFFLED_INDICES_PER_PLAYER[playerSource] = {}
	PLAYER_PROGRESS[playerSource] = 1
	shuffleCarsPerPlayer(playerSource)
	triggerClientEvent(playerSource, "updateTarget", playerSource, PLAYER_PROGRESS[playerSource])
end
addCommandHandler("ie_resetprogress", cheatResetProgress)

function cheatSkipForPlayer(playerSource, commandName, name)
	if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(playerSource)), aclGetGroup ("Admin")) then
		local playa = getPlayerFromName ( name )
		if (not playa) then
			iprint("[FleischBerg Autos] no such player")
			return
		end

		progress = PLAYER_PROGRESS[playa] + 1
		if (progress > REQUIRED_CHECKPOINTS) then
			return
		end
		PLAYER_PROGRESS[playa] = progress
		
		teleportToNext(progress, playa)
		triggerClientEvent(playa, "updateTarget", playa, progress)
	end
end
addCommandHandler("ie_cheatSkipForPlayer", cheatSkipForPlayer )

function cheatSkipVehicle(playerSource, commandName)
	progress = PLAYER_PROGRESS[playerSource] + 1
	if (progress > REQUIRED_CHECKPOINTS) then
		return
	end
	PLAYER_PROGRESS[playerSource] = progress
	
	teleportToNext(progress, playerSource)
	triggerClientEvent(playerSource, "updateTarget", playerSource, progress)
end
addCommandHandler("cheatnext", cheatSkipVehicle)

function cheatFlipVehicle(playerSource, commandName)
	vehicle = getPedOccupiedVehicle(playerSource)
	setElementRotation(vehicle, 0, 180, 0)
end
addCommandHandler("cheatflip", cheatFlipVehicle)

function cheatPrevVehicle(playerSource, commandName)
	progress = PLAYER_PROGRESS[playerSource] - 1
	if (progress == 0) then
		return
	end
	PLAYER_PROGRESS[playerSource] = progress
	
	teleportToNext(progress, playerSource)
	triggerClientEvent(playerSource, "updateTarget", playerSource, progress)
end
addCommandHandler("cheatprev", cheatPrevVehicle)

function cheatTeleportVehicle(playerSource, commandName)
	vehicle = getPedOccupiedVehicle(playerSource)
	setElementPosition(vehicle, 0, 0, 20)
end
addCommandHandler("cheattp", cheatTeleportVehicle)

function cheatTeleportVehicleOp(playerSource, commandName)
	vehicle = getPedOccupiedVehicle(playerSource)
	setElementPosition(vehicle, 5, -241, 20)
end
addCommandHandler("cheattpop", cheatTeleportVehicleOp)

function cheatTeleportBoat(playerSource, commandName)
	vehicle = getPedOccupiedVehicle(playerSource)
	setElementPosition(vehicle, -219, -604, 20)
end
addCommandHandler("cheattpboat", cheatTeleportBoat)
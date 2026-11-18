------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------
------------------------------------------------------ Cheats ------------------------------------------------------

CHEATS_ENABLED = false

function cheatResetProgress(playerSource, commandName)
	outputChatBox ( "Resetting Progress", playerSource, 255, 127, 127, true )
	SHUFFLED_INDICES_PER_PLAYER[playerSource] = {}
	PLAYER_PROGRESS[playerSource] = 1
	shuffleCarsPerPlayer(playerSource)
	triggerClientEvent(playerSource, "updateTarget", playerSource, PLAYER_PROGRESS[playerSource])
end

function enableCheats(playerSource, commandName)
	if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(playerSource)), aclGetGroup ("Admin")) then
		CHEATS_ENABLED = true
	end
end

function enableOption(playerSource, commandName, count)
	if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(playerSource)), aclGetGroup ("Admin")) then
		FORCE_ADD_POLL_OPTION = tonumber(count)
		iprint("[FleischBerg Autos] Adding " .. count)
	end
end

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

function cheatSkipVehicle(playerSource, commandName)
	if (not CHEATS_ENABLED) then return end
	progress = PLAYER_PROGRESS[playerSource] + 1
	if (progress > REQUIRED_CHECKPOINTS) then
		return
	end
	PLAYER_PROGRESS[playerSource] = progress
	
	teleportToNext(progress, playerSource)
	triggerClientEvent(playerSource, "updateTarget", playerSource, progress)
end

function cheatFlipVehicle(playerSource, commandName)
	if (not CHEATS_ENABLED) then return end
	vehicle = getPedOccupiedVehicle(playerSource)
	setElementRotation(vehicle, 0, 180, 0)
end

function cheatPrevVehicle(playerSource, commandName)
	if (not CHEATS_ENABLED) then return end
	progress = PLAYER_PROGRESS[playerSource] - 1
	if (progress == 0) then
		return
	end
	PLAYER_PROGRESS[playerSource] = progress
	
	teleportToNext(progress, playerSource)
	triggerClientEvent(playerSource, "updateTarget", playerSource, progress)
end

function cheatTeleportVehicle(playerSource, commandName)
	if (not CHEATS_ENABLED) then return end
	vehicle = getPedOccupiedVehicle(playerSource)
	setElementPosition(vehicle, 0, 0, 20)
end

function cheatTeleportVehicleOp(playerSource, commandName)
	if (not CHEATS_ENABLED) then return end
	vehicle = getPedOccupiedVehicle(playerSource)
	setElementPosition(vehicle, 5, -241, 20)
end

function cheatTeleportBoat(playerSource, commandName)
	if (not CHEATS_ENABLED) then return end
	vehicle = getPedOccupiedVehicle(playerSource)
	setElementPosition(vehicle, -219, -604, 20)
end

addCommandHandler("ie_resetprogress", cheatResetProgress)
addCommandHandler("ie_cheatSkipForPlayer", cheatSkipForPlayer )
addCommandHandler("ie_enableCheats", enableCheats )
addCommandHandler("ie_poll", enableOption )
addCommandHandler("cheatnext", cheatSkipVehicle)
addCommandHandler("cheatflip", cheatFlipVehicle)
addCommandHandler("cheatprev", cheatPrevVehicle)
addCommandHandler("cheattp", cheatTeleportVehicle)
addCommandHandler("cheattpboat", cheatTeleportBoat)	
addCommandHandler("cheattpop", cheatTeleportVehicleOp)
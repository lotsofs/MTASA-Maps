function onClientWantsPackageInfo()
	sendClientPackageData(source)
end
addEvent("onClientWantsPackageInfo", true)
addEventHandler("onClientWantsPackageInfo", root, onClientWantsPackageInfo)

function sendClientPackageData(player, nonParticipation)
	local account = getPlayerAccount(player)
	convertOldInformation(account)
	if (nonParticipation == nil) then
		nonParticipation = getAccountNonParticipation(account)
	end
	local packageData = db_getPlayerCollectedPackages(player)
	triggerClientEvent(player, "onServerSentPackageInfo", resourceRoot, packageData, not isGuestAccount(account), nonParticipation, g_currentMapFileName, g_currentMapFriendlyName)
end

function onClientCollectedPackage(packType, packNum, vehicleModel, checkpoint)
	playerAccount = getPlayerAccount(source)
	playerAccountID = getAccountID(playerAccount)
	timestamp = getRealTime().timestamp
	spamKillFeed(packType, source)
	db_writePlayerCollectedPackage(packType, packNum, playerAccountID, vehicleModel, g_currentMapFileName, checkpoint or 0, timestamp, false)
end
addEvent("onClientCollectedPackage", true)
addEventHandler("onClientCollectedPackage", root, onClientCollectedPackage)

function validateBlacks()
	local packages = getElementsByType("packageCustom", resourceRoot)

    for i, pack in ipairs(packages) do
        local mapName = getElementData(pack, "mapAssignment")
		-- validate map exists
		if (not getResourceFromName(mapName)) then
			outputDebugString("INVALID MAP", 0, 255, 0 , 255)
			iprint("[Hidden Packages Colored] Map with ID "..mapName.." has been renamed or removed.")
		end
    end
end
addEventHandler("onResourceStart", resourceRoot, validateBlacks)

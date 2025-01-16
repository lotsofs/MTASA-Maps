function generatePackageCollectionPopupMessage(package)
	local packType = package.packType
	local packName = PACKAGE_TYPES[packType].forwardName
	
	local r = PACKAGE_TYPES[packType].r
	local g = PACKAGE_TYPES[packType].g
	local b = PACKAGE_TYPES[packType].b

	local regionId = package.region
	local region = Regions.instances[regionId]
	local regionName = region.friendlyName or region.id
	
	local totalPacksInRegion = region:countPackagesOfType(packType, false)
	local totalPacksInWorld = Packages:countOfType(packType, false)

	local collectedPacksInRegion = region:countPackagesOfType(packType, true)
	local collectedPacksInWorld = Packages:countOfType(packType, true)

	local str = packName.." Hidden Package collected! \n"
	..collectedPacksInWorld.." out of "..totalPacksInWorld.."\n"
	..collectedPacksInRegion.." out of "..totalPacksInRegion.." in "..regionName
	return str,r,g,b
end

function playApplicableSounds(package)
	playSoundFrontEnd(20)
	local packType = package.packType
	local regionId = package.region
	local region = Regions.instances[regionId]
	local totalPacksInWorld = Packages:countOfType(packType, false)
	local collectedPacksInWorld = Packages:countOfType(packType, true)
	if (totalPacksInWorld == collectedPacksInWorld) then
		setTimer(playJingle, 2000, 1, true)
		return
	end
	local totalPacksInRegion = region:countPackagesOfType(packType, false)
	local collectedPacksInRegion = region:countPackagesOfType(packType, true)
	if (totalPacksInRegion == collectedPacksInRegion) then
		setTimer(playJingle, 2000, 1, false)
	end
end

function playJingle(epic)
	local sfx = playSFX("radio", "Beats", epic and 9 or 8, false)
	setSoundVolume(sfx, 0.7)
end

function spamChatIfAppropriate(package)
	local packType = package.packType
	local totalPacksInWorld = Packages:countOfType(packType, false)
	local collectedPacksInWorld = Packages:countOfType(packType, true)
	local nickname = getPlayerName(localPlayer)
	local hex = PACKAGE_TYPES[packType].hex
	local packName = PACKAGE_TYPES[packType].forwardName
	if (totalPacksInWorld == collectedPacksInWorld) then
		local message = nickname .. "#E7D9B0 has collected all " .. hex .. packName .. "#E7D9B0 Hidden Packages! Well done!"
		triggerServerEvent("onSpamChatReward", resourceRoot, message)
	end
	if (collectedPacksInWorld % 10 == 0) then
		local message = nickname .. "#E7D9B0 has collected " .. collectedPacksInWorld .. " " .. hex .. packName .. "#E7D9B0 Hidden Packages!"
		triggerServerEvent("onSpamChatReward", resourceRoot, message)
	end

	local regionId = package.region
	local region = Regions.instances[regionId]
	local regionName = region.friendlyName
	if (packType == PACKAGE_BLACK_TYPE) then
		regionName = g_currentMapFriendlyName
	end
	local totalPacksInRegion = region:countPackagesOfType(packType, false)
	local collectedPacksInRegion = region:countPackagesOfType(packType, true)
	if (totalPacksInRegion == collectedPacksInRegion) then
		local message = nickname .. "#E7D9B0 has collected every " .. hex .. packName .. "#E7D9B0 Hidden Package in " .. regionName .. "!"
		triggerServerEvent("onSpamChatReward", resourceRoot, message)
	end
end
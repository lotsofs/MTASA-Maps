g_loggedIn = false
g_nonParticipant = false

PACKAGES_TO_SPAWN_PER_TICK = 10
PACKAGE_SPAWN_TICKRATE = 33

packageSpawnTimer = nil
packagesIDsLeftToSpawn = {}

function resourceStarted()
	local allPackages = {}
	populateRegions()
	populateRadarZones()
	for packTypeI, packTypeV in ipairs(PACKAGE_TYPES) do
		local packs = getElementsByType("package" .. packTypeV.typeName, resourceRoot)
		for i, p in ipairs(packs) do
			package = Packages:create(p, packTypeI, i)
			Regions:addPackage(package)
		end
	end
	triggerServerEvent("onClientWantsPackageInfo", localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, resourceStarted)

function onServerSentPackageInfo(collectedPackageData, loggedIn, nonParticipant, mapFileName, mapFriendlyName)
	despawnAllPackages()
	markAllPackagesUncollected()
	g_loggedIn = loggedIn
	if (not loggedIn and nonParticipant) then
		-- hack to allow turning packages back on if they were disabled earlier as guest
		g_nonParticipant = not g_nonParticipant
	else
		g_nonParticipant = nonParticipant
	end
	if (collectedPackageData) then
		for i,v in ipairs(collectedPackageData) do
			local package = Packages.instances[getCompositePackageKey(v.packageType, v.packageNumber)]
			markPackageAsCollected(package)
		end
	end
	if (not g_nonParticipant) then
		preparePackageSpawner()
		changeMapPackages(mapFileName, mapFriendlyName)
	end
	bigTextClear()
	bigTextBuild()
	toggleRegionDisplay()
	checkForResets()
end
addEvent("onServerSentPackageInfo", true)
addEventHandler("onServerSentPackageInfo", root, onServerSentPackageInfo)

function spawnPackageWithBlackCheck(package)
	if (package.packType == PACKAGE_BLACK_TYPE) then
		if (package.region ~= g_currentMapFileName) then
			return
		end
	end
	if (package.collected) then
		package:toggleBlip(g_showBlips)
	else
		package:spawn()
	end
end

function spawnPackageBunch()
	if (g_nonParticipant) then
		abortPackageSpawner()
		return
	end
	local targetI = math.max(1, #packagesIDsLeftToSpawn-PACKAGES_TO_SPAWN_PER_TICK)
	for i = #packagesIDsLeftToSpawn, targetI, -1 do
		local id = packagesIDsLeftToSpawn[i]
		spawnPackageWithBlackCheck(Packages.instances[id])
		packagesIDsLeftToSpawn[i] = nil
	end
	if (#packagesIDsLeftToSpawn == 0) then
		abortPackageSpawner()
	end
end

function preparePackageSpawner()
	for i, p in pairs(Packages.instances) do
		packagesIDsLeftToSpawn[#packagesIDsLeftToSpawn+1] = i
	end
	startPackageSpawner()
end

function startPackageSpawner()
	abortPackageSpawner()
	packageSpawnTimer = setTimer(spawnPackageBunch, PACKAGE_SPAWN_TICKRATE, 0)
end

function abortPackageSpawner()
	if (packageSpawnTimer) then
		killTimer(packageSpawnTimer)
		packageSpawnTimer = nil
	end
end

function markAllPackagesUncollected()
	for i, p in pairs(Packages.instances) do
		p.collected = false
	end
end

function despawnAllPackages()
	packagesIDsLeftToSpawn = {}
	for i, p in pairs(Packages.instances) do
		p:despawn()
		p:hideBlip()
	end
end

function markPackageAsCollected(package)
	package.collected = true
end

function packageCollect(package)
	markPackageAsCollected(package)
	
	package:toggleBlip(g_showBlips)
	package:despawn()
	
	updatePopupText(generatePackageCollectionPopupMessage(package))
	playApplicableSounds(package)
	spamChatIfAppropriate(package)

	local regionId = package.region
	local region = Regions.instances[regionId]
	region:toggleRadarZones(g_showRegions)
	
	updateMiniOverlayText(region)
	updateBigText(package)

	informServerOnPackageCollection(package)
end

function informServerOnPackageCollection(package)
	local vehicleModel = 0
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (vehicle) then
		vehicleModel = getElementModel(vehicle)
	end
	local cp = getElementData(localPlayer, "race.checkpoint")
	triggerServerEvent("onClientCollectedPackage", localPlayer, package.packType, package.packageNumber, vehicleModel, cp)
end
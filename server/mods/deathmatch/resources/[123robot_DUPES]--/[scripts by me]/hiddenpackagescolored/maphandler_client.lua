g_currentMapFileName = nil
g_currentMapFriendlyName = "Current Map"

function changeMapPackages(mapFileName, mapFriendlyName)
	despawnBlackPackagesByMap(g_currentMapFileName)
	g_currentMapFileName = mapFileName
	spawnBlackPackagesByMap(g_currentMapFileName)
	g_currentMapFriendlyName = mapFriendlyName or "Current Map"
	if (g_nonParticipant) then
		return
	end
	updateMiniOverlayText()
end
addEvent("changeMapPackages", true)
addEventHandler("changeMapPackages",root,changeMapPackages)

function spawnBlackPackagesByMap(mapFileName)
	if (not mapFileName) then
		return
	end
	if (not Regions.instances[mapFileName]) then
		-- No packages on this map
		return
	end
	local packages = Regions.instances[mapFileName]:getAllPackages()
	for i,p in pairs(packages) do
		spawnPackageWithBlackCheck(p)
	end
end

function despawnBlackPackagesByMap(mapFileName)
	if (not mapFileName) then
		return
	end
	if (not Regions.instances[mapFileName]) then
		-- No packages on this map
		return
	end
	local packages = Regions.instances[mapFileName]:getAllPackages()
	for i,p in pairs(packages) do
		p:despawn()
		p:hideBlip()
	end
end

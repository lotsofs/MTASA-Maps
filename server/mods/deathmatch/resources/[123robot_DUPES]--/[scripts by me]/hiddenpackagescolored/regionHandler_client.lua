g_showRegions = false
g_currentRegion = nil

g_regionLookupTable = {}

function populateRegions()
	local regions = getElementsByType("region", resourceRoot)
	for i, r in ipairs(regions) do
		Regions:createRegion(r)
	end
	g_currentRegion = Regions:createEmpty()
	g_previousRegion = g_currentRegion
	for i = -3000, 2975, 25 do
		g_regionLookupTable[i] = {}
	end
end

function populateRadarZones()
	local radarZones = getElementsByType("radarZone", resourceRoot)
	for i, rz in ipairs(radarZones) do
		local radarZone = RadarZones:create(rz)
		table.insert(Regions.instances[radarZone.region].radarZones, radarZone)
		for x = radarZone.lowerX, radarZone.upperX-25, 25 do
			for y = radarZone.lowerY, radarZone.upperY-25, 25 do
				g_regionLookupTable[x][y] = Regions.instances[radarZone.region]
			end
		end
	end
end

function toggleRegions()
	if (g_nonParticipant) then
		return
	end
	
	g_showRegions = not g_showRegions
	toggleRegionDisplay()
end
addCommandHandler("toggleradar", toggleRegions, false, false)

function toggleRegionDisplay()
	for i, r in pairs(Regions.instances) do
		r:toggleRadarZones(g_showRegions)
	end
end

function checkCurrentRegion()
	if (g_nonParticipant) then return end
	local x,y,z = getElementPosition(localPlayer)
	x = math.floor(x/25) * 25
	y = math.floor(y/25) * 25
	if (x < -3000 or x >= 3000) then
		return
	end
	local newRegion = g_regionLookupTable[x][y]
	if (not newRegion or newRegion == g_currentRegion) then 
		return 
	end
	g_currentRegion = newRegion
	updateMiniOverlayText(g_currentRegion)
end
addEventHandler("onClientPreRender", root, checkCurrentRegion)

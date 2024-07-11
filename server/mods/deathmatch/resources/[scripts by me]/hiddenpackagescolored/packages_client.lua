-- TODO:
-- prevent helicoptering red packages
-- inflate numbers by including an extra area
-- help.xml
-- account manager
-- bug: joining a game spawns ALL map packages, they only get filtered on next map start

PACKAGE_DATA = { 
	packageNormal = { 		model = 1575, 	r = 255, 	g = 255, 	b = 255, 	a = 32,		name = "White",		hex = "#FFFFFF" },
	packageWater = { 		model = 1579, 	r = 0, 		g = 0, 		b = 255, 	a = 32,		name = "Blue",		hex = "#0000FF"  },
	packageHelicopter = { 	model = 1576, 	r = 255, 	g = 128, 	b = 0, 		a = 32,		name = "Orange",	hex = "#FF7F00"  },
	packageBike = { 		model = 1578, 	r = 0, 		g = 255, 	b = 0, 		a = 32,		name = "Green",		hex = "#00FF00"  },
	packageHard = { 		model = 1577, 	r = 255, 	g = 255, 	b = 0, 		a = 32,		name = "Yellow",	hex = "#FFFF00"  },
	packageExtreme = { 		model = 1580, 	r = 255, 	g = 0, 		b = 0, 		a = 32,		name = "Red",		hex = "#FF0000"  },
	packageCustom = {		model = 1575,	r = 127,	g = 127,	b = 127,	a = 32,		name = "Black",		hex = "#7F7F7F"  }
}

PACKAGE_ELEMENTS = {}
PACKAGE_PICKUPS = {}
PACKAGE_CORONAS = {}
COLLECTED_PACKAGES = {}

PACKAGE_GROUPS = {}

PACKAGES_COLLECTED_BY_MAP = {}

-- get all packages from the map file
function getPackages()
	PACKAGE_GROUPS["packagesNormal"] = getElementsByType("packageNormal", resourceRoot)
	PACKAGE_GROUPS["packagesWater"] = getElementsByType("packageWater", resourceRoot)
	PACKAGE_GROUPS["packagesHelicopter"] = getElementsByType("packageHelicopter", resourceRoot)
	PACKAGE_GROUPS["packagesBike"] = getElementsByType("packageBike", resourceRoot)
	PACKAGE_GROUPS["packagesHard"] = getElementsByType("packageHard", resourceRoot)
	PACKAGE_GROUPS["packagesExtreme"] = getElementsByType("packageExtreme", resourceRoot)
	PACKAGE_GROUPS["packagesCustom"] = getElementsByType("packageCustom", resourceRoot)

	COLLECTED_PACKAGES = getElementData(localPlayer, "coloredPackages.collected") or {}
	-- stuff them into a table for future data lookups
	for i, v in pairs(PACKAGE_GROUPS) do
		for j, w in pairs(v) do
			local typeName = getElementType(w)
			local id = typeName .. j
			PACKAGE_ELEMENTS[id] = w		
		end
	end
end

-- spawn visual representation of packages
function showPackages(packages)
	for i, pack in ipairs(packages) do
		-- get information about package
		local typeName = getElementType(pack)
		local id = typeName .. i

		-- place package if it hasn't been collected already, otherwise mark it as done for the region
		collected = COLLECTED_PACKAGES[id]
		if (not collected or collected == false) then
			local x, y, z = getElementPosition(pack)
			local model = PACKAGE_DATA[typeName].model
			local r = PACKAGE_DATA[typeName].r
			local g = PACKAGE_DATA[typeName].g
			local b = PACKAGE_DATA[typeName].b
			local a = PACKAGE_DATA[typeName].a
			PACKAGE_CORONAS[id] = createMarker(x, y, z + 0.6, "corona", 1, r, g, b, a)
			PACKAGE_PICKUPS[id] = createPickup(x, y, z + 0.5, 3, model)
		else
			local map = getElementData(pack, "mapAssignment")
			if (map) then
				countM = PACKAGES_COLLECTED_BY_MAP[map]
				if (not countM) then
					countM = 0
				end
				countM = countM + 1
				PACKAGES_COLLECTED_BY_MAP[map] = countM
			else
				local region = getElementByID(getElementData(pack, "region"))
				local dataName = "collected_" .. typeName
				count = getElementData(region, dataName)
				if (not count) then
					count = 0
				end
				count = count + 1
				setElementData(region, dataName, count, false)
			end
		end
	end
end

function enablePackages()
	disablePackages() -- delete existing ones first
	for i, v in pairs(PACKAGE_GROUPS) do
		showPackages(v)
	end
end

function enablePackagesIfDisabled()
	if (packagesEnabled) then
		return
	end
	disablePackages() -- delete existing ones first
	for i, v in pairs(PACKAGE_GROUPS) do
		showPackages(v)
	end
	outputChatBox("Hidden Packages Enabled", 13, 206, 49)
	setElementData(localPlayer, "coloredPackages.nonParticipant", false)
end

function togglePackages()
	if (packagesEnabled() == true) then
		outputChatBox("Hidden Packages Disabled", 206, 13, 49)
		disablePackages()
		setElementData(localPlayer, "coloredPackages.nonParticipant", true)
	else
		outputChatBox("Hidden Packages Enabled", 13, 206, 49)
		enablePackages()
		setElementData(localPlayer, "coloredPackages.nonParticipant", false)
	end
end

function disablePackages()
	for i, v in pairs(PACKAGE_PICKUPS) do
		if (v) then
			destroyElement(v)
			PACKAGE_PICKUPS[i] = nil
		end
	end	
	for i, v in pairs(PACKAGE_CORONAS) do
		if (v) then
			destroyElement(v)
			PACKAGE_CORONAS[i] = nil
		end
	end	
end

-- checks if packages are currently shown
function packagesEnabled()
	for i, v in pairs(PACKAGE_PICKUPS) do
		if (v) then
			return true
		end
	end	
	for i, v in pairs(PACKAGE_CORONAS) do
		if (v) then
			return true
		end
	end
	return false
end


-- package blips
-- -------------

PACKAGE_BLIPS = {}

function showBlips(packages)
	for i, pack in ipairs(packages) do
		-- get information about package
		local typeName = getElementType(pack)
		local id = typeName .. i

		-- place blip if it has been collected already
		collected = COLLECTED_PACKAGES[id]
		if (collected) then
			local x, y, z = getElementPosition(pack)
			local r = PACKAGE_DATA[typeName].r
			local g = PACKAGE_DATA[typeName].g
			local b = PACKAGE_DATA[typeName].b
			PACKAGE_BLIPS[id] = createBlip(x, y, z, 0, 2, r, g, b, 255, 0, 350)
		end
	end
end

function disableBlips()
	for i, v in pairs(PACKAGE_BLIPS) do
		if (v) then
			destroyElement(v)
			PACKAGE_BLIPS[i] = nil
		end
	end	
end

function enableBlips()
	disableBlips() -- delete existing ones first
	for i, v in pairs(PACKAGE_GROUPS) do
		showBlips(v)
	end
end

function toggleBlips()
	if (blipsEnabled() == true) then
		disableBlips()
	else
		enablePackagesIfDisabled()
		enableBlips()
	end
end

-- checks if blips are currently shown
function blipsEnabled()
	for i, v in pairs(PACKAGE_BLIPS) do
		if (v) then
			return true
		end
	end	
	return false
end

-- radar zones
-- -----------

RADAR_ZONES = {}
COL_ZONES = {}
ZONE_ELEMENTS = {}

function getRadarZones()
	local radarZones = getElementsByType("radarZone", resourceRoot)
	for i, zone in ipairs(radarZones) do
		local id = getElementID(zone)
		ZONE_ELEMENTS[id] = zone
		createRadarAreaColZone(id, zone)
	end
end

function enableRadarAreas()
	disableRadarAreas() -- delete existing ones first
	local radarZones = getElementsByType("radarZone", resourceRoot)
	for i, zone in ipairs(radarZones) do
		-- get zone information
		local id = getElementID(zone)
		local fromX = getElementData(zone, "originX")
		local fromY = getElementData(zone, "originY")
		local toX = getElementData(zone, "sizeX")
		local toY = getElementData(zone, "sizeY")

		-- get zone region information, collected / total packages
		local region = getElementByID(getElementData(zone, "region"))
		local r, g, b = 0, 0, 0

		local totalNormal = getElementData(region, "total_packageNormal") or 0
		local totalWater = getElementData(region, "total_packageWater") or 0
		local totalHelicopter = getElementData(region, "total_packageHelicopter") or 0
		local totalBike = getElementData(region, "total_packageBike") or 0
		local totalHard = getElementData(region, "total_packageHard") or 0
		local totalExtreme = getElementData(region, "total_packageExtreme") or 0

		-- calculate colors
		local totalRed = totalHard + totalExtreme
		local totalGreen = totalNormal + totalBike
		local totalBlue = totalWater + totalHelicopter

		if (totalRed == 0) then
			r = 255
		else 
			local collectedHard = getElementData(region, "collected_packageHard") or 0
			local collectedExtreme = getElementData(region, "collected_packageExtreme") or 0
			r = (collectedHard + collectedExtreme) / totalRed * 255
		end
		if (totalGreen == 0) then
			g = 255
		else 
			local collectedNormal = getElementData(region, "collected_packageNormal") or 0
			local collectedBike = getElementData(region, "collected_packageBike") or 0
			g = (collectedNormal + collectedBike) / totalGreen * 255
		end
		if (totalBlue == 0) then
			b = 255
		else 
			local collectedWater = getElementData(region, "collected_packageWater") or 0
			local collectedHelicopter = getElementData(region, "collected_packageHelicopter") or 0
			b = (collectedWater + collectedHelicopter) / totalBlue * 255
		end
		-- place the zones
		radarZone = createRadarAreaFromTo(fromX, fromY, toX, toY, r, g, b, 96)
		RADAR_ZONES[id] = radarZone
	end
end

function disableRadarAreas()
	for i, v in pairs(RADAR_ZONES) do
		if (v) then
			destroyElement(v)
			RADAR_ZONES[i] = nil
		end
	end	
end

function toggleRadarAreas()
	-- check if a radar area exists
	if (radarZonesEnabled() == true) then
		disableRadarAreas()
	else
		enablePackagesIfDisabled()
		enableRadarAreas()
	end
end

function createRadarAreaFromTo(minX, minY, maxX, maxY, r, g, b, a, visibleTo)
	local r = r or 255
	local g = g or 0
	local b = b or 0
	local a = a or 255
	local visibleTo = visibleTo or root
	local sizeX = maxX - minX
	local sizeY = maxY - minY
	local radarArea = createRadarArea(minX, minY, sizeX, sizeY, r, g, b, a, visibleTo)
	return radarArea
end

function createRadarAreaColZone(id, zone)
	local fromX = getElementData(zone, "originX")
	local fromY = getElementData(zone, "originY")
	local toX = getElementData(zone, "sizeX")
	local toY = getElementData(zone, "sizeY")
	COL_ZONES[id] = createColRectangleFromTo(fromX, fromY, toX, toY)
	setElementData(COL_ZONES[id], "region", getElementData(zone, "region"))
end

function createColRectangleFromTo(minX, minY, maxX, maxY)
	local sizeX = maxX - minX
	local sizeY = maxY - minY
	local colShape = createColRectangle(minX, minY, sizeX, sizeY)
	return colShape
end

-- checks if radar zones are currently shown
function radarZonesEnabled()
	for i, v in pairs(RADAR_ZONES) do
		if (v) then
			return true
		end
	end
	return false
end

-- events
-- ------

function reloadPackages()
	for i, v in pairs(getElementsByType("region")) do
		if (v) then
			setElementData(v, "collected_packageNormal", 0, false)
			setElementData(v, "collected_packageHard", 0, false)
			setElementData(v, "collected_packageExtreme", 0, false)
			setElementData(v, "collected_packageWater", 0, false)
			setElementData(v, "collected_packageBike", 0, false)
			setElementData(v, "collected_packageHelicopter", 0, false)
		end
	end	
	PACKAGES_COLLECTED_BY_MAP = {}
	
	getPackages()
	getRadarZones()

	if (not getElementData(localPlayer, "coloredPackages.nonParticipant")) then
		enablePackages()
	else
		disablePackages()
	end

	-- redraw zones if needed
	if (radarZonesEnabled()) then
		enableRadarAreas()
	end
	-- redraw blips if needed
	if (blipsEnabled()) then
		enableBlips()
	end
	-- update overlay if needed
	if (SHOW_PACKAGE_COUNTER) then
		setLeftText()
		setRightText()
	end
end

function resetPackages()
	if (getElementData(localPlayer, "coloredPackages.nonParticipant")) then
		outputChatBox("You must enable hidden packages before you can do that.", 49, 206, 13)
		return
	end
	setElementData(localPlayer, "coloredPackages.collected", {}, true)
	outputChatBox("Hidden Packages Reset", 206, 49, 13)
	reloadPackages()
end

function onCollectPackage(packageId)
	-- Remove the package
	if (PACKAGE_CORONAS[packageId]) then
		destroyElement(PACKAGE_CORONAS[packageId])
		PACKAGE_CORONAS[packageId] = nil
	end
	if (PACKAGE_PICKUPS[packageId]) then
		destroyElement(PACKAGE_PICKUPS[packageId])
		PACKAGE_PICKUPS[packageId] = nil			
	end
	-- Update player package info
	COLLECTED_PACKAGES = getElementData(localPlayer, "coloredPackages.collected")
	local map = getElementData(PACKAGE_ELEMENTS[packageId], "mapAssignment")
	if (map) then
		countM = PACKAGES_COLLECTED_BY_MAP[map]
		if (not countM) then
			countM = 0
		end
		countM = countM + 1
		PACKAGES_COLLECTED_BY_MAP[map] = countM
	else
		-- Update the region package count
		local region = getElementByID(getElementData(PACKAGE_ELEMENTS[packageId], "region"))
		local typeName = getElementType(PACKAGE_ELEMENTS[packageId])
		local dataName = "collected_" .. typeName
		count = getElementData(region, dataName)
		if (not count) then
			count = 0
		end
		count = count + 1
		setElementData(region, dataName, count, false)
	end
	LAST_PACKAGE = PACKAGE_ELEMENTS[packageId]
	MIDDLE_TEXT_TIMER = 300
	setMiddleText()
	checkForMilestones()
	-- redraw zones if needed
	if (radarZonesEnabled()) then
		enableRadarAreas()
	end
	-- redraw blips if needed
	if (blipsEnabled()) then
		enableBlips()
	end
	-- update overlay if needed
	if (SHOW_PACKAGE_COUNTER) then
		setLeftText()
		setRightText()
	end
end
addEvent("onCollectPackage", true)
addEventHandler("onCollectPackage", localPlayer, onCollectPackage)

function checkForMilestones()
	if (not LAST_PACKAGE) then
		return
	end
	packType = getElementType(LAST_PACKAGE)
	name = PACKAGE_DATA[packType].name
	hex = PACKAGE_DATA[packType].hex
	
	collected = 0
	total = 0
	for i, v in pairs(PACKAGE_ELEMENTS) do
		type2 = getElementType(v)
		if (type2 == packType) then
			total = total + 1
			if (COLLECTED_PACKAGES[i]) then
				collected = collected + 1
			end
		end			
	end
	subCounter = ""
	if (packType == "packageCustom") then
		subMapCollected = PACKAGES_COLLECTED_BY_MAP[CURRENT_MAPID]
		if (subMapCollected == TOTAL_PACKAGES_THIS_MAP) then
			nickname = getPlayerName(localPlayer)
			message = nickname .. " has collected every " .. hex .. name .. "#E7D9B0 Hidden Package in " .. CURRENT_MAPNAME .. "!"
			triggerServerEvent("onMilestone", resourceRoot, message)
			-- call a spam event
		end
	elseif (CURRENT_REGION) then
		regionName = getElementData(CURRENT_REGION, "friendlyname")
		subCollected = getElementData(CURRENT_REGION, "collected_" .. packType) or 0
		subTotal = getElementData(CURRENT_REGION, "total_" .. packType) or 0
		if (subTotal == subCollected) then
			nickname = getPlayerName(localPlayer)
			message = nickname .. " has collected every " .. hex .. name .. "#E7D9B0 Hidden Package in " .. regionName .. "!"
			triggerServerEvent("onMilestone", resourceRoot, message)
			-- call a spam event
		end
	end
	if (collected % 10 == 0) then
		nickname = getPlayerName(localPlayer)
		message = nickname .. " has collected " .. collected .. " " .. hex .. name .. "#E7D9B0 Hidden Packages!"
		triggerServerEvent("onMilestone", resourceRoot, message)
		-- call a spam event
	end
	if (collected == total) then
		nickname = getPlayerName(localPlayer)
		message = nickname .. " has collected all " .. hex .. name .. "#E7D9B0 Hidden Packages! Well done!"
		triggerServerEvent("onMilestone", resourceRoot, message)
		-- call a spam event
	end
end

function toggleOverlay()
	iprint("[Packages] Toggling UI", CURRENT_MAPID, CURRENT_MAPNAME)
	SHOW_PACKAGE_COUNTER = not SHOW_PACKAGE_COUNTER 
	if (SHOW_PACKAGE_COUNTER) then
		enablePackagesIfDisabled()
		setLeftText()
		setRightText()
	end
end

CURRENT_REGION = nil
SHOW_PACKAGE_COUNTER = false

-- player enters a new region
function onClientColShapeHit(theElement, matchingDimension)
	if (getElementType(theElement) ~= "player") then
		return
	end
	if (theElement ~= localPlayer) then
		return
	end
	name = getElementData(source, "region")
	if (not name) then
		return
	end
	region = getElementByID(name)
	if (not region) then
		return
	end
	CURRENT_REGION = region
	if (SHOW_PACKAGE_COUNTER) then
		setLeftText()
		setRightText()
	end
end
addEventHandler("onClientColShapeHit", resourceRoot, onClientColShapeHit)

RIGHT_TEXT = ""
LEFT_TEXT = ""
MIDDLE_TEXT = ""
MIDDLE_TEXT_TIMER = 0

function setLeftText()
	local totals = { packageNormal = 0; packageBike = 0; packageWater = 0; packageHelicopter = 0; packageHard = 0; packageExtreme = 0; packageCustom = 0}
	local collected = { packageNormal = 0; packageBike = 0; packageWater = 0; packageHelicopter = 0; packageHard = 0; packageExtreme = 0; packageCustom = 0}

	for i, v in pairs(PACKAGE_ELEMENTS) do
		packType = getElementType(v)
		totals[packType] = totals[packType] + 1
		
		if (COLLECTED_PACKAGES[i]) then
			collected[packType] = collected[packType] + 1
		end
	end
	local totalCollected = collected["packageNormal"] + collected["packageBike"] + collected["packageWater"] + collected["packageHelicopter"] + collected["packageHard"] + collected["packageExtreme"] --+ collected["packageCustom"]
	local totalExisting = totals["packageNormal"] + totals["packageBike"] + totals["packageWater"] + totals["packageHelicopter"] + totals["packageHard"] + totals["packageExtreme"] --+ totals["packageCustom"]
	local totalPercentage = math.floor(totalCollected / totalExisting * 100)

	local percentageNormal = math.floor(collected["packageNormal"] / totals["packageNormal"] * 100)
	local percentageBike = math.floor(collected["packageBike"] / totals["packageBike"] * 100)
	local percentageWater = math.floor(collected["packageWater"] / totals["packageWater"] * 100)
	local percentageHelicopter =  math.floor(collected["packageHelicopter"] / totals["packageHelicopter"] * 100)
	local percentageHard =  math.floor(collected["packageHard"] / totals["packageHard"] * 100)
	local percentageExtreme = math.floor(collected["packageExtreme"] / totals["packageExtreme"] * 100)
	local percentageCustom = math.floor(collected["packageCustom"] / totals["packageCustom"] * 100)
	
	LEFT_TEXT = "\nTotal: " .. totalCollected .. "/" .. totalExisting .. " (" .. totalPercentage .. "%)\n"
	LEFT_TEXT = LEFT_TEXT .. "#FFFFFFWhite: " .. collected["packageNormal"] .. "/" .. totals["packageNormal"] .. " (" .. percentageNormal .. "%)\n"
	LEFT_TEXT = LEFT_TEXT .. "#00FF00Green: " .. collected["packageBike"] .. "/" .. totals["packageBike"] .. " (" .. percentageBike .. "%)\n"
	LEFT_TEXT = LEFT_TEXT .. "#007FFFBlue: " .. collected["packageWater"] .. "/" .. totals["packageWater"] .. " (" .. percentageWater .. "%)\n"
	LEFT_TEXT = LEFT_TEXT .. "#FF7F00Orange: " .. collected["packageHelicopter"] .. "/" .. totals["packageHelicopter"] .. " (" .. percentageHelicopter .. "%)\n"
	LEFT_TEXT = LEFT_TEXT .. "#FFFF00Yellow: " .. collected["packageHard"] .. "/" .. totals["packageHard"] .. " (" .. percentageHard .. "%)\n"
	LEFT_TEXT = LEFT_TEXT .. "#FF0000Red: " .. collected["packageExtreme"] .. "/" .. totals["packageExtreme"] .. " (" .. percentageExtreme .. "%)\n"
	LEFT_TEXT = LEFT_TEXT .. "\n#7F7F7FBlack: " .. collected["packageCustom"] .. "/" .. totals["packageCustom"] .. " (" .. percentageCustom .. "%)\n"
	-- LEFT_TEXT = LEFT_TEXT .. "\n\n#7F7F7FBlack: " .. collected["packageCustom"] .. "/" .. totals["packageCustom"] .. " (" .. percentageCustom .. "%)\n"
end

function setRightText()
	iprint("[Packages] UI. Right text changing:", CURRENT_MAPID, CURRENT_MAPNAME, TOTAL_PACKAGES_THIS_MAP, getElementData(CURRENT_REGION, "friendlyname"))
	-- local mapN = "Current Map:\n" .. (CURRENT_MAPNAME or "<unknown>")
	local mapN = CURRENT_MAPNAME or "<unknown map>"
	local suggestedMap = CURRENT_MAPNAME
	local totalSuggested = 0
	local totalShown = TOTAL_PACKAGES_THIS_MAP
	-- if (TOTAL_PACKAGES_THIS_MAP == 0) then
	-- 	local rng = math.random(#PACKAGE_GROUPS["packagesCustom"])
	-- 	local suggestedMap = getElementData(PACKAGE_GROUPS["packagesCustom"][rng], "mapAssignment")
	-- 	mapN = "Map suggestion:\n" .. suggestedMap
	-- 	for i, v in ipairs(PACKAGE_GROUPS["packagesCustom"]) do
	-- 		if getElementData(v, "mapAssignment") == suggestedMap then
	-- 			totalSuggested = totalSuggested + 1
	-- 		end
	-- 	end
	-- 	totalShown = totalSuggested
	-- end

	RIGHT_TEXT = ""
	if (not CURRENT_REGION) then
		RIGHT_TEXT = RIGHT_TEXT .. "Current Region:\n"
		RIGHT_TEXT = RIGHT_TEXT .. "Total: " .. 0 .. "/" .. 0 .. "\n"
		RIGHT_TEXT = RIGHT_TEXT .. "#FFFFFFWhite: " .. 0 .. "/" .. 0 .. "\n"
		RIGHT_TEXT = RIGHT_TEXT .. "#00FF00Green: " .. 0 .. "/" .. 0 .. "\n"
		RIGHT_TEXT = RIGHT_TEXT .. "#007FFFBlue: " .. 0 .. "/" .. 0 .. "\n"
		RIGHT_TEXT = RIGHT_TEXT .. "#FF7F00Orange: " .. 0 .. "/" .. 0 .. "\n"
		RIGHT_TEXT = RIGHT_TEXT .. "#FFFF00Yellow: " .. 0 .. "/" .. 0 .. "\n"
		RIGHT_TEXT = RIGHT_TEXT .. "#FF0000Red: " .. 0 .. "/" .. 0 .. "\n"
	else
		local name = getElementData(CURRENT_REGION, "friendlyname")
		local cNor = getElementData(CURRENT_REGION, "collected_packageNormal") or 0
		local cBik = getElementData(CURRENT_REGION, "collected_packageBike") or 0
		local cHar = getElementData(CURRENT_REGION, "collected_packageHard") or 0
		local cExt = getElementData(CURRENT_REGION, "collected_packageExtreme") or 0
		local cHel = getElementData(CURRENT_REGION, "collected_packageHelicopter") or 0
		local cWat = getElementData(CURRENT_REGION, "collected_packageWater") or 0
		
		local tNor = getElementData(CURRENT_REGION, "total_packageNormal") or 0
		local tBik = getElementData(CURRENT_REGION, "total_packageBike") or 0
		local tHar = getElementData(CURRENT_REGION, "total_packageHard") or 0
		local tExt = getElementData(CURRENT_REGION, "total_packageExtreme") or 0
		local tHel = getElementData(CURRENT_REGION, "total_packageHelicopter") or 0
		local tWat = getElementData(CURRENT_REGION, "total_packageWater") or 0

		local cTot = cNor + cBik + cWat + cHel + cHar + cExt
		local tTot = tNor + tBik + tWat + tHel + tHar + tExt

		local pNor = ((tNor == 0) and "-") or math.floor(cNor / tNor * 100)
		local pBik = ((tBik == 0) and "-") or math.floor(cBik / tBik * 100)
		local pHar = ((tHar == 0) and "-") or math.floor(cHar / tHar * 100)
		local pExt = ((tExt == 0) and "-") or math.floor(cExt / tExt * 100)
		local pHel = ((tHel == 0) and "-") or math.floor(cHel / tHel * 100)
		local pWat = ((tWat == 0) and "-") or math.floor(cWat / tWat * 100)
		local pTot = ((tTot == 0) and "-") or math.floor(cTot / tTot * 100)
		RIGHT_TEXT = RIGHT_TEXT .. name .. ":\n"
		RIGHT_TEXT = RIGHT_TEXT .. "Total: " .. cTot .. "/" .. tTot .. " (" .. pTot .. "%)\n"
		RIGHT_TEXT = RIGHT_TEXT .. "#FFFFFFWhite: " .. cNor .. "/" .. tNor .. " (" .. pNor .. "%)\n"
		RIGHT_TEXT = RIGHT_TEXT .. "#00FF00Green: " .. cBik .. "/" .. tBik .. " (" .. pBik .. "%)\n"
		RIGHT_TEXT = RIGHT_TEXT .. "#007FFFBlue: " .. cWat .. "/" .. tWat .. " (" .. pWat .. "%)\n"
		RIGHT_TEXT = RIGHT_TEXT .. "#FF7F00Orange: " .. cHel .. "/" .. tHel .. " (" .. pHel .. "%)\n"
		RIGHT_TEXT = RIGHT_TEXT .. "#FFFF00Yellow: " .. cHar .. "/" .. tHar .. " (" .. pHar .. "%)\n"
		RIGHT_TEXT = RIGHT_TEXT .. "#FF0000Red: " .. cExt .. "/" .. tExt .. " (" .. pExt .. "%)\n"
	end
	if (mapN) then
		RIGHT_TEXT = RIGHT_TEXT .. "#AFAFAF" .. mapN .. "\n"
	else
		RIGHT_TEXT = RIGHT_TEXT .. "#AFAFAF" .. "\n"
	end
	-- local cCus = PACKAGES_COLLECTED_BY_MAP[suggestedMap] or 0
	-- local tCus = totalShown or 0
	-- local pCus = ((tCus == 0) and "-") or math.floor(cCus / tCus * 100)
	-- RIGHT_TEXT = RIGHT_TEXT .. "#7F7F7FBlack: " .. cCus .. "/" .. tCus .. " (" .. pCus .. "%)\n"
	local cCus = PACKAGES_COLLECTED_BY_MAP[CURRENT_MAPID] or 0
	local tCus = TOTAL_PACKAGES_THIS_MAP or 0
	local pCus = ((tCus == 0) and "-") or math.floor(cCus / tCus * 100)
	RIGHT_TEXT = RIGHT_TEXT .. "#7F7F7FBlack: " .. cCus .. "/" .. tCus .. " (" .. pCus .. "%)\n"
end

LAST_PACKAGE = nil

function setMiddleText()
	if (not LAST_PACKAGE) then
		return
	end
	packType = getElementType(LAST_PACKAGE)
	name = PACKAGE_DATA[packType].name
	
	collected = 0
	total = 0
	for i, v in pairs(PACKAGE_ELEMENTS) do
		type2 = getElementType(v)
		if (type2 == packType) then
			total = total + 1
			if (COLLECTED_PACKAGES[i]) then
				collected = collected + 1
			end
		end			
	end
	subCounter = ""

	if (packType == "packageCustom") then
		subCollected = PACKAGES_COLLECTED_BY_MAP[CURRENT_MAPID]
		subCounter = subCollected .. " out of " .. TOTAL_PACKAGES_THIS_MAP .. " in" .. CURRENT_MAPNAME
	elseif (CURRENT_REGION) then
		regionName = getElementData(CURRENT_REGION, "friendlyname")
		subCollected = getElementData(CURRENT_REGION, "collected_" .. packType) or 0
		subTotal = getElementData(CURRENT_REGION, "total_" .. packType) or 0
		subCounter = subCollected .. " out of " .. subTotal .. " in " .. regionName
	end
	MIDDLE_TEXT = name .. " Hidden Package collected! \n" .. collected .. " out of " .. total .. "\n" .. subCounter
	MIDDLE_R = PACKAGE_DATA[packType].r
	MIDDLE_G = PACKAGE_DATA[packType].g
	MIDDLE_B = PACKAGE_DATA[packType].b
end

function drawPackageCounter()
	if (MIDDLE_TEXT_TIMER > 0) then
		MIDDLE_TEXT_TIMER = MIDDLE_TEXT_TIMER - 1
		local width,height = guiGetScreenSize()
		titleX = width * 0
		titleY = height * 0.3
		titleWidth = width*1
		titleHeight = height*0.9
		titleFont = width / 300
		drawBorderedText( MIDDLE_TEXT, titleFont * 0.5, titleX, titleY, titleWidth, titleHeight, tocolor(MIDDLE_R, MIDDLE_G, MIDDLE_B, 255), titleFont, "default-bold", "center", "top", false, true, false, false)
	end
	if (SHOW_PACKAGE_COUNTER) then
		local width,height = guiGetScreenSize()
		-- box
		boxX = width * 0.045
		boxY = height * 0.455
		boxWidth = width * 0.18
		boxHeight = (height * 0.225)
		dxDrawRectangle(boxX, boxY, boxWidth, boxHeight, tocolor(0, 0, 0, 196), false)
		-- textTitle
		titleX = boxX + width * 0.005
		titleY = boxY + height * 0.005
		titleWidth = width*0.8
		titleHeight = height*0.9
		titleFont = width / 1200
		titleText = "PACKAGES COLLECTED:"
		dxDrawText(titleText, titleX, titleY, titleWidth, titleHeight, tocolor(178, 178, 178, 255), titleFont, "default-bold", "left", "top", false, true, false, false)
		-- textLeftTotal
		leftX = boxX + width * 0.005
		leftY = boxY + height * 0.030
		leftWidth = width*0.8
		leftHeight = height*0.9
		leftFont = width / 1400
		dxDrawText(LEFT_TEXT, leftX, leftY, leftWidth, leftHeight, tocolor(178, 178, 178, 255), leftFont, "default-bold", "left", "top", false, true, false, true)	
		-- textRightTotal
		rightX = boxX + width * 0.005
		rightY = boxY + height * 0.030
		rightWidth = width*0.22
		rightHeight = height*0.9
		rightFont = width / 1400
		dxDrawText(RIGHT_TEXT, rightX, rightY, rightWidth, rightHeight, tocolor(178, 178, 178, 255), rightFont, "default-bold", "right", "top", false, true, false, true)	
	end
end

addEventHandler("onClientRender", root, drawPackageCounter)

function drawBorderedText(text, borderSize, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
	dxDrawText(text2, width+borderSize, height, width2+borderSize, height2, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width, height+borderSize, width2, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width, height-borderSize, width2, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height, width2-borderSize, height2, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width+borderSize, height+borderSize, width2+borderSize, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height-borderSize, width2-borderSize, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width+borderSize, height-borderSize, width2+borderSize, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height+borderSize, width2-borderSize, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
end

function onClientResourceStart(startedResource)
	-- client script has loaded, spawn packages.
	getPackages()
	getRadarZones()

	enablePackages()
	iprint("[Packages] changeMapPackages because onClientResourceStart")
	changeMapPackages(nil, nil)
end
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)

addCommandHandler("toggleradar", toggleRadarAreas, false, false)
addCommandHandler("togglepackages", togglePackages, false, false)
addCommandHandler("toggleblips", toggleBlips, false, false)
addCommandHandler("toggleui", toggleOverlay, false, false)
addCommandHandler("resetpackages", resetPackages, false, false)

addEvent("reloadPackages", true)
addEventHandler("reloadPackages", root, reloadPackages)


-- --------------------
-- Custom packages specific

function changeMapPackages(mapName, mapFriendly) 
	iprint("[Packages] Attempting change map packages")
	if not packagesEnabled() then
		iprint("[Packages] FAILED")
		return
	end
	iprint("[Packages] Changing Map Packages", mapName, mapFriendly)
	CURRENT_MAPID = mapName
	CURRENT_MAPNAME = mapFriendly

	TOTAL_PACKAGES_THIS_MAP = 0
	for i, pack in pairs(PACKAGE_GROUPS["packagesCustom"]) do
		local typeName = getElementType(pack)
		local id = typeName .. i
		
		-- destroy first just to be sure it's generating properly
		if (PACKAGE_CORONAS[id]) then
			destroyElement(PACKAGE_CORONAS[id])
			PACKAGE_CORONAS[id] = nil
		end
		if (PACKAGE_PICKUPS[id]) then
			destroyElement(PACKAGE_PICKUPS[id])
			PACKAGE_PICKUPS[id] = nil
		end
		
		-- get information about package
		local mapAssignment = getElementData(pack, "mapAssignment")
		if (mapName == mapAssignment) then
			TOTAL_PACKAGES_THIS_MAP = TOTAL_PACKAGES_THIS_MAP + 1
			collected = COLLECTED_PACKAGES[id]
			iprint("[Packages] Found a package for this map", mapAssignment, id, collected)
			if (not collected or collected == false) then
				local x, y, z = getElementPosition(pack)
				local model = PACKAGE_DATA[typeName].model
				local r = PACKAGE_DATA[typeName].r
				local g = PACKAGE_DATA[typeName].g
				local b = PACKAGE_DATA[typeName].b
				local a = PACKAGE_DATA[typeName].a

				PACKAGE_CORONAS[id] = createMarker(x, y, z + 0.6, "corona", 1, r, g, b, a)
				PACKAGE_PICKUPS[id] = createObject(model, x, y, z + 0.5)
				setElementInterior(PACKAGE_CORONAS[id], getElementInterior(localPlayer), x, y, z)
				setElementInterior(PACKAGE_PICKUPS[id], getElementInterior(localPlayer), x, y, z)
				setElementCollisionsEnabled(PACKAGE_PICKUPS[id], false)
				moveObject(PACKAGE_PICKUPS[id], 2000*1800, x, y, z, 0, 0, 360*1800) --rotate
			end
		end
	end

	-- update overlay if needed
	if (SHOW_PACKAGE_COUNTER) then
		setLeftText()
		setRightText()
	end
end

addEvent("changeMapPackages", true)
addEventHandler("changeMapPackages", root, changeMapPackages)

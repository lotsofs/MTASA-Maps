-- TODO:
-- prevent helicoptering red packages
-- inflate numbers by including an extra area
-- help.xml
-- account manager

PACKAGE_DATA = { 
	packageNormal = { 		model = 1575, 	r = 255, 	g = 255, 	b = 255, 	a = 32,		name = "#FFFFFFWhite" },
	packageWater = { 		model = 1579, 	r = 0, 		g = 0, 		b = 255, 	a = 32,		name = "#007FFFBlue"  },
	packageHelicopter = { 	model = 1576, 	r = 255, 	g = 128, 	b = 0, 		a = 32,		name = "#FF7F00Orange"  },
	packageBike = { 		model = 1578, 	r = 0, 		g = 255, 	b = 0, 		a = 32,		name = "#00FF00Green"  },
	packageHard = { 		model = 1577, 	r = 255, 	g = 255, 	b = 0, 		a = 32,		name = "#FFFF00Yellow"  },
	packageExtreme = { 		model = 1580, 	r = 255, 	g = 0, 		b = 0, 		a = 32,		name = "#FF0000Red"  }
}

PACKAGE_ELEMENTS = {}
PACKAGE_PICKUPS = {}
PACKAGE_CORONAS = {}
COLLECTED_PACKAGES = {}

PACKAGE_GROUPS = {}

-- get all packages from the map file
function getPackages()
	PACKAGE_GROUPS["packagesNormal"] = getElementsByType("packageNormal", resourceRoot)
	PACKAGE_GROUPS["packagesWater"] = getElementsByType("packageWater", resourceRoot)
	PACKAGE_GROUPS["packagesHelicopter"] = getElementsByType("packageHelicopter", resourceRoot)
	PACKAGE_GROUPS["packagesBike"] = getElementsByType("packageBike", resourceRoot)
	PACKAGE_GROUPS["packagesHard"] = getElementsByType("packageHard", resourceRoot)
	PACKAGE_GROUPS["packagesExtreme"] = getElementsByType("packageExtreme", resourceRoot)

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
			PACKAGE_BLIPS[id] = createBlip(x, y, z, 0, 1, r, g, b, 255, 0, 350)
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
		radarZone = createRadarAreaFromTo(fromX, fromY, toX, toY, r, g, b, 64)
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
	if (not packagesEnabled()) then
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
	type = getElementType(LAST_PACKAGE)
	name = PACKAGE_DATA[type].name
	
	collected = 0
	total = 0
	for i, v in pairs(PACKAGE_ELEMENTS) do
		type2 = getElementType(v)
		if (type2 == type) then
			total = total + 1
			if (COLLECTED_PACKAGES[i]) then
				collected = collected + 1
			end
		end			
	end
	subCounter = ""
	if (CURRENT_REGION) then
		regionName = getElementData(CURRENT_REGION, "friendlyname")
		subCollected = getElementData(CURRENT_REGION, "collected_" .. type) or 0
		subTotal = getElementData(CURRENT_REGION, "total_" .. type) or 0
		if (subTotal == subCollected) then
			nickname = getPlayerName(localPlayer)
			message = nickname .. " has collected every " .. name .. "#E7D9B0 Hidden Package in " .. regionName .. "!"
			triggerServerEvent("onMilestone", resourceRoot, message)
			-- call a spam event
		end
	end
	if (collected % 10 == 0) then
		nickname = getPlayerName(localPlayer)
		message = nickname .. " has collected " .. collected .. " " .. name .. "#E7D9B0 Hidden Packages!"
		triggerServerEvent("onMilestone", resourceRoot, message)
		-- call a spam event
	end
	if (collected == total) then
		nickname = getPlayerName(localPlayer)
		message = nickname .. " has collected all " .. name .. "#E7D9B0 Hidden Packages! Well done!"
		triggerServerEvent("onMilestone", resourceRoot, message)
		-- call a spam event
	end
end


function toggleOverlay()
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
	local totals = { packageNormal = 0; packageBike = 0; packageWater = 0; packageHelicopter = 0; packageHard = 0; packageExtreme = 0}
	local collected = { packageNormal = 0; packageBike = 0; packageWater = 0; packageHelicopter = 0; packageHard = 0; packageExtreme = 0}

	for i, v in pairs(PACKAGE_ELEMENTS) do
		type = getElementType(v)
		totals[type] = totals[type] + 1
		
		if (COLLECTED_PACKAGES[i]) then
			collected[type] = collected[type] + 1
		end
	end
	LEFT_TEXT = "Total:\n"
	LEFT_TEXT = LEFT_TEXT .. "#FFFFFFWhite: " .. collected["packageNormal"] .. "/" .. totals["packageNormal"] .. "\n"
	LEFT_TEXT = LEFT_TEXT .. "#00FF00Green: " .. collected["packageBike"] .. "/" .. totals["packageBike"] .. "\n"
	LEFT_TEXT = LEFT_TEXT .. "#007FFFBlue: " .. collected["packageWater"] .. "/" .. totals["packageWater"] .. "\n"
	LEFT_TEXT = LEFT_TEXT .. "#FF7F00Orange: " .. collected["packageHelicopter"] .. "/" .. totals["packageHelicopter"] .. "\n"
	LEFT_TEXT = LEFT_TEXT .. "#FFFF00Yellow: " .. collected["packageHard"] .. "/" .. totals["packageHard"] .. "\n"
	LEFT_TEXT = LEFT_TEXT .. "#FF0000Red: " .. collected["packageExtreme"] .. "/" .. totals["packageExtreme"] .. "\n"
end

function setRightText()
	if (not CURRENT_REGION) then
		RIGHT_TEXT = ""
		return
	end
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
	RIGHT_TEXT = name .. ":\n"
	RIGHT_TEXT = RIGHT_TEXT .. "#FFFFFFWhite: " .. cNor .. "/" .. tNor .. "\n"
	RIGHT_TEXT = RIGHT_TEXT .. "#00FF00Green: " .. cBik .. "/" .. tBik .. "\n"
	RIGHT_TEXT = RIGHT_TEXT .. "#007FFFBlue: " .. cWat .. "/" .. tWat .. "\n"
	RIGHT_TEXT = RIGHT_TEXT .. "#FF7F00Orange: " .. cHel .. "/" .. tHel .. "\n"
	RIGHT_TEXT = RIGHT_TEXT .. "#FFFF00Yellow: " .. cHar .. "/" .. tHar .. "\n"
	RIGHT_TEXT = RIGHT_TEXT .. "#FF0000Red: " .. cExt .. "/" .. tExt .. "\n"
end

LAST_PACKAGE = nil

function setMiddleText()
	if (not LAST_PACKAGE) then
		return
	end
	type = getElementType(LAST_PACKAGE)
	name = PACKAGE_DATA[type].name
	
	collected = 0
	total = 0
	for i, v in pairs(PACKAGE_ELEMENTS) do
		type2 = getElementType(v)
		if (type2 == type) then
			total = total + 1
			if (COLLECTED_PACKAGES[i]) then
				collected = collected + 1
			end
		end			
	end
	subCounter = ""
	if (CURRENT_REGION) then
		regionName = getElementData(CURRENT_REGION, "friendlyname")
		subCollected = getElementData(CURRENT_REGION, "collected_" .. type) or 0
		subTotal = getElementData(CURRENT_REGION, "total_" .. type) or 0
		subCounter = subCollected .. " out of " .. subTotal .. " in " .. regionName
	end
	MIDDLE_TEXT = name .. " Hidden Package collected! \n" .. collected .. " out of " .. total .. "\n" .. subCounter
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
		drawBorderedText( MIDDLE_TEXT, titleFont * 0.5, titleX, titleY, titleWidth, titleHeight, tocolor(196, 196, 196, 255), titleFont, "default-bold", "center", "top", false, true, false, true)
	end
	if (SHOW_PACKAGE_COUNTER) then
		local width,height = guiGetScreenSize()
		-- box
		boxX = width * 0.055
		boxY = height * 0.455
		boxWidth = width * 0.16
		boxHeight = (boxWidth * 0.6275)
		dxDrawRectangle(boxX, boxY, boxWidth, boxHeight, tocolor(0, 0, 0, 196), false)
		-- textTitle
		titleX = boxX + width * 0.005
		titleY = boxY + height * 0.005
		titleWidth = width*0.8
		titleHeight = height*0.9
		titleFont = width / 1200
		titleText = "PACKAGES COLLECTED:"
		dxDrawText(titleText, titleX, titleY, titleWidth, titleHeight, tocolor(196, 196, 196, 255), titleFont, "default-bold", "left", "top", false, true, false, false)
		-- textLeftTotal
		leftX = boxX + width * 0.005
		leftY = boxY + height * 0.035
		leftWidth = width*0.8
		leftHeight = height*0.9
		leftFont = width / 1400
		dxDrawText(LEFT_TEXT, leftX, leftY, leftWidth, leftHeight, tocolor(196, 196, 196, 255), leftFont, "default-bold", "left", "top", false, true, false, true)	
		-- textRightTotal
		rightX = boxX + width * 0.005
		rightY = boxY + height * 0.035
		rightWidth = width*0.21
		rightHeight = height*0.9
		rightFont = width / 1400
		dxDrawText(RIGHT_TEXT, rightX, rightY, rightWidth, rightHeight, tocolor(196, 196, 196, 255), rightFont, "default-bold", "right", "top", false, true, false, true)	
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
end
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)

addCommandHandler("toggleradar", toggleRadarAreas, false, false)
addCommandHandler("togglepackages", togglePackages, false, false)
addCommandHandler("toggleblips", toggleBlips, false, false)
addCommandHandler("toggleui", toggleOverlay, false, false)
addCommandHandler("resetpackages", resetPackages, false, false)

addEvent("reloadPackages", true)
addEventHandler("reloadPackages", root, reloadPackages)
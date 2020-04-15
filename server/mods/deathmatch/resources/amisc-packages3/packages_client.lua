PACKAGE_DATA = { 
	packageNormal = { 		model = 1575, 	r = 255, 	g = 255, 	b = 255, 	a = 32 },
	packageWater = { 		model = 1579, 	r = 0, 		g = 0, 		b = 255, 	a = 32 },
	packageHelicopter = { 	model = 1576, 	r = 255, 	g = 128, 	b = 0, 		a = 32 },
	packageBike = { 		model = 1578, 	r = 0, 		g = 255, 	b = 0, 		a = 32 },
	packageHard = { 		model = 1577, 	r = 255, 	g = 255, 	b = 0, 		a = 32 },
	packageExtreme = { 		model = 1580, 	r = 255, 	g = 0, 		b = 0, 		a = 32 }
}

PACKAGE_PICKUPS = {}
PACKAGE_CORONAS = {}

-- get all packages from the map file, then spawn them
function getPackages()
	local packagesNormal = getElementsByType("packageNormal", resourceRoot)
	local packagesWater = getElementsByType("packageWater", resourceRoot)
	local packagesHelicopter = getElementsByType("packageHelicopter", resourceRoot)
	local packagesBike = getElementsByType("packageBike", resourceRoot)
	local packagesHard = getElementsByType("packageHard", resourceRoot)
	local packagesExtreme = getElementsByType("packageExtreme", resourceRoot)

	showPackages(packagesNormal)
	showPackages(packagesWater)
	showPackages(packagesHelicopter)
	showPackages(packagesBike)
	showPackages(packagesHard)
	showPackages(packagesExtreme)
end

-- spawn visual representation of packages
function showPackages(packages)
	for i, pack in ipairs(packages) do
		-- get information about package
		local typeName = getElementType(pack)
		local x, y, z = getElementPosition(pack)
		local model = PACKAGE_DATA[typeName].model
		local r = PACKAGE_DATA[typeName].r
		local g = PACKAGE_DATA[typeName].g
		local b = PACKAGE_DATA[typeName].b
		local a = PACKAGE_DATA[typeName].a
		-- see if this package already exists, and if yes, remove it
		if (PACKAGE_CORONAS[model .. i]) then
			destroyElement(PACKAGE_CORONAS[model .. i])
			PACKAGE_CORONAS[model .. i] = nil
		end
		if (PACKAGE_PICKUPS[model .. i]) then
			destroyElement(PACKAGE_PICKUPS[model .. i])
			PACKAGE_PICKUPS[model .. i] = nil			
		end
		-- place package
		PACKAGE_CORONAS[model .. i] = createMarker(x, y, z + 0.6, "corona", 1, r, g, b, a)
		PACKAGE_PICKUPS[model .. i] = createPickup(x, y, z + 0.5, 3, model)
	end
end

RADARZONES = {}

function getRadarZones()
	local radarZones = getElementsByType("radarZone", resourceRoot)
	for i, zone in ipairs(radarZones) do
		-- get zone information
		local id = getElementID(zone)
		local fromX = getElementData(zone, "originX")
		local fromY = getElementData(zone, "originY")
		local toX = getElementData(zone, "sizeX")
		local toY = getElementData(zone, "sizeY")
		-- see if zone already exists, and if yes, remove it
		if (RADARZONES[id]) then
			destroyElement(RADARZONES[id])
			RADARZONES[id] = nil
		end
		-- display zone
		RADARZONES[id] = createRadarAreaFromTo(fromX, fromY, toX, toY, 0, 0, 0, 128)
	end
end

function createRadarAreaFromTo(minX, minY, maxX, maxY, r, g, b, a, visibleTo)
	r = r or 255
	g = g or 0
	b = b or 0
	a = a or 255
	visibleTo = visibleTo or root
	sizeX = maxX - minX
	sizeY = maxY - minY
	radarArea = createRadarArea(minX, minY, sizeX, sizeY, r, g, b, a, visibleTo)
	return radarArea
end

function onClientResourceStart(startedResource)
	-- client script has loaded, spawn packages.
	getPackages()
	-- TODO: Tell server we are ready to receive information
	getRadarZones()
end
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)

-- white + green = green
-- blue + orange = blue
-- yellow + red = red
-- package creation code below
-- ---------------------------

MAP_PACKAGE_COUNT = {}

CUT_PACKAGE_LIST = {
    -- 1: 2024-03-22 Removing too easy black packages after first release feedback
    {"packageCustom1","packageCustom2","packageCustom3","packageCustom6",
    "packageCustom7","packageCustom10","packageCustom12","packageCustom17",
    "packageCustom21","packageCustom44","packageCustom46","packageCustom52",
    "packageCustom54","packageCustom59"},
    -- 2: 2024-03-25 Package that sticked out through the floor and was automatically picked up
    {"packageCustom7"}
    -- 3
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
    -- {} -- DONT FORGET TO PUT TRAILING COMMAS
}

-- get all packages from the map file, then spawn them
function getPackages()
	local packagesNormal = getElementsByType("packageNormal", resourceRoot)
	local packagesWater = getElementsByType("packageWater", resourceRoot)
	local packagesHelicopter = getElementsByType("packageHelicopter", resourceRoot)
	local packagesBike = getElementsByType("packageBike", resourceRoot)
	local packagesHard = getElementsByType("packageHard", resourceRoot)
	local packagesExtreme = getElementsByType("packageExtreme", resourceRoot)
    local packagesCustom = getElementsByType("packageCustom", resourceRoot)

	createPackageHitboxes(packagesNormal)
	createPackageHitboxes(packagesWater)
	createPackageHitboxes(packagesHelicopter)
	createPackageHitboxes(packagesBike)
	createPackageHitboxes(packagesHard)
    createPackageHitboxes(packagesExtreme)
    
    assignPackagesToRegion(packagesNormal)
    assignPackagesToRegion(packagesWater)
    assignPackagesToRegion(packagesHelicopter)
    assignPackagesToRegion(packagesBike)
    assignPackagesToRegion(packagesHard)
    assignPackagesToRegion(packagesExtreme)

    assignPackagesCustom(packagesCustom)
end

PACKAGE_HITBOXES = {}
PACKAGE_ORIGINALS = {}

-- spawn visual representation of packages
function createPackageHitboxes(packages)
	for i, pack in ipairs(packages) do
		-- get information about package
		local typeName = getElementType(pack)
		local x, y, z = getElementPosition(pack)
		-- see if this package already exists, and if yes, remove it
		if (PACKAGE_HITBOXES[typeName .. i]) then
			destroyElement(PACKAGE_HITBOXES[typeName .. i])
			PACKAGE_HITBOXES[typeName .. i] = nil
		end
        -- place package
        PACKAGE_HITBOXES[typeName .. i] = createColTube(x,y,z-1,1.5,4)
        PACKAGE_ORIGINALS[typeName .. i] = pack
        setElementID(PACKAGE_HITBOXES[typeName .. i], typeName .. i)
	end
end

function assignPackagesToRegion(packages)
    for i, pack in ipairs(packages) do
        -- add this package to the radar area region so it can be colored
		local typeName = getElementType(pack)
        local region = getElementByID(getElementData(pack, "region"))
        local dataName = "total_" .. typeName
        count = getElementData(region, dataName)
        if (not count) then
            count = 0
        end
        count = count + 1
        setElementData(region, dataName, count)
    end
end

function assignPackagesCustom(packages)
    for i, pack in ipairs(packages) do
        -- get information about package
		local typeName = getElementType(pack)
		local x, y, z = getElementPosition(pack)
		-- see if this package already exists, and if yes, remove it
		if (PACKAGE_HITBOXES[typeName .. i]) then
			destroyElement(PACKAGE_HITBOXES[typeName .. i])
			PACKAGE_HITBOXES[typeName .. i] = nil
		end        
        -- place package
        PACKAGE_HITBOXES[typeName .. i] = createColTube(x,y,z-1,1.5,4)
        PACKAGE_ORIGINALS[typeName .. i] = pack
        setElementID(PACKAGE_HITBOXES[typeName .. i], typeName .. i)
        -- add this package as a map specific package
        local mapName = getElementData(pack, "mapAssignment")
        local count = MAP_PACKAGE_COUNT[mapName]
        if (not count) then
            count = 0
        end
        setElementData(PACKAGE_HITBOXES[typeName .. i], "map", mapName)
        count = count + 1
        MAP_PACKAGE_COUNT[mapName] = count
    end
end

-- package collection code below
-- -----------------------------

function collectPackage(source, player)
    packageId = getElementID(source)
    
    local playerNonParticipation = getElementData(player, "coloredPackages.nonParticipant")
    if (playerNonParticipation) then
        -- player disabled packages
        return
    end

    local desiredMap = getElementData(source, "map")
    if (desiredMap) then
	    local currentMap = getResourceName(call(getResourceFromName("mapmanager"), "getRunningGamemodeMap"))
        if (currentMap ~= desiredMap) then
            -- map specific package, but we are not on the right map
            return
        end
    end

    local playerAccount = getPlayerAccount(player)
    if (isGuestAccount(playerAccount)) then
        outputChatBox("You need an account to collect hidden packages", player, 149, 113, 206)
        return
    end
    local playerPackageTable = getElementData(player, "coloredPackages.collected")
    if (not playerPackageTable) then
        playerPackageTable = {}
    elseif (playerPackageTable[packageId]) then
        -- player has already collected this package
        return
    end
    local vehicle = getPedOccupiedVehicle(player)
    local model = 0
    if (vehicle) then
        model = getElementModel(vehicle)
    end
    playerPackageTable[packageId] = model
    setElementData(player, "coloredPackages.collected", playerPackageTable)
    triggerClientEvent(player, "onCollectPackage", player, packageId)
end

local function onColShapeHit(hitElement, matchingDimension)
    if (getElementType(hitElement) ~= "player") then
        return
    end
    collectPackage(source, hitElement)
end
addEventHandler("onColShapeHit", resourceRoot, onColShapeHit)

-- other stuff
-- -----------

function onResourceStart(startedResource)
    getPackages()
end
addEventHandler("onResourceStart", resourceRoot, onResourceStart)

function onMilestone(text)
    outputChatBox(text, root, 231, 217, 176, true)
end
addEvent("onMilestone", true)
addEventHandler("onMilestone", resourceRoot, onMilestone)

function onPlayerQuit()
    local playeraccount = getPlayerAccount(source)
    if (playeraccount and not isGuestAccount(playeraccount)) then
        local packages = getElementData(source, "coloredPackages.collected")
        local nonParticipant = getElementData(source, "coloredPackages.nonParticipant")
        local resetHistory = getElementData(source, "coloredPackages.resetHistory")
        local packagesJson = toJSON(packages)
        setAccountData(playeraccount, "coloredPackages.collected", packagesJson)
        setAccountData(playeraccount, "coloredPackages.nonParticipant", nonParticipant)
        setAccountData(playeraccount, "coloredPackages.resetHistory", resetHistory)
    end
end
addEventHandler("onPlayerQuit", root, onPlayerQuit)

function onPlayerLogin(thePreviousAccount, theCurrentAccount)
    if (theCurrentAccount and not isGuestAccount(theCurrentAccount)) then
        local nonParticipant = getAccountData(theCurrentAccount, "coloredPackages.nonParticipant")
        local packagesJson = getAccountData(theCurrentAccount, "coloredPackages.collected")
        local resetHistory = getAccountData(theCurrentAccount, "coloredPackages.resetHistory") or 0
        if (not packagesJson) then
            setElementData(source, "coloredPackages.resetHistory", #CUT_PACKAGE_LIST)
            return
        end
        local packages = fromJSON(packagesJson)
        -- TODO: This reset history is only done upon player login, but should ideally be done on resource start as well
        -- This isn't an issue on robot's server since it never restarts resources while players are there, but if this ever
        -- epxands elsewhere, it needs to be done.
        for i=resetHistory+1,#CUT_PACKAGE_LIST do
            for j, v in ipairs(CUT_PACKAGE_LIST[i]) do
                if (packages[v]) then
                    iprint(theCurrentAccount, v, packages[v], "Cut content. Resetting collection status.")
                    packages[v] = nil
                end
            end
        end
        resetHistory = #CUT_PACKAGE_LIST
        setElementData(source, "coloredPackages.resetHistory", resetHistory)
        setElementData(source, "coloredPackages.nonParticipant", nonParticipant)
        setElementData(source, "coloredPackages.collected", packages)
    end
    triggerClientEvent(source, "reloadPackages", source)
    local currentMap = call(getResourceFromName("mapmanager"), "getRunningGamemodeMap")
    local currentMapFile = getResourceName(currentMap)
    local currentMapName = getResourceInfo(currentMap,"name")
    triggerClientEvent(source, "changeMapPackages", resourceRoot, currentMapFile, currentMapName)
end
addEventHandler("onPlayerLogin", root, onPlayerLogin)

function OnPlayerLogout(thePreviousAccount, theCurrentAccount)
    if (thePreviousAccount) and not isGuestAccount(thePreviousAccount) then
        local packages = getElementData(source, "coloredPackages.collected")
        local nonParticipant = getElementData(source, "coloredPackages.nonParticipant")
        local resetHistory = getElementData(source, "coloredPackages.resetHistory")
        local packagesJson = toJSON(packages)
        setAccountData(thePreviousAccount, "coloredPackages.collected", packagesJson)
        setAccountData(thePreviousAccount, "coloredPackages.nonParticipant", nonParticipant)
        setAccountData(thePreviousAccount, "coloredPackages.resetHistory", resetHistory)
    end
end
addEventHandler("onPlayerLogout", root, OnPlayerLogout)

function OnResourceStop(stoppedResource, wasDeleted)
    for i, v in pairs(getElementsByType("player")) do
        local playeraccount = getPlayerAccount(v)
        if (playeraccount) and not isGuestAccount(playeraccount) then
            local packages = getElementData(v, "coloredPackages.collected")
            local nonParticipant = getElementData(v, "coloredPackages.nonParticipant")
            local resetHistory = getElementData(v, "coloredPackages.resetHistory")
            local packagesJson = toJSON(packages)
            setAccountData(playeraccount, "coloredPackages.collected", packagesJson)
            setAccountData(playeraccount, "coloredPackages.nonParticipant", nonParticipant)
            setAccountData(playeraccount, "coloredPackages.collected", packages)
        end
    end
end
addEventHandler("OnResourceStop", resourceRoot, OnResourceStop)

-- Custom packages related
--------------------------

function OnMapStarting()
    local currentMap = call(getResourceFromName("mapmanager"), "getRunningGamemodeMap")
    local currentMapFile = getResourceName(currentMap)
    local currentMapName = getResourceInfo(currentMap,"name")
    triggerClientEvent(root, "changeMapPackages", resourceRoot, currentMapFile, currentMapName)
end
addEventHandler("onMapStarting",root,OnMapStarting)
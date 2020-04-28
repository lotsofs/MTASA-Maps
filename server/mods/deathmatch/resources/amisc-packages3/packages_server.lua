-- package creation code below
-- ---------------------------

-- get all packages from the map file, then spawn them
function getPackages()
	local packagesNormal = getElementsByType("packageNormal", resourceRoot)
	local packagesWater = getElementsByType("packageWater", resourceRoot)
	local packagesHelicopter = getElementsByType("packageHelicopter", resourceRoot)
	local packagesBike = getElementsByType("packageBike", resourceRoot)
	local packagesHard = getElementsByType("packageHard", resourceRoot)
	local packagesExtreme = getElementsByType("packageExtreme", resourceRoot)

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
        PACKAGE_HITBOXES[typeName .. i] = createColTube(x,y,z,1.5,3)
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

-- package collection code below
-- -----------------------------

function collectPackage(packageId, player)
    local playerNonParticipation = getElementData(player, "coloredPackages.nonParticipant")
    if (playerNonParticipation) then
        -- player disabled packages
        return
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
    local model = getElementModel(vehicle)
    playerPackageTable[packageId] = model
    setElementData(player, "coloredPackages.collected", playerPackageTable)
    triggerClientEvent(player, "onCollectPackage", player, packageId)
end

local function onColShapeHit(hitElement, matchingDimension)
    if (getElementType(hitElement) ~= "player") then
        return
    end
    packageId = getElementID(source)
    collectPackage(packageId, hitElement)
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
        local packagesJson = toJSON(packages)
        setAccountData(playeraccount, "coloredPackages.collected", packagesJson)
        setAccountData(playeraccount, "coloredPackages.nonParticipant", nonParticipant)
    end
end
addEventHandler("onPlayerQuit", root, onPlayerQuit)

function onPlayerLogin(thePreviousAccount, theCurrentAccount)
    if (theCurrentAccount and not isGuestAccount(theCurrentAccount)) then
        local nonParticipant = getAccountData(theCurrentAccount, "coloredPackages.nonParticipant")
        local packagesJson = getAccountData(theCurrentAccount, "coloredPackages.collected")
        local packages = fromJSON(packagesJson)
        setElementData(source, "coloredPackages.nonParticipant", nonParticipant)
        setElementData(source, "coloredPackages.collected", packages)
    end
    triggerClientEvent(source, "reloadPackages", source)
end
addEventHandler("onPlayerLogin", root, onPlayerLogin)

function OnPlayerLogout(thePreviousAccount, theCurrentAccount)
    if (thePreviousAccount) and not isGuestAccount(thePreviousAccount) then
        local packages = getElementData(source, "coloredPackages.collected")
        local nonParticipant = getElementData(source, "coloredPackages.nonParticipant")
        local packagesJson = toJSON(packages)
        setAccountData(thePreviousAccount, "coloredPackages.collected", packagesJson)
        setAccountData(thePreviousAccount, "coloredPackages.nonParticipant", nonParticipant)
    end
end
addEventHandler("OnPlayerLogout", root, OnPlayerLogout)

function OnResourceStop(stoppedResource, wasDeleted)
    for i, v in pairs(getElementsByType("player")) do
        local playeraccount = getPlayerAccount(v)
        if (playeraccount) and not isGuestAccount(playeraccount) then
            local packages = getElementData(v, "coloredPackages.collected")
            local nonParticipant = getElementData(v, "coloredPackages.nonParticipant")
            local packagesJson = toJSON(packages)
            setAccountData(playeraccount, "coloredPackages.collected", packagesJson)
            setAccountData(playeraccount, "coloredPackages.nonParticipant", nonParticipant)
        end
    end
end
addEventHandler("OnResourceStop", resourceRoot, OnResourceStop)

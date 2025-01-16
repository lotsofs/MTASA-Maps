Packages = {}
Packages.__index = Packages
Packages.instances = {}

function Packages:create(package, packType, packageNumber)
	local id = getCompositePackageKey(packType, packageNumber)
	local data = getAllElementData( package )
	Packages.instances[id] = setmetatable(
		{
			id = id,
			packType = packType,
			packageNumber = packageNumber,
			x = data.posX,
			y = data.posY,
			z = data.posZ,
			region = data.region or data.mapAssignment,
			collected = false,
			pickup = nil,
			glow = nil,
			hitbox = nil,
			blip = nil,
		},
		self
	)
	return Packages.instances[id]
end

function Packages:countOfType(packType, collectedOnly)
	local count = 0
	local packKey = getCompositePackageKey(packType, 1)
	while (self.instances[packKey]) do
		if (not collectedOnly or self.instances[packKey].collected) then
			count = count + 1
		end
		packKey = packKey + 1
	end
	return count
end

function Packages:countTotals(collectedOnly)
	local totalCount = 0
	local typeCounts = {}
	for i, _ in ipairs(PACKAGE_TYPES) do
		typeCounts[i] = 0
	end
	for i, p in pairs(self.instances) do
		if (not collectedOnly or p.collected) then
			local packType = p.packType
			typeCounts[packType] = typeCounts[packType] + 1
			totalCount = totalCount + 1
		end
	end
	return totalCount, typeCounts
end

function Packages:getAll(collectedOnly)
	local packages = {}
	for _, p in pairs(self.instances) do
		if (not collectedOnly or p.collected) then
			table.insert(packages, p)
		end
	end
	return packages
end

function Packages:getAllTypeNumberPairs(collectedOnly)
	local packages = {}
	for i, p in pairs(self.instances) do
		if (not collectedOnly or p.collected) then
			table.insert(packages, {p.packType, p.packageNumber})
		end
	end
	return packages
end

function Packages:getAllIds(collectedOnly)
	local packages = {}
	for i, p in pairs(self.instances) do
		if (not collectedOnly or p.collected) then
			table.insert(packages, p.id)
		end
	end
	return packages
end

function Packages:spawn()
	local pickupModel = PACKAGE_TYPES[self.packType].model
	local r = PACKAGE_TYPES[self.packType].r
	local g = PACKAGE_TYPES[self.packType].g
	local b = PACKAGE_TYPES[self.packType].b
	local a = PACKAGE_TYPES[self.packType].a
	local x = self.x
	local y = self.y
	local z = self.z
	if (not self.pickup) then
		if (PACKAGE_TYPES[self.packType].typeName == "Custom") then
			self.pickup = createObject(pickupModel, x, y, z + 0.5)
			setElementInterior(self.pickup, getElementInterior(localPlayer), x, y, z + 0.6)
			setElementInterior(self.pickup, getElementInterior(localPlayer), x, y, z + 0.5)
			setElementCollisionsEnabled(self.pickup, false)
			moveObject(self.pickup, 2000*1800, x, y, z + 0.5, 0, 0, 360*1800)
		else
			self.pickup = createPickup(x, y, z + 0.5, 3, pickupModel)
		end
	end
	if (not self.glow) then
		self.glow = createMarker(x, y, z + 0.6, "corona", 1, r, g, b, a)
	end
	if (not self.hitbox) then
		self.hitbox = createColTube(x,y,z-1,1.5,4)
	end
	addEventHandler("onClientColShapeHit", self.hitbox, 
		function(theElement, matchingDimension)
			self:tryCollect(theElement, matchingDimension, true)
		end
	)
	addEventHandler("onClientMarkerHit", self.glow,
		function(theElement, matchingDimension)
			-- The player is actually physically touching the package. Collect it without checking for LoS.
			-- This only happens if the package is right around a corner, or within a bush or tree.
			self:tryCollect(theElement, matchingDimension, false)
		end
	)
end

function Packages:despawn()
	if (self.glow) then
		destroyElement(self.glow)
		self.glow = nil
	end
	if (self.hitbox) then
		destroyElement(self.hitbox)
		self.hitbox = nil
	end
	if (self.pickup) then
		destroyElement(self.pickup)
		self.pickup = nil
	end
end

function Packages:toggleBlip(enabled)
	if (enabled) then
		self:showBlip()
	else
		self:hideBlip()
	end
end

function Packages:showBlip()
	if (not self.blip) then
		local r = PACKAGE_TYPES[self.packType].r
		local g = PACKAGE_TYPES[self.packType].g
		local b = PACKAGE_TYPES[self.packType].b
		local x = self.x
		local y = self.y
		local z = self.z
		self.blip = createBlip(x,y,z,0,2,r,g,b,255,0,350)
	end
end

function Packages:hideBlip()
	if (self.blip) then
		destroyElement(self.blip)
		self.blip = nil
	end
end

function Packages:tryCollect(theElement, matchingDimension, checkLineOfSight)
	if (theElement ~= localPlayer) then
		-- Only get collected by the player
		return
	end
	if (not matchingDimension) then
		iprint("[Hidden Packages Colored] Incorrect Dimension")
		-- Might as well check for if we're in a different dimension
		return
	end
	local playerX, playerY, playerZ = getElementPosition(localPlayer)
	local lineOfSight = isLineOfSightClear(playerX, playerY, playerZ, self.x, self.y, self.z, true, false, false, true, false, false, false, self.pickup)
	if (checkLineOfSight and not lineOfSight) then
		-- We do not have a straight line from us to the package, meaning we're likely attempting to grab it through a floor or wall or something
		iprint("[Hidden Packages Colored] No LoS on package. Not collecting")
		return
	end
	if (self.collected) then
		-- Prevent double collection
		return
	end
	if (not g_loggedIn) then
		-- Don't let unlogged players collect
        outputChatBox("You need an account to collect hidden packages", 149, 113, 206)
		return
	end
	packageCollect(self)
end
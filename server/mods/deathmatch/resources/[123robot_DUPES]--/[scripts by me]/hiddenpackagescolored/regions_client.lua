Regions = {}
Regions.__index = Regions
Regions.instances = {}

function Regions:createRegion(region)
	local data = getAllElementData( region )
	local id = data.id
	Regions.instances[id] = setmetatable(
		{
			id = id,
			friendlyName = data.friendlyname,
			packageGroups = {},
			radarZones = {},
			r = 0,
			g = 0,
			b = 0,
			a = 96,
		},
		self
	)
	for i,_ in ipairs(PACKAGE_TYPES) do
		Regions.instances[id].packageGroups[i] = {}
	end
	return Regions.instances[id]
end

function Regions:createMap(fileName)
	local id = fileName
	Regions.instances[id] = setmetatable(
		{
			id = id,
			packageGroups = {},
			isMap = true,
		},
		self
	)
	for i,_ in ipairs(PACKAGE_TYPES) do
		Regions.instances[id].packageGroups[i] = {}
	end
	return Regions.instances[id]
end

function Regions:createEmpty()
	local id = 0
	Regions.instances[id] = setmetatable(
		{
			id = id,
			friendlyName = "Current Region",
			packageGroups = {},
		},
		self
	)
	for i,_ in ipairs(PACKAGE_TYPES) do
		Regions.instances[id].packageGroups[i] = {}
	end
	return Regions.instances[id]
end

function Regions:addPackage(package)
	local id = package.region
	local map = self.instances[id]

	if not map then
		map = Regions:createMap(id)
	end
	table.insert(Regions.instances[id].packageGroups[package.packType], package)
end

function Regions:getAllPackages(collectedOnly)
	local packs = {}
	for i,_ in ipairs(PACKAGE_TYPES) do
		for _,p in pairs(self.packageGroups[i]) do
			if (not collectedOnly or p.collected) then
				table.insert(packs, p)
			end
		end
	end
	return packs
end

function Regions:getPackagesInGroup(group)
	local packs = {}
	for _,p in pairs(self.packageGroups[group]) do
		table.insert(packs, p)
	end
	return packs
end

function Regions:calculateRGB()
	local rgbMax = {0,0,0}
	local rgbVal = {0,0,0}
	for i, p in ipairs(self:getAllPackages()) do
		local regionColoring = PACKAGE_TYPES[p.packType].regionColor
		rgbMax[regionColoring] = rgbMax[regionColoring] + 1
		if (p.collected) then
			rgbVal[regionColoring] = rgbVal[regionColoring] + 1
		end
	end
	self.r = rgbVal[1]/rgbMax[1]*255
	self.g = rgbVal[2]/rgbMax[2]*255
	self.b = rgbVal[3]/rgbMax[3]*255
	-- if (math.random(1,10) > 0) then
	-- 	self.r = 255
	-- 	self.b = 233
	-- 	self.g = 255
	-- end
	-- if (math.random(1,10) ~= 10) then
	-- 	self.r = 255
	-- 	self.b = 255
	-- 	self.g = 255
	-- end
	if self.b == 255 and self.r == self.g and self.g == self.b then
		self.a = 127
	else
		self.a = 96
	end
end

function Regions:toggleRadarZones(enabled)
	if (not self.radarZones) then
		return
	end
	self:calculateRGB()
	for i,v in ipairs(self.radarZones) do
		if (enabled) then
			v:hide() -- Destroy zone before creating a new one
			v:show(self.r,self.g,self.b,self.a)
		else
			v:hide()
		end
	end
end

function Regions:countPackagesOfType(packType, collectedOnly)
	if (not collectedOnly) then
		return #self.packageGroups[packType]
	end
	local count = 0
	for _, p in pairs(self.packageGroups[packType]) do
		if (p.collected) then
			count = count + 1
		end
	end
	return count
end

function Regions:countPackages(collectedOnly)
	local totalCount = 0
	local typeCounts = {}
	for i, _ in ipairs(PACKAGE_TYPES) do
		typeCounts[i] = 0
	end
	for i, pg in ipairs(self.packageGroups) do
		local c = self:countPackagesOfType(i, collectedOnly)
		totalCount = totalCount + c
		typeCounts[i] = typeCounts[i] + c
	end
	return totalCount, typeCounts
end

function Regions:getFromName(name)
	local r = self.instances[name]
	if (r) then return r end
	r = self.instances["region ("..name..")"]
	if (not r) then return false end
	return r
end
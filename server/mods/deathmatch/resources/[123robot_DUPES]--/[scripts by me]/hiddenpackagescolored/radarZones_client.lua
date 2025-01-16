RadarZones = {}
RadarZones.__index = RadarZones
RadarZones.instances = {}

function RadarZones:create(radarZone)
	local id = #RadarZones.instances + 1
	local data = getAllElementData(radarZone)

	RadarZones.instances[id] = setmetatable(
		{
			id = id,
			lowerX = data.originX,
			upperX = data.sizeX,
			lowerY = data.originY,
			upperY = data.sizeY,
			region = data.region,
			element = nil,
		},
		self
	)
	return RadarZones.instances[id]
end

function RadarZones:show(r,g,b,a)
	if (not self.element) then
		self.element = createRadarArea(self.lowerX, self.lowerY, self.upperX-self.lowerX, self.upperY-self.lowerY, r, g, b, a)
	end
end

function RadarZones:hide()
	if (self.element) then
		destroyElement(self.element)
		self.element = nil
	end
end
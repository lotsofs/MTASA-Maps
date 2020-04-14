areas = { 
	-- https://ehgames.com/gta/map/jsnhjeiwa0h
	baysideMountainRange = { minX = -3000, minY = 2100, maxX = -2150, maxY = 3000 }, 
	bayside = { minX = -2700, minY = 2200, maxX = -2150, maxY = 2600 },
}

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

function onResourceStart(startedResource)
	outputChatBox("AAA")
	r = 0
	for i, area in pairs(areas) do
		createRadarAreaFromTo(area.minX, area.minY, area.maxX, area.maxY, r, 0, 0, 96)
		r = r + 128
	end
end
addEventHandler("onResourceStart", resourceRoot, onResourceStart)

-- white + green = green
-- blue + orange = blue
-- yellow + red = red
function colorGenerator(thePlayer, seat, jacked)
	colors = {}
	for i = 1, 4, 1 do
		listNumber = {1, 2, 3}
		shuffledNumbers = {}
		for i = #listNumber, 1, -1 do
			randomIndex = math.random(1,i)
			shuffledNumbers[i] = listNumber[randomIndex]
			table.remove(listNumber, randomIndex)
		end
		someColors = {}
		someColors[1] = 255
		someColors[2] = 0
		someColors[3] = math.random(0, 255)
		saturation = math.random(0, 100) / 100
		value = math.random(0, 100) / 100
		for j,w in pairs(shuffledNumbers) do
			c = someColors[w]
			c = c + ((255 - c) * (1 - saturation))
			c = c * value
			c = c - (c % 1)
			colors[j + (i - 1) * 3] = c
		end
	end
	setVehicleColor(source, colors[1], colors[2], colors[3], colors[4], colors[5], colors[6], colors[7], colors[8], colors[9], colors[10], colors[11], colors[12])
	
	--setVehicleColor(vehicle, math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255))
end
addEventHandler("onVehicleEnter", root, colorGenerator)

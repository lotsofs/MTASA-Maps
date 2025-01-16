PACKAGE_BLACK_TYPE = 7
PACKAGE_TYPES = {
	[1] = { 
		forwardName = "White",
		typeName = "Normal", 
		model = 1575,
		r = 255,
		g = 255,
		b = 255,
		a = 32,
		hex = "#FFFFFF",
		regionColor = 2,
		iconWidth = 26,
	},
	[2] = { 
		forwardName = "Green",
		typeName = "Bike", 
		model = 1578,
		r = 0,
		g = 255,
		b = 0,
		a = 32,
		hex = "#00FF00",
		regionColor = 2,
		iconWidth = 25,
	},
	[3] = { 
		forwardName = "Blue",
		typeName = "Water", 
		model = 1579,
		r = 0,
		g = 127,
		b = 255,
		a = 32,
		hex = "#007FFF",
		regionColor = 3,
		iconWidth = 25,
	},
	[4] = { 
		forwardName = "Orange",
		typeName = "Helicopter", 
		model = 1576,
		r = 255,
		g = 127,
		b = 0,
		a = 32,
		hex = "#FF7F00",
		regionColor = 3,
		iconWidth = 25,
	},
	[5] = { 
		forwardName = "Yellow",
		typeName = "Hard", 
		model = 1577,
		r = 255,
		g = 255,
		b = 0,
		a = 32,
		hex = "#FFFF00",
		regionColor = 1,
		iconWidth = 25,
	},
	[6] = { 
		forwardName = "Red",
		typeName = "Extreme", 
		model = 1580,
		r = 255,
		g = 0,
		b = 0,
		a = 32,
		hex = "#FF0000",
		regionColor = 1,
		iconWidth = 26,
	},
	[7] = { 
		forwardName = "Black",
		typeName = "Custom", 
		model = 1575,
		r = 127,
		g = 127,
		b = 127,
		a = 32,
		hex = "#7F7F7F",
		regionColor = 1,
		iconWidth = 26,
	},
}

function unpackCompositePackageKey(key)
	local packType = math.floor(key/10000)
	local packNum = key % 10000
	return packType, packNum
end

function getCompositePackageKey(packType, packageNumber)
	return packType * 10000 + packageNumber
end

function convertResetFormatToCompositePackageKey(str)
	local letter, number_str = str:match("([A-Za-z])([0-9]+)")
	if (not letter or not number_str) then
		return false
	end
	local number = tonumber(number_str)
	if (letter == "W" or letter == "w") then
		return 10000+number
	elseif (letter == "G" or letter == "g") then
		return 20000+number
	elseif (letter == "B" or letter == "b") then
		return 30000+number
	elseif (letter == "O" or letter == "o") then
		return 40000+number
	elseif (letter == "Y" or letter == "y") then
		return 50000+number
	elseif (letter == "R" or letter == "r") then
		return 60000+number
	elseif (letter == "K" or letter == "k") then
		return 70000+number
	else
		return false
	end
end
_bigTexts = {
	{
		blobs = {},
		labels = {},
		text = "",
		labelText = "",
	},
	{
		blobs = {},
		labels = {},
		text = "",
		labelText = "",
	}
}

g_displayText = 1
g_showBigOverlay = false

_handledRegions = {}
_latestHandledRegion = {}

function toggleBigOverlay()
	if (g_nonParticipant) then
		return
	end
	
	g_showBigOverlay = not g_showBigOverlay
	bigTextBuild()
end
addCommandHandler("togglebigui", toggleBigOverlay, false, false)

function drawBigTable(width, height)
	if (not g_showBigOverlay) then
		return
	end
	local width2 = height * (16/9)
	local xOffset = (width - width2) / 2
	xOffset = math.max(xOffset, 0)
	width = math.min(width, height * (16/9))
	local x = width * 0.05
	local y = height * 0.025
	width = width * 0.9
	height = height * 0.95
	local font = (width * 0.9) / 912
	dxDrawRectangle(x + xOffset, y, width, height, tocolor(6, 0, 16, 223), true)
	dxDrawText(_bigTexts[g_displayText].text, x*1.05 + xOffset, y+3, width-x, height-y, tocolor(178, 178, 178, 255), font, "unifont", "left", "top", true, true, true, true)
	dxDrawText(_bigTexts[g_displayText].labelText, x*1.05 + xOffset, y+(font*13)+3, width-x, height-y, tocolor(178, 178, 178, 91), font, "unifont", "left", "top", true, true, true, true)
	dxDrawText(g_displayText .. "\n◀", x * 0.1 + xOffset, height*0.4, width, height, tocolor(24, 0, 64, 255), font*5, "verdana", "left", "top", true, true, true, true)
	dxDrawText("\n▶", width + x * 1.1 + xOffset, height*0.4, width, height, tocolor(24, 0, 64, 255), font*5, "verdana", "left", "top", true, true, true, true)
end

function updateBigText(package)
	if (#_bigTexts[1].blobs == 0) then
		return
	end
	
	local char = "▀"
	if (package.packageNumber == 1) then
		if (package.packType == 1) then 
			char = PACKAGE_TYPES[package.packType].hex..char
		else
			char = "\n\n"..PACKAGE_TYPES[package.packType].hex..char
		end
	elseif (package.packageNumber % 144 == 1) then 
		char = "\n\n"..char 
	end

	_bigTexts[1].blobs[package.packType][package.packageNumber] = char
	_bigTexts[2].blobs[package.packType][package.packageNumber] = char
	
	bigTextConcat()
end

function bigTextConcat()
	_bigTexts[1].text = ""
	_bigTexts[2].text = ""
	_bigTexts[1].labelText = ""
	_bigTexts[2].labelText = ""
	for i, _ in ipairs(PACKAGE_TYPES) do
		local concatBlob1 = table.concat(_bigTexts[1].blobs[i])
		local concatBlob2 = table.concat(_bigTexts[2].blobs[i])
		local concatLabels1 = table.concat(_bigTexts[1].labels[i])
		local concatLabels2 = table.concat(_bigTexts[2].labels[i])
		_bigTexts[1].text = _bigTexts[1].text .. concatBlob1
		_bigTexts[2].text = _bigTexts[2].text .. concatBlob2
		_bigTexts[1].labelText = _bigTexts[1].labelText .. concatLabels1
		_bigTexts[2].labelText = _bigTexts[2].labelText .. concatLabels2
	end
end

function bigTextClear()
	_bigTexts[1].blobs = {}
	_bigTexts[1].labels = {}
	_bigTexts[2].blobs = {}
	_bigTexts[2].labels = {}
end

function bigTextBuild()
	if (not g_showBigOverlay) then
		return
	end
	if (g_nonParticipant) then
		return
	end
	if (not g_loggedIn) then
		return
	end
	if (#_bigTexts[1].blobs > 0) then
		return
	end
	for i, v in ipairs(PACKAGE_TYPES) do
		_bigTexts[1].blobs[i] = {}
		_bigTexts[1].labels[i] = {}
		_bigTexts[2].blobs[i] = {}
		_bigTexts[2].labels[i] = {}
	end
	for _, region in pairs(Regions.instances) do
		for i, _ in pairs(PACKAGE_TYPES) do
			local packages = region:getPackagesInGroup(i)
			setRegionTableLabels(i, packages, region.friendlyName or region.id) 
			for _, p in pairs(packages) do
				local blob = getBlobChar(p)
				_bigTexts[1].blobs[p.packType][p.packageNumber] = blob
				_bigTexts[2].blobs[p.packType][p.packageNumber] = blob
				_bigTexts[2].labels[p.packType][p.packageNumber] = getNumberTableLabel(p)
			end
		end
	end
	bigTextConcat()
end

function getBlobChar(package)
	local char = package.collected and "█" or "▁"
	if (package.packageNumber == 1) then
		if (package.packType == 1) then return PACKAGE_TYPES[package.packType].hex..char end
		return "\n\n"..PACKAGE_TYPES[package.packType].hex..char
	end
	if (package.packageNumber % 144 == 1) then return "\n\n"..char end
	return char
end

function setRegionTableLabels(packType, packages, regionName)
	if (#packages == 0) then
		return
	end
	if (#packages == 1) then
		local onlyPackage = packages[1]
		local ch = "•"
		ch = prependNewLineAndOrHex(ch, onlyPackage.packageNumber, packType)
		_bigTexts[1].labels[packType][onlyPackage.packageNumber] = ch
		return
	end
	local minPack = 99999
	local maxPack = 0
	for _,p in ipairs(packages) do
		if p.packageNumber > maxPack then
			maxPack = p.packageNumber
		end
		if p.packageNumber < minPack then
			minPack = p.packageNumber
		end
	end
	if (maxPack == minPack + #packages - 1) then
		local nameLength = #regionName
		local lastCharPack = minPack + nameLength - 1
		for _,p in ipairs(packages) do
			local packNum = p.packageNumber
			local ch = ""
			if packNum > lastCharPack then
				ch = "˙"
			elseif packNum == maxPack then
				ch = "…"
			else
				local charI = packNum - minPack + 1
				ch = regionName:sub(charI,charI)
			end
			ch = prependNewLineAndOrHex(ch, packNum, packType)
			_bigTexts[1].labels[packType][packNum] = ch
		end
	else
		local nameLength = #regionName
		local lastCharPack = minPack + nameLength - 1
		local excessChars = #packages - nameLength
		local finalPackageNum = 0
		for _,p in ipairs(packages) do
			local packNum = p.packageNumber
			local ch = ""
			if packNum <= lastCharPack then
				local charI = packNum - minPack + 1
				ch = regionName:sub(charI,charI)
				if packNum > finalPackageNum then
					finalPackageNum = packNum
				end
			elseif (p.packageNumber <= lastCharPack + excessChars ) then
				ch = "˙"
			else 
				ch = "*"
			end
			ch = prependNewLineAndOrHex(ch, packNum, packType)
			_bigTexts[1].labels[packType][packNum] = ch
		end
		if (finalPackageNum <= lastCharPack) then
			if finalPackageNum % 144 == 1 then
				_bigTexts[1].labels[packType][finalPackageNum] = "\n\n…"
			else
				_bigTexts[1].labels[packType][finalPackageNum] = "…"
			end
		end
	end

end

function prependNewLineAndOrHex(char, number, packType)
	if number == 1 then
		if (packType > 1) then
			return PACKAGE_TYPES[packType].hex.."\n\n"..char
		else
			return PACKAGE_TYPES[packType].hex..char
		end
	elseif number % 144 == 1 then
		return "\n\n"..char
	end
	return char
end

function getNumberTableLabel(package)
	local number = package.packageNumber
	if (number == 720) then return "↑\n\n" end
	if (number % 144 == 0) then return "˙\n\n" end
	if (number == 1 and package.packType > 1) then return PACKAGE_TYPES[package.packType].hex.."\n\n↑1" end
	if (number == 1) then return PACKAGE_TYPES[package.packType].hex.."↑1" end
	if (number == 2) then return "" end
	if (number < 100) then
		local mod = number % 10
		if (mod == 0) then return "↑"..tostring(number) end
		if (mod <= 2) then return "" end
		return "˙"
	end
	if (number == 430) then return "↑" end
	if (number > 430 and number <= 433) then return "˙" end
	if (number > 720 and number <= 723) then return "˙" end
	if (number < 1000) then
		local mod = number % 10
		if (mod == 0) then return "↑"..tostring(number) end
		if (mod <= 3) then return "" end
		return "˙"
	end
	return "˙"
end

function switchPage(forward)
	if (not g_showBigOverlay) then return end
	g_displayText = math.fmod(g_displayText + #_bigTexts + (forward and 1 or -1), #_bigTexts)
	if (g_displayText == 0) then
		g_displayText = #_bigTexts
	end
end
bindKey("arrow_l", "down", switchPage, false)
bindKey("arrow_r", "down", switchPage, true)
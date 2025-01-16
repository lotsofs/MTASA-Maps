_leftText = "LEFT TEXT"
_rightText = "RIGHT TEXT"

g_showOverlay = false

function toggleMiniOverlay()
	if (g_nonParticipant) then
		return
	end
	
	g_showOverlay = not g_showOverlay
	updateMiniOverlayText()
end
addCommandHandler("toggleui", toggleMiniOverlay, false, false)

function updateMiniOverlayText(region)
	if (not g_showOverlay) then
		return
	end
	
	local totalInWorld, totalPackagesPerType = Packages:countTotals(false)
	totalInWorld = totalInWorld - totalPackagesPerType[PACKAGE_BLACK_TYPE]
	local collectedInWorld, collectedPackagesPerType = Packages:countTotals(true)
	collectedInWorld = collectedInWorld - collectedPackagesPerType[PACKAGE_BLACK_TYPE]
	local percentageInWorld = math.floor(collectedInWorld/totalInWorld*100)
	
	if (not region or region.isMap) then
		region = g_currentRegion
	end
	local regionName = region.friendlyName
	local totalInRegion, totalInRegionPerType = region:countPackages(false)
	local collectedInRegion, collectedInRegionPerType = region:countPackages(true)
	local percentageInRegion = "-"
	if (totalInRegion > 0) then
		percentageInRegion = math.floor(collectedInRegion/totalInRegion*100)
	end

	local map = Regions.instances[g_currentMapFileName]
	if (map) then
		totalInRegionPerType[PACKAGE_BLACK_TYPE] = totalInRegionPerType[PACKAGE_BLACK_TYPE] + map:countPackagesOfType(PACKAGE_BLACK_TYPE, false)
		collectedInRegionPerType[PACKAGE_BLACK_TYPE] = collectedInRegionPerType[PACKAGE_BLACK_TYPE] + map:countPackagesOfType(PACKAGE_BLACK_TYPE, true)
	end
	
	local strL = "\nTotal: "..collectedInWorld.."/"..totalInWorld.." ("..percentageInWorld.."%)\n"
	local strR = region.friendlyName..":\nTotal: "..collectedInRegion.."/"..totalInRegion.." ("..percentageInRegion.."%)\n"
	for i,_ in ipairs(PACKAGE_TYPES) do
		local hex = PACKAGE_TYPES[i].hex
		local name = PACKAGE_TYPES[i].forwardName
		local percentageWorld = "-"
		if (totalPackagesPerType[i] > 0) then
			percentageWorld = math.floor(collectedPackagesPerType[i]/totalPackagesPerType[i]*100)
		end
		local percentageRegion = "-"
		if (totalInRegionPerType[i] > 0) then
			percentageRegion = math.floor(collectedInRegionPerType[i]/totalInRegionPerType[i]*100)
		end
		if (i == PACKAGE_BLACK_TYPE) then
			strL = strL .. "\n"
			strR = strR .. "#AFAFAF" .. g_currentMapFriendlyName .. ":\n"
		end
		strL = strL..hex..name..": "..collectedPackagesPerType[i].."/"..totalPackagesPerType[i].." ("..percentageWorld.."%)\n"
		strR = strR..hex..name..": "..collectedInRegionPerType[i].."/"..totalInRegionPerType[i].." ("..percentageRegion.."%)\n"
	end
	_leftText = strL
	_rightText = strR

	local totalRegion = 0
end

function drawMiniOverlay(sWidth, height)
	if (not g_showOverlay) then
		return
	end
	local width = height * (16/9) --math.max(sWidth, height * (16/9))
	-- box
	local boxX = width * 0.045
	local boxY = height * 0.455
	local boxWidth = width * 0.16
	local boxHeight = height * 0.2
	dxDrawRectangle(boxX, boxY, boxWidth, boxHeight, tocolor(12, 0, 12, 196), false)
	-- title
	local titleX = boxX + width * 0.005
	local titleY = boxY + height * 0.005
	local titleWidth = width
	local titleHeight = height
	local titleFont = boxHeight * 0.0086
	local titleText = "PACKAGES COLLECTED:"
	dxDrawText(titleText, titleX, titleY, titleWidth, titleHeight, tocolor(178, 178, 178, 255), titleFont, "default-bold", "left", "top", true, true, false, false)
	-- leftText
	local leftX = boxX + width * 0.005
	local leftY = boxY + height * 0.03
	local leftWidth = boxWidth
	local leftHeight = boxHeight
	local leftFont = boxHeight * 0.00555
	dxDrawText(_leftText, leftX, leftY, leftWidth, leftHeight, tocolor(178, 178, 178, 255), leftFont, "default-bold", "left", "top", true, true, false, true)
	-- rightText
	local rightX = width * 0.5 --boxX + width * 0.005
	local rightY = boxY + height * 0.030
	local rightWidth = width*0.202
	local rightHeight = height
	local rightFont = leftFont
	dxDrawText(_rightText, rightX, rightY, rightWidth, rightHeight, tocolor(178, 178, 178, 255), rightFont, "default-bold", "right", "top", true, true, false, true)
end
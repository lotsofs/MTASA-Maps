-- function startGame(res)
-- 	if (res ~= getThisResource()) then return end
-- 	local onmission = getElementData(source, "asp-onmission")
-- 	local yes = triggerClientEvent(source, "onMissionToggle", source, onmission)
-- end

-- addEventHandler( "onPlayerResourceStart", root, startGame)

MARKERS = {}

function setMarkerVisibility(marker, player)
	local conditionsMet = checkConditions(player, marker)
	setElementVisibleTo(marker, player, conditionsMet)
end

function toggleMissionMarkers(player, enabled)
	for _, m in pairs(MARKERS) do
		if (enabled) then
			setMarkerVisibility(m, player)
		else
			setElementVisibleTo(m, player, false)
		end
	end
end

function enableFreeroam()
	setElementData(source, "rsp-onmission", false)
	toggleMissionMarkers(source, true)
end
addEvent("onEnableFreeroam", true)
addEventHandler("onEnableFreeroam", root, enableFreeroam)

function initialize()
	local markerTemplates = getElementsByType("markertemplate")
	for _, m in ipairs(markerTemplates) do
		local x = getElementData(m, "posX")
		local y = getElementData(m, "posY")
		local z = getElementData(m, "posZ") - 1
		local col = getElementData(m, "color")
		local r,g,b,a = getColorFromString(col)
		local size = getElementData(m, "size")
		local markerType = getElementData(m, "type")
		local markerId = "marker_" .. getElementID(m)
		MARKERS[markerId] = createMarker(x, y, z, markerType, size, r, g, b, a, resourceRoot)
		for i, d in pairs(getAllElementData(m)) do
			-- Copy data from the template over to the actual marker
			setElementData(MARKERS[markerId], i, d)
		end
		for _, p in ipairs(getElementsByType("player")) do
			setMarkerVisibility(MARKERS[markerId], p)
		end
	end
end
addEventHandler( "onResourceStart", resourceRoot, initialize)

function handleMarkerHit(hitElement, matchingDimension)
	if (getElementType(hitElement) ~= "player") then return end
	local conditionsMet = checkConditions(hitElement, source)
	if (conditionsMet) then
		toggleFreeroam(hitElement, false)
		triggerEvent("onStartMissionRequested", root, getElementData(source, "starts"), hitElement) 
	end
end
addEventHandler( "onMarkerHit", resourceRoot, handleMarkerHit)

-- -------------------
-- Conditions Check --
-- -------------------

function checkRequirement(thePlayer, req, positive)
	if not req then return true end
	local reqMet = getElementData(thePlayer, "rsp-completed-"..req)
	-- iprint(req,"=",reqMet,"needs to be",positive,":",reqMet == positive)
	return reqMet == positive
end

function checkConditions(player, marker)
	return 
		checkRequirement(player, getElementData(marker, "positiveRequirement1"), true) and
		checkRequirement(player, getElementData(marker, "positiveRequirement2"), true) and
		checkRequirement(player, getElementData(marker, "positiveRequirement3"), true) and
		checkRequirement(player, getElementData(marker, "negativeRequirement1"), false) and
		checkRequirement(player, getElementData(marker, "negativeRequirement2"), false) and
		checkRequirement(player, getElementData(marker, "negativeRequirement3"), false) and
		getElementData(player, "rsp-onmission") == false
end
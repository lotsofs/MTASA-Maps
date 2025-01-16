g_currentMapFileName = nil
g_currentMapFriendlyName = nil

function updateMapInformation()
	local currentMap = call(getResourceFromName("mapmanager"), "getRunningGamemodeMap")
    g_currentMapFileName = getResourceName(currentMap)
    g_currentMapFriendlyName = getResourceInfo(currentMap,"name")
end

function pushMapInformationToClient()
	updateMapInformation()
	triggerClientEvent(root, "changeMapPackages", resourceRoot, g_currentMapFileName, g_currentMapFriendlyName)
end

addEventHandler("onMapStarting", root, pushMapInformationToClient)
addEventHandler("onResourceStart", resourceRoot, updateMapInformation)
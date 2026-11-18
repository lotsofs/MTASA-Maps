-- FILE: customMapEditorScriptingExtension_s.lua
-- PURPOSE: Handle remove world objects (if present) and add lod models for custom objects (if enabled)
-- VERSION: 16/February/2025 , custom edit by LotsOfS

local resourceName = getResourceName(resource)

-- Makes removeWorldObject map entries and LODs work
local function onResourceStartOrStop(startedResource)
	local startEvent = eventName == "onResourceStart"
	local removeObjects = getElementsByType("removeWorldObject", source)

	for removeID = 1, #removeObjects do
		local objectElement = removeObjects[removeID]
		local objectModel = getElementData(objectElement, "model")
		local objectLODModel = getElementData(objectElement, "lodModel")
		local posX = getElementData(objectElement, "posX")
		local posY = getElementData(objectElement, "posY")
		local posZ = getElementData(objectElement, "posZ")
		local objectInterior = getElementData(objectElement, "interior") or 0
		local objectRadius = getElementData(objectElement, "radius")

		if startEvent then
			removeWorldModel(objectModel, objectRadius, posX, posY, posZ, objectInterior)
			removeWorldModel(objectLODModel, objectRadius, posX, posY, posZ, objectInterior)
		else
			restoreWorldModel(objectModel, objectRadius, posX, posY, posZ, objectInterior)
			restoreWorldModel(objectLODModel, objectRadius, posX, posY, posZ, objectInterior)
		end
	end

	if startEvent then
		local useLODs = get(resourceName..".useLODs")

		if useLODs then
			local objectsTable = getElementsByType("object", source)

			for objectID = 1, #objectsTable do
				local objectElement = objectsTable[objectID]
				local objectModel = getElementModel(objectElement)
				local lodModel = LOD_MAP[objectModel]

				if lodModel then
					local objectX, objectY, objectZ = getElementPosition(objectElement)
					local objectRX, objectRY, objectRZ = getElementRotation(objectElement)
					local objectInterior = getElementInterior(objectElement)
					local objectDimension = getElementDimension(objectElement)
					local objectAlpha = getElementAlpha(objectElement)
					local objectScale = getObjectScale(objectElement)
					
					local lodObject = createObject(lodModel, objectX, objectY, objectZ, objectRX, objectRY, objectRZ, true)
					
					if (lodObject) then
						setElementInterior(lodObject, objectInterior)
						setElementDimension(lodObject, objectDimension)
						setElementAlpha(lodObject, objectAlpha)
						setObjectScale(lodObject, objectScale)

						setElementParent(lodObject, objectElement)
						setLowLODElement(objectElement, lodObject)
					else
						iprint("[MapEditorScriptingExtension] failed to create lodObject " .. lodModel .. " for objectModel " .. objectModel)
					end	
				end
			end
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, onResourceStartOrStop, false)
addEventHandler("onResourceStop", resourceRoot, onResourceStartOrStop, false)

-- MTA LOD Table [object] = [lodmodel] 
LOD_MAP = {
	[3175] = 3347, -- sm_airstrm_med_ => lod_airstrm_med_ (countn2)
	[3244] = 3338, -- pylon_big1_ => pylon_lodbig1_ (countn2)
	[4585] = 4626, -- towerlan2 => lodtowerlan (LAn2)
	[8210] = 8272, -- vgsselecfence12 => lodselecfence12 (vegasS)
	[3269] = 3369, -- bonyrd_block1_ => lod_bnyd_blk1_ (countn2)
	[3615] = 3778, -- sanmonbhut1_law2 => lodmonbhut1_lax01 (LAw2)
	[1267] = 1261, -- billbd2 => lodlbd2 (LAe)
	[3426] = 3428, -- nt_noddonkbase => oilplodbitbase (countn2)
}
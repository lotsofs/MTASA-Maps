-- FILE: newMapEditorScriptingExtension_s.lua
-- PURPOSE: Prevent the map editor feature set being limited by what MTA can load from a map file by adding a script file to maps
-- VERSION: 11/October/2024
-- IMPORTANT: Check the resource 'editor_main' at https://github.com/mtasa-resources/ for updates

local resourceName = getResourceName(resource)
local usedLODModels = {}
local LOD_MAP_NEW = {}

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
				local lodModel = LOD_MAP_NEW[objectModel]

				if lodModel then
					local objectX, objectY, objectZ = getElementPosition(objectElement)
					local objectRX, objectRY, objectRZ = getElementRotation(objectElement)
					local objectInterior = getElementInterior(objectElement)
					local objectDimension = getElementDimension(objectElement)
					local objectAlpha = getElementAlpha(objectElement)
					local objectScale = getObjectScale(objectElement)
					
					local lodObject = createObject(lodModel, objectX, objectY, objectZ, objectRX, objectRY, objectRZ, true)
					
					setElementInterior(lodObject, objectInterior)
					setElementDimension(lodObject, objectDimension)
					setElementAlpha(lodObject, objectAlpha)
					setObjectScale(lodObject, objectScale)

					setElementParent(lodObject, objectElement)
					setLowLODElement(objectElement, lodObject)

					usedLODModels[lodModel] = true
				end
			end
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, onResourceStartOrStop, false)
addEventHandler("onResourceStop", resourceRoot, onResourceStartOrStop, false)

-- MTA LOD Table [object] = [lodmodel] 
LOD_MAP_NEW = {[6917] = 7180, [4569] = 4627, [9584] = 9620, [9585] = 9619, [4016] = 4026, [3445] = 3546, [5017] = 4969, [7240] = 7241, [3446] = 3547, [17538] = 17932,
[16327] = 16596, [4019] = 4025, [6928] = 6936, [8333] = 8280, [3449] = 3535, [6930] = 6938, [791] = 785, [3704] = 3705, [4141] = 4181, [6364] = 6365,
[7191] = 7195, [4718] = 4719, [16358] = 16688, [8148] = 8273, [17098] = 17376, [8489] = 8700, [16326] = 16595, [7392] = 7342, [16118] = 16717, [3776] = 3777,
[16480] = 16482, [17511] = 17512, [10789] = 11281, [8504] = 8926, [4602] = 4580, [4603] = 4581, [12953] = 13255, [9907] = 9935, [3620] = 3746, [4857] = 4979,
[4002] = 4024, [4550] = 4561, [5180] = 5206, [12931] = 13048, [10425] = 9278, [8947] = 8958, [5183] = 5205, [6962] = 7131, [7344] = 7345, [12847] = 13224,
[10308] = 10157, [16385] = 16617, [7347] = 7346, [10948] = 11021, [8409] = 8415, [5126] = 5304, [10063] = 10059, [12859] = 13193, [12861] = 13195, [8657] = 8997,
[10196] = 10239, [8201] = 8239, [3989] = 4137, [4570] = 4578, [10412] = 10521, [10954] = 11049, [9824] = 9826, [4564] = 4579, [9735] = 9802, [4013] = 4065,
[17131] = 17411, [16613] = 16614, [7488] = 7705, [3444] = 3537}
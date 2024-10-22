function changeDistance()
	for i,object in pairs(getElementsByType("object")) do
        if isElement(object) then
            local elementID = getElementModel(object)
			if elementID == 16614 then
				local x, y, z = getElementPosition(object)
				local a, b, c = getElementRotation(object)
				createObject(16615, x, y, z, a, b, c, true)
			end
        end
    end
	engineSetModelLODDistance(16615, 1000)
end
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),changeDistance)
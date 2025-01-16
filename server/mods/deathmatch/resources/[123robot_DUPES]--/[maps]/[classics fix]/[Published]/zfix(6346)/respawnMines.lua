local object

addEventHandler("onClientObjectBreak", resourceRoot, 
    function()
        -- Because this sometimes gets called multiple times at once for some reason
        if (object == source) then
            return
        end
        object = source

        newMine = createObject(getElementModel(source), getElementPosition(source)) 
        setElementID(newMine, getElementID(source))
    end
)
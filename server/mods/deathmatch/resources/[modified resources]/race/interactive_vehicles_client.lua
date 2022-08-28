addEventHandler( "onClientElementStreamIn", root,
    function ( )
        if getElementType( source ) == "vehicle" and getElementData(source, "raceiv.interactable") then
            triggerServerEvent("onClientStreamInVehicle", resourceRoot, source)
        end
    end
);
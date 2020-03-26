RAMPS_RAISED = false

function raiseRamps()
	if (RAMPS_RAISED) then
		return
	end
	RAMPS_RAISED = true
	soloRamps = getElementsByType("soloassistant")
	for i, v in ipairs(soloRamps) do
		x,y,z = getElementPosition(v)
		xr = getElementData(v, "rotX")
		yr = getElementData(v, "rotY")
		zr = getElementData(v, "rotZ")
		model = getElementData(v, "model")
		ramp = createObject(model,x,y,z - 30,xr,yr,zr)
		moveObject(ramp, 10000, x, y, z)
	end
end
addEvent("raiseRamps", true)
addEventHandler("raiseRamps", getRootElement(), raiseRamps)
--addCommandHandler("raiseSoloRamps", raiseRamps)

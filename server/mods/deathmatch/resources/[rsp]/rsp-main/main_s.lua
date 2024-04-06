ACTIVEMISSIONS = {}

function startResourceCustom(resName)
	local resource = getResourceFromName(resName)
	local started = startResource(resource)
	if (not started) then
		iprint("Resource ", resource, "not started. Its type is ",getResourceInfo(resource,"type"))
		error("See iprint above")
	end
end

function startGame(res)
	iprint(res, getThisResource())
	
	if (res == getThisResource()) then
		for i,p in ipairs(getElementsByType("player")) do
			setElementData(p, "rsp-completed-riot", true)
			setElementData(p, "rsp-completed-losdesperados", false)
			setElementData(p, "rsp-onmission", false)
		end
		startResourceCustom("rsp-om0")
	end
end
addEventHandler( "onResourceStart", resourceRoot, startGame)

function startMission(mission, player)
	if not ACTIVEMISSIONS[mission] then
		startResourceCustom("rsp-"..mission)
		ACTIVEMISSIONS[mission] = {}
	end
	table.insert(ACTIVEMISSIONS[mission], player)
end
addEvent( "onStartMissionRequested", true)
addEventHandler("onStartMissionRequested", root, startMission)
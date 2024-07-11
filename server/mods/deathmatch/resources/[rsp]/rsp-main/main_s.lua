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
			setElementData(p, "rsp-completion", 0)
		end
		startResourceCustom("rsp-om0")
	elseif (getResourceName(res):find("^rsp-")) then
		-- local missionName = string.sub(getResourceName(res), 5)
		-- iprint(missionName)
		-- iprint(ACTIVEMISSIONS[missionName])
		-- for _, p in pairs(ACTIVEMISSIONS[missionName]) do
		-- 	triggerClientEvent(p, "AnEvent", root, "WHOOOOO")
		-- 	iprint("SUc")
		-- end
	end
end
addEventHandler( "onResourceStart", root, startGame)

function startMission(mission, player)
	setElementData(player, "rsp-onmission", mission)
	local resState = getResourceState(getResourceFromName("rsp-"..mission))
	if (resState == "loaded") then
		startResourceCustom("rsp-"..mission)
	elseif (resState ~= "running") then
		-- something is wrong with the resource
		-- idk what to do here yet
	else
		triggerClientEvent(player, "onClientMissionStarted", root, mission)
	end
end
addEvent( "onStartMissionRequested", true)
addEventHandler("onStartMissionRequested", root, startMission)

gateHelperReunion = "_GATE_HELPER_REUNION"			-- editor id for the first gate
gateFinishLine = "_GATE_FINISH_LINE"				-- editor id for the second gate

soloRamps = {"_ASSISTANT01","_ASSISTANT02","_ASSISTANT03","_ASSISTANT04","_ASSISTANT05","_ASSISTANT06","_ASSISTANT07","_ASSISTANT08","_ASSISTANT09"}		-- editor id for solo assistant ramps



gate1Opened = false
gate2Opened = false
rampsRaised = false

--- collisions setting
function setCollisionsAllHub()
	setCollisionsAll()	-- set the collisions
	setTimer(setCollisionsAll, 2067, 1)	-- set them again after 2 seconds, because respawn times. There seems to be no onRespawn event, so jury rigged it with a timer.
end

function setCollisionsAll()
	-- set every vehicle non-collidable with one another
	local cars = getElementsByType("vehicle")
	for i,v in pairs(cars) do
		for j, w in pairs(cars) do
			setElementCollidableWith(v,w,false)
		end
	end
	-- set my team's vehicles collidable with one another
	local car = getPedOccupiedVehicle(localPlayer)
	local team = getPlayerTeam(localPlayer)

	local teamPlayers = getPlayersInTeam(team)	
	local teamCars = {}
	for i,v in pairs(teamPlayers) do
		teamCars[i] = getPedOccupiedVehicle(v)
	end
	for i,v in pairs(teamCars) do
		for j, w in pairs(teamCars) do
			setElementCollidableWith(v,w,true)
		end
	end
end

function setCollisionsSpecificHub(withPlayer)
	setCollisionsSpecific(withPlayer)	-- set the collisions
	setTimer(setCollisionsSpecific, 2067, 1, withPlayer)	-- set them again after 2 seconds, because respawn times. There seems to be no onRespawn event, so jury rigged it with a timer.
end

function setCollisionsSpecific(withPlayer)	
	local withCar = getPedOccupiedVehicle(withPlayer)
	-- set collisions to false with eveyrone
	local cars = getElementsByType("vehicle")
	for i,v in pairs(cars) do
		setElementCollidableWith(v,withCar,false)
	end

	teamWith = getPlayerTeam(withPlayer)
	team = getPlayerTeam(localPlayer)
	if (team == teamWith) then
		-- set collisions to false if teammates
		for i,v in pairs(getPlayersInTeam(team)) do
			local car = getPedOccupiedVehicle(v)
			setElementCollidableWith(car,withCar,true)
		end
	end
end

function openFirstGate()
	if (gate1Opened) then
		return
	end
	gate1Opened = true
	local gate = getElementByID(gateHelperReunion)
	local x,y,z = getElementPosition(gate)
	moveObject(gate, 1500, x, y, z, 0, 70, 0)
end

function openSecondGate()
	if (gate2Opened) then
		return
	end
	gate2Opened = true
	local gate = getElementByID(gateFinishLine)
	local x,y,z = getElementPosition(gate)
	moveObject(gate, 1500, x, y, z, 0, 70, 0)
end

function raiseRamps()
	if (rampsRaised) then
		return
	end
	rampsRaised = true
	for i,v in pairs(soloRamps) do
		local ramp = getElementByID(v)
		local x,y,z = getElementPosition(ramp)
		moveObject(ramp, 10000, x, y, z + 30)
	end
end

addEvent("setCollisionsAll", true)
addEvent("setCollisionsSpecific", true)
addEvent("openFirstGate", true)
addEvent("openSecondGate", true)
addEvent("raiseRamps", true)
addEventHandler("setCollisionsAll", getRootElement(), setCollisionsAllHub)
addEventHandler("setCollisionsSpecific", getRootElement(), setCollisionsSpecificHub)
addEventHandler("openFirstGate", getRootElement(), openFirstGate)
addEventHandler("openSecondGate", getRootElement(), openSecondGate)
addEventHandler("raiseRamps", getRootElement(), raiseRamps)



-- hud
-- ---
-- ---

markerInformation = ""
teamInformation = "\n\n\n\n\n\n\nLoading Scoreboard"
announcementInformation = ""
objectiveInformation = ""

function drawHud()
	local width,height = guiGetScreenSize()
	dxDrawText(announcementInformation, width*0.2, height*0.2, width*0.8, height*0.9, tocolor(184, 196, 204,255), 3, "default", "center", "top", false, true, false, true)
	dxDrawText(markerInformation, width*0.2, height*0.5, width*0.8, height*0.9, tocolor(184, 196, 204,255), 3, "default", "center", "top", false, true)
	dxDrawText(teamInformation, width*0.2, height*0.03, width*0.87, height*0.9, tocolor(184, 196, 204,255), 1.5, "default", "right", "top", false, true, false, true)
	dxDrawText(objectiveInformation, width*0.2, height*0.8, width*0.8, height*0.95, tocolor(184, 196, 204, 255), 2, "default", "center", "bottom", false, true, false, true)
end

function setMarkerInformation(text)
	markerInformation = text
end

function setTeamInformation(teamData)
	local text = ""
	for i,v in pairs(teamData) do
		text = text .. v.hex .. v.name .. ": " .. v.collectedCheckpoints .. "/" .. v.targetCheckpoints .. " (" .. v.finishedRiders .. "/" .. v.riderRequirement .. "/" .. v.activeMembers .. ")\n"
	end
	teamInformation = text
end

function setAnnouncementInformation(text, teamData)
	if (text) then
	announcementInformation = text
	else
		local team = teamData[getPlayerTeam(localPlayer)]
		local message = "Welcome to the Verona Pier Teamwork!\n\nYour team is: " .. team.hex .. team.name .."\n#B8C4CCYour objective: Have " .. team.hex .. team.riderRequirement .. "#B8C4CC players complete the course.\n\nTeam members:\n" .. team.hex
		local players = getPlayersInTeam(getPlayerTeam(localPlayer))
		for i,v in pairs(players) do
			message = message .. getPlayerName(v) .. team.hex .. "\n"
		end
		announcementInformation = message
	end
end

function setObjectiveInformation(text, teamData)
	local team = teamData[getPlayerTeam(localPlayer)]
	local message = ""
	if (text == "1") then
		message = "Objective: Have " .. team.hex .. team.riderRequirement .. " #B8C4CCteam members complete the course (out of " .. team.hex .. team.activeMembers .. "#B8C4CC active members). Current: " .. team.hex .. team.finishedRiders
	elseif (text == "2") then
		message = "To win, all " .. team.hex .. team.activeMembers .. " #B8C4CCactive team members must finish the race together. Currently ready: " .. team.hex .. team.finishedRiders
	else
		message = text
	end
	objectiveInformation = message
end

addEvent("setMarkerInformation", true)
addEvent("setTeamInformation", true)
addEvent("setAnnouncementInformation", true)
addEvent("setObjectiveInformation", true)

addEventHandler("setMarkerInformation", getRootElement(), setMarkerInformation)
addEventHandler("setTeamInformation", getRootElement(), setTeamInformation)
addEventHandler("setAnnouncementInformation", getRootElement(), setAnnouncementInformation)
addEventHandler("setObjectiveInformation", getRootElement(), setObjectiveInformation)

addEventHandler("onClientRender", root, drawHud)




-- debug
-- addCommandHandler("openGate1", openFirstGate)
-- addCommandHandler("openGate2", openSecondGate)
-- addCommandHandler("raiseSoloRamps", raiseRamps)

gateHelperReunion = "_GATE_HELPER_REUNION"			-- editor id for the first gate
gateFinishLine = "_GATE_FINISH_LINE"				-- editor id for the second gate

gate1Opened = false
gate2Opened = false

-- COLLISIONS NEW
-- --------------
-- --------------
function setCollisionsNew(theKey, oldValue, newValue)
	if (theKey ~= "race.collideothers" or new == 0) then
		return
	end
	if (not getVehicleOccupant(source)) then
		return
	end
	team1 = getPlayerTeam(getVehicleOccupant(source))
	team2 = getPlayerTeam(localPlayer)
	if (team1 ~= team2) then
		setElementData(source, "race.collideothers", 0, false)
	end
end
addEventHandler("onClientElementDataChange", root, setCollisionsNew)


function setCollisionsNewAll()
	for i, v in pairs(getElementsByType("player")) do
		vehicle = getPedOccupiedVehicle(v)
		setElementData(vehicle, "race.collideothers", 1, false)
	end
end
addEvent("setCollisionsNewAll", true)
addEventHandler("setCollisionsNewAll", getRootElement(), setCollisionsNewAll)

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

addEvent("openFirstGate", true)
addEvent("openSecondGate", true)
addEventHandler("openFirstGate", getRootElement(), openFirstGate)
addEventHandler("openSecondGate", getRootElement(), openSecondGate)

-- hud
-- ---
-- ---

markerInformation = ""
teamInformation = "\n\n\n\n\n\n\nLoading Scoreboard"
announcementInformation = ""
objectiveInformation = ""

function drawHud()
	local width,height = guiGetScreenSize()

	drawBorderedText(announcementInformation, 2, width*0.2, height*0.2, width*0.8, height*0.9, tocolor(184, 196, 204,255), 3, "default", "center", "top", false, true, false, true)
	drawBorderedText(markerInformation, 2, width*0.2, height*0.5, width*0.8, height*0.9, tocolor(184, 196, 204,255), 3, "default", "center", "top", false, true)
	drawBorderedText(teamInformation, 1, width*0.2, height*0.03, width*0.87, height*0.9, tocolor(184, 196, 204,255), 1.5, "default", "right", "top", false, true, false, true)
	drawBorderedText(objectiveInformation, 2, width*0.2, height*0.8, width*0.8, height*0.95, tocolor(184, 196, 204, 255), 2, "default", "center", "bottom", false, true, false, true)
	
	-- dxDrawText(markerInformation, width*0.2, height*0.5, width*0.8, height*0.9, tocolor(184, 196, 204,255), 3, "default", "center", "top", false, true)
	-- dxDrawText(teamInformation, width*0.2, height*0.03, width*0.87, height*0.9, tocolor(184, 196, 204,255), 1.5, "default", "right", "top", false, true, false, true)
	-- dxDrawText(objectiveInformation, width*0.2, height*0.8, width*0.8, height*0.95, tocolor(184, 196, 204, 255), 2, "default", "center", "bottom", false, true, false, true)
end

function drawBorderedText(text, borderSize, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
	dxDrawText(text2, width+borderSize, height, width2+borderSize, height2, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width, height+borderSize, width2, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width, height-borderSize, width2, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height, width2-borderSize, height2, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width+borderSize, height+borderSize, width2+borderSize, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height-borderSize, width2-borderSize, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width+borderSize, height-borderSize, width2+borderSize, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width-borderSize, height+borderSize, width2-borderSize, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
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
		local message = "Welcome to the Verona Pier Teamwork!\n\nYour team is: " .. team.hex .. team.name .."\n#B8C4CCYour objective: Have " .. team.hex .. team.riderRequirement .. "#B8C4CC players complete the course.\n\n\n\n\n\nTeam members:\n" .. team.hex
		local players = getPlayersInTeam(getPlayerTeam(localPlayer))
		for i,v in pairs(players) do
			message = message .. team.hex .. getPlayerName(v) .. "#B8C4CC"
			if (i < #players) then
				message = message .. ", "
			end
			if (i % 6 == 0) then
				message = message .. "\n"
			end
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

-- TODO
-- ----
-- ----

-- DONE - left in an outputChatBox, oops
-- DONE - move the first gate to be more visible
-- DONE - speed bumps
-- Perhaps be a bit more in your face with the announcements still. Same with people quiting/idling.
-- Players collide for a frame upon changing vehicle
-- DONE - Players REALLY like to not kill themselves when they suicide. Can I do something against this?
-- Im not a big fan of that pipe blocking part of the end course track. Perhaps alter it slightly.
-- DONE - Trigger the 'team has won' message when rider requirement amount of people finish, as opposed to 1 or all.
-- DONE - If there's teams of 3 and 4, ensure at least 2 helpers, really unfair otherwise.
-- DONE - Add repairs at bottom to prevent chain explosions
-- DONE - Add second place notifications
-- DONE - Something about outlines, josh
-- Make the end gate double, in case someone glitches past
-- DONE - Add a check maybe for if ja rider falls off the track --> Z-coordinate below 13 , Y-coordinate between -1832 & -2016, X coordinate between 817 and 855
-- Double check for join/leave errors
-- triggerEvent('onPlayerReachCheckpointInternal', player, 1)
-- DONE - course abandoned triggers whe nreversing before firsty ankee
-- DONE - course abandoned triggers on home stretch
-- DONE - course abandoned should be removed on death
-- ped doesn't die
-- DONE - tutorial is messed up






-- Constants / Variables -- These values can be easily changed
-- ---------------------
-- ---------------------
MAIN_COURSE_CHECKPOINTS = 20								-- this is the amount of checkpoints on the main course. Enough people acquiring this amount will trigger checkpoints being rewarded to helpers and allowing the team to finish the race
PLAY_AREA = createColRectangle(806,-2098,110,318)			-- bounding rectangle of the play area. Players leaving this area will be flagged as wanderers. 

HELPER_AREA = createColCuboid(817, -2016, 8, 38, 172, 5.5)	-- if riders enter this area, they will get a prompt to respawn (eg. they fell off the track or wandered out of a shared area)

MARKER_TEAM_CONFIG = "_MARKER_TEAM_CONFIG"					-- the marker for changing teams, name in editor. Make sure it matches, make sure it exists.
MARKER_FIRST_GATE = "_MARKER_FIRST_GATE"					-- marker in front of first gate, name in editor, informing pass throughers and forcing checkpoint catchup
MARKER_SECOND_GATE = "_MARKER_SECOND_GATE"					-- marker in front of second gate, name in editor, informing to wait for the rest of your team

-- camera used for the initial cutscene
CAMERA_POSITION_X = 847.4
CAMERA_POSITION_Y = -1776.3
CAMERA_POSITION_Z = 17.6
CAMERA_TARGET_X = 853.9
CAMERA_TARGET_Y = -1797.2
CAMERA_TARGET_Z = 17.2

POSSIBLE_TEAMS = {											-- possible team names & base colors. This list will be shuffled.
	{"Spume",255,255,255,"#FFFFFF"}, --white
	{"Team Deep Sea",0,0,0,"#000000"}, -- black
	{"Lobster",255,0,0,"#FF0000"}, -- red
	{"Team Algae",0,255,0,"#00FF00"}, -- green
	{"Team Daytime Sky",0,0,255,"#0000FF"}, -- blue
	{"Shallow Waters",0,255,255,"#00FFFF"}, -- cyan
	{"Team Pearl",255,0,255,"#FF00FF"}, -- magenta
	{"The Sand",255,255,0,"#FFFF00"} -- yellow
}

----------------------------------------------------------------------- friendly section ends here. --------------------------------------------

TEAM_ODDS = {{1000,1000,1000,1000,1000,1000,1000,1000},
{1000,1000,1000,1000,1000,1000,1000,1000},
{1000,1000,1000,1000,1000,1000,1000,1000},
{500,1000,1000,1000,1000,1000,1000,1000},
{500,1000,1000,1000,1000,1000,1000,1000},
{250,750,1000,1000,1000,1000,1000,1000},
{250,750,1000,1000,1000,1000,1000,1000},
{166,666,832,1000,1000,1000,1000,1000},
{166,332,832,1000,1000,1000,1000,1000},
{125,500,625,750,1000,1000,1000,1000},
{125,375,625,875,1000,1000,1000,1000},
{100,333,566,799,899,1000,1000,1000},
{100,300,500,700,900,1000,1000,1000},
{83,516,616,716,816,916,1000,1000},
{83,166,457,540,831,914,1000,1000},
{71,356,427,712,783,854,925,1000},
{71,142,299,456,613,770,927,1000},
{62,124,436,498,560,872,934,1000},
{62,124,286,448,610,772,934,1000},
{55,110,165,498,831,886,941,1000},
{55,110,443,498,553,608,941,1000},
{50,100,270,440,610,780,950,1000},
{50,100,270,440,610,780,950,1000},
{45,90,294,498,543,747,792,1000},
{45,90,135,180,861,906,951,1000},
{41,82,123,298,473,648,823,1000},
{41,82,123,298,473,648,823,1000},
{38,76,114,498,536,574,958,1000},
{38,76,114,291,468,645,822,1000},
{35,70,105,140,534,928,963,1000},
{35,70,105,319,533,747,961,1000},
{33,66,99,499,532,565,598,1000},
{33,66,99,132,348,564,780,1000},
{31,62,93,124,342,560,778,1000},
{31,62,93,124,530,561,967,1000},
{29,58,87,116,177,876,937,1000},
{29,58,87,116,336,556,776,1000},
{27,54,81,108,330,552,774,1000},
{27,54,81,108,330,552,774,1000},
{26,52,78,104,840,892,944,1000},
{26,52,78,104,130,419,708,1000},
{25,50,75,100,125,525,925,1000},
{25,50,75,100,125,416,707,1000},
{23,46,69,92,115,409,703,1000},
{23,46,69,92,115,409,703,1000},
{22,44,66,88,110,406,702,1000},
{22,44,66,88,110,406,702,1000},
{21,42,63,84,105,487,614,1000},
{21,42,63,84,105,126,889,1000},
{20,40,60,80,100,120,558,1000},
{20,40,60,80,100,120,558,1000},
{20,40,60,80,100,120,560,1000},
{20,40,60,80,100,120,560,1000},
{19,38,57,76,95,114,556,1000},
{19,38,57,76,95,114,556,1000},
{18,36,54,72,90,108,552,1000},
{18,36,54,72,90,108,126,1000},
{17,34,51,68,85,102,119,1000},
{17,34,51,68,85,102,119,1000},
{17,34,51,68,85,102,119,1000},
{17,34,51,68,85,102,119,1000},
{16,32,48,64,80,96,112,1000},
{16,32,48,64,80,96,112,1000},
{16,32,48,64,80,96,112,1000}}

TEAM_COUNT = -1
TEAMS = {}
TEAM_DATA = {}
PLAYER_DATA = {}
GOAL = -1
TEAMS_FINISHED = 0
WIN_MESSAGE = ""

addEvent("onRaceStateChanging", true)

-- Team assignment at start of map
-- -------------------------------
-- -------------------------------

function start()
	for i = 1, 3, 1 do
		car = getElementByID("_TUTORIAL_VEHICLE_" .. i)
		setElementFrozen(car, true)
		setElementAlpha(car, 0)
	end
	
	shuffleTeams()
	assignTeams()
	for i,v in pairs(getElementsByType("player")) do
		initPlayer(v)
	end
end

function shuffleTeams()
	-- shuffle the team list
	local shuffledTeams = {}
	for i = 8, 1, -1 do
		local pickedTeamIndex = math.random(1,i)
		shuffledTeams[i] = POSSIBLE_TEAMS[pickedTeamIndex]
		table.remove(POSSIBLE_TEAMS, pickedTeamIndex)
	end
	POSSIBLE_TEAMS = shuffledTeams	
end

function initTeam(team, data)
	TEAM_DATA[team] = {}
	TEAM_DATA[team]["name"] = data[1]
	TEAM_DATA[team]["r"] = data[2]
	TEAM_DATA[team]["g"] = data[3]
	TEAM_DATA[team]["b"] = data[4]
	TEAM_DATA[team]["hex"] = data[5]
	TEAM_DATA[team]["compensation"] = 0
	TEAM_DATA[team]["quiters"] = 0
	TEAM_DATA[team]["activeMembers"] = 0
	TEAM_DATA[team]["riderRequirement"] = 0
	TEAM_DATA[team]["raceFinished"] = false
	TEAM_DATA[team]["racersFinished"] = 0
	TEAM_DATA[team]["collectedCheckpoints"] = 0
	TEAM_DATA[team]["finishedRiders"] = 0
	TEAM_DATA[team]["targetCheckpoints"] = 0
	TEAM_DATA[team]["wasted"] = true
end

function assignTeams()
	-- determine how many teams to create based on player count and some degree of randomness
	local randomInt = math.random(1000)
	for i = 1,8,1 do
		if (randomInt <= TEAM_ODDS[getPlayerCount()][i]) then
			-- create i teams
			TEAM_COUNT = i
			break
		end
	end	
	
	-- create teams using the list we just shuffled to determine which themes to create
	for i = 1, TEAM_COUNT, 1 do
		TEAMS[i] = createTeam(POSSIBLE_TEAMS[i][1],POSSIBLE_TEAMS[i][2],POSSIBLE_TEAMS[i][3],POSSIBLE_TEAMS[i][4])
		initTeam(TEAMS[i], POSSIBLE_TEAMS[i])
	end
		
	-- take each player and shuffle them too
	local players = getElementsByType("player")
	local shuffledPlayers = {}
	for i = #players, 1, -1 do
		local pickedPlayerIndex = math.random(1,i)
		shuffledPlayers[i] = players[pickedPlayerIndex]
		table.remove(players, pickedPlayerIndex)
	end
	
	-- then add them to the teams
	for i,v in pairs(shuffledPlayers) do
		setPlayerTeam(v, TEAMS[i % TEAM_COUNT + 1])	
	end
	
	determineGoal()
end

addEventHandler("onMapStarting", root, start) 

function initPlayer(player)
	PLAYER_DATA[player] = {}
	PLAYER_DATA[player]["checkpointsReached"] = 0
	PLAYER_DATA[player]["state"] = "running"
		-- nonparticipant
		-- running
		-- riderarrived
		-- helpercatchingup
		-- atendgate
		-- advantagecompensated
		-- homestretch
		-- racefinished
	PLAYER_DATA[player]["formerState"] = "running"
	PLAYER_DATA[player]["wanderTime"] = 0
	PLAYER_DATA[player]["blip"] = createBlipAttachedTo(player, 0, 1, 184, 196, 204)
end

function determineGoal()
	uneven = false
	local lowest = 65
	for i,v in pairs(TEAMS) do
		local TEAM_COUNT = countPlayersInTeam(TEAMS[i])
		if (TEAM_COUNT < lowest) then
			if (lowest <= 64) then
				uneven = true
				-- teams are uneven, make sure that the smaller team gets at least two helpers
			end
			lowest = TEAM_COUNT
		end
	end
	local maxBound = lowest - 1
	if (uneven) then
		maxBound = math.max(maxBound - 1, 1)
	end
	if (maxBound <= 0) then
		-- we have a team of 1 players, move the player to a different team, or check if the player is the only player
		if (#getElementsByType("player") > 1) then
			outputChatBox("ERROR: A team was generated with 1 player in it. This shouldn't happen.", playerSource, 255, 127, 0)
		end
		GOAL = 1
	else
		-- generate three random numbers, and pick whichever is closest to 55% of players.
		for i = 1,3,1 do
			proposedGoal = math.random(1, maxBound)
			if (math.abs(proposedGoal - (lowest * 0.55)) < math.abs(GOAL - (lowest * 0.55))) then
				GOAL = proposedGoal
			end
		end
	end
end

function ValidateTeamLineups()
	-- check for campers, idlers, wanderers, etc
	for i,v in pairs(getElementsByType("player")) do
		local x,y,z = getElementPosition(v)
		if (PLAYER_DATA[v].state == "racefinished") then
			-- do nothing
		elseif (PLAYER_DATA[v].state ~= "nonparticipant") then
			if (getPlayerIdleTime(v) > 60000) then
				for j,w in pairs(getPlayersInTeam(getPlayerTeam(v))) do
					outputChatBox("Your teammate " .. TEAM_DATA[getPlayerTeam(v)].hex .. getPlayerName(v) .. " #B8C4CCis idle. Adjusting objective.", w, 184, 196, 204, true)
				end
				-- player has gone idle, boot from team
				PLAYER_DATA[v].formerState = PLAYER_DATA[v].state
				PLAYER_DATA[v].state = "nonparticipant"
			elseif (z > 30000) then
				-- player has gone into spectate mode, boot from team
				for j,w in pairs(getPlayersInTeam(getPlayerTeam(v))) do
					if (w ~= v) then
						outputChatBox("Your teammate " .. TEAM_DATA[getPlayerTeam(v)].hex .. getPlayerName(v) .. " #B8C4CChas started spectating. Adjusting objective.", w, 184, 196, 204, true)
					end
				end
				PLAYER_DATA[v].formerState = PLAYER_DATA[v].state
				PLAYER_DATA[v].state = "nonparticipant"
			elseif (not isElementWithinColShape(v, PLAY_AREA)) then
				PLAYER_DATA[v].wanderTime = PLAYER_DATA[v].wanderTime + 1
				if (PLAYER_DATA[v].wanderTime == 2) then
					outputChatBox("If you go off to wander, you'll be letting your " .. TEAM_DATA[getPlayerTeam(v)].hex .. "team #B8C4CCdown.", v, 184, 196, 204, true)
				end
				if (PLAYER_DATA[v].wanderTime >= 3) then
					-- player has gone wandering off, boot from team
					for j,w in pairs(getPlayersInTeam(getPlayerTeam(v))) do
						if (w ~= v) then
							outputChatBox("Your teammate " .. TEAM_DATA[getPlayerTeam(v)].hex .. getPlayerName(v) .. " #B8C4CChas gone off wandering. Adjusting objective.", w, 184, 196, 204, true)
						end
					end
					PLAYER_DATA[v].formerState = PLAYER_DATA[v].state
					PLAYER_DATA[v].state = "nonparticipant"
				end
			end
		else 
			if (getPlayerIdleTime(v) < 10000 and z < 10000 and isElementWithinColShape(v, PLAY_AREA)) then
				-- put player back in play
				for j,w in pairs(getPlayersInTeam(getPlayerTeam(v))) do
					outputChatBox(TEAM_DATA[getPlayerTeam(v)].hex .. getPlayerName(v) .. " #B8C4CChas returned. Adjusting objective.", w, 184, 196, 204, true)
				end
				PLAYER_DATA[v].state = PLAYER_DATA[v].formerState
			end
		end
	end
	-- check for stage completion, in case this slipped by the checkpoint triggers
	for i,v in pairs(TEAMS) do
		teamCheckStageOne(v)
		teamCheckStageTwo(v)
	end
	local countPlayers = 0
	for i = 1, TEAM_COUNT, 1 do
		countPlayers = countPlayers + countPlayersInTeam(TEAMS[i])
	end
	if (countPlayers == 1) then
		-- raise ramps for that one player
		for i = 1, TEAM_COUNT, 1 do
			for i,v in pairs(getPlayersInTeam(TEAMS[i])) do
				triggerClientEvent(v, "raiseRamps", getRootElement())
			end
		end
	else
		-- move lone player to another team
		for i = 1, TEAM_COUNT, 1 do
			if (countPlayersInTeam(TEAMS[i]) == 1) then
				AutoBalance(getPlayersInTeam(TEAMS[i])[1])
			end
		end
	end
	updateHudInfo()
end
addEventHandler("onColShapeLeave", PLAY_AREA, function(player)
	if (getElementType(player) == "player") then
		PLAYER_DATA[player].wanderTime = PLAYER_DATA[player].wanderTime + 1
	end
end)
addEventHandler("onColShapeHit", PLAY_AREA, function(player)
	if (getElementType(player) == "player") then
		PLAYER_DATA[player].wanderTime = 0
	end
end)

function AutoBalance(player)
	local lowestTeam = 0
	local selectedTeam = 0
	for i = 1, TEAM_COUNT, 1 do
		local playersInTeam = countPlayersInTeam(TEAMS[i])
		if (playersInTeam > lowestTeam) then
			selectedTeam = i
			lowestTeam = playersInTeam
		end
	end
	if (selectedTeam == 0) then
		-- there are no teams with players, plop player in first
		selectedTeam = 1
	end
	if (getPlayerTeam(player) == TEAMS[selectedTeam]) then
		return
	end
	outputChatBox(TEAM_DATA[getPlayerTeam(player)].hex .. TEAM_DATA[getPlayerTeam(player)].name .. " #B8C4CChas been disbanded. Its sole member has been assigned to " .. TEAM_DATA[TEAMS[selectedTeam]].hex .. TEAM_DATA[TEAMS[selectedTeam]].name, getRootElement(), 184, 196, 204, true)
	setPlayerTeam(player, TEAMS[selectedTeam])
	local car = getPedOccupiedVehicle(player)
	local r,g,b = getTeamColor(getPlayerTeam(player))
	setVehicleColor(car,r,g,b,(r+127)/2,(g+127)/2,(b+127)/2)
	attachBlipToPlayer(player,r,g,b)
	triggerClientEvent(player, "setCollisionsAll", getRootElement())
	for i,v in pairs(getElementsByType("player")) do
		triggerClientEvent(v, "setCollisionsSpecific", getRootElement(), player)
	end
	updateHudInfo()
end

-- Race progress
-- -------------
-- -------------
function startAnnouncement(newState, oldState)
	if (newState == "GridCountdown") then
		for i,v in pairs(getElementsByType("player")) do
			if (#getElementsByType("player") == 1) then
				triggerClientEvent(v, "setAnnouncementInformation", getRootElement(), "You are the only player in the server.\nTeamwork can't be done alone.\nSolo Assistant Ramps will be raised momentarily.", nil)
			else
				triggerClientEvent(v, "setAnnouncementInformation", getRootElement(), nil, TEAM_DATA)
			end
		end
	elseif (newState == "Running") then
		setTimer(ValidateTeamLineups, 10000, 0)
		setTimer(function()
			for i,v in pairs(getElementsByType("player")) do
				triggerClientEvent(v, "setAnnouncementInformation", getRootElement(), "", nil)
				triggerClientEvent(v, "setObjectiveInformation", getRootElement(), "1", TEAM_DATA)
				PLAYER_DATA[v].wanderTime = 0
			end
		end, 3000, 1)
	end
end

addEventHandler("onRaceStateChanging", root, startAnnouncement)

function updateHudInfo()	-- todo: this also deals with checking requirements, lol
	for i,v in pairs(TEAMS) do
		local quitPeople = 0
		if (TEAM_DATA[v]) then
			quitPeople = TEAM_DATA[v].quiters
		end
		local teamMembers = getPlayersInTeam(v)
		local activeMemberCount = 0
		local finishedMemberCount = 0
		local totalCheckpointCount = 0
		local formerIdlers = 0
		local bootFormerIdlers = false
		for j,w in pairs(teamMembers) do
			if (PLAYER_DATA[w].state ~= "nonparticipant") then
				activeMemberCount = activeMemberCount + 1
				if (PLAYER_DATA[w].state == "running") then
					formerIdlers = formerIdlers + 1
				end
			end
			if (PLAYER_DATA[w].state ~= "nonparticipant" and PLAYER_DATA[w].state ~= "running" and PLAYER_DATA[w].state ~= "helpercatchingup") then
				finishedMemberCount = finishedMemberCount + 1
			end
			if (PLAYER_DATA[w].state ~= "nonparticipant" and PLAYER_DATA[w].state ~= "running" and PLAYER_DATA[w].state ~= "riderarrived") then
				-- the code that issues the next phase has already run. This mean anyone who doesn't have their appropriate role now came back to benefit
				bootFormerIdlers = true
			end
			totalCheckpointCount = totalCheckpointCount + PLAYER_DATA[w].checkpointsReached
			totalCheckpointCount = math.min(totalCheckpointCount, MAIN_COURSE_CHECKPOINTS * GOAL)
		end
		if (bootFormerIdlers == true) then
			activeMemberCount = activeMemberCount - formerIdlers
		end
		TEAM_DATA[v].activeMembers = activeMemberCount
		TEAM_DATA[v].riderRequirement = math.max(1, math.min(GOAL - quitPeople, activeMemberCount - 1))
		TEAM_DATA[v].collectedCheckpoints = totalCheckpointCount + TEAM_DATA[v].compensation
		TEAM_DATA[v].finishedRiders = finishedMemberCount
		TEAM_DATA[v].targetCheckpoints = MAIN_COURSE_CHECKPOINTS * GOAL
	end
	for i,v in pairs(getElementsByType("player")) do
		triggerClientEvent(v, "setTeamInformation", getRootElement(), TEAM_DATA)
		local team = getPlayerTeam(v)
		if (not TEAM_DATA[team]) then
			return
		end
		if (TEAM_DATA[team].finishedRiders < TEAM_DATA[team].riderRequirement) then
			triggerClientEvent(v, "setObjectiveInformation", getRootElement(), "1", TEAM_DATA)
		else
			triggerClientEvent(v, "setObjectiveInformation", getRootElement(), "2", TEAM_DATA)
		end
	end
end

function onPlayerFinish(rank, time_)
	PLAYER_DATA[source].state = "racefinished"
	local team = getPlayerTeam(source)
	TEAM_DATA[team].racersFinished = TEAM_DATA[team].racersFinished + 1
	-- for i,v in pairs(getPlayersInTeam(team)) do
		-- if (PLAYER_DATA[v].state == "racefinished") then
			-- finishedCount = finishedCount + 1
		-- end
	-- end
	if (not TEAM_DATA[team].raceFinished and TEAM_DATA[team].racersFinished >= TEAM_DATA[team].riderRequirement) then
		TEAM_DATA[team].raceFinished = true
		local milliseconds = time_ % 1000
		local seconds = ((time_ - milliseconds) % 60000) / 1000
		local minutes = (time_ - milliseconds - (seconds * 1000)) / 60000
		local timeMessage = string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
		TEAMS_FINISHED = TEAMS_FINISHED + 1
		if (TEAMS_FINISHED == 1) then
			WIN_MESSAGE = TEAM_DATA[team].hex .. TEAM_DATA[team].name .. " #B8C4CCwin! (" .. timeMessage .. ")\n"
		elseif (TEAMS_FINISHED == 2) then
			WIN_MESSAGE = WIN_MESSAGE .. TEAM_DATA[team].hex .. TEAM_DATA[team].name .. " #B8C4CCcome 2nd! (" .. timeMessage .. ")\n"
		elseif (TEAMS_FINISHED == 3) then
			WIN_MESSAGE = WIN_MESSAGE .. TEAM_DATA[team].hex .. TEAM_DATA[team].name .. " #B8C4CCcome 3rd! (" .. timeMessage .. ")\n"
		else
			WIN_MESSAGE = WIN_MESSAGE .. TEAM_DATA[team].hex .. TEAM_DATA[team].name .. " #B8C4CCcome " .. TEAMS_FINISHED .. "th! (" .. timeMessage .. ")\n"
		end
		triggerClientEvent("setAnnouncementInformation", getRootElement(), WIN_MESSAGE, nil)
	end
end
addEventHandler("onPlayerFinish", root, onPlayerFinish)

function processCheckpoint(checkpoint, time_)
	if ((PLAYER_DATA[source].state == "helpercatchingup" or PLAYER_DATA[source].state == "atendgate") and checkpoint > MAIN_COURSE_CHECKPOINTS) then
		-- this is a helper for whom the end gate has just opened, and he's now heading to reunite with his riders
		PLAYER_DATA[source].state = "atendgate"	
		teamCheckStageTwo(getPlayerTeam(source))
	elseif ((PLAYER_DATA[source].state == "running" or PLAYER_DATA[source].state == "nonparticipant") and checkpoint >= 3 and checkpoint < MAIN_COURSE_CHECKPOINTS) then
		-- a rider in the middle of the course
		PLAYER_DATA[source].checkpointsReached = checkpoint
	elseif (PLAYER_DATA[source].state == "running" and checkpoint >= MAIN_COURSE_CHECKPOINTS) then
		-- a rider that has reached the end of the main course. Check for total team progress.
		PLAYER_DATA[source].checkpointsReached = MAIN_COURSE_CHECKPOINTS
		PLAYER_DATA[source].state = "riderarrived"
		teamCheckStageOne(getPlayerTeam(source))
	end
	updateHudInfo()
end
addEventHandler("onPlayerReachCheckpoint", root, processCheckpoint)

function teamCheckStageTwo(team)
	local stageAdvanceCount = 0
	local nonParticipants = 0
	local teamMembers = getPlayersInTeam(team)
	local onThisStage = false
	for i,v in pairs(teamMembers) do
		if (PLAYER_DATA[v].state == "helpercatchingup") then
			-- a participant helper is still catching up
			return
		elseif (PLAYER_DATA[v].state == "atendgate") then
			onThisStage = true
		end
	end
	if (not onThisStage) then
		-- we are not on this stage, abort
		return
	end
	if (TEAM_DATA[team].collectedCheckpoints < TEAM_DATA[team].targetCheckpoints) then
		-- all players reached the end, but this is less than the goal because the team has too little players
		local difference = TEAM_DATA[team].targetCheckpoints - TEAM_DATA[team].collectedCheckpoints
		for i,v in pairs(teamMembers) do
			triggerClientEvent(v, "setMarkerInformation", getRootElement(), "")
			PLAYER_DATA[v].state = "advantagecompensated"
		end
		setTimer(addPoint, 2000, difference, team, 1)
		for i,v in pairs(teamMembers) do
			if ((PLAYER_DATA[v].state ~= "nonparticipant" and PLAYER_DATA[v].state ~= "running") or PLAYER_DATA[v].checkpointsReached >= MAIN_COURSE_CHECKPOINTS) then
				-- at this point, idlers who came back after everyone finished will be assigned 0. Do not give them the satisfaction of victory, hence > 0. Exceptions for people that went idle after completing the course.
				setTimer(function()
					PLAYER_DATA[v].state = "homestretch"
					triggerClientEvent(v, "setMarkerInformation", getRootElement(), "")
					triggerClientEvent(v, "openSecondGate", getRootElement())	
				end, (difference + 1) * 2000, 1)
			end
		end
	else
		-- all players have reached the end, and it's more than the initial stated goal
		for i,v in pairs(teamMembers) do
			if (PLAYER_DATA[v].state ~= "nonparticipant" or PLAYER_DATA[v].checkpointsReached >= MAIN_COURSE_CHECKPOINTS) then
				PLAYER_DATA[v].state = "homestretch"
				triggerClientEvent(v, "setMarkerInformation", getRootElement(), "")
				setTimer(function()
					triggerClientEvent(v, "openSecondGate", getRootElement())	
				end, 10000, 1)
			end
		end
	end
end

function addPoint(team, amount)
	TEAM_DATA[team].compensation = TEAM_DATA[team].compensation + amount
	updateHudInfo()
end

-- TODO: This does not check properly
function teamCheckStageOne(team)
	local teamMembers = getPlayersInTeam(team)
	for i,v in pairs(teamMembers) do
		if (PLAYER_DATA[v].state ~= "nonparticipant" and PLAYER_DATA[v].state ~= "running" and PLAYER_DATA[v].state ~= "riderarrived") then
			-- A player has a different state, indicating that this code has run before. Abort. Anyone who does have these states is a returning idler.
			return
		end
	end
	-- check if the team has met its goal, or if all but one of its participating members have reached the finish (the one being the helper)
	if (TEAM_DATA[team].finishedRiders >= TEAM_DATA[team].riderRequirement) then
		-- team is finished, open helper gate for its members
		for i,v in pairs(teamMembers) do
			if (PLAYER_DATA[v].state == "riderarrived") then
				PLAYER_DATA[v].state = "atendgate"
				triggerClientEvent(v, "openFirstGate", getRootElement())	
				triggerClientEvent(v, "setMarkerInformation", getRootElement(), "")
			elseif (PLAYER_DATA[v].state == "running") then
				PLAYER_DATA[v].state = "helpercatchingup"
				playerCpCatchupTeleport(v)
				triggerClientEvent(v, "openFirstGate", getRootElement())	
				triggerClientEvent(v, "setMarkerInformation", getRootElement(), "")
			elseif (PLAYER_DATA[v].state == "nonparticipant") then
				triggerClientEvent(v, "openFirstGate", getRootElement())	
			end
		end
	end
end

function playerCpCatchupTeleport(player)
	PLAYER_DATA[player].wasted = false
	local vehicle = getPedOccupiedVehicle(player)	
	local x,y,z = getElementPosition(vehicle)
	local l,m,n = getElementVelocity(vehicle)	
	local u,v,w = getElementRotation(vehicle)
	--local p,q,r = getElementAngularVelocity(vehicle)
	setElementFrozen(vehicle, true)
	cps = getElementsByType("checkpoint")
	for i = 1, MAIN_COURSE_CHECKPOINTS, 1 do
		local a, b, c = getElementPosition(cps[i])
		setElementPosition(vehicle, a,b,c)
	end		
	setElementPosition(vehicle, x,y,z)
	setTimer(function()
		setElementFrozen(vehicle, false)
		setElementVelocity(vehicle, l,m,n)
		setElementRotation(vehicle, u,v,w)
		--setElementAngularVelocity(vehicle, p,q,r)
	end, 50, 1)
end

function playerDied()
	PLAYER_DATA[source].wasted = true
end
addEvent("onPlayerRaceWasted", true)
addEventHandler("onPlayerRaceWasted", root, playerDied)


function riderFell(hitElement, matchingDimension)
	if (getElementType(hitElement) ~= "player") then
		return
	end
	if (PLAYER_DATA[hitElement].checkpointsReached >= 3) then
		triggerClientEvent(hitElement, "setAnnouncementInformation", getRootElement(), "Course abandoned! \nType /kill in chat to return.", nil)
		setTimer(function()
			triggerClientEvent(hitElement, "setAnnouncementInformation", getRootElement(), "", nil)
		end, 10000, 1)
	end
end
addEventHandler("onColShapeHit", HELPER_AREA, riderFell)

function riderDied()
	triggerClientEvent(source, "setAnnouncementInformation", getRootElement(), "", nil)
end
addEventHandler("onPlayerWasted", root, riderDied)

-- Configure players for team
-- --------------------------
-- --------------------------

function setTeamPlayerAttributesOPPURP()
	local car = getPedOccupiedVehicle(source)
	local r,g,b = getTeamColor(getPlayerTeam(source))
	if (not car) then
		return
	end
	setVehicleColor(car,r,g,b,(r+127)/2,(g+127)/2,(b+127)/2)
	attachBlipToPlayer(source,r,g,b)
	triggerClientEvent(source, "setCollisionsAll", getRootElement())
	for i,v in pairs(getElementsByType("player")) do
		triggerClientEvent(v, "setCollisionsSpecific", getRootElement(), source)
	end
	updateHudInfo()
end
addEventHandler("onPlayerPickUpRacePickup", root, setTeamPlayerAttributesOPPURP)

function setTeamPlayerAttributesOVE(thePlayer)
	if (not getPlayerTeam(thePlayer)) then
		return
	end
	local r,g,b = getTeamColor(getPlayerTeam(thePlayer))
	setVehicleColor(source,r,g,b,(r+127)/2,(g+127)/2,(b+127)/2)
	attachBlipToPlayer(thePlayer,r,g,b)
	triggerClientEvent(thePlayer, "setCollisionsAll", getRootElement())
	for i,v in pairs(getElementsByType("player")) do
		triggerClientEvent(v, "setCollisionsSpecific", getRootElement(), thePlayer)
	end
	updateHudInfo()
end
addEventHandler("onVehicleEnter", root, setTeamPlayerAttributesOVE)	

function setCollisionORSC(newState, oldState)
	if (newState == "undefined" or newState == "NoMap" or newState == "LoadingMap" or newState == "PreGridCountdown") then
		return
	end
	for i,v in pairs(getElementsByType("player")) do
		triggerClientEvent(v, "setCollisionsAll", getRootElement())	
		if (newState == "GridCountdown") then
			local r,g,b = getTeamColor(getPlayerTeam(v))
			attachBlipToPlayer(v,r,g,b)
		end
	end
	updateHudInfo()
end

addEventHandler("onRaceStateChanging", root, setCollisionORSC)

function attachBlipToPlayer(player, r, g, b)
	if (not PLAYER_DATA[player]) then
		return
	end
	if (isElement(PLAYER_DATA[player].blip)) then
		destroyElement(PLAYER_DATA[player].blip)
	end
	PLAYER_DATA[player].blip = createBlipAttachedTo(player, 0, 1, r, g, b)
end

-- Team assignment in marker
-- -------------------------
-- -------------------------

function markerDetection(markerHit, matchingDimension)
	markerID = getElementID(markerHit)
	x1,y1,z1 = getElementPosition(markerHit)
	x2,y2,z2 = getElementPosition(source)
	if (getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2) > getMarkerSize(markerHit)) then
		return
	end
	if (markerID == MARKER_TEAM_CONFIG) then
		promptTeamMenu(source)
	elseif (markerID == MARKER_FIRST_GATE) then
		if (PLAYER_DATA[source].state == "running") then
			triggerClientEvent(source, "setMarkerInformation", getRootElement(), "This gate will open when your team has reached its goal.")
		elseif (PLAYER_DATA[source].state ~= "nonparticipant" and PLAYER_DATA[source].state ~= "running") then
			if (PLAYER_DATA[source].wasted == true) then
				playerCpCatchupTeleport(source)
			end
		end
	elseif (markerID == MARKER_SECOND_GATE) then
		if (PLAYER_DATA[source].state == "atendgate") then
			triggerClientEvent(source, "setMarkerInformation", getRootElement(), "Please wait for the rest of your team.")
		end
		if (PLAYER_DATA[source].state == "advantagecompensated") then
			triggerClientEvent(source, "setMarkerInformation", getRootElement(), "Your team had an advantage, please wait for compensation.")
		end
	end
end
addEventHandler("onPlayerMarkerHit", getRootElement(), markerDetection)

function markerDetectionLeave(markerHit, matchingDimension)
	if (markerID == MARKER_TEAM_CONFIG) then
		-- nothing yet
	elseif (markerID == MARKER_FIRST_GATE) then
		triggerClientEvent(source, "setMarkerInformation", getRootElement(), "")
	elseif (markerID == MARKER_SECOND_GATE) then
		triggerClientEvent(source, "setMarkerInformation", getRootElement(), "")
	end
end
addEventHandler("onPlayerMarkerLeave", getRootElement(), markerDetectionLeave)

function promptTeamMenu(player)		-- TODO: Give this a GUI
	local msg = "Use /changeteam # to change to a team. Possible team numbers: "
	for i = 1,7,1 do
		msg = msg .. POSSIBLE_TEAMS[i][5] .. i .. "#B8C4CC, "
	end
	msg = msg .. POSSIBLE_TEAMS[8][5] .. 8 .. "#B8C4CC."
	outputChatBox(msg, player, 184, 196, 204, true)
end

function changeTeamCmd(playerSource, commandName, teamNo)
	if (not isElementWithinMarker(playerSource, getElementByID("_MARKER_TEAM_CONFIG"))) then
		return
	end
	if (not teamNo) then
		outputChatBox("no team number specified", playerSource)
		return
	end
	teamNumber = tonumber(teamNo)
	if (teamNumber and teamNumber > 0 and teamNumber < 9) then
		changePlayerTeam(playerSource, teamNumber)
	else 
		outputChatBox("Invalid team number", playerSource)
	end
end
addCommandHandler("changeteam", changeTeamCmd)

function changePlayerTeam(player, to)
	local toTeam = getTeamFromName(POSSIBLE_TEAMS[to][1])
	local fromTeam = getPlayerTeam(player)
	if (PLAYER_DATA[player].checkpointsReached > 0) then
		TEAM_DATA[fromTeam].compensation = TEAM_DATA[fromTeam].compensation + PLAYER_DATA[player].checkpointsReached
		TEAM_DATA[fromTeam].quiters = TEAM_DATA[fromTeam].quiters + 1
	end
	PLAYER_DATA[player].state = "running"
	if (toTeam) then
		for i,v in pairs(getPlayersInTeam(toTeam)) do
			outputChatBox(TEAM_DATA[toTeam].hex .. getPlayerName(player) .. " #B8C4CChas joined your team.", v, 184, 196, 204, true)
		end
		setPlayerTeam(player, toTeam)
	else
		TEAMS[to] = createTeam(POSSIBLE_TEAMS[to][1],POSSIBLE_TEAMS[to][2],POSSIBLE_TEAMS[to][3],POSSIBLE_TEAMS[to][4])	
		initTeam(TEAMS[to], POSSIBLE_TEAMS[to])
		setPlayerTeam(player, TEAMS[to])
	end
	for i,v in pairs(getPlayersInTeam(fromTeam)) do
		outputChatBox(TEAM_DATA[fromTeam].hex .. getPlayerName(player) .. " #B8C4CChas abandoned your team. Adjusting objective.", v, 184, 196, 204, true)
	end
	-- set colors & cols etc
	local car = getPedOccupiedVehicle(player)
	local r,g,b = getTeamColor(getPlayerTeam(player))
	setVehicleColor(car,r,g,b,(r+127)/2,(g+127)/2,(b+127)/2)
	attachBlipToPlayer(player,r,g,b)
	triggerClientEvent(player, "setCollisionsAll", getRootElement())
	for i,v in pairs(getElementsByType("player")) do
		triggerClientEvent(v, "setCollisionsSpecific", getRootElement(), player)
	end
	updateHudInfo()
end

-- handle joins and quits
-- ----------------------
-- ----------------------

function handleQuiters()
	local team = getPlayerTeam(source)
	if (PLAYER_DATA[source].checkpointsReached > 0) then
		TEAM_DATA[team].compensation = TEAM_DATA[team].compensation + PLAYER_DATA[source].checkpointsReached
		TEAM_DATA[team].quiters = TEAM_DATA[team].quiters + 1
	end
	for i,v in pairs(getPlayersInTeam(team)) do
		outputChatBox("Your teammate " .. TEAM_DATA[team].hex .. getPlayerName(source) .. " #B8C4CChas disconnected. Adjusting objective.", v, 184, 196, 204, true)
	end
end
addEventHandler("onPlayerQuit", root, handleQuiters)

function handleJoiners()
	initPlayer(source)
	local lowestTeam = 0
	local selectedTeam = 0
	for i = 1, TEAM_COUNT, 1 do
		local playersInTeam = countPlayersInTeam(TEAMS[i])
		if (playersInTeam < lowestTeam) then
			selectedTeam = i
			lowestTeam = playersInTeam
		end
	end
	if (selectedTeam == 0) then
		-- there are no teams with players, plop player in first
		selectedTeam = 1
	end
	setPlayerTeam(source, TEAMS[selectedTeam])
	outputChatBox(getPlayerName(source) .. " #B8C4CChas been assigned to " .. TEAM_DATA[TEAMS[selectedTeam]].hex .. TEAM_DATA[TEAMS[selectedTeam]].name .. "#B8C4CC.", getRootElement(), 184, 196, 204, true)
end
addEventHandler("onPlayerJoin", getRootElement(), handleJoiners)



-- camera
-- ------
-- ------
-- ------

function cutscene(newState, oldState)
	if (newState == "GridCountdown") then
		for i, v in pairs(getElementsByType("player")) do
			setCameraMatrix(v, CAMERA_POSITION_X, CAMERA_POSITION_Y, CAMERA_POSITION_Z, CAMERA_TARGET_X, CAMERA_TARGET_Y, CAMERA_TARGET_Z)
			for i = 1, 3, 1 do
				car = getElementByID("_TUTORIAL_VEHICLE_" .. i)
				setElementFrozen(car, false)
				setElementAlpha(car, 255)
			end
			setTimer(setCameraTarget, 5000, 1, v, v)
		end
	elseif (newState == "Running") then
		for i, v in pairs(getElementsByType("player")) do
			setCameraTarget(v, v)
		end
	end
end
addEventHandler("onRaceStateChanging", root, cutscene)

-- debug
-- -----
-- -----

-- addCommandHandler("rewardHelperCheckpoints", playerCpCatchupTeleport)


    -- <object id="_ASSISTANT01" breakable="true" interior="0" collisions="true" alpha="255" model="7017" doublesided="true" scale="1" dimension="0" posX="881" posY="-1822.5" posZ="-25.9" rotX="291.995" rotY="270" rotZ="105.995"></object>
    -- <object id="_ASSISTANT02" breakable="true" interior="0" collisions="true" alpha="255" model="7017" doublesided="true" scale="1" dimension="0" posX="884.59961" posY="-1865.2998" posZ="-21.6" rotX="285.985" rotY="270" rotZ="89.995"></object>
    -- <object id="_ASSISTANT03" breakable="true" interior="0" collisions="true" alpha="255" model="7017" doublesided="true" scale="1" dimension="0" posX="816.2002" posY="-1852" posZ="-27.1" rotX="289.99" rotY="270" rotZ="179.984"></object>
    -- <object id="_ASSISTANT04" breakable="true" interior="0" collisions="true" alpha="255" model="7017" doublesided="true" scale="1" dimension="0" posX="859.7002" posY="-1889.5" posZ="-18" rotX="279.987" rotY="270" rotZ="147.98"></object>
    -- <object id="_ASSISTANT05" breakable="true" interior="0" collisions="true" alpha="255" model="7017" doublesided="true" scale="1" dimension="0" posX="825.59961" posY="-1994.2998" posZ="-24.7" rotX="289.984" rotY="270" rotZ="353.98"></object>
    -- <object id="_ASSISTANT06" breakable="true" interior="0" collisions="true" alpha="255" model="7017" doublesided="true" scale="1" dimension="0" posX="868.7998" posY="-1909.7998" posZ="-20.4" rotX="281.728" rotY="270" rotZ="139.471"></object>
    -- <object id="_ASSISTANT07" breakable="true" interior="0" collisions="true" alpha="255" model="7017" doublesided="true" scale="1" dimension="0" posX="801.90002" posY="-1999.8" posZ="-26.4" rotX="287.982" rotY="270" rotZ="269.973"></object>
    -- <object id="_ASSISTANT08" breakable="true" interior="0" collisions="true" alpha="255" model="7017" doublesided="true" scale="1" dimension="0" posX="854.20001" posY="-2006.5" posZ="-17.4" rotX="274.73" rotY="270" rotZ="179.973"></object>
    -- <object id="_ASSISTANT09" breakable="true" interior="0" collisions="true" alpha="255" model="7017" doublesided="true" scale="1" dimension="0" posX="794.5" posY="-1834" posZ="-23.4" rotX="283.982" rotY="270" rotZ="269.984"></object>

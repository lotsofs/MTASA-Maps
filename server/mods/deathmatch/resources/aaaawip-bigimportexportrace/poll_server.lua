local GAME_MODES = {
	[1] = "A Basic Race",
	[2] = "Double It Up",
	[3] = "Post SSA Instadeliveries",
	[4] = "Tetrad",
	[5] = "Bite Sized Chunk",
	[6] = "Sunshine Autos Normal",
	[7] = "Portland Harbor Crane",
	[8] = "Like It's 1984",
	[10] = "One List",
	[16] = "Liberty City Garage Style",
	[21] = "A Per Decem",
	[30] = "Classic",
	[55] = "III SSSA Mode",
	[100] = "Extended",
	[212] = "Full Experience"
}

FORCE_ADD_POLL_OPTION = -1

local POLL_OPTIONS = {}

function tableContains(table, val)
	for i, v in pairs(table) do
		if v == val then return true end
	end
	return false
end

function nominateItem(val)
	if (tableContains(POLL_OPTIONS, val)) then return end
	if (#POLL_OPTIONS >= 9) then return end
	if (not GAME_MODES[val]) then return end
	table.insert(POLL_OPTIONS, val)
end

function assemblePOLL_OPTIONS() 
	nominateItem(1)
	nominateItem(5)
	
	local time = getRealTime()
	if (time.year == 124 and time.yearday == 278 and time.hour > 9) then
		-- October 5th 2024 (123robot's postponed birthday) FE race
		iprint("[FleischBerg Autos] 123robot -> 124robot, happy birthday!")
		nominateItem(212)
	end
	nominateItem(FORCE_ADD_POLL_OPTION)

	local r6 = math.random(6)
	local r7 = math.random(7)
	local r8 = math.random(8)
	local r10 = math.random(10)
	local r16 = math.random(16)
	local r21 = math.random(21)
	local r30 = math.random(30)
	local r55 = math.random(55)
	local r100 = math.random(100)
	if r6 == 1 then
		nominateItem(6)
	end
	if r7 == 1 then
		nominateItem(7)
	end
	if r8 == 1 then
		nominateItem(8)
	end
	if r10 == 1 then
		nominateItem(10)
	end
	if r16 == 1 then
		nominateItem(16)
	end
	if r21 == 1 then
		nominateItem(21)
	end
	if r30 == 1 then
		nominateItem(30)
	end
	if r55 == 1 then
		nominateItem(55)
	end
	if r100 == 1 then
		nominateItem(100)
	end

	nominateItem(2)
	nominateItem(3)
	nominateItem(4)
	table.sort(POLL_OPTIONS)
	return o

end

function getGamemodeName(result)
	return GAME_MODES[result] or "ERROR"
end

function startRacePoll()
	exports.votemanager:stopPoll {}
	assemblePOLL_OPTIONS()
	POLL_ACTIVE = true
	-- poll thing, half of which I dont understand what it means
	poll = exports.votemanager:startPoll {
		--start settings (dictionary part)
		title="Choose the map length:",
		percentage=51,
		timeout=CUTSCENE_LENGTH_IN_SECONDS,
		allowchange=true,

		[1]=POLL_OPTIONS[1] and {(GAME_MODES[POLL_OPTIONS[1]] .. " (" .. POLL_OPTIONS[1] .. ")") or nil, "pollFinished" , resourceRoot, POLL_OPTIONS[1] or nil} or nil,		
		[2]=POLL_OPTIONS[2] and {(GAME_MODES[POLL_OPTIONS[2]] .. " (" .. POLL_OPTIONS[2] .. ")") or nil, "pollFinished" , resourceRoot, POLL_OPTIONS[2] or nil} or nil,		
		[3]=POLL_OPTIONS[3] and {(GAME_MODES[POLL_OPTIONS[3]] .. " (" .. POLL_OPTIONS[3] .. ")") or nil, "pollFinished" , resourceRoot, POLL_OPTIONS[3] or nil} or nil,		
		[4]=POLL_OPTIONS[4] and {(GAME_MODES[POLL_OPTIONS[4]] .. " (" .. POLL_OPTIONS[4] .. ")") or nil, "pollFinished" , resourceRoot, POLL_OPTIONS[4] or nil} or nil,		
		[5]=POLL_OPTIONS[5] and {(GAME_MODES[POLL_OPTIONS[5]] .. " (" .. POLL_OPTIONS[5] .. ")") or nil, "pollFinished" , resourceRoot, POLL_OPTIONS[5] or nil} or nil,		
		[6]=POLL_OPTIONS[6] and {(GAME_MODES[POLL_OPTIONS[6]] .. " (" .. POLL_OPTIONS[6] .. ")") or nil, "pollFinished" , resourceRoot, POLL_OPTIONS[6] or nil} or nil,		
		[7]=POLL_OPTIONS[7] and {(GAME_MODES[POLL_OPTIONS[7]] .. " (" .. POLL_OPTIONS[7] .. ")") or nil, "pollFinished" , resourceRoot, POLL_OPTIONS[7] or nil} or nil,		
		[8]=POLL_OPTIONS[8] and {(GAME_MODES[POLL_OPTIONS[8]] .. " (" .. POLL_OPTIONS[8] .. ")") or nil, "pollFinished" , resourceRoot, POLL_OPTIONS[8] or nil} or nil,		
		[9]=POLL_OPTIONS[9] and {(GAME_MODES[POLL_OPTIONS[9]] .. " (" .. POLL_OPTIONS[9] .. ")") or nil, "pollFinished" , resourceRoot, POLL_OPTIONS[9] or nil} or nil,		
	}
	if not poll then
		applyPollResult(1)
	end
end

function applyPollResult(pollResult)
	configureGame(pollResult)

	-- Do some trickery with the map name & the race scoreboard manager so that separate top times are tracked per map length
	local customMapName = getMapName() .. " (" .. GAME_MODES[pollResult] .. ")"
	setMapName ( customMapName )
	
	-- THe default top times manager does not respond to the above. So send it an event so it does
	local timesManager = getResourceRootElement( getResourceFromName("race_toptimes"))
	local raceResRoot = getResourceRootElement( getResourceFromName( "race" ) )
	local raceInfo = raceResRoot and getElementData( raceResRoot, "info" )
	
	local stuff = {}
	stuff.modename = raceInfo.mapInfo.modename
	stuff.name = customMapName
	stuff.statsKey = nil

	if raceInfo and timesManager then
		triggerEvent("onMapStarting", timesManager, stuff, stuff, stuff)
		triggerClientEvent("onClientSetMapName", timesManager, customMapName )
	end
end
addEvent("pollFinished", true)
addEventHandler("pollFinished", resourceRoot, applyPollResult)



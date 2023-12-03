-- database stuff
-- --------------

function finish(rank, _time)
	name = getPlayerName(source)
	RACE_FINISHED = true
	if (DATABASE) then
		dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS progressTable (serial TEXT, progress INTEGER, indices TEXT)")
		local s = getPlayerSerial(source)
		local query = dbQuery(DATABASE, "SELECT * FROM progressTable WHERE serial=? LIMIT 1", s)
		local results = dbPoll(query, -1)
		if (results and #results > 0) then
			dbExec(DATABASE, "DELETE FROM progressTable WHERE serial=?", s)
		end
		if (REQUIRED_CHECKPOINTS == #getElementsByType("checkpoint")) then
			dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS scoresTable (playername TEXT, score integer)")
			query = dbQuery(DATABASE, "SELECT * FROM scoresTable WHERE playername = ?", name)
			results = dbPoll(query, -1)		
			if (LOADED_GAME_FROM_DB) then
				return
			end
			if (results and #results > 0) then
				if (_time < results[1]["score"]) then
					dbExec(DATABASE, "UPDATE scoresTable SET score = ? WHERE playername = ?", _time, name)
				end
			else
				dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", name, _time)
			end
			query2 = dbQuery(DATABASE, "SELECT * FROM scoresTable ORDER BY score ASC LIMIT 10")		
			results = dbPoll(query2, -1)
			triggerClientEvent(root, "setScoreBoard", resourceRoot, results)
		end	
    else
        outputChatBox("ERROR: Scores database fault", root, 255, 127, 0)
	end
end
addEventHandler("onPlayerFinish", getRootElement(), finish)

function showScores(newState, oldState)
	if (newState == "Running") then
		-- triggerClientEvent(root, "setScoreBoard", resourceRoot, results)
		triggerClientEvent(root, "showScoreBoard", resourceRoot, true, 31000)
		return
	elseif (newState == "GridCountdown") then
		if (DATABASE) then
			-- read the database
			dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS scoresTable (playername TEXT, score integer)")
			query = dbQuery(DATABASE, "SELECT * FROM scoresTable ORDER BY score ASC LIMIT 10")
			results = dbPoll(query, -1)
			triggerClientEvent(root, "setScoreBoard", resourceRoot, results)
			triggerClientEvent(root, "showScoreBoard", resourceRoot, true, nil)
		else
			outputChatBox("ERROR: Scores database fault", 255, 127, 0)
		end
	elseif (newState == "TimesUp" or newState == "EveryoneFinished" or newState == "PostFinish" or newState == "SomeoneWon") then
		triggerClientEvent(root, "showScoreBoard", resourceRoot, true, nil)
	end
end
addEventHandler("onRaceStateChanging", root, showScores)
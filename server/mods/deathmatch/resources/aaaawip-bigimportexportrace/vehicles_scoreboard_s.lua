RECORDS_DATABASE = dbConnect("sqlite", ":/mapSuperFleischbergAutosRecords.db")

-- Function converts time in milliseconds into time in format MM:SS.MS
function convertToRaceTime(time)
	if time ~= nil then
		local m = math.floor(time / 1000 / 60)
		local s = math.floor((time / 1000) - m*60)
		local ms = math.floor(time - (m*60+s)*1000)
		
		if m < 1 then m = ""
		else m = m.. ":" end
		if s < 10 and m ~= "" then s = "0" ..s end
		if ms < 10 then ms = "00" ..ms
		elseif ms < 100 and ms > 9 then ms = "0" ..ms end
		
		return m.. "" ..s.. "." ..ms
	end
end

addEvent("onPlayerDeliverVehicle", true)
addEventHandler("onPlayerDeliverVehicle", getRootElement(), function(time, vehicleModel)
	if (RECORDS_DATABASE) then
		dbExec(RECORDS_DATABASE, "CREATE TABLE IF NOT EXISTS Table" ..vehicleModel.. "(playername TEXT, score INTEGER)")
		recordsQuery = dbQuery(RECORDS_DATABASE, "SELECT * FROM Table" ..vehicleModel.. " WHERE playername = ?", getPlayerName(source))
		recordsResults = dbPoll(recordsQuery, -1)		
		
		-- Updating RECORDS_DATABASE
		if (recordsResults and #recordsResults > 0) then
			if (time < recordsResults[1]["score"]) then
				oldScore = recordsResults[1]["score"]
				dbExec(RECORDS_DATABASE, "UPDATE Table" ..vehicleModel.. " SET score = ? WHERE playername = ?", time, getPlayerName(source))
			end
		else
			oldScore = 0
			dbExec(RECORDS_DATABASE, "INSERT INTO Table" ..vehicleModel.. "(playername, score) VALUES (?,?)", getPlayerName(source), time)
		end
		
		-- Sort first 11 Records 
		sortQuery = dbQuery(RECORDS_DATABASE, "SELECT * FROM Table" ..vehicleModel.. " ORDER BY score ASC LIMIT 11")		
		recordsResults = dbPoll(sortQuery, -1)
		
		-- Check for new top time
		for i, recordsData in pairs(recordsResults) do 
			if recordsData["playername"] == getPlayerName(source) and time == recordsData["score"] then
				if oldScore ~= 0 then
					local diff = oldScore - time
					outputChatBox("#00CC00[" ..VEHICLE_NAMES[getElementModel(getPedOccupiedVehicle(source))].. "] New top time #" ..i.. ": " ..getPlayerName(source).. "#00CC00, " ..convertToRaceTime(time).. " (-" ..convertToRaceTime(diff).. ")", root, 255, 255, 255, true)
				else
					outputChatBox("#00CC00[" ..VEHICLE_NAMES[getElementModel(getPedOccupiedVehicle(source))].. "] New top time #" ..i.. ": " ..getPlayerName(source).. "#00CC00, " ..convertToRaceTime(time), root, 255, 255, 255, true)
				end

				break
			end
			
			if i == 11 then break end
		end
	end
end )

-- Event called from client when player want to see stats, event returns data from RECORDS_DATABASE
addEvent("getStats", true)
addEventHandler("getStats", getRootElement(), function(vehicleModel)
	if RECORDS_DATABASE then
		dbExec(RECORDS_DATABASE, "CREATE TABLE IF NOT EXISTS Table" ..vehicleModel.. "(playername TEXT, score INTEGER)")
		recordsQuery = dbQuery(RECORDS_DATABASE, "SELECT * FROM Table" ..vehicleModel.. " ORDER BY score ASC LIMIT 11")
		recordsResults = dbPoll(recordsQuery, -1)		
		triggerClientEvent(source, "receiveStats", source, recordsResults)
	end
end )
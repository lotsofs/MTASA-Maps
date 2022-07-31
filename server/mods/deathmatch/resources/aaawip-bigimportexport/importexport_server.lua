-- TODO:
-- DONE - a script that teleports players to a car at the start
-- DONE - a script that detects the player inside the marker
-- DONE - a script that teleports players to a new car
-- DONE (unintentiallo) - a script that sets the respawn point for players
-- DONE (maybe) - a script that detects the player being inside a tanker and moving the marker for it
-- DONE - move stuff server side for security
-- DONE - repair car on teleport
-- DONE - intermediate checkpoints
-- DONE - fix coordinates for sanchez etc
-- DONE - spamming suicide = skip checkpoints
-- DONE - colorful cars
-- DONE - crane
-- DONE - blip
-- DONE - voting at start for length
-- DONE - leaderboard for 30 minute
-- DONE - make leaderboard disappear after a while, and reappear upon the end, and maybe upon the press of a button
-- DONE - add players to the leaderboard when they finish
-- DONE - taxi driver
-- DONE - make tanker be craned
-- DONE - magnet raised by 2Z then lowered by 4Z
-- DONE - check if player drove their truck off the ship or died somehow on the ship
-- DONE - shuffle is not called on laptop
-- DONE - use the new crane technology to attach the player to it when they finish
-- people entering --> line 208 in server, attempt to perform arithmetic on a nil value
-- DONE - outputchatbox

-- Allow tanks to fire without damaging other players
-- Make the cranes work
---- Make work for players joining midway through
---- Boat Detector: Could probably shave the eastern edge of the boat hitbox further west since you'll only be approaching with a Reefer from that direction. West and southern border are fine.
-- Protection when landing big planes such as AT-400
-- Can bicycles cheese the non-collision fence? Fix
-- Tutorial cutscene
-- There's a failsafe for new players joining (is it needed?). But this triggers by them being in a 'wrong' vehicle. However, there are no wrong vehicles. Workaround.
-- Map loading upon teleporting. If I can't find a way to preload map regions, I think I'll just have to do a freeze before move, or do the hold the line thing.
-- Add options for no planes, boats, etc
-- Janky launch spawns. Need to freeze probably.
-- Trains
-- Runway indicators on map?
-- Coach

MARKER = getElementByID("_MARKER_EXPORT_PARK")
MARKER_TANKER = getElementByID("_MARKER_EXPORT_TANKER")

SHUFFLED_CARS = {}
PLAYER_PROGRESS = {}
TELEPORTING = {}
CHECKPOINT = {}
CHECKPOINTS = getElementsByType("checkpoint")

REQUIRED_CHECKPOINTS = -1
TIMER_POLL = nil

PRE_SHUFFLED_CARS = {}

DATABASE = dbConnect("sqlite", ":/fleischbergAutosTopTimes.db")
	
------------------------------------------------------ Start of race ------------------------------------------------------

function shuffleCarsAll()
	-- do nothing if game hasnt started yet
	if (REQUIRED_CHECKPOINTS == -1) then
		return
	end
	cars = getElementsByType("exportable")
	for i, v in pairs(getElementsByType("player")) do
		if (not SHUFFLED_CARS[v]) then
			if (REQUIRED_CHECKPOINTS == #cars) then
				PRE_SHUFFLED_CARS = cars
			else
				if (#PRE_SHUFFLED_CARS == 0) then
					for i = #cars, #cars - REQUIRED_CHECKPOINTS + 1, -1 do
						randomIndex = math.random(1,i)
						table.insert(PRE_SHUFFLED_CARS, cars[randomIndex])
						table.remove(cars, randomIndex)
					end
				end
			end
			colorGenerator(v)
			triggerClientEvent(v, "shuffle", resourceRoot, PRE_SHUFFLED_CARS)
		else
			colorGenerator(v)
			teleportToNext(v)
		end
	end
end

function inStarterCarFailsafe()
	for i,v in pairs(getElementsByType("player")) do
		vehicle = getPedOccupiedVehicle(v)
		model = getElementModel(vehicle)
		-- if (model == 522 or model == 420 or model == 438) then
			-- do nothing if game hasnt started yet
			if (REQUIRED_CHECKPOINTS == -1) then
				return
			end
			cars = getElementsByType("exportable")
			if (not SHUFFLED_CARS[v]) then
				if (REQUIRED_CHECKPOINTS == #cars) then
					PRE_SHUFFLED_CARS = cars
				else
					if (#PRE_SHUFFLED_CARS == 0) then
						for i = #cars, #cars - REQUIRED_CHECKPOINTS + 1, -1 do
							randomIndex = math.random(1,i)
							table.insert(PRE_SHUFFLED_CARS, cars[randomIndex])
							table.remove(cars, randomIndex)
						end
					end
				end
				colorGenerator(v)
				triggerClientEvent(v, "shuffle", resourceRoot, PRE_SHUFFLED_CARS)
			-- else
				-- colorGenerator(v)
				-- teleportToNext(v)
			end			
		-- end
	end
end
setTimer(inStarterCarFailsafe, 10000, 0)

function shuffleCarsOnePlayer(theVehicle, seat, jacked)
	-- do nothing if game hasnt started yet
	if (REQUIRED_CHECKPOINTS == -1) then
		return
	end
	cars = getElementsByType("exportable")
	if (not SHUFFLED_CARS[source]) then
		if (REQUIRED_CHECKPOINTS == #cars) then
			PRE_SHUFFLED_CARS = cars
		else
			if (#PRE_SHUFFLED_CARS == 0) then
				for i = #cars, #cars - REQUIRED_CHECKPOINTS + 1, -1 do
					randomIndex = math.random(1,i)
					table.insert(PRE_SHUFFLED_CARS, cars[randomIndex])
					table.remove(cars, randomIndex)
				end
			end
		end
		colorGenerator(source)
		triggerClientEvent(source, "shuffle", resourceRoot, PRE_SHUFFLED_CARS)
	else
		colorGenerator(source)
		teleportToNext(source)
	end
end
addEventHandler("onPlayerVehicleEnter", root, shuffleCarsOnePlayer)

function nrgFailsafe(newState, oldState)
	if (newState ~= "GridCountdown") then
		return
	end
	triggerClientEvent ( root, "configureCrane", resourceRoot )
	-- poll thing, half of which I dont understand what it means
	poll = exports.votemanager:startPoll {
	   --start settings (dictionary part)
	   title="Choose the map length:",
	   percentage=75,
	   timeout=11,
	   allowchange=true,

	   --start options (array part)
	   [1]={"Bite Sized Chunk (5)", "pollFinished" , resourceRoot, 5},		
	   [2]={"One List (10)", "pollFinished" , resourceRoot, 10},			
	   [3]={"Classic (30)", "pollFinished" , resourceRoot, 30},			
	   [4]={"Full Experience (212)", "pollFinished", resourceRoot, 212},
	}
	if not poll then
		startGame(30)
	end
	TIMER_POLL = setTimer(startGame, 20000, 1, 30)

	-- -- This might become obsolete
	-- for i, v in pairs(getElementsByType("player")) do
		-- if (getPedOccupiedVehicle(v) == 522) then
			-- killTimer(timerPoll)
			-- shuffleCars()
		-- end
	-- end
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, nrgFailsafe)

function startGame(count)
	killTimer(TIMER_POLL)
	REQUIRED_CHECKPOINTS = count
	shuffleCarsAll()
end
addEvent("pollFinished", true)
addEventHandler("pollFinished", resourceRoot, startGame)

function receiveShuffledCars(shuffledCars)
	SHUFFLED_CARS[client] = shuffledCars
	PLAYER_PROGRESS[client] = 1
	teleportToNext(client)
	colorGenerator(client)
end

function colorGenerator(player)
	colors = {}
	for i = 1, 4, 1 do
		-- since MTA wants colors in RGB, we won't bother calculating hue. Instead, we pretend S & V are both 100% to calculate a RGB values and apply SV on them later.
		-- When both S and V are 100%, the color in RGB will always have one component of 255, one of 0, and one in between.
		components = {}
		components[1] = 255
		components[2] = 0
		components[3] = math.random(0, 255)
		saturation = math.random(99, 100) / 100
		value = math.random(99, 100) / 100

		-- this block of code determines which RGB component will be min, which max, and which the other by shuffling them.
		indices = {1, 2, 3}
		shuffledIndices = {}
		for i = #indices, 1, -1 do
			random = math.random(1,i)
			shuffledIndices[i] = indices[random]
			table.remove(indices, random)
		end

		-- now we take the min/maxed RGB components and do the saturation & value calculations on them based on the shuffled indices
		for j,w in pairs(shuffledIndices) do
			c = components[w]		
			c = c + ((255 - c) * (1 - saturation)) 
			c = c * value			
			c = c - (c % 1)			
			colors[j + (i - 1) * 3] = c	
		end
	end
	-- apply our 4 generated colors the vehicle
	vehicle = getPedOccupiedVehicle(player)
	setVehicleColor(vehicle, colors[1], colors[2], colors[3], colors[4], colors[5], colors[6], colors[7], colors[8], colors[9], colors[10], colors[11], colors[12])
end

function teleportToNext(player)
	-- get our destination
	element = SHUFFLED_CARS[player][PLAYER_PROGRESS[player]]
	x = getElementData(element, "posX")
	y = getElementData(element, "posY")
	z = getElementData(element, "posZ")
	rX = getElementData(element, "rotX")
	rY = getElementData(element, "rotY")
	rZ = getElementData(element, "rotZ")
	model = getElementData(element, "model")
	-- go there
	vehicle = getPedOccupiedVehicle(player)
	setElementModel(vehicle, model)
	setElementPosition(vehicle, x, y, z)
	setElementRotation(vehicle, rX, rY, rZ)
	fixVehicle(vehicle)
	TELEPORTING[player] = false
end

addEvent("shuffleDone", true)
addEventHandler("shuffleDone", resourceRoot, receiveShuffledCars)

------------------------------------------------------ Player progress ------------------------------------------------------

function playerStoppedInMarker()
	for i,v in ipairs(getElementsByType("player")) do	
		vehicle = getPedOccupiedVehicle(v)
		if (vehicle) then
			x, y, z = getElementVelocity(vehicle)
			shittyVelocity = x*x + y*y + z*z
			if (shittyVelocity < 0.001 and isElementWithinMarker(vehicle, MARKER) and not TELEPORTING[v]) then
				TELEPORTING[v] = true
				PLAYER_PROGRESS[v] = PLAYER_PROGRESS[v] + 1
				teleportToCheckpoints(v)
			end
			if (getElementModel(vehicle) == 514 and shittyVelocity < 0.001 and isElementWithinMarker(vehicle, MARKER_TANKER)) then
				triggerClientEvent(v, "moveCrane", resourceRoot)
				--TELEPORTING[v] = true
				--PLAYER_PROGRESS[v] = PLAYER_PROGRESS[v] + 1
				--teleportToCheckpoints(v)
			end
		end
	end
end
setTimer(playerStoppedInMarker, 1, 0)

function cheatSkipVehicle(playerSource, commandName)
	TELEPORTING[playerSource] = true
	PLAYER_PROGRESS[playerSource] = PLAYER_PROGRESS[playerSource] + 1
	teleportToCheckpoints(playerSource)
end
addCommandHandler("cheatnext", cheatSkipVehicle)

function cheatPrevVehicle(playerSource, commandName)
	TELEPORTING[playerSource] = true
	PLAYER_PROGRESS[playerSource] = PLAYER_PROGRESS[playerSource] - 1
	killPed(playerSource)
end
addCommandHandler("cheatprev", cheatPrevVehicle)

function cheatTeleportVehicle(playerSource, commandName)
	vehicle = getPedOccupiedVehicle(playerSource)
	setElementPosition(vehicle, 0, 0, 10)
end
addCommandHandler("cheattp", cheatTeleportVehicle)

function teleportToCheckpoints(player)
	vehicle = getPedOccupiedVehicle(player)
	for i = 1, PLAYER_PROGRESS[player] - 1, 1 do
		x,y,z = getElementPosition(CHECKPOINTS[i])
		setElementPosition(vehicle, x, y, z)
	end
end

function grabCheckpoint(checkpoint, time_)
	if (checkpoint < PLAYER_PROGRESS[source] - 1 and checkpoint < REQUIRED_CHECKPOINTS) then
		--TELEPORTING[source] = false
		teleportToCheckpoints(source)
	elseif (checkpoint == REQUIRED_CHECKPOINTS) then
		PLAYER_PROGRESS[source] = #getElementsByType("checkpoint") + 1
		teleportToCheckpoints(source)
	elseif (checkpoint < REQUIRED_CHECKPOINTS) then
		teleportToNext(source)
	end
	if (checkpoint == REQUIRED_CHECKPOINTS - 1) then
		triggerClientEvent(source, "lastCar", resourceRoot)
	end
end
addEventHandler("onPlayerReachCheckpoint", getRootElement(), grabCheckpoint)

function finish(rank, _time)
	triggerClientEvent(source, "teleportToCraneForFinish", resourceRoot)
	name = getPlayerName(source)
	if (REQUIRED_CHECKPOINTS == #getElementsByType("checkpoint")) then
		if (DATABASE) then
			dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS scoresTable (playername TEXT, score integer)")
			query = dbQuery(DATABASE, "SELECT * FROM scoresTable WHERE playername = ?", name)
			results = dbPoll(query, -1)		

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
		else
			outputChatBox("ERROR: Scores database fault", 255, 127, 0)
		end	
	end
end
addEventHandler("onPlayerFinish", getRootElement(), finish)


-- database stuff
-- --------------

function showScores(newState, oldState)
	if (newState == "Running") then
		triggerClientEvent(root, "showScoreBoard", resourceRoot, true, 5000)
		return
	elseif (newState == "GridCountdown") then
		if (DATABASE) then
			-- read the database
			dbExec(DATABASE, "CREATE TABLE IF NOT EXISTS scoresTable (playername TEXT, score integer)")
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "iguana", 87645)
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "zerogott", 23)
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "jivel", 1011)
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "thedamngod", 45302)
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "kavakcz", 999)
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "uber_dragon", 4)
			-- dbExec(DATABASE, "INSERT INTO scoresTable(playername, score) VALUES (?,?)", "wayno717", 171)
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



-- <exportable id="vehicle (Admiral) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="445" plate="QR48U1T" dimension="0" color="95,10,21,95,10,21,0,0,0,0,0,0" posX="1132.3" posY="-1696.2" posZ="13.7" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Alpha) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="602" plate="FNPN1K4" dimension="0" color="93,27,32,93,27,32,0,0,0,0,0,0" posX="2592.2" posY="1840.2" posZ="10.7" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Ambulance) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="416" plate="U2BX9ZX" dimension="0" color="245,245,245,132,4,16,0,0,0,0,0,0" posX="1222.4" posY="303.60001" posZ="19.9" rotX="0" rotY="0" rotZ="156"></exportable>
-- <exportable id="vehicle (Andromada) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="592" plate="CTNUHQY" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="353.70001" posY="2502.3999" posZ="17.6" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (AT-400) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="577" plate="V3MSPTX" dimension="0" color="189,190,198,76,117,183,0,0,0,0,0,0" posX="1584.5996" posY="1187.9004" posZ="10.9" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Baggage) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="485" plate="NE1SDQS" dimension="0" color="245,245,245,14,49,109,0,0,0,0,0,0" posX="1752" posY="-2456.3" posZ="13.3" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Baggage Trailer (covered)) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="606" plate="F02D58T" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="-1213.2" posY="-109.4" posZ="14.2" rotX="0" rotY="0" rotZ="123.996"></exportable>
-- <exportable id="vehicle (Baggage Trailer (Uncovered)) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="607" plate="PH5O794" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="1914" posY="-2643.5" posZ="13.6" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Bandito) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="568" plate="WNLO4CR" dimension="0" color="111,103,95,151,149,146,0,0,0,0,0,0" posX="-393.70001" posY="2226.8" posZ="42.4" rotX="0" rotY="0" rotZ="286"></exportable>
-- <exportable id="vehicle (Banshee) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="429" plate="SVQEYKY" dimension="0" color="214,218,214,214,218,214,0,0,0,0,0,0" posX="2122.5" posY="987.59998" posZ="10.6" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Barracks) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="433" plate="NSTEHMI" dimension="0" color="95,10,21,0,0,0,0,0,0,0,0,0" posX="298.5" posY="1864.5" posZ="18.2" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Beagle) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="511" plate="5ZPO8FL" dimension="0" color="132,4,16,175,177,177,0,0,0,0,0,0" posX="-37.4" posY="1089.9" posZ="21.3" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Benson) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="499" plate="6WE2WEL" dimension="0" color="89,110,135,132,148,171,0,0,0,0,0,0" posX="2783.2" posY="-2496.3999" posZ="13.8" rotX="0" rotY="0" rotZ="68"></exportable>
-- <exportable id="vehicle (Berkley&apos;s RC Van) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="459" plate="L9CZNRH" dimension="0" color="88,88,83,88,88,83,0,0,0,0,0,0" posX="-1887.40039" posY="-200.7002" posZ="15.2" rotX="16.749" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (BF-400) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="581" plate="RWFZJAI" dimension="0" color="109,24,34,245,245,245,0,0,0,0,0,0" posX="2531" posY="2477" posZ="21.6" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (BF Injection) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="424" plate="2KC2YZ6" dimension="0" color="81,84,89,22,34,72,0,0,0,0,0,0" posX="-2252.3999" posY="-2821.7" posZ="3.4" rotX="0" rotY="0" rotZ="29.998"></exportable>
-- <exportable id="vehicle (Bike) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="509" plate="R2CYWPV" dimension="0" color="37,37,39,245,245,245,0,0,0,0,0,0" posX="1401.1" posY="460.39999" posZ="19.8" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Blade) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="536" plate="C1854JR" dimension="0" color="66,31,33,155,159,157,0,0,0,0,0,0" posX="1772.4" posY="-2129.1001" posZ="13.4" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Blista Compact) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="496" plate="WY0O9ZT" dimension="0" color="59,78,120,59,78,120,0,0,0,0,0,0" posX="1281.6" posY="1307" posZ="10.6" rotX="0" rotY="0" rotZ="269.999"></exportable>
-- <exportable id="vehicle (Bloodring Banger) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="504" plate="LF8ZATG" dimension="0" color="93,27,32,151,149,146,0,0,0,0,0,0" posX="-2158.8999" posY="-407.20001" posZ="35.3" rotX="0" rotY="0" rotZ="224"></exportable>
-- <exportable id="vehicle (BMX) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="481" plate="48TOTJR" dimension="0" color="93,126,141,94,112,114,0,0,0,0,0,0" posX="2259.6001" posY="-1263" posZ="23.6" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Bobcat) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="422" plate="PFAQNCT" dimension="0" color="106,122,140,78,104,129,0,0,0,0,0,0" posX="-135.7" posY="2247" posZ="33.3" rotX="0" rotY="0" rotZ="172"></exportable>
-- <exportable id="vehicle (Box Freight) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="590" plate="P4526SS" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="-105" posY="-348" posZ="2.9" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Boxville) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="498" plate="NPIWETL" dimension="0" color="95,10,21,15,106,137,0,0,0,0,0,0" posX="248.60001" posY="-157.2" posZ="1.8" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Boxville Mission) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="609" plate="VIRCLOS" dimension="0" color="37,37,39,37,37,39,0,0,0,0,0,0" posX="2262.8" posY="-1819.2" posZ="13.8" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Bravura) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="401" plate="ZBWIHAP" dimension="0" color="54,65,85,54,65,85,0,0,0,0,0,0" posX="2359.1001" posY="121.1" posZ="27.2" rotX="350" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Broadway) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="575" plate="PMCG6ZK" dimension="0" color="147,163,150,245,245,245,0,0,0,0,0,0" posX="1911.2" posY="-1784.2" posZ="13.1" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Buccaneer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="518" plate="P8UJPKI" dimension="0" color="42,119,161,109,122,136,0,0,0,0,0,0" posX="2551.6001" posY="2196.7" posZ="10.6" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Buffalo) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="402" plate="LOS97MH" dimension="0" color="105,30,59,105,30,59,0,0,0,0,0,0" posX="888.70001" posY="-23.9" posZ="63.2" rotX="0" rotY="0" rotZ="156"></exportable>
-- <exportable id="vehicle (Bullet) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="541" plate="ZV4V1IU" dimension="0" color="42,119,161,245,245,245,0,0,0,0,0,0" posX="-2355" posY="982.70001" posZ="50.4" rotX="0" rotY="0" rotZ="14"></exportable>
-- <exportable id="vehicle (Burrito) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="482" plate="PD6EWY2" dimension="0" color="124,27,68,124,27,68,0,0,0,0,0,0" posX="848.79999" posY="834.20001" posZ="13.6" rotX="0" rotY="0" rotZ="16"></exportable>
-- <exportable id="vehicle (Bus) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="431" plate="IU8SZJN" dimension="0" color="111,130,151,78,104,129,0,0,0,0,0,0" posX="1793.8" posY="-2328.8999" posZ="-2.4" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Cabbie) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="438" plate="6RKRA7D" dimension="0" color="215,142,16,164,160,150,0,0,0,0,0,0" posX="1676.1" posY="1305.3" posZ="11" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Caddy) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="457" plate="IS6IB4F" dimension="0" color="88,89,90,245,245,245,0,0,0,0,0,0" posX="-2651.7" posY="-296.89999" posZ="7.2" rotX="0" rotY="0" rotZ="314"></exportable>
-- <exportable id="vehicle (Cadrona) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="527" plate="CEEK97C" dimension="0" color="164,160,150,245,245,245,0,0,0,0,0,0" posX="1552.6" posY="2079.8999" posZ="11.1" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Camper) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="483" plate="2S9A2JT" dimension="0" color="245,245,245,95,39,43,245,245,245,0,0,0" posX="-2530.2" posY="1229" posZ="37.5" rotX="0" rotY="0" rotZ="212"></exportable>
-- <exportable id="vehicle (Cargobob) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="548" plate="X4138F6" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="311.39999" posY="2049" posZ="19.5" rotX="0" rotY="0" rotZ="164"></exportable>
-- <exportable id="vehicle (Cement Truck) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="524" plate="UK7WJ34" dimension="0" color="142,140,70,95,39,43,95,39,43,0,0,0" posX="-2110" posY="191.3" posZ="36.1" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Cheetah) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="415" plate="OY4WABN" dimension="0" color="34,25,24,245,245,245,0,0,0,0,0,0" posX="1273" posY="2603.5" posZ="10.7" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Clover) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="542" plate="OGO8YHL" dimension="0" color="93,27,32,109,108,110,0,0,0,0,0,0" posX="2326.8999" posY="-1255.1" posZ="22.3" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Club) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="589" plate="BCDSIIF" dimension="0" color="89,110,135,89,110,135,0,0,0,0,0,0" posX="2034.9" posY="2725.8999" posZ="10.5" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Coach) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="437" plate="FBO4LKD" dimension="0" color="39,47,75,76,117,183,0,0,0,0,0,0" posX="682.59998" posY="-442.79999" posZ="16.6" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Coastguard) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="472" plate="78PLSNV" dimension="0" color="158,164,171,22,34,72,0,0,0,0,0,0" posX="-1607.1" posY="-702.40002" posZ="0.2" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Combine Harvester) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="532" plate="RKNYF6Y" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="-1103.8" posY="-1621.2" posZ="77.5" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Comet) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="480" plate="JDLIHQS" dimension="0" color="93,126,141,93,126,141,0,0,0,0,0,0" posX="231.60001" posY="-1402.6" posZ="51.4" rotX="0" rotY="0" rotZ="50"></exportable>
-- <exportable id="vehicle (Cropduster) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="512" plate="OWTWKOX" dimension="0" color="77,98,104,111,130,151,0,0,0,0,0,0" posX="-1435.3" posY="-953" posZ="201.7" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (DFT-30) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="578" plate="G5859BO" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="-1966.1" posY="-2436.7" posZ="31.4" rotX="0" rotY="0" rotZ="224"></exportable>
-- <exportable id="vehicle (Dinghy) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="473" plate="PUP1HMC" dimension="0" color="158,164,171,22,34,72,0,0,0,0,0,0" posX="-1232.5" posY="-2403.3" posZ="0" rotX="0" rotY="0" rotZ="176"></exportable>
-- <exportable id="vehicle (Dodo) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="593" plate="3KC4UJA" dimension="0" color="88,89,90,189,190,198,0,0,0,0,0,0" posX="1283.4" posY="1361.8" posZ="11.4" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Dozer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="486" plate="K9612K8" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="575.5" posY="881.5" posZ="-43.3" rotX="0" rotY="0" rotZ="308"></exportable>
-- <exportable id="vehicle (Dumper) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="406" plate="ZX70UU1" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="686.09998" posY="895.40002" posZ="-38.3" rotX="0" rotY="0" rotZ="80"></exportable>
-- <exportable id="vehicle (Dune) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="573" plate="2P90KHD" dimension="0" color="14,49,109,123,10,42,0,0,0,0,0,0" posX="1089.3" posY="1615.9" posZ="12.8" rotX="0" rotY="0" rotZ="280"></exportable>
-- <exportable id="vehicle (Elegant) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="507" plate="YRIMQUB" dimension="0" color="124,28,42,124,28,42,0,0,0,0,0,0" posX="1784.1" posY="-1061.3" posZ="23.9" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Elegy) (2)" sirens="false" paintjob="3" interior="0" alpha="255" model="562" plate="OE0T2U4" dimension="0" color="37,37,39,245,245,245,0,0,0,0,0,0" posX="-1668" posY="1207.1" posZ="20.9" rotX="0" rotY="0" rotZ="278"></exportable>
-- <exportable id="vehicle (Emperor) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="585" plate="WNTKD53" dimension="0" color="156,161,163,156,161,163,0,0,0,0,0,0" posX="-2591.5" posY="666.09998" posZ="27.5" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Enforcer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="427" plate="KT6HMVO" dimension="0" color="0,0,0,245,245,245,0,0,0,0,0,0" posX="2312.1001" posY="2430.8999" posZ="-7.2" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Esperanto) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="419" plate="JDH9FS4" dimension="0" color="93,27,32,32,32,44,0,0,0,0,0,0" posX="-1886.6" posY="-957.59998" posZ="32" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Euros) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="587" plate="3NULT58" dimension="0" color="31,37,59,245,245,245,0,0,0,0,0,0" posX="2207.6001" posY="1293.2" posZ="10.6" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Faggio) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="462" plate="I5Y5QV3" dimension="0" color="214,218,214,214,218,214,0,0,0,0,0,0" posX="1892.4" posY="2092.5" posZ="10.5" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Farm Trailer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="610" plate="NNMAAUD" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="-49.4" posY="-210.3" posZ="1.1" rotX="0" rotY="0" rotZ="173.998"></exportable>
-- <exportable id="vehicle (FBI Rancher) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="490" plate="LVEZSIC" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="-1287.3" posY="2506.8999" posZ="87.3" rotX="0" rotY="0" rotZ="120"></exportable>
-- <exportable id="vehicle (FBI Truck) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="528" plate="6T9BAUT" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="1558.8" posY="-1710.8" posZ="6.1" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (FCR-900) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="521" plate="JOUSLBT" dimension="0" color="57,90,131,163,173,198,0,0,0,0,0,0" posX="1174.6" posY="1365.5" posZ="10.5" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Feltzer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="533" plate="VYELZ8K" dimension="0" color="32,32,44,245,245,245,0,0,0,0,0,0" posX="-20.5" posY="-2498.1001" posZ="36.4" rotX="0" rotY="0" rotZ="122"></exportable>
-- <exportable id="vehicle (Fire Truck) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="407" plate="DWMPFVE" dimension="0" color="132,4,16,245,245,245,0,0,0,0,0,0" posX="1748.9" posY="-1455.8" posZ="13.9" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Fire Truck Ladder) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="544" plate="P3SOMS4" dimension="0" color="132,4,16,245,245,245,0,0,0,0,0,0" posX="-2063.7" posY="74.8" posZ="28.8" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Flash) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="565" plate="0Z5K5J8" dimension="0" color="124,28,42,124,28,42,0,0,0,0,0,0" posX="568.5" posY="-1131.3" posZ="50.4" rotX="0" rotY="0" rotZ="211.995"></exportable>
-- <exportable id="vehicle (Flatbed) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="455" plate="NQHILHQ" dimension="0" color="77,50,47,109,24,34,0,0,0,0,0,0" posX="-535.7998" posY="-499.5" posZ="26.1" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Forklift) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="530" plate="XVS73IX" dimension="0" color="68,98,79,245,245,245,0,0,0,0,0,0" posX="-1054.8" posY="-695.09998" posZ="32.2" rotX="0" rotY="0" rotZ="359.996"></exportable>
-- <exportable id="vehicle (Fortune) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="526" plate="XLGW9NL" dimension="0" color="115,14,26,245,245,245,0,0,0,0,0,0" posX="1442.4004" posY="1999.2002" posZ="10.7" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Freeway) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="463" plate="B85CMVV" dimension="0" color="105,30,59,105,30,59,0,0,0,0,0,0" posX="1144.4" posY="-1101.1" posZ="25.4" rotX="0" rotY="0" rotZ="269.996"></exportable>
-- <exportable id="vehicle (Freight) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="537" plate="79LO5H7" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="30.1" posY="-268.79999" posZ="3.8" rotX="0" rotY="0" rotZ="268"></exportable>
-- <exportable id="vehicle (Freight Train Flatbed) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="569" plate="BDHXFP7" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="105.2" posY="-257.79999" posZ="3.1" rotX="0" rotY="0" rotZ="324"></exportable>
-- <exportable id="vehicle (Glendale) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="466" plate="7CNY1JU" dimension="0" color="51,95,63,164,160,150,0,0,0,0,0,0" posX="2051.8" posY="-1694.5" posZ="13.5" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Glenshit) (2)" sirens="false" paintjob="3" interior="0" alpha="255" model="604" plate="0BGWEBP" dimension="0" color="89,110,135,89,110,135,0,0,0,0,0,0" posX="-782.20001" posY="2768.6001" posZ="45.6" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Greenwood) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="492" plate="Z26QXWA" dimension="0" color="123,113,94,99,92,90,0,0,0,0,0,0" posX="2522" posY="-1673.9" posZ="14.8" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Hermes) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="474" plate="GBCA74A" dimension="0" color="108,132,149,245,245,245,0,0,0,0,0,0" posX="2195.1001" posY="-1052.8" posZ="49.6" rotX="0" rotY="0" rotZ="116.004"></exportable>
-- <exportable id="vehicle (Hotdog) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="588" plate="DWE8Y85" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="-909.90002" posY="1992.1" posZ="61" rotX="0" rotY="0" rotZ="310"></exportable>
-- <exportable id="vehicle (Hotknife) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="434" plate="TSDP789" dimension="0" color="157,152,114,157,152,114,0,0,0,0,0,0" posX="-2068.5" posY="-83.7" posZ="35.3" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Hotring Racer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="494" plate="XNB8SMU" dimension="0" color="109,108,110,31,37,59,0,0,0,0,0,0" posX="1354.1" posY="-628.5" posZ="109.1" rotX="0" rotY="0" rotZ="18"></exportable>
-- <exportable id="vehicle (Hotring Racer 2) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="503" plate="SY7F0PE" dimension="0" color="98,68,40,37,37,39,0,0,0,0,0,0" posX="-2529.7" posY="2368.8" posZ="5" rotX="0" rotY="0" rotZ="268"></exportable>
-- <exportable id="vehicle (Hotring Racer 3) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="502" plate="VM1XF4V" dimension="0" color="32,32,44,145,115,71,0,0,0,0,0,0" posX="2891.2" posY="2376" posZ="10.8" rotX="0" rotY="0" rotZ="89.996"></exportable>
-- <exportable id="vehicle (HPV1000) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="523" plate="YB29RKU" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="2764.5" posY="1432.7" posZ="10.2" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Hunter) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="425" plate="2T0DEJ8" dimension="0" color="95,10,21,0,0,0,0,0,0,0,0,0" posX="-1608.2002" posY="287" posZ="8" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Huntley) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="579" plate="JVD7IXL" dimension="0" color="124,28,42,124,28,42,0,0,0,0,0,0" posX="1130.4" posY="2195.1001" posZ="16.8" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Hustler) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="545" plate="JMR0467" dimension="0" color="34,25,24,155,159,157,0,0,0,0,0,0" posX="2401" posY="-1719.6" posZ="13.6" rotX="0" rotY="0" rotZ="192"></exportable>
-- <exportable id="vehicle (Hydra) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="520" plate="C9OJSU5" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="-1456.7" posY="501.10001" posZ="12.1" rotX="0" rotY="0" rotZ="276"></exportable>
-- <exportable id="vehicle (Infernus) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="411" plate="O3Z8H3W" dimension="0" color="34,52,87,245,245,245,0,0,0,0,0,0" posX="2128.7" posY="2356.3" posZ="10.5" rotX="0" rotY="0" rotZ="89.996"></exportable>
-- <exportable id="vehicle (Intruder) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="546" plate="LDJ1R20" dimension="0" color="102,28,38,45,58,53,0,0,0,0,0,0" posX="854" posY="-1512.5" posZ="12.9" rotX="8" rotY="0" rotZ="257.995"></exportable>
-- <exportable id="vehicle (Jester) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="559" plate="TGCUGUC" dimension="0" color="88,89,90,189,190,198,0,0,0,0,0,0" posX="-1578.7" posY="43" posZ="17.1" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Jetmax) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="493" plate="EG7IW4A" dimension="0" color="37,37,39,88,89,90,0,0,0,0,0,0" posX="-2971" posY="494.39999" posZ="0" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Journey) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="508" plate="2338EGL" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="-2349.8999" posY="-1611.1" posZ="484.10001" rotX="0" rotY="0" rotZ="250"></exportable>
-- <exportable id="vehicle (Kart) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="571" plate="8APWT0M" dimension="0" color="101,106,121,105,30,59,0,0,0,0,0,0" posX="828.40002" posY="-2038.8" posZ="12.2" rotX="0" rotY="0" rotZ="352"></exportable>
-- <exportable id="vehicle (Landstalker) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="400" plate="L3XR04H" dimension="0" color="32,32,44,245,245,245,0,0,0,0,0,0" posX="2445.8" posY="697.90002" posZ="11.6" rotX="0" rotY="0" rotZ="96"></exportable>
-- <exportable id="vehicle (Launch) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="595" plate="RT4JRBY" dimension="0" color="89,110,135,59,78,120,0,0,0,0,0,0" posX="-1443.8" posY="504" posZ="0" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Leviathan) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="417" plate="MDRBL49" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="2615.8999" posY="2721.3999" posZ="37" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Linerunner) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="403" plate="6L46CFK" dimension="0" color="31,37,59,245,245,245,0,0,0,0,0,0" posX="597.59998" posY="1648" posZ="7.7" rotX="0" rotY="0" rotZ="66"></exportable>
-- <exportable id="vehicle (Majestic) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="517" plate="7URHNNY" dimension="0" color="34,25,24,37,37,39,0,0,0,0,0,0" posX="2805.1001" posY="-1952.3" posZ="13.5" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Manana) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="410" plate="WPK5M95" dimension="0" color="94,112,114,245,245,245,0,0,0,0,0,0" posX="-1425.6" posY="-21.5" posZ="5.7" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Marquis) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="484" plate="8J8GU58" dimension="0" color="132,137,136,132,148,171,0,0,0,0,0,0" posX="-1720.1" posY="1436.5" posZ="0" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Maverick) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="487" plate="AN474PW" dimension="0" color="151,149,146,124,28,42,0,0,0,0,0,0" posX="2091.3" posY="2415" posZ="74.8" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Merit) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="551" plate="7MNK6NX" dimension="0" color="31,37,59,245,245,245,0,0,0,0,0,0" posX="-1703.4004" posY="1024.5" posZ="17.5" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Mesa) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="500" plate="UEG3DHC" dimension="0" color="34,25,24,77,50,47,0,0,0,0,0,0" posX="-2406.2" posY="-2181.7" posZ="33.5" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Monster 1) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="444" plate="AQK27UP" dimension="0" color="132,148,171,214,218,214,0,0,0,0,0,0" posX="-77" posY="-1552.1" posZ="3.1" rotX="0" rotY="0" rotZ="230"></exportable>
-- <exportable id="vehicle (Monster 2) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="556" plate="RGHS46I" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="2681.8" posY="-1672.7" posZ="9.9" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Monster 3) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="557" plate="AAOZYN0" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="-1786.7" posY="1205" posZ="25.6" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Moonbeam) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="418" plate="MIMB1UN" dimension="0" color="111,103,95,111,103,95,0,0,0,0,0,0" posX="1347.1" posY="205.89999" posZ="19.7" rotX="0" rotY="0" rotZ="336"></exportable>
-- <exportable id="vehicle (Mountain Bike) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="510" plate="JT6591A" dimension="0" color="157,152,114,157,152,114,0,0,0,0,0,0" posX="-258.5" posY="1170.9" posZ="20.6" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Mower) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="572" plate="842H44O" dimension="0" color="32,75,107,245,245,245,0,0,0,0,0,0" posX="301.39999" posY="-1193.3" posZ="80.6" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Mr. Whoopee) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="423" plate="CNG459X" dimension="0" color="245,245,245,90,87,82,0,0,0,0,0,0" posX="-240.89999" posY="2594.7" posZ="62.8" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Mule) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="414" plate="YBFYX1I" dimension="0" color="106,122,140,245,245,245,0,0,0,0,0,0" posX="2175.2" posY="-2266.5" posZ="13.5" rotX="0" rotY="0" rotZ="230"></exportable>
-- <exportable id="vehicle (Nebula) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="516" plate="6ZJHF42" dimension="0" color="38,55,57,245,245,245,0,0,0,0,0,0" posX="1671.6" posY="-1713.4" posZ="20.4" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Nevada) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="553" plate="LN2D8OT" dimension="0" color="111,130,151,57,90,131,0,0,0,0,0,0" posX="-1167.4" posY="-431.39999" posZ="16.4" rotX="0" rotY="0" rotZ="4"></exportable>
-- <exportable id="vehicle (News Chopper) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="488" plate="RCEMI94" dimension="0" color="42,119,161,165,169,167,0,0,0,0,0,0" posX="-1928.5" posY="626.7002" posZ="145.60001" rotX="0" rotY="0" rotZ="219.996"></exportable>
-- <exportable id="vehicle (Newsvan) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="582" plate="Y0USTUS" dimension="0" color="111,103,95,70,89,122,0,0,0,0,0,0" posX="-2531.8999" posY="-602.90002" posZ="132.7" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (NRG-500) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="522" plate="FKHPR5O" dimension="0" color="76,117,183,14,49,109,0,0,0,0,0,0" posX="2791.2" posY="-1459.3" posZ="19.9" rotX="0" rotY="0" rotZ="272"></exportable>
-- <exportable id="vehicle (Oceanic) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="467" plate="56GG7I2" dimension="0" color="156,156,152,245,245,245,0,0,0,0,0,0" posX="2571.5" posY="-1102.5" posZ="66.1" rotX="0" rotY="0" rotZ="46"></exportable>
-- <exportable id="vehicle (Packer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="443" plate="RGPO0ZU" dimension="0" color="59,78,120,245,245,245,0,0,0,0,0,0" posX="2384.7998" posY="2802.40039" posZ="11.6" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Patriot) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="470" plate="QTI4B1J" dimension="0" color="95,10,21,0,0,0,0,0,0,0,0,0" posX="-1238.1" posY="449.60001" posZ="7.3" rotX="0" rotY="0" rotZ="60"></exportable>
-- <exportable id="vehicle (PCJ-600) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="461" plate="PB55X8C" dimension="0" color="32,32,44,245,245,245,0,0,0,0,0,0" posX="435.29999" posY="2546.6001" posZ="15.9" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Perennial) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="404" plate="GGWEKL6" dimension="0" color="31,37,59,31,37,59,0,0,0,0,0,0" posX="741.79999" posY="381.60001" posZ="23" rotX="0" rotY="0" rotZ="279.997"></exportable>
-- <exportable id="vehicle (Phoenix) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="603" plate="TNNOIM9" dimension="0" color="132,148,171,245,245,245,0,0,0,0,0,0" posX="866.79999" posY="-712" posZ="105.7" rotX="0" rotY="0" rotZ="320"></exportable>
-- <exportable id="vehicle (Picador) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="600" plate="9XIN53B" dimension="0" color="101,106,121,101,106,121,0,0,0,0,0,0" posX="2473.6001" posY="-1693.4" posZ="13.4" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Pizzaboy) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="448" plate="FN2S80L" dimension="0" color="132,4,16,215,142,16,0,0,0,0,0,0" posX="2121.2002" posY="-1782.2998" posZ="13.1" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Police LS) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="596" plate="SGBL3FK" dimension="0" color="0,0,0,245,245,245,0,0,0,0,0,0" posX="1595" posY="-1605.8" posZ="13.2" rotX="0" rotY="0" rotZ="2"></exportable>
-- <exportable id="vehicle (Police LV) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="598" plate="QI2EMNA" dimension="0" color="0,0,0,245,245,245,0,0,0,0,0,0" posX="2238.7" posY="2471.1001" posZ="3.1" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Police Maverick) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="497" plate="E68ZYU0" dimension="0" color="0,0,0,245,245,245,0,0,0,0,0,0" posX="1565.3" posY="-1704.4" posZ="28.7" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Police Ranger) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="599" plate="7IBEH7N" dimension="0" color="0,0,0,245,245,245,0,0,0,0,0,0" posX="-1400.4" posY="2634.8" posZ="56.1" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Police SF) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="597" plate="WRGMW57" dimension="0" color="0,0,0,245,245,245,0,0,0,0,0,0" posX="-1637.9" posY="686.09998" posZ="-5.4" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Pony) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="413" plate="AQP6UCU" dimension="0" color="105,88,83,245,245,245,0,0,0,0,0,0" posX="545.70001" posY="-1887.1" posZ="3.7" rotX="0" rotY="0" rotZ="279.998"></exportable>
-- <exportable id="vehicle (Predator) (2)" sirens="false" paintjob="3" interior="0" alpha="255" model="430" plate="SSZQ5TP" dimension="0" color="157,152,114,165,169,167,0,0,0,0,0,0" posX="2688.8" posY="-2311.5" posZ="0" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Premier) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="426" plate="3T5Y7QH" dimension="0" color="156,161,163,156,161,163,0,0,0,0,0,0" posX="-2644.6001" posY="1370" posZ="7" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Previon) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="436" plate="R6BDWLF" dimension="0" color="109,108,110,245,245,245,0,0,0,0,0,0" posX="-1201.6" posY="1815.5" posZ="41.6" rotX="0" rotY="0" rotZ="46"></exportable>
-- <exportable id="vehicle (Primo) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="547" plate="Y4TBZO9" dimension="0" color="98,68,40,245,245,245,0,0,0,0,0,0" posX="1957" posY="2583.6001" posZ="10.7" rotX="0" rotY="0" rotZ="20"></exportable>
-- <exportable id="vehicle (Quadbike) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="471" plate="Z571HVU" dimension="0" color="155,139,128,71,53,50,0,0,0,0,0,0" posX="-1635.6" posY="-2251" posZ="31" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Raindance) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="563" plate="VWZ9CUE" dimension="0" color="245,245,245,215,142,16,0,0,0,0,0,0" posX="268.79999" posY="-1872.4" posZ="3.3" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Rancher) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="489" plate="CSCK790" dimension="0" color="88,89,90,163,173,198,0,0,0,0,0,0" posX="-532.2998" posY="-175.7998" posZ="78.8" rotX="0" rotY="0" rotZ="177.99"></exportable>
-- <exportable id="vehicle (Rancher Lure) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="505" plate="MZ8I8C1" dimension="0" color="124,27,68,215,142,16,0,0,0,0,0,0" posX="-1609.7" posY="-2718.8" posZ="48.9" rotX="0" rotY="0" rotZ="54"></exportable>
-- <exportable id="vehicle (RC Bandit) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="441" plate="MZY44E0" dimension="0" color="116,29,40,39,47,75,0,0,0,0,0,0" posX="-2239.8999" posY="128" posZ="34.3" rotX="0" rotY="0" rotZ="72"></exportable>
-- <exportable id="vehicle (RC Baron) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="464" plate="2A5SSJI" dimension="0" color="214,218,214,32,32,44,0,0,0,0,0,0" posX="-2240.1001" posY="129.60001" posZ="57.3" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (RC Cam) (2)" sirens="false" paintjob="3" interior="0" alpha="255" model="594" plate="74VB33A" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="2186.3999" posY="1663.5" posZ="10.3" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (RC Goblin) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="501" plate="X2SHXVO" dimension="0" color="214,218,214,32,32,44,0,0,0,0,0,0" posX="1271.5" posY="295.20001" posZ="20.1" rotX="0" rotY="0" rotZ="110"></exportable>
-- <exportable id="vehicle (RC Raider) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="465" plate="4OR7ZE1" dimension="0" color="214,218,214,32,32,44,0,0,0,0,0,0" posX="-2239.6001" posY="116" posZ="34.8" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (RC Tiger) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="564" plate="7LRB2VF" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="206.2" posY="1862.1" posZ="12.3" rotX="0" rotY="0" rotZ="304"></exportable>
-- <exportable id="vehicle (Reefer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="453" plate="A6IDDPA" dimension="0" color="158,164,171,158,164,171,0,0,0,0,0,0" posX="2359.2" posY="518.40002" posZ="0" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Regina) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="479" plate="PFN0F0B" dimension="0" color="34,25,24,151,149,146,0,0,0,0,0,0" posX="1112.8" posY="-306.60001" posZ="73.9" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Remington) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="534" plate="UPUX8CQ" dimension="0" color="70,89,122,70,89,122,0,0,0,0,0,0" posX="1804.4" posY="-1932" posZ="13.2" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Rhino) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="432" plate="5DT9DNZ" dimension="0" color="95,10,21,0,0,0,0,0,0,0,0,0" posX="278.89999" posY="1996.3" posZ="17.7" rotX="0" rotY="0" rotZ="250"></exportable>
-- <exportable id="vehicle (Roadtrain) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="515" plate="2H3URH8" dimension="0" color="101,106,121,164,160,150,0,0,0,0,0,0" posX="-1629.3" posY="-57.7" posZ="4.7" rotX="0" rotY="0" rotZ="135.994"></exportable>
-- <exportable id="vehicle (Romero) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="442" plate="A7GU2IC" dimension="0" color="0,0,0,37,37,39,0,0,0,0,0,0" posX="1547.9" posY="787.09998" posZ="10.8" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Rumpo) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="440" plate="Z23GD3D" dimension="0" color="77,50,47,77,50,47,0,0,0,0,0,0" posX="-1835.6" posY="-13.1" posZ="15.3" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Rustler) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="476" plate="LPBMS6P" dimension="0" color="76,117,183,215,142,16,0,0,0,0,0,0" posX="-1374.6" posY="-497.20001" posZ="15.3" rotX="0" rotY="0" rotZ="240"></exportable>
-- <exportable id="vehicle (S.W.A.T.) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="601" plate="JW8PVG7" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="2535.6001" posY="-1308.2" posZ="34.9" rotX="0" rotY="0" rotZ="60"></exportable>
-- <exportable id="vehicle (Sabre) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="475" plate="4SUNN0O" dimension="0" color="115,46,62,245,245,245,0,0,0,0,0,0" posX="-865.5" posY="1544.7" posZ="22.9" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Sadler) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="543" plate="PUL7Q09" dimension="0" color="189,190,198,175,177,177,0,0,0,0,0,0" posX="-376.29999" posY="-1447.7" posZ="25.7" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Sadlshit) (2)" sirens="false" paintjob="3" interior="0" alpha="255" model="605" plate="RF02FE8" dimension="0" color="115,14,26,0,0,0,155,139,128,0,0,0" posX="266.60001" posY="2887" posZ="11.1" rotX="9.945" rotY="6.092" rotZ="120.937"></exportable>
-- <exportable id="vehicle (Sanchez) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="468" plate="1SZ8KXB" dimension="0" color="22,34,72,22,34,72,0,0,0,0,0,0" posX="-2815" posY="-1511.8" posZ="139" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Sandking) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="495" plate="IJ0IISG" dimension="0" color="109,40,55,174,155,127,0,0,0,0,0,0" posX="-279.5" posY="1557.7" posZ="75.9" rotX="0" rotY="0" rotZ="130"></exportable>
-- <exportable id="vehicle (Savanna) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="567" plate="I9MS026" dimension="0" color="175,177,177,155,159,157,0,0,0,0,0,0" posX="2644.8" posY="-2033.6" posZ="13.5" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Seasparrow) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="447" plate="YSX9MGI" dimension="0" color="32,32,44,42,119,161,0,0,0,0,0,0" posX="261" posY="2935.3" posZ="0.7" rotX="0" rotY="0" rotZ="177.997"></exportable>
-- <exportable id="vehicle (Securicar) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="428" plate="LY1X2XD" dimension="0" color="38,55,57,32,32,44,0,0,0,0,0,0" posX="-2443.8" posY="526.09998" posZ="30.2" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Sentinel) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="405" plate="JGH7YUV" dimension="0" color="101,106,121,245,245,245,0,0,0,0,0,0" posX="922.59998" posY="-1293" posZ="13.7" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Shamal) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="519" plate="21XGA9B" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="1520.5" posY="-2460.5" posZ="14.6" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Skimmer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="460" plate="EWT9DI1" dimension="0" color="157,152,114,132,148,171,0,0,0,0,0,0" posX="-937" posY="2653.1001" posZ="42.4" rotX="0" rotY="0" rotZ="132"></exportable>
-- <exportable id="vehicle (Slamvan) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="535" plate="VMWZRAV" dimension="0" color="52,26,30,245,245,245,0,0,0,0,0,0" posX="1938.2" posY="-2083.1001" posZ="13.4" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Solair) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="458" plate="GKQPV4Q" dimension="0" color="66,31,33,245,245,245,0,0,0,0,0,0" posX="-2877.9" posY="783.1" posZ="34.9" rotX="350" rotY="0" rotZ="262"></exportable>
-- <exportable id="vehicle (Sparrow) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="469" plate="G549976" dimension="0" color="245,245,245,132,4,16,0,0,0,0,0,0" posX="1291.2" posY="-786.59998" posZ="96.6" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Speeder) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="452" plate="ZY4RTBC" dimension="0" color="245,245,245,134,68,110,0,0,0,0,0,0" posX="-418.5" posY="1160.5" posZ="0" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Squalo) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="446" plate="NOVE53R" dimension="0" color="0,0,0,0,0,0,0,0,0,245,245,245" posX="-2227.6001" posY="2403" posZ="0" rotX="0" rotY="0" rotZ="44"></exportable>
-- <exportable id="vehicle (Stafford) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="580" plate="RXNH1UQ" dimension="0" color="106,122,140,106,122,140,0,0,0,0,0,0" posX="-2738.8" posY="112.5" posZ="4.4" rotX="0" rotY="0" rotZ="179.996"></exportable>
-- <exportable id="vehicle (Stallion) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="439" plate="762QGPL" dimension="0" color="156,141,113,189,190,198,0,0,0,0,0,0" posX="2136.8" posY="-1365.5" posZ="25.1" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Stratum) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="561" plate="BZDXEZH" dimension="0" color="39,47,75,147,163,150,0,0,0,0,0,0" posX="-2125.3999" posY="649.79999" posZ="52.3" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Streak) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="538" plate="MZR0FPP" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="-114.4" posY="-220.89999" posZ="2.9" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Streak Train Trailer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="570" plate="TDKZ7BN" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="14.9" posY="-384.29999" posZ="8" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Street Clean Trailer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="611" plate="HSC86SM" dimension="0" color="0,0,0,0,0,0,0,0,0,0,0,0" posX="-73.8" posY="-211.7" posZ="5.1" rotX="0" rotY="0" rotZ="267.996"></exportable>
-- <exportable id="vehicle (Stretch) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="409" plate="FVVSPO9" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="-1756.2" posY="750.40002" posZ="24.8" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Stuntplane) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="513" plate="8TRQGU9" dimension="0" color="115,46,62,37,37,39,0,0,0,0,0,0" posX="290.79999" posY="2540" posZ="17.6" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Sultan) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="560" plate="ZFPPB6O" dimension="0" color="115,46,62,245,245,245,0,0,0,0,0,0" posX="-1660.7998" posY="1210.4004" posZ="13.5" rotX="0" rotY="0" rotZ="303.997"></exportable>
-- <exportable id="vehicle (Sunrise) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="550" plate="3NUI09W" dimension="0" color="70,89,122,70,89,122,0,0,0,0,0,0" posX="2658.3" posY="1166.9" posZ="10.7" rotX="0" rotY="0" rotZ="359.996"></exportable>
-- <exportable id="vehicle (Super GT) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="506" plate="BUXKID5" dimension="0" color="164,160,150,164,160,150,0,0,0,0,0,0" posX="-2679.5" posY="868.20001" posZ="76.2" rotX="8" rotY="0" rotZ="7.995"></exportable>
-- <exportable id="vehicle (Sweeper) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="574" plate="XB7UYLN" dimension="0" color="165,169,167,165,169,167,0,0,0,0,0,0" posX="1612.6" posY="-1893.7" posZ="13.3" rotX="0" rotY="0" rotZ="359.998"></exportable>
-- <exportable id="vehicle (Tahoma) (2)" sirens="false" paintjob="3" interior="0" alpha="255" model="566" plate="WWPPT75" dimension="0" color="88,88,83,189,190,198,0,0,0,0,0,0" posX="2186.5" posY="-1480.6" posZ="25.4" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Tampa) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="549" plate="3K4YFO7" dimension="0" color="96,26,35,109,122,136,0,0,0,0,0,0" posX="-1698.9" posY="1035.3" posZ="45.1" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Tanker) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="514" plate="8TTL0D0" dimension="0" color="70,89,122,245,245,245,0,0,0,0,0,0" posX="-1957.4" posY="2394" posZ="50.2" rotX="0" rotY="0" rotZ="292"></exportable>
-- <exportable id="vehicle (Taxi) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="420" plate="BCPLN2Q" dimension="0" color="215,142,16,245,245,245,0,0,0,0,0,0" posX="372.10001" posY="-2043.4" posZ="7.5" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Tornado) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="576" plate="R0GQL6P" dimension="0" color="96,26,35,189,190,198,0,0,0,0,0,0" posX="2855.5" posY="-1353.8" posZ="10.8" rotX="0" rotY="0" rotZ="310"></exportable>
-- <exportable id="vehicle (Towtruck) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="525" plate="LYNVHJT" dimension="0" color="105,30,59,66,31,33,0,0,0,0,0,0" posX="-1908.8" posY="-1666.5" posZ="23" rotX="0" rotY="0" rotZ="250"></exportable>
-- <exportable id="vehicle (Tractor) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="531" plate="O3QW65X" dimension="0" color="34,25,24,90,87,82,0,0,0,0,0,0" posX="-1211.3" posY="-933.70001" posZ="128.5" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Trailer (Stairs)) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="608" plate="FLBT6QB" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="21" posY="-346.20001" posZ="5.9" rotX="0" rotY="0" rotZ="92"></exportable>
-- <exportable id="vehicle (Trailer (Tanker Commando)) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="584" plate="HHW281B" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="-44.5" posY="-359.10001" posZ="6.6" rotX="0" rotY="0" rotZ="300"></exportable>
-- <exportable id="vehicle (Trailer 1) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="435" plate="3MZYE1I" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="-61.2998" posY="-304.09961" posZ="6.1" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Trailer 2) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="450" plate="I7GNJR2" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="-100.8" posY="-310.60001" posZ="2.1" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Trailer 3) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="591" plate="AJ81GO0" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="11.7002" posY="-220.2998" posZ="6.1" rotX="0" rotY="0" rotZ="83.996"></exportable>
-- <exportable id="vehicle (Tram) (2)" sirens="false" paintjob="3" interior="0" alpha="255" model="449" plate="I38U5HL" dimension="0" color="245,245,245,96,26,35,0,0,0,0,0,0" posX="152.89999" posY="-311.60001" posZ="3.1" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Trashmaster) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="408" plate="VPFB886" dimension="0" color="165,169,167,165,169,167,0,0,0,0,0,0" posX="-1857.1" posY="-1614.7" posZ="22.5" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Tropic) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="454" plate="XW61K5B" dimension="0" color="165,169,167,165,169,167,0,0,0,0,0,0" posX="-1475.6" posY="709" posZ="0" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Tug) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="583" plate="6X3S5G2" dimension="0" color="245,245,245,245,245,245,0,0,0,0,0,0" posX="-1338.9" posY="-304.39999" posZ="13.6" rotX="0" rotY="0" rotZ="314"></exportable>
-- <exportable id="vehicle (Turismo) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="451" plate="Y6YJN02" dimension="0" color="27,55,109,27,55,109,0,0,0,0,0,0" posX="2323.3" posY="1458.7" posZ="32.6" rotX="0" rotY="0" rotZ="272"></exportable>
-- <exportable id="vehicle (Uranus) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="558" plate="NAOLJW0" dimension="0" color="34,25,24,245,245,245,0,0,0,0,0,0" posX="-1953.3" posY="296.60001" posZ="40.8" rotX="0" rotY="0" rotZ="130"></exportable>
-- <exportable id="vehicle (Utility Van) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="552" plate="3XLI0BH" dimension="0" color="165,169,167,115,24,39,0,0,0,0,0,0" posX="-1465.2" posY="-207.3" posZ="13.9" rotX="0" rotY="0" rotZ="79.999"></exportable>
-- <exportable id="vehicle (Vincent) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="540" plate="BES3CIX" dimension="0" color="156,161,163,156,161,163,0,0,0,0,0,0" posX="1248.9" posY="-805.09998" posZ="84.1" rotX="0" rotY="0" rotZ="180"></exportable>
-- <exportable id="vehicle (Virgo) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="491" plate="2QKIMNB" dimension="0" color="164,167,165,88,88,83,0,0,0,0,0,0" posX="2796.3999" posY="-1580.7" posZ="10.8" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Voodoo) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="412" plate="4P2Z9UH" dimension="0" color="99,92,90,245,245,245,0,0,0,0,0,0" posX="-2185" posY="-209.7" posZ="36.5" rotX="0" rotY="0" rotZ="270"></exportable>
-- <exportable id="vehicle (Vortex) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="539" plate="AOOQ35L" dimension="0" color="32,32,44,54,65,85,0,0,0,0,0,0" posX="2000.6" posY="1539.3" posZ="13.2" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Walton) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="478" plate="FZFVN6V" dimension="0" color="109,122,136,245,245,245,0,0,0,0,0,0" posX="-1446.9" posY="-1541.1" posZ="101.8" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (Washington) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="421" plate="6RLKGTU" dimension="0" color="34,25,24,245,245,245,0,0,0,0,0,0" posX="-702.09998" posY="947.40002" posZ="12.4" rotX="0" rotY="0" rotZ="64.495"></exportable>
-- <exportable id="vehicle (Wayfarer) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="586" plate="UAK1WKT" dimension="0" color="132,148,171,245,245,245,0,0,0,0,0,0" posX="-2143" posY="-2447" posZ="30.2" rotX="0" rotY="0" rotZ="142"></exportable>
-- <exportable id="vehicle (Willard) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="529" plate="QOARHK7" dimension="0" color="45,58,53,45,58,53,0,0,0,0,0,0" posX="2412.8999" posY="1.9" posZ="26.2" rotX="0" rotY="0" rotZ="90"></exportable>
-- <exportable id="vehicle (Windsor) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="555" plate="JK1CQLL" dimension="0" color="105,30,59,245,245,245,0,0,0,0,0,0" posX="1029.4" posY="-811.29999" posZ="101.6" rotX="0" rotY="0" rotZ="22"></exportable>
-- <exportable id="vehicle (Yankee) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="456" plate="IPBBEF9" dimension="0" color="54,65,85,148,157,159,0,0,0,0,0,0" posX="2706.1001" posY="905.79999" posZ="10.8" rotX="0" rotY="0" rotZ="179.999"></exportable>
-- <exportable id="vehicle (Yosemite) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="554" plate="IG9IX9T" dimension="0" color="214,218,214,132,148,171,0,0,0,0,0,0" posX="2154.7" posY="-99" posZ="2.9" rotX="0" rotY="0" rotZ="0"></exportable>
-- <exportable id="vehicle (ZR-350) (1)" sirens="false" paintjob="3" interior="0" alpha="255" model="477" plate="970IBJH" dimension="0" color="31,37,59,245,245,245,0,0,0,0,0,0" posX="1467" posY="1017.8" posZ="10.7" rotX="0" rotY="0" rotZ="180"></exportable>

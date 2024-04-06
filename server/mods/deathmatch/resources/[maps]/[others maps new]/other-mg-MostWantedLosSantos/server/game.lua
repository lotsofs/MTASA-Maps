-- global for debug purposes atm
jobs = {}
exits = {}
playersByClient = {}

local randomMoneyScaler = 1000 -- random numbers used to scale quota for big $$$

lastJobId = 0
availableJobs = 0
lastSpawnedJobAt = 0
totalMoneyProgress = 0
moneyEscapeQuota = 0
lastExitId = 0
lastSpawnedExitAt = 0
gameState = g_COREGAME_STATE

addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging", getRootElement(), function(state)
	if state == "GridCountdown" then
		for _, player in pairs(getElementsByType("player")) do
			playersByClient[player] = Player:new(player)
		end

		setTimer(function()
			preGameSetup()
			perkSetup(g_PERK_SELECTION_DURATION)

			setTimer(function()
				startGameLoop()
			end, g_PERK_SELECTION_DURATION, 1)
		end, 1000, 1)
	end
end)

function perkSetup(perkSelectionDuration)
	function selectPerk(player, _, _, perkId)
		playersByClient[player]:setPerk(perkId)
	end

	for player in pairs(playersByClient) do
		toggleAllControls(player, false)
		bindKey(player, "1", "down", selectPerk, g_FUGITIVE_PERK.id)
		bindKey(player, "2", "down", selectPerk, g_MECHANIC_PERK.id)
		bindKey(player, "3", "down", selectPerk, g_HOTSHOT_PERK.id)
	end

	setTimer(function()
		for player in pairs(playersByClient) do
			toggleAllControls(player, true)
			unbindKey(player, "1", "down", selectPerk)
			unbindKey(player, "2", "down", selectPerk)
			unbindKey(player, "3", "down", selectPerk)
		end
	end, perkSelectionDuration, 1)
end

function startGameLoop()
	triggerClientEvent(getRootElement(), g_GAME_STATE_UPDATE_EVENT, resourceRoot, gameState)

	setTimer(function()
		maybeUpdateGameState()
		maybeSpawnExitPoint()
		maybeSpawnJob()
		updateJobProgress()
		checkPerks()
	end, 1000 / g_SERVER_TICK_RATE, 0)
end

function checkPerks()
	for _, player in pairs(playersByClient) do
		player:checkPerk()
	end
end

function maybeUpdateGameState()
	if gameState == g_COREGAME_STATE and totalMoneyProgress >= moneyEscapeQuota then
		updateGameState(g_ENDGAME_STATE)
	elseif gameState == g_ENDGAME_STATE and totalMoneyProgress >= moneyEscapeQuota * g_SECRET_ENDING_REQUIREMENT_MULTIPLIER then
		updateGameState(g_ENDENDGAME_STATE)
	elseif gameState ~= g_BADEND_STATE then
		local criminals = getPlayersInTeam(g_CriminalTeam)
		for _, criminal in ipairs(criminals) do
			if getElementData(criminal, "state") == "alive" then
				return
			end
		end

		updateGameState(g_BADEND_STATE)
	end
end

function updateGameState(state)
	if state == g_ENDGAME_STATE then
		lastSpawnedExitAt = getRealTime().timestamp

		for _, criminal in ipairs(getPlayersInTeam(g_CriminalTeam)) do
			createBlipAttachedTo(criminal, 0, 2, 223, 179, 0, 255, 6, 80085)
		end
	elseif state == g_ENDENDGAME_STATE then
		for _, criminal in ipairs(getPlayersInTeam(g_CriminalTeam)) do
			bindKey(criminal, "vehicle_secondary_fire", "down", function()
				giveWeapon(criminal, 30, 9999, true) -- ak47
				setPedDoingGangDriveby(criminal, not isPedDoingGangDriveby(criminal))
			end)
		end
	elseif state == g_BADEND_STATE then
		-- no criminals, so guess its ogre?
	end

	gameState = state
	triggerClientEvent(getRootElement(), g_GAME_STATE_UPDATE_EVENT, resourceRoot, state)
end

function maybeSpawnExitPoint()
	if gameState == g_ENDGAME_STATE or gameState == g_ENDENDGAME_STATE then
		if lastSpawnedExitAt < getRealTime().timestamp - (g_DELAY_BETWEEN_EXIT_SPAWN / 1000) then
			lastExitId = lastExitId + 1
			spawnExitPoint(lastExitId)
			if lastExitId == #exits then
				lastExitId = 0
			end
		end
	end
end

function spawnExitPoint(id)
	local exitPoint = exits[id]
	if not exitPoint.active then
		exitPoint:enable()
		lastSpawnedExitAt = getRealTime().timestamp
	end
end

function maybeSpawnJob()
	if availableJobs < countPlayersInTeam(g_CriminalTeam) * g_AVAILABLE_JOBS_MULTIPLIER + 10 then
		if lastSpawnedJobAt < getRealTime().timestamp - (g_DELAY_BETWEEN_JOB_SPAWN / 1000) then
			lastJobId = lastJobId + 1
			spawnJob(lastJobId)
			if lastJobId == #jobs then
				lastJobId = 0
			end
		end
	end
end

function spawnJob(id)
	local job = jobs[id]
	if job:isComplete() then
		job:enable()
		availableJobs = availableJobs + 1
		lastSpawnedJobAt = getRealTime().timestamp
	end
end


function finishJob(job)
	job:finish()

	availableJobs = availableJobs - 1
	totalMoneyProgress = totalMoneyProgress + job:money()

	triggerClientEvent(getRootElement(), g_MONEY_UPDATE_EVENT, resourceRoot, {
		money = totalMoneyProgress * randomMoneyScaler,
		moneyQuota = moneyEscapeQuota * randomMoneyScaler
	})
end

function assignJob(job, player)
	job:assign(player)
end

function unassignJob(job, player)
	job:unassign(player)
end

function updateJobProgress()
	for _, job in ipairs(jobs) do
		local completed = job:tick()

		if completed then
			finishJob(job)
		end
	end
end

function preGameSetup()
	-- attempt to remove player blips
	for _, blip in pairs(getElementsByType("blip")) do
		destroyElement(blip)
	end

	-- set up exit points and shuffle
	for _, group in ipairs(getElementsByType("exit_group", resourceRoot)) do
		-- not sure what the duplicates are
		if #getElementChildren(group) > 0 then
			exits[#exits + 1] = Exit:new(group)
		end
	end

	shuffle(exits)

	-- randomly select cops and criminals
	local players = {}
	for _, player in pairs(playersByClient) do
		players[#players + 1] = player
	end

	shuffle(players)

	local policeCount = math.ceil(#players / g_CRIMINALS_PER_COP)
	if #players == 1 then
		policeCount = 0
	end

	for i = 1, policeCount do
		players[i]:setRole(g_POLICE_ROLE) -- may not succeed if not enough spawn points
	end
	for i = countPlayersInTeam(g_PoliceTeam) + 1, #players do
		players[i]:setRole(g_CRIMINAL_ROLE)
	end

	-- set up player based limits
	moneyEscapeQuota = countPlayersInTeam(g_CriminalTeam) * 10 + 2
	triggerClientEvent(getRootElement(), g_MONEY_UPDATE_EVENT, resourceRoot, {
		money = 0,
		moneyQuota = moneyEscapeQuota * randomMoneyScaler
	})

	-- shuffle jobs into order they will spawn in
	local jobElements = {}
	for _, job in ipairs({
		g_PICKUP_JOB,
		g_GROUP_JOB,
		g_DELIVERY_JOB,
		g_EXTORTION_JOB
	}) do
		for _, element in ipairs(getElementsByType(job.elementType, resourceRoot)) do
			jobElements[#jobElements + 1] = { element = element, job = job }
		end
	end

	shuffle(jobElements)

	for id, element in ipairs(jobElements) do
		local job = nil
		if element.job == g_DELIVERY_JOB then
			job = DeliveryJob:new(id, element.job.type, getElementPosition(element.element))
		elseif element.job == g_GROUP_JOB then
			job = GroupJob:new(id, element.job.type, getElementPosition(element.element))
		elseif element.job == g_EXTORTION_JOB then
			job = ExtortionJob:new(id, element.job.type, getElementPosition(element.element))
		else
			job = Job:new(id, element.job.type, getElementPosition(element.element))
		end

		jobs[#jobs + 1] = job

		local col = createColCircle(job.pos.x, job.pos.y, g_JOBS_BY_TYPE[job.type].zoneRadius)
		addEventHandler("onColShapeHit", col, function(element)
			local player, vehicle = toPlayer(element)
			if not player then return end
			if not vehicle then return end -- in case of spectator?
			if getPlayerTeam(player.player) ~= g_CriminalTeam then return end

			local _, _, z = getElementPosition(vehicle)
			if math.abs(z - job.pos.z) > 5 then return end

			if not job:isAvailable() then return end

			assignJob(job, player)
		end)
		addEventHandler("onColShapeLeave", col, function(element)
			local player = toPlayer(element)
			if not player then return end
			if not job:isAssignedTo(player) then return end
			-- can't check Z but don't care?

			unassignJob(job, player)
		end)
	end

	-- start listening for client side completion of jobs (honk job, delivery job)
	addEvent(g_FINISH_JOB_EVENT, true)
	addEventHandler(g_FINISH_JOB_EVENT, getRootElement(), function(id)
		finishJob(jobs[id])
	end)
end

function shuffle(a)
	for i = #a, 2, -1 do
		local j = math.random(i)
		a[i], a[j] = a[j], a[i]
	end
end

function toPlayer(element)
	if getElementType(element) ~= "vehicle" then return false end
	return playersByClient[getVehicleOccupant(element)], element
end

if g_DEBUG_MODE then
	addCommandHandler("ugs", function(ply, arg, s)
		print(arg, s)
		updateGameState(s)
	end)

	addCommandHandler("sep", function(ply, arg, id)
		print(arg, id)
		spawnExitPoint(tonumber(id))
	end)

	addCommandHandler("sj", function(ply, arg, id)
		print(arg, id)
		spawnJob(tonumber(id))
	end)

	addCommandHandler("fj", function(ply, arg, id)
		print(arg, id)
		finishJob(jobs[tonumber(id)])
	end)

	addCommandHandler("aj", function(ply, arg, id)
		print(arg, id)
		assignJob(jobs[tonumber(id)], playersByClient[ply])
	end)

	addCommandHandler("uj", function(ply, arg, id)
		print(arg, id)
		unassignJob(jobs[tonumber(id)], playersByClient[ply])
	end)

	addCommandHandler("sr", function(ply, arg, r)
		print(arg, r)
		playersByClient[ply]:setRole(r)
	end)

	addCommandHandler("eee", function(ply, arg, ...)
		print(...)
		loadstring(...)()
	end)
end
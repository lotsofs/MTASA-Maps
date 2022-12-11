RaceMode = {}
RaceMode.__index = RaceMode

RaceMode.registeredModes = {}
RaceMode.instances = {}

function RaceMode:register(name)
	RaceMode.registeredModes[name] = self
	self.name = name
end

function RaceMode.getApplicableMode()
	for modeName,mode in pairs(RaceMode.registeredModes) do
		if mode:isApplicable() then
			return mode
		end
	end
	return RaceMode
end

function RaceMode:getName()
	return self.name
end

function RaceMode.getCheckpoints()
	return g_Checkpoints
end

function RaceMode.getCheckpoint(i)
	return g_Checkpoints[i]
end

function RaceMode.getNumberOfCheckpoints()
	return #g_Checkpoints
end

function RaceMode.checkpointsExist()
	return #g_Checkpoints > 0
end

function RaceMode.getSpawnpoints()
	return g_Spawnpoints
end

function RaceMode.getNumberOfSpawnpoints()
	return #g_Spawnpoints
end

function RaceMode.getSpawnpoint(i)
	return g_Spawnpoints[i]
end

function RaceMode.getOnfootSpawnpoints()
	return g_OnfootSpawnpoints
end

function RaceMode.getNumberOfOnfootSpawnpoints()
	return #g_OnfootSpawnpoints
end

function RaceMode.getOnfootSpawnpoint(i)
	return g_OnfootSpawnpoints[i]
end

function RaceMode.getMapOption(option)
	return g_MapOptions[option]
end

function RaceMode.isMapRespawn()
	return RaceMode.getMapOption('respawn') == 'timelimit'
end

function RaceMode.getPlayers()
	return g_Players
end

function RaceMode.setPlayerIsFinished(player)
	setPlayerFinished(player, true)
end

function RaceMode.isPlayerFinished(player)
	return isPlayerFinished(player)
end

function RaceMode.getPlayerVehicle(player)
	return g_Vehicles[player]
end

function RaceMode:setTimeLeft(timeLeft)
	if g_MapOptions.duration - self:getTimePassed() > timeLeft then
		g_MapOptions.duration = self:getTimePassed() + timeLeft
		TimerManager.destroyTimersFor("raceend")
		TimerManager.createTimerFor("map","raceend"):setTimer(raceTimeout, timeLeft, 1)
		clientCall(root, 'setTimeLeft', timeLeft)
	end
end

function RaceMode.endMap()
    if stateAllowsPostFinish() then
        gotoState('PostFinish')
        local text = g_GameOptions.randommaps and 'Next map starts in:' or 'Vote for next map starts in:'
        Countdown.create(1, RaceMode.startNextMapSelect, text, 255, 255, 255, 0.6, 2.5 ):start()
		triggerEvent('onPostFinish', root)
    end
end

function RaceMode.startNextMapSelect()
	if stateAllowsNextMapSelect() then
		gotoState('NextMapSelect')
		Countdown.destroyAll()
		destroyAllMessages()
		if g_GameOptions.randommaps then
			startRandomMap()
		else
			startNextMapVote()
		end
	end
end

-- Default functions

function RaceMode.isApplicable()
	return false
end

function RaceMode:create()
	local id = #RaceMode.instances + 1
	RaceMode.instances[id] = setmetatable(
		{
			id = id,
			checkpointBackups = {},  -- { player = { goingback = true/false, i = { vehicle = id, position = {x, y, z}, rotation = {x, y, z}, velocity = {x, y, z} } } }
			activePlayerList = {},
			finishedPlayerList = {},
		},
		self
	)
	return RaceMode.instances[id]
end

function RaceMode:launch()
	self.startTick = getTickCount()
	for _,spawnpoint in ipairs(RaceMode.getSpawnpoints()) do
		spawnpoint.used = nil
	end
	-- Put all relevant players into the active player list
	for _,player in ipairs(getElementsByType("player")) do
		if not isPlayerFinished(player) then
			addActivePlayer( player )
		end
	end
end

function RaceMode:getTimePassed()
	if self.startTick then
		return getTickCount() - self.startTick
	else
		return 0
	end
end

function RaceMode:getTimeRemaining()
	if self.startTick then
		return self.startTick + g_MapOptions.duration - getTickCount()
	else
		return 0
	end
end

function RaceMode:isRanked()
	return true
end

function RaceMode:getPlayerRank(queryPlayer)
	local rank = 1
	local queryCheckpoint = getPlayerCurrentCheckpoint(queryPlayer)
	local checkpoint

	-- Figure out rank amoung the active players
	for i,player in ipairs(getActivePlayers()) do
		if player ~= queryPlayer then
			checkpoint = getPlayerCurrentCheckpoint(player)
			if RaceMode.isPlayerFinished(player) or checkpoint > queryCheckpoint then
				rank = rank + 1
			elseif checkpoint == queryCheckpoint then
				if distanceFromPlayerToCheckpoint(player, checkpoint) < distanceFromPlayerToCheckpoint(queryPlayer, checkpoint) then
					rank = rank + 1
				end
			end
		end
	end

	-- Then add on the players that have finished
	rank = rank + getFinishedPlayerCount()
	return rank
end

-- Faster version of old updateRank
function RaceMode:updateRanks()
	-- Make a table with the active players
	local sortinfo = {}
	for i,player in ipairs(getActivePlayers()) do
		sortinfo[i] = {}
		sortinfo[i].player = player
		sortinfo[i].checkpoint = getPlayerCurrentCheckpoint(player)
		sortinfo[i].cpdist = distanceFromPlayerToCheckpoint(player, sortinfo[i].checkpoint )
	end
	-- Order by cp
	table.sort( sortinfo, function(a,b)
						return a.checkpoint > b.checkpoint or
							   ( a.checkpoint == b.checkpoint and a.cpdist < b.cpdist )
					  end )
	-- Copy back into active players list to speed up sort next time
	for i,info in ipairs(sortinfo) do
		g_CurrentRaceMode.activePlayerList[i] = info.player
	end
	-- Update data
	local rankOffset = getFinishedPlayerCount()
	for i,info in ipairs(sortinfo) do
		setElementData(info.player, 'race rank', i + rankOffset )
		setElementData(info.player, 'checkpoint', info.checkpoint-1 .. '/' .. #g_Checkpoints )
	end
	-- Make sure cp text looks good for finished players
	for i,player in ipairs(g_Players) do
		if isPlayerFinished(player) then
			setElementData(player, 'checkpoint', #g_Checkpoints .. '/' .. #g_Checkpoints )
		end
	end
	-- Make text look good at the start
	if not self.running then
		for i,player in ipairs(g_Players) do
			setElementData(player, 'race rank', 1 )
			setElementData(player, 'checkpoint', '0/' .. #g_Checkpoints )
		end
	end
end

function RaceMode:onPlayerJoin(player, spawnpoint)
	self.checkpointBackups[player] = {}
	self.checkpointBackups[player][0] = { 
		onfoot = false, borrowed = false,
		vehicle = spawnpoint.vehicle, position = spawnpoint.position, rotation = spawnpoint.rotation, velocity = {0, 0, 0}, turnvelocity = {0, 0, 0}, geardown = true, 
		vehicle2 = spawnpoint.vehicle, position2 = spawnpoint.position, rotation2 = spawnpoint.rotation, geardown2 = true, velocity2 = {0, 0, 0}, turnvelocity2 = {0, 0, 0}
	}
end

function RaceMode:onPlayerReachCheckpoint(player, checkpointNum)
	local rank = self:getPlayerRank(player)
	local time = self:getTimePassed()
	if checkpointNum < RaceMode.getNumberOfCheckpoints() then
		-- Regular checkpoint
		local vehicle = getPedOccupiedVehicle(player)
		local vehicle2 = RaceMode.getPlayerVehicle(player) -- We can have multiple vehicles now
		if (not vehicle) then
			self.checkpointBackups[player][checkpointNum] = {
				skin = getElementModel(player),
				onfoot = true ,
				borrowed = nil,
				vehicle = nil,
				position = {
					getElementPosition(player)
				},
				rotation = {
					getElementRotation(player)
				},
				velocity = {
					getElementVelocity(player)
				},
				turnvelocity = {
					0,0,0
				},
				interior = getElementInterior(player),
				geardown = false,
				hasNitro = false,
				jetpack = isPedWearingJetpack(player),
				vehicle2 = getElementModel(vehicle2),
				position2 = {getElementPosition(vehicle2)},
				rotation2 = {getElementRotation(vehicle2)},
				velocity2 = {getElementVelocity(vehicle2)},
				turnvelocity2 = {getElementAngularVelocity(vehicle2)},
				interior2 = getElementInterior(vehicle2),
				geardown2 = getVehicleLandingGearDown(vehicle2) or false,
				hasNitro2 = getVehicleUpgradeOnSlot(vehicle2, 8) > 0
			}
		elseif (vehicle == vehicle2) then
			self.checkpointBackups[player][checkpointNum] = {
				skin = getElementModel(player),
				onfoot = false ,
				borrowed = g_IVSpawns[vehicle],
				vehicle = getElementModel(vehicle),
				position = {
					getElementPosition(vehicle)
				},
				rotation = {
					getElementRotation(vehicle)
				},
				velocity = {
					getElementVelocity(vehicle)
				},
				turnvelocity = {
					getElementAngularVelocity(vehicle)
				},
				interior = getElementInterior(vehicle),
				geardown = getVehicleLandingGearDown(vehicle) or false,
				hasNitro = getVehicleUpgradeOnSlot(vehicle, 8) > 0,
			}
			triggerClientEvent(player, 'race:saveNosLevel', resourceRoot, checkpointNum)
		else
			self.checkpointBackups[player][checkpointNum] = {
				skin = getElementModel(player),
				onfoot = false ,
				borrowed = g_IVSpawns[vehicle],
				original = vehicle,
				vehicle = getElementModel(vehicle),
				position = {
					getElementPosition(vehicle)
				},
				rotation = {
					getElementRotation(vehicle)
				},
				velocity = {
					getElementVelocity(vehicle)
				},
				turnvelocity = {
					getElementAngularVelocity(vehicle)
				},
				interior = getElementInterior(vehicle),
				geardown = getVehicleLandingGearDown(vehicle) or false,
				hasNitro = getVehicleUpgradeOnSlot(vehicle, 8) > 0,
				
				vehicle2 = getElementModel(vehicle2),
				position2 = {getElementPosition(vehicle2)},
				rotation2 = {getElementRotation(vehicle2)},
				velocity2 = {getElementVelocity(vehicle2)},
				turnvelocity2 = {getElementAngularVelocity(vehicle2)},
				interior2 = getElementInterior(vehicle2),
				geardown2 = getVehicleLandingGearDown(vehicle2) or false,
				hasNitro2 = getVehicleUpgradeOnSlot(vehicle2, 8) > 0
			}
			triggerClientEvent(player, 'race:saveNosLevel', resourceRoot, checkpointNum)
		end
		self.checkpointBackups[player].goingback = true
		TimerManager.destroyTimersFor("checkpointBackup",player)
		TimerManager.createTimerFor("map","checkpointBackup",player):setTimer(lastCheckpointWasSafe, 5000, 1, self.id, player)
	else
		-- Finish reached
		rank = getFinishedPlayerCount() + 1
		RaceMode.setPlayerIsFinished(player)
		finishActivePlayer( player )
		setPlayerStatus( player, nil, "finished" )
		if rank == 1 then
            gotoState('SomeoneWon')
			showMessage('You have won the race!', 0, 255, 0, player)
			if self.rankingBoard then	-- Remove lingering labels
				self.rankingBoard:destroy()
			end
			self.rankingBoard = RankingBoard:create()
			if g_MapOptions.duration then
				self:setTimeLeft( math.max(g_GameOptions.percentagetimeafterfirstfinish * self:getTimePassed() / 100, g_MapOptions.timeafterfirstfinish ))
			end
		else
			showMessage('You finished ' .. rank .. ( (rank < 10 or rank > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[rank % 10] or 'th' ) .. '!', 0, 255, 0, player)
		end
		--Output a killmessage
		exports.killmessages:outputMessage(
			{
				{"image",path="img/killmessage.png",resource=getThisResource(),width=24},
				getPlayerName(player),
			},
			root,
			255,0,0
		)
		self.rankingBoard:add(player, time)
		if getActivePlayerCount() > 0 then
			TimerManager.createTimerFor("map",player):setTimer(clientCall, 5000, 1, player, 'Spectate.start', 'auto')
		else
			TimerManager.createTimerFor("map"):setTimer(
				function()
					gotoState('EveryoneFinished')
					self:setTimeLeft( 0 )
					RaceMode.endMap()
				end,
				50, 1 )
		end
	end
	if (g_Checkpoints[checkpointNum].trigger) then
		callTrigger(g_Checkpoints[checkpointNum].trigger, player)
	end
	return rank, time
end

function lastCheckpointWasSafe(id, player)
	if not isValidPlayer(player) then
		return
	end
	local self = RaceMode.instances[id]
	if self.checkpointBackups[player] then
		self.checkpointBackups[player].goingback = false
	end
end

function isValidPlayer(player)
 	return g_Players and table.find(g_Players, player)
end

function isValidPlayerVehicle(player,vehicle)
	if isValidPlayer(player) then
		if vehicle and (g_Vehicles[player] == vehicle or getElementData(vehicle, "raceiv.owner") == player or not getElementData(vehicle, "raceiv.owner")) then
			return true
		end
	end
	return false
end


function RaceMode:onPlayerWasted(player)
	if not self.checkpointBackups[player] then
		return
	end
	TimerManager.destroyTimersFor("checkpointBackup",player)
	if RaceMode.getMapOption('respawn') == 'timelimit' and not RaceMode.isPlayerFinished(source) then
        -- See if its worth doing a respawn
        local respawnTime       = RaceMode.getMapOption('respawntime')
        if self:getTimeRemaining() - respawnTime > 3000 then
            Countdown.create(respawnTime/1000, restorePlayer, 'You will respawn in:', 255, 255, 255, 0.25, 2.5, true, self.id, player):start(player)
        end
	    if RaceMode.getMapOption('respawntime') >= 5000 then
		    TimerManager.createTimerFor("map",player):setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
	    end
	end
	if g_MapOptions.respawn == 'none' then
		removeActivePlayer( player )
		TimerManager.createTimerFor("map",player):setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
		if getActivePlayerCount() < 1 and g_CurrentRaceMode.running then
			RaceMode.endMap()
		end
	end
end


function distanceFromVehicleToSpawnpoint(vehicle, spawnpoint)
    if vehicle then
	    local x, y, z = getElementPosition(vehicle)
	    return getDistanceBetweenPoints3D(x, y, z, unpack(spawnpoint.position))
    end
    return 0
end

function getSpaceAroundSpawnpoint(ignore,spawnpoint)
    local space = 100000
    for i,player in ipairs(g_Players) do
		if player ~= ignore then
			space = math.min(space, distanceFromVehicleToSpawnpoint(g_Vehicles[player], spawnpoint))
		end
    end
    return space
end

function hasSpaceAroundSpawnpoint(ignore,spawnpoint, requiredSpace)
    for i,player in ipairs(g_Players) do
		if player ~= ignore then
			if distanceFromVehicleToSpawnpoint(g_Vehicles[player], spawnpoint) < requiredSpace then
				return false
			end
        end
    end
    return true
end

local g_DoubleUpPos = 0
function RaceMode:pickFreeSpawnpoint(ignore)
    -- Use the spawnpoints from #1 to #numplayers as a pool to use
    local numToScan = math.min(getPlayerCount(), #g_Spawnpoints)
    -- Starting at a random place in the pool...
    local scanPos = math.random(1,numToScan)
    -- ...loop through looking for a free spot
    for i=1,numToScan do
        local idx = (i + scanPos) % numToScan + 1
        if hasSpaceAroundSpawnpoint(ignore,g_Spawnpoints[idx], 1) then
            return g_Spawnpoints[idx]
        end
    end
    -- If one can't be found, find the spot which has the most space
    local bestSpace = 0
    local bestMatch = 1
    for i=1,numToScan do
        local idx = (i + scanPos) % numToScan + 1
        local space = getSpaceAroundSpawnpoint(ignore,g_Spawnpoints[idx])
        if space > bestSpace then
            bestSpace = space
            bestMatch = idx
        end
    end
	-- If bestSpace is too small, assume all spawnpoints are taken, and start to double up
	if bestSpace < 0.1 then
		g_DoubleUpPos = ( g_DoubleUpPos + 1 ) % #g_Spawnpoints
		bestMatch = g_DoubleUpPos + 1
	end
    return g_Spawnpoints[bestMatch]
end

function freeSpawnpoint(i)
	if RaceMode.getSpawnpoint(i) then
		RaceMode.getSpawnpoint(i).used = nil
	end
end

-- Respawn Player
function restorePlayer(id, player, bNoFade, bDontFix)
	if not isValidPlayer(player) then
		return
	end
	local self = RaceMode.instances[id]
	if not bNoFade then
		clientCall(player, 'remoteStopSpectateAndBlack')
	end

	local checkpoint = getPlayerCurrentCheckpoint(player)
	if self.checkpointBackups[player].goingback and checkpoint > 1 then
		checkpoint = checkpoint - 1
		setPlayerCurrentCheckpoint(player, checkpoint)
	end
	self.checkpointBackups[player].goingback = true

	local vehicle = RaceMode.getPlayerVehicle(player)
	local vehicle2 = vehicle

	local bkp = self.checkpointBackups[player][checkpoint - 1]
	local spawnpoint
	if not RaceMode.checkpointsExist() or checkpoint==1 then
		spawnpoint = self:pickFreeSpawnpoint(player)

		bkp.onfoot = false
		bkp.position = spawnpoint.position
		bkp.rotation = spawnpoint.rotation
		bkp.geardown = true                 -- Fix landing gear state
		bkp.vehicle = spawnpoint.vehicle    -- Fix spawn'n'blow
		bkp.interior = spawnpoint.interior
	end
	-- Validate some bkp variables
	if type(bkp.rotation) ~= "table" or #bkp.rotation < 3 then
		bkp.rotation = {0, 0, 0}
	end

	local rx, ry, rz = unpack(bkp.rotation)
	local x, y, z = unpack(bkp.position)
	
	spawnPlayer(player, x, y, z, rz or 0, getElementModel(player), bkp.interior or 0)
	if (bkp.skin) then
		setElementModel(player, bkp.skin)
	end
	if (bkp.borrowed) then 
		-- Create our own vehicle if we hit the checkpoint with a vehicle that isn't the 'main'
		if (isElement(bkp.original) and not getVehicleController(bkp.original)) then
			vehicle = bkp.original
		else
			vehicle = spawnInteractiveVehicle(bkp.borrowed)
			setElementData(vehicle, "raceiv.taken", true)
		end
	end
	if (bkp.borrowed or bkp.onfoot) then
		-- Move our main vehicle back to where it was in case you drove off with it, then died, and respawned next to where it was but now it's gone
        setElementVelocity( vehicle2, 0,0,0 )
        setElementAngularVelocity( vehicle2, 0,0,0 )
		local rx2, ry2, rz2 = unpack(bkp.rotation2)
		local x2, y2, z2 = unpack(bkp.position2)
		setElementPosition(vehicle2, x2, y2, z2)
		setElementInterior(vehicle2, bkp.interior2)
		setElementRotation(vehicle2, rx2 or 0, ry2 or 0, rz2 or 0)
		if not bDontFix then
			fixVehicle(vehicle2)
		end
		setVehicleID(vehicle2, 481)	-- BMX (fix engine sound)
		if getElementModel(vehicle2) ~= bkp.vehicle2 then
			setVehicleID(vehicle2, bkp.vehicle2)
		end
		setVehicleLandingGearDown(vehicle2,bkp.geardown2)	
		
		removeVehicleUpgrade(vehicle2, 1010) -- remove nitro
		if bkp.hasNitro2 then
			addVehicleUpgrade(vehicle2, 1010) -- add nos if player had nos
		end
	end
	if vehicle and not bkp.onfoot then
        setElementVelocity( vehicle, 0,0,0 )
        setElementAngularVelocity( vehicle, 0,0,0 )
		setElementInterior(vehicle, bkp.interior or 0)
		setElementPosition(vehicle, x, y, z)
		setElementRotation(vehicle, rx or 0, ry or 0, rz or 0)
		if not bDontFix then
			fixVehicle(vehicle)
		end
		setVehicleID(vehicle, 481)	-- BMX (fix engine sound)
		if getElementModel(vehicle) ~= bkp.vehicle then
			setVehicleID(vehicle, bkp.vehicle)
		end

		warpPedIntoVehicle(player, vehicle)	
		setVehicleLandingGearDown(vehicle,bkp.geardown)		

		RaceMode.playerFreeze(player, true, bDontFix, bkp.onfoot)
        outputDebug( 'MISC', 'restorePlayer: setElementFrozen true for ' .. tostring(getPlayerName(player)) .. '  vehicle:' .. tostring(vehicle) )
		removeVehicleUpgrade(vehicle, 1010) -- remove nitro
		if bkp.hasNitro then
			addVehicleUpgrade(vehicle, 1010) -- add nos if player had nos
		end

		triggerClientEvent(player, 'race:recallNosLevel', resourceRoot, checkpoint)

		TimerManager.destroyTimersFor("unfreeze",player)
		TimerManager.createTimerFor("map","unfreeze",player):setTimer(restorePlayerUnfreeze, 2000, 1, id, player, bDontFix)
	elseif (bkp.onfoot) then -- S: for foot races

		RaceMode.playerFreeze(player, true, bDontFix, bkp.onfoot)
		if (bkp.jetpack) then
			setPedWearingJetpack(player, true)
		end
		
		outputDebug( 'MISC', 'restorePlayer: setElementFrozen true for ' .. tostring(getPlayerName(player)) .. '  vehicle: on foot' )

		TimerManager.destroyTimersFor("unfreeze",player)
		TimerManager.createTimerFor("map","unfreeze",player):setTimer(restorePlayerUnfreeze, 2000, 1, id, player, bDontFix)
	end
    setCameraTarget(player)
	setPlayerStatus( player, "alive", "" )
	
	if (checkpoint > 1) then
		if g_Checkpoints[checkpoint - 1].trigger then
			callTrigger(g_Checkpoints[checkpoint - 1].trigger, player)
		end
	elseif (spawnpoint.trigger) then
		callTrigger(spawnpoint.trigger, player)
	end

	clientCall(player, 'remoteSoonFadeIn', bNoFade )
end

function restorePlayerUnfreeze(id, player, bDontFix)
	if not isValidPlayer(player) then
		return
	end
	RaceMode.playerUnfreeze(player, bDontFix)
	local vehicle = getPedOccupiedVehicle(player)
	local vehicle2 = RaceMode.getPlayerVehicle(player)
	if (not vehicle) then
		vehicle = vehicle2
	end
    outputDebug( 'MISC', 'restorePlayerUnfreeze: vehicle false for ' .. tostring(getPlayerName(player)) .. '  vehicle:' .. tostring(vehicle) )
	local checkpointNum = getPlayerCurrentCheckpoint(player) - 1
	local bkp = RaceMode.instances[id].checkpointBackups[player][checkpointNum]
	if (bkp.onfoot or bkp.borrowed) then
		setElementVelocity(vehicle2, unpack(bkp.velocity2))
		setElementAngularVelocity(vehicle2, unpack(bkp.turnvelocity2))
	end
	if (bkp.onfoot) then
		setElementVelocity(player, unpack(bkp.velocity))
	else
		setElementVelocity(vehicle, unpack(bkp.velocity))
		setElementAngularVelocity(vehicle, unpack(bkp.turnvelocity))
		triggerClientEvent(player, 'race:startNosAgain', resourceRoot, checkpointNum)
	end
end

--------------------------------------
-- For use when starting or respawing
--------------------------------------
function RaceMode.playerFreeze(player, bRespawn, bDontFix, bOnFoot)
    toggleAllControls(player,true)
	clientCall( player, "updateVehicleWeapons" )
	local vehicle = getPedOccupiedVehicle(player)
	local vehicle2 = RaceMode.getPlayerVehicle(player)
	-- We can have multiple vehicles now, but not always.
	if (not vehicle) then
		vehicle = vehicle2
	end

	-- Apply addon overrides at start of new map
	if not bRespawn then
		AddonOverride.applyAll( player )
	end

	-- Reset move away stuff
	Override.setCollideOthers( "ForSpectating", {vehicle, vehicle2}, nil )
	Override.setCollideOthers( "ForMoveAway", {vehicle, vehicle2}, nil )
	Override.setAlpha( "ForMoveAway", {player, vehicle, vehicle2}, nil )

	-- Setup ghost mode for this vehicle
	Override.setCollideOthers( "ForGhostCollisions", {vehicle, vehicle2}, g_MapOptions.ghostmode and 0 or nil )
	Override.setAlpha( "ForGhostAlpha", {player, vehicle, vehicle2}, g_MapOptions.ghostmode and g_GameOptions.ghostalpha and g_GameOptions.ghostalphalevel or nil )

	-- Show non-ghost vehicles as semi-transparent while respawning
	Override.setAlpha( "ForRespawnEffect", {player, vehicle, vehicle2}, bRespawn and not g_MapOptions.ghostmode and 120 or nil )

	-- No collisions while frozen
	Override.setCollideOthers( "ForVehicleSpawnFreeze", {vehicle, vehicle2}, 0 )

	if not bDontFix then
		fixVehicle(vehicle)
		fixVehicle(vehicle2)
	end
	setElementFrozen(player, true)
	setElementFrozen(vehicle, true)
	setElementFrozen(vehicle2, true)
	setVehicleDamageProof(vehicle, true)
	setVehicleDamageProof(vehicle2, true)
	Override.setCollideWorld( "ForVehicleJudder", vehicle, 0 )
	Override.setCollideWorld( "ForVehicleJudder", vehicle2, 0 )
	Override.flushAll()
end

function RaceMode.playerUnfreeze(player, bDontFix)
	if not isValidPlayer(player) then
		return
	end
    toggleAllControls(player,true)
	clientCall( player, "updateVehicleWeapons" )
	local vehicle = getPedOccupiedVehicle(player)
	local vehicle2 = RaceMode.getPlayerVehicle(player)
	-- We can have multiple vehicles now, but not always.
	if (not vehicle) then
		vehicle = vehicle2
	end
	
	if not bDontFix then
		fixVehicle(vehicle)
		fixVehicle(vehicle2)
	end
    setVehicleDamageProof(vehicle, false)
    setVehicleDamageProof(vehicle2, false)
    setVehicleEngineState(vehicle, true)
    setVehicleEngineState(vehicle2, true)
	setElementFrozen(player, false)
	setElementFrozen(vehicle, false)
	setElementFrozen(vehicle2, false)

	-- Remove things added for freeze only
	Override.setCollideWorld( "ForVehicleJudder", {player, vehicle, vehicle2}, nil )
	Override.setCollideOthers( "ForVehicleSpawnFreeze", {player, vehicle, vehicle2}, nil )
	Override.setAlpha( "ForRespawnEffect", {player, vehicle, vehicle2}, nil )
	Override.flushAll()
end
--------------------------------------

-- addCommandHandler("unequipJetpack", function(player)
	-- if (isPedWearingJetpack(player) and isPedOnGround(player)) then
		-- setPedWearingJetpack(player, false)
	-- end
-- end
-- bindKey( next(getBoundKeys"enter_exit"), "down", "unequipJetpack")

-- Handle admin panel unfreeze
addEventHandler ( "onPlayerFreeze", root,
	function ( state )
		local player = source
		if not state then
			TimerManager.createTimerFor("map",player):setTimer( clientCall, 200, 1, player, "updateVehicleWeapons" )
		end
	end
)

-- Handle admin panel change vehicle
addEventHandler ( "aPlayer", root,
	function ( player, cmd, arg )
		if cmd == "givevehicle" then
			TimerManager.createTimerFor("map",player):setTimer( clientCall, 200, 1, player, "updateVehicleWeapons" )
		end
	end
)


function RaceMode:onPlayerQuit(player)
	self.checkpointBackups[player] = nil
	removeActivePlayer( player )
	if g_MapOptions.respawn == 'none' then
		if getActivePlayerCount() < 1 and g_CurrentRaceMode.running then
			RaceMode.endMap()
		end
	end
end

function RaceMode:destroy()
	if self.rankingBoard then
		self.rankingBoard:destroy()
		self.rankingBoard = nil
	end
	TimerManager.destroyTimersFor("checkpointBackup")
	RaceMode.instances[self.id] = nil
end

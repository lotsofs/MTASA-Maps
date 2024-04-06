local honkProgress = 0
local honking = false
local timer = nil

bindKey("horn", "down", function()
	honking = true
end)
bindKey("horn", "up", function()
	honking = false
end)

addEvent(g_STOP_JOB_EVENT, true)
addEventHandler(g_STOP_JOB_EVENT, resourceRoot, function(id)
	cleanupJobs()
end)

addEvent(g_FINISH_JOB_EVENT, true)
addEventHandler(g_FINISH_JOB_EVENT, resourceRoot, function(id)
	cleanupJobs()
end)

addEvent(g_JOB_STATUS_UPDATE_EVENT, true)
addEventHandler(g_JOB_STATUS_UPDATE_EVENT, resourceRoot, function(id, type, data)
	if type == g_DELIVERY_JOB.type then
		triggerEvent(g_SHOW_DELIVERY_TARGET_EVENT, resourceRoot, data.pos)
		if data.subtype == g_DELIVERY_JOB.subtypes.DELIVERY then
			local col = createColCircle(data.pos.x, data.pos.y, g_DELIVERY_TARGET_SIZE)

			function finishDelivery(element)
				if getPedOccupiedVehicle(localPlayer) ~= element then return end
				removeEventHandler("onClientColShapeHit", col, finishDelivery)

				triggerEvent(g_HIDE_DELIVERY_TARGET_EVENT, resourceRoot)
				triggerServerEvent(g_FINISH_JOB_EVENT, resourceRoot, id)
			end
			addEventHandler("onClientColShapeHit", col, finishDelivery)
		elseif data.subtype == g_DELIVERY_JOB.subtypes.ELIMINATION then
			local ped = createPed(127, data.pos.x, data.pos.y, data.pos.z)
			setElementHealth(ped, 30)
			setElementRotation(ped, data.rot.x, data.rot.y, data.rot.z)
			setPedAnimation(ped, "dealer", "dealer_deal")

			local firstHit = false
			addEventHandler("onClientPedWasted", ped, function()
				triggerServerEvent(g_FINISH_JOB_EVENT, resourceRoot, id)
			end)
			addEventHandler("onClientPedDamage", ped, function()
				setPedControlState(ped, "forwards", true)
				setPedCameraRotation(ped, getPedCameraRotation(localPlayer) - (45 + math.random() * 90))
				setPedLookAt(ped, 0, 0, 0, -1, 1000, localPlayer)
				if not firstHit then
					firstHit = true
					triggerEvent(g_HIDE_DELIVERY_TARGET_EVENT, resourceRoot)
				end
			end)
		end
	elseif type == g_EXTORTION_JOB.type then
		honkProgress = 0
		timer = setTimer(function()
			if honkProgress >= 1 then
				triggerServerEvent(g_FINISH_JOB_EVENT, resourceRoot, id)
			end

			if honking then
				honkProgress = math.min(honkProgress + g_EXTORTION_JOB.progressRate, 1)
			else
				honkProgress = math.max(honkProgress - g_EXTORTION_JOB.decayRate, 0)
			end

			triggerEvent(g_SHOW_PROGRESS_BAR_EVENT, resourceRoot)
			triggerEvent(g_UPDATE_PROGRESS_BAR_EVENT, resourceRoot, { progress = honkProgress })
		end, g_EXTORTION_JOB.interval, 0)
	elseif type == g_GROUP_JOB.type then
		if data.playerCount < g_GROUP_JOB.minPlayers then
			triggerEvent(g_PAUSE_JOB_EVENT, resourceRoot, data.playerCount)
		else
			triggerEvent(g_RESUME_JOB_EVENT, resourceRoot, data.playerCount)
		end
		triggerEvent(g_SHOW_PROGRESS_BAR_EVENT, resourceRoot)
		triggerEvent(g_UPDATE_PROGRESS_BAR_EVENT, resourceRoot, data)
	elseif data.progress then
		triggerEvent(g_SHOW_PROGRESS_BAR_EVENT, resourceRoot)
		triggerEvent(g_UPDATE_PROGRESS_BAR_EVENT, resourceRoot, data)
	end
end)

addEvent(g_GAME_STATE_UPDATE_EVENT, true)
addEventHandler(g_GAME_STATE_UPDATE_EVENT, resourceRoot, function(state)
	if state == g_COREGAME_STATE then
		local team = getPlayerTeam(localPlayer)
		local policeTeam = getTeamFromName(g_POLICE_TEAM_NAME)

		if team == policeTeam then
			return
		end

		local cops = getPlayersInTeam(policeTeam)
		for _, cop in ipairs(cops) do
			local vehicle = getPedOccupiedVehicle(cop)
			setVehicleSirensOn(vehicle, true)
		end
	elseif state == g_BADEND_STATE then
		-- drive to donut shop
		local marker = createMarker(1026, -1334, 12, "cylinder", 4, 181, 101, 29, 200)
		local blip = createBlip(1026, -1334, 13, 10)
		local col = createColCircle(1026, -1334, 4)
		function copend(element)
			removeEventHandler("onClientColShapeHit", col, copend)
			destroyElement(marker)
			destroyElement(blip)

			fadeCamera(false, 3)

			setTimer(function()
				triggerEvent("onClientCall_race", root, "checkpointReached", element)
				setTimer(function()
					fadeCamera(true, 1)
				end, 1000, 1)
			end, 5000, 1)
		end
		addEventHandler("onClientColShapeHit", col, copend)
	end
end)

-- suppress race mode error
addEvent("onClientCall_race", true)

function cleanupJobs()
	triggerEvent(g_HIDE_PROGRESS_BAR_EVENT	, resourceRoot)
	honkProgress = 0
	if isTimer(timer) then
		killTimer(timer)
	end
	timer = nil
end

bindKey("4", "down", function()
    print("4", getElementPosition(localPlayer))
    for _, ped in ipairs(getElementsByType("ped")) do
        if getElementModel(ped) == 127 then
            print("pos", getElementPosition(ped))
        end
    end
end)
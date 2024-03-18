local sGhost
local mGhostAllowed
local mGhost
local canHideThisMap = false
local raceState
local afkTriggerTime = 30

function init()
	mapStarted()
end
addEventHandler('onResourceStart', resourceRoot, init)

function mapStarted()
	sGhost = get("*race.ghostmode")
	mGhostAllowed = get("*race.ghostmode_map_can_override")
	mGhost = get(getResourceName(call(getResourceFromName("mapmanager"), "getRunningGamemodeMap"))..".ghostmode")

	if (mGhostAllowed=="true" and mGhost=="true") or (mGhostAllowed~="true" and sGhost=="true") then
		canHideThisMap = true
	else
		canHideThisMap = false
	end
end
addEventHandler("onMapStarting",getRootElement(),mapStarted)

function mapEnded()
	canHideThisMap = false
end
addEventHandler("onMapStopping",getRootElement(),mapEnded)

function hideCommand(player, hide, type)
	-- Store the ASS type if it's a legal type
	if type == "2" or type == "1" or type == "0" then
		setAccountData(getPlayerAccount(player), "ass.type", type)
		--outputChatBox("new type: " .. type .. " can hide this map:" .. tostring(canHideThisMap))

		triggerClientEvent(player, "receiveHideType", player, type)
	end
end
addCommandHandler("ass", hideCommand)
addCommandHandler("hide", hideCommand)

function getPlayerHideType(player)
	hideType = getAccountData(getPlayerAccount(player), "ass.type")

	if hideType == false or hideType == nil then
		hideType = "0"
	end
	return tostring(hideType)
end

addEvent( "clientAsksForHideType", true)
function clientAsksForHideType()
	triggerClientEvent(client, "receiveHideType", client, getPlayerHideType(client))
end
addEventHandler( "clientAsksForHideType", resourceRoot, clientAsksForHideType )

addEvent( "clientAsksForCanHide", true)
function clientAsksForCanHide()
	if canHideThisMap then
		triggerClientEvent(client, "canHide", client, getPlayerHideType(client))
	else
		triggerClientEvent(client, "cantHide", client, getPlayerHideType(client))
	end
end
addEventHandler( "clientAsksForCanHide", resourceRoot, clientAsksForCanHide )

function raceStateChanged(newStateName, oldStateName)
	raceState = newStateName

	if (raceState == "Running") then
		setTimer(afkCheck, 1000, 1)
	end
end
addEvent( "onRaceStateChanging", true )
addEventHandler( "onRaceStateChanging", resourceRoot, raceStateChanged )

function afkCheck()
	if raceState == "Running" or raceState == "MidMapVote" or raceState == "SomeoneWon" then

		for index, player in ipairs(getElementsByType("player")) do

			local idleTime = getPlayerIdleTime(player) / 1000

			if not isPedDead(player) and not getElementData(player, "race.spectating")
				and not isElementFrozen(getPedOccupiedVehicle(player)) then

				if idleTime >= afkTriggerTime - 5 then
					triggerClientEvent(player, "warnAFK", player)
				end

				if idleTime >= afkTriggerTime then
					triggerClientEvent(player, "goAFK", player)
				end

				if idleTime >= afkTriggerTime + 5 then
					triggerEvent('onRequestKillPlayer', player)
				end
			end

			--outputChatBox(tostring(idleTime))
		end

		setTimer(afkCheck, 1000, 1)

	end

end
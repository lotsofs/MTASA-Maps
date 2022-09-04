g_Triggers = {}

function processTriggers(triggers)
	g_Triggers = triggers
end

function destroyTriggers()
	for i, t in pairs(g_Triggers) do
		destroyElement(t)
	end
	g_Triggers = {}
end

function callTrigger(theTrigger, player)
	local trig
	for i, v in pairs(g_Triggers) do
		if (v.id == theTrigger) then
			trig = v
			break
		end
	end
	if (not trig) then
		return
	end
	if (string.sub(trig.action,1,7) == "Jetpack") then
		action_Jetpack(player, trig.boola)
	elseif (string.sub(trig.action,1,12) == "Exit Vehicle") then
		action_ExitVehicle(player, trig.boola)
	end
end

function action_ExitVehicle(player, arg)
	if (arg == "true") then
		removePedFromVehicle(player)
	else
		triggerClientEvent(player, "callTriggerOnClient", player, "Exit Vehicle")
	end
end

function action_Jetpack(player, arg)
	local state
	if (arg == "true") then
		state = true
	elseif (arg == "toggle") then
		state = not isPedWearingJetpack(player)
	else
		state = false
	end
	setPedWearingJetpack(player, state)
end
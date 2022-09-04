addEvent("callTriggerOnClient", true)
addEventHandler("callTriggerOnClient", resourceRoot, function(theTrigger, arg1, arg2, arg3)
	if (theTrigger == "Exit Vehicle") then
		setPedExitVehicle(g_Me)
	end
end)
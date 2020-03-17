function peds(newState, oldState)
	if (newState ~= "Running") then
		return
	end
	setPedAnimation(getElementByID("_SITTING_PED_01"), "ped", "seat_down", -1, false)
	setPedAnimation(getElementByID("_SITTING_PED_02"), "ped", "seat_down", -1, false)
	setPedAnimation(getElementByID("_SITTING_PED_03"), "ped", "seat_down", -1, false)
	setPedAnimation(getElementByID("_SITTING_PED_04"), "ped", "seat_down", -1, false)
	setPedAnimation(getElementByID("_SITTING_PED_05"), "ped", "seat_down", -1, false)
	setPedAnimation(getElementByID("_SITTING_PED_06"), "ped", "seat_down", -1, false)
	setElementHealth(getElementByID("_DYING_PED_01"), 0)
end
addEvent("onRaceStateChanging", true)
addEventHandler("onRaceStateChanging", root, peds) 
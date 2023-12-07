AT_APPROACH_DETECTOR = createColSphere(-51.1, -192.5, -3, 900)

AT_RAMPS = {
    [1] = getElementByID("AT_RAMP_1"),
    [2] = getElementByID("AT_RAMP_2"),
    [3] = getElementByID("AT_RAMP_3"),
    [4] = getElementByID("AT_RAMP_4"),
    [5] = getElementByID("AT_RAMP_5"),
    [6] = getElementByID("AT_RAMP_6"),
    [7] = getElementByID("AT_RAMP_7"),
    [8] = getElementByID("AT_RAMP_8"),
    [9] = getElementByID("AT_RAMP_9"),
    [10] = getElementByID("AT_RAMP_10"),
    [11] = getElementByID("AT_RAMP_11")
}

function hideRamps()
	setElementPosition(AT_RAMPS[1], -51.1, -192.5, -33)
	setElementPosition(AT_RAMPS[2], -50.7, -197.5, -35.1)
	setElementPosition(AT_RAMPS[3], -41.2, -202.2, -35.3)
    setElementPosition(AT_RAMPS[4], -35.8, -211.5, -35.7)
    setElementPosition(AT_RAMPS[5], -48.2, -207.7, -37.9)
    setElementPosition(AT_RAMPS[6], -54.1, -206.6, -35.8)
    setElementPosition(AT_RAMPS[7], -63.9, -192, -39.2)
    setElementPosition(AT_RAMPS[8], -15.6, -199.8, -50.2)
    setElementPosition(AT_RAMPS[9], -48.9, -204.1, -36.8)
    setElementPosition(AT_RAMPS[10], -69.5, -196.5, -32.4)
    setElementPosition(AT_RAMPS[11], -22.2, -203.9, -42.9)
    if (AT_RAMPS[12]) then
        setElementPosition(AT_RAMPS[12], -51.1, -192.5, -33)
        setElementPosition(AT_RAMPS[13], -48.9, -204.1, -36.8)
    end
end

function showRamps()
	setElementPosition(AT_RAMPS[1], -51.1, -192.5, -3)
	setElementPosition(AT_RAMPS[2], -50.7, -197.5, 5.1)
	setElementPosition(AT_RAMPS[3], -41.2, -202.2, 5.3)
    setElementPosition(AT_RAMPS[4], -35.8, -211.5, 5.7)
    setElementPosition(AT_RAMPS[5], -48.2, -207.7, 7.9)
    setElementPosition(AT_RAMPS[6], -54.1, -206.6, 5.8)
    setElementPosition(AT_RAMPS[7], -63.9, -192, -9.2)
    setElementPosition(AT_RAMPS[8], -15.6, -199.8, -20.2)
    setElementPosition(AT_RAMPS[9], -48.9, -204.1, 6.8)
    setElementPosition(AT_RAMPS[10], -69.5, -196.5, 2.4)
    setElementPosition(AT_RAMPS[11], -22.2, -203.9, -12.9)
    if (not AT_RAMPS[12]) then
        AT_RAMPS[12] = createObject(18256, -51.1, -192.5, -3, 359.022, 347.998, 268.496, true)
        AT_RAMPS[13] = createObject(16305, -48.9, -204.1, 6.8, 0, 0, 340, true)
        setObjectScale ( AT_RAMPS[13], 2)
    else
        setElementPosition(AT_RAMPS[12], -51.1, -192.5, -3)
        setElementPosition(AT_RAMPS[13], -48.9, -204.1, 6.8)
    end

end

function erectAtHelperRamp(element, matchingDimension)
	if (element ~= localPlayer) then
		return
	end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (not vehicle) then
		return
	end
	vehicle = getElementModel(vehicle)
	if (not vehicle) then
		return
	end
	-- if (MEDIUM_PLANES[vehicle]) then
	-- 	CRANE1_STATE = "waiting for boat"
	-- 	CRANE2_STATE = "waiting for boat"
	-- end
    if (vehicle == 577) then -- at400
        showRamps()
        
        if (not AT_TUTORIAL_SHOWN) then
            AT_TUTORIAL_SHOWN = true
            MID_PLAY_BLURB = "Hey! Someone spilled a lot of junk next to the delivery point. That might come in handy!"
            SHOW_MID_PLAY_TUTORIAL = true
            setTimer(function()
                SHOW_MID_PLAY_TUTORIAL = false
            end, 7000, 1)
        end
    elseif (vehicle ~= 577 and AT_TUTORIAL_SHOWN) then -- at400
        hideRamps()
        
        AT_TUTORIAL_SHOWN = false
        MID_PLAY_BLURB = "The large mess has unfortunately been cleaned up."
        SHOW_MID_PLAY_TUTORIAL = true
        setTimer(function()
            SHOW_MID_PLAY_TUTORIAL = false
        end, 7000, 1)
    end
end
addEventHandler("onClientColShapeHit", AT_APPROACH_DETECTOR, erectAtHelperRamp)



screenWidth, screenHeight = guiGetScreenSize()
-- local fontBold = dxCreateFont("tahoma.ttf", 9)


function getKeyNames()
	controlUp = next(getBoundKeys("special_control_up"))
	controlDown = next(getBoundKeys("special_control_down"))
	controlRight = next(getBoundKeys("special_control_right"))
	controlLeft = next(getBoundKeys("special_control_left"))
	controlSub = next(getBoundKeys("sub_mission"))
end
getKeyNames();

function drawBorderedText(text, borderSize, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	text2 = string.gsub(text, "#%x%x%x%x%x%x", "")
	-- width = width * screenWidth
	-- height = height * screenHeight
	-- width2 = width2 * screenWidth
	-- height2 = height2 * screenHeight
	-- size = screenWidth * size * 0.0005
	-- borderSize = size

	-- dxDrawText(text2, width+borderSize, height, width2+borderSize, height2, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	-- dxDrawText(text2, width, height+borderSize, width2, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	-- dxDrawText(text2, width, height-borderSize, width2, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	-- dxDrawText(text2, width-borderSize, height, width2-borderSize, height2, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text2, width+borderSize, height+borderSize, width2+borderSize, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	-- dxDrawText(text2, width-borderSize, height-borderSize, width2-borderSize, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	-- dxDrawText(text2, width+borderSize, height-borderSize, width2+borderSize, height2-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	-- dxDrawText(text2, width-borderSize, height+borderSize, width2-borderSize, height2+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
	dxDrawText(text, width, height, width2, height2, color, size, font, horizAlign, vertiAlign, bool1, bool2, bool3, bool4)
end

-- sortedCars = {}
-- unassignedCars = {}

function drawHud()
	if (isSetup == false) then
		return
	end
	if (isPlayerMapVisible() == true) then
		return
	end
	drawBottomHud()
	drawLeftHud()
end

function drawBottomHud()
	local blurb = "Strategizer Race!!: In this race each player gets the same 10 tracks and the same 10 vehicles. You get 5 minutes to assign one vehicle to each track. After that, the race begins and each player will race the tracks with their chosen vehicles."
	drawBorderedText(blurb, 1, screenWidth*0.25, screenHeight - 255, 800, 0.9, tocolor(255, 255, 255, 255), 1, "default-bold", "left", "top", false, true, true, false)
	local controls = "Controls:\n#dbc191"
	controls = controls .. controlLeft .. "#ffffff & #dbc191" .. controlRight .. "#ffffff: Change Vehicles.\n#dbc191"
	controls = controls .. controlUp .. "#ffffff & #dbc191" .. controlDown .. "#ffffff: Change Tracks.\n#dbc191"
	controls = controls .. controlSub .. "#ffffff: Assign current car to current track.\n#dbc191"
	controls = controls .. "F9#ffffff: View Goal/More Information/Help.\n#dbc191"
	controls = controls .. "F11#ffffff: View Map."
	drawBorderedText(controls, 2, screenWidth*0.25, screenHeight - 180, 0.8, 0.9, tocolor(255, 255, 255, 255), 2, "default-bold", "left", "top", false, true, true, true)
end

function drawLeftHud()
	if (#selectedTrackNames == 0) then
		drawBorderedText("Generating tracks...", 1, 22, 196, 0.8, 0.9, tocolor(255, 255, 255, 255), 1, "default-bold", "left", "top", false, true, true, false)
		return
	end
	drawBorderedText("Assigned Car - (Est. Length) Track - Assigned Car", 1, 22, 196, 0.8, 0.9, tocolor(255, 255, 255, 255), 1, "default-bold", "left", "top", false, true, true, false)
	for i = 1, 10 do
		text = selectedTrackNames[i]
		if (sortedCars[i] ~= nil) then
			text = getVehicleNameFromModel(sortedCars[i]) .. " - " .. text
		else 
			text = "<none> - " .. text
		end
		if (i == currentTrack) then
			text = text .. " <==="
		end
		drawBorderedText(text, 1, 22, 198 + (i*22), 0.8, 0.9, tocolor(colors[i][1], colors[i][2], colors[i][3], 255), 1, "default-bold", "left", "top", false, true, true, true)
	end
	if (#unassignedCars > 0) then
		text = "Unassigned Cars: "
		for i, car in pairs(unassignedCars) do
			text = text .. getVehicleNameFromModel(car)
			if (i < #unassignedCars) then
				text = text .. ", "
			end
		end
		drawBorderedText(text, 1, 22, 206 + (11*22), 350, 0.9, tocolor(255, 255, 255, 255), 1, "default-bold", "left", "top", false, true, true, false)
	end

end
addEventHandler("onClientRender", root, drawHud)
